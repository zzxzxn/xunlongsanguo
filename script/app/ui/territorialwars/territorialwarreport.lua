local TerritorialWarReportUI = class('TerritorialWarReportUI', BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TerritorialWarReportUI:ctor(page)
	self.uiIndex = GAME_UI.UI_WORLD_MAP_REPORT
	self.reportList = {}
	self.celltab = {}
    self.page = page or 1
    self.pageBtns = {}
end

function TerritorialWarReportUI:init()
	local bgImg = self.root:getChildByName('bg_img')
	local bgImg1 = bgImg:getChildByName('bg_img1')
	self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getWinSize()
    bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	self.noReportImg = bgImg1:getChildByName('no_report_img')
    self.noReportImg:setVisible(false)
	local closeBtn = bgImg1:getChildByName('close_btn')
	closeBtn:addClickEventListener(function ()
		TerritorialWarMgr:hideReportUI()
	end)

	local title_bg = bgImg1:getChildByName('title_bg')
	local title_tx = title_bg:getChildByName('title_tx')
	title_tx:setString(GlobalApi:getLocalStr('STR_BATTLE_REPORT1'))

    self.reportBgImg = bgImg1:getChildByName('report_bg_img')
    self.eventBgImg = bgImg1:getChildByName('event_bg_img')
	self.reportSv = self.reportBgImg:getChildByName('report_sv')
	self.reportSv:setScrollBarEnabled(false)
    self.eventSv = self.eventBgImg:getChildByName('event_sv')
    self.eventSv:setScrollBarEnabled(false)
    local node = cc.Node:create()
    node:setName('node')
    self.eventSv:addChild(node)

    for i=1,2 do
        local pageBtn = bgImg1:getChildByName('page_'..i..'_btn')
        local infoTx = pageBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_REPORT_TITLE_"..i))
        self.pageBtns[i] = pageBtn
        pageBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:getData()
            end
        end)
    end
    if self.page == 1 then
        self.eventBgImg:setVisible(true)
        self.reportBgImg:setVisible(false)
    else
        self.eventBgImg:setVisible(false)
        self.reportBgImg:setVisible(true)
    end
    self:updatePageBtn()
    self:getData()
end

function TerritorialWarReportUI:getData()
    if self.page == 1 then
        self:getEventMsg()
    else
        self:getReportMsg()
    end
end

