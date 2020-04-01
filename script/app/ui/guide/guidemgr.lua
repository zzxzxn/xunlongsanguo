local ClassGuideClick = require("script/app/ui/guide/guideclick")
local ClassGuideWait = require("script/app/ui/guide/guidewait")
local ClassGuideShowUI = require("script/app/ui/guide/guideshowui")
local ClassGuideTalk = require("script/app/ui/guide/guidetalk")
local ClassGuideFunc = require("script/app/ui/guide/guidefunc")
local ClassGuideAward = require("script/app/ui/guide/guideaward")
local ClassGuideModuleOpen = require("script/app/ui/guide/guidemoduleopen")
local ClassGuideWaitTalk = require("script/app/ui/guide/guidewaittalk")

cc.exports.GuideMgr = {
    runFlag = false,
    guideConf = nil,
    guideNode = nil,
    step = -1,
    jumpStepIndex = -1,
    saveStep = -1,
    saveFlag = false,
    saveWithMsg = false,
    currGuide = nil
}

cc.exports.GUIDE_ONCE = {
    TOWER = 1,
    LEGION = 2,
    EMBATTLE = 3,
    COUNTRY_JADE = 4,
    CITYCRAFT = 5,
    LEGION_TRIAL = 6,
    DIGMINE = 7,
    TERRITORIAL_CITY = 8,
    TERRITORIAL_WARS = 9,
    ROLE_LIST_PROMOTE = 10,
    PEOPLE_KING = 11,
    PEOPLE_KING_1 = 12,
}

function GuideMgr:init()
    CustomEventMgr:dispatchEvent(CUSTOM_EVENT.GUIDE_START)
    self.guideNode = UIManager:getGuideNode()
    self.guidePanel = ccui.Widget:create()
    self.guidePanel:setAnchorPoint(cc.p(0, 0))
    local winsize = cc.Director:getInstance():getWinSize()
    self.guidePanel:setContentSize(winsize)
    self.guidePanel:setTouchEnabled(true)
    self.guidePanel:setPropagateTouchEvents(false)
    self.guidePanel:setLocalZOrder(10000)
    self.guidePanel:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if self.currGuide then
                local swallowFlag = self.currGuide:canSwallow(sender)
                self.guidePanel:setSwallowTouches(swallowFlag)
            else
                self.guidePanel:setSwallowTouches(true)
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self.currGuide then
                self.currGuide:onClickScreen()
            end
        end
    end)
    self.guideNode:addChild(self.guidePanel)
    self.runFlag = true
    self.jumpStepIndex = -1
    self.saveStep = -1
    self.saveFlag = false
    self.saveWithMsg = false
    self.currGuide = nil
end

function GuideMgr:startFirstGuide(step)
    if self.runFlag then
        print("aleady running")
        return false
    end
    local confIndex = MapData:getFightedCityId()
    if confIndex > 0 then
        print("first guide over2")
        return false
    end
    self.step = tonumber(step)
    if self.step <= 0 then
        print("first guide over1")
        return false
    elseif self.step > 1 then
        local guideConf = requireOnce("data/guide/guide_0")
        local checkSave = true
        for k, v in ipairs(guideConf) do
            if v.save and v.save == self.step then
                checkSave = false
                break
            end
        end
        guideConf = nil
        if checkSave then
            self.step = -1
            return false
        end
    end

    MapMgr:cancelBattleTrust()
    BattleMgr:cancelBattleTrust()

    print("start player guide:index = 0 and step = " .. self.step)
    self.guideIndex = 0
    self.guideConf = requireOnce("data/guide/guide_0")
    self:init()
    self:startCurrStep(true)
    return true
end

function GuideMgr:startCityOpenGuide(guideIndex, step)
    if self.runFlag then
        print("aleady running")
        return false
    end
    self.step = tonumber(step)
    if self.step <= 0 then
        print("player guide all over")
        return false
    elseif self.step > 1 then
        local guideConf = requireOnce("data/guide/guide_" .. guideIndex)
        local checkSave = true
        for k, v in ipairs(guideConf) do
            if v.save and v.save == self.step then
                checkSave = false
                break
            end
        end
        guideConf = nil
        if checkSave then
            self.step = -1
            return false
        end
    end
    
    MapMgr:cancelBattleTrust()
    BattleMgr:cancelBattleTrust()

    print("start player guide:index = " .. guideIndex .. " and step = " .. self.step)
    local guideRes = "data/guide/guide_" .. guideIndex
    self.guideIndex = guideIndex
    self.guideConf = requireOnce(guideRes)
    self:init()
    self:startCurrStep(true)
    return true
