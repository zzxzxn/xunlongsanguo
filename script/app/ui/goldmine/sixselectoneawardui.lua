local SixSelectOneAwardUI = class("SixSelectOneAwardUI", BaseUI)
local ClassItemCell = require("script/app/global/itemcell")

local FIRST_STEP_TIME = 0.3
local TIME_INTERVAL = 0.01

function SixSelectOneAwardUI:ctor(selectAward, awards)
	self.uiIndex = GAME_UI.UI_SIX_SELECT_ONE_AWARD
	self.selectAward = selectAward
	self.awards = awards
	self.currTime = 0
	self.dt = 0
	self.currLightIndex = 1
	self.schedulerEntryId = 0
end

function SixSelectOneAwardUI:init()
	local bg_img = self.root:getChildByName("bg_img")
    local img = bg_img:getChildByName("img")
    self:adaptUI(bg_img, img)

	local randomAwards = {self.selectAward[1]}
	for i, award in ipairs(self.awards) do
		if award and award[1] then
			local same = true
			for k, v in ipairs(self.selectAward[1]) do
				if tostring(v) ~= tostring(award[1][k]) then
					same = false
					break
				end
			end
			if not same then
				table.insert(randomAwards, award[1])
			end
			if #randomAwards >= 6 then
				break
			end
		end
	end

	local index
	local tmp
	self.selectIndex = 1
	for i = 6, 2, -1 do
		index = math.random(1, i)
		tmp = randomAwards[i]
		randomAwards[i] = randomAwards[index]
		randomAwards[index] = tmp
		if index == self.selectIndex then
			self.selectIndex = i
		end
	end

	local wheel_img = img:getChildByName("wheel_img")
	self.select_light = wheel_img:getChildByName("select_light")
	self.sixPos = {}
	for i = 1, 6 do
		local award_node = wheel_img:getChildByName("award_node_" .. i)
		table.insert(self.sixPos, cc.p(award_node:getPosition()))
		if randomAwards[i] and randomAwards[i][1] then
			local awards = DisplayData:getDisplayObj(randomAwards[i])
	        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, award_node)
	        local godId = awards:getGodId()
	        awards:setLightEffect(cell.awardBgImg)
	        cell.nameTx:setVisible(false)
	        if awards:getObjType() == 'equip' then
	            cell.lvTx:setString('Lv.'..awards:getLevel())
	        end
	        cell.awardBgImg:setTouchEnabled(false)
	    else
	    	local awardBgImg = ccui.ImageView:create("uires/ui/common/frame_default.png")
	    	local info_tx = ccui.Text:create()
	    	info_tx:setAnchorPoint(cc.p(0, 1))
	    	info_tx:setTextAreaSize(cc.size(60, 80))
	    	info_tx:setFontName("font/gamefont.ttf")
		    info_tx:setFontSize(24)
		    info_tx:enableOutline(COLOR_TYPE.BLACK, 1)
    		info_tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		    info_tx:setString(GlobalApi:getLocalStr("THANKS_FOR_PARTICIPATION"))
		    info_tx:setPosition(cc.p(20, 78))
		    awardBgImg:addChild(info_tx)
	    	award_node:addChild(awardBgImg)
	    end
	end

	self.root:registerScriptHandler(function (event)
        if event == "exit" then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
        end
    end)

    self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
		self:update(dt)
    end, 0.05, false)
end

function SixSelectOneAwardUI:update(dt)
	self.currTime = self.currTime + dt
	self.dt = self.dt + dt
	if self.currTime > FIRST_STEP_TIME then
		if self.selectIndex == self.currLightIndex then
			if self.dt > 0.4 then
				if self.schedulerEntryId > 0 then
		            cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
		            self.schedulerEntryId = 0
		        end
				GlobalApi:showAwardsCommon(self.selectAward)
				DigMineMgr:hideSixSelectOneAward()
			end
		else
			if self.dt > TIME_INTERVAL then
				self:changeSelectEffect()
				self.dt = 0
			end
		end
	else
		if self.dt > TIME_INTERVAL then
			self:changeSelectEffect()
			self.dt = 0
		end
	end
end

function SixSelectOneAwardUI:changeSelectEffect()
	self.currLightIndex = self.currLightIndex + 1
	if self.currLightIndex > 6 then
		self.currLightIndex = 1
	end
	self.select_light:setPosition(self.sixPos[self.currLightIndex])
end

return SixSelectOneAwardUI