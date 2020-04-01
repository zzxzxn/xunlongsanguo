local TavernAnimateUI = class('TavernAnimateUI', BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

-- fucking old log 
local heroFrame = {
	[2] = 'uires/ui/common/card_green.png',
	[3] = 'uires/ui/common/card_blue.png',
	[4] = 'uires/ui/common/card_purple.png',
	[5] = 'uires/ui/common/card_yellow.png',
	[6] = 'uires/ui/common/card_red.png',
	[7] = 'uires/ui/common/card_gold.png',
}

local heroCircle = {
	[1] = 'uires/ui/tavern/tavern_circle_gray.png',
	[2] = 'uires/ui/tavern/tavern_circle_green.png',
	[3] = 'uires/ui/tavern/tavern_circle_blue.png',
	[4] = 'uires/ui/tavern/tavern_circle_puple.png',
	[5] = 'uires/ui/tavern/tavern_circle_yellow.png',
	[6] = 'uires/ui/tavern/tavern_circle_red.png',
}

-- 示例图大小
local defaultSize = cc.size(960, 640)
local positions = {
	[1] = cc.p(100, 320),
	[2] = cc.p(252, 400),
	[3] = cc.p(404, 480),
	[4] = cc.p(556, 480),
	[5] = cc.p(708, 400),
	[6] = cc.p(860, 320),
	[7] = cc.p(708, 240),
	[8] = cc.p(556, 160),
	[9] = cc.p(404, 160),
	[10] = cc.p(252, 240)
}

-- 招募音效ID
local recruitAudioId = nil

function TavernAnimateUI:ctor(awards, func, recuitetype)
	self.uiIndex = GAME_UI.UI_TAVERN_ANIMATE
	self.awards = awards
	self.func = func
	-- self.isTen = isTen
	-- self.isTen = isTen
	self.curCards = 0
	self.cardsPositions = {}
	-- self.camera = nil

	self.cards = {}
	self.recuitetype = recuitetype

	self.highQuality = {}

end

-- function TavernAnimateUI:onShow()
-- 	self.camera:setDepth(1)
-- end

-- function TavernAnimateUI:onCover()
-- 	self.camera:setDepth(-1)
-- end

function TavernAnimateUI:init()
	-- init camera 2
	-- self.camera = UIManager:createCamera()
	-- self.camera:setDepth(1)
	-- self.root:addChild(camera)

	self:adaptCenterUI(self.root)

	local Panel_Main = self.root:getChildByName('Panel_Main')
	self.Panel_Main = Panel_Main
	local mask_bg = Panel_Main:getChildByName('mask_bg')
	local winSize = cc.Director:getInstance():getWinSize()
	self.mask_bg = mask_bg
	-- self:adaptUI(bg, mask_bg, true)

	local againBtn = Panel_Main:getChildByName('again_btn')
	againBtn:setLocalZOrder(9999)
	againBtn:addClickEventListener(function (  )
			self:func()
			TavernMgr:hideTavernAnimate()
			if self.role ~= nil then
				self.role:stopSound('sound')
			end
            if self.recuitetype == 1 then
                TavernMgr:recuit(self.recuitetype)
            else
                -- TavernMgr:recuitTen(self.recuitetype)
                if tonumber(TavernMgr:getLuck()) == 1 then
                    if self.recuitetype == 3 then
		  			    TavernMgr:showTavernMasterUI(function (a)
		  				    TavernMgr:recuitTen(self.recuitetype,a)
		  			    end)
                    elseif self.recuitetype == 2 then
                        TavernMgr:recuitTen(self.recuitetype)
                    end
		  		else
		  			TavernMgr:recuitTen(self.recuitetype)
		  		end
            end
			
		end)
	local againTx = againBtn:getChildByName('text')
	local godieBtn = Panel_Main:getChildByName('godie_btn')
	local backTx = godieBtn:getChildByName('text')
	backTx:setString(GlobalApi:getLocalStr('STR_RETURN_1'))
	godieBtn:setLocalZOrder(9999)
	godieBtn:addClickEventListener(function ()
			self:func()
			TavernMgr:hideTavernAnimate()
			if self.role ~= nil then
				self.role:stopSound('sound')
			end
		end)
	self.againBtn = againBtn
	self.godieBtn = godieBtn

	-- adapt position y
	-- local adapt_y = (mask_bg:getContentSize().height - winSize.height) / 2 + 50
	-- againBtn:setPositionY(adapt_y)
	-- godieBtn:setPositionY(adapt_y)

	local sz = mask_bg:getContentSize()
	if self.recuitetype == 3 then
		againTx:setString(GlobalApi:getLocalStr('TEN_MORE'))
		UIManager:showSidebar({1},{3,5,4},true)
		againBtn:setVisible(false)
		godieBtn:setVisible(false)
	elseif self.recuitetype == 4 then   -- sp...
		againBtn:setVisible(false)
		godieBtn:setPositionX(480)
		godieBtn:setVisible(true)
    	-- 烟花爆竹
		math.randomseed(os.clock()*10000)
		local num = math.random(3,4)
		mask_bg:setCascadeOpacityEnabled(false)
		-- mask_bg:setOpacity(100)
		-- local black_bg = ccui.ImageView:create()
	 --    black_bg:loadTexture('uires/ui/tavern/tavern_background.png')
	 --    black_bg:setScale9Enabled(true)
	 --    black_bg:setContentSize(sz)
	 --    black_bg:setTouchEnabled(true)
	 --    black_bg:setPosition(cc.p(sz.width / 2, sz.height / 2))
		-- self.mask_bg:addChild(black_bg,1)
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
					self.mask_bg:addChild(particle,1)
				end))))
		end
		self:goAction()
		return
	else
		againTx:setString(GlobalApi:getLocalStr('ONCE_MORE'))
		UIManager:showSidebar({1},{3,5,4},true)
	end

  	self:goAction()

	mask_bg:setCascadeOpacityEnabled(false)
	-- mask_bg:setOpacity(0)
