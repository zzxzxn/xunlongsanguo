local ClassItemCell = require('script/app/global/itemcell')

local LordCountrySalaryUI = class("LordCountrySalaryUI", BaseUI)

function LordCountrySalaryUI:ctor(lordCount)
	self.uiIndex = GAME_UI.UI_LORDCOUNTRYSALARY
	self.cityRank = {}
	for i = 1, 3 do
		local obj = {
			id = i,
			count = lordCount[i],
			rank = 1
		}
		table.insert(self.cityRank, obj)
	end
	table.sort(self.cityRank, function (a, b)
		if a.count == b.count then
			return a.id < b.id
		else
			return a.count > b.count
		end
	end)
	local maxCount = self.cityRank[1].count
	for i = 2, 3 do
		if maxCount <= self.cityRank[i].count then
			self.cityRank[i].rank = self.cityRank[i-1].rank
		else
			self.cityRank[i].rank = i
		end
		maxCount = self.cityRank[i].count
	end
end

function LordCountrySalaryUI:init()
	local conf = GameData:getConfData("lordcountrysalary")
    local winsize = cc.Director:getInstance():getWinSize()
    local bg = self.root:getChildByName("bg")
    local bg1 = bg:getChildByName("bg1")
    bg:setPosition(cc.p(winsize.width/2, winsize.height/2))

    local closeBtn = bg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	self:hideUI()
        end
    end)

    local title_bg = bg1:getChildByName("title_bg")
    local title_tx = title_bg:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("LORD_COUNTRY_AWARD"))

    local content = bg1:getChildByName("content")
    local tips_tx = content:getChildByName("tips_tx")
    
    local time = string.format("%02d:00", tonumber(GlobalApi:getGlobalValue("lordCountryBalanceTime")))
    tips_tx:setString(string.format(GlobalApi:getLocalStr("LORD_COUNTRY_AWARD_TIPS"), time))
    for i = 1, 3 do
	    local city = content:getChildByName("city_" .. i)
	    local bg_img = city:getChildByName("bg_img")
	    bg_img:ignoreContentAdaptWithSize(true)
	    bg_img:loadTexture("uires/ui/country/bg_1" .. self.cityRank[i].id ..  ".png")
	    local rank_img = city:getChildByName("rank_img")
	    rank_img:ignoreContentAdaptWithSize(true)
	    rank_img:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. self.cityRank[i].rank .. ".png")
	    local flag_1 = city:getChildByName("flag_1")
	    flag_1:ignoreContentAdaptWithSize(true)
	    flag_1:loadTexture("uires/ui/country/country_flag_" .. self.cityRank[i].id ..  ".png")
	    local flag_2 = city:getChildByName("flag_2")
	    flag_2:ignoreContentAdaptWithSize(true)
	    flag_2:loadTexture("uires/ui/country/country_flag_" .. self.cityRank[i].id .. "_" .. self.cityRank[i].id .. ".png")
	    local info_tx = city:getChildByName("info_tx")
	    info_tx:setString(GlobalApi:getLocalStr("HAVE_LORDS"))
	    local num_tx = city:getChildByName("num_tx")
	    num_tx:setString(tostring(self.cityRank[i].count))
	    local gray_img_1 = city:getChildByName("gray_img_1")
	    local awards = DisplayData:getDisplayObjs(conf[self.cityRank[i].rank].awards)
	    for k, v in ipairs(awards) do
	    	local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, gray_img_1)
	    	cell.awardBgImg:setScale(0.7)
	    	cell.awardBgImg:setPosition(cc.p((k-1)*76 + 40, 42))
	    end
	end
end

return LordCountrySalaryUI