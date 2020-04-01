local IntegralCarnival = class("integral_carnival")
local ClassItemCell = require('script/app/global/itemcell')

local pageIntegralCarnivalAwardUI = require("script/app/ui/activity/page_integral_carnival_award")

function IntegralCarnival:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
	self.cells = {}
	UserData:getUserObj().activity.integral_carnival = self.msg.integral_carnival
	ActivityMgr:showRightIntegralCarnivalRemainTime()
	self.integralCarnival = ActivityMgr:getLefIntegralCarnival()
	self.integralCarnival:setVisible(true)
	self:updateMark()
	self:updateTop()
	self:initShow()
	self:initBottom()
	self:refreshCount()
end

function IntegralCarnival:updateMark()
    if UserData:getUserObj():getSignByType('integral_carnival') then
		ActivityMgr:showMark("integral_carnival", true)
	else
		ActivityMgr:showMark("integral_carnival", false)
	end
end

function IntegralCarnival:updateTop()
	local helpBtn = self.integralCarnival:getChildByName('help')
	helpBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(47)
        end
    end)

	local des = self.integralCarnival:getChildByName('des')
	des:setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_1'))
	local countTx = self.integralCarnival:getChildByName('count_tx')
	countTx:setString(self.msg.integral_carnival.interval)
	print('====++++' ..  self.msg.integral_carnival.interval)
	self.countTx = countTx
	local countBtn = self.integralCarnival:getChildByName('count_btn')
	local infoTx = countBtn:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_2'))
	countBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local args = {}
			MessageMgr:sendPost("get_integral_carnival_exchange", "activity", json.encode(args), function (response)
				local code = response.code
				if code == 0 then
					local pointsExchageAwardUI = pageIntegralCarnivalAwardUI.new(self.msg.integral_carnival.interval,self,response.data)
					pointsExchageAwardUI:showUI()
				end
			end)

        end
    end)
	self.countBtn = countBtn
end

function IntegralCarnival:initShow()
	local bg = self.rootBG:getChildByName('bg')
	local topBg = bg:getChildByName('top_bg')
	local btn = topBg:getChildByName('btn')
	local tx = btn:getChildByName('tx')
	tx:setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_3'))
	btn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			if self.msg.integral_carnival.rewards == 1 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_26'), COLOR_TYPE.RED)
				return
			end

			promptmgr:showMessageBox(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_29'),
				MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
					local args = {}
					MessageMgr:sendPost("reward_integral_carnival", "activity", json.encode(args), function (response)
						local code = response.code
						if code == 0 then
							local awards = response.data.awards
							if awards then
								GlobalApi:parseAwardData(awards)
								GlobalApi:showAwardsCommon(awards,nil,nil,true)
							end
							local costs = response.data.costs
							if costs then
								GlobalApi:parseAwardData(costs)
							end
							self.msg.integral_carnival.rewards = 1
							self:refreshCount(response.data.integral)
							promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_27'), COLOR_TYPE.GREEN)
						end
					end)

				end)
        end
    end)
	self.btn = btn

	local hasGet = topBg:getChildByName('has_get')
	if self.msg.integral_carnival.rewards == 1 then
		hasGet:setVisible(true)
		btn:setVisible(false)
	else
		hasGet:setVisible(false)
		btn:setVisible(true)
	end

	-- richtext
	if topBg:getChildByName('rich_text') then
		topBg:removeChildByName('rich_text')
	end

	local richText = xx.RichText:create()
	richText:setName('rich_text')
	richText:setContentSize(cc.size(800, 40))
	local ntegralCarnival = tonumber(GlobalApi:getGlobalValue('ntegralCarnival'))
	local data = {
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_19',ntegralCarnival},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_20',self.msg.integral_carnival.rate[1]},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_21',self.msg.integral_carnival.rate[2]},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_22',self.msg.integral_carnival.rate[3]},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_23',self.msg.integral_carnival.rate[4]},
	}
	local resTab = {}
	for i = 1,4 do
		local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr(data[i][1]),data[i][2]), 20, COLOR_TYPE.WHITE)
		re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
		re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
		re1:setFont('font/gamefont.ttf')

		local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_24'), 20, COLOR_TYPE.ORANGE)
		re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
		re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
		re2:setFont('font/gamefont.ttf')
		table.insert(resTab,re1)
		table.insert(resTab,re2)
	end

	local allValue = ntegralCarnival * self.msg.integral_carnival.rate[1] * self.msg.integral_carnival.rate[2] * self.msg.integral_carnival.rate[3] * self.msg.integral_carnival.rate[4]
	local re9 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr(data[5][1]),data[5][2],allValue), 20, COLOR_TYPE.WHITE)
	re9:setStroke(COLOROUTLINE_TYPE.BLACK,1)
	re9:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
	re9:setFont('font/gamefont.ttf')
	table.insert(resTab,re9)

	for i = 1,#resTab do
		local re = resTab[i]
		richText:addElement(re)
	end

	richText:setAlignment('left')
	richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(15,20))
	topBg:addChild(richText)
	richText:format(true)
