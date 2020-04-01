local SurpriseStep = class("surprise_step")
local ClassItemCell = require('script/app/global/itemcell')
local ClassSellTips = require('script/app/ui/tips/selltips')

local function tablefind(value, tab)
	for k , v in pairs (tab) do
		if tonumber(value) == tonumber(v) then
			return true
		end
 	end
 	return false
end

function SurpriseStep:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg

    local _,_,_,surpriseStepBuyImg = ActivityMgr:getMenusAndCloseBtn2()
    self.surpriseStepBuyImg = surpriseStepBuyImg

    self:initData()
    self:initTop()
    self:initStep()
    self:initLeftBottom()
    self:initRight()

    self:updateCurrentStep()
    self:updateCurrentStep2()
    self:updateMark()
end

function SurpriseStep:updateMark()
    if UserData:getUserObj():getSignByType('surprise_step') then
		ActivityMgr:showMark("surprise_step", true)
	else
		ActivityMgr:showMark("surprise_step", false)
	end
end

function SurpriseStep:initTop()
    ActivityMgr:showRightSurpriseStepRemainTime()
    ActivityMgr:showLefSurpriseStepCue()
end

function SurpriseStep:initData()
    local avStepAwardsConf = GameData:getConfData('avstepawards')
    self.avStepAwardsConf = {}
    for k,v in pairs(avStepAwardsConf) do
        table.insert(self.avStepAwardsConf,v)
    end
    table.sort(self.avStepAwardsConf,function(a, b)
		return b.step > a.step
	end)
    self.avStepInfoConf = GameData:getConfData('avstepinfo')

    self.stepLines = {}
    self.currentpos = self.msg.surprise_step.currentpos
    self.frameAwards = {}
    self.rightCells = {}
end

function SurpriseStep:initStep()
    local bgStep = self.rootBG:getChildByName('bg_step')
    local bg = bgStep:getChildByName('bg')
    for i = 1,22 do
        local step = bg:getChildByName('step' .. i)
        table.insert(self.stepLines,step)
    end

    local initPosX = 9.5
    local lineWidth = 117
    local initPosY = 197
    local lineHeight = 94

    local icon = ccui.ImageView:create('uires/ui/common/frame_blue.png')
    icon:setPosition(cc.p(initPosX,initPosY))
    icon:setScale(0.76)
    bg:addChild(icon)

    local startImg = ccui.ImageView:create('uires/ui/activity/kaishi.png')
    startImg:setScale(100/76)
    startImg:setPosition(cc.p(94/2,94/2))
    startImg:ignoreContentAdaptWithSize(true)
    icon:addChild(startImg)

    local posEffect = GlobalApi:createLittleLossyAniByName("ui_qitianle_01_01")
    posEffect:getAnimation():playWithIndex(0, -1, 1)
    posEffect:setPosition(cc.p(94/2 + 2,94/2))
    posEffect:setScale(1.3)
    icon:addChild(posEffect)
    icon.posEffect = posEffect
    table.insert(self.frameAwards,icon)

    for i = 2,#self.avStepInfoConf do
        local data = self.avStepInfoConf[i]
        local awardData = data.awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]

        local icon = ccui.ImageView:create('uires/ui/common/frame_default2.png')
        local line = math.ceil(i/5)
        local column = i%5
        if i%5 == 0 then
            column = 5
        end
        local posX = initPosX + (column - 1) * lineWidth
        local posY = initPosY - (line - 1) * lineHeight
        icon:setPosition(cc.p(posX,posY))
        icon:setScale(0.76)
        bg:addChild(icon)
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
        cell.awardBgImg:setTouchEnabled(true)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.awardBgImg:loadTexture(awards:getBgImg())
        cell.chipImg:setVisible(true)
        cell.chipImg:loadTexture(awards:getChip())
        cell.lvTx:setString('x'..awards:getNum())
        cell.awardImg:loadTexture(awards:getIcon())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        icon.effect = cell.awardBgImg:getChildByName('chip_light')
        --if icon.effect then
            --icon.effect:setVisible(false)
        --end
        local posEffect = GlobalApi:createLittleLossyAniByName("ui_qitianle_01_01")
        posEffect:getAnimation():playWithIndex(0, -1, 1)
        posEffect:setPosition(cc.p(94/2 + 2,94/2))
        posEffect:setScale(1.3)
        icon:addChild(posEffect)
        icon.posEffect = posEffect
        table.insert(self.frameAwards,icon)
    end

