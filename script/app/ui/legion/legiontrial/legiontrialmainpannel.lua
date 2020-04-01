local LegionTrialMainPannelUI = class("LegionTrialMainPannelUI", BaseUI)

local CHOOSE_BTN_NORMAL = 'uires/ui/legion/legiontrial/legiontrial_ban6.png'
local CHOOSE_BTN_PRESS = 'uires/ui/legion/legiontrial/legiontrial_ban5.png'

local WENHAO_IMG = 'uires/ui/legion/legiontrial/legiontrial_wenhao.png'

local GUAIREN_IMG = 'uires/ui/legion/legiontrial/legiontrial_guairen2.png'
local SHANGREN_IMG = 'uires/ui/legion/legiontrial/legiontrial_shangren2.png'
local TOUMING_IMG = 'uires/ui/common/touming.png'

local MAXLOCAL_ZORDER = 10000
local ADVERNTRUE_ZORDER = 1

local BOX_IMG = 'uires/ui/legion/legiontrial/legiontrial_box17.png'

function LegionTrialMainPannelUI:ctor(serverData,index)
	self.uiIndex = GAME_UI.UI_LEGION_TRIAL_MAIN_PANNEL
    if serverData.trial.achievement == nil then
        serverData.trial.achievement = {}
    end
    self.trial = serverData.trial
    self.index = index
    self.adventure_rand = serverData.adventure_rand
    self:initData()

    UserData:getUserObj().legioninfo.trial = self.trial
end

function LegionTrialMainPannelUI:init()
    self.trialImg = self.root:getChildByName("legion_trial_bg_img")
    self:adaptUI(self.trialImg, self.trialImg)

    local closeBtn = self.trialImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            UserData:getUserObj().legioninfo.trial = self.trial
            LegionTrialMgr:hideLegionTrialMainPannelUI()
        end
    end)

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.bgPl = self.trialImg:getChildByName('bg_pl')
    self.bgPl:setScale(winSize.height / 768)

    self.zhong_1_ico = self.bgPl:getChildByName('zhong_1_img')
    self.zhong_2_ico = self.bgPl:getChildByName('zhong_2_img')
    
    -- role
    local animBg = self.trialImg:getChildByName('anim_bg')
    self.animBg = animBg
    local role = RoleData:getMainRole()
    local spineAni = GlobalApi:createLittleLossyAniByName(role:getUrl()..'_display', nil, role:getChangeEquipState())
    spineAni:setScale(0.7)
    spineAni:setPosition(cc.p(animBg:getContentSize().width/2,animBg:getContentSize().height/2))
    animBg:addChild(spineAni)
    self.spineAni = spineAni
    self.spineAni:getAnimation():play('idle', -1, 1)

    -- help
    local helpBtn = HelpMgr:getBtn(16)
    helpBtn:setPosition(cc.p(310 ,winSize.height - 30))
    self.trialImg:addChild(helpBtn)
    self.helpBtn = helpBtn

    self:initLeft()
    self:initBottom()
    self:initRight()
    self:refreshRightChoosePage(1,true)

    self:registerAction()
    self:adaptUI2()

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            if k == 1 then
                v.addImg:setVisible(false)    
            end
        end
    end

    self:refreshAdventureMark()
    self:refreshAchievementMark()

    if self.index then
        LegionTrialMgr:showLegionTrialAdventurePannelUI(self.trial,self.index)
    end
end

function LegionTrialMainPannelUI:adaptUI2()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = self.trialImg:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))

    local leftPlTop = self.trialImg:getChildByName("left_pl_top")
    leftPlTop:setPosition(cc.p(0,winSize.height - (640 - 570)))

    self.helpBtn:setAnchorPoint(cc.p(0,0))
    self.helpBtn:setPosition(cc.p(15,winSize.height - (640 - 570) + 5))

    local rightPlNode = self.trialImg:getChildByName("right_pl_node")
    rightPlNode:setLocalZOrder(100)

    rightPlNode:setPosition(cc.p(winSize.width,280))

    local bottomNode = self.trialImg:getChildByName("bottom_node")
    bottomNode:setPosition(cc.p(winSize.width - (960 - 568),53))

    local animBg = self.trialImg:getChildByName('anim_bg')
    animBg:setPosition(cc.p(212,218))

    self.initEndPos = cc.p(self.animBg:getPositionX() + 230,self.animBg:getPositionY())
    self.initStartPos = cc.p(self.animBg:getPositionX() + 800,self.animBg:getPositionY())

    self.initEndNotMovePos = cc.p(self.initEndPos.x - 100,self.initEndPos.y + 50)
    self.initStartNotMovePos = cc.p(self.initStartPos.x,self.initStartPos.y + 50)
end

function LegionTrialMainPannelUI:initData()
    self.adventureTime = 3
    self.bgMoveTime = 20

    self.curChoosePage = 1
    self.choosePageBtns = {}

    self.coins = {}
    self.legiontTialCoins = GameData:getConfData('legiontrialcoins')

    self.centerLineTypes = {}
    self.legionTrialCoinIncreaSetype = GameData:getConfData('legiontrialcoinincreasetype')

    self.legionTrialBaseConfig = GameData:getConfData('legiontrialbaseconfig')

    -- 下一个探索的页数和硬币id
    self.nextExplorePage = 1
    self.nextExploreCoinId = 1

    -- 开始探索部分
    self.isAuto = false     -- 默认不自动
    self.isExploreState = 0 -- 默认不探索，0：是没有探索，1：正在探索，2：停止探索过程中

    self.legionTrialAdventureType = 0 -- 遇到的冒险类型

    self.initEndPos = cc.p(0,0)
    self.initStartPos = cc.p(0,0)
    self.initEndNotMovePos = cc.p(0,0)
    self.initStartNotMovePos = cc.p(0,0)

    self.legionTrialAdventure = GameData:getConfData('legiontrialadventure')

    self.isDisableBtn = false
end

function LegionTrialMainPannelUI:calNextExploreData()
    local round = self.trial.round

    local judge = false
    for i = 1,3 do
        if judge == true then
            break
        end
        local coins = round[tostring(i)].coins
        for j = 1,9 do
            if judge == true then
                break
            end
            if coins[tostring(j)] == 0 then
                judge = true
                self.nextExplorePage = i
                self.nextExploreCoinId = j
            end
        end
    end
end

-------------------------------------------------- 动画逻辑部分 --------------------------------------------------
function LegionTrialMainPannelUI:registerAction()
    local function movementFun(armature, movementType, movementID)
        --0 开始
        --1 完成
        if movementType == 0 then
            if movementID == 'shengli' then
                self.zhong_1_ico:stopAllActions()
                self.zhong_2_ico:stopAllActions()
            end
        elseif movementType == 2 then
            if movementID == 'shengli' then
                self.zhong_1_ico:stopAllActions()
                self.zhong_2_ico:stopAllActions()
                self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
                    self:spineAniEnd()
                end)))
            end
        end
    end
    -- 关键帧事件
    local function frameFun(bone, frameEventName, originFrameIndex, currentFrameIndex)
        if frameEventName == "-1" then  -- skill结束事件
            self:spineAniEnd()
        end
    end
    self.spineAni:getAnimation():setMovementEventCallFunc(movementFun)
    self.spineAni:getAnimation():setFrameEventCallFunc(frameFun)
end

-- 主角spine结束
function LegionTrialMainPannelUI:spineAniEnd()
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
        self.spineAni:getAnimation():play('idle', -1, 1)
    end)))
end

