local ChatUI = class("ChatUI", BaseUI)
local YUYINHEIGHT = 45
function ChatUI:ctor(id)
    self.uiIndex = GAME_UI.UI_CHAT
	self.channelBtns = {}
    self.channelTexts = {}
    self.channelStrings = {"world","legion","shout","system"}

    self.currentChannelCells = {}

    self.usedCells = {}
    self.unusedWidgets = {}
    self.numOChannels = 4
    self.currentChannel = ""
    self.cellSpace = 5

    self.numOfUnuseCell = 0
    self.layouting = false

    -- 是否是语音模式，false:文本，true：语音
    self.isVoice = false

    -- 语音触摸是否在范围内
    self.atRange = false
    -- 是否正在播放
    self.isPlaying = false
    -- 最大录音时间内是否发送
    self.isSendRecord = false
    -- 最大录制时间
    self.maxRecordTime = 20
    -- 剩余倒计时时间
    self.remainRecordTime = 10
    self.isTouch = false
    self.allTime = 0
    -- 快速点击时间限制
    self.speedClickTime = 0.3
end


function ChatUI:init()

    local rootBG  =  self.root:getChildByName("root")
    self.leftBG   =  ccui.Helper:seekWidgetByName(rootBG,"bg")
    self.content  =  ccui.Helper:seekWidgetByName(rootBG,"content")
    self.tabs     =  ccui.Helper:seekWidgetByName(rootBG,"tabs")
    self.rootBG   = rootBG

    local winSize = cc.Director:getInstance():getVisibleSize()
    local bg_img = self.root:getChildByName("bg_img")
    bg_img:setContentSize(winSize)
    bg_img:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.closeBtn = ccui.Helper:seekWidgetByName(rootBG,"closeButton")
    local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("RELOAD_NEW_CLIENT"), "font/gamefont.ttf", 22)
	msg:setAnchorPoint(cc.p(0, 1))
	msg:setPosition(cc.p(262, 216))
	msg:setMaxLineWidth(424)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	msg:setColor(COLOR_TYPE.ORANGE)
	msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))

    self.root:addChild(msg)
    self.heightComp = msg
    self.heightComp:setVisible(false)

    --trumpet 
    self.trumpetPanel = ccui.Helper:seekWidgetByName(self.content,"trumpetPanel")
    self.trumpetText  = ccui.Helper:seekWidgetByName( self.trumpetPanel,"trumpetText")
    self.trumpetNum   = ccui.Helper:seekWidgetByName( self.trumpetPanel,"trumpetNum")


     
    --inputzone 
    self.inputzone  = ccui.Helper:seekWidgetByName(self.content,"inputzone")
    self.inputBtn   = ccui.Helper:seekWidgetByName(self.inputzone,"inputBtn")
    self.textClip   = ccui.Helper:seekWidgetByName(self.inputzone,"clip")
    self.inputText  = ccui.Helper:seekWidgetByName(self.textClip,"inputText")
    self:createEditBox(self.textClip)

    self.voiceMask = self.content:getChildByName('voice_mask')
    self.voiceMask:setVisible(false)
    -- 语音相关
    self.voicePannel = self.content:getChildByName('voice_pannel')
    self.swithBtn = self.content:getChildByName('swith_btn')
    self.swithBtn:ignoreContentAdaptWithSize(true)
    local function swithBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self.isVoice = not self.isVoice
            self:switchVoiceState()
        end
    end
    self.swithBtn:addTouchEventListener(swithBtnCallBack)

    self.voiceBtn = self.voicePannel:getChildByName('voice_btn')
    self.voiceBtn:setContentSize(cc.size(386,self.textClip:getContentSize().height))

    local minX = self.voiceBtn:getPositionX()
    local maxX = minX + self.voiceBtn:getContentSize().width
    local minY = self.voiceBtn:getPositionY()
    local maxY = minY + self.voiceBtn:getContentSize().height

    local function stopRecordLogic(maxRecordState)
        self.isSendRecord = true
        if self.voiceRemainNode:getChildByTag(9527) then
            self.voiceRemainNode:removeChildByTag(9527)
        end

        self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
        self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
        self.voiceNode:setVisible(false)
        YVSdkMgr:stopRecord()

        YVSdkMgr:setRecordFinishCallBack(function(time)
            local time = time or 0
            time = math.floor((time/1000) + 0.5) -- 四舍五入
            if time >= self.maxRecordTime then
                time = self.maxRecordTime
            end

            if time == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                self.voiceMask:setVisible(false)
                return
            elseif self.atRange or maxRecordState then    -- 在范围内或者达到最大录音时间：发送到我们服务器,url,识别文本用content,语音时间,是否未读前端判断
                -- 语音识别并且上传
                YVSdkMgr:speechVoice()
                YVSdkMgr:setSpeechCallBack(function(data)
                    local url = data.url
                    local resultText = data.resultText  -- 文本如果识别为空，看发不
                    print('send to server =============' .. '\n time:' .. time .. '\n url:' .. url .. '\n resultText:' .. resultText)                  
                    self.voiceMask:setVisible(false)

                    -- 语音文字屏蔽
                    local maxLen = 64
                    local str = resultText
                    local unicode = GlobalApi:utf8_to_unicode(str)
                    local len = string.len(unicode)
                    unicode = string.sub(unicode,1,maxLen*6)
                    local utf8 = GlobalApi:unicode_to_utf8(unicode)
                    str = utf8
                    local isOk,str1 = GlobalApi:checkSensitiveWords(str)
                    if not isOk then
                        -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER_2'), MESSAGE_BOX_TYPE.MB_OK)
                        ChatMgr:SendChatMsg(self.currentChannel,str1 or '',url,time)
                    else
                        ChatMgr:SendChatMsg(self.currentChannel,resultText,url,time)
                    end
                    ChatMgr:resetCdTime()
                end)
            else
                self.voiceMask:setVisible(false)
            end

        end)
    end
    self.stopRecordLogic = stopRecordLogic

    local function voiceBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if ChatMgr:judgeSpeakIsOutTime() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_1'), COLOR_TYPE.RED)
                return
            end
            if YVSdkMgr.loginResult == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES7'), COLOR_TYPE.RED)
                return
            end
            self.isTouch = true
            self.allTime = 0
        elseif eventType == ccui.TouchEventType.ended then
            if ChatMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++ended')
            self.isTouch = false
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
            if self.allTime < self.speedClickTime then   
                if YVSdkMgr.loginResult == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                end             
            elseif self.isSendRecord == false then
                --print('max record time 20 s ==================')
                stopRecordLogic()
            end

        elseif eventType == ccui.TouchEventType.canceled then
            if ChatMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++canceled')
            self.isTouch = false
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
            if self.allTime < self.speedClickTime then       
                if YVSdkMgr.loginResult == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                end
            elseif self.isSendRecord == false then
                --print('max record time 20 s ==================')
                stopRecordLogic()
            end

        elseif eventType ==  ccui.TouchEventType.moved then
            if ChatMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++moved')
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu2.png')
            local pos = sender:getTouchMovePosition()
			local convertPos = self.voicePannel:convertToNodeSpace(pos)
            
            if convertPos.x > minX and convertPos.x < maxX and convertPos.y > minY and convertPos.y < maxY then
                self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES2'))
                self.atRange = true
                self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES3'))
                self.voiceNodeText:setTextColor(COLOR_TYPE.WHITE)
            else
                self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
                self.atRange = false
                self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES4'))
                self.voiceNodeText:setTextColor(COLOR_TYPE.RED)
            end
        end
    end
    self.voiceBtn:addTouchEventListener(voiceBtnCallBack)

    self.voiceBtnText = self.voiceBtn:getChildByName('inputText')
    self.voiceBtnText:setPosition(cc.p(self.voiceBtn:getContentSize().width/2,self.voiceBtn:getContentSize().height/2))
    self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))

    -- node
    self.voiceNode = self.leftBG:getChildByName('voice_node')
    self.voiceNodeText = self.voiceNode:getChildByName('text')
    self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES3'))
    self.huaTong = self.voiceNode:getChildByName('huatong')
    self.voiceTab = {}
    for i = 1,5 do
        table.insert(self.voiceTab,self.voiceNode:getChildByName('voice' .. i))
    end
    self.voiceNode:setVisible(false)

    self.voiceRemainNode = self.voiceNode:getChildByName('time')

    local function gLuaRecordVoiceCallBack_(volume)
        local volume = volume or 0
        local value = math.floor(volume/20)
        for i = 1,5 do
            if i <= (value + 1) then
                self.voiceTab[i]:setVisible(true)
            else
                self.voiceTab[i]:setVisible(false)
            end
        end

    end
    YVSdkMgr:setRecordVoiceCallBack(gLuaRecordVoiceCallBack_)

    --chatContent
    self.chatBG   = ccui.Helper:seekWidgetByName(self.content,"chatbg")
    self.chatView = ccui.Helper:seekWidgetByName(self.content,"chatView")
    self.chatView:setScrollBarEnabled(false)
    self.chatView.cellTotalHeight = 0;

    self.tempCell = ccui.Helper:seekWidgetByName(self.content,"chat_cell")
    self.tempCell:setVisible(false)

    --tabs
    for i = 1,self.numOChannels do
        self.channelBtns[i]  = ccui.Helper:seekWidgetByName(self.tabs,"tab"..i)
        self.channelTexts[i] = ccui.Helper:seekWidgetByName(self.channelBtns[i],"text")
        self.channelTexts[i]:setString(GlobalApi:getLocalStr("CHAT_CHANNEL"..i))
    end
    self.groupLock = self.channelBtns[2]:getChildByName('lock')

     if UserData:getUserObj():getLid() > 0 then
        self.groupLock:setVisible(false)
     else
        self.groupLock:setVisible(true)
     end
    
    self.countryLock = self.channelBtns[4]:getChildByName('lock')
    self.channelBtns[4]:getChildByName('new_img'):setVisible(false)  -- 这个提醒暂时没用

    --local countryVisible = GlobalApi:getOpenInfo('country')
    --self.countryLock:setVisible(not countryVisible)
    self.countryLock:setVisible(false)

    --默认世界频道
    self:registerTouchEvents()

    self:changeToChannel("world")

    local currentPos = cc.p(rootBG:getPositionX() - 2,rootBG:getPositionY())
    rootBG:setPositionX(currentPos.x - 2 - 538)
    rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.MoveTo:create(0.3, currentPos)))


    self:updatelegionBtnState()

    self.rootBG:scheduleUpdateWithPriorityLua(function (dt)
		self:update(dt)
	end, 0)

