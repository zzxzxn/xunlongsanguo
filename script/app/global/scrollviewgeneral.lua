local ScrollViewGeneral = class("ScrollViewGeneral")

-- @param sv                        滚动层,这里必须要求sv的描点为(0,0)
-- @param cellsData                 每一项的数据{w,h,index,posY,minY,maxY},刚开始传进来的时候只有w,h,index
-- @param cellsHeight               滚动层里面所有项的总高度
-- @param viewSize                  可视化区域的尺寸
-- @param cellSpace                 项的间隔
-- @param addItemCallBack           添加项的回调函数
-- @param numEveryLine              每行的数量(现在暂时为2个，或者1个)
-- @param innerContainerPosY        滚动层显示的位置
-- @param updateItemCallBack        更新回调
function ScrollViewGeneral:ctor(sv,cellsData,cellsHeight,viewSize,cellSpace,addItemCallBack,numEveryLine,innerContainerPosY,updateItemCallBack)
    self.sv = sv
    self.cellsData = cellsData
    self.cellsHeight = cellsHeight
    self.viewSize = viewSize
    self.cellSpace = cellSpace
    self.addItemCallBack = addItemCallBack
    self.numEveryLine = numEveryLine or 1
    self.innerContainerPosY = innerContainerPosY
    self.updateItemCallBack = updateItemCallBack
    self.startIndex = 1
    self.endIndex = 1
    self:initData()
    self:init()
end

-- 当滚动层在滚动的时候，如果你关闭这个页面，当你再打开这个页面的时候，滚动层会继续在原来的位置的滚动
-- 所以切换的时候会出问题，所以这里的更新是滚动层sv也是新建的一份，全部重新添加监听（做法参考roleequipselectui）
function ScrollViewGeneral:resetScrollView(sv,cellsData,cellsHeight,viewSize,cellSpace,addItemCallBack,numEveryLine,innerContainerPosY,updateItemCallBack)
    self.sv = sv
    self.cellsData = cellsData
    self.cellsHeight = cellsHeight
    self.viewSize = viewSize
    self.cellSpace = cellSpace
    self.addItemCallBack = addItemCallBack
    self.numEveryLine = numEveryLine or 1
    self.innerContainerPosY = innerContainerPosY
    self.updateItemCallBack = updateItemCallBack
    self.startIndex = 1
    self.endIndex = 1
    self:initSet()
end

function ScrollViewGeneral:initData()
    self.INSERT_TYPE = 
    {
        [1] = 'TOP',
	    [2] = 'CENTER',
	    [3] = 'BOTTOM',
    }
end

function ScrollViewGeneral:init()
    self:initSet()
end

function ScrollViewGeneral:initSet()
    if self.cellsHeight > self.viewSize.height then
        self.innerHeight = self.cellsHeight
    else
        self.innerHeight = self.viewSize.height
    end
    local innerContainer = self.sv:getInnerContainer()
    innerContainer:setContentSize(cc.size(self.viewSize.width,self.innerHeight))

    self:resetSet()
    self:scrollViewScrolLogic()                                            -- 初始化项

    local function scrollViewEvent(sender, evenType)
        self:scrollViewScrolLogic()
    end
    self.sv:addEventListener(scrollViewEvent)                                          
end

function ScrollViewGeneral:resetSet()
    self:setParams()
    local innerContainer = self.sv:getInnerContainer()
    if self.innerContainerPosY then
        innerContainer:setPositionY(self.innerContainerPosY)
    else
        innerContainer:setPositionY(self.viewSize.height - self.innerHeight)
    end
end

-- 在底部插入的时候，滚动到最底部
function ScrollViewGeneral:refreshSet()
    self:setParams()
    local innerContainer = self.sv:getInnerContainer()
    innerContainer:setPositionY(0)
end