end

function GuideMgr:startGuideOnlyOnce(guideIndex)
    if self.runFlag then
        print("aleady running")
        return
    end
    local step = UserData:getUserObj():getMark().step or {}
    if step[tostring(guideIndex)] then
        return
    end
    local args = {
        id = guideIndex,
        step = 0
    }
    MessageMgr:sendPost("mark_step", "user", json.encode(args), function (response)
        if response.code == 0 then
            step[tostring(guideIndex)] = 0
            self.guideIndex = guideIndex
            local guideRes = "data/guideonce/guide_" .. guideIndex
            self.guideConf = requireOnce(guideRes)
            self.step = 1
            self:init()
            self.saveStep = 0
            self:startCurrStep(true)
        end
    end)
end

function GuideMgr:saveAndFinish(callBack)
    if self.saveStep ~= 0 then
        self.saveStep = 0
        self.saveWithMsg = true
        MessageMgr:sendPost("mark_guide", "user", "{}", function ()
            self:finish()
			if callBack then
				callBack()
			end
        end)
    else
        self:finish()
		if callBack then
			callBack()
		end
    end
end

function GuideMgr:finish()
    print("player guide finish")
    self.runFlag = false
    self.step = -1
    self.jumpStepIndex = -1
    self.saveStep = -1
    self.saveFlag = false
    self.saveWithMsg = false
    self.guideNode:removeAllChildren()
    self.guideConf = nil
    self.guideNode = nil
    self.currGuide = nil
    CustomEventMgr:dispatchEvent(CUSTOM_EVENT.GUIDE_FINISH)
end

function GuideMgr:forceOver()
    if self.runFlag then
        self.runFlag = false
        self.step = -1
        self.jumpStepIndex = -1
        self.saveStep = -1
        self.saveFlag = false
        self.saveWithMsg = false
        self.guideNode:removeAllChildren()
        self.guideConf = nil
        self.guideNode = nil
        self.currGuide = nil
    end
end

function GuideMgr:isRunning()
    return self.runFlag
end

function GuideMgr:getSaveStep()
    return self.saveStep
end

function GuideMgr:completeSave()
    self.saveWithMsg = false
end

function GuideMgr:startCurrStep(flag)
    -- dump("self.step is :"..self.step)
    local step = self.step%1000
    local guideObj = self.guideConf[step]

    if guideObj == nil then
        self:finish()
        return
    end
    
    -- dump(guideObj)

    --如果选择了保存阵型,战斗界面点击战斗按钮这一步取消
    if guideObj.widgetindex and guideObj.widgetindex[1] == "battle_btn" and GlobalData:getLockFormation() == 1 then
        self:finishCurrGuide()
        return
    end

    local saveWithClick = false
    if guideObj.save and self.saveStep ~= 0 then
        self.saveStep = guideObj.save
        if guideObj.finish and guideObj.finish == "msg" then
            if guideObj.name == "click" then
                saveWithClick = true
            else 
                self.saveWithMsg = true
            end
        else
            self.saveFlag = true
        end
    elseif self.guideConf[step + 1] == nil and self.saveStep ~= 0 then
        self.saveStep = 0
        if guideObj.finish and guideObj.finish == "msg" then
            if guideObj.name == "click" then
                saveWithClick = true
            else 
                self.saveWithMsg = true
            end
        else
            self.saveFlag = true
        end
    end
    if flag and guideObj.needuires then -- 如果从中间某一步开始引导，并且需要打开某个界面
        local uiObj = require("script/app/ui/guide/guideui/" .. guideObj.needuires).new()
        uiObj:showUI()
    end
    if guideObj.name == "click" then
        self.currGuide = ClassGuideClick.new(self.guideNode, guideObj, saveWithClick)
    elseif guideObj.name == "wait" then
        self.currGuide = ClassGuideWait.new(self.guideNode, guideObj)
    elseif guideObj.name == "showui" then
        self.currGuide = ClassGuideShowUI.new(self.guideNode, guideObj)
    elseif guideObj.name == "talk" then
        self.currGuide = ClassGuideTalk.new(self.guideNode, guideObj)
    elseif guideObj.name == "func" then
        self.currGuide = ClassGuideFunc.new(self.guideNode, guideObj, flag)
    elseif guideObj.name == "award" then
        self.currGuide = ClassGuideAward.new(self.guideNode, guideObj)
    elseif guideObj.name == "moduleopen" then
        self.currGuide = ClassGuideModuleOpen.new(self.guideNode, guideObj)
    elseif guideObj.name == 'waittalk' then
        self.currGuide = ClassGuideWaitTalk.new(self.guideNode, guideObj)
    end
    local blockClick
    if guideObj.blockClick ~= nil then
        blockClick = guideObj.blockClick
    else
        blockClick = true
    end
    self.guidePanel:setTouchEnabled(blockClick)
    self.currGuide:startGuide()

    SdkData:trackGuidestep(self.guideIndex, step, 1, guideObj.name)