end

function TavernAnimateUI:genCard(role , typeStr)
	local node = cc.CSLoader:createNode('csb/taverncard.csb')

	local quality = role:getQuality()
	local frame = node:getChildByName('frame')
	frame:setLocalZOrder(98)
	-- frame:setRotation3D(cc.vec3(-45, 0, 0))
	-- frame:loadTexture(heroFrame[quality])
	local effectnode = frame:getChildByName('effect_node')
	-- local cardeffect = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
	local cardeffect = cc.ParticleSystemQuad:create("particle/victory_light.plist")
	-- local cardeffect = GlobalApi:createLittleLossyAniByName()

	cardeffect:setScale(1)
	cardeffect:setPosition(cc.p(0 ,20))
	-- cardeffect:getAnimation():playWithIndex(0, -1, 1)
	-- cardeffect:getAnimation():setSpeedScale(0.8)
	effectnode:addChild(cardeffect, 1)


	local camp_img = frame:getChildByName('camp_img')
	local campType = role:getCamp()
	camp_img:setVisible(false)
	if campType and campType ~= 5 and campType ~= 0 then 
		camp_img:loadTexture('uires/ui/common/camp_'..campType..'.png')
	end

	local type_img = frame:getChildByName('type_img')
	type_img:loadTexture('uires/ui/common/professiontype_'..role:getAbilityType()..'.png')
	type_img:setVisible(false)


	local soldier_img = frame:getChildByName('soldier')
	soldier_img:loadTexture('uires/ui/common/soldier_'..role:getSoldierId()..'.png')
	soldier_img:ignoreContentAdaptWithSize(true)
	soldier_img:setVisible(false)


	local layout = node:getChildByName('mask_white')
	layout:setLocalZOrder(99)

	local name = frame:getChildByName('name')
	name:setVisible(false)

	local quality = role:getQuality()
	name:setString(role:getName())
	name:setTextColor(COLOR_QUALITY[quality])
	name:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))

	local hero = frame:getChildByName('hero')
	hero:setLocalZOrder(999)
	hero:setVisible(true)
	local hid = role:getId()
	-- local aniName = role:getUrl() .. "_display"
	--print('name'..(role:getUrl() .. "_display"))

	--xyh
	local spine = GlobalApi:createLittleLossyAniByName(role:getUrl() .. "_display", nil, role:getChangeEquipState())
	--local effectIndex = 1
	-- repeat
	-- 	local aniEffect = spine:getBone(aniName .. "_effect" .. effectIndex)
	-- 	if aniEffect == nil then
	-- 		break
	-- 	end
	-- 	aniEffect:changeDisplayWithIndex(-1, true)
	-- 	aniEffect:setIgnoreMovementBoneData(true)
	-- 	effectIndex = effectIndex + 1
	-- until false
	local spineScale = 1


	if self.recuitetype ~= 3 then
		-- frame:setScale(1.5)
	end
	
	if spine ~= nil then
		-- 刚开始就他妈是苦逼脸
		spine:setScale(spineScale)
		spine:getAnimation():play('idle', -1, 1)
		-- spine:setAnimation(0, 'idle', true)
		hero:addChild(spine)
		-- spine:setAnimation(0, 'shengli', true)
		local herosz = hero:getContentSize()
		local offsetY = GameData:getConfData('hero')[hid].uiOffsetY
		spine:setPosition(cc.p(herosz.width / 2, herosz.height / 2 + offsetY * spineScale))
	end

	-- card ++
	if typeStr ~= "last" then 
		self.curCards = self.curCards + 1
		node:setName('card' .. self.curCards)
		table.insert(self.cardsPositions,
			self:getTenPosition(
				node:getContentSize(),
				self.Panel_Main:getContentSize()
			)
		)
	end

	return node, frame, spine, layout,cardeffect
