local TavernLimitUI = class("TavernLimitUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local girl_ani_pos = cc.p(120 - 206, 50 - 15)

local ClassRoleObj  =require('script/app/obj/roleobj')

local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}

function TavernLimitUI:ctor()
	self.uiIndex = GAME_UI.UI_TAVEN_LIMIT_PANNEL
    self:initData()
    self.actionisruning = false

end

function TavernLimitUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    self.bgimg = bgimg
    self.bgimg1 = bgimg:getChildByName("bg_img1")

	local winSize = cc.Director:getInstance():getWinSize()
	bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    local helpBtn = HelpMgr:getBtn(18)
    --btn:setScale(0.7)
    helpBtn:setPosition(cc.p(40, winSize.height - 40))
    self.root:addChild(helpBtn)

    -- 关闭
	local closebtn = self.root:getChildByName('close_btn')
	closebtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				TavernMgr:hideTavernLimitUI()
                TavernMgr:UpdateTavernLimitUI()
			end
	end)
	closebtn:setPosition(cc.p(winSize.width,winSize.height - 15))
    -- 图鉴
	local chartBtn = self.root:getChildByName('chart_btn')
	chartBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				ChartMgr:showChartMain(2)
			end
	end)
	chartBtn:setPosition(cc.p(winSize.width - 100,90))
    --chartBtn:setVisible(false)

    local buyImg = self.bgimg1:getChildByName('buy_img')
    buyImg:getChildByName('txt_cost'):setString(tonumber(GlobalApi:getGlobalValue('tavernHotRefreshCost')))

    local refreshBtn = self.bgimg1:getChildByName('refresh_btn')
    --refreshBtn:setPosition(cc.p(winSize.width - 130,80))
    refreshBtn:setTouchEnabled(true)
    refreshBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            
            local openLimit = GlobalApi:getPrivilegeById("tavernLimit")
            -- vip限制
            local vipLimitLv = GlobalApi:getGlobalValue('tavernHotVIPRequire')
            if UserData:getUserObj():getVip() < tonumber(vipLimitLv) and (not openLimit) then            
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("TAVERN_VIP_LIMIT_DES2"),vipLimitLv), COLOR_TYPE.RED)
                return
            end

            local function sendToServer()
				MessageMgr:sendPost('refresh_hot','tavern',json.encode({}),function (response)	
					local code = response.code
					if code == 0 then
                        local costs = response.data.costs
					    if costs then
					        GlobalApi:parseAwardData(costs)
					    end

                        TavernMgr.tavenLimitData.limitHot = response.data.limitHot
                        TavernMgr.tavenLimitData.dayHots = response.data.dayHots

                        self.tavenLimitData.limitHot = response.data.limitHot
                        self.tavenLimitData.dayHots = response.data.dayHots

						self:refreshRole()
					end
				end)
		    end

            local cost= tonumber(GlobalApi:getGlobalValue('tavernHotRefreshCost'))
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH4'),cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                local hasCash = UserData:getUserObj():getCash()
                if hasCash >= cost then
                    sendToServer()
                else
                    promptmgr:showMessageBox(
				    GlobalApi:getLocalStr('STR_CASH')..GlobalApi:getLocalStr('NOT_ENOUGH')..'，'..GlobalApi:getLocalStr('STR_CONFIRM_TOBUY') .. GlobalApi:getLocalStr('STR_CASH') .. '？',
				    MESSAGE_BOX_TYPE.MB_OK_CANCEL,
				    function ()
					    GlobalApi:getGotoByModule('cash')
				    end)
                end

            end)

        end
    end)

    --self:initTop()
    self:refreshRole()
    --self:initTalkBg()
    --self:initRight()
    --self:refresh()


    -- spine动画
	self.bgimg1:getChildByName('nv_img')
		:setTouchEnabled(false)
		:setVisible(false)

	local layout = ccui.Layout:create()
	layout:setName('layout')
	layout:setContentSize(cc.size(412, 417))
	local girl_ani = GlobalApi:createSpineByName("ui_tavern_girl", "spine/ui_tavern_girl/ui_tavern_girl", 1)
	girl_ani:setName('girl_ani')
	girl_ani:setPosition(cc.p(206, 15))
	layout:addChild(girl_ani)
	layout:setPosition(girl_ani_pos)
	layout:setTouchEnabled(true)
	layout:addClickEventListener(function (  )
		girl_ani:setAnimation(0, 'idle01', false)

        if self.girlEffectId then
            AudioMgr.stopEffect(self.girlEffectId)
        end

        -- self.girlEffectId = AudioMgr.playEffect('media/effect/tavern_girl_0'.. GlobalApi:random(1, 3) ..'.mp3', false)
	end)

	self.bgimg1:addChild(layout)
	girl_ani:setAnimation(0, 'idle', true)
    girl_ani:registerSpineEventHandler(function (  )
		girl_ani:setAnimation(0, 'idle', true)
	end, sp.EventType.ANIMATION_COMPLETE)

    -- self.effectId = AudioMgr.playEffect('media/effect/tavern_enter_0'.. GlobalApi:random(1, 4) ..'.mp3', false)

