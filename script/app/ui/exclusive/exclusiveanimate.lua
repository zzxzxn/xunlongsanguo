local ExclusiveAnimateUI = class('ExclusiveAnimateUI', BaseUI)
local ClassExclusiveObj = require('script/app/obj/exclusiveobj')
local ClassItemObj = require('script/app/obj/itemobj')

local heroFrame = {
	[2] = 'uires/ui/common/card_green.png',
	[3] = 'uires/ui/common/card_blue.png',
	[4] = 'uires/ui/common/card_purple.png',
	[5] = 'uires/ui/common/card_yellow.png',
	[6] = 'uires/ui/common/card_red.png',
}

local heroQualityFrame = {
	[1] = 'uires/ui/common/card_green.png',
	[2] = 'uires/ui/common/card_green.png',
	[3] = 'uires/ui/common/card_blue.png',
	[4] = 'uires/ui/common/card_purple.png',
	[5] = 'uires/ui/common/card_yellow.png',
	[6] = 'uires/ui/common/card_red.png',
	[7] = 'uires/ui/common/card_red.png',
}

local defaultSize = cc.size(960, 640)
local positions = {
	[1] = cc.p(185, 303),
	[2] = cc.p(298, 459),
	[3] = cc.p(473, 505),
	[4] = cc.p(657, 506),
	[5] = cc.p(833, 457),
	[6] = cc.p(954, 303),
	[7] = cc.p(772, 206),
	[8] = cc.p(568, 230),
	[9] = cc.p(359, 212),
	[10] = cc.p(570, 384)
}

function ExclusiveAnimateUI:ctor(awards, func, recuitetype, drawNum)
	self.uiIndex = GAME_UI.UI_EXCLUSIVE_ANIMATE
	self.awards = awards
	self.func = func
	self.curCards = 0
	self.cardsPositions = {}
	self.cards = {}
	self.recuitetype = recuitetype
    self.drawNum = drawNum or 1
end

function ExclusiveAnimateUI:init()
	local bg = self.root:getChildByName('tavern_bg')
    self.bg = bg
	local mask_bg = bg:getChildByName('mask_bg')
	local winSize = cc.Director:getInstance():getWinSize()
	self.mask_bg = mask_bg
	self:adaptUI(bg, mask_bg, true)

	local againBtn = mask_bg:getChildByName('again_btn')
	againBtn:setLocalZOrder(9999)
	againBtn:addClickEventListener(function (  )
            if self.func then
			    self:func()
            end
			ExclusiveMgr:hideExclusiveAnimateUI()
            if self.recuitetype == 1 then
                ExclusiveMgr:recuit(self.recuitetype)
            else
                ExclusiveMgr:recuitTen(self.recuitetype,self.drawNum)
            end
		end)
	local againTx = againBtn:getChildByName('text')
	local godieBtn = mask_bg:getChildByName('godie_btn')
	local backTx = godieBtn:getChildByName('text')
	backTx:setString(GlobalApi:getLocalStr('STR_RETURN_1'))
	godieBtn:setLocalZOrder(9999)
	godieBtn:addClickEventListener(function ()
			if self.func then
			    self:func()
            end
			ExclusiveMgr:hideExclusiveAnimateUI()
		end)
	self.againBtn = againBtn
	self.godieBtn = godieBtn

	local adapt_y = (bg:getContentSize().height - winSize.height) / 2 + 50
	againBtn:setPositionY(adapt_y)
	godieBtn:setPositionY(adapt_y)

	local sz = bg:getContentSize()
	if self.drawNum == 5 then
		againTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_101'))
		againBtn:setVisible(false)
		godieBtn:setVisible(false)
	else
		againTx:setString(GlobalApi:getLocalStr('ONCE_MORE'))
	end

    self:onFinish()

	mask_bg:setCascadeOpacityEnabled(false)
	mask_bg:setOpacity(0)
end

function ExclusiveAnimateUI:genCard(exclusiveObj)
	local node = cc.CSLoader:createNode('csb/exclusivecard.csb')

	local frame = node:getChildByName('frame')
	frame:setLocalZOrder(98)

    local layout = node:getChildByName('mask_white')
	layout:setLocalZOrder(99)

    local effectnode = frame:getChildByName('effect_node')
	local cardeffect = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
	cardeffect:setScale(2.2)
	cardeffect:setPosition(cc.p(3, 17))
	cardeffect:getAnimation():playWithIndex(0, -1, 1)
	cardeffect:getAnimation():setSpeedScale(0.8)
	effectnode:addChild(cardeffect, 1)

    local name = frame:getChildByName('name')
    name:setString(exclusiveObj:getName())
    local title = frame:getChildByName('title')
    if exclusiveObj:getObjType() == 'exclusive' then
        local desc = GlobalApi:getLocalStr('EXCLUSIVE_DESC_9' ..  exclusiveObj:getType() - 1)
        title:setString(desc)
		frame:loadTexture(heroQualityFrame[exclusiveObj:getQuality()])
    else
        title:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_94'))
		frame:loadTexture(heroQualityFrame[1])
    end
    local hero = frame:getChildByName('hero')
    hero:loadTexture(exclusiveObj:getIcon())

    local numTx = frame:getChildByName('num_tx')
    if exclusiveObj:getObjType() == 'exclusive' then
	    local starsUrl = exclusiveObj:getStarUrl()
        for i = 1,exclusiveObj:getLevel() do
            local img = ccui.ImageView:create(starsUrl)
            img:setPosition(18,80 + (i - 1)*19)
            frame:addChild(img)
        end
        numTx:setVisible(false)
    else
        numTx:setString('x' .. exclusiveObj:getNum())
    end

	-- card ++
	self.curCards = self.curCards + 1
	node:setName('card' .. self.curCards)
	table.insert(self.cardsPositions,
	    self:getTenPosition(
		    node:getContentSize(),
		    self.mask_bg:getParent():getContentSize()
	    )
	)

	return node,frame,layout,cardeffect
