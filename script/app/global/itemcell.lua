local itemCell = {}
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')
local MAX_ATTR_NUM = 8
local MAX_EXCLUSIVE_STAR = 7
local MAX_EXCLUSIVE_TYPE = 4
local DEFAULT_FRAME = 'uires/ui/common/frame_default.png'
local ALPHA = 'uires/ui/common/bg1_alpha.png'
function itemCell:setGodLight(awardBgImg,godType)
	godType = godType or 0
	local size = awardBgImg:getContentSize()
	local effect = awardBgImg:getChildByName('god_light')
	if godType == 3 then
		if not effect then
			effect = GlobalApi:createLittleLossyAniByName('god_light')
			effect:setPosition(cc.p(size.width/2,size.height/2))
			effect:getAnimation():playWithIndex(0, -1, 1)
			effect:setName('god_light')
			effect:setScale(1.25)
			awardBgImg:addChild(effect)
		end
		effect:setVisible(true)
	else
		if effect then
			effect:setVisible(false)
		end
	end
	local selectAni = awardBgImg:getChildByName('godequip_blink')
	if godType > 0 then
		if not selectAni then
			selectAni = GlobalApi:createLittleLossyAniByName("godequip_blink")
			selectAni:getAnimation():playWithIndex(0, -1, 1)
			selectAni:setName('godequip_blink')
			selectAni:setVisible(true)
			selectAni:setPosition(cc.p(size.width/2,size.height/2))
			awardBgImg:addChild(selectAni)
			local function movementFun(armature, movementType, movementID)
				local posX,posY = math.random(14,80),math.random(14,80)
				if movementType == 2 then
					selectAni:setPosition(cc.p(posX,posY))
				end
			end
			selectAni:getAnimation():setMovementEventCallFunc(movementFun)
		else
			selectAni:setVisible(true)
		end
	else
		if effect then
			effect:setVisible(false)
		end
		if selectAni then
			selectAni:setVisible(false)
		end
	end
end

function itemCell:setHeroPromote(root,hid,promote)
	local obj = ClassRoleObj.new(hid,0)
	obj:setPromoted(promote)
	if obj then
		local size = root:getContentSize()
		local goldframeImg = root:getChildByName('ui_jinjiangtouxiang')
		if not goldframeImg then
			goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
			goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
			goldframeImg:getAnimation():playWithIndex(0, -1, 1)
			goldframeImg:setName('ui_jinjiangtouxiang')
			goldframeImg:setVisible(false)
			root:addChild(goldframeImg)
		end
		local promotestarImgs = {}
		for i=1,3 do
			local promotestarImg = ccui.ImageView:create('uires/ui/common/icon_star3.png')
			promotestarImg:setName('promotestar_img_'..i)
			promotestarImg:setVisible(false)
			promotestarImg:setScale(0.8)
			promotestarImg:setLocalZOrder(1)
			root:addChild(promotestarImg)
			promotestarImgs[i] = promotestarImg
		end

		if obj:getObjType() == 'card' and obj:getPosId() > 0 and obj:isJunZhu() == false then
			local promote = obj:getPromoted()
			local lv = 0
			local protype = 0 

			if promote and #promote > 1 then
				protype = promote[1]
				lv = promote[2]
			end
			local promotedconf =obj:getPromotedConf()
			protype = obj:checkPromoteType(protype)
			if protype > 0 then
				local starnum = promotedconf[protype][obj:getProfessionType()*100 +lv]['heroStars']
				if starnum > 0 then
					for i=1,starnum do
						promotestarImgs[i]:setVisible(true)
					end
				else
					for i=1,3 do
						promotestarImgs[i]:setVisible(false)
					end
				end
				if starnum == 1 then
					promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
				elseif starnum == 2 then
					promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
					promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
				elseif starnum == 3 then
					promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
					promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
					promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
				end
				if obj:getQuality() == 7 then
					goldframeImg:setVisible(true)
				end
			end
		end
		root:loadTexture(obj:getBgImg())
	end
end

