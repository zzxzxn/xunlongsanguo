local LegionWarCityInfoUI = class("LegionWarCityInfoUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionWarCityInfoUI:ctor(isself, index, cityinfo)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_CITYINFO
	self.cityinfo = cityinfo
	self.cityid = index
	self.isself = isself
	self.battledata = LegionMgr:getLegionBattleData()
end

function LegionWarCityInfoUI:init()
	local bgimg = self.root:getChildByName("bgimg")
	local bgimg1 = bgimg:getChildByName("bgimg1")
	self:adaptUI(bgimg, bgimg1)
	
	local bgimg2 = bgimg1:getChildByName("bgimg2")
	local closeBtn = bgimg2:getChildByName("close_btn")
	closeBtn:addClickEventListener(function()
		AudioMgr.PlayAudio(11)
		LegionMgr:hideLegionWarCityInfoUI()
	end)
	
	local titleBg = bgimg2:getChildByName("title_bg")
	local titleLabel = titleBg:getChildByName("title_tx")
	local cityconf = GameData:getConfData('legionwarcity')
	titleLabel:setString(cityconf[self.cityid].name)
	local infoImg = bgimg2:getChildByName("info_img")
	local yuxiImg = infoImg:getChildByName("yuxi_img")
	local img = "uires/ui/legionwar/legionwar_" .. cityconf[self.cityid].urlb
	if self.isself == 0 then
		img = "uires/ui/legionwar/legionwar_" .. cityconf[self.cityid].urlr
	end
	yuxiImg:setTexture(img)
	yuxiImg:setScale(cityconf[self.cityid].scale)
	
	local funcBtn = infoImg:getChildByName("func_btn")
	local funcBtnLabel = funcBtn:getChildByName("text")
	if self.isself == 1 then
		if LegionMgr:getLegionWarData().stage == 1 then
			funcBtnLabel:setString(GlobalApi:getLocalStr("LEGION_WAR_DESC13"))
		else
			funcBtnLabel:setString(GlobalApi:getLocalStr("STR_BATTLE_REPORT1"))
		end
		funcBtn:addClickEventListener(function()
			AudioMgr.PlayAudio(11)
			--if LegionMgr:getLegionWarData().stage > 2 then
			--    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC34'),COLOR_TYPE.RED)
			--else
			if LegionMgr:getLegionWarData().stage >= 2 then
				LegionMgr:showLegionWarLogUI(self.cityinfo.city.reports)
			else
				LegionMgr:showLegionWarCityDefUI(self.cityid, self.cityinfo, self.legionwardata)
			end
		end)
	else
		funcBtnLabel:setString(GlobalApi:getLocalStr("STR_BATTLE_REPORT1"))
		funcBtn:addClickEventListener(function()
			AudioMgr.PlayAudio(11)
			LegionMgr:showLegionWarLogUI(self.cityinfo.city.reports)
		end)
	end
	
	local scoredesctx = infoImg:getChildByName('score_desc_tx')
	scoredesctx:setString(GlobalApi:getLocalStr('SCORE'))
	local buflvdesctx = infoImg:getChildByName('buflv_desc_tx')
	buflvdesctx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC21') .. ':')
	local awardesctx = infoImg:getChildByName('award_desc_tx')
	awardesctx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC23') .. ':')
	local armdesctx = infoImg:getChildByName('arm_desc_tx')
	armdesctx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC22') .. ':')
	local scorenumtx = infoImg:getChildByName('score_num_tx')
	scorenumtx:setString(cityconf[self.cityid].score)
	self.armnumtx = infoImg:getChildByName('arm_num_tx')
	self.bufnumtx = infoImg:getChildByName('buf_num_tx')
	self.bufdesc2tx = infoImg:getChildByName('buf_desc_tx2')
	self.awardnodetab = {}
	for i = 1, 5 do
		self.awardnodetab[i] = infoImg:getChildByName('award_node_' .. i)
	end
	
	local bottombg = bgimg2:getChildByName('display_img')
	self.personlsview = bottombg:getChildByName('ls_view')
	local node = cc.CSLoader:createNode("csb/legion_war_city_member_cell.csb")
	local cellbgimg = node:getChildByName("bg_img")
	self.personlsview:setItemModel(cellbgimg)
	self.personlsview:setScrollBarEnabled(false)
	self:initPersonSv()
	self:update()
end
function LegionWarCityInfoUI:onShow()
	self:update()
end
function LegionWarCityInfoUI:initPersonSv()
	local cityconf = GameData:getConfData('legionwarcity')
	self.persontab = {}
	--if self.isself == 1 then
	local cellnum = self:calcPersonNum()
	for i = 1, cellnum do
		self.personlsview:pushBackDefaultItem()
		local item = self.personlsview:getItem(i - 1)
		item:setName('item_' ..(i - 1))
		item:addTouchEventListener(function(sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				--自己方城市&&准备阶段&&军团长，副军团长才能放人
				if self.isself == 1 then
					if LegionMgr:getSelfLegionPos() <= 2 then
						if LegionMgr:getLegionWarData().stage == 1 then
							if self.cityinfo.city.arms[tostring(i)].uid ~= 0 then
								local name = self.cityinfo.city_users[tostring(self.cityinfo.city.arms[tostring(i)].uid)].un
								local str = string.format(GlobalApi:getLocalStr('LEGION_WAR_DESC31'), name)
								promptmgr:showMessageBox(str, MESSAGE_BOX_TYPE.MB_OK_CANCEL, function()
									self:cancelPersonMsg(self.cityinfo.city.arms[tostring(i)].uid, i)
								end, GlobalApi:getLocalStr('STR_OK2'), GlobalApi:getLocalStr('MESSAGE_NO'))
							else
								LegionMgr:showLegionWarCityDefListUI(self.cityinfo, self.cityid, i)
							end
						else
							promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC35'), COLOR_TYPE.RED)
						end
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC36'), COLOR_TYPE.RED)
					end
				else
					--print('enemy')
					if self.battledata.user.cards['5']
					and self.cityinfo.city.arms[tostring(i)].alive == true
					and self.battledata.user.cards['5'].have > 0
					and self.cityinfo.city.arms[tostring(i)].type == 1 then
						promptmgr:showMessageBox(GlobalApi:getLocalStr('LEGION_WAR_DESC56'), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function()
							self:useCard(i)
						end, GlobalApi:getLocalStr('STR_OK2'), GlobalApi:getLocalStr('MESSAGE_NO'))
					else
						local legionconf = GameData:getConfData('legion')
						if LegionMgr:getLegionBattleData().user.attackNum <= 0 then
							promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC52'), COLOR_TYPE.RED)
							return
						end
						if LegionMgr:getLegionWarData().stage == 2 then
							if self.cityinfo.city.canAttack then
								if self.cityinfo.city.arms[tostring(i)].alive == true then
									self:attackEnemyMsg(i)
								end
							else
								promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC70'), COLOR_TYPE.RED)
							end
						else
							promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC69'), COLOR_TYPE.RED)
						end
					end
				end
			end
		end)
		local bgimg1 = item:getChildByName('bg_img1')
		local namebg = bgimg1:getChildByName('name_bg')
		local lvLabel = bgimg1:getChildByName('lv_tx')
		local heroimg = bgimg1:getChildByName('hero_img')
		local addimg = heroimg:getChildByName('add_img')
		local barbg = bgimg1:getChildByName('bar_bg')
		local bar = barbg:getChildByName('bar')
		local bartx = barbg:getChildByName('bar_tx')
		addimg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3), cc.FadeIn:create(1), cc.FadeOut:create(1))))
		local stateimg = bgimg1:getChildByName('state_img')
		local fightforceIcon = bgimg1:getChildByName('fightforce_img')
		fightforceIcon:setVisible(false)
		local fightforceLabel = bgimg1:getChildByName('fightforce_al')
		fightforceLabel:setVisible(false)
		local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
		nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
		nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		nameLabel:setLineSpacing(- 5)
		nameLabel:setAnchorPoint(cc.p(0.5, 1))
		nameLabel:setPosition(cc.p(- 4, 175))
		bgimg1:addChild(nameLabel)
		self.persontab[i] = {
			img = bgimg1,
			name = nameLabel,
			lv = lvLabel,
			icon = fightforceIcon,
			fightforce = fightforceLabel,
			heroimg = heroimg,
			addimg = addimg,
			namebg = namebg,
			stateimg = stateimg,
			barbg = barbg,
			bar = bar,
			bartx = bartx,
		}
	end
	--else
	--end
