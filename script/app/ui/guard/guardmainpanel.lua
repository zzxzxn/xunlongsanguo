local GuardMainUI = class("GuardMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function GuardMainUI:ctor(id)
	self.uiIndex = GAME_UI.UI_GUARDMAIN
	self.selectId = tonumber(id)
	self.type = 0
end

function GuardMainUI:init()
	local guardBgImg = self.root:getChildByName("guard_bg_img")
	local bgimg1 = guardBgImg:getChildByName('bg_img1')
	self.guardImg = bgimg1:getChildByName("guard_img")
	self:adaptUI(guardBgImg, bgimg1)
	local winsize = cc.Director:getInstance():getWinSize()
    local closeBtn = self.guardImg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
           GuardMgr:hideGuardMain()
        end
    end)
    self.mainImg = self.guardImg:getChildByName("main_img")

    self.jadeSealAddition = 1
    local addition = UserData:getUserObj():getJadeSealAddition("guard")
    if addition[1] then
        self.jadeSealAddition = 1 + addition[2]/100
    end

    self:update()

    local addition_img = self.mainImg:getChildByName("addition_img")
    local enemyLeftPl = self.mainImg:getChildByName("enemy_left_pl")
    if enemyLeftPl:isVisible() then
    	addition_img:setVisible(false)
    else
	    addition_img:setTouchEnabled(true)
	    local additionPos = self.mainImg:convertToWorldSpace(cc.p(addition_img:getPosition()))
	    addition_img:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            TipsMgr:showJadeSealAdditionTips(additionPos, "guard")
	        end
	    end)
	    local addition_tx = addition_img:getChildByName("addition_tx")

	    local addition = UserData:getUserObj():getJadeSealAddition("guard")
	    addition_tx:setString(addition[2] .. "%")
	    if not addition[1] then
	        ShaderMgr:setGrayForWidget(addition_img)
	        addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
	    end
    end
end

function GuardMainUI:update(status)
	if status == nil then
		local data = GuardMgr:getAllCityData()

		local ttype = 1
		for k, v in pairs(data.guard.field) do
			if tonumber(k) == self.selectId then
				if tonumber(v.status) == 0 and tonumber(v.time) == 0 then
					ttype = 2
				else
					ttype = 4
				end				
			end
		end
		self:updateLeft(ttype)
		self:updateRight(ttype)
	else
		self:updateLeft(status)
		self:updateRight(status)
	end
end

