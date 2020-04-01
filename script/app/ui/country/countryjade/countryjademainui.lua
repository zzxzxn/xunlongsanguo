local CountryJadeMainUI = class("CountryJadeMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function CountryJadeMainUI:ctor(showType,serverData,country)
    self.uiIndex = GAME_UI.UI_COUNTRY_JADE_MAIN_PANNEL
    self.showType = showType or COUNTRY_JADE_SHOW_TYPE.OWN
    self.serverData = serverData    -- room的索引是字符串
    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        self.currCountry = UserData:getUserObj():getCountry()
            UserData:getUserObj().country_jade = self.serverData.user.mergeCount
    else
        self.currCountry = country
    end
    self:initData()
end

-- 初始化
function CountryJadeMainUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName("bg_img1")
    self.bgimg1 = bgimg1

    self.closeBtn = self.root:getChildByName("close_btn")

    local txt_title = self.bgimg1:getChildByName("txt_title")
    txt_title:setString(GlobalApi:getLocalStr('COUNTRY_JADE_TITLE'))
    
    
    self.jadeFightBg = self.root:getChildByName("fight_bg")
    self.jadeMineFightTx = self.jadeFightBg:getChildByName("jade_mine_fight_tx")
    self.jadeFightTx = self.jadeFightBg:getChildByName("jade_fight_tx")

    self.jadeJadeTx = self.bgimg1:getChildByName("mine_jade_tx")
    self.jadeJadeImg = self.bgimg1:getChildByName("mine_jade_img")
    self.jadeJadeTxWu = self.bgimg1:getChildByName("mine_jade_tx_wu")
    self.jadeCount = self.bgimg1:getChildByName("jade_count")

    local winSize = cc.Director:getInstance():getWinSize()
    self.btn_panel = self.root:getChildByName("btn_panel")
    self.btn_panel:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

    self.robBtn = self.btn_panel:getChildByName("rob_btn")
    self.robBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_LUEDUO'))

    self.reportBtn = self.btn_panel:getChildByName("report_btn")
    self.reportBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_ZHANBAO'))

    self.refreshBtn = self.btn_panel:getChildByName("refresh_btn")   -- 现在改为转化按钮
    self.refreshBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_ZHUANHUAN'))

    self.getJadeBtn = self.btn_panel:getChildByName("get_jade_btn")
    self.getJadeBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_JIANGLI'))

    self.arrowImg = self.root:getChildByName("arrow_img")
    self.arrowImg:setPositionX(winSize.width / 2)
    self.arrowImgLeft = self.arrowImg:getChildByName("left")
    self.arrowImgRight = self.arrowImg:getChildByName("right")
    self.arrowImgTx = self.arrowImg:getChildByName("tx")

    self.closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
                CountryJadeMgr:hideMyOwnCountryJadeMainUI()
            else
                CountryJadeMgr:hideOtherCountryJadeMainUI()
                CountryJadeMgr:showMyOwnCountryJadeMainUI()
            end
        end
    end)

    self.robBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then     --掠夺
                local countryIds = {}
                for i = 1,3 do
                    if self.currCountry ~= i then
                        table.insert(countryIds,i)
                    end
                end
                CountryJadeMgr:showCountryJadeChooseCountryUI(countryIds)
            else    --回国
                CountryJadeMgr:hideOtherCountryJadeMainUI()
                CountryJadeMgr:showMyOwnCountryJadeMainUI()
            end
        end
    end)

    self.reportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            CountryJadeMgr:showCountryJadeReportUI()
            self:setHasReport()
            self:refreshReportMark()
        end
    end)

    self.arrowImgLeft:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            -- 从大到小，循环
            local currPage = self.currPage - 1
            if currPage < 1 then
                currPage = self.allPage
            end

            local function callBack(msg)
                self.currPage = currPage
                print('++++++++++++' .. self.currPage)
                if msg.user then
                    self.serverData.user = msg.user
                    self:updateMyCountryCorner()
                end
                self:updateAllRoomsData(msg.rooms)
                self:refreshSv()
                self:updateShowPage()
                self:hideAllAdd()
            end

            local startId = (currPage - 1) * self.everyPageRoomCount + 1
            local endId = startId + self.everyPageRoomCount - 1
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN and (tonumber(self.serverData.user.roomId) >= startId) and (tonumber(self.serverData.user.roomId) <= endId) then
                CountryJadeMgr:getCountryJadeFromServer(callBack)
            else
                CountryJadeMgr:getOtherCountryJadeFromServer(self.currCountry,startId,self.everyPageRoomCount,callBack)
            end

        end
    end)

    self.arrowImgRight:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            -- 从小到大，循环
            local currPage = self.currPage + 1
            if currPage > self.allPage then
                currPage = 1
            end

            local function callBack(msg)
                self.currPage = currPage
                print('++++++++++++' .. self.currPage)
                if msg.user then
                    self.serverData.user = msg.user
                    self:updateMyCountryCorner()
                end
                self:updateAllRoomsData(msg.rooms)
                self:refreshSv()
                self:updateShowPage()
                self:hideAllAdd()
            end

            local startId = (currPage - 1) * self.everyPageRoomCount + 1
            local endId = startId + self.everyPageRoomCount - 1
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN and (tonumber(self.serverData.user.roomId) >= startId) and (tonumber(self.serverData.user.roomId) <= endId) then
                CountryJadeMgr:getCountryJadeFromServer(callBack)
            else
                CountryJadeMgr:getOtherCountryJadeFromServer(self.currCountry,startId,self.everyPageRoomCount,callBack)
            end

        end
    end)

    self.refreshBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then      
            local cost = tonumber(GlobalApi:getGlobalValue('countryJadeExchangeCost'))
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH3'),cost), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                local hasCash = UserData:getUserObj():getCash()
                if hasCash >= cost then
                    local function callBack(data)
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self.serverData.user.jade = data.jade
                        self:updateMyCountryCorner()
                        self:showAllAdd()
                    end
                    CountryJadeMgr:replaceJadeFromServer(callBack)
                else
                    promptmgr:showMessageBox(
                        GlobalApi:getLocalStr('STR_CASH')..GlobalApi:getLocalStr('NOT_ENOUGH')..'，'..GlobalApi:getLocalStr('STR_CONFIRM_TOBUY') .. GlobalApi:getLocalStr('STR_CASH') .. '？',
                        MESSAGE_BOX_TYPE.MB_OK_CANCEL,
                        function ()
                            GlobalApi:getGotoByModule('cash')
                    end)

                end

            end)


        end
    end)

    self.getJadeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then        
            if self.getJadeStatus == 1 then  
                if not self:judgeIsHasJade() then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES22'), COLOR_TYPE.RED)
                    return
                end
                    local function callBack(data)
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self.serverData.user = data.user
                        self:updateMyCountryCorner()
                        self:showAllAdd()
                        CountryJadeMgr:showJadeAward(tonumber(data.user.jade))
                    end
                    CountryJadeMgr:getJadeFromServer(callBack)         
            else
                -- 弹出奖励界面
                CountryJadeMgr:showCountryJadeAwardUI()
            end
        end
    end)

    -- cell
    self.cell = bgimg:getChildByName("cell")
    self.cell:setVisible(false)

    local sv_temp = bgimg1:getChildByName('sv')
    sv_temp:setContentSize(cc.size(winSize.width, sv_temp:getContentSize().height))
    sv_temp:setPositionX(-(winSize.width - 960)/2)
    sv_temp:setScrollBarEnabled(false)
    sv_temp:setVisible(false)
    self.sv_temp = sv_temp

	local winSize = cc.Director:getInstance():getWinSize()
	bgimg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    self:adaptUI2()

    self:refresh()
    self:hideAllAdd()

    if self.serverData.status == 1 or self.serverData.status == 2 and CountryJadeMgr.countryJadeSuccessShowStatus == false then
        CountryJadeMgr:showCountryJadeSuccessUI(self.serverData.status)
        self.serverData.status = 0
    end
    CountryJadeMgr.countryJadeSuccessShowStatus = false

