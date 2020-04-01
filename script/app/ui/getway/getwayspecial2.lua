local GetWaySpecial2 = class("GetWaySpecial2", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function GetWaySpecial2:ctor(obj,awards)
    self.uiIndex = GAME_UI.UI_GET_WAY_DROP
    self.obj = obj
	self.awards = awards
end

function GetWaySpecial2:init()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)

	local winSize = cc.Director:getInstance():getVisibleSize()

    local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            GetWayMgr:hideGetWaySpecial2UI()
		end
	end
    bg1:addTouchEventListener(callBack)

    local titleBgImg = bg2:getChildByName("title_bg_img")
    local titleBg = titleBgImg:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr("ACTIVITY_CHRISTMAS_TREE_DESC_11"))
	
    -- 必得
    local fixedAwards = self.awards

    -- 可能获得
    local randAwards = {}

    local headSv = bg2:getChildByName("head_sv")
    headSv:setScrollBarEnabled(false)
    local svSize = headSv:getContentSize()
    local innerContainer = headSv:getInnerContainer()


    local fixDisPlayData = DisplayData:getDisplayObjs(fixedAwards)
    local fixAllNum = #fixDisPlayData

    local randAllNum = #randAwards

    local nameHeight = 40
    local itemHeight = 94
    local itemWidth = 94
    local colNum = 4
    local widhtOffset = 10
    local heightOffset = 10
    local leftInitPos = 12

    local allHeight = 0

    local fixAllHeight = 0
    if fixAllNum > 0 then
        fixAllHeight = fixAllHeight + nameHeight
        local line = 0 
        if fixAllNum <= colNum then
            line = 1
        else
            line = math.ceil(fixAllNum/colNum)
        end
        fixAllHeight = fixAllHeight + line * itemHeight + (line - 1)*heightOffset
    end

    local randAllHeight = 0
    if randAllNum > 0 then
        randAllHeight = randAllHeight + nameHeight
        local line = 0 
        if randAllNum <= colNum then
            line = 1
        else
            line = math.ceil(randAllNum/colNum)
        end
        randAllHeight = randAllHeight + line * itemHeight + (line - 1)*heightOffset
    end
    allHeight = allHeight + fixAllHeight + randAllHeight



    if allHeight < svSize.height then
        allHeight = svSize.height
    end
    print('==============+++++++++++' .. allHeight)
    innerContainer:setContentSize(cc.size(svSize.width,allHeight))
    innerContainer:setPositionY(svSize.height - allHeight)

    local height = 0
    if fixAllNum > 0 then
        local remainHeight = allHeight - height
        for i = 1,fixAllNum do
            local awards = fixDisPlayData[i]
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, headSv)
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)

            if awards:getObjType() == 'equip' then
                cell.lvTx:setString('Lv.'..awards:getLevel())
            end

            local leftNum = i % colNum
            if leftNum == 0 then
                leftNum = colNum
            end
            local leftPos = (leftNum - 1) * (widhtOffset + itemWidth) + leftInitPos

            local line = 0 
            if i <= colNum then
                line = 1
            else
                line = math.ceil(i/colNum)
            end
            local posHeight = line * itemHeight + (line - 1)*heightOffset
            local rightPos = remainHeight - posHeight

            cell.awardBgImg:setAnchorPoint(cc.p(0,0))
            cell.awardBgImg:setPosition(cc.p(leftPos,rightPos))
            cell.awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI2(awards,false)
                end
            end)

        end
    end

    height = fixAllHeight
    if randAllNum > 0 then
        height = height + nameHeight
        local title = cc.Label:createWithTTF(GlobalApi:getLocalStr("GETWAY_DES7"), "font/gamefont.ttf", 20)
        title:setAnchorPoint(cc.p(0.5,0))
        title:setPosition(cc.p(svSize.width/2,allHeight - height + 5))
        title:setColor(COLOR_TYPE.WHITE)
        title:enableOutline(COLOR_TYPE.BLACK, 1)
        --title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BLACK))
        headSv:addChild(title)

        local remainHeight = allHeight - height
        for i = 1,randAllNum do
            local awards = DisplayData:getDisplayObj(randAwards[i][1])

            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards,headSv)
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
        
            if awards:getObjType() == 'equip' then
                cell.lvTx:setString('Lv.'..awards:getLevel())
            end

            local leftNum = i % colNum
            if leftNum == 0 then
                leftNum = colNum
            end
            local leftPos = (leftNum - 1) * (widhtOffset + itemWidth) + leftInitPos

            local line = 0 
            if i <= colNum then
                line = 1
            else
                line = math.ceil(i/colNum)
            end
            local posHeight = line * itemHeight + (line - 1)*heightOffset
            local rightPos = remainHeight - posHeight

            cell.awardBgImg:setAnchorPoint(cc.p(0,0))
            cell.awardBgImg:setPosition(cc.p(leftPos,rightPos))
            cell.awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI2(awards,false)
                end
            end)

        end

    end



end

return GetWaySpecial2