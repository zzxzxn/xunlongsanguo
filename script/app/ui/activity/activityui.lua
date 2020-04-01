local ActivityUI = class("ActivityUI", BaseUI)
local ActivityPayOnlyHelpUI = require("script/app/ui/activity/page_payonly_help")
local ActivityLimitGroupHelpUI = require("script/app/ui/activity/page_limitgroup_help")
local ActivityLuckyWheelHelpUI = require("script/app/ui/activity/page_luckywheel_help")

function ActivityUI:ctor(id)
    self.uiIndex = GAME_UI.UI_ACTIVITY
    self.datas = nil
    self.menus = {}

end
function ActivityUI:init()
    local root    =  self.root:getChildByName("root")
    local rootBG  =  ccui.Helper:seekWidgetByName(root,"bg")
    self.panelBg = rootBG:getChildByName('panel_bg')
    self.rootBG   =  rootBG
    self:adaptUI(root, rootBG)

    self.curBG      = ccui.Helper:seekWidgetByName(root,"cueBG")
    self.leftCue    = ccui.Helper:seekWidgetByName(self.curBG,"leftCue")
    self.rightCueBG = ccui.Helper:seekWidgetByName(self.curBG,"rightCueBG")
    self.remainImg = ccui.Helper:seekWidgetByName(self.curBG,"remain_img")
    self.rightCue   = ccui.Helper:seekWidgetByName(self.curBG,"rightCue")
    self.leftCue2   = ccui.Helper:seekWidgetByName(self.curBG,"leftcue2")
    self.leftCue3   = ccui.Helper:seekWidgetByName(self.curBG,"leftcue3")
    self.cue4   = ccui.Helper:seekWidgetByName(self.curBG,"cue4")
    self.refTime    = self.curBG:getChildByName("refTime")
    
    self.cue2Help = self.leftCue2:getChildByName('help')
    self.cue2Des = self.leftCue2:getChildByName('des')
    self.cue2Cash = self.leftCue2:getChildByName('cash')

    self.cue3Help = self.leftCue3:getChildByName('help')
    self.cue3Des = self.leftCue3:getChildByName('des')
    self.cue3Cash = self.leftCue3:getChildByName('cash')

    self.cue4Help = self.cue4:getChildByName('help')
    self.cue4Tx = self.cue4:getChildByName('tx')

    self.cue2Help:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local helpUI = ActivityPayOnlyHelpUI.new()
			helpUI:showUI()
        end
    end)

    self.cue3Help:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local helpUI = ActivityLimitGroupHelpUI.new()
			helpUI:showUI()
        end
    end)

    self.cue4Help:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(28)
        end
    end)

    self.recruitHelp = ccui.Helper:seekWidgetByName(self.curBG,"recruit_help")
    self.recruitHelp:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.lastSelectMenu.data.key == 'tavern_recruit_level' then
                HelpMgr:showHelpUI(HELP_SHOW_TYPE.TAVERN_RECRUIT)
            elseif self.lastSelectMenu.data.key == 'cloud_buy' then
                HelpMgr:showHelpUI(HELP_SHOW_TYPE.CLOUD_BUY)
			elseif self.lastSelectMenu.data.key == 'surprise_box' then
				HelpMgr:showHelpUI(44)
			elseif self.lastSelectMenu.data.key == 'buy_hot_free' then
				HelpMgr:showHelpUI(45)
			elseif self.lastSelectMenu.data.key == 'invincible_gold_will' then
				HelpMgr:showHelpUI(46)
            end
        end
    end)

	self.goldWillTx = ccui.Helper:seekWidgetByName(self.curBG,"gold_will_tx")
	self.goldWillTx:setString(GlobalApi:getLocalStr("ACTIVITY_GOLD_WILL_DESC_2"))

    self.surpriseStepHelp = ccui.Helper:seekWidgetByName(self.curBG,"surprise_step_help")
    self.surpriseStepHelp:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(33)
        end
    end)

	self.integralCarnival = ccui.Helper:seekWidgetByName(self.curBG,"integral_carnival")
	

    self.happyWheel = ccui.Helper:seekWidgetByName(self.curBG,"happy_wheel")
    
	self.surpriseTurnBg = ccui.Helper:seekWidgetByName(self.curBG,"surprise_turn_bg")
	self.christmasTree = ccui.Helper:seekWidgetByName(self.curBG,"christmas_tree")
    self.surpriseStepBuyImg = ccui.Helper:seekWidgetByName(self.curBG,"surprise_setp_buy_img")

    self.humanWingHelp = ccui.Helper:seekWidgetByName(self.curBG,"human_wing_help")
    self.humanWingHelp:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(36)
        end
    end)

    self.humanArmHelp = ccui.Helper:seekWidgetByName(self.curBG,"human_arm_help")
    self.humanArmHelp:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(37)
        end
    end)

    self.desc2 = ccui.Helper:seekWidgetByName(self.curBG,"desc2")
    self.desc2:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES30'))

    self.leftCue:setVisible(false)  
    self.rightCueBG:setVisible(false)   
    self.remainImg:setVisible(false)
    self.rightCue:setVisible(false)  
    self.leftCue2:setVisible(false)
    self.leftCue3:setVisible(false)
    self.cue4:setVisible(false)
    self.recruitHelp:setVisible(false)
    self.surpriseStepHelp:setVisible(false)
	self.goldWillTx:setVisible(false)
    self.surpriseStepBuyImg:setVisible(false)
    self.humanWingHelp:setVisible(false)
    self.humanArmHelp:setVisible(false)
    self.desc2:setVisible(false)
    self.happyWheel:setVisible(false)
	self.integralCarnival:setVisible(false)
	self.surpriseTurnBg:setVisible(false)
	self.christmasTree:setVisible(false)

    self.menuView = ccui.Helper:seekWidgetByName(root,"menuView")
    self.menuView:setScrollBarEnabled(false)
    self.tempCell = ccui.Helper:seekWidgetByName(root,"menuCell")
    self.tempCell:setVisible(false)

    self.pageContent = ccui.Helper:seekWidgetByName(root,"pageContent")
    self.pageWidth = self.pageContent:getContentSize().width
    self.pageHeight = self.pageContent:getContentSize().height

    self.panelBgHeight = self.panelBg:getContentSize().height

    self.closeBtn =  ccui.Helper:seekWidgetByName(rootBG,"closeBtn")

    self:registerTouchEvents()