function itemCell:create(itemType, obj, parent, createStar)
	itemType = itemType or ITEM_CELL_TYPE.ITEM
	local awardBgImg = ccui.ImageView:create('uires/ui/common/frame_default2.png')
	awardBgImg:ignoreContentAdaptWithSize(true)
	awardBgImg:setLocalZOrder(1)
	awardBgImg:setName("award_bg_img")
	local size = awardBgImg:getContentSize()
	awardBgImg:setTouchEnabled(true)

	local awardImg = ccui.ImageView:create()
	awardImg:ignoreContentAdaptWithSize(true)
	awardImg:setPosition(cc.p(size.width/2,size.height/2))
	awardImg:setName('award_img')

	--local lvTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
	local lvTx = ccui.Text:create()
	lvTx:setFontName("font/gamefont.ttf")
	lvTx:setFontSize(20)
	lvTx:setPosition(cc.p(88,15))
	lvTx:setTextColor(COLOR_TYPE.WHITE)
	lvTx:enableOutline(COLOR_TYPE.BLACK, 1)
	lvTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	lvTx:setAnchorPoint(cc.p(1,0.5))
	lvTx:setName('lv_tx')

	--local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 24)
	local nameTx = ccui.Text:create()
	nameTx:setFontName("font/gamefont.ttf")
	nameTx:setFontSize(24)
	nameTx:setPosition(cc.p(size.width/2,-20))
	nameTx:setTextColor(COLOR_TYPE.WHITE)
	nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	nameTx:setAnchorPoint(cc.p(0.5,0.5))
	nameTx:setName('name_tx')

	local upImg = ccui.ImageView:create('uires/ui/common/new_img.png')
	upImg:setPosition(cc.p(21,72))
	upImg:setName('up_img')
	upImg:setVisible(false)

	local addImg = ccui.ImageView:create('uires/ui/common/add_04.png')
	addImg:setPosition(cc.p(size.width/2,size.height/2))
	addImg:setName('add_img')
	addImg:setVisible(false)

	local chipImg = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
	chipImg:setPosition(cc.p(size.width/2,size.height/2))
	chipImg:setName('chip_img')
	chipImg:setScaleX(-1)


	local limitTx = ccui.Text:create()
	limitTx:setFontName("font/gamefont.ttf")
	limitTx:setFontSize(20)
	limitTx:setPosition(cc.p(10,76))
	limitTx:setTextColor(COLOR_TYPE.WHITE)
	limitTx:enableOutline(COLOR_TYPE.RED, 1)
	limitTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	limitTx:setAnchorPoint(cc.p(0,0.5))
	limitTx:setName('limit_tx')

	local doubleImg = ccui.ImageView:create('uires/ui/common/shuangbei.png')
	doubleImg:setPosition(cc.p(75,75))
	doubleImg:setName('double_img')
	doubleImg:setVisible(false)

	--人皇外观时间
	local surfacetimeImg = ccui.ImageView:create('uires/ui/common/common_num_bg.png')
	surfacetimeImg:setPosition(cc.p(size.width-12,size.height-12))
	surfacetimeImg:setName('surfacetime_Img')
	surfacetimeImg:setVisible(false)
	surfacetimeImg:setContentSize(cc.size(44,22))
	surfacetimeImg:setScale9Enabled(true)
	surfacetimeImg:setCapInsets(cc.rect(20, 10, 4, 2))
	surfacetimeImg:setAnchorPoint(cc.p(0.5,0.5))

	local timeTx = ccui.Text:create()
	timeTx:setFontName("font/gamefont.ttf")
	timeTx:setFontSize(16)
	timeTx:setPosition(cc.p(22,11))
	timeTx:setTextColor(COLOR_TYPE.WHITE)
	timeTx:enableOutline(COLOR_TYPE.BLACK, 1)
	timeTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	timeTx:setAnchorPoint(cc.p(0.5,0.5))
	timeTx:setName('timeTx')
	surfacetimeImg:addChild(timeTx)

	awardBgImg:addChild(awardImg)
	awardBgImg:addChild(lvTx)
	awardBgImg:addChild(addImg)
	awardBgImg:addChild(chipImg)
	awardBgImg:addChild(upImg)
	awardBgImg:addChild(nameTx)
	awardBgImg:addChild(limitTx)
	awardBgImg:addChild(doubleImg)
	awardBgImg:addChild(surfacetimeImg)
	
	local tab = {
		awardBgImg = awardBgImg,
		awardImg = awardImg,
		lvTx = lvTx, 
		upImg = upImg, 
		addImg = addImg,
		chipImg = chipImg,
		nameTx = nameTx,
		limitTx = limitTx,
		doubleImg = doubleImg,
		surfacetimeImg = surfacetimeImg
	}

	if createStar then
		local rhombImgs = {}
		for i=1,5 do
			local rhombImg = ccui.ImageView:create('uires/ui/common/rhomb_1.png')
			rhombImg:setName('rhomb_img_'..i)
			rhombImg:setVisible(false)
			rhombImg:setLocalZOrder(1)
			awardBgImg:addChild(rhombImg)
			rhombImgs[i] = rhombImg
		end
		tab.rhombImgs = rhombImgs
	end
	if itemType == ITEM_CELL_TYPE.ITEM then
		local starImg = ccui.ImageView:create('uires/ui/common/icon_xingxing.png')
		local size1 = starImg:getContentSize()
		starImg:setAnchorPoint(cc.p(1,1))
		starImg:setPosition(cc.p(size.width - 5,size.height - 5))
		starImg:setName('star_img')
		--local starLv = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
		local starLv = ccui.Text:create()
		starLv:setFontName("font/gamefont.ttf")
		starLv:setFontSize(18)
		starLv:setPosition(cc.p(1,size1.height/2))
		starLv:setAnchorPoint(cc.p(1, 0.5))
		starLv:enableOutline(COLOR_TYPE.BLACK, 1)
		starLv:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		starLv:setName('star_lv')
		starImg:addChild(starLv)
		starImg:setVisible(false)
		awardBgImg:addChild(starImg)
		tab.starImg = starImg
		tab.starLv = starLv

		if obj then
			if obj:getObjType() == 'fragment' then
				chipImg:setVisible(true)
				chipImg:loadTexture(obj:getChip())
				limitTx:setVisible(false)
				--xyh
				--新增阵营图标：1神、2妖、3人、4佛、5主角

				self:showTypeImg(obj , awardBgImg)


			elseif obj:getObjType() == 'material' and obj.getResCategory and obj:getResCategory() == "equip" then
				chipImg:setVisible(true)
				chipImg:loadTexture(obj:getChip())
				limitTx:setVisible(false)
			elseif obj:getObjType() == "limitmat" then
				chipImg:setVisible(true)
				chipImg:loadTexture(obj:getChip())
				limitTx:setVisible(true)
				limitTx:setString(GlobalApi:getLocalStr('LIMIT_DESC'))
			else
				chipImg:setVisible(false)
				limitTx:setVisible(false)
			end
			if obj:getObjType() == 'card' then
				--xyh
				--新增阵营图标：1神、2妖、3人、4佛、5主角
				self:showTypeImg(obj , awardBgImg)
			end

			if obj:getObjType() == 'equip' then
				if obj.getObj then
					if obj:getObj() and obj:getObj():getGodLevel() > 0 then
						starImg:setVisible(true)
						starLv:setString(obj:getObj():getGodLevel())
					else
						starImg:setVisible(false)
					end
				else
					if obj:getGodLevel() > 0 then
						starImg:setVisible(true)
						starLv:setString(obj:getGodLevel())
					else
						starImg:setVisible(false)
					end
				end
				self:setGodLight(awardBgImg,obj:getGodId())
			elseif obj:getObjType() == 'headframe' then
				lvTx:setVisible(false)
			else
				if obj:getNum() > 0  then
					lvTx:setString('x'..obj:getNum())
				end
			end

			if obj:getObjType() == 'skywing' or obj:getObjType() == 'skyweapon' then
				local timeType = obj:getTimeType()
				local time = obj:getTime()
				print("timeType" ,timeType)
				local timeTx = surfacetimeImg:getChildByName("timeTx")
				if tonumber(timeType) == 1 then
					timeTx:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_17"),time))
				else
					timeTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_18"))
				end
				surfacetimeImg:setVisible(true)
			else
				surfacetimeImg:setVisible(false)
			end

			awardBgImg:loadTexture(obj:getBgImg())
			awardImg:loadTexture(obj:getIcon())
			awardBgImg:setTouchEnabled(true)
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(obj,false)
				end
			end)
			parent:addChild(awardBgImg)
		end
	elseif itemType == ITEM_CELL_TYPE.HERO then  --英雄头像
		local goldframeImg = awardBgImg:getChildByName('ui_jinjiangtouxiang')

		if not goldframeImg then
			goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
			goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
			goldframeImg:getAnimation():playWithIndex(0, -1, 1)
			goldframeImg:setName('ui_jinjiangtouxiang')
			goldframeImg:setVisible(false)
			awardBgImg:addChild(goldframeImg)
			tab.goldframeImg = goldframeImg
		end

		local promotestarImgs = {}
		for i=1,3 do
			local promotestarImg = ccui.ImageView:create('uires/ui/common/icon_star3.png')
			promotestarImg:setName('promotestar_img_'..i)
			promotestarImg:setVisible(false)
			promotestarImg:setScale(0.8)
			promotestarImg:setLocalZOrder(1)
			awardBgImg:addChild(promotestarImg)
			promotestarImgs[i] = promotestarImg
		end
		tab.promotestarImgs = promotestarImgs
		if obj then
			--xyh
			--新增阵营图标：1神、2妖、3人、4佛、5主角
			self:showTypeImg(obj , awardBgImg)

			if obj:getObjType() == 'card' and obj:getPosId() > 0 and obj:isJunZhu() == false then
				local promote = obj:getPromoted()
				local lv = 0
				local protype = 0 

				if promote and #promote > 1 then
					protype = promote[1]
					lv = promote[2]
				end
				local promotedconf =obj:getPromotedConf()
				protype = obj:checkPromoteType(protype)
				if protype > 0 then
					local starnum = promotedconf[protype][obj:getProfessionType()*100 +lv]['heroStars']
					if starnum > 0 then
						for i=1,starnum do
							promotestarImgs[i]:setVisible(true)
						end
					else
						for i=1,3 do
							promotestarImgs[i]:setVisible(false)
						end
					end
					if starnum == 1 then
						promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
					elseif starnum == 2 then
						promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
						promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
					elseif starnum == 3 then
						promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
						promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
						promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
					end
					if obj:getQuality() == 7 then
						goldframeImg:setVisible(true)
					end
				end
			end
			awardBgImg:loadTexture(obj:getBgImg())
			awardImg:loadTexture(obj:getIcon())
			awardBgImg:setTouchEnabled(true)
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(obj,false)
				end
			end)
			parent:addChild(awardBgImg)
		end
	elseif itemType == ITEM_CELL_TYPE.HEADPIC then
		local headframeImg = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
		headframeImg:setPosition(cc.p(size.width/2,size.height/2))
		headframeImg:setName('headframeImg')
		headframeImg:setVisible(true)
		awardBgImg:addChild(headframeImg)
		tab.headframeImg = headframeImg
		tab.lvTx:setLocalZOrder(1)
	elseif itemType == ITEM_CELL_TYPE.SKILL then
	else
	end

	if obj and awardBgImg then
		self:updateExclusiveStar(awardBgImg,obj)
	end

	return tab
end

function itemCell:updateHero(tabOrRoot, obj, updateType)

	local promotestarImgs
	local goldframeImg
	local awardBgImg
	local awardImg
	local lvTx
	if updateType == 1 then
		promotestarImgs = tabOrRoot.promotestarImgs
		goldframeImg = tabOrRoot.goldframeImg
		awardBgImg = tabOrRoot.awardBgImg
		awardImg = tabOrRoot.awardImg
	else
		promotestarImgs = {}
		for i=1,3 do
			promotestarImgs[i] = tabOrRoot:getChildByName('promotestar_img_' .. i)
		end
		goldframeImg = tabOrRoot:getChildByName("gold_frame_img")
		awardBgImg = tabOrRoot
		awardImg = tabOrRoot:getChildByName("award_img")
	end
	if not goldframeImg then
		goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
		local size = awardBgImg:getContentSize()
		goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
		goldframeImg:getAnimation():playWithIndex(0, -1, 1)
		goldframeImg:setName('ui_jinjiangtouxiang')
		goldframeImg:setVisible(false)
		tabOrRoot:addChild(goldframeImg)
	end


	if obj:getObjType() == 'card' and obj:getPosId() > 0 and obj:isJunZhu() == false then
		self:showTypeImg(obj , awardBgImg)
		local promote = obj:getPromoted()
		local lv = 0
		local protype = 0 

		if promote and #promote > 1 then
			protype = promote[1]
			lv = promote[2]
		end
		local promotedconf =obj:getPromotedConf()
		protype = obj:checkPromoteType(protype)
		if protype > 0 then
			local starnum = promotedconf[protype][obj:getProfessionType()*100+lv]['heroStars']
			if starnum > 0 then
				for i=1,starnum do
					promotestarImgs[i]:setVisible(true)
				end
			else
				for i=1,3 do
					promotestarImgs[i]:setVisible(false)
				end
			end
			local size = awardBgImg:getContentSize()
			if starnum == 1 then
				promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
			elseif starnum == 2 then
				promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
				promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
			elseif starnum == 3 then
				promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
				promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
				promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
			end
			if obj:getQuality() == 7 then
				goldframeImg:setVisible(true)
			end
		end

	else
		for i=1,3 do
			promotestarImgs[i]:setVisible(false)
		end
		goldframeImg:setVisible(false)
	end
	awardBgImg:loadTexture(obj:getBgImg())
	awardImg:loadTexture(obj:getIcon())


