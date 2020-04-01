local ChartInfoUI = class("ChartInfoUI", BaseUI)
local ClassRoleObj  =require('script/app/obj/roleobj')
local fateUI = require('script/app/ui/role/rolefate')
local ClassItemCell = require('script/app/global/itemcell')

local YISHANGZHENG = 'uires/ui/text/yishangzhen.png'
local WEISHANGZHEN = 'uires/ui/text/weishangzhen.png'

function ChartInfoUI:ctor(cardData,showType,obj)
    self.uiIndex = GAME_UI.UI_CHART_INFO
    self.actionisruning = false
    self.showType = showType or ROLE_SHOW_TYPE.NORMAL

    if obj then
        local heroconf = GameData:getConfData('hero') 
        self.cardobj = obj
        --[[
        if RoleData:getRoleById(obj:getId()) then
            self.obj = RoleData:getRoleById(obj:getId())
        else
            self.obj = RoleData:getRoleInfoById(obj:getId())
        end
        --]]
        self.obj = RoleData:getRoleInfoById(obj:getId())
        self.cardData = heroconf[obj:getId()]
    else
        self.cardData = cardData
        --[[
        if RoleData:getRoleById(cardData.id) then
            self.obj = RoleData:getRoleById(cardData.id)
        else
            self.obj = RoleData:getRoleInfoById(cardData.id)
        end
        --]]
        self.obj = RoleData:getRoleInfoById(cardData.id)
    end

    RoleData:getRoleById(id)

    self.svHeight = 0

end

local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}

