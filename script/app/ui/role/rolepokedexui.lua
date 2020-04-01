local PokedexUI = class("PokedexUI", BaseUI)

function PokedexUI:ctor(id)
	self.uiIndex = GAME_UI.UI_POKEDEX
	self.id = id
	self.roleObj = RoleData:getRoleByPos(id)
end

function PokedexUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	local bgimg1 = self.root:getChildByName("bg_img1")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.bgimg1 = bgimg1
	-- bgimg1:addTouchEventListener(function (sender, eventType)
	-- 	if eventType == ccui.TouchEventType.began then
	-- 		AudioMgr.PlayAudio(11)
	-- 	elseif eventType == ccui.TouchEventType.ended then
	-- 		RoleMgr:hidePokedex()
	-- 	end
	-- end)
	local closeBtn = bgimg1:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hidePokedex()
        end
    end)

	local neiPl = bgimg1:getChildByName('nei_pl')
	local effectnode = neiPl:getChildByName('effect_node')
	local cardeffect = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
	cardeffect:setName('card_effect')
	cardeffect:setScaleX(4.2)
	cardeffect:setScaleY(4)
	cardeffect:setPosition(cc.p(5, 32))
	cardeffect:getAnimation():playWithIndex(0, -1, 1)
	cardeffect:getAnimation():setSpeedScale(0.8)
	effectnode:addChild(cardeffect, 1)
	effectnode:setLocalZOrder(99)
	local cardBgImg = neiPl:getChildByName('card_bg_img')
	cardBgImg:setLocalZOrder(100)
	local framePl = neiPl:getChildByName('frame_pl')
	-- local roleImg = framePl:getChildByName('role_img')
	local descTx1 = neiPl:getChildByName('desc_tx1')
	descTx1:setString(GlobalApi:getLocalStr('POKEDEX_DESC'))
	descTx1:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
	-- roleImg:loadTexture(self.roleObj:getBigCardImg())

	-- local rightPl = neiPl:getChildByName('right_pl')
	-- local flagImg = rightPl:getChildByName('flag_img')
	-- local diImg = rightPl:getChildByName('di_img')
	-- local descTx = rightPl:getChildByName('desc_tx')
	-- flagImg:loadTexture('uires/ui/country/country_flag_'..self.roleObj:getCamp()..'.png')
	-- flagImg:setScale(0.27)
	-- diImg:loadTexture(self.roleObj:getTabIcon())
	-- local brief = self.roleObj:getBrief()
	-- descTx:setString(brief)
	-- local size = rightPl:getContentSize()
	-- local spine = GlobalApi:createLittleLossyAniByName(self.roleObj:getUrl() .. "_display")
	-- spine:setPosition(cc.p(size.width/2 + 20,70))
	-- spine:getAnimation():play('idle', -1, 1)
	-- rightPl:addChild(spine)

	bgimg1:setContentSize(cc.size(winSize.width,winSize.height))
	bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	bgimg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
	neiPl:setPosition(cc.p(winSize.width/2,winSize.height/2))
	closeBtn:setPosition(cc.p(winSize.width,winSize.height))
	-- cardBgImg:setPosition(cc.p(winSize.width/4,winSize.height/2))
	-- effectnode:setPosition(cc.p(winSize.width/4,winSize.height/2))
	-- framePl:setPosition(cc.p(winSize.width/4,winSize.height/2))
	-- rightPl:setPosition(cc.p(winSize.width/5*3.5,winSize.height/2))
	descTx1:setPosition(cc.p(480,69))

	framePl:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			RoleMgr:showPokedexHero(self.roleObj)
		end
	end)

	local openNum = RoleData:getRoleNum()
	-- local maxNum = 0
	-- for i=1,openNum do
	-- 	local roleObj = RoleData:getRoleByPos(i)
	-- 	if roleObj and roleObj:getId() > 0 then
	-- 		maxNum = maxNum + 1 
	-- 	end
	-- end
	local leftBtn = bgimg1:getChildByName('left_btn')
    local rightBtn = bgimg1:getChildByName('right_btn')
    leftBtn:setPosition(cc.p(0,winSize.height/2))
    rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    GlobalApi:arrowBtnMove(leftBtn,rightBtn)
    leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
	        for i=1,openNum do
	            self.id = self.id - 1
	            self.id = ((self.id < 1) and openNum) or self.id
	            local obj = RoleData:getRoleByPos(self.id)
	            if obj and obj:getId() > 0 then
	            	self.roleObj = obj
	            	break
	            end
	        end
			self:updatePanel()
        end
    end)
    rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	for i=1,openNum do
	            self.id = self.id+1
	            self.id = ((self.id > openNum) and 1) or self.id
	            local obj = RoleData:getRoleByPos(self.id)
	            if obj and obj:getId() > 0 then
	            	self.roleObj = obj
	            	break
	            end
	        end
            self:updatePanel()
        end
    end)
    leftBtn:setPosition(cc.p(0,winSize.height/2))
    rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))

    self:updatePanel()
end

function PokedexUI:updatePanel()
	local neiPl = self.bgimg1:getChildByName('nei_pl')
	local effectnode = neiPl:getChildByName('effect_node')
	local cardeffect = effectnode:getChildByName('card_effect')
	local framePl = neiPl:getChildByName('frame_pl')
	local roleImg = framePl:getChildByName('role_img')
	roleImg:loadTexture('uires/icon/card_hero/di.jpg')
	roleImg:loadTexture(self.roleObj:getBigCardImg())
	cardeffect:setVisible(self.roleObj:getQuality() >= 5)

	local rightPl = neiPl:getChildByName('right_pl')
	local flagImg = rightPl:getChildByName('flag_img')
	local diImg = rightPl:getChildByName('di_img')
	local descTx = rightPl:getChildByName('desc_tx')
	local camp = self.roleObj:getCamp() or 1
	if camp == 5 then
		flagImg:setVisible(false)
	else
		flagImg:setVisible(true)
		flagImg:loadTexture('uires/ui/country/country_flag_'..camp..'.png')
	end
	flagImg:setScale(0.27)
	diImg:loadTexture(self.roleObj:getTabIcon())
	local brief = self.roleObj:getBrief()
	descTx:setString(brief)
	local size = rightPl:getContentSize()
	local spine = rightPl:getChildByName('spine')
	if spine then
		spine:removeFromParent()
	end
	spine = GlobalApi:createLittleLossyAniByName(self.roleObj:getUrl() .. "_display", nil, self.roleObj:getChangeEquipState())
	spine:setName('spine')
	spine:setScale(0.8)
	spine:setPosition(cc.p(size.width/2 + 20,70))
	spine:getAnimation():play('idle', -1, 1)
	rightPl:addChild(spine)
end

return PokedexUI
