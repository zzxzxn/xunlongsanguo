local TreasureUI = class("TreasureUI", BaseUI)
local TREASURE_CONF = GameData:getConfData("treasure")
local PLAYER_SKILL_CONF = GameData:getConfData("playerskill")
local PLAYER_SKILL_SLOT_CONF = GameData:getConfData("playerskillslot")

local MAX_LEVEL = 5
local MAX_DRAGON_EFFECT = 3
function TreasureUI:ctor(page)
	self.uiIndex = GAME_UI.UI_TREASURE
	self.num = #GameData:getConfData("playerskill")
	local id = UserData:getUserObj():getTreasure().id
	if id > self.num then
		id = self.num
	end
	self.currPos = page or id
	self.pos = {}
	self.maxLen = 0
	self.currMax = 0
	self.maxNum = 3
	self.oldMaxFrame = 0
	self.intervalSize = 12.8
	self.singleSize = cc.size(94*0.85,94*0.85)
	self.skillsTab = UserData:getUserObj():getSkills()
	self.oldSkills = clone(UserData:getUserObj():getSkills())
	self.spineIndex = 0
	self.attrRichText = {}

	self.choose = 0  --底部+

	----------
	self.skillImgs = {}
	self.cannotMove = false
end

function TreasureUI:initPos()
	local size = self.pl:getContentSize()
	local midWidth = size.width/2
	local midHeight = size.height/2
	for i=1,self.num do
		if i <= 6 then
			self.pos[i] = {pos = cc.p(midWidth + (i - 1)*320,(((i == 1) and midHeight) or midHeight - 20)),zorder = (((i == 1) and 3) or 1),scale = (((i == 1) and 0.9) or 0.7)}
		else
			self.pos[i] = {pos = cc.p(midWidth + (i - self.num - 1)*320,midHeight - 20),zorder = (((i == 1) and 3) or 1),scale = (((i == 1) and 0.9) or 0.7)}
		end
	end
end

function TreasureUI:maekSpineDirty()
	self.spineIndex = 0
end

function TreasureUI:hideChooseNode()
	self.chooseNode:setVisible(false)
	self.choose = 0

	self:updatePanel()
end

function TreasureUI:showChooseNode(index)
	if index > 0 then
		local slotConf = GameData:getConfData("playerskillslot")
		local openLevel = tonumber(slotConf[index].open)
		local level = UserData:getUserObj():getLv()
		if level >= openLevel then
			self.chooseNode:setVisible(true)
			self.choose = index

			self:updateChoose()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('GETWAY_DESC1'), COLOR_TYPE.RED)
		end
	else
		self.chooseNode:setVisible(false)
		self.choose = index

		self:updateChoose()
	end
end

function TreasureUI:createChooseCell(k,v)
	local chooseCell = cc.CSLoader:createNode("csb/choose_dragon_item.csb")
	chooseCell:setName("chooseCell"..k)
	local itemNode = chooseCell:getChildByName('item_node')
	itemNode:setName("item_node_"..k)
	itemNode:setSwallowTouches(false)

	local isCanMove = true
	local touchBeginX = 0
	itemNode:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			isCanMove = true
			touchBeginX = sender:getTouchBeganPosition().x
        elseif eventType == ccui.TouchEventType.moved then
        	local touchMoveX = sender:getTouchMovePosition().x
        	if math.abs(touchBeginX - touchMoveX) > 32 then
        		isCanMove = false
    		end
        elseif eventType == ccui.TouchEventType.ended then
        	if isCanMove then
        		if v.type == 3 then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_104'), COLOR_TYPE.RED)
					return
				end

	        	self.currPos = v.id
				self:updateSkills(self.choose)

	        	self:sendSkillsChange(function()
					local roleObj = RoleData:getMainRole()
					roleObj:setDragon()

					self:hideChooseNode()
				end)
	        end
	        isCanMove = true
		end
	end)

	if v.type == 3 then
		itemNode:setOpacity(125)
		itemNode:setColor(cc.c3b(210,210,210))
	end

	local lvTx = itemNode:getChildByName('lv_tx')
	local iconNode = itemNode:getChildByName('icon_node')
	local starNode = itemNode:getChildByName('star_node')
	local img2 = itemNode:getChildByName('img_2')
	img2:setVisible(v.type == 1)

	lvTx:setVisible(false)

	-- local dragon = RoleData:getDragonById(v.id)
	-- lvTx:setString(dragon:getLevel())

	local iconImg = ccui.ImageView:create('uires/ui/treasure/treasure_'..v.icon)
	iconNode:addChild(iconImg)

	local level = RoleData:getDragonById(v.id) and RoleData:getDragonById(v.id).level
	for i=1,5 do
		local star = starNode:getChildByName('star_img_'..i)
		if level and i <= level then
			star:setVisible(true)
		else
			star:setVisible(false)
		end
	end

	local itemSize = itemNode:getContentSize()
	local preX = itemSize.width
	local y = itemSize.height/2 + 20

	chooseCell:setPosition(preX*(k - 1) - 10, y)
	self.chooseSv:addChild(chooseCell)

	self.chooseSv:setInnerContainerSize(cc.size(10*preX, 214))
end

--刷新法宝选择界面
function TreasureUI:updateChoose()
	self.chooseSv = self.chooseNode:getChildByName("choose_sv")
	local grayImg = self.chooseNode:getChildByName("gray_img")
	local treasureInfo = UserData:getUserObj():getTreasure()
	local conf = GameData:getConfData("playerskill")

	grayImg:setSwallowTouches(true)
	grayImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then

        elseif eventType == ccui.TouchEventType.ended then
        	self:hideChooseNode()
		end
	end)

	local wear = {}			--已装备
	local notWaer = {}		--未装备
	local notGet = {}		--未获得
	for k,v in ipairs(conf) do
		if k <= tonumber(treasureInfo.id) then
			local isWear = false
			for i=1,5 do
				if tonumber(self.skillsTab[tostring(i)].id) == k then
					isWear = true
				end
			end

			if isWear then
				table.insert(wear,{id = k,icon = v.icon,type = 1})
			else
				table.insert(notWaer,{id = k,icon = v.icon,type = 2})
			end
		else
			table.insert(notGet,{id = k,icon = v.icon,type = 3})
		end
	end

	local dragons = {}

	for k,v in ipairs(wear) do
		table.insert(dragons, v)
	end

	for k,v in ipairs(notWaer) do
		table.insert(dragons, v)
	end

	for k,v in ipairs(notGet) do
		table.insert(dragons, v)
	end

	for k,v in ipairs(dragons) do
		if self.chooseSv:getChildByName("chooseCell"..k) then
			self.chooseSv:getChildByName("chooseCell"..k):removeFromParent()
		end
		self:createChooseCell(k,v)
	end

	self.chooseSv:setScrollBarEnabled(false)
end

