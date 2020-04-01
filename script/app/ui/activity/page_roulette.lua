local PageRoulette = class("PageRoulette")
local ClassItemCell = require('script/app/global/itemcell')

function PageRoulette:init(msg)
    self.rootBG     = self.root:getChildByName("root")
    self.cfg = GameData:getConfData("avroulette")
	
	self.cells={}
	self.starNum=0
	for k,v in pairs(msg.roulette.star) do
		if tonumber(v)>0 then
			self.starNum=self.starNum+1
		end
	end
	
	local vip = UserData:getUserObj():getVip()
    local vipConf = GameData:getConfData("vip")
    local rolleteReset = vipConf[tostring(vip)].rolleteReset
	self.alreadyResetNum=msg.roulette.reset
	self.resetNum=rolleteReset-msg.roulette.reset
	self.isGetAwards=msg.roulette.got
	self.rotTimes=msg.roulette.cash
	
	self.leftPanel=ccui.Helper:seekWidgetByName(self.rootBG, 'leftPanel')
	
	self.tempCell=ccui.Helper:seekWidgetByName(self.rootBG, 'tempCell')
    self.tempCell:getChildByName('isGet'):getChildByName('tx_0'):setString(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_DES1'))
    self.tempCell:setVisible(false)
	self.tempCell:setTouchEnabled(false)
	
	self.itemPanel=ccui.Helper:seekWidgetByName(self.rootBG, 'itemPanel')
	self:ShowItems()
	local arrowPanel=self.rootBG:getChildByName("arrowPanel")
	self.arrow=arrowPanel:getChildByName("arrow")
	self.arrow:setRotation(270+msg.roulette.index*45)
	self.starPic={}
	for i=1,8 do
		local star=arrowPanel:getChildByName("star"..i)
		self.starPic[i]=star
		self.starPic[i].isSelected=(msg.roulette.star[i]>0) and true or false
		if self.starPic[i].isSelected==true then
			ShaderMgr:setGrayForWidget(self.starPic[i])
		else
			ShaderMgr:restoreWidgetDefaultShader(self.starPic[i])
		end
	end
	--boxBtn
	self.boxBtn=self.leftPanel:getChildByName("boxBtn")
	--[[
	self.boxBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				
				local cfg=GameData:getConfData("specialreward")["roulette_full"]
				local awards = DisplayData:getDisplayObjs(cfg.reward)
				GetWayMgr:showGetwayUI(awards[1],false)
			end
		end)
	--]]
	self.boxBtn:setTouchEnabled(false)
	
	--beginBtn
	self.beginBtn=self.rootBG:getChildByName("beginBtn")
    self.beginBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_DES5'))
	self.beginBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				
				self.rotTimes=self.rotTimes+1
				print("~~~~~~~~~~~~~~~~~~ Cur Rotate Times "..self.rotTimes)
				local function sendToServer()
					MessageMgr:sendPost('turn_roulette','activity',json.encode({}),
					function(response)
						if(response.code ~= 0) then
							return
						end
						
						local costs = response.data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						
						self:rotateSeq(response.data.turn)
					end)
				end
				local cfg=GameData:getConfData("buy")
				local cost=tonumber(cfg[self.rotTimes].rouletteTurn)
				if cost>0 then
					UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
				else
					sendToServer()
				end
			end
		end)
		
	--resetBtn
	self.resetBtn=self.rootBG:getChildByName("resetBtn")
    self.resetBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_DES4'))
	self.resetBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				--reset roulette
				local function sendToServer()
					MessageMgr:sendPost('reset_roulette','activity',json.encode({}),
					function(response)
						if(response.code ~= 0) then
							return
						end

						local costs = response.data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_RESET_TIPS'), COLOR_TYPE.GREEN)
						
						-- reset
						self.starNum=0
						for k,v in pairs(response.data.roulette.star) do
							if tonumber(v)>0 then
								self.starNum=self.starNum+1
							end
						end
						
						local vip = UserData:getUserObj():getVip()
						local vipConf = GameData:getConfData("vip")
						local rolleteReset = vipConf[tostring(vip)].rolleteReset
						self.alreadyResetNum=response.data.roulette.reset
						self.resetNum=rolleteReset-response.data.roulette.reset
						self.isGetAwards=0
						self.rotTimes=response.data.roulette.cash
						self.arrow:setRotation(270+response.data.roulette.index*45)
						for i=1,8 do
							self.starPic[i].isSelected=(response.data.roulette.star[i]>0) and true or false
							if self.starPic[i].isSelected==true then
								ShaderMgr:setGrayForWidget(self.starPic[i])
							else
								ShaderMgr:restoreWidgetDefaultShader(self.starPic[i])
							end
						end
	
						self:updateStarNum()
						self:updateBtnState()
						ActivityMgr:ShowRouletteRemainCount(self.resetNum)
					end)
				end
				
				local cfg=GameData:getConfData("buy")
				local times=(self.alreadyResetNum > #cfg) and #cfg or self.alreadyResetNum
				local cost=tonumber(cfg[times].rouletteReset)
				UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))	
				
				
			end
		end)
	self.resetBtn:setVisible(false)
	self.resetBtn:setTouchEnabled(false)
		
	--getBtn
	self.getBtn=self.rootBG:getChildByName("getBtn")
    self.getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_DES2'))
	self.getBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				--get awards
				MessageMgr:sendPost('reward_roulette','activity',json.encode({}),
					function(response)
						if(response.code ~= 0) then
							return
						end

						local awards = response.data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
							GlobalApi:showAwardsCommon(awards,nil,nil,true)
						end
						self.isGetAwards=1
						self:updateStarNum()
						self:updateBtnState()
					end)
			end
		end)
	self.getBtn:setVisible(false)
	self.getBtn:setTouchEnabled(false)
	
	--againBtn
	self.againBtn=self.rootBG:getChildByName("againBtn")
    self.againBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_DES3'))
	self.againBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				
				self.rotTimes=self.rotTimes+1
				print("~~~~~~~~~~~~~~~~~~ Cur Rotate Times "..self.rotTimes)
				
				local function sendToServer()
					MessageMgr:sendPost('turn_roulette','activity',json.encode({}),
					function(response)
						if(response.code ~= 0) then
							return
						end
						
						local costs = response.data.costs
						if costs then
							GlobalApi:parseAwardData(costs)
						end
						
						self:rotateSeq(response.data.turn)
					end)
				end
				
				local cfg=GameData:getConfData("buy")
				local times=(self.rotTimes > #cfg) and #cfg or self.rotTimes
				local cost=tonumber(cfg[times].rouletteTurn)
				UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))	
			end
		end)
	self.againBtn:setVisible(false)
	self.againBtn:setTouchEnabled(false)
		
	self:updateStarNum()
	self:updateBtnState()
	
	ActivityMgr:showLeftCue(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_VIP_TIPS'))
	ActivityMgr:ShowRouletteRemainCount(self.resetNum)
	ActivityMgr:showMark("roulette", false)
end	

function PageRoulette:CreateItem(item,parent)
	if item==nil then
		return nil
	end
	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, item, parent)
	tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			GetWayMgr:showGetwayUI(item,false)
		end
	end)
	return tab