end

function CountryJadeMainUI:onShowUIAniOver()
    -- if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN and self:judgeIsHasJade() then
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.COUNTRY_JADE)
    -- end
end

function CountryJadeMainUI:adaptUI2()
    local winSize = cc.Director:getInstance():getWinSize()
    self.closeBtn:setPosition(cc.p(winSize.width - 40,winSize.height - 40))

    self.jadeJadeTx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES11'))
    self.jadeJadeImg:setPositionX(self.jadeJadeTx:getPositionX() + 30)
    self.jadeJadeTxWu:setPositionX(self.jadeJadeTx:getPositionX() + 5)

    -- self.arrowImg:setPosition(cc.p(winSize.width - (960 - 889),58))

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.COUNTRY_JADE)
    btn:setPosition(cc.p(32,600))
    self.bgimg1:addChild(btn)
end

function CountryJadeMainUI:initData()
    self.countryDatas = {
        [1] = { ["country_img"] = 'uires/ui/country/jade/weiguo.png'},
        [2] = { ["country_img"] = 'uires/ui/country/jade/shuguo.png'},
        [3] = { ["country_img"] = 'uires/ui/country/jade/wuguo.png'},
    }
    self.countryJadeConf = GameData:getConfData('countryjade')

    -- 每页房间数量
    self.everyPageRoomCount = CountryJadeMgr:getCountryJadePageRoomCount()
    -- 所有的房间数量
    self.allPageRoomCount = CountryJadeMgr:getCountryJadeRoomCount()
    -- 所有的页数,这里的配置必须为整除来配置
    self.allPage = self.allPageRoomCount/self.everyPageRoomCount
    -- 当前页
    self.currPage = 1
    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        local roomId = self.serverData.user.roomId
        if roomId > 4 then
            self.currPage = math.ceil(roomId/self.everyPageRoomCount)
        end
    end
    -- 项
    self.cells = {}
    
    self.getJadeStatus = 1

    -- 所有的加号图片
    self.allAddImg = {}

    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        for k,v in pairs(self.serverData.rooms) do
            if tonumber(k) == tonumber(self.serverData.user.roomId) then
                UserData:getUserObj():setCountryJadeFinishTime(v.finishTime)
                UserData:getUserObj():addGlobalTime()
                break
            end
        end
    end