function GuardMainUI:updateLeft(status)
	local nameBgImg = self.mainImg:getChildByName("name_bg")
	local cityNameTx = nameBgImg:getChildByName("name_tx")
	local cityConf = GameData:getConfData("guardfield")[self.selectId]
	cityNameTx:setString(cityConf.name)
	local enemyLeftPl = self.mainImg:getChildByName("enemy_left_pl")
	enemyLeftPl:setVisible(false)
	local addLeftPl = self.mainImg:getChildByName("add_left_pl")
	addLeftPl:setVisible(false)
	local myHeroLeftPl = self.mainImg:getChildByName("my_hero_left_pl")
	myHeroLeftPl:setVisible(false)
	local patrolLeftPl = self.mainImg:getChildByName("patrol_left_pl")
	patrolLeftPl:setVisible(false)
	patrolLeftPl:setBackGroundImage('uires/ui/guard/guard_'..cityConf.bgimg)
	myHeroLeftPl:setBackGroundImage('uires/ui/guard/guard_'..cityConf.bgimg)
	addLeftPl:setBackGroundImage('uires/ui/guard/guard_'..cityConf.bgimg)
	enemyLeftPl:setBackGroundImage('uires/ui/guard/guard_'..cityConf.bgimg)

	if status == 1 then
		local enemyTxbg = enemyLeftPl:getChildByName('enemy_name_bg_ico')
		local enemyTx = enemyTxbg:getChildByName('enemy_name_tx')
		local monsterConf = GameData:getConfData("guardmonster")[self.selectId]
		enemyTx:setString(monsterConf.name)
		local bossConf = GameData:getConfData("formation")[tonumber(monsterConf.bossId)]
		local bossId = bossConf['pos' .. bossConf.boss]
		local roleConf = GameData:getConfData("monster")[tonumber(bossId)]
		local spineAni = GlobalApi:createLittleLossyAniByName(roleConf.url.."_display")
	    spineAni:setScale(1)
	    spineAni:setPosition(cc.p(185,100))
	    spineAni:getAnimation():play('idle', -1, 1)
	    enemyLeftPl:addChild(spineAni,1,1)
		enemyLeftPl:setVisible(true)
	elseif status == 2 then
		patrolLeftPl:removeChildByTag(9527)
		local addBtn = addLeftPl:getChildByName('add_btn')
		addBtn:addTouchEventListener(function (sender, eventType)
	        if eventType ==  ccui.TouchEventType.ended then
	           self:onClickAdd()
	        end
	    end)
	    addBtn:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.3),cc.FadeIn:create(1),cc.FadeOut:create(1))))
		addLeftPl:setVisible(true)
		local desctx1 = addLeftPl:getChildByName('add_info_tx')
		desctx1:setString(GlobalApi:getLocalStr('GUARD_DESC9'))
		local desctx2 = addLeftPl:getChildByName('add_info_tx1')
		desctx2:setString(GlobalApi:getLocalStr('GUARD_DESC10'))
	elseif status == 3 then
	    self.addspineAni = GlobalApi:createLittleLossyAniByRoleId(GuardMgr:getSelectRoleId())
	    self.addspineAni:setScale(1)
	    self.addspineAni:setPosition(cc.p(185,100))
	    self.addspineAni:getAnimation():play('idle', -1, 1)
	    myHeroLeftPl:addChild(self.addspineAni,1,1)
		myHeroLeftPl:setVisible(true)
		self.talkbg = myHeroLeftPl:getChildByName('talk_bg')
		self.talkbg:setLocalZOrder(2)
		self.tx = self.talkbg:getChildByName('talk_tx')
		self.tx:setString(GlobalApi:getLocalStr('GUARD_DESC11'))
		local enemyTx = myHeroLeftPl:getChildByName('role_name_tx')
		local roleobj = RoleData:getRoleInfoById(GuardMgr:getSelectRoleId())
		enemyTx:setString(roleobj:getName())
	elseif status == 4 then
		local data = GuardMgr:getAllCityData()
		for k, v in pairs(data.guard.field) do
			if tonumber(k) == self.selectId then
				self:addIdleNpc(patrolLeftPl)
				self.selectRole = GlobalApi:createLittleLossyAniByRoleId(v.hid)
				self.selectRole:setScale(0.5)
			 	self.selectRole:setPosition(cc.p(50, 50))
			    self.selectRole:getAnimation():play('run', -1, 1)
			    self.selectRole:setTag(9527)
			    patrolLeftPl:addChild(self.selectRole,1,9999)
			    local heroconf = GameData:getConfData('hero')[v.hid]
			    local selectAni = GlobalApi:createLittleLossyAniByName("ui_hueichen_01")
				selectAni:getAnimation():playWithIndex(0, -1, 1)
				selectAni:setPosition(cc.p(-200,-20-heroconf.uiOffsetY))
				selectAni:setVisible(true)
				selectAni:setScale(2)
				self.selectRole:addChild(selectAni)

				local spine = GlobalApi:createSpineByName("ui_xunluozhong", "spine/ui_xunluozhong/ui_xunluozhong", 1)
			    spine:setPosition(cc.p(25, 200))
			    if heroconf.uiOffsetY ~= 0 then
			    	spine:setPosition(cc.p(25, 200-heroconf.uiOffsetY+30))
			    end
			    spine:setAnimation(0, "animation", true)
			    self.selectRole:addChild(spine,1,1000)

			    local move1 = cc.MoveTo:create(3, cc.p(200, 100))
			    local move2 = cc.MoveTo:create(3, cc.p(500, 50))
			    local move3 = cc.MoveTo:create(3, cc.p(100, 100))
			    local move4 = cc.MoveTo:create(3, cc.p(-100, 50))
		        local fn1 = cc.CallFunc:create(function ()
		            self.selectRole:setScaleX(0.6)
		            spine:setScaleX(1)
		        end)
		        --local move2 = cc.MoveTo:create(3, cc.p(50, 100))
		        local fn2 = cc.CallFunc:create(function ()
		            self.selectRole:setScaleX(-0.6)
		            spine:setScaleX(-1)
		        end)
		        self.selectRole:runAction(cc.RepeatForever:create(cc.Sequence:create(fn1,move1,move2,fn2,move1,move3,move4)))
			end
		end
		patrolLeftPl:setVisible(true)
	end
end

