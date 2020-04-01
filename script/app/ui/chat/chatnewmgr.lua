local ClassNewChatUI = require("script/app/ui/chat/chatnewui")

cc.exports.ChatNewMgr = {
    uiClass = {
        chatUI = nil,
    },
    worldChannelDatas = {},
    legionChannelDatas = {},
    systemChannelDatas = {},
    shoutChannelDatas = {},
    countryWarChannelDatas = {},
    countryWarShoutChannelDatas = {},
    isChatShow = false,
    speakTime = 0,
    speakLimitTime = 0,   -- 聊天刷屏时间限制
}

setmetatable(ChatNewMgr.uiClass, {__mode = "v"})

function ChatNewMgr:showChat(type)
    local chatLevelLimit = tonumber(GlobalApi:getGlobalValue('chatLevelLimit'))
    local lv = UserData:getUserObj():getLv()
    if lv < chatLevelLimit then
        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('CHAT_DESC_2'),chatLevelLimit), COLOR_TYPE.RED)
        return
    end
    
	if self.uiClass["chatUI"] == nil then
        self.uiClass["chatUI"] = ClassNewChatUI.new(type)
	    self.uiClass["chatUI"]:showUI()
	end
end

function ChatNewMgr:hideChat()
    for i = #self.legionChannelDatas,1,-1 do
        local data = self.legionChannelDatas[i]
        if data.info and data.info.used and data.info.used ~= 0 then    -- 清除已经领取的红包
            table.remove(self.legionChannelDatas,i)
        end
    end

	if self.uiClass["chatUI"] then
        self.uiClass["chatUI"]:ActionClose()
		self.uiClass["chatUI"] = nil
        self.isChatShow = false
	end
end

function ChatNewMgr:GetLog()
    local function socketOpenCall()
        CustomEventMgr:removeEventListener("user_handshake",self)
        CustomEventMgr:addEventListener("chat_get_chat_log",self,ChatNewMgr.ProcessChatLogMsg)
        CustomEventMgr:addEventListener("chat_chat",self,ChatNewMgr.ProcessChatMsg)
        CustomEventMgr:addEventListener("chat_system",self,ChatNewMgr.ProcessChatMsg)
        CustomEventMgr:addEventListener("countrywar_chat",self,ChatNewMgr.ProcessChatMsg)
        CustomEventMgr:addEventListener("countrywar_shout",self,ChatNewMgr.ProcessChatMsg)
        SocketMgr:send("get_chat_log","chat",{})
    end
    CustomEventMgr:addEventListener("user_handshake", ChatNewMgr, socketOpenCall)
end

function ChatNewMgr:SendChatMsg(channelString,chatContent,voice_url,voice_time)
    local msg = {}
    msg["type"] = channelString
    msg["content"] = chatContent
    if voice_url then
        msg["voice_url"] = voice_url
    end
    if voice_time then
        msg["voice_time"] = voice_time
    end
    if channelString == "shout" then
        MessageMgr:sendPost('shout','user',json.encode(msg),function(jsonObj)
            if jsonObj.code == 101 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES8'), COLOR_TYPE.RED)
                return
            end
            GlobalApi:parseAwardData(jsonObj.data.costs)
            if ChatNewMgr.uiClass.chatUI ~= nil then
                ChatNewMgr.uiClass.chatUI:refreshShoutItemNum()
            end
        end)
    elseif channelString == "countrywar_shout" then
        MessageMgr:sendPost('shout','countrywar',json.encode(msg),function(jsonObj)
            if jsonObj.code == 101 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES8'), COLOR_TYPE.RED)
                return
            end
            GlobalApi:parseAwardData(jsonObj.data.costs)
            if ChatNewMgr.uiClass.chatUI ~= nil then
                ChatNewMgr.uiClass.chatUI:refreshShoutItemNum()
            end
        end)
    elseif channelString == "countrywar" then
        MessageMgr:sendPost('chat','countrywar',json.encode(msg),function(jsonObj)
            
        end)
    else
        if channelString == 'world' and voice_url == nil then
            UserData:getUserObj():setDayWorldChatCount(UserData:getUserObj():getDayWorldChatCount() + 1)
        end
        SocketMgr:send("chat","chat",msg)
    end
end

