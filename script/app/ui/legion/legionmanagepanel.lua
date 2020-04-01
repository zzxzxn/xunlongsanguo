local LegionManageUI = class("LegionManageUI", BaseUI)

local havefunc = {
    [1] = 3,
    [2] = 1,
    [3] = 1,
    [4] = 0,
    [5] = 4
}
function LegionManageUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONMANAGEUI
  self.pos = LegionMgr:getSelfLegionPos()
  self.data = data
end

function LegionManageUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionManageUI()
        end
    end)
    local bgimg3 = bgimg2:getChildByName('bg_img2')
    self:adaptUI(bgimg1, bgimg2)
    self.contentWidget = ccui.Widget:create()
    bgimg3:addChild(self.contentWidget)
    local num  =  havefunc[self.pos]
    if self.pos == 1 and LegionMgr:getMemberCount(self.data.members) == 1 then
        num = havefunc[5]
    end
    bgimg2:setContentSize(cc.size(300,100*num+100))
    bgimg3:setContentSize(cc.size(288,100*num-12+100))
    self.contentWidget:setPosition(cc.p(150,100*num+50))
    bgimg3:setPosition(cc.p(150,100*num/2+50))
    self.btnarr = {}
    self.btnarrtxlabel = {}
    for i=1,num do
        local funcbtn = ccui.Button:create("uires/ui/common/common_btn_4.png", "", "")
        self.btnarr[i] = funcbtn 
        self.btnarrtxlabel[i] = cc.Label:createWithTTF("", "font/gamefont.ttf", 30)
        self.btnarrtxlabel[i]:setTextColor(cc.c4b(255, 255, 255, 255))
        self.btnarrtxlabel[i]:enableOutline(cc.c4b(165,70,6, 255), 1)
        self.btnarrtxlabel[i]:setPosition(cc.p(94.5, 37))
        self.btnarrtxlabel[i]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
        funcbtn:setTouchEnabled(true)
        funcbtn:addChild(self.btnarrtxlabel[i])
        funcbtn:setPosition(cc.p(0,-(50+(i-1)*100)))
        self.contentWidget:addChild(funcbtn)     
    end

    if self.btnarr[1] then
        self.btnarrtxlabel[1]:setString(GlobalApi:getLocalStr('LEGION_APPLY_LIST'))     
        self.btnarr[1]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionMgr:hideLegionManageUI()
                LegionMgr:showLegionApplyListUI(self.data)
            end
        end)
        local manageBtnNewImg = ccui.ImageView:create('uires/ui/common/new_img.png')
        manageBtnNewImg:setPosition(cc.p(186,67))
        self.btnarr[1]:addChild(manageBtnNewImg)
        manageBtnNewImg:setVisible(UserData:getUserObj():getSignByType('legion_member_hall'))
    end

    if self.btnarr[2] then
        self.btnarrtxlabel[2]:setString(GlobalApi:getLocalStr('LEGION_PUB_CHANGE'))
        self.btnarr[2]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionMgr:hideLegionManageUI()
                LegionMgr:showLegionPubSettingUI(self.data)
            end
        end)
    end

    if self.btnarr[3] then
        self.btnarrtxlabel[3]:setString(GlobalApi:getLocalStr('LEGION_SET'))
        self.btnarr[3]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionMgr:hideLegionManageUI()
                LegionMgr:showLegionSettingUI(self.data)
            end
        end)
    end
    local legionglobalconf = GameData:getConfData('legion')
    if self.btnarr[4] then
        self.btnarrtxlabel[4]:setString(GlobalApi:getLocalStr('LEGION_DISMISS'))
        self.btnarr[4]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then 
                promptmgr:showMessageBox(GlobalApi:getLocalStr('LEGION_DISMISS_DESC1')..GlobalApi:getLocalStr('LEGION_DISMISS_DESC2'), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    MessageMgr:sendPost('exit','legion','{}',function (response)
                        
                        local code = response.code
                        local data = response.data
                        if code == 0 then
							UserData:getUserObj().lid=0
                            LegionMgr:hideLegionManageUI()
                            LegionMgr:hideLegionMainUI()
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_QUIT_SUC'), COLOR_TYPE.GREEN)                      
                        end
                    end)
               end)
            end
        end)
    end       

end

return LegionManageUI