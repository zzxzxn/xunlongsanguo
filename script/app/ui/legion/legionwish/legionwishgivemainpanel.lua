local LegionWishGiveMainPanelUI = class("LegionWishGiveMainPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionWishGiveMainPanelUI:ctor()
	self.uiIndex = GAME_UI.UI_LEGION_WISH_GIVE_MAIN
    self.legionWishConf = GameData:getConfData('legionwishconf')
    self.data = LegionWishMgr:getLegionWishData()
    self.logState = self.data.wish_log or 0
end

function LegionWishGiveMainPanelUI:onShow()
    if LegionWishMgr:getDirty() then
        self.data = LegionWishMgr:getLegionWishData()
        self:update()
    end
    LegionWishMgr:setDirty(false)
    self:updateSigns()
end

function LegionWishGiveMainPanelUI:updateSigns()
    self.rewardMarkImg:setVisible(UserData:getUserObj():getLegionWishWeekAwardState())
    if self.logState == 1 then
        self.logMarkImg:setVisible(true)
    else
        self.logMarkImg:setVisible(false)
    end
end

function LegionWishGiveMainPanelUI:init()
    local bgBigImg = self.root:getChildByName("bg_big_img")
    local bgImg = bgBigImg:getChildByName('bg_img')
    local bgImg1 = bgImg:getChildByName('bg_img1')
    self:adaptUI(bgBigImg, bgImg)

    local bg = bgImg1:getChildByName('bg')
    self.bg = bg
    local closebtn = bg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:hideLegionWishGiveMainPanelUI()
        end
    end)

    local helpBtn = bg:getChildByName('help_btn')
    helpBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(29)
        end
    end)

    local rewardBtn = bg:getChildByName('reward_btn')
    rewardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:showLegionWishWeekAwardPanelUI()
        end
    end)

    local logBtn = bg:getChildByName('log_btn')
    logBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.logState = 0
            self:updateSigns()
            LegionWishMgr:showLegionWishLogPanelUI()
        end
    end)

    self.rewardMarkImg = rewardBtn:getChildByName('mark')
    self.logMarkImg = logBtn:getChildByName('mark')

    self:refreshGiveCount()
    self:initCenter()
    self:initBottom()
    self:updateSigns()
end

function LegionWishGiveMainPanelUI:update()
    self:initCenter()
end

function LegionWishGiveMainPanelUI:refreshGiveCount()
    local descTx = self.bg:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC4'))
    local allNumTx = self.bg:getChildByName('all_num_tx')
    local allNum = LegionWishMgr:getLegionWishGiveTimes()
    allNumTx:setString('/' .. allNum)

    local sendNumTx = self.bg:getChildByName('send_num_tx')
    local remainNum = allNum - LegionWishMgr:getGiveNum()
    sendNumTx:setString(remainNum)
    if remainNum <= 0 then
        sendNumTx:setString(0)
        sendNumTx:setColor(COLOR_TYPE.RED)
    else
        sendNumTx:setColor(COLOR_TYPE.WHITE)
    end
end

