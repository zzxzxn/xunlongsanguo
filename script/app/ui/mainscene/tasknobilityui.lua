local TaskNobilityUI = class("TaskNobilityUI", BaseUI)

local nobilityIconUrl = "uires/ui/worldwar/worldwar_"
local lightStarUrl = {
	light = "uires/ui/common/icon_star3.png",
	dark = "uires/ui/common/icon_star3_bg.png",
}

local stateImgUrl = {
	open = "uires/ui/text/yikaiqi.png",
	close = "uires/ui/text/weikaiqi.png",
}
local privilegeIconUrl = "uires/ui/task/task_"

local iconRes = {
	"uires/ui/common/atk_icon.png",
	"uires/ui/common/def_icon.png",
	"uires/ui/common/mdf_icon.png",
	"uires/ui/common/hp_icon.png",
}
function TaskNobilityUI:ctor(curNobilityId,star)
	 self.uiIndex = GAME_UI.UI_NEW_TASK_NOBILITY
	 self.curNobilityId = curNobilityId
	 self.star = star
end

function TaskNobilityUI:init()

	self.nobilityTab = GameData:getConfData('nobiltybase')

	local alphaBg = self.root:getChildByName("bg_img")
	local bg = alphaBg:getChildByName("bg_img1")
	self:adaptUI(alphaBg, bg)

	--左侧界面
	local leftBg = bg:getChildByName("left_bg")
	self.cardSv = leftBg:getChildByName("nobility_sv")
	self.cardSv:setScrollBarEnabled(false)

	--右侧界面
	local rightBg = bg:getChildByName("right_bg")
	local depBg = rightBg:getChildByName("deep_bg")
	self.attrBg = depBg:getChildByName("attr_bg")
	local titleTx = self.attrBg:getChildByName("title_tx")
	titleTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT50"))
	
	--属性显示
	self.attrInfo = {}
	for i=1,2 do
		local attrinfo = self.attrBg:getChildByName("attr_info" .. i)
		self.attrInfo[i] = attrinfo
	end
	self.width = self.attrBg:getContentSize().width

	--特权展示
	self.privilege = {}
	for i=1,3 do
		local privilegeBg = rightBg:getChildByName("prerogative_" .. i)
		self.privilege[i] = privilegeBg
	end

	local closeBtn = bg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
    	if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideTaskNobilityUI()
        end
    end)
	self:loadNobilityCell()
end

function TaskNobilityUI:loadNobilityCell()

	self.chooseImg = {}
	local size1
	for i=1,#self.nobilityTab do
		local cellBg = self.cardSv:getChildByTag(i + 100)
	    if not cellBg then
		    local cell = cc.CSLoader:createNode('csb/task_nobility_cell.csb')
		    cellBg = cell:getChildByName('cell_bg')
		    cellBg:removeFromParent(false)
		    self.cardSv:addChild(cellBg,1,i+100)
	    end

	    size1 = cellBg:getContentSize()
		local guangBg = cellBg:getChildByName("guang_bg")
		guangBg:setVisible(false)
		self.chooseImg[i] = guangBg
		--爵位显示
		local nobilityIcon = cellBg:getChildByName("nobility_icon")
		nobilityIcon:loadTexture(nobilityIconUrl .. self.nobilityTab[i].icon)
		local nobilityNameTx = nobilityIcon:getChildByName("name")
		nobilityNameTx:setString(self.nobilityTab[i].name)

		--是否为当前爵位
		local curTx = cellBg:getChildByName("cur_tx")
		if i == self.curNobilityId then
			curTx:setString(GlobalApi:getLocalStr("TOWER_DESC_10") .. ":")
		else
			curTx:setString("")
		end

		--星级显示
		for j=1,3 do
			local star = cellBg:getChildByName("star_" .. j)
			if i<self.curNobilityId then
				star:loadTexture(lightStarUrl.light)
			elseif i == self.curNobilityId then
				if j <= self.star then
					star:loadTexture(lightStarUrl.light)
				else
					star:loadTexture(lightStarUrl.dark)
				end
			else
				star:loadTexture(lightStarUrl.dark)
			end
		end
		--nobilityIcon:setSwallowTouches(false)
		nobilityIcon:addTouchEventListener(function (sender, eventType)
        	if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            self:chooseNobilty(i)
	        end
	    end)
	end

	if not size1 then
		return
	end

	local maxNum = #self.nobilityTab
	local size = self.cardSv:getContentSize()
    if maxNum * size1.height > size.height then
        self.cardSv:setInnerContainerSize(cc.size(size.width,(maxNum * size1.height)))
    else
        self.cardSv:setInnerContainerSize(size)
    end
    local function getPos(i)
    	local size2 = self.cardSv:getInnerContainerSize()
		return cc.p(0,size2.height - size1.height * i)
	end
	for i=1,maxNum do
		local cellBg = self.cardSv:getChildByTag(i + 100)
		if cellBg then
		    cellBg:setPosition(getPos(i))
	    end
	end

	local percent = (self.curNobilityId-1)/#self.nobilityTab*100
	if percent >70 then
		percent = self.curNobilityId/#self.nobilityTab*100
	end
	self.cardSv:jumpToPercentVertical(percent)

	self:chooseNobilty(self.curNobilityId)
