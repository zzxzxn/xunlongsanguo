local ExclusiveMainUI = class("ExclusiveMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local roleAnim ={
	'attack',
	'run',
	'skill1',
	'skill2',
	'shengli'
}
local STARS = {1,1,2,2,6,3,7}

function ExclusiveMainUI:ctor(index)
	self.uiIndex = GAME_UI.UI_EXCLUSIVE_MAIN
    self.chooseBtns = {}
    self.chooseBtnsTx = {}
    self.btnNewImgs = {}
    self.curSelectIndex = index or 1

    -- 卤娄脦茂
    self.curObj = nil
    self.roleArr = {}

    -- 合成
    self.mergeCells = {}
    self.curMergeLevelIndex = 1
    self.mergeLevel = nil
    self.chooseExclusiveObj = {}
    self.chooseExclusiveLimit = {}
    self.mergeShowTabs = {}


	-- 重铸
	self.recastCells = {}
	self.curRecastLevelIndex = 1
	self.recastShowTabs = {}
	self.recastLevel = nil
	self.chooseRecastExclusiveObj = nil
end

function ExclusiveMainUI:onShow()
    if ExclusiveMgr:getDirty() == true then
        self:update()
    end
    ExclusiveMgr:setDirty(false)
end

function ExclusiveMainUI:init()
    self.bgImg = self.root:getChildByName("bg_img")
	self.bgImg1 = self.bgImg:getChildByName("bg_img1")
	self.bgImg2 = self.bgImg1:getChildByName("bg_img2")
	self:adaptUI(self.bgImg, self.bgImg1)
	local winSize = cc.Director:getInstance():getVisibleSize()
	local closeBtn = self.bgImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            ExclusiveMgr:hideExclusiveMainUI()
		end
	end)
    closeBtn:setPosition(cc.p(winSize.width - 10,winSize.height - 30))

    for i = 1,4 do
        local btn = self.bgImg2:getChildByName('btn' .. i)
        table.insert(self.chooseBtns,btn)
        local btnTx = self.bgImg2:getChildByName('btn_tx' .. i)
        btnTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_' .. (i + 1)))
        table.insert(self.chooseBtnsTx,btnTx)
        btn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                if self.curSelectIndex == i then
                    return
                end 
                self.curSelectIndex = i
                self:update()
		    end
	    end)

		local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('exclusive_recast')
        if isOpen == false and i == 4 then
            btn:setVisible(false)
            btnTx:setVisible(false)
        end

        local newImg = self.bgImg2:getChildByName('new_img_' .. i)
        table.insert(self.btnNewImgs,newImg)
    end

    local pokeGuang = self.bgImg2:getChildByName('poke_guang')
    pokeGuang:runAction(cc.RepeatForever:create(cc.RotateBy:create(3.5, 360)))
    local pokeBtn = self.bgImg2:getChildByName('poke_btn')
    local pokeBtnTx = pokeBtn:getChildByName('func_tx')
    pokeBtnTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_1'))
    pokeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            ExclusiveMgr:showExclusivePokedexUI()
		end
	end)

    local bgRight = self.bgImg2:getChildByName('bg_right')
    self.rightTreasurePanel = bgRight:getChildByName('right_treasure_panel')
    self.rightTreasureSv = self.rightTreasurePanel:getChildByName('sv')
    self.rightMakePanel = bgRight:getChildByName('right_make_panel')
    self.rightMergePanel = bgRight:getChildByName('right_merge_panel')
	self.rightRecastPanel = bgRight:getChildByName('right_recast_panel')
    self.leftTreasurePanel = self.bgImg2:getChildByName('left_treasure_panel')
    self.leftMakePanel = self.bgImg2:getChildByName('left_make_panel')
    self.leftMergePanel = self.bgImg2:getChildByName('left_merge_panel')
	self.leftRecastPanel = self.bgImg2:getChildByName('left_recast_panel')
    self.rightTreasureSv:setScrollBarEnabled(false)

    local leftImg = self.rightMergePanel:getChildByName('img1')
    local rightImg = self.rightMergePanel:getChildByName('img2')
    local moveByOffset = 10
    leftImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(0.3, cc.p(moveByOffset, 0)), 
        cc.MoveBy:create(0.3, cc.p(-moveByOffset, 0))
    )))

    rightImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(0.3, cc.p(-moveByOffset, 0)), 
        cc.MoveBy:create(0.3, cc.p(moveByOffset, 0))
    )))

    local bg = self.leftTreasurePanel:getChildByName('bg')
    local bottomImg = bg:getChildByName('bottom_img')
    self.leftTreasureArrow = bottomImg:getChildByName('arrow_img')
    self.leftTreasureArrow:runAction(cc.RepeatForever:create(cc.Sequence:create(
        cc.MoveBy:create(0.3, cc.p(moveByOffset, 0)), 
        cc.MoveBy:create(0.3, cc.p(-moveByOffset, 0))
    )))

    self:update()
end

function ExclusiveMainUI:update()
    for i = 1,4 do
        local btn = self.chooseBtns[i]
        local tx = self.chooseBtnsTx[i]
        if i == self.curSelectIndex then
            btn:loadTextureNormal('uires/ui/common/title_btn_sel_2.png')
            tx:setTextColor(COLOR_TYPE.WHITE)
        else
            btn:loadTextureNormal('uires/ui/common/title_btn_nor_2.png')
            tx:setTextColor(cc.c3b(0xcf, 0xba, 0x8d))
        end
    end
    
    if self.curSelectIndex == 1 then
        self.rightTreasurePanel:setVisible(true)
        self.rightMakePanel:setVisible(false)
        self.rightMergePanel:setVisible(false)
        self.leftTreasurePanel:setVisible(true)
        self.leftMakePanel:setVisible(false)
        self.leftMergePanel:setVisible(false)
		self.rightRecastPanel:setVisible(false)
		self.leftRecastPanel:setVisible(false)
        self:updateLeftTreasurePanel()
        self:updateRightTreasurePanel()
    elseif self.curSelectIndex == 2 then
        self.rightTreasurePanel:setVisible(false)
        self.rightMakePanel:setVisible(true)
        self.rightMergePanel:setVisible(false)
        self.leftTreasurePanel:setVisible(false)
        self.leftMakePanel:setVisible(true)
        self.leftMergePanel:setVisible(false)
		self.rightRecastPanel:setVisible(false)
		self.leftRecastPanel:setVisible(false)
        self:updateLeftMakePanel()
        self:updateRightMakePanel()
    elseif self.curSelectIndex == 3 then
        self.rightTreasurePanel:setVisible(false)
        self.rightMakePanel:setVisible(false)
        self.rightMergePanel:setVisible(true)
        self.leftTreasurePanel:setVisible(false)
        self.leftMakePanel:setVisible(false)
        self.leftMergePanel:setVisible(true)
		self.rightRecastPanel:setVisible(false)
		self.leftRecastPanel:setVisible(false)
        self.mergeShowTabs = clone(ExclusiveMgr:getMergeExclusiveMap())
        self:updateLeftMergePanel(true)
        self:updateRightMergePanel()
    else
        self.rightTreasurePanel:setVisible(false)
        self.rightMakePanel:setVisible(false)
        self.rightMergePanel:setVisible(false)
        self.leftTreasurePanel:setVisible(false)
        self.leftMakePanel:setVisible(false)
        self.leftMergePanel:setVisible(false)
		self.rightRecastPanel:setVisible(true)
		self.leftRecastPanel:setVisible(true)
		self.recastShowTabs = clone(ExclusiveMgr:getRecastExclusiveMap())
		self:updateLeftRecastPanel(true)
		self:updateRightRecastPanel()
    end
    self:updateBtnNewImgs()
end

function ExclusiveMainUI:updateBtnNewImgs()
    local signs = {
        ExclusiveMgr:canTreasureExclusive(),
        ExclusiveMgr:canMakeExclusive(),
        false,
        false,
    }
    
    for i = 1,4 do
        self.btnNewImgs[i]:setVisible(signs[i])
    end
