local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local fateUI = require('script/app/ui/role/rolefate')

local RoleInfo = class("RoleInfo", ClassRoleBaseUI)

local leftInterval = 10
local verticalInterval = 8
local titleInterval = 12
local bgWidth = 453
local rtlWidth = 440
local infoInterval = 6
local guild_position = cc.p(0, -630)
local guild_percent = 46
local fengexian_height = 3

local titleImg = {
	[1] = 'TITLE_JCSX',
	[2] = 'TITLE_ZDSX',
	[3] = 'TITLE_JN',
	[4] = 'TITLE_YF',
	[5] = 'TITLE_TF',
}
function RoleInfo:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roleinfopanel.csb")
	self.panel:setName("role_info_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	self.sv = bgimg:getChildByName('info_sv')
	self.sv:setInertiaScrollEnabled(true)
	self.sv:setBounceEnabled(false)
	self.sv:setScrollBarEnabled(false)
	self.sv:setInnerContainerSize(self.sv:getContentSize())
	self.obj = nil

	self.frames = {}

end

function RoleInfo:genTitle(idx)
	local titletx = GlobalApi:getLocalStr(titleImg[idx])
	local title = cc.Label:createWithTTF(titletx, "font/gamefont.ttf", 25)
	title:setTextColor(cc.c3b(255,247,228))
	title:enableOutline(cc.c4b(78, 49, 17, 255), 2)
	title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
	title:setAnchorPoint(cc.p(0, 0))
	return title
end

function RoleInfo:genBaseAttr()
	local ret = cc.Node:create()

	local rt = xx.RichText:create()
	rt:setAnchorPoint(cc.p(0, 0))
	rt:setPosition(cc.p(leftInterval, verticalInterval))
	local herrotx = {}
	local att = RoleData:getPosAttByPos(self.obj)
	herrotx[1] = math.floor(att[1])
	herrotx[2] = math.floor(att[4])
	herrotx[3] = math.floor(att[2])
	herrotx[4] = math.floor(att[3])

	--攻击,生命,物防,法防
	for i = 1, 4 do
		local nrtl = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_ATT'..i), 25, cc.c4b(254, 165, 0, 255))
		nrtl:setStroke(cc.c4b(0, 0, 0, 255), 1)
		nrtl:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		nrtl:setMinWidth(80)
		rt:addElement(nrtl)
		if i == 1 then
			if self.obj:getProfessionType() == 1 then
				nrtl:setString(GlobalApi:getLocalStr('PROFESSION_NAME1'))
			elseif self.obj:getProfessionType() == 2 then
				nrtl:setString(GlobalApi:getLocalStr('PROFESSION_NAME2'))
			end
		end
		local artl = xx.RichTextLabel:create(herrotx[i], 25, cc.c4b(255, 255, 255, 255))
		artl:setStroke(cc.c4b(0, 0, 0, 255), 1)
		artl:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		artl:setMinWidth(110)
		rt:addElement(artl)

		if i == 2 then
			local br = xx.RichTextLabel:create('\n')
			rt:addElement(br)
		end
	end
	rt:format(true)
	local rteSize = rt:getElementsSize()
	rt:setContentSize(rteSize)

	local attrFrame = ccui.ImageView:create('uires/ui/common/touban.png')
	attrFrame:setAnchorPoint(cc.p(0, 0))
	attrFrame:setScale9Enabled(true)

	local frameHeight = rteSize.height + verticalInterval * 2
	attrFrame:setContentSize(cc.size(bgWidth, frameHeight))
	attrFrame:addChild(rt)

	local title = self:genTitle(1)
	title:setPosition(cc.p(leftInterval, frameHeight + titleInterval))
	-- local bg = ccui.ImageView:create()
 --    bg:loadTexture("uires/ui/common/bg1_alpha.png")
 --    bg:setScale9Enabled(true)
 --    bg:setTouchEnabled(true)
	-- bg:addTouchEventListener(function (sender, eventType)
 --        if eventType == ccui.TouchEventType.began then
 --            AudioMgr.PlayAudio(11)
 --        end
 --        if eventType == ccui.TouchEventType.ended then
 --            TipsMgr:showRoleAttTips(self.obj)
 --        end
 --    end)
	local sumHeight = frameHeight + titleInterval * 2 + title:getContentSize().height
	ret:setContentSize(cc.size(bgWidth, sumHeight))
	-- bg:setContentSize(cc.size(bgWidth, sumHeight))
	-- bg:setPosition(cc.p(bgWidth/2,sumHeight/2))
	ret:addChild(attrFrame)
	--ret:addChild(bg)
	ret:addChild(title)

	return ret
end

function RoleInfo:genFightAttr()
	local ret = cc.Node:create()
	local attconf = GameData:getConfData('attribute')
	local att = RoleData:getPosAttByPos(self.obj)
	local skillRichText = xx.RichText:create()
	skillRichText:setAnchorPoint(cc.p(0, 0))
	skillRichText:setPosition(cc.p(leftInterval, verticalInterval))
 	for i=1,4 do
 		local tx1 = attconf[4+i].name ..'：' 
 		local tx2 = '（' ..GlobalApi:getLocalStr('STR_ATTFIGHT_DESC'.. 4+i) .. att[4+i]/100  .. '%' 
 		local tx3 = att[4+i] .. '  '
 		local re1 = xx.RichTextLabel:create(tx1, 25, cc.c4b(254, 165, 0, 255))
 		re1:setStroke(cc.c4b(0, 0, 0, 255), 1)
 		re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
 		local re3 = xx.RichTextLabel:create(tx3, 25, cc.c4b(254, 165, 0, 255))
 		re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
 		re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

 		local re4 = xx.RichTextLabel:create( '+'..att[19+i].."%", 20, cc.c4b(255, 0, 0, 255))
 		re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
 		re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

 		local tx5 = "）"
 		local str = tx5
 		if i ~= 4 then
 			str = str .. '\n'
 		end
 		local re5 = xx.RichTextLabel:create(str, 20, cc.c4b(36, 255, 0, 255))
 		re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
 		re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

 		local re2 = xx.RichTextLabel:create(tx2, 20, cc.c4b(36, 255, 0, 255))
 		re2:setStroke(cc.c4b(0, 0, 0, 255), 1)
 		re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
 		skillRichText:addElement(re1)
 		skillRichText:addElement(re3)
 		skillRichText:addElement(re2)
 		if att[19+i] > 0 then
 			skillRichText:addElement(re4)
 		end
 		skillRichText:addElement(re5)
		
 	end
 	skillRichText:setVerticalAlignment('middle')
 	skillRichText:format(true)
 	local rteSize = skillRichText:getElementsSize()
 	skillRichText:setContentSize(rteSize)
 	
	local fFrame = ccui.ImageView:create('uires/ui/common/touban.png')
	fFrame:setScale9Enabled(true)
	fFrame:setAnchorPoint(cc.p(0, 0))

	local frameHeight = rteSize.height + verticalInterval * 2
	fFrame:setContentSize(cc.size(bgWidth, frameHeight))
	fFrame:addChild(skillRichText)

	local title = self:genTitle(2)
	title:setPosition(cc.p(leftInterval, frameHeight + titleInterval))

	local richTextinfo = xx.RichText:create()
	richTextinfo:setAnchorPoint(cc.p(0,0.5))
	richTextinfo:setPosition(cc.p(title:getContentSize().width + 20, title:getContentSize().height / 2))
	local tx1 = GlobalApi:getLocalStr('STR_ADDATT_DESC1')
	local tx2 = GlobalApi:getLocalStr('STR_ADDATT_DESC2')
	local tx3 = UserData:getUserObj():getLv()
	local re1 = xx.RichTextLabel:create(tx1, 20, cc.c4b(254, 165, 0, 255))
	re1:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
	local re2 = xx.RichTextLabel:create(tx2, 20, cc.c4b(254, 165, 0, 255))
	re2:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
	local re3 = xx.RichTextLabel:create(tx3, 20, cc.c4b(36, 255, 0, 255))
	re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

	richTextinfo:addElement(re1)
	richTextinfo:addElement(re3)
	richTextinfo:addElement(re2)

	richTextinfo:format(true)
 	local rteSize = richTextinfo:getElementsSize()
 	richTextinfo:setContentSize(rteSize)

	title:addChild(richTextinfo)

	local sumHeight = frameHeight + titleInterval * 2 + title:getContentSize().height
	ret:setContentSize(cc.size(bgWidth, sumHeight))
	ret:addChild(fFrame)
	ret:addChild(title)
	return ret
end

function RoleInfo:genSkill()
	local ret = cc.Node:create()

	local txTalentinfo = cc.Label:createWithTTF("", "font/gamefont.ttf", 19)
	txTalentinfo:setTextColor(cc.c3b(255, 255, 255))
	txTalentinfo:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	txTalentinfo:enableShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1), 0)
	txTalentinfo:setAnchorPoint(cc.p(0, 0))
	txTalentinfo:setString(GlobalApi:getLocalStr('STR_TIANMINGINFO'))
	txTalentinfo:setPosition(cc.p(leftInterval, verticalInterval))

	local skilltab = self.obj:getSkillIdTab()
	local skillconf = GameData:getConfData("skill")
	local skillcell = cc.CSLoader:createNode("csb/roleinfocellskill.csb")
	local skillbg = skillcell:getChildByName('skillmain_bg_img')
	skillbg:removeFromParent(false)
	local widget = ccui.Widget:create()
	widget:addChild(skillbg)
	for i=1,#skilltab do
		local plbg = skillbg:getChildByName('skill_'..i..'_pl')
		local skbg = plbg:getChildByName('skill_bg_img')
		skbg:setSwallowTouches(false)
		local skillimg =skbg:getChildByName('skill_img')
		skillimg:setLocalZOrder(20)
		--local skillframe = skbg:getChildByName('frame_img')
		local desc = {}
		local nametx = plbg:getChildByName('name_tx')
		local lvtx = plbg:getChildByName('lv_tx')
		local heighttemp = 0
		local skill = skillconf[skilltab[i]]
		local skillName = skill['name']
		local skillicon ='uires/icon/skill/' .. skill['skillIcon']
		nametx:setString(skillName)
		lvtx:setString('Lv.' .. self.obj:getDestiny().level)
		skillimg:loadTexture(skillicon)
		skillimg:ignoreContentAdaptWithSize(true)
		skbg:addClickEventListener(function ()
			local begin = skbg:getTouchBeganPosition()
			local endp = skbg:getTouchEndPosition()
			if math.abs(endp.x - begin.x) < 20 and math.abs(endp.y - begin.y) < 20 then
				local size = skillbg:getContentSize()
				local x, y = skbg:convertToWorldSpace(cc.p(skbg:getPosition(size.width / 2, size.height / 2)))
				TipsMgr:showRoleSkillTips(self.obj:getDestiny().level,skilltab[i],cc.p(x,y),false)
			end
		end)
	end
	widget:setPosition(cc.p(leftInterval, txTalentinfo:getContentSize().height + verticalInterval + infoInterval))

	local frame = ccui.ImageView:create('uires/ui/common/touban.png')
	frame:setScale9Enabled(true)
	frame:setAnchorPoint(cc.p(0, 0))

	local frameHeight = txTalentinfo:getContentSize().height + infoInterval + skillbg:getContentSize().height + verticalInterval * 2
	frame:setContentSize(cc.size(bgWidth, frameHeight))
	frame:addChild(txTalentinfo)
	frame:addChild(widget)

	local title = self:genTitle(3)
	title:setPosition(cc.p(leftInterval, frameHeight + titleInterval))

	local sumHeight = frameHeight + titleInterval * 2 + title:getContentSize().height
	ret:setContentSize(cc.size(bgWidth, sumHeight))
	ret:addChild(frame)
	ret:addChild(title)

	return ret
