local ResGetBackUI = class("ResGetBackUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ResGetBackUI:ctor(key,data,callback,isAll,isCash)
	self.uiIndex = GAME_UI.UI_RES_GET_BACK_CELL
	self.data = data
	self.key = key
	self.callback = callback
	self.isAll = isAll
	self.isCash = isCash
end

function ResGetBackUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
	local bgImg2 = bgImg:getChildByName("bg_img2")
    self:adaptUI(bgImg, bgImg1)
    self:adaptUI(bgImg, bgImg2)
    local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = bgImg1:getChildByName("close_btn")
    local closeBtn1 = bgImg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideResGetBackCellUI()
	    end
	end)
	closeBtn1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideResGetBackCellUI()
	    end
	end)

	local conf = GameData:getConfData("resback")[self.key]
	if conf.backType == 2 then
		bgImg1:setVisible(true)
		bgImg2:setVisible(false)
		local ratios = {conf.freeRadio,conf.cashRadio}
		for i=1,2 do
			local neiBgImg = bgImg1:getChildByName('nei_bg_img_'..i)
			local descTx = neiBgImg:getChildByName('desc_tx')
			descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_TITLE_DESC_'..i))
			local awards = DisplayData:getDisplayObjs(self.data.data.awards)
			local size = neiBgImg:getContentSize()
			local pos = {cc.p(size.width/2 - 50,135),cc.p(size.width/2 + 50,135),cc.p(size.width/2,135)}
			local maxItem = 0
			for i1=1,2 do
				if awards[i1] and math.floor(awards[i1]:getNum() * ratios[i]) > 0 then
					maxItem = maxItem + 1
				end
			end
			for j=1,2 do
				local awardBgImg = neiBgImg:getChildByName('award_bg_img_'..j)
				if awards[j] then
					if not awardBgImg then
						local tab = ClassItemCell:create()
						awardBgImg = tab.awardBgImg
						awardBgImg:setName('award_bg_img_'..j)
						neiBgImg:addChild(awardBgImg)
					end
					if maxItem > 1 then
						awardBgImg:setPosition(pos[j])
					else
						awardBgImg:setPosition(pos[3])
					end
					awardBgImg:setVisible(true)
					awardBgImg:setScale(0.8)
					ClassItemCell:updateItem(awardBgImg, awards[j], 0)
					local lvTx = awardBgImg:getChildByName('lv_tx')
					if not self.isAll or i == 2 then
						lvTx:setString('x'..GlobalApi:toWordsNumber(math.floor(awards[j]:getNum() * ratios[i])))
						if math.floor(awards[j]:getNum() * ratios[i]) <= 0 then
							awardBgImg:setVisible(false)
						end
					else
						local awards1 = DisplayData:getDisplayObjs(self.data.data.awards1)
						lvTx:setString('x'..GlobalApi:toWordsNumber(math.floor(awards1[j]:getNum())))
						if math.floor(awards1[j]:getNum()) <= 0 then
							awardBgImg:setVisible(false)
						end
					end
			    	awardBgImg:addTouchEventListener(function (sender, eventType)
				        if eventType == ccui.TouchEventType.began then
				            AudioMgr.PlayAudio(11)
				        elseif eventType == ccui.TouchEventType.ended then
							GetWayMgr:showGetwayUI(awards[j],false)
				        end
				    end)
				else
					if awardBgImg then
						awardBgImg:setVisible(false)
					end
				end
			end
		end
		local freeBtn = bgImg1:getChildByName('free_get_btn')
		local infoTx = freeBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr("RES_GET_BACK_DESC_8"))
		local cashBtn = bgImg1:getChildByName('get_btn')
		local numTx = cashBtn:getChildByName('num_tx')
		local cash = conf.perCash * self.data.data.remainnum
		numTx:setString(cash)
		freeBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	if self.isAll then
	        		self:getAllBack(0)
	        	else
					self:getBack(0)
				end
	        end
	    end)

		cashBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	if self.isAll then
	        		self:getAllBack(1,cash)
	        	else
					self:getBack(1,cash)
				end
	        end
	    end)
	else
		bgImg1:setVisible(false)
		bgImg2:setVisible(true)
		local neiBgImg = bgImg2:getChildByName('nei_bg_img')
		local descTx = neiBgImg:getChildByName('desc_tx')
		if self.isCash then
			descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_TITLE_DESC_2'))
		else
			descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_TITLE_DESC_1'))
		end
		local awards = DisplayData:getDisplayObjs(self.data.data.awards)
		local size = neiBgImg:getContentSize()
		local pos = {cc.p(size.width/2 - 55,135),cc.p(size.width/2 + 55,135),cc.p(size.width/2,135)}
		for i=1,2 do
			local awardBgImg = neiBgImg:getChildByName('award_bg_img_'..i)
			if awards[i] then
				if not awardBgImg then
					local tab = ClassItemCell:create()
					awardBgImg = tab.awardBgImg
					awardBgImg:setName('award_bg_img_'..i)
					neiBgImg:addChild(awardBgImg)
				end
				if #awards > 1 then
					awardBgImg:setPosition(pos[i])
				else
					awardBgImg:setPosition(pos[3])
				end
				awardBgImg:setVisible(true)
				awardBgImg:setScale(0.8)
				ClassItemCell:updateItem(awardBgImg, awards[i], 0)
				local lvTx = awardBgImg:getChildByName('lv_tx')
				-- lvTx:setString('x'..GlobalApi:toWordsNumber(math.floor(awards[i]:getNum())))
				if self.isCash then
					lvTx:setString('x'..GlobalApi:toWordsNumber(math.floor(awards[i]:getNum() *conf.cashRadio)))
				else
					if self.isAll then
						local awards1 = DisplayData:getDisplayObjs(self.data.data.awards1)
						lvTx:setString('x'..GlobalApi:toWordsNumber(math.floor(awards1[i]:getNum())))
					else
						lvTx:setString('x'..GlobalApi:toWordsNumber(math.floor(awards[i]:getNum() * conf.freeRadio)))
					end
				end
		    	awardBgImg:addTouchEventListener(function (sender, eventType)
			        if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[i],false)
			        end
			    end)
			else
				if awardBgImg then
					awardBgImg:setVisible(false)
				end
			end
		end
		local cashBtn = bgImg2:getChildByName('get_btn')
		local numTx = cashBtn:getChildByName('num_tx')
		local cashImg = cashBtn:getChildByName('cash_img')
		local infoTx = cashBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr("RES_GET_BACK_DESC_8"))
		local cash = conf.perCash * self.data.data.remainnum
		if self.isCash then
			numTx:setString(cash)
			infoTx:setVisible(false)
			cashImg:setVisible(true)
		else
			numTx:setString('')
			infoTx:setVisible(true)
			cashImg:setVisible(false)
		end
		
		cashBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	if self.isCash then
		        	if self.isAll then
		        		self:getAllBack(1,cash)
		        	else
						self:getBack(1,cash)
					end
				else
		        	if self.isAll then
		        		self:getAllBack(0)
		        	else
						self:getBack(0)
					end
				end
	        end
	    end)
	end