end

function TavernLimitUI:setRoleAni()
    -- 武将模型
    local heroConf = GameData:getConfData("hero")
    local data = self.tavernHotConf[self.tavenLimitData.limitHot]
    local awards = DisplayData:getDisplayObjs(data.award1)
    local roleId = awards[1]:getId()
    local cardData = heroConf[roleId]


    local anmPl = self.bgimg1:getChildByName('anm_pl')
    local roleBottomImg = anmPl:getChildByName('role_bottom_img')
    if cardData.quality == 6 then
        roleBottomImg:loadTexture('uires/ui/common/tab_red.png')
    elseif cardData.quality == 5 then
        roleBottomImg:loadTexture('uires/ui/common/tab_yellow.png')
    elseif cardData.quality == 4 then
        roleBottomImg:loadTexture('uires/ui/common/tab_purple.png')
    else
        roleBottomImg:setVisible(false)
    end

    if anmPl:getChildByTag(9527) then
        anmPl:removeChildByTag(9527)
    end

    local spineAni = GlobalApi:createLittleLossyAniByName(cardData.url .. "_display")
	if spineAni then
	    spineAni:setScale(1.1)
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
		spineAni:setPosition(cc.p(anmPl:getContentSize().width/2,60+cardData.uiOffsetY))
		spineAni:setLocalZOrder(999)
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
                    self.startBtn:setTouchEnabled(false)
                    ChartMgr:showChartInfo(cardData,ROLE_SHOW_TYPE.NORMAL)
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
end

function TavernLimitUI:swapanimation(spineAni)
	-- local seed = math.random(1, 5)
	-- if self.action ~= roleanim[seed] then
	-- 	self.action = roleanim[seed]
	-- 	spineAni:getAnimation():play(roleanim[seed], -1, -1)
	-- end
end

function TavernLimitUI:onShow()
    self.startBtn:setTouchEnabled(true)
end


function TavernLimitUI:onHide()
	self.bgimg1:getChildByName('layout')
		:getChildByName('girl_ani')
		:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)

    if self.girlEffectId then
        AudioMgr.stopEffect(self.girlEffectId)
    end

    if self.effectId then
        AudioMgr.stopEffect(self.effectId)
    end

end

function TavernLimitUI:initData()
	self.tavernHotConf = GameData:getConfData("tavernhot")
    self.tavenLimitData = TavernMgr:getTavenLimitData()

end

function TavernLimitUI:refreshRole()
    self:initTop()
    self:initRight()
    self:setRoleAni()
    self:initTalkBg()
    self:refresh()
end

function TavernLimitUI:initTop()
	local topBg = self.bgimg:getChildByName("top_bg")
    local desc1 = topBg:getChildByName("desc1")
    desc1:setString(GlobalApi:getLocalStr('TAVEN_LIMIT_DES1'))

    local desc2 = topBg:getChildByName("desc2")
    desc2:setString(GlobalApi:getLocalStr('TAVEN_LIMIT_DES2'))

    local desc3 = topBg:getChildByName("desc3")
    desc3:setString(GlobalApi:getLocalStr('TAVEN_LIMIT_DES3'))

    local heroConf = GameData:getConfData("hero")
    -- 刷新时间
    local remainTime = topBg:getChildByName("remain_time")
    self:timeoutCallback(remainTime,self.tavenLimitData.nextUpdate)

    -- 下期限时热点
    local nextRoleName = topBg:getChildByName("next_role_name")
    local nextId = TavernMgr:getNextId()
    local nextData = self.tavernHotConf[nextId]
    local nextAwards = DisplayData:getDisplayObjs(nextData.award1)
    local nextRoleId = nextAwards[1]:getId()
    local nextHeroData = heroConf[nextRoleId]
    nextRoleName:setString(nextHeroData.heroName)

    -- 招募必得和概率必得(富文本)
    local data = self.tavernHotConf[self.tavenLimitData.limitHot]
    local awards = DisplayData:getDisplayObjs(data.award1)        -- 目前配置表只有一项
    local roleId = awards[1]:getId()
    local heroData = heroConf[roleId]
    local heroName = heroData.heroName

    if topBg:getChildByName('top_richtext') then
        topBg:removeChildByName('top_richtext')
    end

    local richText = xx.RichText:create()
    richText:setName('top_richtext')
	richText:setContentSize(cc.size(530, 40))
	local re1 = xx.RichTextLabel:create(heroName .. GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES1'), 34, COLOR_TYPE.RED)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES2'), 28, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')
	local re3 = xx.RichTextLabel:create(heroName .. GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES3'), 28, COLOR_TYPE.RED)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES4'), 28, COLOR_TYPE.WHITE)
	re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re4:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
	richText:addElement(re4)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(desc1:getPositionX() + 3,desc1:getPositionY() + 2))
	topBg:addChild(richText)
    
