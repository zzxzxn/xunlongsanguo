local TaskUI = class("TaskUI", BaseUI)
local ClassActiveBox = require('script/app/ui/mainscene/activeboxui')
local ClassItemCell = require('script/app/global/itemcell')
local KingLvUpUI = require("script/app/ui/mainscene/kinglvup")
local BASE_YEAR = 220

local DAILY_PAGE = 3
local TASK_PAGE = 1
local ALL_PAGE = 2
local MAX_CAMP = 10
local TITLE_TEXTURE_NOR = {
	'uires/ui/common/title_btn_nor_3.png',
	'uires/ui/common/title_btn_nor_3.png',
	'uires/ui/common/title_btn_nor_1.png',
}
local TITLE_TEXTURE_SEL = {
	'uires/ui/common/title_btn_sel_3.png',
	'uires/ui/common/title_btn_sel_3.png',
	'uires/ui/common/title_btn_sel_1.png',
}

local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
	[6] = 'RED'
}

function TaskUI:ctor(page,data,callback)
	self.uiIndex = GAME_UI.UI_TASK
	self.page = page or 1
	self.data = data
	self.intervalSize = 2
	self.zxIntervalSize = 15
	self.mrRt = {}
	self.zxRt = {}
	self.boxRt = {}
	self.mrLockRTs = {}
	self.zxLockRTs = {}
	self.showIndex = 0
	self.currMainNum = 0
	self.oldMainNum = 0
	self.progress = MapData:getFightedCityId()
	self.callback = callback
end

function TaskUI:getMinProgress()
	local conf = GameData:getConfData('achievement')
	local egg = UserData:getUserObj():getEgg()
	local min = 0
	local currProgress = 1
	for i,v in ipairs(conf) do
		if egg >= v.egg then
			min = i
			currProgress = min + 1
		end
	end
	min = math.floor(min/5)*5
	local isMax = false
	if min >= #conf then
		min = #conf - 5
		isMax = true
	end
	return min,currProgress,isMax
end

function TaskUI:showAttr()
	if self.showIndex and self.showIndex > 0 then
		MainSceneMgr:showTaskAtt(1,self.showIndex)
		self.showIndex = 0
	end
end

function TaskUI:updateEgg()
	local pl = self.mainBgImg:getChildByName('bottom_pl')
	local descTx1 = pl:getChildByName('desc_1_tx')
	local nameTx = pl:getChildByName('name_tx')
	local descTx3 = pl:getChildByName('desc_3_tx')
	local numTx1 = pl:getChildByName('num_1_tx')
	local numTx2 = pl:getChildByName('num_2_tx')
	local barBg = pl:getChildByName('bar_bg')
	local bar = barBg:getChildByName('bar')
	local minProgress,currProgress,isMax = self:getMinProgress()
	local conf = GameData:getConfData('achievement')
	local egg = UserData:getUserObj():getEgg()
	local award = DisplayData:getDisplayObj({'user','egg',egg})
	for i=1,5 do
		local bgBtn = pl:getChildByName('bg_'..i..'_btn')
		local num = conf[i + minProgress].egg
		-- bgBtn:setTouchEnabled(num <= egg)
		bgBtn:setBright(num <= egg)
		bgBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	MainSceneMgr:showTaskAtt(1,i + minProgress)
		    end
		end)
	end
	for i=1,3 do
		local descTx = pl:getChildByName('desc_'..i..'_tx')
		descTx:setString(GlobalApi:getLocalStr('TASK_DESC_'..i))
	end
	numTx1:setString(egg)
	if isMax then
		numTx2:setString(0)
	else
		numTx2:setString(conf[currProgress].egg - egg)
	end
	nameTx:setString(award:getName())
	local maxEgg = conf[minProgress + 5].egg
	local minEgg = 0
	if conf[minProgress] then
		minEgg = conf[minProgress].egg
	end
	bar:setPercent((egg - minEgg)/(maxEgg - minEgg)*100)

	local arrBtn = pl:getChildByName('arr_btn')
	arrBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	MainSceneMgr:showTaskAtt(2)
	    end
	end)
	if self.oldProgress and self.oldProgress ~= currProgress - 1 then
		self.showIndex = currProgress - 1
		RoleData:setAllFightForceDirty()
		for i=1,7 do
			local obj = RoleData:getRoleByPos(i)
			if obj and obj:getId() > 0 then
				RoleMgr:popupTips(obj,true)
			end
		end
	end
	self.oldProgress = currProgress - 1