end

-- fate stay night ... 
function RoleInfo:genFateStayNight()
	local ret = cc.Node:create()

	local fateatt =	self.obj:getFateArr()
	if #fateatt > 0 then
		local frame = ccui.ImageView:create('uires/ui/common/touban.png')
		frame:setScale9Enabled(true)
		frame:setAnchorPoint(cc.p(0, 0))

		local fn = function ()
			local pos = self.sv:getInnerContainerPosition()
			local sh = verticalInterval
			for i = #fateatt, 1, -1 do
				local panel = frame:getChildByName('frame' .. i)
				panel:setPositionY(sh)
				local regionRect = panel:getContentSize()
				sh = sh + regionRect.height
				if i ~= 1 then
					sh = sh + 5
					frame:getChildByName('fengexian' .. i)
						:setPositionY(sh)
					sh = sh + fengexian_height + 5
				end
			end
			local frameHeight = sh + verticalInterval
			frame:setContentSize(cc.size(bgWidth, frameHeight))

			local title = ret:getChildByName('title')
			title:setPosition(cc.p(leftInterval, frameHeight + titleInterval))

			local sumHeight = frameHeight + titleInterval * 2 + title:getContentSize().height
			ret:setContentSize(cc.size(bgWidth, sumHeight))

			self:updateHeight()
			self.sv:setInnerContainerPosition(pos)
		end

		local sh = verticalInterval
		for i = #fateatt, 1, -1 do
			local fateObj = fateUI.new()
			local panel = fateObj:genFateStayNight(self.obj, i, fn)
			panel:setName('frame' .. i)
			panel:setPositionY(sh)
			local regionSize = panel:getContentSize()
			sh = sh + regionSize.height
			-- local regionRect = panel:getClippingRegion()
			-- sh = sh + regionRect.height
			frame:addChild(panel)
			if i ~= 1 then
				local fengexian = ccui.ImageView:create('uires/ui/common/xian.png')
				fengexian:setName('fengexian' .. i)
				fengexian:setAnchorPoint(cc.p(0, 0))
				fengexian:ignoreContentAdaptWithSize(false)
				fengexian:setContentSize(cc.size(bgWidth, fengexian_height))
				-- fengexian:setScale9Enabled(true)
				-- fengexian:setContentSize(cc.size(bgWidth - 1, fengexian_height))
				sh = sh + 5
				fengexian:setPositionY(sh)
				sh = sh + fengexian_height + 5
				frame:addChild(fengexian)
			end
		end

		local frameHeight = sh + verticalInterval
		frame:setContentSize(cc.size(bgWidth, frameHeight))

		local title = self:genTitle(4)
		title:setName('title')
		title:setPosition(cc.p(leftInterval, frameHeight + titleInterval))
		ret:addChild(frame)
		ret:addChild(title)

		local sumHeight = frameHeight + titleInterval * 2 + title:getContentSize().height
		ret:setContentSize(cc.size(bgWidth, sumHeight))
	end
	return ret