end

function itemCell:updateItem(tabOrRoot, obj, updateType)
	local chipImg
	local starImg
	local awardBgImg
	local awardImg
	local lvTx
	local limitTx
	local surfacetimeImg
	



	if updateType == 1 then
		chipImg = tabOrRoot.chipImg
		starImg = tabOrRoot.starImg
		awardBgImg = tabOrRoot.awardBgImg
		awardImg = tabOrRoot.awardImg
		lvTx = tabOrRoot.lvTx
		limitTx = tabOrRoot.limitTx
		surfacetimeImg = tabOrRoot.surfacetimeImg
	else
		chipImg = tabOrRoot:getChildByName("chip_img")
		starImg = tabOrRoot:getChildByName("star_img")
		awardBgImg = tabOrRoot
		awardImg = tabOrRoot:getChildByName("award_img")
		lvTx = tabOrRoot:getChildByName("lv_tx")
		limitTx = tabOrRoot:getChildByName('limit_tx')
		surfacetimeImg = tabOrRoot:getChildByName('surfacetime_Img')
	end
	if obj:getObjType() == 'fragment' then
		chipImg:setVisible(true)
		limitTx:setVisible(false)
		chipImg:loadTexture(obj:getChip())
	elseif obj:getObjType() == 'material' and obj.getResCategory and obj:getResCategory() == "equip" then
		chipImg:setVisible(true)
		limitTx:setVisible(false)
		chipImg:loadTexture(obj:getChip())
	elseif obj:getObjType() == "limitmat" then
		chipImg:setVisible(false)
		limitTx:setVisible(true)
		limitTx:setString(GlobalApi:getLocalStr('LIMIT_DESC'))
	else
		chipImg:setVisible(false)
		limitTx:setVisible(false)
	end
	if obj:getObjType() == 'equip' then
		if obj.getObj then
			if obj:getObj() and obj:getObj():getGodLevel() > 0 then
				starImg:setVisible(true)
				local starLv = starImg:getChildByName("star_lv")
				starLv:setString(obj:getObj():getGodLevel())
			else
				starImg:setVisible(false)
			end
		else
			if obj:getGodLevel() > 0 then
				starImg:setVisible(true)
				local starLv = starImg:getChildByName("star_lv")
				starLv:setString(obj:getGodLevel())
			else
				starImg:setVisible(false)
			end
		end
		self:setGodLight(awardBgImg, obj:getGodId())
		lvTx:setVisible(false)
	elseif obj:getObjType() == 'headframe' then
		lvTx:setVisible(false)
	else
		starImg:setVisible(false)
		if obj:getNum() > 0  then
			lvTx:setVisible(true)
			lvTx:setString('x'..obj:getNum())
		else
			lvTx:setVisible(false)
		end
	end
	if obj:getObjType() == 'skywing' or obj:getObjType() == 'skyweapon' then
		local timeType = obj:getTimeType()
		local time = obj:getTime()
		local timeTx = surfacetimeImg:getChildByName("timeTx")
		if tonumber(timeType) == 1 then
			timeTx:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_17"),time))
		else
			timeTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_18"))
		end
		surfacetimeImg:setVisible(true)
	else
		surfacetimeImg:setVisible(false)
	end


	awardBgImg:loadTexture(obj:getBgImg())
	awardImg:loadTexture(obj:getIcon())


	if updateType == 2 and obj:getObjType() == "card" then
		--xyh
		--新增阵营图标：1神、2妖、3人、4佛、5主角
		self:showTypeImg(obj , awardBgImg)
	end



	if obj and awardBgImg then
		self:updateExclusiveStar(awardBgImg,obj)
	end
end

function itemCell:updateAwardLvTx(node,obj,param)
	local lvTx = node:getChildByName('lv_tx')
	if not obj or param.showLvTx == false then
		if lvTx then
			lvTx:setVisible(false)
		end
		return
	end
	local str = param.lvTxStr or ''
	if not param.lvTxStr then
		if obj:getObjType() == 'equip' or obj:getObjType() == 'card' then
			str = 'Lv.'..obj:getLevel()
		else
			str = 'x'..obj:getNum()
		end
	end
	local lvTx = self:updateTextlabel(node,str,nil,20,'lv_tx',nil,cc.p(88,15),nil,nil,nil,nil,cc.p(1,0.5))
	lvTx:setLocalZOrder(1)
end

function itemCell:updateAwardNameTx(node,obj,param)
	local nameTx = node:getChildByName('name_tx')
	if not obj or not param.showNameTx then
		if nameTx then
			nameTx:setVisible(false)
		end
		return
	end
	local size = node:getContentSize()
	self:updateTextlabel(node,obj:getName(),nil,param.nameTxFontSize or 24,'name_tx',nil,
		param.nameTxPos or cc.p(size.width/2,-20),obj:getNameColor(),obj:getNameOutlineColor(),
		nil,nil,param.nameTxAnchorPoint or cc.p(0.5,0.5))
end

function itemCell:updateAwardUpImg(node,obj,param)
	local upImg = node:getChildByName('up_img')
	if not param.showUpImg then
		if upImg then
			upImg:setVisible(false)
		end
		return
	end
	self:updateImageView(node,'uires/ui/common/new_img.png','up_img',nil,nil,param.upImgPos or cc.p(21,72))
end

function itemCell:updateAwardAddImg(node,obj,param)
	local addImg = node:getChildByName('add_img')
	if not param.showAddImg then
		if addImg then
			addImg:setVisible(false)
		end
		return
	end
	local size = node:getContentSize()
	self:updateImageView(node,param.addImgUrl or 'uires/ui/common/add_04.png','add_img',nil,nil,cc.p(size.width/2,size.height/2))
end

function itemCell:updateAwardChipImg(node,obj,param)
	local chipImg = node:getChildByName('chip_img')
	if obj and (obj:getObjType() == 'fragment' or (obj:getObjType() == 'material' and obj:getResCategory() == 'equip')) then
		local size = node:getContentSize()
		chipImg = self:updateImageView(node,obj:getChip(),'chip_img',nil,nil,cc.p(size.width/2,size.height/2))
		chipImg:setScaleX(-1)
	else
		if chipImg then
			chipImg:setVisible(false)
		end
	end
end

function itemCell:updateAwardLitmitTx(node,obj,param)
	local limitTx = node:getChildByName('limit_tx')
	if not param.limitTxStr and (not obj or obj:getObjType() ~= 'limitmat') then
		if limitTx then
			limitTx:setVisible(false)
		end
		return
	end
	self:updateTextlabel(node,param.limitTxStr or GlobalApi:getLocalStr('LIMIT_DESC'),"font/gamefont.ttf",20,'limit_tx',nil,
		cc.p(10,76),nil,COLOR_TYPE.RED,nil,nil,cc.p(0,0.5))
end

function itemCell:updateAwardDoubleImg(node,obj,param)
	local doubleImg = node:getChildByName('double_img')
	if not param.showDoubleImg then
		if doubleImg then
			doubleImg:setVisible(false)
		end
		return
	end
	self:updateImageView(node,'uires/ui/common/shuangbei.png','double_img',nil,nil,cc.p(75,75))
end