end

function TaskUI:updateZX()
	local conf = GameData:getConfData('task')
	local size1
	self.currMainNum = #self.newMainConf
	for i,v in ipairs(self.newMainConf) do
		-- local index = self.data.task.main[tostring(i)] or 1
		local progress = v.progress
		local status = v.status
		local data = v.data
		local taskBgImg = self.mainSv:getChildByTag(i+1000)
		if not taskBgImg then
			local cellNode = cc.CSLoader:createNode('csb/taskmaincell.csb')
			taskBgImg = cellNode:getChildByName('task_bg_img')
			taskBgImg:removeFromParent(false)
			self.mainSv:addChild(taskBgImg,1,i+1000)
		end
		size1 = taskBgImg:getContentSize()
		taskBgImg:setPosition(cc.p((size1.width + self.zxIntervalSize) * (i - 1) + self.zxIntervalSize,0))
		local titleImg = taskBgImg:getChildByName('title_img')
		local titleTx = titleImg:getChildByName('title_tx')
		local descTx = taskBgImg:getChildByName('desc_tx')
		local infoTx = taskBgImg:getChildByName('info_tx')
		titleTx:setString(data.name)
		descTx:setString(data.desc)
		local awards = DisplayData:getDisplayObjs(data.award)
		for i=1,2 do
			local awardBgImg = taskBgImg:getChildByName('award_'..i..'_img')
			if not awardBgImg then
				local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
				awardBgImg = tab.awardBgImg
				awardBgImg:setScale(0.8)
				awardBgImg:setName('award_'..i..'_img')
				taskBgImg:addChild(awardBgImg)
				awardBgImg:setPosition(cc.p(70 + 90*(i - 1),135))
			end
			if awards[i] then
				awardBgImg:setVisible(true)
				ClassItemCell:updateItem(awardBgImg, awards[i], 2)
				awardBgImg:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						GetWayMgr:showGetwayUI(awards[i],false)
					end
				end)
			else
				awardBgImg:setVisible(false)
			end
		end

		local x = ((progress > data.target) and data.target) or progress
		local tx = x..'/'..data.target
		infoTx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC12')..tx)

		local gotoBtn = taskBgImg:getChildByName('goto_btn')
		local infoTx = gotoBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
		local getBtn = taskBgImg:getChildByName('get_btn')
		local infoTx = getBtn:getChildByName('info_tx')
		infoTx:setString(GlobalApi:getLocalStr('STR_GET_1'))
		local level = UserData:getUserObj():getLv()
		local desc,isOpen = GlobalApi:getGotoByModule(data.key,true)
		if not desc then
			if self.zxLockRTs[i] then
				self.zxLockRTs[i].richText:setVisible(false)
			end
			if status >= tonumber(data.goalId) then
				getBtn:setVisible(true)
				getBtn:setBright(false)
				getBtn:setTouchEnabled(false)
				-- infoTx:setColor(COLOR_TYPE.WHITE)
				-- infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
				gotoBtn:setVisible(false)
			elseif progress >= data.target then
				getBtn:setVisible(true)
				getBtn:setBright(true)
				getBtn:setTouchEnabled(true)
				gotoBtn:setVisible(false)
				-- infoTx:setColor(COLOR_TYPE.WHITE)
				-- infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
				getBtn:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						local args = {id = v.id}
						MessageMgr:sendPost('mainline_reward','task',json.encode(args),function (response)
					        
					        local code = response.code
					        local resData = response.data
					        if code == 0 then
                                local lastLv = UserData:getUserObj():getLv()

					        	local awards = resData.awards
					            if awards then
					                GlobalApi:parseAwardData(awards)
					            end
					            local costs = resData.costs
			                    if costs then
			                        GlobalApi:parseAwardData(costs)
			                    end
					            local progress = resData.progress
					            if progress then
					            	self.data.task.main[tostring(v.id)] = progress
					            end
					            -- self.newMainConf[i].status = v.id
					            self.data.task.main_reward[tostring(v.id)] = data.goalId
					            self:getZxData()
					            self:updatePanel()
					            if awards then
                                    GlobalApi:showAwards(awards, nil, nil, function()
					            		self:showAttr()
					            		GlobalApi:showAwardsCommonByText(awards, true)
					            	end)
					            end


                                local nowLv = UserData:getUserObj():getLv()
                                GlobalApi:showKingLvUp(lastLv,nowLv)

					        end
					    end)
				    end
				end)
			else
				getBtn:setVisible(false)
				getBtn:setTouchEnabled(false)
				gotoBtn:setVisible(true)
				gotoBtn:addTouchEventListener(function (sender, eventType)
					if eventType == ccui.TouchEventType.began then
			            AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
						local key = data.key
						GlobalApi:getGotoByModule(key)
						self:hideMySelf(true)
				    end
				end)
			end
		else
			getBtn:setVisible(false)
			gotoBtn:setVisible(false)
			-- lockInfoTx:setString(string.format(GlobalApi:getLocalStr('LV_LIMIT'),openLevel))
			-- lockInfoTx:setString(desc)
			if not self.zxLockRTs[i] then
				local richText = xx.RichText:create()
				richText:setContentSize(cc.size(450, 30))
				richText:setAlignment('middle')
  				richText:setVerticalAlignment('middle')
  				local tx1,tx2
				if isOpen == 1 then
					tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
					tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
				else
					tx1 = ''
					tx2 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
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
				richText:setPosition(cc.p(size1.width/2,45))
				taskBgImg:addChild(richText)
				self.zxLockRTs[i] = {richText = richText,re1 = re1,re2 = re2,re3 = re3}
			else
				self.zxLockRTs[i].richText:setVisible(true)
			end
		end
	end
	if size1 then
		local size = self.mainSv:getContentSize()
	    if (size1.width + self.zxIntervalSize) * #self.newMainConf + self.zxIntervalSize > size.width then
	        self.mainSv:setInnerContainerSize(cc.size((size1.width + self.zxIntervalSize) * #self.newMainConf + self.zxIntervalSize,size.height))
	    else
	        self.mainSv:setInnerContainerSize(size)
	    end
	end
	self:updateEgg()
	for i=self.currMainNum + 1,self.oldMainNum do
		local taskBgImg = self.mainSv:getChildByTag(i+1000)
		if taskBgImg then
			taskBgImg:removeFromParent()
		end
	end
	self.oldMainNum = self.currMainNum

end

function TaskUI:playEffect(img)
    if img.lvUp then
        img.lvUp:removeFromParent()
        img.lvUp = nil
    end
    

    local parent = img:getParent()
    local img = img
    local posX = img:getPositionX()
    local posY = img:getPositionY()

    local size1 = img:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(posX ,posY + 65))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img:setLocalZOrder(101)
    --lvUp:setScale(0.75)
    parent:addChild(lvUp)

    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)

    img.lvUp = lvUp