end

function LegionWarCityInfoUI:updateDisplay()
	self.battledata = LegionMgr:getLegionBattleData()
	local index = 1
	--printall(self.cityinfo.city.arms)
	for i = 1, #self.persontab do
		local data = self.cityinfo.city.arms[tostring(i)]
		self.persontab[index].img:setVisible(true)
		self.persontab[index].namebg:setVisible(false)
		self.persontab[index].stateimg:setVisible(false)
		self.persontab[index].stateimg:setLocalZOrder(999)
		self.persontab[index].barbg:setVisible(false)
		if data.type == 1 or data.type == 2 then
			--暗格
			self.persontab[index].img:loadTexture('uires/ui/citycraft/dizuoan.png')
			self.persontab[index].lv:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC25'))
		else
			self.persontab[index].img:loadTexture('uires/ui/citycraft/dizuo.png')
			self.persontab[index].lv:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC26'))
		end
		if data.uid ~= 0 then
			local userdata = self.cityinfo.city_users[tostring(data.uid)]
			self.persontab[index].img:removeChildByName("hero")
			self.persontab[index].img:removeChildByTag(9527)
			self.persontab[index].addimg:setVisible(false)
			self.persontab[index].heroimg:setVisible(false)
			self.persontab[index].namebg:setVisible(true)
			local conf = GameData:getConfData("hero") [tonumber(userdata.model)]
			local promote = nil
	        local weapon_illusion = nil
	        local wing_illusion = nil
	        if userdata.promote and userdata.promote[1] then
				promote = userdata.promote[1]
			end
	        if conf.camp == 5 then
	            if userdata.weapon_illusion and userdata.weapon_illusion > 0 then
	                weapon_illusion = userdata.weapon_illusion
	            end
	            if userdata.wing_illusion and userdata.wing_illusion > 0 then
	                wing_illusion = userdata.wing_illusion
	            end
	        end
			local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
			local hero = GlobalApi:createLittleLossyAniByName(conf.url .. "_display", nil, changeEquipObj)
			hero:setScale(0.7)
			hero:getAnimation():play("idle", - 1, - 1)
			hero:setName("hero")
			hero:setPosition(cc.p(78.5, 50 + conf.uiOffsetY * 0.7))
			self.persontab[index].stateimg:setLocalZOrder(100)
			self.persontab[index].img:addChild(hero)
			local shadow = hero:getBone(conf.url .. "_shadow")
			if shadow then
				shadow:changeDisplayWithIndex(- 1, true)
			end
			local flag = GlobalApi:isContainEnglish(tostring(userdata.un))
			if flag then
				self.persontab[index].name:setAnchorPoint(cc.p(0, 0.5))
				self.persontab[index].name:setRotation(90)
				self.persontab[index].name:setMaxLineWidth(0)
			else
				self.persontab[index].name:setAnchorPoint(cc.p(0.5, 1))
				self.persontab[index].name:setRotation(0)
				self.persontab[index].name:setMaxLineWidth(20)
			end
			self.persontab[index].name:setVisible(true)
			self.persontab[index].name:setString(userdata.un)
			self.persontab[index].name:setTextColor(COLOR_QUALITY[userdata.quality])
			
			if data.alive == true then
				if data.type == 1 and self.isself == 0 then
					self.persontab[index].fightforce:setString("")
					self.persontab[index].icon:setVisible(false)
					self.persontab[index].fightforce:setVisible(false)
					self.persontab[index].namebg:setVisible(false)
					self.persontab[index].name:setVisible(false)
                    self.persontab[index].barbg:setVisible(true)
                    self.persontab[index].bar:setPercent(math.floor(data.power))
                    self.persontab[index].bartx:setString(tostring(math.floor(data.power)..'%'))
				else
					self.persontab[index].fightforce:setString(tostring(userdata.fight_force))
					self.persontab[index].icon:setVisible(true)
					self.persontab[index].fightforce:setVisible(true)
                    if self.isself == 1 then
                        self.persontab[index].barbg:setVisible(false)
                    else
                        self.persontab[index].barbg:setVisible(true)
                        self.persontab[index].bar:setPercent(math.floor(data.power))
                        self.persontab[index].bartx:setString(tostring(math.floor(data.power)..'%'))
                    end

					if data.type == 2 then
						self.persontab[index].stateimg:loadTexture('uires/ui/text/yibaolou.png')
						self.persontab[index].stateimg:setVisible(true)
					end
				end
			else
				if self.isself == 0 then
					self.persontab[index].stateimg:loadTexture('uires/ui/text/tx_yijipo.png')
					self.persontab[index].stateimg:setVisible(true)
				end
				self.persontab[index].fightforce:setString(tostring(userdata.fight_force))
				self.persontab[index].icon:setVisible(true)
				self.persontab[index].fightforce:setVisible(true)
                self.persontab[index].barbg:setVisible(true)
                self.persontab[index].bar:setPercent(0)
                self.persontab[index].bartx:setString('0%')		
			end
		else
			self.persontab[index].heroimg:setVisible(true)
			--自己方城市&&准备阶段&&军团长，副军团长才能放人
			if self.isself == 1 and LegionMgr:getLegionWarData().stage == 1 and LegionMgr:getSelfLegionPos() <= 2 then
				self.persontab[index].addimg:setVisible(true)
			else
				self.persontab[index].addimg:setVisible(false)
				self.persontab[index].heroimg:setVisible(false)
				self.persontab[index].namebg:setVisible(false)
			end
			self.persontab[index].img:removeChildByName("hero")
			self.persontab[index].icon:setVisible(false)
			self.persontab[index].fightforce:setVisible(false)
			self.persontab[index].name:setString('')
		end
		index = index + 1
	end
	local cityconf = GameData:getConfData('legionwarcity')
	local awardstab = DisplayData:getDisplayObjs(cityconf[self.cityid].award)
	for i = 1, 5 do
		if awardstab[i] then
			local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awardstab[i], self.awardnodetab[i])
		end
	end
