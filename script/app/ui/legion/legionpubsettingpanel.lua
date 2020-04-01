local LegionPubSettingUI = class("LegionPubSettingUI", BaseUI)

function LegionPubSettingUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONPUBSETTINGUI
  self.data = data
end

function LegionPubSettingUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionPubSettingUI()
    --     end
    -- end)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionPubSettingUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local legionglobalconf = GameData:getConfData('legion')    
    local titletx = bgimg2:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_PUB_CHANGE_TITLE'))
    local funcbtn = bgimg2:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_OK2'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --todo 字数判断
            -- if 1 then
            --     promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_SETTING_PUB_FAIL'),legionglobalconf['legionNoticeMax'].value), COLOR_TYPE.RED)
            --     return
            -- end
            local args = {
                notice = self.nameTx:getString()
            }
            MessageMgr:sendPost('set_notice','legion',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    self.data.notice = self.nameTx:getString()
                    LegionMgr:hideLegionPubSettingUI()
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SETTING_PUB_SUC'), COLOR_TYPE.GREEN)                    
                end
            end)
        end
    end)
    -- local noticebg = bgimg2:getChildByName('notice_bg')
    -- local noticetx = noticebg:getChildByName('notice_tx')
    -- noticetx:ignoreContentAdaptWithSize(false)
    -- noticetx:setTextAreaSize(cc.size(500,60))
    -- noticetx:setString('')
    -- local richText = xx.RichText:create()
    -- richText:setContentSize(cc.size(500, 60))
    -- local re1 = xx.RichTextLabel:create(hasnum,23, COLOR_TYPE.WHITE)
    -- re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- richText:addElement(re1)
    -- richText:setAnchorPoint(cc.p(0,1))
    -- richText:setPosition(cc.p(0,60))
    -- noticetx:addChild(richText)
    -- if self.data.notice == '' then
    --     --noticetx:setString(GlobalApi:getLocalStr('LEGION_PUB_DEFAULT'))
    --     re1:setString(GlobalApi:getLocalStr('LEGION_PUB_DEFAULT'))
    --     richText:format(true)
    -- else
    --     --noticetx:setString(self.data.notice)
    --     re1:setString(self.data.notice)
    --     richText:format(true)
    -- end
    
    local maxLen = legionglobalconf['legionNoticeMax'].value
    self.pubedbox = cc.EditBox:create(cc.size(510, 160), 'uires/ui/common/name_bg9.png')
    self.pubedbox:setPlaceholderFontColor(cc.c4b(255, 255, 255,0))
    self.pubedbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.pubedbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.pubedbox:setPlaceHolder('')
    self.pubedbox:setPosition(262, 180)
    self.pubedbox:setFontSize(25)
    self.pubedbox:setText('')
    self.pubedbox:setFontColor(cc.c3b(255, 255, 255))
    self.pubedbox:setMaxLength(maxLen*10)
    -- self.pubedbox:setOpacity(0)
    bgimg2:addChild(self.pubedbox)

    self.nameTx = ccui.Text:create()
    self.nameTx:setFontName('font/gamefont.ttf')
    self.nameTx:setFontSize(23)
    self.nameTx:setAnchorPoint(cc.p(0,1))
    self.nameTx:setPosition(cc.p(15,255))
    self.nameTx:setTextAreaSize(cc.size(495,160))
    self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.WHITE2))

    if self.data.notice == '' then
        self.nameTx:setString(GlobalApi:getLocalStr('LEGION_PUB_DEFAULT'))
    else
        self.nameTx:setString(self.data.notice)
    end
    bgimg2:addChild(self.nameTx,1)

    local oldStr = ''
    self.pubedbox:registerScriptEditBoxHandler(function(event,pSender)
        -- if event == "began" then
        -- elseif event == "changed" then
        --     --noticetx:setString(self.pubedbox:getText())
        --     re1:setString(self.pubedbox:getText())
        --     richText:format(true)        
        -- elseif event == "ended" then
        --     --noticetx:setString(self.pubedbox:getText())
        --     re1:setString(self.pubedbox:getText())
        --     richText:format(true) 
        -- end
        if event == "began" then
            self.pubedbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
        elseif event == "ended" then
            local str = self.pubedbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.pubedbox:setText('')
            if self.nameTx:getString() == '' then
                self.nameTx:setString(GlobalApi:getLocalStr('LEGION_PUB_DEFAULT'))
            end
        end
    end)
    
end

return LegionPubSettingUI