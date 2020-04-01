local ClassFriendsMainUI = require("script/app/ui/friends/friendsmainpanel")
local ClassFriendsInfoUI = require('script/app/ui/friends/friendsinfopanel')
local ClassFriendsRankUI = require('script/app/ui/friends/friendsrankpanel')
local ClassFriendsAwardsUI = require('script/app/ui/friends/friendsawardspanel')
local ClassFriendsFindBossUI = require('script/app/ui/friends/friendsfindbosspanel')
local ClassFriendsBossUI = require('script/app/ui/friends/friendsbosspanel')
cc.exports.FriendsMgr = {
	uiClass = {
		FriendsMainUI = nil,
		FriendsInfoUI = nil,
		FriendsRankUI = nil,
		FriendsAwardsUI = nil,
		FriendsFindBossUI = nil,
		FriendsBossUI = nil
	},
	friendsdata = {},
	recommenddata = {},
    speakTime = 0,
    chatCacheDatas = {},
    chatCacheFriendSendStatus = {},    -- 缓存的有好友发过来的状态数据.索引是好友的uid
    dirty = false
}

setmetatable(FriendsMgr.uiClass, {__mode = "v"})

function FriendsMgr:showFriendsMain(callback)
	if self.uiClass["FriendsMainUI"] == nil then
		MessageMgr:sendPost("get", "friend", "{}", function (jsonObj)
	        if jsonObj.code == 0 then
	        	self:setFriendData(jsonObj.data)

                UserData:getUserObj().friendToTwenty = false
                UserData:getUserObj().tips.friend_message = 0
                UserData:getUserObj().tips.friend_gift = 0
                UserData:getUserObj().tips.friend_apply = 0

                UserData:getUserObj():getFriendsysInfo().explorationtime = self.friendsdata.explorationtime
                UserData:getUserObj():getFriendsysInfo().hasfightboss = self.friendsdata.hasfightboss

                -- 好友如果有离线消息则缓存到本地
                self:cacheFriendData(jsonObj.data)
                self:setDirty(false)
	            self.uiClass["FriendsMainUI"] = ClassFriendsMainUI.new()
				self.uiClass["FriendsMainUI"]:showUI()

				if callback then
			    	callback()
			    end
	        end
	    end)
	end
end

function FriendsMgr:hideFriendsMain()
	if self.uiClass["FriendsMainUI"] then
		self.uiClass["FriendsMainUI"]:hideUI()
		self.uiClass["FriendsMainUI"] = nil
	end
end

function FriendsMgr:setFriendData(data)
	self.friendsdata = data
end

function FriendsMgr:getFriendData()
	return self.friendsdata
end

function FriendsMgr:cacheFriendData(friendsdata)
    for k,v in pairs(friendsdata.friends) do
        local offlineMessage = v.offlineMessage
        if #offlineMessage > 0 then
            local uid = v.uid   -- uid是好友的uid(字符串)
            if FriendsMgr.chatCacheDatas[uid] == nil then       
                FriendsMgr.chatCacheDatas[uid] = {}
            end
            for k,v in pairs(offlineMessage) do
                table.insert(FriendsMgr.chatCacheDatas[uid],v)      -- senduid 是每条消息的发送者uid,receiveuid是接收者的uid
            end
            table.sort(FriendsMgr.chatCacheDatas[uid],function(a, b)
		        return b.time > a.time
	        end)
        end
    end
end

function FriendsMgr:showFriendsInfo()
	if self.uiClass["FriendsInfoUI"] == nil then
		MessageMgr:sendPost("recommend", "friend", "{}", function (jsonObj)
	        print(json.encode(jsonObj))
	        if jsonObj.code == 0 then
	        	self:setRecommendData(jsonObj.data)
	            self.uiClass["FriendsInfoUI"] = ClassFriendsInfoUI.new()
				self.uiClass["FriendsInfoUI"]:showUI()
	        end
	    end)
	end
end

function FriendsMgr:hideFriendsInfo()
	if self.uiClass["FriendsInfoUI"] then
		self.uiClass["FriendsInfoUI"]:hideUI()
		self.uiClass["FriendsInfoUI"] = nil
	end
end

function FriendsMgr:setRecommendData(data)
	self.recommenddata = data
end

function FriendsMgr:getRecommendData()
	return self.recommenddata
end