function LegionTrialMainPannelUI:startOneRunAction()
    self:runBgAction()
    self.spineAni:getAnimation():play('run', -1, 1)

    local img = ccui.ImageView:create(BOX_IMG)
    img:setLocalZOrder(ADVERNTRUE_ZORDER)
    img:setAnchorPoint(cc.p(0.5,0.5))
    img:setPosition(self.initStartNotMovePos)
    self.trialImg:addChild(img)

    local size = self.zhong_1_ico:getContentSize()
    local timeTotal = 6
    local speed = size.width/timeTotal

    local act1 = cc.MoveTo:create((self.initStartNotMovePos.x - self.initEndNotMovePos.x)/speed, self.initEndNotMovePos)
    local act2 = cc.CallFunc:create(
        function ()
            self.zhong_1_ico:stopAllActions()
            self.zhong_2_ico:stopAllActions()
            self.spineAni:getAnimation():play('shengli', -1, 1)
        end
        )
    local act3 = cc.DelayTime:create(0.3 + 0.1)
	local act4 = cc.CallFunc:create(
		function ()
            img:removeFromParent()
            ----------------------------------------------------------------------------------
            local function callBack(data)
                self:oneExploreRefreshData(data)
                local serverCoins = data.coins

                local function callBackCoins()
                    local coin = serverCoins[1]
                    if coin then
                        local coins = self.trial.round[tostring(self.nextExplorePage)].coins
                        coins[tostring(self.nextExploreCoinId)] = coin
                        self:refreshStatus()

                        --local index = (self.nextExplorePage - 1) * 9 + self.nextExploreCoinId
                        --self:promptmgr(nil,self.adventure_rand[tostring(index)])

                        self:flyCoin(self.callBackCoins,true)
                        table.remove(serverCoins,1)
                        self.nextExploreCoinId = self.nextExploreCoinId + 1
                    else
                        self:exploreEnd()
                    end
                end
                self.callBackCoins = callBackCoins

                -- 烟雾特效
                self:getBombAnimation(callBackCoins)
            end
            LegionTrialMgr:legionTrialOneExploreFromServer(callBack)
            ----------------------------------------------------------------
        end
        )
	img:runAction(cc.Sequence:create(act1,act2,act3,act4))
end

function LegionTrialMainPannelUI:startRunAction()
    self:runBgAction()
    self.spineAni:getAnimation():play('run', -1, 1)

    if self.legionTrialAdventureType == 0 or self.legionTrialAdventureType == LEGION_TRIAL_ADVENTURE_TYPE.CASH then
        local img = ccui.ImageView:create(BOX_IMG)
        img:setLocalZOrder(ADVERNTRUE_ZORDER)
        img:setAnchorPoint(cc.p(0.5,0.5))
        img:setPosition(self.initStartNotMovePos)
        self.trialImg:addChild(img)

        local size = self.zhong_1_ico:getContentSize()
        local timeTotal = 6
        local speed = size.width/timeTotal

        local act1 = cc.MoveTo:create((self.initStartNotMovePos.x - self.initEndNotMovePos.x)/speed, self.initEndNotMovePos)
        local act2 = cc.CallFunc:create(
            function ()
                self.zhong_1_ico:stopAllActions()
                self.zhong_2_ico:stopAllActions()
                self.spineAni:getAnimation():play('shengli', -1, 1)
            end
            )
        local act3 = cc.DelayTime:create(0.3 + 0.1)
	    local act4 = cc.CallFunc:create(
		    function ()
                img:removeFromParent()
                ----------------------------------------------------------------------------------
                local function callBack(data)
                    self:exploreRefreshData(data)

                    local function callBack1()
                        local function callBack2()
                            self:exploreEnd()
                        end
                        self:flyCoin(callBack2)
                    end
                    -- 烟雾特效
                    self:getBombAnimation(callBack1)
                end
                LegionTrialMgr:legionTrialExploreFromServer(callBack)
                ----------------------------------------------------------------
            end
          	)
		    img:runAction(cc.Sequence:create(act1,act2,act3,act4))
    --[[if self.legionTrialAdventureType == 0 then
        local action1 = cc.DelayTime:create(self.adventureTime)
        local action2 = cc.CallFunc:create(function ()
            self.spineAni:getAnimation():play('shengli', -1, 1)
        end)
        self.spineAni:runAction(cc.Sequence:create(action1,action2))

    elseif self.legionTrialAdventureType == LEGION_TRIAL_ADVENTURE_TYPE.CASH then
        local action1 = cc.DelayTime:create(self.adventureTime)
        local action2 = cc.CallFunc:create(function ()
            self.spineAni:getAnimation():play('shengli', -1, 1)
        end)
        self.spineAni:runAction(cc.Sequence:create(action1,action2))
        --]]
    else
        local aniName = nil
        local spine = nil
        if self.legionTrialAdventureType == LEGION_TRIAL_ADVENTURE_TYPE.SHOP then
            spine = GlobalApi:createLittleLossyAniByName("xunyu_display")
            spine:getAnimation():play('idle', -1, 1)
            aniName = 'shengli'
        else
            spine = GlobalApi:createLittleLossyAniByName("luoshen_display")
            spine:getAnimation():play('idle', -1, 1)
            aniName = 'skill1'
        end

        spine:setScale(-0.6,0.6)
        spine:setPosition(self.initStartPos)
        self.trialImg:addChild(spine)
        spine:setLocalZOrder(ADVERNTRUE_ZORDER)
        
        local size = self.zhong_1_ico:getContentSize()
        local timeTotal = 6
        local speed = size.width/timeTotal

        local act1 = cc.MoveTo:create((self.initStartPos.x - self.initEndPos.x)/speed, self.initEndPos)
        local act2 = cc.CallFunc:create(
            function ()
                self.zhong_1_ico:stopAllActions()
                self.zhong_2_ico:stopAllActions()
                self.spineAni:getAnimation():play(aniName, -1, 1)
            end
            )
        local act3 = cc.DelayTime:create(0.3 + 0.1)
		local act4 = cc.CallFunc:create(
			function ()
                ----------------------------------------------------------------------------------
                local function callBack(data)
                    self:exploreRefreshData(data)

                    -- 飞到奇遇按钮的动画(粒子特效)
                    local aniImg = ccui.ImageView:create(TOUMING_IMG)
                    aniImg:setContentSize(cc.size(134,90))
                    aniImg:setScale9Enabled(true)
                    aniImg:setLocalZOrder(MAXLOCAL_ZORDER)
                    aniImg:setAnchorPoint(cc.p(0.5,0.5))
                    aniImg:setPosition(self.initEndNotMovePos)
                    self.trialImg:addChild(aniImg)

                    local size = aniImg:getContentSize()
                    local particle = cc.ParticleSystemQuad:create("particle/effect_fly.plist")
                    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                    particle:setPosition(cc.p(size.width/2, size.height/2))
                    aniImg:addChild(particle)

                    local size = self.adventrueBtn:getContentSize()
                    local desPos = self.adventrueBtn:convertToWorldSpace(cc.p(size.width/2, size.height/2))
                    local despos = self.trialImg:convertToNodeSpace(cc.p(desPos.x,desPos.y))

		            local aniAct1 = cc.DelayTime:create(0.1)
                    local aniAct2 = cc.Spawn:create(cc.MoveTo:create(0.5, desPos))
                    local aniAct3 = cc.DelayTime:create(0.1)
		            local aniAct4 = cc.CallFunc:create(
			            function ()
                            aniImg:removeFromParent()
                            spine:removeFromParent()

                            local function callBack1()
                                local function callBack2()
                                    self:exploreEnd()
                                end
                                self:flyCoin(callBack2)
                            end
                            -- 烟雾特效
                            self:getBombAnimation(callBack1)
			            end
		            )
		            aniImg:runAction(cc.Sequence:create(aniAct1, aniAct2, aniAct3,aniAct4))

                end

                LegionTrialMgr:legionTrialExploreFromServer(callBack)
                ----------------------------------------------------------------------------------
			end
		)
		spine:runAction(cc.Sequence:create(act1,act2,act3,act4))
    end