end

function ExclusiveMainUI:updateRightTreasurePanel()
    ClassItemCell:createExclusiveAllInfo(self.rightTreasureSv,15,self.curObj)
end

function ExclusiveMainUI:updateRightMakePanel()
    local helpBtn = self.rightMakePanel:getChildByName('help_btn')
    helpBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(40)
		end
	end)

    local wday = tonumber(Time.date('%w', GlobalData:getServerTime()))
    if wday == 0 then
        wday = 7
    end
    local exclusiveBuildData = GameData:getConfData('exclusivebuild')[wday]
    local disPlayData = DisplayData:getDisplayObjs(exclusiveBuildData.cost)

    if self.rightMakePanel:getChildByName('rich_text') then
        self.rightMakePanel:removeChildByName('rich_text')
    end
    local richText = xx.RichText:create()
    richText:setName('rich_text')
	richText:setContentSize(cc.size(510, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_18'), 22, COLOR_TYPE.WHITE)
	re1:setStroke(cc.c4b(78,49,17,255),1)
    re1:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    local starWeights = exclusiveBuildData.starWeights
    local allWeights = 0
    for i = 1,#starWeights do
        allWeights = allWeights + starWeights[i]
    end
    local re2 = xx.RichTextLabel:create(math.floor(starWeights[2]*100/allWeights) .. '%', 22, COLOR_TYPE.GREEN)
	re2:setStroke(cc.c4b(78,49,17,255),1)
    re2:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_19'), 22, COLOR_TYPE.WHITE)
	re3:setStroke(cc.c4b(78,49,17,255),1)
    re3:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')
    local re4 = xx.RichTextLabel:create(2, 22, COLOR_TYPE.GREEN)
	re4:setStroke(cc.c4b(78,49,17,255),1)
    re4:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re4:setFont('font/gamefont.ttf')
    local re5 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_20'), 22, COLOR_TYPE.WHITE)
	re5:setStroke(cc.c4b(78,49,17,255),1)
    re5:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re5:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:addElement(re5)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(205,420))
    self.rightMakePanel:addChild(richText)
    richText:format(true)

    local wheelBg = self.rightMakePanel:getChildByName('wheel_bg')
    local markTx = wheelBg:getChildByName('mark_tx')
    markTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_17'))
    local costTxs = {}
    for i = 1,6 do
        local frame = wheelBg:getChildByName('icon_' .. i)
        frame:setLocalZOrder(2000)
        local tx = frame:getChildByName('tx')
        table.insert(costTxs,tx)
        local awards = disPlayData[i]
        tx.awards = awards
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setPosition(cc.p(47,47))
        cell.lvTx:setVisible(false)
        awards:setLightEffect(cell.awardBgImg)
        ClassItemCell:updateExclusiveStar(cell.awardBgImg,awards)

        cell.awardBgImg:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(awards,true)
		    end
	    end)
    end
    
    local makeCostTx = self.rightMakePanel:getChildByName('make_cost_tx')

    local maxBtn = self.rightMakePanel:getChildByName('max_btn')
    local maxBtnTx = maxBtn:getChildByName('tx')
    maxBtnTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_21'))
    local makeBtn = self.rightMakePanel:getChildByName('make_btn')
    makeBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_22'))
    local nameBg = self.rightMakePanel:getChildByName('name_bg')
    local costNumTx = nameBg:getChildByName('tx')
    local leftBtn = self.rightMakePanel:getChildByName('left_btn')
    local rightBtn = self.rightMakePanel:getChildByName('right_btn')

    local minNum = 0
    local maxNum = nil
    local curNum = 1
    local function update(curNumValue)
        for i = 1,6 do
            local awards = disPlayData[i]
            local num = math.floor(awards:getOwnNum()/awards:getNum())
            if not maxNum then
                maxNum = num
            elseif num < maxNum then
                maxNum = num
            end
        end
        if maxNum > 0 then
            minNum = 1
        end

        if maxNum >= 99 then
            maxNum = 99
        end

        curNum = curNumValue or minNum
        costNumTx:setString(curNum)
        costNumTx:setTextColor(COLOR_TYPE.WHITE)
        local costCoin = disPlayData[7]:getNum()*curNum
        if curNum <= 0 then
            costNumTx:setString(1)
            costNumTx:setTextColor(COLOR_TYPE.RED)
            costCoin = disPlayData[7]:getNum()*1
        end
        makeCostTx:setString(costCoin)
        if UserData:getUserObj():getGold() >= costCoin then
            makeCostTx:setTextColor(COLOR_TYPE.WHITE)
        else
            makeCostTx:setTextColor(COLOR_TYPE.RED)
        end

        for i = 1,6 do
            local costTx = costTxs[i]
            local awards = disPlayData[i]

            local showCostNum = 1
            if curNum > 1 then
                showCostNum = curNum
            end
            local costPropNum = awards:getNum() * showCostNum
            costTx:setString(awards:getOwnNum() .. '/' .. costPropNum)
            costTx.isAction = false
            if awards:getOwnNum() >= costPropNum then
                costTx:setTextColor(COLOR_TYPE.GREEN)
            else
                costTx:setTextColor(COLOR_TYPE.RED)
                costTx.isAction = true
            end
        end

        if minNum <= 0 or maxNum == 1 then
            ShaderMgr:setGrayForWidget(leftBtn)
            leftBtn:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(rightBtn)
            rightBtn:setTouchEnabled(false)
        else
            if curNum <= minNum then
                ShaderMgr:setGrayForWidget(leftBtn)
                leftBtn:setTouchEnabled(false)
                ShaderMgr:restoreWidgetDefaultShader(rightBtn)
                rightBtn:setTouchEnabled(true)
            elseif curNum >= maxNum then
                ShaderMgr:restoreWidgetDefaultShader(leftBtn)
                leftBtn:setTouchEnabled(true)
                ShaderMgr:setGrayForWidget(rightBtn)
                rightBtn:setTouchEnabled(false)
            else
                ShaderMgr:restoreWidgetDefaultShader(leftBtn)
                leftBtn:setTouchEnabled(true)
                ShaderMgr:restoreWidgetDefaultShader(rightBtn)
                rightBtn:setTouchEnabled(true)
            end
        end

        if minNum <= 0 then
            ShaderMgr:setGrayForWidget(maxBtn)
            maxBtn:setTouchEnabled(false)
            maxBtnTx:setColor(COLOR_TYPE.GRAY)
            maxBtnTx:enableOutline(COLOR_TYPE.BLACK)
        else
            ShaderMgr:restoreWidgetDefaultShader(maxBtn)
            maxBtn:setTouchEnabled(true)
            maxBtnTx:setColor(COLOR_TYPE.WHITE)
            maxBtnTx:enableOutline(cc.c4b(165, 70, 0, 255), 1)
        end

        leftBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                local showNum = curNum - 1
                if showNum <= 0 then
                    showNum = 1
                end
                update(showNum)
		    end
	    end)

        rightBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                local showNum = curNum + 1
                if showNum >= maxNum then
                    showNum = maxNum
                end
                update(showNum)
		    end
	    end)

        maxBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                if curNum >= maxNum then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_23'), COLOR_TYPE.RED)
                    return
                end
                update(maxNum)
		    end
	    end)

        makeBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                if minNum <= 0 then
                    for i = 1,6 do
                        local costTx = costTxs[i]
                        if costTx.isAction then
                            costTx:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.ScaleTo:create(0.3,2),cc.ScaleTo:create(0.3,1)))
                        end
                    end
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_103'), COLOR_TYPE.RED)
                    return
                end
                if UserData:getUserObj():getGold() < costCoin then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_25'), COLOR_TYPE.RED)
                    return
                end
                makeBtn:setTouchEnabled(false)
                local function callBack(awards)
                    self.makeAnimationIndex = 0
                    local progress = cc.ProgressTimer:create(cc.Sprite:create('uires/ui/exclusive/quan.png'))
                    progress:setReverseDirection(true)
                    progress:setName('progress')
                    progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
                    progress:setPosition(cc.p(275/2,275/2))
                    wheelBg:addChild(progress)
                    progress:setPercentage(0)
                    self:playMakeAnimation(progress,awards)
                    self:updateBtnNewImgs()
                end
                local function callBack2()
                    makeBtn:setTouchEnabled(true)
                end
                ExclusiveMgr:makeExclusive(curNum,callBack,callBack2)
		    end
	    end)
    end

    if self.rightMakePanel:getChildByName('editbox') then
        self.rightMakePanel:removeChildByName('editbox')
    end
    local editbox = cc.EditBox:create(nameBg:getContentSize(), 'uires/ui/common/touming.png')
    editbox:setName('editbox')
    editbox:setPosition(nameBg:getPosition())
    editbox:setMaxLength(10)
    editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.rightMakePanel:addChild(editbox)
    editbox:registerScriptEditBoxHandler(function(event,pSender)
        local edit = pSender
		local strFmt 
		if event == "began" then
            editbox:setText(curNum)
            costNumTx:setText('')
		elseif event == "ended" then
			local num = tonumber(editbox:getText())
			if not num then
                editbox:setText('')
				update()
				return
			end
            local endNum = 1
            if num <= 0 then
                endNum = 1
            elseif num > maxNum then
                endNum = maxNum
            else
                endNum = num
            end
            editbox:setText('')
            update(endNum)
		end
    end)
    update()
    makeBtn:setTouchEnabled(true)
