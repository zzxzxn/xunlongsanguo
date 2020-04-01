local ChatNewUI = class("ChatNewUI", BaseUI)
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local ClassItemCell = require('script/app/global/itemcell')

local CAMP_COLOR = {
    COLOR_TYPE.BLUE,
    COLOR_TYPE.GREEN,
    COLOR_TYPE.RED,
}

-- 右边聊天内容的间距
local CELL_SPACE = 30 - 7

-- 右边聊天内容项的基本宽和高
local CELL_WIDTH = 486
local CELL_HEIGHT = 76 + 7

-- 里面的项是纯文本的时候的高度
local CELL_TEXT_HEIGHT = 24

-- 右边聊天文本最大限制宽
local MAX_TEXT_WIDTH = 290

-- 右边聊天文本背景图片文字距离左、右、上、下边的间距像素
local LIMIT_TEXT_BG_LR_SPACE = 10       -- 左右
local LIMIT_TEXT_BG_UD_SPACE = 10       -- 上下
local LIMIT_TEXT_BG_ARROW_WIDTH = 5     -- 聊天背景图片箭头的宽度

-- 右边聊天项聊天文本背景图片基本高度,基本宽度(宽度也是最小的宽度)
local TEXT_BG_WIDTH = 62
local TEXT_BG_HEIGHT = 47

-- 语音的高度
local YUYIN_HEIGHT = 45

-- 语音图片的高度，数据有待测试
local YUYIN_IMG_HEIGHT = 40

-- 没文本的时候语音的宽度
local YUYIN_NOT_TEXT_WIDTH = 110
------------------------------- 聊天内容参数控制 -----------------------------------------

--------------------------------- 语音相关参数 -------------------------------------------
-- 最大录制时间
local MAX_RECORD_TIME = 20

-- 剩余倒计时时间
local REMAIN_RECORD_TIME = 10

-- 快速点击时间限制
local SPEED_CLICK_TIME = 0.3
--------------------------------- 语音相关参数 -------------------------------------------

local CHAT_CHANNEL_TYPE_INDEXS = {
    [1] = {1,2,3,4},        -- 默认聊天
    [2] = {6,5,1,2},        -- 国战聊天
}

local CHAT_CHANNEL_TYPE = {
    [1] = 'world',
    [2] = 'legion',
    [3] = 'system',
    [4] = 'shout',
    [5] = 'countrywar',
    [6] = 'countrywar_shout',
}

local CHOOSE_BTN_NORMAL = 'uires/ui/chat/chat_anniu4.png'
local CHOOSE_BTN_PRESS = 'uires/ui/chat/chat_anniu3.png'

local LEGION_JIARU_BTN = 'uires/ui/chat/chat_jiaru.png'
local LEGION_SHENGQING_BTN = 'uires/ui/chat/chat_shenqing.png'
local LEGION_YISHENGQING_BTN = 'uires/ui/chat/chat_yishenqing.png'
local LEGION_CHEXIAO_BTN = 'uires/ui/chat/chat_chexiao.png'

function ChatNewUI:ctor(type)
    self.uiIndex = GAME_UI.UI_NEW_CHAT
    self.type = type or 1
    self.chatChannelTypeIndexs = CHAT_CHANNEL_TYPE_INDEXS[self.type]
    self.curChannelIndex = self.chatChannelTypeIndexs[1]
    if type == 2 then
        self.curChannelIndex = self.chatChannelTypeIndexs[2]
    end
    self.curChannelStrings = CHAT_CHANNEL_TYPE[self.curChannelIndex]
    self.chatDatas = {}
    self.menuBtns = {}

    -- 是否是语音模式，false:文本，true：语音
    self.isVoice = false
    -- 语音触摸是否在范围内
    self.atRange = false
    -- 是否正在播放
    self.isPlaying = false
    -- 最大录音时间内是否发送
    self.isSendRecord = false
    self.isTouch = false
    self.allTime = 0
end

function ChatNewUI:init()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local bgImg = self.root:getChildByName("bg_img")
    bgImg:setContentSize(winSize)
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.rootBG = self.root:getChildByName("root")
    local closeBtn = self.rootBG:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ChatNewMgr:hideChat()
        end
    end)

    local bg = self.rootBG:getChildByName('bg')
    local content = bg:getChildByName('content')
    self.content = content
    local svBg = content:getChildByName('sv_bg')
    self.svBg = svBg
    self.chatOtherCell = svBg:getChildByName('chat_other_cell')
    self.chatOtherCell:setVisible(false)
    self.chatMyCell = svBg:getChildByName('chat_my_cell')
    self.chatMyCell:setVisible(false)

    self.chatsvTemp = svBg:getChildByName('sv')
    self.chatsvTemp:setScrollBarEnabled(false)
    self.chatsvTemp:setVisible(false)

    self.chatTx = self.svBg:getChildByName('chat_tx')
    self.chatTx:setVisible(false)
    local msg = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
	msg:setAnchorPoint(cc.p(0, 1))
	msg:setPosition(cc.p(262, 216))
	msg:setMaxLineWidth(MAX_TEXT_WIDTH)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	msg:setColor(COLOR_TYPE.ORANGE)
	msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    self.root:addChild(msg)
    self.heightComp = msg
    self.heightComp:setVisible(false)

    local currentPos = cc.p(self.rootBG:getPositionX(),self.rootBG:getPositionY())
    self.rootBG:setPositionX(currentPos.x - (660+48))
    self.rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.MoveTo:create(0.3, currentPos)))

    self:initVoice()
    self:initLeftMenus()
    self:changeChannel(self.curChannelIndex)
