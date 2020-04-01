local SurpriseTurn = class("surprise_turn")
local ClassItemCell = require('script/app/global/itemcell')

function SurpriseTurn:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
	self.tempData = GameData:getConfData('avsurpriseturn')
    UserData:getUserObj().activity.surprise_turn = self.msg.surprise_turn

	ActivityMgr:showRightSurpriseTurnRemainTime()
    self:updateMark()
	self.surpriseTurnBg = ActivityMgr:getLefSurpriseTurnBgCue()
	self.surpriseTurnBg:setVisible(true)
	self:updateRight()
	self:update()
end

function SurpriseTurn:updateMark()
    if UserData:getUserObj():getSignByType('surprise_turn') then
		ActivityMgr:showMark("surprise_turn", true)
	else
		ActivityMgr:showMark("surprise_turn", false)
	end
end

function SurpriseTurn:update()
	local desc = self.surpriseTurnBg:getChildByName('desc')
	desc:setString(GlobalApi:getLocalStr("ACTIVITY_SURPRISE_TURN_DES1"))
	local numTx = self.surpriseTurnBg:getChildByName('num')
	numTx:setString(self.msg.surprise_turn.left_num)
	if self.msg.surprise_turn.left_num <= 0 then
		numTx:setColor(COLOR_TYPE.RED)
	else
		numTx:setColor(COLOR_TYPE.WHITE)
	end
	self:updateLeft()
end

function SurpriseTurn:updateLeft()
	local left = self.rootBG:getChildByName('left')
	local titleTx1 = left:getChildByName('title_tx1')
	titleTx1:setString(GlobalApi:getLocalStr("ACTIVITY_SURPRISE_TURN_DES2"))
	local titleTx2 = left:getChildByName('title_tx2')
	titleTx2:setString(GlobalApi:getLocalStr("ACTIVITY_SURPRISE_TURN_DES3"))

	local cell1 = left:getChildByName('cell1')
	local desc = cell1:getChildByName('desc')
	desc:setString(string.format(GlobalApi:getLocalStr("ACTIVITY_SURPRISE_TURN_DES4"), tonumber(GlobalApi:getGlobalValue('surpriseTurnPerMoney')),tonumber(GlobalApi:getGlobalValue('surpriseTurnMax'))))

	local cell2 = left:getChildByName('cell2')
	for i = 1,5 do
		if cell2:getChildByName('rich_text' .. i) then
			cell2:removeChildByName('rich_text' .. i)
		end
	end
	for i = 1,5 do
		local name = self.msg.names[i]
		local id = self.msg.ids[i]
		if name and id then
			local awards = self.tempData[tonumber(id)].awards
			local disPlayData = DisplayData:getDisplayObjs(awards)[1]

			local richText = xx.RichText:create()
			richText:setName('rich_text' .. i)
			richText:setContentSize(cc.size(600, 40))

			local re1 = xx.RichTextLabel:create(name, 20, COLOR_TYPE.WHITE)
			re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
			re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
			re1:setFont('font/gamefont.ttf')
			local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_SURPRISE_TURN_DES8'), 20, COLOR_TYPE.WHITE)
			re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
			re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
			re2:setFont('font/gamefont.ttf')
			local re3 = xx.RichTextLabel:create(disPlayData:getNum() .. '     ', 20, COLOR_TYPE.GREEN)
			re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
			re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
			re3:setFont('font/gamefont.ttf')
			local re4 = xx.RichTextImage:create(disPlayData:getIcon())
			re4:setScale(0.4)
			richText:addElement(re1)
			richText:addElement(re2)
			richText:addElement(re3)
			richText:addElement(re4)
			richText:setAlignment('left')
			richText:setVerticalAlignment('middle')
			richText:setAnchorPoint(cc.p(0,0.5))
			richText:setPosition(cc.p(30,140 - (i - 1)*30))
			cell2:addChild(richText)
			richText:format(true)
		end
	end

end