end

function TavernLimitUI:initTalkBg()
	local talkBg = self.bgimg:getChildByName("talk_bg")

    local buyImg = talkBg:getChildByName("buy_img")
    self.buyImg = buyImg
    local cost = buyImg:getChildByName("txt_cost")
    self.cost = cost
    local free = talkBg:getChildByName("free")
    free:setString(GlobalApi:getLocalStr('FREE_TIME'))
    self.free = free

    -- 招募按钮
    local startBtn = talkBg:getChildByName('start_btn')
	startBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then

            local openLimit = GlobalApi:getPrivilegeById("tavernLimit")
            -- vip限制
            local vipLimitLv = GlobalApi:getGlobalValue('tavernHotVIPRequire')
            if UserData:getUserObj():getVip() < tonumber(vipLimitLv)  and (not openLimit) then     
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("TAVERN_VIP_LIMIT_DES"),vipLimitLv), COLOR_TYPE.RED)
                return
            end

            local function callBack(awards)
                local temp = {}
                for i = 1,6 do
                    if awards[i][1] == 'card' then
                        table.insert(temp,awards[i])
                    end
                end
                for i = 1,6 do
                    if awards[i][1] == 'card' then   
                    else
                        table.insert(temp,awards[i])
                    end
                end
                TavernMgr:showTavernLimitAwardUI('cash',temp)
                self.startBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('TAVEN_LIMIT_DES4'))
            end
		    TavernMgr:buyHot('cash',callBack)
		end
	end)
    startBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('TAVEN_LIMIT_DES4'))
    self.startBtn = startBtn
    
    local imgVip = startBtn:getChildByName('img_vip')
    local descStart = startBtn:getChildByName('desc_start')
    descStart:setString(GlobalApi:getLocalStr('TAVEN_CAN_START2'))
    
    local openLimit = GlobalApi:getPrivilegeById("tavernLimit")
    local vipLimitLv = tonumber(GlobalApi:getGlobalValue('tavernHotVIPRequire'))
    if startBtn:getChildByName('vipLabel') then
        startBtn:removeChildByName('vipLabel')
    end
    local vipLabel = cc.LabelAtlas:_create(vipLimitLv, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
    vipLabel:setName('vipLabel')
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setScale(1)
    vipLabel:setPosition(cc.p(imgVip:getPositionX() + 2,imgVip:getPositionY()))
    startBtn:addChild(vipLabel)

    if UserData:getUserObj():getVip() < tonumber(vipLimitLv) and (not openLimit) then
        imgVip:setVisible(true)
        descStart:setVisible(true)
        vipLabel:setVisible(true)
        startBtn:getChildByName('inputbtn_text'):setVisible(false)
    else
        imgVip:setVisible(false)
        descStart:setVisible(false)
        vipLabel:setVisible(false)
        startBtn:getChildByName('inputbtn_text'):setVisible(true)
    end
    
    -- 碎片显示
    if talkBg:getChildByName('talk_richtext') then
        talkBg:removeChildByName('talk_richtext')
    end

    local heroConf = GameData:getConfData("hero")
    local itemConf = GameData:getConfData("item")
    local data = self.tavernHotConf[self.tavenLimitData.limitHot]
    local awards = DisplayData:getDisplayObjs(data.award1)        -- 目前配置表只有一项
    local roleId = awards[1]:getId()
    local heroData = heroConf[roleId]
    local heroName = heroData.heroName

    local richText = xx.RichText:create()
    richText:setName('talk_richtext')
	richText:setContentSize(cc.size(600, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES5'), 28, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(heroName .. GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES1'), 28, COLOR_TYPE.RED)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')

	local re3 = xx.RichTextLabel:create('', 28, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(365,95))
	talkBg:addChild(richText)

    self.fragramentRe3 = re3
    self.richText = richText

    -- 爱心招募
    local tavernCostLoveNum = tonumber(GlobalApi:getGlobalValue('tavernCostLoveNum'))
    local loveBtn = talkBg:getChildByName('love_btn')
	loveBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            local function callBack(awards)
                local temp = {}
                for i = 1,6 do
                    if awards[i][1] == 'card' then
                        table.insert(temp,awards[i])
                    end
                end
                for i = 1,6 do
                    if awards[i][1] == 'card' then   
                    else
                        table.insert(temp,awards[i])
                    end
                end
                TavernMgr:showTavernLimitAwardUI('love',temp)
            end
		    TavernMgr:buyHot('love',callBack)
		end
	end)
    loveBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('TAVEN_LIMIT_DES4'))
    self.loveBtn = loveBtn

    local loveImg = talkBg:getChildByName('love_img')
    local loveTxtCost = loveImg:getChildByName('txt_cost')
    loveTxtCost:setString(tavernCostLoveNum)
    self.loveTxtCost = loveTxtCost