end

function ExclusiveAnimateUI:goAction()
	local ele = table.remove(self.awards)
	if ele == nil then
		-- fly to the end position
		if self.drawNum == 5 then
			for i = 1, 5 do
				self.mask_bg:getChildByName('card' .. i)
					:runAction(
						cc.Sequence:create(
							cc.MoveTo:create(0.2, self.cardsPositions[i]), 
							cc.CallFunc:create(function (  )
								self.againBtn:setVisible(true)
								self.godieBtn:setVisible(true)

								for k,v in pairs(self.cards) do
									v:setTouchEnabled(true)
								end
							end)))
			end
			self.cardsPositions = {}
			return
		end
		self.againBtn:setVisible(true)
		self.godieBtn:setVisible(true)
		for k,v in pairs(self.cards) do
			v:setTouchEnabled(true)
		end
		return
	end
    local exclusiveObj = nil
    if ele[1] == 'exclusive' then
         exclusiveObj = ClassExclusiveObj.new(ele[2], ele[3])
    else
        exclusiveObj = ClassItemObj.new(ele[2], ele[3])
    end
    if not exclusiveObj then
        return
    end
	if self.drawNum == 5 then
        if self:isProcedure1(exclusiveObj) then
			self:tenUnderPuple(exclusiveObj)
		else
			self:tenOverPuple(exclusiveObj)
		end
	else
		if self:isProcedure1(exclusiveObj) then
			self:singleUnderPuple(exclusiveObj)
		else
			self:singleOverPuple(exclusiveObj)
		end
	end
end

function ExclusiveAnimateUI:tenUnderPuple(exclusiveObj)
	local hnode, hFrame, layout,cardeffect = self:genCard(exclusiveObj)
	layout:setVisible(false)
	layout:setTouchEnabled(false)
	cardeffect:setVisible(false)

	hFrame:setTouchEnabled(false)
	hFrame:addClickEventListener(function (sender, eventType)
		GetWayMgr:showGetwayUI(exclusiveObj,false)
	end)

	table.insert(self.cards, hFrame)

	local nodeSize = hnode:getContentSize()

	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.MoveTo:create(0.2, self.cardsPositions[self.curCards]), cc.ScaleTo:create(0.2, 1), cc.RotateTo:create(0.2, 720)),
		cc.CallFunc:create(function()
				layout:setVisible(true)
				layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), 
					cc.CallFunc:create(function ()
							self:goAction()
						end)))
			end)))
end

function ExclusiveAnimateUI:tenOverPuple(exclusiveObj)
	local hnode, hFrame, layout, cardeffect = self:genCard(exclusiveObj)
	layout:setVisible(false)
	layout:setTouchEnabled(false)
	cardeffect:setVisible(true)

	hFrame:setTouchEnabled(false)
	hFrame:addClickEventListener(function (sender, eventType)
		GetWayMgr:showGetwayUI(exclusiveObj,false)
	end)

	table.insert(self.cards, hFrame)

	local nodeSize = hnode:getContentSize()
	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	local bglight = ccui.ImageView:create()
	bglight:setScale(2)
	bglight:setTag(9527)
	bglight:loadTexture('uires/ui/tavern/tavern_light4.png')
	hnode:addChild(bglight, -1)
	bglight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 10)))

	local bglight1 = ccui.ImageView:create()
	bglight1:setScale(1.7)
	bglight1:setRotation(math.random(120, 180))
	bglight1:setTag(9528)
	bglight1:loadTexture('uires/ui/tavern/tavern_light4.png')
	hnode:addChild(bglight1, -1)
	bglight1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -8)))

	bglight:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))
	bglight1:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))

	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 2)), cc.RotateTo:create(0.4, 360)),
		cc.CallFunc:create(function()
				-- craete a new layout
				local backLayer = ccui.Layout:create()
				backLayer:setTouchEnabled(true)
				backLayer:setAnchorPoint(cc.p(0.5, 0.5))
				backLayer:setContentSize(sz)
				backLayer:setBackGroundColorType(LAYOUT_COLOR_SOLID)
				backLayer:setBackGroundColor(cc.c3b(5, 5, 5))
				backLayer:setBackGroundColorOpacity(200)
				backLayer:setTag(9119)
				hnode:addChild(backLayer, -10)

				hFrame:setTouchEnabled(true)
				if heroSpine ~= nil then
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
							backLayer:addClickEventListener(function (sender, eventType)
									backLayer:setTouchEnabled(false)
									hFrame:setTouchEnabled(false)
									hnode:removeChildByTag(9527)
									hnode:removeChildByTag(9528)
									hnode:removeChildByTag(9119)
									hnode:runAction(cc.Sequence:create(cc.Spawn:create(
										cc.MoveTo:create(0.2, self.cardsPositions[self.curCards]), cc.ScaleTo:create(0.2, 1)),
										cc.CallFunc:create(function ()
												self:goAction()
											end)))
								end)
						end

						end)
				else
					backLayer:addClickEventListener(function (sender, eventType)
							backLayer:setTouchEnabled(false)
							hFrame:setTouchEnabled(false)
							hnode:removeChildByTag(9527)
							hnode:removeChildByTag(9528)
							hnode:removeChildByTag(9119)
							hnode:runAction(cc.Sequence:create(cc.Spawn:create(
								cc.MoveTo:create(0.2, self.cardsPositions[self.curCards]), cc.ScaleTo:create(0.2, 1)),
								cc.CallFunc:create(function ()
										self:goAction()
									end)))
						end)
				end
			end)))