end

function TavernAnimateUI:goAction()
	local ele = table.remove(self.awards)
	while (ele ~= nil and ele[1] ~= 'card') do
		ele = table.remove(self.awards)
	end
	if ele == nil then
		-- fly to the end position
		--xyh
		-- if self.recuitetype == 3 then
		-- 	for i = 1, 10 do
		-- 		-- print('i .............. ' .. i)
		-- 		self.Panel_Main:getChildByName('card' .. i)
		-- 			:runAction(
		-- 				cc.Sequence:create(
		-- 					cc.MoveTo:create(0.2, self.cardsPositions[i]), 
		-- 					cc.CallFunc:create(function (  )
		-- 						-- actions finish
		-- 						self.againBtn:setVisible(true)
		-- 						self.godieBtn:setVisible(true)

		-- 						for k,v in pairs(self.cards) do
		-- 							-- print(k, v)
		-- 							v:setTouchEnabled(true)
		-- 						end
		-- 					end)))
		-- 	end
		-- 	self.cardsPositions = {}
		-- 	return
		-- end
		-- actions finish
		--xyh
		self.againBtn:setVisible(true)
		self.godieBtn:setVisible(true)

		--xyh
		-- for k,v in pairs(self.cards) do
		-- 	-- print(k, v)
		-- 	v:setTouchEnabled(true)
		-- end
		return
	end
	local role = ClassRoleObj.new(ele[2], ele[3])
	-- dump(role)
	self.role = role



	
	if self.recuitetype ~= 3 then
		if self:isProcedure1(role) then
			self:singleUnderPuple(role)
		else
			self:singleOverPuple(role)
		end
		return
	else
		if self:isProcedure1(role) then
			self:tenUnderPuple(role)
			self:createHeadNode(role)
			
		else
			self:tenOverPuple(role)
			self:createHeadNode(role)
			
		end
	end
	return
end