end

function PageRoulette:ShowItems()
	for k,v in pairs(self.cfg) do
		local item = DisplayData:getDisplayObjs(v.award)
		if(item[1] ~= nil) then
			local panel=self.tempCell:clone()
			panel:setVisible(true)
			panel:setTouchEnabled(true)
			local itemNode=panel:getChildByName("itemNode")
			panel.isGet=panel:getChildByName("isGet")
			panel.isGet:setVisible(false)
			panel.num=panel:getChildByName("num")
			panel.num:setString('x'..tonumber(k))
			panel.star=panel:getChildByName("star")
			local cell=self:CreateItem(item[1], itemNode)
			if cell~=nil then
				local size=itemNode:getContentSize()
				cell.awardBgImg:setPosition(cc.p(size.width/2,size.height/2))
			end
			panel.cell=cell
			
			local xPos = (k-1)%4*110+10
			local yPos = (k<=4) and 160 or 10
			self.itemPanel:addChild(panel)
			self.cells[k]=panel
			panel:setPosition(cc.p(xPos, yPos))
		end
	end
end

function PageRoulette:updateStarNum()
	local needNum=self.leftPanel:getChildByName("num")
	needNum:setString(8-tonumber(self.starNum))
	local desPic=self.leftPanel:getChildByName("desPic")
	
	for k,v in pairs(self.cfg) do
		local panel=self.cells[k]
		panel.isGet:setVisible(false)
		if tonumber(k) > tonumber(self.starNum) then
			ShaderMgr:setGrayForWidget(panel.cell.awardBgImg)
			ShaderMgr:setGrayForWidget(panel.cell.awardImg)
			ShaderMgr:setGrayForWidget(panel.star)
		else
			ShaderMgr:restoreWidgetDefaultShader(panel.cell.awardBgImg)
			ShaderMgr:restoreWidgetDefaultShader(panel.cell.awardImg)
			ShaderMgr:restoreWidgetDefaultShader(panel.star)
			if self.isGetAwards>0 then
				panel.isGet:setVisible(true)
			end
		end
	end
	
	if tonumber(self.starNum) < 8 then
		desPic:loadTexture("uires/ui/activity/roulette_zi.png")
		needNum:setString(8-tonumber(self.starNum))
		ShaderMgr:setGrayForWidget(self.boxBtn)
		--self.boxBtn:setTouchEnabled(false)
	else 
		desPic:loadTexture("uires/ui/activity/roulette_zi1.png")
		needNum:setString(self.starNum)
		ShaderMgr:restoreWidgetDefaultShader(self.boxBtn)
		--self.boxBtn:setTouchEnabled(true)
	end
end

