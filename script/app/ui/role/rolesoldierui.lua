local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local RoleSoldierUI = class("RoleSoldierUI", ClassRoleBaseUI)
local ClassDressObj = require('script/app/obj/dressobj')
local defaulticon = 'uires/ui/common/add_02.png'
local defaulticon1 = 'uires/ui/common/add_01.png'
local defaulticon2 = 'uires/ui/common/lock_2.png'
function RoleSoldierUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/rolesoldierpanel.csb")
	self.panel:setName("role_soldier_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')
	self.max_pl = bgimg:getChildByName('max_pl')
	-- self.aatbimg = self.nor_pl:getChildByName('bef_img')
	-- self.aataimg = self.nor_pl:getChildByName('aft_img')
	self.attarr = {}
	local att2bg = self.nor_pl:getChildByName('num_bg')
	for i=1,4 do
		local attatx = att2bg:getChildByName('atta_' .. i .. '_tx') -- 攻击
		local attbtx = att2bg:getChildByName('attb_' .. i .. '_tx')
        attbtx:setVisible(false)
		local attantx = att2bg:getChildByName('numa_' .. i .. '_tx') -- 10000
		local attbntx = att2bg:getChildByName('numb_' .. i .. '_tx') -- +500
		local addtx = att2bg:getChildByName('add_' .. i .. '_tx')
        addtx:setVisible(false)
		local dresstx = att2bg:getChildByName('dress_' .. i .. '_tx')
        dresstx:setVisible(false)
		local arrowimg = att2bg:getChildByName('arrow_' .. i .. '_img') -- 箭头
		local arr = {}
		arr.atta = attatx
		--arr.attan = attbtx
		arr.attb = attantx
		arr.attbn = attbntx
		--arr.add = addtx
		--arr.dress = dresstx
		arr.arrow = arrowimg
		self.attarr[i] = arr
	end

    -- 激活
    self.activeAtt = {}
    for i=1,4 do
        local arr = {}
        arr.actNum = i + 1
		arr.attatx = self.nor_pl:getChildByName('act_' .. i .. '_tx')
        self.activeAtt[i] = arr
	end

	self.soldierarrbef = {}
	self.soldierarraft = {}
	for i=1,1 do    -- 循环1次
		local attbbg = self.nor_pl:getChildByName('a_pl')
		self.soldierarrbef[i] = attbbg:getChildByName('soldier_' .. i ..'_img')
		self.soldierarrbef[i]:ignoreContentAdaptWithSize(true)
		self.soldiernumb = attbbg:getChildByName('num_tx')

        self.leftWidget = ccui.Layout:create()
        self.leftWidget:setAnchorPoint(cc.p(0,0.5))
        self.leftWidget:setContentSize(cc.size(20,90))

        --self.leftWidget:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        --self.leftWidget:setBackGroundColor(cc.c3b(0xff,0,0))
        --self.leftWidget:setBackGroundColorOpacity(100)

        self.leftWidget:setPosition(cc.p(self.soldierarrbef[i]:getPositionX() + 80,self.soldierarrbef[i]:getPositionY() - 2))
        attbbg:addChild(self.leftWidget)

		local attabg = self.nor_pl:getChildByName('b_pl')
		self.soldierarraft[i] = attabg:getChildByName('soldier_' .. i ..'_img')
		self.soldierarraft[i]:ignoreContentAdaptWithSize(true)
		self.soldiernuma = attabg:getChildByName('num_tx')
        

        self.rightWidget = ccui.Layout:create()
        self.rightWidget:setAnchorPoint(cc.p(0,0.5))
        self.rightWidget:setContentSize(cc.size(20,90))

        --self.rightWidget:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
        --self.rightWidget:setBackGroundColor(cc.c3b(0xff,0,0))
        --self.rightWidget:setBackGroundColorOpacity(100)

        self.rightWidget:setPosition(cc.p(self.soldierarrbef[i]:getPositionX() + 75,self.soldierarrbef[i]:getPositionY() - 2))
        attabg:addChild(self.rightWidget)

	end
	self.soldierartnode = self.nor_pl:getChildByName('mod_pl')

	self.skillarr = {}
	local skillpl = self.nor_pl:getChildByName('skill_pl')
	for i=1,4 do
		local skillbg = skillpl:getChildByName('skilla_' .. i ..'_img')
		skillbg:addTouchEventListener(function (sender,eventType)
			if eventType ==ccui.TouchEventType.ended then
				--if self.soldier.skills[tostring(i)] > 0 then
					RoleMgr:showSoldierSkill(self.obj)
				--end
			end
		end)
		local arr = {}
		arr.icon = skillbg:getChildByName('skill_img')
		arr.icon:ignoreContentAdaptWithSize(true)
		--arr.frame = skillbg:getChildByName('frame_img')
		arr.skillbg =skillbg
		arr.lvtx = skillbg:getChildByName('lv_tx')
		arr.nametx = skillbg:getChildByName('name_tx')
		arr.lock = skillbg:getChildByName('lock_img')
		arr.newimg = skillbg:getChildByName('new_img')
		arr.newimg:setVisible(false)
		self.skillarr[i] = arr
	end

	self.soldier = nil
	self.equiparr = {}
	local armbg = self.nor_pl:getChildByName('arm_img')
	for i=1,6 do
		local itemtab = {}
		local equipbg = armbg:getChildByName('arm_' .. i ..'_img')
		itemtab.icon = equipbg:getChildByName('icon_img')
		itemtab.icon:ignoreContentAdaptWithSize(true)
		itemtab.equipbg = equipbg
		itemtab.add = equipbg:getChildByName('add_img')
		itemtab.add:ignoreContentAdaptWithSize(true)
		itemtab.numtx = equipbg:getChildByName('num_tx')
		equipbg:addTouchEventListener(function (sender,eventType)
			if eventType ==ccui.TouchEventType.ended then
				if self.soldier.dress[tostring(i)] ~= 1 then
					local equiparr = self.obj:getSoldierArmArr()
					--GetWayMgr:showSoldierEquip(equiparr[i].id,equiparr[i].num,self.obj)
					local obj = BagData:getDressById(equiparr[i].id) or  ClassDressObj.new(tonumber(equiparr[i].id), 0)
					GetWayMgr:showGetwayUI(obj,true,equiparr[i].num,self.obj,equiparr[i].poslevel,false)
				else 
					--local x, y = equipbg:convertToWorldSpace(cc.p(equipbg:getPosition()))
					local size = equipbg:getContentSize()
    				local x, y = equipbg:convertToWorldSpace(cc.p(equipbg:getPosition(size.width / 2, size.height / 2)))
					TipsMgr:showSoldierEquipTips(self.obj,i,cc.p(680,200))
				end
			end
		end)
		self.equiparr[i] = itemtab
	end
	local lvbtn = armbg:getChildByName("lv_btn")
    self.lvbtn = lvbtn
	self.functx = lvbtn:getChildByName('func_tx')
	self.functx:setString(GlobalApi:getLocalStr('SOLDIERLVUP1'))
    lvbtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
    		local canlvup = true
    		local equiparr = self.obj:getSoldierArmArr()
    		for i=1,6 do
    			if equiparr[i].id > 0 and self.soldier.dress[tostring(i)] ~= 1 then
    				canlvup = false
    			end
    		end
            if canlvup then
                self.lvbtn:setTouchEnabled(false)
                local args = {
                    pos = self.obj:getPosId()
                }
                MessageMgr:sendPost("upgrade_soldier", "hero", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        self.upgrade_soldier = true
                    	RoleMgr:showSoldierUpgrade(self.obj, self.curattarr, self.nextattarr, function (  )
	                        self.obj:setSoldierLv()
	                        self.obj:setFightForceDirty(true)
	                        RoleMgr:updateRoleList()
	                        RoleMgr:updateRoleMainUI()
	                        promptmgr:showSystenHint(GlobalApi:getLocalStr("UP_SUCC"), COLOR_TYPE.GREEN)                     
                            self.upgrade_soldier = false
                    	end)
                    end
                end)
            else
            	--todo
            	local  canquip = self.obj:isSoldierCanEquip()
            	if not canquip then
            		promptmgr:showSystenHint(GlobalApi:getLocalStr("EQUIP_FAIL"), COLOR_TYPE.RED)
            		return
            	end
                local args = {
                    pos = self.obj:getPosId()
                }
                MessageMgr:sendPost("dress_wear_all", "hero", json.encode(args), function (jsonObj)
                    print(json.encode(jsonObj))
                    local code = jsonObj.code
                    if code == 0 then
                        local awards = jsonObj.data.awards
                        GlobalApi:parseAwardData(awards)
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        for k,v in pairs(costs) do
                    	    self.obj:setSoldierdress(v[2]%10)
                    	end
                        self.obj:setFightForceDirty(true)
                        RoleMgr:updateRoleList()
                        RoleMgr:updateRoleMainUI()
                        if #costs > 0 then
                        	promptmgr:showSystenHint(GlobalApi:getLocalStr('EQUIP_SUCC'), COLOR_TYPE.GREEN)
                    	else
                    		promptmgr:showSystenHint(GlobalApi:getLocalStr('EQUIP_FAIL'), COLOR_TYPE.RED)
                    	end
                    end
                end)
            end
    	end	
    end)

    local infobtn = self.nor_pl:getChildByName('info_btn')
    infobtn:addTouchEventListener(function (sender, eventType)
    	if eventType ==  ccui.TouchEventType.ended then
    		RoleMgr:showSoldierinfo(self.obj)
    	end	
    end)   

    self.maxarr = {} --突破满级属性控件
    self.attmaxbg = self.max_pl:getChildByName('num_bg')
   -- local att2maxbg = self.attmaxbg:getChildByName('num_bg')
	for i=1,4 do
		local attatx = self.attmaxbg:getChildByName('atta_' .. i .. '_tx')
		local attantx = self.attmaxbg:getChildByName('numa_' .. i .. '_tx')
		local arr = {}
		arr.atta = attatx
		arr.attan = attantx
		self.maxarr[i] = arr
	end

	self.soldiermaxarr = {}
	for i=1,1 do
		local attbbg = self.max_pl:getChildByName('a_pl')
		self.soldiermaxarr[i] = attbbg:getChildByName('soldier_' .. i ..'_img')
		self.soldiermaxarr[i]:ignoreContentAdaptWithSize(true)
		self.soldiernummax = attbbg:getChildByName('num_tx')
	end


	self.skillmaxarr = {}
	local skillmaxpl = self.max_pl:getChildByName('skill_pl')
	for i=1,4 do
		local skillbg = skillmaxpl:getChildByName('skilla_' .. i ..'_img')
		skillbg:addTouchEventListener(function (sender,eventType)
			if eventType ==ccui.TouchEventType.ended then
				--if self.soldier.skills[tostring(i)] > 0 then
					RoleMgr:showSoldierSkill(self.obj)
				--end
			end
		end)
		local arr = {}
		arr.icon = skillbg:getChildByName('skill_img')
		arr.icon:ignoreContentAdaptWithSize(true)
		--arr.frame = skillbg:getChildByName('frame_img')
		arr.skillbg = skillbg
		arr.lvtx = skillbg:getChildByName('lv_tx')
		arr.nametx = skillbg:getChildByName('name_tx')
		arr.lock = skillbg:getChildByName('lock_img')
		arr.newimg = skillbg:getChildByName('new_img')
		arr.newimg:setVisible(false)
		self.skillmaxarr[i] = arr
	end
	local infomaxbtn = self.max_pl:getChildByName('info_btn')
    infomaxbtn:addTouchEventListener(function (sender, eventType)
    	if eventType ==  ccui.TouchEventType.ended then
    		RoleMgr:showSoldierinfo(self.obj)
    	end	
    end)

    local widget = ccui.Layout:create()
    widget:setAnchorPoint(cc.p(0.5,0.5))
    widget:setContentSize(cc.size(20,90))

    local offset = 9
    for i = 1,5 do
        local img = ccui.ImageView:create()
        img:loadTexture('uires/ui/role/role_star_3.png')
        img:setPosition(cc.p(10,offset))
        widget:addChild(img)
        offset = offset + 18
    end

    widget:setPosition(cc.p(infomaxbtn:getPositionX() - 60,infomaxbtn:getPositionY() + 5))
    self.max_pl:addChild(widget)


    self.upgrade_soldier = false