function ChatNewMgr:SendOpenGiftMsg(boonId,callBack)
    local msg = {}
    msg.id = boonId
    MessageMgr:sendPost('grab_boon','legion',json.encode(msg),function(jsonObj)
        if(jsonObj.code ~= 0) then
            if(jsonObj.code == 116) then
                if ChatNewMgr.uiClass.chatUI ~= nil then
                    for k,cell in pairs(self.legionChannelDatas) do
                        if cell.info ~= nil and cell.info.boon ~= nil and cell.info.boon.id == boonId then
                            cell.info.used = true
                            break
                        end
                    end
                    if callBack then
                        callBack()
                    end
                    promptmgr:showMessageBox(GlobalApi:getLocalStr('CHAT_GRAB_OVER'), MESSAGE_BOX_TYPE.MB_OK)
                end
            end
            return
        end
        local awards = jsonObj.data.awards
        GlobalApi:parseAwardData(awards)
        GlobalApi:showAwardsCommon(awards,true,nil,false)

        UserData:getUserObj():getLegionInfo().grab_boon = UserData:getUserObj():getLegionInfo().grab_boon + jsonObj.data.count
        if(ChatNewMgr.uiClass.chatUI ~= nil) then
            for k,cell in pairs(self.legionChannelDatas) do
                if cell.info ~= nil and cell.info.boon ~= nil and cell.info.boon.id == boonId then
                    cell.info.used = true
                    break
                end
            end
            if callBack then
                callBack()
            end
        end
    end)
end

function ChatNewMgr.ProcessChatLogMsg(msg)
    print("RecvChatLogMsg")
    ChatNewMgr.worldChannelDatas = ChatNewMgr:sortDatas(msg.chat_log.world)
    ChatNewMgr.legionChannelDatas = ChatNewMgr:sortDatas(msg.chat_log.legion,true)
    ChatNewMgr.shoutChannelDatas = ChatNewMgr:sortDatas(msg.chat_log.shout)
    ChatNewMgr.systemChannelDatas = ChatNewMgr:sortDatas(msg.chat_log.country)    -- 里面有合璧和系统消息
end

function ChatNewMgr:sortDatas(datas,isLegion)
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
        -- 语音处理
        if ChatNewMgr.judgeIsVoice(data) and data.user.uid and (data.user.uid == UserData:getUserObj():getUid()) then
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
                ChatNewMgr.isChatShow = false
            else
                if(tonumber(UserData:getUserObj():getLegionInfo().grab_boon) < tonumber(GlobalApi:getGlobalValue("grabBoonPerDay"))) and data.info and data.info.used == 0 then
                    legionCount = legionCount + 1
                end

            end
        end

    end

    if isLegion == true then
        if legionCount > 0 then
            -- ChatNewMgr.isChatShow = true
            if UIManager and UIManager.sidebar then   
                UIManager.sidebar:updateChatShowStatus()
            end
            if CountryWarMgr then
                CountryWarMgr:updateChatShowStatus()
            end
        end
    end

    return ret
end