end

function ExclusiveMainUI:playMakeAnimation(progress,awards)
    if self.makeAnimationIndex >= 100 then
        local lvUp = GlobalApi:createLittleLossyAniByName('ui_jueseshengji_01')
        lvUp:setPosition(cc.p(200,275))
        lvUp:setAnchorPoint(cc.p(0.5,0.5))
        lvUp:setLocalZOrder(1000)
        lvUp:setScale(0.7)
        self.rightMakePanel:addChild(lvUp)
        lvUp:getAnimation():playWithIndex(0, -1, 0)
   
        lvUp:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		    lvUp:removeFromParent()
            local wheelBg = self.rightMakePanel:getChildByName('wheel_bg')
            if wheelBg:getChildByName('progress') then
                wheelBg:removeChildByName('progress')
            end
            if awards then
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            self:updateRightMakePanel()
	    end)))
        return
    end

    local action1 = cc.DelayTime:create(0.001)
    local action2 = cc.CallFunc:create(function ()
        self.makeAnimationIndex = self.makeAnimationIndex + 5
        progress:setPercentage(self.makeAnimationIndex)
        self:playMakeAnimation(progress,awards)
    end)
    self.rightMakePanel:runAction(cc.Sequence:create(action1,action2))
end

function ExclusiveMainUI:updateRightMergePanel()
    local helpBtn = self.rightMergePanel:getChildByName('help_btn')
    helpBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(41)
		end
	end)

    local wday = tonumber(Time.date('%w', GlobalData:getServerTime()))
    if wday == 0 then
        wday = 7
    end
    local exclusiveComposeData = GameData:getConfData('exclusivecompose')[wday]

    if self.rightMergePanel:getChildByName('rich_text') then
        self.rightMergePanel:removeChildByName('rich_text')
    end
    local richText = xx.RichText:create()
    richText:setName('rich_text')
	richText:setContentSize(cc.size(510, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_63'), 22, COLOR_TYPE.WHITE)
	re1:setStroke(cc.c4b(78,49,17,255),1)
    re1:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

    local allWeights = 0
    local maxWeight = nil
    local maxWeightIndex = nil
    for i = 1,4 do
        local weight = exclusiveComposeData['weight' .. i]
        if maxWeight == nil then
            maxWeight = weight
            maxWeightIndex = i
        elseif weight > maxWeight then
            maxWeight = weight
            maxWeightIndex = i
        end
        allWeights = allWeights + weight
    end

    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_TYPE_' .. maxWeightIndex), 22, COLOR_TYPE.GREEN)
	re2:setStroke(cc.c4b(78,49,17,255),1)
    re2:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_64'), 22, COLOR_TYPE.WHITE)
	re3:setStroke(cc.c4b(78,49,17,255),1)
    re3:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')
    local re4 = xx.RichTextLabel:create(math.floor(maxWeight*100/allWeights) .. '%', 22, COLOR_TYPE.GREEN)
	re4:setStroke(cc.c4b(78,49,17,255),1)
    re4:setShadow(cc.c4b(78,49,17,255), cc.size(0, -1))
    re4:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(205,420))
    self.rightMergePanel:addChild(richText)
    richText:format(true)

    local topImg = self.rightMergePanel:getChildByName('top_img')
    for i = 1,tonumber(GlobalApi:getGlobalValue('openStarLvl')) do
        if topImg:getChildByName('star_img' .. i) then
            topImg:removeChildByName('star_img' .. i)
        end
    end
    local markTx = topImg:getChildByName('mark_tx')
    local desc = self.rightMergePanel:getChildByName('desc')

    local function getPos(num,node)
        local posXS = {}
        local offset = 0
        local width = 19
        local allWidth = num*width + (num - 1)*offset
        local size = node:getContentSize()
        local initPosX = size.width/2 - allWidth/2 + width/2
        for i = 1,num do
            local posX = initPosX + (i - 1)*(offset + width)
            table.insert(posXS,posX)
        end
        return posXS
    end

    local hasExclusiveNum = 0
    for k,v in pairs(self.chooseExclusiveObj) do
        if v then
            hasExclusiveNum = hasExclusiveNum + 1
        end
    end
    if hasExclusiveNum == 2 then
        markTx:setVisible(true)
        markTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_17'))
        local mergeStarLevel = self.mergeLevel + 1
	    local starsUrl =  'uires/ui/role/role_star_'..STARS[mergeStarLevel]..'.png'
        local posXS = getPos(mergeStarLevel,topImg)
        for i = 1,mergeStarLevel do
            local img = ccui.ImageView:create(starsUrl)
            img:setName("star_img" .. i)
            img:setPosition(cc.p(posXS[i],28))
            topImg:addChild(img)
        end
        
        if self.mergeLevel == 1 or self.mergeLevel == 2 then
            desc:setVisible(true)
            local tab = exclusiveComposeData.starWeights
            desc:setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_62'),tab[2]*100/(tab[1] + tab[2]) .. '%',self.mergeLevel + 2))
        else
            desc:setVisible(false)
        end
    else
        markTx:setVisible(false)
        desc:setVisible(true)
        desc:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_29'))
    end

	local makeBtn = self.rightMergePanel:getChildByName('make_btn')
    for i = 1,2 do
        local container = self.rightMergePanel:getChildByName('container_' .. i)
        local icon = container:getChildByName('icon')
        local closeBtn = container:getChildByName('close_btn')

        for i = 1,tonumber(GlobalApi:getGlobalValue('openStarLvl')) do
            if container:getChildByName('star_img' .. i) then
                container:removeChildByName('star_img' .. i)
            end
        end
        local obj = self.chooseExclusiveObj[i]
        if obj then
            icon:setVisible(true)
            icon:loadTexture(obj:getIcon())

            local mergeStarLevel = self.mergeLevel
	        local starsUrl =  'uires/ui/role/role_star_'..STARS[mergeStarLevel]..'.png'
            local posXS = getPos(mergeStarLevel,container)
            for i = 1,mergeStarLevel do
                local img = ccui.ImageView:create(starsUrl)
                img:setName("star_img" .. i)
                img:setPosition(cc.p(posXS[i],10))
                container:addChild(img)
            end
            closeBtn:setVisible(true)
        else
            icon:setVisible(false)
            closeBtn:setVisible(false)
        end

        local function makeLogic()
			if makeBtn:isTouchEnabled() == false then
				return
			end
            if obj then
                self.chooseExclusiveObj[i] = nil
                self:updateLeftMergeCellsNum(1,obj:getId())
                local judge = false
                for i = 1,2 do
                    if self.chooseExclusiveObj[i] then
                        judge = true
                        break
                    end
                end
                if judge == false then
                    self.mergeLevel = nil
                end
                self:updateRightMergePanel()
            end
        end
        container:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                makeLogic()
		    end
	    end)

        closeBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                makeLogic()
		    end
	    end)

    end

    local resImg = self.rightMergePanel:getChildByName('res_img')
    local costCashTx = resImg:getChildByName('tx')
    makeBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_67'))
    makeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            if hasExclusiveNum < 2 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_69'), COLOR_TYPE.RED)
                return
            end

            local hasNum = 0
            for j = 1,4 do
                if self.chooseExclusiveLimit[j] then
                    hasNum = hasNum + 1
                end
            end
            local costCash = tonumber(GlobalApi:getGlobalValue('compCost'))*hasNum

            local function callBack2()
				makeBtn:setTouchEnabled(false)
                local function callBack(awards)
                    local lvUp = GlobalApi:createLittleLossyAniByName('ui_jueseshengji_01')
                    lvUp:setPosition(cc.p(200,355))
                    lvUp:setAnchorPoint(cc.p(0.5,0.5))
                    lvUp:setLocalZOrder(10000)
                    lvUp:setScale(0.8)
                    self.rightMergePanel:addChild(lvUp)
                    lvUp:getAnimation():playWithIndex(0, -1, 0)
   
                    lvUp:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function()
		                lvUp:removeFromParent()
                        for i = 1,2 do
                            self.chooseExclusiveObj[i] = nil
                        end
                        if awards then
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end

                        local curShowTabsData = self.mergeShowTabs[self.mergeLevel]
                        self.mergeShowTabs = clone(ExclusiveMgr:getMergeExclusiveMap())
                        self.mergeShowTabs[self.mergeLevel] = curShowTabsData
                        self.mergeLevel = nil
                        if self.mergeLevel ~= self.curMergeLevelIndex then
                            self:updateLeftMergePanel(true)
                        end
                        self:updateRightMergePanel()
                        self:updateBtnNewImgs()
						makeBtn:setTouchEnabled(true)
	                end)))
                end
                local ids = {}
                local except = {}

                for k,v in pairs(self.chooseExclusiveObj) do
                    if v then
                        table.insert(ids,v:getId())
                    end
                end

                for ii = 1,4 do
                    if self.chooseExclusiveLimit[ii] then
                        except[tostring(ii)] = self.chooseExclusiveLimit[ii]
                    end
                end
				local function errorCallBack()
					makeBtn:setTouchEnabled(true)
				end
                ExclusiveMgr:mergeExclusive(ids,except,callBack,errorCallBack)
            end

            if costCash > 0 then
                local hasCash = UserData:getUserObj():getCash()
                if costCash > hasCash then
                    promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        GlobalApi:getGotoByModule("cash")
                    end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                else
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_70'),costCash),
                        MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            callBack2()
                        end)
                end
            else
                callBack2()
            end

		end
	end)

    local centerImg = self.rightMergePanel:getChildByName('center_img')
    local function updateSelectItem()
        local costCash = 0
        for i = 1,4 do
             local frame = centerImg:getChildByName('frame_' .. i)
             local selectImg = frame:getChildByName('select_img')
             if self.chooseExclusiveLimit[i] then
                selectImg:setVisible(true)
                costCash = costCash + tonumber(GlobalApi:getGlobalValue('compCost'))
             else
                selectImg:setVisible(false)
             end
        end
        if costCash > 0 then
            costCashTx:setString(costCash)
        else
            costCashTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_66'))
        end
    end

    for i = 1,4 do
        local frame = centerImg:getChildByName('frame_' .. i)
        local desc = frame:getChildByName('desc')
        desc:setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_65'),GlobalApi:getLocalStr('EXCLUSIVE_TYPE_' .. i)))
        local costCash = frame:getChildByName('cost_cash')
        costCash:setString(tonumber(GlobalApi:getGlobalValue('compCost')))

        local selectImg = frame:getChildByName('select_img')
        local chooseBg = frame:getChildByName('choose_bg')
        chooseBg:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
		    if eventType == ccui.TouchEventType.ended then
                if self.chooseExclusiveLimit[i] then
                    self.chooseExclusiveLimit[i] = nil
                    selectImg:setVisible(false)
                    updateSelectItem()
                    return
                end

                local hasNum = 0
                for j = 1,4 do
                    if self.chooseExclusiveLimit[j] then
                        hasNum = hasNum + 1
                    end
                end
                
                if hasNum >= tonumber(GlobalApi:getGlobalValue('compMax')) then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_68'), COLOR_TYPE.RED)
                    return
                end

                self.chooseExclusiveLimit[i] = i
                selectImg:setVisible(true)
                updateSelectItem()
		    end
	    end)
    end
    updateSelectItem()
	makeBtn:setTouchEnabled(true)