end

function SurpriseStep:updateCurrentStep()
    local stepline = self.avStepInfoConf[self.currentpos].stepline
    for i = 1,#self.stepLines do
        if tablefind(i,stepline) then
            self.stepLines[i]:setVisible(true)
        else
            self.stepLines[i]:setVisible(false)
        end
    end

end

function SurpriseStep:updateCurrentStep2()
    for i = 1,#self.frameAwards do
        local icon = self.frameAwards[i]
        if self.currentpos == i then
            if icon.effect then
                icon.effect:setVisible(false)
            end
            icon.posEffect:setVisible(true)
        else
            if icon.effect then
                icon.effect:setVisible(true)
            end
            icon.posEffect:setVisible(false)
        end
    end
end

function SurpriseStep:initLeftBottom()
    local oneBtn = self.rootBG:getChildByName('one_btn')
    local stepOne = tonumber(GlobalApi:getGlobalValue('perStepItemNum'))
    oneBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:stepLogic(1,stepOne)
        end
    end)
    oneBtn:getChildByName('desc'):setString(GlobalApi:getLocalStr('ACTIVE_SURPRIESE_STEP_DESC1'))
    self.oneBtn = oneBtn
    oneBtn:getChildByName('tx'):setString('x ' .. stepOne)

    local tenBtn = self.rootBG:getChildByName('ten_btn')
    self.tenBtn = tenBtn
    local stepTen = tonumber(GlobalApi:getGlobalValue('tenStepItemNum'))
    tenBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:stepLogic(10,stepTen)
        end
    end)
    tenBtn:getChildByName('desc'):setString(GlobalApi:getLocalStr('ACTIVE_SURPRIESE_STEP_DESC2'))
    tenBtn:getChildByName('tx'):setString('x ' .. stepTen)


    local fiveBtn = self.rootBG:getChildByName('five_btn')
    local stepFive = tonumber(GlobalApi:getGlobalValue('fiveStepItemNum'))
    self.fiveBtn = fiveBtn
    fiveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:stepLogic(50,stepFive)
        end
    end)
    fiveBtn:getChildByName('desc'):setString(GlobalApi:getLocalStr('ACTIVE_SURPRIESE_STEP_DESC5'))
    fiveBtn:getChildByName('tx'):setString('x ' .. stepFive)

    local buyImg = self.surpriseStepBuyImg
    local ownNowNum = 0
    local stepItemId = tonumber(GlobalApi:getGlobalValue('stepItemId'))
    if BagData:getMaterialById(stepItemId) then
        ownNowNum = BagData:getMaterialById(stepItemId):getNum()
    end
    local ownNum = buyImg:getChildByName('own_num')
    ownNum:setString(ownNowNum)

    local addBtn = buyImg:getChildByName('add_btn')
    self.addBtn = addBtn
    addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            
            local awardData = {{'material',tostring((GlobalApi:getGlobalValue('stepItemId'))),1}}
            local disPlayData = DisplayData:getDisplayObjs(awardData)
            local awards = disPlayData[1]
            local tab = {}
            tab.icon = 'uires/ui/res/res_cash.png'
            tab.num = UserData:getUserObj():getCash()   -- 拥有的元宝数
            tab.desc = GlobalApi:getLocalStr('NOT_ENOUGH_CASH')
            tab.id = 'cash'
            tab.costNum = tonumber(GlobalApi:getGlobalValue('stepItemCostNum'))     -- 单价
            tab.confId = nil
            tab.sellNum = 1     -- 这个暂时好像没用
            --[[if tab.num < tab.costNum then
			    promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
				        GlobalApi:getGotoByModule('cash')
			        end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
                return
            end
            --]]
            self:showTips(awards,tab,nil,function(callback,num,cash)
                if callback then
                    callback()
                end
                if num == 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES12'), COLOR_TYPE.RED)
                else
                    self:buyProp(num,cash)
                end
            end,nil,math.floor(tab.num/tab.costNum),'show_at_surprise_step')

        end
    end)