function FriendsMgr:showFriendsRank()
	if self.uiClass["FriendsRankUI"] == nil then
		 MessageMgr:sendPost("rank_list", "friend", "{}", function (jsonObj)
	        print(json.encode(jsonObj))
	        if jsonObj.code == 0 then
	            self.uiClass["FriendsRankUI"] = ClassFriendsRankUI.new(jsonObj.data)
				self.uiClass["FriendsRankUI"]:showUI()
	         end
	     end)
	end
end

function FriendsMgr:hideFriendsRank()
	if self.uiClass["FriendsRankUI"] then
		self.uiClass["FriendsRankUI"]:hideUI()
		self.uiClass["FriendsRankUI"] = nil
	end
end

function FriendsMgr:showFriendsFindBoss()
	if self.uiClass["FriendsFindBossUI"] == nil then
        local obj = {
            bossOwnerId = UserData:getUserObj():getUid()
        }
		MessageMgr:sendPost("get_boss", "friend", json.encode(obj), function (jsonObj)
	        print(json.encode(jsonObj))
	        if jsonObj.code == 0 then
	            self.uiClass["FriendsFindBossUI"] = ClassFriendsFindBossUI.new(jsonObj.data)
				self.uiClass["FriendsFindBossUI"]:showUI()
			else
	            self.uiClass["FriendsFindBossUI"] = ClassFriendsFindBossUI.new(nil)
				self.uiClass["FriendsFindBossUI"]:showUI()				
	        end
	    end)
	end
end

function FriendsMgr:hideFriendsFindBoss()
	if self.uiClass["FriendsFindBossUI"] then
		self.uiClass["FriendsFindBossUI"]:hideUI()
		self.uiClass["FriendsFindBossUI"] = nil
	end
end

function FriendsMgr:showFriendsBoss(OwnerId)
	if self.uiClass["FriendsBossUI"] == nil then
	    local obj = {
            bossOwnerId = OwnerId
        }
		MessageMgr:sendPost("get_boss", "friend", json.encode(obj), function (jsonObj)
	        print(json.encode(jsonObj))
	        if jsonObj.code == 0 then
	            self.uiClass["FriendsBossUI"] = ClassFriendsBossUI.new(jsonObj.data,OwnerId)
				self.uiClass["FriendsBossUI"]:showUI()
            elseif jsonObj.code == 100 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_13'), COLOR_TYPE.RED)
	        end
	    end)
	end
end

function FriendsMgr:hideFriendsBoss()
	if self.uiClass["FriendsBossUI"] then
		self.uiClass["FriendsBossUI"]:hideUI()
		self.uiClass["FriendsBossUI"] = nil
	end
end


function FriendsMgr:showFriendsAwards()
	if self.uiClass["FriendsAwardsUI"] == nil then
	    self.uiClass["FriendsAwardsUI"] = ClassFriendsAwardsUI.new()
		self.uiClass["FriendsAwardsUI"]:showUI()
	end
end

function FriendsMgr:hideFriendsAwards()
	if self.uiClass["FriendsAwardsUI"] then
		self.uiClass["FriendsAwardsUI"]:hideUI()
		self.uiClass["FriendsAwardsUI"] = nil
	end
end


function FriendsMgr:MsgPop(codeid)
    if codeid == 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_5'), COLOR_TYPE.GREEN)
    elseif codeid == 1 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_8'), COLOR_TYPE.RED)
    elseif codeid == 2 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_9'), COLOR_TYPE.RED)
    elseif codeid == 3 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_3'), COLOR_TYPE.RED) 
    elseif codeid == 4 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_2'), COLOR_TYPE.RED) 
    elseif codeid == 5 then
        --todo 更新好友列表
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_6'), COLOR_TYPE.GREEN) 
    elseif codeid == 6 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_1'), COLOR_TYPE.RED)
    elseif codeid == 7 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_10'), COLOR_TYPE.RED) 
    elseif codeid == 8 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_12'), COLOR_TYPE.RED)
    elseif codeid == 9 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_4'), COLOR_TYPE.RED)
    elseif codeid == 10 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_14'), COLOR_TYPE.RED)              
    end
end

function FriendsMgr:SendChatMsg(friendId,chatContent,voice_url,voice_time)
    local msg = {}
    msg["friendId"] = friendId
    msg["content"] = chatContent
    if voice_url then
        msg["voice_url"] = voice_url
    end
    if voice_time then
        msg["voice_time"] = voice_time
    end
    SocketMgr:send("friend_chat","chat",msg)
end

function FriendsMgr:resetCdTime(time)
    self.speakTime = time or GlobalData:getServerTime()