end

function RoleSoldierUI:getStarNumAndLevel(level)
    if level <= 5 then
        local num = level
        local url = 'uires/ui/role/role_star_1.png'
        return num,url
    elseif level > 5 and level <= 10 then
        local num = level - 5
        local url = 'uires/ui/role/role_star_2.png'
        return num,url
    else
        local num = level - 10
        local url = 'uires/ui/role/role_star_3.png'
        return num,url
    end

end

-- 更新星星
function RoleSoldierUI:updateStar()
	local soldier = self.obj:getSoldier()
    local speed = 1
    -- left
    for i = 1,5 do
        if self.leftWidget:getChildByName('left' .. i) then
            self.leftWidget:removeChildByName('left' .. i)
        end
    end

    local offset = 9
    local num,url = self:getStarNumAndLevel(soldier.level)
    self.leftWidget:setContentSize(cc.size(20,18*num))
    self.leftWidget:setPosition(cc.p(self.soldierarrbef[1]:getPositionX() + 80,self.soldierarrbef[1]:getPositionY() - 2))
    for i = 1,num do
        local img = ccui.ImageView:create()
        img:setName('left' .. i)
        img:loadTexture(url)
        img:setPosition(cc.p(10,offset))
        self.leftWidget:addChild(img)

        if soldier.level == 1 then
            img:setVisible(false)
        end

        if (soldier.level == 2 and num - 1 == i and self.upgrade_soldier == true) or (num == i and self.upgrade_soldier == true) then
            print('----------123------------------')
            img:setScale(0)
            local act1 = cc.DelayTime:create(0.5)
	        local act2 = cc.CallFunc:create(function ()
                local size = img:getContentSize()
                local particle = cc.ParticleSystemQuad:create("particle/getitem.plist")
                particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                particle:setPosition(cc.p(10,offset))
                self.leftWidget:addChild(particle)

                --AudioMgr.playEffect("media/effect/show_award.mp3", false)
            end)
            local act3 = cc.DelayTime:create(0.1*speed)
            local act4 = cc.Spawn:create(cc.MoveTo:create(0.2*speed, cc.p(10,offset)),cc.ScaleTo:create(0.2*speed, 1), cc.RotateTo:create(0.2*speed, 720))
            local act5 = cc.CallFunc:create(function ()
            end)
	        img:runAction(cc.Sequence:create(act1,act2,act3,act4,act5))
        end
        offset = offset + 18
    end

    -- right
    for i = 1,5 do
        if self.rightWidget:getChildByName('right' .. i) then
            self.rightWidget:removeChildByName('right' .. i)
        end
    end
    local level = soldier.level + 1
    if level > 15 then
        level = 15
    end
    local num,url = self:getStarNumAndLevel(level)
    self.rightWidget:setContentSize(cc.size(20,18*num))
    self.rightWidget:setPosition(cc.p(self.soldierarrbef[1]:getPositionX() + 75,self.soldierarrbef[1]:getPositionY() - 2))
    local offset = 9
    for i = 1,num do
        local img = ccui.ImageView:create()
        img:setName('right' .. i)
        img:loadTexture(url)
        img:setPosition(cc.p(10,offset))
        self.rightWidget:addChild(img)
        if num == i and self.upgrade_soldier == true then
            img:setScale(0)
            local act1 = cc.DelayTime:create(0.5)
	        local act2 = cc.CallFunc:create(function ()
                local size = img:getContentSize()
                local particle = cc.ParticleSystemQuad:create("particle/getitem.plist")
                particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                particle:setPosition(cc.p(10,offset))
                self.rightWidget:addChild(particle)

                AudioMgr.playEffect("media/effect/show_award.mp3", false)
            end)
            local act3 = cc.DelayTime:create(0.1*speed)
            local act4 = cc.Spawn:create(cc.MoveTo:create(0.2*speed, cc.p(10,offset)),cc.ScaleTo:create(0.2*speed, 1), cc.RotateTo:create(0.2*speed, 720))
            local act5 = cc.CallFunc:create(function ()
            end)
	        img:runAction(cc.Sequence:create(act1,act2,act3,act4,act5))
        end
        offset = offset + 18
    end