end

function CountryJadeMainUI:refresh()
    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        self:updateMyCountryCorner()
    else
        self:updateOtherCountryCorner()
    end
    self:refreshSv()
    self:updateShowPage()
end

function CountryJadeMainUI:updateMyCountryCorner()
    self.jadeCount:setVisible(true)
    self.jadeFightBg:setVisible(false)

    self.jadeJadeTx:setVisible(true)
    self.jadeJadeImg:setVisible(true)
    self.jadeJadeTxWu:setVisible(true)

    self.reportBtn:setTouchEnabled(true)
    self.reportBtn:setBright(true)

    self.getJadeBtn:setTouchEnabled(true)
    self.getJadeBtn:setBright(true)

    self.reportBtn:setVisible(true)
    self.getJadeBtn:setVisible(true)
    self.refreshBtn:setVisible(true)
    self.robBtn:setVisible(true)

    -- self.closeBtn:loadTextureNormal('uires/ui/common/btn_close.png')

    -- 现在暂时改为可以免费领取3次,并且只要是可以领取的状态和玩家没有玉璧的时候，红点就存在
    local mark = self.getJadeBtn:getChildByName('mark')
    local allCount = CountryJadeMgr:getCountryJadeGetJadeFreeTimes()
    if self:judgeIsHasJade() and self.serverData.user.jadeGetCount < CountryJadeMgr:getCountryJadeGetJadeFreeTimes() then -- 没有玉璧，并且有可领取的次数,等后台加个字段
        self.getJadeStatus = 1
        -- self.getJadeBtn:loadTextureNormal('uires/ui/country/jade/lingbi.png')
        self.getJadeBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_LINGBI'))
        mark:setVisible(true)
    else
        self.getJadeStatus = 2
        -- self.getJadeBtn:loadTextureNormal('uires/ui/country/jade/jiangli.png')
        self.getJadeBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_JIANGLI'))
        mark:setVisible(false)
    end

    self.robBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_LUEDUO'))

    self.jadeCount:setString(string.format(GlobalApi:getLocalStr('COUNTRY_JADE_DES10'),self:getJadeRemainCount(),CountryJadeMgr:getCountryJadeMergeCount()))
    self.jadeJadeTxWu:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES20'))
    -- 看是否有玉璧没
    if self:judgeIsHasJade() then -- 无
        self.jadeJadeImg:setVisible(false)
        self.jadeJadeTxWu:setVisible(true)

        self.refreshBtn:setTouchEnabled(false)
        self.refreshBtn:setBright(false)
    else
        self.jadeJadeImg:setVisible(true)
        self.jadeJadeImg:loadTexture(self.countryJadeConf[tonumber(self.serverData.user.jade)].icon)
        if self.countryJadeConf[tonumber(self.serverData.user.jade)].subType == 2 then
            self.jadeJadeImg:setRotation(180)
        else
            self.jadeJadeImg:setRotation(0)
        end
        self.jadeJadeTxWu:setVisible(false)

        self.refreshBtn:setTouchEnabled(true)
        self.refreshBtn:setBright(true)
    end

    --self:refreshGetJadeMark()
    self:refreshReportMark()
end

function CountryJadeMainUI:updateShowPage()
    self.arrowImgTx:setString(string.format(GlobalApi:getLocalStr('COUNTRY_JADE_DES47'),self.currPage,self.allPage))
end

function CountryJadeMainUI:updateOtherCountryCorner()
    self.jadeCount:setVisible(false)
    self.jadeFightBg:setVisible(true)

    self.jadeJadeTx:setVisible(false)
    self.jadeJadeImg:setVisible(false)
    self.jadeJadeTxWu:setVisible(false)

    -- self.reportBtn:setTouchEnabled(false)
    -- self.reportBtn:setBright(false)

    -- self.getJadeBtn:setTouchEnabled(false)
    -- self.getJadeBtn:setBright(false)

    -- self.refreshBtn:setTouchEnabled(false)
    -- self.refreshBtn:setBright(false)
    
    -- self.robBtn:getChildByName("name_text"):setString(GlobalApi:getLocalStr('COUNTRY_JADE_HUIGUO'))

    self.reportBtn:setVisible(false)
    self.getJadeBtn:setVisible(false)
    self.refreshBtn:setVisible(false)
    self.robBtn:setVisible(false)

    -- self.closeBtn:loadTextureNormal('uires/ui/common/btn_return3.png')

    self.jadeMineFightTx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES12'))
    self.jadeFightTx:setString(RoleData:getFightForce())
