local ExpeditionCellUI = class("ExpeditionCellUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}

function ExpeditionCellUI:ctor(id)
	self.uiIndex = GAME_UI.UI_EXPEDITION_CELL
	self.id = id
	self.maxCellCount = 0
	self.page = MapData.cityProcess + 1
end

function ExpeditionCellUI:OnFighting()
	local cityData = MapData.data[self.id]
	-- local needFood = cityData:getFood(1)
	-- local food = UserData:getUserObj():getFood()
	-- if needFood > food then
	-- 	promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_FOOD'), COLOR_TYPE.RED)
	-- 	return
	-- end
	local id = self.id
    local page = self.page
    MapMgr:playBattle(BATTLE_TYPE.NORMAL, id, 1,function()
        MapMgr:showMainScene(2,id,function()
            MapMgr:showExpeditionPanel(id)
        end)
    end,page)
end

function ExpeditionCellUI:getSpine(url,y)
    local spineAni = GlobalApi:createLittleLossyAniByName(url..'_display')
    local shadow = spineAni:getBone(url .. "_display_shadow")
    if shadow then
        shadow:changeDisplayWithIndex(-1, true)
    end
	spineAni:setPosition(cc.p(170,100 + y))
    spineAni:setAnchorPoint(cc.p(0.5,0))
	self.leftImg:addChild(spineAni)
    spineAni:getAnimation():play('idle', -1, 1)
end

function ExpeditionCellUI:updateAward()
	local cityData = MapData.data[self.id]
	local awardsTab = cityData:getPfirstDrop(self.page)
	local index = 0
	for i=1,10 do
		local str = 'award'..i
    	if awardsTab[str] and awardsTab[str][1] then
    		index = index + 1
    		local awardBgImg = self.awardSv:getChildByTag(1000 + index)
    		if not awardBgImg then
			    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			    awardBgImg = tab.awardBgImg
			    self.awardSv:addChild(awardBgImg,1,1000 + index)
			    awardBgImg:setAnchorPoint(cc.p(0,0.5))
			    awardBgImg:setPosition(cc.p((index - 1)*110 + 10,50))
			end
			local award = DisplayData:getDisplayObj(awardsTab[str][1])
			ClassItemCell:updateItem(awardBgImg, award, 2)
			local lvTx = awardBgImg:getChildByName('lv_tx')
			local stype = award:getCategory()
	    	if stype == 'equip' then
	    		lvTx:setString('Lv.'..award:getLevel())
	    	else
	    		lvTx:setString('x'..award:getNum())
	    	end
		    awardBgImg:setTouchEnabled(true)
	    	awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(award,false)
		        end
		    end)
	    end
	end
	if index < self.maxCellCount then
		for i=index + 1,self.maxCellCount do
			local awardBgImg = self.awardSv:getChildByTag(i + 1000)
			if awardBgImg then
				awardBgImg:removeFromParent()
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

function ExpeditionCellUI:updatePanel()
    self:updateAward()
end

function ExpeditionCellUI:init()
	local bgImg = self.root:getChildByName("expedition_bg_img")
	self.expeditionImg = bgImg:getChildByName("expedition_img")
    self:adaptUI(bgImg, self.expeditionImg)
	local closeBtn = self.expeditionImg:getChildByName("close_btn")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.expeditionImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))
	local titleImg = self.expeditionImg:getChildByName("title_img")
	self.cityNameTx = titleImg:getChildByName("city_name_tx")
	local cityData = MapData.data[self.id]
	local keyArr = string.split(cityData:getName() , '.')
	self.cityNameTx:setString(keyArr[#keyArr]..'-'..GlobalApi:getLocalStr('CITY_CELL_NAME_'..self.page))

	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideExpeditionCellPanel()
        end
    end)
    local neiBgImg = self.expeditionImg:getChildByName("nei_bg_img")
    local leftImg = neiBgImg:getChildByName("left_bg_img")
    local talkImg = leftImg:getChildByName("talk_img")
    self.leftImg = leftImg
    leftImg:loadTexture('uires/ui/guard/guard_frame_'..(self.page * 2)..'.png')
    talkImg:loadTexture('uires/ui/battle/bg_talk_'..(4 + self.page)..'.png')
    talkImg:setLocalZOrder(10)
    local descTx = talkImg:getChildByName("desc_tx")
    descTx:setString(GlobalApi:getLocalStr('CITY_CELL_TALK_'..self.page))
    talkImg:setOpacity(0)
    talkImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
    	cc.DelayTime:create(1), 
    	cc.FadeIn:create(0.5),
    	cc.DelayTime:create(3), 
    	cc.FadeOut:create(0.5))))

    local rightPl = neiBgImg:getChildByName("right_pl")
    local bottomImg = rightPl:getChildByName("bottom_bg_img")
    local topImg = rightPl:getChildByName("top_bg_img")
    for i=1,3 do
    	local nameTx = topImg:getChildByName('name_tx_'..i)
    	local signImg = topImg:getChildByName('sign_img_'..i)
    	local cityImg = topImg:getChildByName('city_img_'..i)
    	signImg:setVisible((self.page - 1) >= i)
    	nameTx:setString(GlobalApi:getLocalStr('CITY_CELL_NAME_'..i))

    	if i == self.page then
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
    infoTx:setString(GlobalApi:getLocalStr('BEGIN_FIGHTING'))
    self.awardSv = bottomImg:getChildByName("award_sv")
    self.awardSv:setScrollBarEnabled(false)
    self.fightingBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
	        if BagData:getEquipFull() then
	            promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
	            return
	        end
            self:OnFighting()
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

	local cityData = MapData.data[self.id]
	local pformation = cityData:getPformation1()
	local monsterGroup = pformation[self.page]
	local monsterConf = GameData:getConfData("formation")[monsterGroup]
    local fightforce = 0
    for i=1,9 do
        local posId = monsterConf["pos"..i]
        if posId and posId > 0 then
            fightforce = fightforce + RoleData:CalMonsterFightForce(posId)
        end
    end

	self.forceLabel:setString(fightforce)
	local monsterId = monsterConf['pos'..monsterConf.boss]
	local monsterObj = GameData:getConfData("monster")[monsterId]
    self:getSpine(monsterObj.url,monsterObj.uiOffsetY)

    self:updatePanel()

    local isFirst = false
    for i=1,self.id - 1 do
    	local cityData = MapData.data[i]
    	if #pformation > 0 then
    		isFirst = true
    	end
    end
    if not isFirst and MapData.cityProcess == 0 then
        GuideMgr:startCityOpenGuide(38, 1)
    end
    
    if #pformation == 1 then
        local nameTx = topImg:getChildByName('name_tx_2')
        nameTx:setVisible(false)
        local signImg = topImg:getChildByName('sign_img_2')
        signImg:setVisible(false)
        local cityImg = topImg:getChildByName('city_img_2')
        cityImg:setVisible(false)

        local line1 = topImg:getChildByName('line_img1')
        line1:setVisible(false)
        local line2 = topImg:getChildByName('line_img2')
        line2:setPositionX((topImg:getChildByName('city_img_1'):getPositionX() + topImg:getChildByName('city_img_3'):getPositionX())/2)
    end
end

return ExpeditionCellUI