function GuardMainUI:addIdleNpc(parent)
	local talkbg1 = ccui.ImageView:create('uires/ui/battle/bg_talk_5.png')
	talkbg1:setScale(0.6)
    local talktx1 = ccui.Text:create()
    talktx1:setFontName('font/gamefont.ttf')
    talktx1:setFontSize(20)
    talktx1:setAnchorPoint(cc.p(0.5,0.5))
    talktx1:setPosition(cc.p(110,80))
    talktx1:setTextAreaSize(cc.size(118,90))
    talktx1:enableOutline(COLOR_TYPE.BLACK, 1)
    talktx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.WHITE2))
    talkbg1:addChild(talktx1)
    local cityConf = GameData:getConfData("guardfield")[self.selectId]

	local spineAni1 = GlobalApi:createLittleLossyAniByRoleId(3205)
    spineAni1:setScale(0.4)
    spineAni1:setPosition(cc.p(40 ,250))
    spineAni1:getAnimation():play('idle', -1, 1)
    
    parent:addChild(spineAni1,1,80)
    parent:addChild(talkbg1,1,100)
    talkbg1:setPosition(cc.p(40,350))

    local talkbg2 = ccui.ImageView:create('uires/ui/battle/bg_talk_5.png')
    talkbg2:setScale(0.6)
    local talktx2 = ccui.Text:create()
    talktx2:setFontName('font/gamefont.ttf')
    talktx2:setFontSize(20)
    talktx2:setAnchorPoint(cc.p(0.5,0.5))
    talktx2:setPosition(cc.p(110,80))
    talktx2:setTextAreaSize(cc.size(118,90))
    talktx2:enableOutline(COLOR_TYPE.BLACK, 1)
    talktx2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.WHITE2))
    talkbg2:addChild(talktx2)
    
    local spineAni2 = GlobalApi:createLittleLossyAniByRoleId(3206)
    spineAni2:setScale(0.5)
    spineAni2:setPosition(cc.p(190 ,210))
    spineAni2:getAnimation():play('idle', -1, 1)
    
    parent:addChild(spineAni2,1,81)
    parent:addChild(talkbg2,1,101)
    talkbg2:setPosition(cc.p(190,310))
    local talkbg3 = ccui.ImageView:create('uires/ui/battle/bg_talk_5.png')
    talkbg3:setScale(0.6)
    local talktx3 = ccui.Text:create()
    talktx3:setFontName('font/gamefont.ttf')
    talktx3:setFontSize(20)
    talktx3:setAnchorPoint(cc.p(0.5,0.5))
    talktx3:setPosition(cc.p(110,80))
    talktx3:setTextAreaSize(cc.size(118,90))
    talktx3:enableOutline(COLOR_TYPE.BLACK, 1)
    talktx3:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.WHITE2))
    talkbg3:addChild(talktx3)

    local spineAni3 = GlobalApi:createLittleLossyAniByRoleId(3207)
    spineAni3:setScale(0.4)
    spineAni3:setPosition(cc.p(340 ,250))
    
    spineAni3:getAnimation():play('idle', -1, 1)
    parent:addChild(spineAni3,1,82)
    parent:addChild(talkbg3,1,102)
    talkbg3:setPosition(cc.p(340,350))
    
    local time2 = 1
    local fn2 = cc.CallFunc:create(function ()
        time2 = math.random(1,20)
    end)

    local fn3 = cc.CallFunc:create(function ()
        local herorand = math.random(1,3)
        talkbg1:setVisible(false)
        talkbg2:setVisible(false)
        talkbg3:setVisible(false)
	    if herorand == 1 then
	    	talkbg1:setVisible(true)
	    	local rand1 = math.random(1,2)
    		talktx1:setString(cityConf[tostring('sentence')..rand1])
	    	talkbg1:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.FadeOut:create(2)))
	    	talktx1:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.FadeOut:create(2)))
	    elseif herorand == 2 then
	    	local rand2 = math.random(4,5)
    		talktx2:setString(cityConf[tostring('sentence')..rand2])
	    	talkbg2:setVisible(true)
	    	talkbg2:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.FadeOut:create(2)))
	    	talktx2:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.FadeOut:create(2)))
	    else
	    	local rand3 = math.random(7,8)
    		talktx3:setString(cityConf[tostring('sentence')..rand3])
	    	talkbg3:setVisible(true)
	    	talkbg3:runAction(cc.Sequence:create(cc.DelayTime:create(7),cc.FadeOut:create(2)))
	    	talktx3:runAction(cc.Sequence:create(cc.DelayTime:create(7),cc.FadeOut:create(2)))
	    end
    end)
    parent:runAction(cc.RepeatForever:create(cc.Sequence:create(fn3,fn2,cc.DelayTime:create(time2),cc.DelayTime:create(time2))))
end

