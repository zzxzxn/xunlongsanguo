local RoleInfo = require("script/app/ui/role/roleinfoui")
local RoleTupo = require("script/app/ui/role/roletupoui")
local RoleEquipSelect = require("script/app/ui/role/roleequipselectui")
local RoleEquipInfo = require("script/app/ui/role/roleequipinfoui")
local RoleSelectListUI = require("script/app/ui/role/roleselectlistui")
local RoleTianmingUI = require("script/app/ui/role/roletianmingui")
local RoleSoldierUI = require("script/app/ui/role/rolesoldierui")
local RoleLvUpUI = require('script/app/ui/role/rolelvupui')
local RoleEquipUpgradeStarUI = require('script/app/ui/role/roleequipupgradestarui')
local RoleEquipInheritUI = require('script/app/ui/role/roleequipinheritui')
local RoleRiseStarUI = require('script/app/ui/role/rolerisestar')
local RoleGemUI = require('script/app/ui/role/rolegemui')
local ClassItemCell = require('script/app/global/itemcell')
local RoleMainUI = class("RoleMainUI", BaseUI)
local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}
local btn1nor = 'uires/ui/common/common_btn_7.png'
local btn2nor = 'uires/ui/common/common_btn_5.png'
local defIcon = 'uires/ui/common/add_01.png'
local defequipIcon = 'uires/ui/common/add_02.png'
local defecanquipIcon = 'uires/ui/common/add_04.png'
local defframeIcon = 'uires/ui/common/frame_default.png'
local RolechildName = {
	[1] = 'TITLE_WJSX',
	[2] = 'TITLE_TP',
	[3] = 'TITLE_ZBXZ',
	[4] = 'TITLE_XB',
	[5] = 'TITLE_TM',
	[6] = 'TITLE_WJSX',
	[7] = 'TITLE_ZBXX',
	[8] = 'TITLE_WJXZ',
	[9] = 'TITLE_WJSJ',
	[10] = 'TITLE_ZBSX',
	[11] = 'TITLE_ZBCC',
	[12] = 'TITLE_BSXQ',
	[13] = 'TITLE_PZTS',
	[14] = 'TITLE_WJSX'
}
local MAXDELTA = 0.5
function RoleMainUI:ctor(pos,pltype,equippos)
	self.uiIndex = GAME_UI.UI_ROLEMAIN
	self.panelObjArr = {}
	self.currPanelObj = nil
	self.selecttype = nil
	self.bgimg = nil
	self.bgimg1 = nil
	self.bgimg2 = nil
	self.bgimg4 = nil
	self.rtname = nil
	self.name = nil
	self.strength = nil
	self.soldiername = nil
	self.armsumname = nil
	self.fightforcebg = nil
	self.expbar = nil
	self.exptx = nil
	self.lv = nil
	self.anim_pl = nil
	self.select_img = nil
	self.action = ""
	self.equipTab = {}
    self.childPanelPos = 0
	self.currHid = 0
	self.obj =RoleData:getRoleByPos(pos)
	self.dirty = false
	self.onlychild = false
	self.paneltype = pltype or ROLEPANELTYPE.UI_RISESTAR
	self.cantouch = true
    self.pltype = pltype
    self.equippos = equippos or 0
end

function RoleMainUI:setDirty(onlychild)
	self.dirty = true
	self.onlychild = onlychild
end

function RoleMainUI:onShow()
	self.currHid = self.obj:getId()
	--RoleMgr:setCurHeroChange(true)
	--小兵装备前往XX地方回来要刷新界面 突破界面也是
	if self.dirty or self.selecttype == ROLEPANELTYPE.UI_SOLDIER  
		or self.selecttype == ROLEPANELTYPE.UI_TUPO 
		or self.selecttype == ROLEPANELTYPE.UI_TIANMING 
		or self.selecttype == ROLEPANELTYPE.UI_RISESTAR 
		or self.selecttype == ROLEPANELTYPE.UI_LVUP then
		self.dirty = false
		self:update()
	end
end

function RoleMainUI:swapTitle( idx )
	self.title = self.bgimg4:getChildByName('type_tx')
	self.title:setLocalZOrder(99999)
	self.title:setString(GlobalApi:getLocalStr(RolechildName[idx]))
end

function RoleMainUI:setTitleName( str )
	self.title = self.bgimg4:getChildByName('type_tx')
	self.title:setString(str)
