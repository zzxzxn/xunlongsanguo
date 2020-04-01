local TerritorialWarsMsgUI = class("TerritorialWarsMsg", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TerritorialWarsMsgUI:ctor(nType,win,staying)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_MESSAGEBOX
    self.nType = nType       --1:战斗结果 2：行动力购买 3：布阵超时
    if self.nType == 1 or self.nType == 4 then
        self.cost = staying
        self.win = win
    end
end

function TerritorialWarsMsgUI:init()

    local bgimg = self.root:getChildByName('bg_img')
    local msgimg = bgimg:getChildByName('msg_img')
    self:adaptUI(bgimg,msgimg)
    local closeBtn = msgimg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideMsgUI()
        end
    end)

    local innerBg = msgimg:getChildByName('inner_bg')
    self.titleTx = innerBg:getChildByName('title_tx')
    self.resultBg = innerBg:getChildByName('result_bg')
    self.buyBg = innerBg:getChildByName('buy_bg')
    if self.nType == 1 or self.nType == 4 then
        self.resultBg:setVisible(true)
        self.buyBg:setVisible(false)
        self:showBattleResult()
    elseif self.nType == 2 then
        self.resultBg:setVisible(false)
        self.buyBg:setVisible(true)
        self:showBuyActionPoint()
    elseif self.nType == 3 then
        self.resultBg:setVisible(true)
        self.buyBg:setVisible(false)
        self:showBattleOutTime()
    end
  
end

function TerritorialWarsMsgUI:showBattleOutTime()
    
    self.titleTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG13'))
    local infoTx = self.resultBg:getChildByName('result_text5')
    infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG14'))

    for i=1,4 do
        local infoTx = self.resultBg:getChildByName('result_text' .. i)
        infoTx:setVisible(false)
    end
    local icon = self.resultBg:getChildByName('staying_icon')
    icon:setVisible(false)

    local confirmBtn = self.resultBg:getChildByName('confirm_btn')
    local btnTx = confirmBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    confirmBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:setBattleEnd(nil,nil,nil)
            TerritorialWarMgr:hideMsgUI()
        end
    end)
end

function TerritorialWarsMsgUI:showBattleResult()
    
    if self.win == nil or self.cost == nil then
        return
    end

    local resultStr = self.win and GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG6') or GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG5')
    local titleStr = self.win and GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG10') or GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG9')

    --平局特殊显示
    if self.nType == 4 then
        resultStr = GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG15')
        titleStr = GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG9')
    end

    local result = self.resultBg:getChildByName('result_text1')
    result:setString(resultStr)
    self.titleTx:setString(titleStr)

    local infoTx = self.resultBg:getChildByName('result_text2')
    infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG7'))
    infoTx:setVisible(not self.win)

    local infoTx3 = self.resultBg:getChildByName('result_text3')
    infoTx3:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG8'))
    infoTx3:setVisible(self.win)

    local icon = self.resultBg:getChildByName('staying_icon')
    local infoTx4 = self.resultBg:getChildByName('result_text4')
    infoTx4:setString(self.cost)
    icon:setVisible(self.win)
    infoTx4:setVisible(self.win)

    if self.nType == 4 then
       icon:setVisible(false)
       infoTx3:setVisible(false)
       infoTx4:setVisible(false)
       infoTx:setVisible(true)
    end

    local confirmBtn = self.resultBg:getChildByName('confirm_btn')
    local btnTx = confirmBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    confirmBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:setBattleEnd(nil,nil,nil)
            TerritorialWarMgr:hideMsgUI()
        end
    end)
end
 
function TerritorialWarsMsgUI:updateInfo()
    
    local vip = UserData:getUserObj():getVip()
    local totalCount = GameData:getConfData('vip')[tostring(vip)].actionBuy
    local buyCount = tonumber(UserData:getUserObj():getTerritorialWar().buy_action_count)
    local count = totalCount - buyCount
    
    self.countTx:setString(count)
    local color =  (count == 0) and COLOR_TYPE.RED or COLOR_TYPE.GREEN
    self.countTx:setColor(color)

    local config = GameData:getConfData('dfactioncost')
    local nextCout = buyCount + 1
    if nextCout > #config then
        nextCout = #config
    end

    local costItem = DisplayData:getDisplayObj(config[nextCout].cost[1]) 
    self.haveCash = UserData:getUserObj():getCash()
    self.needCash = costItem:getNum()
    if self.needCash == 0 then
      self.cashTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG12')) 
    else
        self.cashTx:setString(self.needCash)
    end
    local color =  (self.needCash > self.haveCash) and COLOR_TYPE.RED or COLOR_TYPE.GREEN
    self.cashTx:setColor(color)

end

function TerritorialWarsMsgUI:showBuyActionPoint()
    
    self.titleTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG11'))
    local awardNode = self.buyBg:getChildByName('award_node')
    for i=1,3 do
        local infoTxt = self.buyBg:getChildByName('info_tx' .. i)
        infoTxt:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG' .. i))
    end
    self.countTx = self.buyBg:getChildByName('info_tx4')
    
    local dfbaseconfig = GameData:getConfData('dfbasepara')
    local num = tonumber(dfbaseconfig['actionBuyAward'].value[1])
    local displayobj = DisplayData:getDisplayObj({'user','action_point',num})
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj, awardNode)
    self.cashTx = self.buyBg:getChildByName('info_tx5')
    
    self:updateInfo()
    
    local cancleBtn = self.buyBg:getChildByName('cancle_btn')
    local btnTx = cancleBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('STR_CANCEL_1'))
    cancleBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideMsgUI()
        end
    end)

    local buyBtn = self.buyBg:getChildByName('buy_btn')
    local btnTx = buyBtn:getChildByName('info_tx')
    btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_MSG4'))
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then

            UserData:getUserObj():cost('cash',self.needCash,function()
                MessageMgr:sendPost('buy_action_point', 'territorywar', json.encode({}), function (jsonObj)
                    local code = jsonObj.code
                    local data = jsonObj.data
                    if code == 0 then
                        if data.awards then
                            GlobalApi:parseAwardData(data.awards)
                            GlobalApi:showAwardsCommon(data.awards,2,nil,true)
                        end
                        if data.costs then
                            GlobalApi:parseAwardData(data.costs)
                        end
                        UserData:getUserObj():getTerritorialWar().buy_action_count = UserData:getUserObj():getTerritorialWar().buy_action_count + 1
                        self:updateInfo()
                    else
                        local vipLv = UserData:getUserObj():getVip()
                        if vipLv < GlobalApi:getMaxVip() then
                            TerritorialWarMgr:handleErrorCode(code)
                        else
                            local errStr = GlobalApi:getLocalStr('TERRITORY_WAR_ERROR_240')
                            promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
                        end
                    end
                end)
            end,false,string.format(GlobalApi:getLocalStr('NEED_CASH'),self.needCash))
        end
    end)

end

return TerritorialWarsMsgUI