function GuardMainUI:updateRight(status)
	local rightBgImg = self.mainImg:getChildByName("right_bg_img")
	local enemyRightPl = rightBgImg:getChildByName("enemy_right_pl")
	enemyRightPl:setVisible(false)
	local addRightPl = rightBgImg:getChildByName("add_right_pl")
	addRightPl:setVisible(false)
	local myHeroRightPl = rightBgImg:getChildByName("my_hero_right_pl")
	myHeroRightPl:setVisible(false)
	local patrolRightPl = rightBgImg:getChildByName("patrol_right_pl")
	patrolRightPl:setVisible(false)

	if status == 1 then
		local monsterConf = GameData:getConfData("guardmonster")[self.selectId]
		local bossConf = GameData:getConfData("formation")[tonumber(monsterConf.bossId)]
		local bossId = bossConf['pos' .. bossConf.boss]
		local awardtoptx = enemyRightPl:getChildByName('award_top_tx')
		awardtoptx:setString(GlobalApi:getLocalStr('GUARD_DESC3'))
		local enemyInfoTx = enemyRightPl:getChildByName('enemy_info_tx')
		enemyInfoTx:setString(monsterConf.content1)
		enemyInfoTx:ignoreContentAdaptWithSize(false)
    	enemyInfoTx:setTextAreaSize(cc.size(384,200))

    	local photoIco = {}
		local award = DisplayData:getDisplayObjs(monsterConf.award)
		for i = 1, 4 do
			photoIco[i] = enemyRightPl:getChildByName('node_' .. i)
			if award[i] then
				ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award[i], photoIco[i])
			end
		end

		local challengeBtn = enemyRightPl:getChildByName('challenge_btn')
		local challengeBtnTx = challengeBtn:getChildByName('challenge_tx')
		challengeBtnTx:setString(GlobalApi:getLocalStr('GUARD_DESC4'))
		challengeBtn:addTouchEventListener(function (sender, eventType)
			local idx = self.selectId
        	if eventType ==  ccui.TouchEventType.ended then
	              local customObj = {
                    id = self.selectId,
                    bossId = tonumber(monsterConf.bossId),
                    type = 1
                }
                BattleMgr:playBattle(BATTLE_TYPE.GUARD, customObj, function ()
                	local id = tonumber(monsterConf.bossId)
                    MainSceneMgr:showMainCity(function()
                        CampaignMgr:showCampaignMain()
                        GuardMgr:showGuardMap(idx)
                    end, nil, GAME_UI.UI_GUARDMAIN)
                end)
	        end
	    end)

    	local fightingTx = enemyRightPl:getChildByName('fighting_text_tx')
    	fightingTx:setString('')

    	local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(439, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC2'),25, COLOR_TYPE.ORANGE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    local re2 = xx.RichTextLabel:create(monsterConf.power,25, COLOR_TYPE.WHITE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:setAnchorPoint(cc.p(0,0.5))
		richText:setVerticalAlignment('middle')
	    richText:setPosition(cc.p(0,-3))
	    fightingTx:addChild(richText,9527)
		enemyRightPl:setVisible(true)
	elseif status == 2 then
		local cityConf = GameData:getConfData('guardfield')[self.selectId]
		local titletx1 = addRightPl:getChildByName('add_title_1_tx')
		titletx1:setString('')
		local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(439, 40))
	    local re1 = xx.RichTextLabel:create(cityConf.name..GlobalApi:getLocalStr('GUARD_DESC6'),23, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC5'),19, COLOR_TYPE.ORANGE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(0,-3))
	    titletx1:addChild(richText,9527)

	    local titletx2 = addRightPl:getChildByName('add_title_2_tx')
		titletx2:setString('')
		local richText1 = xx.RichText:create()
	    richText1:setContentSize(cc.size(439, 40))
	    local re1 = xx.RichTextLabel:create(cityConf.name..GlobalApi:getLocalStr('GUARD_DESC7'),23, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC5'),19, COLOR_TYPE.ORANGE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    richText1:addElement(re1)
	    richText1:addElement(re2)
	    richText1:setAnchorPoint(cc.p(0,0.5))
	    richText1:setPosition(cc.p(0,-3))
	    titletx2:addChild(richText1,9527)

	   	local titletx3 = addRightPl:getChildByName('add_title_3_tx')
		titletx3:setString('')
		local richText2 = xx.RichText:create()
	    richText2:setContentSize(cc.size(439, 40))
	    local re1 = xx.RichTextLabel:create(cityConf.name..GlobalApi:getLocalStr('GUARD_DESC8'),23, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText2:addElement(re1)
	    richText2:setAnchorPoint(cc.p(0,0.5))
	    richText2:setPosition(cc.p(0,-3))
	    titletx3:addChild(richText2,9527)

		local awardtab1 = {}
		local awardtab2 = {}
		for i = 1, 4 do
			local arr1 = {}
			arr1.bg = addRightPl:getChildByName('tiao_1_img')
			arr1.frame = arr1.bg:getChildByName('node_' .. i)
			awardtab1[i] = arr1
			local arr2 = {}
			arr2.bg = addRightPl:getChildByName('tiao_2_img')
			arr2.frame = arr2.bg:getChildByName('node_' .. i)
			awardtab2[i] = arr2
		end

		local cityData = GameData:getConfData('guard')[self.selectId]
		local index1 = 1
		local index2 = 1
		local addtab = {}
		for i = 1, #cityData do
			if cityData[i].show == 1  and cityData[i].award[1] then
				local award = DisplayData:getDisplayObj(cityData[i].award[1])
				if award:getType() == 'fragment' then
					ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, awardtab1[index1].frame)
					index1 = index1 + 1
				else
					local ishave = false
						for k,v in pairs(addtab) do
							if award:getType() == v[1] and cityData[i].award[1][2] == v[2] then
								ishave =true
							end
						end
					if not ishave then
						table.insert(addtab,cityData[i].award[1])
						if index2 <= 4 then
							ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, awardtab2[index2].frame)
							index2 = index2 + 1
						end

					end
				end
			end
		end
		local bg3 = addRightPl:getChildByName('tiao_3_img')
		local sv = bg3:getChildByName('info_sv')
		sv:setScrollBarEnabled(false)
		local infoTx = sv:getChildByName('add_info_tx')
		infoTx:ignoreContentAdaptWithSize(false)
    	infoTx:setTextAreaSize(cc.size(410,120))
		infoTx:setString(cityConf.desc)
		sv:setInnerContainerSize(cc.size(sv:getContentSize().width,infoTx:getContentSize().height))
		infoTx:setPosition(cc.p(12,sv:getInnerContainerSize().height-10))
		addRightPl:setVisible(true)
	elseif status == 3 then
		local photoIco = {}
		local bg = myHeroRightPl:getChildByName('tiao_1_img')
		for i = 1, 8 do
			photoIco[i] = bg:getChildByName('node_' .. i)
		end
		local cityData = GameData:getConfData('guard')[self.selectId]
		local index = 1
		for i = 1, #cityData do
			if cityData[i].show == 1  and index <= 8 and cityData[i].award[1] then
				local award = DisplayData:getDisplayObj(cityData[i].award[1])
				ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, photoIco[i])
				index = index + 1
			end
		end
		local toptx = myHeroRightPl:getChildByName('top_tx')
		toptx:setString(GlobalApi:getLocalStr('MAYBE_GET'))
		local checkBgImg = myHeroRightPl:getChildByName('check_bg_img')
		for i = 1, 3 do
			local kuangIco = checkBgImg:getChildByName('kuang_' .. i .. '_ico')
			local timetx = kuangIco:getChildByName('time_tx')
			timetx:setString(string.format(GlobalApi:getLocalStr('GUARD_DESC13'),GlobalApi:getGlobalValue('guardHourType' .. i)))
			kuangIco:addTouchEventListener(function (sender, eventType)
		        if eventType ==  ccui.TouchEventType.ended then
		    		self:onClickKuang(i)
		        end
		    end)
		end
		self:updateCheck(1)
		local pushBtn = myHeroRightPl:getChildByName('start_btn')
		local pushBtntx =pushBtn:getChildByName('btn_tx')
		pushBtntx:setString(GlobalApi:getLocalStr('GUARD_DESC12'))
		pushBtn:addTouchEventListener(function (sender, eventType)
	        if eventType ==  ccui.TouchEventType.ended then
	        	local soul = UserData:getUserObj():getSoul()
				local costper = GlobalApi:getGlobalValue('guardSoulCostPerHour')
				local hour = GlobalApi:getGlobalValue('guardHourType' .. self.type)
				local freetime = GuardMgr:getFreeTimes()

	        	local func = function ()
		        	if costper > soul then
		        		promptmgr:showSystenHint(GlobalApi:getLocalStr('NOT_ENOUGH_SOUL'), COLOR_TYPE.RED)
		        		local award = DisplayData:getDisplayObj({'user','soul',0})
		        		GetWayMgr:showGetwayUI(award,true)
		        		return
		        	end
		        	self:onClickPush()
		    		local action1 = cc.Spawn:create(cc.FadeTo:create(0.1, 255), cc.EaseBackOut:create(cc.ScaleTo:create(0.1, 0.2)))
		    		local fn1 = cc.CallFunc:create(function ()
			            self.talkbg:setVisible(false)
			    		local selectAni = GlobalApi:createLittleLossyAniByName("ui_hueichen_01")
						selectAni:getAnimation():playWithIndex(0, -1, 1)
						selectAni:setPosition(cc.p(-100,-50))
						selectAni:setVisible(true)
						selectAni:setScale(3)
						self.addspineAni:addChild(selectAni)
						self.addspineAni:getAnimation():play('run', -1, 1)
						
					    local move1 = cc.MoveTo:create(1, cc.p(600, 100))
				        local fn2 = cc.CallFunc:create(function ()
				            --self:onClickPush()
				        end)

				        self.addspineAni:runAction((cc.Sequence:create(move1,fn2)))
			        end)
			        self.tx:setString(GlobalApi:getLocalStr('GUARD_DESC36'))
					self.talkbg:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),action1,fn1))	       
	        	end

				if freetime >= tonumber(hour) then
					costper = 0
					func()
				else
					costper = (hour-freetime)*costper
					promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('XUNLUO_COST_MESSAGE'), GlobalApi:getGlobalValue('guardSoulCostPerHour')),MESSAGE_BOX_TYPE.MB_OK_CANCEL,
					    function ()
					    	func()
					    end
				    )
				end
	        end
	    end)
		myHeroRightPl:setVisible(true)
	elseif status == 4 then
		local awardBgIco = patrolRightPl:getChildByName('award_bg_ico')
		local getBtn = awardBgIco:getChildByName('get_btn')
		local getBtntx = getBtn:getChildByName('get_tx')
		getBtntx:setString(GlobalApi:getLocalStr('STR_GET_1'))
		getBtn:addTouchEventListener(function (sender, eventType)
	        if eventType ==  ccui.TouchEventType.ended then
	    		self:onClickGet()
	        end
	    end)
	    local sv1 = patrolRightPl:getChildByName('info_sv')
	    local nextawardtime = patrolRightPl:getChildByName('next_awardtime_tx')
	    sv1:setScrollBarEnabled(false)
	    local awardicobg = patrolRightPl:getChildByName('award_bg_ico')
	    local sv2 = awardicobg:getChildByName('award_sv')
	    sv2:setScrollBarEnabled(false)
	    local toptx = awardicobg:getChildByName('award_top_tx')
	    toptx:setString(GlobalApi:getLocalStr('GUARD_DESC14'))
		self:initGuarding(sv1,sv2)
		local patrolTx = awardBgIco:getChildByName('patroling_tx')
		local data = GuardMgr:getAllCityData()
		for k, v in pairs(data.guard.field) do
			if tonumber(k) == self.selectId then
				local serverTime = tonumber(GlobalData:getServerTime())
				local starTime = tonumber(v.time)
				local finishTime = starTime + tonumber(GlobalApi:getGlobalValue('guardHourType' .. v.type)) * 3600
				local guardtime = GlobalApi:getGlobalValue('guardProduceIntervalTime') --巡逻产生奖励间隔
				if serverTime >= starTime and serverTime <= finishTime then
					getBtn:setBright(false)
					getBtntx:enableOutline(cc.c4b(59,59,59,255),1)
					patrolTx:setString(GlobalApi:getLocalStr('GUARD_DESC15'))
					self:updateGuardTime(patrolTx, finishTime - serverTime-1)
					nextawardtime:setVisible(true)
					local nexttime = guardtime-(serverTime-starTime)%guardtime -1
					Utils:createCDLabel(nextawardtime,nexttime,COLOR_TYPE.YELLOW,COLOROUTLINE_TYPE.YELLOW,CDTXTYPE.FRONT, GlobalApi:getLocalStr('GUARD_DESC24'),COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.ORANGE,20,function ()
				        --print('xxxxx1')
				        nextawardtime:removeAllChildren()
				        self:updateRight(4)
				    end)
				else
					patrolTx:setString(GlobalApi:getLocalStr('GUARD_DESC16'))
					getBtntx:enableOutline(cc.c4b(165,70,6,255),1)
					getBtn:setBright(true)
					nextawardtime:setVisible(false)
					nextawardtime:setString('')
				end
			end
		end
		patrolRightPl:setVisible(true)
	end