function itemCell:updateAwardSurfacetimeImg(node,obj,param)
	local surfacetimeImg = node:getChildByName('surfacetime_Img')
	if not obj or (obj:getObjType() ~= 'skywing' and obj:getObjType() ~= 'skyweapon') then
		if surfacetimeImg then
			surfacetimeImg:setVisible(false)
		end
		return
	end
	local size = node:getContentSize()
	surfacetimeImg = self:updateImageView(node,'uires/ui/common/common_bg_34.png','surfacetime_Img',nil,nil,cc.p(size.width-20,size.height-14))
	local timeType = obj:getTimeType()
	local time = obj:getTime()
	local str = ''
	if tonumber(timeType) == 1 then
		str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_17"),time)
	else
		str = GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_18")
	end
	self:updateTextlabel(surfacetimeImg,str,nil,16,'time_tx',nil,cc.p(22,11))
end

function itemCell:updateAwardRhombImg(node,obj,param)
	if not param.showRhombImg then
		for i=1,5 do
			local rhombImg = node:getChildByName('rhomb_img_'..i)
			if rhombImg then
				rhombImg:setVisible(false)
			end
		end
		return
	end
	local pos = {
		[1] = {cc.p(48,91)},
		[2] = {cc.p(40,91),cc.p(56,91)},
		[3] = {cc.p(32,91),cc.p(48,91),cc.p(64,91)},
		[4] = {cc.p(24,91),cc.p(40,91),cc.p(56,91),cc.p(72,91)},
	}
	for i=1,5 do
		if i <= param.rhombPosNum then
			self:updateImageView(node,'uires/ui/common/rhomb_'..param.rhombType..'.png','rhomb_img_'..i,1,nil,pos[param.rhombPosNum][i])
		else
			local rhombImg = node:getChildByName('rhomb_img_'..i)
			if rhombImg then
				rhombImg:setVisible(false)
			end
		end
	end
end

function itemCell:updateAwardStarImg(node,obj,param)
	local starImg = node:getChildByName('star_img')
	if not obj or obj:getObjType() ~= 'equip' or param.showStarImg == false then
		if starImg then
			starImg:setVisible(false)
		end
		return
	end
	local size = node:getContentSize()
	starImg = self:updateImageView(node,'uires/ui/common/icon_xingxing.png','star_img',nil,nil,cc.p(size.width - 5,size.height - 5),cc.p(1,1))
	local num = 0
	if obj.getObj then
		if obj:getObj() and obj:getObj():getGodLevel() > 0 then
			num = obj:getObj():getGodLevel()
		end
	else
		if obj:getGodLevel() > 0 then
			num = obj:getGodLevel()
		end
	end
	if num > 0 then
		local size1 = starImg:getContentSize()
		self:updateTextlabel(starImg,num,nil,18,'star_lv',nil,cc.p(1,size1.height/2),nil,nil,nil,nil,cc.p(1,0.5))
	else
		if starImg then
			starImg:setVisible(false)
		end
	end
end

function itemCell:updateAwardGoldframeImg(node,obj,param)
	local goldframeImg = node:getChildByName('ui_jinjiangtouxiang')
	local size = node:getContentSize()
	if obj and obj:getObjType() == 'card' and obj.getPosId and obj:getPosId() > 0 and obj:isJunZhu() == false then
		local promote = obj:getPromoted()
		local lv = 0
		local protype = 0

		if promote and #promote > 1 then
			protype = promote[1]
			lv = promote[2]
		end
		local promotedconf =obj:getPromotedConf()
		protype = obj:checkPromoteType(protype)
		if protype > 0 then
			local promotestarImgs = {}
			for i=1,3 do
				local promotestarImg = self:updateImageView(node,'uires/ui/common/icon_star3.png','promotestar_img_'..i,1)
				promotestarImg:setVisible(false)
				promotestarImg:setScale(0.8)
				promotestarImgs[i] = promotestarImg
			end
			local starnum = promotedconf[protype][obj:getProfessionType()*100+lv]['heroStars']
			if starnum > 0 then
				for i=1,starnum do
					promotestarImgs[i]:setVisible(true)
				end
			else
				for i=1,3 do
					promotestarImgs[i]:setVisible(false)
				end
			end
			local size = node:getContentSize()
			if starnum == 1 then
				promotestarImgs[1]:setPosition(cc.p(size.width/2,5))
			elseif starnum == 2 then
				promotestarImgs[1]:setPosition(cc.p(size.width/2-15,5))
				promotestarImgs[2]:setPosition(cc.p(size.width/2+15,5))
			elseif starnum == 3 then
				promotestarImgs[1]:setPosition(cc.p(size.width/2-25,5))
				promotestarImgs[2]:setPosition(cc.p(size.width/2,5))
				promotestarImgs[3]:setPosition(cc.p(size.width/2+25,5))
			end
			if obj:getQuality() == 7 then
				if not goldframeImg then
					goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
					goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
					goldframeImg:getAnimation():playWithIndex(0, -1, 1)
					goldframeImg:setName('ui_jinjiangtouxiang')
					node:addChild(goldframeImg)
				else
					goldframeImg:setVisible(true)
				end
			end
		end
	else
		for i=1,3 do
			local promotestarImg = node:getChildByName('promotestar_img_'..i)
			if promotestarImg then
				promotestarImg:setVisible(false)
			end
		end
		if goldframeImg then
			goldframeImg:setVisible(false)
		end
	end
end

function itemCell:updateAwardHeadframeImg(node,obj,param)
	local headframeImg = node:getChildByName('headframeImg')
	if not param.showHeadframeImg then
		if headframeImg then
			headframeImg:setVisible(false)
		end
		return
	end
	local size = node:getContentSize()
	self:updateImageView(node,param.headframeImgUrl,'headframeImg',nil,nil,cc.p(size.width/2,size.height/2))
end

function itemCell:updateAwardLight(node,obj,param)
	if not obj then
		self:setGodLight(node)
		GlobalApi:setLightEffect(node,0)
	else
		local godId
		if obj:getObjType() == 'equip' then
			godId = obj:getGodId()
		end
		self:setGodLight(node,godId)
		obj:setLightEffect(node)
	end
end

function itemCell:updateAwardBgImg(node,obj,param)
	local awardBgImg = node:getChildByName(param.bgName or 'award_bg_img')
	if not awardBgImg then
		awardBgImg = self:updateImageView(node,param.bgUrl or (obj and obj:getBgImg() or DEFAULT_FRAME),param.bgName or 'award_bg_img',
			1,param.bgTouchEnaled == false and false or true,param.bgPos)
	else
		awardBgImg:loadTexture(param.bgUrl or (obj and obj:getBgImg() or DEFAULT_FRAME))
		if param.bgPos then
			awardBgImg:setPosition(param.bgPos)
		end
	end
	awardBgImg:setVisible(true)
	if param.bgScale then
		awardBgImg:setScale(param.bgScale)
	end
	local size = awardBgImg:getContentSize()
	self:updateImageView(awardBgImg,param.awardImgUrl or (obj and obj:getIcon() or ALPHA),'award_img',nil,nil,cc.p(size.width/2,size.height/2))

	return awardBgImg
end
--[[
	param = {
		-- 参数字段					-- 字段介绍							-- 默认
		bgName : 					awardBgImg 的名字 					('award_bg_img')
		bgUrl : 					awardImg 的资源 					(DEFAULT_FRAME)
		bgScale : 					awardBgImg 缩放 					(1)
		bgTouchEnaled : 			awardBgImg 是否可点击 				(可点击)
		bgPos : 					awardBgImg 的坐标 					(cc.p(0,0))
		awardImgUrl : 				awardImg 的资源 					('uires/ui/common/bg1_alpha.png')
		showLvTx : 					lvTx 是否显示  						(显示)
		lvTxStr : 					lvTx 文字  							(按道具显示)
		showNameTx : 				nameTx 是否显示 					(不显示)
		nameTxPos : 				nameTx 的坐标						(size.width/2,-20)
		nameTxFontSize : 			nameTx 的文字大小					(24)
		nameTxAnchorPoint : 		nameTx的锚点						(cc.p(0.5,0.5))
		showUpImg : 				upImg 是否显示 						(不显示)
		showStarImg : 				starImg 是否显示 					(显示)
		upImgPos :   				upImg 的坐标						(cc.p(21,72))
		showAddImg : 				addImg 是否显示 					(不显示)
		addImgUrl : 				addImg 的资源 						('uires/ui/common/add_04.png')
		addImgPos :   				addImg 的坐标						(cc.p(size.width/2,size.height/2))
		limitTxStr :   				limitTx 的特殊文字					(GlobalApi:getLocalStr('LIMIT_DESC'))
		showDoubleImg :				doubleImg 是否显示					(不显示)
		showRhombImg :				rhombImg 是否显示					(不显示)
		rhombPosNum :				rhombImg 显示数量					()
		rhombType :					rhombImg 显示类型					()
		showHeadframeImg			headframeImg 是否显示				(不显示)
		headframeImgUrl				headframeImg 资源					()
	}
]]--

