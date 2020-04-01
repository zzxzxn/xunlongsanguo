local TavernUI = class("TavernUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')

local girl_ani_pos = cc.p(120 - 206, 50 - 15)

function TavernUI:ctor()
	self.uiIndex = GAME_UI.UI_TAVERN
    self:initData()
end

function TavernUI:init()
    local bgimg = self.root:getChildByName("bg_img")
	self.bgimg1 = bgimg:getChildByName('bg_img1')

	local winSize = cc.Director:getInstance():getWinSize()
	bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    -- 关闭
	local closebtn = self.root:getChildByName('close_btn')
	closebtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				TavernMgr:hideTavernMain()
			end
	end)
	closebtn:setPosition(cc.p(winSize.width,winSize.height - 15))
    -- 图鉴
	local chartBtn = self.root:getChildByName('chart_btn')
	chartBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				ChartMgr:showChartMain(1)
			end
	end)
	chartBtn:setPosition(cc.p(winSize.width - 100,130))

    -- 酒馆招募活动
    local tavernRcruitBtn = ccui.ImageView:create('uires/ui/tavern/tavern_zhaomuhuodong.png')
    tavernRcruitBtn:setTouchEnabled(true)
    --tavernRcruitBtn:setVisible(false)
	self.root:addChild(tavernRcruitBtn)		
    tavernRcruitBtn:setPosition(cc.p(120,winSize.height - 100))
    tavernRcruitBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            tavernRcruitBtn:setScale(1.1)
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            tavernRcruitBtn:setScale(1)
			if UserData:getUserObj():getActivityStatus('tavern_recruit') == true then
                ActivityMgr:showActivityPage('tavern_recruit')
                return
            end
            if UserData:getUserObj():getActivityStatus('tavern_recruit_level') == true then
                ActivityMgr:showActivityPage('tavern_recruit_level')
                return
            end
		end
	end)

    if UserData:getUserObj():getActivityStatus('tavern_recruit') == false and UserData:getUserObj():getActivityStatus('tavern_recruit_level') == false then
        tavernRcruitBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(tavernRcruitBtn)
    end

    -- 底部talk
	local talkbg = bgimg:getChildByName('talk_bg')
	talkbg:setPosition(cc.p(150+(winSize.width-960)/2,84))
	local tx1 = talkbg:getChildByName('tx_1')
	tx1:setString('')
	local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRVEN_DESC_8'), 25, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.PALE, 1)
	re1:setShadow(COLOROUTLINE_TYPE.PALE, cc.size(0, -2))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRVEN_DESC_10'), 25, COLOR_TYPE.YELLOW)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	re2:setShadow(COLOROUTLINE_TYPE.PALE, cc.size(0, -2))
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRVEN_DESC_9'), 25, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.PALE, 1)
	re3:setShadow(COLOROUTLINE_TYPE.PALE, cc.size(0, -2))
    re3:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
		
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(0,0))
	tx1:addChild(richText,9527)
	richText:setVisible(true)

	local tx2 = talkbg:getChildByName('tx_2')
	tx2:setString(GlobalApi:getLocalStr('TRVEN_DESC_7'))
	self:upDatenorpl()
	self:upDategoldpl()
    self:upLimitAward()

	-- spine动画
	-- self.bgimg1:getChildByName('nv_img')
	-- 	:setTouchEnabled(false)
	-- 	:setVisible(false)

	-- local layout = ccui.Layout:create()
	-- layout:setName('layout')
	-- layout:setContentSize(cc.size(412, 417))
	-- -- layout:setAnchorPoint(cc.p(0.5, 0.5))
	-- -- layout:setBackGroundColorType(ccui.LayoutBackGroundColorType.solid)
	-- -- layout:setBackGroundColor(cc.c4b(255, 0, 0, 255))
	-- local girl_ani = GlobalApi:createSpineByName("ui_tavern_girl", "spine/ui_tavern_girl/ui_tavern_girl", 1)
	-- girl_ani:setName('girl_ani')
	-- girl_ani:setPosition(cc.p(206, 15))
	-- layout:addChild(girl_ani)
	-- layout:setPosition(girl_ani_pos)
	-- layout:setTouchEnabled(true)
	-- layout:addClickEventListener(function (  )
	-- 	girl_ani:setAnimation(0, 'idle01', false)

 --        if self.girlEffectId then
 --            AudioMgr.stopEffect(self.girlEffectId)
 --        end

 --        self.girlEffectId = AudioMgr.playEffect('media/effect/tavern_girl_0'.. GlobalApi:random(1, 3) ..'.mp3', false)
 --        --print('dsfsafdsafdsafsafds' .. value)
	-- end)

	-- self.bgimg1:addChild(layout)
	-- girl_ani:setAnimation(0, 'idle', true)
 --    girl_ani:registerSpineEventHandler(function (  )
	-- 	girl_ani:setAnimation(0, 'idle', true)
	-- end, sp.EventType.ANIMATION_COMPLETE)

    -- self.effectId = AudioMgr.playEffect('media/effect/tavern_enter_0'.. GlobalApi:random(1, 4) ..'.mp3', false)

    local btn = HelpMgr:getBtn(48)
    btn:setScale(1)
    closebtn:addChild(btn)
    btn:setPosition(cc.p(-25,50))
    
