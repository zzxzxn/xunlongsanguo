local TavernUI = class("TavernUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')

local girl_ani_pos = cc.p(120 - 206, 50 - 15)

function TavernUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_TAVERN
    self.girlEffectId = nil

end

function TavernUI:init()
	 local bgimg = self.root:getChildByName("bg_img")
	 self.bgimg1 = bgimg:getChildByName('bg_img1')

	local winSize = cc.Director:getInstance():getWinSize()
	bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))
	self.tavern = UserData:getUserObj():getTaverninfo()
	local closebtn = self.root:getChildByName('close_btn')
	closebtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
					TavernMgr:hideTavernMain()
			end
	end)
	closebtn:setPosition(cc.p(winSize.width,winSize.height))
	local talkbg = bgimg:getChildByName('talk_bg')
	talkbg:setPosition(cc.p(150+(winSize.width-960)/2,84))
	local tx1 = talkbg:getChildByName('tx_1')
	tx1:setString('')
	local richText = xx.RichText:create()
	local winSize = cc.Director:getInstance():getWinSize()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRVEN_DESC_8'), 25, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.PALE, 1)
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRVEN_DESC_10'), 25, COLOR_TYPE.YELLOW)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRVEN_DESC_9'), 25, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.PALE, 1)
    re3:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
		
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(0,0))
	--richText:setAlignment('middle')
	tx1:addChild(richText,9527)
	richText:setVisible(true)

	local tx2 = talkbg:getChildByName('tx_2')
	tx2:setString(GlobalApi:getLocalStr('TRVEN_DESC_7'))
	self:upDatenorpl()
	self:upDategoldpl()
	self:upDatetengoldpl()

	-- create spine animation ...
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
	-- girl_ani:registerSpineEventHandler(function (  )
	-- 	-- girl_ani:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
	-- 	girl_ani:setAnimation(0, 'idle', true)
	-- end, sp.EventType.ANIMATION_COMPLETE)

	-- 帮助按钮
   	-- local btn = HelpMgr:getBtn(1)
    -- btn:setScale(0.9)
    -- btn:setPosition(cc.p(-20 ,-50))
    -- bgimg:addChild(btn)
    -- local btn = ccui.Button:create("uires/ui/common/btn_help.png", nil, nil)
    -- btn:setTouchEnabled(true)
    -- btn:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         HelpMgr:showHelpUI(id)
    --     end
    -- end)
    -- btn:setPosition(cc.p(100 ,100))
    -- btn:setLocalZOrder(999)
    -- bgimg:addChild(btn)

    -- 图鉴
	local chartBtn = self.root:getChildByName('chart_btn')
	chartBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
			elseif eventType == ccui.TouchEventType.ended then
				ChartMgr:showChartMain()
			end
	end)
	chartBtn:setPosition(cc.p(winSize.width - 100,130))
    --chartBtn:setVisible(false)
    -- self.effectId = AudioMgr.playEffect('media/effect/tavern_enter_0'.. GlobalApi:random(1, 4) ..'.mp3', false)
    -- local helpbtn = self.root:getChildByName('help_btn')
    -- helptn:setPosition(cc.p(winSize.width,winSize.height))

    

end

function TavernUI:onHide()
	-- self.bgimg1:getChildByName('layout')
	-- 	:getChildByName('girl_ani')
	-- 	:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)

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

function TavernUI:onShow()

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
		numtx:setFontSize(28)
		numtx:setTextColor(cc.c3b(255,255,255))
		numtx:enableOutline(cc.c4b(0,0,0,255),1)
		numtx:setFontName('font/gamefont.ttf')
		numtx:setString(GlobalApi:getLocalStr('FREE_TIME'))
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
			self:recuit(2)
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