end

function GuideMgr:nextStep(delaytime)
    local function _nextStep()
        if self.jumpStepIndex > 0 then
            self.step = self.jumpStepIndex
            self.jumpStepIndex = -1
        else
            self.step = self.step + 1
        end
        if delaytime then
            self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime), cc.CallFunc:create(function ()
                self:startCurrStep()
            end)))
        else
            self:startCurrStep()
        end
    end
    if self.saveFlag and self.saveStep >= 0 then
        print("========save step============")
        self.saveWithMsg = true
        MessageMgr:sendPost("mark_guide", "user", "{}", function ()
            self.saveFlag = false
            self.saveWithMsg = false
            _nextStep()
        end)
    else
        _nextStep()
    end
end

function GuideMgr:finishCurrGuide()
    if self.currGuide then
        self.currGuide:finish()
    else
        self:nextStep()
    end
end

-- 开场假战斗1
function GuideMgr:showGuideBattle1()
    BattleMgr:playBattle(BATTLE_TYPE.GUIDE_1, {}, function ()
        self:finishCurrGuide()
    end)
end

-- 开场假战斗2
function GuideMgr:showGuideBattle2()
    BattleMgr:playBattle(BATTLE_TYPE.GUIDE_2, {}, function ()
        self:finishCurrGuide()
    end)
end