end

function ChatUI:update(dt)
    if self.isTouch == true then
        self.allTime = self.allTime + dt
        if self.allTime > self.speedClickTime then
            -- 开始录音
            self.isTouch = false

            self.voiceMask:setVisible(true)

            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES2'))
            self.voiceNode:setVisible(true)
            self.atRange = true
            self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES3'))
            self.voiceNodeText:setTextColor(COLOR_TYPE.WHITE)
            YVSdkMgr:startRecord()

            self.isSendRecord = false
            self.huaTong:setVisible(true)

            -- 添加时间倒计时
            self:timeoutCallback(self.maxRecordTime - self.remainRecordTime,false)
        end

    end

end

function ChatUI:timeoutCallback(diffTime,isSendMsg)
	local diffTime = diffTime - 1
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
	if self.voiceRemainNode:getChildByTag(9527) then
        self.voiceRemainNode:removeChildByTag(9527)
    end
	self.voiceRemainNode:addChild(node)
    if isSendMsg == false then
        node:setVisible(false)
    end
	Utils:createCDLabel(node,diffTime,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,CDTXTYPE.NONE,nil,nil,nil,40,function ()
        if isSendMsg == false then
            self:timeoutCallback(self.remainRecordTime,true)
            self.huaTong:setVisible(false)
        else
            self.stopRecordLogic(true)
        end
	end,1)