end

function TaskUI:createImgs()
    local awardBgImg = ccui.ImageView:create('uires/ui/common/frame_yellow.png')
    awardBgImg:setName("award_bg_img")
    local size = awardBgImg:getContentSize()
    local awardImg = ccui.ImageView:create()
    awardImg:setPosition(cc.p(size.width/2,size.height/2))
    awardImg:setName('award_img')
    awardBgImg:addChild(awardImg)
    return awardBgImg
end

function TaskUI:updateAllCampTop()
	local infoImg = self.allCampPl:getChildByName('info_img_1')
	local nameTx = infoImg:getChildByName('name_tx')
	local fightforceTx = infoImg:getChildByName('fightforce_tx')
	local numTx = infoImg:getChildByName('num_tx')
	local descTx = infoImg:getChildByName('desc_tx')
	local headnode = infoImg:getChildByName('head_node')
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
	headnode:addChild(cell.awardBgImg)
	local sv = infoImg:getChildByName('sv')
	sv:setScrollBarEnabled(false)

	local role = RoleData:getMainRole()
	nameTx:setString(UserData:getUserObj():getName())
	numTx:setString(self.progress + 1)
	descTx:setString(GlobalApi:getLocalStr('TASK_MAP_DESC_1'))
	fightforceTx:setString(UserData:getUserObj():getFightforce())
	cell.awardBgImg:loadTexture(role:getBgImg())
	cell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
	cell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
	cell.headframeImg:setVisible(true)
	local treasureInfo = UserData:getUserObj():getTreasure()
	local conf = GameData:getConfData("treasure")[tonumber(treasureInfo.id)]
	local level = treasureInfo.id
	dump(treasureInfo)
	local size = sv:getContentSize()
	local size1
	local scale = 0.6
	for i=1,level do
		local awardBgImg = self:createImgs()
		local awardImg = awardBgImg:getChildByName('award_img')
		awardBgImg:setScale(scale)
		awardImg:loadTexture('uires/ui/treasure/treasure_00'..i..'.png')
		size1 = awardBgImg:getContentSize()
		awardBgImg:setPosition(cc.p((size1.width*scale + 5)* (i - 0.5),size.height/2))
		sv:addChild(awardBgImg)
	end
	if size1 then
		sv:setInnerContainerSize(cc.size((size1.width*scale + 5)* level + 5,size.height))
	end
