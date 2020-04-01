local ResGetBackAllUI = class("ResGetBackAllUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ResGetBackAllUI:ctor(data,callback)
	self.uiIndex = GAME_UI.UI_RES_GET_BACK_ALL
	self.data = data
	self.callback = callback
end

function ResGetBackAllUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideResGetBackAllUI()
	    end
	end)

	local scale = 0.74
	local diff = 14
	local function getPos(size,size1,i)
		local h = math.floor((i - 1)/4)
		local w = (i - 1)%4 + 1
		local posY = -(size1.height + diff)*(h + 0.5)*scale
		local posX = (size1.width + diff)*(w - 0.5)*scale + 2.5
		return cc.p(posX,posY)
	end

	for i=1,2 do
		local neiBgImg = bgImg1:getChildByName('nei_bg_img_'..i)
		local titleImg = bgImg1:getChildByName('title_bg_img_'..i)
		local descTx = neiBgImg:getChildByName('desc_tx')
		local cardSv = neiBgImg:getChildByName('card_sv')
		cardSv:setScrollBarEnabled(false)
		local size = cardSv:getContentSize()
		local node = cc.Node:create()
		node:setPosition(cc.p(0,size.height))
		cardSv:addChild(node)
		local titleTx = titleImg:getChildByName('info_tx')
		titleTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_TITLE_ALL_DESC_'..i))
		local awardsTab,cost = self:getAwards(i - 1)
		local awards = DisplayData:getDisplayObjs(awardsTab)
		if descTx then
			descTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_10'))
			descTx:setVisible(#awards <= 0)
		end
		for j,v in ipairs(awards) do
			local awardBgImg = neiBgImg:getChildByName('award_bg_img_'..j)
			if not awardBgImg then
				local tab = ClassItemCell:create()
				awardBgImg = tab.awardBgImg
				awardBgImg:setName('award_bg_img_'..j)
				local size1 = awardBgImg:getContentSize()
				awardBgImg:setPosition(getPos(size,size1,j))
				node:addChild(awardBgImg)
			end
			awardBgImg:setVisible(true)
			awardBgImg:setScale(scale)
            local lvTx = awardBgImg:getChildByName('lv_tx')
			ClassItemCell:updateItem(awardBgImg, v, 0)
			lvTx:setString('x'..GlobalApi:toWordsNumber(v:getNum()))
			if v:getNum() <= 0 then
				awardBgImg:setVisible(false)
			end
			awardBgImg:setSwallowTouches(false)
	    	awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(v,false)
		        end
		    end)
		end
		local buyBtn = neiBgImg:getChildByName('buy_btn')
		local cashImg = buyBtn:getChildByName('cash_img')
		local infoTx = buyBtn:getChildByName('info_tx')
		if cashImg then
			infoTx:setString(cost)
		else
			infoTx:setString(GlobalApi:getLocalStr('RES_GET_BACK_DESC_8'))
		end
		buyBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
		        AudioMgr.PlayAudio(11)
		    elseif eventType == ccui.TouchEventType.ended then
		    	self:getAllBack(i - 1,cost)
		    end
		end)
	end
end

function ResGetBackAllUI:getAwards(ntype)
    local itemTab = {}
    local gemTab = {}
    local materialTab = {}
    local dressTab = {}
    local otherTab = {}
    local remainnum = 0
    local cost = 0
    local conf = GameData:getConfData("resback")
    for i,v in pairs(conf) do
    	if self.data[v.type] and (v.backType == 2 or v.backType == ntype) then
    		local ratio = (ntype == 0) and v.freeRadio or v.cashRadio
    		for k,v1 in pairs(self.data[v.type]) do
    			if v1.isget ~= 1 then
				    for j,v2 in ipairs(v1.awards) do
				        if v2[1] == 'user' then
				            itemTab[v2[2]] = (itemTab[v2[2]] or 0) + math.floor(v2[3]*ratio)
				        elseif v2[1] == 'gem' then
				            gemTab[v2[2]] = (gemTab[v2[2]] or 0) + math.floor(v2[3]*ratio)
				        elseif v2[1] == 'material' then
				            materialTab[v2[2]] = (materialTab[v2[2]] or 0) + math.floor(v2[3]*ratio)
				        elseif v2[1] == 'dress' then
				            dressTab[v2[2]] = (dressTab[v2[2]] or 0) + math.floor(v2[3]*ratio)
				        else
				            otherTab[#otherTab + 1] = {v2[1],v2[2],math.floor(v2[3]*ratio)}
				        end
				    end
				    cost = cost + v1.remainnum*v.perCash
				end
    		end
    	end
    end

    for i,v in pairs(itemTab) do
        otherTab[#otherTab + 1] = {'user',i,tonumber(v)}
    end
    for i,v in pairs(gemTab) do
        otherTab[#otherTab + 1] = {'gem',i,tonumber(v)}
    end
    for i,v in pairs(materialTab) do
        otherTab[#otherTab + 1] = {'material',i,tonumber(v)}
    end
    for i,v in pairs(dressTab) do
        otherTab[#otherTab + 1] = {'dress',i,tonumber(v)}
    end
    -- printall(otherTab)
    return otherTab,cost
end

function ResGetBackAllUI:getAllBack(isCash,cash)
	local function sendMsg()
		local args = {
			isCash = isCash,
		}
		MessageMgr:sendPost("get_oneKey_award", "resback", json.encode(args), function (jsonObj)
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
	                GlobalApi:showAwardsCommon(awards,nil,showArena,false)
	                local nowLv = UserData:getUserObj():getLv()
	                GlobalApi:showKingLvUp(lastLv,nowLv)
	            end
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
	        	if self.callback then
	        		self.callback()
	        		MainSceneMgr:hideResGetBackAllUI()
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

return ResGetBackAllUI