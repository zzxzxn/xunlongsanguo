cc.exports.CustomEventMgr = {
    listeners = {}
}

cc.exports.CUSTOM_EVENT = {
    UI_SHOW = 1,
    MSG_RESPONSE = 2,
    GUIDE_FINISH = 3,
    GUIDE_START = 4,
    ENTER_BACKGROUND = 5,
    ENTER_FOREGROUND = 6,
    UPDATE_NO_NEED = 7,
    UPDATE_FINISH = 8,
    LEGION_BUILDING_UPGRADE = 9,
    BACK_TO_LOGIN = 10,
    RESTART_GAME = 11,
    GET_REWARD = 12
}

cc.exports.SOCKET_EVENT = {
}

function CustomEventMgr:addEventListener(name, obj, callback)
    if self.listeners[name] == nil then
        self.listeners[name] = {}
        setmetatable(self.listeners[name], {__mode = "k"})
    end
    self.listeners[name][obj] = callback
end

function CustomEventMgr:removeEventListener(name, obj)
    if self.listeners[name] then
        self.listeners[name][obj] = nil
        if next(self.listeners[name]) == nil then
            self.listeners[name] = nil
        end
    end
end

function CustomEventMgr:dispatchEvent(name, customobj)
    if self.listeners[name] then
        for k, v in pairs(self.listeners[name]) do
            v(customobj)
        end
    end
end

function CustomEventMgr:removeEventListenersForTarget(target)
    for k, v in pairs(self.listeners) do
        for k2, v2 in pairs(v) do
            if k2 == target then
                v[k2] = nil
                break
            end
        end
    end
end

function CustomEventMgr:purge()
    self.listeners = {}
end