--底部法宝栏
function TreasureUI:updateSkillImgs()
	local conf = GameData:getConfData("playerskill")
	local slotConf = GameData:getConfData("playerskillslot")
	self.slotOpend = {}
	for i,v in ipairs(self.skillImgs) do
		local skillImg = v:getChildByName('skill_img')
		local lvBgImg = v:getChildByName('lv_bg_img')
		local lvTx = v:getChildByName('lv_tx')
		local openTx = v:getChildByName('open_tx')
		local addImg = v:getChildByName('add_img')
		-- 小红点
		local redImg = v:getChildByName('red_img')
		local openLevel = tonumber(slotConf[i].open)
		local level = UserData:getUserObj():getLv()
		skillImg:setLocalZOrder(5)
		skillImg:setVisible(true)

		if level >= openLevel then
			openTx:setString('')
			lvTx:setVisible(true)
			lvBgImg:setVisible(true)
			self.slotOpend[i] = true

			if self.skillsTab[tostring(i)] then
				lvTx:setString(GlobalApi:getLocalStr('SETTING_INFO_LV')..self.skillsTab[tostring(i)].level)
				if tonumber(self.skillsTab[tostring(i)].id) > 0 then
					skillImg:loadTexture('uires/ui/treasure/treasure_'..conf[self.skillsTab[tostring(i)].id].icon)
					addImg:setVisible(false)
					redImg:setVisible(false)
					lvTx:setVisible(true)
					lvBgImg:setVisible(true)
				else   --没有放置英雄
					skillImg:loadTexture('uires/ui/common/bg1_alpha.png')
					addImg:setVisible(true)
					redImg:setVisible(true)
					lvTx:setString('')
					lvTx:setVisible(false)
					lvBgImg:setVisible(false)
				end
			else
				skillImg:loadTexture('uires/ui/common/bg1_alpha.png')
				addImg:setVisible(true)
				redImg:setVisible(true)
				lvTx:setString('')
				lvTx:setVisible(false)
				lvBgImg:setVisible(false)
			end
		else  --等级未到没开放
			skillImg:setVisible(false)
			openTx:setString(openLevel..GlobalApi:getLocalStr('STR_POSCANTOPEN_1'))
			lvTx:setVisible(false)
			lvBgImg:setVisible(true)
			addImg:setVisible(false)
			redImg:setVisible(false)
			local img = ccui.ImageView:create("uires/ui/treasure/treasure_lock.png")
			img:setPosition(addImg:getPosition())
			img:setScale(0.4)
			v:addChild(img)
			self.slotOpend[i] = false
		end
	end
end

function TreasureUI:updateBottomPanel()
	self.posXs = {min = 480,max = 480}
	self.posYs = {min = 30,max = 30}
	local conf = GameData:getConfData("treasure")
	local playerSkillConf = GameData:getConfData("playerskill")
	local size
	for i=1,5 do
		local size1 = self.skillImgs[i]:getContentSize()
		size = cc.size(size1.width*0.7,size1.height*0.7)
		local tab = self.skillImgs[i]:convertToWorldSpace(cc.p(0,0))
		tab.x = tab.x *0.7
		tab.y = tab.y *0.7
		self.posXs.min = math.floor(((tab.x < self.posXs.min) and tab.x) or self.posXs.min)
		self.posXs.max = math.floor((((tab.x + size.width) > self.posXs.max) and (tab.x + size.width)) or self.posXs.max)
		self.posYs.min = math.floor(((tab.y < self.posYs.min) and tab.y) or self.posYs.min)
		self.posYs.max = math.floor((((tab.y + size.height) > self.posYs.max) and (tab.y + size.height)) or self.posYs.max)
	end
	local diffSize = (self.posXs.max - self.posXs.min - 5*size.width)/4
	self.posXs.min = self.posXs.min - diffSize/2
	self.posXs.max = self.posXs.max + diffSize/2
	self:updateSkillImgs()

	local treasureInfo = UserData:getUserObj():getTreasure()
	local isGoto = false
    if self.currPos > tonumber(treasureInfo.id) then
    	isGoto = true
    end

	local winSize = cc.Director:getInstance():getVisibleSize()
	local size1 = self.leftBottomImg:getContentSize()
	local tx = playerSkillConf[self.currPos].desc1
	if not self.rts then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(500, 30))
		richText:setAlignment('middle')
		richText:setVerticalAlignment('middle')
	    local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('TREASURE_DESC_1'),28,COLOR_TYPE.WHITE)
	    local re1 = xx.RichTextLabel:create(tx,28,COLOR_TYPE.WHITE)
	    re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	    local re2 = xx.RichTextImage:create('uires/ui/treasure/treasure_skill_name_'..self.currPos..'.png')
	    re2:setScale(0.8)
	    re:setFont('font/gamefont.ttf')
	    re1:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:addElement(re)
	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(winSize.width/2,winSize.height - 400))
	    self.root:addChild(richText)
	    self.rts = {richText = richText,re = re,re1 = re1,re2 = re2}
	else
		self.rts.re1:setString(tx)
		self.rts.re2:setImg('uires/ui/treasure/treasure_skill_name_'..self.currPos..'.png')
		self.rts.re2:setScale(0.8)
		self.rts.richText:format(true)
	end
	self.rts.richText:setVisible(isGoto and self.currPos ~= 1 and self.currPos ~= 2)
end

-- 新手引导会重写这个方法
function TreasureUI:playEggActionOver(spine)
	if spine then
		spine:removeFromParent()
	end
end

function TreasureUI:updateSpine()
	local conf = GameData:getConfData("treasure")
	local playerSkillConf = GameData:getConfData("playerskill")
	local treasureInfo = UserData:getUserObj():getTreasure()
	local id = tonumber(treasureInfo.id)
	local level = 1

    local roleObj = RoleData:getMainRole()
	local size = self.leftBottomImg:getContentSize()
	local roleSpine = self.leftBottomImg:getChildByTag(9999)
	if roleSpine then
		roleSpine:removeFromParent()
	end
	local effect = self.leftBottomImg:getChildByName('effect')
	if not effect then
	    effect = GlobalApi:createSpineByName("treasure_dan", "spine/treasure_dan_effect/treasure_dan", 1)
	    self.leftBottomImg:addChild(effect,2)
	    effect:setPosition(cc.p(size.width/2,size.height - 30))
	    effect:setName('effect')
	end

    local spine = nil
	local dragon = RoleData:getDragonById(self.currPos)
	-- if dragon then
	-- 	local dragonLevel = dragon:getLevel()
	-- 	spine = GlobalApi:createLittleLossyAniByName(conf[self.currPos][1].url, nil, dragon:getChangeEquipState())
	-- 	local url = playerSkillConf[self.currPos]['upgrade'..dragonLevel]
	-- 	if url then
	-- 		local effect = GlobalApi:createLittleLossyAniByName(url)
	-- 		effect:setPosition(cc.p(playerSkillConf[self.currPos]['posx'..dragonLevel], playerSkillConf[self.currPos]['posy'..dragonLevel]))
	-- 		effect:setLocalZOrder(10000)
	-- 		effect:getAnimation():playWithIndex(0, -1, 1)
	-- 		effect:setName('dragon_effect')
	-- 		spine:addChild(effect)
	-- 	end
	-- 	ShaderMgr:restoreArmatureDefaultShader(spine)
	-- else
	-- 	--不要战马
	-- 	-- if self.currPos == 1 then
	-- 	-- 	local str = 'spine/treasure/'.. conf[self.currPos][1].url
	-- 	-- 	spine = GlobalApi:createSpineByName(conf[self.currPos][1].url, str, 1)
	-- 	-- 	spine:setAnimation(0, 'idle', true)
	-- 	-- else
 --    		-- spine = GlobalApi:createLittleLossyAniByName(conf[self.currPos][1].url)
 --    		-- spine:setOpacity(125)
 --    		-- ShaderMgr:setGrayForArmature(spine, "default_etc")
 --    	-- end
	-- end
    -- spine:getAnimation():play('idle', -1, 1)
    -- spine:setPosition(cc.p(size.width/2,size.height - 30))
    -- self.leftBottomImg:addChild(spine)
	if self.currPos ~= id or level == #conf[self.currPos] then
		effect:setAnimation(0, 'effect_0_idle', true)
	else
		effect:setAnimation(0, 'effect_'..level..'_idle', true)
	end

	if self.currSpine then
		self.currSpine:removeFromParent()
	end
	-- self.currSpine = spine
	self.spineIndex = index
