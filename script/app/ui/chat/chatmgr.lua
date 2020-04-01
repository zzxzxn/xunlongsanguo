local ClassChatUI = require("script/app/ui/chat/chatui")

cc.exports.ChatMgr = {
    uiClass = {
        chatUI = nil,
    },
    isOpen = false,
    normalChannelDatas = {},
    groupChannelDatas = {},
    trumpetChannelDatas = {},
    countryChannelDatas = {},
    systemChannelDatas = {},
    numOfCachePerChannel = 100,
    isChatShow = false,
    speakTime = 0,
    speakLimitTime = 0,   -- 聊天刷屏时间限制
}

setmetatable(ChatMgr.uiClass, {__mode = "v"})

function ChatMgr:resetCdTime(time)
    self.speakTime = time or GlobalData:getServerTime()
end

function ChatMgr:judgeSpeakIsOutTime()
    local nowTime = GlobalData:getServerTime()
    if nowTime - self.speakTime <= 10 then
        return true
    else
        return false
    end
end

function ChatMgr:resetSpeakLimitCdTime(time)
    self.speakLimitTime = time or GlobalData:getServerTime()
end

function ChatMgr:judgeSpeakLimitTime()
    local nowTime = GlobalData:getServerTime()
    if self.speakLimitTime == 0 then
        self:resetSpeakLimitCdTime()
        return true
    end
    if nowTime - self.speakLimitTime <= 120 then
        return true
    else
        return false
    end
end

function ChatMgr:showChat()
    local chatLevelLimit = tonumber(GlobalApi:getGlobalValue('chatLevelLimit'))
    local lv = UserData:getUserObj():getLv()
    if lv < chatLevelLimit then
        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('CHAT_DESC_2'),chatLevelLimit), COLOR_TYPE.RED)
        return
    end
    
	if self.uiClass.chatUI == nil then
        --self:addSystemMsg()
        self.uiClass.chatUI = ClassChatUI.new()
	    self.uiClass.chatUI:showUI()
        self.isOpen = true
	end
end

function ChatMgr:hideChat()
    -- 语音相关处理
    YVSdkMgr:stopPlay()
    YVSdkMgr.YVSdkCallBackList.recordVoiceCallBack = nil

    for i = #self.groupChannelDatas,1,-1 do
        local data = self.groupChannelDatas[i]
        if data.info and data.info.used and data.info.used ~= 0 then    -- 清除已经领取的红包
            table.remove(self.groupChannelDatas,i)
        end
    end
    
	if self.uiClass.chatUI then
        self.uiClass.chatUI:ActionClose()
		self.uiClass.chatUI = nil
        self.isOpen = false
        self:removeSystemMsg()

        self.isChatShow = false

	end
end
-----------------message--------------------------------------------------------------------------
function ChatMgr:GetLog()
    local function socketOpenCall()
        CustomEventMgr:removeEventListener("user_handshake",self)
        CustomEventMgr:addEventListener("chat_get_chat_log",self,ChatMgr.ProcessChatLogMsg)
        CustomEventMgr:addEventListener("chat_chat",        self,ChatMgr.ProcessChatMsg)
        CustomEventMgr:addEventListener("chat_system",        self,ChatMgr.ProcessChatMsg)
        SocketMgr:send("get_chat_log","chat",{})
    end
   
   CustomEventMgr:addEventListener("user_handshake", ChatMgr, socketOpenCall)

end
function ChatMgr:addSystemMsg()
    local msg = {}
    msg["type"] = "world"
    msg.isSystem = true
    msg.content = GlobalApi:getLocalStr("CHAT_SYSTEM_WARRING")
    ChatMgr.ProcessChatMsg(msg)

end
function ChatMgr:removeSystemMsg()
    for i = #self.normalChannelDatas,1,-1 do
        if(self.normalChannelDatas[i].isSystem) then
            table.remove(self.normalChannelDatas,i)
            return
        end
    end
    