end

function TavernUI:initData()
    self.tavern = UserData:getUserObj():getTaverninfo()
    self.girlEffectId = nil
end

function TavernUI:onHide()
	-- self.bgimg1:getChildByName('layout')
		-- :getChildByName('girl_ani')
		-- :unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)

    if self.girlEffectId then
        AudioMgr.stopEffect(self.girlEffectId)
    end

    if self.effectId then
        AudioMgr.stopEffect(self.effectId)
    end

end

function TavernUI:timeoutCallback(parent ,time)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
	parent:removeChildByTag(9527)
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.BACK, GlobalApi:getLocalStr('TRVEN_DESC_1'),cc.c3b(255,255,255),cc.c4b(0,0,0,255),30,function ()
		if diffTime <= 0 then
			parent:removeAllChildren()
			--parent:setString(GlobalApi:getLocalStr('FREE_TIME'))
		else
			self:timeoutCallback(parent ,time)
		end
	end)
end

function TavernUI:upDatenorpl()
	local freeTavernPerDay = GlobalApi:getGlobalValue('freeTavernPerDay')	 	 --每天免费招募次数
	local freeTavernInterval = GlobalApi:getGlobalValue('freeTavernInterval')		 --普通招募免费间隔分钟数
	local pl = self.bgimg1:getChildByName('tavern_1_bg')
	local newImg = pl:getChildByName('new_img')
	newImg:setVisible(UserData:getUserObj():getSignByType('tavern_free'))
	pl:setLocalZOrder(50)
	pl:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			self:recuit(1)
		end
	end)

	local tavernicon = pl:getChildByName('trvern_icon')
	local numbg = pl:getChildByName('num_bg')
	local numicon = pl:getChildByName('num_icon')
	numicon:ignoreContentAdaptWithSize(true)
	local numtx = pl:getChildByName('num_tx')
	numtx:setFontName('font/gamefont.ttf')
	numtx:setString('1')
	numtx:setFontSize(43)
	if UserData:getUserObj():getnToken() < 1 then
		numtx:setTextColor(cc.c3b(255,0,0))
		numtx:enableOutline(cc.c4b(65,8,8,255),1)
	else
		numtx:setTextColor(cc.c3b(255,255,255))
		numtx:enableOutline(cc.c4b(0,0,0,255),1)
	end

	local diffTime = 0
	if self.tavern.ntime ~= 0 then
		diffTime = self.tavern.ntime - GlobalData:getServerTime()
	end
	local desc1 = pl:getChildByName('desc_1')
	desc1:setString(GlobalApi:getLocalStr('FREE_TIMES')..tostring(freeTavernPerDay - self.tavern.nfree)..GlobalApi:getLocalStr('FREE_TIMES_DESC'))
	local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')

	if diffTime > 0 and diffTime <= freeTavernInterval*60 then
		self:timeoutCallback(desc3,self.tavern.ntime)
		desc1:setVisible(true)
	elseif diffTime > freeTavernInterval*60 then
		desc1:removeAllChildren()
		-- desc3:setString('')
		desc1:setVisible(true)
		desc1:setString(GlobalApi:getLocalStr('FREE_TIMES')..tostring(0)..GlobalApi:getLocalStr('FREE_TIMES_DESC'))
	elseif diffTime <= 0 then
		desc1:removeAllChildren()
		desc1:setVisible(true)
		if freeTavernPerDay - self.tavern.nfree > 0 then
			numtx:setFontSize(28)
			numtx:setTextColor(cc.c3b(255,255,255))
			numtx:enableOutline(cc.c4b(0,0,0,255),1)
			numtx:setFontName('font/gamefont.ttf')
			numtx:setString(GlobalApi:getLocalStr('FREE_TIME'))
		end
		-- desc3:setString(GlobalApi:getLocalStr('FREE_TIME'))
		-- desc3:setString('kkkkkkkkkk')
	end