end

function ExclusiveMainUI:updateLeftTreasurePanel()
    local objArr = {}
    for k, v in pairs(RoleData:getRoleMap()) do
		if v:getId() < 10000 and v:getId() > 0 then
			objArr[tonumber(k)] = v
		end
	end

    local bg = self.leftTreasurePanel:getChildByName('bg')
    local bottomImg = bg:getChildByName('bottom_img')
    local sv = bottomImg:getChildByName('sv')
    local innerContainer = sv:getInnerContainer()

    local function updateArrow()
        local judge = false
        for i = 5,7 do
            if objArr[i] and objArr[i]:isCanEquipExclusive() == true then
                judge = true
                break
            end
        end
        local posX = innerContainer:getPositionX()
        local offset = sv:getContentSize().width - innerContainer:getContentSize().width
        if judge == true then
            if (posX <= offset) or (posX >= offset + 95 and posX <= offset) then
                self.leftTreasureArrow:setVisible(false)
            else
                self.leftTreasureArrow:setVisible(true)
            end
        else
            self.leftTreasureArrow:setVisible(false)
        end
    end
    if self.curObj then
        updateArrow()
        for i = 1,#self.roleArr do
            local infoImg = self.roleArr[i].infoImg
            infoImg:setVisible(self.roleArr[i].obj:isCanEquipExclusive())
        end
        self:updateLeftTreasureEquipPanel()
        return
    end

    self.curObj = objArr[1]
    sv:setScrollBarEnabled(false)
    local cell = bottomImg:getChildByName('cell')
    cell:setVisible(false)

    local num = #objArr
    local size = sv:getContentSize()
    local allWidth = size.width
    local cellSpace = 20
    local CELLWIDTH = 90
    local CELLHEIGHT = 84.6
    local width = num * CELLWIDTH + (num - 1)*cellSpace + 5
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = CELLWIDTH
    for i = 1,num,1 do
        local tempCell = cell:clone()
        tempCell:setName('tempCell' .. i)
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()
        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(5 + offset,57))
        sv:addChild(tempCell)

        local selectImg = tempCell:getChildByName('select_img')
        selectImg:setLocalZOrder(-1)
        selectImg:setVisible(false)
        local obj = objArr[i]
        self.roleArr[tonumber(obj:getPosId())] = tempCell
        tempCell.obj = obj
        tempCell.selectImg = selectImg

        local icon = tempCell:getChildByName('icon')
	    local bgiconSize = icon:getContentSize()
        if icon:getChildByName('award_bg_img') then
            icon:removeChildByName('award_bg_img')
        end
	    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, obj, icon)
	    iconCell.awardBgImg:setPosition(cc.p(bgiconSize.width/2, bgiconSize.height/2))
	    iconCell.awardBgImg:setTouchEnabled(false)
	    iconCell.awardBgImg:ignoreContentAdaptWithSize(true)
	    iconCell.awardImg:ignoreContentAdaptWithSize(true)

        tempCell:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.ended then
			    if self.curObj == obj then
                    return
                end
                self.curObj = obj
                self:updateLeftTreasureEquipPanel()
                self:updateRightTreasurePanel()
	        end
	    end)

        local infoImg = tempCell:getChildByName('info_img')
        infoImg:setLocalZOrder(9999)
        infoImg:setVisible(obj:isCanEquipExclusive())
        tempCell.infoImg = infoImg
    end
    innerContainer:setPositionX(0)
    updateArrow()
    local function scrollViewEvent(sender, evenType)
        updateArrow()
    end
    sv:addEventListener(scrollViewEvent)
    self:updateLeftTreasureEquipPanel()
