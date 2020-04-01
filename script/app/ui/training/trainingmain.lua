
local TrainingMainUI = class("TrainingMainUI", BaseUI)

function TrainingMainUI:ctor(msg)
	self.uiIndex = GAME_UI.UI_TRAININGMAIN
	self.cfg = GameData:getConfData("training")
	self.heroList = {}
	self.initMsg = msg
	self.allCash = 0
end

function TrainingMainUI:onShow()
	self:updatePanel()
end

function TrainingMainUI:updateSlot(idx)
	local slot = self.node[idx]
	if slot ~= nil then
		local data = self.cfg[idx]
		local lv = UserData:getUserObj():getLv()
		local vip = UserData:getUserObj():getVip()
		
		local isLock = false
		local btnStr = ''
		local privilegeOpen = GlobalApi:getPrivilegeById("train" .. idx)		--特权是否开启
		if self.initMsg['train'][tostring(idx)][3] == 0 and (not privilegeOpen) then
			isLock = true
			btnStr = GlobalApi:getLocalStr('BUY')..GlobalApi:getGlobalValue('trainSlotOpenCost4')
			if vip < data.vip then
				btnStr = string.format(GlobalApi:getLocalStr('TRAINING_VIP_LIMITED'), data.vip)
			end
			
			if lv < data.level then
				btnStr = string.format(GlobalApi:getLocalStr('TRAINING_LEVEL_LIMITED'), data.level)
			end
			
		end
		local isTraining = (self.heroList[idx]~=nil) and true or false
		
		slot.lockPic:setVisible(isLock)
		
		local tx = slot.trainBtn:getChildByName('tx')
		local str= (isTraining==false) and GlobalApi:getLocalStr('TRAINING_TRAIN_BTN') or GlobalApi:getLocalStr('TRAINING_ACC_BTN')
		tx:setString( (isLock==true) and btnStr or str )

		slot.trainBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				if isTraining==true then
					self:AccHero(idx)
				else
					if self.initMsg['train'][tostring(idx)][3] == 0 then
						if idx ~= 4 then
							if lv < data.level then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'),COLOR_TYPE.RED)
								return
							end
							if vip < data.vip then
								promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_NEED_VIP_1'),COLOR_TYPE.RED)
								return
							end
						end

						local str = string.format(GlobalApi:getLocalStr('TRAINING_DESC_1'),GlobalApi:getGlobalValue('trainSlotOpenCost4'))
						local cost = tonumber(GlobalApi:getGlobalValue('trainSlotOpenCost4'))
						promptmgr:showMessageBox(str, MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
							UserData:getUserObj():cost('cash', cost, function ()
								local args = {slot = idx}
								MessageMgr:sendPost('buy_train_slot','hero',json.encode(args),function (response)	
									local code = response.code
									if code == 0 then
										self.initMsg['train'][tostring(idx)][3] = 1
										local costs = response.data.costs
										if costs then
											GlobalApi:parseAwardData(costs)
										end
										self:updatePanel()
									end
								end)
							end)
						end)
					else
						self:SelectHero(idx)
					end
				end
			end
		end)
	end
end

function TrainingMainUI:updatePanel()
	print("TrainingMainUI:updatePanel")
	--update training slot
	for i=1,6 do
		self:updateSlot(i)
	end
end	