end

function LegionTrialMainPannelUI:stopAllAction()
    self.zhong_1_ico:stopAllActions()
    self.zhong_2_ico:stopAllActions()
    self.spineAni:stopAllActions()
    self.spineAni:getAnimation():play('idle', -1, 1)
end

function LegionTrialMainPannelUI:runBgAction()
    self:runBgAction1()
    self:runBgAction2()
end

-- 探索结束数据刷新
function LegionTrialMainPannelUI:exploreRefreshData(data)
    -- 刷新本地数据
    local coin = data.coin
    local adventure = data.adventure
    local achievement = data.achievement

    local coins = self.trial.round[tostring(self.nextExplorePage)].coins
    coins[tostring(self.nextExploreCoinId)] = coin
                    
    -- 有改变，就替换
    for k,v in pairs(achievement) do
        if self.trial.achievement[k] == nil then
            self.trial.achievement[k] = {}
            self.trial.achievement[k].award_got_level = 0
        end
        self.trial.achievement[k].progress = v.progress
    end
    self.trial.explore_count = self.trial.explore_count + 1

    local awardsData = nil
    for k,v in pairs(adventure) do
        self.trial.adventure[tostring(k)] = v
        if v.type == LEGION_TRIAL_ADVENTURE_TYPE.CASH then
            local awards = v.param1
		    if awards then
			    GlobalApi:parseAwardData(awards)
                awardsData = awards
                --GlobalApi:showAwardsCommonByText(awards,true)
		    end
        end
    end       
    self:promptmgr(awardsData)
    self:refreshStatus()
end

-- 一键探索结束数据刷新
function LegionTrialMainPannelUI:oneExploreRefreshData(data)
    -- 刷新本地数据
    local serverCoins = data.coins
    local adventure = data.adventure
    local achievement = data.achievement

    --local coins = self.trial.round[tostring(self.nextExplorePage)].coins
    --coins[tostring(self.nextExploreCoinId)] = serverCoins[1]
    
    -- 有改变，就替换
    for k,v in pairs(achievement) do
        if self.trial.achievement[k] == nil then
            self.trial.achievement[k] = {}
            self.trial.achievement[k].award_got_level = 0
        end
        self.trial.achievement[k].progress = v.progress
    end
    self.trial.explore_count = self.trial.explore_count + #serverCoins

    local awardsData = nil
    for k,v in pairs(adventure) do
        self.trial.adventure[tostring(k)] = v
        if v.type == LEGION_TRIAL_ADVENTURE_TYPE.CASH then
            local awards = v.param1
		    if awards then
			    GlobalApi:parseAwardData(awards)
                awardsData = awards
                --GlobalApi:showAwardsCommonByText(awards,true)
		    end
        end
    end       
    --self:promptmgr(awardsData)

    local showWidgets = {}
    for i = self.nextExploreCoinId,9 do
        local index = (self.nextExplorePage - 1) * 9 + i
        local aventureType = self.adventure_rand[tostring(index)]

        local desc = nil
        if aventureType <= 0 then
            desc = GlobalApi:getLocalStr('LEGION_TRIAL_DESC54')
        elseif aventureType == 3 then
            desc = self.legionTrialAdventure[aventureType].desc
        else
            desc = self.legionTrialAdventure[aventureType].desc
        end
        if desc then
            local w = cc.Label:createWithTTF(desc, 'font/gamefont.ttf', 24)
		    w:setTextColor(COLOR_TYPE.WHITE)
            if aventureType >= 1 then
                w:setTextColor(COLOR_TYPE.ORANGE)
            end
		    w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		    w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		    table.insert(showWidgets, w)
        end
    end
    promptmgr:showAttributeUpdate(showWidgets)

    self:refreshStatus()
end

function LegionTrialMainPannelUI:refreshStatus()
    UserData:getUserObj().legioninfo.trial = self.trial
    self:refreshAchievementMark()
    self:refreshAdventureMark()
end

function LegionTrialMainPannelUI:promptmgr(awards,aventureType)
    local legionTrialAdventureType = self.legionTrialAdventureType
    if aventureType then
        legionTrialAdventureType = aventureType
    end
    if legionTrialAdventureType <= 0 then
        if aventureType == nil then
            GlobalApi:timeOut(function()       
                local showWidgets = {}
		        local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('LEGION_TRIAL_DESC54'), 'font/gamefont.ttf', 24)
		        w:setTextColor(COLOR_TYPE.WHITE)
		        w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		        w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		        table.insert(showWidgets, w)
		        promptmgr:showAttributeUpdate(showWidgets)
            end,delay)
        end
    elseif legionTrialAdventureType == 3 then
        if aventureType then
            if awards then       
                GlobalApi:timeOut(function()       
                    local showWidgets = {}
		            local w = cc.Label:createWithTTF(self.legionTrialAdventure[legionTrialAdventureType].desc, 'font/gamefont.ttf', 24)
		            w:setTextColor(COLOR_TYPE.WHITE)
		            w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		            w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		            table.insert(showWidgets, w)
		            promptmgr:showAttributeUpdate(showWidgets)
                end,delay)
                GlobalApi:timeOut(function()       
                    GlobalApi:showAwardsCommonByText(awards,true)
                end,2)
            end
        else
            GlobalApi:timeOut(function()       
                local showWidgets = {}
		        local w = cc.Label:createWithTTF(self.legionTrialAdventure[legionTrialAdventureType].desc, 'font/gamefont.ttf', 24)
		        w:setTextColor(COLOR_TYPE.WHITE)
		        w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		        w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		        table.insert(showWidgets, w)
		        promptmgr:showAttributeUpdate(showWidgets)
            end,delay)
        end
    else
        GlobalApi:timeOut(function()       
            local showWidgets = {}
		    local w = cc.Label:createWithTTF(self.legionTrialAdventure[legionTrialAdventureType].desc, 'font/gamefont.ttf', 24)
		    w:setTextColor(COLOR_TYPE.WHITE)
		    w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		    w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		    table.insert(showWidgets, w)
		    promptmgr:showAttributeUpdate(showWidgets)
        end,delay)
    end
end

function LegionTrialMainPannelUI:runBgAction1()
    self.zhong_1_ico:stopAllActions()
    local size = self.zhong_1_ico:getContentSize()
    local endPoint = cc.p(0 - size.width,0)
    local timeTotal = 5
    local speed = size.width/timeTotal
    local time = 0.01

    local pos = cc.p(self.zhong_1_ico:getPositionX(),self.zhong_1_ico:getPositionY())
    local action = cc.MoveTo:create(math.abs(endPoint.x - pos.x)/speed,cc.p(endPoint.x,pos.y))
    local actionFun = cc.CallFunc:create(function () 
        local size = self.zhong_1_ico:getContentSize()
        local p = cc.p(self.zhong_2_ico:getPositionX(),self.zhong_2_ico:getPositionY())
        self.zhong_1_ico:setPosition(cc.p(p.x + size.width - time*timeTotal - 50,p.y))
        self.zhong_1_ico:stopAllActions()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
            self:runBgAction1()
        end)))
    end)
    self.zhong_1_ico:runAction(cc.Sequence:create(action,actionFun))
