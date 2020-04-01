local ActivityThreeYuanBuyUI = class("ActivityThreeYuanBuyUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActivityThreeYuanBuyUI:ctor(data)
	self.uiIndex = GAME_UI.UI_ACTIVITY_EIGHT_YUAN_BUY
    self.data = data
    UserData:getUserObj().activity.money_buy3 = self.data.money_buy3
end

function ActivityThreeYuanBuyUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = self.root:getChildByName('bg_img_1')

    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            UserData:getUserObj().activity.money_buy3 = self.data.money_buy3
            MainSceneMgr:hideEightYuanBuyUI()
        end
    end)
    self.closebtn = closebtn
    self.bgimg2 = bgimg2

    local winsize = cc.Director:getInstance():getWinSize()
    bgimg1:setContentSize(winsize)
    bgimg1:setPosition(cc.p(winsize.width/2,winsize.height/2))
    bgimg2:setPosition(cc.p(winsize.width/2 - (480 - 438),winsize.height - (640 - 320)))

    
    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(425, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES18'), 22, cc.c4b(254,227,134,255))
	re1:setStroke(cc.c4b(140,56,0,255),1)
    --re1:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re1:setFont('font/gamefont.ttf')
    
	-- local re2 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES19'),tonumber(GlobalApi:getGlobalValue('eightYuanBuyCashNum'))), 22, COLOR_TYPE.GREEN)
	-- re2:setStroke(cc.c4b(140,56,0,255),1)
 --    --re2:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
 --    re2:setFont('font/gamefont.ttf')

	-- local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES20'), 22, cc.c4b(254,227,134,255))
	-- re3:setStroke(cc.c4b(140,56,0,255),1)
 --    --re3:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
 --    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	-- richText:addElement(re2)
 --    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(550,290))
    -- self.bgimg2:addChild(richText)
    richText:format(true)

    -- 
    local buyBtn = self.bgimg2:getChildByName('buy_btn')
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rechageData = GameData:getConfData('recharge')
            if not rechageData[11] then
                return
            end
            if self.data.money_buy3.status == 0 then -- 充值
                self.buyBtn:setTouchEnabled(false)
                self.buyBtn:setBright(false)
                --self.closebtn:setTouchEnabled(false)
                -- local function callBack(obj)
                --     if obj.code == 0 then
                --         self.data.money_buy3.status = 1
                --         self:refreshBtnStatus()
                --         --self.closebtn:setTouchEnabled(true)
                --     else
                --         self.buyBtn:setTouchEnabled(true)
                --         self.buyBtn:setBright(true)
                --         --self.closebtn:setTouchEnabled(true)
                --     end
                -- end
                -- RechargeMgr:specialRecharge(11,callBack)
                self.buyBtn:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
					self.buyBtn:setTouchEnabled(true)
                    self.buyBtn:setBright(true)
                    --self.closebtn:setTouchEnabled(true)
                end)))

                RechargeMgr:pay(rechageData[11], function (code)
                    self:buyCallback(code)
                end)
            end
        end
    end)
    self.buyBtn = buyBtn
    self.buyBtnTx = buyBtn:getChildByName('tx')


    local avEightYuanBuyConf = GameData:getConfData("aveightyuanbuy")
    local awardData = avEightYuanBuyConf[1].awards
    local disPlayData = DisplayData:getDisplayObjs(awardData)

    for i = 1,#disPlayData do
        local icon = self.bgimg2:getChildByName("icon_" .. i)
        local awards = disPlayData[i]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        -- 名字
        local name = cc.Label:createWithTTF('', 'font/gamefont.ttf', 22)
		name:setAnchorPoint(cc.p(0.5, 0.5))
		name:setPosition(cc.p(47, -20))
        cell.awardBgImg:addChild(name)

        name:setString(awards:getName())
        name:setColor(awards:getNameColor())
        name:enableOutline(awards:getNameOutlineColor(),1)
        name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    end

    self.getBtns = {}
    for i = 1,1 do
        local getBtn = bgimg2:getChildByName('get_btn')
        getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES9'))
        table.insert(self.getBtns,getBtn)
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.money_buy3.status == 1 then -- 领取
                    local function callBack()
                        local args = {
                            id = 1
                        }
                        MessageMgr:sendPost('get_money_buy3_reward','activity',json.encode(args),function (jsonObj)
                        print(json.encode(jsonObj))
                            if jsonObj.code == 0 then
                                local awards = jsonObj.data.awards
                                if awards then
                                    GlobalApi:parseAwardData(awards)
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                                end
                                local costs = jsonObj.data.costs
                                if costs then
                                    GlobalApi:parseAwardData(costs)
                                end
                                self.data.money_buy3.status = 2
                                self:refreshBtnStatus()
                                if not UserData:getUserObj().activity['promote_get_soul'] then
                                    UserData:getUserObj().activity['promote_get_soul'] = {}
                                end
                                UserData:getUserObj().activity['promote_get_soul']['time'] = jsonObj.data.time
                            elseif jsonObj.code == 100 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
                            end
                        end)
                    end
                    callBack()
                end
            end
        end)
    end
    
    --local btn = HelpMgr:getBtn(27)
    --btn:setScale(0.9)
    --btn:setPosition(cc.p(50 ,422))
    --bgimg2:addChild(btn)

    -- local infoLabel = bgimg2:getChildByName("info_tx")
    -- local lv = GameData:getConfData('moduleopen')['promote'].level
    -- infoLabel:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES22'),lv))
    -- infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    self:refreshBtnStatus()

    CustomEventMgr:addEventListener("get_recharge_raward",self,function (code) 
        self:buyCallback(code)
    end)

    local function onNodeEvent(event)
        if "exit" == event then
            -- print("注销回调函数")
            CustomEventMgr:removeEventListener("get_recharge_raward",self)
        end
    end
    self.root:registerScriptHandler(onNodeEvent)

end


function ActivityThreeYuanBuyUI:buyCallback(code)
    print("        buyCallback    code   =   ",code)
    if code == 1 then -- sdk购买成功
        self.data.money_buy3.status = 1
        self:refreshBtnStatus()
        --self.closebtn:setTouchEnabled(true)
    else  -- sdk购买失败
        self.buyBtn:setTouchEnabled(true)
        self.buyBtn:setBright(true)
        --self.closebtn:setTouchEnabled(true)
    end

    self:refreshBtnStatus()
end

-- 刷新按钮状态
function ActivityThreeYuanBuyUI:refreshBtnStatus()
    for i = 1,1 do
        self.getBtns[i]:setVisible(false)
    end
    if self.data.money_buy3.status == 0 then -- 待充值
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(true)
        self.buyBtn:setTouchEnabled(true)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES21'))
    elseif self.data.money_buy3.status == 1 then -- 待领取
        self.buyBtn:setVisible(false)
        for i = 1,1 do
            self.getBtns[i]:setVisible(true)
        end
    elseif self.data.money_buy3.status == 2 then -- 已领取
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(false)
        self.buyBtn:setTouchEnabled(false)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES10'))
    end
end

return ActivityThreeYuanBuyUI