end
function RoleMainUI:init()
	self.bgimg = self.root:getChildByName("bg_img")
	self.bgimg1 = self.bgimg:getChildByName("bg_img1")
	self.bgimg2 = self.bgimg1:getChildByName("bg_img2")
	self.bgimg2:setLocalZOrder(999)
	self:adaptUI(self.bgimg, self.bgimg1)
	local winSize = cc.Director:getInstance():getVisibleSize()


	--xyh
	self.type_img = self.bgimg2:getChildByName("type_img")

	self.type_img:loadTexture("uires/ui/common/professiontype_"..self.obj:getAbilityType()..".png")



	local closebtn = self.bgimg2:getChildByName("close_btn")
	closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            if self.panelObjArr[ROLEPANELTYPE.UI_LVUP] then
                self.panelObjArr[ROLEPANELTYPE.UI_LVUP].firstState = false
            end
			RoleMgr:hideRoleMain()
		end
	end)
	self.touchimg = self.bgimg2:getChildByName('touch_img')
	self.touchimg:setTouchEnabled(false)
	local bgimg3 =  self.bgimg2:getChildByName("bg_img_3")
	self.bgimg4 = self.bgimg2:getChildByName("bg_img_4")
	self.infobtn = bgimg3:getChildByName("info_btn")
	self.infobtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_SOLDIER,self.obj)
			-- local t = {}
			-- for i = 1, 10 do
			-- 	table.insert(t, 'WTF -------  ' .. i)
			-- end
			-- promptmgr:showGuajiInfo(t)
		 end
	end)
	
	self.riseBg = bgimg3:getChildByName("mingjiang_btn")
	self.riseStarBtn = self.riseBg:getChildByName("rise_btn")
	self.riseImg = self.riseBg:getChildByName('info_img')
	self.riseImg:setLocalZOrder(1)
	self.riseImg:setVisible(self.obj:isCanRiseStar())
	self.riseStarBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_RISESTAR,self.obj)
		 end
	end)
	local quality = self.obj:getHeroQuality()
	local conf = GameData:getConfData('heroquality')[quality]
	self.riseStarBtn:loadTextureNormal('uires/ui/role/role_flag_'..conf.quality..'.png')
	self.starBgImg = self.riseBg:getChildByName("di_img")
	local size = self.riseBg:getContentSize()
	
	for i=1,3 do
		local starBgImg = self.riseBg:getChildByName('star_bg_'..i..'_img')
		local starImg = self.riseBg:getChildByName('star_'..i..'_img')
		if conf.quality < 1 then
			starBgImg:setVisible(false)
			starImg:setVisible(false)
		-- elseif conf.quality == 2 then
		-- 	starBgImg:setVisible(i <= 1)
		-- 	starImg:setVisible(conf.star >= i and i <= 1)
		-- elseif conf.quality == 3 then
		-- 	starBgImg:setVisible(i <= 2)
		-- 	starImg:setVisible(conf.star >= i and i <= 2)
		else
			starBgImg:setVisible(true)
			starImg:setVisible(conf.star >= i)
		end
	end
	if self.paneltype == ROLEPANELTYPE.UI_RISESTAR then
		-- self.starBgImg:setVisible(true)
		self.starBgImg:setVisible(false)
	else
		self.starBgImg:setVisible(false)
	end

	self.lvbtn = bgimg3:getChildByName("lv_btn")
	self.lvinfo = self.lvbtn:getChildByName('info_img')
	self.lvbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('reborn')
			local desc = ''
			local errCode = 0
			local str = ''
			local cityData = MapData.data[id]
			if isOpen then
				self:swappanel(ROLEPANELTYPE.UI_TUPO,self.obj)
			else
				if level then
			        str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
			    elseif cityData then
			        desc = cityData:getName()
			        str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
			    else
			        str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
			    end
		        if not isOpen and not isNotIn then
			        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			        return
			    end
			end

		end
	end)
	
	self.skillbtn = bgimg3:getChildByName("skill_btn")
	self.skillbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			
			local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('destiny')
			local desc = ''
			local errCode = 0
			local str = ''
			local cityData = MapData.data[id]
			if isOpen then
				self:swappanel(ROLEPANELTYPE.UI_TIANMING,self.obj)
			else
				if level then
			        str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
			    elseif cityData then
			        desc = cityData:getName()
			        str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
			    else
			        str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
			    end
		        if not isOpen and not isNotIn then
			        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			        return
			    end
			end
		end
	end) 

	local autoexchangebtn = self.bgimg2:getChildByName('auto_exchange_btn')
    self.autoexchangebtn = autoexchangebtn

	autoexchangebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			local equipnum = 0
			for i=1,6 do
				if self.equipidarr[i] > 0 then
					equipnum = equipnum + 1
				end
			end
			if equipnum > 0 then
				if self.needinheritnum > 0 then
					promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ROLE_DESC6'),self.needinheritnum,-self.inheriteritgold), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
	                    UserData:getUserObj():cost('gold',-self.inheriteritgold,function()
	                        self:autoExchangeEquip(self.equipidarr,self.equiparr,1)
	                    end)                  
	              	end,GlobalApi:getLocalStr('TAVERN_YES'),GlobalApi:getLocalStr('TAVERN_NO'),function ()
	              		self:autoExchangeEquip(self.equipidarr,self.equiparr,0)
	              	end) 
				else
					self:autoExchangeEquip(self.equipidarr,self.equiparr,0)
				end
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC7'), COLOR_TYPE.RED)
			end
		end
	end) 
	local probtn = self.bgimg:getChildByName("pro_btn")
    self.probtn = probtn
	--probtn:setVisible(false)
	probtn:setPosition(cc.p(20,winSize.height/2))
	probtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:changePos(self.obj:getPosId(),false)
		end
	end) 

	local nextbtn = self.bgimg:getChildByName("next_btn")
    self.nextbtn = nextbtn
	--nextbtn:setVisible(false)
	GlobalApi:arrowBtnMove(probtn,nextbtn)
	nextbtn:setPosition(cc.p(winSize.width - 20,winSize.height/2))
	nextbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:changePos(self.obj:getPosId(),true)
		end
	end) 

	self.select_img = bgimg3:getChildByName('frame_img')
	self.select_img:setVisible(false)
	for i=1,6 do
		local armnode = bgimg3:getChildByName('arm_' .. i .. '_node')
		armnode:setLocalZOrder(1000)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil, true)
        tab.awardBgImg.index = i	
		tab.awardBgImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
			if eventType == ccui.TouchEventType.ended then
				local equipObj = self.obj:getEquipByIndex(sender.index)
				if self.selectIndex == i and self.paneltype == ROLEPANELTYPE.UI_EQUIP_INFO then
					return
				end
				if equipObj then
					if self.cantouch then
						self.selectIndex = i
						self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO, self.obj, sender.index)
						self:setAtt()
					end
				else -- 这一格没有装备
					if self.cantouch then
						self.selectIndex = i
						self:swappanel(ROLEPANELTYPE.UI_EQUIP, self.obj, sender.index)
						self:setAtt()
					end
				end
				--self.childPanelPos = sender.index     -- 防止快速点击不能点击的问题
			end
		end)
		tab.addImg:setVisible(false)
		tab.addImg:ignoreContentAdaptWithSize(true)
		local equiparr = {}
		equiparr.node = armnode
		equiparr.tab = tab
		-- equiparr.icon = tab.awardImg
		-- equiparr.fram = tab.awardBgImg
		-- equiparr.star = tab.starImg 
		-- equiparr.num = tab.starLv
		-- equiparr.lv = tab.lvTx
		-- equiparr.rhombImgs = tab.rhombImgs
		self.equipTab[i] = equiparr
		armnode:addChild(tab.awardBgImg)
	end

	local titleimg = bgimg3:getChildByName('type_img')
	local namebg = titleimg
	titleimg:setTouchEnabled(true)
	namebg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			-- TipsMgr:showProfessTips(self.obj)
		end
	end)
	self.rtname = xx.RichText:create()
	namebg:addChild(self.rtname)
	self.rtname:setContentSize(cc.size(200, 47))
	self.rtname:setPosition(cc.p(140, 24))
	self.rtname:setAlignment('middle')
	self.name = xx.RichTextLabel:create()
	self.strength = xx.RichTextLabel:create()
	self.rtname:addElement(self.name)
	self.rtname:addElement(self.strength)

	self.type = namebg:getChildByName('type_img')
	self.type:setVisible(false)
	local swapbtn = namebg:getChildByName("swap_btn")
	self.swapbtn = swapbtn
	swapbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_SWAP_ROLE,self.obj)
		end
	end) 
	local rolebg = bgimg3:getChildByName('role_bg')
	self.anim_pl = rolebg:getChildByName('anm_pl')

	local soldierbtn = bgimg3:getChildByName('soldier_btn')
	self.soldierinfo = self.infobtn:getChildByName('info_img')
	local soldierinfox = soldierbtn:getChildByName('info_img')
	soldierinfox:setVisible(false)
	soldierbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_INFO,self.obj)
		end
	end) 

	self.pokedexBtn = bgimg3:getChildByName('pokedex_btn')
	self.pokedexBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			RoleMgr:showPokedex(self.obj:getPosId())
		end
	end)
	-- local brief = self.obj:getBrief()
	-- if brief ~= '0' then
	-- 	self.pokedexBtn:setVisible(true)
	-- else
		self.pokedexBtn:setVisible(false)
	-- end

	local armsumbtn = bgimg3:getChildByName('armsum_btn')
	self.armsumImg = armsumbtn:getChildByName('info_img')
	armsumbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:showSuit(self.obj:getPosId(),1)
		end
	end)

	self.fightforcebg = bgimg3:getChildByName('fightforce_img')
	local leftLabel = cc.LabelAtlas:_create(RoleData:getPosFightForceByPos(self.obj), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	leftLabel:setAnchorPoint(cc.p(0.5,0.5))
	leftLabel:setPosition(cc.p(132,20))
	leftLabel:setScale(0.7)
	self.fightforcebg:addChild(leftLabel)
	self.leftLabel = leftLabel
   
	local expbg = bgimg3:getChildByName('exp_bg')
	self.expbar = expbg:getChildByName('exp_bar')

    self.expbar:setScale9Enabled(true)
    self.expbar:setCapInsets(cc.rect(10,15,1,1))


	-- --: DEBUG
	-- self.expbar:setPercent(10)
	-- GlobalApi:runExpBar(self.expbar, 0.2, 10, 39)

	self.exptx =self.expbar:getChildByName('exp_tx')
	local lvbg = expbg:getChildByName('lv_bg')
	self.lv = lvbg:getChildByName('lv_tx')
	local lvlabel = cc.LabelAtlas:_create(level, "uires/ui/number/font_sz.png", 17, 23, string.byte('.'))
	lvlabel:setAnchorPoint(cc.p(0.5,0.5))
	lvlabel:setPosition(cc.p(0,0))
	self.lv:addChild(lvlabel)
	self.lvlabel = lvlabel

	local expbtn = expbg:getChildByName("exp_btn")
	self.expbtn = expbtn
	expbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			self:swappanel(ROLEPANELTYPE.UI_LVUP,self.obj)
		end
	end)
	self.riseExp = self.expbtn:getChildByName('info_img')
	self.riseExp:setLocalZOrder(1)
	self.riseExp:setVisible(self.obj:isCanUpdateLv())

	self.objarr = {}
	for k, v in pairs(RoleData:getRoleMap()) do
		self.objarr[tonumber(k)] = v
	end
	RoleMgr:sortByQuality(self.objarr,ROLELISTTYPE.UI_ASSIST)
	local infotx = self.infobtn:getChildByName('func_tx')
	infotx:setString(GlobalApi:getLocalStr('TITLE_XB'))
	local skilltx = self.skillbtn:getChildByName('func_tx')
	skilltx:setString(GlobalApi:getLocalStr('STR_TIANMING'))
	local lvtx = self.lvbtn:getChildByName('func_tx')
	lvtx:setString(GlobalApi:getLocalStr('STR_TUPO'))
	RoleMgr:setCurHeroChange(true)
	self:swappanel(self.paneltype,self.obj)
	self:setAtt()

	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.swapbtn:setVisible(not self.obj:isJunZhu())
    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self:updatepush(dt)
    end, 0)