function PageRoulette:updateBtnState()
	
	self.beginBtn:setVisible(false)
	self.beginBtn:setTouchEnabled(false)
	self.getBtn:setVisible(false)
	self.getBtn:setTouchEnabled(false)
	self.againBtn:setVisible(false)
	self.againBtn:setTouchEnabled(false)
	self.resetBtn:setVisible(false)
	self.resetBtn:setTouchEnabled(false)
	
	if self.starNum >= 8 then
		self.getBtn:setVisible(true)
		self.getBtn:setTouchEnabled(true)
		self.resetBtn:setVisible(true)
		self.resetBtn:setTouchEnabled(true)
	elseif self.starNum <= 0 then
		self.beginBtn:setVisible(true)
		self.beginBtn:setTouchEnabled(true)
	else
		self.getBtn:setVisible(true)
		
		if self.isGetAwards>0 then
			self.resetBtn:setVisible(true)
			self.resetBtn:setTouchEnabled(true)
			
			self.getBtn:setTouchEnabled(false)
			ShaderMgr:setGrayForWidget(self.getBtn)
		else
			self.againBtn:setVisible(true)
			self.againBtn:setTouchEnabled(true)
			
			self.getBtn:setTouchEnabled(true)
			ShaderMgr:restoreWidgetDefaultShader(self.getBtn)
		end
	end
	
end

function PageRoulette:rotateSeq(seq)
	if seq==nil then
		return
	end
	self.rotSeq=seq
	self:rotate(1)
end

function PageRoulette:rotate(idx)
	if idx > #self.rotSeq then
		return
	end
	local val=self.rotSeq[idx]
	if val==nil then
		return
	end
	val=val+1
	print("PageRoulette:rotate "..val)
	self.beginBtn:setVisible(false)
	self.beginBtn:setTouchEnabled(false)
	self.getBtn:setVisible(false)
	self.getBtn:setTouchEnabled(false)
	self.againBtn:setVisible(false)
	self.againBtn:setTouchEnabled(false)
	self.resetBtn:setVisible(false)
	self.resetBtn:setTouchEnabled(false)
				
	self.arrow:setRotation(270)
	local deg=(val-1)*45
	local vec=cc.pForAngle(math.rad(90-deg))
	local offset=60
	--EaseSineOut EaseExponentialOut
	deg = (deg<=90) and (deg+360) or deg 
	local act1=cc.Sequence:create(cc.RotateBy:create(2,3600), cc.EaseSineOut:create(cc.RotateBy:create(3, deg)))
	local act2=cc.Sequence:create(cc.MoveBy:create(0.2,cc.p(vec.x*offset, vec.y*offset)), cc.MoveBy:create(0.15,cc.p(vec.x*-offset, vec.y*-offset)))
	local act3=cc.CallFunc:create(
		function ()
			if self.starPic[val].isSelected==false then
				self.starPic[val].isSelected=true
				
				self.beginBtn:setVisible(true)
				self.beginBtn:setTouchEnabled(true)
				self.getBtn:setVisible(false)
				self.getBtn:setTouchEnabled(false)
				self.againBtn:setVisible(false)
				self.againBtn:setTouchEnabled(false)
				
				self.starNum=self.starNum+1
				self:fly(self.starNum, self.starPic[val])
				
				ShaderMgr:setGrayForWidget(self.starPic[val])
				
				if self.starNum >= 8 then
					self.beginBtn:setVisible(false)
					self.beginBtn:setTouchEnabled(false)
					self.getBtn:setVisible(true)
					self.getBtn:setTouchEnabled(true)
					self.againBtn:setVisible(false)
					self.againBtn:setTouchEnabled(false)
					self.resetBtn:setVisible(true)
					self.resetBtn:setTouchEnabled(true)
				else
					self:rotate(idx+1)
				end
			else
				self.beginBtn:setVisible(false)
				self.beginBtn:setTouchEnabled(false)
				self.getBtn:setVisible(true)
				self.getBtn:setTouchEnabled(true)
				self.againBtn:setVisible(true)
				self.againBtn:setTouchEnabled(true)
			end
		end)
	self.arrow:runAction(cc.Sequence:create(act1, act2, act3))
end

function PageRoulette:fly(idx, pic)
	if self.cells[idx] then
		local temp=pic:clone()
		local picSize=pic:getContentSize()
		local srcPos=pic:convertToWorldSpace(cc.p(picSize.width/2, picSize.height/2))
		local offset=self.rootBG:convertToWorldSpace(cc.p(0,0))
		srcPos=cc.p(srcPos.x-offset.x, srcPos.y-offset.y)
		temp:setPosition(srcPos)
		self.rootBG:addChild(temp,100)
		
		local size=self.cells[idx]:getContentSize()
		local desPos=self.cells[idx]:convertToWorldSpace(cc.p(size.width/2, size.height/2))
		
		local act1=cc.Sequence:create(cc.ScaleTo:create(0.2,2.5), cc.ScaleTo:create(0.2,1.5))
		local act2=cc.Spawn:create(cc.MoveTo:create(0.5, desPos), cc.FadeOut:create(0.5))
		local act3=cc.CallFunc:create(
			function ()
				temp:removeFromParent()
				
				self:updateStarNum()
			end
		)
		temp:runAction(cc.Sequence:create(act1, act2, act3))
		AudioMgr.PlayAudio(12)
	end
end

return PageRoulette