-- 开场动画
function GuideMgr:showFirstAnimation()
    local url = 'spine_lossless/kaichangdonghua/kaichangdonghua'
    local name = 'kaichangdonghua'
    local spine = GlobalApi:createSpineByName(name, url, 2)
    if nil ~= spine then
        local winSize = cc.Director:getInstance():getWinSize()
        local black_bg = ccui.ImageView:create()
        black_bg:loadTexture('uires/ui/common/bg_black.png')
        black_bg:setScale9Enabled(true)
        black_bg:setContentSize(winSize)
        black_bg:setTouchEnabled(true)
        black_bg:setPosition(cc.p(winSize.width / 2, winSize.height / 2))
        black_bg:addChild(spine)
        UIManager:addAction(black_bg)

        local skip = ccui.Button:create("uires/ui/common/btn_skip2.png")
        skip:setTouchEnabled(true)
        skip:addClickEventListener(function (  )
            spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            black_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                black_bg:removeFromParent()
                UIManager:playCurrBgm()
                self:finishCurrGuide()
            end)))
        end)
        skip:setPosition(cc.p(winSize.width - 60, winSize.height - 60))
        black_bg:addChild(skip, 999)

        spine:registerSpineEventHandler( function ( event )
            spine:unregisterSpineEventHandler(sp.EventType.ANIMATION_COMPLETE)
            black_bg:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function()
                black_bg:removeFromParent()
                UIManager:playCurrBgm()
                self:finishCurrGuide()
            end)))
        end, sp.EventType.ANIMATION_COMPLETE)
        spine:setPosition(cc.p(winSize.width / 2, winSize.height / 2))

        local count = 1
        black_bg:scheduleUpdateWithPriorityLua(function (dt)
            count = count + 1
            if count > 2 then
                black_bg:unscheduleUpdate()
                spine:setAnimation(0, "animation", false)
                AudioMgr.PlayAudio(4)
                -- 飞两行弹幕
                spine:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
                    local label1 = ccui.Text:create()
                    label1:setFontName("font/gamefont.ttf")
                    label1:setFontSize(20)
                    label1:enableOutline(COLOR_TYPE.BLACK, 1)
                    label1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    label1:setString(GlobalApi:getLocalStr("KAICHANGDONGHUA_DANMU_1"))
                    label1:setPosition(cc.p(winSize.width/2 + 100, 240))
                    local img1 = ccui.ImageView:create("uires/icon/face/1.png")
                    local labelSize1 = label1:getContentSize()
                    label1:addChild(img1)
                    img1:setPosition(cc.p(labelSize1.width + 25, labelSize1.height/2))
                    label1:runAction(cc.MoveBy:create(14, cc.p(-winSize.width*2, 0)))
                    spine:addChild(label1)
                end), cc.DelayTime:create(2),cc.CallFunc:create(function()
                    local label2 = ccui.Text:create()
                    label2:setFontName("font/gamefont.ttf")
                    label2:setFontSize(20)
                    label2:enableOutline(COLOR_TYPE.BLACK, 1)
                    label2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    label2:setString(GlobalApi:getLocalStr("KAICHANGDONGHUA_DANMU_5"))
                    label2:setPosition(cc.p(winSize.width/2 + 100, 200))
                    label2:runAction(cc.MoveBy:create(14, cc.p(-winSize.width*2, 0)))
                    spine:addChild(label2)
                end), cc.DelayTime:create(1),cc.CallFunc:create(function()
                    local label3 = ccui.Text:create()
                    label3:setFontName("font/gamefont.ttf")
                    label3:setFontSize(20)
                    label3:enableOutline(COLOR_TYPE.BLACK, 1)
                    label3:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    label3:setString(GlobalApi:getLocalStr("KAICHANGDONGHUA_DANMU_2"))
                    label3:setPosition(cc.p(winSize.width/2 + 100, 160))
                    label3:runAction(cc.MoveBy:create(14, cc.p(-winSize.width*2, 0)))
                    spine:addChild(label3)
                end), cc.DelayTime:create(3),cc.CallFunc:create(function()
                    local label4 = ccui.Text:create()
                    label4:setFontName("font/gamefont.ttf")
                    label4:setFontSize(20)
                    label4:enableOutline(COLOR_TYPE.BLACK, 1)
                    label4:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    label4:setString(GlobalApi:getLocalStr("KAICHANGDONGHUA_DANMU_3"))
                    label4:setPosition(cc.p(winSize.width/2 + 100, 240))
                    label4:runAction(cc.MoveBy:create(14, cc.p(-winSize.width*2, 0)))
                    spine:addChild(label4)
                end), cc.DelayTime:create(1),cc.CallFunc:create(function()
                    local label5 = ccui.Text:create()
                    label5:setFontName("font/gamefont.ttf")
                    label5:setFontSize(20)
                    label5:enableOutline(COLOR_TYPE.BLACK, 1)
                    label5:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                    label5:setString(GlobalApi:getLocalStr("KAICHANGDONGHUA_DANMU_4"))
                    label5:setPosition(cc.p(winSize.width/2 + 100, 200))
                    label5:runAction(cc.MoveBy:create(14, cc.p(-winSize.width*2, 0)))
                    spine:addChild(label5)
                end)))
            end
        end, 0)
    end
end

function GuideMgr:updateRunBar()
    MapMgr:updateRunBar(function()
        self:finishCurrGuide()
    end)
end

function GuideMgr:getFeilongBoxAwards()
    MapMgr:getFeilongBoxAwards(function()
        self:finishCurrGuide()
    end)
end

function GuideMgr:showRunBar()
    MapMgr:showRunBar(function()
        self:finishCurrGuide()
    end)
end

function GuideMgr:showDiDiGet()
    MapMgr:showDiDiGet(function()
        self:finishCurrGuide()
    end)
end

function GuideMgr:diDiFly()
    UIManager:getSidebar():mapBtnsFly('didi',function()
        self:finishCurrGuide()
    end)
end

-- 显示大地图
function GuideMgr:showMap(arg)
    if UIManager:getUIByIndex(GAME_UI.UI_MAINSCENE) then
        if arg and arg.index then
            MapMgr:showMainScene(2, arg.index, function ()
                self:finishCurrGuide()
            end)
        else
            self:finishCurrGuide()
        end
    else
        local index = nil
        if arg and arg.index then
            index = arg.index
        end
        MapMgr:showMainScene(2, index, function ()
            self:finishCurrGuide()
        end)
    end
end