end

function RoleMainUI:getRoleMainUIChangeBtn()
    return self.probtn,self.nextbtn
end

function RoleMainUI:getLv()
    return self.lvlabel:getString(),self.expbar:getPercent()

end

function RoleMainUI:addAutoExchagneEffect()
    local equipnum = 0
	for i=1,6 do
		if self.equipidarr[i] > 0 then
			equipnum = equipnum + 1
		end
	end
    if equipnum > 0 then
        if not self.autoexchangebtn:getChildByName('ui_auto_equip') then
            local size = self.autoexchangebtn:getContentSize()
            local effect = GlobalApi:createLittleLossyAniByName('ui_auto_equip')
            effect:setName('ui_auto_equip')
            effect:setPosition(cc.p(size.width/2 ,size.height/2))
            effect:setAnchorPoint(cc.p(0.5,0.5))
            self.autoexchangebtn:addChild(effect)
            effect:getAnimation():playWithIndex(0, -1, 1)
        end
    else
        if self.autoexchangebtn:getChildByName('ui_auto_equip') then
            self.autoexchangebtn:removeChildByName('ui_auto_equip')
        end
    end

end

function RoleMainUI:autoExchangeEquip(equipidarr,equiparr,isinherit)
	local args = {
        eids = equipidarr,
        pos = self.obj:getPosId(),
        inherit = isinherit
    }
    local equips = {}
    for k, v in ipairs(equipidarr) do
    	if v > 0 and equiparr[k] then
	    	local equip = BagData:getEquipMapByType(equiparr[k])[v]
	    	equips[equiparr[k]] = equip
	    end
    end
    MessageMgr:sendPost("wear_all", "hero", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            if tonumber(isinherit) > 0 then
            	for i=1,6 do
            		local equipobj = self.obj:getEquipByIndex(i)
            		if equipobj and equipobj:getGodId() ~= 0 and equips[i] and equips[i]:getGodId() == 0  then
            			equips[i]:inheritGod(equipobj)
            		end
            		if equips[i] then
	            		RoleData:putOnEquip(self.obj:getPosId(), equips[i])
	            	end
            	end
                --self.equipObj:inheritGod(obj)
            else
            	for i=1,6 do
            		if equips[i] then
	            		RoleData:putOnEquip(self.obj:getPosId(), equips[i])
	            	end
            	end            	
            end
            GlobalApi:parseAwardData(jsonObj.data.awards)
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.obj:setFightForceDirty(true)
            --RoleData:putOnEquip(self.rolePos, self.equipObj)
            RoleMgr:updateRoleList()
            RoleMgr:updateRoleMainUI()
        end
    end)
