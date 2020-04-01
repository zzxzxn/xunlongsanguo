local BattleHelper = require("script/app/ui/battle/battlehelper")
local ClassItemCell = require('script/app/global/itemcell')
local BattleVictoryUI = class("BattleVictoryUI", BaseUI)

function BattleVictoryUI:ctor(displayAwards, starNum, specialAwardDatas, kingLvUpData, notFromBattlefield, damageInfo,otherPic)
    self.uiIndex = GAME_UI.UI_BATTLE_VICTORY
    self.displayAwards = displayAwards
    self.starNum = starNum
    self.specialAwardDatas = specialAwardDatas
    self.kingLvUpData = kingLvUpData
    self.notFromBattlefield = notFromBattlefield
    self.damageInfo = damageInfo
    self.otherPic = otherPic or false
end

function BattleVictoryUI:init()
    local animationOver = false
    local userAwards = {}
    local otherAwards = {}
    local otherAwardNum = 0
    for k, v in pairs(self.displayAwards) do
        if v:getType() == "user" then
            local id = v:getId()
            if userAwards[id] then
                userAwards[id] = userAwards[id] + v:getNum()
            else
                userAwards[id] = v:getNum()
            end
            if id ~= "gold" and id ~= "xp" then
                table.insert(otherAwards, v)
                otherAwardNum = otherAwardNum + 1
            end
        else
            table.insert(otherAwards, v)
            otherAwardNum = otherAwardNum + 1
        end
    end
    
    local victoryBgImg = self.root:getChildByName("victory_bg_img")
    local victoryNode = victoryBgImg:getChildByName("victory_node")
    self:adaptUI(victoryBgImg, victoryNode)
    local originPosx, originPosy = victoryNode:getPosition()
    local infoLabel = victoryNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local mainImg = victoryNode:getChildByName("main_img")
    -- 战斗结束图片
    if self.otherPic then
        mainImg:loadTexture('uires/ui/battleresult/battleresult_001.png')
    end
    mainImg:setLocalZOrder(3)
    local damageBtn = mainImg:getChildByName("damage_btn")
    local damageLabel = damageBtn:getChildByName("text")
    damageLabel:setString(GlobalApi:getLocalStr("STR_STATISTICS"))
    damageBtn:addClickEventListener(function ()
        if self.notFromBattlefield then
            BattleMgr:showBattleDamageCount(false, self.damageInfo)
        else
            BattleMgr:showBattleDamageCount()
        end
    end)

    local returnBtn = mainImg:getChildByName("return_btn")
    local returnLabel = returnBtn:getChildByName("text")
    returnLabel:setString(GlobalApi:getLocalStr("STR_RETURN_1"))
    returnBtn:addClickEventListener(function ()
        local function exitBattleCallBack()
            BattleMgr:hideVictory()
            if not self.notFromBattlefield then
                BattleMgr:exitBattleField()
            end
        end
        if self.kingLvUpData and self.kingLvUpData.nowLv > self.kingLvUpData.lastLv then
            GlobalApi:showKingLvUp(self.kingLvUpData.lastLv,self.kingLvUpData.nowLv,nil,exitBattleCallBack)
        else
            exitBattleCallBack()
        end
    end)

    local userObj = UserData:getUserObj()
    local lvLabel = mainImg:getChildByName("lv_tx")
    lvLabel:setString(tostring(userObj:getLv()))
    local expLabel = mainImg:getChildByName("exp_tx")
    local addExpNum = userAwards["xp"] or 0
    expLabel:setString(tostring(addExpNum))
    local goldLabel = mainImg:getChildByName("gold_tx")
    local addGoldNum = userAwards["gold"] or 0
    goldLabel:setString(tostring(addGoldNum))

    local sv = mainImg:getChildByName("awards_sv")
    local svSize = sv:getContentSize()
    sv:setScrollBarEnabled(false)
    -- 奖励物品
    for i = 1, otherAwardNum do
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, otherAwards[i], sv)
        tab.lvTx:setAnchorPoint(cc.p(1, 0.5))
        tab.lvTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        tab.lvTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        tab.lvTx:setString(tostring(otherAwards[i]:getNum()))
        tab.lvTx:setPosition(cc.p(80, 16))
        tab.awardBgImg:setPosition(cc.p(55 + (i-1)*110, 60))
        ClassItemCell:setGodLight(tab.awardBgImg,otherAwards[i]:getGodId())

        if otherAwards[i]:getExtraBg() then
            tab.doubleImg:setVisible(true)
        else
            tab.doubleImg:setVisible(false)
        end

    end
    local totalWidth = otherAwardNum*110
    local posX = svSize.width
    if totalWidth > posX then
        posX = totalWidth
    end
    sv:setInnerContainerSize(cc.size(posX, svSize.height))

    -- 特殊icon，玉璧代表，暂时没其他道具奖励品
    if self.specialAwardDatas then
        if self.specialAwardDatas.battleType == BATTLE_TYPE.COUNTRY_JADE then
            local awardBgImg = ccui.ImageView:create(COLOR_FRAME[self.specialAwardDatas.type + 1])
            
            local size = awardBgImg:getContentSize()

            local awardImg = ccui.ImageView:create(self.specialAwardDatas.icon)
            awardImg:setPosition(cc.p(size.width/2,size.height/2))
            awardImg:setScale(0.5)
            awardBgImg:addChild(awardImg)
            if self.specialAwardDatas.pos == 1 then
                awardImg:setRotation(0)
            else
                awardImg:setRotation(180)
            end

            awardBgImg:setPosition(cc.p(55,60))
            sv:addChild(awardBgImg)
        elseif self.specialAwardDatas.battleType == BATTLE_TYPE.TOWER then
            sv:removeAllChildren()
            local cur_floor = self.specialAwardDatas.cur_floor
            -- 添加显示
            local richText = xx.RichText:create()
	        richText:setContentSize(cc.size(500, 40))

	        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('BATTLE_VICTORY_DES1'), 24, COLOR_TYPE.WHITE)
	        re1:setStroke(COLOR_TYPE.BLACK,1)
            re1:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
            re1:setFont('font/gamefont.ttf')

            local re2 = xx.RichTextImage:create('uires/ui/res/res_tower.png')
            
            local num = self.displayAwards[1]:getNum() -- 目前只有塔币

	        local re3 = xx.RichTextLabel:create(num, 24, COLOR_TYPE.GREEN)
	        re3:setStroke(COLOR_TYPE.BLACK,1)
            re3:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
            re3:setFont('font/gamefont.ttf')

            local towercoinrewardConf = GameData:getConfData("towercoinreward")
            local towerData = towercoinrewardConf[cur_floor]
            local des4
            local re4
            if num == towerData['crit' .. self.starNum] then
                des4 = GlobalApi:getLocalStr('BATTLE_VICTORY_DES2')
                re4 = xx.RichTextLabel:create(des4, 24, COLOR_TYPE.PURPLE)
	            re4:setStroke(COLOR_TYPE.BLACK,1)
                re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
                re4:setFont('font/gamefont.ttf')
            elseif num == towerData['luckyCrit' .. self.starNum] then
                des4 = GlobalApi:getLocalStr('BATTLE_VICTORY_DES3')
                re4 = xx.RichTextLabel:create(des4, 24, COLOR_TYPE.RED)
	            re4:setStroke(COLOR_TYPE.BLACK,1)
                re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
                re4:setFont('font/gamefont.ttf')
            end

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:addElement(re3)
            if des4 then
                richText:addElement(re4)
            end
                     
            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0.5,0.5))
            sv:addChild(richText)
            richText:setPosition(cc.p(sv:getContentSize().width/2,sv:getContentSize().height/2))
            richText:format(true)

        end
    end

    -- 光
    local lightPl = victoryNode:getChildByName("light_panel")
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
        --particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
        local size = lightPl:getContentSize()
        particle:setPosition(cc.p(size.width/2, 0))
        lightPl:addChild(particle)
    end

    local starArr = {}
    local starIndex = 0
    for i = 1, 3 do
        local starBg = mainImg:getChildByName("star_" .. i)
        local star = starBg:getChildByName("star")
        star:setVisible(false)
        if i <= self.starNum then
            starIndex = starIndex + 1
            table.insert(starArr, star)
        end
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
                        -- victoryNode:stopAllActions()
                        -- victoryNode:runAction(cc.Sequence:create(cc.Shake:create(0.3, 3, 6), cc.CallFunc:create(function ()
                        --     victoryNode:setPosition(cc.p(originPosx, originPosy))
                             animationOver = true
                        -- end)))
                    end))
            else
                action = cc.Sequence:create(cc.DelayTime:create(delayTime), cc.CallFunc:create(function ()
                        star:setVisible(true)
                    end),
                    cc.Spawn:create(cc.MoveTo:create(0.2, cc.p(posx, posy)), cc.ScaleTo:create(0.2, 1)), cc.CallFunc:create(function ()
                        -- victoryNode:stopAllActions()
                        -- victoryNode:runAction(cc.Sequence:create(cc.Shake:create(0.15, 3, 6), cc.CallFunc:create(function ()
                        --     victoryNode:setPosition(cc.p(originPosx, originPosy))
                        -- end)))
                    end))
            end
            star:runAction(action)
        end
    end

    local ani = GlobalApi:createSpineByName("ui_battlevictory", "spine/ui_battlevictory/ui_battlevictory", 1)
    ani:setVisible(false)
    ani:setLocalZOrder(2)
    victoryNode:addChild(ani)
    --ani:setAnimation(0, "animation", false)

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
    victoryBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if animationOver then
                local function exitBattleCallBack()
                    BattleMgr:hideVictory()
                    if not self.notFromBattlefield then
                        BattleMgr:exitBattleField()
                    end
                end
                if self.kingLvUpData and self.kingLvUpData.nowLv > self.kingLvUpData.lastLv then
                    GlobalApi:showKingLvUp(self.kingLvUpData.lastLv,self.kingLvUpData.nowLv,nil,exitBattleCallBack)
                else
                    exitBattleCallBack()
                end
            end
        end
    end)


    if BattleMgr:getTrust() then
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(2),cc.CallFunc:create(function()
            local function exitBattleCallBack()
                BattleMgr:hideVictory()
                if not self.notFromBattlefield then
                    BattleMgr:exitBattleField()
                end
            end
            if self.kingLvUpData and self.kingLvUpData.nowLv > self.kingLvUpData.lastLv then
                GlobalApi:showKingLvUp(self.kingLvUpData.lastLv,self.kingLvUpData.nowLv,nil,exitBattleCallBack)
            else
                exitBattleCallBack()
            end
        end)))
    end
end

return BattleVictoryUI