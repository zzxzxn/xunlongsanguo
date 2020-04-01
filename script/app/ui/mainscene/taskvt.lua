local TaskNewUI = class("TaskNewUI", BaseUI)

local fontColor = cc.c4b(255,247,229,255)
local outColor = cc.c4b(78,49,17,255)
local nobilityIconUrl = "uires/ui/worldwar/worldwar_"
local lightStarUrl = {
	light = "uires/ui/common/icon_star3.png",
	dark = "uires/ui/common/icon_star3_bg.png",
}
local upImg = "uires/ui/task/task_jinji.png"

local TEMP_BLOCK_NAME = "battle"

function TaskNewUI:ctor(data)

	self.uiIndex = GAME_UI.UI_NEW_TASK
	self.data = data
	self.mrRt = {}
	self.mrLockRTs = {}
	self.intervalSize = 6

	self.nobilityId  = data.task.nobility[1] or 1
    self.nobiltyStar = data.task.nobility[2] or 0
    UserData:getUserObj():setNobility(self.nobilityId,self.nobiltyStar)
    self.curActive = data.task.active
    self.vipInfo = {}
    local vipConf = GameData:getConfData('vip')
	for k,v in pairs(vipConf) do
		local i = tonumber(v.level)
		self.vipInfo[i] = v
	end
	self.cangetCount = 0
end

function TaskNewUI:init()

	local winsize = cc.Director:getInstance():getWinSize()
    local campaignBgImg = self.root:getChildByName("campaign_bg_img")
    campaignBgImg:setContentSize(winsize)
    campaignBgImg:setPosition(cc.p(winsize.width/2, winsize.height/2))
    local conntent = campaignBgImg:getChildByName("bg")
    self:adaptUI(campaignBgImg, conntent)

    local topTiao = conntent:getChildByName("top_tiao")
    local infoLabel = topTiao:getChildByName("info_tx")
  	infoLabel:setString(GlobalApi:getLocalStr("TASK_PRIVILEGE_4"))

  	local signNew = {"main_task","world_reward"}
  	local function callback()
  		for i=1,2 do
	    	local funBtn = conntent:getChildByName("btn_" .. i)
	    	local newImg = funBtn:getChildByName("new_img")
	    	local sign = UserData:getUserObj():getSignByType(signNew[i])
	    	newImg:setVisible(sign)
	    end
  	end
  	
    for i=1,2 do
    	local funBtn = conntent:getChildByName("btn_" .. i)
    	local newImg = funBtn:getChildByName("new_img")
    	funBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then    
	        	--local test = true
	            --if not test then
	             MainSceneMgr:showTask(i,callback)
	            --else
	            	--self.curActive = self.curActive + 200
			        --self:updateActive()
	            --end
	        end
	    end)

    	local sign = UserData:getUserObj():getSignByType(signNew[i])
    	newImg:setVisible(sign)
    end

    --每日任务列表
    local svImg = conntent:getChildByName("sv_img")
    self.cardSv = svImg:getChildByName("sv")
    self.cardSv:setScrollBarEnabled(false)

    --问号
    local qBtn = conntent:getChildByName("q_btn")
    qBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showTaskNobilityUI(self.nobilityId,self.nobiltyStar)
        end
    end)

    --爵位显示
    self.nobilityIcon = conntent:getChildByName("nobility_icon")
    self.privilege = {}
    for i=1,3 do
    	local text = conntent:getChildByName("privilege_text" .. i)
    	local icon = conntent:getChildByName("star" .. i)
    	self.privilege[i] = {}
    	self.privilege[i].icon = icon
    	self.privilege[i].text = text
    end

    self.nobilityIcon:setTouchEnabled(true)
    self.nobilityIcon:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showTaskNobilityUI(self.nobilityId,self.nobiltyStar)
        end
    end)
    
    --活跃度显示
    self.barBg = conntent:getChildByName("bar_bg")
    self.barStar = conntent:getChildByName("fly_icon")
    self.barStar:setVisible(false)
    -- 关闭按钮
    local closeBtn = conntent:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	UserData:getUserObj():setSignByType('daily_task',self:getMRstatus())
            MainSceneMgr:hideTaskNewUI()
        end
    end)

    self.newData, self.cangetCount = TaskMgr:getDailyData(self.data)
    self:updateMR()
    self:updateActive()
    self:updateNobility()

end

function TaskNewUI:getMRstatus()
	local isSign = 0
	for i,v in ipairs(self.newData) do
		local status = v.status
		if v.status == 0 then
			isSign = 1
			break
		end
	end
	return isSign