end

function CountryJadeMainUI:refreshSv()
    self.allAddImg = {}
    self.cells = {}
    if self.bgimg1:getChildByName('scrollView_sv') then
        self.bgimg1:removeChildByName('scrollView_sv')
    end
    local sv = self.sv_temp:clone()
    sv:setVisible(true)
    sv:setName('scrollView_sv')
    sv:setAnchorPoint(cc.p(0, 0))
    -- sv:setPosition(cc.p(0, 0))
    self.bgimg1:addChild(sv)

    local bgimg1 = self.bgimg1
    local countryImg = bgimg1:getChildByName('country_img')
    countryImg:loadTexture(self.countryDatas[self.currCountry]['country_img'])

    local num = self.everyPageRoomCount

    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 18

    local width = num * self.cell:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 48
    local tempWidth = self.cell:getContentSize().width
    for i = 1,num,1 do
        local roomId = (self.currPage - 1) * self.everyPageRoomCount + i
        local tempCell = self.cell:clone()
        tempCell:setName('svCell' .. i)
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,48))
        sv:addChild(tempCell)

        tempCell.roomId = roomId
        self:updateCell(tempCell)
        table.insert(self.cells,tempCell)
    end
    innerContainer:setPositionX(0)
end

function CountryJadeMainUI:updateCell(cell)
    local roomData = self.serverData.rooms[tostring(cell.roomId)]    -- 这个rooms的索引和房间号id对应的
    if not roomData then
        return
    end
    -- 顶部
    local topImg = cell:getChildByName('top_img')
    local joinTx = topImg:getChildByName('join_tx') 
    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        if (roomData.leftPlayer.uid == 0 or roomData.rightPlayer.uid == 0) and roomData.robUid == 0 then    -- 可以加入
            joinTx:setVisible(true)
            joinTx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES17'))
        else
            joinTx:setVisible(false)
        end
    else
        joinTx:setVisible(false)
    end

    local remainTimeTx = topImg:getChildByName('remain_time_tx')
    local finishTime = roomData.finishTime
    local diffTime = finishTime - GlobalData:getServerTime()
    if diffTime > 0 then
        self:timeoutCallback(cell,remainTimeTx,finishTime)
        remainTimeTx:setVisible(true)
    else
        remainTimeTx:setVisible(false)
    end

    -- 中部
    local centerImg = cell:getChildByName('center_img')
    local centerLeft = centerImg:getChildByName('left')
    local centerRight = centerImg:getChildByName('right')

    if tonumber(roomData.leftPlayer.jade) ~= 0 then
        centerLeft:loadTexture(self.countryJadeConf[tonumber(roomData.leftPlayer.jade)].icon)
        centerLeft:setVisible(true)
        centerLeft:setRotation(0)
    else
        centerLeft:setVisible(false)
    end

    if tonumber(roomData.rightPlayer.jade) ~= 0 then
        centerRight:loadTexture(self.countryJadeConf[tonumber(roomData.rightPlayer.jade)].icon)
        centerRight:setVisible(true)
        centerRight:setRotation(180)
    else
        centerRight:setVisible(false)
    end

    -- 底部
    self.allAddImg[cell.roomId] = {}
    for i = 1,2 do  -- 1带表左，2带表右
        local widgetName,data,workData  -- data是i的数据，workData是另一方的数据
        if i == 1 then
            widgetName = 'left'
            data = roomData.leftPlayer
            workData = roomData.rightPlayer
        else
            widgetName = 'right'
            data = roomData.rightPlayer
            workData = roomData.leftPlayer
        end

        local widget = cell:getChildByName(widgetName)
        local size = widget:getContentSize()
        if widget:getChildByName('fightforceLabel') then
            widget:removeChildByName('fightforceLabel')
        end
        local name = widget:getChildByName('name')  -- you
        local roleNode = widget:getChildByName('role_node')
        local awardBgImg = roleNode:getChildByName('award_bg_img')
        if not awardBgImg then
            local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
            awardBgImg = iconCell.awardBgImg
            awardBgImg:setScale(0.65)
            roleNode:addChild(iconCell.awardBgImg)
            -- iconCell.awardBgImg:setPosition(cc.p(size.width / 2, size.height / 2))
            local size = awardBgImg:getContentSize()
            local labaImg = ccui.ImageView:create('uires/ui/country/jade/laba3.png')
            labaImg:ignoreContentAdaptWithSize(true)
            labaImg:setPosition(cc.p(size.width/2,size.height/2))
            labaImg:setName('laba_img')
            labaImg:setScale(1.5)
            awardBgImg:addChild(labaImg)

            iconCell.addImg:loadTexture('uires/ui/common/add_01.png')
            iconCell.addImg:ignoreContentAdaptWithSize(true)
            iconCell.addImg:setScale(1.65)
        end
        -- local obj = RoleData:getHeadPicObj(self.roleInfo.headpic)
        -- iconCell.awardImg:loadTexture(obj:getIcon())
        -- iconCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.roleInfo.headframe))
        -- iconCell.headframeImg:setVisible(true)
        -- iconCell.awardBgImg:loadTexture(COLOR_FRAME[self.roleInfo.quality])
        local headframeImg = awardBgImg:getChildByName('headframeImg')
        local icon = awardBgImg:getChildByName('award_img')  -- you
        local lv = awardBgImg:getChildByName('lv_tx')  -- you
        local add = awardBgImg:getChildByName('add_img')  -- you
        table.insert(self.allAddImg[cell.roomId],add)
        local labaImg = awardBgImg:getChildByName('laba_img')  -- you 

        local rob_btn = widget:getChildByName('rob_btn')
        local fight_bg = widget:getChildByName('fight_bg')  -- you
        local fight_wan = widget:getChildByName('fight_wan')  -- you
        fight_wan:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES27'))
        local time = widget:getChildByName('time')  -- you
        local hong_img = widget:getChildByName('hong_img')  -- you
        local hong_img_tx = hong_img:getChildByName('tx')  -- you

        local leave_btn = widget:getChildByName('leave_btn')
        leave_btn:setVisible(false)

        local state = 0
        if data.uid == 0 then
            headframeImg:setVisible(false)
            name:setVisible(false)
            icon:setVisible(false)
            lv:setVisible(false)
            fight_bg:setVisible(false)
            fight_wan:setVisible(false)
            awardBgImg:loadTexture("uires/ui/common/frame_default.png")

            --
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
                -- 判断其他位置是否有人，并且那个人是自己,并且是否被抢
                -- 2种情况:1:可加入，喊话
                if roomData.robUid == 0 then
                    if workData.uid ~= 0 and workData.uid == UserData:getUserObj():getUid() then  -- 喊话
                        labaImg:setVisible(true)
                        add:setVisible(false)
                        
                        self:shoutRefresh(cell,time,labaImg)
                        state = 2
                    else    -- 可加入
                        time:setVisible(false)
                        labaImg:setVisible(false)
                        add:setVisible(true)
                        state = 1
                    end
                else
                    time:setVisible(false)
                    labaImg:setVisible(false)
                    add:setVisible(false)
                end
   
            else
                time:setVisible(false)
                labaImg:setVisible(false)
                add:setVisible(false)
            end

            rob_btn:setVisible(false)
            hong_img:setVisible(false)
        else
            name:setVisible(true)
            icon:setVisible(true)
            lv:setVisible(true)
            fight_bg:setVisible(true)
            headframeImg:setVisible(true)

            name:setString(data.name)
            local headpic = 1   -- 兼容性，防止后台发0
            if data.headpic then
                headpic = data.headpic
            end
            local conf = GameData:getConfData('settingheadicon')[headpic]
            icon:loadTexture(conf.icon)
            if data.quality and data.quality > 0 then
                awardBgImg:loadTexture(COLOR_FRAME[data.quality])
            else
                awardBgImg:loadTexture(COLOR_FRAME[conf.quality])
            end
            headframeImg:loadTexture(GlobalApi:getHeadFrame(data.headframe))
            lv:setString(data.level)

            local fightforceLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))    -- 26是字符高度，38是字符宽度,0是开始字符
            fightforceLabel:setName('fightforceLabel')
            fightforceLabel:setAnchorPoint(cc.p(0.5, 0.5))
            local labelScale = 0.5
            fightforceLabel:setScale(labelScale)         
            widget:addChild(fightforceLabel)
            local fightforceLabelOffset = 5

            if data.fight_force > 10000 then
                fight_wan:setVisible(true)
                fightforceLabel:setString(math.ceil(tonumber(data.fight_force)/10000))
            else
                fight_wan:setVisible(false)
                fightforceLabel:setString(data.fight_force)
            end

            local fightforceLabelWidth = fightforceLabel:getContentSize().width * labelScale
            fightforceLabel:setPosition(cc.p(50,fight_wan:getPositionY()))
            fight_bg:setPositionX(fightforceLabel:getPositionX() - fightforceLabelWidth / 2 - fightforceLabelOffset)
            fight_wan:setPositionX(fightforceLabel:getPositionX() + fightforceLabelWidth / 2 + fightforceLabelOffset)

            --
            time:setVisible(false)
            labaImg:setVisible(false)
            add:setVisible(false)
            --
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then     -- 退出状态，被抢中(有可能在合璧，也有可能不在合璧)
                if roomData.robUid == 0 then
                    local diffTime = roomData.finishTime - GlobalData:getServerTime()
                    if diffTime <= 0 and data.uid == UserData:getUserObj():getUid() then     -- 有合璧，可退出
                        hong_img:setVisible(false)
                        state = 3
                        leave_btn:setVisible(true)
                    else
                        hong_img:setVisible(false)
                    end
                else    -- 抢夺中
                    if roomData.robPos == i then
                        hong_img:setVisible(true)
                        if UserData:getUserObj():getUid() == data.uid then  -- 自己 被抢中
                            hong_img_tx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES18'))
                        else
                            hong_img_tx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES25'))
                        end
                        
                    else
                        hong_img:setVisible(false)
                    end
                end
                rob_btn:setVisible(false)
            else
                if roomData.robUid == 0 then   -- 可抢夺
                    rob_btn:setVisible(true)
                    hong_img:setVisible(false)
                else    -- 抢夺中
                    rob_btn:setVisible(false)
                    if roomData.robPos == i then
                        hong_img:setVisible(true)
                        hong_img_tx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES25'))
                    else
                        hong_img:setVisible(false)
                    end
                end

            end

        end
        add.lastVisible = add:isVisible()  -- 把原来的显示状态记录下来

        local function ExitRoomCallBack()
            local function callBack(msg)
                self.serverData.user.roomId = 0
                self:updateSingleRoomsDataByOther(msg.room)
                self:refreshSingleRoom(roomData.id)
                self:showAllAdd()
            end
            CountryJadeMgr:exitRoomFromServer(roomData.id,callBack)
        end

        awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            end
            if eventType == ccui.TouchEventType.ended then
                --print('kkkkkkkkkk' .. state)
                if state == 1 then  -- 加入
                    -- 已经在房间里面了
                    if self.serverData.user.roomId ~= 0 then
                        --promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES110'), COLOR_TYPE.RED)
                        return
                    end

                    -- 被抢中，不能加入
                    if roomData.robUid ~= 0 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES41'), COLOR_TYPE.RED)
                        return
                    end
                    -- 没有玉璧
                    if self:judgeIsHasJade() then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES29'), COLOR_TYPE.RED)
                        return
                    end
                
                    -- 次数限制
                    if self:getJadeRemainCount() <= 0 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES113'), COLOR_TYPE.RED)
                        return
                    end

                    -- 位置不匹配
                    local pos = i
                    if i ~= self.countryJadeConf[tonumber(self.serverData.user.jade)].subType then
                        -- 如果有2个房间
                        if workData.uid ~= 0 then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES30'), COLOR_TYPE.RED)
                            return
                        else
                            if i == 1 then
                                pos = 2
                            else
                                pos = 1
                            end                            
                        end                       
                    end

                    -- 合璧活动即将关闭，现在无法进行合璧。快去抢夺他人吧
                    -- 先取消这个限制条件
                    if CountryJadeMgr:judgeIsCountryJadeCloseJadeTime() then
                        --promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES31'), COLOR_TYPE.RED)
                        --return
                    end

                    -- 如果能合璧的话，弹出窗口提示
                    promptmgr:showMessageBox(GlobalApi:getLocalStr("COUNTRY_JADE_DES32"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        local function callBack(msg)
                            self.serverData.user.roomId = roomData.id
                            self:updateSingleRoomsDataByOther(msg.room)
                            self:refreshSingleRoom(roomData.id)
                            self:hideAllAdd()
                            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
                                UserData:getUserObj():setCountryJadeFinishTime(msg.room.finishTime)
                                UserData:getUserObj():addGlobalTime()
                            end
                        end
                        CountryJadeMgr:joinRoomFromServer(roomData.id,pos,callBack)   -- pos是位置

                    end, nil, nil, nil, "country_jade_tips")

                elseif state == 2 then  -- 喊话
                    local nextShoutTime = self.serverData.user.nextShoutTime
                    if nextShoutTime - GlobalData:getServerTime() > 0 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES112'), COLOR_TYPE.RED)
                        return
                    end

                    local function callBack(msg)
                        self.serverData.user = msg.user
                        self:shoutRefresh(cell,time,labaImg)
                    end
                    CountryJadeMgr:broadcastFromServer(callBack)

                elseif state == 3 then  -- 退出
                    if data.uid ~= 0 then
                        BattleMgr:showCheckInfo(data.uid,'world','country')
                    end
                else
                    if data.uid ~= 0 then
                        BattleMgr:showCheckInfo(data.uid,'world','country')
                    end
                end
            end
        end)

        -- closeBtn:addTouchEventListener(function (sender, eventType)
        --     if eventType == ccui.TouchEventType.began then
        --         AudioMgr.PlayAudio(11)
        --     end
        --     if eventType == ccui.TouchEventType.ended then
        --         -- 退出
        --         ExitRoomCallBack()
        --     end
        -- end)

        leave_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            end
            if eventType == ccui.TouchEventType.ended then
                -- 退出
                ExitRoomCallBack()
            end
        end)

        rob_btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            end
            if eventType == ccui.TouchEventType.ended then       
                --合璧剩余时间不足2分钟时，玩家点击掠夺提示，前端判断
                if remainTimeTx:getChildByTag(9527) and remainTimeTx:getChildByTag(9527).time then
                    if CountryJadeMgr:judgeJadeIsCompleteByRob(remainTimeTx:getChildByTag(9527).time) then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_JADE_DES33'), COLOR_TYPE.RED)
                        return
                    end
                end
                                      
                promptmgr:showMessageBox(GlobalApi:getLocalStr("COUNTRY_JADE_DES28"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    local function callBack(msg)
                        local customObj = {
                            country = self.currCountry,
                            roomId = roomData.id,
                            roomData = roomData,
                            info = msg.info    -- 战斗信息数据（对手的阵型信息）
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.COUNTRY_JADE, customObj, function ()
                            MainSceneMgr:showMainCity(function ()
                                CountryJadeMgr:showMyOwnCountryJadeMainUI()
                            end, nil, GAME_UI.UI_COUNTRY_JADE_MAIN_PANNEL)

                        end)
                    end
                    CountryJadeMgr:robOtherCountryFromServer(self.currCountry,roomData.id,i,callBack)

                end, nil, nil, nil, "country_jade_rob_tips")
            end
        end)

    end