function LegionWishGiveMainPanelUI:initCenter()
    local centerBg = self.bg:getChildByName('center_bg')

    local icon = centerBg:getChildByName('icon')
    local getNumTx = centerBg:getChildByName('get_num_tx')
    local img = centerBg:getChildByName('img')
    local stageTx = centerBg:getChildByName('stage_tx')
    local getBtn = centerBg:getChildByName('get_btn')
    local wishBtn = centerBg:getChildByName('wish_btn')

    local myWishData = self.data.own_wish[tostring(UserData:getUserObj():getUid())]
    local judge = false
    if myWishData and myWishData then
        judge = true
    end
    if judge == true then
        icon:setVisible(true)
        getNumTx:setVisible(true)
        img:setVisible(true)
        stageTx:setVisible(true)
        getBtn:setVisible(true)
        wishBtn:setVisible(false)

        local progressData = myWishData[tostring(1)]

        local fragmentId = progressData.fragment
        local awardData = {{'fragment',tostring(fragmentId),1}}
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.awardBgImg:loadTexture(awards:getBgImg())
        cell.chipImg:setVisible(true)
        cell.chipImg:loadTexture(awards:getChip())
        cell.lvTx:setString('x'..awards:getNum())
        cell.lvTx:setVisible(false)
        cell.awardImg:loadTexture(awards:getIcon())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        local quality = GameData:getConfData("item")[tonumber(awards:getId())].quality
        local confData = LegionWishMgr:getLegionConfDataByQuality(quality)
        -- 已经获得的碎片数量（真实的数量）
        local hasGetNum = progressData.has_collect
        -- 已经获得的碎片数量进度
        local hasGetProgressNum = progressData.has_got
        -- 可以领取的数量
        local canGetNum = hasGetProgressNum - hasGetNum

        getNumTx:setString(string.format(GlobalApi:getLocalStr('LEGION_WISH_DESC7'),canGetNum))
        if hasGetProgressNum >= confData.wishFragmentMax then
            stageTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC8'))
        else
            stageTx:setString(hasGetProgressNum .. '/' .. confData.wishFragmentMax)
        end

        local funcTx = getBtn:getChildByName('func_tx')
        funcTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC6'))
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    times = 1,
                    id = fragmentId
                }
                MessageMgr:sendPost('get_wish_fragment','legion',json.encode(args),function (response)
                    local code = response.code
		            local data = response.data
		            if code == 0 then
                        progressData.has_got = data.has_got
                        progressData.has_collect = data.has_collect

                        local awards = data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        if data.has_collect >= confData.wishFragmentMax then
                            UserData:getUserObj():getLegionInfo().wish.wish_progress[tostring(2)] = 1
                        end
                        UserData:getUserObj().wish[tostring(1)] = progressData
                        self:updateSigns()
                        self:initCenter()
                    else
                        LegionWishMgr:popWindowErrorCode(code)
		            end
	            end)
            end
        end)
        if canGetNum <= 0 then
            ShaderMgr:setGrayForWidget(getBtn)
            funcTx:setColor(COLOR_TYPE.GRAY)
            funcTx:enableOutline(COLOR_TYPE.BLACK)
            getBtn:setTouchEnabled(false)
        else
            ShaderMgr:restoreWidgetDefaultShader(getBtn)
            funcTx:setColor(COLOR_TYPE.WHITE)
            funcTx:enableOutline(cc.c4b(165, 70, 0, 255), 1)
            getBtn:setTouchEnabled(true)
        end
    else
        icon:setVisible(false)
        getNumTx:setVisible(false)
        img:setVisible(false)
        stageTx:setVisible(false)
        getBtn:setVisible(false)
        wishBtn:setVisible(true)
        
        wishBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('LEGION_WISH_DESC5'))
        wishBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionWishMgr:showLegionWishMakeWishPanelUI()
            end
        end)
    end
end

