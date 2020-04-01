local OpenBoxUI = class("OpenBoxUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassItemObj = require('script/app/obj/itemobj')

function OpenBoxUI:ctor(obj)
    self.uiIndex = GAME_UI.UI_OPEN_BOX
    self.obj = obj
end

-- 初始化
function OpenBoxUI:init()
    local bg = self.root:getChildByName("bg")
	local bg1 = bg:getChildByName("bg1")
    self.bg1 = bg1
	self:adaptUI(bg, bg1)
    
    local closeBtn = bg1:getChildByName("close")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
            BagMgr:hideOpenBox()
	    end
	end)
    self.closeBtn = closeBtn
    self.arrow = bg1:getChildByName("arrow")
    self.arrow:setVisible(false)

    self:initData()
    self:initTop()
    self:initLeft()
    self:initRight()
    self:refreshScrollImgState()

    self.root:scheduleUpdateWithPriorityLua(function (dt)
		self:update(dt)
	end, 0)
end

function OpenBoxUI:update(dt)
    if self.srolling == true then
        local rotation = self.arrow:getRotation()
        local deg = rotation%360
        -- 误差
        local diff = 30
        if deg >= (0 - diff) and deg <= (0 + diff) then
            self:refreshScrollImgState2(1)
        elseif deg >= (60 - diff) and deg <= (60 + diff) then
            self:refreshScrollImgState2(2)
        elseif deg >= (120 - diff) and deg <= (120 + diff) then
            self:refreshScrollImgState2(3)
        elseif deg >= (180 - diff) and deg <= (180 + diff) then
            self:refreshScrollImgState2(4)
        elseif deg >= (240 - diff) and deg <= (240 + diff) then
            self:refreshScrollImgState2(5)
        elseif deg >= (300 - diff) and deg <= (300 + diff) then
            self:refreshScrollImgState2(6)

        end
    end
end

function OpenBoxUI:initData()
    local trialBox = GameData:getConfData('trialbox')
    local subType = tonumber(self.obj:getSubType())
    local trialBoxData = trialBox[subType]
    self.showItemAwards = {}
    self.curChooseId = 1
    for i = 1,#trialBoxData do
        if type(trialBoxData[i]) ~= "string" then
            local award = trialBoxData[i].award
            table.insert(self.showItemAwards,award)
            if tonumber(award[1][2]) == tonumber(self.obj:getId()) then
                self.curChooseId = tonumber(trialBoxData[i].type)
            end
        end
    end
    --print('===========666666++++++++++++' .. self.curChooseId)
    self.cells = {}
    self.scrollImg = {}
    local rightBg = self.bg1:getChildByName('right_bg')
    for i = 1,6,1 do
        local frame = rightBg:getChildByName('icon_' .. i)
        local img = frame:getChildByName('guang_img_' .. i)
        local guangEffecImg = rightBg:getChildByName('guang_effect_' .. i)
        img.guangEffecImg = guangEffecImg
        table.insert(self.scrollImg,img)
    end
    self.scrollDeg = {0,60,120,180,240,300}
    self.srolling = false
end

function OpenBoxUI:refreshScrollImgState()
    for i = 1,#self.scrollImg do
        self.scrollImg[i]:setVisible(false)
        self.scrollImg[i].guangEffecImg:setVisible(false)
    end
end

function OpenBoxUI:refreshScrollImgState2(id)
    --print('===========666666++++++++++++' .. id)
    for i = 1,#self.scrollImg do
        if id == i then
            self.scrollImg[i]:setVisible(true)
            self.scrollImg[i].guangEffecImg:setVisible(true)
        else
            self.scrollImg[i]:setVisible(false)
            self.scrollImg[i].guangEffecImg:setVisible(false)
        end
    end
end

function OpenBoxUI:initTop()
    local titleBg = self.bg1:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('SHOP_DESC_8'))

end

function OpenBoxUI:initLeft()
    local sv = self.bg1:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local cell = self.bg1:getChildByName('cell')
    cell:setVisible(false)
    self.sv = sv
    self.cell = cell
    self:updateSV()
end

