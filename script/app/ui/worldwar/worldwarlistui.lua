local WorldWarListUI = class("WorldWarListUI", BaseUI)
local MAX_CELL = 10
local MAX_ROLE = 32
function WorldWarListUI:ctor(data)
	self.uiIndex = GAME_UI.UI_WORLDWARLIST
    self.data = data
    self.rankData = self.data.rank_list
    self.pageBtn = 1
    self.page = 1
    self.cells = {}
    self.lastCells = {}
end

function WorldWarListUI:updatePageBtn()
    for i,v in ipairs(self.pageBtns) do
        v:setBrightStyle(((i == self.pageBtn) and ccui.BrightStyle.highlight) or ccui.BrightStyle.normal)
    end
end

function WorldWarListUI:updateListCell()
    local index = 0
    local singleSize
    for i=1,MAX_CELL do
        local data = self.rankData[i + (self.page - 1)*MAX_CELL]
        if data then
            singleSize = self.cells[i].listImg:getContentSize()
            index = index + 1
            self.cells[i].listImg:setVisible(true)
            self.cells[i].bgImg:setVisible(i%2 == 1)
            self.cells[i].rankTx:setString(i + (self.page - 1)*MAX_CELL)
            self.cells[i].nameTx:setString(data.name)
            self.cells[i].serverTx:setString(data.sid)
            self.cells[i].scoreTx:setString(data.score)
            local roleObj = RoleData:getRoleInfoById(tonumber(data.headpic))
            self.cells[i].headpicImg:loadTexture(roleObj:getIcon())
        else
            self.cells[i].listImg:setVisible(false)
        end
    end

    local size = self.rankSv:getContentSize()
    if index * (singleSize.height + self.intervalSize) > size.height then
        self.rankSv:setInnerContainerSize(cc.size(size.width,index * (singleSize.height + self.intervalSize)))
    else
        self.rankSv:setInnerContainerSize(size)
    end
    for i=1,index do
        if index > 3 then
            self.cells[i].listImg:setPosition(cc.p(0,(index - i)*singleSize.height))
        else
            self.cells[i].listImg:setPosition(cc.p(0,size.height - i*singleSize.height))
        end
    end
end

function WorldWarListUI:updateLastListCell()
    if #self.lastCells <= 0 then
        for i=1,MAX_CELL do
            local cellNode = cc.CSLoader:createNode("csb/worldwarlastlistcell.csb")
            local listImg = cellNode:getChildByName('list_img')
            local bgImg = listImg:getChildByName('bg_img')
            local rankTx = listImg:getChildByName('rank_tx')
            local nameTx = listImg:getChildByName('name_tx')
            local titleTx = listImg:getChildByName('title_tx')
            listImg:removeFromParent(false)
            self.lastRankSv:addChild(listImg)
            self.lastCells[i] = {listImg = listImg,bgImg = bgImg,rankTx = rankTx,
                nameTx = nameTx,titleTx = titleTx}
        end
    end
    local singleSize
    local index = 0
    for i=1,MAX_CELL do
        local data = self.rankData[i + (self.page - 1)*MAX_CELL]
        singleSize = self.lastCells[i].listImg:getContentSize()
        self.lastCells[i].bgImg:setVisible(i%2 == 1)
        self.lastCells[i].rankTx:setString(i + (self.page - 1)*MAX_CELL)
        if (i + (self.page - 1)*MAX_CELL) <= MAX_ROLE then
            if data then
                index = index + 1
                self.lastCells[i].listImg:setVisible(true)
                self.lastCells[i].nameTx:setString(data.name)
                self.lastCells[i].titleTx:setString(data.sid)
            elseif (i + (self.page - 1)*MAX_CELL) <= MAX_ROLE then
                index = index + 1
                self.lastCells[i].listImg:setVisible(true)
                self.lastCells[i].nameTx:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC30'))
                self.lastCells[i].titleTx:setString(i + (self.page - 1)*MAX_CELL)
            end
        else
            self.lastCells[i].listImg:setVisible(false)
        end
    end

    local size = self.lastRankSv:getContentSize()
    if index * (singleSize.height + self.intervalSize) > size.height then
        self.lastRankSv:setInnerContainerSize(cc.size(size.width,index * (singleSize.height + self.intervalSize)))
    else
        self.lastRankSv:setInnerContainerSize(size)
    end
    for i=1,index do
        if index > 3 then
            self.lastCells[i].listImg:setPosition(cc.p(0,(index - i)*singleSize.height))
        else
            self.lastCells[i].listImg:setPosition(cc.p(0,size.height - i*singleSize.height))
        end
    end