end

function TaskNewUI:updateNobility()

	local nobiltybaseCfg = GameData:getConfData('nobiltybase')
    local nobilityId,nobilityStar = self.nobilityId,self.nobiltyStar
	local nobiltybaseCfgInfo = nobiltybaseCfg[nobilityId]
	if not nobiltybaseCfgInfo then
		print("not find nobilityId: " .. nobilityId .. " in nobiltybase config")
		return
	end

	--爵位名字,图标
	local nameTx = self.nobilityIcon:getChildByName("name")
	nameTx:setString(nobiltybaseCfgInfo.name)
	self.nobilityIcon:loadTexture(nobilityIconUrl .. nobiltybaseCfgInfo.icon)

	--特权描述显示
	local privilegeCfg = GameData:getConfData("nobiltytitle")
	for i=1,3 do
		local color = (nobilityStar >= i) and COLOR_TYPE.GREEN or cc.c4b(171, 171, 171, 255)
		local star  = (nobilityStar >= i) and lightStarUrl.light or lightStarUrl.dark

		local privilegeId = nobiltybaseCfgInfo["pg" .. i]
		local privilegeValue = nobiltybaseCfgInfo["pgnum" .. i]
		if privilegeId == 4 or privilegeId == 5 then
			self:updateMR()
		end
		self.privilege[i].text:stopAllActions()
		local desc,newDesc = self:getPrivilegeDesc(nobilityId,privilegeId,privilegeValue)
		self.privilege[i].text:setOpacity(255)
		local count = 0
		if nobilityStar < i and newDesc then 
			self.privilege[i].text:setString(newDesc)
			local sequence = cc.Sequence:create(cc.FadeIn:create(0.8),cc.DelayTime:create(0.4),
			cc.FadeOut:create(0.5),cc.DelayTime:create(0.4),
			cc.CallFunc:create(function()
				if count%2 == 0 then
					self.privilege[i].text:setString(desc)
				else
					self.privilege[i].text:setString(newDesc)
				end
				count = count + 1
			end))
			self.privilege[i].text:runAction(cc.RepeatForever:create(sequence))
		else
			self.privilege[i].text:setString(desc)
		end

		self.privilege[i].text:setColor(color)
		self.privilege[i].icon:loadTexture(star)
	end

	--满级处理
	if nobilityId == #nobiltybaseCfg and nobilityStar == 3 then
		local numTx = self.barBg:getChildByName("num")
		numTx:setString("MAX")
		local upIcon = self.barBg:getChildByName("up_icon")
		local tx = upIcon:getChildByName("Text_1")
		tx:setString(GlobalApi:getLocalStr("TASK_PRIVILEGE_6"))
		upIcon:setVisible(true)
		local icon = self.barBg:getChildByName("icon")
    	icon:setVisible(false)
	end
end

function TaskNewUI:getPrivilegeDesc(nobilityId,id,value)

	local privilegeCfg = GameData:getConfData("nobiltytitle")[id]
	local desc = privilegeCfg.name
	local ntype = privilegeCfg.lock
	if ntype ~= 1 then
		desc = string.format(desc,value)
	end	
	--检测是否有其他系统加成显示
	if not privilegeCfg.open[1] then
		return desc
	end

	local newDesc = privilegeCfg.desc

	--[[if self.nobilityId > nobilityId then
		newDesc = nil
	end
	
	local stype = privilegeCfg.open[1]
	local nLimit = privilegeCfg.open[2] or 0
	local haveAdd = self:otherSysAdd(stype,nLimit)
	if haveAdd then
		newDesc = privilegeCfg.desc
	end]]
	return desc,newDesc
end

function TaskNewUI:otherSysAdd(stype,nLimit)

	local haveAdd = false
	if stype == "vip" then
		local vip = UserData:getUserObj():getVip()
		if vip >= tonumber(nLimit) then
			haveAdd = true
		end
	elseif stype == "train" then 		--判断是否购买4号训练槽

		local trainInfo = UserData:getUserObj():getTrain()
		if trainInfo and trainInfo["4"] and trainInfo["4"][3] and trainInfo["4"][3] == 1 then
			haveAdd = true
		end
	elseif stype == "lifecard"	then 	--判断是否购买终生卡
		local paymentInfo = UserData:getUserObj():getPayment()
		if paymentInfo.long_card >0 then
			haveAdd = true
		end
	end
	return haveAdd
end