end

-- 播放语音
function ChatUI:playRecord(widget,url)
    if self.isPlaying == true then
        print('isPlaying=========================')
        return
    end
    if not url or url == '' then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES6'), COLOR_TYPE.RED)
        return
    end
    -- 加入动画
    widget.yuyin1:setVisible(false)
    widget.yuyin2:setVisible(false)
    widget.yuyin3:setVisible(false)

    widget.playBtn:setOpacity(0)

    local act1 = cc.CallFunc:create(
	    function ()
            widget.yuyin1:setVisible(true)
            widget.yuyin2:setVisible(false)
            widget.yuyin3:setVisible(false)
		end
    )
    local act2 = cc.CallFunc:create(
	    function ()
            widget.yuyin1:setVisible(true)
            widget.yuyin2:setVisible(true)
            widget.yuyin3:setVisible(false)
		end
    )
    local act3 = cc.CallFunc:create(
	    function ()
            widget.yuyin1:setVisible(true)
            widget.yuyin2:setVisible(true)
            widget.yuyin3:setVisible(true)
		end
    )
    local actDelay = cc.DelayTime:create(0.4)
    widget.playBtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(actDelay,act1,actDelay,act2,actDelay,act3)))

    self.isPlaying = true
    YVSdkMgr:playRecordFromUrl(url)
    local function callBack(result)
        -- 已读的变为未读的,客户端处理
        print('chatui=========================')
        if self then
            self.isPlaying = false
        end
        if widget then
            widget.playBtn:stopAllActions()
            widget.yuyin1:setVisible(false)
            widget.yuyin2:setVisible(false)
            widget.yuyin3:setVisible(false)

            widget.playBtn:setOpacity(255)
        end
        widget.isReadImg:setVisible(false)
    end
    YVSdkMgr:setFinishPlayCallBack(callBack)

end

function BaseUI:onHide()
    if( self.usedCells ~= nil) then
	    self:removeAllUsedCell()
    end
    self.unusedWidget = {}
    self.currentChannel = ""
    self.numOfUnuseCell = 0
end
function ChatUI:ActionClose()
     self.rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.MoveBy:create(0.3, cc.p(-456,0))))
     self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
        end)))
end
function ChatUI:createEditBox(attachNode)
    local maxLen = 64
    self.editbox = cc.EditBox:create(cc.size(attachNode:getContentSize().width - 10,attachNode:getContentSize().height), 'uires/ui/chat/chat_bg_inputzone.png')
    self.editbox:setPosition(cc.p(attachNode:getContentSize().width/2,attachNode:getContentSize().height/2))
    self.editbox:setFont('font/gamefont.ttf',20)
    self.editbox:setFontColor(cc.c4b(100,45,16,255))
    self.editbox:setPlaceholderFontColor(cc.c4b(100,45,16,255))
    self.editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editbox:setMaxLength(maxLen*10)
    attachNode:addChild(self.editbox)
    self.editbox:setLocalZOrder(0)
    --self.inputText:setLocalZOrder(1)
    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    self.nameTx:setPosition(cc.p(5,attachNode:getContentSize().height/2))
    self.nameTx:setColor(cc.c4b(100,45,16,255))
    --self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    --self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0,0.5))
    self.nameTx:setName('name_tx')
    attachNode:addChild(self.nameTx)

    local oldStr = ''
    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.editbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
        elseif event == "ended" then
            local str = self.editbox:getText()
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
            self.editbox:setText('')
        end
    end)
end

function ChatUI:registerTouchEvents()

    local function clickInputBtn (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:SendChatMessage()
            AudioMgr.PlayAudio(11)
        end
    end
    self.inputBtn:addTouchEventListener(clickInputBtn)
   


    for i = 1,self.numOChannels do
        local function clickTable(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                AudioMgr.PlayAudio(11)
                if i == 2 then
                    local newImg  = ccui.Helper:seekWidgetByName(self.channelBtns[2],"new_img")
                    newImg:setVisible(false)
                end

                --local countryVisible = GlobalApi:getOpenInfo('country')
                local countryVisible = true
                if(i == 2 and UserData:getUserObj():getLid() == 0) then
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CHAT_NOGROUP')), MESSAGE_BOX_TYPE.MB_OK_CANCEL)
                    return
                elseif i == 4 and not countryVisible then
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('COUNTRY_NOGROUP')), MESSAGE_BOX_TYPE.MB_OK_CANCEL)
                    return
                end

                self.isVoice = false
                if i == 4 then
                    self.inputzone:setVisible(false)
                    self.voicePannel:setVisible(false)
                    self.swithBtn:setVisible(false)
                else
                    self.inputzone:setVisible(true)
                    self.voicePannel:setVisible(true)
                    self.swithBtn:setVisible(true)
                end
                self:changeToChannel(self.channelStrings[i])

            end
        end
        self.channelBtns[i]:addTouchEventListener(clickTable)
    end

   
    local function scrollViewEvent(sender, evenType)
        --if evenType == ccui.ScrollviewEventType.scrolling then
            self:onChatViewScrolling()
        --end
    end
    self.chatView:addEventListener(scrollViewEvent)

    local function clickClose(sender, evenType)
        ChatMgr:hideChat()
    end
    self.closeBtn:addTouchEventListener(clickClose)
end
function ChatUI:replaceTextToRichText(chatCell)
    local tempText = ccui.Helper:seekWidgetByName(chatCell,"chatText")

    local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("RELOAD_NEW_CLIENT"), "font/gamefont.ttf", 22)
	msg:setAnchorPoint(cc.p(0, 1))
	msg:setMaxLineWidth(280)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    msg:setColor(cc.c4b(100,45,16,255))

    chatCell.contentBG:addChild(msg)
    msg:setPosition(cc.p(tempText:getPosition()))
    chatCell.contentTTF = msg

    local msg2 = cc.Label:createWithTTF(GlobalApi:getLocalStr("RELOAD_NEW_CLIENT"), "font/gamefont.ttf", 22)
	msg2:setAnchorPoint(cc.p(0, 1))
	msg2:setMaxLineWidth(280)
	msg2:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    msg2:setColor(cc.c4b(100,45,16,255))
	msg2:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))

    chatCell.contentBG:addChild(msg2)
    msg2:setPosition(cc.p(tempText:getPosition()))
    chatCell.contentTTFSpecial = msg2