end

-- 喊话刷新
function CountryJadeMainUI:shoutRefresh(cell,timeLabel,labaImg)
    local nextShoutTime = self.serverData.user.nextShoutTime
    if nextShoutTime - GlobalData:getServerTime() > 0 then
        self:shoutTimeoutCallback(cell,timeLabel,labaImg,nextShoutTime)
        ShaderMgr:setGrayForWidget(labaImg)
        timeLabel:setVisible(true)
    else
        ShaderMgr:restoreWidgetDefaultShader(labaImg)
        timeLabel:setVisible(false)
    end
end

-- 战报要根据是否有新的战报判断
function CountryJadeMainUI:refreshReportMark()
    local mark = self.reportBtn:getChildByName('mark')
    mark:setVisible(self:judgeIsHasReport())
end

function CountryJadeMainUI:refreshGetJadeMark()
    local mark = self.getJadeBtn:getChildByName('mark')
    mark:setVisible(self:judgeTodayIsGetJade() and self:judgeIsHasJade() and CountryJadeMgr:judgetCountryJadePriceIsEnough())
end

function CountryJadeMainUI:timeoutCallback(cell,parent,time)
    local diffTime = 0
    if time ~= 0 then
        diffTime = time - GlobalData:getServerTime()
    end
    local node = cc.Node:create()
    node:setTag(9527)        
    node:setPosition(cc.p(0,0))
    if parent:getChildByTag(9527) then
        parent:removeChildByTag(9527)
    end
    parent:addChild(node)
    Utils:createCDLabel(node,diffTime,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,CDTXTYPE.NONE,nil,nil,nil,26,function ()
        if diffTime <= 0 then
            -- 掠夺失败，合璧和次数不会扣除
            if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
                -- 拉取自己的国家的消息
                local function callBack(msg)
                    local judge = false
                    if tonumber(self.serverData.user.roomId) == tonumber(cell.roomId) then
                        judge = true
                    end
                    self.serverData.user = msg.user
                    self.serverData.rooms[tostring(cell.roomId)] = msg.rooms[tostring(cell.roomId)]
                    self:updateMyCountryCorner()
                    self:refreshSingleRoom(cell.roomId)
                    self:hideAllAdd()

                    -- 合璧成功显示弹窗
                    if judge == true then
                        CountryJadeMgr:showCountryJadeSuccessUI(1)
                        CountryJadeMgr.countryJadeSuccessShowStatus = true
                        UserData:getUserObj():setCountryJadeFinishTime(0)
                        UserData:getUserObj():addGlobalTime()
                    end
                    UserData:getUserObj().country_jade = self.serverData.user.mergeCount
                end
                CountryJadeMgr:getCountryJadeFromServer(callBack)
            else
                local function callBack(msg)
                    self.serverData.rooms[tostring(cell.roomId)] = msg.rooms[tostring(cell.roomId)]
                    self:refreshSingleRoom(cell.roomId)
                end
                CountryJadeMgr:getOtherCountryJadeFromServer(self.currCountry,cell.roomId,1,callBack) 
            end
        else
            self:timeoutCallback(cell,parent,time)
        end
    end,2)
