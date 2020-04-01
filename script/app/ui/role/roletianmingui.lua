local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")

local RoleTianmingUI = class("RoleTianmingUI", ClassRoleBaseUI)
local maxlv = #GameData:getConfData('destiny')
local MAXDELTA =0.05
local skillarr = {
	lvtx = nil,
	skillimg = nil,
	nametx = nil,
}

function RoleTianmingUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roletianmingpanel.csb")
	self.panel:setName('role_tianming_panel')
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')
	self.max_pl = bgimg:getChildByName('max_pl')
	local attbg = self.nor_pl:getChildByName('att_img')
	local activetx = attbg:getChildByName('att_active_tx')
	activetx:setString(GlobalApi:getLocalStr('ROLESKILL'))
	self.attarr = {}
	self.skillaarr = {}
	local att2bg = attbg:getChildByName('num_bg')
	
	for i=1,4 do
		local attatx = att2bg:getChildByName('atta_' .. i .. '_tx')
		local attbtx = att2bg:getChildByName('attb_' .. i .. '_tx')
		local attantx = att2bg:getChildByName('numa_' .. i .. '_tx')
		local attbntx = att2bg:getChildByName('numb_' .. i .. '_tx')
		local arr = {}
		arr.atta = attatx
		arr.attan = attbtx
		arr.attb = attantx
		arr.attbn = attbntx
		self.attarr[i] = arr
	end

	local skillbbg = attbg:getChildByName('skilla_1_img')
	local skilltabb = {}
	skilltabb.bg = skillbbg
	skilltabb.lvatx = skillbbg:getChildByName('lva_tx')
	skilltabb.lvbtx = skillbbg:getChildByName('lvb_tx')
	skilltabb.nametx = skillbbg:getChildByName('name_tx')
	skilltabb.skillimg = skillbbg:getChildByName('skill_img')
	skilltabb.skillimg:ignoreContentAdaptWithSize(true)
	self.skillaarr[1] = skilltabb

	local skillabg = attbg:getChildByName('skillb_1_img')
	local skilltaba = {}
	skilltaba.bg = skillabg
	skilltaba.lvatx = skillabg:getChildByName('lva_tx')
	skilltaba.lvbtx = skillabg:getChildByName('lvb_tx')
	skilltaba.nametx = skillabg:getChildByName('name_tx')
	skilltaba.skillimg = skillabg:getChildByName('skill_img')
	skilltaba.skillimg:ignoreContentAdaptWithSize(true)
	self.skillaarr[2] = skilltaba


	self.maxarr = {}
	local attmaxbg = self.max_pl:getChildByName('att_img')
	local activetx2 = attmaxbg:getChildByName('att_active_tx')
	activetx2:setString(GlobalApi:getLocalStr('ROLESKILL'))
	local att2maxbg = attmaxbg:getChildByName('num_bg')
	for i=1,4 do
		local attatx = att2maxbg:getChildByName('atta_' .. i .. '_tx')
		local attantx = att2maxbg:getChildByName('numa_' .. i .. '_tx')
		local arr = {}
		arr.atta = attatx
		arr.attan = attantx
		self.maxarr[i] = arr
	end
	self.maxSkillarr = {}

	local skillmaxbbg = attmaxbg:getChildByName('skilla_1_img')
	local skillmaxtabb = {}
	skillmaxtabb.bg = skillmaxbbg
	skillmaxtabb.lvatx = skillmaxbbg:getChildByName('lva_tx')
	skillmaxtabb.lvbtx = skillmaxbbg:getChildByName('lvb_tx')
	skillmaxtabb.nametx = skillmaxbbg:getChildByName('name_tx')
	skillmaxtabb.skillimg = skillmaxbbg:getChildByName('skill_img')
	skillmaxtabb.skillimg:ignoreContentAdaptWithSize(true)
	self.maxSkillarr[1] = skillmaxtabb

	local skillmaxabg = attmaxbg:getChildByName('skillb_1_img')
	local skillmaxtaba = {}
	skillmaxtaba.bg = skillmaxabg
	skillmaxtaba.lvatx = skillmaxabg:getChildByName('lva_tx')
	skillmaxtaba.lvbtx = skillmaxabg:getChildByName('lvb_tx')
	skillmaxtaba.nametx = skillmaxabg:getChildByName('name_tx')
	skillmaxtaba.skillimg = skillmaxabg:getChildByName('skill_img')
	skillmaxtaba.skillimg:ignoreContentAdaptWithSize(true)
	self.maxSkillarr[2] = skillmaxtaba

	local tiao3 = self.nor_pl:getChildByName('tiao_3')
	
	self.uppercenttx = self.nor_pl:getChildByName('uppercent_tx')
	local needbg =self.nor_pl:getChildByName('neednumbg_img')

	local needtx = needbg:getChildByName('need_tx')
	needtx:setString(GlobalApi:getLocalStr('STR_CONSUME'))

	local Image_3 = needbg:getChildByName('Image_3')
	Image_3:setPositionX(needtx:getPositionX() + needtx:getContentSize().width)

	self.neednum = needbg:getChildByName('num_tx')
	self.neednum:setPositionX(Image_3:getPositionX() + Image_3:getContentSize().width)

	self.havenum = needbg:getChildByName('have_tx')

	local barbg = self.nor_pl:getChildByName('barbg_img')
	self.bar = self.nor_pl:getChildByName('bar')

    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(7,6,1,1))


	self.bartx = barbg:getChildByName('bar_tx')
	self.istouch = false
	self.tiemdelta = 0
	self.obj = nil
	self.num = 0  --长摁中计算的消耗次数
	self.energy = 0 --自己计算的剩余能量
	self.level = 0  --自己计算的等级
	self.lvbtn = self.nor_pl:getChildByName('lvup_btn')
	self.lvbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			local destinyconf =GameData:getConfData('destiny')[self.obj:getDestiny().level]
			local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
			local materialobj = BagData:getMaterialById(award:getId())
			if materialobj == nil then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
				GetWayMgr:showGetwayUI(award,true)
				return
			else
				local costnum =	award:getNum()
				local havenum = materialobj:getNum()
				if costnum > havenum then
					promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
					GetWayMgr:showGetwayUI(award,true)
				else

					-- add effect
					if self.animation1 == nil then
						self.animation1 = GlobalApi:createLittleLossyAniByName("tianming_dragon_00")
						local dsz = barbg:getContentSize()
						self.animation1:setPosition(cc.p(dsz.width / 2 + 8, dsz.height / 2 + 22))
						self.animation1:setAnchorPoint(cc.p(0.5, 0.5))
						self.animation1:getAnimation():setSpeedScale(1)
						self.animation1:getAnimation():playWithIndex(0,-1,-1)
						barbg:addChild(self.animation1, -1)
					end
					self.animation1:setOpacity(0)
					self.animation1:stopAllActions()
					self.animation1:runAction(cc.FadeIn:create(0.5))

					if self.animation2 == nil then
						self.animation2 = GlobalApi:createLittleLossyAniByName("tianming_soul_00")
						self.animation2:setAnchorPoint(cc.p(0.5, 0.5))
						self.animation2:getAnimation():setSpeedScale(1)
						self.animation2:getAnimation():playWithIndex(0,-1,-1)
						UIManager:addAction(self.animation2)
						local barsz = self.bar:getContentSize()
						local x2 = self.bar:getPercent() * barsz.width / 100
						local y2 = barsz.height / 2
						local pos2 = self.bar:convertToWorldSpace(cc.p(x2 - 23, y2))
						self.animation2:setPosition(cc.p(pos2.x, pos2.y))
					end

		   			self.istouch = true
		   			self.tiemdelta = 0
		   			local fate = self.obj:getDestiny()
		   			self.energy = fate.energy
		   			self.level = fate.level
		   		end
	   		end
   		elseif eventType ==  ccui.TouchEventType.ended or eventType ==  ccui.TouchEventType.canceled then
   			if self.animation1 ~= nil then
	   			self.animation1:stopAllActions()
	   			self.animation1:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), 
	   				cc.CallFunc:create(function()
	   						self.animation1:removeFromParent()
	   						self.animation1 = nil
	   					end)))
   			end
   			if self.animation2 ~= nil then
	   			self.animation2:removeFromParent()
				self.animation2 = nil
			end

   			self.istouch = false
   			if self.num > 0 then
				self:lvUpPost()
			end
   		end
	end)

	local title_tx = self.lvbtn:getChildByName('title_tx')
	title_tx:setString(GlobalApi:getLocalStr('TIANMING_ZHURU'))

	self.panel:scheduleUpdateWithPriorityLua(function (dt)
			self:updatepush(dt)
		end, 0)

	self.animation1 = nil
	self.animation2 = nil