function ChartInfoUI:init()
    local bg   =  self.root:getChildByName("bg")
    local root =  bg:getChildByName("root")

    local cardData = self.cardData
    self.isRoleBrief = false
    if cardData.roleBrief == '0' then
        self.isRoleBrief = false
    else
        self.isRoleBrief = true
    end

    -- 左边
    --xyh 
    --显示类型图标
    local left_bg =  root:getChildByName("left_bg")


 
    --兵种
    local anmPl =left_bg:getChildByName("anm_pl")
    local countryImg = anmPl:getChildByName("country_img")
    countryImg:loadTexture('uires/ui/common/soldier_'..cardData.soldierId..'.png')

    --职业
    local anmPl =left_bg:getChildByName("anm_pl")
    local type_img = anmPl:getChildByName("type_img")
    type_img:loadTexture('uires/ui/common/professiontype_'..cardData.ability..'.png')

    --阵营
    local soliderImg = anmPl:getChildByName("solider_img")
    local campType = cardData.camp or 1
    soliderImg:loadTexture('uires/ui/common/camp_'..campType..'.png')



    local titleText = anmPl:getChildByName("title_text")
    titleText:setTextColor(self.obj:getNameColor())
	titleText:enableOutline(self.obj:getNameOutlineColor(),2)
    titleText:setString(cardData.heroName)





    local chartImg = anmPl:getChildByName("chart_img")
    chartImg:setVisible(false)
    chartImg:ignoreContentAdaptWithSize(true)
    chartImg:loadTexture('uires/ui/tavern/tavern_tujian.png')
    chartImg:setTouchEnabled(true)
    chartImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:showPokedexHero(self.obj)
        end
    end)

    local roleBg = anmPl:getChildByName("role_bg")
    local spineAni = GlobalApi:createLittleLossyAniByName(cardData.url .. "_display")
	if spineAni then
	--  spineAni:setScale(0.6)
		local shadow = spineAni:getBone(cardData.url .. "_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
		end
		local effectIndex = 1
		repeat
			local aniEffect = spineAni:getBone(cardData.url .. "_effect" .. effectIndex)
			if aniEffect == nil then
				break
			end
			aniEffect:changeDisplayWithIndex(-1, true)
			aniEffect:setIgnoreMovementBoneData(true)
			effectIndex = effectIndex + 1
		until false
		spineAni:setPosition(cc.p(anmPl:getContentSize().width/2,500+cardData.uiOffsetY))
		spineAni:setLocalZOrder(999)
        spineAni:setScale(2.5)
		spineAni:setTag(9527)
		anmPl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		local beginPoint = cc.p(0,0)
		local endPoint = cc.p(0,0)
		anmPl:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				beginPoint = sender:getTouchBeganPosition()
			end

			if eventType ==  ccui.TouchEventType.ended then
				endPoint= sender:getTouchEndPosition()
				local deltax = (beginPoint.x -endPoint.x)
				local deltay = math.abs(beginPoint.y -endPoint.y)
			    if self.actionisruning  ~= true then
				    self.actionisruning = true
				    self:swapanimation(spineAni)
			    end

			end 

		end) 

		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
				self.actionisruning =false
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
				self.actionisruning =false
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end


    local roleBottomImg = anmPl:getChildByName("role_bottom_img")
    if cardData.quality == 6 then
        roleBottomImg:loadTexture('uires/ui/common/tab_red.png')
    elseif cardData.quality == 5 then
        roleBottomImg:loadTexture('uires/ui/common/tab_yellow.png')
    elseif cardData.quality == 4 then
        roleBottomImg:loadTexture('uires/ui/common/tab_purple.png')
    else
        roleBottomImg:setVisible(false)
    end


    local probgImg = anmPl:getChildByName("probg_img")
    local iconChip = probgImg:getChildByName("icon_chip")
    local proBar = probgImg:getChildByName("pro_bar") -- 进度条
    local barTx = proBar:getChildByName("bar_tx")

    local fragment = {}

    local mergenum = 0
    local num = 0
    local isChip = false
    local allfragment = BagData:getFragment()

    local conf = GameData:getConfData('item')
    for k, v in pairs(conf) do -- 碎片
		if v.id == cardData.id then
            isChip = true
            mergenum = v.mergeNum
            break
        end
	end

	for k, v in pairs(allfragment) do
		if v:getId() < 10000 and v:getId() == cardData.id then
			num = v:getOwnNum()
            break
		end
	end

    if isChip == true then
        probgImg:setVisible(true)
        proBar:setPercent((num/mergenum)*100)
        barTx:setString(num ..'/' .. mergenum)
    else
        probgImg:setVisible(false)
    end

    local getBtn = left_bg:getChildByName("get_btn")
    getBtn:getChildByName("inputbtnText"):setString(GlobalApi:getLocalStr('GET_TEXT'))
    getBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            local tempRole = RoleData:getRoleInfoById(self.cardData.id)
            GetWayMgr:showGetwayUI(tempRole,true)	
            --ChartMgr:hideChartInfo()
        end
    end)

    local demoBtn = left_bg:getChildByName("demo_btn")
    demoBtn:getChildByName("inputbtnText"):setString(GlobalApi:getLocalStr('DEMO_TEXT'))
    demoBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            ChartMgr:setDemoDataByIndex(1,self.cardData.id)
            ChartMgr:hideChartInfo()
            
        end
    end)
    
    -- 右边
    local rightRoot =  root:getChildByName("right_bg")
    local closebtn = rightRoot:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            ChartMgr:hideChartInfo()

        end
    end)

    local sv =  rightRoot:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    self.sv = sv
    

    self.bg = sv:getChildByName("bg")
    self.titleImg = self.bg:getChildByName("title_img")


    -- 滑动层里面的操作
    self:calFate()
    if self.isRoleBrief == true then
        self:setDes()
        self.svHeight = self.svHeight + 30
    else
        self.bg:setVisible(false)
    end
 
    local fateatt =	self:getFateArr()
    local skillHeigth = 135
    local specialFate = 240
    local fateHeigth = #fateatt * 110 + 75
    if #fateatt == 0 then
        fateHeigth = 0
    end
    
    local talentHeigth = 0
    --if self.svHeight + 30 + 25 + skillHeigth + 25 + talentHeigth + fateHeigth > sv:getContentSize().height then
    --    sv:setInnerContainerSize(cc.size(sv:getContentSize().width,self.svHeight + 30 + 25 + skillHeigth + 25 + talentHeigth + fateHeigth))
    --end
    
    
    self:genSkill(skillHeigth)

    local innateGroupId = self.obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
    self.teamheroID = groupconf['teamheroID']

    if self.teamheroID > 0 then  -- 表明有组合的武将
        self.svHeight = self.svHeight + 25
        self:genSpeccialFateStayNight(specialFate)
    else
        self.svHeight = self.svHeight + 35
    end

    self.svHeight = self.svHeight + 25
    self:genTalent()
    self.svHeight = self.svHeight
    self:genFateStayNight(fateHeigth)

    if self.svHeight > sv:getContentSize().height then
        sv:setInnerContainerSize(cc.size(sv:getContentSize().width,self.svHeight))
    end
    self:updatePos()




    ccui.Helper:seekWidgetByName(sv, "text"):setString(GlobalApi:getLocalStr('CHART_RECORD'))

    self:adaptUI(bg,root,false)

    self.actionLine = cc.CSLoader:createTimeline("csb/chartinfo.csb")
    self.actionLine:gotoFrameAndPlay(0,55,false)
    self.root:runAction(self.actionLine)
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.66),cc.CallFunc:create(function ()
        self.obj:playSound('sound')
    end)))
    
    -- left
    local mergeBtn = left_bg:getChildByName("merge_btn")                -- 合成
    local beassistpanel = left_bg:getChildByName("beassist_panel")      -- 分解


    if self.showType == ROLE_SHOW_TYPE.NORMAL then
        probgImg:setVisible(false)

        demoBtn:setVisible(false)
        getBtn:setVisible(false)

        mergeBtn:setVisible(false)

        beassistpanel:setVisible(false)

    elseif self.showType == ROLE_SHOW_TYPE.CHART then
        probgImg:setVisible(true)

        demoBtn:setVisible(true)
        getBtn:setVisible(true)

        mergeBtn:setVisible(false)

        beassistpanel:setVisible(false)

    elseif self.showType == ROLE_SHOW_TYPE.CHIP_MERGET then
        probgImg:setVisible(true)

        demoBtn:setVisible(false)
        getBtn:setVisible(false)

        mergeBtn:setVisible(true)

        beassistpanel:setVisible(false)

        local tx = mergeBtn:getChildByName('tx')

		local num = self.cardobj:getOwnNum()
		local mergenum = self.cardobj:getMergeNum()
		proBar:setPercent((num/mergenum)*100)
		barTx:setString(num ..'/' .. mergenum)
        if num >= mergenum then
			self.iscanmerge = true
			mergeBtn:loadTextureNormal('uires/ui/common/common_btn_7.png')
			tx:setString(GlobalApi:getLocalStr("STR_MERGE"))
			tx:setTextColor(COLOR_TYPE.WHITE)
			tx:enableOutline(COLOROUTLINE_TYPE.WHITE2, 1)
			tx:enableShadow(cc.c4b(19, 19, 19, 255), cc.size(0, -1), 0)
		else
            self.iscanmerge = false
			mergeBtn:loadTextureNormal('uires/ui/common/common_btn_5.png')
			tx:setString(GlobalApi:getLocalStr("STR_HUOQU"))
			tx:setTextColor(COLOR_TYPE.WHITE)
			tx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
			tx:enableShadow(cc.c4b(19, 19, 19, 255), cc.size(0, -1), 0)
		end


		mergeBtn:addClickEventListener(function (sender, eventType)
			if self.iscanmerge then
				local args = {
					id = self.obj:getId(),
					num = self.cardobj:getMergeNum()
				}
				MessageMgr:sendPost("use", "bag", json.encode(args), function (jsonObj)
					print(json.encode(jsonObj))
					local code = jsonObj.code
					if code == 0 then
						local awards = jsonObj.data.awards
						GlobalApi:parseAwardData(awards)
						TavernMgr:showTavernAnimate(awards, function (  )
							local costs = jsonObj.data.costs
							if costs then
								GlobalApi:parseAwardData(costs)
							end
							if self.obj:getNum() > 0 then
								self:setType()
							else
								
							end
							RoleMgr:updateRoleList()
							
                            local num = self.cardobj:getOwnNum()
		                    local mergenum = self.cardobj:getMergeNum()
		                    proBar:setPercent((num/mergenum)*100)
		                    barTx:setString(num ..'/' .. mergenum)
                            if num >= mergenum then
			                    self.iscanmerge = true
			                    mergeBtn:loadTextureNormal('uires/ui/common/common_btn_7.png')
			                    tx:setString(GlobalApi:getLocalStr("STR_MERGE"))
			                    tx:setTextColor(COLOR_TYPE.WHITE)
			                    tx:enableOutline(COLOROUTLINE_TYPE.WHITE2, 1)
			                    tx:enableShadow(cc.c4b(19, 19, 19, 255), cc.size(0, -1), 0)
		                    else
                                self.iscanmerge = false
			                    mergeBtn:loadTextureNormal('uires/ui/common/common_btn_5.png')
			                    tx:setString(GlobalApi:getLocalStr("STR_HUOQU"))
			                    tx:setTextColor(COLOR_TYPE.WHITE)
			                    tx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
			                    tx:enableShadow(cc.c4b(19, 19, 19, 255), cc.size(0, -1), 0)
		                    end

                                                                       
							promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_SUCC'), COLOR_TYPE.GREEN)
                        end, 4)

					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_FAIL'), COLOR_TYPE.RED)
					end
				end)
			else               
                if GetWayMgr.uiClass["GetWayUI"] then
                    ChartMgr:hideChartInfo()
                else
                    GetWayMgr:showGetwayUI(self.cardobj,true)
                end
			end
		end)



    elseif self.showType == ROLE_SHOW_TYPE.CARD_DECOMPOSE then
        probgImg:setVisible(false)

        demoBtn:setVisible(false)
        getBtn:setVisible(false)

        mergeBtn:setVisible(false)

        beassistpanel:setVisible(true)
        
        local numtx = beassistpanel:getChildByName('num_tx')
		numtx:setString(self.cardobj:getNum())

        local funcbtn = beassistpanel:getChildByName("func_btn")
        funcbtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                local function callback()
					if self.cardobj:getOwnNum() > 0 then
						local args = {
							cid = self.cardobj:getId(),
							num = 1
						}
						MessageMgr:sendPost("resolve_card", "hero", json.encode(args), function (jsonObj)
							print(json.encode(jsonObj))
							local code = jsonObj.code
							if code == 0 then
								local awards = jsonObj.data.awards
								GlobalApi:parseAwardData(awards)
								local costs = jsonObj.data.costs
								if costs then
									GlobalApi:parseAwardData(costs)
								end
								local disaward = DisplayData:getDisplayObj(awards[1])
								local str = string.format(GlobalApi:getLocalStr('STR_RESOLVE_ONES'),self.cardobj:getName(),tonumber(disaward:getNum()))
								promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
								RoleMgr:updateRoleList()
                                numtx:setString(self.cardobj:getNum())
							end
						end)
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC5'), COLOR_TYPE.RED)
					end
				end
				--分解武将
			    if self.cardobj:getQuality() >= 5 then
	                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("ROLE_DESC9")), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
	                    callback()
	                end)
	            else
	                callback()
	            end
            end
        end)

        local tx = funcbtn:getChildByName('func_tx')
		tx:setString(GlobalApi:getLocalStr("STR_RESOLVE"))
		local desctx = beassistpanel:getChildByName('desc_tx')
		desctx:setString(GlobalApi:getLocalStr('STR_ZHANG'))
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(335, 30))
		local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("STR_RESOLVE_ONE"), 20, COLOR_TYPE.WHITE)
		re1:setStroke(COLOR_TYPE.BLACK, 1)
		local re2 = xx.RichTextLabel:create(self.cardobj:getSoulNum(), 20, COLOR_TYPE.WHITE)
		re2:setStroke(COLOR_TYPE.BLACK, 1)
		local re3 = xx.RichTextImage:create('uires/ui/res/res_soul.png')
		re3:setScale(0.8)
		richText:addElement(re1)
		richText:addElement(re3)
		richText:addElement(re2)

		richText:setLocalZOrder(2)
		richText:setPosition(cc.p(260, 70))
		richText:setTag(9527)
		beassistpanel:removeChildByTag(9527)
		beassistpanel:addChild(richText)
    end