end

function TavernLimitUI:initRight()
	local rightBg = self.bgimg:getChildByName("right_bg")
    
    local desc1 = rightBg:getChildByName("desc1")
    desc1:setString(GlobalApi:getLocalStr('TAVEN_CAN_GET_DES1'))

    local desc2 = rightBg:getChildByName("desc2")
    desc2:setString(GlobalApi:getLocalStr('TAVEN_CAN_GET_DES2'))

    local desc3 = rightBg:getChildByName("desc3")
    desc3:setString("，")

    local desc4 = rightBg:getChildByName("desc4")
    desc4:setString(GlobalApi:getLocalStr('TAVEN_CAN_GET_DES2'))

    local desc5 = rightBg:getChildByName("desc5")
    desc5:setString(GlobalApi:getLocalStr('TAVEN_CAN_GET_DES3'))

    local desc6 = rightBg:getChildByName("desc6")
    desc6:setString(GlobalApi:getLocalStr('TAVEN_SPECIAL_DES2'))

    local desc7 = rightBg:getChildByName("desc7")
    desc7:setString("。")

    -- 将星兑换
	local exchange = rightBg:getChildByName('img4')
    exchange:setTouchEnabled(true)
	exchange:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then

            local openLimit = GlobalApi:getPrivilegeById("tavernLimit")
            -- vip限制
            local vipLimitLv = GlobalApi:getGlobalValue('tavernHotVIPRequire')
            if UserData:getUserObj():getVip() < tonumber(vipLimitLv) and (not vipLimitLv) then            
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("TAVERN_LIMIT_GET_DES8"),vipLimitLv), COLOR_TYPE.RED)
                return
            end

            local haveLuckValue = UserData:getUserObj():getTavenLuck()
            local costLuckValue = TavernMgr:exchangeCostLuckValue()
            if haveLuckValue < costLuckValue then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("TAVERN_EXCHANGE_LUCK_NOT_ENOUGH"), COLOR_TYPE.RED)
            else
                TavernMgr:showTavernExchangeUI()
            end
			
		end
	end)

    -- 热点武将
    for i = 1,3 do
        local frame = rightBg:getChildByName("frame" .. i)
        if frame:getChildByName('award_bg_img') then
            frame:removeChildByName('award_bg_img')
        end
    end

    local heroConf = GameData:getConfData("hero")
    local dayHots = self.tavenLimitData.dayHots
    for i = 1,3 do
        local frame = rightBg:getChildByName("frame" .. i)
        local hotData = self.tavernHotConf[dayHots[i]]
        if hotData.award1 then
            local awards = DisplayData:getDisplayObjs(hotData.award1)
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[1], frame)
            cell.lvTx:setVisible(false)
            awards[1]:setLightEffect(cell.awardBgImg)
            local name = cc.Label:createWithTTF('', 'font/gamefont.ttf', 26)
			name:setAnchorPoint(cc.p(0.5, 0.5))
			name:setPosition(cc.p(47, -18.25))
            name:setString(awards[1]:getName())
            name:setColor(awards[1]:getNameColor())
            name:enableOutline(awards[1]:getNameOutlineColor(),1)
            name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            cell.awardBgImg:addChild(name)
            cell.awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if awards[1]:getType() == 'card' or awards[1]:getType() == 'fragment' then
                        self.startBtn:setTouchEnabled(false)
                        local heroConf = GameData:getConfData("hero")
                        local roleId = awards[1]:getId()
                        local cardData = heroConf[roleId]
                        ChartMgr:showChartInfo(cardData,ROLE_SHOW_TYPE.NORMAL)
                    else
                        GetWayMgr:showGetwayUI(awards[1],false)
                    end
                end
            end)
        end
    end
    -- 进度条
    local expBg = rightBg:getChildByName("exp_bg")
    local expBar = expBg:getChildByName("exp_bar")
    local expVal = expBar:getChildByName("exp_val")
    expBar:setScale9Enabled(true)
    expBar:setCapInsets(cc.rect(10,15,1,1))
    self.expBar = expBar
    self.expVal = expVal