end

function LegionTrialMainPannelUI:runBgAction2()
    self.zhong_2_ico:stopAllActions()
    local size = self.zhong_1_ico:getContentSize()
    local endPoint = cc.p(0 - size.width,0)
    local timeTotal = 5
    local speed = size.width/timeTotal
    local time = 0.01

    local pos1 = cc.p(self.zhong_2_ico:getPositionX(),self.zhong_2_ico:getPositionY())
    local action1 = cc.MoveTo:create(math.abs(endPoint.x - pos1.x)/speed,cc.p(endPoint.x,pos1.y))
    local actionFun1 = cc.CallFunc:create(function ()
        local size = self.zhong_1_ico:getContentSize()
        local p = cc.p(self.zhong_1_ico:getPositionX(),self.zhong_1_ico:getPositionY())
        self.zhong_2_ico:setPosition(cc.p(p.x + size.width - time*timeTotal - 50,p.y))
        self.zhong_2_ico:stopAllActions()
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(time),cc.CallFunc:create(function ()
            self:runBgAction2()
        end)))
    end)

    self.zhong_2_ico:runAction(cc.Sequence:create(action1,actionFun1))
end

function LegionTrialMainPannelUI:getBombAnimation(callBack)
    local ani = GlobalApi:createLittleLossyAniByName("ui_paolong")
    ani:setName('ui_paolong')
    ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        if movementType == 1 then
            ani:removeFromParent()
            if callBack then
                callBack()
            end
        end
    end)
    ani:setLocalZOrder(MAXLOCAL_ZORDER)
    ani:setPosition(self.initEndNotMovePos)
    self.trialImg:addChild(ani)
    ani:getAnimation():playWithIndex(0, -1, 0)
    return ani
end

function LegionTrialMainPannelUI:flyCoin(callBack,isOneExplore)
     -- 硬币动画
    local coinFrame = self.coins[self.nextExploreCoinId]

    local coins = self.trial.round[tostring(self.nextExplorePage)].coins
    local coin = coins[tostring(self.nextExploreCoinId)]

    local coinFrameSprite = coinFrame:clone()
    local icon = coinFrameSprite:getChildByName("icon")
    local lightImg = coinFrameSprite:getChildByName("light_img")
    local selectImg = coinFrameSprite:getChildByName("select_img")
    lightImg:setVisible(true)
    icon:ignoreContentAdaptWithSize(true)
    selectImg:setVisible(false)
    icon:loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coin].icon)

    local size = coinFrameSprite:getContentSize()
    local desPos = coinFrame:convertToWorldSpace(cc.p(size.width/2, size.height/2))
    coinFrameSprite:setPosition(self.initEndNotMovePos)
    self.trialImg:addChild(coinFrameSprite,MAXLOCAL_ZORDER)

    if isOneExplore then
        local act1 = cc.DelayTime:create(0.2)
        local act2 = cc.CallFunc:create(
		    function ()
                if callBack then
                    callBack()
                end
		    end
	    )
        coinFrameSprite:runAction(cc.Sequence:create(act1,act2))

        local act2 = cc.MoveTo:create(0.3, desPos)
        local act3 = cc.ScaleTo:create(0.1, 1.1)
        local act4 = cc.ScaleTo:create(0.1, 0.8)
        local act4 = cc.FadeOut:create(0.1)
	    local act5 = cc.CallFunc:create(
		    function ()
                coinFrameSprite:removeFromParent()
                coinFrame:getChildByName('icon'):loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coin].icon)
		    end
	    )
	    coinFrameSprite:runAction(cc.Sequence:create(act2, act3,act4,act5))
    else
        local act1 = cc.DelayTime:create(0.5)
        local act2 = cc.MoveTo:create(0.3, desPos)
        local act3 = cc.ScaleTo:create(0.2, 1.1)
        local act4 = cc.ScaleTo:create(0.2, 0.8)
        local act4 = cc.FadeOut:create(0.2)
	    local act5 = cc.CallFunc:create(
		    function ()
                coinFrameSprite:removeFromParent()
                if callBack then
                    callBack()
                end
		    end
	    )
	    coinFrameSprite:runAction(cc.Sequence:create(act1, act2, act3,act4,act5))
    end
end

--  一次探索结束
function LegionTrialMainPannelUI:exploreEnd()
    -- 刷新显示
    self:refreshRightChoosePage(self.nextExplorePage,true)
    self:refreshLeftBottom()
    if self.isAuto == true and self.trial.explore_count < LegionTrialMgr:getLegionTrialAllEcploreCount() then
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function ()
            self:startExplore()
        end)))
    else
        self.isExploreState = 0
        self:refreshleftBottomExploreShowStatus()
        self:openBtn()
    end
end

-------------------------------------------------- 动画逻辑部分 --------------------------------------------------
function LegionTrialMainPannelUI:initLeft()
    local leftPlTop = self.trialImg:getChildByName("left_pl_top")

    -- 奇遇
    local adventrueBtn = leftPlTop:getChildByName('adventrue_btn')
    adventrueBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.isDisableBtn then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC53'), COLOR_TYPE.RED)
                return
            end
            LegionTrialMgr:showLegionTrialAdventurePannelUI(self.trial)
        end
    end)
    self.adventrueBtn = adventrueBtn

    -- 成就
    local achievementBtn = leftPlTop:getChildByName('achievement_btn')
    self.achievementBtn = achievementBtn
    achievementBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.isDisableBtn then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC53'), COLOR_TYPE.RED)
                return
            end
            local function callBack(achievement)
                self.trial.achievement = achievement
                self:refreshStatus()
            end
            LegionTrialMgr:showLegionTrialAchievementPannelUI(self.trial,callBack)
        end
    end)

    -- 兑换
    local exchangeBtn = leftPlTop:getChildByName('exchange_btn')
    self.exchangeBtn = exchangeBtn
    exchangeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.isDisableBtn then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC53'), COLOR_TYPE.RED)
                return
            end
            MainSceneMgr:showShop(54,{min = 51,max = 54})
        end
    end)
end

function LegionTrialMainPannelUI:onShow()
    self:refreshAdventureMark()
    self:refreshAchievementMark()
end

function LegionTrialMainPannelUI:refreshAdventureMark()
    local mark = self.adventrueBtn:getChildByName('mark')
    mark:setVisible(UserData:getUserObj():getLegionTrialAdventureShowStatus())
end

function LegionTrialMainPannelUI:refreshAchievementMark()
    local mark = self.achievementBtn:getChildByName('mark')
    mark:setVisible(UserData:getUserObj():getLegionTrialAchievementShowStatus())
end