end

function SurpriseStep:buyProp(num,cost)
    local num = num or 1
    local function sendToServer()
        self:sendToServer(num)
	end
	UserData:getUserObj():cost('cash',cost,sendToServer,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),cost))
end

function SurpriseStep:sendToServer(num)
    MessageMgr:sendPost('surprise_step_item_buy','activity',json.encode({num = num}),
	    function(response)
		    if(response.code ~= 0) then
			    return
		    end

            local awards = response.data.awards
		    if awards then
			    GlobalApi:parseAwardData(awards)
			    GlobalApi:showAwardsCommon(awards,nil,nil,true)
		    end

		    local costs = response.data.costs
		    if costs then
			    GlobalApi:parseAwardData(costs)
		    end
            self:initLeftBottom()
	    end)
end

function SurpriseStep:stepLogic(step,costNum)
    self:disableBtn()
    local ownNowNum = 0
    local stepItemId = tonumber(GlobalApi:getGlobalValue('stepItemId'))
    if BagData:getMaterialById(stepItemId) then
        ownNowNum = BagData:getMaterialById(stepItemId):getNum()
    end

    if ownNowNum < costNum then
        local stepItemCostNum = tonumber(GlobalApi:getGlobalValue('stepItemCostNum'))
        local buyNum = costNum - ownNowNum
        local cost = stepItemCostNum * buyNum
        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVE_SURPRIESE_STEP_DESC4'),cost,buyNum), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
            local hasCash = UserData:getUserObj():getCash()
            if hasCash >= cost then
                self:sendToServer(buyNum)
            else
                promptmgr:showMessageBox(
				GlobalApi:getLocalStr('STR_CASH')..GlobalApi:getLocalStr('NOT_ENOUGH')..'，'..GlobalApi:getLocalStr('STR_CONFIRM_TOBUY') .. GlobalApi:getLocalStr('STR_CASH') .. '？',
				MESSAGE_BOX_TYPE.MB_OK_CANCEL,
				function ()
					GlobalApi:getGotoByModule('cash')
				end)
            end
        end)
        self:openBtn()
        return
    end

    MessageMgr:sendPost('surprise_step','activity',json.encode({stepnum = step}),
	    function(response)
		    if(response.code ~= 0) then
                self:openBtn()
			    return
		    end
		    local awards = response.data.awards
		    if awards then
			    GlobalApi:parseAwardData(awards)
			    --GlobalApi:showAwardsCommon(awards,nil,nil,true)
		    end

            local costs = response.data.costs
		    if costs then
			    GlobalApi:parseAwardData(costs)
		    end

            self.msg.surprise_step.step = self.msg.surprise_step.step + step
            --for i = 1,#self.rightCells do
                --self:updateCell(self.rightCells[i],i)
            --end
            local stepmark = response.data.stepmark
            local temp = {}
            local tempAwards = {}
            for i = 1,#stepmark do
                table.insert(temp,stepmark[i])
                table.insert(tempAwards,awards[i])
                if stepmark[i] == 15 then
                    table.insert(temp,1)
                    table.insert(tempAwards,1)
                end
            end

            self.stopIndex = 0
            self:stopAnimal(temp,tempAwards)

	    end)