end

function TavernUI:upDategoldpl()
	local advTavernInterval = GlobalApi:getGlobalValue('advTavernInterval')		 --高级招募免费间隔小时数
	local tavernCashCost = GlobalApi:getGlobalValue('tavernCashCost')			 --高级招募消耗元宝数
	--local tavernPurpleCount = GlobalApi:getGlobalValue('tavernPurpleCount')		 --高级招募必得紫卡的次数
	local tavernOrangeCount = GlobalApi:getGlobalValue('tavernOrangeCount')		 --高级招募必得橙卡的次数

	local pl = self.bgimg1:getChildByName('tavern_2_bg')
	local newImg = pl:getChildByName('new_img')
	newImg:setVisible(UserData:getUserObj():getSignByType('tavern_ten'))
	pl:setLocalZOrder(51)
	pl:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
			TavernMgr:showTavernTenUI()
		end
	end)
	local tavernicon = pl:getChildByName('trvern_icon')
	local numbg = pl:getChildByName('num_bg')
	local numicon = pl:getChildByName('num_icon')
	numicon:ignoreContentAdaptWithSize(true)
	local numtx = pl:getChildByName('num_tx')
	numtx:setFontSize(43)
	numtx:setFontName('font/gamefont.ttf')
	if UserData:getUserObj():gethToken() > 0 then
		numicon:loadTexture('uires/icon/user/recruit2.png')
		numtx:setString('1')
		numtx:setTextColor(cc.c3b(255,249,243))
		numtx:enableOutline(cc.c4b(0,0,0),2)
	else
		numicon:loadTexture('uires/icon/user/cash.png')
		numtx:setString(tonumber(tavernCashCost))
		if UserData:getUserObj():getCash() >= tonumber(tavernCashCost) then
			numtx:setTextColor(cc.c3b(255,249,243))
			numtx:enableOutline(cc.c4b(0,0,0,255),2)
		else
			numtx:setTextColor(cc.c3b(255,0,0))
			numtx:enableOutline(cc.c4b(65,8,8,255),2)
		end
	end

	local desc1 = pl:getChildByName('desc_1')
	local desc2 = pl:getChildByName('desc_2')
	local desc4 = pl:getChildByName('desc_4')
	desc4:setString(GlobalApi:getLocalStr('TRVEN_DESC_5'))
	if tavernOrangeCount - self.tavern.hcount%10-1 == 0 then
		desc1:setVisible(false)
		desc2:setVisible(false)
		desc4:setVisible(true)
	else
		desc4:setVisible(false)
		desc2:setVisible(true)
		desc1:setVisible(true)
		desc1:setString(GlobalApi:getLocalStr('TRVEN_DESC_6'))
		desc2:setString(tostring(tavernOrangeCount - self.tavern.hcount%10-1))
	end

	local desc3 = pl:getChildByName('desc_3')
	desc3:setString('')
	local diffTime = 0
	if self.tavern.htime ~= 0 then
		diffTime = (self.tavern.htime - GlobalData:getServerTime())
	end
	if diffTime > 0 then
		desc3:setVisible(true)
		self:timeoutCallback(desc3,self.tavern.htime)
	else
		desc3:removeAllChildren()
		desc3:setVisible(false)
		numtx:setFontSize(28)
		numtx:setTextColor(cc.c3b(255,255,255))
		numtx:enableOutline(cc.c4b(0,0,0,255),1)
		numtx:setFontName('font/gamefont.ttf')
		numtx:setString(GlobalApi:getLocalStr('FREE_TIME'))
		-- desc3:setString(GlobalApi:getLocalStr('FREE_TIME'))
	end