function itemCell:updateAwardFrameByObj(node,obj,param)
	-- 道具背景，道具图片
	local awardBgImg = self:updateAwardBgImg(node,obj,param)
	-- 武器等级 数量
	self:updateAwardLvTx(awardBgImg,obj,param)
	-- 名字
	self:updateAwardNameTx(awardBgImg,obj,param)
	-- 箭头
	self:updateAwardUpImg(awardBgImg,obj,param)
	-- 加号
	self:updateAwardAddImg(awardBgImg,obj,param)
	-- 碎片图片
	self:updateAwardChipImg(awardBgImg,obj,param)
	-- 限时
	self:updateAwardLitmitTx(awardBgImg,obj,param)
	-- 人皇限时
	self:updateAwardSurfacetimeImg(awardBgImg,obj,param)
	-- 精炼
	self:updateAwardRhombImg(awardBgImg,obj,param)
	-- 神器星星
	self:updateAwardStarImg(awardBgImg,obj,param)
	-- 金将
	self:updateAwardGoldframeImg(awardBgImg,obj,param)
	-- 头像框
	self:updateAwardHeadframeImg(awardBgImg,obj,param)
	-- 光效
	self:updateAwardLight(awardBgImg,obj,param)
	-- 宝物星星
	self:updateExclusiveStar(awardBgImg,obj,param)
    -- 双倍图片
    self:updateAwardDoubleImg(awardBgImg,obj,param)

	return awardBgImg
end

function itemCell:updateTextlabel(node,str,ttf,fontSize,name,maxLineWidth,pos,fontColor,fontOutline,fontOutlineSize,shadow,anchorPoint,noAll)
	local label
	local needCreate = true
	if name and node then
		label = node:getChildByName(name)
		if label then
			needCreate = false
		end
	end
	if needCreate then
		label = ccui.Text:create(str or "", ttf or "font/gamefont.ttf",fontSize or 20)
	elseif str then
		label:setString(str)
		if fontSize then
			label:setFontSize(fontSize)
		end
	end
	if pos then
		label:setPosition(pos)
	end
	if maxLineWidth then
		label:setMaxLineWidth(maxLineWidth)
	end
	if name then
		label:setName(name)
	end
	if not noAll then
		label:setColor(fontColor or COLOR_TYPE.WHITE)
		label:enableOutline(fontOutline or COLOROUTLINE_TYPE.WHITE, fontOutlineSize or 1)
		label:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
	end
	if anchorPoint then
		label:setAnchorPoint(anchorPoint)
	end
	if node and needCreate then
		node:addChild(label)
	end
	label:setVisible(true)
	return label
end

function itemCell:updateTTFlabel(node,str,ttf,fontSize,name,maxLineWidth,pos,fontColor,fontOutline,fontOutlineSize,shadow,anchorPoint,noAll)
	local label
	local needCreate = true
	if name and node then
		label = node:getChildByName(name)
		if label then
			needCreate = false
		end
	end
	if needCreate then
		label = cc.Label:createWithTTF(str or "", ttf or "font/gamefont.ttf",fontSize or 20)
	elseif str then
		label:setString(str)
	end
	if pos then
		label:setPosition(pos)
	end
	if maxLineWidth then
		label:setMaxLineWidth(maxLineWidth)
	end
	if name then
		label:setName(name)
	end
	if not noAll then
		label:setColor(fontColor or COLOR_TYPE.WHITE)
		label:enableOutline(fontOutline or COLOROUTLINE_TYPE.WHITE, fontOutlineSize or 1)
		label:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
	end
	if anchorPoint then
		label:setAnchorPoint(anchorPoint)
	end
	if node and needCreate then
		node:addChild(label)
	end
	label:setVisible(true)
	return label
end

function itemCell:updateImageView(node,url,name,order,touchEnabled,pos,anchorPoint)
	local imageView
	local needCreate = true
	if name and node then
		imageView = node:getChildByName(name)
		if imageView then
			needCreate = false
		end
	end
	if needCreate then
		imageView = ccui.ImageView:create(url)
	elseif url then
		imageView:loadTexture(url)
	end
	imageView:ignoreContentAdaptWithSize(true)
	if order then
		imageView:setLocalZOrder(order)
	end
	if name then
		imageView:setName(name)
	end
	if touchEnabled then
		imageView:setTouchEnabled(touchEnabled)
	end
	if anchorPoint then
		imageView:setAnchorPoint(anchorPoint)
	end
	if pos then
		imageView:setPosition(pos)
	end
	if node and needCreate then
		node:addChild(imageView)
	end
	imageView:ignoreContentAdaptWithSize(true)
	imageView:setVisible(true)
	return imageView
end

function itemCell:updateExclusiveStar(node,obj)
	if not obj or obj:getObjType() ~= 'exclusive' then
		for i=1,MAX_EXCLUSIVE_STAR do
			local starImg = node:getChildByName('star_img_'..i)
			if starImg then
				starImg:setVisible(false)
			end
		end
		return
	end
	local level = obj:getLevel()
	local url = obj:getStarUrl()
	local size = node:getContentSize()
	for i=1,MAX_EXCLUSIVE_STAR do
		local starImg = node:getChildByName('star_img_'..i)
		if i <= level then
			if not starImg then
				starImg = self:updateImageView(node,url,'star_img_'..i)
				starImg:setPosition(cc.p(5,15 + (size.height - 30)/6*(i - 1)))
			else
				starImg:loadTexture(url)
			end
			starImg:setVisible(true)
		else
			if starImg then
				starImg:setVisible(false)
			end
		end
	end
end

function itemCell:updateExclusive(node,obj,bgName,isLv,isName,isDesc,showType)
	local awardBgImg
	if bgName then
		awardBgImg = node:getChildByName(bgName)
	else
		awardBgImg = node:getChildByName('award_bg_img')
	end
	if not awardBgImg then
		awardBgImg = self:updateImageView(node,obj:getBgImg(),bgName or 'award_bg_img',1,true)
		local size = awardBgImg:getContentSize()
		self:updateImageView(awardBgImg,obj:getIcon(),'award_img',nil,nil,cc.p(size.width/2,size.height/2))
		if isLv then
			local num = obj:getNum() > 0 and 'x'..obj:getNum() or ''
			self:updateTTFlabel(awardBgImg,num,"font/gamefont.ttf",20,'lv_tx',nil,cc.p(88,15),nil,nil,nil,nil,cc.p(1,0.5))
		end
		if isName then
			self:updateTTFlabel(awardBgImg,obj:getName(),"font/gamefont.ttf",25,'name_tx',nil,
			cc.p(105,70),obj:getNameColor(),obj:getNameOutlineColor(),nil,nil,cc.p(0,0.5))
		end
		if isDesc then
			self:updateTTFlabel(awardBgImg,GlobalApi:getLocalStr('SOLDIER_DESC_2')..GlobalApi:getLocalStr('EXCLUSIVE_TYPE_'..obj:getType()),
			"font/gamefont.ttf",24,'desc_tx',nil,cc.p(105,30),nil,nil,nil,nil,cc.p(0,0.5))
		end
		if showType then
			local equipImg = self:updateImageView(awardBgImg,'uires/ui/text/tx_green_bg.png','equip_img',nil,nil,cc.p(240,size.height/2 + 20))
			local size = equipImg:getContentSize()
			local infoTx = self:updateTTFlabel(equipImg,GlobalApi:getLocalStr('EXCLUSIVE_EQUIP_DESC_'..showType),"font/gamefont.ttf",25,'info_tx',nil,cc.p(55,40),nil,nil,nil,nil,nil,true)
			infoTx:setSkewX(-23.31)
			infoTx:setSkewY(23.31)
			equipImg:setSkewX(45)
			equipImg:setSkewY(-45)
			equipImg:setScale(0.5)
		end
	else
		local size = awardBgImg:getContentSize()
		local awardImg = awardBgImg:getChildByName('award_img')
		awardBgImg:loadTexture(obj:getBgImg())
		awardImg:loadTexture(obj:getIcon())
		local lvTx = awardBgImg:getChildByName('lv_tx')
		local nameTx = awardBgImg:getChildByName('name_tx')
		local descTx = awardBgImg:getChildByName('desc_tx')
		local equipImg = awardBgImg:getChildByName('equip_img')
		if isLv then
			local num = obj:getNum() > 0 and 'x'..obj:getNum() or ''
			lvTx:setString(num)
			lvTx:setVisible(true)
		else
			if lvTx then
				lvTx:setVisible(false)
			end
		end
		if isName then
			nameTx:setString(obj:getName())
			nameTx:setColor(obj:getNameColor())
			nameTx:enableOutline(obj:getNameOutlineColor(),1)
			nameTx:setVisible(true)
		else
			if nameTx then
				nameTx:setVisible(false)
			end
		end
		if isDesc then
			descTx:setString(GlobalApi:getLocalStr('SOLDIER_DESC_2')..GlobalApi:getLocalStr('EXCLUSIVE_TYPE_'..obj:getType()))
			descTx:setVisible(true)
		else
			if descTx then
				descTx:setVisible(false)
			end
		end
		if showType then
			local infoTx = equipImg:getChildByName('info_tx')
			infoTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_EQUIP_DESC_'..showType))
			equipImg:setVisible(true)
		else
			if equipImg then
				equipImg:setVisible(false)
			end
		end
	end
	self:updateExclusiveStar(awardBgImg,obj)
	return awardBgImg