end
function ChatMgr:SendChatMsg(channelString,chatContent,voice_url,voice_time)
    
    
    local msg = {}
    msg["type"] = channelString
    msg["content"] = chatContent
    if voice_url then
        msg["voice_url"] = voice_url
    end
    if voice_time then
        msg["voice_time"] = voice_time
    end

    if(channelString == "shout") then
        MessageMgr:sendPost('shout','user',json.encode(msg),function(jsonObj)
            if jsonObj.code == 101 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES8'), COLOR_TYPE.RED)
                return
            end
             GlobalApi:parseAwardData(jsonObj.data.costs)
              if(ChatMgr.uiClass.chatUI ~= nil) then
                  ChatMgr.uiClass.chatUI:refreshShoutItemNum()
              end
        end)
    else
        SocketMgr:send("chat","chat",msg)
    end

end
function ChatMgr:SendOpenGiftMsg(boonId)
    local msg = {}
    msg.id = boonId
    MessageMgr:sendPost('grab_boon','legion',json.encode(msg),function(jsonObj)
        if(jsonObj.code ~= 0) then
        if(jsonObj.code == 116) then
            ChatMgr.uiClass.chatUI:refreshGiftItem(boonId)
            promptmgr:showMessageBox(GlobalApi:getLocalStr('CHAT_GRAB_OVER'), MESSAGE_BOX_TYPE.MB_OK)
        end
        return
        end
        local awards = jsonObj.data.awards
        GlobalApi:parseAwardData(awards)
        GlobalApi:showAwardsCommon(awards,true,nil,false)

        UserData:getUserObj():getLegionInfo().grab_boon = UserData:getUserObj():getLegionInfo().grab_boon + jsonObj.data.count
        if(ChatMgr.uiClass.chatUI ~= nil) then
            ChatMgr.uiClass.chatUI:refreshGiftItem(boonId)
        end
    end)
end
function ChatMgr.ProcessChatLogMsg(msg)
    print("RecvChatLogMsg")
    ChatMgr.normalChannelDatas = ChatMgr:sortDatas(msg.chat_log.world)
    ChatMgr.groupChannelDatas = ChatMgr:sortDatas(msg.chat_log.legion,true)
    ChatMgr.trumpetChannelDatas = ChatMgr:sortDatas(msg.chat_log.shout)
    ChatMgr.countryChannelDatas = ChatMgr:sortDatas(msg.chat_log.country)
end
function ChatMgr:sortDatas(datas,isLegion)
    local newDatas = {}
    for i = 1,#datas do
        local data = datas[i]
        local judge = true
        if (data["type"] == "country") and data.info.roomId then
           if (not data.user.uid) or (data.user.uid and data.user.uid == UserData:getUserObj():getUid()) then
                judge = false   -- 玉璧喊话如果是自己，则不显示
           end
        end
        if judge == true then
            table.insert(newDatas,datas[i])
        end
    end

    local ret = {}
    local count = 1
    local legionCount = 0
    for i = #newDatas,1,-1 do
        local data = newDatas[i]
        if(data.info ~= nil) then
         print(data.info.self_use)
        end

        -- 语音处理
        if ChatMgr.judgeIsVoice(data) and data.user.uid and (data.user.uid == UserData:getUserObj():getUid()) then
            data.user.isRead = true  -- true已经读取，其它情况未读
        end

        if(not isLegion or data.info == nil or data.info.self_use == 1 or data.user.uid ~= GlobalData:getSelectUid()) then
            if isLegion and data.info and data.info.used and data.info.used ~= 0 then     -- 军团红包如果已经失效则不显示

            else
                data.index = count
                table.insert(ret,data)
            end         
        end
        
        if isLegion == true then       
            if data.user.uid == GlobalData:getSelectUid() then
                ChatMgr.isChatShow = false
            else
                if(tonumber(UserData:getUserObj():getLegionInfo().grab_boon) < tonumber(GlobalApi:getGlobalValue("grabBoonPerDay"))) and data.info and data.info.used == 0 then
                    legionCount = legionCount + 1
                end

            end
        end

    end

    if isLegion == true then
        if legionCount > 0 then
            ChatMgr.isChatShow = true
            if UIManager and UIManager.sidebar then   
                UIManager.sidebar:updateChatShowStatus()
            end

        end

    end


    return ret