end

function GuardMainUI:updateGuardTime(img, diffTime)
	local label = img:getChildByTag(9999)
    local size = img:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:setTag(9999)
    label:setAnchorPoint(cc.p(0,0.5))
    label:setPosition(cc.p(img:getContentSize().width+10, img:getContentSize().height/2))   
    img:addChild(label)
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, nil,nil,nil,25,function ()
    	label:removeAllChildren()
    	--print('xxxxx2')
        self:updateRight(4)
    end)
end

function GuardMainUI:onClickAdd()
	GuardMgr:showGuardList()
end

function GuardMainUI:onClickKuang(id)
	self:updateCheck(id)
end

function GuardMainUI:updateCheck(id)
	self.type = id
	local rightBgImg = self.mainImg:getChildByName("right_bg_img")
	local myHeroRightPl = rightBgImg:getChildByName("my_hero_right_pl")
	--local timeBgImg = myHeroRightPl:getChildByName('time_bg_img')
	local checkBgImg = myHeroRightPl:getChildByName('check_bg_img')
	local cashnumtx = myHeroRightPl:getChildByName('cashnum_tx')
	local cashimg = myHeroRightPl:getChildByName('cash_img')
	for i = 1, 3 do
		local kuangIco = checkBgImg:getChildByName('kuang_' .. i .. '_ico')
		local checkIco = kuangIco:getChildByName('check_ico')
		if id == i then
			kuangIco:setTouchEnabled(false)
			checkIco:setVisible(true)
		else
			kuangIco:setTouchEnabled(true)
			checkIco:setVisible(false)
		end
	end
	local costper = GlobalApi:getGlobalValue('guardSoulCostPerHour')
	local hour = GlobalApi:getGlobalValue('guardHourType' .. id)
	local freetime = GuardMgr:getFreeTimes()
	if freetime >= tonumber(hour) then
		cashnumtx:setVisible(false)
		cashimg:setVisible(false)
	else
		cashimg:setVisible(true)
		cashnumtx:setVisible(true)
		cashnumtx:setString(' x' ..(hour-freetime)*costper)
	end
