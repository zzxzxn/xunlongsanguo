local InfiniteBattleUI = class("InfiniteBattleUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function InfiniteBattleUI:ctor(chapterId, id, progress)
	self.uiIndex = GAME_UI.UI_INFINITE_BATTLE
	local infiniteData = UserData:getUserObj():getInfinite()
	self.chapterId = chapterId
	self.id = id
	self.progress = progress
	self.conf = GameData:getConfData("itmain")[chapterId][id]
	self.maxCellCount = 0
	self.cells = {}
end

function InfiniteBattleUI:onFighting()
	local shas = UserData:getUserObj():getShas()
	if shas <= 0 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('SHAS_NOT_ENOUGH'), COLOR_TYPE.RED)
		return
	end
	local infiniteData = UserData:getUserObj():getInfinite()
	local obj = {
		chapterId = self.chapterId,
		cityId = self.id,
		progress = self.progress,
		type = self.conf.isBranch
	}
	local chapterId = self.chapterId
	BattleMgr:playBattle(BATTLE_TYPE.INFINITE_BATTLE, obj, function()
		if InfiniteBattleMgr.nextChapter then
			MainSceneMgr:showMainCity(function()
	            CampaignMgr:showCampaignMain(4, chapterId+1)
	        end, nil, GAME_UI.UI_CAMPAIGN)
		else
			MainSceneMgr:showMainCity(function()
	            CampaignMgr:showCampaignMain(4, chapterId)
	            InfiniteBattleMgr:showInfiniteBattleMain(chapterId)
	        end, nil, GAME_UI.UI_INFINITE_BATTLE_MAIN)
		end
	end)
end

function InfiniteBattleUI:getSpine(url,y)
    local spineAni = GlobalApi:createLittleLossyAniByName(url..'_display')
    local shadow = spineAni:getBone(url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
	spineAni:setPosition(cc.p(195,135 + y))
	self.leftImg:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function InfiniteBattleUI:updateAward()
	local infiniteData = UserData:getUserObj():getInfinite()
	local awardsTab = self.conf['award'..self.progress + 1]
	local awards = DisplayData:getDisplayObjs(awardsTab)
	local index = #awards
	for i,v in ipairs(awards) do
		local awardBgImg = self.awardSv:getChildByTag(1000 + i)
		if not awardBgImg then
		    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, v, self.awardSv)
		    awardBgImg = tab.awardBgImg
		    awardBgImg:setTag(1000 + i)
		    awardBgImg:setAnchorPoint(cc.p(0,0.5))
		    awardBgImg:setPosition(cc.p((i - 1)*110 + 10,50))
		    self.cells[tostring(1000 + i)] = tab
		else
			ClassItemCell:updateItem(self.cells[tostring(1000 + i)], v, 1)
		end
	    local lvTx = awardBgImg:getChildByName('lv_tx')
    	local stype = v:getCategory()
    	if stype == 'equip' then
    		lvTx:setString('Lv.'..v:getLevel())
    	else
    		lvTx:setString('x'..v:getNum())
    	end
    	awardBgImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				GetWayMgr:showGetwayUI(v,false)
	        end
	    end)
	end
	if index < self.maxCellCount then
		for i=index + 1,self.maxCellCount do
			local awardBgImg = self.awardSv:getChildByTag(i + 1000)
			if awardBgImg then
				awardBgImg:removeFromParent()
				self.cells[tostring(1000 + i)] = nil
			end
		end
	end
	self.maxCellCount = index

    local size = self.awardSv:getContentSize()
    if index * 110 + 10 > size.width then
        self.awardSv:setInnerContainerSize(cc.size(index* 110,size.height))
    else
        self.awardSv:setInnerContainerSize(size)
    end
end

function InfiniteBattleUI:updatePanel()
    self:updateAward()
end

function InfiniteBattleUI:init()
	local bgImg = self.root:getChildByName("expedition_bg_img")
	self.expeditionImg = bgImg:getChildByName("expedition_img")
    self:adaptUI(bgImg, self.expeditionImg)
	local closeBtn = self.expeditionImg:getChildByName("close_btn")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.expeditionImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))
	local titleImg = self.expeditionImg:getChildByName("title_img")
	self.cityNameTx = titleImg:getChildByName("city_name_tx")
	self.cityNameTx:setString(self.conf.name)

	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            InfiniteBattleMgr:hideInfiniteBattle()
        end
    end)
    local neiBgImg = self.expeditionImg:getChildByName("nei_bg_img")
    local leftImg = neiBgImg:getChildByName("left_bg_img")
    self.leftImg = leftImg

    local rightPl = neiBgImg:getChildByName("right_pl")
    local bottomImg = rightPl:getChildByName("bottom_bg_img")
    local topImg = rightPl:getChildByName("top_bg_img")
    local infiniteData = UserData:getUserObj():getInfinite()
    for i=1,3 do
    	local nameTx = topImg:getChildByName('name_tx_'..i)
    	local signImg = topImg:getChildByName('sign_img_'..i)
    	local cityImg = topImg:getChildByName('city_img_'..i)
    	local starBgImg = leftImg:getChildByName('star_bg_img_'..i)
    	local starImg = starBgImg:getChildByName('star_img')
    	signImg:setVisible(self.progress >= i)
    	starImg:setVisible(i < (self.progress + 1))
    	nameTx:setString(GlobalApi:getLocalStr('CITY_CELL_NAME_'..i))

    	if i == self.progress + 1 then
	        local sprite = GlobalApi:createSpineByName('map_fight', "spine/map_fight/map_fight", 1)
	        sprite:setPosition(cc.p(cityImg:getPositionX(),signImg:getPositionY() - 2))
	        sprite:setAnimation(0, 'animation', true)
	        sprite:setScale(0.7)
	        topImg:addChild(sprite)
	    end
    end
    local titleBgImg = bottomImg:getChildByName("title_bg_img")
    local infoTx = titleBgImg:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('CITY_CELL_DESC_1'))
    self.fightingBtn = bottomImg:getChildByName("fighting_btn")
    infoTx = self.fightingBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_1'))
    self.awardSv = bottomImg:getChildByName("award_sv")
    self.awardSv:setScrollBarEnabled(false)
    self.fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:onFighting()
        end
    end)

    local zhanBgImg = leftImg:getChildByName('zhan_bg_img')
    local forceLabel = zhanBgImg:getChildByName('fightforce_tx')
    forceLabel:setString('')
    self.forceLabel = cc.LabelAtlas:_create('', "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    self.forceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    self.forceLabel:setPosition(cc.p(130, 22))
    self.forceLabel:setScale(0.7)
    zhanBgImg:addChild(self.forceLabel)

	local monsterGroup = self.conf['fightId'..(self.progress + 1)]
	local monsterConf = GameData:getConfData("formation")[monsterGroup]
	self.forceLabel:setString(monsterConf.fightforce)
	local monsterId = monsterConf['pos'..monsterConf.boss]
	local monsterObj = GameData:getConfData("monster")[monsterId]
    self:getSpine(monsterObj.url,monsterObj.uiOffsetY)

    self:updatePanel()
end

return InfiniteBattleUI