function LegionWishGiveMainPanelUI:initBottom()
    local panel = self.bg:getChildByName('panel')
    local noWishTx = self.bg:getChildByName('no_wish_tx')

    local myWishData = self.data.own_wish
    local wish = {}
    for k,v in pairs(myWishData) do
        if k ~= tostring(UserData:getUserObj():getUid()) then
            local progressData = v[tostring(1)]
            local fragmentId = progressData.fragment
            local awardData = {{'fragment',tostring(fragmentId),1}}
            local disPlayData = DisplayData:getDisplayObjs(awardData)
            local awards = disPlayData[1]
            
            local quality = GameData:getConfData("item")[tonumber(awards:getId())].quality
            local confData = LegionWishMgr:getLegionConfDataByQuality(quality)
            if progressData.has_got < confData.wishFragmentMax then   -- 未实现
                local temp = {}
                temp.uid = k
                temp.data = v
                table.insert(wish,temp)
            end
        end
    end

    local wishNum = #wish
    self.wishNum = wishNum
    self.wish = wish

    noWishTx:setVisible(false)
    panel:setVisible(true)
    local img = panel:getChildByName('img')
    img:setVisible(false)
    if wishNum == 0 then
        noWishTx:setVisible(true)
        panel:setVisible(false)
        noWishTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC9'))
    elseif wishNum == 1 then
        local tempImg = img:clone()
        tempImg:setPosition(cc.p(441,200))
        panel:addChild(tempImg)
        tempImg:setVisible(true)
        self:refreshItem(1,tempImg)
    elseif wishNum == 2 then
        local tempLeftImg = img:clone()
        tempLeftImg:setPosition(cc.p(321,200))
        panel:addChild(tempLeftImg)
        tempLeftImg:setVisible(true)
        self:refreshItem(2,tempLeftImg)

        local tempRightImg = img:clone()
        tempRightImg:setPosition(cc.p(561,200))
        panel:addChild(tempRightImg)
        tempRightImg:setVisible(true)
        self:refreshItem(1,tempRightImg)
    elseif wishNum >= 3 then
        self.curPos = 1
        local imgs = {}
        local rightNum = math.ceil((wishNum - 1)/2)
        local leftNum = wishNum - 1 - rightNum
        local initPosX = 441
        local posRightX = initPosX
        local imgHorizontalOffset = 34
        local allPos = {}
        local baseHeight = 200
        local imgHeightOffset = 12
        local heightRight = baseHeight
        local baseScale = 1
        local sacleOffset = 0.94
        local scaleRight = baseScale
        local scaleLeft = baseScale * sacleOffset^(leftNum + 1)
        local scales = {}
        local imgWidth = img:getContentSize().width
        local imgHeight = img:getContentSize().height

        local Pos = {}
        local scaleLeftTemp = baseScale
        local posLeftX = initPosX
        local posLeftY = baseHeight
        for i = 1,leftNum do
            scaleLeftTemp = scaleLeftTemp*sacleOffset
            posLeftX = posLeftX - imgHorizontalOffset - (scaleLeftTemp/sacleOffset)*imgWidth/2 - scaleLeftTemp*imgWidth/2
            posLeftY = posLeftY + (scaleLeftTemp/sacleOffset)*imgHeight/2 + imgHeightOffset - scaleLeftTemp*imgHeight/2
            if i == 1 then
                posLeftY = posLeftY - 4
            end
            table.insert(Pos,cc.p(posLeftX,posLeftY))
        end
        local k = #Pos
        for i = 1,wishNum do
            local tempImg = img:clone()
            tempImg:setTouchEnabled(true)
            panel:addChild(tempImg)
            tempImg:setVisible(true)
            table.insert(imgs,tempImg)

            local height3 = baseHeight
            if i ~= 1 then
                if i > rightNum + 1 then
                    scaleLeft = scaleLeft/sacleOffset
                    table.insert(scales,scaleLeft)
                else
                    scaleRight = scaleRight * sacleOffset
                    table.insert(scales,scaleRight)
                    heightRight = heightRight + (scaleRight/sacleOffset)*imgHeight/2 + imgHeightOffset - scaleRight*imgHeight/2
                    height3 = heightRight
                end
            else
                table.insert(scales,baseScale)
            end
            if i > rightNum + 1 then
                local pos = Pos[k]
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
                k = k - 1
            elseif i == 1 then
                local pos = cc.p(initPosX,height3)
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
            else
                posRightX = posRightX + imgHorizontalOffset + (scaleRight/sacleOffset)*imgWidth/2 + scaleRight*imgWidth/2
                if i == 2 then
                    height3 = height3 - 4
                end
                local pos = cc.p(posRightX,height3)
                tempImg:setPosition(pos)
                table.insert(allPos,pos)
            end
            self:refreshItem(i,tempImg)
        end
        self.imgs = imgs

        GlobalApi:setCardRunRound(panel,imgs,self.curPos or 1,rightNum,leftNum,200,false,nil,nil,
        function(i)
            self.curPos = i
            self:refreshCurPos()
            self:refreshItem(self.curPos,self.imgs[self.curPos])
        end,allPos,nil,scales,{255,255,95})
        self:refreshCurPos()
    end
end

