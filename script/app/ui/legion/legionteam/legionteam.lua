local LegionTeamUI = class("LegionTeamUI", BaseUI)

function LegionTeamUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONTEAM
  self.data = data
  self.leftIndex = 1
end

function LegionTeamUI:updatePanel()
    local size1
    local queues = self.data.queues
    for i=1,#queues do
        local teamBgImg = self.cellSv:getChildByTag(i+1000)
        if not teamBgImg then
            local cellNode = cc.CSLoader:createNode('csb/legionteamcell.csb')
            teamBgImg = cellNode:getChildByName('team_bg_img')
            teamBgImg:removeFromParent(false)
            self.cellSv:addChild(teamBgImg,1,i+1000)
        end
        size1 = teamBgImg:getContentSize()
        local tab = {}
        for k,v in pairs(queues[i].members) do
            tab[#tab + 1] = v
        end
        local qid = queues[i].qid
        for j=1,5 do
            local bgImg = teamBgImg:getChildByName('role_bg_'..j..'_img')
            local roleBgImg = bgImg:getChildByName('role_bg_img')
            local roleImg = roleBgImg:getChildByName('role_img')
            local lvTx = roleBgImg:getChildByName('lv_tx')
            local nameTx = bgImg:getChildByName('name_tx')
            local timeTx = bgImg:getChildByName('time_tx')
            local descTx = bgImg:getChildByName('desc_tx')
            descTx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC31'))
            if tab[j] then
                -- local obj = RoleData:getRoleInfoById(tonumber(tab[j].hid))
                local obj = RoleData:getHeadPicObj(tonumber(tab[j].headpic))
                roleImg:loadTexture(obj:getIcon())
                roleBgImg:loadTexture(obj:getBgImg())
                nameTx:setString(tab[j].name)
                timeTx:setString(Time.getStr(tab[j].left_time))
                descTx:setVisible(false)
                bgImg:setTouchEnabled(false)
            else
                roleImg:loadTexture('uires/ui/common/add_01.png')
                lvTx:setString('')
                nameTx:setString('')
                timeTx:setString('')
                descTx:setVisible(true)
                bgImg:setTouchEnabled(true)
            end
            roleImg:ignoreContentAdaptWithSize(true)
            bgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    LegionMgr:joinTeam(qid,function()
                        LegionMgr:hideLegionTeamUI()
                    end)
                end
            end)
        end
    end

    if size1 then
        local size = self.cellSv:getContentSize()
        if #queues * size1.height > size.height then
            self.cellSv:setInnerContainerSize(cc.size(size.width,#queues * size1.height))
        else
            self.cellSv:setInnerContainerSize(size)
        end
    end

    local size = self.cellSv:getInnerContainerSize()
    for i=1,#queues do
        local cell = self.cellSv:getChildByTag(i+1000)
        if cell then
            cell:setPosition(cc.p(0,size.height - (#queues - i + 1) * size1.height))
        end
    end

    local timeTx = self.timeBgImg:getChildByName('time_tx')
    timeTx:setString(Time.getStr(self.data.left_time or 0))
end

function LegionTeamUI:init()
    local teamBgImg = self.root:getChildByName('team_bg_img')
    local teamImg = teamBgImg:getChildByName('team_img')
    self:adaptUI(teamBgImg, teamImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn = teamImg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionTeamUI()
        end
    end)
    self.cellSv = teamImg:getChildByName('cell_sv')
    self.cellSv:setScrollBarEnabled(false)
    self.timeBgImg = teamImg:getChildByName('time_bg_img')
    self.timeBgImg:getChildByName('desc_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC28'))
    teamImg:getChildByName('nei_bg_img'):getChildByName('title_img'):getChildByName('title_img'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC27'))

    local createBtn = teamImg:getChildByName('create_btn')
    createBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC29'))
    createBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:createTeam(function()
                LegionMgr:hideLegionTeamUI()
            end)
        end
    end)
    local refreshBtn = teamImg:getChildByName('refresh_btn')
    refreshBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:refreshTeam(function(data)
                self.data = data
                self:updatePanel()
            end)
        end
    end)
    local quickBtn = teamImg:getChildByName('quick_btn')
    quickBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC30'))
    quickBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionTeamUI()
        end
    end)
    self:updatePanel()
end

return LegionTeamUI