end

function TaskUI:updateAllCampBottom(i)
	local conf = GameData:getConfData('worldsituation')[i or self.worldId or 1]
	local infoImg = self.allCampPl:getChildByName('info_img_2')
	local nameTx = infoImg:getChildByName('name_tx')
	local fightforceTx = infoImg:getChildByName('fightforce_tx')
	local numTx = infoImg:getChildByName('num_tx')
	local descTx = infoImg:getChildByName('desc_tx')
	local headnode = infoImg:getChildByName('head_node')
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
	headnode:addChild(cell.awardBgImg)
	local pos1 = {cc.p(146.5,38),cc.p(212,38)}
	if self.progress + 1 > #MapData.data then
		infoImg:setVisible(false)
		self.campNumTx:setVisible(false)
		self.txytImg:setVisible(true)
		self.descTx:setVisible(false)
	else
		self.descTx:setVisible(true)
		self.txytImg:setVisible(false)
		self.campNumTx:setVisible(true)
		infoImg:setVisible(true)
		cell.awardImg:loadTexture(conf.url)
		local cityId = self.campCityId[conf.camp]
		local cityData = MapData.data[cityId]
		fightforceTx:setString(cityData:getFightforce(1))
		nameTx:setString(conf.name)
		numTx:setString(self.campCityNums[conf.camp])
		cell.awardBgImg:loadTexture(COLOR_ITEMFRAME[FRAME_COLOR[conf['quality']]])

		local dragonBgImg = infoImg:getChildByName('item_bg_img')
		local dragonImg = dragonBgImg:getChildByName('role_img')
		local dragon = cityData:getDragon()
		if cityId == #MapData.data then
			dragonBgImg:setVisible(false)
			pos1 = {cc.p(81,38),cc.p(146.5,38)}
		else
			dragonBgImg:setVisible(true)
			dragonImg:loadTexture('uires/ui/treasure/treasure_00'..dragon..'.png')
		end
		descTx:setString(GlobalApi:getLocalStr('CITY_CELL_DESC_1'))

		local awards = DisplayData:getDisplayObjs(conf.award)
		for i=1,2 do
			local awardBgImg = infoImg:getChildByName('award_'..i..'_img')
			if not awardBgImg then
				local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
				awardBgImg = tab.awardBgImg
				awardBgImg:setScale(0.6)
				awardBgImg:setName('award_'..i..'_img')
				infoImg:addChild(awardBgImg)
			end
			awardBgImg:setPosition(pos1[i])
			local numTx = awardBgImg:getChildByName('lv_tx')
			if awards[i] then
				awardBgImg:setVisible(true)
				ClassItemCell:updateItem(awardBgImg, awards[i], 2)
				numTx:setString(awards[i]:getNum())
			else
				awardBgImg:setVisible(false)
			end
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local point1 = sender:getTouchBeganPosition()
                    local point2 = sender:getTouchEndPosition()
                    if point1 then
                        local dis =cc.pGetDistance(point1,point2)
                        if dis <= 5 then
                            GetWayMgr:showGetwayUI(awards[i],false)
                        end
                    end
                end
            end)
		end
	end
end

function TaskUI:getIdByCamp(currCamp)
	local conf = GameData:getConfData('worldsituation')
	for i,v in ipairs(conf) do
		if v.camp == currCamp then
			return v.id
		end
	end