function TrainingMainUI:init()
	local bg1 = self.root:getChildByName("bg1")
	local bgNode = bg1:getChildByName("bg_node")
	local bg2 = bgNode:getChildByName("bg2")
	self:adaptUI(bg1, bgNode)
	local winSize = cc.Director:getInstance():getVisibleSize()
	-- bg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
    -- local action = cc.CSLoader:createTimeline("csb/trainingmain.csb")
    -- self.root:runAction(action)
    -- action:gotoFrameAndPlay(0,false)

    local warCollegeBtn = ccui.Button:create('uires/ui/buoy/icon_warcollege.png')
    warCollegeBtn:setAnchorPoint(cc.p(0,1))
    warCollegeBtn:setPosition(cc.p(0,winSize.height))
    self.root:addChild(warCollegeBtn)
    warCollegeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WarCollegeMgr:showWarCollege(true)
        end
    end)

	self.node={}
	for i=1,6 do
		self.heroList[i]=nil
		self.node[i] = bg2:getChildByName("node"..i)
		self.node[i]:setLocalZOrder(100-i)
		
		local spineAni=GlobalApi:createSpineByName("daocaoren", "spine/daocaoren/daocaoren", 1)
		self.node[i].ani = spineAni
		spineAni:setPosition(cc.p(self.node[i]:getContentSize().width/2+40,i*100))		
		spineAni:setScale(1)
		spineAni:setLocalZOrder(1)
		--spineAni:getAnimation():play('idle', -1, 1)
		self.node[i]:addChild(spineAni)
		spineAni:runAction(cc.EaseQuadraticActionIn:create(cc.MoveBy:create(0.5, cc.p(0, -i*100))))
		
		self.node[i].lvBg=self.node[i]:getChildByName("lvBg")
		self.node[i].expBg=self.node[i]:getChildByName("expBg")
		self.node[i].lvBg:setOpacity(0)
		self.node[i].expBg:setOpacity(0)
		
		self.node[i].cdTime=self.node[i]:getChildByName("cdTime")
		
		self.node[i].lockPic=self.node[i]:getChildByName("lockPic")
		self.node[i].lockPic:setLocalZOrder(3)
		
		self.node[i].trainBtn = self.node[i]:getChildByName("trainBtn")
		self.node[i].trainBtn:setLocalZOrder(2)
	end
	
	--npc
	local npc = ccui.ImageView:create('uires/ui/training/training_001.png')
	local npc_node = bg2:getChildByName("npc_node")
	npc:setLocalZOrder(5)
	npc_node:addChild(npc)
	
	local talkBg=npc_node:getChildByName("talkBg")
	talkBg:setLocalZOrder(10)
	
	local lv=UserData:getUserObj():getLv()
	local getExp=GameData:getConfData("level")[lv].trainExp
	
	local richText = xx.RichText:create()
    talkBg:addChild(richText)
    richText:setContentSize(cc.size(170, 64))
    richText:setPosition(cc.p(20,55))
    richText:setAlignment('left')
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRAINING_TIPS1'), 23, COLOR_TYPE.ZYQCOLOR)
	re1:setStroke(COLOROUTLINE_TYPE.WHITE1, 0)
	re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(getExp, 23, COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	re2:setFont('font/gamefont.ttf')
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TRAINING_TIPS2'), 23, COLOR_TYPE.ZYQCOLOR)
	re3:setStroke(COLOROUTLINE_TYPE.WHITE1, 0)
	re3:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
    richText:format(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setContentSize(richText:getElementsSize())
	
	--cash bg
	local cashBg=ccui.Helper:seekWidgetByName(bg1, 'cashBg')
	cashBg:setPosition(cc.p(winSize.width-240,40))
	self.cashText=cashBg:getChildByName('cashText')
	
	--all acc btn
	self.allAccBtn = ccui.Helper:seekWidgetByName(bg1, 'allAccBtn')
	self.allAccBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			self:AccAllHero()
	    end
	end)
	
	--close btn
	local closeBtn = bg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
            UserData:getUserObj():initTrain(self.initMsg.train)
			TrainingMgr:hideTrainingMain()
	    end
	end)
	closeBtn:setPosition(cc.p(winSize.width,winSize.height - 15))
	
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
	
	self:updatePanel()
	self:updateCash()
	
	for k,v in pairs(self.initMsg.train) do
		local posId=v[1]
		local time=v[2]
		if time>0 and posId>0 then
			local diffTime=time-GlobalData:getServerTime()
			print("diffTime "..diffTime)
			if diffTime>0 then
				local role=RoleData:getRoleByPos(posId)
				self:SetSlot(role, tonumber(k), diffTime)
			end
		end
	end