--十连抽
function TavernAnimateUI:tenUnderPuple(role)
	self.mask_bg:loadTexture("uires/ui/tavern/tavern_background2.jpg")
	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	layout:setTouchEnabled(false)
	cardeffect:setVisible(false)

	hFrame:setTouchEnabled(false)
	hFrame:addClickEventListener(function (sender, eventType)
		--显示卡片详情
		ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
	end)

	table.insert(self.cards, hFrame)



	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()

	local sz = self.Panel_Main:getContentSize()
	self.Panel_Main:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setScale(0)
	-- hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))
	hnode:setPosition(cc.p(230 , 280))

	self:createCongratulationImg(self.Panel_Main)
	self:createLeftImg(self.Panel_Main ,role , "ten")
	self:createLastCard(self.Panel_Main)


	AudioMgr.playEffect("media/effect/normal_card.mp3", false)

	--xyh
	-- hnode:runAction(cc.Sequence:create(cc.Spawn:create(
	-- 	--移动，缩放，旋转
	-- 	cc.MoveTo:create(0.2, positions[self.curCards]), cc.ScaleTo:create(0.2, 1), cc.RotateTo:create(0.2, 720)),
	-- 	cc.CallFunc:create(function() 
	-- 			layout:setVisible(true)
	-- 			--淡出
	-- 			layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.2), 
	-- 				cc.CallFunc:create(function ()
	-- 						--执行待机动画
	-- 						if heroSpine ~= nil then
	-- 							heroSpine:getAnimation():play('idle', -1, 1)
	-- 						end
	-- 						self:goAction()
	-- 					end)))
	-- 		end)))



	--xyh
	hnode:setOpacity(0)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
	--移动，缩放，旋转
	cc.MoveTo:create(0.2, cc.p(230 , 280)), cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2)),
	cc.CallFunc:create(function()
			--淡出
			layout:runAction(cc.Sequence:create(cc.FadeOut:create(1), 
				cc.CallFunc:create(function ()
						--执行待机动画
						if heroSpine ~= nil then
							heroSpine:getAnimation():play('idle', -1, 1)
						end
						if hnode  then 
							hnode:removeFromParent()
						end
						
						self:goAction()

					end)))
		end)))


end

function TavernAnimateUI:tenOverPuple(role)
	self.mask_bg:loadTexture("uires/ui/tavern/tavern_background2.jpg")
	local hnode, hFrame, heroSpine, layout, cardeffect = self:genCard(role)
	layout:setVisible(false)
	layout:setTouchEnabled(false)
	cardeffect:setVisible(true)

	hFrame:setTouchEnabled(false)
	hFrame:addClickEventListener(function (sender, eventType)
		ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
	end)

	table.insert(self.cards, hFrame)

	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()
	local sz = self.Panel_Main:getContentSize()
	self.Panel_Main:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))
	self:createCongratulationImg(self.Panel_Main)
	self:createLeftImg(self.Panel_Main ,role , "ten")
	

	-- local pox, poy = self:getTenPosition(nodeSize, sz)

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
	hnode:setPositionY(hnode:getPositionY() - 70)
	bglight1:runAction(cc.RepeatForever:create(cc.RotateBy:create(1, -8)))

	bglight:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))
	bglight1:getVirtualRenderer():setBlendFunc(cc.blendFunc(gl.DST_ALPHA, gl.ONE))

	AudioMgr.playEffect("media/effect/special_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		--十连抽抽到高级卡，单独显示
		cc.EaseBackOut:create(cc.ScaleTo:create(0.4, 1.2)), cc.RotateTo:create(0.4, 360)),
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
					role:playSound('sound')
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
									role:stopSound('sound')
									hnode:runAction(cc.Sequence:create(cc.Spawn:create(
										-- cc.MoveTo:create(0.2, positions[self.curCards]), cc.ScaleTo:create(0.2, 1)),
										--xyh
										cc.MoveTo:create(0.2, cc.p(230 , 280)), cc.ScaleTo:create(0.2, 1)),
										cc.CallFunc:create(function ()
											self:createLastCard(self.Panel_Main , "last")
												--xyh
												if hnode  then 
													hnode:removeFromParent()
												end
												--xyh
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
								-- cc.MoveTo:create(0.2, positions[self.curCards]), cc.ScaleTo:create(0.2, 1)),
								--xyh
								cc.MoveTo:create(0.2, cc.p(230 , 280)), cc.ScaleTo:create(0.2, 1)),
								cc.CallFunc:create(function ()
										--xyh
										if hnode then 
											hnode:removeFromParent()
										end
										--xyh
										self:goAction()
									end)))
						end)
				end
			end)))
end

function TavernAnimateUI:singleUnderPuple(role)
	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	cardeffect:setVisible(false)

	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()
	local sz = self.Panel_Main:getContentSize()
	self.Panel_Main:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))

	self:createCongratulationImg(self.Panel_Main)
	self:createLeftImg(self.Panel_Main ,role , "single")



	AudioMgr.playEffect("media/effect/normal_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
				end)
				if heroSpine ~= nil then
					role:playSound('sound')
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
						end
					end)
				end
			end)))
