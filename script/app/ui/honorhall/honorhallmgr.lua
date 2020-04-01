local ClassHonorHallUI = require("script/app/ui/honorhall/honorhallui")
local ClassTagWallUI = require("script/app/ui/honorhall/tagwallui")

cc.exports.HonorHallMgr = {
    uiClass = {
        HonorHallUI = nil,
        TagWallUI = nil,
    },
}

setmetatable(HonorHallMgr.uiClass, {__mode = "v"})


function HonorHallMgr:showUI()
	if self.uiClass.HonorHallUI == nil then
        self:GetHonorData()
	end
end

function HonorHallMgr:hideUI(call)
	if self.uiClass.HonorHallUI then
        self.uiClass.HonorHallUI:ActionClose(call)
		self.uiClass.HonorHallUI = nil
	end
end

function HonorHallMgr:showTagWallUI(typeString)
	if self.uiClass.TagWallUI == nil then
        self:GetTagData(typeString)
	end
end

function HonorHallMgr:hideTagWallUI(call)
	if self.uiClass.TagWallUI then
        self.uiClass.TagWallUI:ActionClose(call)
		self.uiClass.TagWallUI = nil
	end
end

function  HonorHallMgr:GetHonorData()
     MessageMgr:sendPost('get_honor_hall','user',json.encode({}),function(jsonObj)
        print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            return
        end

        self.uiClass.HonorHallUI = ClassHonorHallUI.new()
	    self.uiClass.HonorHallUI:showUI()
        self.uiClass.HonorHallUI:setTopRoles(jsonObj.data.honor_list)
        self.uiClass.HonorHallUI:createMoveRoles(jsonObj.data.names)

    end)
end
function  HonorHallMgr:GetTagData(typeString,uid)
    MessageMgr:sendPost('get_honor_user','user',json.encode({["type"] = typeString,target = uid}),function(jsonObj)
        if(jsonObj.code ~= 0) then
            print(json.encode(jsonObj))
            return
        end

        if(jsonObj.data.replace ~= nil) then
            self.uiClass.HonorHallUI:replcaceType(typeString,jsonObj.data.replace)
        end

        self.uiClass.TagWallUI = ClassTagWallUI.new()
	    self.uiClass.TagWallUI:showUI()
        self.uiClass.TagWallUI:displayByData(jsonObj.data,typeString,uid)
    end)
end
function HonorHallMgr:AddTag(typeString,uid,bullet)
    local msg = {}
    msg.type = typeString
    print(uid)
    msg.target = uid
    msg.bullet = bullet


    MessageMgr:sendPost('send_bullet','user',json.encode(msg),function(jsonObj)
         print(json.encode(jsonObj))
        if(jsonObj.code ~= 0) then
            if(json.code == 102) then
                 promptmgr:showMessageBox(GlobalApi:getLocalStr("HONORHALL_OUT"), MESSAGE_BOX_TYPE.MB_OK)
            end
            return
        end
        self.uiClass.TagWallUI:refreshTag(jsonObj.data.bullet)
        self.uiClass.HonorHallUI:addTag(bullet)

    end)
end