end

function ChatNewUI:ActionClose()
    self.rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.MoveBy:create(0.3, cc.p(-(660+48),0))))
    self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(0.35),cc.CallFunc:create(function ()
        self:hideUI()
    end)))
end

function ChatNewUI:initVoice()
    -- inputzone 
    self.inputzone  = self.rootBG:getChildByName('inputzone')
    self.inputBtn   = self.inputzone:getChildByName('inputBtn')
    self.textClip   = self.inputzone:getChildByName('clip')
    self.inputText  = self.textClip:getChildByName('inputText')
    self:createEditBox(self.textClip)

    self.chatLimit = self.inputzone:getChildByName('chat_limit')
    self:refreshChatLimitCount()

    local function clickInputBtn(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:SendChatMessage()
        end
    end
    self.inputBtn:addTouchEventListener(clickInputBtn)
    
    -- 喊话
    self.shoutPanel = self.rootBG:getChildByName('trumpet_panel')
    self.trumpetText = self.shoutPanel:getChildByName('trumpet_text')
    self.trumpetNum = self.shoutPanel:getChildByName('trumpet_num')

    -- 军团招人
    self.legionBtn = self.rootBG:getChildByName('legion_btn')
    self.legionBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local type = UserData:getUserObj():getLtype()
            if type == 2 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_SUC2'), COLOR_TYPE.RED)
                return
            end

            -- 冷却时间到没
            local legionglobalconf = GameData:getConfData('legion')
            local legionHeadSendInvitationTime = tonumber(legionglobalconf['legionHeadSendInvitationTime'].value)
            local legionInfo = UserData:getUserObj():getLegionInfo()
            if GlobalData:getServerTime() - legionInfo.invite_time < legionHeadSendInvitationTime then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_SUC6'), COLOR_TYPE.RED)
                return
            end

            -- 发送给后台
            local function callBack()
                local obj = {
                    type = self.curChannelStrings
                }
                MessageMgr:sendPost('invite','legion',json.encode(obj),function(jsonObj)
                    if jsonObj.code == 0 then
                        GlobalApi:parseAwardData(jsonObj.data.costs)
                        UserData:getUserObj():getLegionInfo().invite_time = GlobalData:getServerTime()
                        if self.curChannelStrings == 'shout' then
                            self:refreshShoutItemNum()
                        end
                    elseif jsonObj.code == 107 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_107_NEW'), COLOR_TYPE.RED)
                    end
                end)
            end

            if self.curChannelStrings == 'shout' then    -- 喊话
                local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("shoutCostId")))
                local num = item and item:getNum() or 0
                if num < 1 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_SUC4'), COLOR_TYPE.RED)
                    return
                end
                promptmgr:showMessageBox(GlobalApi:getLocalStr('LEGION_APPLY_SUC3'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
				    callBack()
			    end)
            else
                callBack()
            end
        end
    end)

    -- voicePannel
    self.voiceMask = self.rootBG:getChildByName('voice_mask')
    self.voiceMask:setVisible(false)

    self.voicePannel = self.rootBG:getChildByName('voice_pannel')
    self.swithBtn = self.rootBG:getChildByName('swith_btn')
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
            if time >= MAX_RECORD_TIME then
                time = MAX_RECORD_TIME
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
                        ChatNewMgr:SendChatMsg(self.curChannelStrings,str1 or '',url,time)
                    else
                        ChatNewMgr:SendChatMsg(self.curChannelStrings,resultText,url,time)
                    end
                    ChatNewMgr:resetCdTime()
                end)
            else
                self.voiceMask:setVisible(false)
            end

        end)
    end
    self.stopRecordLogic = stopRecordLogic

    local function voiceBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if ChatNewMgr:judgeSpeakIsOutTime() then
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
            if ChatNewMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++ended')
            self.isTouch = false
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
            if self.allTime < SPEED_CLICK_TIME then   
                if YVSdkMgr.loginResult == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                end             
            elseif self.isSendRecord == false then
                --print('max record time 20 s ==================')
                stopRecordLogic()
            end

        elseif eventType == ccui.TouchEventType.canceled then
            if ChatNewMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++canceled')
            self.isTouch = false
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
            if self.allTime < SPEED_CLICK_TIME then       
                if YVSdkMgr.loginResult == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                end
            elseif self.isSendRecord == false then
                --print('max record time 20 s ==================')
                stopRecordLogic()
            end

        elseif eventType ==  ccui.TouchEventType.moved then
            if ChatNewMgr:judgeSpeakIsOutTime() then
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
    self.voiceNode = self.content:getChildByName('voice_node')
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

    self.root:scheduleUpdateWithPriorityLua(function (dt)
		self:updateTime(dt)
	end, 0)

    -- 世界聊天发言限制
    local chatSpeakLevelLimit = tonumber(GlobalApi:getGlobalValue('chatSpeakLevelLimit'))
    
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('CHAT_DESC_5'),chatSpeakLevelLimit), 26, COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('CHAT_DESC_6'), 26,COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(327,42))
    richText:format(true)
    self.rootBG:addChild(richText)

    self.chatSpeakLevelLimitRichText = richText
    self:switchVoiceState()
end

function ChatNewUI:refreshShoutItemNum()
    self.trumpetText:setString(GlobalApi:getLocalStr("CHAT_TRUMPET"))
    local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("shoutCostId")))
    if item == nil or item:getNum() == 0 then
        self.trumpetNum:setString("（0）")
        self.trumpetNum:setColor(COLOR_TYPE.RED)
    else
        self.trumpetNum:setString("（" .. item:getNum() .. "）")
        self.trumpetNum:setColor(COLOR_TYPE.WHITE)
    end