end

function GuardMainUI:onClickPush()
	local rid = GuardMgr:getSelectRoleId()
	local args = {
		id = self.selectId,
		hid = rid,
		type = self.type
	}
	MessageMgr:sendPost('guard','guard',json.encode(args),function (jsonObj) -- 开始巡逻
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
        	GuardMgr:addAllCityData(jsonObj.data.field,self.selectId)
        	local data = GuardMgr:getAllCityData()
        	data.guard.free_hour = data.guard.free_hour + GlobalApi:getGlobalValue('guardHourType' .. self.type)

            UserData:getUserObj().guard.free_hour = data.guard.free_hour

            UserData:getUserObj().guard.field_sync = data.guard.field
            UserData:getUserObj():addGlobalTime()

        	local awards = jsonObj.data.awards
        	if awards then
	            GlobalApi:parseAwardData(awards)
	            GlobalApi:showAwardsCommon(awards,nil,nil,true)
	        end
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
        	
			local fn1 = cc.CallFunc:create(function ()
	            self:update(4)
	        end)
        	self.talkbg:runAction(cc.Sequence:create(cc.DelayTime:create(1.0),fn1))
        	if CampaignMgr then
                CampaignMgr:updateShowGuard()
            end

        end
    end)
end

function GuardMainUI:onClickGet()
	local args = {
		id = self.selectId
	}
	MessageMgr:sendPost('get_reward','guard',json.encode(args),function (jsonObj)
        print(json.encode(jsonObj))
        if jsonObj.code == 0 then
            -- 清除状态
            UserData:getUserObj().guardAwardStatus = false

        	local data = GuardMgr:getAllCityData()
        	for k, v in pairs(data.guard.field) do
        		if tonumber(k) == self.selectId then
					local hour = GlobalApi:getGlobalValue('guardHourType' .. v.type)
					GuardMgr:setCityAccumulate(hour)
        			v.events = {}
					v.type = 0
					v.time = 0
					v.status = 0
					v.hid = 0

                    local field_sync = UserData:getUserObj().guard.field_sync
                    if not field_sync[k] then
                        field_sync[k] = {}
                    end
                    field_sync[k].type = v.type
                    field_sync[k].status = v.status
                    field_sync[k].time = v.time

        		end
        	end
            UserData:getUserObj():addGlobalTime()
            
        	local awards = jsonObj.data.awards
        	if awards then
	            GlobalApi:parseAwardData(awards)
	            GlobalApi:showAwardsCommon(awards,true,nil,true)
	        end
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.selectRole:stopAllActions()
            self.selectRole:removeFromParent()
        	self:update(2)

            if CampaignMgr then
                CampaignMgr:updateShowGuard()
            end

        end
    end)
