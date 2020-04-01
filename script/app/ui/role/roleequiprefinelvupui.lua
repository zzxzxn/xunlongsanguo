local EquipRefineLvUpUI = class("EquipRefineLvUpUI", BaseUI)

local TITLE_IMG = {
	'uires/ui/text/qianghuachenggong.png',
	'uires/ui/text/shenqidashi.png',
	'uires/ui/text/baoshidashi.png',
	'uires/ui/text/jingliandashi.png',
}
function EquipRefineLvUpUI:ctor(pos,equipPos,currLevel,nextLevel,page,callback)
	self.uiIndex = GAME_UI.UI_EQUIP_REFINE_LV_UP
	self.pos = pos
	self.obj = RoleData:getRoleByPos(pos)
	self.equipPos = equipPos
	self.currLevel = currLevel
	self.nextLevel = nextLevel
	self.page = page or 1
	self.callback = callback
end

function EquipRefineLvUpUI:createAnimation(name, framecount)
	local cache = cc.SpriteFrameCache:getInstance()
	cache:addSpriteFrames('uires/ui/role/role_upgrade_star/' .. name .. '.plist', 'uires/ui/role/role_upgrade_star/' .. name .. '.png')
	local animFrames = {}
	for i = 0, framecount do
	    animFrames[i] = cache:getSpriteFrame(string.format('%s%d.png', name, i))
	end
	return cc.Animation:createWithSpriteFrames(animFrames, 0.1)
end

function EquipRefineLvUpUI:updatePanel3(suitConf)
	local winSize = cc.Director:getInstance():getWinSize()
	local bg1 = self.bg:getChildByName('page_node_3')
	bg1:setPosition(cc.p(winSize.width/2,winSize.height/2))

	local titleTx = bg1:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('SUIT_DESC_15'))
	local sv = bg1:getChildByName('sv')
	sv:setScrollBarEnabled(false)

	local obj = RoleData:getRoleByPos(self.pos)
	local oldData,newData = obj:getSuitData()

	local maxNum = 0
	local tab = {}
	for k,v in pairs(newData) do
		for k1,v1 in pairs(v) do
			if not oldData[k][k1] then
				if not tab[k] then
					tab[k] = {}
					maxNum = maxNum + 1
				end
				tab[k][k1] = 1
				maxNum = maxNum + 1
			end
		end
	end
	local size = sv:getContentSize()
    if maxNum >= 5 then
    	sv:setContentSize(cc.size(820,320))
	    if maxNum * 60 > size.height then
	        sv:setInnerContainerSize(cc.size(size.width,maxNum * 60))
	    else
	        sv:setInnerContainerSize(size)
	    end
    	sv:setAnchorPoint(cc.p(0.5,1))
    	sv:setPosition(cc.p(0,122))
    else
    	sv:setContentSize(cc.size(820,maxNum * 60))
    	sv:setInnerContainerSize(cc.size(size.width,maxNum * 60))
    	sv:setPosition(cc.p(0,80))
    end
    local size = sv:getInnerContainerSize()
	local num = 0
    local function createCell(k,k1,isTitle)
        local cellNode = cc.CSLoader:createNode("csb/equiprefinelvupcell.csb")
        local bgImg = cellNode:getChildByName('bg_img')
        bgImg:removeFromParent(false)
        sv:addChild(bgImg)
        bgImg:setPosition(cc.p(size.width/2,size.height - (num - 1)*60 - 30))
        bgImg:setOpacity(0)

        bgImg:runAction(cc.Sequence:create(cc.DelayTime:create(num*0.1),cc.FadeIn:create(0.5)))
        local conf = suitConf[tonumber(k)]
        local titleTx = bgImg:getChildByName('title_tx')
        local descTx = bgImg:getChildByName('desc_tx')
        local arrowImg = bgImg:getChildByName('arrow_img')
        if isTitle then
        	titleTx:setString('Lv.'..conf.id..' '..conf.name)
        	descTx:setString('')
        	arrowImg:setVisible(false)
        	return
        end
        titleTx:setString('')
        descTx:setString(k1..GlobalApi:getLocalStr('SUIT_DESC_1'))
		local attributeConf = GameData:getConfData("attribute")
		local attributes = conf['attribute'..k1]
		for i,v in ipairs(attributes) do
			local attrTab = string.split(v, ':')
			local per = (attributeConf[tonumber(attrTab[1])].desc == '0') and '' or '%'
		    local richText = xx.RichText:create()
		    richText:setContentSize(cc.size(300, 24))
		    richText:setAlignment('left')
		    richText:setVerticalAlignment('middle')
		    richText:setCascadeOpacityEnabled(true)
			local re1 = xx.RichTextLabel:create(attributeConf[tonumber(attrTab[1])].name, 24, COLOR_TYPE.WHITE)
			local re2 = xx.RichTextLabel:create(' +'..tonumber(attrTab[2])..per, 24, COLOR_TYPE.GREEN)
			local re3 = xx.RichTextImage:create('uires/ui/common/arrow1.png')
			re3:setScale(1.4)
			re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
			re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
			richText:addElement(re1)
			richText:addElement(re2)
			richText:addElement(re3)
			richText:setAnchorPoint(cc.p(0,0.5))
			bgImg:addChild(richText)
			if i == 1 then
				richText:setPosition(cc.p(272,30))
			else
				richText:setPosition(cc.p(495,30))
			end
		end
    end
    for k,v in pairs(tab) do
    	num = num + 1
    	createCell(k,k1,true)
    	for k1,v1 in pairs(v) do
    		num = num + 1
    		createCell(k,k1)
    	end
    end
	self.bg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            if self.callback then
            	self.callback()
            end
            RoleMgr:hideEquipRefineLvUp()
        end
    end)