end

function TreasureUI:updateRideBtn()
	local obj = RoleData:getRoleByPos(1)
	local oldatt = RoleData:getPosAttByPos(obj)
	local treasureInfo = UserData:getUserObj():getTreasure()

	local id = tonumber(treasureInfo.id)
	local active = tonumber(treasureInfo.active)
	-- if self.currPos == id and active == 0 then
	-- 	MainSceneMgr:showDragonInfoUI(self.currPos,true,function ()
	-- 		local args = {}
	-- 	    MessageMgr:sendPost('active','treasure',json.encode(args),function (response)
	-- 	        local code = response.code
	-- 	        local data = response.data
	-- 	        if code == 0 then
	-- 	        	RoleData:setAllFightForceDirty()
	-- 	        	RoleData:createDragon(self.currPos,{level = 1})

	-- 	        	treasureInfo.active = treasureInfo.active + 1
	-- 				UserData:getUserObj():setTreasure(treasureInfo)

	-- 	        	if data.awards then
	-- 	        		GlobalApi:parseAwardData(data.awards)
	-- 	        	end
	-- 	        	if data.costs then
	-- 	        		GlobalApi:parseAwardData(data.costs)
	-- 	        	end
	-- 	        	self.pl:setTouchEnabled(false)

	-- 				for i=1,7 do
	-- 					local obj = RoleData:getRoleByPos(i)
	-- 					if obj and obj:getId() > 0 then
	-- 						RoleMgr:popupTips(obj,true)
	-- 					end
	-- 				end

	-- 	        	local newatt = RoleData:getPosAttByPos(obj)
	-- 	        	self:popupTips(oldatt,newatt,self.oldFightForce,self:getFightForce())
	-- 	        	self:updatePanel()
	-- 	        end
	-- 	    end)
	-- 	end)
	-- end
end

function TreasureUI:updateLeftPanel()
	local conf = GameData:getConfData("treasure")
	local attributeConf = GameData:getConfData("attribute")
	local playerSkillConf = GameData:getConfData("playerskill")
	local buffConf = GameData:getConfData("buff")
	local treasureInfo = UserData:getUserObj():getTreasure()
	printall(treasureInfo)
	local id = tonumber(treasureInfo.id)
	local level = 1
	local currId
	local dragonInfo = RoleData:getDragonMap()[self.currPos]

	local infoTx = self.tameBtn:getChildByName('info_tx')
	self.tameBtn:setBright(true)
	self.tameBtn:setTouchEnabled(true)
	infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1)
	infoTx:setString(GlobalApi:getLocalStr('STR_TAME'))

	local attrs = {}
	local attrTxs = {}
	local nextAttrx = {}
	local tab = conf[self.currPos][level]
	for j=1,4 do
		local attr = tab['attr'..j]
		local value = tab['value'..j]
		attrs[attr] = (attrs[attr] or 0) + value
	end
	local nextConf = conf[self.currPos][level + 1]
	if nextConf then
		for i=1,4 do
			local attr = nextConf['attr'..i]
			local value = nextConf['value'..i]
			nextAttrx[attr] = (nextAttrx[attr] or 0) + value
		end
	end

	local index = self.currPos*100 + level
	local isShow = false
	if self.leftIndex and self.currPos == math.floor(self.leftIndex/100) then
		isShow = true
	end
	self.leftIndex = index
    local lv = UserData:getUserObj():getLv()
    local function getStr(conf1)
        local str = ''
        local num = nil
        if conf1.coefficient == 0 and conf1.buffId == 0 then
            str = conf1.skillDesc[1]
        elseif conf1.coefficient ~= 0 then
            num = math.floor(conf1.coefficient*(lv*26 + 856)/100 + conf1.fixedDamage)
            local str1 = conf1.skillDesc[1]
            local arr = string.split(tostring(str1),'@')
            if #arr > 1 then
                str = arr[1]..'%'..arr[2]
            else
                str = arr[1]
            end
        elseif conf1.buffId ~= 0 then
            local tab = buffConf[conf1.buffId]
            num = math.floor(tab.coefficient*(lv*26 + 856)/100 + tab.fixedDamage)
            local str1 = conf1.skillDesc[1]
            local arr = string.split(tostring(str1),'@')
            if #arr > 1 then
                str = arr[1]..'%'..arr[2]
            else
                str = arr[1]
            end
        end
        return str,num
    end
	if self.richText then
		self.richText:removeFromParent()
		self.richText = nil
	end

	local richText = xx.RichText:create()
	richText:setContentSize(cc.size(280, 50))
	richText:setPosition(cc.p(10,60))
    richText:setAnchorPoint(cc.p(0,1))
    self.descPl:addChild(richText)
    richText:setCascadeOpacityEnabled(true)
    self.richText = richText

	local strTab,data1,str,str1,num
	local dragon = RoleData:getDragonMap()[self.currPos]
	local skillLevel = 1
	self.tameBtn:setVisible(false)
	if dragon then
		skillLevel = dragon:getLevel()
		self.tameBtn:setVisible(true)
	end
    local skillConf = GameData:getConfData("skill")
    local skillId = playerSkillConf[self.currPos].skillId
    local data = skillConf[skillId + skillLevel * 2 ]
    str,num = getStr(data)
    strTab = string.split(str,'%s')
    if #strTab > 1 then
    	str1 = strTab[1]..num..strTab[2]
    else
    	str1 = strTab[1]
    end
    data1 = skillConf[skillId + (skillLevel + 1)*2]
    xx.Utils:Get():analyzeHTMLTag(self.richText,str1)

	for i,v in ipairs(self.numTxs) do
		v:setString(' + '..conf[self.currPos][#conf[self.currPos]]['value'..i])
	end
end

--滑动右边法宝调用
function TreasureUI:setImgsPosition()
	local conf = GameData:getConfData("treasure")
	local treasureInfo = UserData:getUserObj():getTreasure()
	local active = tonumber(treasureInfo.active)
	for i=1,self.num do
		local dragon = RoleData:getDragonById(i)
		local index = (i-self.currPos)%self.num + 1
		self.imgs[i]:setLocalZOrder(self.pos[index].zorder)
		self.imgs[i]:setTouchEnabled(index == 1)
		self.imgs[i]:setSwallowTouches(false)
		self.imgs[i]:setScale(((index == 1)and 1) or 0.7)
		self.imgs[i]:setCascadeOpacityEnabled(true)
		if i == self.currPos then
			self.imgs[i]:getChildByName("starImg"):setVisible(true)
			self.imgs[i]:setOpacity(255)
	    else
			self.imgs[i]:getChildByName("starImg"):setVisible(false)
	    	self.imgs[i]:setOpacity(125)
	    end

	    self.imgs[i]:getChildByName("starImg"):getChildByName("installImg"):setVisible(false)
	    for k,v in pairs(self.skillsTab) do
	    	if v.id == i then
	    		self.imgs[i]:getChildByName("starImg"):getChildByName("installImg"):setVisible(true)
	    	end
	    end

	    if dragon then
	    	local level = dragon:getLevel()
	    	for j=1,5 do
		    	local starImg = self.imgs[i]:getChildByName("starImg"):getChildByName("starImg"..j)
	    		if j <= level then
		    		starImg:setVisible(true)
		    	else
		    		starImg:setVisible(false)
		    	end
	    	end
	    else
	    	local starImg = self.imgs[i]:getChildByName("starImg")
	    	starImg:setVisible(false)
	    end

		local cellImg = self.imgs[i]:getChildByTag(998)
		local lockImg = self.imgs[i]:getChildByTag(997)
		local nameImg = self.imgs[i]:getChildByTag(995)
		local longSpine = self.imgs[i]:getChildByTag(994)
		-- local fangdaImg = self.imgs[i]:getChildByTag(993)

		lockImg:loadTexture('uires/ui/treasure/treasure_lock.png')
	    if i < tonumber(treasureInfo.id) or i == tonumber(treasureInfo.id) and active >= 1 then
	    	-- ShaderMgr:restoreWidgetDefaultShader(self.imgs[i])
	    	-- ShaderMgr:restoreWidgetDefaultShader(cellImg)
	    	-- ShaderMgr:restoreWidgetDefaultShader(nameImg)
	    	longSpine:setVisible(true)
	    	-- fangdaImg:setBright(true)
	    	lockImg:setVisible(false)
	    else
	    	-- ShaderMgr:setGrayForWidget(self.imgs[i])
	    	-- ShaderMgr:setGrayForWidget(cellImg)
	    	-- ShaderMgr:setGrayForWidget(nameImg)
	    	longSpine:setVisible(false)
	    	-- fangdaImg:setBright(false)
	    	lockImg:setVisible(true)
	    	-- fangdaImg:setTouchEnabled(false)
	    end

		self.imgs[i]:stopAllActions()
		if index < 4 or index > 8 then
			local posX,posY = self.imgs[i]:getPositionX(),self.imgs[i]:getPositionY()
			local time = math.abs(posX - self.pos[index].pos.x)/1000
			self.imgs[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,self.pos[index].pos),cc.CallFunc:create(function()
				self.imgs[i]:setVisible(true)
			end)))
		else
			self.imgs[i]:setPosition(self.pos[index].pos)
		end

		local shadeImg = self.imgs[i]:getChildByTag(996)
		if shadeImg then
			shadeImg:setOpacity(((index == 1)and 0) or 127.5)
		end
		if i == self.currPos then
			local size = self.imgs[i]:getContentSize()
			if self.lightImg then
				self.lightImg:retain()
				self.lightImg:removeFromParent(false)
			else
				self.lightImg = cc.Sprite:create('uires/ui/treasure/treasure_card_selected.png')
				self.lightImg:retain()
				local count = 0
				local function runNewAction()
					self.lightImg:stopAllActions()
					count = (count + 1)%2
					if count == 1 then
						self.lightImg:runAction(cc.FadeOut:create(2))
					else
						self.lightImg:runAction(cc.FadeIn:create(2))
					end
					self.lightImg:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(runNewAction)))
				end
				runNewAction()
			end
			self.lightImg:setPosition(cc.p(size.width/2,size.height/2))
			self.imgs[i]:addChild(self.lightImg, -1)
			self.lightImg:release()
		end
	end
