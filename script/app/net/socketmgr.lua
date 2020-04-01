cc.exports.SocketMgr = {
    socket = nil,
    jsonStr = nil,
    addTimes = 0,
    schedulerEntryId = 0
}

-- websocket
function SocketMgr:init(port)
    local host = GlobalData:getGameServerUrl()
    host = string.gsub(host, "https", "ws")
    local index = string.find(host, ":", 4)
    host = string.sub(host, 0, index)
    host = host .. port
    local createSocket = nil
    self.flag = false
    local function socketOpen()
        print("websocket was opened.")
        local obj = {
            uid = GlobalData:getSelectUid(),
            mod = "user",
            act = "handshake",
            args = {
                auth_key = GlobalData:getAnthKey(),
                auth_time = GlobalData:getAnthTime(),
                openid = GlobalData:getOpenId()
            }
        }
        self.socket:sendString(json.encode(obj))
    end

    local function socketMessage(jsonStr)
        print("==============getMessage==============:" .. jsonStr)
        if jsonStr ~= "" then
            if self.jsonStr then
                jsonStr = self.jsonStr .. jsonStr
                self.jsonStr = jsonStr
                self.addTimes = self.addTimes + 1
            end
            local jsonObj = json.decode(jsonStr)


            if jsonObj then
                self.addTimes = 0
                self.jsonStr = nil
                if jsonObj.code == 0 then
                    local key = jsonObj.mod .. "_" .. jsonObj.act
                    jsonObj.data.act = jsonObj.act
                    jsonObj.data.mod = jsonObj.mod

                    CustomEventMgr:dispatchEvent(key, jsonObj.data)
                elseif jsonObj.code == 101 then

                    --禁言之后提示框
                    -- promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES8'), COLOR_TYPE.RED)
                    -- return
       


                    --禁言之后玩家可以发送消息自己看到，别人不能看到
                    local msg = json.decode(self.sendJosn)
                    local content   =  msg.args.content
                    local Type      =  msg.args.type 
                    local act       =   msg.act
                    local mod       =   msg.mod
   
                    local headframe = UserData:getUserObj():getHeadFrameId()  -- 头像框Id
                    local headframeIcon = UserData:getUserObj():getHeadFrame()  -- 头像框Id
                    local quality = tonumber(string.sub(headframeIcon , -6 , -5))
                    local title     = GameData:getConfData('chatlord')  --称号
                    local headpic   = UserData:getUserObj():getHeadpicId()    --头像Id
                    local level     = UserData:getUserObj():getLv()         --等级
                    local uid       = UserData:getUserObj():getUid()        --uid
                    local un       = UserData:getUserObj():getName()        --名字
                    local vip       = UserData:getUserObj():getVip()        --vip等级
                    local time      = jsonObj.serverTime


                    local data = {
                                    content = content,
                                    quality = quality,
                                    time    = time,
                                    title   = "",
                                    type    = Type,
                                    user    = {
                                        headframe = headframe,
                                        headpic = headpic,
                                        level   = level,
                                        uid     = uid,
                                        un      = un,
                                        vip     = vip,
                                    },
                    }


                    dump(data)
                    local key = act .. "_" .. mod
                    jsonObj.data.act = act
                    jsonObj.data.mod = mod
                    CustomEventMgr:dispatchEvent(key, data)
                elseif jsonObj.code == 102 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_40'), COLOR_TYPE.RED)
                    return
                else
                    if jsonObj.code > 1 and jsonObj.code < 10 then
                        self.flag = true
                        if self.socket then
                            self.socket:close()
                        end
                        -- MessageMgr:parseCode(jsonObj.code)
                        MessageMgr:parseCode(jsonObj)
                    end
                end
            elseif self.addTimes > 5 then
                self.flag = false
                if self.socket then
                    self.socket:close()
                end
            end
        end
    end

    local function socketClose()
        print("websocket closed")
        self.addTimes = 0
        self.jsonStr = nil
        if self.socket then
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_OPEN)
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_MESSAGE)
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_CLOSE)
            self.socket:unregisterScriptHandler(cc.WEBSOCKET_ERROR)
            self.socket = nil
        end
        if not self.flag then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
            self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
                if self.schedulerEntryId > 0 then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                    self.schedulerEntryId = 0
                    createSocket()
                end
            end, 5, false)
        end
    end

    local function socketError()
        print("websocket Error")
    end

    createSocket = function ()
        local socket = cc.WebSocket:create(host)
        socket:registerScriptHandler(socketOpen, cc.WEBSOCKET_OPEN)
        socket:registerScriptHandler(socketMessage, cc.WEBSOCKET_MESSAGE)
        socket:registerScriptHandler(socketClose, cc.WEBSOCKET_CLOSE)
        socket:registerScriptHandler(socketError, cc.WEBSOCKET_ERROR)
        self.socket = socket
    end
    createSocket()
end

function SocketMgr:close()
    if self.schedulerEntryId > 0 then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
        self.schedulerEntryId = 0
    end
    self.flag = true
    if self.socket then
        self.socket:close()
    end
end

function SocketMgr:send(act, mod, args)
    if self.socket and cc.WEBSOCKET_STATE_OPEN == self.socket:getReadyState() then
        local obj = {
            uid = GlobalData:getSelectUid(),
            mod = mod,
            act = act,
            args = args
        }
        self.sendJosn = json.encode(obj)
       
        self.socket:sendString(self.sendJosn)

        -- print("==============sendMessage==============:" .. sendJosn)
    end
end