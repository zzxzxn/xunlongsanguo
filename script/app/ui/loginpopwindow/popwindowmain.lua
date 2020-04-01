local PopWindowMainUI = class("PopWindowMainUI", BaseUI)

local ClassPages = {}
ClassPages["open_seven"] = require('script/app/ui/loginpopwindow/popwindowopenseven')                               -- 七天乐
ClassPages["first_pay"] = require('script/app/ui/loginpopwindow/popwindowfirstrecharge')                            -- 首充礼包
ClassPages["daily_recharge"] = require('script/app/ui/loginpopwindow/popwindowdailyrecharge')                       -- 每日充值
ClassPages["single_recharge"] = require('script/app/ui/loginpopwindow/popwindowsinglerecharge')                     -- 单笔充值
ClassPages["exchange_points"] = require('script/app/ui/loginpopwindow/popwindowexchangepoints')                     -- 积分兑换
ClassPages["todaydouble"] = require('script/app/ui/loginpopwindow/popwindowtodaydouble')                            -- 今日双倍
ClassPages["tavern_recruit"] = require('script/app/ui/loginpopwindow/popwindowtavernrecruit')                       -- 酒馆招募限时
ClassPages["lucky_dragon"] = require('script/app/ui/loginpopwindow/popwindowlucky_dragon')                          -- 招财龙
ClassPages["tavern_recruit_level"] = require('script/app/ui/loginpopwindow/popwindowtavernrecruitlevel')            -- 酒馆招募等级

local NORMAL_IMG = 'uires/ui/popwindow/pop_dian2.png'
local PRESS_IMG = 'uires/ui/popwindow/pop_dian1.png'

function PopWindowMainUI:ctor(data)
    self.data = data
    if self.data[1].defaultKey == 'open_seven' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_OPEN_SEVEN
    elseif self.data[1].defaultKey == 'first_pay' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_FIRST_PAY
    elseif self.data[1].defaultKey == 'daily_recharge' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_DAILY_RECHARGE
    elseif self.data[1].defaultKey == 'single_recharge' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_SINGLE_RECHARGE
    elseif self.data[1].defaultKey == 'exchange_points' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_EXCHANGE_POINTS
    elseif self.data[1].defaultKey == 'todaydouble' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_TODAY_DOUBLE
    elseif self.data[1].defaultKey == 'tavern_recruit' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_TAVERN_RECRUIT
    elseif self.data[1].defaultKey == 'lucky_dragon' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_LUCKY_DRAGON
    elseif self.data[1].defaultKey == 'tavern_recruit_level' then
        self.uiIndex = GAME_UI.UI_POP_WINDOW_MAIN_TAVERN_RECRUIT_LEVEL
    end
end

function PopWindowMainUI:onShow()
	self.selectImg:setVisible(not LoginPopWindowMgr:getTodayVisible())
end

function PopWindowMainUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local closebtn = bgimg1:getChildByName('close')
    closebtn:setLocalZOrder(9999)
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.data[1].defaultKey == 'open_seven' then
                LoginPopWindowMgr:hidePopWindowOpenSevenUI()
            elseif self.data[1].defaultKey == 'first_pay' then
                LoginPopWindowMgr:hidePopWindowFirstPayUI()
            elseif self.data[1].defaultKey == 'daily_recharge' then
                LoginPopWindowMgr:hidePopWindowDailyRechargeUI()
            elseif self.data[1].defaultKey == 'single_recharge' then
                LoginPopWindowMgr:hidePopWindowSingleRechargeUI()
            elseif self.data[1].defaultKey == 'exchange_points' then
                LoginPopWindowMgr:hidePopWindowExchangePointsUI()
            elseif self.data[1].defaultKey == 'todaydouble' then
                LoginPopWindowMgr:hidePopWindowTodayDoubleUI()
            elseif self.data[1].defaultKey == 'tavern_recruit' then
                LoginPopWindowMgr:hidePopWindowTavernRecruitUI()
            elseif self.data[1].defaultKey == 'lucky_dragon' then
                LoginPopWindowMgr:hidePopWindowLuckyDragonUI()
            elseif self.data[1].defaultKey == 'tavern_recruit_level' then
                LoginPopWindowMgr:hidePopWindowTavernRecruitLevelUI()
            end
        end
    end)

    local dian = bgimg2:getChildByName('dian')
    dian:setVisible(false)

    local winSize = cc.Director:getInstance():getWinSize()
    closebtn:setPosition(cc.p(winSize.width,winSize.height))

    local pageView = ccui.PageView:create()
    pageView:setTouchEnabled(false)
    pageView:setContentSize(winSize)
    pageView:setTouchEnabled(true)
    pageView:setCustomScrollThreshold(60)
    pageView:setPosition(cc.p(0,0))
    bgimg2:addChild(pageView)

    for i = 1,#self.data do
        local page = ClassPages[self.data[i].defaultKey].new(self.data[i])
        local panel = page:getPanel()
        panel:setPosition(cc.p(winSize.width/2,winSize.height/2))
        pageView:insertPage(panel,i - 1)
    end

    local function pageViewEvent(sender, eventType)
        if eventType == ccui.PageViewEventType.turning then
            local index = pageView:getCurrentPageIndex()
            for i = 1,#self.chooseDian do
                if (i - 1) == index then
                    self.chooseDian[i]:loadTexture(PRESS_IMG)
                else
                    self.chooseDian[i]:loadTexture(NORMAL_IMG)
                end
            end
        end
    end 
    pageView:addEventListener(pageViewEvent)

    self.chooseDian = {}
    local offset = 20
    local width = dian:getContentSize().width
    local allWidth = #self.data*width + (#self.data - 1)*offset
    local initPosX = winSize.width/2 - allWidth/2 + width/2
    for i = 1,#self.data do
        local img = dian:clone()
        bgimg2:addChild(img)
        --img:setVisible(true)
        img:setPositionX(initPosX + (i - 1)*(offset + width/2))
        table.insert(self.chooseDian,img)
        if i == 1 then
            img:loadTexture(PRESS_IMG)
        else
            img:loadTexture(NORMAL_IMG)
        end
    end

    local selectImg = bgimg2:getChildByName('select_img')
    selectImg:setLocalZOrder(9001)
    selectImg:setVisible(not LoginPopWindowMgr:getTodayVisible())
    self.selectImg = selectImg

    local chooseBg = bgimg2:getChildByName('choose_bg')
    chooseBg:setLocalZOrder(9000)
    chooseBg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local updateDay = tonumber(Time.date('%Y%m%d',GlobalData:getServerTime()))
            if LoginPopWindowMgr:getTodayVisible() == true then
                LoginPopWindowMgr:setTodayVisible(updateDay)
            else
                LoginPopWindowMgr:setTodayVisible('')
            end
            selectImg:setVisible(not LoginPopWindowMgr:getTodayVisible())
        end
    end)

    local timeDesc = bgimg2:getChildByName('time_desc')
    timeDesc:setLocalZOrder(9002)
    timeDesc:setString(GlobalApi:getLocalStr('POP_WINDOW_DES19'))

    self:adaptUI(bgimg1, bgimg2)
end

return PopWindowMainUI