function LegionTrialMainPannelUI:initBottom()
    local bottomNode = self.trialImg:getChildByName("bottom_node")

    -- 探索
    local chooseImg = bottomNode:getChildByName('choose_img')
    self.chooseImg = chooseImg
    self.chooseImg:setVisible(false)

    -- 探索一次
    local exploreBtn = bottomNode:getChildByName('explore_btn')
    self.exploreBtn = exploreBtn
    exploreBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:startExplore()
        end
    end)
    local exploreBtnTx = exploreBtn:getChildByName('text')
    exploreBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC1'))

    -- 自动探索
    local autoExploreBtn = bottomNode:getChildByName('auto_explore_btn')
    self.autoExploreBtn = autoExploreBtn
    autoExploreBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:startExplore()
        end
    end)
    local autoExploreBtnTx = autoExploreBtn:getChildByName('text')
    autoExploreBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC29'))

    -- 一键探索
    local oneExploreBtn = bottomNode:getChildByName('one_explore_btn')
    self.oneExploreBtn = oneExploreBtn
    oneExploreBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:startOneExplore()
        end
    end)
    local oneExploreBtnTx = oneExploreBtn:getChildByName('text')
    oneExploreBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC56'))

    local stop_text1 = oneExploreBtn:getChildByName('stop_text1')
    local stop_ani1 = oneExploreBtn:getChildByName('stop_ani1')
    local stop_ani2 = oneExploreBtn:getChildByName('stop_ani2')
    local stop_ani3 = oneExploreBtn:getChildByName('stop_ani3')
    stop_text1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC55'))
    stop_ani1:setString('.')
    stop_ani2:setString('.')
    stop_ani3:setString('.')

    -- 停止探索
    local stopExploreBtn = bottomNode:getChildByName('stop_explore_btn')
    self.stopExploreBtn = stopExploreBtn
    local stopExploreBtnTx = stopExploreBtn:getChildByName('text')
    stopExploreBtnTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC30'))

    local stop_text1 = stopExploreBtn:getChildByName('stop_text1')
    local stop_ani1 = stopExploreBtn:getChildByName('stop_ani1')
    local stop_ani2 = stopExploreBtn:getChildByName('stop_ani2')
    local stop_ani3 = stopExploreBtn:getChildByName('stop_ani3')
    stop_text1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC55'))
    stop_ani1:setString('.')
    stop_ani2:setString('.')
    stop_ani3:setString('.')

    -- 选择框按钮
    local chooseBtn = bottomNode:getChildByName('choose_btn')
    self.chooseBtn = chooseBtn
    self.chooseBtn:setVisible(false)
    chooseBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.isAuto == false then
                self.isAuto = true
            else
                self.isAuto = false
            end
            self:refreshleftBottomExploreShowStatus()
        end
    end)

    local exploreDesc = bottomNode:getChildByName('explore_desc')
    self.exploreDesc = exploreDesc
    exploreDesc:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC2'))
    self.exploreDesc:setVisible(false)
    --
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC14'), 26, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create('', 26,COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_TRIAL_DESC15'), 26,COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(exploreBtn:getPositionX(),exploreBtn:getPositionY() + 50))
    richText:format(true)
    bottomNode:addChild(richText)

    richText.re1 = re1
    richText.re2 = re2
    richText.re3 = re3
    self.leftBottomRichText = richText

    self:refreshLeftBottom()
    self:refreshleftBottomExploreShowStatus()
end

function LegionTrialMainPannelUI:disableBtn()
    self.isDisableBtn = true
    --[[
    for i = 1,#self.choosePageBtns do
        self.choosePageBtns[i]:setTouchEnabled(false)
    end

    self.adventrueBtn:setTouchEnabled(false)
    self.achievementBtn:setTouchEnabled(false)
    self.exchangeBtn:setTouchEnabled(false)

    for i = 1,9 do
        local coin = self.coins[i]
        coin:setTouchEnabled(false)
    end
    --]]

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(false)
            v.addImg:setTouchEnabled(false)    
        end
    end
end

function LegionTrialMainPannelUI:openBtn()
    self.isDisableBtn = false
    for i = 1,#self.choosePageBtns do
        self.choosePageBtns[i]:setTouchEnabled(true)
    end

    self.adventrueBtn:setTouchEnabled(true)
    self.achievementBtn:setTouchEnabled(true)
    self.exchangeBtn:setTouchEnabled(true)

    for i = 1,9 do
        local coin = self.coins[i]
        coin:setTouchEnabled(true)
    end

    local szTabs = UIManager:getSidebar():getSzTabs()
    if szTabs then
        for k,v in pairs(szTabs) do
            v.bgImg:setTouchEnabled(true)
            v.addImg:setTouchEnabled(true)
        end
    end
end

function LegionTrialMainPannelUI:startOneExplore()
    if self.trial.explore_count >= LegionTrialMgr:getLegionTrialAllEcploreCount() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC13'), COLOR_TYPE.RED)
        return
    end

    local exploreBtn = self.exploreBtn
    exploreBtn:setTouchEnabled(false)
    ShaderMgr:setGrayForWidget(exploreBtn)
    local exploreBtnTx = exploreBtn:getChildByName('text')
    exploreBtnTx:setColor(COLOR_TYPE.GRAY)
    exploreBtnTx:enableOutline(COLOR_TYPE.BLACK)

    local oneExploreBtn = self.oneExploreBtn
    oneExploreBtn:setTouchEnabled(false)
    ShaderMgr:setGrayForWidget(oneExploreBtn)
    local oneExploreBtnTx = oneExploreBtn:getChildByName('text')
    local stop_text1 = oneExploreBtn:getChildByName('stop_text1')
    local stop_ani1 = oneExploreBtn:getChildByName('stop_ani1')
    local stop_ani2 = oneExploreBtn:getChildByName('stop_ani2')
    local stop_ani3 = oneExploreBtn:getChildByName('stop_ani3')
    stop_text1:setVisible(true)
    stop_ani1:setVisible(true)
    stop_ani2:setVisible(true)
    stop_ani3:setVisible(true)
    oneExploreBtnTx:setVisible(false)
    self.stopIndex = 0
    self:stopAnimal(oneExploreBtn)

    self:disableBtn()
    self:calNextExploreData()
    -- 刷新到要得到硬币的标签页
    self:refreshRightChoosePage(self.nextExplorePage)
    self.legionTrialAdventureType = 0

    self:startOneRunAction()
end

function LegionTrialMainPannelUI:startExplore()
    if self.trial.explore_count >= LegionTrialMgr:getLegionTrialAllEcploreCount() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC13'), COLOR_TYPE.RED)
        return
    end
    self:disableBtn()

    self:calNextExploreData()
    -- 刷新到要得到硬币的标签页
    self:refreshRightChoosePage(self.nextExplorePage)
    local index = (self.nextExplorePage - 1) * 9 + self.nextExploreCoinId
    self.legionTrialAdventureType = self.adventure_rand[tostring(index)]

    self:startRunAction()
    self.isExploreState = 1
    self:refreshleftBottomExploreShowStatus()
end

function LegionTrialMainPannelUI:refreshLeftBottom()
    local showCount = LegionTrialMgr:getLegionTrialAllEcploreCount() - self.trial.explore_count
    if showCount <= 0 then
        showCount = 0
    end
    self.leftBottomRichText.re2:setString(showCount)
    self.leftBottomRichText:format(true)
end