end

function RoleInfo:genTalent()
	local ret = cc.Node:create()

	local txTalentinfo = cc.Label:createWithTTF("", "font/gamefont.ttf", 19)
	txTalentinfo:setTextColor(cc.c3b(255, 255, 255))
	txTalentinfo:enableOutline(cc.c4b(0, 0, 0, 255), 1)
	txTalentinfo:enableShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1), 0)
	txTalentinfo:setPosition(cc.p(leftInterval, verticalInterval))
	txTalentinfo:setAnchorPoint(cc.p(0, 0))
	txTalentinfo:setString(GlobalApi:getLocalStr('STR_TUPOINFO'))

	local rt = xx.RichText:create()
	rt:setContentSize(cc.size(430, 200))

	rt:setAnchorPoint(cc.p(0, 0))
	rt:setPosition(cc.p(leftInterval, txTalentinfo:getContentSize().height + verticalInterval + infoInterval))

	local innateGroupId = self.obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
	local teamnum = 1
	for i = 2, 16 do
		local innateid = groupconf[tostring('level' .. i-1)]
		local specialtab = groupconf['highlight']
		local teamtab = groupconf['teamvaluegroup']
		local effect =groupconf[tostring('value' .. i-1)]
		local innateconf = GameData:getConfData('innate')[innateid]
		local teamheroID = groupconf['teamheroID']
		local tx1 = ''
		local tx2 = ''
		local tx3 = ''
		local tx4 = ''
		local re1 = xx.RichTextLabel:create(tx1, 19, cc.c4b(163, 163, 163, 255))
		re1:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re3 = xx.RichTextLabel:create(tx3, 21, cc.c4b(163, 163, 163, 255))
		re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re2 = xx.RichTextLabel:create(tx2, 19, cc.c4b(163, 163, 163, 255))
		re2:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re5 = xx.RichTextLabel:create(tx4, 19, cc.c4b(163, 163, 163, 255))
		re5:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re5:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re6 = xx.RichTextImage:create('uires/ui/common/arrow5.png')
		re6:setScale(0.6)

		local s = GlobalApi:tableFind(teamtab,i-1)

		if s ~= 0 then
			tx4 =  groupconf[tostring('teamDes'..teamnum)]
			re5:setString(tx4)
			teamnum = teamnum + 1
		end
		if innateid < 1000 then
			tx1 = innateconf['desc'] .. effect .. '%'
			if innateconf['type'] ~= 2 then
				tx1 = innateconf['desc'] .. effect
			end
			tx3 =  '【' .. innateconf['name'] ..'】 '
			tx2 =  '（' .. GlobalApi:getLocalStr('TITLE_TP')  ..' '.. '+' .. i-1 ..' '.. GlobalApi:getLocalStr('STR_JIHUO') ..'）'
		else
			tx1 = groupconf[tostring('specialDes'..innateid%1000)]
			tx3 =  '【' .. groupconf[tostring('specialName'..innateid%1000)] ..'】 '
			tx2 =  '（' .. GlobalApi:getLocalStr('TITLE_TP')  ..' '.. '+' .. i-1 ..' '.. GlobalApi:getLocalStr('STR_JIHUO') ..'）'
		end
		local n  = GlobalApi:tableFind(specialtab,i-1)
		
		if  self.obj:getTalent() >= i -1 then
			re3:setColor(cc.c4b(254, 165, 0, 255))
			re2:setColor(cc.c4b(254, 165, 0, 255))
			
			re1:setString(tx1)
			re2:setString(tx2.. '\n')
			re3:setString(tx3)

			rt:addElement(re3)

			if n == 0 then
				re1:setColor(cc.c4b(36, 255, 0, 255))
				re5:setColor(cc.c4b(36, 255, 0, 255))
			else
				re1:setColor(cc.c4b(255, 0, 0, 255))
				re5:setColor(cc.c4b(255, 0, 0, 255))
				local re4 = xx.RichTextImage:create('uires/ui/common/icon_star3.png')
				re4:setScale(0.8)
				rt:addElement(re4)
			end

			rt:addElement(re1)
			if s ~= 0 then
				rt:addElement(re6)
				rt:addElement(re5)
				local obj = RoleData:getRoleById(teamheroID) 
				if not obj then
					re5:setColor(cc.c4b(163, 163, 163, 255))
				end
			end
			rt:addElement(re2)
		else
			re1:setColor(cc.c4b(163, 163, 163, 255))
			re3:setColor(cc.c4b(163, 163, 163, 255))
			re2:setColor(cc.c4b(163, 163, 163, 255))
			re5:setColor(cc.c4b(163, 163, 163, 255))
			re1:setString(tx1)
			re2:setString(tx2.. '\n')
			re3:setString(tx3)
			rt:addElement(re3)

			if n ~= 0 then
				local re4 = xx.RichTextImage:create('uires/ui/common/icon_star3_bg.png')
				re4:setScale(0.8)
				rt:addElement(re4)
			end
			rt:addElement(re1)
			if s ~= 0 then
				rt:addElement(re6)
				rt:addElement(re5)
			end
			rt:addElement(re2)

		end
	end
 	rt:format(true)
 	local rteSize = rt:getElementsSize()
 	rt:setContentSize(rteSize)

	local frame = ccui.ImageView:create('uires/ui/common/touban.png')
	frame:setScale9Enabled(true)
	frame:setAnchorPoint(cc.p(0, 0))

	local frameHeight = rteSize.height + verticalInterval * 2 + infoInterval + txTalentinfo:getContentSize().height
	frame:setContentSize(cc.size(bgWidth, frameHeight))
	frame:addChild(rt)
	frame:addChild(txTalentinfo)

	local title = self:genTitle(5)
	title:setPosition(cc.p(leftInterval, frameHeight + titleInterval))

	local sumHeight = frameHeight + titleInterval * 2 + title:getContentSize().height
	ret:setContentSize(cc.size(bgWidth, sumHeight))
	ret:addChild(frame)
	ret:addChild(title)
	return ret
