local RoleSkillTipsUI = class("RoleSkillTipsUI", BaseUI)
local ClassDressObj = require('script/app/obj/dressobj')
function RoleSkillTipsUI:ctor(lv,id,pos,isshownext)
	self.uiIndex = GAME_UI.UI_SKILLTIPS
	self.lv =lv
	self.id =id
	self.pos =pos
	self.isshownext = isshownext
end

function RoleSkillTipsUI:init()
	local bgimg = self.root:getChildByName("bg_img_1")
	bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            TipsMgr:hideRoleSkillTips()
        end
    end)
    local bgimg1 = bgimg:getChildByName('bg_img_2')
    local bgimg2 = bgimg1:getChildByName('bg_img_3')
    self:adaptUI(bgimg, bgimg1)
    bgimg1:setPosition(cc.p(480,480))
	local skillconf = GameData:getConfData("skill")
	local skillgroupconf = GameData:getConfData("skillgroup")
	local skbg = bgimg2:getChildByName('skilla_1_img')
	local skillimg =skbg:getChildByName('skill_img')

	--local skillframe = skbg:getChildByName('frame_img')
	local height = 0
	local nametx = bgimg2:getChildByName('name_tx')
	local lvtx = bgimg2:getChildByName('lv_tx')
	local lineimg = bgimg2:getChildByName('line_img')
	local skill = skillconf[self.id + self.lv - 1]
	local skillGroupId = math.floor(self.id/1000);
	local sss = math.mod(self.id, 1000)
	local skillType	= math.floor(math.mod(self.id, 1000)/100)
	local skillgrouptab = skillgroupconf[skillGroupId]
	local autotime = skillgrouptab['autoSkillTimes1']
	local skillName = skill['name']
	local skillDescarr = skill['skillDesc']
	local skillicon ='uires/icon/skill/' .. skill['skillIcon']
	nametx:setString(skillName..' Lv.' .. self.lv )
	if skillType == 1 then
		lvtx:setString(GlobalApi:getLocalStr('SKILL_TIPS_DESC_2')..autotime..GlobalApi:getLocalStr('SKILL_TIPS_DESC_3'))
	else
		lvtx:setString(GlobalApi:getLocalStr('SKILL_TIPS_DESC_1'))
	end
	lvtx:setColor(COLOR_TYPE.BLUE)
	skillimg:loadTexture(skillicon)
	skillimg:ignoreContentAdaptWithSize(true)
	local childtotalheight = 0

	local richText = xx.RichText:create() 
	richText:setContentSize(cc.size(360, 30))
	self.re1 = xx.RichTextLabel:create(skillDescarr[1]..'\n',21, COLOR_TYPE.WHITE)
	self.re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.re2 = xx.RichTextLabel:create('', 21, COLOR_TYPE.GREEN)
	self.re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKILL_TIPS_DESC_4')..'\n',21, COLOR_TYPE.YELLOW)
	self.re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.re4 = xx.RichTextLabel:create(skillDescarr[1]..'\n',21, COLOR_TYPE.GREEN)
	self.re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	richText:addElement(self.re1)
	richText:addElement(self.re2)
	richText:addElement(self.re3)
	richText:addElement(self.re4)
	richText:setAnchorPoint(cc.p(0,1))
	
	self:initCell(skillDescarr)
	local maxlv = #GameData:getConfData('destiny')
	if self.isshownext and self.lv < maxlv then
		local skill2 = skillconf[self.id + self.lv]
		local skillDescarr2 = skill2['skillDesc']
		self:initCellTwo(skillDescarr2)
	else
		self.re3:setString('')
		self.re4:setString('')
	end
	richText:format(true)
	richText:setPosition(cc.p(20,richText:getBrushY()))
	bgimg2:addChild(richText)
	local  diffheight = richText:getBrushY()
	
	skbg:setPosition(cc.p(skbg:getPositionX(),skbg:getPositionY()+diffheight))
	nametx:setPosition(cc.p(nametx:getPositionX(),nametx:getPositionY()+diffheight))
	lvtx:setPosition(cc.p(lvtx:getPositionX(),lvtx:getPositionY()+diffheight-5))
	lineimg:setPosition(cc.p(lineimg:getPositionX(),lineimg:getPositionY()+diffheight))
	bgimg2:setContentSize(cc.size(405,120+diffheight))
	bgimg1:setContentSize(cc.size(405,120+diffheight))

end

function RoleSkillTipsUI:initCell(skillDescarr )
	local str = ''
	for i=2,#skillDescarr do
		str = str .. skillDescarr[i]..'\n'
	end
	self.re2:setString(str)
end

function RoleSkillTipsUI:initCellTwo(skillDescarr )
	local str = ''
	for i=2,#skillDescarr do
		str = str .. skillDescarr[i]..'\n'
	end
	self.re4:setString(str)
end
return RoleSkillTipsUI