end

function ChatNewUI:refreshChatLimitCount()
    local hasUseWorldChatCount = UserData:getUserObj():getDayWorldChatCount()
    local lv = UserData:getUserObj():getLv()
    local worldChatCount = GameData:getConfData('level')[lv].worldChatCount
    if worldChatCount - hasUseWorldChatCount <= 0 then
        self.chatLimit:setString(string.format(GlobalApi:getLocalStr('CHAT_DESC_8'),0))
    else
        self.chatLimit:setString(string.format(GlobalApi:getLocalStr('CHAT_DESC_8'),worldChatCount - hasUseWorldChatCount))
    end
end

function ChatNewUI:updateTime(dt)
    if self.isTouch == true then
        self.allTime = self.allTime + dt
        if self.allTime > SPEED_CLICK_TIME then
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
            self:timeoutCallback(MAX_RECORD_TIME - REMAIN_RECORD_TIME,false)
        end
    end
end

function ChatNewUI:timeoutCallback(diffTime,isSendMsg)
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
            self:timeoutCallback(REMAIN_RECORD_TIME,true)
            self.huaTong:setVisible(false)
        else
            self.stopRecordLogic(true)
        end
	end,1)
end

function ChatNewUI:createEditBox(attachNode)
    local maxLen = 64
    self.editbox = cc.EditBox:create(attachNode:getContentSize(), 'uires/ui/friends/friends_input.png')
    self.editbox:setPosition(cc.p(attachNode:getContentSize().width/2,attachNode:getContentSize().height/2))
    self.editbox:setFont('font/gamefont.ttf',22)
    self.editbox:setFontColor(cc.c4b(100,45,16,255))
    self.editbox:setPlaceholderFontColor(cc.c4b(100,45,16,255))
    self.editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editbox:setMaxLength(maxLen*10)
    attachNode:addChild(self.editbox)
    self.editbox:setLocalZOrder(0)
    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    self.nameTx:setPosition(cc.p(0,attachNode:getContentSize().height/2))
    self.nameTx:setColor(cc.c4b(100,45,16,255))
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
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.editbox:setText('')
        end
    end)
end

function ChatNewUI:SendChatMessage()
    local sendString = self.nameTx:getString()
    if sendString == "" then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_39'), COLOR_TYPE.RED)
        return
    end

    if self.curChannelStrings == "world" then
        local hasUseWorldChatCount = UserData:getUserObj():getDayWorldChatCount()
        local lv = UserData:getUserObj():getLv()
        local worldChatCount = GameData:getConfData('level')[lv].worldChatCount
        if worldChatCount - hasUseWorldChatCount <= 0 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_7'), COLOR_TYPE.RED)
            return
        end
    end

    if ChatNewMgr:judgeSpeakIsOutTime() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_1'), COLOR_TYPE.RED)
        return
    end

    -- 判断是否和保存的聊天内容是一样的
    --[[
    local uid = UserData:getUserObj():getUid()
    local judge = false
    for i = 1,10 do
        local str = cc.UserDefault:getInstance():getStringForKey(uid .. 'chatcontent' .. i,'')
        if str and str ~= '' then
            local str1 = string.gsub(sendString, '%[', "<<line>>")
            local str2 = string.gsub(str, '%[', "<<line>>")

            local a = string.find(str1,str2)
            local b = string.find(str2,str1)
            if sendString == str or a or b then
                judge = true
                break
            end
        end
    end

    if ChatNewMgr:judgeSpeakLimitTime() == false then
        for i = 1,10 do
            cc.UserDefault:getInstance():setStringForKey(uid .. 'chatcontent' .. i,'')
        end
        ChatNewMgr:resetSpeakLimitCdTime()
        judge = false
    end

    if judge == true then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_4'), COLOR_TYPE.RED)
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
    --]]

    if self.curChannelStrings == "shout" or self.curChannelStrings == "countrywar_shout" then
         local item = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue("shoutCostId")))
         if item == nil or item:getNum() <= 0 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_TRUMPET_NE'), COLOR_TYPE.RED)
         else
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CHAT_TRUMPET_COST')), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                ChatNewMgr:resetCdTime()
                 ChatNewMgr:SendChatMsg(self.curChannelStrings,sendString)
                 self.nameTx:setString("")
                 self.inputText:setString("")
            end)
         end
    else
        ChatNewMgr:resetCdTime()
         ChatNewMgr:SendChatMsg(self.curChannelStrings,sendString)
         self.nameTx:setString("")
         self.inputText:setString("")
    end 
end

-- 切换语音和文字的状态
function ChatNewUI:switchVoiceState()
    self.voicePannel:setVisible(self.isVoice)
    self.inputzone:setVisible(not self.isVoice)
    if self.isVoice then    -- 语音状态
        self.swithBtn:loadTextureNormal("uires/ui/friends/friends_keyboard.png")
        self.chatLimit:setVisible(false)
    else
        self.swithBtn:loadTextureNormal("uires/ui/friends/friends_siri.png")
        self.chatLimit:setVisible(true)
    end

    if self.curChannelIndex ~= 1 then
        self.chatLimit:setVisible(false)
    end
end

-- 播放语音
function ChatNewUI:playRecord(widget,url)
    if YVSdkMgr.loginResult == false then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES7'), COLOR_TYPE.RED)
        return
    end

    if self.isPlaying then
        print('isPlaying=========================')
        YVSdkMgr:stopPlay()
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
        if not self then
            return
        end
        if not widget or (widget and not widget.playBtn) then
            return
        end

        self.isPlaying = false
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