end

function ExclusiveMainUI:updateLeftTreasureEquipPanel()
    for k,v in pairs(self.roleArr) do
        if tonumber(k) == self.curObj:getPosId() then
            v.selectImg:setVisible(true)
        else
            v.selectImg:setVisible(false)
        end
    end
    local nameTx = self.leftTreasurePanel:getChildByName('name_tx')
    nameTx:setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_6'),self.curObj:getName()))
    nameTx:setTextColor(self.curObj:getNameColor())
    
    local bg = self.leftTreasurePanel:getChildByName('bg')
	local fightforceImg = bg:getChildByName('fightforce_img')
    if fightforceImg:getChildByName('left_label') then
        fightforceImg:removeChildByName('left_label')
    end
	local leftLabel = cc.LabelAtlas:_create(RoleData:getPosFightForceByPos(self.curObj), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    leftLabel:setName('left_label')
	leftLabel:setAnchorPoint(cc.p(0.5,0.5))
	leftLabel:setPosition(cc.p(111.00,16.50))
	leftLabel:setScale(0.7)
	fightforceImg:addChild(leftLabel)

    local roleBg = self.leftTreasurePanel:getChildByName('role_bg')
	local anim_pl = roleBg:getChildByName('anm_pl')
    anim_pl:removeAllChildren()
	local actionisruning = false
    local action = ""
	local spineAni = GlobalApi:createLittleLossyAniByName(self.curObj:getUrl() .. "_display", nil, self.curObj:getChangeEquipState())
	local heroconf = GameData:getConfData('hero')[self.curObj:getId()]
	if spineAni then
		local shadow = spineAni:getBone(self.curObj:getUrl() .. "_display_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
			shadow:setIgnoreMovementBoneData(true)
		end
		spineAni:setPosition(cc.p(anim_pl:getContentSize().width/2,50+heroconf.uiOffsetY))
		anim_pl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		anim_pl:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
			end
			if eventType ==  ccui.TouchEventType.ended or 
				eventType == ccui.TouchEventType.canceled then
				if actionisruning  ~= true then
					actionisruning = true
					local seed = math.random(1, 5)
	                if action ~= roleAnim[seed] then
		                action = roleAnim[seed]
		                spineAni:getAnimation():play(roleAnim[seed], -1, -1)
	                end
				end
			end
		end) 
		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end

    for i = 1,4 do
        local armNode = self.leftTreasurePanel:getChildByName('arm_node_' .. i)
        local noChooseImg = armNode:getChildByName('no_choose_img')
        local addImg = armNode:getChildByName('add_img')
        local infoImg = armNode:getChildByName('info_img')
        infoImg:setVisible(self.curObj:isCanEquipBetterExclusiveByType(i))
        infoImg:setLocalZOrder(9999)

        if armNode:getChildByName('award_bg_img') then
            armNode:removeChildByName('award_bg_img')
        end
        local exclusiveId = self.curObj:getExclusiveId(tostring(i))
        local exclusiveObj = nil
        if exclusiveId > 0 then
            exclusiveObj = BagData:getExclusiveObjById(exclusiveId)
            local awardCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, exclusiveObj, armNode)
            awardCell.awardBgImg:setPosition(cc.p(47,47))
            awardCell.awardBgImg:setTouchEnabled(false)
            awardCell.lvTx:setVisible(false)
            exclusiveObj:setLightEffect(awardCell.awardBgImg)
            ClassItemCell:updateExclusiveStar(awardCell.awardBgImg,exclusiveObj)
        end

        local exclusiveMap = ExclusiveMgr:getExclusiveMapByType(i,exclusiveId)
        local num = #exclusiveMap
        local state = 1
        if exclusiveId > 0 then
            addImg:setVisible(false)
            noChooseImg:setVisible(false)
        else
            addImg:setVisible(true)
            noChooseImg:setVisible(true)
            if num > 0 then
                addImg:loadTexture('uires/ui/common/add_01.png')
            else
                state = 2
                addImg:loadTexture('uires/ui/common/add_02.png')
                addImg:setVisible(false)
            end
        end
 
        armNode:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.ended then
			    if state == 1 then
                    ExclusiveMgr:showExclusiveExchangeUI(exclusiveMap,exclusiveObj,self.curObj)
                else
                    local id = i*100 + 4
					if i == 1 then
						id = 360008
					elseif i == 2 then
						id = 360010
					elseif i == 3 then
						id = 360009
					else
						id = 360011
					end
                    GetWayMgr:showGetwayUI(BagData:getMaterialById(id),true)
                end
	        end
	    end)
    end
end

