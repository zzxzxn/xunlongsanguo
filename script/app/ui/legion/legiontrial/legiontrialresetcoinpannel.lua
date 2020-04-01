local LegionTrialResetCoinPannelUI = class("LegionTrialResetCoinPannelUI", BaseUI)

function LegionTrialResetCoinPannelUI:ctor(trial,round,index,callBack,callBack2)
    self.uiIndex = GAME_UI.UI_LEGION_TRIAL_RESET_COIN_PANNEL
    self.trial = trial
    self.round = round
    self.index = index
    self.callBack = callBack
    self.callBack2 = callBack2

    self.legionTrialCoinResetCostConf = GameData:getConfData('legiontrialcoinresetcost')
    self.legiontTialCoins = GameData:getConfData('legiontrialcoins')
end

function LegionTrialResetCoinPannelUI:init()
    local activeBgImg = self.root:getChildByName("active_bg_img")
    local activeImg = activeBgImg:getChildByName("active_img")
    self:adaptUI(activeBgImg, activeImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    activeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    self.neiBgImg = activeImg:getChildByName('nei_bg_img')
    local closeBtn = activeImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
            self.callBack2()
        end
    end)
    local titleTx = activeImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC19'))

    local cancleBtn = self.neiBgImg:getChildByName('cancle_btn')
    cancleBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC17'))
    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
            self.callBack2()
        end
    end)

    local reset_count = self.trial.reset_count  -- 已经重置的次数
    local next_reset = reset_count + 1
    if next_reset >= #self.legionTrialCoinResetCostConf then
        next_reset = #self.legionTrialCoinResetCostConf
    end
    local confData = self.legionTrialCoinResetCostConf[next_reset]
    local costAward = confData.cost
    
    local cost1
	if #costAward ~= 0 then
		cost1 = DisplayData:getDisplayObj(costAward[1])
	end


    local coinId = self.trial.round[tostring(self.round)].coins[tostring(self.index)]

    local frame = self.neiBgImg:getChildByName('frame')
    local icon = frame:getChildByName('icon')
    icon:ignoreContentAdaptWithSize(true)
    icon:loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coinId].icon)

    local costDes2 = self.neiBgImg:getChildByName('cost_des2')
    costDes2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC21'))

    local costDes1 = self.neiBgImg:getChildByName('cost_des1')
    costDes1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC22'))

    local costNum = self.neiBgImg:getChildByName('cost_num')
    local img = self.neiBgImg:getChildByName('img')

    local costFreeDes = self.neiBgImg:getChildByName('cost_free_des')
    costFreeDes:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC23'))

    if cost1 then   -- 消耗元宝
        costNum:setVisible(true)
        costDes1:setVisible(true)
        img:setVisible(true)

        costFreeDes:setVisible(false)
        costNum:setString(cost1:getNum())
    else
        costNum:setVisible(false)
        costDes1:setVisible(false)
        img:setVisible(false)
        costFreeDes:setVisible(true)
    end

    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC20'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callBack(data)
                LegionTrialMgr:hideLegionTrialResetCoinPannelUI()
                
                local reset_count2 = self.trial.reset_count
                reset_count2 = reset_count2 + 1
                if reset_count2 >= #self.legionTrialCoinResetCostConf then
                    reset_count2 = #self.legionTrialCoinResetCostConf
                end
                self.trial.reset_count = reset_count2
                self.callBack2()
                self.callBack(data,reset_count2)
            end
            if cost1 then   
                local cash = UserData:getUserObj():getCash()
                if cash >= cost1:getNum() then
                    LegionTrialMgr:legionTrialResetExploreCoinFromServer(self.round,self.index,callBack)
                else
                    UserData:getUserObj():cost('cash',cost1:getNum(),function()
                        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH'),cost1:getNum()), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            LegionTrialMgr:legionTrialResetExploreCoinFromServer(self.round,self.index,callBack)
                        end)
                    end)
                end
            else
                LegionTrialMgr:legionTrialResetExploreCoinFromServer(self.round,self.index,callBack)
            end

        end
    end)


end

return LegionTrialResetCoinPannelUI