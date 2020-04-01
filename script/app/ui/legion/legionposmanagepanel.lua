local LegionPosManageUI = class("LegionPosManageUI", BaseUI)

local maxpos = 4
local havefunc = {
    [1] = 4,
    [2] = 2,
    [3] = 0,
    [4] = 0,
}
function LegionPosManageUI:ctor(legiondata,memberdata)
  self.uiIndex = GAME_UI.UI_LEGIONMANAGEUI
  self.legiondata = legiondata
  self.memberdata = memberdata
  self.pos  = LegionMgr:getSelfLegionPos()
end

function LegionPosManageUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionPosManageUI()
        end
    end)
    local bgimg3 = bgimg2:getChildByName('bg_img2')
    self:adaptUI(bgimg1, bgimg2)
    self.contentWidget = ccui.Widget:create()
    bgimg3:addChild(self.contentWidget)
    local num  =  havefunc[self.pos]
    bgimg2:setContentSize(cc.size(300,100*num+100))
    bgimg3:setContentSize(cc.size(288,100*num-12+100))
    self.contentWidget:setPosition(cc.p(150,100*num+50))
    bgimg3:setPosition(cc.p(150,100*num/2+50))
    self.btnarr = {}
    self.btnarrtxlabel = {}
    local legionglobalconf = GameData:getConfData('legion')

    for i=num,1,-1 do
        local funcbtn = ccui.Button:create("uires/ui/common/common_btn_4.png", "", "")
        self.btnarr[i] = funcbtn 
        local curduty = (maxpos-num+i)
        self.btnarrtxlabel[i] = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
        self.btnarrtxlabel[i]:setTextColor(COLOR_TYPE.WHITE)
        self.btnarrtxlabel[i]:enableOutline(cc.c4b(165,70,6, 255), 1)
        self.btnarrtxlabel[i]:setPosition(cc.p(94.5, 37))
        self.btnarrtxlabel[i]:setString(GlobalApi:getLocalStr('LEGION_POS'..curduty))
        self.btnarrtxlabel[i]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))

        funcbtn:setTouchEnabled(true)
        funcbtn:addChild(self.btnarrtxlabel[i])
        funcbtn:setPosition(cc.p(0,-(50+(i-1)*100)))
        funcbtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if curduty == 1 then
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("LEGION_DESC6")), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        self:sendMsg(curduty)
                    end)
                else
                    self:sendMsg(curduty)
                end
            end
        end)
        self.contentWidget:addChild(funcbtn)     
    end
end

function LegionPosManageUI:sendMsg(curduty)
    local legionglobalconf = GameData:getConfData('legion')
    local limitnumdeputy = legionglobalconf['deputyLimit'].value
    local limitnumadviser = legionglobalconf['adviserLimit'].value

    if (curduty ==2 and tonumber(LegionMgr:getMemberCountByPos(curduty,self.legiondata.members)) >= tonumber(limitnumdeputy))
        or (curduty==3 and tonumber(LegionMgr:getMemberCountByPos(curduty,self.legiondata.members)) >= tonumber(limitnumadviser)) then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_POS'..curduty)..GlobalApi:getLocalStr('LEGION_MAXNUM'), COLOR_TYPE.RED)
        return
    end
    if self.legiondata.members[self.memberdata[1]].duty == curduty then
        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_CHANGEPOS_SUC1'),self.memberdata[2].un,GlobalApi:getLocalStr('LEGION_POS'..curduty)), COLOR_TYPE.RED)
        return
    end
    local args = {
        uid = self.memberdata[1],
        duty = curduty
    }
    MessageMgr:sendPost('appoint','legion',json.encode(args),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            self.legiondata.members[self.memberdata[1]].duty = curduty
            --军团长转让特殊处理
            if curduty == 1 then
                self.legiondata.members[tostring(UserData:getUserObj():getUid())].duty = 4
            end
            LegionMgr:hideLegionMemberInfoUI()
            LegionMgr:hideLegionPosManageUI()
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_CHANGEPOS_SUC'),self.memberdata[2].un,GlobalApi:getLocalStr('LEGION_POS'..curduty)), COLOR_TYPE.GREEN)
        elseif code == 107 then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_107'),self.memberdata[2].un), COLOR_TYPE.RED)                 
        end
    end)
end
return LegionPosManageUI