end
function ChatMgr.ProcessChatMsg(msg)
    local channelData = nil
    if msg.act == 'system' then   -- 系统消息
        channelData = ChatMgr.countryChannelDatas   -- 暂时把这个加到这个字段里面
        UIManager:getSidebar():setChatMsg(msg)

        if(#channelData >= ChatMgr.numOfCachePerChannel) then
            local data = table.remove(channelData,1)
            if(ChatMgr.uiClass.chatUI ~= nil and ChatMgr.uiClass.chatUI.currentChannel == 'system') then
                ChatMgr.uiClass.chatUI:removeBottomCell(data)
            end
        end

        msg.index = #channelData
        table.insert(channelData,msg)

        if(ChatMgr.uiClass.chatUI ~= nil and ChatMgr.uiClass.chatUI.currentChannel == 'system') then
            ChatMgr.uiClass.chatUI:ShowNewMessage(msg)
        end

        if UIManager and UIManager.sidebar then   
            UIManager.sidebar:updateChatShowStatus()
        end
    else
        ChatMgr.handleVocieData(msg)
        if (msg["type"] == "country") and msg.info.roomId then
           if (not msg.user.uid) or (msg.user.uid and msg.user.uid == UserData:getUserObj():getUid()) then
                return
           end
        end
        print("RecvChatMsg")
        print('==================',msg["type"])
        if(msg["type"] == "world") then
            channelData = ChatMgr.normalChannelDatas
            UIManager:getSidebar():setLittleChatMsg(msg)
        elseif(msg["type"] == "country") then
            channelData = ChatMgr.countryChannelDatas
        elseif(msg["type"] == "legion") then
            if(msg.info ~= nil and msg.info.self_use == 0 and msg.user.uid == GlobalData:getSelectUid()) then
                return
            end

            ChatMgr.isChatShow = false

            -- 自己不能抢
            if msg.user.uid == GlobalData:getSelectUid() then
                ChatMgr.isChatShow = false
            else
                if(tonumber(UserData:getUserObj():getLegionInfo().grab_boon) < tonumber(GlobalApi:getGlobalValue("grabBoonPerDay"))) and msg.info and msg.info.used == 0 then
                    ChatMgr.isChatShow = true
                end

            end
            channelData = ChatMgr.groupChannelDatas
            UIManager:getSidebar():setLittleChatMsg(msg)
        elseif (msg["type"] == "shout") then
            channelData = ChatMgr.trumpetChannelDatas
            UIManager:getSidebar():setChatMsg(msg)
        else
            channelData = ChatMgr.trumpetChannelDatas
        end

        if(#channelData >= ChatMgr.numOfCachePerChannel) then
            local data = table.remove(channelData,1)
            if(ChatMgr.uiClass.chatUI ~= nil and ChatMgr.uiClass.chatUI.currentChannel == msg["type"]) then
                ChatMgr.uiClass.chatUI:removeBottomCell(data)
            end
        end

        msg.index = #channelData
        table.insert(channelData,msg)

        if(ChatMgr.uiClass.chatUI ~= nil and ChatMgr.uiClass.chatUI.currentChannel == msg["type"]) then
            ChatMgr.uiClass.chatUI:ShowNewMessage(msg)
        end

        if UIManager and UIManager.sidebar then   
            UIManager.sidebar:updateChatShowStatus()
        end
    end
end

-- 处理语音数据
function ChatMgr.handleVocieData(msg)
    if not ChatMgr.judgeIsVoice(msg) then
        return
    end
    if msg.user.uid and (msg.user.uid == UserData:getUserObj():getUid()) then
        msg.user.isRead = true  -- true已经读取，其它情况未读
    end
end

-- 判断是否是语音
function ChatMgr.judgeIsVoice(msg)
    if (msg["type"] == "world") or (msg["type"] == "legion") then
        if msg.voice_url and msg.voice_time then
            return true
        else
            return false
        end
    else
        return false
    end
end

function ChatMgr:getDesc(type,array)
    local chatNoticeConf = GameData:getConfData('chatnotice')
    local htmlstr = chatNoticeConf[type].htmlstr
    local str = chatNoticeConf[type].str
    local num = #array
    for i = 1,num do
        str = string.gsub(str, "<s" .. i ..">", array[i])
        htmlstr = string.gsub(htmlstr, "<s" .. i ..">", array[i])
    end
    return str,htmlstr
end

function ChatMgr:OnNewChatMessage(data)
    
end