end

function CountryJadeMainUI:shoutTimeoutCallback(cell,parent,labaImg,time)
    local diffTime = 0
    if time ~= 0 then
        diffTime = time - GlobalData:getServerTime()
    end
    local node = cc.Node:create()
    node:setTag(9527)        
    node:setPosition(cc.p(0,0))
    if parent:getChildByTag(9527) then
        parent:removeChildByTag(9527)
    end
    parent:addChild(node)
    Utils:createCDLabel(node,diffTime,cc.c3b(255,255,255),cc.c4b(0,0,0,255),CDTXTYPE.NONE,nil,nil,nil,18,function ()
        if diffTime <= 0 then
            self:shoutRefresh(cell,parent,labaImg)
        else
            self:shoutTimeoutCallback(cell,parent,labaImg,time)
        end
    end,2)
end

-- 隐藏加号
function CountryJadeMainUI:hideAllAdd()
    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        if self.serverData.user.roomId ~= 0 then   -- 在房间中
            for k,v in pairs(self.allAddImg) do
                local roomData = self.serverData.rooms[tostring(k)] 
                if tonumber(k) ~= tonumber(self.serverData.user.roomId) then
                    local leftPlayer = roomData.leftPlayer
                    if v[1] and leftPlayer.uid == 0 then
                        v[1]:setVisible(false)
                    end
                    local rightPlayer = roomData.rightPlayer
                    if v[2] and rightPlayer.uid == 0 then
                        v[2]:setVisible(false)
                    end
                end
            end
        elseif self:judgeIsHasJade() then   -- 没有玉璧了
            for i = 1,#self.cells do
                local cell = self.cells[i]
                if cell then
                    local roomData = self.serverData.rooms[tostring(cell.roomId)] 
                    local add = self.allAddImg[tonumber(cell.roomId)]
                    if roomData and add then
                        local leftPlayer = roomData.leftPlayer
                        if leftPlayer.uid == 0 then
                            add[1]:setVisible(false)
                        end
                        local rightPlayer = roomData.rightPlayer
                        if rightPlayer.uid == 0 then
                            add[2]:setVisible(false)
                        end
                    end
                end
            end

        end
    end