end

function TavernAnimateUI:singleOverPuple(role)
	local hnode, hFrame, heroSpine, layout,cardeffect = self:genCard(role)
	layout:setVisible(false)
	cardeffect:setVisible(true)


	local nodeSize = hnode:getContentSize()
	-- local sz = cc.Director:getInstance():getWinSize()
	local sz = self.Panel_Main:getContentSize()
	self.Panel_Main:addChild(hnode)
	hnode:setLocalZOrder(99)
	hnode:setOpacity(50)
	hnode:setScale(0)
	hnode:setPosition(cc.p(sz.width / 2, sz.height / 2))
	self:createCongratulationImg(self.Panel_Main)
	self:createLeftImg(self.Panel_Main ,role , "single")

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

	AudioMgr.playEffect("media/effect/special_card.mp3", false)
	hnode:runAction(cc.Sequence:create(cc.Spawn:create(
		cc.FadeIn:create(0.4), cc.ScaleTo:create(0.4, 1), cc.RotateTo:create(0.4, 720)),
		cc.CallFunc:create(function()
				hFrame:setTouchEnabled(true)
				hFrame:addClickEventListener(function (sender, eventType)
					ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, role)
				end)
				if heroSpine ~= nil then
					role:playSound('sound')
					heroSpine:getAnimation():play('skill2', -1, 0)
					heroSpine:getAnimation():setMovementEventCallFunc(function ( armature, movementType, movementID )
						if movementType == 1 then
							heroSpine:getAnimation():play('idle', -1, 1)
						end
						end)
				end
			end)))
end

function TavernAnimateUI:isProcedure1(role)
	return role:getQuality() <= 4
end

function TavernAnimateUI:getTenPosition(nodeSize, sz)
	-- self.curCards = self.curCards + 1
	local avw = sz.width / 6
	local pox = 0
	local poy = 0
	local disy = 200
	if self.curCards <= 5 then
		pox = self.curCards * avw
		poy = sz.height / 2 + nodeSize.height / 2 + disy - 50
	else
		pox = (self.curCards - 5) * avw
		poy = sz.height / 2 - nodeSize.height / 2 - disy + 100
	end
	return cc.p(pox, poy)
end



--创建十连抽右边的十个头像图标
function TavernAnimateUI:createHeadNode(role)

	local Node = ccui.ImageView:create("uires/ui/common/frame_gray.png")
	Node:addTo(self.Panel_Main)
	Node:setTouchEnabled(true)
	Node:setSwallowTouches(true)
	Node:setAnchorPoint(cc.p(0.5 ,0.5))

   	Node:addTouchEventListener(function (sender, eventType)
		if eventType ==  ccui.TouchEventType.ended then
        ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,role)
	end
	end)

	local professionType = role:getAbilityType()
	local professionType_img =  ccui.ImageView:create('uires/ui/common/professiontype_'..professionType..'.png')
	professionType_img:setName("professionType_img")
	professionType_img:addTo(Node , 10)
	professionType_img:setScale(0.8)
	professionType_img:setPosition(cc.p(75 ,75))
	local headNode = ClassItemCell:create(ITEM_CELL_TYPE.ITEM , role , Node)
	headNode.lvTx:setVisible(false)
	headNode.awardBgImg:setTouchEnabled(false)
	headNode.awardBgImg:setSwallowTouches(true)
	headNode.awardBgImg:setAnchorPoint(cc.p(0.5 ,0.5))
	headNode.awardBgImg:setPosition(47 ,47)

	if self.curCards < 6 then 
		Node:setPosition(cc.p(380 + (self.curCards - 1) * 115 ,370))
	else
		Node:setPosition(cc.p(380 + (self.curCards - 6 ) * 115 ,250))
	end
	return headNode
end