end

function ExclusiveAnimateUI:singleUnderPuple(exclusiveObj)
	local hnode, hFrame, layout,cardeffect = self:genCard(exclusiveObj)
	layout:setVisible(false)
	cardeffect:setVisible(false)

	local nodeSize = hnode:getContentSize()
	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1.4), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					GetWayMgr:showGetwayUI(exclusiveObj,false)
				end)
			end)))
end

function ExclusiveAnimateUI:singleOverPuple(exclusiveObj)
	local hnode, hFrame, layout,cardeffect = self:genCard(exclusiveObj)
	layout:setVisible(false)
	cardeffect:setVisible(false)


	local nodeSize = hnode:getContentSize()
	local sz = self.mask_bg:getParent():getContentSize()
	self.mask_bg:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	local bglight = ccui.ImageView:create()
	bglight:setTag(9527)
	bglight:loadTexture('uires/ui/tavern/tavern_light4.png')

	local bglight1 = ccui.ImageView:create()
	bglight1:setRotation(math.random(120, 180))
	bglight1:setTag(9528)
	bglight1:loadTexture('uires/ui/tavern/tavern_light4.png')

	bglight:setScale(4)
	bglight1:setScale(3.4)

	hnode:addChild(bglight, -1)
	hnode:addChild(bglight1, -1)

	bglight:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, 10)))
	bglight1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -8)))

	bglight:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))
	bglight1:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))

	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1.4), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					GetWayMgr:showGetwayUI(exclusiveObj,false)
				end)
			end)))
end

function ExclusiveAnimateUI:isProcedure1(exclusiveObj)
    if exclusiveObj:getObjType() == 'exclusive' then
        return exclusiveObj:getLevel() <= 4
    else
        return false
    end
end

function ExclusiveAnimateUI:getTenPosition(nodeSize, sz)
	local avw = sz.width / 6
	local pox = 0
	local poy = 0

    pox = self.curCards * avw
    poy = sz.height / 2
    if self.curCards%2 == 0 then
        poy = sz.height / 2 + 112
    end

	return cc.p(pox, poy)
end

function ExclusiveAnimateUI:onFinish()
    local sz = self.bg:getContentSize()

    math.randomseed(os.clock()*10000)
	local num = math.random(3,4)
	local black_bg = ccui.ImageView:create()
	black_bg:loadTexture('uires/ui/common/bg_alpha2.png')
	black_bg:setScale9Enabled(true)
	black_bg:setContentSize(sz)
	black_bg:setTouchEnabled(true)
	black_bg:setPosition(cc.p(sz.width / 2, sz.height / 2))
	self.mask_bg:addChild(black_bg,1)
	for i=1,num do
		local totaldelaytime = 0
		local delaytime = math.random(1,3)
		totaldelaytime = totaldelaytime + 1/delaytime						
		self.mask_bg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(totaldelaytime),cc.CallFunc:create(
			function ()
				local winSize = cc.Director:getInstance():getWinSize()
				local scale = math.random(1,2)
				local list = math.random(1,5)
				local particle = cc.ParticleSystemQuad:create("particle/ui_tavern_fireworks_"..list..".plist")
				particle:setAutoRemoveOnFinish(true)
				local posx = math.random(0,winSize.width)
				local posy = math.random(200,winSize.height+200)
				particle:setPosition(cc.p(posx,posy))
				particle:setScale(scale)
				self.mask_bg:addChild(particle,3)
			end))))
	end
	self:goAction()
end

return ExclusiveAnimateUI