end

function LegionWarCityInfoUI:update()
	self.legionwardata = LegionMgr:getLegionBattleData()
	local cityconf = GameData:getConfData('legionwarcity')
	local attsconf = GameData:getConfData('attribute')
	self.armnumtx:setString(self.cityinfo.city.aliveArm .. '/' .. cityconf[self.cityid].arm)
	self.bufnumtx:setString(self.cityinfo.city.buffLevel .. GlobalApi:getLocalStr('LEGION_LV_DESC'))
	
	
	self.bufdesc2tx:setString('')
	self.bufdesc2tx:removeAllChildren()
	if cityconf[self.cityid] [tostring('atts' .. self.cityinfo.city.buffLevel)] [1] > 0 then
		local rt1 = xx.RichText:create()
		self.bufdesc2tx:addChild(rt1)
		rt1:setPosition(cc.p(0, 15))
		rt1:setAlignment('middle')
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC66'), 24, COLOR_TYPE.ORANGE)
		re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
		re1:setFont('font/gamefont.ttf')
		local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC22'), 24, COLOR_TYPE.WHITE)
		re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
		re2:setFont('font/gamefont.ttf')
		rt1:addElement(re1)
		rt1:addElement(re2)
		for k, v in pairs(cityconf[self.cityid] [tostring('atts' .. self.cityinfo.city.buffLevel)]) do
			local str1 = attsconf[v].name .. GlobalApi:getLocalStr('STR_TIGAO') --.. cityconf[self.cityid][tostring('value'..self.cityinfo.city.buffLevel)][k]..'%'
			local rex1 = xx.RichTextLabel:create(str1, 22, COLOR_TYPE.WHITE)
			rex1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
			rex1:setFont('font/gamefont.ttf')
			rt1:addElement(rex1)
			
			local rex2 = xx.RichTextLabel:create(cityconf[self.cityid] [tostring('value' .. self.cityinfo.city.buffLevel)] [k] .. '%', 24, COLOR_TYPE.GREEN)
			rex2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
			rex2:setFont('font/gamefont.ttf')
			rt1:addElement(rex2)
			if k < #cityconf[self.cityid] [tostring('atts' .. self.cityinfo.city.buffLevel)] then
				local rex3 = xx.RichTextLabel:create('，', 22, COLOR_TYPE.WHITE)
				rex3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
				rex3:setFont('font/gamefont.ttf')
				rt1:addElement(rex3)
			end
		end
		rt1:setVerticalAlignment('middle')
		rt1:format(true)
		rt1:setAnchorPoint(cc.p(0.5, 0.5))
	end
	self:updateDisplay()