end

function TavernUI:upLimitAward()
    local pl = self.bgimg1:getChildByName('tavern_3_bg')
	local newImg = pl:getChildByName('new_img')
    newImg:setVisible(UserData:getUserObj():getSignByType('tavern_limit'))

    local roleIcon = pl:getChildByName('trvern_icon') -- 武将，到时根据是哪个热点读取
    if TavernMgr:getTavenLimitData().limitHot then
        local tavernHotConf = GameData:getConfData("tavernhot")[TavernMgr:getTavenLimitData().limitHot]
        if tavernHotConf.icon then
            roleIcon:loadTexture('uires/icon/tavern/' .. tavernHotConf.icon .. '.png')
        end
    end

    local numicon = pl:getChildByName('num_icon')
	numicon:ignoreContentAdaptWithSize(true)
    numicon:loadTexture('uires/icon/user/cash.png')

    local numtx = pl:getChildByName('num_tx')
    numtx:setFontSize(43)
	numtx:setFontName('font/gamefont.ttf')
    numtx:setString(GlobalApi:getGlobalValue('tavernHotCashCost'))
    if UserData:getUserObj():getCash() >= tonumber(GlobalApi:getGlobalValue('tavernHotCashCost')) then
		numtx:setTextColor(cc.c3b(255,249,243)) -- 白色
		numtx:enableOutline(cc.c4b(0,0,0,255),2)
	else
		numtx:setTextColor(cc.c3b(255,0,0)) -- 红色
		numtx:enableOutline(cc.c4b(65,8,8,255),2)
	end

    local des1 = pl:getChildByName('des1')
    local des2 = pl:getChildByName('des2')
    des1:setString(GlobalApi:getLocalStr('TAVEN_SPECIAL_DES1'))
    des2:setString(GlobalApi:getLocalStr('TAVEN_SPECIAL_DES2'))


    local descFreeTime = pl:getChildByName('desc_free_time') -- 本次免费
    local imgVip = pl:getChildByName('img_vip')
    local descStart = pl:getChildByName('desc_start')
    
    local vipLimitLv = GlobalApi:getGlobalValue('tavernHotVIPRequire')
    if pl:getChildByName('vipLabel') then
        pl:removeChildByName('vipLabel')
    end
    local vipLabel = cc.LabelAtlas:_create(vipLimitLv, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
    vipLabel:setName('vipLabel')
    vipLabel:setAnchorPoint(cc.p(0, 0.5))
    vipLabel:setScale(1.5)
    vipLabel:setPosition(cc.p(imgVip:getPositionX() + 5,imgVip:getPositionY()))
    pl:addChild(vipLabel)

    local openLimit = GlobalApi:getPrivilegeById("tavernLimit")
    if UserData:getUserObj():getVip() < tonumber(vipLimitLv) and (not openLimit) then
        descFreeTime:setVisible(false)
        imgVip:setVisible(true)
        descStart:setVisible(true)
        vipLabel:setVisible(true)
        descStart:setString(GlobalApi:getLocalStr('TAVEN_CAN_START'))

    else
        descFreeTime:setVisible(true)
        imgVip:setVisible(false)
        descStart:setVisible(false)
        vipLabel:setVisible(false)

        -- 判断是否本次免费
        if UserData:getUserObj():judgeTavenLimitState() == true then
            --descFreeTime:setString(GlobalApi:getLocalStr('FREE_TIME'))
            descFreeTime:setVisible(false)

            numtx:setFontSize(28)
		    numtx:setTextColor(cc.c3b(255,255,255))
		    numtx:enableOutline(cc.c4b(0,0,0,255),1)
		    numtx:setFontName('font/gamefont.ttf')
		    numtx:setString(GlobalApi:getLocalStr('FREE_TIME'))
        else
            descFreeTime:setVisible(true)
            self:timeoutCallback(descFreeTime,self.tavern.hot_time)
        end
    end

    imgVip:setVisible(false)
    vipLabel:setVisible(false)
    descStart:setVisible(false)

    pl:setLocalZOrder(52)
  	pl:addTouchEventListener(function (sender, eventType)
  		if eventType == ccui.TouchEventType.began then
  			AudioMgr.PlayAudio(11)
  		elseif eventType == ccui.TouchEventType.ended then
            --if UserData:getUserObj():getVip() < tonumber(vipLimitLv) then            
                --promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("TAVERN_VIP_LIMIT_DES"),vipLimitLv), COLOR_TYPE.RED)
            --else
                TavernMgr:showTavernLimitUI()
            --end
  			
  		end
  	end)