function ExclusiveMainUI:updateLeftMakePanel()
    local nameTx = self.leftMakePanel:getChildByName('name_tx')
    nameTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_8'))

    local bg = self.leftMakePanel:getChildByName('bg')
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    local showTab = ExclusiveMgr:getMakeExclusiveMap()
    local num = #showTab
    local CELLWIDHT = 94*0.98
    local CELLHEIGHT = 94*0.98
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellWidthSpace = 15
    local cellHeightSpace = 10

    local height = math.ceil(num/4) * CELLHEIGHT + (math.ceil(num/4) - 1)*cellHeightSpace + 6
    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 3
    for i = 1,num do
        if not sv:getChildByName('award_bg_img_' .. i) then
            local v = showTab[i]
            local awardBgImg = ClassItemCell:updateExclusive(sv,v,'award_bg_img_'..i)
		    awardBgImg:addTouchEventListener(function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	                AudioMgr.PlayAudio(11)
	            elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(v,false)
	            end
	        end)

            awardBgImg:setScale(0.98)
            awardBgImg:setAnchorPoint(cc.p(0,0))
            local remainderNum = (i%4 == 0) and 4 or i%4
        
            local posX = 14 + (CELLWIDHT + cellWidthSpace)*(remainderNum - 1)
            local posY = 0
            local curCellHeight = 0
            if i%4 == 1 then
                curCellHeight = CELLHEIGHT
            end
            local curSpace = 0
            if i == 1 or i == 2 or i == 3 or i == 4 then
                curSpace = 0
            elseif i%4 == 1 then
                curSpace = cellHeightSpace
            end
            offset = offset + curCellHeight + curSpace
            local posY = allHeight - offset
            awardBgImg:setPosition(cc.p(posX,posY))
        end
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function ExclusiveMainUI:updateLeftMergePanel(clearData)
    self.mergeCells = {}
    if clearData == true then
        self.mergeLevel = nil
        self.chooseExclusiveObj = {}
    end
    
    local nameTx = self.leftMergePanel:getChildByName('name_tx')
    nameTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_24'))

    local bg = self.leftMergePanel:getChildByName('bg')
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local noMergeTx = self.leftMergePanel:getChildByName('no_treasure_tx')
    noMergeTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_26'))

    local autoBtn = self.leftMergePanel:getChildByName('auto_btn')
    autoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_27'))
    autoBtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then  
            local mergeNum = 0
            for k,m in pairs(self.chooseExclusiveObj) do
                if m then
                    mergeNum = mergeNum + 1
                end
            end
            if mergeNum >= 2 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_71'), COLOR_TYPE.RED)
                return
            end

            if self.mergeLevel and self.curMergeLevelIndex ~= self.mergeLevel then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_61'), COLOR_TYPE.RED)
                return
            end
            
            local judge = false
            for i = 1,2 do
                if not self.chooseExclusiveObj[i] then
                    local mergeObj = self.mergeShowTabs[self.curMergeLevelIndex][1]
                    if not mergeObj then
                        judge = true
                    else
                        self.chooseExclusiveObj[i] = self.mergeShowTabs[self.curMergeLevelIndex][1]
                        self.mergeLevel = self.chooseExclusiveObj[i]:getLevel()
                        self:updateLeftMergeCellsNum(-1,self.chooseExclusiveObj[i]:getId())
                    end  
                end
            end
            if judge == true then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_72'), COLOR_TYPE.RED)
            end
            self:updateRightMergePanel()
	    end
	end)

    local starTips = self.leftMergePanel:getChildByName('star_tips')
    starTips:setVisible(false)
    local tipsBtn = starTips:getChildByName('btn')
    tipsBtn:setVisible(false)
    local showLevel = tonumber(GlobalApi:getGlobalValue('openStarLvl')) - 1
    local tipsHeight = 41*math.ceil(showLevel/2)
    starTips:setContentSize(cc.size(starTips:getContentSize().width,tipsHeight))
    local cellTotalHeight = 9
    for i = 1,showLevel do
        if not starTips:getChildByName('cell' .. i) then
            local btn = tipsBtn:clone()
            btn:setVisible(true)
            btn:setName('cell' .. i)

            local curCellHeight = 0
            if i%2 == 1 then
                curCellHeight = 31
            end

            local curSpace = 0
            if i == 1 or i == 2 then
                curSpace = 0
            elseif i%2 == 1 then
                curSpace = 5
            end
            cellTotalHeight = cellTotalHeight + curCellHeight + curSpace
            btn:setPosition(cc.p((i%2 == 1) and 13 or 111,tipsHeight - cellTotalHeight))
            starTips:addChild(btn)

            btn:getChildByName('tx'):setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_28'),i))
            btn:addTouchEventListener(function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	                AudioMgr.PlayAudio(11)
	            elseif eventType == ccui.TouchEventType.ended then
                    if self.curMergeLevelIndex == i then
                        starTips:setVisible(false)
                        return
                    end
	                self.curMergeLevelIndex = i
                    self:updateLeftMergePanel()
	            end
	        end)
        end
    end

    local starBtn = self.leftMergePanel:getChildByName('star_btn')
    starBtn:getChildByName('tx'):setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_28'),self.curMergeLevelIndex))
    starBtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then
	        starTips:setVisible(not starTips:isVisible())
	    end
	end)

    local showTab = self.mergeShowTabs[self.curMergeLevelIndex]
    local num = #showTab
    sv:removeAllChildren()
    if num <= 0 then
        noMergeTx:setVisible(true)
        return
    end
    noMergeTx:setVisible(false)

    local CELLWIDHT = 94*0.98
    local CELLHEIGHT = 94*0.98
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellWidthSpace = 15
    local cellHeightSpace = 10

    local height = math.ceil(num/4) * CELLHEIGHT + (math.ceil(num/4) - 1)*cellHeightSpace + 6
    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    else
        innerContainer:setContentSize(cc.size(size.width,size.height))
        allHeight = size.height
    end

    local offset = 3
    for i = 1,num do
        local v = showTab[i]
        local awardBgImg = ClassItemCell:updateExclusive(sv,v,'award_bg_img_'..i,true)
        awardBgImg.obj = v
        table.insert(self.mergeCells,awardBgImg)
		awardBgImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
                -- 选择
                if self.mergeLevel and self.curMergeLevelIndex ~= self.mergeLevel then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_61'), COLOR_TYPE.RED)
                    return
                end

                local mergeNum = 0
                for k,m in pairs(self.chooseExclusiveObj) do
                    if m then
                        mergeNum = mergeNum + 1
                    end
                end
                if mergeNum >= 2 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_60'), COLOR_TYPE.RED)
                    return
                end

                for i = 1,2 do
                    if not self.chooseExclusiveObj[i] then
                        self.chooseExclusiveObj[i] = v
                        self.mergeLevel = v:getLevel()
                        break
                    end
                end
                self:updateLeftMergeCellsNum(-1,v:getId())
                self:updateRightMergePanel()
	        end
	    end)

        awardBgImg:setScale(0.98)
        awardBgImg:setAnchorPoint(cc.p(0,0))
        local remainderNum = (i%4 == 0) and 4 or i%4
        
        local posX = 14 + (CELLWIDHT + cellWidthSpace)*(remainderNum - 1)
        local posY = 0
        local curCellHeight = 0
        if i%4 == 1 then
            curCellHeight = CELLHEIGHT
        end
        local curSpace = 0
        if i == 1 or i == 2 or i == 3 or i == 4 then
            curSpace = 0
        elseif i%4 == 1 then
            curSpace = cellHeightSpace
        end
        offset = offset + curCellHeight + curSpace
        local posY = allHeight - offset
        awardBgImg:setPosition(cc.p(posX,posY))
    end
    innerContainer:setPositionY(size.height - allHeight)

end

function ExclusiveMainUI:updateLeftMergeCellsNum(addNum,id)
    local exclusiveObj = BagData:getExclusiveObjById(id)
    if self.curMergeLevelIndex == exclusiveObj:getLevel() then
        for i = 1,#self.mergeCells do
            local cell = self.mergeCells[i]
            local obj = cell.obj

            if obj:getId() == id then
                local curNum = obj:getNum()
                if curNum + addNum <= 0 then
                    for k,v in pairs(self.mergeShowTabs[self.curMergeLevelIndex]) do
                        if v:getId() == id then
                            table.remove(self.mergeShowTabs[self.curMergeLevelIndex],k)
                        end
                    end
                    self:updateLeftMergePanel()
                else
                    obj:addNum(addNum)
                    local lvTx = cell:getChildByName('lv_tx')
			        lvTx:setString('x'..obj:getNum())
                end
                return
            end
        end

        exclusiveObj.num = addNum
        table.insert(self.mergeShowTabs[exclusiveObj:getLevel()],exclusiveObj)
        ExclusiveMgr:sortData(self.mergeShowTabs[exclusiveObj:getLevel()])
        self:updateLeftMergePanel()
    else
        local data = self.mergeShowTabs[exclusiveObj:getLevel()]
        for i = 1,#data do
            if data[i]:getId() == id then
                data[i]:addNum(addNum)
                return
            end
        end

        exclusiveObj.num = addNum
        table.insert(self.mergeShowTabs[exclusiveObj:getLevel()],exclusiveObj)
        ExclusiveMgr:sortData(self.mergeShowTabs[exclusiveObj:getLevel()])
    end
end