function ChatNewUI:initLeftMenus()
    local bg = self.rootBG:getChildByName('bg')
    local tabs = bg:getChildByName('tabs')
    local tab = tabs:getChildByName('tab')
    tab:setVisible(false)

    local cellOffset = 19
    local cellHeight = tab:getContentSize().height
    local initPosY = tab:getPositionY()
    for i = 1,#self.chatChannelTypeIndexs do
        local tempTab = tab:clone()
        tempTab:setVisible(true)
        tempTab:setPositionY(initPosY - (i - 1)*(cellHeight + cellOffset))
        tabs:addChild(tempTab)
        table.insert(self.menuBtns,tempTab)

        local text = tempTab:getChildByName('text')
        local lock = tempTab:getChildByName('lock')
        local newImg = tempTab:getChildByName('new_img')
        local index = self.chatChannelTypeIndexs[i]
        text:setString(GlobalApi:getLocalStr("CHAT_CHANNEL"..index))

        tempTab.text = text
        tempTab.lock = lock
        tempTab.newImg = newImg
        tempTab.index = index

        tempTab:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if index == self.curChannelIndex then
                    return
                end
                self:changeChannel(index)
            end
        end)
    end
    self:refreshMenus()
end

function ChatNewUI:changeChannel(index)
    if self:judgeIsOpen(index) == false then
        if index == 2 then
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CHAT_NOGROUP')), MESSAGE_BOX_TYPE.MB_OK_CANCEL)
        end
        return
    end
    if index == 2 then
        ChatNewMgr.isChatShow = false
    end

    self.isVoice = false
    self.curChannelIndex = index
    self.curChannelStrings = CHAT_CHANNEL_TYPE[self.curChannelIndex]
    self:refreshMenus()
    self:refreshScrollView()
    self:updateBottom(index)
end

function ChatNewUI:updateBottom(index)
    self.voicePannel:setVisible(false)
    self.shoutPanel:setVisible(false)
    self.chatSpeakLevelLimitRichText:setVisible(false)

    self.textClip:setPositionY(5.86)

    if index == 1 then
        self.textClip:setPositionY(-4.14)

        self.inputzone:setVisible(true)
        self.swithBtn:setVisible(true)
        self.legionBtn:setVisible(self:judgeisLegionLeader())

        local chatSpeakLevelLimit = tonumber(GlobalApi:getGlobalValue('chatSpeakLevelLimit'))
        local lv = UserData:getUserObj():getLv()
        if lv < chatSpeakLevelLimit then
            self.chatSpeakLevelLimitRichText:setVisible(true)
            self.voicePannel:setVisible(false)
            self.shoutPanel:setVisible(false)
            self.inputzone:setVisible(false)
            self.legionBtn:setVisible(false)
            self.swithBtn:setVisible(false)
        end

    elseif index == 2 or index == 5 then
        self.inputzone:setVisible(true)
        self.swithBtn:setVisible(true)
        self.legionBtn:setVisible(false)
    elseif index == 3 then
        self.inputzone:setVisible(false)
        self.swithBtn:setVisible(false)
        self.legionBtn:setVisible(false)
    elseif index == 4 then
        self.inputzone:setVisible(true)
        self.swithBtn:setVisible(false)
        self.legionBtn:setVisible(self:judgeisLegionLeader())
        self.shoutPanel:setVisible(true)
        self:refreshShoutItemNum()
    elseif index == 5 then
        self.inputzone:setVisible(true)
        self.swithBtn:setVisible(true)
        self.legionBtn:setVisible(false)
    elseif index == 6 then
        self.inputzone:setVisible(true)
        self.swithBtn:setVisible(false)
        self.legionBtn:setVisible(false)
        self.shoutPanel:setVisible(true)
        self:refreshShoutItemNum()
    end

    if index == 1 then
        self.chatLimit:setVisible(true)
    else
        self.chatLimit:setVisible(false)
    end

end

-- 判断是否是军团长或者副军团长
function ChatNewUI:judgeisLegionLeader()
    if UserData:getUserObj():getLid() > 0 and UserData:getUserObj():getLegionInfo() then
        local pos = UserData:getUserObj():getLduty()
        if pos == 1 or pos == 2 then
            return true
        else
            return false
        end
    end
    return false
end

function ChatNewUI:refreshMenus()
    for i = 1,#self.menuBtns do
        local btn = self.menuBtns[i]
        if btn.index == self.curChannelIndex then
            btn:loadTextureNormal(CHOOSE_BTN_PRESS)
            btn.text:setColor(COLOR_TYPE.WHITE)
        else
            btn.text:setColor(cc.c4b(107,20,133,255))
            btn:loadTextureNormal(CHOOSE_BTN_NORMAL)
        end
        btn.lock:setVisible(not self:judgeIsOpen(btn.index))
        btn.newImg:setVisible(self:getNewImgsStatus(btn.index))
    end
end

function ChatNewUI:judgeIsOpen(type)
    if type == 2 then
        if UserData:getUserObj():getLid() > 0 then
            return true
        else
            return false
        end
    elseif type == 5 then
        return true
    else
        return true
    end
end

function ChatNewUI:getNewImgsStatus(type)
    if type == 2 then
        return ChatNewMgr.isChatShow
    elseif type == 5 then
        return false
    else
        return false
    end
end

function ChatNewUI:onHide()
    -- 语音相关处理
    -- YVSdkMgr:stopPlay()
    -- YVSdkMgr.YVSdkCallBackList.recordVoiceCallBack = nil
end