end

function ActivityUI:showMenus(typeEnum)
    
    local sortedDatas = ActivityMgr:getDatasByType(typeEnum)
    if(sortedDatas ~= nil) then
        local numOfAdded = 0
        for key,data in pairs(sortedDatas) do
            print(data.commonConfigKey..":"..ActivityMgr:getActivityTime(data.commonConfigKey))
            local privilegeIsFinished = true
            if data.key == 'privilege' and UserData:getUserObj():judgePrivilegeActivityIsFinished() == true then
                privilegeIsFinished = false
            end

            local levelGiftIsFinished = true
            if data.key == 'levelgift' and UserData:getUserObj():judgeLevelGiftIsFinished() == true then
                levelGiftIsFinished = false
            end

            if(ActivityMgr:getActivityTime(data.commonConfigKey) ~= 0) and (ActivityMgr:getActivityTime(data.commonConfigKey) ~= -2) and data.key ~= 'limit_seckill' and data.key ~= 'roulette' and privilegeIsFinished and levelGiftIsFinished then
                local newCell = self.tempCell:clone()
                newCell:setAnchorPoint(cc.p(0.5, 0))
                newCell.titleBG = ccui.Helper:seekWidgetByName(newCell,"titlebg")
                newCell.titleTx = ccui.Helper:seekWidgetByName(newCell,"titletx")
                newCell.icon    = ccui.Helper:seekWidgetByName(newCell,"icon")
				newCell.mark	= ccui.Helper:seekWidgetByName(newCell,"mark")

                newCell.titleTx:setString(data.titleString)
                newCell.icon:loadTexture(data.iconNormal)
                if data.key == 'levelgift' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('levelgift')) --temp
                elseif data.key == 'sign' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('sign')) --temp
                elseif data.key == 'limit_buy' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('limit_buy')) --temp
                elseif data.key == 'petition' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('petition')) --temp

                elseif data.key == 'week' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('week')) --temp

                elseif data.key == 'value_package' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('value_package')) --temp

                elseif data.key == 'privilege' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('privilege')) --temp
                elseif data.key == 'todaydouble' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('todaydouble')) --temp
                elseif data.key == 'login_goodgift' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('login_goodgift')) --temp
                elseif data.key == 'limit_seckill' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('limit_seckill')) --temp
                elseif data.key == 'pay_only' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('pay_only')) --temp
                elseif data.key == 'limit_group' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('limit_group')) --temp
                elseif data.key == 'lucky_wheel' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('lucky_wheel')) --temp
                elseif data.key == 'grow_fund' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('grow_fund')) --temp
                elseif data.key == 'accumulate_recharge' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('accumulate_recharge')) --temp
                elseif data.key == 'daily_recharge' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('daily_recharge')) --temp
                elseif data.key == 'single_recharge' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('single_recharge')) --temp
                elseif data.key == 'expend_gift' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('expend_gift')) --temp
                elseif data.key == 'tavern_recruit' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('tavern_recruit')) --temp
                elseif data.key == 'exchange_points' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('exchange_points')) --temp
                elseif data.key == 'daily_cost' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('daily_cost')) --temp
                elseif data.key == 'tavern_recruit_level' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('tavern_recruit_level')) --temp
                elseif data.key == 'value_package_new' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('value_package_new')) --temp
                elseif data.key == 'day_challenge' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('day_challenge')) --temp
                elseif data.key == 'day_vouchsafe' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('day_vouchsafe')) --temp
                elseif data.key == 'promote_exchange' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('promote_exchange')) --temp
                elseif data.key == 'surprise_step' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('surprise_step')) --temp
                elseif data.key == 'human_wing' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('human_wing')) --temp
                elseif data.key == 'human_arms' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('human_arms')) --temp
                elseif data.key == 'happy_wheel' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('happy_wheel')) --temp
				elseif data.key == 'surprise_turn' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('surprise_turn')) --temp
				elseif data.key == 'christmas_tree' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('christmas_tree')) --temp
				elseif data.key == 'surprise_box' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('surprise_box')) --temp
				elseif data.key == 'buy_hot_free' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('buy_hot_free')) --temp
				elseif data.key == 'invincible_gold_will' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('invincible_gold_will')) --temp
				elseif data.key == 'integral_carnival' then
                    newCell.mark:setVisible(UserData:getUserObj():getSignByType('integral_carnival')) --temp
                else
                    newCell.mark:setVisible(false) --temp
                end
				
                newCell:setVisible(true)
				
                newCell.data = data
                self.menus[data.key] = newCell
                self.menuView:addChild(newCell)

                local function clickMenu(sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        newCell:stopAllActions()
                        newCell:runAction(cc.ScaleTo:create(0.1,0.9))
                    elseif eventType == ccui.TouchEventType.ended then
                        if(self.lastSelectMenu and self.lastSelectMenu.data.key == data.key) then   
                            return
                        end
                        newCell:stopAllActions()
                        newCell:runAction(cc.ScaleTo:create(0.1, 1))
                        
                        self:playEffect(sender)
                            
                        ActivityMgr:showActivityPage(data.key)
                        ActivityMgr:onPageHide(data.key)
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.canceled then
                        newCell:stopAllActions()
                        newCell:runAction(cc.ScaleTo:create(0.1, 1))
                    end
                end
                newCell:addTouchEventListener(clickMenu)
            end
        end
    end
    self.datas = sortedDatas
end

function ActivityUI:playEffect(img)
    if self.lvUp then
        self.lvUp:removeFromParent()
        self.lvUp = nil
    end
    
    local size = img:getContentSize()

    --[[
    local size1 = img:getContentSize()
    local lvUp = GlobalApi:createLittleLossyAniByName('ui_tongyonguangshu_01')
    lvUp:setPosition(cc.p(size.width/2 ,size.height/2))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img.icon:setLocalZOrder(101)
    img.titleBG:setLocalZOrder(102)
    img.titleTx:setLocalZOrder(103)
    img.mark:setLocalZOrder(104)
    --lvUp:setScale(1.2)
    img:addChild(lvUp)
    lvUp:getAnimation():playWithIndex(0, -1, 1)
    --]]

    local size1 = img:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(size.width/2 - 5 ,size.height/2 - 25))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img.icon:setLocalZOrder(101)
    img.titleBG:setLocalZOrder(102)
    img.titleTx:setLocalZOrder(103)
    img.mark:setLocalZOrder(104)
    --lvUp:setScale(0.6)
    img:addChild(lvUp)

    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)



    self.lvUp = lvUp


