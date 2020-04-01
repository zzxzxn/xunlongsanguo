--loadMask.lua

local loadMask = class("loadMask")

function loadMask:ctor()
	self.root = cc.CSLoader:createNode("csb/loadMask.csb")

	self.root:setAnchorPoint(cc.p(0.5,0.5))

	local loading = self.root:getChildByName("loading")
	loading:setScale(0.4)

	loading:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))

	local mask = self.root:getChildByName("mask")
	mask:setSwallowTouches(false)

	mask:addTouchEventListener(function ()
	
	end)
end

function loadMask:getRoot()
	return self.root
end

return loadMask