end

function ChartInfoUI:ActionClose()
    self.obj:stopSound('sound')
    self.actionLine:gotoFrameAndPlay(57,95,false)
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.66),cc.CallFunc:create(function ()
            self:hideUI()
        end)))
end

function ChartInfoUI:swapanimation(spineAni)
	-- local seed = math.random(1, 5)
	-- if self.action ~= roleanim[seed] then
	-- 	self.action = roleanim[seed]
	-- 	spineAni:getAnimation():play(roleanim[seed], -1, -1)
	-- end
end


-- 描述
function ChartInfoUI:setDes()
    local bg = self.bg
    local bgSize = bg:getContentSize()
    
    local posX = self.titleImg:getPositionX()
    local posY = self.titleImg:getPositionY()

    local contentWidget = ccui.Widget:create()
    bg:addChild(contentWidget)
    contentWidget:setPosition(cc.p(10, 0))


    --[[local richText = xx.RichText:create()
	richText:setContentSize(cc.size(bgSize.width - 20, 40))
	richText:setAnchorPoint(cc.p(0,1))
	richText:setPosition(cc.p(0,0))
	contentWidget:addChild(richText)

    local str = GlobalApi:getLocalStr('TEST_TEXT')

	local re1 = xx.RichTextLabel:create("",20, COLOR_TYPE.PALE)
	re1:setFont('font/gamefont.ttf')
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	richText:addElement(re1)
	xx.Utils:Get():analyzeHTMLTag(richText,str)

    richText:format(true)
    local labelheight = richText:getBrushY()
    if labelheight > bgSize.height - 65 then -- 65是标题的高低
    	labelheight = labelheight + 65
    else
        labelheight = bgSize.height
    end
    self.svHeight = labelheight
    --]]

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(bgSize.width - 20, 40))
	richText:setAnchorPoint(cc.p(0,1))
	richText:setPosition(cc.p(0,0))
	contentWidget:addChild(richText)

    local str = self.cardData.roleBrief

	local re1 = xx.RichTextLabel:create(str,20, COLOR_TYPE.PALE)
	re1:setFont('font/gamefont.ttf')
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	richText:addElement(re1)

    richText:format(true)
    local labelheight = richText:getBrushY()
    if labelheight > bgSize.height - 65 then -- 65是标题的高低
    	labelheight = labelheight + 65
    else
        labelheight = bgSize.height
    end
    self.svHeight = labelheight


    bg:setContentSize(cc.size(bgSize.width,labelheight))
    contentWidget:setPosition(cc.p(10, labelheight - 60))
    richText:setPosition(cc.p(0,0))
   
    self.labelheight = labelheight

    self.titleImg:setPosition(cc.p(posX,labelheight - 20))
    