end

function EquipRefineLvUpUI:updatePanel2(suitConf)
	local winSize = cc.Director:getInstance():getWinSize()
	local bg1 = self.bg:getChildByName('page_node_2')
	local sv = bg1:getChildByName('sv')
	bg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
	sv:getChildByName('light')
		:runAction(cc.RepeatForever:create(
			cc.RotateBy:create(0.5, 20)))

	local upgradeBg = bg1:getChildByName('upgrade_bg')
	local titleTx = upgradeBg:getChildByName('title_tx')
	titleTx:loadTexture(TITLE_IMG[self.page])
	local conf = suitConf[self.currLevel]
	local conf1 = suitConf[self.nextLevel]
	local attributeConf = GameData:getConfData("attribute")
	local lvTx1 = upgradeBg:getChildByName('lv_tx_1')
	local lvTx2 = upgradeBg:getChildByName('lv_tx_2')
	local arrowImg1 = upgradeBg:getChildByName('arrow_img_1')
	local arrowImg3 = upgradeBg:getChildByName('arrow_img_3')
	lvTx1:setString('Lv.'..self.currLevel)
	lvTx2:setString('Lv.'..self.nextLevel)
	lvTx1:setVisible(false)
	lvTx2:setVisible(false)
	arrowImg1:setVisible(false)
	arrowImg3:setVisible(false)

	local attrTab = {}
	local attrTab1 = {}
	for i,v in pairs(conf.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab[#attrTab + 1] = {name = name,desc = desc}
	end
	for i,v in pairs(conf1.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab1[#attrTab1 + 1] = {name = name,desc = desc}
	end

	local rts = {}
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(300, 24))
    richText:setAlignment('right')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(attrTab[1].name, 30, COLOR_TYPE.RED)
	local re2 = xx.RichTextLabel:create(' +'..attrTab[1].desc, 30, COLOR_TYPE.YELLOW)
	re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:setAnchorPoint(cc.p(1,0.5))
	richText:setPosition(cc.p(225,110))
	upgradeBg:addChild(richText)
	richText:setVisible(false)
	rts[#rts + 1] = richText

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(300, 24))
    richText:setAlignment('right')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(attrTab[2].name, 30, COLOR_TYPE.RED)
	local re2 = xx.RichTextLabel:create(' +'..attrTab[2].desc, 30, COLOR_TYPE.YELLOW)
	re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:setAnchorPoint(cc.p(1,0.5))
	richText:setPosition(cc.p(225,60))
	upgradeBg:addChild(richText)
	richText:setVisible(false)
	rts[#rts + 1] = richText

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(300, 24))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(attrTab1[1].name, 30, COLOR_TYPE.RED)
	local re2 = xx.RichTextLabel:create(' +'..attrTab1[1].desc, 30, COLOR_TYPE.YELLOW)
	local re3 = xx.RichTextImage:create('uires/ui/common/arrow1.png')
	re3:setScale(1.4)
	re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(325,110))
	upgradeBg:addChild(richText)
	richText:setVisible(false)
	rts[#rts + 1] = richText


    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(300, 24))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(attrTab1[2].name, 30, COLOR_TYPE.RED)
	local re2 = xx.RichTextLabel:create(' +'..attrTab1[2].desc, 30, COLOR_TYPE.YELLOW)
	local re3 = xx.RichTextImage:create('uires/ui/common/arrow1.png')
	re3:setScale(1.4)
	re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(325,60))
	upgradeBg:addChild(richText)
	richText:setVisible(false)
	rts[#rts + 1] = richText

	local funcTab = {}
	local pos = {cc.p(250,170),cc.p(250,100),cc.p(250,50)}
	for i = 1, 3 do
		funcTab[i] = function ()
			local flashsp = cc.Sprite:create()
			flashsp:setPosition(pos[i])
			upgradeBg:addChild(flashsp, 9999)
			local flashAni = self:createAnimation('flash', 7)
		    flashsp:setVisible(true)
		    flashsp:runAction(cc.Sequence:create(cc.Animate:create(flashAni), cc.CallFunc:create(function()
					flashsp:removeFromParent()
				end)))

			if i == 1 then
				lvTx1:setVisible(true)
				lvTx2:setVisible(true)
				arrowImg1:setVisible(true)
			elseif i == 2 then
				rts[1]:setVisible(true)
				rts[2]:setVisible(true)
				arrowImg3:setVisible(true)
			else
				rts[3]:setVisible(true)
				rts[4]:setVisible(true)
			end
		end
	end

	self.root:runAction(cc.Sequence:create(cc.CallFunc:create(funcTab[1]), 
		cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[2]), 
		cc.DelayTime:create(0.3), cc.CallFunc:create(funcTab[3]),
		cc.CallFunc:create(function()
		self.bg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
	            if self.callback then
	            	self.callback()
	            end
	            RoleMgr:hideEquipRefineLvUp()
	        end
	    end)
	end)))
