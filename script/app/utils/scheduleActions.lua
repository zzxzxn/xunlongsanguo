local scheduleActions = {
--[[
actionsArray = {
	[1] = {
		widget = target widget,
		subwidget = extra widget,
		ufunc = callback function, user function
		args = {
			[1] = args1,
			[2] = args2,
		}
		sfunc = ahead of the end function, system function
		entry = entry index,
	}
}
]]
	actionsArray = {}
}

-- SAS == SCHEDULE_ACTIONS_STATUS
cc.exports.SAS = {
	START = 1,
	FRAME = 2,
	SINGLE_END = 3,
	END = 4,
}

-- bar 目标控件
-- singletime 单条跑完的时间
-- count 跑几条
-- final 最后停到哪儿
-- func 每帧调用 func(e)
-- 			e = { status = SAS.FRAME, percent = now_percent, count = now_count }
-- 
function scheduleActions:_runExpBar(bar, singletime, count, final, func)
	local ori = bar:getPercent()
	local oncetime = singletime / 100
	local scheduler = bar:getScheduler()
	if final > 100 then
		print('[ERROR]: final is bigger then 100')
		return
	end
	if count > -1 and count < 1 then
		print('[ERROR]: count between (-1, 1)')
		return
	end

	-- -- calc sum time 
	local slow = 100
	local entry = nil
	
	local function onNodeEvent(event)
		if event == 'exit' and entry ~= nil then
			self:_clean(bar)
			scheduler:unscheduleScriptEntry(entry)
			entry = nil
		end
	end
	bar:registerScriptHandler(onNodeEvent)

	-- START FUNC
	if func ~= nil then
		local e = {
			status = SAS.START,
			percent = ori,
			count = count
		}
		func(e)
	end

	entry = scheduler:scheduleScriptFunc(function ( dt )
		if bar == nil then
			return
		end
		local np = bar:getPercent()
		local delta = dt / oncetime
		-- if math.abs(count) == 1 then
			-- delta = delta / (5 + dt * slow)
		-- end
		if count > 0 then
			local t = np + delta
			-- if end
			if count == 1 and t >= final then
				bar:setPercent(final)
				if entry ~= nil then
					if func then
						local e = {
							status = SAS.END,
							percent = final,
							count = count
						}
						func(e)
					end
					self:_clean(bar)
					scheduler:unscheduleScriptEntry(entry)
				end
				return
			end
			local st = SAS.FRAME
			if t >= 100 then
				t = 0
				count = count - 1
				st = SAS.SINGLE_END
			end
			bar:setPercent(t)
			if func then
				local e = {
					status = st,
					percent = t,
					count = count
				}
				func(e)
			end
		else
			local t = np - delta
			if count == -1 and t <= final then
				bar:setPercent(final)
				if entry ~= nil then
					if func then
						local e = {
							status = SAS.END,
							percent = final,
							count = count
						}
						func(e)
					end
					self:_clean(bar)
					scheduler:unscheduleScriptEntry(entry)
				end
				return
			end
			local st = SAS.FRAME
			if t <= 0 then
				t = 100
				count = count + 1
				st = SAS.SINGLE_END
			end
			bar:setPercent(t)
			if func then
				local e = {
					status = st,
					percent = t,
					count = count
				}
				func(e)
			end
		end
	end, 0.01, false)
	return entry
end

function scheduleActions:runExpBar(bar, singletime, count, final, func)
	self:remove(bar)

	local t = {}
	t.widget = bar
	-- t.subwidget = tx
	t.ufunc = func
	t.sfunc = function ()
		bar:setPercent(final)
		if func then
			local c = 1
			if count < 0 then
				c = -1
			end
			local e = {
				status = SAS.END,
				percent = final,
				count = c,
			}
			func(e)
		end
	end
	t.args = {}
	table.insert(t.args, count)
	table.insert(t.args, final)
	-- local time = 0
	-- if bar:getPercent() > final then
	-- 	time = math.abs(bar:getPercent() - final - 100)/25
	-- else
	-- 	time = math.abs(bar:getPercent() - final)/25
	-- end
	t.entry = self:_runExpBar(bar, singletime, count, final, func)
	table.insert(self.actionsArray, t)
end

function scheduleActions:remove(widget)
	local t = self:_clean(widget)
	if t == nil then
		return
	end
	t.widget:getScheduler()
		:unscheduleScriptEntry(t.entry)

	return t.sfunc and t.sfunc()
end

function scheduleActions:_clean(widget)
	for i, v in ipairs(self.actionsArray) do
		if v.widget == widget then
			return table.remove(self.actionsArray, i)
		end
	end
end

return scheduleActions