end

function RoleMainUI:changePos( currpos,isright )

	self.anim_pl:setTouchEnabled(false)
	self.anim_pl:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function (  )
		self.anim_pl:setTouchEnabled(true)
	end)))

	self.posarr = {}
	for i=1,MAXROlENUM do
		self.posarr[i] = self.objarr[i]:getPosId()
	end
	local inposarrpos = 0
	for i=1,MAXROlENUM do
		if self.posarr[i] == currpos then
			inposarrpos = i
		end
	end
	local postemp = 0
	if isright then
		local pos = inposarrpos
		local needdoing = true
		while needdoing do
			pos = pos +1
			if pos > MAXROlENUM then
				pos = 1
			end
			if RoleData:getRoleByPos(self.posarr[pos]):getId() > 0 then
				RoleMgr:setSelectRolePos(self.posarr[pos])
				RoleMgr:updateRoleMainUI()
				RoleMgr:updateRoleList()
				needdoing = false
			end
		end
		postemp = pos
	else
		local pos = inposarrpos
		local needdoing = true
		while needdoing do
			pos = pos -1
			if pos < 1 then
				pos = MAXROlENUM
			end
			if RoleData:getRoleByPos(self.posarr[pos]):getId() > 0 then
				RoleMgr:setSelectRolePos(self.posarr[pos])
				RoleMgr:updateRoleMainUI()
				RoleMgr:updateRoleList()
				needdoing = false
			end
		end
		postemp = pos
	end

	if inposarrpos ~= postemp then
		RoleMgr:setCurHeroChange(true)
	end
	if (self.paneltype == ROLEPANELTYPE.UI_LVUP or self.paneltype == ROLEPANELTYPE.UI_SWAP_ROLE ) and self.obj:isJunZhu() then
		self:swappanel(ROLEPANELTYPE.UI_RISESTAR,self.obj)
	end

	self:update()
	-- self.obj:playSound('sound')
end

function RoleMainUI:swapanimation(spineAni)
	-- local seed = math.random(1, 5)
	-- if self.action ~= roleanim[seed] then
	-- 	self.action = roleanim[seed]
	-- 	spineAni:getAnimation():play(roleanim[seed], -1, -1)
	-- end
end

function RoleMainUI:createAnimation()
	self.anim_pl:removeAllChildren()
	local actionisruning = false
	local spineAni = GlobalApi:createLittleLossyAniByName(self.obj:getUrl() .. "_display", nil, self.obj:getChangeEquipState())
	-- dump("this is resource url :"..self.obj:getUrl() .. "_display")
	-- ShaderMgr:setLightnessColorForArmature(spineAni, 'particle/wenli_00257.tga')
	local heroconf = GameData:getConfData('hero')[self.obj:getId()]
	if spineAni then
		local shadow = spineAni:getBone(self.obj:getUrl() .. "_display_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
			shadow:setIgnoreMovementBoneData(true)
		end
		spineAni:setPosition(cc.p(self.anim_pl:getContentSize().width/2,70+heroconf.uiOffsetY))
		spineAni:setLocalZOrder(999)
		self.anim_pl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		local beginPoint = cc.p(0,0)
		local endPoint = cc.p(0,0)
		self.anim_pl:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				beginPoint = sender:getTouchBeganPosition()
			end

			if eventType ==  ccui.TouchEventType.ended or 
				eventType == ccui.TouchEventType.canceled then
				endPoint = sender:getTouchEndPosition()
				local deltax = (beginPoint.x -endPoint.x)
				local deltay = math.abs(beginPoint.y -endPoint.y)
				if deltax > 25  then
					self:changePos(self.obj:getPosId(),true)
				elseif deltax <= -25 then
					self:changePos(self.obj:getPosId(),false)
				else
					if actionisruning  ~= true then
						actionisruning = true
						self:swapanimation(spineAni)
					end
				end
			end

		end)

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