end

function itemCell:createDescInfo(node,diff,diffSize,maxWidth,obj)
	local diffHeight = 6
	local desc = obj:getDesc()
	local descLineImg = node:getChildByName('desc_line_img')
	local descTitleTx = node:getChildByName('desc_title_tx')
	local descSkillTilteTx = node:getChildByName('desc_skill_tilte_tx')
	if desc then
		if not descLineImg then
			descLineImg = self:updateImageView(node,'uires/ui/common/common_tiao_4.png','desc_line_img')
			descLineImg:setScale9Enabled(true)
			descLineImg:setContentSize(cc.size(maxWidth,descLineImg:getContentSize().height))
		end
		diff = diff + descLineImg:getContentSize().height/2
		descLineImg:setPosition(cc.p(maxWidth/2,-diff))

		diff = diff + diffHeight
		if not descTitleTx then
			descTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_DESC_12'),"font/gamefont.ttf",24,'desc_title_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.ORANGE,
				nil,nil,nil,cc.p(0,1))
		else
			descTitleTx:setPosition(cc.p(diffSize,-diff))
		end
		diff = diff + descTitleTx:getContentSize().height + diffHeight

		if not descSkillTilteTx then
			descSkillTilteTx = self:updateTTFlabel(node,desc,nil,20,'desc_skill_tilte_tx',maxWidth - 2*diffSize,cc.p(diffSize,-diff),
				COLOR_TYPE.WHITE,nil,nil,nil,cc.p(0,1))
			descSkillTilteTx:setLineHeight(30)
		else
			descSkillTilteTx:setString(desc)
			descSkillTilteTx:setPosition(cc.p(diffSize,-diff))
		end
		diff = diff + descSkillTilteTx:getContentSize().height + diffHeight
		descLineImg:setVisible(true)
		descTitleTx:setVisible(true)
		descSkillTilteTx:setVisible(true)
	else
		if descLineImg then
			descLineImg:setVisible(false)
		end
		if descTitleTx then
			descTitleTx:setVisible(false)
		end
		if descSkillTilteTx then
			descSkillTilteTx:setVisible(false)
		end
	end
	return diff
end

function itemCell:createExclusiveHeroDesc(node,diff,diffSize,maxWidth,obj)
	local diffHeight = 6
	local showEffectDesc = obj:isExclusive()
	local specialLineImg = node:getChildByName('special_hero_line_img')
	local specialTitleTx = node:getChildByName('special_hero_title_tx')
	local specialSkillTx = node:getChildByName('special_hero_skill_tx')
	if showEffectDesc then
		local desc = obj:getExclusiveHeroDesc()
		if not specialLineImg then
			specialLineImg = self:updateImageView(node,'uires/ui/common/common_tiao_4.png','special_hero_line_img')
			specialLineImg:setScale9Enabled(true)
			specialLineImg:setContentSize(cc.size(maxWidth,specialLineImg:getContentSize().height))
		end
		diff = diff + specialLineImg:getContentSize().height/2
		specialLineImg:setPosition(cc.p(maxWidth/2,-diff))

		diff = diff + diffHeight
		if not specialTitleTx then
			specialTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_DESC_105'),"font/gamefont.ttf",24,'special_hero_title_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.ORANGE,
			nil,nil,nil,cc.p(0,1))
		else
			specialTitleTx:setPosition(cc.p(diffSize,-diff))
		end
		diff = diff + specialTitleTx:getContentSize().height + diffHeight

		if not specialSkillTx then
			specialSkillTx = self:updateTTFlabel(node,desc,nil,20,'special_hero_skill_tx',maxWidth - 2*diffSize,cc.p(diffSize,-diff),
			COLOR_TYPE.WHITE,nil,nil,nil,cc.p(0,1))
			specialSkillTx:setLineHeight(30)
		else
			specialSkillTx:setString(desc)
			specialSkillTx:setPosition(cc.p(diffSize,-diff))
		end

		for i=0,2 do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				letter:setColor(COLOR_TYPE.RED)
			end
		end
		local maxLen = specialSkillTx:getStringLength()
		for i=3,maxLen do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				letter:setColor(COLOR_TYPE.GREEN)
			end
		end
		diff = diff + specialSkillTx:getContentSize().height + diffHeight
		specialLineImg:setVisible(true)
		specialTitleTx:setVisible(true)
		specialSkillTx:setVisible(true)
	else
		if specialLineImg then
			specialLineImg:setVisible(false)
		end
		if specialTitleTx then
			specialTitleTx:setVisible(false)
		end
		if specialSkillTx then
			specialSkillTx:setVisible(false)
		end
	end
	return diff
end

function itemCell:createSpecialDesc(node,diff,diffSize,maxWidth,obj)
	local diffHeight = 6
	local showEffectDesc = obj:showEffectDesc()
	local specialLineImg = node:getChildByName('special_line_img')
	local specialTitleTx = node:getChildByName('special_title_tx')
	local specialSkillTx = node:getChildByName('special_skill_tx')
	if showEffectDesc then
		local desc = obj:getSpecialDesc()
		local color = obj:getSpecialColor()
		if not specialLineImg then
			specialLineImg = self:updateImageView(node,'uires/ui/common/common_tiao_4.png','special_line_img')
			specialLineImg:setScale9Enabled(true)
			specialLineImg:setContentSize(cc.size(maxWidth,specialLineImg:getContentSize().height))
		end
		diff = diff + specialLineImg:getContentSize().height/2
		specialLineImg:setPosition(cc.p(maxWidth/2,-diff))

		diff = diff + diffHeight
		if not specialTitleTx then
			specialTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_DESC_11'),"font/gamefont.ttf",24,'special_title_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.ORANGE,
			nil,nil,nil,cc.p(0,1))
		else
			specialTitleTx:setPosition(cc.p(diffSize,-diff))
		end
		diff = diff + specialTitleTx:getContentSize().height + diffHeight

		if not specialSkillTx then
			specialSkillTx = self:updateTTFlabel(node,desc,nil,20,'special_skill_tx',maxWidth - 2*diffSize,cc.p(diffSize,-diff),
			COLOR_TYPE.WHITE,nil,nil,nil,cc.p(0,1))
			specialSkillTx:setLineHeight(30)
		else
			specialSkillTx:setString(desc)
			specialSkillTx:setPosition(cc.p(diffSize,-diff))
		end

		for i=0,2 do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				letter:setColor(color)
			end
		end
		local colorTab = GlobalApi:getAllCharIndex(desc)
		local maxLen = specialSkillTx:getStringLength()
		for i=3,maxLen do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				if colorTab[i + 1] then
					letter:setColor(COLOR_TYPE.BLUE)
				else
					letter:setColor(COLOR_TYPE.WHITE)
				end
			end
		end
		diff = diff + specialSkillTx:getContentSize().height + diffHeight
		specialLineImg:setVisible(true)
		specialTitleTx:setVisible(true)
		specialSkillTx:setVisible(true)
	else
		if specialLineImg then
			specialLineImg:setVisible(false)
		end
		if specialTitleTx then
			specialTitleTx:setVisible(false)
		end
		if specialSkillTx then
			specialSkillTx:setVisible(false)
		end
	end
	return diff
end