function OpenBoxUI:updateSV()
    local num = #self.showItemAwards
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local cellSpace = 5
    local allHeight = size.height

    local topOffset = 10    -- 顶部要裁剪，选择框要高一点
    local height = num * self.cell:getContentSize().height + (num - 1)*cellSpace + topOffset

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    else
        innerContainer:setContentSize(size)
        allHeight = height
        self.sv:setBounceEnabled(false)
    end
    print('===========++++++++++++' .. allHeight)

    local dropConf = GameData:getConfData('drop')
    local offset = topOffset
    local tempHeight = self.cell:getContentSize().height
    for i = 1,num do
        local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(70,allHeight - offset))
        self.sv:addChild(tempCell)

        local awardData = self.showItemAwards[i]
        local disPlayObj = DisplayData:getDisplayObjs(awardData)[1]

        local item = tempCell:getChildByName('item')
        item:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.curChooseId == i then
                    return
                end
                self.curChooseId = i
                for j = 1,#self.cells,1 do
                    if self.curChooseId == j then
                        self.cells[j].chooseImg:setVisible(true)
                    else
                        self.cells[j].chooseImg:setVisible(false)
                    end
                end
                self:initRight()
            end
        end)

        local img = item:getChildByName('img')
        local ownNum = img:getChildByName('own_num')
        local icon = item:getChildByName('icon')
        icon:loadTexture(disPlayObj:getIcon())
        icon:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI(disPlayObj,false)
            end
        end)

        local chooseImg = item:getChildByName('choose_img')
        if self.curChooseId == i then
            chooseImg:setVisible(true)
        else
            chooseImg:setVisible(false)
        end   

        local titleTx = item:getChildByName('title_tx')
        titleTx:setString(disPlayObj:getName())
        titleTx:setColor(disPlayObj:getNameColor())
        titleTx:enableOutline(disPlayObj:getNameOutlineColor(),1)
        titleTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))

        local openBtn = item:getChildByName('open_btn')   
        openBtn.index = i    
        local btnTx = openBtn:getChildByName('btn_tx')
        btnTx:setString(GlobalApi:getLocalStr('SHOP_DESC_9'))

        -- 元宝消耗富文本，钥匙消耗富文本
        local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(500, 40))
	    local re1 = xx.RichTextImage:create('uires/icon/material/muyaoshi.png')
        re1:setScale(0.45)

	    local re2 = xx.RichTextLabel:create('', 24, COLOR_TYPE.WHITE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        --re2:setShadow(cc.c4b(26, 26, 26, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)

        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(openBtn:getPositionX() - 5,openBtn:getPositionY() + 38))
        richText:format(true)
        item:addChild(richText)

        --
        tempCell.ownNum = ownNum
        tempCell.openBtn = openBtn
        tempCell.disPlayObj = disPlayObj
        tempCell.re1 = re1
        tempCell.re2 = re2
        tempCell.richText = richText
        tempCell.chooseImg = chooseImg
        tempCell.item = item

        self:refreshItem(tempCell)
        table.insert(self.cells,tempCell)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function OpenBoxUI:refreshItem(cell)
    local disPlayObj = cell.disPlayObj

    -- 宝箱拥有的数量
    local ownNum = cell.ownNum  
    ownNum:setString(disPlayObj:getOwnNum())

    if disPlayObj:getOwnNum() > 0 then
        ownNum:setColor(COLOR_TYPE.WHITE)
    else
        ownNum:setColor(COLOR_TYPE.RED)
    end

    -- 消耗
    local richText = cell.richText
    local re1 = cell.re1
    local re2 = cell.re2

    local costObj = disPlayObj:getCost()
    local cost1Obj = disPlayObj:getCost1()
    local showCostTypeObj
    if costObj then
        showCostTypeObj = costObj
    elseif cost1Obj then
        showCostTypeObj = cost1Obj
    end
    re1:setImg(showCostTypeObj:getIcon())
    re2:setString(showCostTypeObj:getOwnNum())
    local costNum = showCostTypeObj:getNum()
    local ownNum = showCostTypeObj:getOwnNum()
    if ownNum >= costNum then
        re2:setColor(COLOR_TYPE.WHITE)
    else
        re2:setColor(COLOR_TYPE.RED)
    end
    richText:format(true)
    --
    local openBtn = cell.openBtn


    openBtn:setSwallowTouches(false)
    openBtn:setPropagateTouchEvents(false)
    local point1
    local point2
    openBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            point1 = sender:getTouchBeganPosition()      
        end
        if eventType == ccui.TouchEventType.ended then
            point2 = sender:getTouchEndPosition()
            if point1 then
                local dis = cc.pGetDistance(point1,point2)
                if dis <= 5 then
                    ------------logic-------------
                    if disPlayObj:getOwnNum() <= 0 then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('SHOP_DESC_10'),disPlayObj:getName()), COLOR_TYPE.RED)
                        return
                    end

                    local function useItem()
                        self:disableBtn()
				        local args = {
					        type = 'material',
					        id = disPlayObj:getId(),
					        num = 1     -- 消耗默认是1
				        }
				        MessageMgr:sendPost('use_rare_box','bag',json.encode(args),function (response)
					        local code = response.code
					        local data = response.data
					        if code == 0 then
                                -- 开始转
                                self:scrollStart(response.data)
                            else
                                self:openBtn()
					        end
				        end)
			        end

                    --
                    local nowCostObj
                    if costObj then
                        local judge = false
                        local costNum = costObj:getNum()
                        local ownNum = costObj:getOwnNum()
                        if ownNum >= costNum then   -- 可以购买
                            if costObj:getCategory() == 'material' then
                                --promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('SHOP_DESC_12'),costNum,costObj:getName()), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
					                    --useItem()
				                    --end)
                                    local index = sender.index
                                    if self.curChooseId ~= index then
                                        self.curChooseId = index
                                        for j = 1,#self.cells,1 do
                                            if self.curChooseId == j then
                                                self.cells[j].chooseImg:setVisible(true)
                                            else
                                                self.cells[j].chooseImg:setVisible(false)
                                            end
                                        end
                                        self:initRight()
                                    end
                                    useItem()
                            elseif costObj:getId() == 'cash' then
                                UserData:getUserObj():cost('cash',costObj:getNum(),function()
				                    useItem()
				                end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),costObj:getNum()))
                            end
                        elseif cost1Obj then    -- 第2个是cash消耗
                            local materialName = costObj:getName()
                            if cost1Obj:getId() == 'cash' then
                                UserData:getUserObj():cost('cash',cost1Obj:getNum(),function()
				                    useItem()
				                end,true,string.format(GlobalApi:getLocalStr('SHOP_DESC_11'),materialName,cost1Obj:getNum()))
                            end
                        else
                            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('SHOP_DESC_13'),costObj:getName()), COLOR_TYPE.RED)
                        end
                    elseif cost1Obj then   -- 这种情况暂时不考虑      
                    end
                    ------------logic-------------
                end
            end
        end
	end)