end

function TaskNobilityUI:chooseNobilty(id)

	for i=1,#self.nobilityTab do
		if id ==i then
			self.chooseImg[i]:setVisible(true)
		else
			self.chooseImg[i]:setVisible(false)
		end
	end

	self:updateRigthPanelInfo(id)
end

function TaskNobilityUI:updateRigthPanelInfo(id)

	--属性展示
	local posX = self.width/2
	if id < self.curNobilityId  or  (self.curNobilityId == #self.nobilityTab) then
		self.attrInfo[2]:setVisible(false)
		self.attrInfo[1]:setPositionX(posX)

		for i=1,4 do
			local img = self.attrBg:getChildByName("Image_" .. i)
			img:setVisible(false)
		end
	else
		self.attrInfo[2]:setVisible(true)
		self.attrInfo[1]:setPositionX(posX-116)
		for i=1,4 do
			local img = self.attrBg:getChildByName("Image_" .. i)
			img:setVisible(true)
		end
	end

	local nextId = (id == self.curNobilityId) and (self.curNobilityId+1) or id
	if nextId > #self.nobilityTab then
		nextId = #self.nobilityTab
	end

	local curAttr = {0,0,0,0}
	for i=1,2 do
		local nobilityCfgInfo = (i==1) and self.nobilityTab[self.curNobilityId] or self.nobilityTab[nextId]
		local nobilityNameTx = self.attrInfo[i]:getChildByName("name")
		nobilityNameTx:setString(nobilityCfgInfo.name)

		--攻击,物防,法防,生命
		for j=1,4 do
			local attr = self.attrInfo[i]:getChildByName("attr" .. j)
			local numTx = attr:getChildByName("num")
			local value = nobilityCfgInfo["attr" .. j]
			numTx:setString(value)
			local attrName = GlobalApi:getLocalStr("STR_ATT" .. j)
			if j==2 then
				attrName = GlobalApi:getLocalStr("STR_ATT3")
			elseif j == 3  then
				attrName = GlobalApi:getLocalStr("STR_ATT4")
			elseif j ==4 then
				attrName = GlobalApi:getLocalStr("STR_ATT2")
			end
			
			local nameTx = attr:getChildByName("name")
			nameTx:setString(attrName)

			local icon = attr:getChildByName("icon")
			icon:loadTexture(iconRes[j])
		end
	end

	--特权展示
	local privilegeCfg = GameData:getConfData("nobiltytitle")
	for i=1,3 do
		local iconBg = self.privilege[i]:getChildByName("icon_bg")
		local icon = iconBg:getChildByName("icon")
		local desTx = self.privilege[i]:getChildByName("text")
		local stateImg = self.privilege[i]:getChildByName("state_img")
		local state = false
		if id < self.curNobilityId then
			state = true
		elseif id == self.curNobilityId and i<=self.star then
			state = true
		end
		local img = state and stateImgUrl.open or stateImgUrl.close
		stateImg:loadTexture(img)

		--特权描述
		local privilegeId = self.nobilityTab[id]["pg" .. i]
		local privilegeValue = self.nobilityTab[id]["pgnum" .. i]
		desTx:stopAllActions()
		local desc,newDesc = MainSceneMgr:getPrivilegeDesc(id,privilegeId,privilegeValue)
		desTx:setOpacity(255)
		local count = 0
		if not state and newDesc then 
			desTx:setString(newDesc)
			local sequence = cc.Sequence:create(cc.FadeIn:create(0.8),cc.DelayTime:create(0.4),
			cc.FadeOut:create(0.5),cc.DelayTime:create(0.4),
			cc.CallFunc:create(function()
				if count%2 == 0 then
					desTx:setString(desc)
				else
					desTx:setString(newDesc)
				end
				count = count + 1
			end))
			desTx:runAction(cc.RepeatForever:create(sequence))
		else
			desTx:setString(desc)
		end
		--GlobalApi:getLocalStr("TASK_PRIVILEGE_" .. i) ..
		--特权图标
		icon:loadTexture(privilegeIconUrl .. privilegeCfg[privilegeId].icon)
	end

end

return TaskNobilityUI