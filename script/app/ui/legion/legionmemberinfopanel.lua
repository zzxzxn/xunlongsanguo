local LegionMemberInfoUI = class("LegionMemberInfoUI", BaseUI)
local ClassRoleObj  =require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function LegionMemberInfoUI:ctor(legiondata,memberdata,parent)
  self.uiIndex = GAME_UI.UI_LEGIONMEMBERINFOUI
  self.data = memberdata
  self.legiondata = legiondata
  self.parent = parent
end

function LegionMemberInfoUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    self:adaptUI(bgimg1, bgimg2)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionMemberInfoUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_MEMBER_INFO_TITLE')) 
    local legionglobalconf = GameData:getConfData('legion')
    local legionlvconf = GameData:getConfData('legionlevel')
    local iconBgNode = bgimg2:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    iconBgNode:addChild(cell.awardBgImg)
    cell.awardBgImg:loadTexture(COLOR_FRAME[self.data[2].quality])
    cell.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if tonumber(self.data[1]) ~= 0 then
                BattleMgr:showCheckInfo(tonumber(self.data[1]),'world','country')
            end
        end
    end)
    local obj = RoleData:getHeadPicObj(tonumber(self.data[2].headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.data[2].headframe))
    local lvdesctx = bgimg2:getChildByName('lv_desc_tx')
    lvdesctx:setString(GlobalApi:getLocalStr('LEGION_MEM_LV')..':')
    local namedesctx = bgimg2:getChildByName('name_desc_tx')
    namedesctx:setString(GlobalApi:getLocalStr('LEGION_MEM_NAME')..':')
    local posdesctx = bgimg2:getChildByName('pos_desc_tx')
    posdesctx:setString(GlobalApi:getLocalStr('LEGION_POS')..':')
    local timedesctx = bgimg2:getChildByName('time_desc_tx')
    timedesctx:setString(GlobalApi:getLocalStr('STR_LAST_LOGIN')..':')
    local lvtx = bgimg2:getChildByName('lv_tx')
    lvtx:setString(self.data[2].level)
    local nametx = bgimg2:getChildByName('name_tx')
    nametx:setString(self.data[2].un)
    local postx = bgimg2:getChildByName('pos_tx')
    postx:setString(GlobalApi:getLocalStr('LEGION_POS'..self.data[2].duty))
    local timetx = bgimg2:getChildByName('time_tx')
    timetx:setString(GlobalApi:toEasyTime(self.data[2].login_time))
    local kickbtn = bgimg2:getChildByName('kick_btn')
    local kickbtntx =  kickbtn:getChildByName('btn_tx')
    kickbtntx:setString(GlobalApi:getLocalStr('LEGION_KICK'))
    kickbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then     
            local judge = false     
            local legiondat = GameData:getConfData('legion')
            local legionKickPlayerCostDonateValue = tonumber(legiondat['legionKickPlayerCostDonateValue'].value)

            local function callBack()
                local args = {
                    uid = self.data[1]
                }
                MessageMgr:sendPost('kick','legion',json.encode(args),function (response)                
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        if data.icon then
                            if data.icon ~= LegionMgr:getSelectIconID() then
                                self.legiondata.icon = data.icon
                                LegionMgr:setSelectIconChange(true)
                                LegionMgr:setSelectIconID(data.icon)
                            end
                        end
                        self.legiondata.members[self.data[1]] = nil
                        if judge == true then
                            self.legiondata.xp = self.legiondata.xp - legionKickPlayerCostDonateValue
                        end
                        LegionMgr:hideLegionMemberInfoUI()
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_KICK_SUC'), COLOR_TYPE.GREEN)
                    elseif code == 107 then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_107'),self.data[2].un), COLOR_TYPE.RED)                 
                    end
                end)
            end

            local construct_progress = LegionMgr:getLegionConstructProgress()
            -- ��������Ծֵ�ڵ�7���͵�6��
            local activeValue7 = self.data[2].active[7]
            local activeValue6 = self.data[2].active[6]
            if activeValue6 > 0 or activeValue7 > 0 then   -- �ǻ�Ծ���
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('LEGION_KICK2'),48,legionKickPlayerCostDonateValue), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    if self.legiondata.xp >= legionKickPlayerCostDonateValue then
                        judge = true
                        callBack()
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_KICK3'), COLOR_TYPE.RED)
                    end
			    end)
            else
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('LEGION_MENBER_DES9')), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                    callBack()
                end)
            end

        end
    end)
    local changeposbtn = bgimg2:getChildByName('changepos_btn')
    local changeposbtntx = changeposbtn:getChildByName('btn_tx')
    changeposbtntx:setString(GlobalApi:getLocalStr('LEGION_CHANGEPOS'))
    changeposbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionPosManageUI(self.legiondata,self.data)
        end
    end)

    local exitBtn = bgimg2:getChildByName('exit_btn')
    local exitbtntx = exitBtn:getChildByName('btn_tx')
    exitbtntx:setString(GlobalApi:getLocalStr('LEGION_DESC1'))
    exitBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if tonumber(self.legiondata.impeachmentInitiatorId) == tonumber(self.data[1]) then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEADER_CANNT_QUIT2'), COLOR_TYPE.RED)
                return
            end

            local memberarr = {}
            if self.legiondata.members then
                for k,v in pairs (self.legiondata.members) do 
                    local arr = {}
                    arr[1] = k
                    arr[2] = v
                    table.insert(memberarr,arr)
                end
            end

            if LegionMgr:getSelfLegionPos() == 1 and #memberarr > 1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEADER_CANNT_QUIT'), COLOR_TYPE.RED)
                return
            end
            local legionExitTimeLimit = tonumber(legionglobalconf['legionExitTimeLimit'].value)
            local join_time = self.data[2].join_time
            if GlobalData:getServerTime() - join_time < legionExitTimeLimit then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("LEGION_QUIT_CONFIRM_INFO2"), math.floor(legionExitTimeLimit/3600)),COLOR_TYPE.RED)
                return
            end
            promptmgr:showMessageBox(GlobalApi:getLocalStr('LEGION_MENBER_DES10'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                --promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("LEGION_QUIT_CONFIRM_INFO"), math.floor(tonumber(legionglobalconf['joinTimeLimit'].value)/3600)), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    MessageMgr:sendPost('exit','legion','{}',function (response)
                        
                        local code = response.code
                        local data = response.data
                        if code == 0 then
                            UserData:getUserObj():getLegionInfo().leave_time = data.leave_time
                            UserData:getUserObj().lid=0
                            LegionMgr:hideLegionMemberListUI()
                            LegionMgr:hideLegionMainUI()
                            LegionMgr:hideLegionMemberInfoUI()
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_QUIT_SUC'), COLOR_TYPE.GREEN)                      
                        end
                    end)
               --end)
            end)
        end
    end)

    local checkBtn = bgimg2:getChildByName('check_btn')
    local checkBtntx = checkBtn:getChildByName('btn_tx')
    checkBtntx:setString(GlobalApi:getLocalStr('LEGION_DESC12'))
    checkBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BattleMgr:showCheckInfo(tonumber(self.data[1]),'world','arena')
        end
    end)

    if tonumber(UserData:getUserObj():getUid()) == tonumber(self.data[1]) then
        exitBtn:setVisible(true)
    else
        exitBtn:setVisible(false)
    end

    if LegionMgr:getSelfLegionPos() < self.data[2].duty  then
        kickbtn:setVisible(true)
    else
        kickbtn:setVisible(false)
    end
    if LegionMgr:getSelfLegionPos() < 3 and LegionMgr:getSelfLegionPos() < self.data[2].duty then
        changeposbtn:setVisible(true)
    else
        changeposbtn:setVisible(false)
    end

    if tonumber(UserData:getUserObj():getUid()) == tonumber(self.data[1]) then
        checkBtn:setVisible(false)
    else
        checkBtn:setVisible(true)
        if LegionMgr:getSelfLegionPos() >= self.data[2].duty then
            checkBtn:setPositionX(exitBtn:getPositionX())
        end
    end
end

return LegionMemberInfoUI