function TavernUI:upDatetengoldpl()
  	local tenTavernDiscount = GlobalApi:getGlobalValue('tenTavernDiscount')		 --十连抽折扣
  	local tavernCashCost = GlobalApi:getGlobalValue('tavernCashCost')			 --高级招募消耗元宝数
  	local pl = self.bgimg1:getChildByName('tavern_3_bg')
  	pl:setLocalZOrder(52)
  	pl:addTouchEventListener(function (sender, eventType)
  		if eventType == ccui.TouchEventType.began then
  			AudioMgr.PlayAudio(11)
  		elseif eventType == ccui.TouchEventType.ended then
  			self:recuit(3)
  		end
  	end)
  	local tavernicon = pl:getChildByName('trvern_icon')
  	local numbg = pl:getChildByName('num_bg')
  	local numicon = pl:getChildByName('num_icon')
  	numicon:ignoreContentAdaptWithSize(true)
  	local numtx = pl:getChildByName('num_tx')

  	if UserData:getUserObj():gethToken() >= 10*(tenTavernDiscount/10) then
  		numicon:loadTexture('uires/icon/user/recruit2.png')
  		numtx:setTextColor(cc.c3b(255,249,243))
  		numtx:enableOutline(cc.c4b(0,0,0,255),2)
  		numtx:setString(10*(tenTavernDiscount/10))
  	else
  		numicon:loadTexture('uires/icon/user/cash.png')
  		numtx:setString(tavernCashCost*10*(tenTavernDiscount/10))
  		if UserData:getUserObj():getCash() >= tavernCashCost*10*(tenTavernDiscount/10) then
  			numtx:setTextColor(cc.c3b(255,249,243))
  			numtx:enableOutline(cc.c4b(0,0,0,255),2)
  		else
  			numtx:setTextColor(cc.c3b(255,0,0))
  			numtx:enableOutline(cc.c4b(65,8,8,255),2)
  		end
  	end
  	local desc1 = pl:getChildByName('desc_1')
  	desc1:setString(GlobalApi:getLocalStr('TAVERN_MUST_ORANGE'))
  	-- desc1:setString('必出橙将')
  	local desc3 = pl:getChildByName('desc_3')
  	desc3:setString('')
  	-- desc3:setString('招10次')
    local richText = xx.RichText:create()
    local winSize = cc.Director:getInstance():getWinSize()
    richText:setContentSize(cc.size(200, 40))
    local re1 = xx.RichTextLabel:create("招", 30, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create('10', 30, COLOR_TYPE.GREEN)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create('次', 30, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re3:setFont('font/gamefont.ttf')
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    
    richText:setVerticalAlignment('middle')
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(0,0))
    richText:setAlignment('middle')
    desc3:addChild(richText,9527)
    richText:setVisible(true)
end

function TavernUI:update()
	self.tavern = UserData:getUserObj():getTaverninfo()
	self:upDatenorpl()
	self:upDategoldpl()
	self:upDatetengoldpl()
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
	print("重新招募")
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
		if diffTime > 0 then
		end
		local args = {}
		if diffTime <= 0 then
				args = {
					free = 1
				}
		end
		if	diffTime > 0 and UserData:getUserObj():getnToken() < 1		then
			promptmgr:showMessageBox(GlobalApi:getLocalStr('TRVEN_DESC_3'), MESSAGE_BOX_TYPE.MB_OK)
		else
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
	elseif recuitType == 2 then
		local pl = self.bgimg1:getChildByName('tavern_2_bg')
		local newImg = pl:getChildByName('new_img')
		newImg:setVisible(UserData:getUserObj():getSignByType('tavern_ten'))
		local diffTime = 0
		if self.tavern.htime ~= 0 then
			diffTime = self.tavern.htime - GlobalData:getServerTime()
		end
		local args = {}

		if diffTime <= 0 then
			print('a')
			args = {
				free = 1
			}
		elseif diffTime > 0 and UserData:getUserObj():gethToken() > 0	then
			print('b')
			args = {
				token = UserData:getUserObj():gethToken()
			}
		end

		if	diffTime > 0 and UserData:getUserObj():gethToken() <= 0 and UserData:getUserObj():getCash() < tonumber(tavernCashCost) then
			self:scaleAction(pl,function ()
			promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
					GlobalApi:getGotoByModule('cash')
				end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))					 
			end)
		else
			print("高级招募")
			MessageMgr:sendPost("high_tavern", "tavern", json.encode(args), function (jsonObj)
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
					-- GlobalApi:parseAwardData(awards)
						if jsonObj.data.htime then
								self.tavern.htime = jsonObj.data.htime
						end
						self.tavern.hcount = self.tavern.hcount + 1
						TavernMgr:UpdateTavernMain()
					end, 2)
				end
			end)
		end
	elseif recuitType == 3 then
		local pl = self.bgimg1:getChildByName('tavern_3_bg')
		local args = {}
		if UserData:getUserObj():gethToken() >= 10*(tenTavernDiscount/10) then
			args = {
				token = UserData:getUserObj():gethToken()
			}
		end
		if (UserData:getUserObj():gethToken() < 10*(tenTavernDiscount/10)) and (UserData:getUserObj():getCash() < tonumber(10*tavernCashCost*(tenTavernDiscount/10))) then
			self:scaleAction(pl,function ()
			promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
					GlobalApi:getGotoByModule('cash')
				end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))					 
			end)
		else
			-- promptmgr:showMessageBox(GlobalApi:getLocalStr('COST_CASH_TEN'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
				MessageMgr:sendPost("ten_tavern", "tavern", json.encode(args), function (jsonObj)
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
								TavernMgr:UpdateTavernMain()
						end, 3)
					end
				end)					 
			-- end)

		end
	end
end

return TavernUI