end

function ChartInfoUI:updatePos()
    local innerContainerSize = self.sv:getInnerContainerSize()

    if self.teamheroID > 0 then  -- 表明有组合的武将
        self.specialFateWidget:setPosition(cc.p(15,innerContainerSize.height - self.specialFateHeight))
    end
    self.skillWidget:setPosition(cc.p(15,innerContainerSize.height - self.skillHeight))
    self.fateWidget:setPosition(cc.p(15,innerContainerSize.height - self.fateHeight))
    self.tatentWidget:setPosition(cc.p(10,innerContainerSize.height - self.tatentHeight + 35))
 
    if self.isRoleBrief == true then
        self.bg:setPositionY(self.sv:getInnerContainerSize().height - 15)
        self.titleImg:setPositionY(self.labelheight - 20)
    end

end


-- 技能
function ChartInfoUI:genSkill(height)
    local bgSize = self.bg:getContentSize()
    local innerContainerSize = self.sv:getInnerContainerSize()


	local skilltab = self:getSkillIdTab()
	local skillconf = GameData:getConfData("skill")
	local skillcell = cc.CSLoader:createNode("csb/roleinfocellskill.csb")
	local skillbg = skillcell:getChildByName('skillmain_bg_img')
	skillbg:removeFromParent(false)

	local widget = ccui.Widget:create()
    skillbg:setPosition(cc.p(0,height - 55 - skillbg:getContentSize().height))
	widget:addChild(skillbg)
    widget:setAnchorPoint(cc.p(0,1))
    self.sv:addChild(widget)

    -- 封将技能
    if self.cardData.quality == 5 then
        local promoteSkillBtn = ccui.ImageView:create('uires/ui/honorhall/honorhall_fengjiangjineng.png')
        promoteSkillBtn:ignoreContentAdaptWithSize(true)
        promoteSkillBtn:setTouchEnabled(true)
        widget:addChild(promoteSkillBtn)
        promoteSkillBtn:setPosition(cc.p(325,119))
        promoteSkillBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                ChartMgr:showChartPromotedProviewUI(self.obj,1)
            end
        end)
    end

	for i=1,#skilltab do
		local plbg = skillbg:getChildByName('skill_'..i..'_pl')
		local skbg = plbg:getChildByName('skill_bg_img')
		skbg:setSwallowTouches(false)
		local skillimg =skbg:getChildByName('skill_img')
		skillimg:setLocalZOrder(20)
        if i == 2 then
            local posX = plbg:getPositionX()
            plbg:setPositionX(posX - 10)
        end
		--local skillframe = skbg:getChildByName('frame_img')
		local desc = {}
		local nametx = plbg:getChildByName('name_tx')
        nametx:setFontSize(22)
		local lvtx = plbg:getChildByName('lv_tx')
        lvtx:setFontSize(24)
		local heighttemp = 0
		local skill = skillconf[skilltab[i]]
		local skillName = skill['name']
		local skillicon ='uires/icon/skill/' .. skill['skillIcon']
		nametx:setString(skillName)
		lvtx:setString('Lv.' .. 1)
		skillimg:loadTexture(skillicon)
		skillimg:ignoreContentAdaptWithSize(true)
		skbg:addClickEventListener(function ()
			local begin = skbg:getTouchBeganPosition()
			local endp = skbg:getTouchEndPosition()
			if math.abs(endp.x - begin.x) < 20 and math.abs(endp.y - begin.y) < 20 then
				local size = skillbg:getContentSize()
				local x, y = skbg:convertToWorldSpace(cc.p(skbg:getPosition(size.width / 2, size.height / 2)))
				TipsMgr:showRoleSkillTips(1,skilltab[i],cc.p(x,y),false)
			end
		end)
	end
    


	local frame = ccui.ImageView:create('uires/ui/common/name_bg12.png')
	--frame:setScale9Enabled(true)
    frame:ignoreContentAdaptWithSize(false)
    frame:setContentSize(cc.size(216, 40))
	frame:setAnchorPoint(cc.p(0, 1))
    frame:setOpacity(126)
    frame:setPosition(cc.p(0,height))
    widget:addChild(frame)

	local title = self:genTitle(1)
	title:setPosition(cc.p(10,5))
    frame:addChild(title)

    widget:setContentSize(cc.size(bgSize.width,height))
    self.skillHeight = self.svHeight
    widget:setPosition(cc.p(15,innerContainerSize.height - self.svHeight))
    self.svHeight = self.svHeight + height

    self.skillWidget = widget