function RoleMainUI:setAtt()
	self.equipidarr, self.needinheritnum , self.inheriteritgold,self.equiparr = self.obj:getAutoExchangeEquips()
	if self.obj:getTalent() > 0 then
		self.strength:setString(' +' .. self.obj:getTalent())
	else
		self.strength:setString('')
	end
	self.name:setString(self.obj:getName())
	self.name:setFont("font/gamefont.ttf")
	self.name:setFontSize(24)
	self.strength:setFontSize(22)
	self.name:setColor(self.obj:getNameColor())
	self.strength:setColor(self.obj:getNameColor())
	self.name:setStroke(cc.c4b(78, 49, 17, 255), 2)
	self.strength:setStroke(cc.c4b(78, 49, 17, 255), 2)
	self.name:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
	self.strength:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
	self.rtname:format(true)
	self.rtname:setVerticalAlignment('middle')
	

	--xyh
	local camp_type = self.obj:getCamp()
	if camp_type ~= 5 and camp_type then 
		self.type:setVisible(true)
		self.type:loadTexture('uires/ui/common/camp_'..camp_type..'.png')
	end
	self.type:ignoreContentAdaptWithSize(true)
	RoleData:runPosFightForceByPos(self.obj,self.leftLabel,'LabelAtlas',0.7)
	local percent, curexp ,needexp = self.obj:getExpPercent()
	self.expbar:setPercent(percent)
	self.exptx:setString(percent .. '%')
	self.lv:setString('')
	self.lvlabel:setString(self.obj:getLevel())
	--local infoarr = RoleData:getWorstEquipArr()
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		local ishaveeq,canequip = self.obj:isHavebetterEquip(i)	
		self.equipTab[i].tab.upImg:setVisible(false)
		if ishaveeq then
			if canequip then
				if equipObj then
					--if infoarr[i].pos == self.obj:getPosId() then
						self.equipTab[i].tab.upImg:setVisible(true)
					--end
				else
					self.equipTab[i].tab.addImg:loadTexture(defecanquipIcon)
					self.equipTab[i].tab.addImg:setVisible(true)
				end
			else
				self.equipTab[i].tab.addImg:setVisible(true)
				self.equipTab[i].tab.addImg:loadTexture(defequipIcon)
			end
        else
            self.equipTab[i].tab.addImg:setVisible(false)
		end

		local partInfo = self.obj:getPartInfoByPos(i)
		local num = 0
		local num1 = 1
		local pos = {
			[1] = {cc.p(48,91)},
			[2] = {cc.p(40,91),cc.p(56,91)},
			[3] = {cc.p(32,91),cc.p(48,91),cc.p(64,91)},
			[4] = {cc.p(24,91),cc.p(40,91),cc.p(56,91),cc.p(72,91)},
			[5] = {cc.p(16,91),cc.p(32,91),cc.p(48,91),cc.p(64,91),cc.p(80,91)},
		}
		if partInfo.level == 10 then
			num = 4
			num1 = 3
		elseif partInfo.level == 0 then
			num = 0
			num1 = 0
		else
			num = (partInfo.level - 1)%3 + 1
			num1 = math.ceil(partInfo.level/3)
		end

		if partInfo.level > 10 then
			num = partInfo.level - 10
			num1 = 4
		end

		for j=1,5 do
			if j <= num then
				self.equipTab[i].tab.rhombImgs[j]:loadTexture('uires/ui/common/rhomb_'..num1..'.png')
				self.equipTab[i].tab.rhombImgs[j]:setVisible(true)
				self.equipTab[i].tab.rhombImgs[j]:setPosition(pos[num][j])
			else
				self.equipTab[i].tab.rhombImgs[j]:setVisible(false)
			end
		end

		if equipObj then
			ClassItemCell:updateItem(self.equipTab[i].tab, equipObj, 1)
			self.equipTab[i].tab.addImg:setVisible(false)
			ClassItemCell:setGodLight(self.equipTab[i].tab.awardBgImg, equipObj:getGodId())
			self.equipTab[i].tab.lvTx:setVisible(true)
			self.equipTab[i].tab.lvTx:setString('Lv.'.. equipObj:getLevel())
		else
			self.equipTab[i].tab.awardBgImg:loadTexture('uires/ui/common/frame_default.png')
			self.equipTab[i].tab.awardImg:loadTexture(DEFAULTEQUIP[i])
			self.equipTab[i].tab.starImg:setVisible(false)
			self.equipTab[i].tab.lvTx:setVisible(false)
			ClassItemCell:setGodLight(self.equipTab[i].tab.awardBgImg, 0)
		end
	end
	
	if self.obj:isTupo() then
		self.lvinfo:setVisible(true)
	else
		self.lvinfo:setVisible(false)
	end
	local suitFlag = self.obj:getSuitFlag()
	self.armsumImg:setVisible(suitFlag)
	if self.obj:isSoldierCanLvUp() then
		self.soldierinfo:setVisible(true)
	elseif self.obj:isSoldierSkillCanLvUp() then
		self.soldierinfo:setVisible(true)
	else
		self.soldierinfo:setVisible(false)
	end
	self.select_img:setVisible(false)
	if self.childPanelPos ~= 0 then
		self.select_img:setVisible(true)
		local x, y = self.equipTab[self.childPanelPos].node:getPosition()
		self.select_img:setPosition(cc.p(x, y))
		local equipObj = self.obj:getEquipByIndex(self.childPanelPos)
		if not equipObj then
			-- RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP, self.childPanelPos)
			self:swappanel(ROLEPANELTYPE.UI_EQUIP, self.obj, self.childPanelPos)
		else
			local godlv = equipObj:getGodLevel()
			if godlv <= 0 and (self.selecttype == ROLEPANELTYPE.UI_UPGRADE_STAR or self.selecttype == ROLEPANELTYPE.UI_INHERIT)  then
				self:swappanel(ROLEPANELTYPE.UI_EQUIP_INFO, self.obj, self.childPanelPos)
			end
		end
	end
	if RoleMgr:getCurHeroChange() then
		self:createAnimation()
		self.obj:playSound('sound')
		RoleMgr:setCurHeroChange(false)
	end

	RoleMgr:popupTips(self.obj)

    if self.obj:isJunZhu() then
        self:setJunZhuEXP()
    end

    self:addAutoExchagneEffect()