end

function ActivityUI:getMenusAndCloseBtn()
    return self.menus,self.closeBtn,self.cue4Help
end

function ActivityUI:getMenusAndCloseBtn2()
    return self.menus,self.closeBtn,self.surpriseStepHelp,self.surpriseStepBuyImg
end

function ActivityUI:showMark(activityName, isShow)
    for key,menu in pairs(self.menus) do
        if(key == activityName) then
            menu.mark:setVisible(isShow)
            break
        end
    end
end
function ActivityUI:hideTopCue()
    if self.leftCue then
        self.leftCue:setVisible(false) 
    end

    if self.rightCueBG then
        self.rightCueBG:setVisible(false) 
    end

    if self.remainImg then
        self.remainImg:setVisible(false) 
    end

    if self.rightCue then
        self.rightCue:setVisible(false)  
    end

    if self.refTime then
        self.refTime:removeAllChildren()
    end

    if self.leftCue2 then
        self.leftCue2:setVisible(false)
    end

    if self.leftCue3 then
        self.leftCue3:setVisible(false)
    end

    if self.cue4 then
        self.cue4:setVisible(false)
    end

    if self.recruitHelp then
        self.recruitHelp:setVisible(false)
    end

    if self.surpriseStepHelp then
        self.surpriseStepHelp:setVisible(false)
    end

	if self.goldWillTx then
        self.goldWillTx:setVisible(false)
    end
	
    if self.happyWheel then
        self.happyWheel:setVisible(false)
    end
    
	if self.integralCarnival then
		self.integralCarnival:setVisible(false)
	end

	if self.surpriseTurnBg then
		self.surpriseTurnBg:setVisible(false)
	end

	if self.christmasTree then
		self.christmasTree:setVisible(false)
	end

    if self.surpriseStepBuyImg then
        self.surpriseStepBuyImg:setVisible(false)
    end

    if self.humanWingHelp then
        self.humanWingHelp:setVisible(false)
    end

    if self.humanArmHelp then
        self.humanArmHelp:setVisible(false)
    end
    
    if self.desc2 then
        self.desc2:setVisible(false)
    end
    