end


function RoleSoldierUI:updateNorPanel(obj)
	self.obj = obj
	local soldierid = obj:getSoldierId()
	self.soldier = obj:getSoldier()
	local dresstab = {}
	dresstab =self.soldier.dress
	 
	local soldlevelconf = GameData:getConfData('soldierlevel')[soldierid][self.soldier.level]
	local soldlevelconf1 = GameData:getConfData('soldierlevel')[soldierid][self.soldier.level+1]
	local soldconf = GameData:getConfData('soldier')[soldlevelconf['soldierId']]
	local soldierSkillConf = GameData:getConfData('soldierskill')
	local soldierdressConf = GameData:getConfData('dress')
	local attconf = GameData:getConfData('attribute')

	self.soldiernumb:setString('x '..soldlevelconf.num)
	self.soldiernuma:setString('x '..soldlevelconf1.num)
	self.soldierarrbef[1]:loadTexture('uires/ui/role/role_' ..soldlevelconf.soldierIcon )
	self.soldierarraft[1]:loadTexture('uires/ui/role/role_' ..soldlevelconf1.soldierIcon )


    self:updateStar()


	local skillarr = obj:getSoldierSkillArr()
	for i=1,4 do
		self.skillarr[i].newimg:setVisible(false)
		local lvlimit = skillarr[i][1]
		local img = 'uires/icon/skill/' .. soldierSkillConf[skillarr[i][2]]['icon']
		self.skillarr[i].icon:loadTexture(img)
		self.skillarr[i].icon:ignoreContentAdaptWithSize(true)
		self.skillarr[i].nametx:setString('')
		if self.soldier.level >= lvlimit then
			self.skillarr[i].lvtx:setString('Lv.' .. self.soldier.skills[tostring(i)])
			--self.skillarr[i].nametx:setString(soldierSkillConf[skillarr[i][2]]['name'])
			self.skillarr[i].lock:setVisible(false)
			ShaderMgr:restoreWidgetDefaultShader(self.skillarr[i].icon)
			ShaderMgr:restoreWidgetDefaultShader(self.skillarr[i].skillbg)
			local lvconf  = GameData:getConfData('level')
			if self.obj:getSoldier().skills[tostring(i)]+1 < #lvconf then
				local costvalue = lvconf[self.obj:getSoldier().skills[tostring(i)]]['soldierskilllevelupcost']
				if tonumber(self.obj:getSoldier().skills[tostring(i)]) < self.obj:getLevel() and UserData:getUserObj():getGold() >= tonumber(costvalue) then
					self.skillarr[i].newimg:setVisible(true)
				else
					self.skillarr[i].newimg:setVisible(false)
				end
			else
				self.skillarr[i].newimg:setVisible(false)
			end
		else
			ShaderMgr:setGrayForWidget(self.skillarr[i].icon)
			ShaderMgr:setGrayForWidget(self.skillarr[i].skillbg)
			self.skillarr[i].lock:setVisible(true)
			self.skillarr[i].lvtx:setString('')
			--self.skillarr[i].nametx:setString(string.format(GlobalApi:getLocalStr('SOLDIERSKILLLIMIT'),lvlimit))
		end
	end

	local equiparr = obj:getSoldierArmArr()
	
	for i=1,6 do
		local lvlimit = equiparr[i].poslevel
		self.equiparr[i].numtx:setString('')		
		if equiparr[i].id > 0 and self.soldier.dress[tostring(i)] == 1 then
			local img = 'uires/icon/dress/' .. soldierdressConf[equiparr[i].id]['icon']
			self.equiparr[i].icon:loadTexture(img)
			self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
			self.equiparr[i].add:setVisible(false)
			self.equiparr[i].equipbg:setTouchEnabled(true)
			self.equiparr[i].numtx:setString(equiparr[i].num)	
		elseif equiparr[i].id == 0 then
			self.equiparr[i].add:setVisible(true)
			self.equiparr[i].equipbg:setTouchEnabled(false)
		 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.GRAY)
		 	self.equiparr[i].add:loadTexture(defaulticon2)	
		else
		 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.DEFAULT)
		 	local dressobj = BagData:getDressById(equiparr[i].id)
		 	self.equiparr[i].icon:loadTexture(DEFAULTSOLDEREQUIP[i])
		 	if dressobj ~= nil and equiparr[i].num <= dressobj:getNum() and self.obj:getLevel() >=lvlimit then
		 		self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
		 		self.equiparr[i].add:loadTexture(defaulticon1)
		 		self.equiparr[i].add:setVisible(true)
		 		self.equiparr[i].equipbg:setTouchEnabled(true)
		 	elseif dressobj ~= nil and equiparr[i].num <= dressobj:getNum() then
		 		self.equiparr[i].add:loadTexture(defaulticon)
		 		self.equiparr[i].add:setVisible(true)
			 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
			 	self.equiparr[i].equipbg:setTouchEnabled(true)
			else
				self.equiparr[i].add:loadTexture(defaulticon)
				self.equiparr[i].add:setVisible(true)
				self.equiparr[i].equipbg:setTouchEnabled(true)
			 	self.equiparr[i].equipbg:loadTexture(COLOR_ITEMFRAME.ORANGE)
		 	end
		end
	end

	local canlvup = true
	local attconf =GameData:getConfData('attribute')
	local attcount = #attconf
	local dressarr = {}
	local dressmaxarr = {}
	for i=1,attcount do
		dressarr[i] = 0
		dressmaxarr[i] = 0
	end
	local conf = GameData:getConfData('soldierlevel') [obj:getSoldierId()][self.soldier.level]
	for i=1,6 do
		local equipNum = conf['equipNum' .. i]
		local equipId = conf['equipId' .. i]
		local dressconf = GameData:getConfData('dress')[equipId]
		if dressconf and self.soldier.dress[tostring(i)] == 1 then
			for j=1,2 do
				local dressatt = dressconf['att'.. j]
				local dressvalue = dressconf['value' .. j]*equipNum
				dressarr[dressatt] = dressarr[dressatt] + dressvalue
			end
		end
		if equiparr[i].id >0 and self.soldier.dress[tostring(i)] ~= 1 then
			canlvup = false
		end
	end

	local conf1 = GameData:getConfData('soldierlevel') [obj:getSoldierId()][self.soldier.level]
	for i=1,6 do
		local equipNum = conf1['equipNum' .. i]
		local equipId = conf1['equipId' .. i]
		local dressconf = GameData:getConfData('dress')[equipId]
		if dressconf then
			for j=1,2 do
				local dressatt = dressconf['att'.. j]
				local dressvalue = dressconf['value' .. j]*equipNum
				dressmaxarr[dressatt] = dressmaxarr[dressatt] + dressvalue
			end
		end
	end

	if canlvup then
		self.functx:setString(GlobalApi:getLocalStr('SOLDIERLVUP1'))
        if self.lvbtn:getChildByName('ui_yijianzhuangbei') then
            self.lvbtn:removeChildByName('ui_yijianzhuangbei')
        end
        local size = self.lvbtn:getContentSize()
        local effect = GlobalApi:createLittleLossyAniByName('ui_yijianzhuangbei')
        effect:setName('ui_yijianzhuangbei')
        effect:setPosition(cc.p(size.width/2 ,size.height/2))
        effect:setAnchorPoint(cc.p(0.5,0.5))
        effect:getAnimation():playWithIndex(0, -1, 1)
        self.lvbtn:addChild(effect)

	else
        if self.lvbtn:getChildByName('ui_yijianzhuangbei') then
            self.lvbtn:removeChildByName('ui_yijianzhuangbei')
        end
		self.functx:setString(GlobalApi:getLocalStr('EQUIP1'))
	end
	local att = RoleData:getPosAttByPos(obj)
	local attsoidlerbefor,percentattbefer = obj:getSoldierUpgradeAtt(self.soldier.level,false)
	local attsoidlerafter,percentattafter = obj:getSoldierUpgradeAtt(self.soldier.level+1,true)
	local curattarr = {}
	local addarr = {}

	for i=1,attcount do
		addarr[i] = 0
	end

	--local baseattarr = obj:getCalBaseAtt()
	for i=1,attcount do
		addarr[i] = addarr[i] + (attsoidlerafter[i]-attsoidlerbefor[i]) -- -dressarr[i]+ dressnextarr[i]) 
		addarr[i] = addarr[i] + math.floor(att[i]*((percentattafter[i]-percentattbefer[i])/100))
	end

	curattarr[1] = math.floor((att[1] - dressarr[1] ))--*soldconf['attPowPercent']/100)
	curattarr[2] = math.floor((att[4] - dressarr[4] ))--*soldconf['heaPowPercent']/100)
	curattarr[3] = math.floor((att[2] - dressarr[2] ))--*soldconf['phyArmPowPercent']/100) 
	curattarr[4] = math.floor((att[3] - dressarr[3] ))--*soldconf['magArmPowPercent']/100) 
	self.curattarr = curattarr
	local nextattarr = {}

	nextattarr[1] = math.floor((att[1] + addarr[1] ))--*soldconf['attPowPercent']/100) 
	nextattarr[2] = math.floor((att[4] + addarr[4]))--*soldconf['heaPowPercent']/100)
	nextattarr[3] = math.floor((att[2] + addarr[2] ))--*soldconf['phyArmPowPercent']/100) 
	nextattarr[4] = math.floor((att[3] + addarr[3]))--*soldconf['magArmPowPercent']/100) 
	self.nextattarr = {}
	self.nextattarr[1] = math.floor((att[1] + addarr[1]))--*soldconf['attPowPercent']/100) 
	self.nextattarr[2] = math.floor((att[4] + addarr[4]))--*soldconf['heaPowPercent']/100)
	self.nextattarr[3] = math.floor((att[2] + addarr[2]))--*soldconf['phyArmPowPercent']/100) 
	self.nextattarr[4] = math.floor((att[3] + addarr[3]))--*soldconf['magArmPowPercent']/100) 	
	local dressshowarr = {}
	dressshowarr[1] = math.floor(dressarr[1])--*soldconf['attPowPercent']/100)
	dressshowarr[2] = math.floor(dressarr[4])--*soldconf['heaPowPercent']/100)
	dressshowarr[3] = math.floor(dressarr[2])--*soldconf['phyArmPowPercent']/100)
	dressshowarr[4] = math.floor(dressarr[3])--*soldconf['magArmPowPercent']/100)


    -- 激活
    local atts,allAtts = obj:getSoldierdressAtts()
    local activeAtt = self.activeAtt
    local num = obj:getSoldierdressNum()
    if atts and allAtts then
        for i=1,4 do
            if allAtts[activeAtt[i].actNum] then
                local att1 = allAtts[activeAtt[i].actNum].att1
                local str = string.format(GlobalApi:getLocalStr('ACTIVE_COUNT_ATTR'),activeAtt[i].actNum,GameData:getConfData('attribute')[att1].name,allAtts[activeAtt[i].actNum].value1)
                activeAtt[i].attatx:setString(str)

                --ShaderMgr:setGrayForWidget(activeAtt[i].attatx)
                if activeAtt[i].actNum <= num then
                    --ShaderMgr:restoreWidgetDefaultShader(activeAtt[i].attatx)
                    activeAtt[i].attatx:setTextColor(COLOR_TYPE.GREEN)
                else
                    --ShaderMgr:setGrayForWidget(activeAtt[i].attatx)
                    activeAtt[i].attatx:setTextColor(COLOR_TYPE.GRAY)
                end
            end

        end

    end


	for i=1,4 do
		--[[
        self.attarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.attarr[i].attan:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.attarr[i].attb:setString(curattarr[i])
		self.attarr[i].attbn:setString(nextattarr[i])
		self.attarr[i].add:setString('')
		self.attarr[i].arrow:setVisible(false)
		if att[i] > 0 then
			--self.attarr[i].add:setString(addshowarr[i])
			self.attarr[i].arrow:setVisible(true)
		end
		if dressshowarr[i] > 0 then
			self.attarr[i].dress:setString('+'..dressshowarr[i])
		else
			self.attarr[i].dress:setString('')
		end
        --]]

        self.attarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
        self.attarr[i].attb:setString(curattarr[i])
		self.attarr[i].attbn:setString('+' .. nextattarr[i] - curattarr[i])
        self.attarr[i].arrow:setVisible(false)
        if att[i] > 0 then
			self.attarr[i].arrow:setVisible(true)
		end

        local size = self.attarr[i].attbn:getContentSize()
        local posX = self.attarr[i].attbn:getPositionX()
        self.attarr[i].arrow:setPositionX(posX + size.width + 10)


	end
	local str = soldconf['soldierName'].. self.soldier.level .. GlobalApi:getLocalStr('SOLDIER0')
	RoleMgr:setRoleMainTitle(str)