-- 显示最小缩放的大地图
function GuideMgr:showWholeMap()
    if UIManager:getUIByIndex(GAME_UI.UI_MAINSCENE) then
        self:finishCurrGuide()
    else
        MapMgr:showMainScene(2, nil, function ()
            self:finishCurrGuide()
        end, 0.35)
    end
end

-- 显示主城
function GuideMgr:showMainScene()
    if UIManager:getUIByIndex(GAME_UI.UI_MAINCITY) then
        self:finishCurrGuide()
    else
        MapMgr:hideMainScene()

        MainSceneMgr:showMainCity(function ()
            self:finishCurrGuide()
        end)
    end
end

-- 引导缩放大地图
function GuideMgr:guideZoomMap(args)
    local winsize = cc.Director:getInstance():getWinSize()
    local hands = GlobalApi:createLittleLossyAniByName('guide_zoom')
    hands:setPosition(cc.p(winsize.width/2, winsize.height/2 - 100))
    hands:getAnimation():playWithIndex(0, -1, 1)
    hands:setName('guideZoomMapHands')
    hands:setScale(0.7)
    self.guideNode:addChild(hands)

    -- 显示提示
    local guidetextConf = GameData:getConfData("local/guidetext")[args.tipstext]
    local dialogNode = cc.Node:create()
    local dialog = cc.Sprite:create("uires/ui/guide/guide_bg_dialog3.png")
    local npc = ccui.ImageView:create('uires/ui/yindao/yindao_5.png')
    local npcScaleX = args.tipsscalex or 1
    local label = cc.Label:createWithTTF(guidetextConf.text, "font/gamefont.ttf", 21)
    label:setTextColor(COLOR_TYPE.BLACK)
    label:enableOutline(cc.c4b(255, 255, 255, 255), 1)
    dialogNode:addChild(npc)
    dialogNode:addChild(dialog)
    dialogNode:addChild(label)
    dialogNode:setName('guideZoomMapTips')
    self.guideNode:addChild(dialogNode)
    dialogNode:setPosition(cc.p(200 + args.tipspos.x,winsize.height/2 + args.tipspos.y))
    AudioMgr.playEffect("media/guide/" .. guidetextConf.soundRes, false)

    MapMgr:guideZoomMap(function ()
        local hand3 = self.guideNode:getChildByName("guideZoomMapHands")
        local tips = self.guideNode:getChildByName("guideZoomMapTips")
        tips:removeFromParent()
        hand3:removeFromParent()
        self:finishCurrGuide()
    end)
end

-- 龙蛋介绍动画(改成遗书了)
function GuideMgr:introduceDragonEgg()
    local winsize = cc.Director:getInstance():getWinSize()
    local blackBg = ccui.ImageView:create()
    blackBg:loadTexture('uires/ui/yindao/yindao_yishu.png')
    blackBg:setPosition(cc.p(winsize.width / 2, winsize.height / 2))
    blackBg:setOpacity(0)
    GlobalApi:imgScaleWinSize(blackBg)
    self.guideNode:addChild(blackBg)

    local guidetextConf = GameData:getConfData("local/guidetext")
    local originalStr = guidetextConf["GUIDE_TEXT_1072"].text
    local lable = cc.Label:createWithTTF("", 'font/gamefont.ttf', 26)
    lable:setPosition(cc.p(winsize.width/2, winsize.height/2 - 80))
    lable:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
    lable:setDimensions(winsize.width - 150, winsize.height - 150)
    lable:setLineSpacing(15)
    lable:setAdditionalKerning(3)
    lable:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
    lable:setVerticalAlignment(cc.VERTICAL_TEXT_ALIGNMENT_TOP)
    self.guideNode:addChild(lable)

    blackBg:runAction(cc.Sequence:create(
        cc.FadeIn:create(1), 
        cc.CallFunc:create(function ()
            local len = math.ceil(string.len(originalStr)/3)
            local function setSingleString(index)
                local str = string.sub(originalStr,1,index*3)
                lable:setString(str)
                self.guideNode:runAction(cc.Sequence:create(cc.DelayTime:create(0.000001),cc.CallFunc:create(function()
                    if index >= len then
                        self.guideNode:runAction(cc.Sequence:create(
                            cc.DelayTime:create(3),
                            cc.FadeOut:create(1),
                            cc.CallFunc:create(function ()
                                blackBg:removeFromParent()
                                lable:removeFromParent()
                                
                                self:finishCurrGuide()
                            end)
                        ))
                    else
                        setSingleString(index + 1)
                    end
                end)))
            end
            setSingleString(1)
        end)
    ))