function SurpriseTurn:updateRight()
	local center = self.rootBG:getChildByName('center')
    local wheel = center:getChildByName('wheel')
    self.arrow = wheel:getChildByName('arrow')
    local img = wheel:getChildByName('img')
	img:getChildByName('tx'):setString(GlobalApi:getLocalStr("ACTIVITY_SURPRISE_TURN_DES5"))
    img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:scrollToServer(callBack)
        end
    end)
    self.img = img
	local sortDatas = {}
	for k,v in pairs(self.tempData) do
		table.insert(sortDatas,clone(v))
	end
	table.sort(sortDatas,function (a,b)
        return tonumber(a.sortId) < tonumber(b.sortId)
    end)

    local num = #sortDatas
    for i = 1,num do
        local data = sortDatas[i]
        local frame = wheel:getChildByName('icon_' .. i)
        local awardData = data.awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setScale(1.1)
        cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)
    end

end

-- 转到通讯
function SurpriseTurn:scrollToServer(callBack)
    self:disableBtn()
    -- 元宝消耗
    local function callBack()  
        MessageMgr:sendPost('get_surprise_turn_award','activity',json.encode({}),
	    function(response)
		    if(response.code ~= 0) then
                self:openBtn()
			    return
		    end
            self:disableBtn()
            -- 开始转动
            self:scrollStart(response.data)
	    end)
    end

    if self.msg.surprise_turn.turn_num >= tonumber(GlobalApi:getGlobalValue('surpriseTurnMax')) then
        self:openBtn()
		promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_SURPRISE_TURN_DES7'), COLOR_TYPE.RED)
        return
	end

	if self.msg.surprise_turn.left_num <= 0 then
		self:openBtn()
		promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("ACTIVITY_SURPRISE_TURN_DES6"), tonumber(GlobalApi:getGlobalValue('surpriseTurnPerMoney'))), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            GlobalApi:getGotoByModule("cash")
			ActivityMgr:hideUI()
        end,GlobalApi:getLocalStr("STR_OK2"),GlobalApi:getLocalStr("STR_CANCEL_1"))
        return
	end
    callBack()
end

-- 转动开始
function SurpriseTurn:scrollStart(data)
    local id = tonumber(data.id)
    print('+++++++++++++++++++++' .. id)
    local awards = data.awards
    local costs = data.costs

    if not id or id <= 0 then
        if awards then
			GlobalApi:parseAwardData(awards)
		end
        if costs then
            GlobalApi:parseAwardData(costs)
        end
        self:openBtn()
        return
    end

    local endDeg = (self.tempData[id].sortId - 3) * 60
    local act1 = cc.Sequence:create(CCEaseSineIn:create(cc.RotateBy:create(0.33, 120)),cc.RotateBy:create(0.4,360),cc.EaseSineOut:create(cc.RotateBy:create(1, endDeg + 360 * 2)))
    local act2 = cc.DelayTime:create(0.01)
    local act3 = cc.CallFunc:create(
	    function ()
			GlobalApi:showAwardsCommon(awards,true,nil,false)

            if awards then
			    GlobalApi:parseAwardData(awards)
		    end
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self:openBtn()

            -- 刷新显示
            self.arrow:setRotation(0)
			self.msg.surprise_turn.left_num = self.msg.surprise_turn.left_num - 1
			self.msg.surprise_turn.turn_num = self.msg.surprise_turn.turn_num + 1
			if data.names then
				self.msg.names = data.names
				self.msg.ids = data.ids
			end
			self:update()
	    end)
    self.arrow:runAction(cc.Sequence:create(act1,act2,act3))
end

-- 禁用按钮
function SurpriseTurn:disableBtn()
    self.img:setTouchEnabled(false)
    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(false)
            v.addImg:setTouchEnabled(false)
        end
    end
	local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if closeBtn then
        closeBtn:setTouchEnabled(false)
    end
	if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(false)
        end
    end
end

-- 启用按钮
function SurpriseTurn:openBtn()
    self.img:setTouchEnabled(true)
    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(true)
            v.addImg:setTouchEnabled(true)
        end
    end
	local menus,closeBtn,cue4Help = ActivityMgr:getMenusAndCloseBtn()
    if closeBtn then
        closeBtn:setTouchEnabled(true)
    end
	if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(true)
        end
    end
end
return SurpriseTurn