end

-- 特殊缘分
function ChartInfoUI:genSpeccialFateStayNight(height)
    local bgSize = self.bg:getContentSize()
    local innerContainerSize = self.sv:getInnerContainerSize()

	local widget = ccui.Widget:create()
    widget:setAnchorPoint(cc.p(0,1))
    self.sv:addChild(widget)
	
	local frame1 = ccui.ImageView:create('uires/ui/common/name_bg12.png')
	--frame:setScale9Enabled(true)
    frame1:ignoreContentAdaptWithSize(false)
    frame1:setContentSize(cc.size(216, 40))
	frame1:setAnchorPoint(cc.p(0, 1))
    frame1:setOpacity(126)
    frame1:setPosition(cc.p(0,height))
    widget:addChild(frame1)

	local title = self:genTitle(4)
	title:setPosition(cc.p(10,5))
    frame1:addChild(title)

    local panel = cc.CSLoader:createNode("csb/herospecialfate.csb")
    panel:setPosition(cc.p(22,50))
    widget:addChild(panel)

    local bg = panel:getChildByName('bg')

    local des = bg:getChildByName('des')
    des:setString(GlobalApi:getLocalStr('SPECIAL_FATE_DESC'))

    -- left
    local left = bg:getChildByName('left')
    local leftFrameNode = left:getChildByName('frame_node')
    local itemcell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.obj, leftFrameNode)
    itemcell.awardBgImg:setTouchEnabled(false)
    itemcell.nameTx:setString(self.obj:getName())
    itemcell.nameTx:setTextColor(self.obj:getNameColor())
    itemcell.nameTx:enableOutline(self.obj:getNameOutlineColor(),1)
    itemcell.nameTx:setString(self.obj:getName())
    local leftState = left:getChildByName('state')
    leftState:loadTexture(YISHANGZHENG)

    -- right
    local right = bg:getChildByName('right')
    local rightFrameNode = right:getChildByName('frame_node')
    local itemcell2 = ClassItemCell:create(ITEM_CELL_TYPE.HERO)
    rightFrameNode:addChild(itemcell2.awardBgImg)
    itemcell2.awardBgImg:setTouchEnabled(false)

    local rightState = right:getChildByName('state')

    local innateGroupId = self.obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
    local teamheroID = groupconf['teamheroID']

    -- 判断是否有这个卡牌
    if teamheroID > 0 then  -- 表明有组合的武将
        local obj = RoleData:getRoleInfoById(teamheroID)
        ClassItemCell:updateHero(itemcell2, obj, 1)
        itemcell2.nameTx:setString(obj:getName())

        local roleObj = RoleData:getRoleById(self.obj:getId())
        if BagData:getCardById(self.obj:getId()) or roleObj then
            if roleObj then
                leftState:loadTexture(YISHANGZHENG)
            else
                leftState:loadTexture(WEISHANGZHEN)
            end
        else
            ShaderMgr:setGrayForWidget(itemcell.awardBgImg)
            ShaderMgr:setGrayForWidget(itemcell.awardImg)
            itemcell.nameTx:setTextColor(COLOR_TYPE.GRAY)
            leftState:setVisible(false)
        end
                 
        if roleObj and roleObj:getTalent() >= 2 then    -- 配置表里面现在是2，3，4，5
            itemcell2.nameTx:setTextColor(obj:getNameColor())
            itemcell2.nameTx:enableOutline(obj:getNameOutlineColor(),1)
            rightState:setVisible(true)
            -- 判断是否上阵
            if RoleData:getRoleById(teamheroID) then
                rightState:loadTexture(YISHANGZHENG)
            else
                rightState:loadTexture(WEISHANGZHEN)
            end
        else
            ShaderMgr:setGrayForWidget(itemcell2.awardBgImg)
            ShaderMgr:setGrayForWidget(itemcell2.awardImg)
            itemcell2.nameTx:setTextColor(COLOR_TYPE.GRAY)
            rightState:setVisible(false)
        end
    end

    widget:setContentSize(cc.size(bgSize.width,height))
    self.specialFateHeight = self.svHeight
    widget:setPosition(cc.p(15,innerContainerSize.height - self.svHeight))
    self.svHeight = self.svHeight + height

    self.specialFateWidget = widget
