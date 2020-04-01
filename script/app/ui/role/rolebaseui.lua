local RoleBaseUI = class("RoleBaseUI")

function RoleBaseUI:ctor()
	self.dirty = true
	self:initPanel()
end

function RoleBaseUI:initPanel()
end

function RoleBaseUI:getPanel()
	return self.panel
end

function RoleBaseUI:setVisible(vis)
	self.panel:setVisible(vis)
end

function RoleBaseUI:setPosition( point )
	self.panel:setPosition(point)
end

function RoleBaseUI:setDirty(onlychild)
	self.dirty = true
end

function RoleBaseUI:onMoveOut()
    
end
return RoleBaseUI