end

function TreasureUI:createSmallCard(i,point)
	local conf = GameData:getConfData("playerskill")
	local treasureInfo = UserData:getUserObj():getTreasure()
	local currDragon = RoleData:getDragonById(i)
	local id = tonumber(treasureInfo.id)
	if self.currPos > id or not currDragon then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('SKILL_NOT_OPEN'), COLOR_TYPE.RED)
		return
	end
	local img = self.root:getChildByTag(9999)
	if not img then
		img = ccui.ImageView:create()
	    img:loadTexture('uires/ui/treasure/treasure_kapai.png')
	    local size = img:getContentSize()
	    local longSpine = GlobalApi:createLittleLossyAniByName(conf[i].res)
	    longSpine:setPosition(cc.p(size.width/2,size.height/2 - 100))
	    longSpine:getAnimation():play('idle', -1, 1)
	    longSpine:setScale(0.6)
	    -- local fangdaImg = ccui.ImageView:create('uires/ui/common/fangda.png')
	    -- fangdaImg:setPosition(cc.p(size.width - 27,size.height - 42))
	    local cellImg = ccui.ImageView:create('uires/ui/treasure/treasure_cell.png')
	    cellImg:setPosition(cc.p(138.85,116.15))
	   	local nameImg = ccui.ImageView:create('uires/ui/treasure/treasure_'..string.gsub(conf[i].icon,'icon','name'))
	    nameImg:setPosition(cc.p(size.width/2 + 10,58))
	    img:addChild(cellImg)
	    img:addChild(nameImg)
	    -- img:addChild(fangdaImg)
	    img:addChild(longSpine)

	    self.root:addChild(img,9,9999)
	    img:runAction(cc.ScaleTo:create(0.2,0.5))
	    local cellImg = self.imgs[i]:getChildByTag(998)
	    self.imgs[i]:setCascadeOpacityEnabled(true)
	    self.imgs[i]:setOpacity(127.5)
	    cellImg:setOpacity(20)
	end
    img:setPosition(point)
end

function TreasureUI:updateSkills(index)
	for k,v in pairs(self.skillsTab) do
		if v.id == self.currPos then
			self.skillsTab[k].id = 0
			self.skillsTab[k].level = 0
		end
	end
	local currDragon = RoleData:getDragonById(self.currPos)
	self.skillsTab[tostring(index)].id = self.currPos
	self.skillsTab[tostring(index)].level = currDragon:getLevel()
	if self.guidCallback then
		self.guidCallback()
		self.guidCallback = nil
		local hand = self.root:getChildByName("guide_finger")
		if hand then
			hand:removeFromParent()
		end
		local closeBtn = self.root:getChildByName("close_btn")
	    local helpbtn = self.root:getChildByName('help_btn')
	    closeBtn:setTouchEnabled(true)
	    helpbtn:setTouchEnabled(true)
	    self.tameBtn:setTouchEnabled(true)
	    for i,v in ipairs(self.skillImgs) do
	    	v:setTouchEnabled(true)
	    end
		for i=2,self.num do
			-- local fangdaImg = self.imgs[i]:getChildByTag(993)
			-- fangdaImg:setTouchEnabled(true)
		end
	end
	self:updateSkillImgs()
end

function TreasureUI:samllCardFly(img)
	local size = self.imgs[self.currPos]:getContentSize()
	local beginPoint = self.imgs[self.currPos]:convertToWorldSpace(cc.p(size.width/2,size.height/2))
	img:runAction(cc.Sequence:create(cc.MoveTo:create(0.4,beginPoint),cc.CallFunc:create(function()
		local cellImg = self.imgs[self.currPos]:getChildByTag(998)
	    self.imgs[self.currPos]:setCascadeOpacityEnabled(true)
		self.imgs[self.currPos]:setOpacity(255)
		cellImg:setOpacity(255)
		img:removeFromParent()
	end)))
	img:runAction(cc.ScaleTo:create(0.4,1))
end