end

function IntegralCarnival:refreshCount(counts)
    self.msg.integral_carnival.interval = counts or self.msg.integral_carnival.interval
	self.countTx:setString(self.msg.integral_carnival.interval)
	self:initShow()
end

function IntegralCarnival:initBottom()
	local bg = self.rootBG:getChildByName('bg')
	local frame = bg:getChildByName('frame')
	frame:setVisible(false)
	local allWidth = 909
	local cellWidth = 186
	local offset = (allWidth - cellWidth*4)/5

	for i = 1,4 do
		local cell = frame:clone()
		cell:setVisible(true)
		bg:addChild(cell)

		local labels = {}
		for j = 1,4 do
			-- local label = cc.LabelBMFont:create()
			-- label:setFntFile("uires/ui/number/font1_yellownum.fnt")
			local label = cc.LabelAtlas:_create("", "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
			cell:addChild(label)
			if j == 1 then
				label:setPosition(cc.p(80, 175))
			elseif j == 2 then
				label:setPosition(cc.p(138, 118))
			elseif j == 3 then
				label:setPosition(cc.p(80, 64))
			else
				label:setPosition(cc.p(20, 118))
			end
			table.insert(labels,label)
		end
		cell.labels = labels

		local temp = {}
		local confData = GameData:getConfData('avintegralcarnival')[tonumber(i)]
		for k,v in pairs(confData) do
			if type(v) ~= "string" then
				table.insert(temp,clone(v))
			end
		end
		table.sort(temp,function (a,b)  return tonumber(a.id) < tonumber(b.id) end)

		local showImg = cell:getChildByName('show_img')
		local sv = showImg:getChildByName('sv')
		sv:setScrollBarEnabled(false)
		local cellImg = showImg:getChildByName('cell')
		cellImg:setVisible(false)
		local num = #temp
		local size = sv:getContentSize()
		local innerContainer = sv:getInnerContainer()
		local allHeight = size.height
		local cellSpace = 5

		local height = num * cellImg:getContentSize().height + (num - 1)*cellSpace

		if height > size.height then
			innerContainer:setContentSize(cc.size(size.width,height))
			allHeight = height
		end

		local offset2 = 0
		local tempHeight = cellImg:getContentSize().height
		for j = 1,num do
			local tempCell = cellImg:clone()
			tempCell:setVisible(true)
			local size = tempCell:getContentSize()

			local space = 0
			if j ~= 1 then
				space = cellSpace
			end
			offset2 = offset2 + tempHeight + space
			tempCell:setPosition(cc.p(0,allHeight - offset2))
			sv:addChild(tempCell)

			local des1_1 = tempCell:getChildByName('des1_1')
			local des1_2 = tempCell:getChildByName('des1_2')
			local datas = temp[tonumber(j)]
			des1_1:setString(datas.condition)
			des1_2:setString(datas.rate[1] .. '-' .. datas.rate[4])
		end
		innerContainer:setPositionY(size.height - allHeight)

		self:refreshItem(i,cell)
		table.insert(self.cells,cell)
		cell:setPositionX(offset + (i - 1)*(cellWidth + offset))
	end
end

function IntegralCarnival:refreshItem(i,cell)
	local showDatas = {
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_6','ACTIVITY__INTEGRAL_CARNIVAL_DESC_10','ACTIVITY__INTEGRAL_CARNIVAL_DESC_14',self.msg.logins},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_7','ACTIVITY__INTEGRAL_CARNIVAL_DESC_11','ACTIVITY__INTEGRAL_CARNIVAL_DESC_15',self.msg.vip},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_8','ACTIVITY__INTEGRAL_CARNIVAL_DESC_12','ACTIVITY__INTEGRAL_CARNIVAL_DESC_16',self.msg.day_paid},
		{'ACTIVITY__INTEGRAL_CARNIVAL_DESC_9','ACTIVITY__INTEGRAL_CARNIVAL_DESC_13','ACTIVITY__INTEGRAL_CARNIVAL_DESC_17',self.msg.day_money}
	}

	local labels = cell.labels
	local range = self.msg.integral_carnival.range
	local rate = self.msg.integral_carnival.rate
	local turn = self.msg.integral_carnival.turn
	local confData = GameData:getConfData('avintegralcarnival')[tonumber(i)]
	local curCondition = confData[tonumber(range[i])]
	local pos = self.msg.integral_carnival.pos

	for j = 1,4 do
		labels[j]:setString(curCondition.rate[j])
	end

	local loginTx = cell:getChildByName('login_tx')
	loginTx:setString(GlobalApi:getLocalStr(showDatas[i][1]))

	local arrow = cell:getChildByName('arrow')
	arrow:setLocalZOrder(9990)
	local img = cell:getChildByName('img')
	img:setLocalZOrder(9998)
	arrow:setRotation((pos[i] - 1)*90)

	local showImg = cell:getChildByName('show_img')
	showImg:setLocalZOrder(9999)
	showImg:getChildByName('des1'):setString(GlobalApi:getLocalStr(showDatas[i][1]))
	showImg:getChildByName('des2'):setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_28'))
	showImg:setVisible(false)
	local loginBtn = cell:getChildByName('login_btn')
	loginBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			showImg:setVisible(not showImg:isVisible())
        end
    end)

	local des1 = cell:getChildByName('des1')
	des1:setString(string.format(GlobalApi:getLocalStr(showDatas[i][2]),showDatas[i][4]))

	local des2 = cell:getChildByName('des2')
	if confData[tonumber(range[i])+1] then
		des2:setString(string.format(GlobalApi:getLocalStr(showDatas[i][3]),confData[tonumber(range[i])+1].condition))
	else
		des2:setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_18'))
	end

	local upBtn = cell:getChildByName('up_btn')
	local scrollBtn = cell:getChildByName('scroll_btn')
	if confData[tonumber(range[i])+1] then
		if showDatas[i][4] >= confData[tonumber(range[i])+1].condition then
			upBtn:setVisible(true)
			scrollBtn:setVisible(false)
		else
			upBtn:setVisible(false)
			scrollBtn:setVisible(true)
		end
	else
		upBtn:setVisible(false)
		scrollBtn:setVisible(true)
	end

	upBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_4'))
	upBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			local args = {type = i}
			MessageMgr:sendPost("upgrade_integral_carnival", "activity", json.encode(args), function (response)
				local code = response.code
				if code == 0 then
					local awards = response.data.awards
					if awards then
						GlobalApi:parseAwardData(awards)
						GlobalApi:showAwardsCommon(awards,nil,nil,true)
					end
					local costs = response.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end

					self.msg.integral_carnival = response.data.integral_carnival
					self:refreshItem(i,cell)

				end
			end)

        end
    end)

	scrollBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_5'))
	scrollBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			if turn[tonumber(i)] == 1 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_25'), COLOR_TYPE.RED)
				return
			end
			local args = {type = i}
			self:disableBtn()
			MessageMgr:sendPost("turn_integral_carnival", "activity", json.encode(args), function (response)
				local code = response.code
				if(response.code ~= 0) then
					self:openBtn()
					return
				end
				self:disableBtn()
				self.msg.integral_carnival = response.data.integral_carnival
				-- 开始转动
				local function callBack()
					self:refreshItem(i,cell)
					self:initShow()
				end
				self:scrollStart(i,callBack,arrow)
			end)

        end
    end)