end

function RoleTianmingUI:lvUpPost()
	if self.animation1 ~= nil then
		self.animation1:stopAllActions()
		self.animation1:runAction(cc.Sequence:create(cc.FadeOut:create(0.5), 
			cc.CallFunc:create(function()
					self.animation1:removeFromParent()
					self.animation1 = nil
				end)))
	end
	if self.animation2 ~= nil then
		self.animation2:removeFromParent()
		self.animation2 = nil
	end

	self.lvbtn:setTouchEnabled(false)
	self.istouch = false
	local args = {
		num = self.num,
		pos = self.obj:getPosId(),
	}
	MessageMgr:sendPost("upgrade_destiny", "hero", json.encode(args), function (jsonObj)
		local code = jsonObj.code
		if code == 0 then
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
			local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			local cd = self.obj:getDestiny()
			if cd.level < jsonObj.data.level then
				RoleMgr:showSkillUpgrade(self.obj,
					function (  )
						self.obj:setDestiny(jsonObj.data.level,jsonObj.data.energy,jsonObj.data.expect)
						self.obj:setFightForceDirty(true)
						RoleMgr:updateRoleList()
						RoleMgr:updateRoleMainUI()
						self.num = 0
						self.level =  jsonObj.data.level
						self.energy = jsonObj.data.energy
						self.tiemdelta = 0
						self.lvbtn:setTouchEnabled(true)
					end)
				return
			else
				self.obj:setDestiny(jsonObj.data.level,jsonObj.data.energy,jsonObj.data.expect)
				self.level =  jsonObj.data.level
				self.energy = jsonObj.data.energy
			end
			self.obj:setDestiny(jsonObj.data.level,jsonObj.data.energy,jsonObj.data.expect)
			self.obj:setFightForceDirty(true)
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'), COLOR_TYPE.RED)
		end
		RoleMgr:updateRoleList()
		RoleMgr:updateRoleMainUI()
		self.num = 0
		self.energy = 0
		self.level = 0
		self.tiemdelta = 0
		self.lvbtn:setTouchEnabled(true)
	end)