--创建抽卡上面的恭喜获得图片
function TavernAnimateUI:createCongratulationImg(parentNode)

	local congratuliation_img =  ccui.ImageView:create('uires/ui/common/card_Congratulations.png')
	parentNode:addChild(congratuliation_img)
	congratuliation_img:setPosition(cc.p(parentNode:getContentSize().width / 2 , parentNode:getContentSize().height / 2 + 230))
	congratuliation_img:runAction(
				cc.Sequence:create(cc.FadeIn:create(3),
					cc.CallFunc:create(function ()
						if congratuliation_img and self.curCards > 0 and self.curCards < 10 then 
							congratuliation_img:removeFromParent()
						end
					end)))
end



--创建抽卡左边的长条图，阵容，阵营，职业图片
function TavernAnimateUI:createLeftImg(parentNode , role, typeStr)
	local bg = ccui.ImageView:create('uires/ui/common/card_type.png')
	bg:addTo(parentNode)

	local quality = role:getQuality()
	
	if quality > 4 and typeStr ~= "last" then
		table.insert(self.highQuality , self.role)
	end

	local nameText = cc.Label:createWithTTF(role:getName(), 'font/gamefont.ttf', 20)
	nameText:setTextColor(COLOR_QUALITY[quality])
	nameText:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	nameText:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
	nameText:setDimensions(21 ,150)
	nameText:setAnchorPoint(cc.p(0.5 , 1))
	nameText:addTo(bg)



	local camp_img = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
	local campType = role:getCamp()
	if campType and campType ~= 5 and campType ~= 0 then 
		camp_img:loadTexture('uires/ui/common/camp_'..campType..'.png')
	end
	camp_img:setScale(0.8)

	local type_img = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
	type_img:loadTexture('uires/ui/common/professiontype_'..role:getAbilityType()..'.png')


	local soldier_img = ccui.ImageView:create('uires/ui/common/bg1_alpha.png')
	soldier_img:loadTexture('uires/ui/common/soldier_'..role:getSoldierId()..'.png')
	soldier_img:ignoreContentAdaptWithSize(true)
	soldier_img:setScale(0.8)

	bg:addChild(camp_img)
	bg:addChild(type_img)
	bg:addChild(soldier_img)
	soldier_img:setPosition(cc.p(30 ,104))
	camp_img:setPosition(cc.p(31 ,318))
	type_img:setPosition(cc.p(30 ,380))
	nameText:setPosition(cc.p(30 , 280))

	if typeStr == "single" then 
		bg:setPosition(cc.p(300 ,320))
		self.curCards = 0
	elseif typeStr == "ten" then 
		bg:setPosition(cc.p(80 ,320))
	else
		bg:setPosition(cc.p(80 ,320))
	end

	bg:setOpacity(0)

	local delaytime = 1

	if typeStr == "last"  then 
		delaytime = 3
	end

	for k,v in pairs(bg:getChildren()) do
			v:setOpacity(0)
			v:runAction(cc.FadeIn:create(delaytime))
		end

		
	bg:runAction(
		cc.Sequence:create(
			cc.FadeIn:create(delaytime),
			cc.CallFunc:create(function ()
				if bg and self.curCards > 0 and #self.highQuality < 0 then 
					bg:removeFromParent()
				end
			end)))

end


--十连招募完成后显示最后招募到的最高品质英雄
function TavernAnimateUI:createLastCard(parentNode , typeStr)
	if self.curCards == 10 and #self.highQuality > 0  then 
		self:createLeftImg(parentNode ,self.highQuality[#self.highQuality], "last")
		local hnode, hFrame, heroSpine, layout, cardeffect = self:genCard(self.highQuality[#self.highQuality], "last")

		parentNode:addChild(hnode)
		hnode:setLocalZOrder(99)
		hnode:setScale(0)
		hnode:setPosition(cc.p(250 ,400))
		layout:setVisible(false)

		local time = 2
		if typeStr == "last" then 
			time = 1
		end

		hnode:setOpacity(0)
		hnode:runAction(cc.Sequence:create( cc.DelayTime:create(time) ,cc.Spawn:create(
		--移动，缩放，旋转
		cc.MoveTo:create(0.2, cc.p(230 , 280)), cc.ScaleTo:create(0.2, 1), cc.FadeIn:create(0.2)),
		cc.CallFunc:create(function()
				if heroSpine ~= nil then
					heroSpine:getAnimation():play('idle', -1, 1)
				end
			end)))
	end
end

return TavernAnimateUI