local BattleHelper = require("script/app/ui/battle/battlehelper")
local BattleVictoryUI = class("BattleVictoryUI", BaseUI)

function BattleVictoryUI:ctor(starNum)
    self.uiIndex = GAME_UI.UI_BATTLEREPORTRESULT
    self.starNum = starNum
end

function BattleVictoryUI:init()
    local animationOver = false
    local resultBgImg = self.root:getChildByName("result_bg_img")
    local resultNode = resultBgImg:getChildByName("result_node")
    self:adaptUI(resultBgImg, resultNode)
    local originPosx, originPosy = resultNode:getPosition()
    local infoLabel = resultNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local mainImg = resultNode:getChildByName("main_img")
    mainImg:setLocalZOrder(3)
    local damageBtn = mainImg:getChildByName("damage_btn")
    local damageLabel = damageBtn:getChildByName("text")
    damageLabel:setString(GlobalApi:getLocalStr("STR_STATISTICS"))
    damageBtn:addClickEventListener(function ()
        BattleMgr:showBattleDamageCount(true)
    end)

    local returnBtn = mainImg:getChildByName("return_btn")
    local returnLabel = returnBtn:getChildByName("text")
    returnLabel:setString(GlobalApi:getLocalStr("STR_RETURN_1"))
    returnBtn:addClickEventListener(function ()
        BattleMgr:hideBattleReportResult()
        BattleMgr:exitBattleField()
    end)

    -- 光
    local lightPl = resultNode:getChildByName("light_panel")
    lightPl:setLocalZOrder(1)
    local lightNode = lightPl:getChildByName("light_node")
    lightNode:setVisible(false)
    local lightBg = lightPl:getChildByName("light_bg")
    lightBg:setVisible(false)

    local function showLight()
        lightBg:setVisible(true)
        lightNode:setVisible(true)
        lightNode:runAction(cc.RepeatForever:create(cc.RotateBy:create(8, 360)))
        local particle = cc.ParticleSystemQuad:create("particle/victory_light.plist")
        local size = lightPl:getContentSize()
        particle:setPosition(cc.p(size.width/2, 0))
        lightPl:addChild(particle)
    end

    local starArr = {}
    local starIndex = self.starNum
    for i = 1, 3 do
        local starBg = mainImg:getChildByName("star_" .. i)
        local star = starBg:getChildByName("star")
        star:setVisible(false)
        table.insert(starArr, star)
    end

    local function showStar()
        local starPosArr = {}
        for i = 1, starIndex do
            local star = starArr[i]
            local posx, posy = star:getPosition()
            starPosArr[i] = cc.p(posx, posy)
            star:setPosition(cc.p(posx, posy + 200))
            star:setScale(5)
            local delayTime = (i-1)*0.2
            local action
            if i == starIndex then
                action = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function ()
                        star:setVisible(true)
                    end),
                    cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(posx, posy)), cc.ScaleTo:create(0.2, 1)), cc.CallFunc:create(function ()
                        animationOver = true
                    end))
            else
                action = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function ()
                        star:setVisible(true)
                    end),
                    cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(posx, posy)), cc.ScaleTo:create(0.2, 1)))
            end
            star:runAction(action)
        end
    end

    local ani = GlobalApi:createSpineByName("ui_battlevictory", "spine/ui_battlevictory/ui_battlevictory", 1)
    ani:setVisible(false)
    ani:setLocalZOrder(2)
    resultNode:addChild(ani)

    mainImg:setPosition(cc.p(0, 600))
    ani:setPosition(cc.p(0, 600))

    local moveDownAct = cc.Sequence:create(cc.EaseBounceOut:create(cc.MoveBy:create(0.8, cc.p(0, -640))), cc.CallFunc:create(function ()
        showStar()
        showLight()
    end))
    local moveDownAct2 = cc.Spawn:create(cc.EaseBounceOut:create(cc.MoveBy:create(0.8, cc.p(0, -640))), cc.Sequence:create(cc.DelayTime:create(0.6), cc.CallFunc:create(function ()
        ani:setVisible(true)
        ani:setAnimation(0, "animation", false)
    end)))
    mainImg:runAction(moveDownAct)
    ani:runAction(moveDownAct2)
    resultBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if animationOver then
                BattleMgr:hideBattleReportResult()
                BattleMgr:exitBattleField()
            end
        end
    end)
end

return BattleVictoryUI