end

function GuardMainUI:initGuarding(sv1,sv2)
	sv2:removeAllChildren()
	sv1:removeAllChildren()
	local guardconf = GameData:getConfData('guard')
	local data = GuardMgr:getAllCityData()
	local awardtab = {}
	if data.repress and data.repress[tostring(self.selectId)] then
		local award = ''
		for i=1,#guardconf[tonumber(self.selectId)] do
			if guardconf[tonumber(self.selectId)][i].type == "repression" then
				award = guardconf[tonumber(self.selectId)][i].award[1]
			end
 		end
		local arr = {}
		arr[1] = award[1]
		arr[2] = award[2]
		arr[3] = award[3]
		table.insert(awardtab,arr)
	end

	for k,v in pairs(data.guard.field[tostring(self.selectId)].events) do
		if guardconf[tonumber(self.selectId)][v[1]].award[1]  then
			local award = guardconf[tonumber(self.selectId)][v[1]].award[1]
			local ishave = false
			local num = 0
			for i=1,#awardtab do
				if awardtab[i][1]==award[1] and awardtab[i][2] == award[2] then
					ishave = true
					num = i
					break
				end
			end
			if not ishave then
				local arr = {}
				arr[1] = award[1]
				arr[2] = award[2]
				arr[3] = award[3]
				table.insert(awardtab,arr)
			else
				awardtab[num][3] = awardtab[num][3] + award[3]
			end
		end
	end

	for i=1,#awardtab do
		local award = awardtab[i]
		local displayobj = DisplayData:getDisplayObj(award)
		local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj, sv2)
		cell.lvTx:setString(tostring(math.floor(displayobj:getNum()*self.jadeSealAddition)))
		cell.awardBgImg:setPosition(cc.p((cell.awardBgImg:getContentSize().width+4)*i-cell.awardBgImg:getContentSize().width/2,sv2:getContentSize().height/2))
		if (cell.awardBgImg:getContentSize().width+4)*i > sv2:getContentSize().width then
			sv2:setInnerContainerSize(cc.size((cell.awardBgImg:getContentSize().width+4)*i+10,sv2:getContentSize().height))
		end
	end
	if data.guard.field[tostring(self.selectId)].fragment > 0 then
		local roleobj = RoleData:getRoleInfoById(data.guard.field[tostring(self.selectId)].hid)
		local award = {}
		award[1] = 'fragment'
		award[2] = data.guard.field[tostring(self.selectId)].hid
		award[3] = data.guard.field[tostring(self.selectId)].fragment
		local displayobj = DisplayData:getDisplayObj(award)
		local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj, sv2)
		cell.awardBgImg:setPosition(cc.p((cell.awardBgImg:getContentSize().width+4)*(1+#awardtab)-cell.awardBgImg:getContentSize().width/2,sv2:getContentSize().height/2))
		if (cell.awardBgImg:getContentSize().width+4)*(1+#awardtab) > sv2:getContentSize().width then
			sv2:setInnerContainerSize(cc.size((cell.awardBgImg:getContentSize().width+4)*(1+#awardtab)+10,sv2:getContentSize().height))
		end
	end

	local richText = xx.RichText:create()
	richText:setContentSize(cc.size(420, 40))
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(0,23))
	sv1:addChild(richText)
	if data.repress and data.repress[tostring(self.selectId)] then
		local desc = ''
		for i=1,#guardconf[tonumber(self.selectId)] do
			if guardconf[tonumber(self.selectId)][i].type == "repression" then
				desc = guardconf[tonumber(self.selectId)][i].desc
			end
 		end
		local str  = string.format(desc,data.repress[tostring(self.selectId)].un)
		local re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.PALE)
	    --re1:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,str)
	end

	for k,v in pairs(data.guard.field[tostring(self.selectId)].events) do
		local desc = guardconf[tonumber(self.selectId)][v[1]].desc
		local roleobj = RoleData:getRoleInfoById(data.guard.field[tostring(self.selectId)].hid)
		local str  = string.format(desc,roleobj:getName())
		local re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.PALE)
	    --re1:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,str)
	end
    richText:format(true)
    local labelheight = richText:getBrushY()
    if labelheight > sv1:getContentSize().height then
    	sv1:setInnerContainerSize(cc.size(sv1:getContentSize().width,labelheight))
    end
    richText:setPosition(cc.p(0,sv1:getInnerContainerSize().height-10))
end

function GuardMainUI:createDescCell()
	local desc = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    desc:setPosition(cc.p(88,15))
    desc:setColor(COLOR_TYPE.WHITE)
    desc:enableOutline(COLOR_TYPE.BLACK, 1)
    desc:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    desc:setAnchorPoint(cc.p(1,0.5))
end

return GuardMainUI
