local ChartPromotedProviewUI = class("ChartPromotedProviewUI", BaseUI)


local herochangeconf = GameData:getConfData('herochange')
local MAXPROTYPE = #herochangeconf

function ChartPromotedProviewUI:ctor(obj,protype)
	self.uiIndex = GAME_UI.UI_CHART_PROMOTED_PROVIEW_PANEL
    self.obj = obj
    self.obj:setDestiny(10,self.obj:getDestiny().energy,obj:getDestiny().expect)
    self.conf = self.obj:getPromotedConf()
    self.professtype = self.obj:getProfessionType()
    self.protype = protype or 1
end

function ChartPromotedProviewUI:init()
	local bgimg = self.root:getChildByName("bg_img_1")
	local bgimg1 = bgimg:getChildByName("bg_img2")
	local closebtn = bgimg1:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ChartMgr:hideChartPromotedProviewUI()
        end
    end)
    self:adaptUI(bgimg, bgimg1)

    local bgimg2 = bgimg1:getChildByName('bg_img')
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('ROLE_DESC38'))
    local nametx =  bgimg2:getChildByName('name_tx')
    local tabimg = bgimg2:getChildByName('tab_img')

	nametx:setString(self.conf[self.protype+1][tonumber(self.professtype*100+0)]['surname']..self.obj:getName())

    local objtemp = clone(self.obj)
    local promotedtemp = {}
    promotedtemp[1] = self.protype+1
    promotedtemp[2] = 0
    objtemp:setPromoted(promotedtemp)
    
	nametx:setColor(objtemp:getNameColor())
    tabimg:loadTexture(COLOR_TABBG[tonumber(objtemp:getQuality())])
    self.anim_pl = bgimg2:getChildByName('hero_pl')
    self:createAnimation()
    
    self.norpl  = bgimg2:getChildByName('nor_pl')
    self.maxpl = bgimg2:getChildByName('max_pl')

    if self.protype+ 1 == MAXPROTYPE  then
        self.norpl:setVisible(false)
        --self:initmaxpl()
    else
        self.maxpl:setVisible(false)
        self:initnorpl()
    end
    local promoteFirst = cc.UserDefault:getInstance():getBoolForKey('promote_first',true)
    if promoteFirst then
        cc.UserDefault:getInstance():setBoolForKey('promote_first',false)
    end
end

function ChartPromotedProviewUI:addEvent(parent,skillid,pos)
	parent:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
        	local size = parent:getContentSize()
			local x, y = parent:convertToWorldSpace(cc.p(parent:getPosition(size.width / 2, size.height / 2)))
  	    	TipsMgr:showRoleSkillTips(self.obj:getDestiny().level,skillid,cc.p(x,y),fa)
         end
    end)
end

function ChartPromotedProviewUI:getAtt(protype,lv)
	local objtemp = clone(self.obj)
	local promotedtemp = {}
	promotedtemp[1] = protype
	promotedtemp[2] = lv
	objtemp:setPromoted(promotedtemp)
	local atttemp = RoleData:CalPosAttByPos(objtemp,true)
	return atttemp
end

function ChartPromotedProviewUI:createAnimation()
	self.anim_pl:removeAllChildren()
	local actionisruning = false
    local prompt = self.obj:getPromoteType()
    local changeEquipObj
    if prompt < MAXPROTYPE then
        local customObj = {
            advanced = prompt + 1
        }
        changeEquipObj = self.obj:getChangeEquipState(customObj)
    else
        changeEquipObj = self.obj:getChangeEquipState()
    end
	local spineAni = GlobalApi:createLittleLossyAniByName(self.obj:getUrl() .. "_display", nil, changeEquipObj)
	local heroconf = GameData:getConfData('hero')[self.obj:getId()]
	if spineAni then
		local shadow = spineAni:getBone(self.obj:getUrl() .. "_display_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
			shadow:setIgnoreMovementBoneData(true)
		end
		spineAni:setPosition(cc.p(self.anim_pl:getContentSize().width/2,10+heroconf.uiOffsetY))
		spineAni:setLocalZOrder(999)
		self.anim_pl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)

		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end
end