function ExclusiveMainUI:updateLeftRecastPanel(clearData)
	self.recastCells = {}
    if clearData == true then
        self.recastLevel = nil
        self.chooseRecastExclusiveObj = nil
    end
    
    local nameTx = self.leftRecastPanel:getChildByName('name_tx')
    nameTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_24'))

    local bg = self.leftRecastPanel:getChildByName('bg')
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local noMergeTx = self.leftRecastPanel:getChildByName('no_treasure_tx')
    noMergeTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_108'))
	
    local autoBtn = self.leftRecastPanel:getChildByName('auto_btn')
    autoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_27'))
    autoBtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then  
			if self.chooseRecastExclusiveObj then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_111'), COLOR_TYPE.RED)
				return
			end

			local exclusiveObj = self.recastShowTabs[self.curRecastLevelIndex][1]
			if exclusiveObj then
				self.chooseRecastExclusiveObj = exclusiveObj
                self.recastLevel = self.chooseRecastExclusiveObj:getLevel()
                self:updateLeftRecastCellsNum(-1,self.chooseRecastExclusiveObj:getId())
				self:updateRightRecastPanel()
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_72'), COLOR_TYPE.RED)
			end
	    end
	end)

    local starTips = self.leftRecastPanel:getChildByName('star_tips')
    starTips:setVisible(false)
    local tipsBtn = starTips:getChildByName('btn')
    tipsBtn:setVisible(false)
    local showLevel = tonumber(GlobalApi:getGlobalValue('openStarLvl'))
    local tipsHeight = 41*math.ceil(showLevel/2)
    starTips:setContentSize(cc.size(starTips:getContentSize().width,tipsHeight))
    local cellTotalHeight = 9
    for i = 1,showLevel do
        if not starTips:getChildByName('cell' .. i) then
            local btn = tipsBtn:clone()
            btn:setVisible(true)
            btn:setName('cell' .. i)

            local curCellHeight = 0
            if i%2 == 1 then
                curCellHeight = 31
            end

            local curSpace = 0
            if i == 1 or i == 2 then
                curSpace = 0
            elseif i%2 == 1 then
                curSpace = 5
            end
            cellTotalHeight = cellTotalHeight + curCellHeight + curSpace
            btn:setPosition(cc.p((i%2 == 1) and 13 or 111,tipsHeight - cellTotalHeight))
            starTips:addChild(btn)

            btn:getChildByName('tx'):setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_28'),i))
            btn:addTouchEventListener(function (sender, eventType)
	            if eventType == ccui.TouchEventType.began then
	                AudioMgr.PlayAudio(11)
	            elseif eventType == ccui.TouchEventType.ended then
					if self.curRecastLevelIndex == i then
                        starTips:setVisible(false)
                        return
                    end
	                self.curRecastLevelIndex = i
                    self:updateLeftRecastPanel()
					if self.chooseRecastExclusiveObj then
						self:updateLeftRecastCellsNum(1,self.chooseRecastExclusiveObj:getId())
						self.chooseRecastExclusiveObj = nil
						self.recastLevel = nil
					end
					self:updateRightRecastPanel()
	            end
	        end)
        end
    end

    local starBtn = self.leftRecastPanel:getChildByName('star_btn')
    starBtn:getChildByName('tx'):setString(string.format(GlobalApi:getLocalStr('EXCLUSIVE_DESC_28'),self.curRecastLevelIndex))
    starBtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then
	        starTips:setVisible(not starTips:isVisible())
	    end
	end)

    local showTab = self.recastShowTabs[self.curRecastLevelIndex]
    local num = #showTab
    sv:removeAllChildren()
    if num <= 0 then
        noMergeTx:setVisible(true)
        return
    end
    noMergeTx:setVisible(false)

    local CELLWIDHT = 94*0.98
    local CELLHEIGHT = 94*0.98
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allHeight = size.height
    local cellWidthSpace = 15
    local cellHeightSpace = 10

    local height = math.ceil(num/4) * CELLHEIGHT + (math.ceil(num/4) - 1)*cellHeightSpace + 6
    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    else
        innerContainer:setContentSize(cc.size(size.width,size.height))
        allHeight = size.height
    end

    local offset = 3
    for i = 1,num do
        local v = showTab[i]
        local awardBgImg = ClassItemCell:updateExclusive(sv,v,'award_bg_img_'..i,true)
        awardBgImg.obj = v
        table.insert(self.recastCells,awardBgImg)
		awardBgImg:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
				local function callBack()
					if self.chooseRecastExclusiveObj then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_111'), COLOR_TYPE.RED)
						return
					end
					self.chooseRecastExclusiveObj = v
					self.recastLevel = v:getLevel()
					self:updateLeftRecastCellsNum(-1,v:getId())
					self:updateRightRecastPanel()
				end
				ExclusiveMgr:showExclusivePutUI(v,nil,callBack)
	        end
	    end)

        awardBgImg:setScale(0.98)
        awardBgImg:setAnchorPoint(cc.p(0,0))
        local remainderNum = (i%4 == 0) and 4 or i%4
        
        local posX = 14 + (CELLWIDHT + cellWidthSpace)*(remainderNum - 1)
        local posY = 0
        local curCellHeight = 0
        if i%4 == 1 then
            curCellHeight = CELLHEIGHT
        end
        local curSpace = 0
        if i == 1 or i == 2 or i == 3 or i == 4 then
            curSpace = 0
        elseif i%4 == 1 then
            curSpace = cellHeightSpace
        end
        offset = offset + curCellHeight + curSpace
        local posY = allHeight - offset
        awardBgImg:setPosition(cc.p(posX,posY))
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function ExclusiveMainUI:updateRightRecastPanel()
	local helpBtn = self.rightRecastPanel:getChildByName('help_btn')
    helpBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(42)
		end
	end)

	local makeBtn = self.rightRecastPanel:getChildByName('make_btn')
    local container = self.rightRecastPanel:getChildByName('container')
    local icon = container:getChildByName('icon')
    local closeBtn = container:getChildByName('close_btn')

    for i = 1,tonumber(GlobalApi:getGlobalValue('openStarLvl')) do
        if container:getChildByName('star_img' .. i) then
            container:removeChildByName('star_img' .. i)
        end
    end

	local function getPos(num,node)
        local posXS = {}
        local offset = 0
        local width = 19
        local allWidth = num*width + (num - 1)*offset
        local size = node:getContentSize()
        local initPosX = size.width/2 - allWidth/2 + width/2
        for i = 1,num do
            local posX = initPosX + (i - 1)*(offset + width)
            table.insert(posXS,posX)
        end
        return posXS
    end

    local obj = self.chooseRecastExclusiveObj
    if obj then
        icon:setVisible(true)
        icon:loadTexture(obj:getIcon())

        local recastStarLevel = self.recastLevel
	    local starsUrl =  'uires/ui/role/role_star_'..STARS[recastStarLevel]..'.png'
        local posXS = getPos(recastStarLevel,container)
        for i = 1,recastStarLevel do
            local img = ccui.ImageView:create(starsUrl)
            img:setName("star_img" .. i)
            img:setPosition(cc.p(posXS[i],10))
            container:addChild(img)
        end
        closeBtn:setVisible(true)
    else
        icon:setVisible(false)
        closeBtn:setVisible(false)
    end

    local function makeLogic()
		if makeBtn:isTouchEnabled() == false then
			return
		end
        if obj then
			self.chooseRecastExclusiveObj = nil
			self:updateLeftRecastCellsNum(1,obj:getId())
			self.recastLevel = nil
			self:updateRightRecastPanel()
        end
    end
    container:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            makeLogic()
		end
	end)

    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            makeLogic()
		end
	end)

	local guangImgs = {}
	for i = 1,4 do
		local guanImg = self.rightRecastPanel:getChildByName('guang_' .. i)
		guanImg:setVisible(false)
		table.insert(guangImgs,guanImg)
	end

	local recastConfData = GameData:getConfData('recast')[self.curRecastLevelIndex]
    local resImg = self.rightRecastPanel:getChildByName('res_img')
    local costCashTx = resImg:getChildByName('tx')
    makeBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_109'))
	local costGoldAward = recastConfData.cost[1]
	local costGold = math.abs(tonumber(costGoldAward[3]))
	costCashTx:setString(costGold)
    makeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			if not self.chooseRecastExclusiveObj then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_112'), COLOR_TYPE.RED)
                return
			end
			local hasGold = UserData:getUserObj():getGold()
			if costGold > hasGold then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('EXCLUSIVE_DESC_113'), COLOR_TYPE.RED)
                return
            else
				makeBtn:setTouchEnabled(false)
                local function callBack(awards,group)
					local function callBack2()
						local level = self.chooseRecastExclusiveObj:getLevel()
						self.recastShowTabs = clone(ExclusiveMgr:getRecastExclusiveMap())
						self:updateLeftRecastPanel(true)
						self:updateRightRecastPanel()
						makeBtn:setTouchEnabled(true)
					end
					-- 动画
					local endId = group
					if group == 3 then
						endId = 4
					end
					if group == 4 then
						endId = 3
					end
					self.recastAnimationIndex = 1
					self.endIndex = 4*1 + endId
					self:playRecastAnimation(guangImgs,awards,callBack2)
                end
				local function errorCallBack()
					makeBtn:setTouchEnabled(true)
				end
                ExclusiveMgr:recastExclusive(self.chooseRecastExclusiveObj:getId(),callBack,errorCallBack)
            end
		end
	end)

	local allWeights = recastConfData.weight1 + recastConfData.weight2 + recastConfData.weight3 + recastConfData.weight4
	-- 一个上一星级宝物+高级鉴宝券,高一星级的宝物,同星级宝物,两个上一星级的宝物
	local color = {COLOR_TYPE.WHITE,COLOR_TYPE.RED,COLOR_TYPE.ORANGE,COLOR_TYPE.GREEN}
	for i = 1,4 do
		local item = self.rightRecastPanel:getChildByName('item' .. i)

		if item:getChildByName('rich_text') then
			item:removeChildByName('rich_text')
		end
		local richText = xx.RichText:create()
		richText:setName('rich_text')
		richText:setContentSize(cc.size(510, 40))
		local re1 = xx.RichTextLabel:create(math.floor(recastConfData['weight' .. i]*100/allWeights) .. '%', 20, color[i])
		re1:setStroke(COLOR_TYPE.BLACK,1)
		re1:setShadow(cc.c3b(0x40, 0x40, 0x40), cc.size(0, -1))
		re1:setFont('font/gamefont.ttf')
		local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('EXCLUSIVE_DESC_114'), 20, color[i])
		re2:setStroke(COLOR_TYPE.BLACK,1)
		re2:setShadow(cc.c3b(0x40, 0x40, 0x40), cc.size(0, -1))
		re2:setFont('font/gamefont.ttf')
		richText:addElement(re1)
		richText:addElement(re2)
		richText:setAlignment('middle')
		richText:setVerticalAlignment('middle')
		richText:setAnchorPoint(cc.p(0.5,0.5))
		richText:setPosition(cc.p(83,80))
		item:addChild(richText)
		richText:format(true)

		local frame1 = item:getChildByName('node_1')
		local frame2 = item:getChildByName('node_2')
		if frame1:getChildByName('award_bg_img') then
            frame1:removeChildByName('award_bg_img')
        end
		if frame2:getChildByName('award_bg_img') then
            frame2:removeChildByName('award_bg_img')
        end

		local showAwards = {}
		local recastId = recastConfData['recast' .. i]
		local recastGroupData = GameData:getConfData('recastgroup')[recastId]
		showAwards = clone(recastGroupData.fixed)
		local randType = recastGroupData.randType
		local randNum = recastGroupData.randNum
		local starLvId = {'101','104','107','111','116','122','131'}
		local starLvItemId = {'360012','360013','360014','360015','360016','360017','360018'}
        for j = 1,randNum do
            table.insert(showAwards,{'exclusive',starLvId[randType],1})
        end
		local disPlayData = DisplayData:getDisplayObjs(showAwards)
		local showFrames = {}
		if #disPlayData == 1 then
			frame1:setPosition(83,38)
			frame2:setVisible(false)
			table.insert(showFrames,frame1)
		else
			frame1:setPosition(cc.p(45.5,38))
			frame2:setVisible(true)
			table.insert(showFrames,frame1)
			table.insert(showFrames,frame2)
		end
		for k = 1,#showFrames do
			if disPlayData[k] then
				local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, disPlayData[k], showFrames[k])
				cell.awardBgImg:setPosition(cc.p(47,47))
				disPlayData[k]:setLightEffect(cell.awardBgImg)
				ClassItemCell:updateExclusiveStar(cell.awardBgImg,disPlayData[k])

				if disPlayData[k]:getObjType() == 'exclusive' then
					--cell.awardBgImg:setTouchEnabled(false)
					if cell.awardBgImg:getChildByName('award_img') then
						cell.awardBgImg:removeChildByName('award_img')
					end
					local topImg = self.rightMergePanel:getChildByName('top_img')
					local markTx = topImg:getChildByName('mark_tx')
					markTx:setString(GlobalApi:getLocalStr('EXCLUSIVE_DESC_17'))
					local newMarkTx = markTx:clone()
					newMarkTx:setVisible(true)
					newMarkTx:removeFromParent(false)
					newMarkTx:setName('mark_tx')
					cell.awardBgImg:addChild(newMarkTx)
					newMarkTx:setScale(1.2)
					newMarkTx:setPosition(47,47)

					cell.awardBgImg:addTouchEventListener(function (sender, eventType)
						if eventType == ccui.TouchEventType.began then
							AudioMgr.PlayAudio(11)
						end
						if eventType == ccui.TouchEventType.ended then
							local obj = DisplayData:getDisplayObj({'material',starLvItemId[randType],1})
							local cloneObject = cell.awardBgImg:clone()
							cloneObject:removeFromParent(false)
							obj.cloneObject = cloneObject
							obj.exclusiveObj = disPlayData[k]
							GetWayMgr:showGetwayUI(obj,false,nil,nil,nil,nil,true)
						end
					end)

				end
			end
		end

	end
	makeBtn:setTouchEnabled(true)
