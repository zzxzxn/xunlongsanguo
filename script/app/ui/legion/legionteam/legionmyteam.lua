local LegionTeamUI = class("LegionTeamUI", BaseUI)

function LegionTeamUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONMYTEAM
  self.data = data
end

function LegionTeamUI:updatePanel()
    printall(self.data)
    local queue = self.data.queue
    local tab = {}
    for k,v in pairs(queue.members) do
        tab[#tab + 1] = v
    end
    for i=1,5 do
        local bgImg = self.neiBgImg:getChildByName('role_bg_'..i..'_img')
        local bgImg1 = bgImg:getChildByName('bg_img')
        local roleBgImg = bgImg1:getChildByName('role_bg_img')
        local roleImg = roleBgImg:getChildByName('role_img')
        local lvTx = roleBgImg:getChildByName('lv_tx')
        local nameTx = bgImg1:getChildByName('name_tx')
        local timeTx = bgImg:getChildByName('time_tx')
        local descTx = bgImg:getChildByName('desc_tx')
        local numTx = bgImg:getChildByName('num_tx')
        local infoTx = bgImg:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC25'))
        if tab[i] then
            -- local obj = RoleData:getRoleInfoById(tonumber(tab[i].hid))
            local obj = RoleData:getHeadPicObj(tonumber(tab[i].headpic))
            roleImg:loadTexture(obj:getIcon())
            roleBgImg:loadTexture(obj:getBgImg())
            nameTx:setString(tab[i].name)
            timeTx:setString(Time.getStr(tab[i].left_time))
            descTx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC26'))
            numTx:setString('+30%')
            infoTx:setVisible(false)
            bgImg:setTouchEnabled(false)
        else
            roleBgImg:loadTexture('uires/ui/common/frame_default.png')
            lvTx:setString('')
            nameTx:setString('')
            timeTx:setString('')
            descTx:setString('')
            numTx:setString('')
            infoTx:setVisible(true)
            bgImg:setTouchEnabled(true)
        end
        roleImg:ignoreContentAdaptWithSize(true)
    end

    local uid = UserData:getUserObj():getUid()
    local timeTx = self.timeBgImg:getChildByName('time_tx')
    local descTx1 = self.timeBgImg:getChildByName('desc_1_tx')
    local descTx2 = self.timeBgImg:getChildByName('desc_2_tx')
    local numTx = self.timeBgImg:getChildByName('num_tx')
    descTx1:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC20'))
    descTx2:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC21'))
    timeTx:setString(Time.getStr(queue.members[tostring(uid)].left_time or 0))
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
            LegionMgr:hideLegionMyTeamUI()
        end
    end)
    
    self.neiBgImg = teamImg:getChildByName('nei_bg_img')
    self.neiBgImg:getChildByName('title_img'):getChildByName('title_img'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC22'))
    self.timeBgImg = teamImg:getChildByName('time_bg_img')
    local leaveBtn = teamImg:getChildByName('leave_btn')
    leaveBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC23'))
    leaveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:leaveTeam(self.data.qid,function()
                LegionMgr:hideLegionMyTeamUI()
            end)
        end
    end)

    self.neiBgImg:getChildByName('bag_btn'):getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC24'))

    self:updatePanel()
end

return LegionTeamUI