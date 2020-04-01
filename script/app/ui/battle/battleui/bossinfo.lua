local BossInfoUI = class("BossInfoUI", BaseUI)

function BossInfoUI:ctor(battleType, boss, callback)
    self.uiIndex = GAME_UI.UI_BOSSINFO
	self.battleType = battleType
	self.boss = boss
	self.callback = callback
	--self:getBoss()
end

local SOLDIER_ATTACK_TYPE = {
	GlobalApi:getLocalStr('SOLDIER_ATTACK_TYPE_1'),
	GlobalApi:getLocalStr('SOLDIER_ATTACK_TYPE_2'),
	GlobalApi:getLocalStr('SOLDIER_ATTACK_TYPE_1'),
}
function BossInfoUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	local bg3 = bg1:getChildByName("bg3")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2))
	bg3:setPosition(cc.p(0,0))
	local titleBgImg = bg2:getChildByName('title_bg_img')
	local titleTx = titleBgImg:getChildByName('title_tx')
	titleTx:setString(GlobalApi:getLocalStr('BOSS_INFO_TITLE_TX'))

	local skillGroupConf = GameData:getConfData("skillgroup")
	local skillConf = GameData:getConfData("skill")
	local skillGroup = skillGroupConf[self.boss.heroInfo.skillGroupId]
	local skills = {skillConf[skillGroup.autoSkill1],skillConf[skillGroup.angerSkill]}

	local rightBottomImg = bg2:getChildByName('right_bottom_img')
	local leftImg = bg2:getChildByName('left_bg_img')
	local rightTopImg = bg2:getChildByName('right_top_img')
	local descTx = bg2:getChildByName('desc_tx')
	self.skllBgImgs = {}
	for i=1,2 do
		self.skllBgImgs[i]= rightBottomImg:getChildByName('skill_'..i..'_img')
		local skillImg = self.skllBgImgs[i]:getChildByName('skill_img')
		local nameTx = self.skllBgImgs[i]:getChildByName('name_tx')
		skillImg:loadTexture('uires/icon/skill/' .. skills[i].skillIcon)
		nameTx:setString(skills[i].name)
		self.skllBgImgs[i]:setTouchEnabled(true)
		self.skllBgImgs[i]:addClickEventListener(function ()
			local begin = self.skllBgImgs[i]:getTouchBeganPosition()
			local endp = self.skllBgImgs[i]:getTouchEndPosition()
			if math.abs(endp.x - begin.x) < 20 and math.abs(endp.y - begin.y) < 20 then
				local size = skillImg:getContentSize()
				local x, y = self.skllBgImgs[i]:convertToWorldSpace(cc.p(self.skllBgImgs[i]:getPosition(size.width / 2, size.height / 2)))
				TipsMgr:showRoleSkillTips(self.boss.heroInfo.skillLevel or 1, skills[i].id, cc.p(x,y),false)
			end
		end)
	end
	
	local numStr = {GlobalApi:getLocalStr('COLOR_ORANGE'),GlobalApi:getLocalStr('SOLDIER_TYPE_'..self.boss.heroInfo.legionType),self.boss.heroInfo.atk,
	self.boss.heroInfo.hp,self.boss.heroInfo.phyDef,self.boss.heroInfo.magDef}

	local nameTx = leftImg:getChildByName('name_tx')

	local num = self.boss.heroInfo.legionType
	local rNum = (num - 2)%3 + 1
	local desc1 = nil
	local speed = self.boss.heroInfo.moveSpeed
	if speed > 100 then
		desc1 = GlobalApi:getLocalStr('SOLDIER_SPEED_TYPE_1')
	else
		desc1 = GlobalApi:getLocalStr('SOLDIER_SPEED_TYPE_2')
	end
	local numStr1 = {GlobalApi:getLocalStr('SOLDIER_TYPE_'..rNum),SOLDIER_ATTACK_TYPE[self.boss.heroInfo.legionType],desc1}
	self.descTypeTx = {}
	for i=1,3 do
		local descTypeTx = rightTopImg:getChildByName('desc_'..i..'_tx')
		local descTx1 = descTypeTx:getChildByName('desc_tx')
		descTx1:setString(numStr1[i])
		descTypeTx:setString(GlobalApi:getLocalStr('SOLDIER_DESC_'..i))
		descTypeTx:setOpacity(0)
		self.descTypeTx[i] = descTypeTx
	end
	local soldierImg = rightTopImg:getChildByName('soldier_img')
	local arrTab = string.split(self.boss.info.soldierUrl,'_')
	soldierImg:loadTexture('uires/ui/role/role_'.. arrTab[1]..arrTab[2]..'.png')
	soldierImg:setOpacity(0)

	local effect = GlobalApi:createLittleLossyAniByName("ui_bossjieshaojiemiantexiao")	
	effect:setScale(1.5)
	effect:setPosition(cc.p(winSize.width/2,winSize.height/2))
	effect:getAnimation():play('Animation1', -1, -1)
    bg1:addChild(effect)

	bg2:setScaleX(1)
	bg2:setScaleY(0.05)
	bg2:setVisible(false)
	--expand center bg
	local act1=cc.Sequence:create(cc.DelayTime:create(0.6), cc.Show:create(), cc.ScaleBy:create(0.5,1,20))

	local spine = nil
	local act3=cc.CallFunc:create(
		function ()
			spine = GlobalApi:createAniByName(self.boss.heroInfo.url)
			spine:getAnimation():play('run', -1, 1)
			if spine~=nil then
				spine:setPosition(cc.p(-340, 100))
				spine:runAction(cc.Sequence:create(cc.MoveTo:create(1, cc.p(291, 100)),cc.CallFunc:create(function()
					spine:getAnimation():play('shengli', -1, 1)
				end)))
				bg2:addChild(spine)
			end
			nameTx:setString(self.boss.heroInfo.heroName)
			nameTx:setOpacity(0)
			nameTx:runAction(cc.FadeIn:create(1))
			for i=1,6 do
				local numTx = leftImg:getChildByName('num_'..i..'_tx')
				numTx:setString(numStr[i])
				numTx:setOpacity(0)
				numTx:runAction(cc.FadeIn:create(1))
			end
		end
	)
	-- local spineAni = nil
	local act4 = cc.DelayTime:create(1)
	local act5 = cc.CallFunc:create(
		function()
			soldierImg:setOpacity(0)
			soldierImg:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
			for i=1,3 do
				local posY = self.descTypeTx[i]:getPositionY()
				self.descTypeTx[i]:setOpacity(0)
				self.descTypeTx[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*i),cc.EaseElasticOut:create(cc.MoveTo:create(0.5,cc.p(225,posY)))))
				self.descTypeTx[i]:runAction(cc.FadeIn:create(0.5))
			end
		end)
	local act6 = cc.DelayTime:create(0.5)
	local act7 = cc.CallFunc:create(
		function()
			for i=1,2 do
				local posX = self.skllBgImgs[i]:getPositionX()
				self.skllBgImgs[i]:setOpacity(0)
				self.skllBgImgs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*i),cc.EaseElasticOut:create(cc.MoveTo:create(0.5,cc.p(posX,93)))))
				self.skllBgImgs[i]:runAction(cc.FadeIn:create(0.5))
				self.skllBgImgs[i]:runAction(cc.ScaleTo:create(0.5,1))
			end
		end)
	local act8 = cc.DelayTime:create(0.5)
	local act9=cc.CallFunc:create(
		function ()
			descTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
			descTx:setVisible(true)
			descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
			bg3:addTouchEventListener(function (sender, eventType)
				TipsMgr:hideRoleSkillTips()
				BattleMgr:hideBossInfo()
				if self.callback then
					self.callback()
				end
		    end)
		end
	)
	-- local act10=cc.Sequence:create(cc.DelayTime:create(5), cc.CallFunc:create(
	-- 	function ()
	-- 		TipsMgr:hideRoleSkillTips()
	-- 		BattleMgr:hideBossInfo()
	-- 		if self.callback then
	-- 			self.callback()
	-- 		end
	-- 	end
	-- ))
	bg2:runAction(cc.Sequence:create(act1,act3,act4,act5,act6,act7,act8,act9))
end

return BossInfoUI