end

function TavernUI:update()
	self.tavern = UserData:getUserObj():getTaverninfo()
	self:upDatenorpl()
	self:upDategoldpl()
    self:upLimitAward()

end

function TavernUI:scaleAction(node,callback)
	if node then
		local numbg = node:getChildByName('num_bg')
		local numtx = node:getChildByName('num_tx')
		local act1 = cc.ScaleTo:create(0.15, 1.5)
		local act2 = cc.ScaleTo:create(0.15,1)
		local callbackfunc = cc.CallFunc:create(callback)
		numtx:runAction(cc.Sequence:create(act1,act2,callbackfunc))
	end
end

-- i`m sorry
-- break youer package...
function TavernUI:recuit(recuitType)
	local freeTavernPerDay = GlobalApi:getGlobalValue('freeTavernPerDay')		--每天免费招募次数
	local freeTavernInterval = GlobalApi:getGlobalValue('freeTavernInterval')		--普通招募免费间隔分钟数
	local advTavernInterval = GlobalApi:getGlobalValue('advTavernInterval')		--高级招募免费间隔小时数
	local tavernCashCost = GlobalApi:getGlobalValue('tavernCashCost')			--高级招募消耗元宝数
--	local tavernPurpleCount = GlobalApi:getGlobalValue('tavernPurpleCount')		--高级招募必得紫卡的次数
	local tavernOrangeCount = GlobalApi:getGlobalValue('tavernOrangeCount')		--高级招募必得橙卡的次数
	local tenTavernDiscount = GlobalApi:getGlobalValue('tenTavernDiscount')		--十连抽折扣

	if recuitType == 1 then
		local pl = self.bgimg1:getChildByName('tavern_1_bg')
		local newImg = pl:getChildByName('new_img')
		newImg:setVisible(UserData:getUserObj():getSignByType('tavern_free'))
		local diffTime = 0
		if self.tavern.ntime ~= 0 then
			diffTime = self.tavern.ntime- GlobalData:getServerTime()
		end
		local args = {}
		local freeTavernPerDay = GlobalApi:getGlobalValue('freeTavernPerDay')
		local times = freeTavernPerDay - self.tavern.nfree
		if	(diffTime > 0 and UserData:getUserObj():getnToken() < 1) or (times <= 0 and UserData:getUserObj():getnToken() < 1) then
			promptmgr:showMessageBox(GlobalApi:getLocalStr('TRVEN_DESC_3'), MESSAGE_BOX_TYPE.MB_OK)
			return
		elseif diffTime <= 0 and times > 0 then
			args = {
				free = 1
			}
		end
		MessageMgr:sendPost("normal_tavern", "tavern", json.encode(args), function (jsonObj)
			print(json.encode(jsonObj))
			local code = jsonObj.code
			if code == 0 then
				local awards = jsonObj.data.awards
				GlobalApi:parseAwardData(awards)
				local costs = jsonObj.data.costs
				if costs then
						GlobalApi:parseAwardData(costs)
				end
				TavernMgr:showTavernAnimate(awards, function (	)
					if jsonObj.data.ntime then
							self.tavern.ntime = jsonObj.data.ntime
					end
					if jsonObj.data.nfree then
							self.tavern.nfree =jsonObj.data.nfree
					end
					TavernMgr:UpdateTavernMain()
				end, 1)
			end
		end)
    end

end

return TavernUI