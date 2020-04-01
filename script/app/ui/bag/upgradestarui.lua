local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")

local UpgradeStarUI = class("UpgradeStarUI", BaseUI)

-- 排序:品质>等级>战斗力>id
local function sortByQuality(arr)
    table.sort(arr, function (a, b)
        local q1 = a:getQuality()
        local q2 = b:getQuality()
        if q1 == q2 then
            local l1 = a:getLevel()
            local l2 = b:getLevel()
            if l1 == l2 then
                local f1 = a:getFightForce()
                local f2 = b:getFightForce()
                if f1 == f2 then
                    local id1 = a:getId()
                    local id2 = b:getId()
                    return id1 > id2
                else
                    return f1 < f2
                end
            else
                return l1 < l2
            end
        else
            return q1 < q2
        end
    end)
end

function UpgradeStarUI:ctor(obj,callback)
	self.uiIndex = GAME_UI.UI_UPGRADE_STAR
	self.selectedMap = {}
	self.currObj = obj
	self.awards = {}
	self.selectedArr = {}
	self.selectIndex = 0
	self.callback = callback
end

function UpgradeStarUI:onShow()
	self.selectedMap = {}
	self:updatePanel()
end

function UpgradeStarUI:resetSelectMap()
	self.selectedMap = {}
	self:updatePanel()
end

function UpgradeStarUI:updatePanel()

	print(self.currObj:getBgImg())
	self.selectedEquip.awardBg:loadTexture(self.currObj:getBgImg())
	self.selectedEquip.awardImg:loadTexture(self.currObj:getIcon())
	self.selectedEquip.frameImg:loadTexture(self.currObj:getFrame())
	self.selectedEquip.awardImg:ignoreContentAdaptWithSize(true)
	local level = self.currObj:getGodLevel()
	self.selectedEquip.starLv:setString(level)
	local bgImg = self.root:getChildByName("star_bg_img")
	local starImg = bgImg:getChildByName("star_img")
	for i=1,10 do
		local starBgImg = starImg:getChildByName('star_bg_'..i..'_img')
		local starIcon = starBgImg:getChildByName("star_img")
		starIcon:setVisible(level >= i)
	end

    local currXp = self.currObj:getXp()
    local maxXp = self.currObj:getNextXp()
    local progress = currXp/maxXp*100
    progress = progress > 100 and 100 or progress
    self.bar2:setPercentage(progress)
	self.progressLabel:setString(currXp .. "/" .. maxXp)
	local tab = {}
	for i,v in pairs(self.selectedMap) do
		tab[#tab + 1] = v
	end
	for i,v in ipairs(self.awards) do
		local equip = tab[i]
		if equip then
			print(equip:getBgImg())
			v.awardBg:loadTexture(equip:getBgImg())
			v.awardImg:loadTexture(equip:getIcon())
			v.frameImg:loadTexture(equip:getFrame())
			v.starIcon:setVisible(true)
			local level = equip:getGodLevel()
			v.starLv:setString(level)
			v.awardImg:ignoreContentAdaptWithSize(true)
			currXp = currXp + equip:getXp() + 1
		else
			v.awardImg:loadTexture('uires/ui/common/add_01.png')
			v.frameImg:loadTexture('uires/ui/common/frame_default.png')
			v.awardImg:ignoreContentAdaptWithSize(true)
			v.starIcon:setVisible(false)
		end
	end
    -- for k, v in ipairs(self.selectedArr) do
    --     self.equipArr[self.selectIndex].icon:loadTexture(v:getIcon())
    --     self.equipArr[self.selectIndex].frame:loadTexture(v:getFrame())
    --     self.equipArr[self.selectIndex].starBg:setVisible(true)
    --     self.equipArr[self.selectIndex].starBg:removeAllChildren()
    --     local rightLabel = cc.LabelAtlas:_create(tostring(v:getGodLevel()), "uires/ui/number/xin.png", 12, 18, string.byte('0'))
    --     rightLabel:setAnchorPoint(cc.p(0.5,0.5))
    --     rightLabel:setPosition(cc.p(19,19))
    --     self.equipArr[self.selectIndex].starBg:addChild(rightLabel)
    --     self.selectIndex = self.selectIndex + 1
    -- end

    progress = currXp/maxXp*100
    progress = progress > 100 and 100 or progress
    self.bar1:setPercentage(progress)
    self.bar1:setOpacity(255)
    self.bar1:stopAllActions()
    if self.selectIndex > 0 then
        self.bar1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1), cc.FadeIn:create(1))))
    end
end