function itemCell:createAttrInfo(node,diff,diffSize,maxWidth,obj)
	local diffHeight = 6
	local attrLineImg = node:getChildByName('attr_line_img')
	local attrTitleTx = node:getChildByName('attr_title_tx')
	if not attrLineImg then
		attrLineImg = self:updateImageView(node,'uires/ui/common/common_tiao_4.png','attr_line_img')
		attrLineImg:setScale9Enabled(true)
		attrLineImg:setContentSize(cc.size(maxWidth,attrLineImg:getContentSize().height))
	end
	diff = diff + attrLineImg:getContentSize().height/2
	attrLineImg:setPosition(cc.p(maxWidth/2,-diff))

	diff = diff + diffHeight
	if not attrTitleTx then
		attrTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_DESC_10'),"font/gamefont.ttf",24,'attr_title_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.ORANGE,
		nil,nil,nil,cc.p(0,1))
	else
		attrTitleTx:setPosition(cc.p(diffSize,-diff))
	end
	diff = diff + attrTitleTx:getContentSize().height + diffHeight

	local baseAttr,baseAttrName = obj:getBaseAttrInfo()
	local curId = 0
	local attrHeight = 0
	for i=1,MAX_ATTR_NUM do
		if baseAttr[i] then
			curId = curId + 1
			local attrTx = node:getChildByName('attr_tx_'..curId)
			local pos = cc.p(diffSize,-diff)
			if curId % 2 == 0 then
				pos = cc.p(maxWidth/2 + diffSize/2,-diff + attrHeight + diffHeight)
			end
			if not attrTx then
				attrTx = self:updateTTFlabel(node,baseAttrName[i]..' +'..baseAttr[i],nil,20,'attr_tx_'..curId,nil,pos,COLOR_TYPE.WHITE,
				nil,nil,nil,cc.p(0,1))
			else
				attrTx:setString(baseAttrName[i]..' +'..baseAttr[i])
				attrTx:setPosition(pos)
			end
			local maxLen = attrTx:getStringLength()
			for j=3,maxLen do
				local letter = attrTx:getLetter(j)
				if letter then
					letter:setColor(COLOR_TYPE.GREEN)
				end
			end
			attrTx:setVisible(true)
			attrHeight = attrTx:getContentSize().height
			if curId % 2 == 1 then
				diff = diff + attrHeight + diffHeight
			end
		end
	end
	for i=curId + 1,MAX_ATTR_NUM do
		local attrTx = node:getChildByName('attr_tx_'..i)
		if attrTx then
			attrTx:setVisible(false)
		end
	end
	return diff
end

function itemCell:createAwardInfo(node,diff,diffSize,obj,showNum,showType)
	local diffHeight = 6
	local awardBgImg = self:updateExclusive(node,obj,'award_bg_img',showNum,true,true,showType)
	awardBgImg:setSwallowTouches(false)
	local size = awardBgImg:getContentSize()
	diff = diff + diffHeight/2 + size.height/2
	awardBgImg:setPosition(cc.p(diffSize + size.width/2,-diff))
	diff = diff + diffHeight + size.height/2 + diffHeight/2
	return diff
end

function itemCell:createExclusiveInfo(sv,diffSize,obj,showNum,showType)
	if not obj then
		local node = sv:getChildByName('node')
		if node then
			node:setVisible(false)
		end
		return
	end
	local svSize = sv:getContentSize()
	local diff = 0
	local node = sv:getChildByName('node')
	if not node then
		node = cc.Node:create()
		sv:addChild(node)
		node:setName('node')
	end
	node:setVisible(true)

	diff = self:createAwardInfo(node,diff,diffSize,obj,showNum,showType)
	diff = self:createExclusiveHeroDesc(node,diff,diffSize,svSize.width,obj)
	diff = self:createSpecialDesc(node,diff,diffSize,svSize.width,obj)
	diff = self:createAttrInfo(node,diff,diffSize,svSize.width,obj)
	diff = self:createDescInfo(node,diff,diffSize,svSize.width,obj)

	if svSize.height > diff then
		node:setPosition(cc.p(0,svSize.height))
		sv:setInnerContainerSize(svSize)
	else
		node:setPosition(cc.p(0,diff))
		sv:setInnerContainerSize(cc.size(svSize.width,diff))
	end
end

function itemCell:createAllAttrInfo(node,diff,diffSize,attrDiff,maxWidth,attrInfo)
	local diffHeight = 6
	local attrTitleTx = node:getChildByName('attr_title_tx')
	local attrBgImg = node:getChildByName('attr_bg_img')
	-- diff = diff + diffHeight
	if not attrTitleTx then
		attrTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_MAIN_TITLE_DESC_1'),"font/gamefont.ttf",24,'attr_title_tx',
		nil,cc.p(diffSize,-diff),COLOR_TYPE.PALE,COLOROUTLINE_TYPE.PALE,2,nil,cc.p(0,1))
	else
		attrTitleTx:setPosition(cc.p(diffSize,-diff))
	end
	diff = diff + attrTitleTx:getContentSize().height + diffHeight + diffHeight/3

	local oldDiff = diff
	if not attrBgImg then
		attrBgImg = self:updateImageView(node,'uires/ui/common/common_tiao_mid_2.png','attr_bg_img',nil,nil,cc.p(0,-diff),cc.p(0,1))
		attrBgImg:setScale9Enabled(true)
	else
		attrBgImg:setPosition(cc.p(0,-diff))
	end
	diff = diff + diffHeight

	local baseAttr = attrInfo.baseAttr
	local baseAttrName = attrInfo.baseAttrName
	local curId = 0
	local attrHeight = 0
	for i=1,MAX_ATTR_NUM do
		if baseAttr[i] then
			curId = curId + 1
			local attrTx = node:getChildByName('attr_tx_'..curId)
			local pos = cc.p(attrDiff,-diff)
			if curId % 2 == 0 then
				pos = cc.p(maxWidth/2 + attrDiff/2,-diff + attrHeight + diffHeight)
			end
			if not attrTx then
				attrTx = self:updateTTFlabel(node,baseAttrName[i]..' +'..baseAttr[i],nil,20,'attr_tx_'..curId,nil,pos,COLOR_TYPE.WHITE,
				nil,nil,nil,cc.p(0,1))
			else
				attrTx:setString(baseAttrName[i]..' +'..baseAttr[i])
				attrTx:setPosition(pos)
			end
			local maxLen = attrTx:getStringLength()
			for j=3,maxLen do
				local letter = attrTx:getLetter(j)
				if letter then
					letter:setColor(COLOR_TYPE.GREEN)
				end
			end
			attrTx:setVisible(true)
			attrHeight = attrTx:getContentSize().height
			if curId % 2 == 1 then
				diff = diff + attrHeight + diffHeight
			end
		end
	end
	for i=curId + 1,MAX_ATTR_NUM do
		local attrTx = node:getChildByName('attr_tx_'..i)
		if attrTx then
			attrTx:setVisible(false)
		end
	end
	attrBgImg:setContentSize(cc.size(maxWidth,diff - oldDiff))
	return diff
end

function itemCell:createAllSpecialInfo(node,diff,diffSize,attrDiff,maxWidth,obj,index,ntype)
	local diffHeight = 6
	-- local showEffectDesc = obj:showEffectDesc()
	local specialTitleTx = node:getChildByName('special_attr_title_tx')
	local specialBgImg = node:getChildByName('special_attr_bg_img')
	local specialSkillTx = node:getChildByName('special_skill_tx_'..index)
	if obj and obj:showEffectDesc() then
		local desc = GlobalApi:getLocalStr('EXCLUSIVE_TYPE_'..ntype)..'·'..obj:getSpecialDesc()
		local color = obj:getSpecialColor()
		diff = diff + diffHeight
		if not specialSkillTx then
			specialSkillTx = self:updateTTFlabel(node,desc,nil,20,'special_skill_tx_'..index,maxWidth - 2*diffSize,cc.p(diffSize,-diff),
			COLOR_TYPE.WHITE,nil,nil,nil,cc.p(0,1))
			specialSkillTx:setLineHeight(30)
		else
			specialSkillTx:setString(desc)
			specialSkillTx:setPosition(cc.p(diffSize,-diff))
		end

		for i=0,5 do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				letter:setColor(color)
			end
		end
		local colorTab = GlobalApi:getAllCharIndex(desc)
		local maxLen = specialSkillTx:getStringLength()
		for i=6,maxLen do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				if colorTab[i + 1] then
					letter:setColor(COLOR_TYPE.BLUE)
				else
					letter:setColor(COLOR_TYPE.WHITE)
				end
			end
		end
		diff = diff + specialSkillTx:getContentSize().height
		specialSkillTx:setVisible(true)
	else
		if specialSkillTx then
			specialSkillTx:setVisible(false)
		end
	end
	return diff