function LegionWishGiveMainPanelUI:refreshCurPos()
    for i = 1,self.wishNum do
        local img = self.imgs[i]
        local icon = img:getChildByName('icon')
        local getBtn = img:getChildByName('get_btn')
        if i == self.curPos then
            icon:setTouchEnabled(true)
            getBtn:setTouchEnabled(true)
            icon:getChildByName('award_bg_img'):setTouchEnabled(true)
        else
            icon:setTouchEnabled(false)
            getBtn:setTouchEnabled(false)
            icon:getChildByName('award_bg_img'):setTouchEnabled(false)
        end
    end
end

function LegionWishGiveMainPanelUI:refreshItem(i,img)
    local wishData = self.wish[i]

    local progressData = wishData.data[tostring(1)]
    local fragmentId = progressData.fragment
    local awardData = {{'fragment',tostring(fragmentId),1}}
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]
            
    local quality = GameData:getConfData("item")[tonumber(awards:getId())].quality
    local confData = LegionWishMgr:getLegionConfDataByQuality(quality)

    local nameTx = img:getChildByName('name_tx')
    nameTx:setString(progressData.name or '')

    local icon = img:getChildByName('icon')
    if icon:getChildByName('award_bg_img') then
        icon:removeChildByName('award_bg_img')
    end
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.awardBgImg:loadTexture(awards:getBgImg())
    cell.chipImg:setVisible(true)
    cell.chipImg:loadTexture(awards:getChip())
    cell.lvTx:setString('x'..awards:getNum())
    cell.lvTx:setVisible(false)
    cell.awardImg:loadTexture(awards:getIcon())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)

    local stageTx = img:getChildByName('stage_tx')
    stageTx:setString(progressData.has_got .. '/' .. confData.wishFragmentMax)

    local getBtn = img:getChildByName('get_btn')
    local funcTx = getBtn:getChildByName('func_tx')
    funcTx:setString(string.format(GlobalApi:getLocalStr('LEGION_WISH_DESC26'),confData.giveLimit))
    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 愿望实现
            if progressData.has_got >= confData.wishFragmentMax then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC27'), COLOR_TYPE.RED)
                return
            end

            -- 碎片不足
            local num = 0
            if BagData:getFragmentById(fragmentId) then
                num = BagData:getFragmentById(fragmentId):getNum()
            end
            if num < confData.giveLimit then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC28'), COLOR_TYPE.RED)
                return
            end
            
            -- 赠送次数不足
            if LegionWishMgr:getLegionWishGiveTimes() - LegionWishMgr:getGiveNum() <= 0 then
                local vip = UserData:getUserObj():getVip()
                if vip < GlobalApi:getMaxVip() then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC29'), COLOR_TYPE.RED)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC30'), COLOR_TYPE.RED)
                end
                return
            end

            local function callBack()
                progressData.has_got = progressData.has_got + confData.giveLimit
                local wish_progress = UserData:getUserObj():getLegionInfo().wish.wish_progress
                if wish_progress[tostring(3)] == nil then
                    wish_progress[tostring(3)] = 0
                end
                wish_progress[tostring(3)] = wish_progress[tostring(3)] + 1
                self:updateSigns()
                self:refreshItem(i,img)
                self:refreshGiveCount()
            end
            LegionWishMgr:showLegionWishGiveGiftPanelUI(wishData,callBack)
        end
    end)

    local num = 0
    if BagData:getFragmentById(fragmentId) then
        num = BagData:getFragmentById(fragmentId):getNum()
    end
    if progressData.has_got >= confData.wishFragmentMax or num < confData.giveLimit then
        ShaderMgr:setGrayForWidget(getBtn)
        funcTx:setColor(COLOR_TYPE.GRAY)
        funcTx:enableOutline(COLOR_TYPE.BLACK)
        getBtn:setTouchEnabled(false)
    else
        ShaderMgr:restoreWidgetDefaultShader(getBtn)
        funcTx:setColor(COLOR_TYPE.WHITE)
        funcTx:enableOutline(cc.c4b(165, 70, 0, 255), 1)
        getBtn:setTouchEnabled(true)
    end

    if self.wishNum >= 3 and i ~= self.curPos then
        getBtn:setTouchEnabled(false)
    end
end

return LegionWishGiveMainPanelUI