function ChartPromotedProviewUI:initnorpl()
    --local attpl = self.norpl:getChildByName('att_pl')
    local proattbase = {}
    local att = {}
    local disnumatt = {}
    proattbase = self:getAtt(0,0)
    att = self:getAtt(self.protype+1,0)

    disnumatt[1] = att[1]-proattbase[1]
    disnumatt[2] = att[4]-proattbase[4]
    disnumatt[3] = att[2]-proattbase[2]
    disnumatt[4] = att[3]-proattbase[3]

    --[[for i=1,4 do
        local atttx = attpl:getChildByName('att_'..i)
        atttx:setString(GlobalApi:getLocalStr('STR_ATT'..i))
        local numtx = attpl:getChildByName('num_'..i)
        numtx:setString(' +'..disnumatt[i])
        if disnumatt[i] > 0 then
            numtx:setString(' +'..disnumatt[i])
        else
            numtx:setString(disnumatt[i])
        end
    end
    --]]
    local skilldistab1 = {}
    local skilldistab2 = {}
    local skilltab1 = self.obj:getSkillIdTab()
    local objtemp = clone(self.obj)
    local promotedtemp = {}
    promotedtemp[1] = self.protype+1
    promotedtemp[2] = 0
    objtemp:setPromoted(promotedtemp)
    local skilltab2 = objtemp:getSkillIdTab()

    for i=1,2 do
        local tab1 = {}
        local tab2 = {}
        local bg1 = self.norpl:getChildByName('skill_'..i)
        
        tab1.skillbg = bg1:getChildByName('skilla_1_img')
        tab1.skillicon = tab1.skillbg:getChildByName('skill_img')
        tab1.lvtx = tab1.skillbg:getChildByName('lv_tx')
        tab1.nametx = tab1.skillbg:getChildByName('name_tx')
        tab1.skillicon:ignoreContentAdaptWithSize(true)
        skilldistab1[i] = tab1

        
        tab2.skillbg = bg1:getChildByName('skilla_2_img')
        tab2.skillicon = tab2.skillbg:getChildByName('skill_img')
        tab2.lvtx = tab2.skillbg:getChildByName('lv_tx')
        tab2.nametx = tab2.skillbg:getChildByName('name_tx')
        tab2.skillicon:ignoreContentAdaptWithSize(true)
        skilldistab2[i] = tab2
    end

    local skillconf = GameData:getConfData("skill")
    local fate = self.obj:getDestiny()
    for i=1,#skilltab1 do
        local skill = skillconf[skilltab1[i]]
        local skillName = skill['name']
        local skillicon ='uires/icon/skill/' .. skill['skillIcon']
        skilldistab1[i].lvtx:setString('Lv.' .. fate.level)
        skilldistab1[i].nametx:setString(skillName)
        skilldistab1[i].skillicon:loadTexture(skillicon)
        skilldistab1[i].skillbg:loadTexture(self.obj:getBgImg())
        self:addEvent(skilldistab1[i].skillbg,skilltab1[i])


        local skill2 = skillconf[skilltab2[i]]
        local skillName2 = skill2['name']
        local skillicon2 ='uires/icon/skill/' .. skill2['skillIcon']
        skilldistab2[i].lvtx:setString('Lv.' .. fate.level)
        skilldistab2[i].nametx:setString(skillName2)
        skilldistab2[i].skillicon:loadTexture(skillicon2)
        skilldistab2[i].skillbg:loadTexture(objtemp:getBgImg())
        self:addEvent(skilldistab2[i].skillbg,skilltab2[i])
    end
end

function ChartPromotedProviewUI:initmaxpl()
    local proattbase = {}
    local att = {}
    local disnumatt = {}
    local basenumatt = {}
    basenumatt[1] = 0
    basenumatt[2] = 0
    basenumatt[3] = 0
    basenumatt[4] = 0

    proattbase = self:getAtt(0,0)
    att = self:getAtt(self.protype+1,0)
    if self.obj:getQuality() == 6 and self.obj:getRealQulity() == 5 then
        proattbase = self:getAtt(2,0)
        local atttep = self:getAtt(0,0)
        basenumatt[1] = proattbase[1] - atttep[1]
        basenumatt[2] = proattbase[4] - atttep[4]
        basenumatt[3] = proattbase[2] - atttep[2]
        basenumatt[4] = proattbase[3] - atttep[3]
    end
        disnumatt[1] = att[1]-proattbase[1]
        disnumatt[2] = att[4]-proattbase[4]
        disnumatt[3] = att[2]-proattbase[2]
        disnumatt[4] = att[3]-proattbase[3]    

    local frompl = self.maxpl:getChildByName('from')
    local topl = self.maxpl:getChildByName('to')

    for i=1,4 do
        local bg1 = frompl:getChildByName('att'..i..'bg')
        local atttx = bg1:getChildByName('attr1')
        atttx:setString(GlobalApi:getLocalStr('STR_ATT'..i))
        local numtx = bg1:getChildByName('count')
        numtx:setString(basenumatt[i])

        local bg2 = topl:getChildByName('att'..i..'bg')
        local toatttx = bg2:getChildByName('attr1')
        toatttx:setString(GlobalApi:getLocalStr('STR_ATT'..i))
        local tonumtx = bg2:getChildByName('count')
        tonumtx:setString(disnumatt[i])
        local arrowimg = bg2:getChildByName('arrow_img')
        if disnumatt[i] > 0 then
            arrowimg:setVisible(true)
        else
            arrowimg:setVisible(false)
        end
    end
end

return ChartPromotedProviewUI