end

function WorldWarListUI:updatePanel()
    for i,v in ipairs(self.pageBtns) do
        local infoTx = v:getChildByName('info_tx')
        if i == self.pageBtn then
            v:setBrightStyle(ccui.BrightStyle.highlight)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            v:setBrightStyle(ccui.BrightStyle.normal)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end

    if self.page <= 1 then
        self.leftBtn:setTouchEnabled(false)
        self.leftBtn:setBright(false)
        self.page = 1
    else
        self.leftBtn:setTouchEnabled(true)
        self.leftBtn:setBright(true)
    end

    if self.page >= self.maxPage then
        self.page = self.maxPage
        self.rightBtn:setTouchEnabled(false)
        self.rightBtn:setBright(false)
    else
        self.rightBtn:setTouchEnabled(true)
        self.rightBtn:setBright(true)
    end
    self.pageTx:setString(self.page..'/'..self.maxPage)

    if self.pageBtn == 1 then
        self.rankSv:setVisible(true)
        self.lastRankSv:setVisible(false)
        self:updateListCell()
    else
        self.rankSv:setVisible(false)
        self.lastRankSv:setVisible(true)
        self:updateLastListCell()
    end
end

function WorldWarListUI:init()
    self.intervalSize = 0
	local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

	local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideList()
        end
    end)

    self.pageBtns = {}
    for i=1,2 do
        local pageBtn = worldwarImg:getChildByName('page_'..i..'_btn')
        local infoTx = pageBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('RANK_TITLE_'..i))
        self.pageBtns[i] = pageBtn
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.pageBtn = i
                if i == 1 then
                    self.rankData = self.data.rank_list
                    self.maxPage = math.ceil(#self.data.rank_list/MAX_CELL)
                else
                    self.rankData = WorldWarMgr.lastTop32 or {}
                    self.maxPage = 4
                end
                self:updatePanel()
            end
        end)
    end

    self.rankSv = worldwarImg:getChildByName('rank_sv')
    self.rankSv:setScrollBarEnabled(false)
    self.lastRankSv = worldwarImg:getChildByName('last_rank_sv')
    self.lastRankSv:setScrollBarEnabled(false)
    for i=1,MAX_CELL do
        local cellNode = cc.CSLoader:createNode("csb/worldwarlistcell.csb")
        local listImg = cellNode:getChildByName('list_img')
        local bgImg = listImg:getChildByName('bg_img')
        local rankTx = listImg:getChildByName('rank_tx')
        local headpicImg = listImg:getChildByName('headpic_img')
        local nameTx = listImg:getChildByName('name_tx')
        local serverTx = listImg:getChildByName('server_tx')
        local scoreTx = listImg:getChildByName('score_tx')
        local emBtn = listImg:getChildByName('em_btn')
        emBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                print(i + (self.page - 1)*MAX_CELL)
            end
        end)
        listImg:removeFromParent(false)
        self.rankSv:addChild(listImg)
        self.cells[i] = {listImg = listImg,bgImg = bgImg,rankTx = rankTx,headpicImg = headpicImg,
            nameTx = nameTx,serverTx = serverTx,scoreTx = scoreTx}
    end

    self.leftBtn = worldwarImg:getChildByName("left_btn")
    self.rightBtn = worldwarImg:getChildByName("right_btn")
    self.pageTx = worldwarImg:getChildByName("page_tx")
    self.maxPage = math.ceil(#self.rankData/MAX_CELL)
    self.leftBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.page > 0 then
                self.page = self.page - 1
            else
                return
            end
            self:updatePanel()
        end
    end)

    self.rightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.page < self.maxPage then
                self.page = self.page + 1
            else
                return
            end
            self:updatePanel()
        end
    end)
    self.pageTx:setLocalZOrder(1)
    self.editbox = cc.EditBox:create(cc.size(164, 40), 'uires/ui/common/name_bg9.png')
    self.editbox:setPosition(self.pageTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    self.editbox:setLocalZOrder(0)
    worldwarImg:addChild(self.editbox)

    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
        local edit = pSender
        local strFmt 
        if event == "began" then
            self.editbox:setText(self.page)
            self.pageTx:setString('')
        elseif event == "ended" then
            local page = tonumber(self.editbox:getText()) or 1
            if page > self.maxPage then
                self.page = self.maxPage
            elseif page < 1 then
                self.page = 1
            else
                self.page = page
            end
            self.editbox:setText('')
            self:updatePanel()
        end
    end)
    self:updatePanel()
end

return WorldWarListUI