end

-- 移动到某一指定建筑
function GuideMgr:moveToMainSceneBuilding(arg)
    MainSceneMgr:setWinPosition(arg.name, true)
    self:finishCurrGuide()
end

function GuideMgr:closeSidebar()
    UIManager:getSidebar():setFrameBtnsVisible(false)
    UIManager:getSidebar():setBottomBtnsVisible(true)
    self:finishCurrGuide()
end

function GuideMgr:openSidebar()
    UIManager:getSidebar():setFrameBtnsVisible(true)
    self:finishCurrGuide()
end

function GuideMgr:feilongFlyCallback()
    MapMgr:feilongFlyCallback()
    self:finishCurrGuide()
end

function GuideMgr:feilongFlyForGuide()
    -- MapMgr:feilongFly(0,function ()
        self:finishCurrGuide()
    -- end)
end


function GuideMgr:wait()
    self.guidePanel:setTouchEnabled(false)
end

-- 功能按钮飞向Map的动画
function GuideMgr:openMapModule(arg)
    UIManager:getSidebar():mapBtnsFly(arg.name, function ()
        MapMgr:setBuoyBtnsVisible()
        self:finishCurrGuide()
    end)
end

-- 功能按钮飞向sidebar的动画
function GuideMgr:openSidebarModule(arg)
    UIManager:getSidebar():btnsFly(arg.name, function ()
        self:finishCurrGuide()
    end)
end

-- 特殊阵型
function GuideMgr:setBattleSpecialFormation()
    local formation = {0,0,0,0,0,0,0,0,0}
    local map = RoleData:getRoleMap()
    local conf = GameData:getConfData("specialreward")["guide_guanyu"]
    local firstHeroId = DisplayData:getDisplayObj(conf.reward[1]):getId()
    for k, v in pairs(map) do
        if v:getId() > 0 then
            if v:isJunZhu() then
                formation[1] = v:getPosId()
            elseif v:getId() == firstHeroId then
                formation[2] = v:getPosId()
            end
        end
    end
    UserData:getUserObj():setFormation(formation)
    self:finishCurrGuide()
end

-- 特殊布阵
function GuideMgr:guideSpecialEmbattle()
    BattleMgr:guideSpecialEmbattle()
    self:finishCurrGuide()
end

-- 宝物界面
function GuideMgr:showGuideTreasure()
    if UIManager:getUIByIndex(GAME_UI.UI_TREASURE) == nil then
        local treasureInfo = UserData:getUserObj():getTreasure()
        local active = tonumber(treasureInfo.active)
        RoleData:createDragon(1,{level = 1})
        MainSceneMgr:showDragonInfoUI(1,false,function ()
            local args = {}
            MessageMgr:sendPost('active','treasure',json.encode(args),function (response)
                local code = response.code
                local data = response.data
                if code == 0 then
                    RoleData:setAllFightForceDirty()

                    treasureInfo.active = treasureInfo.active + 1
                    UserData:getUserObj():setTreasure(treasureInfo)

                    if data.awards then
                        GlobalApi:parseAwardData(data.awards)
                    end
                    if data.costs then
                        GlobalApi:parseAwardData(data.costs)
                    end

                    for i=1,7 do
                        local obj = RoleData:getRoleByPos(i)
                        if obj and obj:getId() > 0 then
                            RoleMgr:popupTips(obj,true)
                        end
                    end

                    MainSceneMgr:showTreasure(1)
                end

                local guideTreasureUI = require("script/app/ui/guide/guideui/guidetreasure").new()
                guideTreasureUI:showUI()
            end)
        end)
    else
        self:finishCurrGuide()
    end
end

-- 中途退出再次进入宝物界面
function GuideMgr:showGuideTreasure2()
    if UIManager:getUIByIndex(GAME_UI.UI_TREASURE) == nil then
        local guideTreasureUI = require("script/app/ui/guide/guideui/guidetreasure").new()
        guideTreasureUI:showUI()
        -- guideTreasureUI:guideEquipDragon()
    end
    self:finishCurrGuide()
end