end

function RoleTianmingUI:updatetitle(percent)
	percent = tonumber(percent)
	if percent <= 20 then
		self.uppercenttx:setString(GlobalApi:getLocalStr('STR_UPPERCENT1'))
	elseif percent >20 and percent <=30 then
		self.uppercenttx:setString(GlobalApi:getLocalStr('STR_UPPERCENT2'))
	elseif percent >30 and percent <=50 then
		self.uppercenttx:setString(GlobalApi:getLocalStr('STR_UPPERCENT3'))
	elseif percent >50 and percent <=60 then
		self.uppercenttx:setString(GlobalApi:getLocalStr('STR_UPPERCENT4'))
	elseif percent >60 and percent <=100 then
		self.uppercenttx:setString(GlobalApi:getLocalStr('STR_UPPERCENT5'))
	end
end

function RoleTianmingUI:updatebar(level,energy,need,have,oldenergy )
	local destinyconf =GameData:getConfData('destiny')[level]
	local percent =string.format("%.2f", (energy/destinyconf['maxEnergy'])*100)  
	self:updatetitle(percent)
	self.bar:setPercent(percent)
	self.bartx:setString(GlobalApi:getLocalStr('STR_TIANMINGZHI') ..' ' .. energy ..'/' ..destinyconf['maxEnergy'])
	local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
	self.neednum:setString(award:getNum())

	self.havenum:setPositionX(self.neednum:getPositionX() + self.neednum:getContentSize().width + 2)
	-- if award:getId() == 300001 then
	-- 	self.lvbtn:loadTextureNormal('uires/ui/role/role_btn_tm_nor.png')
	-- elseif award:getId() == 300019 then
	-- 	self.lvbtn:loadTextureNormal('uires/ui/role/role_btn_tm_high.png')
	-- end
	self.havenum:setString("/ "..have)
	if have < award:getNum() then
		self.neednum:setTextColor(cc.c3b(255,0,0))
	else
		self.neednum:setTextColor(cc.c3b(0,255,0))
	end
	if oldenergy and energy - oldenergy > 0 then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_TIANMINGZHI') ..GlobalApi:getLocalStr('STR_ADD')..(energy - oldenergy),COLOR_TYPE.GREEN)
	end

	local barsz = self.bar:getContentSize()
	local x2 = percent * barsz.width / 100
	local pos = self.bar:convertToWorldSpace(cc.p(x2 - 23, 0))
	if	self.animation2 then
		self.animation2:setPositionX(pos.x)
	end