function ScrollViewGeneral:setParams()
    self.cellsNum = #self.cellsData
    self.low = 1
    if self.numEveryLine == 1 then
        self.high = #self.cellsData
    elseif self.numEveryLine == 2 then
        if self.cellsNum == 1 then
            self.high = 1
        else
            self.high = math.ceil(self.cellsNum/2)
        end       
    end
    self:resetCellPos()
end

function ScrollViewGeneral:scrollViewScrolLogic()
    local viewStartPos = -self.sv:getInnerContainerPosition().y             -- 下面
    if viewStartPos < 0 then
        viewStartPos = 0
    end
    local viewEndPos = viewStartPos + self.viewSize.height                  -- 上面
    if viewEndPos > self.innerHeight then
        viewEndPos = self.innerHeight
    end
    --print('===================' .. viewStartPos ..'+++++++++++++++++' .. viewEndPos)

    local startIndex = self:getIndexFromPos(viewEndPos)
    local endIndex   = self:getIndexFromPos(viewStartPos)
    self.startIndex = startIndex
    self.endIndex = endIndex

    if self.numEveryLine == 2 then  -- 由于endIndex为奇数
        endIndex = endIndex + 1
        if endIndex > self.cellsNum then
            endIndex = endIndex - 1
        end
    end

    --print('===================' .. startIndex ..'+++++++++++++++++' .. endIndex)
    self:addCells(startIndex,endIndex)
    self:removeCells(startIndex,endIndex)
end

-- 重置位置
function ScrollViewGeneral:resetCellPos()
    if self.numEveryLine == 1 then
        local cellTotalHeight = 0
        for i = 1,self.cellsNum,1 do
            local tempCellData = self.cellsData[i]
            local h = tempCellData.h
            local cellSpace = 0
            if i == 1 then
                cellSpace = 0
            else
                cellSpace = self.cellSpace
            end
            cellTotalHeight = cellTotalHeight + h + cellSpace
            tempCellData.index = i
            tempCellData.posY = self.innerHeight - cellTotalHeight
            tempCellData.minY = tempCellData.posY
            tempCellData.maxY = tempCellData.minY + h + cellSpace           -- 把中间间隔的距离也加到下面那一项中去
        end
    else
        local cellTotalHeight = 0
        for i = 1,self.cellsNum,1 do
            local tempCellData = self.cellsData[i]
            local h = tempCellData.h

            local curCellHeight = 0
            if i%2 == 1 then
                curCellHeight = h
            end

            local curSpace = 0
            local cellSpace = 0
            if i == 1 or i == 2 then
                curSpace = 0
                cellSpace = 0
            else
                if i%2 == 1 then
                    curSpace = self.cellSpace
                end
                cellSpace = self.cellSpace
            end

            cellTotalHeight = cellTotalHeight + curCellHeight + curSpace
            tempCellData.index = i
            tempCellData.posY = self.innerHeight - cellTotalHeight
            tempCellData.minY = tempCellData.posY
            tempCellData.maxY = tempCellData.minY + h + cellSpace
        end
    end
end

-- 要求项的名字为'cell+i'这种
function ScrollViewGeneral:addCells(startIndex,endIndex)
    for i = startIndex,endIndex do
        if self.sv:getChildByName('cell' .. i) == nil then
            local widgetItem = ccui.Widget:create()
            widgetItem:setPosition(cc.p(0, self.cellsData[i].posY))
            widgetItem:setName('cell' .. i)
            self.sv:addChild(widgetItem)
            self.addItemCallBack(self.cellsData[i],widgetItem)
        end
    end
end

function ScrollViewGeneral:removeCells(startIndex,endIndex)
    for i = 1,self.cellsNum do
        if i < startIndex or i > endIndex then
            if self.sv:getChildByName('cell' .. i) then
                self.sv:removeChildByName('cell' .. i)
            end
        end
    end
end