end

function ResGetBackUI:getAllBack(isCash,cash)
	local function sendMsg()
		local args = {
			mod = self.key,
			isCash = isCash,
		}
		MessageMgr:sendPost("get_all_award", "resback", json.encode(args), function (jsonObj)
			local data = jsonObj.data
	        if jsonObj.code == 0 then
	            local awards = data.awards
	            local extAwards = data.ext_awards
	            local lastLv = UserData:getUserObj():getLv()
	            if awards then
					local oldLv = UserData:getUserObj():getArenaLv()
	                GlobalApi:parseAwardData(awards)
					local level = UserData:getUserObj():getArenaLv()
					local xp1 = UserData:getUserObj():getArenaXp()
					local xp2 = UserData:getUserObj():getOldArenaXp()
					local showArena 
					if extAwards then
						GlobalApi:parseAwardData(extAwards)
						if level ~= oldLv then
							showArena = function()
								local award = DisplayData:getDisplayObjs(extAwards)
								ArenaMgr:showArenaAward(2,'x'..award[1]:getNum())
							end
						end
					end
					UserData:getUserObj():setOldArenaXp(xp1)
					UserData:getUserObj():setOldArenaLv(level)
	                GlobalApi:showAwardsCommon(awards,true,showArena,false)
	                local nowLv = UserData:getUserObj():getLv()
	                GlobalApi:showKingLvUp(lastLv,nowLv)
	            end
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
	        	if self.callback then
	        		self.callback()
	        		MainSceneMgr:hideResGetBackCellUI()
	        	end
	        end
	    end)
	end
	if isCash == 1 then
        UserData:getUserObj():cost('cash',cash,sendMsg,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cash))
	else
		sendMsg()
	end
end

function ResGetBackUI:getBack(isCash,cash)
	local function sendMsg()
		local args = {
			day = self.data.date,
			mod = self.key,
			isCash = isCash,
		}
		MessageMgr:sendPost("get_award", "resback", json.encode(args), function (jsonObj)
			local data = jsonObj.data
	        if jsonObj.code == 0 then
	            local awards = data.awards
	            local extAwards = data.ext_awards
	            local lastLv = UserData:getUserObj():getLv()
	            if awards then
					local oldLv = UserData:getUserObj():getArenaLv()
	                GlobalApi:parseAwardData(awards)
					local level = UserData:getUserObj():getArenaLv()
					local xp1 = UserData:getUserObj():getArenaXp()
					local xp2 = UserData:getUserObj():getOldArenaXp()
					local showArena 
					if extAwards then
						GlobalApi:parseAwardData(extAwards)
						if level ~= oldLv then
							showArena = function()
								local award = DisplayData:getDisplayObjs(extAwards)
								ArenaMgr:showArenaAward(2,'x'..award[1]:getNum())
							end
						end
					end
					UserData:getUserObj():setOldArenaXp(xp1)
					UserData:getUserObj():setOldArenaLv(level)
	                GlobalApi:showAwardsCommon(awards,true,showArena,false)
	                local nowLv = UserData:getUserObj():getLv()
	                GlobalApi:showKingLvUp(lastLv,nowLv)
	            end
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
	        	if self.callback then
	        		self.callback()
	        		MainSceneMgr:hideResGetBackCellUI()
	        	end
	        end
	    end)
	end
	if isCash == 1 then
        UserData:getUserObj():cost('cash',cash,sendMsg,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cash))
	else
		sendMsg()
	end
end

return ResGetBackUI