function TreasureUI:changeSkills()
	local img = self.root:getChildByTag(9999)
	if img then
		local posX,posY = img:getPositionX()*0.7,img:getPositionY()*0.7
		local diffX = (self.posXs.max - self.posXs.min)/5
		if posX <= self.posXs.max and posX >= self.posXs.min and posY <= self.posYs.max and posY >= self.posYs.min then
			local beginX = posX - self.posXs.min
			local index = (beginX - beginX%diffX)/diffX + 1
			if index >= 1 and index <= 5 then
				if self.slotOpend[index]  == true then
					if self.skillsTab[tostring(index)].id ~= self.currPos then
						img:removeFromParent()
						self.imgs[self.currPos]:setOpacity(255)
						local size = self.skillImgs[index]:getContentSize()
						local skillSet = GlobalApi:createLittleLossyAniByName('ui_treasure_skill_set')
					    skillSet:setPosition(cc.p(size.width/2,size.height/2 - 17))
					    skillSet:setScale(1.6)
					    skillSet:setLocalZOrder(3)
					    self.skillImgs[index]:addChild(skillSet)
					    local function movementFun(armature, movementType, movementID)
					        if movementType == 1 then
					            skillSet:removeFromParent()
					        elseif movementType == 0 then
					        	self:updateSkills(index)
					        	self:setImgsPosition()
					        end
					    end
					    skillSet:getAnimation():setMovementEventCallFunc(movementFun)
					    skillSet:getAnimation():playWithIndex(0, -1, -1)
					else
						img:removeFromParent()
						self.imgs[self.currPos]:setOpacity(255)
					end
				else
					promptmgr:showSystenHint(GlobalApi:getLocalStr('SKILL_SLOT_NOT_OPEN'), COLOR_TYPE.RED)
					self:samllCardFly(img)
				end
			end
		else
			self:samllCardFly(img)
		end
	end
end

--右边可滑动的法宝
function TreasureUI:createTreasure()
	local treasureInfo = UserData:getUserObj():getTreasure()
	local conf = GameData:getConfData("playerskill")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.imgs = {}

    for i=1,self.num do
		local dragon = RoleData:getDragonById(i)
    	local img = ccui.ImageView:create('uires/ui/treasure/treasure_kapai.png')
	    local index = (i-self.currPos)%self.num + 1
	    img:setPosition(self.pos[index].pos)
	    img:setLocalZOrder(self.pos[index].zorder)
	    self.imgs[i] = img

	    local size = img:getContentSize()
	    img:setTouchEnabled(true)
	    
	    img:setCascadeOpacityEnabled(true)
	    self.pl:addChild(img)

	    -- local fangdaImg = ccui.Button:create('uires/ui/common/fangda.png')
	    -- fangdaImg:setPosition(cc.p(size.width - 15,size.height - 42))
        local longSpine = GlobalApi:createLittleLossyAniByName(conf[i].res)
	    longSpine:setPosition(cc.p(size.width/2,size.height/2 - 100))
	    longSpine:getAnimation():play('idle', -1, 1)
	    longSpine:setScale(0.6)
	    local cellImg = ccui.ImageView:create('uires/ui/treasure/treasure_cell.png')
	    cellImg:setPosition(cc.p(138.85,116.15))
	    local shadeImg = ccui.ImageView:create('uires/ui/treasure/treasure_kaipai_shade.png')
	    shadeImg:setPosition(cc.p(size.width/2,size.height/2))
	    local lockImg = ccui.ImageView:create('uires/ui/treasure/treasure_lock.png')
	    lockImg:setPosition(cc.p(size.width/2,size.height/2 - 30))
	   	local nameImg = ccui.ImageView:create('uires/ui/treasure/treasure_'..string.gsub(conf[i].icon,'icon','name'))
	    nameImg:setPosition(cc.p(size.width/2 + 10,size.height - 25))

	    --法宝星级
	    local starImgBg = ccui.ImageView:create('uires/ui/treasure/terasure_003.png')
	    starImgBg:setName("starImg")
	    starImgBg:setAnchorPoint(cc.p(0.5,1))
	    starImgBg:setPosition(starImgBg:getContentSize().width + 10, size.height - 50)

	    local starImgBgSize = starImgBg:getContentSize()
	    for i=1,5 do
	    	local starImg = ccui.ImageView:create('uires/ui/treasure/terasure_002.png')
	    	starImg:setName("starImg"..i)
	    	starImg:setPosition(starImgBgSize.width/2, starImgBgSize.height - 26 - (23)*i)
	    	starImgBg:addChild(starImg)
	    end

	    local installImg = ccui.ImageView:create('uires/ui/treasure/treasure_choose_2.png')
	    installImg:setPosition(starImgBgSize.width/2, starImgBgSize.height - installImg:getContentSize().height)
	    installImg:setName("installImg")
	    starImgBg:addChild(installImg)

	    if dragon then
		    local level = cc.Label:createWithTTF("", 'font/gamefont.ttf', 24)
		    level:setTextColor(cc.c3b(50,53,62))
		    level:setPosition(size.width/2 + 35 + nameImg:getContentSize().width/2, size.height - 25)
		    level:setString("lv."..dragon:getLevel())
	    	img:addChild(level,3,999)
		end

	    if i == self.currPos then
	    	shadeImg:setOpacity(0)
	    else
	    	shadeImg:setOpacity(127.5)
	    end
	    img:addChild(starImgBg,2,999)
	    img:addChild(cellImg,2,998)
	    img:addChild(nameImg,1,995)
	    img:addChild(lockImg,3,997)
	    img:addChild(shadeImg,4,996)
	    img:addChild(longSpine,1,994)
	 --    img:addChild(fangdaImg,3,993)
	 --    fangdaImg:setTouchEnabled(true)
	 --    fangdaImg:addTouchEventListener(function (sender, eventType)
		-- 	if eventType == ccui.TouchEventType.began then
	 --            AudioMgr.PlayAudio(11)
	 --        elseif eventType == ccui.TouchEventType.ended then
		--         MainSceneMgr:showDragonInfoUI(i)
		-- 	end
		-- end)

	    local scheduler = img:getScheduler()
		local beginPoint
		local isCreate = false
		local currPos = i
		img:setSwallowTouches(true)
		img:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
            	AudioMgr.PlayAudio(11)
	        	beginPoint = sender:getTouchBeganPosition()
	        	if self.schedulerEntry then
	        		scheduler:unscheduleScriptEntry(self.schedulerEntry)
	        	end
	        	-- self.schedulerEntry = scheduler:scheduleScriptFunc(function()
	        	-- 	if self.isMove == true or currPos ~= self.currPos then
	        	-- 		scheduler:unscheduleScriptEntry(self.schedulerEntry)
	        	-- 		return
	        	-- 	end
	        	-- 	if isCreate == false and self.isMove == false and currPos == self.currPos then
	        	-- 		self.pl:setTouchEnabled(false)
	        	-- 		isCreate = true
		        -- 		self:createSmallCard(i,beginPoint)
		        -- 	end
	        	-- end,0.2,false)
	        elseif eventType == ccui.TouchEventType.moved then
	        	beginPoint = sender:getTouchMovePosition()
	        	if isCreate == true then
		        	self:createSmallCard(i,beginPoint)
		        end
		    else
		    	if not self.isMove then
		    		local id = tonumber(treasureInfo.id)
		    		if i <= id then 
			    		MainSceneMgr:showDragonInfoUI(i)
			    	else
			    		promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_OPEN_YET'),COLOR_TYPE.RED)
			    	end
			    end
	        	-- if self.schedulerEntry then
	        	-- 	scheduler:unscheduleScriptEntry(self.schedulerEntry)
	        	-- end
	        	-- isCreate = false
	        	-- if self.cannotMove ~= true then
	        	-- 	self.pl:setTouchEnabled(true)
	        	-- end
	        	-- self:changeSkills()
	        end
	    end)
    end