end
function ActivityUI:selectMenu(activityName)
    local curSelectMenu = nil
    for key,menu in pairs(self.menus) do
        if(key == activityName) then
            menu.icon:loadTexture(menu.data.iconHighlight)
            menu.titleBG:loadTexture("uires/ui/activity/biaoti.png")
            menu.titleTx:setTextColor(cc.c4b(128,67,13, 255))
            curSelectMenu = menu

            self:playEffect(menu)

            break
        end
    end

    if(self.lastSelectMenu ~= nil) then
        local menu = self.lastSelectMenu
        menu.icon:loadTexture(menu.data.iconNormal)
        menu.titleBG:loadTexture("uires/ui/activity/biaoti2.png")
        menu.titleTx:setTextColor(cc.c4b(110,73,48,255))
    end

    self.lastSelectMenu = curSelectMenu
    
end
function ActivityUI:showLeftCue(text)
    self.leftCue:setVisible(true)
    self.leftCue:setString(text)
end
function ActivityUI:showRightCue(text)
    self.rightCueBG:setVisible(true)
    self.rightCue:setVisible(true)
    self.rightCue:setString(text)
end

function ActivityUI:showLeftPayOnlyCue()
    self.leftCue2:setVisible(true)
    self.cue2Des:setString(string.format(GlobalApi:getLocalStr('ACTIVE_PAY_ONLY_DES1'),UserData:getUserObj().activity.pay_only.paid or 0))
    self.cue2Cash:setPosition(cc.p(self.cue2Des:getPositionX() + self.cue2Des:getContentSize().width + 8,self.cue2Des:getPositionY()))