------------------------------------------------------- 滚动层相关 -------------------------------------------------------
function ChatNewUI:refreshScrollView()
    if self.svBg:getChildByName('scrollview_sv') then
        self.svBg:removeChildByName('scrollview_sv')
        self.chatsv = nil
    end
    self.scrollViewGeneral = nil

    local scrollView = ccui.ScrollView:create()
    scrollView:setName('scrollview_sv')
	scrollView:setTouchEnabled(true)
	scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(self.chatsvTemp:getPosition())
    scrollView:setContentSize(self.chatsvTemp:getContentSize())
    self.svBg:addChild(scrollView)
	self.chatsv = scrollView

    self.chatDatas = {}
    if self.curChannelIndex == 1 then
        self.chatDatas = ChatNewMgr.worldChannelDatas
    elseif self.curChannelIndex == 2 then
        self.chatDatas = ChatNewMgr.legionChannelDatas
    elseif self.curChannelIndex == 3 then
        self.chatDatas = ChatNewMgr.systemChannelDatas
    elseif self.curChannelIndex == 4 then
        self.chatDatas = ChatNewMgr.shoutChannelDatas
    elseif self.curChannelIndex == 5 then
        self.chatDatas = ChatNewMgr.countryWarChannelDatas
    elseif self.curChannelIndex == 6 then
        self.chatDatas = ChatNewMgr.countryWarShoutChannelDatas
    end

	if self.chatDatas and #self.chatDatas > 0 then
        self.viewSize = self.chatsv:getContentSize() -- 可视区域的大小
		self:initListView()
	end
end

function ChatNewUI:initListView()
    self.cellSpace = CELL_SPACE
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.chatDatas
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace

    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    local function updateCallback(tempCellData,widgetItem)
        self:updateItem(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.chatsv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil,0,updateCallback)
    else
        self.scrollViewGeneral:resetScrollView(self.chatsv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil,0,updateCallback)
    end
end

function ChatNewUI:initItemData(index)
    if self.chatDatas[index] then
        local w,h = self:getItemWH(index)

        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function ChatNewUI:getItemWH(index)
    local chatData = self.chatDatas[index]

    local w = CELL_WIDTH
    local h = CELL_HEIGHT

    local content = chatData.content
    if chatData.act == 'system' then
        local str,htmlstr = ChatNewMgr:getDesc(chatData.sub_type,chatData.str_array)
        content = str
    end

    if chatData.info and chatData.info.roomId then    -- 玉璧加入
        local str,color = ChatNewMgr:getJadeDesc(chatData.info.jade)
        content = str
    end

    if chatData["type"] == "legion" and chatData.info ~= nil then
        content = GlobalApi:getLocalStr("CHAT_GIFT")
    end

    self.chatTx:setString(content)
    local width = self.chatTx:getContentSize().width    -- 文本的宽度
    local textHeight = TEXT_BG_HEIGHT
    if width > MAX_TEXT_WIDTH then
        width = MAX_TEXT_WIDTH
        self.heightComp:setString(content)
        textHeight = self.heightComp:getContentSize().height + LIMIT_TEXT_BG_UD_SPACE * 2
    end
    
    -- 判断是否是语音
    if chatData.act ~= 'system' and ChatNewMgr.judgeIsVoice(chatData) and content ~= "" then
        textHeight = textHeight + YUYIN_HEIGHT
    end

    if textHeight > TEXT_BG_HEIGHT then
        h = h + (textHeight - TEXT_BG_HEIGHT)
    end

    self.chatDatas[index].textBgHeight = textHeight

    width = width + 2*LIMIT_TEXT_BG_LR_SPACE + LIMIT_TEXT_BG_ARROW_WIDTH
    if width > TEXT_BG_WIDTH then    -- 设置聊天内容背景宽度
        self.chatDatas[index].textBgWidth = width
    else
        self.chatDatas[index].textBgWidth = TEXT_BG_WIDTH
    end

    if chatData.act ~= 'system' and ChatNewMgr.judgeIsVoice(chatData) then
        if content ~= "" then
            self.chatDatas[index].textBgWidth = MAX_TEXT_WIDTH + 2*LIMIT_TEXT_BG_LR_SPACE + LIMIT_TEXT_BG_ARROW_WIDTH
        else
            self.chatDatas[index].textBgWidth = YUYIN_NOT_TEXT_WIDTH
        end
    end

    self.chatDatas[index].cellHeight = h
    self.chatDatas[index].offsetHeight = textHeight - TEXT_BG_HEIGHT
    
    return w,h
end

function ChatNewUI:addItem(tempCellData,widgetItem)
    if self.chatDatas[tempCellData.index] then
        local chatData = self.chatDatas[tempCellData.index]
        local index = tempCellData.index

        local cell = nil
        local judge = false
        if chatData.user and chatData.user.uid and tonumber(chatData.user.uid) == tonumber(UserData:getUserObj():getUid()) then
            cell = self.chatMyCell:clone()
            self:updateCell(cell,index,true)
            judge = true
        else
            cell = self.chatOtherCell:clone()
            self:updateCell(cell,index,false)
        end
        cell:setVisible(true)
        cell:setName('widgetitem_cell')

        local w = tempCellData.w
        local h = tempCellData.h

        -- 屏蔽仙盟红包
        -- if self.chatDatas[index].type ~= "legion" then
            widgetItem:addChild(cell)
        -- end
        if judge then
            cell:setPosition(cc.p(cc.p(16,0)))
        else
            cell:setPosition(cc.p(cc.p(5,0)))
        end
    end
end