end

function TreasureUI:onShow()
	if self.notOnshow then
		self.notOnshow = nil
		return
	end
    self:updatePanel()
	self:runFightforce()
end

function TreasureUI:runFightforce()
	local newFightForce = self:getFightForce()
	if self.oldFightForce ~= newFightForce then
		self.fightForceLabel:stopAllActions()
		self.fightForceLabel:runAction(cc.DynamicNumberTo:create("LabelAtlas", 1, newFightForce))
		self.oldFightForce = newFightForce
	end
end

function TreasureUI:getFightForce()
	local attconf = GameData:getConfData('attribute')
	local attcount = #attconf
	local att = {}
	for i=1,attcount do
		att[i] = 0
	end

	local dragonTotalAttr = {}
	local dragons = RoleData:getDragonMap()
	for k, dragon in pairs(dragons) do
	    local dragonAttr = dragon:getAttr()
	    for k2, v2 in pairs(dragonAttr) do
	        dragonTotalAttr[k2] = dragonTotalAttr[k2] or 0
            dragonTotalAttr[k2] = dragonTotalAttr[k2] + v2
	    end
	end
	for i, value in pairs(dragonTotalAttr) do
		att[i] =  att[i] + math.floor(value)
	end

	local fightForce = 0
	for i = 1,8 do
		fightForce = fightForce + att[i]*attconf[i].factor
	end

	local roleMap = RoleData:getRoleMap()
    local roleCount = 0
    for k,v in pairs(roleMap) do
        if v and v:getId() > 0 then
            roleCount = roleCount + 1
        end
    end
    fightForce = math.floor(fightForce*roleCount)

	return fightForce
end

local function sortFn(a, b)
    local q1 = a:getQuality()
    local q2 = b:getQuality()
    local level1 = (a.getGodLevel and a:getGodLevel()) or 0
    local level2 = (b.getGodLevel and b:getGodLevel()) or 0
    if q1 == q2 then
    	if level1 == level2 then
	        local l1 = a:getLevel()
	        local l2 = b:getLevel()
	        if l1 == l2 then
	        	local id1 = a:getId()
	        	local id2 = b:getId()
	        	return id1 < id2
	        else
	        	return l1 > l2
	        end
	    else
	    	return level1 > level2
	    end
    else
        return q1 > q2
    end
end

function TreasureUI:updateAttr()
	local conf = GameData:getConfData("treasure")
	local dragon = RoleData:getDragonById(self.currPos)
	local treasureInfo = UserData:getUserObj():getTreasure()
	local isVisible = false
	if self.currPos > treasureInfo.id then
		isVisible = true
	else
		isVisible = false
	end
	self.attrPl:setVisible(isVisible)
	self.descPl:stopAllActions()
	self.descPl:setVisible(true)
	self.descPl:setOpacity(255)
	self.attrPl:stopAllActions()
	if isVisible then
		self.descPl:setOpacity(0)
		self.descPl:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
			cc.DelayTime:create(1.5),
			cc.FadeIn:create(1.5),
			cc.DelayTime:create(0.5),
			cc.FadeOut:create(1.5),
			cc.DelayTime:create(2)
			)))
		self.attrPl:setOpacity(255)
		self.attrPl:runAction(cc.RepeatForever:create(
			cc.Sequence:create(
			cc.FadeOut:create(1.5),
			cc.DelayTime:create(3.5),
			cc.FadeIn:create(1.5),
			cc.DelayTime:create(0.5)
			)))
	end			
end

function TreasureUI:setCurrPos(currPos)
	self.currPos = currPos or 1
end

function TreasureUI:updatePanel()
	self:updateBottomPanel()
	self:updateSpine()
	self:updateLeftPanel()
	self:updateRideBtn()
	self:setImgsPosition()
	self:updateAttr()
end

function TreasureUI:getMove(index,bgPanelPos,bgPanelPrePos)
	local bgPanelDiffPos = nil
	local isEnd = false
	local diffPosX = (bgPanelPos.x - bgPanelPrePos.x)/2
    local per = math.abs(diffPosX/self.maxLen)
    local per1
	local lePosX,lePosY,sPosX,sPosY,cPosX,cPosY,rePosX,rePosY
	local startIndex = (index-self.currPos)%self.num + 1
	local lEndIndex = (index-self.currPos - 1)%self.num + 1
	local rEndIndex = (index-self.currPos + 1)%self.num + 1
	if startIndex == 7 then
		self.imgs[index]:setVisible(false)
	end
	lePosX = self.pos[lEndIndex].pos.x
	lePosY = self.pos[lEndIndex].pos.y
	rePosX = self.pos[rEndIndex].pos.x
	rePosY = self.pos[rEndIndex].pos.y
	sPosX = self.pos[startIndex].pos.x
	sPosY = self.pos[startIndex].pos.y
	cPosX = self.imgs[index]:getPositionX()
	cPosY = self.imgs[index]:getPositionY()
	local isBig
	local diffPosX1
	local scale = 0.7
	local shade = 127.5
	if cPosX < sPosX then
		if diffPosX < 0 then
			bgPanelDiffPos = cc.p(per*(lePosX - sPosX),per*(lePosY - sPosY))
		else
			bgPanelDiffPos = cc.p(per*(sPosX - lePosX),per*(sPosY - lePosY))
		end
		isBig = self.currPos%self.num + 1
		diffPosX1 = lePosX - sPosX
	elseif cPosX > sPosX then
		if diffPosX < 0 then
			bgPanelDiffPos = cc.p(per*(sPosX - rePosX),per*(sPosY - rePosY))
		else
			bgPanelDiffPos = cc.p(per*(rePosX - sPosX),per*(rePosY - sPosY))
		end
		isBig = (self.currPos - 2)%self.num + 1
		diffPosX1 = rePosX - sPosX
	else
		if diffPosX < 0 then
			bgPanelDiffPos = cc.p(per*(lePosX - sPosX),per*(lePosY - sPosY))
			isBig = self.currPos%self.num + 1
			diffPosX1 = lePosX - sPosX
		else
			bgPanelDiffPos = cc.p(per*(rePosX - sPosX),per*(rePosY - sPosY))
			isBig = (self.currPos - 2)%self.num + 1
			diffPosX1 = rePosX - sPosX
		end
	end
	local pos = cc.pAdd(cc.p(cPosX,cPosY),bgPanelDiffPos)
	local diffLendX = pos.x - lePosX
	local diffLharfEndX = pos.x - ((lePosX + sPosX)/2)
	local diffRendX = pos.x - rePosX
	local diffRharfEndX = pos.x - ((rePosX + sPosX)/2)
	local diffStartX = pos.x - sPosX
	local per1 = (pos.x - sPosX)/diffPosX1
	if index == self.currPos then
		scale = 1 - 0.3*per1
		shade = 127.5*per1
	elseif index == isBig then
		scale = 0.7 + 0.3*per1
		shade = 127.5 - 127.5*per1
	end
	shade = ((shade < 0 ) and 0) or shade
	local bCanMove = false
	if startIndex == 1 then
		if math.abs(diffStartX) > 0 and self.isMove == false then
			self.isMove = true
		end
		if (diffLendX >= 0 and diffRendX <= 0) then
			isEnd = false
		elseif diffLendX < 0 then
			self.currPos = self.currPos%self.num + 1
			isEnd = true
		elseif diffRendX > 0 then
			self.currPos = (self.currPos - 2)%self.num + 1
			isEnd = true
		end
		if isEnd == false then
			if diffLharfEndX < 0 then
				self.currPos1 = self.currPos%self.num + 1
			elseif diffRharfEndX > 0 then
				self.currPos1 = (self.currPos - 2)%self.num + 1
			else
				self.currPos1 = self.currPos
			end
		end
	end
    return isEnd,pos,scale,shade