end

function RoleTianmingUI:onMoveOut()
end

function RoleTianmingUI:calFunction()
	local destinyconf =GameData:getConfData('destiny')[self.level]
	local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
	local materialobj = BagData:getMaterialById(award:getId())
	if materialobj == nil then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
		return
	end
	local costnum =	award:getNum()
	local havenum = materialobj:getNum()
	
	if costnum <= havenum-self.num*costnum then
		if self.energy < destinyconf['minUpEnergy'] then
			self.num = self.num + 1
			local energy = clone(self.energy)
			self.energy = self.energy + destinyconf['getEnergy']
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum, energy)
			--print('self.energy===='..self.energy)
			return
		end

		if self.energy >= destinyconf['maxEnergy'] then
			local energy = clone(self.energy)
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum ,energy)
			self:lvUpPost()
			--print('self.energy===='..self.energy)
			return
		end
		--print('self.energy===='..self.energy)
		
		local lvupneedExp = self.obj:getDestiny().expect
		--print('lvupneedExp===='..lvupneedExp)
		if self.energy >= lvupneedExp then
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum )
			self:lvUpPost()
			return
		else
			self.num = self.num + 1
			local energy = clone(self.energy)
			self.energy = self.energy + destinyconf['getEnergy']
			if self.energy >= destinyconf['maxEnergy'] then
				self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum )
				self:lvUpPost()
				return
			end
			self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum ,energy)
		end
	else
		if self.num > 0 then
			self:lvUpPost()
		end
	end

	self:updatebar(self.level,self.energy,costnum,havenum-self.num*costnum )
end

function RoleTianmingUI:updatepush(dt)
	self.tiemdelta = self.tiemdelta + dt 
	if self.istouch and self.tiemdelta > MAXDELTA then
		--todo
		self:calFunction(self.obj)
		self.tiemdelta = 0
	end
end

function RoleTianmingUI:updateNorPanel(obj)
	local str = GlobalApi:getLocalStr('TITLE_TM') 
	if obj:getDestiny().level > 0 then
		str = GlobalApi:getLocalStr('TITLE_TM')..' + '..obj:getDestiny().level
	end
    RoleMgr:setRoleMainTitle(str)
	local skilltab = obj:getSkillIdTab()
	local fate =obj:getDestiny()
	local destinyconf =GameData:getConfData('destiny')[fate.level]
	local destinyconfnext = GameData:getConfData('destiny')[fate.level+1]
    local skillconf = GameData:getConfData("skill")
    for i=1,#skilltab do
        local skill = skillconf[skilltab[i]]
        local skillName = skill['name']
        local skillicon ='uires/icon/skill/' .. skill['skillIcon']
        self.skillaarr[i].lvbtx:setString('Lv.' .. fate.level)
        self.skillaarr[i].lvbtx:setAnchorPoint(cc.p(1,0.5))
        self.skillaarr[i].lvbtx:setPositionX(140)
        self.skillaarr[i].lvatx:setString('Lv.' .. fate.level+1)
        self.skillaarr[i].nametx:setString(skillName)
        self.skillaarr[i].skillimg:loadTexture(skillicon)
        self:addEvent(self.skillaarr[i].bg,skilltab[i])
    end

    local baseatt = RoleData:getPosAttByPos(obj)
    local curattarr = {}
    curattarr[1] = math.floor(baseatt[1])
    curattarr[2] = math.floor(baseatt[4])
    curattarr[3] = math.floor(baseatt[2])
    curattarr[4] = math.floor(baseatt[3])
    self.curattarr = curattarr

    local tempobj = clone(obj)
    tempobj:setDestiny(fate.level+1,0,tempobj:getDestiny().expect)
    local baseatttemp = RoleData:CalPosAttByPos(tempobj,true)
    local nextattarr = {}
    nextattarr[1] = math.floor(baseatttemp[1])
    nextattarr[2] = math.floor(baseatttemp[4])
    nextattarr[3] = math.floor(baseatttemp[2])
    nextattarr[4] = math.floor(baseatttemp[3])
    self.nextattarr = nextattarr

    local addarr = {}
    addarr[1] = math.floor(nextattarr[1] -curattarr[1])
    addarr[2] = math.floor(nextattarr[2] -curattarr[2])
    addarr[3] = math.floor(nextattarr[3] -curattarr[3])
    addarr[4] = math.floor(nextattarr[4] -curattarr[4])

    for i=1,4 do
    	self.attarr[i].attbn:removeAllChildren()
    	self.attarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.attarr[i].attan:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.attarr[i].attb:setString(curattarr[i])
		self.attarr[i].attbn:setString('')
		local richText = xx.RichText:create()
		local re1 = xx.RichTextLabel:create(nextattarr[i].."   ",25, COLOR_TYPE.GREEN)
    	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    	local re2 = xx.RichTextImage:create('uires/ui/common/arrow_up2.png')
    	richText:addElement(re1)
    	
		if addarr[i] > 0 then
			richText:addElement(re2)
		end
		richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(0,15))
		richText:setVerticalAlignment('middle')
	    self.attarr[i].attbn:addChild(richText,9527)
	    richText:setVisible(true)
    end

	local award = DisplayData:getDisplayObj(destinyconf['cost'][1])
	self.neednum:setString(award:getNum())

	self.havenum:setPositionX(self.neednum:getPositionX() + self.neednum:getContentSize().width + 2)

	local materialobj = BagData:getMaterialById(award:getId())
	if materialobj then
		self.havenum:setString("/ "..materialobj:getNum())
		if materialobj:getNum() < award:getNum() then
			self.neednum:setTextColor(cc.c3b(255,0,0))
		else
			self.neednum:setTextColor(cc.c3b(0,255,0))
		end
	else
		self.havenum:setString("/ 0")
	end
	local percent =string.format("%.2f", (fate.energy/destinyconf['maxEnergy'])*100)  
	self:updatetitle(percent)
	self.bar:setPercent(percent)
	self.bartx:setString(GlobalApi:getLocalStr('STR_TIANMINGZHI') ..' ' ..fate.energy ..'/' ..destinyconf['maxEnergy'])
	-- if award:getId() == 300001 then
	-- 	self.lvbtn:loadTextureNormal('uires/ui/role/role_btn_tm_nor.png')
	-- elseif award:getId() == 300019 then
	-- 	self.lvbtn:loadTextureNormal('uires/ui/role/role_btn_tm_high.png')
	-- end