function TaskNewUI:updateActive(lockAwards)

    local nobilityId,nobiltyStar =  self.nobilityId,self.nobiltyStar
	local curLevel = (nobilityId-1)*4+nobiltyStar+1
	local nobiltylevelCfg = GameData:getConfData('nobiltylevel')
    if curLevel >= #nobiltylevelCfg then
    	return
    end
    local needActive = 0
    for i=1,curLevel do
    	needActive = needActive + nobiltylevelCfg[i].active
    end
    self:updateActiveBar(curLevel)
    if self.curActive >= needActive then
    	self:playEffect(curLevel+1,lockAwards)
    end
end

function TaskNewUI:updateActiveBar(level)

	local nobiltylevelCfg = GameData:getConfData('nobiltylevel')
    if level >= #nobiltylevelCfg then
    	return
    end

    local needActive = nobiltylevelCfg[level].active
    local numTx = self.barBg:getChildByName("num")
    local bar = self.barBg:getChildByName("bar")

    local beforLvActive = 0
    for i=1,level do
    	if i<level then
    		beforLvActive = beforLvActive + nobiltylevelCfg[i].active
    	end
    end

    local curActive = self.curActive-beforLvActive
    local percent = curActive/needActive*100
    bar:setPercent(percent)
    numTx:setString(curActive .. "/" .. needActive)

    local nobiltyStar = (level-1)%4
    local upImg = self.barBg:getChildByName("up_icon")
    local tx = upImg:getChildByName("Text_1")
    tx:setString(GlobalApi:getLocalStr("TASK_PRIVILEGE_5"))
    upImg:setVisible(nobiltyStar == 3)
    local icon = self.barBg:getChildByName("icon")
    icon:setVisible(nobiltyStar ~= 3)
end

function TaskNewUI:popupTips(oldatt,newatt,oldfightforce,newfightforce)

    local attchange = {}
    local arr1 = newatt
    local arr2 = oldatt
    local attconf =GameData:getConfData('attribute')
    local isnew = true
    local attcount = #attconf
    for i=1,attcount do
        if arr2[i] -arr1[i]  ~= 0 then
            isnew = false
        end
    end

    local showWidgets = {}
    if isnew == false then
        for i = 1,attcount do
            attchange[i] = arr1[i] - arr2[i]
            local desc = attconf[i].desc
            if desc == "0" then
                desc = ''
            end
            if attchange[i] > 0 then
                local str = math.abs(math.floor(attchange[i]))
                local name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' + '.. str..desc
                local color = COLOR_TYPE.GREEN
                if i == 10 then
                    name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' - '.. str..desc
                    color = COLOR_TYPE.RED
                end
                local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
                w:setTextColor(color)
                w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                table.insert(showWidgets, w)
            elseif attchange[i] < 0 then
                local str = math.abs(math.floor(attchange[i]))
                local name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' - '.. str..desc
                local color = COLOR_TYPE.RED
                if i == 10 then
                    name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' + '.. str..desc
                    color = COLOR_TYPE.GREEN
                end
                
                local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
                w:setTextColor(color)
                w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                table.insert(showWidgets, w)
            end

        end
        if newfightforce - oldfightforce > 0 then
            local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' + '.. math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 26)
            w:setTextColor(cc.c3b(0,252,255))
            w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            table.insert(showWidgets, w)
        elseif newfightforce - oldfightforce < 0 then
            local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' - '..math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 24)
            w:setTextColor(COLOR_TYPE.RED)
            w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            table.insert(showWidgets, w)
        end
        promptmgr:showAttributeUpdate(showWidgets)
    end
end