end

function TreasureUI:scroll()
	print('=================')
end

function TreasureUI:registerHandler()
	local bgPanelPrePos = nil
    local bgPanelPos = nil
    self.isMove = false
    self.pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
        	if self.canMove == false then
        		return
        	end
            bgPanelPrePos = bgPanelPos
            bgPanelPos = sender:getTouchMovePosition()
            if bgPanelPrePos then
            	local isEnd = self:getMove(self.currPos,bgPanelPos,bgPanelPrePos)
            	if isEnd == false then
            		for i=1,self.num do
            			local _,pos,scale,shade = self:getMove(i,bgPanelPos,bgPanelPrePos)
            			self.imgs[i]:setPosition(pos)
            			self.imgs[i]:setScale(scale)
            			local shadeImg = self.imgs[i]:getChildByTag(9999)
            			if shadeImg then
            				shadeImg:setOpacity(shade)
            			end
            		end
            	else
            		if GuideMgr:isRunning() == true and self.currPos == 2 then
            			self.pl:setTouchEnabled(false)
            			self.isMove = false
            			self:scroll()
            		end
			    	bgPanelPrePos = nil
			    	self:setImgsPosition()
			    	self:updatePanel()
			    	self.pl:setTouchEnabled(true)
            	end
            end
        else
            bgPanelPrePos = nil
            bgPanelPos = nil
            if eventType == ccui.TouchEventType.began then
            	AudioMgr.PlayAudio(11)
            	self.currPos1 = self.currPos
            else
            	self.currPos = self.currPos1
            	if self.isMove == true then
            		self.currPos = self.currPos1
            		self:setImgsPosition()
            		self:updatePanel()
            	end
            	self.isMove = false
            end
        end
    end)
end

function TreasureUI:sendSkillsChange(callback)
	local tab = {}
	local isChange = false
	for k,v in pairs(self.skillsTab) do
		tab[tonumber(k)] = v.id
		isChange = isChange or (v.id ~= self.oldSkills[k].id)
	end
	if isChange == false then
		if callback then
			callback()
		end
		return
	end
	local args = {skills = tab}
    MessageMgr:sendPost('set_skills','treasure',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
        	UserData:getUserObj():setSkills(self.skillsTab)
			if callback then
				callback()
			end
        end
    end)
end

function TreasureUI:getMaxDragon()
	local treasureInfo = UserData:getUserObj():getTreasure()
	local dragonInfo = RoleData:getDragonMap()
	self.maxDragon = 1
	for k,v in pairs(dragonInfo) do
		local level = v:getLevel()
		if level > 0 then
			self.maxDragon = self.maxDragon + 1
		end
	end
end

function TreasureUI:closeDragonGemBag()
	self.addBtnIndex = 0
	self.dragonBagImg:setVisible(false)
	self.dragonGemSelectImg:setVisible(false)
end