end


function RoleSoldierUI:updateMaxPanel(obj)
	self.obj = obj
	local soldierid = obj:getSoldierId()
	self.soldier = obj:getSoldier()
	local dresstab = {}
	dresstab =self.soldier.dress
	 
	local soldlevelconf = GameData:getConfData('soldierlevel')[soldierid][self.soldier.level]
	local soldlevelconf1 = GameData:getConfData('soldierlevel')[soldierid][self.soldier.level+1]
	local soldconf = GameData:getConfData('soldier')[soldlevelconf['soldierId']]
	local soldierSkillConf = GameData:getConfData('soldierskill')
	local soldierdressConf = GameData:getConfData('dress')
	local attconf = GameData:getConfData('attribute')

	self.soldiernummax:setString('x '..soldlevelconf.num)
	self.soldiermaxarr[1]:loadTexture('uires/ui/role/role_' ..soldlevelconf.soldierIcon )
	-- for i=1,12 do
	-- 	self.soldiermaxarr[i]:loadTexture('uires/ui/role/role_' ..soldlevelconf.soldierIcon )
	-- 	ShaderMgr:restoreWidgetDefaultShader(self.soldiermaxarr[i])
	-- end

	local skillarr = obj:getSoldierSkillArr()
	for i=1,4 do
		self.skillmaxarr[i].newimg:setVisible(false)
		local lvlimit = skillarr[i][1]
		local img = 'uires/icon/skill/' .. soldierSkillConf[skillarr[i][2]]['icon']
		self.skillmaxarr[i].icon:loadTexture(img)
		self.skillmaxarr[i].icon:ignoreContentAdaptWithSize(true)
		self.skillmaxarr[i].nametx:setString('')
		if self.soldier.level >= lvlimit then
			self.skillmaxarr[i].lvtx:setString('Lv.' .. self.soldier.skills[tostring(i)])
			--self.skillmaxarr[i].nametx:setString(soldierSkillConf[skillarr[i][2]]['name'])
			self.skillmaxarr[i].lock:setVisible(false)
			ShaderMgr:restoreWidgetDefaultShader(self.skillmaxarr[i].icon)
			ShaderMgr:restoreWidgetDefaultShader(self.skillmaxarr[i].skillbg)
			local lvconf  = GameData:getConfData('level')
			if self.obj:getSoldier().skills[tostring(i)]+1 < #lvconf then
				local costvalue = lvconf[self.obj:getSoldier().skills[tostring(i)]]['soldierskilllevelupcost']
				if tonumber(self.obj:getSoldier().skills[tostring(i)]) < self.obj:getLevel() and UserData:getUserObj():getGold() >= tonumber(costvalue) then
					self.skillmaxarr[i].newimg:setVisible(true)
				else
					self.skillmaxarr[i].newimg:setVisible(false)
				end
			else
				self.skillmaxarr[i].newimg:setVisible(false)
			end
		else
			ShaderMgr:setGrayForWidget(self.skillmaxarr[i].icon)
			ShaderMgr:setGrayForWidget(self.skillmaxarr[i].skillbg)
			self.skillmaxarr[i].lock:setVisible(true)
			self.skillmaxarr[i].lvtx:setString('')
			--self.skillmaxarr[i].nametx:setString(string.format(GlobalApi:getLocalStr('SOLDIERSKILLLIMIT'),lvlimit))
		end
	end

	local att = RoleData:getPosAttByPos(obj)
	local curattarr = {}
	curattarr[1] = math.floor(att[1])--*soldconf['attPowPercent']/100)
	curattarr[2] = math.floor(att[4])--*soldconf['heaPowPercent']/100)
	curattarr[3] = math.floor(att[2])--*soldconf['phyArmPowPercent']/100) 
	curattarr[4] = math.floor(att[3])--*soldconf['magArmPowPercent']/100) 


	for i=1,4 do
    	self.maxarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.maxarr[i].attan:setString(curattarr[i])
	end

	local str = soldconf['soldierName'].. self.soldier.level .. GlobalApi:getLocalStr('SOLDIER0')
	RoleMgr:setRoleMainTitle(str)
end

function RoleSoldierUI:update(obj)
    self.lvbtn:setTouchEnabled(true)
	self.obj = obj
	if obj:getSoldier().level >= MAXSOLDIERLV then
		self:updateMaxPanel(obj)
		self.nor_pl:setVisible(false)
		self.max_pl:setVisible(true)
	else
		self:updateNorPanel(obj)
		self.nor_pl:setVisible(true)
		self.max_pl:setVisible(false)
	end
end

return RoleSoldierUI