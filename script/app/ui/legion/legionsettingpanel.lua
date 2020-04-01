local LegionSettingUI = class("LegionSettingUI", BaseUI)

local MAXTYPE = 3
function LegionSettingUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONSETTINGUI
  self.data = data
  self.selectlimittype = self.data.type + 1
  self.lvlimitnum = self.data.level_limit
end

function LegionSettingUI:onShow()
    self:update()
end
function LegionSettingUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionSettingUI()
    --     end
    -- end)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then         
            LegionMgr:setSelectIconChange(false)
            LegionMgr:hideLegionSettingUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local titilebg = bgimg2:getChildByName('title_bg')
    local titletx = titilebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_SET_TITLE'))
    self.iconbg = bgimg2:getChildByName('icon_bg_img')
    self.iconimg = self.iconbg:getChildByName('icon_img')
    self.iconimg:ignoreContentAdaptWithSize(true)
    local iconConf = GameData:getConfData("legionicon") 
    self.iconbg:loadTexture(COLOR_FRAME[iconConf[self.data.icon].frameQuality])
    self.iconimg:loadTexture(iconConf[self.data.icon].icon)
    local icontx = bgimg2:getChildByName('icon_tx')
    icontx:setString(GlobalApi:getLocalStr('LEGION_ICON')..':')
    local limittx = bgimg2:getChildByName('limit_tx')
    limittx:setString(GlobalApi:getLocalStr('LEGION_APPLY_DESC')..':')
    local lvtx = bgimg2:getChildByName('lv_tx')
    lvtx:setString(GlobalApi:getLocalStr('LEGION_APPLY_LV')..':')
    local changeiconbtn = bgimg2:getChildByName('change_icon_btn')
    local changeiconbtntx = changeiconbtn:getChildByName('btn_tx')
    changeiconbtntx:setString(GlobalApi:getLocalStr('LEGION_CHANGE_ICON_2'))
    changeiconbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionIconSelectUI(self.data.members)
        end
    end)
    local okbtn = bgimg2:getChildByName('func_btn')
    local okbtntx = okbtn:getChildByName('btn_tx')
    okbtntx:setString(GlobalApi:getLocalStr('STR_OK'))
    okbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local icon = self.data.icon
            if LegionMgr:getIsSelectIconChange() then
                icon = LegionMgr:getSelectIconID()
            end
            local args = {
                icon = icon,
                type = self.selectlimittype - 1,
                level_limit = self.lvlimitnum
            }
            MessageMgr:sendPost('setting','legion',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    self.data.type = self.selectlimittype - 1
                    self.data.level_limit = self.lvlimitnum
                    self.data.icon = icon
                    LegionMgr:setSelectIconChange(false)
                    LegionMgr:hideLegionSettingUI()
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SETTING_SUC'), COLOR_TYPE.GREEN)                    
                end
            end)
        end
    end)
    local limitbg = bgimg2:getChildByName('limit_bg')
    self.limittx = limitbg:getChildByName('limit_tx')

    local lvlimitbg = bgimg2:getChildByName('lvlimit_bg')
    lvlimitbg:setLocalZOrder(1)
    self.lvlimittx = lvlimitbg:getChildByName('lvlimit_tx')
    local limitprobtn = bgimg2:getChildByName('limit_pro_btn')
    limitprobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.selectlimittype = self.selectlimittype - 1
            if self.selectlimittype < 1 then
                self.selectlimittype = MAXTYPE
            end
            self:update()
        end
    end)
    local limitnextbtn = bgimg2:getChildByName('limit_next_btn')
    limitnextbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.selectlimittype = self.selectlimittype + 1
            if self.selectlimittype > MAXTYPE then
                self.selectlimittype  = 1
            end
            self:update()
        end
    end)
    local legionglobalconf = GameData:getConfData('legion')
    local lvconf = GameData:getConfData('level')
    self.lvmin = legionglobalconf['legionOpenLevel'].value
    self.lvmax = #lvconf
    --self.lvlimitnum = self.lvmin
    local lvprobtn = bgimg2:getChildByName('lv_pro_btn')
    lvprobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.lvlimitnum = self.lvlimitnum - 1 
            if tonumber(self.lvlimitnum) < tonumber(self.lvmin) then
                self.lvlimitnum = self.lvmin
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT_DESC'),self.lvmin,self.lvmax), COLOR_TYPE.RED)
            end
            self.lvlimittx:setString(self.lvlimitnum)
            self:update()
        end
    end)
    local lvnextbtn = bgimg2:getChildByName('lv_next_btn')
    lvnextbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.lvlimitnum = self.lvlimitnum + 1 
            if tonumber(self.lvlimitnum) > tonumber(self.lvmax) then
                self.lvlimitnum = self.lvmax
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT_DESC'),self.lvmin,self.lvmax), COLOR_TYPE.RED)
            end
            self.lvlimittx:setString(self.lvlimitnum)
            self:update()
        end
    end)

    self.lvbox = cc.EditBox:create(cc.size(250,50), 'uires/ui/common/name_bg9.png')
    self.lvbox:setPlaceholderFontColor(cc.c4b(255, 255, 255,0))
    self.lvbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.lvbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.lvbox:setPlaceHolder('')
    self.lvbox:setPosition(463.33, 170.34)
    self.lvbox:setFontSize(25)
    self.lvbox:setText('')
    self.lvbox:setFontColor(cc.c3b(255, 255, 255))
    -- self.lvbox:setOpacity(0)
    self.lvbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.lvbox:setText(self.lvlimitnum)
            self.lvlimittx:setString('')
        elseif event == "ended" then
            local lv = tonumber(self.lvbox:getText()) or tonumber(self.lvmin)
            if lv > tonumber(self.lvmax) then
                self.lvlimitnum = self.lvmax
                self.lvlimittx:setString(self.lvlimitnum)
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT_DESC'),self.lvmin,self.lvmax), COLOR_TYPE.RED)
            elseif lv < tonumber(self.lvmin) then
                self.lvlimitnum = self.lvmin
                self.lvlimittx:setString(self.lvlimitnum)
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT_DESC'),self.lvmin,self.lvmax), COLOR_TYPE.RED)
            else
                self.lvlimitnum = lv
                self.lvlimittx:setString(self.lvlimitnum)
            end
            -- self.lvbox:setText(self.lvlimitnum)
            self.lvbox:setText('')
            self.lvlimittx:setString(self.lvlimitnum)
            self:update()
        end
    end)

    -- --: DEBUG
    -- local num = GlobalApi:genNumberEditor(lvprobtn, self.lvlimittx, lvnextbtn, self.lvmin, self.lvmax)
    -- print(num)

    self.limittx:setString(GlobalApi:getLocalStr('LEGION_APPLY_TYPE'..tostring(self.data.type+1)))
    self.lvlimittx:setString(self.data.level_limit)
    bgimg2:addChild(self.lvbox)
end

function LegionSettingUI:update()
    local iconConf = GameData:getConfData("legionicon") 
    if LegionMgr:getIsSelectIconChange() then
        self.iconbg:loadTexture(COLOR_FRAME[iconConf[LegionMgr:getSelectIconID()].frameQuality])
        self.iconimg:loadTexture(iconConf[LegionMgr:getSelectIconID()].icon)
    else
        self.iconbg:loadTexture(COLOR_FRAME[iconConf[self.data.icon].frameQuality])
        self.iconimg:loadTexture(iconConf[self.data.icon].icon)
    end
    self.limittx:setString(GlobalApi:getLocalStr('LEGION_APPLY_TYPE'..self.selectlimittype))
    self.lvlimittx:setString(self.lvlimitnum)
end

return LegionSettingUI