function TaskNewUI:playEffect(nextLevel,lockAwards)

	local nobilityId  = math.floor((nextLevel-1)/4)+1
    local nobiltyStar = (nextLevel-1)%4
    self.nobilityId,self.nobiltyStar = nobilityId,nobiltyStar

    UserData:getUserObj():setNobility(self.nobilityId,self.nobiltyStar)

    --晋级
	if nobiltyStar == 0 then

		local oldAttr = {}
		local newAttr = {}
		local oldfight = RoleData:getFightForce()
	    for i=1,7 do
	    	local obj = RoleData:getRoleByPos(i)
	    	if obj and obj:getId() > 0 then
		        local oldatt = RoleData:getPosAttByPos(obj)
		        oldAttr[i] = oldatt
		    end
	    end

	    RoleData:setAllFightForceDirty()
	    for i=1,7 do
	    	local obj = RoleData:getRoleByPos(i)
	    	if obj and obj:getId() > 0 then
		        RoleMgr:popupTips(obj,true)
		    end
	    end

		MainSceneMgr:showTaskNobilityUpUI(function ()
			self:updateActiveBar(nextLevel)
			self:updateNobility()
			local newfight = RoleData:getFightForce()
		    for i=1,7 do
		    	local obj = RoleData:getRoleByPos(i)
		    	local newAttr = RoleData:getPosAttByPos(obj)
				if oldAttr[i] and newAttr then
					self:popupTips(oldAttr[i],newAttr,oldfight,newfight)
				end
			end
		end,nobilityId,nobiltyStar)
		return
	end
	
	--升星
    self.barStar:setVisible(true)
	local barStarPosX,barStarPosY = self.barStar:getPositionX(),self.barStar:getPositionY()
	local targetPosX,targetPosY = self.privilege[nobiltyStar].icon:getPositionX(),self.privilege[nobiltyStar].icon:getPositionY()

	local startPos = cc.p(barStarPosX,barStarPosY)
	local scendPos = cc.p(targetPosX+150,targetPosY)
	local endPos = cc.p(targetPosX,targetPosY)
	
	local bezier1 ={
        startPos,
        scendPos,
        endPos
    }

    local bezierAction1 = cc.BezierTo:create(0.5, bezier1)
	local sequenceAction = cc.Sequence:create(bezierAction1,
		cc.ScaleTo:create(0.1,1.5),cc.DelayTime:create(0.2),cc.ScaleTo:create(0.1,1.0),cc.CallFunc:create(function()
			
			--判断是否弹获得已解锁奖励
			local nobilitbaseCf = GameData:getConfData("nobiltybase")[nobilityId]
			local privilegeId = nobilitbaseCf["pg" .. nobiltyStar]
			local privilegeValue = nobilitbaseCf["pgnum" .. nobiltyStar]
			local privilegeCfg = GameData:getConfData("nobiltytitle")[privilegeId]

			--设置特权值
			local value = UserData:getUserObj():getPrivilege(privilegeId) or 0
			print("value:" ,value)
			privilegeValue = value + privilegeValue
			UserData:getUserObj():setPrivilege(privilegeId,privilegeValue)

			--vip特殊处理
			if privilegeCfg.key == "vipExp" then
				local vip_xp = UserData:getUserObj():getVipXp()
				local oldvip = UserData:getUserObj():getVip()
				local vip = 0
				vip_xp = vip_xp + privilegeValue
				for i=0,#self.vipInfo do
					if self.vipInfo[i].cash <= vip_xp then
						vip = tonumber(self.vipInfo[i].level)
					end
				end
				UserData:getUserObj():setVip(vip)
				UserData:getUserObj():setVipXp(vip_xp)
			elseif privilegeCfg.key == "godShopRefresh" then

				local freeGtime = UserData:getUserObj():getFreeGToken()
				print("freeGtime:" ,freeGtime)
				freeGtime = freeGtime + privilegeValue - value
				print("freeGtimeAfter:" ,freeGtime)
				UserData:getUserObj():setFreeGToken(freeGtime)

			elseif privilegeCfg.key == "equipShopRefresh" then

				local freeMtime = UserData:getUserObj():getFreeMToken()
				print("freeMtime:" ,freeMtime)
				freeMtime = freeMtime + privilegeValue - value
				print("freeMtimeAfter:" ,freeMtime)
				UserData:getUserObj():setFreeMToken(freeMtime)
			elseif privilegeCfg.key == "lifeCard" then
				local paymentInfo = UserData:getUserObj():getPayment()
				if paymentInfo then
					paymentInfo.long_card = 1
				end

				--处理任务界面的刷新
				local conf = GameData:getConfData('dailytask')
				for i=1,#conf do
					if conf[i].event == "longCard" then
						self.data.task.daily[tostring(i)] = 1
					elseif conf[i].event == "doubleCard" then
						local count = self.data.task.daily[tostring(i)] or 0
						count = count + 1
						self.data.task.daily[tostring(i)] = count
					end
				end
				self.newData, self.cangetCount = TaskMgr:getDailyData(self.data)
			end

			self:updateNobility()
			self.barStar:setPosition(startPos)
			self.barStar:setVisible(false)
			self:updateActiveBar(nextLevel)

			local stype = privilegeCfg.open[1]
			local nLimit = privilegeCfg.open[2] or 0
			local haveAdd = self:otherSysAdd(stype,nLimit)
			if haveAdd and lockAwards then
                GlobalApi:parseAwardData(lockAwards)
                GlobalApi:showAwardsCommon(lockAwards,nil,nil,true)
			end
		end)
	)

	self.barStar:runAction(sequenceAction)