end

function ActivityUI:showLeftLimitGroupCue(num)
    self.leftCue3:setVisible(true)
    self.cue3Des:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LIMIT_GROUP_DES1'),num))
    self.cue3Cash:setPosition(cc.p(self.cue3Des:getPositionX() + self.cue3Des:getContentSize().width + 5,self.cue3Des:getPositionY()))
end

function ActivityUI:showLefTavernRecruitCue()
    self.recruitHelp:setVisible(true)
end

function ActivityUI:showLefSurpriseStepCue()
    self.surpriseStepHelp:setVisible(true)
    self.surpriseStepBuyImg:setVisible(true)
end

function ActivityUI:showLefGoldWillTx()
    self.goldWillTx:setVisible(true)
end

function ActivityUI:getLefHappyWheelCue()
    return self.happyWheel
end

function ActivityUI:getLefIntegralCarnival()
    return self.integralCarnival
end

function ActivityUI:getLefSurpriseTurnBgCue()
    return self.surpriseTurnBg
end

function ActivityUI:getLefChristmasTreeBgCue()
    return self.christmasTree
end

function ActivityUI:showLefHumanWingCue()
    self.humanWingHelp:setVisible(true)
end

function ActivityUI:showLefhumanArmCue()
    self.humanArmHelp:setVisible(true)
end

function ActivityUI:showLefSDesc2Cue()
    self.desc2:setVisible(true)
end

function ActivityUI:ShowRemainCount(count)
	self.refTime:removeAllChildren()
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(400, 28))
    richText:setAlignment('right')
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FREE_TIMES_1'), 21,COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re2 = xx.RichTextLabel:create(count, 21, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	richText:addElement(re1)
	richText:addElement(re2)
    richText:format(true)
    --richText:setAnchorPoint(cc.p(1,0.5))
    richText:setContentSize(richText:getElementsSize())

    local node = cc.Node:create()
    self.refTime:addChild(node)

    self.refTime:addChild(richText)
end

function ActivityUI:ShowRouletteRemainCount(count)
	self.refTime:removeAllChildren()
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(400, 28))
    richText:setAlignment('right')
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ROULETTE_RESET_TITLE'), 21,COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re2 = xx.RichTextLabel:create(count, 21, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	richText:addElement(re1)
	richText:addElement(re2)
    richText:format(true)
    --richText:setAnchorPoint(cc.p(1,0.5))
    richText:setContentSize(richText:getElementsSize())

    local node = cc.Node:create()
    self.refTime:addChild(node)

    self.refTime:addChild(richText)
end

function ActivityUI:showRightCueResetHour()
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local serverTime = GlobalData:getServerTime()
    local now = Time.date('*t', serverTime )
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local refTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0}) - Time.getCorrectServerTime()
    if(now.hour >= resetHour) then
        refTime = refTime + 24 * 3600
    end
    local node = cc.Node:create()
    self.refTime:addChild(node)

    Utils:createCDLabel(node,refTime,COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,CDTXTYPE.FRONT, GlobalApi:getLocalStr('REMAINDER_TIME'),COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,21)
        
end