end

--切换频道
function ChatUI:changeToChannel(channelString)
    if (channelString == "world") or (channelString == "legion") then
        self.voicePannel:setVisible(true)
        self.swithBtn:setVisible(true)
    else
        self.voicePannel:setVisible(false)
        self.swithBtn:setVisible(false)
    end

    if(self.currentChannel == channelString) then
        self:switchVoiceState()
        return
    else
        self.currentChannel = channelString
        self:switchVoiceState()
    end

    for i = 1,self.numOChannels do
        if(self.channelStrings[i] == channelString) then
            self.channelBtns[i]:loadTextureNormal('uires/ui/chat/chat_btn_light.png')
            self.channelTexts[i]:setTextColor(COLOR_TYPE.PALE)
        else
            self.channelBtns[i]:loadTextureNormal('uires/ui/chat/chat_btn_dark.png')
            self.channelTexts[i]:setTextColor(COLOR_TYPE.DARK)
        end
    end

    self:removeAllUsedCell();

    if(self.currentChannel == "world") then
        self.currentChannelCells = ChatMgr.normalChannelDatas
        self.trumpetPanel:setVisible(false)
    elseif(self.currentChannel == "legion") then
        self.currentChannelCells = ChatMgr.groupChannelDatas
        self.trumpetPanel:setVisible(false)
    elseif(self.currentChannel == "system") then
        self.currentChannelCells = ChatMgr.countryChannelDatas
        self.trumpetPanel:setVisible(false)
    else
        self.currentChannelCells = ChatMgr.trumpetChannelDatas
         --喊话频道有喇叭显示
         self:refreshShoutItemNum()
    end
     self.chatView.alignmentTop = true

    --屏幕适应
    self:doLayout()
    --填充内容
    self:refreshView()

end

-- 切换状态
function ChatUI:switchVoiceState()
    if (self.currentChannel == "world") or (self.currentChannel == "legion") then
        self.voicePannel:setVisible(self.isVoice)
        self.inputzone:setVisible(not self.isVoice)
        if self.isVoice then    -- 语音状态
            self.swithBtn:loadTexture("uires/ui/chat/chat_jianpan.png")
        else
            self.swithBtn:loadTexture("uires/ui/chat/chat_huatong.png")
        end

    end

end

function ChatUI:refreshShoutItemNum()
    self.trumpetPanel:setVisible(true)
    self.trumpetText:setString(GlobalApi:getLocalStr("CHAT_TRUMPET"));
    local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("shoutCostId")))

    if(item == nil) or item:getNum() == 0 then
        self.trumpetNum:setString("（0）")
        self.trumpetNum:setColor(COLOR_TYPE.RED)
    else
        self.trumpetNum:setString("（" .. item:getNum() .. "）")
        self.trumpetNum:setColor(COLOR_TYPE.WHITE)
    end
end

function ChatUI:refreshGiftItem(id)
    
    for k,cell in pairs(self.currentChannelCells) do
        if(cell.info ~= nil and cell.info.boon ~= nil and cell.info.boon.id == id) then
            cell.info.used = true
            if(cell.root ~= nil) then
                local widget = cell.root
                widget.chatBtn:setTouchEnabled(false)
                widget.btnText:setString(GlobalApi:getLocalStr("STR_HAVEGET"))
                widget.btnText:enableOutline(COLOROUTLINE_TYPE.WHITE2,1)
                widget.chatBtn:loadTextureNormal("uires/ui/common/common_btn_6.png") 
                widget.chatBtn:setContentSize(cc.size(108,60))
            end
        end
    end


end
--屏幕适应
function ChatUI:doLayout()
    self.layouting = true
    local winSize = cc.Director:getInstance():getWinSize()

    self.leftBG:setContentSize(cc.size(self.leftBG:getContentSize().width,winSize.height))
   
    self.tabs:setPositionY(winSize.height-1)
    local contentSize = cc.size(self.content:getContentSize().width, winSize.height - self.tabs:getContentSize().height)
    self.content:setContentSize(contentSize)

    self.textClip:setPositionX(460.40 - 10)
        --世界频道有喇叭显示
    if(self.currentChannel == "shout") then
        self.textClip:setContentSize(cc.size(255,self.textClip:getContentSize().height))
        self.editbox:setContentSize(cc.size(255,self.textClip:getContentSize().height))
        self.editbox:setPosition(cc.p(self.textClip:getContentSize().width/2,self.textClip:getContentSize().height/2))
        self.textClip:setPositionX(460.40)
    elseif (self.currentChannel == "world") or (self.currentChannel == "legion") then
        self.textClip:setContentSize(cc.size(350,self.textClip:getContentSize().height))
        self.editbox:setContentSize(cc.size(350,self.textClip:getContentSize().height))
        self.editbox:setPosition(cc.p(self.textClip:getContentSize().width/2,self.textClip:getContentSize().height/2))
    else
        self.textClip:setContentSize(cc.size(460,self.textClip:getContentSize().height))
        self.editbox:setContentSize(cc.size(460,self.textClip:getContentSize().height))
        self.editbox:setPosition(cc.p(self.textClip:getContentSize().width/2,self.textClip:getContentSize().height/2))
    end
    
    contentSize.width   = self.chatBG:getContentSize().width
    contentSize.height  = contentSize.height -  self.inputzone:getContentSize().height
    self.chatBG:setContentSize(contentSize)
   
    contentSize.height =  contentSize.height - 30
    self.chatView.viewSize = cc.size(contentSize.width,contentSize.height)
    self.chatView:setContentSize(contentSize)
    self.chatView:getInnerContainer():setContentSize(contentSize)
 
    self.layouting = false