end

function RoleMainUI:createChildPanel(paneltype)
	local obj = nil
	if paneltype == ROLEPANELTYPE.UI_INFO then
		obj = RoleInfo.new(self.obj)
	elseif paneltype == ROLEPANELTYPE.UI_EQUIP then
		obj = RoleEquipSelect.new()
	elseif paneltype == ROLEPANELTYPE.UI_TUPO then
		obj = RoleTupo.new()
	elseif paneltype == ROLEPANELTYPE.UI_EQUIP_INFO then
		obj = RoleEquipInfo.new()
	elseif paneltype == ROLEPANELTYPE.UI_SWAP_ROLE then
		obj = RoleSelectListUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_TIANMING then
		obj = RoleTianmingUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_SOLDIER then
		obj = RoleSoldierUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_LVUP then
		obj = RoleLvUpUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_UPGRADE_STAR then
		obj = RoleEquipUpgradeStarUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_INHERIT then
		obj = RoleEquipInheritUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_GEM then
		obj = RoleGemUI.new()
	elseif paneltype == ROLEPANELTYPE.UI_RISESTAR then
		obj = RoleRiseStarUI.new()
	end
	return obj
end

function RoleMainUI:childFadein()
	local time = 0.3
	local moveto = cc.MoveBy:create(time,cc.p(455, 0))
	return moveto
end

function RoleMainUI:chidlFadeOut(callback)
	local time = 0.3
	local moveto = cc.MoveBy:create(time,cc.p(-455, 0))
	local callbak = cc.CallFunc:create(callback)
	local sequence = cc.Sequence:create(moveto,callbak)
	return sequence
end

function RoleMainUI:showChildPanelByIdx(paneltype, pos, immediately)
	self:swappanel(paneltype, self.obj, pos, immediately)
	self:setAtt()
end