function UpgradeStarUI:init()
	local bgImg = self.root:getChildByName("star_bg_img")
	local starImg = bgImg:getChildByName("star_img")
	local closeBtn = starImg:getChildByName("close_btn")
	local autoBtn = starImg:getChildByName("auto_btn")
	local swallowBtn = starImg:getChildByName("swallow_btn")
    self:adaptUI(bgImg, starImg)

    bgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			BagMgr:hideUpgradeStar()
	    end
	end)
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			BagMgr:hideUpgradeStar()
	    end
	end)

	autoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.selectedArr = {}
            local selectedMap = {}
            local equips = {}
            local selectEquipNum = 0
            local equipMap = BagData:getAllEquips()
            for k, v in pairs(equipMap) do
                for k2, v2 in pairs(v) do
                    if v2:getGodId() ~= 0 and v2:getSId() ~= self.currObj:getSId() then
                        if self.selectedMap[v2:getSId()] then
                            selectedMap[v2:getSId()] = v2
                            table.insert(self.selectedArr, v2)
                            selectEquipNum = selectEquipNum + 1
                        else
                            table.insert(equips, v2)
                        end
                    end
                end
            end
            sortByQuality(equips)
            if #equips > 0 then
                for i = 1, 6 - selectEquipNum do
                	if equips[i] then
	                    selectedMap[equips[i]:getSId()] = equips[i]
	                    table.insert(self.selectedArr, equips[i])
	                    self.selectIndex = self.selectIndex + 1
	                end
                end
            end
            self.selectedMap = selectedMap
            self:updatePanel()
	    end
	end)

	swallowBtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectIndex <= 1 then
                -- 当前没有可吞噬的
                print('当前没有可吞噬的')
                return
            end
            if self.currObj:getGodLevel() >= 10 then
                -- 已经满级了
                return
            end
            local needGold = self.currObj:getSwallowCost()
            local currGold = UserData:getUserObj():getGold()
            if currGold < needGold then
                -- 金币不足
                promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
                self.swallowLabel:stopAllActions()
                self.swallowLabel:setScale(1)
                self.swallowLabel:runAction(cc.Sequence:create(cc.ScaleTo:create(0.1, 2), cc.ScaleTo:create(0.1, 1)))
                return
            end
            local sids = {}
            for k, v in pairs(self.selectedMap) do
                table.insert(sids, k)
            end
            local args = {
                eid = self.currObj:getSId(),
                sids = sids
            }
            MessageMgr:sendPost("swallow", "equip", json.encode(args), function (jsonObj)
                print(json.encode(jsonObj))
                local code = jsonObj.code
                if code == 0 then
                    self.selectedMap = {}
                    self.selectedArr = {}
                    self.selectIndex = 0
                    self.currObj:updateGodAttr(jsonObj.data.god, jsonObj.data.xp)
                    GlobalApi:parseAwardData(jsonObj.data.awards)
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    self:updatePanel()
                end
            end)
	    end
	end)
	local size
	for i=1,6 do
		local awardBg = starImg:getChildByName('award_bg_'..i..'_img')
		local awardImg = awardBg:getChildByName('award_img')
		local frameImg = awardBg:getChildByName('frame_img')
		local starIcon = awardBg:getChildByName('star_img')
		local starLv = cc.LabelAtlas:_create('', "uires/ui/number/xin.png", 12, 18, string.byte('0'))
		size = starIcon:getContentSize()
	    starLv:setPosition(cc.p(size.width/2,size.height/2))
	    starLv:setAnchorPoint(cc.p(0.5, 0.5))
	    starIcon:addChild(starLv,1,999)
		self.awards[i] = {awardBg = awardBg,awardImg = awardImg,frameImg = frameImg,starLv = starLv,starIcon = starIcon}
		awardBg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				local selectedMap = {}
	            local equipSelectUI = ClassEquipSelectUI.new(nil,self.selectedMap, 6, 0, 1, 0, function (map)
	                self.selectedMap = map or {}
	                self:updatePanel()
	            end,1)
	            equipSelectUI:showUI()
		    end
		end)
	end
	local awardBg = starImg:getChildByName('equip_bg_img')
	local awardImg = awardBg:getChildByName('award_img')
	local frameImg = awardBg:getChildByName('frame_img')
	local starIcon = awardBg:getChildByName('star_img')
	local starLv = cc.LabelAtlas:_create('', "uires/ui/number/xin.png", 12, 18, string.byte('0'))
    starLv:setPosition(cc.p(size.width/2,size.height/2))
    starLv:setAnchorPoint(cc.p(0.5, 0.5))
    starIcon:addChild(starLv,1,999)
	self.selectedEquip = {awardBg = awardBg,awardImg = awardImg,frameImg = frameImg,starLv = starLv,starIcon = starIcon}

	local progressBg = starImg:getChildByName("progress_bg_img")
    self.bar1 = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/upgrade_star_bar2.png"))
    self.bar1:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.bar1:setMidpoint(cc.p(0, 0))
    self.bar1:setBarChangeRate(cc.p(1, 0))
    self.bar1:setPosition(cc.p(191.5, 17.5))
    self.bar2 = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/upgrade_star_bar1.png"))
    self.bar2:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self.bar2:setMidpoint(cc.p(0, 0))
    self.bar2:setBarChangeRate(cc.p(1, 0))
    self.bar2:setPosition(cc.p(191.5, 17.5))
    progressBg:addChild(self.bar1)
    progressBg:addChild(self.bar2)
    self.progressLabel = progressBg:getChildByName("progress_tx")

	self:updatePanel()
end

return UpgradeStarUI