end

function TrainingMainUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bg1")
	local bgNode = bg1:getChildByName("bg_node")
	local panel=bgNode:getChildByName("bg2")
     --panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
	panel:runAction(cc.FadeOut:create(0.3))
    panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
            if(call ~= nil) then
                return call()
            end
        end)))
end

function TrainingMainUI:AccAllHero()
        local vip = UserData:getUserObj():getVip()
        if vip < tonumber(GlobalApi:getGlobalValue('trainSpeedVipLimit')) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('TRAIN_SPEED_VIP_LIMIT_DES'),tonumber(GlobalApi:getGlobalValue('trainSpeedVipLimit'))), COLOR_TYPE.RED)
            return
        end


		local function sendToServer()
			local args = {}
			MessageMgr:sendPost('train_accelerate_all','hero',json.encode(args),function (response)	
				local code = response.code
				if code == 0 then
					local trainInfo = UserData:getUserObj():getTrain()
					for i=1,6 do
						trainInfo[tostring(i)][2] = 0
					end
					UserData:getUserObj():initTrain(trainInfo)
					local costs = response.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					for i=1,6 do
						self:FinishTrain(i)
					end
				end
			end)
		end
				
		local cost=self.allCash
		local tips=string.format(GlobalApi:getLocalStr('TRAINING_ACC_ALL_USECASH'), cost)
		--[[
		promptmgr:showMessageBox(tips, MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
				UserData:getUserObj():cost('cash', cost, sendToServer)
			end)
		--]]
		UserData:getUserObj():cost('cash', cost, sendToServer, true, tips)
end

function TrainingMainUI:AccHero(idx)
        local vip = UserData:getUserObj():getVip()
        if vip < tonumber(GlobalApi:getGlobalValue('trainSpeedVipLimit')) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('TRAIN_SPEED_VIP_LIMIT_DES'),tonumber(GlobalApi:getGlobalValue('trainSpeedVipLimit'))), COLOR_TYPE.RED)
            return
        end

		local function sendToServer()
		
			local args = {}
			args.slot=idx
			MessageMgr:sendPost('train_accelerate','hero',json.encode(args),function (response)
								
								local code = response.code
								if code == 0 then
									local trainInfo = UserData:getUserObj():getTrain()
									trainInfo[tostring(idx)][2] = 0
									UserData:getUserObj():initTrain(trainInfo)
									local costs = response.data.costs
									if costs then
										GlobalApi:parseAwardData(costs)
									end
									self:FinishTrain(idx)
								end
							end)
			
		end
		
		local time = self.initMsg.train[tostring(idx)][2] - GlobalData:getServerTime()
		local count = math.ceil(time/3600)
		local cost=self.cfg[idx].need*count
		local tips=string.format(GlobalApi:getLocalStr('TRAINING_ACC_SINGLE_USECASH'), cost)
		--[[
		promptmgr:showMessageBox(tips, MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
				UserData:getUserObj():cost('cash', cost, sendToServer)
			end)
		--]]
		UserData:getUserObj():cost('cash', cost, sendToServer, true, tips)
end

function TrainingMainUI:SelectHero(idx)
	self.sel=idx
	
	local list={}
	for k, v in pairs(RoleData:getRoleMap()) do
		if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== false then		
			table.insert(list, v)
			
			v.isTraining=false
			--if #self.heroList>0 then
				for m, n in pairs(self.heroList) do
					if n~=nil and v:getId() == n:getId() then
						v.isTraining=true
					end
				end
			--end
		end
	end
	if #list>0 then
		TrainingMgr:showTrainingSelect(list)
	else
		promptmgr:showSystenHint(GlobalApi:getLocalStr('TRAINING_HERO_EMPTY'), COLOR_TYPE.RED)
	end
	
end