end

-- 缘分
function ChartInfoUI:genFateStayNight(height)
    local bgSize = self.bg:getContentSize()
    local innerContainerSize = self.sv:getInnerContainerSize()

	local widget = ccui.Widget:create()
    widget:setAnchorPoint(cc.p(0,1))
    self.sv:addChild(widget)
	
	local frame1 = ccui.ImageView:create('uires/ui/common/name_bg12.png')
	--frame:setScale9Enabled(true)
    frame1:ignoreContentAdaptWithSize(false)
    frame1:setContentSize(cc.size(216, 40))
	frame1:setAnchorPoint(cc.p(0, 1))
    frame1:setOpacity(126)
    frame1:setPosition(cc.p(0,height))
    widget:addChild(frame1)

	local title = self:genTitle(2)
	title:setPosition(cc.p(10,5))
    frame1:addChild(title)

    -- 缘分基本属性
    local frameHeight = 0
    local sh = 0
    --self:calFate()
    local fateatt =	self:getFateArr()
    local showStatus = nil
    if self.showType == ROLE_SHOW_TYPE.CHART then
        showStatus = true   -- 默认显示亮度，其余置灰
    end
	if #fateatt > 0 then
		local frame = ccui.ImageView:create('uires/ui/common/touming.png')
		frame:setScale9Enabled(true)
		frame:setAnchorPoint(cc.p(0, 0))
        frame:setPosition(cc.p(-5,25))

		for i = #fateatt, 1, -1 do
			local panel = fateUI:genFateStayNight(self.obj, i, nil,280,showStatus)
			panel:setName('frame' .. i)
			panel:setPositionY(sh)
			local regionRect = panel:getContentSize()
			sh = sh + regionRect.height

			panel:getChildByName('panel' .. i)
				:getChildByName('collapse')
				:setVisible(false)

			frame:addChild(panel)
			if i ~= 1 then
				local fengexian = ccui.ImageView:create('uires/ui/common/xian.png')
				fengexian:setName('fengexian' .. i)
				fengexian:setAnchorPoint(cc.p(0, 0))
				fengexian:ignoreContentAdaptWithSize(false)
				fengexian:setContentSize(cc.size(bgSize.width, 3))
				sh = sh + 5
				fengexian:setPositionY(sh)
				sh = sh + 3 + 5
				frame:addChild(fengexian)
                fengexian:setVisible(false)
			end
		end

		frameHeight = sh + 8
		frame:setContentSize(cc.size(bgSize.width, frameHeight))
        widget:addChild(frame)
    else
        widget:setVisible(false)
	end


    widget:setContentSize(cc.size(bgSize.width,height))
    self.fateHeight = self.svHeight
    widget:setPosition(cc.p(15,innerContainerSize.height - self.svHeight))
    self.svHeight = self.svHeight + height

    self.fateWidget = widget

