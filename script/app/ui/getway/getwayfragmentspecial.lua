local GetwayFragmentSpecialUI = class("GetwayFragmentSpecialUI", BaseUI)

function GetwayFragmentSpecialUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_GET_WAY_FRAGMENT_SPECIAL
    self.obj = obj
    local userEffect = tonumber(self.obj:getUseEffect())
    self.conf = GameData:getConfData("herobox")[userEffect]
    self.percent = 0
end 

function GetwayFragmentSpecialUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    self:adaptUI(bgimg)

    local winsize = cc.Director:getInstance():getWinSize()
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetWayFragmentSpecialUI()
        end
    end)

    local cell = bgimg:getChildByName('cell')
    cell:setVisible(false)

    local sv = bgimg:getChildByName('sv')
    sv:setContentSize(cc.size(winsize.width - 2*50,sv:getContentSize().height))
    sv:getInnerContainer():setContentSize(cc.size(winsize.width - 2*50,sv:getContentSize().height))
    sv:setPosition(cc.p(50,sv:getPositionY()))
    sv:setScrollBarEnabled(false)
    sv:setSwallowTouches(false)
    sv:setPropagateTouchEvents(true)

    local awards = self.conf.awards
    local displayobj = DisplayData:getDisplayObjs(awards)
    local num = #displayobj
    local cellSpace = 30
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width

    local width = num * cell:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

	self.allWidth = allWidth
	self.width = size.width
	self.innerContainer = innerContainer

    local offset = 0
    local tempWidth = cell:getContentSize().width
    for i = 1,num,1 do
        local tempCell = cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

        local lightimg = tempCell:getChildByName('light_bg')
        lightimg:setVisible(false)
        -- 
        local cardbg = tempCell:getChildByName('card_bg')
        local checkTx = cardbg:getChildByName('check_tx')
        checkTx:setVisible(false)
        tempCell.checkTx = checkTx

        if displayobj[i] then
            local roleobj = RoleData:getRoleInfoById(displayobj[i]:getId())
            cardbg:loadTexture(roleobj:getCardIcon())
            local heroimg = cardbg:getChildByName('hero_img')
            heroimg:loadTexture(roleobj:getBigIcon())
            local nametx = cardbg:getChildByName('name_tx')
            nametx:setString(roleobj:getName())
            local flagImg = cardbg:getChildByName('flag_img')
            local camp = roleobj:getCamp()
            if camp == 0 then
                flagImg:setVisible(false)
                nametx:setPositionX(74)
            else
                nametx:setPositionX(92)
                flagImg:setVisible(true)
                -- flagImg:loadTexture('uires/ui/citycraft/citycraft_flag_'..camp..'.png')
                flagImg:loadTexture('uires/ui/common/camp_'..camp..'.png')
            end
            local soldierimg  = cardbg:getChildByName('soldier_img')
            soldierimg:loadTexture('uires/ui/common/'..'soldier_'..roleobj:getSoldierId()..'.png')
            local chipimg = cardbg:getChildByName('chip_img')
            local chipnum = cardbg:getChildByName('chip_num')
            chipnum:setString('x ' .. displayobj[i]:getNum())
            if displayobj[i]:getObjType() == 'fragment' then
                chipnum:setVisible(true)
                chipimg:setVisible(true)
            else
                chipimg:setVisible(false)
                chipnum:setVisible(false)
            end

            cardbg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,roleobj)
                end
            end)
        end
    end
    innerContainer:setPositionX(0)

    local desc = bgimg:getChildByName('desc')
    desc:setPosition(cc.p(winsize.width*0.5,desc:getPositionY()))
    desc:setString(self.obj:getDesc())

    local leftBtn = bgimg:getChildByName('left_btn')
	self.leftBtn =leftBtn
	local rightBtn = bgimg:getChildByName('right_btn')
	self.rightBtn = rightBtn

    rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local pos = math.abs(innerContainer:getPositionX())
            self.percent = (pos * 100)/(allWidth - size.width)
            self.percent = self.percent + 20
            if self.percent >= 100 then
                self.percent = 100
            end
            sv:scrollToPercentHorizontal(self.percent,0.3,true)
        end
    end)
    leftBtn:setPosition(cc.p(0,sv:getPositionY() + 318/2))

    leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local pos = math.abs(innerContainer:getPositionX())
            self.percent = (pos * 100)/(allWidth - size.width)
            self.percent = self.percent - 20
            if self.percent <= 0 then
                self.percent = 0
            end
            sv:scrollToPercentHorizontal(self.percent,0.3,true)
        end
    end)
    rightBtn:setPosition(cc.p(winsize.width,sv:getPositionY() + 318/2))

	bgimg:scheduleUpdateWithPriorityLua(function(dt)
		self:update(dt)
	end, 0)
end

function GetwayFragmentSpecialUI:update(dt)
	local pos = math.abs(self.innerContainer:getPositionX())
    local percent = (pos * 100)/(self.allWidth - self.width)

	self.leftBtn:setTouchEnabled(true)
	self.rightBtn:setTouchEnabled(true)
	ShaderMgr:restoreWidgetDefaultShader(self.leftBtn)
	ShaderMgr:restoreWidgetDefaultShader(self.rightBtn)
    if percent <= 0 then
		ShaderMgr:setGrayForWidget(self.leftBtn)
		self.leftBtn:setTouchEnabled(false)
    elseif percent >= 100 then
		ShaderMgr:setGrayForWidget(self.rightBtn)
		self.rightBtn:setTouchEnabled(false)
    end
end

return GetwayFragmentSpecialUI