end

-- 先把加号显示出来
function CountryJadeMainUI:showAllAdd()
    if self.showType == COUNTRY_JADE_SHOW_TYPE.OWN then
        if self.serverData.user.roomId ~= 0 then   -- 在房间中
        elseif self:judgeIsHasJade() then   -- 没有玉璧了
        else
            for k,v in pairs(self.allAddImg) do
                v[1]:setVisible(v[1].lastVisible)
                v[2]:setVisible(v[2].lastVisible)
            end
        end
    end
end
----------------------------------------------------------- 数据 ------------------------------------------------------------------
-- 剩余合璧次数
function CountryJadeMainUI:getJadeRemainCount()
    local remainCount = CountryJadeMgr:getCountryJadeMergeCount() - self.serverData.user.mergeCount
    if remainCount < 0 then
        remainCount = 0
    end
    return remainCount
end

-- 判断今天是否可以领取玉璧
function CountryJadeMainUI:judgeTodayIsGetJade()
    local serverDay = tonumber(Time.getDayToModifiedServerDay())
    if self.serverData.user.jadeGetTime ~= 0 then   -- 不能领取
        return false
    else    -- 可以领取
        return true
    end
end

-- 判断玩家是否有玉璧
function CountryJadeMainUI:judgeIsHasJade()
    if tonumber(self.serverData.user.jade) == 0 then
        return true
    else
        return false
    end
end

-- 判断是否有战报
function CountryJadeMainUI:judgeIsHasReport()
    return self.serverData.user.hasNewReport
end

-- 设置已经看了战报
function CountryJadeMainUI:setHasReport()
    self.serverData.user.hasNewReport = false
end

function CountryJadeMainUI:updateAllRoomsData(rooms)
    self.serverData.rooms = rooms
end

-- 请求国家的时候单个房间数据,这个暂时没用
function CountryJadeMainUI:updateSingleRoomsDataByCountry(room)
    for k,v in pairs(self.serverData.rooms) do
        if v.id == room[k].id then
            self.serverData.rooms[k] = room[k]
            break
        end
    end
end

-- 请求国家以外的请求
function CountryJadeMainUI:updateSingleRoomsDataByOther(room)
    for k,v in pairs(self.serverData.rooms) do
        if v.id == room.id then
            self.serverData.rooms[k] = room
            break
        end
    end
end
----------------------------------------------------------- 数据 ------------------------------------------------------------------
-- 刷新单个房间
function CountryJadeMainUI:refreshSingleRoom(roomId)
    for i = 1,#self.cells do
        if self.cells[i].roomId == roomId then
            self:updateCell(self.cells[i])
            break
        end
    end
end

return CountryJadeMainUI