end

-- 当前选择的哪个就显示哪个的drop
function OpenBoxUI:initRight()
    local awardData = self.showItemAwards[self.curChooseId]
    local disPlayObj = DisplayData:getDisplayObjs(awardData)[1]
    local useEffect = disPlayObj:getUseEffect()
    local tab = string.split(useEffect,'.')
    local dropId
    if tab and tab[1] == 'drop' then
        local tab2 = string.split(tab[2],':')
        dropId = tab2[1]
    end

    if not dropId then
        return
    end

    local dropConf = GameData:getConfData('drop')
    print('dropid===' .. dropId)
    local dropData = dropConf[tonumber(dropId)]

    local rightBg = self.bg1:getChildByName('right_bg')
    for i = 1,6,1 do
        local frame = rightBg:getChildByName('icon_' .. i)
        local award = dropData["award" .. i]
        local awards = DisplayData:getDisplayObjs(award)[1]
        if frame:getChildByName('award_bg_img') then
            frame:removeChildByName('award_bg_img')
        end
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)
    end

    local centerBg = rightBg:getChildByName('center')
    centerBg:loadTexture(disPlayObj:getIcon())
end

-- 转动开始
function OpenBoxUI:scrollStart(data)
    local awards = data.awards
    local costs = data.costs

    -- 寻找id
    local id = tonumber(data.awardId)
    self.srolling = true
    local endDeg = (id - 1) * 60
    local act1 = cc.Sequence:create(CCEaseSineIn:create(cc.RotateBy:create(1, 360)),cc.RotateBy:create(1.6,1440),cc.EaseSineOut:create(cc.RotateBy:create(3, endDeg + 360 * 2)))
    local act2 = cc.DelayTime:create(0.5)
    local act3 = cc.CallFunc:create(
	    function ()
            self.srolling = false
            if awards then
			    GlobalApi:parseAwardData(awards)
		    end
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            local function callBack()
                self.arrow:setRotation(0)
                self:refreshScrollImgState()
            end
			GlobalApi:showAwardsCommon(awards,true,callBack,false)
            -- 刷新显示
            self:openBtn()
            self.arrow:setRotation(0)
            for i = 1,#self.cells do
                self:refreshItem(self.cells[i])
            end
	    end)
    self.arrow:runAction(cc.Sequence:create(act1,act2,act3))

end

-- 禁用按钮
function OpenBoxUI:disableBtn()
    self.closeBtn:setTouchEnabled(false)
    for i = 1,#self.cells do
        self.cells[i].openBtn:setTouchEnabled(false)
        self.cells[i].item:setTouchEnabled(false)
    end
end

-- 启用按钮
function OpenBoxUI:openBtn()
    self.closeBtn:setTouchEnabled(true)
    for i = 1,#self.cells do
        self.cells[i].openBtn:setTouchEnabled(true)
        self.cells[i].item:setTouchEnabled(true)
    end
end

return OpenBoxUI