end

function SurpriseStep:stopAnimal(stepmark,awards)
    self.stopIndex = self.stopIndex + 1
    print(self.stopIndex)
    if self.stopIndex > #stepmark then
        self:openBtn()
        self:initRight()
        self:initLeftBottom()
        return
    end

    local action1 = cc.DelayTime:create(0.6)
    local action2 = cc.CallFunc:create(function ()
        local showAwards = {}
        self.currentpos = stepmark[self.stopIndex]
        if self.currentpos > 1 then
            table.insert(showAwards,awards[self.stopIndex])
            GlobalApi:showAwardsCommonByText(showAwards,nil)
        end
        self:updateCurrentStep2()
    end)
    local action3 = cc.DelayTime:create(0.1)
    local action4 = cc.CallFunc:create(function ()
        self:updateCurrentStep()
        self:stopAnimal(stepmark,awards)
    end)
    self.rootBG:runAction(cc.Sequence:create(action1,action2,action3,action4))
end

function SurpriseStep:initRight()
    local rightBg = self.rootBG:getChildByName('right_bg')
    local cell = rightBg:getChildByName('cell')
    cell:setVisible(false)
    local sv = rightBg:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    self.rightCells = {}
    sv:removeAllChildren()

    self.avStepAwards = {}
    for i = 1,#self.avStepAwardsConf do
        local v = clone(self.avStepAwardsConf[i])
        local curStep = self.msg.surprise_step.step
        local needStep = v.step
        v.showStatus = 2
        if curStep >= needStep then    -- 进度达成
            if self.msg.surprise_step.achieve and self.msg.surprise_step.achieve[tostring(needStep)] and self.msg.surprise_step.achieve[tostring(needStep)] == 1 then    -- 已经领取
                v.showStatus = 1            
            else
                v.showStatus = 3
            end
        end
        table.insert(self.avStepAwards,v)
    end

    table.sort(self.avStepAwards,function(a, b)
        if a.showStatus == b.showStatus then
            return a.step < b.step
        else
            return a.showStatus > b.showStatus
        end
	end)

    local num = #self.avStepAwards
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * cell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = cell:getContentSize().height
    for i = 1,num do
        local tempCell = cell:clone()
        tempCell:setVisible(true)

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0 + tempCell:getContentSize().width/2 + 6,allHeight - offset + tempCell:getContentSize().height/2))
        sv:addChild(tempCell)
        self:updateCell(tempCell,i)
        table.insert(self.rightCells,tempCell)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function SurpriseStep:updateCell(img,i)
    local data = self.avStepAwards[i]
    local needStep = data.step
    local awardData = data.awards

    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local icons = {}
    table.insert(icons,img:getChildByName('icon' .. 2))
    table.insert(icons,img:getChildByName('icon' .. 1))
    icons[1]:setPositionX(249.85)
    for i = 1,2 do
        local icon = icons[i]
        if icon:getChildByName('award_bg_img') then
            icon:removeChildByName('award_bg_img')
        end
        local awards = disPlayData[i]
        if awards then
            icon:setVisible(true)
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
            cell.awardBgImg:setTouchEnabled(true)
            cell.awardBgImg:setPosition(cc.p(94/2,94/2))
            cell.awardBgImg:loadTexture(awards:getBgImg())
            cell.chipImg:setVisible(true)
            cell.chipImg:loadTexture(awards:getChip())
            cell.lvTx:setString('x'..awards:getNum())
            cell.awardImg:loadTexture(awards:getIcon())
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
        else
            icon:setVisible(false)
            icons[1]:setPositionX(209)
        end
    end

    local curStep = self.msg.surprise_step.step
    local desc = img:getChildByName('desc')
    desc:setString(string.format(GlobalApi:getLocalStr('ACTIVE_SURPRIESE_STEP_DESC3'),needStep))

    local stateImage = img:getChildByName('state_image')
    local getBtn = img:getChildByName('get_btn')
    getBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES9'))
    img.getBtn = getBtn
    local expBg = img:getChildByName('exp_bg')
    local expBar = img:getChildByName('exp_bar')
    local expTx = img:getChildByName('exp_tx')

    local showStep = curStep >= needStep and needStep or curStep
    expTx:setString(showStep .. '/' .. needStep)
    expBar:setPercent(showStep/needStep * 100)

    if curStep >= needStep then    -- 进度达成
        if self.msg.surprise_step.achieve and self.msg.surprise_step.achieve[tostring(needStep)] and self.msg.surprise_step.achieve[tostring(needStep)] == 1 then    -- 已经领取
            stateImage:setVisible(true)
            getBtn:setVisible(false)
        else
            stateImage:setVisible(false)
            getBtn:setVisible(true)
        end
        expBg:setVisible(false)
        expBar:setVisible(false)
        expTx:setVisible(false)
    else    -- 未达成
        stateImage:setVisible(false)
        getBtn:setVisible(false)
        expBg:setVisible(true)
        expBar:setVisible(true)
        expTx:setVisible(true)
    end

    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('get_surprise_step_award','activity',json.encode({step = needStep}),
	            function(response)
		            if(response.code ~= 0) then
			            return
		            end
		            local awards = response.data.awards
		            if awards then
			            GlobalApi:parseAwardData(awards)
			            GlobalApi:showAwardsCommon(awards,nil,nil,true)
		            end

                    local costs = response.data.costs
		            if costs then
			            GlobalApi:parseAwardData(costs)
		            end
                    self.msg.surprise_step.achieve[tostring(needStep)] = 1
                    --self:updateCell(img,i)
                    self:initRight()
	            end)
        end
    end)