end

function TavernLimitUI:timeoutCallback(parent ,time)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	local node = cc.Node:create()
	node:setTag(9527)	 
	node:setPosition(cc.p(0,0))
	parent:removeChildByTag(9527)
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,0),cc.c4b(0,0,0,255),CDTXTYPE.FRONT, nil,nil,nil,26,function ()
		if diffTime <= 0 then
			parent:removeAllChildren()
			--parent:setString('')
		else
			self:timeoutCallback(parent ,time)
		end
	end)
end

--- 刷新将星值和碎片
function TavernLimitUI:refresh()
    -- 将星值
	local havaNum = UserData:getUserObj():getTavenLuck()
    local allNum = TavernMgr:getExchangeCostMaxLuckValue()
    if havaNum >= tonumber(allNum) then
        self.expBar:setPercent(100)
    else
        self.expBar:setPercent(100 * havaNum/tonumber(allNum))
    end

    self.expVal:setString(string.format(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES7'),havaNum,allNum))

    -- 碎片
    local itemConf = GameData:getConfData("item")
    local data = self.tavernHotConf[self.tavenLimitData.limitHot]
    local awards = DisplayData:getDisplayObjs(data.award1)        -- 目前配置表只有一项
    local roleId = awards[1]:getId()

    local fragmentItem = BagData:getFragmentById(roleId) -- 这个也是碎片的id
    local num = 0
    if fragmentItem then
        num = fragmentItem:getNum()
    end
    local needNum = itemConf[roleId].mergeNum
    local str = string.format(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES6'),num,needNum)
    self.fragramentRe3:setString(str)
    self.richText:format(true)

    -- 判断是否本次免费
    local cost = self.cost
    cost:setString(GlobalApi:getGlobalValue('tavernHotCashCost'))
    if UserData:getUserObj():getCash() >= tonumber(GlobalApi:getGlobalValue('tavernHotCashCost')) then
		cost:setTextColor(cc.c3b(255,249,243)) -- 白色
		cost:enableOutline(cc.c4b(0,0,0,255),2)
	else
		cost:setTextColor(cc.c3b(255,0,0)) -- 红色
		cost:enableOutline(cc.c4b(65,8,8,255),2)
	end

    if UserData:getUserObj():judgeTavenLimitState() == true then
        cost:setString('0')
        cost:setTextColor(cc.c3b(255,249,243))
		cost:enableOutline(cc.c4b(0,0,0,255),2)

        self.free:setVisible(false)
        --self.buyImg:setVisible(false)
        self.startBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('FREE_TIME'))
    else
        self.free:setVisible(false)
        --self.buyImg:setVisible(true)
    end

    local tavernCostLoveNum = tonumber(GlobalApi:getGlobalValue('tavernCostLoveNum'))
    local userLove = UserData:getUserObj():getLove()
    if userLove >= tavernCostLoveNum then
		self.loveTxtCost:setTextColor(cc.c3b(255,249,243)) -- 白色
		self.loveTxtCost:enableOutline(cc.c4b(0,0,0,255),2)
	else
		self.loveTxtCost:setTextColor(cc.c3b(255,0,0)) -- 红色
		self.loveTxtCost:enableOutline(cc.c4b(65,8,8,255),2)
	end
end



return TavernLimitUI