function ActivityUI:showRightTodayDoubleRemainTime()
	self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)
    local time = ActivityMgr:getActivityTime("todaydouble")

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightLoginGoodGiftRemainTime()
    local time = ActivityMgr:getActivityTime("login_goodgift")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightAccumulateRechargeRemainTime()
    local time = ActivityMgr:getActivityTime("accumulate_recharge")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightDayVouchsafeRemainTime()
    local time = ActivityMgr:getActivityTime("day_vouchsafe")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSkyDropArmsRemainTime()
    local time = ActivityMgr:getActivityTime("sky_drop_arms")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSkyDropWingRemainTime()
    local time = ActivityMgr:getActivityTime("sky_drop_wing")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightDayVouchsafeRemainTime()
    local time = ActivityMgr:getActivityTime("day_vouchsafe")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightDayChallengeRemainTime()
    local _,time = ActivityMgr:getActivityTime("day_challenge")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSurpriseStepRemainTime()
    local time = ActivityMgr:getActivityTime("surprise_step")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightHumanWingRemainTime()
    local time = ActivityMgr:getActivityTime("human_wing")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightHumanArmsRemainTime()
    local time = ActivityMgr:getActivityTime("human_arms")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSaleNewRemainTime()
    local time = ActivityMgr:getActivityTime("value_package_new")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightDailyRechargeRemainTime()
    local time = ActivityMgr:getActivityTime("daily_recharge")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSurpriseTurnRemainTime()
    local time = ActivityMgr:getActivityTime("surprise_turn")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightChristmasTreeRemainTime()
    local time = ActivityMgr:getActivityTime("christmas_tree")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSurpriseBoxRemainTime()
    local time = ActivityMgr:getActivityTime("surprise_box")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightBuyHotFreeRemainTime()
    local time = ActivityMgr:getActivityTime("buy_hot_free")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightInvincibleGoldWillRemainTime()
    local time = ActivityMgr:getActivityTime("invincible_gold_will")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightIntegralCarnivalRemainTime()
    local time = ActivityMgr:getActivityTime("integral_carnival")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightDailyCostRemainTime()
    local time = ActivityMgr:getActivityTime("daily_cost")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightSingleRechargeRemainTime()
    local time = ActivityMgr:getActivityTime("single_recharge")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightTavernRecruitRemainTime()
    local time = ActivityMgr:getActivityTime("tavern_recruit")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end
    self:showRemainTime(time,node)
end

function ActivityUI:showRightTavernRecruitLevelRemainTime()
    local temp,time = ActivityMgr:getActivityTime("tavern_recruit_level")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end
function ActivityUI:showRightLimitSeckillRemainTime()
    local time = ActivityMgr:getActivityTime("limit_seckill")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightPromoteExchangeRemainTime()
    local time = ActivityMgr:getActivityTime("promote_exchange")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightExchangePointsRemainTime()
    local time = ActivityMgr:getActivityTime("exchange_points")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightLuckyWheelRemainTime()
    self.cue4:setVisible(true)
    self.remainImg:setVisible(true)
    local time = ActivityMgr:getActivityTime("lucky_wheel")
    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end
    self:showRemainTime(time,node)
end
-- 显示积分
function ActivityUI:showLuckyWheelCount(count)
    self.cue4Tx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES1'),count))
end

function ActivityUI:showRightHappyWheelRemainTime()
    local time = ActivityMgr:getActivityTime("happy_wheel")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end
    self:showRemainTime(time,node)
end

function ActivityUI:showHappyWheelCount(count)
    self.cue4Tx:setString(string.format(GlobalApi:getLocalStr('ACTIVE_HAPPY_DESC_1'),count))
end

function ActivityUI:showRightPayOnlyRemainTime()
    local time = ActivityMgr:getActivityTime("pay_only")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

function ActivityUI:showRightExpendGiftRemainTime()
    local time = ActivityMgr:getActivityTime("expend_gift")
    self.rightCueBG:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME2'),math.floor(time / (24 * 3600))) 
    Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,CDTXTYPE.FRONT,str,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,21)
end

function ActivityUI:showRightLimitGroupRemainTime()
    local time = ActivityMgr:getActivityTime("limit_group")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end

    self:showRemainTime(time,node)