end
function ChatUI:refreshView()
    
    
    self:resetPosition(self.currentChannelCells)

    if(self.chatView.cellTotalHeight > self.chatView.viewSize.height) then
        self.chatView.alignmentTop = false
        local newSize = cc.size(self.chatView.viewSize.width,self.chatView.cellTotalHeight)
        self.chatView:getInnerContainer():setContentSize(newSize)
    end
    self:onChatViewScrolling(true)
    self.chatView:interceptTouchEvent(ccui.TouchEventType.began,self.chatView,cc.Touch:new())
    self.chatView:jumpToBottom()
    self:doCellsAlignment()
    
end


function ChatUI:onChatViewScrolling(force)
     
     if(#self.currentChannelCells < 1 or not force and ( self.layouting or self.chatView.alignmentTop)) then
        return
     end
     
     local viewStartPos = -self.chatView:getInnerContainerPosition().y
     local viewEndPos = viewStartPos + self.chatView.viewSize.height

     local startIndex = self:_getIndexFromPos(viewEndPos)
     local endIndex   = self:_getIndexFromPos(viewStartPos)

     if(startIndex == -1 or endIndex < startIndex) then
        print("ChatUI:onChatViewScrolling:endIdx < stardIdx")
        return
     end

     local removeCells = nil
     for k,cell in pairs(self.usedCells) do
        if(cell.index < startIndex or cell.index > endIndex) then
            removeCells = removeCells or {}
            table.insert(removeCells,cell)           
        end
     end

     if(removeCells ~= nil) then
        for k,cell in pairs(removeCells) do
            self:removeUsedCell(cell)
        end
     end
     for i = startIndex,endIndex do
        if(self.currentChannelCells[i].root == nil) then
            self:showCell(self.currentChannelCells[i])
        end
     end

     self.chatView:setBounceEnabled(true)
end
function ChatUI:removeBottomCell(cell)
    if(cell.root ~= nil) then
       self:removeUsedCell(cell)
    end

    self:resetPosition(self.currentChannelCells)
    self:onChatViewScrolling()
end

function ChatUI:removeUsedCell(cell)
    if(cell.root == nil) then
        return
    end
    local i = 1
    for k,v in pairs(self.usedCells) do
        if(v == cell)  then
            table.remove(self.usedCells,i)
            break
        end
        i = i+1
    end

    local cellWidget = cell.root

    cellWidget:setVisible(false)
    cell.root = nil
    table.insert(self.unusedWidgets,self.numOfUnuseCell + 1,cellWidget)
    self.numOfUnuseCell = self.numOfUnuseCell + 1
end

function ChatUI:removeAllUsedCell()
    for k,cell in pairs(self.usedCells) do
        local cellWidget = cell.root
        cellWidget:setVisible(false)
        cell.root = nil

        table.insert(self.unusedWidgets,self.numOfUnuseCell + 1,cellWidget)
        self.numOfUnuseCell = self.numOfUnuseCell + 1
    end

    self.usedCells = {}
end 

function  ChatUI:_getIndexFromPos(pos)
    local low = 1
    local high= #self.currentChannelCells

    local search = pos

    while (high >= low) do
        local index = math.floor(low + (high - low) / 2);
        local cellStart = self.currentChannelCells[index].minY;
        local cellEnd   = self.currentChannelCells[index].maxY

        if (search >= cellStart and search <= cellEnd) then
            return index
        elseif (search < cellEnd) then
            low = index + 1
        else
            high = index - 1
        end
    end

    if (low <= 1)  then
        return 1
    end

    if(high >= #self.currentChannelCells) then
        return #self.currentChannelCells
    end

    return -1;
end

function ChatUI:SendChatMessage()

    local sendString = self.nameTx:getString()
    if (sendString == "") then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_39'), COLOR_TYPE.RED)
        return
    end
    if ChatMgr:judgeSpeakIsOutTime() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_1'), COLOR_TYPE.RED)
        return
    end

    -- 判断是否和保存的聊天内容是一样的
    local uid = UserData:getUserObj():getUid()
    local judge = false
    for i = 1,10 do
        local str = cc.UserDefault:getInstance():getStringForKey(uid .. 'chatcontent' .. i,'')
        if str and str ~= '' then
            local a = string.find(sendString,str)
            local b = string.find(str,sendString)
            if sendString == str or a or b then
                judge = true
                break
            end
        end
    end

    if ChatMgr:judgeSpeakLimitTime() == false then
        for i = 1,10 do
            cc.UserDefault:getInstance():setStringForKey(uid .. 'chatcontent' .. i,'')
        end
        ChatMgr:resetSpeakLimitCdTime()
        judge = false
    end

    if judge == true then
        promptmgr:showSystenHint('你的发言过于频繁，请在两分钟后再试！', COLOR_TYPE.RED)
        return
    end

    local index = 1
    for i = 1,10 do
        local str = cc.UserDefault:getInstance():getStringForKey(uid .. 'chatcontent' .. i,'')
        if not str or str == '' then
            index = i
            break
        end
    end
    cc.UserDefault:getInstance():setStringForKey(uid .. 'chatcontent' .. index,sendString)


    ChatMgr:resetCdTime()
    if(self.currentChannel == "shout") then
         local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("shoutCostId")))
         if(item == nil) then
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CHAT_TRUMPET_NE')), MESSAGE_BOX_TYPE.MB_OK_CANCEL)
         else
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CHAT_TRUMPET_COST')), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                 ChatMgr:SendChatMsg(self.currentChannel,sendString)
                 self.nameTx:setString("")
                 self.inputText:setString("")
            end)
         end
    else
         ChatMgr:SendChatMsg(self.currentChannel,sendString)
         self.nameTx:setString("")
         self.inputText:setString("")
    end 
end

