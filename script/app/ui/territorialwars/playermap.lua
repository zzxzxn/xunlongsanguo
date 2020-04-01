local path = "script/app/ui/territorialwars/playerstack"

cc.exports.playermap = {}

function playermap:insert(cellId,data)
	cellId = tonumber(cellId)
	if not self[cellId] then
		if package.loaded[path] then
			package.loaded[path] = nil
		end
		self[cellId] = {_data = nil}
		self[cellId]._data = require(path)
	end
	self[cellId]._data:push(data)
end

function playermap:top(cellId)

	cellId = tonumber(cellId)
	if not self[cellId] then
		return
	end
	return self[cellId]._data:top()
end

function playermap:pop(cellId)

	cellId = tonumber(cellId)
	if not self[cellId] then
		return
	end
	return self[cellId]._data:pop()
end

function playermap:getmap()

	return playermap
end

function playermap:getplayerStack(cellId)

	cellId = tonumber(cellId)
	if not self[cellId] then
		return
	end
	return self[cellId]._data

end

function playermap:delete(uid)

	for k,v in pairs(playermap) do
		if type(v) ~= "function" then
			local data = v._data:delete(uid)
            if data ~= nil then
            	return data
            end 
        end
	end
	return nil
end

function playermap:getdata(uid)
	uid = tonumber(uid)
	for k,v in pairs(playermap) do
		if type(v) ~= "function" then
			local data = v._data:getdata(uid)
            if data ~= nil then
            	return data
            end 
        end
	end
	return nil
end

function playermap:isTop(uid)

	for k,v in pairs(playermap) do
		
		if type(v) ~= "function" then
			local res = v._data:isTop(uid)
			if res ~= nil then
				return v._data:isTop(uid)
			end
        end
	end
	return nil
end

function playermap:clear()
	for k,v in pairs(playermap) do
		if type(v) ~= "function" then
			v._data:clear()
			v.data = nil
		end
	end 
end



