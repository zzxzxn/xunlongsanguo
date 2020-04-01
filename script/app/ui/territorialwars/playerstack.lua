local Stack = {}
function Stack:new()
	local copy = {}
	setmetatable(copy,self)
	self.__index = self
	return copy
end

function Stack:top()
	if #self == 0 then
		return nil
	end
	return self[#self]
end

function Stack:push(data)

	if not data then
		return
	end

	local uid = UserData:getUserObj():getUid()
	if not uid then
		return
	end

	local temp = self:top()
	if temp and temp.uid == uid then
		self[#self] = data
	  	self[#self+1] = temp
	else
		self[#self+1] = data
	end

end


function Stack:pop()

	local data = self:top()
	for i=#self,1,-1 do
		if self[i] == data then
			table.remove(self,i)
		end
	end
	return data
end

function Stack:delete(uid)
	local data = nil
	for i=#self,1,-1 do
		if self[i].uid == uid then
			data = self[i]
			table.remove(self,i)
		end
	end
	return data
end

function Stack:clear()
	for i=#self,1,-1 do
		table.remove(self,i)
	end
end

function Stack:getdata(uid)

	local data = nil
	for i=#self,1,-1 do
		if self[i].uid == uid then
			data = self[i]
		end
	end
	return data
end

function Stack:isTop(uid)
	local data = nil
	local index = nil
	for i=#self,1,-1 do
		if self[i].uid == uid then
			index = i
			break
		end
	end
	
	if index == nil then
		return nil
	end

	local res = (index == #self) and true or false
	return res
end

return Stack