function TerritorialWarReportUI:updateEventData(data)
    local tab = {}
    for i,v in ipairs(data) do
        local beginTime = Time.beginningOfOneDay(v.time)
        if not tab[beginTime] then
            tab[beginTime] = {}
        end
        tab[beginTime][#tab[beginTime] + 1] = v
    end
    self.eventsData = {}
    for k,v in pairs(tab) do
        self.eventsData[#self.eventsData + 1] = {time = k,data = v}
    end
    table.sort( self.eventsData,function(a,b)
        return a.time > b.time
    end )
end

function TerritorialWarReportUI:getEventMsg()
    local obj = {
        uid = UserData:getUserObj():getUid()
    }
    MessageMgr:sendPost('get_events', 'territorywar', json.encode(obj), function (jsonObj)
        local data = jsonObj.data
        if jsonObj.code == 0 then
            self:updateEventData(data.events)
            self:updateEventCell()
            self:updatePanel()
            self.eventBgImg:setVisible(true)
            self.reportBgImg:setVisible(false)
            self.noReportImg:setVisible(false)
        else
            TerritorialWarMgr:handleErrorCode(code)
        end
    end)
end

function TerritorialWarReportUI:getReportMsg()
    local obj = {
        uid = UserData:getUserObj():getUid()
    }
    MessageMgr:sendPost('get_reports', 'territorywar', json.encode(obj), function (jsonObj)
        if jsonObj.code == 0 then
            self.reportList = jsonObj.data.report
            self.num = #self.reportList
            self.noReportImg:setVisible(self.num <= 0)
            table.sort( self.reportList, function(a,b)
                return a[1] > b[1]
            end )
            self:updatePanel()
            for j=1,self.num do
                self:addReportCells(j)
            end
            self.reportBgImg:setVisible(true)
            self.eventBgImg:setVisible(false)
        else
            TerritorialWarMgr:handleErrorCode(code)
        end
    end)
end

function TerritorialWarReportUI:updateEventCell(index)
    local diffHeight = 0
    local function createEventCell(ntype,num,data)
        local node = self.eventSv:getChildByName('node')
        local bgImg = node:getChildByName('bg_img_'..num)
        if not bgImg then
            local cellNode = cc.CSLoader:createNode("csb/territoralwar_event_cell.csb")
            bgImg = cellNode:getChildByName("pl")
            bgImg:removeFromParent(false)
            bgImg:setName('bg_img_'..num)
            node:addChild(bgImg)
        end
        local cellBg = bgImg:getChildByName('cell_bg')
        local timeTx = bgImg:getChildByName('time_tx')
        local tempTx = bgImg:getChildByName('temp_tx')
        local titleTx = bgImg:getChildByName('title_tx')
        cellBg:setVisible(num%2 == 0)
        local descRT = bgImg:getChildByName('desc_rt')
        if descRT then
            descRT:removeFromParent()
            descRT = nil
        end
        local str = ''
        local str1 = ''
        if ntype == 1 then
            local time = os.date('*t',data.time)
            timeTx:setString('')
            titleTx:setString(string.format(GlobalApi:getLocalStr("STR_TIME5"),time.year,string.format('%02d',time.month),string.format('%02d',time.day)))
        else
            local time = os.date('*t',data.time)
            timeTx:setString('【'..string.format('%02d',time.hour)..':'..string.format('%02d',time.min)..'】')
            titleTx:setString('')

            local conf = GameData:getConfData("dfeventconf")[data.id]
            local paramNum = 0
            if data.param then
                for i,v in ipairs(data.param) do
                    if v ~= '' then
                        paramNum = paramNum + 1
                    end
                end
                if paramNum == 0 then
                    str = conf.text
                    str1 = conf.desc
                elseif paramNum == 1 then
                    str = string.format(conf.text,data.param[1])
                    str1 = string.format(conf.desc,data.param[1])
                elseif paramNum == 2 then
                    str = string.format(conf.text,data.param[1],data.param[2])
                    str1 = string.format(conf.desc,data.param[1],data.param[2])
                elseif paramNum == 3 then
                    str = string.format(conf.text,data.param[1],data.param[2],data.param[3])
                    str1 = string.format(conf.desc,data.param[1],data.param[2],data.param[3])
                end
                descRT = xx.RichText:create()
                descRT:setContentSize(cc.size(650, 40))
                descRT:setAlignment('left')
                descRT:setVerticalAlignment('top')
                descRT:setName('desc_rt')
                descRT:setAnchorPoint(cc.p(0,1))
                bgImg:addChild(descRT)
                xx.Utils:Get():analyzeHTMLTag(descRT,str)
            end
        end

        tempTx:setString(str1)
        local size = tempTx:getContentSize()
        local size1 = bgImg:getContentSize()
        bgImg:setPosition(cc.p(0,diffHeight))
        if descRT then
            if size.width > 630 then
                bgImg:setContentSize(cc.size(size1.width,88))
                cellBg:setContentSize(cc.size(size1.width,88))
                descRT:setPosition(cc.p(130,70.5))
                timeTx:setPosition(cc.p(72,70.5))
                diffHeight = diffHeight - 88
            else
                bgImg:setContentSize(cc.size(size1.width,66))
                cellBg:setContentSize(cc.size(size1.width,66))
                descRT:setPosition(cc.p(130,48.5))
                timeTx:setPosition(cc.p(72,48.5))
                diffHeight = diffHeight - 66
            end
        else
            diffHeight = diffHeight - 66
        end
        tempTx:setString('')
    end

    local num = 0
    for i,v in ipairs(self.eventsData) do
        num = num + 1
        createEventCell(1,num,v)
        local tab = v.data
        table.sort(tab, function(a,b)
            return a.time > b.time
        end )
        for j,v in ipairs(tab) do
            num = num + 1
            createEventCell(2,num,v)
        end
    end
    local size = self.eventSv:getContentSize()
    if math.abs(diffHeight) > size.height then
        self.eventSv:setInnerContainerSize(cc.size(size.width,math.abs(diffHeight)))
    else
        self.eventSv:setInnerContainerSize(size)
    end

    local size1 = self.eventSv:getInnerContainerSize()
    local node = self.eventSv:getChildByName('node')
    node:setPosition(cc.p(size1.width/2,size1.height))
end

function TerritorialWarReportUI:updatePanel()
    self:updatePageBtn()
end

function TerritorialWarReportUI:updatePageBtn()
    for i=1,2 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        if i == self.page then
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
end

function TerritorialWarReportUI:addReportCells(index)
    local node = cc.CSLoader:createNode("csb/territoralwar_report_cell.csb")
    local bgimg = node:getChildByName("cell_bg")
    bgimg:removeFromParent(false)
    self.celltab[index] = ccui.Widget:create()
    self.celltab[index]:addChild(bgimg)
    self:updateCells(self.reportList[index],index)

    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.reportSv:getContentSize().height then
        self.reportSv:setInnerContainerSize(cc.size(self.reportSv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.reportSv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height/2
    self.celltab[index]:setPosition(cc.p(contentsize.width/2 + 2,posy))
    self.reportSv:addChild(self.celltab[index])
    self.reportSv:scrollToTop(0.1,true)
end

function TerritorialWarReportUI:updateCells(reportArr,index)
	local time = reportArr[1]
    local win = reportArr[2] == 1
    local uid = reportArr[3]
    local rankChange = tostring(reportArr[4])
    local name
    local headpic
    local headframe
    local level
    local quality
    local reportId
    local vip = reportArr[12]
    local fightforce = reportArr[13]
    local legioname = reportArr[5]
    local legionicon = reportArr[6]
    local coststay = reportArr[4]
    if reportArr[8] then
        reportId = reportArr[7]
        name = reportArr[8]
        headpic = tonumber(reportArr[9])
        level = tostring(reportArr[10])
        quality = reportArr[11]
        headframe = tonumber(reportArr[12])
    else
        name = reportArr[8]
        headpic = tonumber(reportArr[9])
        level = tostring(reportArr[10])
        quality = reportArr[11]
        headframe = tonumber(reportArr[12])
    end

    local bgimg = self.celltab[index]:getChildByName('cell_bg')
	local rsimg = bgimg:getChildByName('rs_img')
	if win then
        rsimg:loadTexture("uires/ui/report/report_win.png")
    else
        rsimg:loadTexture("uires/ui/report/report_lose.png")
    end

    -- 时间
    local timeLabel = bgimg:getChildByName('time_tx')
    if GlobalData:getServerTime() - time > 86400 then
        timeLabel:setString(GlobalApi:getLocalStr("STR_ONEDAY_BEFORE"))
    else
        timeLabel:setString(Time.date("%H:%M:%S", time))
    end

	local headnode = bgimg:getChildByName('head_node')
	local legionametx = bgimg:getChildByName('legin_name')
	legionametx:setString(legioname)
	local legioniconimg = bgimg:getChildByName('legion_icon')
	legioniconimg:loadTexture('uires/ui/legion/legion_'..legionicon..'_jun.png')
	local stayimg = bgimg:getChildByName('stayingpower_img')
	local staytx = bgimg:getChildByName('stayingpower_tx')
	staytx:setString('-'..coststay)

	local reportbtn = bgimg:getChildByName('report_btn')
	--self:initHeadNode(headnode,data)

	local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    -- if arrdata.frameBg then
    --     cell.awardBgImg:loadTexture(arrdata.frameBg)
    -- else
        cell.awardBgImg:loadTexture(COLOR_FRAME[quality])
    --end
    cell.lvTx:setString('Lv.'..level)
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(headframe))
    local obj = RoleData:getHeadPicObj(tonumber(headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.awardImg:ignoreContentAdaptWithSize(true)
    cell.nameTx:setString('')
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(name..' ', 24,COLOR_TYPE.WHITE)
    local rt2 = xx.RichTextImage:create("uires/ui/chat/chat_vip_small.png")
    local rt3 = xx.RichTextAtlas:create(vip,"uires/ui/number/font_ranking.png", 20, 22, '0')
    rt:addElement(rt1)
    if vip and tonumber(vip) > 0 then
        rt:addElement(rt2)
        rt:addElement(rt3)
    end
    rt:setAlignment("left")
    rt:setVerticalAlignment('middle')
    rt:setPosition(cc.p(0, 0))
    rt:setContentSize(cc.size(400, 30))
    cell.nameTx:addChild(rt)
    cell.nameTx:setPosition(cc.p(100,70))

    local rtfightforce = xx.RichText:create()
    rtfightforce:setAnchorPoint(cc.p(0, 0.5))
    local rtfightforce1= xx.RichTextImage:create("uires/ui/common/fightbg.png")
    local rtfightforce2 = xx.RichTextAtlas:create(fightforce,"uires/ui/number/font_fightforce_3.png", 26, 38, '0')
    rtfightforce:addElement(rtfightforce1)
    rtfightforce:addElement(rtfightforce2)
    rtfightforce:setAlignment("left")
    rtfightforce:setVerticalAlignment('middle')
    rtfightforce:setPosition(cc.p(0, -40))
    rtfightforce:setContentSize(cc.size(400, 30))
    rtfightforce:setScale(0.8)
    cell.nameTx:addChild(rtfightforce)
    cell.nameTx:setPosition(cc.p(100,70))
    headnode:addChild(cell.awardBgImg)
    reportbtn:addTouchEventListener(function (sender, eventType)
	    if eventType == ccui.TouchEventType.began then
	        AudioMgr.PlayAudio(11)
	    elseif eventType == ccui.TouchEventType.ended then
	        local args = {
	            id = reportId
	        }
	        MessageMgr:sendPost('get_replay', 'territorywar', json.encode(args), function (jsonObj)
	            if jsonObj.code == 0 then
	                local customObj = {
	                    info = jsonObj.data.info,
	                    enemy = jsonObj.data.enemy,
	                    rand1 = jsonObj.data.rand1,
	                    rand2 = jsonObj.data.rand2
	                }
	                BattleMgr:playBattle(BATTLE_TYPE.REPLAY, customObj, function ()
	                    TerritorialWarMgr:showMapUI()
	                end)
	            else
	                TerritorialWarMgr:handleErrorCode(code)
	            end
	        end)
        end
    end)
end


return TerritorialWarReportUI