end

function RoleTianmingUI:updateMaxPanel(obj)
	local skilltab = obj:getSkillIdTab()
	local fate =obj:getDestiny()
	local destinyconf =GameData:getConfData('destiny')[fate.level]
	local destinyconfnext = GameData:getConfData('destiny')[fate.level+1]
    local skillconf = GameData:getConfData("skill")
    for i=1,#skilltab do
        local skill = skillconf[skilltab[i]]
        local skillName = skill['name']
        local skillicon ='uires/icon/skill/' .. skill['skillIcon']
        self.maxSkillarr[i].lvbtx:setString('Lv.' .. fate.level)
        self.maxSkillarr[i].nametx:setString(skillName)
        self.maxSkillarr[i].skillimg:loadTexture(skillicon)
        self:addEvent(self.maxSkillarr[i].bg,skilltab[i])
    end

   	local baseatt = RoleData:getPosAttByPos(obj)
    local curattarr = {}
    curattarr[1] = math.floor(baseatt[1])
    curattarr[2] = math.floor(baseatt[4])
    curattarr[3] = math.floor(baseatt[2])
    curattarr[4] = math.floor(baseatt[3])

    for i=1,4 do
    	self.maxarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.maxarr[i].attan:setString(curattarr[i])
    end
    local str = GlobalApi:getLocalStr('TITLE_TM')..' + '..obj:getDestiny().level
    RoleMgr:setRoleMainTitle(str)
end

function RoleTianmingUI:update(obj)
	self.obj = obj
	if obj:getDestiny().level >= maxlv then
		self:updateMaxPanel(obj)
		self.nor_pl:setVisible(false)
		self.max_pl:setVisible(true)
	else
		self:updateNorPanel(obj)
		self.nor_pl:setVisible(true)
		self.max_pl:setVisible(false)
	end
end

function RoleTianmingUI:addEvent(parent,skillid,pos)
	parent:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
        	local size = parent:getContentSize()
			local x, y = parent:convertToWorldSpace(cc.p(parent:getPosition(size.width / 2, size.height / 2)))
  	    	TipsMgr:showRoleSkillTips(self.obj:getDestiny().level,skillid,cc.p(x,y),true)
         end
    end)
end

return RoleTianmingUI