-- 打造界面
function GuideMgr:showFusion()
    CustomEventMgr:addEventListener(CUSTOM_EVENT.UI_SHOW, self, function (uiIndex)
        if UIManager:getTopNodeIndex() == GAME_UI.UI_FUSION then
            CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
            self:finishCurrGuide()
        end
    end)
    BagMgr:showFusion()
end

-- 训练馆
function GuideMgr:showTrain()
    CustomEventMgr:addEventListener(CUSTOM_EVENT.UI_SHOW, self, function (uiIndex)
        if UIManager:getTopNodeIndex() == GAME_UI.UI_TRAININGMAIN then
            CustomEventMgr:removeEventListener(CUSTOM_EVENT.UI_SHOW, self)
            self:finishCurrGuide()
        end
    end)
    TrainingMgr:showTrainingMain()
end

-- 武将界面的缘分特殊处理
function GuideMgr:playFateGuide()
    RoleMgr:playFateGuild()
    self:finishCurrGuide()
end

function GuideMgr:stopFateGuide()
    RoleMgr:stopFateGuild()
    self:finishCurrGuide()
end

function GuideMgr:showRoleEquipGem()
    local obj = RoleData:getRoleByPos(1)
    local index = 0
    for i=1,6 do
        local equip = obj:getEquipByIndex(i)
        if equip and equip:getMaxGemNum() > 0 then
            index = i
        end
    end
    local isOpen = GlobalApi:getOpenInfo('gem')
    if index > 0 and isOpen then
        RoleMgr:showRoleMain(1,7,index)
        self:finishCurrGuide()
    else
        self:saveAndFinish()
    end
end

function GuideMgr:showRoleEquipRefine()
    local obj = RoleData:getRoleByPos(1)
    local index = 0
    for i=1,6 do
        local equip = obj:getEquipByIndex(i)
        if equip then
            index = i
        end
    end
    local isOpen = GlobalApi:getOpenInfo('refine')
    if index > 0 and isOpen then
        RoleMgr:showRoleMain(1,7,index)
        self:finishCurrGuide()
    else
        self:saveAndFinish()
    end
end

function GuideMgr:showRoleEquipGod()
    local obj = RoleData:getRoleByPos(1)
    local index = 0
    for i=1,6 do
        local equip = obj:getEquipByIndex(i)
        if equip and equip:getGodId() > 0 then
            index = i
        end
    end
    
    local isOpen = GlobalApi:getOpenInfo('godupgrade')
    if index > 0 and isOpen then
        RoleMgr:showRoleMain(1,7,index)
        self:finishCurrGuide()
    else
        self:saveAndFinish()
    end
end

-- 宝物界面
function GuideMgr:showTreasure(arg)
    if arg then
        MainSceneMgr:showTreasure(arg.page)
    else
        MainSceneMgr:showTreasure()
    end
    self:finishCurrGuide()
end

-- 引导升星界面
function GuideMgr:showUpgradeGod(ntype)
    BagMgr:showUpgradeGod(ntype)
    self:finishCurrGuide()
end

-- 关闭升星界面
function GuideMgr:hideUpgradeGod()
    BagMgr:hideUpgradeGod()
    self:finishCurrGuide()
end

-- 装备龙
function GuideMgr:equipDragon()
    MainSceneMgr:guideEquipDragon(function()
        self:finishCurrGuide()
    end)
end

function GuideMgr:giveName()
    if not UserData:getUserObj():getName() or UserData:getUserObj():getName() == "" then
        self.guidePanel:setTouchEnabled(false)
        local guidecreatename = require("script/app/ui/guide/guideui/guidecreatename").new()
        guidecreatename:showUI()
    else
        self:finishCurrGuide()
    end
end

function GuideMgr:checkWhetherHasThirdHero(arg)
    local role = RoleData:getRoleByPos(3)
    if role and role:getId() > 0 then
        self.jumpStepIndex = arg.goto
        self:finishCurrGuide()
    else
        self:finishCurrGuide()
    end
end

function GuideMgr:showStory(arg)
    local uiObj = requireOnce("script/app/ui/guide/guideui/guidestory_" .. arg.index).new()
    uiObj:showUI()
    uiObj:start()
end

function GuideMgr:closeMapOnshow()
    MapMgr:closeMapOnshow()
    self:finishCurrGuide()
end