end

--- 天赋
function ChartInfoUI:genTalent()
    local baseHeight = 25

    local bgSize = self.bg:getContentSize()
    local innerContainerSize = self.sv:getInnerContainerSize()

	local widget = ccui.Widget:create()
    widget:setAnchorPoint(cc.p(0,1))
    self.sv:addChild(widget)
	
	local frame1 = ccui.ImageView:create('uires/ui/common/name_bg12.png')
	--frame:setScale9Enabled(true)
    frame1:ignoreContentAdaptWithSize(false)
    frame1:setContentSize(cc.size(216, 40))
	frame1:setAnchorPoint(cc.p(0, 1))
    frame1:setOpacity(126)
    frame1:setPosition(cc.p(0,baseHeight))
    widget:addChild(frame1)

	local title = self:genTitle(3)
	title:setPosition(cc.p(10,5))
    frame1:addChild(title)



    -- 基本属性
	local rt = xx.RichText:create()
	rt:setAnchorPoint(cc.p(0, 0))
    rt:setContentSize(cc.size(bgSize.width, 40))
    rt:setPosition(cc.p(-5,-25))

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
    local labelheight = rt:getBrushY()
 	rt:setContentSize(cc.size(bgSize.width,labelheight))
    widget:addChild(rt)
    --print('ddddddddddddddd' .. labelheight)

    local height = baseHeight + labelheight

    widget:setContentSize(cc.size(bgSize.width,height))
    widget:setPosition(cc.p(15,innerContainerSize.height - self.svHeight + 35))

    frame1:setPosition(cc.p(8,height))
    title:setPosition(cc.p(10,5))
    rt:setPosition(cc.p(5,-25))

    self.tatentHeight = self.svHeight

    self.svHeight = self.svHeight + height

    self.tatentWidget = widget

end

function ChartInfoUI:getSkillIdTab()
	local skilltab ={}
	local skillgroup = self.cardData.skillGroupId[1]
	local skillgroupconf = GameData:getConfData("skillgroup")
	local skillgrouptab = skillgroupconf[skillgroup]
	local skillid1 = skillgrouptab['angerSkill']
	local skillid2 = skillgrouptab['autoSkill1']
	skilltab[1] = skillid2
	skilltab[2] = skillid1
	return skilltab
end

function ChartInfoUI:genTitle(idx)
    local str = 'SKILL_TEXT'
    if idx == 1 then
        str = 'SKILL_TEXT'
    elseif idx == 2 then
        str = 'YUANFUN_TEXT'
    elseif idx == 3 then
        str = 'TIANFU_TEXT'
    elseif idx == 4 then
        str = 'SPECIAL_FATE_TEXT'
    end
	local titletx = GlobalApi:getLocalStr(str)
	local title = cc.Label:createWithTTF(titletx, "font/gamefont.ttf", 28)
	title:setTextColor(cc.c3b(255,247,228))
	title:enableOutline(cc.c4b(78, 49, 17, 255), 2)
	title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
	title:setAnchorPoint(cc.p(0, 0))
	return title
end