function RoleMainUI:swappanel(paneltype, obj, pos, immediately)
	self.touchimg:setTouchEnabled(true)
	self.cantouch = false
	self.tiemdelta = 0
    if self.pltype then
        pos = pos or self.equippos
        self.pltype = nil
    end
    pos = pos or self.equippos
	paneltype = paneltype or ROLEPANELTYPE.UI_SOLDIER
	self.paneltype = paneltype
	RoleMgr:swapChildName(paneltype)
	if self.selecttype == paneltype and self.childPanelPos == pos then
		self.touchimg:setTouchEnabled(false)
		return
	elseif self.selecttype == paneltype and self.childPanelPos ~= pos then
		self.childPanelPos = pos
		self.panelObjArr[paneltype]:update(obj,pos)
		self:setAtt()
		self.touchimg:setTouchEnabled(false)
		return
	end
	self.selecttype = paneltype
	local infotx = self.infobtn:getChildByName('func_tx')
	local skilltx = self.skillbtn:getChildByName('func_tx')
	local lvtx = self.lvbtn:getChildByName('func_tx')
	if self.selecttype == ROLEPANELTYPE.UI_SOLDIER then
		self.infobtn:loadTextureNormal(btn2nor)
		self.skillbtn:loadTextureNormal(btn1nor)
		self.lvbtn:loadTextureNormal(btn1nor)
		infotx:enableOutline(cc.c4b(165,70,6,255),1)
		skilltx:enableOutline(cc.c4b(9,69,121,255),1)
		lvtx:enableOutline(cc.c4b(9,69,121,255),1)
	elseif self.selecttype == ROLEPANELTYPE.UI_TIANMING then
		self.infobtn:loadTextureNormal(btn1nor)
		self.skillbtn:loadTextureNormal(btn2nor)
		self.lvbtn:loadTextureNormal(btn1nor)
		infotx:enableOutline(cc.c4b(9,69,121,255),1)
		skilltx:enableOutline(cc.c4b(165,70,6,255),1)
		lvtx:enableOutline(cc.c4b(9,69,121,255),1)
	elseif self.selecttype == ROLEPANELTYPE.UI_TUPO then
		self.infobtn:loadTextureNormal(btn1nor)
		self.skillbtn:loadTextureNormal(btn1nor)
		self.lvbtn:loadTextureNormal(btn2nor)
		infotx:enableOutline(cc.c4b(9,69,121,255),1)
		skilltx:enableOutline(cc.c4b(9,69,121,255),1)
		lvtx:enableOutline(cc.c4b(165,70,6,255),1)
	else
		self.infobtn:loadTextureNormal(btn1nor)
		self.skillbtn:loadTextureNormal(btn1nor)
		self.lvbtn:loadTextureNormal(btn1nor)
		infotx:enableOutline(cc.c4b(9,69,121,255),1)
		skilltx:enableOutline(cc.c4b(9,69,121,255),1)
		lvtx:enableOutline(cc.c4b(9,69,121,255),1)
	end
	
	self.childPanelPos = pos
	local uiNode
	if self.panelObjArr[paneltype] == nil then
		self.panelObjArr[paneltype] = self:createChildPanel(paneltype)
		uiNode = self.panelObjArr[paneltype]:getPanel()
		uiNode:setPosition(cc.p(-230,260))
		self.bgimg4:addChild(uiNode)
	else
		uiNode = self.panelObjArr[paneltype]:getPanel()
		uiNode:setPosition(cc.p(-230,260))
	end
	self.panelObjArr[paneltype]:setVisible(true)
	uiNode:setLocalZOrder(11)
	if immediately then -- 如果不播动画
		uiNode:setPosition(cc.p(230, 260))
		if self.currPanelObj then
			self.currPanelObj:onMoveOut()
			self.currPanelObj:getPanel():setLocalZOrder(10)
			self.currPanelObj:setPosition(cc.p(-230,260))
			self.currPanelObj:setVisible(false)
		end
		self.currPanelObj = self.panelObjArr[paneltype]
		self.touchimg:setTouchEnabled(false)
	else
		uiNode:runAction(self:childFadein())
		if self.currPanelObj then
			self.currPanelObj:onMoveOut()
			self.currPanelObj:getPanel():setLocalZOrder(10)
			self.currPanelObj:getPanel():runAction(self:chidlFadeOut(function()
				self.currPanelObj:setVisible(false)
				self.currPanelObj = self.panelObjArr[paneltype]
				self.touchimg:setTouchEnabled(false)
			end))
		else
			self.currPanelObj = self.panelObjArr[paneltype]
			self.touchimg:setTouchEnabled(false)
		end
	end
	self.panelObjArr[paneltype]:update(obj,pos)
	if self.paneltype == ROLEPANELTYPE.UI_RISESTAR then
		self.starBgImg:setVisible(false)
	else
		self.starBgImg:setVisible(false)
	end
	-- self:setAtt()
end

-- 设置君主经验条
function RoleMainUI:setJunZhuEXP()
    local level = UserData:getUserObj().level
    if level >= 100 then
        return
    end
    local curlvexp = UserData:getUserObj().xp -- 现在拥有的经验值
    local lvupneedxp = GameData:getConfData('level')[level + 1].exp
    local percent = string.format("%.2f", curlvexp/lvupneedxp*100)

	self.expbar:setPercent(percent)
    self.exptx:setString(percent .. '%')
end

function RoleMainUI:setEXP()
    if self.obj:getLevel() >= 100 then
        return
    end

    require('script/app/utils/scheduleActions'):remove(self.expbar)

    self.lvlabel:setString(self.obj:getLevel())
    local percent, curexp ,needexp = self.obj:getExpPercent()
    --print('rrrrrrrrrrrrrrrrrrrrr' .. percent)
	self.expbar:setPercent(percent)
	self.exptx:setString(percent .. '%')

    
end


function RoleMainUI:updateOutSide()
	self.obj:stopSound('sound')
	self.obj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
	self:setAtt()

	-- fucking JunZhu special
	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.swapbtn:setVisible(not self.obj:isJunZhu())
	self.currPanelObj:update(self.obj, self.childPanelPos)
end
function RoleMainUI:update()



	if not self.onlychild then
		self.obj:stopSound('sound')
		self.obj =RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		self:setAtt()
	else
		self.onlychild = false
	end
	-- fucking JunZhu special
	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.swapbtn:setVisible(not self.obj:isJunZhu())
	self.currPanelObj:update(self.obj, self.childPanelPos)

	local quality = self.obj:getHeroQuality()
	local conf = GameData:getConfData('heroquality')[quality]
	self.riseStarBtn:loadTextureNormal('uires/ui/role/role_flag_'..conf.quality..'.png')
	for i=1,3 do
		local starBgImg = self.riseBg:getChildByName('star_bg_'..i..'_img')
		local starImg = self.riseBg:getChildByName('star_'..i..'_img')
		if conf.quality < 1 then
			starBgImg:setVisible(false)
			starImg:setVisible(false)
		-- elseif conf.quality == 2 then
		-- 	starBgImg:setVisible(i <= 1)
		-- 	starImg:setVisible(conf.star >= i and i <= 1)
		-- elseif conf.quality == 3 then
		-- 	starBgImg:setVisible(i <= 2)
		-- 	starImg:setVisible(conf.star >= i and i <= 2)
		else
			starBgImg:setVisible(true)
			starImg:setVisible(conf.star >= i)
		end
	end
	if self.paneltype == ROLEPANELTYPE.UI_RISESTAR then
		self.starBgImg:setVisible(false)
	else
		self.starBgImg:setVisible(false)
	end
	self.riseImg:setVisible(self.obj:isCanRiseStar())

	self.riseExp:setVisible(self.obj:isCanUpdateLv())

	local brief = self.obj:getBrief()
	-- if brief ~= '0' then
	-- 	self.pokedexBtn:setVisible(true)
	-- else
		self.pokedexBtn:setVisible(false)
	-- end
	local suitFlag = self.obj:getSuitFlag()
	self.armsumImg:setVisible(suitFlag)

	-- self.type_img:loadTexture("uires/ui/common/professiontype_"..self.obj:getProfessionType()..".png")
	self.type_img:loadTexture(self.obj:getProfessionTypeImg())

	self.type:setVisible(false)
	local camp_type = self.obj:getCamp()
	if camp_type ~= 5 and camp_type then 
		self.type:setVisible(true)
		self.type:loadTexture('uires/ui/common/camp_'..camp_type..'.png')
	end