function ChatUI:GetCellHeight(cell)
    local minHeight = 54
    if cell.act == 'system' then  -- 系统消息
        self.heightComp:setMaxLineWidth(380)
        local str,htmlstr = ChatMgr:getDesc(cell.sub_type,cell.str_array)
        self.heightComp:setString(str)
        local textHeight = self.heightComp:getContentSize().height
        if(textHeight < minHeight) then
            textHeight = minHeight
        end
        local cellHeight = 56 + textHeight
        return cellHeight
    else
        if(cell["type"] == "legion" and cell.info ~= nil) then
            self.heightComp:setMaxLineWidth(270)
            cell.content = GlobalApi:getLocalStr("CHAT_GIFT")
            minHeight = 70
        else
            self.heightComp:setMaxLineWidth(380)
        end

        self.heightComp:setString(cell.content)
        local textHeight = self.heightComp:getContentSize().height
        if(textHeight < minHeight) then
            textHeight = minHeight
        end
        local cellHeight = 56 + textHeight
        if ChatMgr.judgeIsVoice(cell) then    -- 如果是语音
            cellHeight = cellHeight + YUYINHEIGHT
        end
        return cellHeight
    end

end

function ChatUI:ShowNewMessage(newCell)
    self:resetPosition(self.currentChannelCells)

    if(self.chatView.cellTotalHeight > self.chatView.viewSize.height) then
        local newSize = cc.size(self.chatView.viewSize.width,self.chatView.cellTotalHeight)
        self.chatView:getInnerContainer():setContentSize(newSize)
    end

    --最后一条消息在显示框内,新消息立即显示在界面上
    if(self:isLastCellInView()) then
        self:showCell(newCell)

        self:doCellEnterAction(newCell.root)

        if(self.chatView.alignmentTop) then
            self:doCellsAlignment()
        else
             self.chatView:interceptTouchEvent(ccui.TouchEventType.began,self.chatView,cc.Touch:new())
            self.chatView:jumpToBottom()
        end

        --刷新一下，回收被挤出屏幕的CELL
        self:onChatViewScrolling()
    end
end

function ChatUI:resetPosition(cells)
    
    local totalHeight = 0
    local curCell = nil
    for i =#cells,1,-1 do
        curCell = cells[i]
        curCell.index = i
        if(curCell.cellhight == nil) then
            curCell.cellHeight = self:GetCellHeight(curCell)
        end
        curCell.minY = totalHeight
        curCell.maxY = curCell.minY + curCell.cellHeight + self.cellSpace;
        totalHeight  = curCell.maxY
        if(curCell.root ~= nil) then
            curCell.root:setPositionY(curCell.minY)
            print(curCell.minY)
        end
    end

    self.chatView.cellTotalHeight = totalHeight

end
function ChatUI:doCellsAlignment()
    if(self.chatView.cellTotalHeight > self.chatView.viewSize.height) then
        --所有元素高度大于滚动区域时,处于画面中最下面的元素贴着底部
        for i = 1,#self.usedCells do
            self.usedCells[i].root:setPositionY(self.usedCells[i].minY)
        end
        self.chatView:interceptTouchEvent(ccui.TouchEventType.began,self.chatView,cc.Touch:new())
        self.chatView:jumpToBottom()
        self.chatView.alignmentTop = false
    else
        --所有元素高度小于滚动区域时,处于画面中最上面的元素贴着顶部
        local currentY = self.chatView.viewSize.height
         for i = 1,#self.usedCells do
            currentY = currentY - self.usedCells[i].cellHeight
            self.usedCells[i].root:setPositionY(currentY)
            currentY = currentY -  self.cellSpace
        end
    end