function ChatNewUI:updateItem(tempCellData,widgetItem)
    if self.chatDatas[tempCellData.index] then
        local chatData = self.chatDatas[tempCellData.index]
        local index = tempCellData.index
        local cell = widgetItem:getChildByName('widgetitem_cell')
        if not cell then
            return
        end
        if chatData.user and chatData.user.uid and tonumber(chatData.user.uid) == tonumber(UserData:getUserObj():getUid()) then
            self:updateCell(cell,index,true,true)
        else
            self:updateCell(cell,index,false,true)
        end
    end
end

function ChatNewUI:updateCell(cell,index,isMyOwn,update)
    local chatData = self.chatDatas[index]
    local cellHeight = chatData.cellHeight
    local textBgHeight = chatData.textBgHeight
    local textBgWidth = chatData.textBgWidth
    local offsetHeight = chatData.offsetHeight
    if update then
        offsetHeight = 0
    end
    cell:setContentSize(cc.size(cell:getContentSize().width,cellHeight))

    local head = cell:getChildByName('head')
    head:setPositionY(head:getPositionY() + offsetHeight)
    local awardBgImg = head:getChildByName('award_bg_img')
    if not awardBgImg then
        local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
        awardBgImg = iconCell.awardBgImg
        awardBgImg:setScale(0.7)
        awardBgImg:setAnchorPoint(cc.p(0,1))
        awardBgImg:setPosition(cc.p(1,1))
        head:addChild(iconCell.awardBgImg)
    end
    local headframeImg = awardBgImg:getChildByName('headframeImg')
    local icon = awardBgImg:getChildByName('award_img')
    local lvTx = awardBgImg:getChildByName('lv_tx')
    local name = cell:getChildByName('name')
    name:setPositionY(name:getPositionY() + offsetHeight)
    local imgV = cell:getChildByName('img_v')
    imgV:setPositionY(imgV:getPositionY() + offsetHeight)
    local lord = cell:getChildByName('img_lord')
    local getBtn = cell:getChildByName('get_btn')
    local joinBtn = cell:getChildByName('join_btn')
    local applyBtn = cell:getChildByName('apply_btn')
    local serverId = cell:getChildByName('server_id')
    serverId:setPositionY(serverId:getPositionY() + offsetHeight)

    if isMyOwn == false then 
        getBtn:setPositionY(getBtn:getPositionY() + offsetHeight)
        joinBtn:setPositionY(joinBtn:getPositionY() + offsetHeight)
        applyBtn:setPositionY(applyBtn:getPositionY() + offsetHeight)
    end
    local yuyinNode = cell:getChildByName('yuyin_node')
    local systemTx = cell:getChildByName('system_tx')

    local content = chatData.content
    if chatData.act == 'system' then  -- 系统消息
        
        local str,htmlstr = ChatNewMgr:getDesc(chatData.sub_type,chatData.str_array)
        content = str

        name:setString(GlobalApi:getLocalStr('CHAT_DESC_3'))
        name:setPositionX(92)
        icon:loadTexture("uires/icon/hero/xiaoqiao_icon.png")
        awardBgImg:loadTexture(COLOR_FRAME[1])
        lvTx:setVisible(false)
        imgV:setVisible(false)
        lord:setVisible(false)
        yuyinNode:setVisible(false)
        headframeImg:setVisible(false)
        serverId:setVisible(false)
        if isMyOwn == false then
            getBtn:setVisible(false)
            joinBtn:setVisible(false)
            applyBtn:setVisible(false)
        end
    else
        headframeImg:loadTexture(GlobalApi:getHeadFrame(chatData.user.headframe))
        headframeImg:setVisible(true)
        awardBgImg:loadTexture(COLOR_FRAME[chatData.quality or 3])
        local settingHeadIconData = GameData:getConfData('settingheadicon')
        icon:loadTexture(settingHeadIconData[chatData.user.headpic].icon)
        icon:setTouchEnabled(true)
        icon:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if chatData.user and chatData.user.uid and tonumber(chatData.user.uid) ~= tonumber(UserData:getUserObj():getUid()) then
                    ChatNewMgr:hideChat()
                    BattleMgr:showCheckInfo(chatData.user.uid,'world','arena')
                end
            end
        end)

        lvTx:setString(chatData.user.level)
        name:setString(chatData.user.un)

        -- 先判断玩家是否有霸主的称号，然后设置玩家名字的位置
        local lordJudge = false
        if chatData.title then
            local charLordConf = GameData:getConfData('chatlord')
            local confData = charLordConf[chatData.title]
            if confData then
                lord:setVisible(true)
                lord:loadTexture(confData.icon)
                lordJudge = true
            else
                lord:setVisible(false)
            end
        else
            lord:setVisible(false)
        end

        if chatData.user.serverId then
            serverId:setString(string.format(GlobalApi:getLocalStr('CHAT_DESC_9'),chatData.user.serverId))
            if chatData.user.camp and self.curChannelStrings == 'countrywar_shout' then
                name:setColor(CAMP_COLOR[chatData.user.camp])
                serverId:enableOutline(cc.c4b(0, 0, 0, 255),1)
	            serverId:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            end
        end

        if lordJudge == true then
            lord:setPositionY(lord:getPositionY() + offsetHeight)
            serverId:setPositionX(190)
        else
            serverId:setPositionX(92)
        end
        name:setPositionX(serverId:getPositionX() + serverId:getContentSize().width)

        if cell:getChildByName('vipLabel') then
            cell:removeChildByName('vipLabel')
        end

        local vip = chatData.user.vip
        local vipLabel
        if vip > 0 then
            vipLabel = cc.LabelAtlas:_create(vip, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
            vipLabel:setName('vipLabel')
	        vipLabel:setAnchorPoint(cc.p(0, 0.5))
	        cell:addChild(vipLabel)
            imgV:setPositionX(name:getPositionX() + name:getContentSize().width)
            vipLabel:setPosition(cc.p(imgV:getPositionX() + imgV:getContentSize().width,imgV:getPositionY()))
        else
            imgV:setVisible(false)
        end

        if isMyOwn == true then     -- 自己
            if vipLabel then
                vipLabel:setAnchorPoint(cc.p(1, 0.5))
                vipLabel:setPositionX(391)
                imgV:setPositionX(vipLabel:getPositionX() - vipLabel:getContentSize().width)
                name:setPositionX(imgV:getPositionX() - imgV:getContentSize().width)
            else
                name:setPositionX(391)
            end
            serverId:setPositionX(name:getPositionX() - name:getContentSize().width)
            lord:setPositionX(serverId:getPositionX() - serverId:getContentSize().width)
        end

        -- 语音
        cell.playBtn = yuyinNode:getChildByName('play_btn')
        cell.isReadImg = yuyinNode:getChildByName('is_read')
        cell.seconds = yuyinNode:getChildByName('seconds')
        cell.yuyin1 = yuyinNode:getChildByName('yuyin1')
        cell.yuyin2 = yuyinNode:getChildByName('yuyin2')
        cell.yuyin3 = yuyinNode:getChildByName('yuyin3')
        if ChatNewMgr.judgeIsVoice(chatData) then
            yuyinNode:setVisible(true)
            yuyinNode:setPositionY(yuyinNode:getPositionY() + offsetHeight)
            cell.seconds:setString(chatData.voice_time .. '"')
        else
            yuyinNode:setVisible(false)
        end
        cell.isReadImg:setVisible(false)

        local function playCallBack(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                self:playRecord(cell,chatData.voice_url)
            end
        end
        cell.playBtn:addTouchEventListener(playCallBack)

        if ChatNewMgr.judgeIsVoice(chatData) then
            cell:getChildByName('text_bg'):setTouchEnabled(true)
            cell:getChildByName('text_bg'):addTouchEventListener(playCallBack)
        else
            cell:getChildByName('text_bg'):setTouchEnabled(false)
        end

        --
        if isMyOwn == false then
            ------------------------------------------------------------------------------------------------------
            -- 军团申请按钮
            applyBtn:setVisible(true)
            local legionState = 0
            local judge = false
            local type = 1
            if chatData.sub_type and chatData.sub_type == 'legion_invite' then
                judge = true
                type = chatData.info.type
            end
            local isApply = chatData.isApply or 1
            if judge == false then
                legionState = 0
                applyBtn:setVisible(false)
            elseif UserData:getUserObj():getLid() > 0 then              -- 已经在军团
                legionState = 1
                applyBtn:loadTextureNormal(LEGION_YISHENGQING_BTN)
            elseif type == 1 then                                       
                if isApply == 0 then                     -- 撤销
                    legionState = 4
                    applyBtn:loadTextureNormal(LEGION_CHEXIAO_BTN)
                else
                    legionState = 2                                     -- 申请
                    applyBtn:loadTextureNormal(LEGION_SHENGQING_BTN)
                end
            elseif type == 0 then                                       -- 加入
                legionState = 3
                applyBtn:loadTextureNormal(LEGION_JIARU_BTN)
            else
                legionState = 0
                applyBtn:setVisible(false)
            end

            applyBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if legionState == 1 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_SUC5'), COLOR_TYPE.GREEN)
                    elseif legionState == 2 or legionState == 3 then
                        local leave_time = UserData:getUserObj():getLegionInfo().leave_time
                        local legionglobalconf = GameData:getConfData('legion')
                        if GlobalData:getServerTime() - legionglobalconf['joinTimeLimit'].value < leave_time then
                            local str = string.format(GlobalApi:getLocalStr('LEGION_APPLY_TIME_NEED'),math.ceil((leave_time + legionglobalconf['joinTimeLimit'].value-GlobalData:getServerTime())/3600))
                            promptmgr:showSystenHint(str, COLOR_TYPE.RED)
                            return                    
                        end

                        if UserData:getUserObj():getLv() < chatData.info.level_limit then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'), COLOR_TYPE.RED)
                            return
                        end

                        local obj = {
                            lid = chatData.info.lid
                        }
                        MessageMgr:sendPost('join','legion',json.encode(obj),function (response)
                            local code = response.code
                            local data = response.data
                            -- 所有的申请变成撤销
                            local function callBcack()
                                for i = 1,#self.chatDatas do
                                    local chatDataData = self.chatDatas[i]
                                    if chatDataData.sub_type and chatDataData.sub_type == 'legion_invite' and chatData.info.lid == chatDataData.info.lid then
                                        chatDataData.isApply = 0
                                        chatDataData.info.type = 1
                                    end
                                end
                            end
                            if code == 0 then
                                if data.legion then -- 立即加入
                                    local firstJoin = cc.UserDefault:getInstance():getBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',false)
                                    if not firstJoin then
                                        cc.UserDefault:getInstance():setBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',true)
                                    end
							        UserData:getUserObj():setLegion(data.legion.lid, data.legion.name, data.legion.level,data.legion.gold_tree,data.legion.lduty,data.legion.ltype)
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_DESC13'), COLOR_TYPE.GREEN)
                                else    -- 申请
                                    callBcack()
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_SUC'), COLOR_TYPE.GREEN)         
                                end
                                self.scrollViewGeneral:updateItems()
                            elseif code == 102 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_102'), COLOR_TYPE.RED)
                            elseif code == 104 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_104'), COLOR_TYPE.RED)
                            elseif code == 105 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_105'), COLOR_TYPE.RED)
                            elseif code == 117 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_117'), COLOR_TYPE.RED)
                            elseif code == 112 then
                                callBcack()
                                self.scrollViewGeneral:updateItems()
                            end
                        end)
                    
                    elseif legionState == 4 then
                        local obj = {
                            lid = chatData.info.lid
                        }
                        MessageMgr:sendPost('revoke_request','legion',json.encode(obj),function (response)
                            local code = response.code
                            local data = response.data
                            if code == 0 then
                                -- 所有的撤销变成申请
                                for i = 1,#self.chatDatas do
                                    local chatDataData = self.chatDatas[i]
                                    if chatDataData.sub_type and chatDataData.sub_type == 'legion_invite' and chatData.info.lid == chatDataData.info.lid then
                                        chatDataData.isApply = 1
                                    end
                                end
                                self.scrollViewGeneral:updateItems()
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_REVOKE_SUC'), COLOR_TYPE.GREEN)
                            elseif code == 102 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_102'), COLOR_TYPE.RED)
                            elseif code == 117 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_117'), COLOR_TYPE.RED)
                            elseif code == 104 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_104'), COLOR_TYPE.RED)        
                            end
                        end)
                        
                    end
                end
            end)

            if chatData.info == nil then
                getBtn:setVisible(false)
                joinBtn:setVisible(false)
            else
                if chatData.info.roomId then    -- 合璧
                    getBtn:setVisible(false)
                    local pos = 1
                    local subType = GameData:getConfData('countryjade')[tonumber(chatData.info.jade)].subType
                    if subType == 1 then
                        pos = 2
                    else
                        pos = 1
                    end
                    joinBtn:addTouchEventListener(function (sender, eventType)
                        if eventType == ccui.TouchEventType.began then
                            AudioMgr.PlayAudio(11)
                        elseif eventType == ccui.TouchEventType.ended then
                            local function callBack(msg)
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES44'), COLOR_TYPE.GREEN)
                            end
                            CountryJadeMgr:joinRoomFromServer(chatData.info.roomId,pos,callBack)   -- i是位置
                        end
                    end)
                else
                    joinBtn:setVisible(false)
                    if(chatData.info.used and chatData.info.used ~= 0) then     --  已经使用
                        getBtn:setTouchEnabled(false)
                        getBtn:loadTextureNormal("uires/ui/chat/chat_yilingqu.png")
                    else
                        getBtn:setTouchEnabled(true)
                        getBtn:loadTextureNormal("uires/ui/chat/chat_lingqu.png")
                        getBtn:addTouchEventListener(function (sender, eventType)
                            if eventType == ccui.TouchEventType.began then
                                AudioMgr.PlayAudio(11)
                            elseif eventType == ccui.TouchEventType.ended then
                                if(tonumber(UserData:getUserObj():getLegionInfo().grab_boon) < tonumber(GlobalApi:getGlobalValue("grabBoonPerDay"))) then
                                    local function callBack()
                                        chatData.info.used = true
                                        getBtn:setTouchEnabled(false)
                                        getBtn:loadTextureNormal("uires/ui/chat/chat_yilingqu.png")
                                    end
                                    ChatNewMgr:SendOpenGiftMsg(chatData.info.boon.id,callBack)
                                else
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr("CHAT_GRAB_MAXNUMBER"), COLOR_TYPE.RED)
                                end
                            end
                        end)
                    end

                end
            end
            ------------------------------------------------------------------------------------------------------
        end

    end

    -- 文本
    local textBg = cell:getChildByName('text_bg')
    textBg:setContentSize(textBgWidth,textBgHeight)

    if textBg:getChildByName('chatText') then
        textBg:removeChildByName('chatText')
    end

    local chatText = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
    chatText:setName('chatText')
	chatText:setAnchorPoint(cc.p(0, 1))
	chatText:setMaxLineWidth(MAX_TEXT_WIDTH)
	chatText:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	chatText:setColor(cc.c4b(255,255,255,255))
    if chatData.act ~= 'system' and chatData.info and chatData.info.roomId then    -- 玉璧加入
        local str,color = ChatNewMgr:getJadeDesc(chatData.info.jade)
        content = str
        chatText:setColor(color)
    end
    if chatData["type"] == "legion" and chatData.info ~= nil then
        content = GlobalApi:getLocalStr("CHAT_GIFT")
    end
    chatText:setString(content)
    textBg:addChild(chatText)
    chatText:setPosition(cc.p(LIMIT_TEXT_BG_LR_SPACE + LIMIT_TEXT_BG_ARROW_WIDTH,textBgHeight - LIMIT_TEXT_BG_UD_SPACE))
    if chatData.act ~= 'system' and ChatNewMgr.judgeIsVoice(chatData) and content ~= "" then
        chatText:setPosition(cc.p(LIMIT_TEXT_BG_LR_SPACE,textBgHeight - LIMIT_TEXT_BG_UD_SPACE - YUYIN_IMG_HEIGHT))
    end
end
------------------------------------------------------- 滚动层相关 -------------------------------------------------------

function ChatNewUI:showNewMessage(msg)
    if not self.scrollViewGeneral then
        self:refreshScrollView()
    else
        local index = #self.chatDatas
        local w,h = self:getItemWH(index)
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w
        self.scrollViewGeneral:insertCell(self.scrollViewGeneral.INSERT_TYPE[3],tempCellData)
    end
    self:refreshChatLimitCount()
end

return ChatNewUI