function GuideMgr:signWeapon()
	local step = UserData:getUserObj():getMark().step or {}
	local args = {
		id = GUIDE_ONCE.PEOPLE_KING,
		step = 0
	}
	MessageMgr:sendPost("mark_step", "user", json.encode(args), function (response)
		if response.code == 0 then
			step[tostring(GUIDE_ONCE.PEOPLE_KING)] = 0
			self:finishCurrGuide()
		end
	end)
end

function GuideMgr:checkWeapon()
	local step = UserData:getUserObj():getMark().step or {}
	if step[tostring(GUIDE_ONCE.PEOPLE_KING)] then
		self:saveAndFinish()
		return
	end
	self:finishCurrGuide()
end

function GuideMgr:checkRoleQuality()
    for k, v in pairs(RoleData:getRoleMap()) do
        if v:isJunZhu() == false and v:getQuality() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit')) then
            self:finishCurrGuide()
            return
        end
    end
    self:saveAndFinish()
end

function GuideMgr:checkEliteEquip()
    local fighted = MapData:getFightedEliteCityId()
    if fighted >= 1 then
        self:finishCurrGuide()
    else
        self:finish()
    end
end

function GuideMgr:checkSoldierEquip(arg)
    local objarr = {}
    for k, v in pairs(RoleData:getRoleMap()) do
        if v:getId() < 10000 then
            objarr[tonumber(k)] = v
        end
    end
    RoleMgr:sortByQuality(objarr, 1)
    if arg.step == 1 then
        local roleObj = objarr[arg.pos]
        if roleObj then
            if roleObj:getSoldierLv() == 1 then             
                local hadDress = false
                for i=1,6 do
                    local obj = BagData:getDressById(100 + i)
                    if obj and obj:getNum() > 0 then
                        hadDress = true
                        break
                    end
                end
                if hadDress then
                    if roleObj:getSoldierdressNum() == 6 then
                        self.jumpStepIndex = arg.goto
                    end
                    self:finishCurrGuide()
                else
                    self:saveAndFinish()
                end
            else
                self:saveAndFinish()
            end
        else
            self:saveAndFinish()
        end
    elseif arg.step == 2 then
        local roleObj = objarr[arg.pos]
        if roleObj and roleObj:getSoldierdress(2) == 0 then
            self:finishCurrGuide()
        else
            self:saveAndFinish()
        end
    else
        self:saveAndFinish()
    end
end

function GuideMgr:checkDragonGem(arg)
    local dragon = RoleData:getDragonById(arg.dragonId)
    if dragon then
        if dragon:getLevel() == 1 and dragon:getDragonGemBySlot(arg.slotId) == nil then
            local dragonLevel = GameData:getConfData("dragonlevel")[dragon:getLevel()]
            local cost = DisplayData:getDisplayObj(dragonLevel.cost[1])
            local currGold = UserData:getUserObj():getGold()
            if currGold >= cost:getNum() and BagData:getDragongemTotalNum() > 0 then
                self:finishCurrGuide()
            else
                self:saveAndFinish()
            end
        else
             self:saveAndFinish()
        end
    else
        self:saveAndFinish()
    end
end

function GuideMgr:showBattleCounter()
    BattleMgr:showBattleCounter()
    self:finishCurrGuide()
end

function GuideMgr:getActivityBtnName(funcname)
   local widgetName = UIManager:getSidebar():getActivityWidget(funcname)
   print("widgetName" ,widgetName)
   return widgetName
end

function GuideMgr:checkEquipBagFull()
    if BagData:getEquipFull() then
        self:saveAndFinish()
    else
        self:finishCurrGuide()
    end
end

function GuideMgr:checkCountryIsOpen()
	if UserData:getUserObj():getCountry() == 0 then
		self:finishCurrGuide()
	else
		self:saveAndFinish()
	end
end

function GuideMgr:checkCountryIsOpen2()
	if UserData:getUserObj():getCountry() == 0 then
		self:finishCurrGuide()
	else
		local function callBack()
			MapMgr:showViewPrefecturePanelByGuide()
		end
		self:saveAndFinish(callBack)
	end
end

--测试用
function GuideMgr:startGuideOnlyOnceTest(guideIndex, step, once)
    local guideRes = "data/guide/guide_" .. guideIndex
    if once then
        guideRes = "data/guideonce/guide_" .. guideIndex
    end
    self.guideConf = requireOnce(guideRes)
    self.step = step or 1
    self:init()
    self.saveStep = 0
    self:startCurrStep(true)
end