end

function EquipRefineLvUpUI:updatePanel1()
	local winSize = cc.Director:getInstance():getWinSize()
	local bg1 = self.bg:getChildByName('page_node_1')
	bg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
	local sv = bg1:getChildByName('sv')
	sv:getChildByName('light')
		:runAction(cc.RepeatForever:create(
			cc.RotateBy:create(0.5, 20)))

	local upgradeBg = bg1:getChildByName('upgrade_bg')
	local titleTx = upgradeBg:getChildByName('title_tx')
	titleTx:loadTexture(TITLE_IMG[self.page])
	local lvs = {self.currLevel,self.nextLevel}
	for i=1,2 do
		local equipBgImg = upgradeBg:getChildByName('skill_bg_'..i)
		local awardBgImg = equipBgImg:getChildByName('award_bg_img')
		local awardImg = awardBgImg:getChildByName('award_img')
		local lvTx = awardBgImg:getChildByName('lv_tx')
		local nameTx = awardBgImg:getChildByName('name_tx')
		lvTx:setString('Lv.'..lvs[i])
		awardImg:loadTexture(DEFAULTEQUIP[self.equipPos])
		awardImg:ignoreContentAdaptWithSize(true)
		nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..self.equipPos))
	end
	local conf = GameData:getConfData("equiprefine")[self.equipPos][self.currLevel]
	local conf1 = GameData:getConfData("equiprefine")[self.equipPos][self.nextLevel]
	local attributeConf = GameData:getConfData("attribute")

	local rts = {}
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(300, 30))
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STRENGTH_JIHUO')..self.nextLevel, 25, COLOR_TYPE.YELLOW)
	local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing.png')
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STRENGTH_ATTR'), 25, COLOR_TYPE.YELLOW)
	re1:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	re3:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(275,100))
	upgradeBg:addChild(richText)
	rts[#rts + 1] = richText

	local attrTab = {}
	for i,v in pairs(conf.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab[#attrTab + 1] = {name = name,desc = desc}
	end
	for i,v in pairs(conf1.attribute) do
		local tab = string.split(v, ':')
		local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
		local name = attributeConf[tonumber(tab[1])].name
		local desc = tonumber(tab[2])..per
		attrTab[#attrTab + 1] = {name = name,desc = desc}
	end

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(200, 24))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(attrTab[1].name, 25, COLOR_TYPE.RED)
	local re2 = xx.RichTextLabel:create(' +'..attrTab[1].desc, 25, COLOR_TYPE.YELLOW)
	re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(115,45))
	upgradeBg:addChild(richText)
	rts[#rts + 1] = richText

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(200, 24))
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	local re1 = xx.RichTextLabel:create(attrTab[2].name, 25, COLOR_TYPE.RED)
	local re2 = xx.RichTextLabel:create(' +'..attrTab[2].desc, 25, COLOR_TYPE.YELLOW)
	local re3 = xx.RichTextImage:create('uires/ui/common/arrow1.png')
	re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
	re2:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(315,45))
	upgradeBg:addChild(richText)
	rts[#rts + 1] = richText

	local equipBgImg1 = upgradeBg:getChildByName('skill_bg_1')
	local equipBgImg2 = upgradeBg:getChildByName('skill_bg_2')
	local arrowImg1 = upgradeBg:getChildByName('arrow_img_1')
	local arrowImg3 = upgradeBg:getChildByName('arrow_img_3')
	equipBgImg1:setOpacity(0)
	equipBgImg2:setOpacity(0)
	arrowImg1:setOpacity(0)
	arrowImg3:setVisible(false)
	rts[1]:setVisible(false)
	rts[2]:setVisible(false)
	rts[3]:setVisible(false)

	local funcTab = {}
	local pos = {cc.p(250,100),cc.p(250,38)}
	for i = 1, 2 do
		funcTab[i] = function ()
			local flashsp = cc.Sprite:create()
			flashsp:setPosition(pos[i])
			upgradeBg:addChild(flashsp, 9999)
			local flashAni = self:createAnimation('flash', 7)
		    flashsp:setVisible(true)
		    flashsp:runAction(cc.Sequence:create(cc.Animate:create(flashAni), cc.CallFunc:create(function()
					flashsp:removeFromParent()
				end)))
			if i == 1 then
				rts[1]:setVisible(true)
				arrowImg3:setVisible(true)
			else
				rts[2]:setVisible(true)
				rts[3]:setVisible(true)
			end
		end
	end
	self.root:runAction(cc.Sequence:create(cc.CallFunc:create(function()
		equipBgImg1:runAction(cc.FadeIn:create(0.3))
	end),cc.DelayTime:create(0.2),
	cc.CallFunc:create(function()
		arrowImg1:runAction(cc.FadeIn:create(0.3))
	end),cc.DelayTime:create(0.2),
	cc.CallFunc:create(function()
		equipBgImg2:runAction(cc.FadeIn:create(0.3))
	end),cc.DelayTime:create(0.2),
	cc.CallFunc:create(funcTab[1]),cc.DelayTime:create(0.3),
	cc.CallFunc:create(funcTab[2]),
	cc.CallFunc:create(function()
		self.bg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
	            if self.callback then
	            	self.callback()
	            end
	            RoleMgr:hideEquipRefineLvUp()
	        end
	    end)
	end)
	))
end

function EquipRefineLvUpUI:init()
	local bg = self.root:getChildByName("bg")
    self:adaptUI(bg)
    self.bg = bg
    local winSize = cc.Director:getInstance():getWinSize()

	-- bg:addTouchEventListener(function (sender, eventType)
	-- 	if eventType == ccui.TouchEventType.began then
	-- 		AudioMgr.PlayAudio(11)
	-- 	elseif eventType == ccui.TouchEventType.ended then
 --            if self.callback then
 --            	self.callback()
 --            end
 --            RoleMgr:hideEquipRefineLvUp()
 --        end
 --    end)

	bg:getChildByName('press_tx')
		:setPosition(cc.p(winSize.width/2,65))
		:setVisible(true)
		:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
		:setFontName('font/gamefont.ttf')
		:runAction(cc.RepeatForever:create(
			cc.Sequence:create(cc.FadeOut:create(1.2),
			cc.FadeIn:create(1.2))))

	local bgNode1 = bg:getChildByName('page_node_1')
	local bgNode2 = bg:getChildByName('page_node_2')
	local bgNode3 = bg:getChildByName('page_node_3')
    if self.page == 5 then
    	bgNode1:setVisible(true)
    	bgNode2:setVisible(false)
    	bgNode3:setVisible(false)
    	self:updatePanel1()
    elseif self.page == 2 then
    	local conf = GameData:getConfData("equipsuit")
    	bgNode1:setVisible(false)
    	bgNode2:setVisible(true)
    	bgNode3:setVisible(false)
    	self:updatePanel2(conf)
	elseif self.page == 3 then
    	local conf = GameData:getConfData("gemsuit")
    	bgNode1:setVisible(false)
    	bgNode2:setVisible(true)
    	bgNode3:setVisible(false)
    	self:updatePanel2(conf)
	elseif self.page == 4 then
    	local conf = GameData:getConfData("equiprefinesuit")
    	bgNode1:setVisible(false)
    	bgNode2:setVisible(true)
    	bgNode3:setVisible(false)
    	self:updatePanel2(conf)
	elseif self.page == 1 then
    	local conf = GameData:getConfData("equiplvsuit")
    	bgNode1:setVisible(false)
    	bgNode2:setVisible(false)
    	bgNode3:setVisible(true)
    	self:updatePanel3(conf)
	end
end

return EquipRefineLvUpUI