--缘分展示数据
function ChartInfoUI:getFateArr(isGetActive)
	local arr = {}
	local heroconf = GameData:getConfData('hero')
	local fateconf = GameData:getConfData('fate')
	local attconf = GameData:getConfData('attribute')

	local currNum = 0
	local maxNum = 0
	local idx = 1
	for i=1,#self.fateinfoarr do
		local atttemp = {
			fid = nil,
			fname = nil,				-- 缘分名字
			roleStatus = {},			-- 相关武将状态 [1] = { hid = 1, active = true }
			effect1 = nil,				-- 效果1名字 [攻击]
			effvalue1 = nil,			-- 效果1值
			effect2 = nil,				-- 效果2名字
			effvalue2 = nil,			-- 效果2值
			isactive = false			-- 是否激活
		}

		atttemp.fid = self.fateinfoarr[i].fateid
		local fname = fateconf[tonumber(self.fateinfoarr[i].fateid)].name
		-- local str = ''
		for j = 1, 5 do
			local hid = tonumber(self.fateinfoarr[i].hidarr[j])
			if hid > 0 then
				local temp = {}
				temp.hid = hid
				local assign = RoleData:getRoleById(hid)
				local assist = self:isAsssist(atttemp.fid, hid)
				--temp.active = (assign ~= nil) or assist
                temp.active = false
				table.insert(atttemp.roleStatus, temp)
			end
		end
		-- str = string.sub(str,0,string.len(str)-3)
		local realeffect = false
		local atttab  = fateconf[tonumber(self.fateinfoarr[i].fateid)]['att'..self.fateinfoarr[i].index ..'1']
		local attvalue = fateconf[tonumber(self.fateinfoarr[i].fateid)]['value'..self.fateinfoarr[i].index ..'1']
		atttemp.fname = fname
		-- atttemp.hnamestr = str
		if atttab  and tonumber(atttab[1]) > 0 then
			if  #atttab > 1 then
				-- 当有多个属性的时候 只有可能是防御
				atttemp.effect1 = GlobalApi:getLocalStr('PROFESSION_NAME3')
			else
				atttemp.effect1 = attconf[tonumber(atttab[1])].name
			end	
			atttemp.effvalue1 = tostring(attvalue)
			realeffect = true
		end

        atttemp.isactive = false
		--atttemp.isactive = RoleData:isFateActive(self.fateinfoarr[i].fateid, self)
		local atttab2 = fateconf[tonumber(self.fateinfoarr[i].fateid)]['att'..self.fateinfoarr[i].index ..'2']
		local attvalue2 = fateconf[tonumber(self.fateinfoarr[i].fateid)]['value'..self.fateinfoarr[i].index ..'2']
		--if  tonumber(atttab2[1]) > 0 then
			if atttab2 and tonumber(atttab2[1]) > 0 then
				if #atttab2 > 1 then 
					atttemp.effect2 = GlobalApi:getLocalStr('PROFESSION_NAME3')
				else
					atttemp.effect2 = attconf[tonumber(atttab2[1])].name
				end
				atttemp.effvalue2 = tostring(attvalue2)
				realeffect = true
			end

		--end
		if realeffect then
			arr[idx] = atttemp
			maxNum = maxNum + 1
			idx = idx + 1
		end
		if atttemp.isactive then
			currNum = currNum + 1
		end
	end

	if isGetActive then
		return currNum,maxNum
	end
	self:sortByQuality(arr)
	return arr
end

function ChartInfoUI:isAsssist(fid, hid)
	fid = tonumber(fid)
	hid = tonumber(hid)
	if self.assist == nil or self.assist[fid] == nil then
		return false
	end

	for i, v in ipairs(self.assist[fid]) do
		if v == hid then
			return true
		end
	end

	return false
end


--缘分激活排序
function ChartInfoUI:sortByQuality(arr)
	table.sort(arr, function (a, b)
		local q1 = a.isactive
		local q2 = b.isactive
		if (q1 == true and q2 == true)  or (q1 == false and q2 == false ) then
			-- local f1 = a.fname
			-- local f2 = b.fname
			-- return f1 < f2
			return tonumber(a.fid) < tonumber(b.fid)
		elseif q1 == true and q2 == false then 
			return true
		elseif q1 == false and q2 == true then
			return false
		end
	end)
end

--计算缘分
function ChartInfoUI:calFate()
    self.fateinfoarr = {
		fateid = 0,
		index = 0,
		hidarr = {}
	}

	local fatearr = {}
	fatearr = self.cardData.fateGroup
	local fateconf = GameData:getConfData('fate')

	for i=1,#fatearr do
		local fatehidarr = {}
		local attidx = 0
		if tonumber(fatearr[i]) > 0 then
			local fateidconf = fateconf[tonumber(fatearr[i])]
			if tonumber(fatearr[i]) > 1000 then -- 主角缘分
				attidx = 1
				fatehidarr[1] = 0
				for j = 2, 5 do
					fatehidarr[j] = fateidconf['hid'..j]
				end
			else
				for j = 1, 5 do
					fatehidarr[j] = fateidconf['hid'..j]
					if fatehidarr[j] == self.cardData.id then
						attidx = j
						fatehidarr[j] = 0 
					end
				end
			end
			local fateatttemp ={
				fateid = 0,    --缘分id
				index = 0,	   --在缘分的第几个位置
				hidarr = {}    --激活需要上阵的武将
			}
			fateatttemp.fateid = fatearr[i]
			fateatttemp.index = attidx
			fateatttemp.hidarr = fatehidarr
			self.fateinfoarr[i] = fateatttemp
		end
	end
end

return ChartInfoUI