end

function LegionWarCityInfoUI:calcPersonNum()
	local num = 0
	for k, v in pairs(self.cityinfo.city.arms) do
		num = num + 1
	end
	return num
end

function LegionWarCityInfoUI:cancelPersonMsg(uid, pos)
	local args = {
		city = self.cityid,
		arm_uid = uid
	}
	MessageMgr:sendPost("remove_city_force", "legionwar", json.encode(args), function(response)
		local code = response.code
		if code == 0 then
			promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC29'), COLOR_TYPE.GREEN)
			self.cityinfo.city.arms[tostring(pos)].uid = 0
			self.cityinfo.city.aliveArm = self.cityinfo.city.aliveArm - 1
			local battledata = LegionMgr:getLegionBattleData()
			battledata.ownLegion.cities[tostring(self.cityid)].aliveArm = battledata.ownLegion.cities[tostring(self.cityid)].aliveArm - 1
			battledata.ownLegion.garrion[tostring(uid)] = battledata.ownLegion.garrion[tostring(uid)] - 1
			self:update()
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC30'), COLOR_TYPE.RED)
		end
	end)
end

function LegionWarCityInfoUI:attackEnemyMsg(pos)
	local power = self.cityinfo.city.arms[tostring(pos)].power
	local args = {
		city = self.cityid,
		arm = pos
	}
	MessageMgr:sendPost("attack_arm", "legionwar", json.encode(args), function(response)
		local code = response.code
		if code == 0 then
			local atts = self:calcatts(response.data.cardEffects)
			local customObj = {
				info = response.data.info.fight_info,
				enemy = response.data.enemy.fight_info,
				city = self.cityid,
				arm = pos,
				attrs = atts,
				rand1 = response.data.rand1,
                rand2 = response.data.rand2,
                power = power
			}

			--玩法指引数据同步
			local guide = UserData:getUserObj():getGuideData()
			if guide and guide.legionwar_attacknum then
				local surplusAttackNum = guide.legionwar_attacknum
				surplusAttackNum = surplusAttackNum - 1
				if surplusAttackNum < 0 then
					surplusAttackNum = 0
				end
				UserData:getUserObj():setGuideAttacknum(surplusAttackNum)
			end

			BattleMgr:playBattle(BATTLE_TYPE.LEGION_WAR, customObj, function()
				MainSceneMgr:showMainCity(function()
					LegionMgr:showMainUI(function()
						LegionMgr:showLegionWarMainUI(function()
							LegionMgr:showLegionWarBattleUI()
						end)
					end)
				end, nil, GAME_UI.UI_LEGIONWAR_BATTLE)
				
			end)
		elseif code ==  110 then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("LEGION_WAR_SERVER_ERROR6"), MESSAGE_BOX_TYPE.MB_OK, function ()	
				LegionMgr:hideLegionWarCityInfoUI()
			end)
		elseif code ==  111 then
			promptmgr:showMessageBox(GlobalApi:getLocalStr("LEGION_WAR_SERVER_ERROR5"), MESSAGE_BOX_TYPE.MB_OK, function ()	
			end)
		else
			promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()	
			end)
		end
	end)