--	self.equipidarr, self.needinheritnum , self.inheriteritgold,self.equiparr = self.obj:getAutoExchangeEquips()
end

function RoleMainUI:lvUpdate()
	if not self.onlychild then
		self.obj:stopSound('sound')
		self.obj =RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		self.equipidarr, self.needinheritnum , self.inheriteritgold,self.equiparr = self.obj:getAutoExchangeEquips()

	    RoleData:runPosFightForceByPos(self.obj,self.leftLabel,'LabelAtlas',0.7)
	    local percent, curexp ,needexp = self.obj:getExpPercent()
	    self.expbar:setPercent(percent)
	    self.exptx:setString(percent .. '%')
	    self.lv:setString('')
	    self.lvlabel:setString(self.obj:getLevel())

	    if self.obj:isTupo() then
		    self.lvinfo:setVisible(true)
	    else
		    self.lvinfo:setVisible(false)
	    end
		local suitFlag = self.obj:getSuitFlag()
		self.armsumImg:setVisible(suitFlag)
	    if self.obj:isSoldierCanLvUp() then
		    self.soldierinfo:setVisible(true)
	    elseif self.obj:isSoldierSkillCanLvUp() then
		    self.soldierinfo:setVisible(true)
	    else
		    self.soldierinfo:setVisible(false)
	    end
	    self.select_img:setVisible(false)
	    if self.childPanelPos ~= 0 then
		    self.select_img:setVisible(true)
	    end

	    RoleMgr:popupTips(self.obj)

        if self.obj:isJunZhu() then
            self:setJunZhuEXP()
        end

	else
		self.onlychild = false
	end
	self.currPanelObj:update(self.obj, self.childPanelPos)
    self:addAutoExchagneEffect()

end


function RoleMainUI:updatelvbar(oldlv,percent,level,index,callBack)
    --local lastLv = self.lvlabel:getString()
    --self.lvlabel:setString(math.max(tonumber(lastLv),oldlv))
    self.lvlabel:setString(oldlv)
    --print('LLLLLLLLLLLL' .. oldlv .. 'NNNNNNNNN' .. level)
    --if level < oldlv then
        --return
    --end

	self.expbtn:setVisible(not self.obj:isJunZhu())
	self.leftLabel:setString(RoleData:getPosFightForceByPos(self.obj))
	--self.expbar:setPercent(percent)
	-- GlobalApi:runExpBar(self.expbar, 0.2, level-oldlv+1, tonumber(percent),function (lv)
	-- 	self.lvlabel:setString(level-lv+1)
	-- end,self.exptx)
	require('script/app/utils/scheduleActions'):runExpBar(
		self.expbar, 
		0.2, 
		level - oldlv + 1, 
		tonumber(percent),
		function (e)
			if e.status == SAS.START then
				self.exptx:setScale(1.2)
			elseif e.status == SAS.FRAME then
				local p = string.format('%.2f', e.percent) 
				self.exptx:setString(p .. '%')
			elseif e.status == SAS.SINGLE_END then
                if index and index == 1 then
                else
                    RoleMgr:playRoleUpgradeEffect()
                end
                
				local lv = e.count
				self.lvlabel:setString(level - lv + 1)
				local p = string.format('%.2f', e.percent) 
				self.exptx:setString(p .. '%')
			elseif e.status == SAS.END then
				local p = string.format('%.2f', e.percent) 
				self.exptx:setString(p .. '%')
				self.exptx:setScale(1)
                if callBack then
                    callBack()
                end
                
			end
		end)
	self.lv:setString('')
	
end

function RoleMainUI:hideChildPanelByIdx(idx)
	if self.panelObjArr[idx] then
		self.panelObjArr[idx]:setVisible(false)
		self.panelObjArr[idx]:getPanel():runAction(self:chidlFadeOut(function()
		end))
		self.selecttype = nil
		self.currPanelObj = nil
	end
end

function RoleMainUI:getExpBarPos()
	local size = self.expbar:getContentSize()
	local x, y = self.expbar:convertToWorldSpace(cc.p(self.expbar:getPosition(size.width / 2, size.height / 2)))
	return x,y
end

function RoleMainUI:onShowUIAniOver()
	-- self.obj:playSound('sound')
end

function RoleMainUI:onClose()
	self.obj:stopSound('sound')
end

function RoleMainUI:playFateGuild()
	if self.panelObjArr[ROLEPANELTYPE.UI_INFO] ~= nil then
		self.panelObjArr[ROLEPANELTYPE.UI_INFO]:playGuild()
	end
end

function RoleMainUI:stopFateGuild()
	if self.panelObjArr[ROLEPANELTYPE.UI_INFO] ~= nil then
		self.panelObjArr[ROLEPANELTYPE.UI_INFO]:stopGuild()
	end	
end

function RoleMainUI:updatepush(dt)
    self.tiemdelta = self.tiemdelta + dt 
    if self.tiemdelta > MAXDELTA then
        self.tiemdelta = 0
        self.cantouch = true
    end
end

return RoleMainUI