-- 刷新探索状态显示
function LegionTrialMainPannelUI:refreshleftBottomExploreShowStatus()
    local exploreBtn = self.exploreBtn
    local autoExploreBtn = self.autoExploreBtn
    local stopExploreBtn = self.stopExploreBtn
    local stopExploreBtnTx = stopExploreBtn:getChildByName('text')
    stopExploreBtn:stopAllActions()

    local oneExploreBtn = self.oneExploreBtn
    oneExploreBtn:stopAllActions()
    local oneExploreBtnTx = oneExploreBtn:getChildByName('text')
    oneExploreBtnTx:setColor(COLOR_TYPE.GRAY)
    oneExploreBtnTx:enableOutline(COLOR_TYPE.BLACK)
    local stop_text1 = oneExploreBtn:getChildByName('stop_text1')
    local stop_ani1 = oneExploreBtn:getChildByName('stop_ani1')
    local stop_ani2 = oneExploreBtn:getChildByName('stop_ani2')
    local stop_ani3 = oneExploreBtn:getChildByName('stop_ani3')
    stop_text1:setVisible(false)
    stop_ani1:setVisible(false)
    stop_ani2:setVisible(false)
    stop_ani3:setVisible(false)
    oneExploreBtnTx:setVisible(true)

    local chooseBtn = self.chooseBtn
    local chooseImg = self.chooseImg
    local exploreDesc = self.exploreDesc

    chooseBtn:setTouchEnabled(true) 
    stopExploreBtn:setTouchEnabled(false)

    local stop_text1 = stopExploreBtn:getChildByName('stop_text1')
    local stop_ani1 = stopExploreBtn:getChildByName('stop_ani1')
    local stop_ani2 = stopExploreBtn:getChildByName('stop_ani2')
    local stop_ani3 = stopExploreBtn:getChildByName('stop_ani3')
    stop_text1:setVisible(false)
    stop_ani1:setVisible(false)
    stop_ani2:setVisible(false)
    stop_ani3:setVisible(false)
    stopExploreBtnTx:setVisible(true)
    self.stopIndex = 0

    ShaderMgr:restoreWidgetDefaultShader(stopExploreBtn)
    --stopExploreBtnTx:setColor(COLOR_TYPE.WHITE)
    --stopExploreBtnTx:enableOutline(cc.c4b(165, 70, 0, 255), 1)

    ShaderMgr:restoreWidgetDefaultShader(exploreBtn)
    exploreBtn:setTouchEnabled(true)
    local exploreBtnTx = exploreBtn:getChildByName('text')
    exploreBtnTx:setColor(COLOR_TYPE.WHITE)
    exploreBtnTx:enableOutline(cc.c4b(165, 70, 0, 255), 2)
    exploreBtnTx:enableShadow(COLOR_TYPE.WHITE,cc.size(0, 0))

    local judge = false
    if self.isExploreState == 0 then    -- 没探索
        if self.isAuto == true then     -- 自动探索
            autoExploreBtn:setVisible(true)
            exploreBtn:setVisible(false)
        else
            autoExploreBtn:setVisible(false)
            exploreBtn:setVisible(true)
        end
        stopExploreBtn:setVisible(false)

        chooseBtn:setVisible(true)
        chooseImg:setVisible(true)
        exploreDesc:setVisible(true)
        chooseImg:setVisible(self.isAuto)

        oneExploreBtn:setTouchEnabled(true)
        ShaderMgr:restoreWidgetDefaultShader(oneExploreBtn)
        oneExploreBtnTx:setColor(COLOR_TYPE.WHITE)
        oneExploreBtnTx:enableOutline(cc.c4b(165, 70, 0, 255), 2)
        oneExploreBtnTx:enableShadow(COLOR_TYPE.WHITE,cc.size(0, 0))
    elseif self.isExploreState == 1 then    -- 正在探索
        if self.isAuto == true then         -- 自动探索
            chooseBtn:setTouchEnabled(false)       
            chooseBtn:setVisible(true)
            chooseImg:setVisible(true)
            exploreDesc:setVisible(true)
            chooseImg:setVisible(self.isAuto)
            stopExploreBtn:setVisible(true)
        else    -- 探索1次
            chooseBtn:setVisible(false)
            chooseImg:setVisible(false)
            exploreDesc:setVisible(false)

            chooseBtn:setTouchEnabled(true)
            stopExploreBtn:setVisible(true)
            stopExploreBtn:setTouchEnabled(false)   -- 先暂时设置成这个
            ShaderMgr:setGrayForWidget(stopExploreBtn)
            --stopExploreBtnTx:setColor(COLOR_TYPE.GRAY)
            --stopExploreBtnTx:enableOutline(COLOR_TYPE.BLACK)
            judge = true
        end
        exploreBtn:setVisible(false)
        autoExploreBtn:setVisible(false)

        oneExploreBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(oneExploreBtn)
    else    -- 停止探索过程中(只有自动探索才会触发)
        chooseBtn:setVisible(false)
        chooseImg:setVisible(false)
        exploreDesc:setVisible(false)

        exploreBtn:setVisible(false)
        autoExploreBtn:setVisible(false)
        stopExploreBtn:setVisible(true)
        stopExploreBtn:setTouchEnabled(false)   -- 先暂时设置成这个

        ShaderMgr:setGrayForWidget(stopExploreBtn)
        --stopExploreBtnTx:setColor(COLOR_TYPE.GRAY)
        --stopExploreBtnTx:enableOutline(COLOR_TYPE.BLACK)
        judge = true

        oneExploreBtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(oneExploreBtn)
    end

    stopExploreBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if judge == true then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC51'), COLOR_TYPE.RED)
                return
            end
            self.isExploreState = 3
            self.isAuto = false
            self:refreshleftBottomExploreShowStatus()
        end
    end)
    if judge == false then
        stopExploreBtn:setTouchEnabled(true)
    else
        stop_text1:setVisible(true)
        stopExploreBtnTx:setVisible(false)
        -- 动画
        self:stopAnimal(stopExploreBtn)
    end

    self.chooseBtn:setVisible(false)
    self.exploreDesc:setVisible(false)
    self.chooseImg:setVisible(false)
end

function LegionTrialMainPannelUI:stopAnimal(node)
    self.stopIndex = self.stopIndex + 1
    if self.stopIndex > 3 then
        self.stopIndex = 1
    end

    local action1 = cc.DelayTime:create(0.1)
    local action2 = cc.CallFunc:create(function ()
        for i = 1,3 do
            local aniText = node:getChildByName('stop_ani' .. i)
            if i <= self.stopIndex then
                aniText:setVisible(true)
            else
                aniText:setVisible(false)
            end
        end
    end)
    local action3 = cc.DelayTime:create(0.1)
    local action4 = cc.CallFunc:create(function ()
        self:stopAnimal(node)
    end)
    node:runAction(cc.Sequence:create(action1,action2,action3,action4))
end