end

function TaskUI:getAllCampCityNums()
	self.campCityNums = {}
	self.campCityId = {}
	if self.progress + 1 > #MapData.data then
	else
		local currCamp = MapData.data[self.progress + 1]:getCamp()
		self.worldId = self:getIdByCamp(currCamp)
		for i = self.progress + 1,#MapData.data do
			local camp = MapData.data[i]:getCamp()
			if self.campCityNums[camp] then
				self.campCityNums[camp] = self.campCityNums[camp] + 1
			else
				self.campCityNums[camp] = 1
			end
			self.campCityId[camp] = i
		end
	end
end

function TaskUI:getAward(i)
	local args = {
		id = i
	}
    MessageMgr:sendPost("world_situation_reward", "task", json.encode(args), function (jsonObj)
        if jsonObj.code == 0 then
        	self.data.task.world_reward[tostring(i)] = 1
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
			GlobalApi:showAwardsCommon(awards,nil,nil,true)
			self:updatePanel()
        end
    end)
end

function TaskUI:updateList(index,conf,isBegin)
	-- local lastyear = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_year_'..(index - 1),''))
	-- local lastmonth = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_month_'..(index - 1),''))
	-- local year = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_year_'..index,''))
	-- local month = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_month_'..index,''))
	local year,month
	local tx,tx1,tx2,tx3,tx4
	if isBegin then
		year = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_year_'..(index - 1),''))
		month = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_month_'..(index - 1),''))
		if not year then
			year = BASE_YEAR
		end
		tx2 = GlobalApi:getLocalStr('TASK_MAP_DESC_3')
		tx4 = GlobalApi:getLocalStr('TASK_MAP_DESC_4')..'\n'
		if not month then
			month = math.random(1,6)
			cc.UserDefault:getInstance():setStringForKey('power_end_month_'..(index - 1),month)
		end
		month = month + 6
	else
		year = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_year_'..index,''))
		month = tonumber(cc.UserDefault:getInstance():getStringForKey('power_end_month_'..index,''))
		tx2 = GlobalApi:getLocalStr('TASK_MAP_DESC_5')
		tx4 = GlobalApi:getLocalStr('TASK_MAP_DESC_6')..'\n'
		if not month then
			month = math.random(1,6)
			cc.UserDefault:getInstance():setStringForKey('power_end_month_'..index,month)
		end
		if not year then
	        local baseYear = BASE_YEAR + (index - 1)*6 + 1
	        year = math.random(baseYear,baseYear + 5)
	        cc.UserDefault:getInstance():setStringForKey('power_end_year_'..index,year)
	    end
	end
	-- if not month or month == '' then
	-- 	month = math
	-- 	cc.UserDefault:getInstance():setStringForKey('power_end_month_'..id,year)
	-- end
	tx = string.format(GlobalApi:getLocalStr('TASK_MAP_DESC_7'),year,month)..'   '
	tx1 = UserData:getUserObj():getName()
	tx3 = conf[index].name
	local i = 100 * index + (isBegin == true and 1 or 2)
	if not self.listRts[i] then
		local re = xx.RichTextLabel:create(tx, 22, COLOR_TYPE.WHITE)
		re:setMinWidth(120)
		re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		local re1 = xx.RichTextLabel:create(tx1, 22, COLOR_TYPE.YELLOW)
		re1:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
		local re2 = xx.RichTextLabel:create(tx2, 22, COLOR_TYPE.WHITE)
		re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		local re3 = xx.RichTextLabel:create(tx3, 22, COLOR_TYPE.ORANGE)
		re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
		local re4 = xx.RichTextLabel:create(tx4, 22, COLOR_TYPE.WHITE)
		re4:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		self.listRts.richText:addElement(re)
		self.listRts.richText:addElement(re1)
		self.listRts.richText:addElement(re2)
		self.listRts.richText:addElement(re3)
		self.listRts.richText:addElement(re4)
		self.listRts[i] = {re = re,re1 = re1,re2 = re2,re3 = re3,re4 = re4}
	else
		self.listRts[i].re:setString(tx)
		self.listRts[i].re1:setString(tx1)
		self.listRts[i].re2:setString(tx2)
		self.listRts[i].re3:setString(tx3)
		self.listRts[i].re4:setString(tx4)
	end