end

function LegionWarCityInfoUI:calcatts(arr)
	local attsconf = GameData:getConfData('attribute')
	local attackarr = {}
	for i = 1, #attsconf do
		attackarr[i] = 0
	end
	local cardconf = GameData:getConfData('legionwarcard')
	for i, v in pairs(arr) do
		local cardeffid = cardconf[v].att
		local cardeff = cardconf[v].value
		attackarr[tonumber(cardeffid)] = attackarr[tonumber(cardeffid)] + cardeff
	end
	local cityconf = GameData:getConfData('legionwarcity')
	local attsconf = GameData:getConfData('attribute')
	for k, v in pairs(cityconf[self.cityid] [tostring('atts' .. self.cityinfo.city.buffLevel)]) do
		if v > 0 then
			attackarr[v] = attackarr[v] + cityconf[self.cityid] [tostring('value' .. self.cityinfo.city.buffLevel)] [k]
		end
	end
	--print('attack atts')
	--printall(attackarr)
	return attackarr
end
--使用探明暗格的卡牌
function LegionWarCityInfoUI:useCard(armpos)
	local args = {
		card = 5,
		target = {
			city = self.cityid,
			arm = armpos,		
		},
	}
	
	MessageMgr:sendPost('use_card', 'legionwar', json.encode(args), function(response)
		local code = response.code
		if code == 0 then
			local data = self.cityinfo.city.arms[tostring(armpos)]
			data.type = 2
			self.cityinfo.city_users[tostring(data.uid)] = response.data.arm
			self.battledata.user.cards['5'].have = self.battledata.user.cards['5'].have - 1
			if self.battledata.user.cards['5'].have < 0 then
				self.battledata.user.cards['5'].have = 1
			end
			self:update()
		end
	end)
end
return LegionWarCityInfoUI 