function ChatNewMgr.ProcessChatMsg(msg)
    print("ProcessChatMsg")
    if msg.mod == 'countrywar' and msg.act == 'chat' then
        if msg.user and msg.user.camp and msg.user.camp == CountryWarMgr.camp then
        else
            return
        end
    end

    local channelData = nil
    if msg.act == 'system' then   -- 系统消息
        channelData = ChatNewMgr.systemChannelDatas   -- 暂时把这个加到这个字段里面
        UIManager:getSidebar():setChatMsg(msg)

        msg.index = #channelData
        table.insert(channelData,msg)

        if(ChatNewMgr.uiClass.chatUI ~= nil and ChatNewMgr.uiClass.chatUI.curChannelStrings == 'system') then
            ChatNewMgr.uiClass.chatUI:showNewMessage(msg)
        end

    elseif msg.mod == 'countrywar' then   -- 国战消息
        if msg.act == 'chat' then
            channelData = ChatNewMgr.countryWarChannelDatas

            msg.index = #channelData
            table.insert(channelData,msg)

            if(ChatNewMgr.uiClass.chatUI ~= nil and ChatNewMgr.uiClass.chatUI.curChannelStrings == 'countrywar') then
                ChatNewMgr.uiClass.chatUI:showNewMessage(msg)
            end

            if UIManager and UIManager.sidebar then   
                UIManager.sidebar:updateChatShowStatus()
            end
            if CountryWarMgr then
                CountryWarMgr:updateChatShowStatus()
                CountryWarMgr:setMapLittleChatMsg(msg)
                CountryWarMgr:setMatchLittleChatMsg(msg)
            end
        elseif msg.act == 'shout' then
            channelData = ChatNewMgr.countryWarShoutChannelDatas
            if CountryWarMgr then
                CountryWarMgr:setMapChatShoutMsg(msg)
            end

            msg.index = #channelData
            table.insert(channelData,msg)

            if(ChatNewMgr.uiClass.chatUI ~= nil and ChatNewMgr.uiClass.chatUI.curChannelStrings == 'countrywar_shout') then
                ChatNewMgr.uiClass.chatUI:showNewMessage(msg)
            end

            if UIManager and UIManager.sidebar then   
                UIManager.sidebar:updateChatShowStatus()
            end
        end
    else
        print('==================',msg["type"])
        --ChatNewMgr.handleVocieData(msg)
        if msg["type"] == "country" and msg.info.roomId then
           if (not msg.user.uid) or (msg.user.uid and msg.user.uid == UserData:getUserObj():getUid()) then
                return
           end
        end
        if msg["type"] == "world" then
            channelData = ChatNewMgr.worldChannelDatas

            local chatLevelLimit = tonumber(GlobalApi:getGlobalValue('chatLevelLimit'))
            local lv = UserData:getUserObj():getLv()
            if lv >= chatLevelLimit then
                UIManager:getSidebar():setLittleChatMsg(msg)
            end
        elseif msg["type"] == "legion" then
            if msg.info ~= nil and msg.info.self_use == 0 and msg.user.uid == GlobalData:getSelectUid() then
                return
            end
            ChatNewMgr.isChatShow = false
            -- 自己不能抢
            if msg.user.uid == GlobalData:getSelectUid() then
                ChatNewMgr.isChatShow = false
            else
                if(tonumber(UserData:getUserObj():getLegionInfo().grab_boon) < tonumber(GlobalApi:getGlobalValue("grabBoonPerDay"))) and msg.info and msg.info.used == 0 then
                    -- ChatNewMgr.isChatShow = true
                end
            end

            channelData = ChatNewMgr.legionChannelDatas

            local chatLevelLimit = tonumber(GlobalApi:getGlobalValue('chatLevelLimit'))
            local lv = UserData:getUserObj():getLv()
            if lv >= chatLevelLimit then
                UIManager:getSidebar():setLittleChatMsg(msg)
            end
        elseif msg["type"] == "country" then
            channelData = ChatNewMgr.systemChannelDatas
        elseif msg["type"] == "shout" then
            channelData = ChatNewMgr.shoutChannelDatas
            UIManager:getSidebar():setChatMsg(msg)
        elseif msg["type"] == "countrywar" then
            channelData = ChatNewMgr.countryWarChannelDatas
        end

        msg.index = #channelData
        table.insert(channelData,msg)

        if(ChatNewMgr.uiClass.chatUI ~= nil and ChatNewMgr.uiClass.chatUI.curChannelStrings == msg["type"]) then
            ChatNewMgr.uiClass.chatUI:showNewMessage(msg)
        end
        if UIManager and UIManager.sidebar then
            UIManager.sidebar:updateChatShowStatus()
        end
        if CountryWarMgr then
            CountryWarMgr:updateChatShowStatus()
        end
    end
end

function ChatNewMgr:resetCdTime(time)
    self.speakTime = time or GlobalData:getServerTime()
end

function ChatNewMgr:judgeSpeakIsOutTime()
    local nowTime = GlobalData:getServerTime()
    if nowTime - self.speakTime <= 10 then
        return true
    else
        return false
    end
end

function ChatNewMgr:judgeSpeakLimitTime()
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

function ChatNewMgr:resetSpeakLimitCdTime(time)
    self.speakLimitTime = time or GlobalData:getServerTime()
end

-- 处理语音数据
function ChatNewMgr.handleVocieData(msg)
    if not ChatNewMgr.judgeIsVoice(msg) then
        return
    end
    if msg.user.uid and (msg.user.uid == UserData:getUserObj():getUid()) then
        msg.user.isRead = true  -- true已经读取，其它情况未读
    end
end

-- 判断是否是语音
function ChatNewMgr.judgeIsVoice(msg)
    if msg.voice_url and msg.voice_time then
        return true
    end
    if (msg["type"] == "world") or (msg["type"] == "legion") or (msg["type"] == "countrywar") then
        if msg.voice_url and msg.voice_time then
            return true
        else
            return false
        end
    else
        return false
    end
end

function ChatNewMgr:getDesc(type,array)
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

-- 得到玉璧的文字
function ChatNewMgr:getJadeDesc(jade)
    local color = COLOR_TYPE.GREEN
    local jadeType = GameData:getConfData('countryjade')[tonumber(jade)].type
    if jadeType == 1 then
        color = cc.c4b(17,178,25,255)
    elseif jadeType == 2 then
        color = cc.c4b(20,130,181,255)
    elseif jadeType == 3 then
        color = cc.c4b(255,255,255,255)
    elseif jadeType == 4 then
        color = cc.c4b(204,119,28,255)
    elseif jadeType == 5 then
        color = COLOR_TYPE.RED
    end

    local des2 = GameData:getConfData('countryjade')[tonumber(jade)].desc
    local content = GlobalApi:getLocalStr("COUNTRY_JADE_DES45") .. des2 .. GlobalApi:getLocalStr("COUNTRY_JADE_DES46")
    return content,color
end