end

function TaskUI:updateAllCamp()
	local bgImg = self.allCampPl:getChildByName('bg_img')
	self.campNumTx = bgImg:getChildByName('camp_num_tx')
	self.descTx = bgImg:getChildByName('desc_tx')
	self.descTx:setString(GlobalApi:getLocalStr('TASK_MAP_DESC_8'))
	local listBtn = bgImg:getChildByName('list_btn')
	local listImg = bgImg:getChildByName('list_img')
	self.txytImg = bgImg:getChildByName('txyt_img')
	local rtSv = listImg:getChildByName('rt_sv')
	rtSv:setScrollBarEnabled(false)
	local infoTx = listBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('TASK_MAP_DESC_2'))
	local conf = GameData:getConfData('worldsituation')
	local data = self.data.task.world_reward
	self:getAllCampCityNums()
	local num = 0
	local isEnd = false

	if not self.listRts then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(498,980))
		richText:setAlignment('left')
		richText:setVerticalAlignment('top')
	    richText:setAnchorPoint(cc.p(0,1))
	    richText:setPosition(cc.p(0,330))
	    rtSv:addChild(richText)
	    self.listRts = {richText = richText}
	end

	local isBegin = true
	for i=1,MAX_CAMP do
		local mapImg = bgImg:getChildByName('map_img_'..i)
		local nameImg = bgImg:getChildByName('name_img_'..i)
		local cityImg = bgImg:getChildByName('city_img_'..i)
		local numTx = cityImg:getChildByName('num_tx')
		local boxBgImg = bgImg:getChildByName('tribute_box_bg_img_'..i)
		if conf[i].target <= self.progress then
			-- mapImg:setVisible(true)
			self:updateList(i,conf,true)
			self:updateList(i,conf,false)
			num = num + 1
			mapImg:setTouchEnabled(false)
			if not data or not data[tostring(i)] then
                local posX = nameImg:getPositionX()
                local posY = nameImg:getPositionY()
                if not boxBgImg then
                	boxBgImg = ccui.ImageView:create('uires/ui/task/task_guang.png')
                	boxBgImg:setAnchorPoint(cc.p(0.5,0.3))
                	boxBgImg:setPosition(cc.p(posX,posY))
                	boxBgImg:setName('tribute_box_bg_img_'..i)
                	local size = boxBgImg:getContentSize()
	                local boxImg = ccui.ImageView:create('uires/ui/common/box4.png')
	                boxImg:setName('tribute_box_img_'..i)
	                boxImg:setScale(0.7)
	                boxImg:setAnchorPoint(cc.p(0.5,0.2))
	                boxImg:setPosition(cc.p(size.width/2,10))
	                boxBgImg:addChild(boxImg)
	                bgImg:addChild(boxBgImg)
	                boxBgImg:setTouchEnabled(true)
	                boxImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
	                    cc.RotateBy:create(0.025, 15),
	                    cc.RotateBy:create(0.025, -15),
	                    cc.RotateBy:create(0.025, 0),
	                    cc.RotateBy:create(0.025, -15),
	                    cc.RotateBy:create(0.025, 15),
	                    cc.DelayTime:create(1))))
	                boxBgImg:addTouchEventListener(function (sender, eventType)
	                    if eventType == ccui.TouchEventType.began then
	                        AudioMgr.PlayAudio(11)
	                    elseif eventType == ccui.TouchEventType.ended then
						    mapImg:runAction(cc.Sequence:create(cc.Repeat:create(
						        cc.Sequence:create(
						            cc.FadeIn:create(0.2),
						            cc.DelayTime:create(0.1),
						            cc.FadeOut:create(0.2),
						            cc.DelayTime:create(0.1)
						            ),
						        2),cc.FadeIn:create(0.2),cc.CallFunc:create(function()
						            self:getAward(i)
						        end)))
	                    end
	                end)
	            end
                nameImg:setVisible(false)
                if data[tostring(i)] ~= 1 then
                	mapImg:setOpacity(0)
                else
                	mapImg:setOpacity(255)
                end
            else
            	nameImg:setVisible(true)
				nameImg:loadTexture('uires/ui/mainscene/mainscene_flag.png')
				nameImg:setScale(0.8)
				if boxBgImg then
					boxBgImg:removeFromParent()
				end
			end
			cityImg:setVisible(false)
		else
        	if isBegin then
        		self:updateList(i,conf,true)
        		isBegin = false
        	end
			if boxBgImg then
				boxBgImg:removeFromParent()
			end
			nameImg:setVisible(true)
			cityImg:setVisible(true)
			-- mapImg:setVisible(false)
			mapImg:setOpacity(0)
			mapImg:setTouchEnabled(true)
			nameImg:loadTexture(conf[i].nameUrl)
			numTx:setString(self.campCityNums[conf[i].camp])
		end
		nameImg:ignoreContentAdaptWithSize(true)
		mapImg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				self:updateAllCampBottom(i)
		    end
		end)
	end
	self.listRts.richText:format(true)
	local height = self.listRts.richText:getBrushY()
	local size = rtSv:getContentSize()
	if size.height < height then
		rtSv:setInnerContainerSize(cc.size(size.width,height))
		self.listRts.richText:setPosition(cc.p(0,height))
	else
		rtSv:setInnerContainerSize(cc.size(size.width,size.height))
		self.listRts.richText:setPosition(cc.p(0,size.height))
	end

	self.campNumTx:setString(num..'/'..MAX_CAMP)
	listImg:setLocalZOrder(1)
	listImg:setVisible(false)
	local backBtn = listImg:getChildByName('back_btn')
	local infoTx = backBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('STR_RETURN_1'))
	listBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			listImg:setVisible(true)
	    end
	end)
	backBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			listImg:setVisible(false)
	    end
	end)

	local spine = bgImg:getChildByName('map_fight')
	if self.worldId then
		if not spine then
		    spine = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
		    spine:setName('map_fight')
		    bgImg:addChild(spine)
		    spine:setAnimation(0, "animation", true)
		end
		local nameImg = bgImg:getChildByName('name_img_'..self.worldId)
		local posX = nameImg:getPositionX()
		local posY = nameImg:getPositionY()
		spine:setPosition(cc.p(posX, posY))
		spine:setVisible(true)
	else
		if spine then
			spine:setVisible(false)
		end
	end

	self:updateAllCampTop()
	self:updateAllCampBottom()
	-- self:updateList()