-- sv已经初始化完成
-- 现在暂时insertCellData为插入的1项数据（self.cellsData中每一项的数据结构）,index要重置,有待测试
function ScrollViewGeneral:insertCell(insertType,insertCellData)
    if insertType == self.INSERT_TYPE[1] then
        local addHeight = 0
        if self.cellsNum == 0 then
            addHeight = insertCellData.h
        else
            addHeight = insertCellData.h + self.cellSpace
        end

        local temp = {}
        table.insert(insertCellData)
        for i = 1,self.cellsNum do
            table.insert(self.cellsData[i])
        end
        self.cellsData = temp
        self:refresh(addHeight)
    elseif insertType == self.INSERT_TYPE[2] then
        -- 这种情况至少原来里面有2项
        addHeight = insertCellData.h + self.cellSpace
        local temp = {}
        for i = 1,self.cellsNum do
            if i == insertCellData.index then
                table.insert(temp,insertCellData)
            end
            table.insert(temp,self.cellsData[i])
        end
        self.cellsData = temp
        self:refresh(addHeight)
    elseif insertType == self.INSERT_TYPE[3] then
        local addHeight = 0
        if self.cellsNum == 0 then
            addHeight = insertCellData.h
        else
            addHeight = insertCellData.h + self.cellSpace
        end
        table.insert(self.cellsData,insertCellData)
        self:refresh(addHeight)
    end
end

-- sv已经初始化完成,index要重置
function ScrollViewGeneral:deleteCell(deleteCellData)
    local reduceHeight = deleteCellData.h
    table.remove(self.cellsData,deleteCellData.index)   -- 这里删除后，后面的会向前移动一位，涉及删除多项，后面优化
    self:refresh(reduceHeight)
end

function ScrollViewGeneral:refresh(changeHeight)
    self.cellsHeight = self.cellsHeight + changeHeight
    if self.cellsHeight > self.viewSize.height then
        self.innerHeight = self.cellsHeight
    else
        self.innerHeight = self.viewSize.height
    end
    local innerContainer = self.sv:getInnerContainer()
    innerContainer:setContentSize(cc.size(self.viewSize.width,self.innerHeight))

    self:refreshSet()                             -- 这里里面重置位置可以优化下
    for i = 1,self.cellsNum do                    -- 强制移除，然后下面再刷新
        if self.sv:getChildByName('cell' .. i) then
            self.sv:removeChildByName('cell' .. i)
        end
    end
    self:scrollViewScrolLogic()             -- 这里让其刷新吧
end

function ScrollViewGeneral:updateItems()
    if self.updateItemCallBack then
        for i = self.startIndex,self.endIndex do
            local widgetItem = self.sv:getChildByName('cell' .. i)
            if widgetItem then
                self.updateItemCallBack(self.cellsData[i],widgetItem)
            end
        end
    end
end

function ScrollViewGeneral:getIndexFromPos(pos)
    local low = self.low
    local high = clone(self.high)

    local search = pos
    if self.numEveryLine == 1 then
        while (high >= low) do
            local index = math.floor(low + (high - low) / 2)
            local cellStart = self.cellsData[index].minY
            local cellEnd   = self.cellsData[index].maxY

            if (search >= cellStart and search <= cellEnd) then
                return index
            elseif (search < cellEnd) then
                low = index + 1
            else
                high = index - 1
            end
        end

        if (low <= 1)  then
            return 1
        end

        if(high >= self.high) then
            return self.high
        end
    elseif self.numEveryLine == 2 then  -- 以左边第1列为准（1，3，5，7，9）
        while (high >= low) do
            local index = math.floor(low + (high - low) / 2)
            local realCellIndex = index * 2 - 1

            local cellStart = self.cellsData[realCellIndex].minY
            local cellEnd   = self.cellsData[realCellIndex].maxY

            if (search >= cellStart and search <= cellEnd) then
                return index * 2 - 1
            elseif (search < cellEnd) then
                low = index + 1
            else
                high = index - 1
            end
        end

        if (low <= 1)  then
            return 1
        end

        if(high >= self.high) then
            return self.high * 2 - 1
        end
    end
end

return ScrollViewGeneral