end

function TaskNewUI:updateMR()
	local size1
	local conf = GameData:getConfData('dailytask')
	local lunch = GlobalApi:getPrivilegeById("lunch") or 0
	local dinner = GlobalApi:getPrivilegeById("dinner") or 0

	local maxNum = #self.newData

	for i,v in ipairs(self.newData) do
		local desc1, desc2, desc2Color = TaskMgr:getDailyCellDesc(v)

		local status = v.status
		local times = v.times
		local taskImg = self.cardSv:getChildByTag(i + 100)
		if not taskImg then
			local cellNode = cc.CSLoader:createNode('csb/taskcell.csb')
			taskImg = cellNode:getChildByName('task_img')
			taskImg:removeFromParent(false)
			self.cardSv:addChild(taskImg,1,i+100)
		end

		size1 = taskImg:getContentSize()
		local awards = DisplayData:getDisplayObjs(conf[v.id]['award'])
		for j=1,3 do
			local awardBgImg = taskImg:getChildByName('award_'..j..'_img')
			local awardImg = awardBgImg:getChildByName('award_img')
			local numTx = awardBgImg:getChildByName('num_tx')
			if awards[j] then
				awardBgImg:loadTexture(awards[j]:getBgImg())
				awardBgImg:setVisible(true)
				awardImg:loadTexture(awards[j]:getIcon())
				awardImg:ignoreContentAdaptWithSize(true)
				local num = awards[j]:getNum()

				if conf[v.id].event == "food" then
					local nowTime = GlobalData:getServerTime()
					local today = Time.beginningOfToday()
					local time1 = string.split(GlobalApi:getGlobalValue('dailyFoodNoon'),'-')
					-- local time3 = string.split(GlobalApi:getGlobalValue('dailyFoodNight'),'-')
					local time2 = string.split(GlobalApi:getGlobalValue('dailyFoodEvening'),'-')
					local time = {time1,time2}
					local isOut = true
					for i,v in ipairs(time) do
						if nowTime - today < v[2]*3600 then
							if i == 1 then
								num = awards[j]:getNum() + lunch
							elseif i== 2 then
								num = awards[j]:getNum() + dinner
							end
							isOut = false
							break
						end
					end
					if isOut then
						num = awards[j]:getNum() + lunch
					end
				end

				numTx:setString("x" .. num)
				awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[j],false)
					end
				end)
			else
				awardBgImg:setVisible(false)
			end
		end
		local taskBgImg = taskImg:getChildByName('task_bg_img')
		local awardImg = taskBgImg:getChildByName('task_img')
		awardImg:loadTexture('uires/icon/dailytask/'..conf[v.id].icon)
		awardImg:ignoreContentAdaptWithSize(true)


		local nameTx = taskImg:getChildByName('name_tx')
		nameTx:setString(desc1)
		local txSize = nameTx:getContentSize()
		local posX = txSize.width+nameTx:getPositionX()

		local nameTx1 = taskImg:getChildByName('name_tx1')
		nameTx1:setPositionX(posX)
		nameTx1:setString(desc2)
		nameTx1:setColor(desc2Color)
		
		local gotoBtn = taskImg:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		local getBtn = taskImg:getChildByName('get_btn')
		local infoTx = getBtn:getChildByName('info_tx')
		-- 领取
		local str = self.cangetCount > 1 and GlobalApi:getLocalStr('TRIBUTE_DESC_5') or GlobalApi:getLocalStr('STR_GET_1')
		infoTx:setString(str)
		local level = UserData:getUserObj():getLv()

		local desc,isOpen = nil,0
		local routetoCfg = GameData:getConfData("routeto")[conf[v.id].key]
    	if routetoCfg then
    		if routetoCfg.value == 1 then
				desc,isOpen = GlobalApi:getGotoByModule(routetoCfg.key,true)
			else
				desc = GlobalApi:getGotoLegionModule(routetoCfg.key,true)
				isOpen = 3	
			end
    	end

		if not desc then
			getBtn:setTouchEnabled(false)
			if self.mrLockRTs[i] then
				self.mrLockRTs[i].richText:setVisible(false)
			end
			if status == 0 then
				getBtn:setVisible(true)
				getBtn:setBright(true)
				getBtn:setTouchEnabled(true)
				infoTx:setColor(COLOR_TYPE.WHITE)
				infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
				getBtn:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
			        	TaskMgr:getDailyReward(self.newData, function(data, getTab)
			        		local conf = GameData:getConfData('dailytask')
				        	for k=1,#getTab do
					        	
					        	local taskId = getTab[k]
			                    local addActive = conf[taskId].active
			                    self.curActive = self.curActive + addActive

                                if taskId == 16 then
                                    UserData:getUserObj().task.daily_reward['16'] = 1
                                end

			                    self.cangetCount = self.cangetCount - 1
			                    if self.cangetCount < 0 then
			                    	self.cangetCount = 0
			                    end

			                    self.data.task.daily_reward[tostring(taskId)] = 1
			                    for l,v in pairs(self.newData) do
			                    	if v.id == taskId then
					            		self.newData[l].status = 2
					            	end
					            end
					        end

					        local lastLv = UserData:getUserObj():getLv()
					        local awards = data.awards
					        local lockAwards = data.already_lock_awards
				            if awards then
				                GlobalApi:parseAwardData(awards)

				                GlobalApi:showAwardsCommon(awards,nil,function ()
				                	self:updateActive(lockAwards)
				                end,true)
				            end
				            local costs = data.costs
		                    if costs then
		                        GlobalApi:parseAwardData(costs)
		                    end
		                    TaskMgr:sortNewData(self.newData)
				            self:updateMR()

                            local nowLv = UserData:getUserObj():getLv()
                            GlobalApi:showKingLvUp(lastLv,nowLv)
		        		end)
				    end
				end)
			elseif status == 2 then
				getBtn:setVisible(true)
				getBtn:setBright(false)
				infoTx:setColor(COLOR_TYPE.WHITE)
				infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
			else
				getBtn:setVisible(false)
			end
			gotoBtn:setVisible(status == 1)
			gotoBtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	local routetoCfg = GameData:getConfData("routeto")[conf[v.id].key]
		        	if not routetoCfg then
		        		return
		        	end

		        	--防止界面转跳错误
		        	MainSceneMgr:hideTaskNewUI()
		        	if routetoCfg.value == 1 then
						GlobalApi:getGotoByModule(routetoCfg.key)
					else
						GlobalApi:getGotoLegionModule(routetoCfg.key)	
					end
					UserData:getUserObj():setSignByType('daily_task',self:getMRstatus())
					
			    end
			end)
		else
			getBtn:setVisible(false)
			gotoBtn:setVisible(false)
			if not self.mrLockRTs[i] then
				local richText = xx.RichText:create()
				richText:setContentSize(cc.size(450, 30))
				richText:setAlignment('middle')
  				richText:setVerticalAlignment('middle')
  				local tx1,tx2
				if isOpen == 1 then 	--通关xx开放
					tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
					tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
				elseif isOpen == 2 then --xx级开放
					tx1 = ''
					tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
				elseif isOpen == 3 then --xx开放
					tx1 = ''
					tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
				end
				local re2 = xx.RichTextLabel:create(desc,22,COLOR_TYPE.RED)
				local re1 = xx.RichTextLabel:create(tx1,22,COLOR_TYPE.WHITE)
				local re3 = xx.RichTextLabel:create(tx2,22,COLOR_TYPE.WHITE)
				re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
				re2:setStroke(COLOROUTLINE_TYPE.RED, 1)
				re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
				richText:addElement(re1)
				richText:addElement(re2)
				richText:addElement(re3)
				richText:setAnchorPoint(cc.p(0.5,0.5))
				richText:setPosition(cc.p(721,55))
				taskImg:addChild(richText)
				self.mrLockRTs[i] = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
			else
				self.mrLockRTs[i].richText:setVisible(true)
			end
		end
	end

	local size = self.cardSv:getContentSize()
    if maxNum * (size1.height + self.intervalSize) > size.height then
        self.cardSv:setInnerContainerSize(cc.size(size.width,(maxNum * (size1.height + self.intervalSize))))
    else
        self.cardSv:setInnerContainerSize(size)
    end
    local function getPos(i)
    	local size2 = self.cardSv:getInnerContainerSize()
		return cc.p(6,size2.height - (size1.height + self.intervalSize) * i)
	end
	for i,v in ipairs(self.newData) do
		local taskImg = self.cardSv:getChildByTag(i + 100)
		if taskImg then
			taskImg:setPosition(getPos(i))
		end
	end
end

return TaskNewUI