end

function RoleInfo:update(obj)
	self.obj = obj
	self.sv:removeAllChildren()

	local sh = 0

	self.frames[5] = self:genTalent()
	self.frames[5]:setPositionY(sh)
	self.sv:addChild(self.frames[5])

	sh = sh + self.frames[5]:getContentSize().height

	self.frames[4] = self:genFateStayNight()
	self.frames[4]:setPositionY(sh)
	self.sv:addChild(self.frames[4])

	sh = sh + self.frames[4]:getContentSize().height

	self.frames[3] = self:genSkill()
	self.frames[3]:setPositionY(sh)
	self.sv:addChild(self.frames[3])

	sh = sh + self.frames[3]:getContentSize().height

	self.frames[2] = self:genFightAttr()
	self.frames[2]:setPositionY(sh)
	self.sv:addChild(self.frames[2])

	sh = sh + self.frames[2]:getContentSize().height

	self.frames[1] = self:genBaseAttr()
	self.frames[1]:setPositionY(sh)
	self.sv:addChild(self.frames[1])

	sh = sh + self.frames[1]:getContentSize().height

	if sh > self.sv:getContentSize().height then
		self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,sh))
	end
	self.sv:scrollToTop(0.1,true)
end

function RoleInfo:onMoveOut()

end

function RoleInfo:updateHeight()
	local sh = 0
	for i = #self.frames, 1, -1 do
		self.frames[i]:setPositionY(sh)
		sh = sh + self.frames[i]:getContentSize().height
		if i ~= 1 then
			sh = sh + fengexian_height
		end
	end

	self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,sh))
end

function RoleInfo:playGuild()
	self.sv:setTouchEnabled(false)
	self.sv:jumpToPercentVertical(guild_percent)
end

function RoleInfo:stopGuild()
	self.sv:setTouchEnabled(true)
end

return RoleInfo