end
function ChatUI:isLastCellInView()
    if(#self.currentChannelCells <= 1) then
        return true
    end

    local lastCell = self.currentChannelCells[#self.currentChannelCells -1]

    if(lastCell.root == nil) then
        return false
    end

    local cellTop = lastCell.root:getContentSize().height
        

    if(cellTop > self.chatView:getInnerContainerPosition().y) then
        return true
    else
        return false
    end
end
function ChatUI:showCell(cell)
    local widget = self:GetOrCreateCell()
    local function playCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if YVSdkMgr.loginResult == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES7'), COLOR_TYPE.RED)
                return
            end

            if self.isPlaying then
                YVSdkMgr:stopPlay()
            else
                cell.user.isRead = true
                self:playRecord(widget,cell.voice_url)
            end
            
        end
    end
    widget.playBtn:addTouchEventListener(playCallBack)

    widget.icon:setTouchEnabled(true)
    widget.icon:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if tonumber(cell.user.uid) ~= tonumber(UserData:getUserObj():getUid()) then
                ChatMgr:hideChat()
                BattleMgr:showCheckInfo(cell.user.uid,'world','arena')
            end
        end
    end)

    if cell.act == 'system' then  -- 系统消息
        widget.contentTTF:setMaxLineWidth(380)
        local str,htmlstr = ChatMgr:getDesc(cell.sub_type,cell.str_array)
        widget.contentTTF:setString(str)
        widget:setVisible(true)
        widget:setPositionY(cell.minY)

        widget.vipIcon:setVisible(false)
        widget.nameBG:setVisible(false)
        widget.chatBtn:setVisible(false)
        widget.yuyinNode:setVisible(false)
        widget.levelText:setVisible(false)
        widget.systemTitleTx:setVisible(true)
        widget.systemTx:setVisible(true)
        widget.icon:loadTexture("uires/icon/hero/xiaoqiao_icon.png")
        widget.contentTTFSpecial:setVisible(false)
    else
------------------------------------------------------------------------------------------------------------------
        widget.vipIcon:setVisible(true)
        widget.nameBG:setVisible(true)
        widget.chatBtn:setVisible(true)
        widget.yuyinNode:setVisible(true)
        widget.levelText:setVisible(true)
        widget.systemTitleTx:setVisible(false)
        widget.systemTx:setVisible(false)
        widget.contentTTFSpecial:setVisible(true)

        if(cell.info == nil) then
            widget.chatBtn:setVisible(false)
            widget.contentTTF:setMaxLineWidth(380)
        else
            widget.chatBtn:setVisible(true)

            if cell.info.roomId then
                widget.btnText:setString(GlobalApi:getLocalStr("COUNTRY_JADE_DES43"))
                widget.btnText:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
                widget.chatBtn:loadTextureNormal("uires/ui/common/common_btn_5.png") 
                widget.chatBtn:setTouchEnabled(true)

                local pos = 1
                local subType = GameData:getConfData('countryjade')[tonumber(cell.info.jade)].subType
                if subType == 1 then
                    pos = 2
                else
                    pos = 1
                end

                local function clickGet(sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        local function callBack(msg)
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES44'), COLOR_TYPE.GREEN)
                        end
                        CountryJadeMgr:joinRoomFromServer(cell.info.roomId,pos,callBack)   -- i是位置
                    end
                end
                widget.chatBtn:addTouchEventListener(clickGet)
            else
                if(cell.info.used and cell.info.used ~= 0) then
                    widget.btnText:setString(GlobalApi:getLocalStr("STR_HAVEGET"))
                    widget.btnText:enableOutline(COLOROUTLINE_TYPE.WHITE2,1)
                    widget.chatBtn:loadTextureNormal("uires/ui/common/common_btn_6.png") 
                    widget.chatBtn:setTouchEnabled(false)
                else
                    widget.btnText:setString(GlobalApi:getLocalStr("STR_GET_1"))
                    widget.btnText:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
                    widget.chatBtn:loadTextureNormal("uires/ui/common/common_btn_5.png") 
                    widget.chatBtn:setTouchEnabled(true)

                    local function clickGet(sender, eventType)
                        if eventType == ccui.TouchEventType.ended then
                            if(tonumber(UserData:getUserObj():getLegionInfo().grab_boon) < tonumber(GlobalApi:getGlobalValue("grabBoonPerDay"))) then
                                ChatMgr:SendOpenGiftMsg(cell.info.boon.id)
                                AudioMgr.PlayAudio(11) 
                            else
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("CHAT_GRAB_MAXNUMBER"), COLOR_TYPE.RED);
                            end
                        end
                    end
                   widget.chatBtn:addTouchEventListener(clickGet)
                end
            end
            widget.contentTTF:setMaxLineWidth(270)
            widget.contentTTFSpecial:setMaxLineWidth(270)
        end

        widget.imgV:setVisible(false)
        widget.vipLabel:setVisible(false)

        -- 先判断玩家是否有霸主的称号，然后设置玩家名字的位置
        local lordJudge = false
        if cell.title then
            local charLordConf = GameData:getConfData('chatlord')
            local confData = charLordConf[cell.title]
            if confData then
                widget.lord:setVisible(true)
                widget.lord:loadTexture(confData.icon)
                lordJudge = true
            else
                widget.lord:setVisible(false)
            end
        else
            widget.lord:setVisible(false)
        end
        if lordJudge == true then
            widget.nameText:setPositionX(widget.lord:getPositionX() + widget.lord:getContentSize().width)
        else
            widget.nameText:setPositionX(17.46)
        end

        if(cell.isSystem) then
            widget.nameText:setString(GlobalApi:getLocalStr("CHAT_SYSTEM_MSG"))
            widget.levelText:setString("")
            widget.timeText:setString("")
            widget.icon:loadTexture("uires/icon/hero/liubei_icon.png")
            widget.vipIcon:setVisible(false)
        else
            widget.nameText:setString(cell.user.un)
            if(cell.user.vip >= 1) then
                widget.imgV:setVisible(true)
                widget.vipLabel:setVisible(true)

                widget.imgV:setPosition(cc.p(widget.nameText:getPositionX() + widget.nameText:getContentSize().width + 2,widget.nameText:getPositionY()))
                widget.vipLabel:setPosition(cc.p(widget.imgV:getPositionX() + widget.imgV:getContentSize().width - 2,widget.imgV:getPositionY()))
                widget.vipLabel:setString(cell.user.vip)
            end
            if(cell.user.vip >= 13) then
                widget.vipIcon:setVisible(true)
            else
                widget.vipIcon:setVisible(false)
            end
            widget.levelText:setString("Lv."..cell.user.level)
            widget.timeText:setString(Time.date("%m/%d %H:%M", cell.time))
            local data = GameData:getConfData('settingheadicon')
            if(data[cell.user.headpic] ~= nil) then
                widget.icon:loadTexture(data[cell.user.headpic].icon)
            else
                print("chat:can not find head icon by headpic index:"..cell.user.headpic)
            end
        
        end

        widget.contentTTF:setColor(cc.c4b(100,45,16,255))

        local content = cell.content
        if cell.info and cell.info.roomId then    -- 玉璧加入
            local color = COLOR_TYPE.GREEN
            local jadeType = GameData:getConfData('countryjade')[tonumber(cell.info.jade)].type
            if jadeType == 1 then
                color = COLOR_TYPE.GREEN
            elseif jadeType == 2 then
                color = COLOR_TYPE.BLUE
            elseif jadeType == 3 then
                color = COLOR_TYPE.PURPLE
            elseif jadeType == 4 then
                color = COLOR_TYPE.ORANGE
            elseif jadeType == 5 then
                color = COLOR_TYPE.RED
            end

            local des2 = GameData:getConfData('countryjade')[tonumber(cell.info.jade)].desc
            content = GlobalApi:getLocalStr("COUNTRY_JADE_DES45") .. des2 .. GlobalApi:getLocalStr("COUNTRY_JADE_DES46")
            widget.contentTTF:setColor(color)

            widget.contentTTFSpecial:setColor(color)
            widget.contentTTFSpecial:setVisible(true)
            widget.contentTTF:setVisible(false)
        else
            widget.contentTTFSpecial:setVisible(false)
            widget.contentTTF:setVisible(true)
        end
        widget.contentTTFSpecial:setString(content)

        widget.contentTTF:setString(content)
        widget:setVisible(true)
        widget:setPositionY(cell.minY)

        -- 语音相关
        if ChatMgr.judgeIsVoice(cell) then
            widget.yuyinNode:setVisible(true)
            if cell.user.isRead == true then    -- 已经读取
                widget.isReadImg:setVisible(false)
            else
                widget.isReadImg:setVisible(true)
            end
            widget.seconds:setString(cell.voice_time .. '"')
        else
            widget.yuyinNode:setVisible(false)
        end
------------------------------------------------------------------------------------------------------------------
    end

    --调整尺寸/坐标
    widget.contentBG:setContentSize(cc.size(widget.contentBG:getContentSize().width,cell.cellHeight))
    widget:setContentSize(cc.size(widget:getContentSize().width,cell.cellHeight))
    widget.iconBG:setPositionY(cell.cellHeight - 7)
    widget.nameBG:setPositionY(cell.cellHeight - 4)
    widget.systemTitleTx:setPositionY(cell.cellHeight - 16)
    widget.chatBtn:setPositionY(cell.cellHeight - 70)
    widget.yuyinNode:setPositionY(cell.cellHeight - 65)
    if cell.act == 'system' then  -- 系统消息
        widget.contentTTF:setPositionY(cell.cellHeight - 46)
    else
        if ChatMgr.judgeIsVoice(cell) then    -- 如果是语音
            widget.contentTTF:setPositionY(cell.cellHeight - 46 - YUYINHEIGHT)
        else
            widget.contentTTF:setPositionY(cell.cellHeight - 46)
        end
    end
    cell.root  = widget
    table.insert(self.usedCells,cell)
end

function ChatUI:GetOrCreateCell()
    
    local ret  = nil
    if(self.numOfUnuseCell > 0) then
        ret = self.unusedWidgets[self.numOfUnuseCell]
        table.remove(self.unusedWidgets,self.numOfUnuseCell)
        self.numOfUnuseCell = self.numOfUnuseCell - 1
    else
        ret = self.tempCell:clone()
        ret.iconBG = ccui.Helper:seekWidgetByName( ret,"rollIconbg")
        ret.icon      = ccui.Helper:seekWidgetByName( ret.iconBG,"rollIcon")
        ret.levelText = ccui.Helper:seekWidgetByName( ret.iconBG,"levelText")
        ret.vipIcon   = ccui.Helper:seekWidgetByName( ret.iconBG,"vipIcon")

        ret.contentBG =  ccui.Helper:seekWidgetByName(ret,"bg")
        ret.nameBG    =  ccui.Helper:seekWidgetByName(ret,"namebg")
        ret.lord      =  ccui.Helper:seekWidgetByName(ret.nameBG,"lord")
        ret.imgV      =  ccui.Helper:seekWidgetByName(ret.nameBG,"img_v")
        ret.nameText  =  ccui.Helper:seekWidgetByName(ret.nameBG,"nameText")
        ret.timeText  =  ccui.Helper:seekWidgetByName(ret.nameBG,"timeText")
        ret.vipText   =  ccui.Helper:seekWidgetByName(ret.nameBG,"vipText")
        ret.chatBtn   =  ccui.Helper:seekWidgetByName( ret,"chatBtn")
        ret.btnText   =  ccui.Helper:seekWidgetByName( ret.chatBtn,"btnText")

        ret.systemTitleTx = ccui.Helper:seekWidgetByName( ret,"system_title_tx")
        ret.systemTx = ccui.Helper:seekWidgetByName( ret,"system_tx")
        ret.systemTitleTx:setString(GlobalApi:getLocalStr('CHAT_DESC_3'))
        ret.systemTx:setString(GlobalApi:getLocalStr('CHAT_DESC_3'))
        ret.vipText:setVisible(false)

        ret.chatBtn:setPositionX(ret.chatBtn:getPositionX() - 6)

        ret.timeText:setAnchorPoint(cc.p(1,0.5))
        ret.timeText:setPositionX(ret.chatBtn:getPositionX() + ret.chatBtn:getContentSize().width/2 - 12)
        self:replaceTextToRichText(ret)
        local vipLabel = cc.LabelAtlas:_create(1, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	    vipLabel:setAnchorPoint(cc.p(0, 0.5))
	    ret.nameBG:addChild(vipLabel)
        ret.vipLabel = vipLabel

        ret.imgV:setScale(0.9)
        ret.vipLabel:setScale(0.9)

        self.chatView:addChild(ret)

        -- 语音部分
        ret.yuyinNode = ret.contentBG:getChildByName('yuyin_node')
        ret.playBtn = ret.yuyinNode:getChildByName('play_btn')
        ret.isReadImg = ret.yuyinNode:getChildByName('is_read')
        ret.seconds = ret.yuyinNode:getChildByName('seconds')
        ret.yuyin1 = ret.yuyinNode:getChildByName('yuyin1')
        ret.yuyin2 = ret.yuyinNode:getChildByName('yuyin2')
        ret.yuyin3 = ret.yuyinNode:getChildByName('yuyin3')

        ret:setScale(0.9)
        ret:setPositionX(ret:getPositionX() + 20)
    end
    return ret
end

function ChatUI:doCellEnterAction(cellRoot)
    cellRoot:setPositionX(cellRoot:getPositionX() + self.chatView.viewSize.width)
    cellRoot:runAction(cc.MoveBy:create(0.3,cc.p(-self.chatView.viewSize.width,0)))
end
function ChatUI:getVipTextColor(vipLevel)
    if(vipLevel == nil) then
        return COLOR_TYPE.WHITE
    end

    if(vipLevel >= 1 and vipLevel <= 4) then
        return COLOR_TYPE.ORANGE
    elseif(vipLevel >= 5 and vipLevel <= 8) then
        return cc.c4b(243,251,13, 255)
    elseif(vipLevel >= 9 and vipLevel <= 12) then
        return COLOR_TYPE.RED
    elseif(vipLevel >= 13 ) then
        return COLOR_TYPE.RED
    end

    return COLOR_TYPE.WHITE
end

--- 更新军团按钮的状态
function ChatUI:updatelegionBtnState()
    local newImg  = ccui.Helper:seekWidgetByName(self.channelBtns[2],"new_img")

    local value = false
    if ChatMgr then
        value =  ChatMgr.isChatShow
    end

    newImg:setVisible(value)
end


return ChatUI