function LegionTrialMainPannelUI:initRight()
    local rightPlNode = self.trialImg:getChildByName("right_pl_node")
    --
    for i = 1,3 do
        local chooseBtn = rightPlNode:getChildByName("choose" .. i .."_btn")
        local tx = chooseBtn:getChildByName('tx')
        chooseBtn.tx = tx
        if i == 1 then
            tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC3'))
        elseif i == 2 then
            tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC4'))
        else
            tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC5'))
        end
        table.insert(self.choosePageBtns,chooseBtn)

        chooseBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.isDisableBtn then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC53'), COLOR_TYPE.RED)
                    return
                end
                self:refreshRightChoosePage(i)
            end
        end)
    end

    -- 顶部
    local cloneImg = rightPlNode:getChildByName("clone_img")
    for i = 1,9 do
        local coin = cloneImg:getChildByName("coin_" .. i)
        coin.id = i
        local lightImg = coin:getChildByName("light_img")
        local icon = coin:getChildByName("icon")
        icon:ignoreContentAdaptWithSize(true)

        local selectImg = coin:getChildByName("select_img")

        coin.lightImg = lightImg
        coin.icon = icon
        coin.selectImg = selectImg
        table.insert(self.coins,coin)
    end

    -- 中部
    local cloneCenterImg = rightPlNode:getChildByName("clone_center_img")
    for i = 1,3 do
        local centerLineType = cloneCenterImg:getChildByName("center_line_type" .. i)
        local rateTx = centerLineType:getChildByName("rate_tx")
        centerLineType.rateTx = rateTx
        table.insert(self.centerLineTypes,centerLineType)
    end

    self.checkBtn = cloneCenterImg:getChildByName("check_btn")
    self.checkBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:showLegionTrialAddRatePannelUI()
        end
    end)

    self.noRateAddTx = cloneCenterImg:getChildByName("no_rate_add_tx")
    self.noRateAddTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC6'))

    -- 底部
    local bottomImg = rightPlNode:getChildByName("bottom_img")
    local rewardRateDes1 = bottomImg:getChildByName("reward_rate_des1")
    rewardRateDes1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC8'))

    local rewardDes2 = bottomImg:getChildByName("reward_des2")
    rewardDes2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC9'))

    local reward_img = bottomImg:getChildByName("reward_img")
    
    local getBtn = bottomImg:getChildByName("get_btn")
    self.getBtn = getBtn

    --
    local richText1 = xx.RichText:create()
	richText1:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create('', 23, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create('', 23,COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText1:addElement(re1)
	richText1:addElement(re2)

    richText1:setAlignment('left')
    richText1:setVerticalAlignment('middle')

	richText1:setAnchorPoint(cc.p(0,0.5))
	richText1:setPosition(cc.p(rewardRateDes1:getPositionX() + 5,rewardRateDes1:getPositionY() - 5))
    richText1:format(true)
    bottomImg:addChild(richText1)

    richText1.re1 = re1
    richText1.re2 = re2
    self.bottomRichTextAddTx1 = richText1

    --
    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create('', 23, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create('', 23,COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText2:addElement(re1)
	richText2:addElement(re2)

    richText2:setAlignment('left')
    richText2:setVerticalAlignment('middle')

	richText2:setAnchorPoint(cc.p(0,0.5))
	richText2:setPosition(cc.p(reward_img:getPositionX() + 5,reward_img:getPositionY() - 5))
    richText2:format(true)
    bottomImg:addChild(richText2)

    richText2.re1 = re1
    richText2.re2 = re2
    self.bottomRichTextAddTx2 = richText2

    --
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

	local re1 = xx.RichTextLabel:create('', 23, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create('', 23,COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create('', 23,COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(getBtn:getPositionX(),getBtn:getPositionY() - 5))
    richText:format(true)
    bottomImg:addChild(richText)

    richText.re1 = re1
    richText.re2 = re2
    richText.re3 = re3
    self.bottomRichText = richText
end

function LegionTrialMainPannelUI:refreshRightChoosePage(i,isForce)
    if i == self.curChoosePage and not isForce then
        return
    end
    self.curChoosePage = i
    for i = 1,3 do
        local btn = self.choosePageBtns[i]
        local tx = btn.tx
        if i == self.curChoosePage then
            btn:loadTexture(CHOOSE_BTN_PRESS)
            tx:setColor(cc.c4b(255, 247, 229, 255))

            self:refreshRightCoinsShowStatus()
            self:refreshRightRemain()
        else
            btn:loadTexture(CHOOSE_BTN_NORMAL)
            tx:setColor(cc.c4b(207, 186, 141, 255))
        end
    end
end

function LegionTrialMainPannelUI:refreshRightCoinsShowStatus()
    local round = self.trial.round
    local coins = round[tostring(self.curChoosePage)].coins

    for i = 1,9,1 do
        local coinId = coins[tostring(i)]
        local coin = self.coins[i]
        local lightImg = coin.lightImg
        local icon = coin.icon
        local selectImg = coin.selectImg

        selectImg:setVisible(false)
        lightImg:setVisible(false)
        if coinId == 0 then
            icon:loadTexture(WENHAO_IMG)
        else
            icon:loadTexture('uires/icon/legiontrial/'.. self.legiontTialCoins[coinId].icon)
        end
    end
    self:refreshRightCoinsBlinks()
end

function LegionTrialMainPannelUI:refreshRightCoinsBlinks()
    self.coins[1]:stopAllActions()
    local round = self.trial.round
    local coins = round[tostring(self.curChoosePage)].coins

    local ids = {}
    for i = 1,9 do
        if coins[tostring(i)] > 0 then
            table.insert(ids,coins[tostring(i)])
        end
    end

    local temp1,temp2 = LegionTrialMgr:getLegionTrialBlink(ids)
    if #temp2 > 0 then
        self:blinkArrays(1,temp2)
    end
end

function LegionTrialMainPannelUI:blinkArrays(index,temp)
    local allNum = #temp
    if index > allNum then
        index = 1
    end

    local blinkAnimals = temp[index]
    local action1 = cc.DelayTime:create(0.3)
    local action2 = cc.CallFunc:create(function ()
        for i = 1,#blinkAnimals do
            local pos = blinkAnimals[i]
            local coinFrame = self.coins[pos]
            local lightImg = coinFrame.lightImg
            lightImg:setVisible(true)
        end
    end)
    local action3 = cc.DelayTime:create(0.3)
    local action4 = cc.CallFunc:create(function ()
        for i = 1,#blinkAnimals do
            local pos = blinkAnimals[i]
            local coinFrame = self.coins[pos]
            local lightImg = coinFrame.lightImg
            lightImg:setVisible(false)
        end
        self:blinkArrays(index + 1,temp)
    end)
    self.coins[1]:runAction(cc.Sequence:create(action1,action2,action3,action4))
end

function LegionTrialMainPannelUI:refreshRightRemain()
    -- 中间
    local round = self.trial.round
    local coins = round[tostring(self.curChoosePage)].coins
    local temp = {}
    local hasGetNum = 0
    for i = 1,9 do
        temp[i] = coins[tostring(i)]
        if temp[i] > 0 then
            hasGetNum = hasGetNum + 1
        end
    end

    local rates = LegionTrialMgr:getLegionTrialAddAwardRate(temp)

    if rates[tostring(5)] == 1 then
        self.noRateAddTx:setVisible(true)
        self.checkBtn:setPositionY(60)
        for i = 1,3 do
            local centerLineType = self.centerLineTypes[i]
            centerLineType:setVisible(false)
        end
    else
        self.noRateAddTx:setVisible(false)
        self.checkBtn:setPositionY(77)

        --if rates[tostring(4)] == 1 then
            --self.centerLineTypes[1]:setVisible(true)
            --self.centerLineTypes[2]:setVisible(false)
            --self.centerLineTypes[3]:setVisible(false)

            --local rateTx = self.centerLineTypes[1].rateTx
            --rateTx:setString(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC7'), self.legionTrialCoinIncreaSetype[4].awardIncrease))
        --else
            local showIds = {}
            for i = 1,4 do
                if rates[tostring(i)] > 0 then
                    local temp = {}
                    temp.type = i
                    temp.value = rates[tostring(i)]
                    table.insert(showIds,temp)
                end
            end
            for i = 1,3 do
                if #showIds > 0 then
                    local data = showIds[1]
                    local awardIncrease = self.legionTrialCoinIncreaSetype[data.type].awardIncrease
                    local rateTx = self.centerLineTypes[i].rateTx
                    local value = string.format("%.1f", awardIncrease * data.value)

                    local value1 = value
                    if math.floor(tonumber(value)) == math.ceil(tonumber(value)) then
                        value1 = math.floor(tonumber(value))
                    end

                    --rateTx:setString(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC7'), value1))
                    rateTx:setString(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC7'), data.value))
                    self.centerLineTypes[i]:setVisible(true)
                    self.centerLineTypes[i]:loadTexture( 'uires/icon/legiontrial/' .. self.legionTrialCoinIncreaSetype[data.type].icon)
                    table.remove(showIds,1)
                else
                    self.centerLineTypes[i]:setVisible(false)
                end
            end
        --end
    end

    -- 底部
    self.bottomRichTextAddTx1.re1:setString(LegionTrialMgr:getLegionTrialBaseRate())
    local value = 0
    if rates[tostring(4)] == 1 then
        value = 2
    else
        for i = 1,3 do
            if rates[tostring(i)] > 0 then
                local awardIncrease = self.legionTrialCoinIncreaSetype[i].awardIncrease
                value = value + rates[tostring(i)] * awardIncrease
            end
        end
    end
    local value = string.format("%.1f", value)

    local value1 = value
    if math.floor(tonumber(value)) == math.ceil(tonumber(value)) then
        value1 = math.floor(tonumber(value))
    end

    self.bottomRichTextAddTx1.re2:setString(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC10'), value1))
    self.bottomRichTextAddTx1:format(true)

    local legionTrialBaseConfigData = self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]
    self.bottomRichTextAddTx2.re1:setString(legionTrialBaseConfigData.coinBaseAward)

    local coinAddAward = string.format("%.1f", legionTrialBaseConfigData.coinBaseAward * value)
    local value2 = coinAddAward
    if math.floor(tonumber(coinAddAward)) == math.ceil(tonumber(coinAddAward)) then
        value2 = math.floor(tonumber(coinAddAward))
    end
    self.bottomRichTextAddTx2.re2:setString(string.format(GlobalApi:getLocalStr('LEGION_TRIAL_DESC10'), value2))
    self.bottomRichTextAddTx2:format(true)

    self:refreshGetState()
end

function LegionTrialMainPannelUI:refreshGetState()
    local round = self.trial.round
    local coins = round[tostring(self.curChoosePage)].coins
    local temp = {}
    local hasGetNum = 0
    for i = 1,9 do
        temp[i] = coins[tostring(i)]
        if temp[i] > 0 then
            hasGetNum = hasGetNum + 1
        end
    end

    local getState = false
    local getTx = self.getBtn:getChildByName('text')
    if round[tostring(self.curChoosePage)].award_got == 0 then -- 未领取
        if 9 == hasGetNum then
            self.getBtn:setVisible(true)
            self.bottomRichText:setVisible(false)
            getTx:setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))

            self.getBtn:setTouchEnabled(true)
			ShaderMgr:restoreWidgetDefaultShader(self.getBtn)

            getTx:setColor(COLOR_TYPE.WHITE)
            getTx:enableOutline(cc.c4b(165, 70, 0, 255), 2)
        else
            self.getBtn:setVisible(false)
            self.bottomRichText:setVisible(true)

            self.bottomRichText.re1:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC11'))
            self.bottomRichText.re2:setString(9 - hasGetNum)
            self.bottomRichText.re3:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC12'))
            self.bottomRichText:format(true)
        end
    else    -- 已领取
        getState = true
        self.getBtn:setVisible(true)
        self.bottomRichText:setVisible(false)
        getTx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))

        self.getBtn:setTouchEnabled(false)
		ShaderMgr:setGrayForWidget(self.getBtn)

        getTx:setColor(COLOR_TYPE.GRAY)
        getTx:enableOutline(COLOR_TYPE.BLACK)
    end
    self.getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if getState == true then
                return
            end

            -- 领取通讯
            local function callBack(data)
                local awards = data.awards
			    if awards then
				    GlobalApi:parseAwardData(awards)
				    GlobalApi:showAwardsCommon(awards,nil,nil,true)
			    end
                
                local achievement = data.achievement 
                -- 有改变，就替换
                if achievement then
                    for k,v in pairs(achievement) do
                        if self.trial.achievement[k] == nil then
                            self.trial.achievement[k] = {}
                            self.trial.achievement[k].award_got_level = 0
                        end
                        self.trial.achievement[k].progress = v.progress
                    end
                end              
                
                self.trial.round[tostring(self.curChoosePage)].award_got = 1
                self:refreshGetState()
            end
            LegionTrialMgr:showLegionTrialGetAwardPannelUI(self.trial,self.curChoosePage,callBack)

        end
    end)

    -- 硬币监听
    for i = 1,9 do
        local coin = self.coins[i]
        local id = coin.id
        local selectImg = coin.selectImg
        coin:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.trial.round[tostring(self.curChoosePage)].coins[tostring(i)] == 0 or getState == true then
                    return
                end

                if self.isDisableBtn then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC53'), COLOR_TYPE.RED)
                    return
                end

                local function callBack2()
                    selectImg:setVisible(false)
                end
                local function callBack(data,reset_count)
                    local achievement = data.achievement

                    local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    self.trial.round[tostring(self.curChoosePage)].coins[tostring(i)] = data.new_coin
                    self.trial.round[tostring(self.curChoosePage)].reset_count = reset_count

                    -- 有改变，就替换
                    if achievement then
                        for k,v in pairs(achievement) do
                            if self.trial.achievement[k] == nil then
                                self.trial.achievement[k] = {}
                                self.trial.achievement[k].award_got_level = 0
                            end
                            self.trial.achievement[k].progress = v.progress
                        end
                    end

                    self:refreshStatus()
                    -- 硬币随机动画
                    self:playCoinAct(coin.icon,data.new_coin)
                end
                selectImg:setVisible(true)
                LegionTrialMgr:showLegionTrialResetCoinPannelUI(self.trial,self.curChoosePage,i,callBack,callBack2)
            end
        end)
    end
end

function LegionTrialMainPannelUI:playCoinAct(icon,new_coin)
    local randTemp = {}
    for i = 1,9 do
        if i ~= new_coin then
            table.insert(randTemp,i)
        end
    end
    local icon1 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(1, 2)]].icon
    local icon2 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(3, 4)]].icon
    local icon3 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(5, 6)]].icon
    local icon4 = 'uires/icon/legiontrial/'.. self.legiontTialCoins[randTemp[GlobalApi:random(7, 8)]].icon

    local act1 = cc.DelayTime:create(0.1)
    local act2 = cc.CallFunc:create(function() icon:loadTexture(icon1) end)
    local act3 = cc.DelayTime:create(0.1)
    local act4 = cc.CallFunc:create(function() icon:loadTexture(icon2) end)
    local act5 = cc.DelayTime:create(0.1)
    local act6 = cc.CallFunc:create(function() icon:loadTexture(icon3) end)
    local act7 = cc.DelayTime:create(0.1)
    local act8 = cc.CallFunc:create(function() icon:loadTexture(icon4) end)
    local act9 = cc.DelayTime:create(0.1)
    local act10 = cc.CallFunc:create(function() self:refreshRightChoosePage(self.curChoosePage,true) end)
    icon:runAction(cc.Sequence:create(act1,act2,act3,act4,act5,act6,act7,act8,act9,act10))
end

function LegionTrialMainPannelUI:refreshAchievement(achievement)
    for k,v in pairs(achievement) do
        if self.trial.achievement[k] == nil then
            self.trial.achievement[k] = {}
            self.trial.achievement[k].award_got_level = 0
        end
        self.trial.achievement[k].progress = v.progress
    end
    self:refreshStatus()
end

function LegionTrialMainPannelUI:refreshAdventure(serverData)
    local index = serverData.index
    local data = serverData.data
    self.trial.adventure[tostring(index)] = data
    self:refreshStatus()
end

function LegionTrialMainPannelUI:onShowUIAniOver()
    GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.LEGION_TRIAL)
end

return LegionTrialMainPannelUI