end

function TaskUI:updatePanel()
	self.mainBgImg:setVisible(self.page == TASK_PAGE)
	--self.dayBgImg:setVisible(self.page == DAILY_PAGE)
	self.dayBgImg:setVisible(false)
	self.allCampPl:setVisible(self.page == ALL_PAGE)
	--local signs = {self:getMRstatus(),self:getZXstatus(),self:getAllOnwerStatus()}
	local signs = {self:getZXstatus(),self:getAllOnwerStatus()}
    for i=1,2 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        local newImg = self.pageBtns[i]:getChildByName('new_img')
        newImg:setVisible(signs[i] == 1)
        if i == self.page then
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_SEL[i])
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i]:loadTexture(TITLE_TEXTURE_NOR[i])
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end


	--if self.page == DAILY_PAGE then
		--self:updateMR()
	--else
	if self.page == TASK_PAGE then
		self:updateZX()
	else
		self:updateAllCamp()
	end
end

function TaskUI:getCurrActive()
	local active = 0
	local conf = GameData:getConfData('dailytask')
	for i,v in ipairs(self.newData) do
		if v.status == 2 then
			local awards = conf[v.id]['award']
			for i,v in ipairs(awards) do
				if v[2] == 'active' then
					active = v[3] + active
				end
			end
		end
	end
	return active
end

function TaskUI:sortMainData()
	local function sortFn(a,b)
		local statusA = (a.status < tonumber(a.data.goalId)) and (a.progress >= a.data.target)
		local statusB = (b.status < tonumber(b.data.goalId)) and (b.progress >= b.data.target)
		if statusA == statusB then
			return a.id < b.id
		end
		return statusA
	end
	table.sort( self.newMainConf, sortFn )
end

function TaskUI:sortNewData()
	local function sortFn(a,b)
		if a.status == b.status then
			if a.isOpen == b.isOpen then
				return a.id < b.id
			end
			return a.isOpen < b.isOpen
		end
		return a.status < b.status
	end
	table.sort( self.newData, sortFn )