end

-- 转动开始
function IntegralCarnival:scrollStart(i,callBack,arrow)
    local id = self.msg.integral_carnival.pos[i]
    if not id or id <= 0 then
        self:openBtn()
        return
    end
	--arrow:setRotation(0)
    local endDeg = (id - 1) * 90 + (360 - arrow:getRotation())
    local vec = cc.pForAngle(math.rad(90 - endDeg))
    local act1 = cc.Sequence:create(CCEaseSineIn:create(cc.RotateBy:create(0.66, 360)),cc.RotateBy:create(0.4,360),cc.EaseSineOut:create(cc.RotateBy:create(1, endDeg + 360 * 2)))
    local act2 = cc.DelayTime:create(0.75)
    local act3 = cc.CallFunc:create(
	    function ()
            self:openBtn()
			if callBack then
				callBack()
			end

	    end)
    arrow:runAction(cc.Sequence:create(act1,act2,act3))
end

-- 禁用按钮
function IntegralCarnival:disableBtn()
	local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(false)
            v.addImg:setTouchEnabled(false)    
        end
    end

	self.countBtn:setTouchEnabled(false)

	local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(false)
        end
    end
    if closeBtn then
        closeBtn:setTouchEnabled(false)
    end

	self.btn:setTouchEnabled(false)

	for i = 1,#self.cells do
		local upBtn = self.cells[i]:getChildByName('up_btn')
		local scrollBtn = self.cells[i]:getChildByName('scroll_btn')
		upBtn:setTouchEnabled(false)
		scrollBtn:setTouchEnabled(false)
	end
end

-- 启用按钮
function IntegralCarnival:openBtn()
	local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(true)
            v.addImg:setTouchEnabled(true)    
        end
    end

	self.countBtn:setTouchEnabled(true)

	local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(true)
        end
    end
    if closeBtn then
        closeBtn:setTouchEnabled(true)
    end

	self.btn:setTouchEnabled(true)

	for i = 1,#self.cells do
		local upBtn = self.cells[i]:getChildByName('up_btn')
		local scrollBtn = self.cells[i]:getChildByName('scroll_btn')
		upBtn:setTouchEnabled(true)
		scrollBtn:setTouchEnabled(true)
	end
end

return IntegralCarnival