end

function itemCell:createAllSpecialBgImg(node,diff,maxWidth,oldDiff)
	local specialBgImg = node:getChildByName('special_attr_bg_img')
	if oldDiff then
		if not specialBgImg then
			specialBgImg = self:updateImageView(node,'uires/ui/common/common_tiao_mid_2.png','special_attr_bg_img',-1,nil,cc.p(0,-oldDiff),cc.p(0,1))
			specialBgImg:setScale9Enabled(true)
		else
			specialBgImg:setPosition(cc.p(0,-oldDiff))
		end
		specialBgImg:setVisible(true)
		specialBgImg:setContentSize(cc.size(maxWidth,diff - oldDiff))
	else
		if specialBgImg then
			specialBgImg:setVisible(false)
		end
	end
end

function itemCell:createAllSpecialDesc(node,diff,diffSize,show)
	local diffHeight = 10
	local specialDescTx = node:getChildByName('special_attr_desc_tx')
	if show then
		diff = diff + diffHeight
		if not specialDescTx then
			specialDescTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_DESC_30'),nil,20,
			'special_attr_desc_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.YELLOW,nil,nil,nil,cc.p(0,1))
		end
		specialDescTx:setPosition(cc.p(diffSize,-diff))
		diff = diff + specialDescTx:getContentSize().height + diffHeight
		specialDescTx:setVisible(true)
	else
		if specialDescTx then
			specialDescTx:setVisible(false)
		end
	end
	return diff
end

function itemCell:createAllSpecialTitleTx(node,diff,diffSize)
	local diffHeight = 6
	local specialTitleTx = node:getChildByName('special_attr_title_tx')
	diff = diff + diffHeight
	if not specialTitleTx then
		specialTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_MAIN_TITLE_DESC_2'),"font/gamefont.ttf",24,
		'special_attr_title_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.PALE,COLOROUTLINE_TYPE.PALE,2,nil,cc.p(0,1))
	else
		specialTitleTx:setPosition(cc.p(diffSize,-diff))
	end
	specialTitleTx:setVisible(true)
	diff = diff + specialTitleTx:getContentSize().height + diffHeight + diffHeight/3
	return diff
end

function itemCell:createAllSpecialHero(node,diff,diffSize,attrDiff,maxWidth,roleObj)
	local diffHeight = 6
	local name,showEffectDesc = roleObj:getSpecialExclusiveDes()
	local specialTitleTx = node:getChildByName('special_attr_hero_title_tx')
	local specialSkillTx = node:getChildByName('special_hero_skill_tx')
	local attrBgImg = node:getChildByName('attr_hero_bg_img')
	if name and showEffectDesc then
		diff = diff + diffHeight
		if not specialTitleTx then
			specialTitleTx = self:updateTTFlabel(node,GlobalApi:getLocalStr('EXCLUSIVE_MAIN_TITLE_DESC_3'),"font/gamefont.ttf",24,
			'special_attr_hero_title_tx',nil,cc.p(diffSize,-diff),COLOR_TYPE.PALE,COLOROUTLINE_TYPE.PALE,2,nil,cc.p(0,1))
		else
			specialTitleTx:setPosition(cc.p(diffSize,-diff))
		end
		specialTitleTx:setVisible(true)
		diff = diff + specialTitleTx:getContentSize().height + diffHeight + diffHeight/3
		
		local oldDiff = diff
		if not attrBgImg then
			attrBgImg = self:updateImageView(node,'uires/ui/common/common_tiao_mid_2.png','attr_hero_bg_img',nil,nil,cc.p(0,-diff),cc.p(0,1))
			attrBgImg:setScale9Enabled(true)
		else
			attrBgImg:setPosition(cc.p(0,-diff))
		end
		attrBgImg:setVisible(true)

		local desc = name .. '·' .. showEffectDesc
		if not roleObj:isEquipSpecialExclusive() then
			desc = desc .. string.format(GlobalApi:getLocalStr("EXCLUSIVE_DESC_106"),name)
		end
		diff = diff + diffHeight
		if not specialSkillTx then
			specialSkillTx = self:updateTTFlabel(node,desc,nil,20,'special_hero_skill_tx',maxWidth - 2*diffSize,cc.p(diffSize,-diff),
			COLOR_TYPE.WHITE,nil,nil,nil,cc.p(0,1))
			specialSkillTx:setLineHeight(30)
		else
			specialSkillTx:setString(desc) 
			specialSkillTx:setPosition(cc.p(diffSize,-diff))
		end
		specialSkillTx:setVisible(true)

		local len = GlobalApi:utf8len(name) + 4
		for i=0,len - 1 do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				letter:setColor(COLOR_TYPE.RED)
			end
		end
		local maxLen = specialSkillTx:getStringLength()
		for i=len,maxLen do
			local letter = specialSkillTx:getLetter(i)
			if letter then
				if roleObj:isEquipSpecialExclusive() then
					letter:setColor(COLOR_TYPE.GREEN)
				else
					letter:setColor(COLOR_TYPE.GRAY)
				end
			end
		end
		diff = diff + specialSkillTx:getContentSize().height
		specialSkillTx:setVisible(true)
		attrBgImg:setContentSize(cc.size(maxWidth,diff - oldDiff))
	else
		if specialSkillTx then
			specialSkillTx:setVisible(false)
		end
		if specialTitleTx then
			specialTitleTx:setVisible(false)
		end
		if attrBgImg then
			attrBgImg:setVisible(false)
		end
	end
	return diff
end

function itemCell:createExclusiveAllInfo(sv,diffSize,roleObj)
	local svSize = sv:getContentSize()
	local diff = 0
	local node = sv:getChildByName('node')
	if not node then
		node = cc.Node:create()
		sv:addChild(node)
		node:setName('node')
	end
	node:setVisible(true)

	local baseAttr,baseAttrName = roleObj:getExclusiveAttr()
	diff = self:createAllAttrInfo(node,diff,diffSize,40,svSize.width,{baseAttr = baseAttr,baseAttrName = baseAttrName})
	diff = self:createAllSpecialHero(node,diff,diffSize,40,svSize.width,roleObj)
	diff = self:createAllSpecialTitleTx(node,diff,diffSize)
	local oldDiff = diff
	local num = 0
	for i=1,MAX_EXCLUSIVE_TYPE do
		local id = roleObj:getExclusiveId(i)
		if id ~= 0 then
			local obj = ClassExclusiveObj.new(tonumber(id), 0)
			local showEffectDesc = obj:showEffectDesc()
			if showEffectDesc then
				num = num + 1
				diff = self:createAllSpecialInfo(node,diff,diffSize,40,svSize.width,obj,num,i)
			end
		end
	end
	diff = self:createAllSpecialDesc(node,diff,diffSize,num <= 0)

	for i=num + 1,MAX_EXCLUSIVE_TYPE do
		diff = self:createAllSpecialInfo(node,diff,diffSize,40,svSize.width,nil,i)
	end
	self:createAllSpecialBgImg(node,diff,svSize.width,oldDiff)

	if svSize.height > diff then
		node:setPosition(cc.p(0,svSize.height))
		sv:setInnerContainerSize(svSize)
	else
		node:setPosition(cc.p(0,diff))
		sv:setInnerContainerSize(cc.size(svSize.width,diff))
	end
end

function itemCell:showTypeImg(obj , node)
	--xyh
	--新增阵营图标：1神、2妖、3人、4佛、5主角
	if node:getChildByName("imgCamp") then
		node:removeChildByName("imgCamp")
	end
	local objId = obj:getId()
	if objId and objId ~= 0 then   --objId == 0 这个是空的位置没有东西
		local campType = GameData:getConfData("hero")[objId].camp
		if campType and campType ~= 5 and campType ~= 0  then 
			local imgCamp = ccui.ImageView:create('uires/ui/common/camp_'..campType..'.png')
			imgCamp:setName('imgCamp')
			imgCamp:setVisible(true)
			imgCamp:setScale(0.6)
			node:addChild(imgCamp)
			imgCamp:setPosition(cc.p(10 , 10))
			imgCamp:setLocalZOrder(1)
		end
	end
end

return itemCell