function TreasureUI:init()
    local closeBtn = self.root:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			-- self:sendSkillsChange(function()
			-- 	local roleObj = RoleData:getMainRole()
			-- 	roleObj:setDragon()
				MainSceneMgr:hideTreasure()
			-- end)
		end
	end)

	local winSize = cc.Director:getInstance():getVisibleSize()
	self.bgImg = self.root:getChildByName("bg_img")
	self:adaptCenterUI(self.bgImg)
    self.rightBottomImg = self.root:getChildByName("right_bottom_img")

    self.chooseNode = self.root:getChildByName("choose_node")
    self.chooseNode:setVisible(false)

    self.leftTopImg = self.root:getChildByName("left_top_img")
    self.rightPl = self.root:getChildByName("right_pl")
    self.pl = self.rightPl:getChildByName("pl")

    local leftZdImg = self.root:getChildByName("left_zd_img")
    local rightZdImg = self.root:getChildByName("right_zd_img")
    self.leftBottomImg = self.root:getChildByName("left_bottom_img")

    local helpbtn = self.root:getChildByName('help_btn')
    helpbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	HelpMgr:showHelpUI(13)
		end
	end)
	local conf = GameData:getConfData("treasure")
	local attributeConf = GameData:getConfData("attribute")
	self.attrPl = self.leftBottomImg:getChildByName('attr_pl')
	self.descPl = self.leftBottomImg:getChildByName('desc_pl')
	local descTx = self.attrPl:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr('DRAGON_MERGE_DESC_5'))
	self.numTxs = {}
	for i=1,4 do
    	local descTx = self.attrPl:getChildByName('desc_tx_'..i)
    	local numTx = self.attrPl:getChildByName('num_tx_'..i)
    	descTx:setString(attributeConf[conf[self.currPos][#conf[self.currPos]]['attr'..i]].name)
    	self.numTxs[i] = numTx
    end
	self.tameBtn = self.leftBottomImg:getChildByName('tame_btn')
	local infoTx = self.tameBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_TAME'))
	self.tameBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local desc,isOpen = GlobalApi:getGotoByModule("digging",true)
            if desc then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("FUNCTION_DESC_1") .. desc .. GlobalApi:getLocalStr("FUNCTION_DESC_2"), COLOR_TYPE.RED)
           	else
           		local dragonInfo = RoleData:getDragonMap()[self.currPos]
	        	if not dragonInfo then
	        		self:getMaxDragon()
	        		self.currPos = self.maxDragon
	        	end
	        	MainSceneMgr:showInlayDragonGemUI(self.currPos)
            end
		end
	end)

    local size1 = self.leftBottomImg:getContentSize()
    self.bgImg:setPosition(cc.p(winSize.width / 2,winSize.height / 2))

    self.rightBottomImg:setContentSize(cc.size(winSize.width - size1.width + 10,130))
    self.rightBottomImg:setPosition(cc.p(winSize.width,0))
    local size2 = self.rightBottomImg:getContentSize()
    local width = (winSize.width - size1.width - 500)/3

    self.descPos = cc.p(size1.width + width,size2.height/2 + 3)

    self.leftBottomImg:setPosition(cc.p(winSize.width/2 - 5,winSize.height/2 - 150))
    self.leftTopImg:setPosition(cc.p(9.5,winSize.height))
    self.chooseNode:setPosition(cc.p(winSize.width/2,winSize.height/2))

    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    helpbtn:setPosition(cc.p(helpbtn:getPositionX(),winSize.height-10))

    rightZdImg:setContentSize(cc.size(rightZdImg:getContentSize().width,winSize.height - size2.height))
    rightZdImg:setPosition(cc.p(winSize.width,size2.height))

    leftZdImg:setContentSize(cc.size(leftZdImg:getContentSize().width,winSize.height - size2.height))
    leftZdImg:setPosition(cc.p(size1.width - 1,size2.height))

	local allFightforce = self.root:getChildByName('all_fightforce')
	allFightforce:setString(GlobalApi:getLocalStr('TREASURE_DESC_16'))
	allFightforce:setPosition(cc.p(helpbtn:getPositionX() + 15,helpbtn:getPositionY() - 11))
	self.allFightforce = allFightforce

	self.oldFightForce = self:getFightForce()
	local fightForceLabel = cc.LabelAtlas:_create(self.oldFightForce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	fightForceLabel:setAnchorPoint(cc.p(0,1))
	fightForceLabel:setPosition(cc.p(allFightforce:getPositionX() + 90,allFightforce:getPositionY() - 2))
	fightForceLabel:setScale(0.7)
	self.root:addChild(fightForceLabel)
	self.fightForceLabel = fightForceLabel

    self.rightPl:setPosition(cc.p(0,size2.height))
    self.rightPl:setContentSize(cc.size(winSize.width,winSize.height - size2.height))
    self.pl:setContentSize(cc.size(winSize.width,winSize.height - size2.height))
    self.pl:setPosition(cc.p(0,0))
    self.maxLen = (winSize.width)/3
    local function getPos(i)
    	local width = winSize.width - size1.width
    	local height = size2.height/3*2 - 10
    	return cc.p((2*i -1)/10*width,height)
    end
    local pos = getPos(3)

    --底部法宝栏
    self.skillImgs = {}
    for i=1,5 do
		local skillImg = self.bgImg:getChildByName('treasure_'..i..'_img')
		-- skillImg:setPosition(getPos(i))
		skillImg:setTouchEnabled(true)
		self.skillImgs[i] = skillImg
		skillImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	self:showChooseNode(i)
				-- if self.slotOpend[i]  == true then
				-- 	if self.skillsTab[tostring(i)].id and self.skillsTab[tostring(i)].id > 1 then
				-- 		local desc,isOpen = GlobalApi:getGotoByModule("digging",true)
			 --            if desc then
			 --                promptmgr:showSystenHint(GlobalApi:getLocalStr("FUNCTION_DESC_1") .. desc .. GlobalApi:getLocalStr("FUNCTION_DESC_2"), COLOR_TYPE.RED)
			 --           	else
				--         	MainSceneMgr:showInlayDragonGemUI(self.skillsTab[tostring(i)].id)
				--         end
				--     else
				-- 		self:showChooseNode(i)
				-- 	end
				-- end
	        end
	    end)
	end

	self:getMaxDragon()
	self:initPos()
    self:registerHandler()
    self:createTreasure()
    self:setImgsPosition()
    self:updatePanel()
    self:updateSpine()
    self:updateAttr()

    if not GuideMgr:isRunning() then
	    local currDragon = UserData:getUserObj():getTreasure().id
	    for i=1,currDragon do
	    	if not RoleData:getDragonById(i) and i ~= 1 then
	    		local treasureInfo = UserData:getUserObj():getTreasure()
	            local active = tonumber(treasureInfo.active)
	            RoleData:createDragon(i,{level = 1})
	    		MainSceneMgr:showDragonInfoUI(i,nil,function ()
	                local args = {}
	                MessageMgr:sendPost('active','treasure',json.encode(args),function (response)
	                    local code = response.code
	                    local data = response.data
	                    if code == 0 then
	                        RoleData:setAllFightForceDirty()

	                        treasureInfo.active = treasureInfo.active + 1
	                        UserData:getUserObj():setTreasure(treasureInfo)

	                        if data.awards then
	                            GlobalApi:parseAwardData(data.awards)
	                        end
	                        if data.costs then
	                            GlobalApi:parseAwardData(data.costs)
	                        end

	                        for j=1,7 do
	                            local obj = RoleData:getRoleByPos(j)
	                            if obj and obj:getId() > 0 then
	                                RoleMgr:popupTips(obj,true)
	                            end
	                        end

	                        MainSceneMgr:showTreasure(i)
	                    end
	                    self:updatePanel()
	                end)
	            end)
	    	end
	    end
	end

    self:showChooseNode(0)
end

function TreasureUI:popupTips(oldatt,newatt,oldfightforce,newfightforce)
	--local time1 = socket.gettime()
	local attchange = {}
	local arr1 = newatt
	local arr2 = oldatt
	local attconf =GameData:getConfData('attribute')
	local isnew = true
	local attcount = #attconf
	for i=1,attcount do
		if arr2[i] -arr1[i]  ~= 0 then
			isnew = false
		end
	end
	local showWidgets = {}
	if isnew == false then
		for i = 1,attcount do
			attchange[i] = arr1[i] - arr2[i]
			local desc = attconf[i].desc
			if desc == "0" then
				desc = ''
			end
			if attchange[i] > 0 then

				local str = math.abs(math.floor(attchange[i]))
				local name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' + '.. str..desc
				local color = COLOR_TYPE.GREEN
				if i == 10 then
					name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' - '.. str..desc
					color = COLOR_TYPE.RED
				end
				local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
				w:setTextColor(color)
				w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
				w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
				table.insert(showWidgets, w)
			elseif attchange[i] < 0 then
				local str = math.abs(math.floor(attchange[i]))
				local name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' - '.. str..desc
				local color = COLOR_TYPE.RED
				if i == 10 then
					name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' + '.. str..desc
					color = COLOR_TYPE.GREEN
				end
				
				local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
				w:setTextColor(color)
				w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
				w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
				table.insert(showWidgets, w)
			end

		end
		if newfightforce - oldfightforce > 0 then
			local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' + '.. math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 26)
			w:setTextColor(cc.c3b(0,252,255))
			w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		elseif newfightforce - oldfightforce < 0 then
			local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' - '..math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 24)
			w:setTextColor(COLOR_TYPE.RED)
			w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		end
		promptmgr:showAttributeUpdate(showWidgets)
	end
end

function TreasureUI:guideEquipDragon(callback)
    local closeBtn = self.root:getChildByName("close_btn")
    local helpbtn = self.root:getChildByName('help_btn')
    helpbtn:setTouchEnabled(false)
    closeBtn:setTouchEnabled(false)
    self.pl:setTouchEnabled(false)
    self.tameBtn:setTouchEnabled(false)
    for i,v in ipairs(self.skillImgs) do
    	v:setTouchEnabled(false)
    end
    self.notOnshow = true
	for i=2,self.num do
		-- local fangdaImg = self.imgs[i]:getChildByTag(993)
		-- fangdaImg:setTouchEnabled(false)
	end
    self.cannotMove = true
    local hand = GlobalApi:createLittleLossyAniByName("guide_finger")
    hand:getAnimation():play("idle02", -1, -1)
    hand:getAnimation():gotoAndPause(0)
    hand:setRotation(120)
    self.root:addChild(hand)
    local startPos = self.pl:convertToWorldSpace(cc.p(self.imgs[self.currPos]:getPosition()))
    local endPos = cc.pAdd(self.rightBottomImg:convertToWorldSpace(cc.p(self.skillImgs[self.currPos]:getPosition())), cc.p(-20, 0))
    hand:setPosition(startPos)
    hand:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveTo:create(1, endPos), cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
        hand:setPosition(startPos)
    end))))
    self.guidCallback = callback
end

return TreasureUI