end

function ExclusiveMainUI:playRecastAnimation(guangImgs,awards,callBack)
	if self.curSelectIndex ~= 4 then
		self.rightRecastPanel:stopAllActions()
		return
	end
    if self.recastAnimationIndex > self.endIndex then
		local action1 = cc.DelayTime:create(0.3)
		local action2 = cc.CallFunc:create(function ()
			GlobalApi:showAwardsCommon(awards,nil,nil,true)
			if callBack then
				callBack()
			end
		end)
		self.rightRecastPanel:runAction(cc.Sequence:create(action1,action2))
        return
    end

    local action1 = cc.DelayTime:create(0.2)
    local action2 = cc.CallFunc:create(function ()
		for i = 1,4 do
			local index = self.recastAnimationIndex%4
			if index == 0 then
				index = 4
			end
			if index == i then
				guangImgs[i]:setVisible(true)
			else
				guangImgs[i]:setVisible(false)
			end
		end
        self.recastAnimationIndex = self.recastAnimationIndex + 1
        self:playRecastAnimation(guangImgs,awards,callBack)
    end)
    self.rightRecastPanel:runAction(cc.Sequence:create(action1,action2))
end

function ExclusiveMainUI:updateLeftRecastCellsNum(addNum,id)
    local exclusiveObj = BagData:getExclusiveObjById(id)
    if self.curRecastLevelIndex == exclusiveObj:getLevel() then
        for i = 1,#self.recastCells do
            local cell = self.recastCells[i]
            local obj = cell.obj

            if obj:getId() == id then
                local curNum = obj:getNum()
                if curNum + addNum <= 0 then
                    for k,v in pairs(self.recastShowTabs[self.curRecastLevelIndex]) do
                        if v:getId() == id then
                            table.remove(self.recastShowTabs[self.curRecastLevelIndex],k)
                        end
                    end
                    self:updateLeftRecastPanel()
                else
                    obj:addNum(addNum)
                    local lvTx = cell:getChildByName('lv_tx')
			        lvTx:setString('x'..obj:getNum())
                end
                return
            end
        end

        exclusiveObj.num = addNum
        table.insert(self.recastShowTabs[exclusiveObj:getLevel()],exclusiveObj)
        ExclusiveMgr:sortData(self.recastShowTabs[exclusiveObj:getLevel()])
        self:updateLeftRecastPanel()
    else
        local data = self.recastShowTabs[exclusiveObj:getLevel()]
        for i = 1,#data do
            if data[i]:getId() == id then
                data[i]:addNum(addNum)
                return
            end
        end

        exclusiveObj.num = addNum
        table.insert(self.recastShowTabs[exclusiveObj:getLevel()],exclusiveObj)
        ExclusiveMgr:sortData(self.recastShowTabs[exclusiveObj:getLevel()])
    end
end

return ExclusiveMainUI