end

function SurpriseStep:showTips(award,tab,status,callback,sidebarList,num,showType)
    local sellTipsUI = ClassSellTips.new(award,tab,status,callback,sidebarList,num,showType)
    sellTipsUI:showUI()
end

function SurpriseStep:disableBtn()
    local menus,closeBtn,recruitHelp,surpriseStepBuyImg = ActivityMgr:getMenusAndCloseBtn2()
    local addBtn = surpriseStepBuyImg:getChildByName('add_btn')
    addBtn:setTouchEnabled(false)

    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(false)
        end
    end
    if closeBtn then
        closeBtn:setTouchEnabled(false)
    end
    if recruitHelp then
        recruitHelp:setTouchEnabled(false)
    end

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(false)
            v.addImg:setTouchEnabled(false)
        end
    end

    for i = 1,#self.rightCells do
        self.rightCells[i].getBtn:setTouchEnabled(false)
    end

    self.tenBtn:setTouchEnabled(false)
    self.fiveBtn:setTouchEnabled(false)
    self.oneBtn:setTouchEnabled(false)
    self.addBtn:setTouchEnabled(false)
end

function SurpriseStep:openBtn()
    local menus,closeBtn,recruitHelp,surpriseStepBuyImg = ActivityMgr:getMenusAndCloseBtn2()
    local addBtn = surpriseStepBuyImg:getChildByName('add_btn')
    addBtn:setTouchEnabled(true)

    if menus then
        for k,v in pairs(menus) do
            v:setTouchEnabled(true)
        end
    end
    if closeBtn then
        closeBtn:setTouchEnabled(true)
    end
    if recruitHelp then
        recruitHelp:setTouchEnabled(true)
    end

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(true)
            v.addImg:setTouchEnabled(true)
        end
    end

    for i = 1,#self.rightCells do
        self.rightCells[i].getBtn:setTouchEnabled(true)
    end

    self.tenBtn:setTouchEnabled(true)
    self.fiveBtn:setTouchEnabled(true)
    self.oneBtn:setTouchEnabled(true)
    self.addBtn:setTouchEnabled(true)
end

return SurpriseStep