end

function FriendsMgr:judgeSpeakIsOutTime()
    --local nowTime = GlobalData:getServerTime()
    --if nowTime - self.speakTime <= 0 then
        --return true
    --else
        --return false
    --end
    return false
end

-- 判断是否是语音
function FriendsMgr.judgeIsVoice(msg)
    if msg.voice_url and msg.voice_time then
        return true
    else
        return false
    end
end

function FriendsMgr:GetLog()
    CustomEventMgr:addEventListener("chat_friend_chat",self,FriendsMgr.ProcessChatMsg)
    CustomEventMgr:addEventListener("chat_friend_boss",self,FriendsMgr.ProcessFriendBossMsg)
end

function FriendsMgr.ProcessChatMsg(msg)
    if UserData:getUserObj():getUid() == tonumber(msg.senduid) then   -- 自己发的,好友的uid是receiveuid
        if FriendsMgr.chatCacheDatas[msg.receiveuid] == nil then
            FriendsMgr.chatCacheDatas[msg.receiveuid] = {}
        end
        table.insert(FriendsMgr.chatCacheDatas[msg.receiveuid],msg)

        local num = 0
        for k,v in pairs(FriendsMgr.chatCacheDatas[msg.receiveuid]) do
            if num >= 2 then
                break
            end
            if UserData:getUserObj():getUid() == tonumber(v.senduid) then
                num = num + 1
            end
        end
        if num == 1 then
            local specialMsg = clone(msg)
            specialMsg.showType = 1     -- 代表是文本
            table.insert(FriendsMgr.chatCacheDatas[msg.receiveuid],specialMsg)
        end
    else    -- 好友发给我的,好友的uid是senduid
        if FriendsMgr.chatCacheDatas[msg.senduid] == nil then 
            FriendsMgr.chatCacheDatas[msg.senduid] = {}
        end
        table.insert(FriendsMgr.chatCacheDatas[msg.senduid],msg)
        FriendsMgr.chatCacheFriendSendStatus[msg.senduid] = 1
        if FriendsMgr.uiClass.FriendsMainUI ~= nil then       
            FriendsMgr.uiClass.FriendsMainUI:refreshLeftShow(msg)
        end
    end
    if FriendsMgr.uiClass.FriendsMainUI ~= nil then
        FriendsMgr.uiClass.FriendsMainUI:showNewMessage(msg)
    end
end

function FriendsMgr.ProcessFriendBossMsg(msg)
    if FriendsMgr.uiClass.FriendsMainUI ~= nil then
        FriendsMgr.uiClass.FriendsMainUI:refreshBossLeftShow(msg)
    end
end

-- 清除聊天数据缓存
function FriendsMgr:clearUserCacheData(uid)
    FriendsMgr.chatCacheDatas[uid] = nil
end

-- 处理语音数据
function FriendsMgr.handleVocieData(msg)
    if not FriendsMgr.judgeIsVoice(msg) then
        return
    end
end

-- 有未读消息
function FriendsMgr:getFriendNotReadStatus()
    local isOpen = GlobalApi:getOpenInfo('friend')
    if isOpen == false then
        return isOpen
    end
    local status = false
    for k,v in pairs(FriendsMgr.chatCacheFriendSendStatus) do
        if v then
            status = true
            break
        end
    end
    return status
end

-- 有好友申请
function FriendsMgr:getFriendApplyStatus()
    local isOpen = GlobalApi:getOpenInfo('friend')
    if isOpen == false then
        return isOpen
    end

    local status = false
    if self.friendsdata and self.friendsdata.applied and #self.friendsdata.applied > 0 then
        status = true
    end

    return status
end

-- 有有好友礼物可以领取
function FriendsMgr:getFriendGiftStatus()
    local isOpen = GlobalApi:getOpenInfo('friend')
    if isOpen == false then
        return isOpen
    end
    local status = false
    local friendconf = GameData:getConfData('friend')
    if self.friendsdata and self.friendsdata.friends then
        for k,v in pairs(self.friendsdata.friends) do
            if v.hasGiftReceive == 1 then
                if tonumber(self.friendsdata.dailyGiftGetNum) >= tonumber(friendconf['dailyGiftGetLimit'].value) then
                else
                    status = true
                end
            end
        end
    end
    return status
end

function FriendsMgr:setDirty(dirty)
    self.dirty = dirty
end

function FriendsMgr:getDirty()
    return self.dirty
end