end

function TaskUI:getZxData()
	self.newMainConf = {}
	local conf1 = GameData:getConfData('task')
	for i,v in ipairs(conf1) do
		-- local index = self.data.task.main[tostring(i)] or 1
		local progress = self.data.task.main[tostring(i)] or 0
		local status = self.data.task.main_reward[tostring(i)] or 0
		local index = status + 1
		for j,k in ipairs(v) do
			if index == j then
				self.newMainConf[#self.newMainConf + 1] = {data = k,status = tonumber(status),progress = progress,id = i}
			end
		end
	end
	self:sortMainData()
end

function TaskUI:getMrData()
	local conf = GameData:getConfData('dailytask')
	local maxNum = #conf
	self.newData = {}
	for i=1,#conf do
		local isOpen = true
		if conf[i].key == 'xpRescopy' or conf[i].key == 'destinyRescopy' then
			isOpen = GlobalApi:getOpenInfo(conf[i].key)
		end
		if isOpen then
			local status = self.data.task.daily_reward[tostring(i)] or 2
			local times = self.data.task.daily[tostring(i)] or 0
			if status ~= 1 and times >= (conf[i].target or 0) then
				status = 0
			elseif status ~= 1 and times < (conf[i].target or 0) then
				status = 1
			else
				status = 2
			end
			local desc,isOpen = GlobalApi:getGotoByModule(conf[i].key,true)
			if not desc then
				isOpen = 0
			end
			self.newData[#self.newData + 1] = {times = times,status = status,id = conf[i].id,active = active,isOpen = isOpen}
		end
	end
	self:sortNewData()
end

function TaskUI:getZXstatus()
	local isSign = 0
	for i,v in ipairs(self.newMainConf) do
		local progress = v.progress
		local status = v.status
		local data = v.data
		if status < tonumber(data.goalId) and progress >= data.target then
			isSign = 1
			break
		end
	end
	return isSign
end

function TaskUI:getAllOnwerStatus()
	local isSign = 0
	local conf = GameData:getConfData('worldsituation')
	local data = self.data.task.world_reward
	for i=1,MAX_CAMP do
		if conf[i].target <= self.progress and data[tostring(i)] ~= 1 then
			isSign = 1
			break
		end
	end
	return isSign
end

function TaskUI:hideMySelf(ntype)
	--UserData:getUserObj():setSignByType('daily_task',self:getMRstatus())
	UserData:getUserObj():setSignByType('main_task',self:getZXstatus())
	UserData:getUserObj():setSignByType('world_reward',self:getAllOnwerStatus())
	if not ntype then
		if self.callback then
			self.callback()
		end
		MainSceneMgr:hideTask()
	else
		MainSceneMgr:hideTask1()
	end
end

function TaskUI:init()
	local bgImg = self.root:getChildByName("task_bg_img")
	local taskImg = bgImg:getChildByName("task_img")
    self:adaptUI(bgImg, taskImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    taskImg:setPosition(cc.p(winSize.width/2 + 7,winSize.height/2 - 40))

    self.allCampPl = taskImg:getChildByName('all_camp_pl')
    self.mainBgImg = taskImg:getChildByName('main_bg_img')
    self.mainSv = self.mainBgImg:getChildByName('main_sv')
    self.mainSv:setScrollBarEnabled(false)
    self.dayBgImg = taskImg:getChildByName('day_bg_img')
    self.cardSv = self.dayBgImg:getChildByName('cell_sv')
    self.cardSv:setScrollBarEnabled(false)
    local closeBtn = taskImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			self:hideMySelf()
	    end
	end)

    self.pageBtns = {}
    local STR = {
		GlobalApi:getLocalStr('MAIN_TASK'),
		GlobalApi:getLocalStr('LAND_TASK'),
	}
    for i=1,2 do
    	local pageBtn = taskImg:getChildByName('page_'..i..'_img')
    	local infoTx = pageBtn:getChildByName('info_tx')
    	infoTx:setString(STR[i])
    	pageBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				self.page = i
				self:updatePanel()
		    end
		end)
		self.pageBtns[i] = pageBtn
    end
    --self:getMrData()
    self:getZxData()
	self:updatePanel()
end

return TaskUI