function TrainingMainUI:PlayAttackAnim(hero, idx)
	local node=self.node[idx]	
	local pos=ccui.Helper:seekWidgetByName(node,"pos")
	pos:removeAllChildren()
	pos.ani=nil
	pos:setLocalZOrder(3)
	local spineAni = GlobalApi:createLittleLossyAniByName(hero:getUrl().."_display", nil, hero:getChangeEquipState())
	local heroconf = GameData:getConfData('hero')[hero:getId()]
	if spineAni then
		spineAni:setPosition(cc.p(pos:getContentSize().width/2,0))
		spineAni:setLocalZOrder(999)
		spineAni:setScale(0.6)
		pos:addChild(spineAni)
		pos.ani=spineAni
		
		spineAni:getAnimation():play("attack", -1, -1)
		
		local function overFunc(armature, movementType, movementID)
	        if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
		
				
				local act1=cc.Sequence:create(cc.DelayTime:create(3),cc.CallFunc:create(
					function ()
						if spineAni~=nil and spineAni:getAnimation()~=nil then
							spineAni:getAnimation():play('attack', -1, -1)
						end
					end
				))
				node:runAction(cc.Sequence:create(act1))
	        end
	    end
		
		--attack hit
		local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
			if frameEventName == "-1" then
				--npc
				node.ani:setAnimation(0, 'animation', false)
			end
		end
	
    	spineAni:getAnimation():setMovementEventCallFunc(overFunc)
		spineAni:getAnimation():setFrameEventCallFunc(frameFun)
	end
	
end

function TrainingMainUI:SendTrainingHero(hero)
	local args = {}
	args.pos=hero.posid
	args.slot=self.sel
	MessageMgr:sendPost('train','hero',json.encode(args),function (response)	
		local code = response.code
		if code == 0 then
			local trainInfo = UserData:getUserObj():getTrain()
			trainInfo[tostring(self.sel)][2] = response.data.cold_time
			self.initMsg.train[tostring(self.sel)][2] = response.data.cold_time
			UserData:getUserObj():initTrain(trainInfo)
			local diffTime=response.data.cold_time-GlobalData:getServerTime()							
			if diffTime>0 then
				local getExp=GameData:getConfData("level")[tonumber(UserData:getUserObj():getLv())].trainExp
				local str=string.format(GlobalApi:getLocalStr('TRAINING_GET_EXP'), hero:getName(), tonumber(getExp) )
				promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
				
				self:SetSlot(hero, self.sel, diffTime, response.data)
			end
		end
	end)
end

function TrainingMainUI:SetSlot(hero, idx, time, data)
	print("TrainingMainUI:SetSlot idx "..idx.." time "..time)
	self.heroList[idx]=hero
	
	local node=self.node[idx]
	
	node:runAction(cc.Sequence:create(cc.DelayTime:create((data~=nil and 0 or 0.5)), cc.CallFunc:create(
		function ()
			self:PlayAttackAnim(hero, idx)
			self:ShowExpAdd(hero, data)
		end)))
	
	local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 27)
    label:setPosition(cc.p(-20,0))
	label:setLocalZOrder(10)
    node.cdTime:addChild(label)
	Utils:createCDLabel(label,time,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.FRONT,nil,nil,nil,25,function()
		self:FinishTrain(idx)
	end)
	
	self:updateSlot(idx)
	self:updateCash()
end

