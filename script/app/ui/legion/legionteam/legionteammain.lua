local LegionTeamMainUI = class("LegionTeamMainUI", BaseUI)

function LegionTeamMainUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONTEAMMAIN
  self.data = data
end

function LegionTeamMainUI:onShow()
    LegionMgr:getTeam(function(data)
        self.data = data
        self:updatePanel()
    end)
end
function LegionTeamMainUI:updatePanel()
    local descTx = self.timePl:getChildByName('desc_tx')
    local timeBgImg = self.timePl:getChildByName('time_bg_img')
    local descTx1 = timeBgImg:getChildByName('desc_tx')
    local timeTx = timeBgImg:getChildByName('time_tx')
    local time = self.data.left_time
    local qid = self.data.qid
    if qid ~= 0 then
        self.onTeamImg:setVisible(true)
    else
        self.onTeamImg:setVisible(false)
    end
    if time > 0 then
        timeBgImg:setVisible(true)
        descTx:setVisible(false)
        timeTx:setString(Time.getStr(time))
    else
        timeBgImg:setVisible(false)
        descTx:setVisible(true)
    end
end

function LegionTeamMainUI:gotoTeam()
    if self.data.qid == 0 then
        LegionMgr:showLegionTeamUI()
    else
        LegionMgr:showLegionMyTeamUI()
    end
end

function LegionTeamMainUI:init()
    local teamImg = self.root:getChildByName('legion_team_img')
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn = self.root:getChildByName('close_btn')
    closeBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('STR_RETURN'))
    local bagBtn = self.root:getChildByName('bag_btn')
    bagBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC24'))
    self.teamBtn = self.root:getChildByName('team_btn')
    self.teamBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC37'))
    self.onTeamImg = self.root:getChildByName('on_team_img')
    self.onTeamImg:getChildByName('desc_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC36'))
    self.timePl = self.root:getChildByName('time_pl')

    self.timePl:getChildByName('desc_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC34'))
    self.timePl:getChildByName('time_bg_img'):getChildByName('desc_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC28'))

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionTeamMainUI()
        end
    end)
    self.teamBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:gotoTeam()
        end
    end)
    bagBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionTeamBagUI()
        end
    end)

    local size = bagBtn:getContentSize()
    teamImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    closeBtn:setPosition(cc.p(size.width/2,size.height/2))
    bagBtn:setPosition(cc.p(winSize.width - 1.5*size.width - 20,size.height/2))
    self.teamBtn:setPosition(cc.p(winSize.width - 0.5*size.width - 10,size.height/2))
    self.timePl:setPosition(cc.p(winSize.width - 2*size.width - 30,size.height/2))
    self.onTeamImg:setPosition(cc.p(0,winSize.height))
    
    self:updatePanel()
end

return LegionTeamMainUI