end

-- 特效处理超值礼包显示
function ActivityUI:ShowRightCueResetHourBySale()
    
    local conf = GameData:getConfData('activities')['value_package']

    local nowTime = Time.getCorrectServerTime()

    local endTime = GlobalApi:convertTime(1,conf.endTime)
    local delayTime = conf.delayDays * 86400

    local refTime = endTime + delayTime - nowTime
    
    if refTime > 0 then
        self.rightCueBG:setVisible(true)
        self.remainImg:setVisible(true)
    else
        self.rightCueBG:setVisible(false)
        self.remainImg:setVisible(false)
    end

    local node = cc.Node:create()
    self.refTime:addChild(node)

    self:showRemainTime(refTime,node) 
end

function ActivityUI:showRightCueMonthResetHour()
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)
    local serverTime = GlobalData:getServerTime()
    local now = Time.date('*t', serverTime )
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local refTime = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0}) - Time.getCorrectServerTime()
    if(now.hour >= resetHour) then
        refTime = refTime + 24 * 3600
    end
    
    local node = cc.Node:create()
    self.refTime:addChild(node)
    local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),Time.getDayHaveInThisMonth()) 
    Utils:createCDLabel(node,refTime % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.BLACK,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,28)
    if Time.getDayHaveInThisMonth() < 10 then
        self.remainImg:setPositionX(self.refTime:getPositionX() - 50)
    else
        self.remainImg:setPositionX(self.refTime:getPositionX() - 70)
    end

end
function ActivityUI:ShowPetitionTime(args)
    local temp,time = ActivityMgr:getActivityTime("petition")
    self.rightCueBG:setVisible(true)
    self.remainImg:setVisible(true)

    local node = cc.Node:create()
    self.refTime:addChild(node)

    if time > 0 then
        node:setVisible(true)
    else
        node:setVisible(false)
    end


    self:showRemainTime(time,node)

end

function ActivityUI:showRemainTime(time,node)
    local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
    Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.BLACK,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,28)
    if math.floor(time / (24 * 3600)) < 10 then
        self.remainImg:setPositionX(self.refTime:getPositionX() - 50)
    else
        self.remainImg:setPositionX(self.refTime:getPositionX() - 70)
    end
end

function ActivityUI:showPage(pageUI,data,activityName)
    
    if(pageUI == nil or data == nil) then
        return
    end



    self.pageContent:addChild(pageUI)

    if(self.lastSelectMenu ~= nil and self.lastPage ~= nil) then
        if activityName == 'grow_fund' or activityName == 'exchange_points' or activityName == 'day_challenge' then
            self.pageContent:setContentSize(cc.size(self.pageWidth,self.panelBgHeight + 300))
        else
            self.pageContent:setContentSize(cc.size(self.pageWidth,self.pageHeight))
        end

        local lastPage = self.lastPage
        local moveDir = 0
        if(data.order < self.lastSelectMenu.data.order) then
              pageUI:setPositionX(-self.pageWidth) 
              moveDir = self.pageWidth 
        else
              pageUI:setPositionX(self.pageWidth) 
              moveDir = -self.pageWidth 
        end
         lastPage:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(moveDir,0)),cc.CallFunc:create(function ()
            self.pageContent:removeChild(lastPage)
            ActivityMgr:onPageHide()
        end)))
        pageUI:runAction(cc.MoveBy:create(0.3,cc.p(moveDir,0)))
    end

    self.lastPage = pageUI

    self:selectMenu(data.key)


end
function ActivityUI:ActionClose()
     --self.rootBG:runAction(cc.EaseQuadraticActionIn:create(cc.MoveBy:create(0.3, cc.p(-456,0))))
     --self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
        --end)))
end
function ActivityUI:registerTouchEvents()
    local function clickClose(sender, eventType)
       if eventType == ccui.TouchEventType.ended then
            ActivityMgr:hideUI()
            AudioMgr.PlayAudio(11)
       end
    end
    self.closeBtn:addTouchEventListener(clickClose)
end
return ActivityUI