function TrainingMainUI:FinishTrain(idx)
	
	local node=self.node[idx]
	if node==nil then
		return
	end
	node.lvBg:runAction(cc.FadeOut:create(0.5))
	node.expBg:runAction(cc.FadeOut:create(0.5))
	node.cdTime:removeAllChildren(true)
	node:stopAllActions()
	local pos=ccui.Helper:seekWidgetByName(node,"pos")
	local act1=cc.CallFunc:create(
		function ()
			if pos.ani~=nil then
				pos.ani:runAction(cc.Sequence:create(cc.MoveBy:create(0.3, cc.p(110, -90)), cc.MoveBy:create(1.2, cc.p(800,0))))
				pos.ani:getAnimation():play('run', -1, 1)
				
				node.trainBtn:setTouchEnabled(false)
				self.allAccBtn:setTouchEnabled(false)
			end
		end)
	local act2=cc.DelayTime:create(1.5)
	local act3=cc.CallFunc:create(
		function ()
			if pos.ani~=nil then
				pos.ani:stopAllActions()
				pos.ani=nil
				pos:removeAllChildren(true)
				node.trainBtn:setTouchEnabled(true)
				self.heroList[idx]=nil
				self:updateSlot(idx)
				self:updateCash()
			end
		end)
	pos:runAction(cc.Sequence:create(act1, act2, act3))
	
end

function TrainingMainUI:ShowExpAdd(hero, data)
	local node=self.node[self.sel]
	if node==nil or data==null then
		return
	end		
	
	node.lvBg:runAction(cc.FadeIn:create(0.5))
	node.expBg:runAction(cc.FadeIn:create(0.5))
	local lvVal=node.lvBg:getChildByName("lvText")
	local expBar=node.expBg:getChildByName("expBar")
	local expVal=expBar:getChildByName("expText")
	node.expBg:setVisible(true)
	
	local oldLv=hero:getLevel()
	lvVal:setString(oldLv)
	local newLv=data.level
	local lvconf = GameData:getConfData('level')
	local lvExp=lvconf[newLv]['roleExp']
	print(data.xp,lvExp)
	local percent=data.xp/lvExp*100
	if data.xp == lvExp - 1 then
		percent = 99.99
	end
	print("TrainingMainUI:ShowExpAdd oldLv "..oldLv.." newLv "..newLv.." per "..percent)
	hero:setLevelandXp(newLv,data.xp)
	hero:setFightForceDirty(true)
			
	local singleTime= (newLv-oldLv)>=5 and 0.2 or 0.25
	require('script/app/utils/scheduleActions'):runExpBar(
		expBar, 
		singleTime, 
		newLv- oldLv + 1, 
		tonumber(percent),
		function (e)
			if e.status == SAS.START then
				expVal:setScale(1.2)
			elseif e.status == SAS.FRAME then
				local p = string.format('%.2f', e.percent) 
				expVal:setString(p .. '%')
			elseif e.status == SAS.SINGLE_END then
				local lv = e.count
				lvVal:setString(newLv - lv + 1)
				if lv==1 then
					print("TrainingMainUI:ShowExpAdd Lv "..lv)
					node.lvBg:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.FadeOut:create(1)))
					node.expBg:runAction(cc.Sequence:create(cc.DelayTime:create(3),cc.FadeOut:create(1)))
				end
				local p = string.format('%.2f', e.percent) 
				expVal:setString(p .. '%')
			elseif e.status == SAS.END then
				local p = string.format('%.2f', e.percent) 
				expVal:setString(p .. '%')
				expVal:setScale(1)
			end
		end)
	
	--node.lvBg:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.FadeOut:create(1)))
	--node.expBg:runAction(cc.Sequence:create(cc.DelayTime:create(5),cc.FadeOut:create(1)))
end

function TrainingMainUI:updateCash()
	self.allCash=0
	for i=1,6 do
		if self.heroList[i]~=nil then
			local time = self.initMsg.train[tostring(i)][2] - GlobalData:getServerTime()
			local count = math.ceil(time/3600)
			self.allCash=self.allCash+self.cfg[i].need*count
		end
	end
	self.cashText:setString(self.allCash)
	
	local tx=self.allAccBtn:getChildByName('tx')
	if self.allCash==0 then
		ShaderMgr:setGrayForWidget(self.allAccBtn)
		tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        self.allAccBtn:setTouchEnabled(false)
	else
		ShaderMgr:restoreWidgetDefaultShader(self.allAccBtn)
		tx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 1)
		self.allAccBtn:setTouchEnabled(true)
	end
end

return TrainingMainUI