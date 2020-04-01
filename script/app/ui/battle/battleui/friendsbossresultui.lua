local ClassItemCell = require('script/app/global/itemcell')
local FriendsBossResultUI = class("FriendsBossResultUI", BaseUI)

function FriendsBossResultUI:ctor(damage, score, displayAwards, starNum, specialAwardDatas, kingLvUpData, otherPic)
    self.uiIndex = GAME_UI.UI_FRIENDS_BOSS_RESULT
    self.displayAwards = displayAwards
    self.starNum = starNum
    self.specialAwardDatas = specialAwardDatas
    self.kingLvUpData = kingLvUpData
    self.damage = damage
    self.score = score
    self.otherPic = otherPic or true
end

function FriendsBossResultUI:init()
    local animationOver = false
    local otherAwardNum = #self.displayAwards
    
    local victoryBgImg = self.root:getChildByName("victory_bg_img")
    local victoryNode = victoryBgImg:getChildByName("victory_node")
    self:adaptUI(victoryBgImg, victoryNode)
    local originPosx, originPosy = victoryNode:getPosition()
    local infoLabel = victoryNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local mainImg = victoryNode:getChildByName("main_img")
    mainImg:setLocalZOrder(3)
    if self.otherPic then
        mainImg:loadTexture('uires/ui/battleresult/battleresult_001.png')
    end

    local damageBtn = mainImg:getChildByName("damage_btn")
    local damageLabel = damageBtn:getChildByName("text")
    damageLabel:setString(GlobalApi:getLocalStr("STR_STATISTICS"))
    damageBtn:addClickEventListener(function ()
        BattleMgr:showBattleDamageCount()
    end)

    local returnBtn = mainImg:getChildByName("return_btn")
    local returnLabel = returnBtn:getChildByName("text")
    returnLabel:setString(GlobalApi:getLocalStr("STR_RETURN_1"))
    returnBtn:addClickEventListener(function ()
        local function exitBattleCallBack()
            BattleMgr:hideFriendsBossResult()
            BattleMgr:exitBattleField()
        end
        if self.kingLvUpData and self.kingLvUpData.nowLv > self.kingLvUpData.lastLv then
            GlobalApi:showKingLvUp(self.kingLvUpData.lastLv,self.kingLvUpData.nowLv,nil,exitBattleCallBack)
        else
            exitBattleCallBack()
        end
        
    end)

    local lvImg = mainImg:getChildByName("lv_img")
    lvImg:setVisible(false)
    local lvLabel = mainImg:getChildByName("lv_tx")
    lvLabel:setVisible(false)
    local expImg = mainImg:getChildByName("exp_img")
    expImg:setVisible(false)
    local expLabel = mainImg:getChildByName("exp_tx")
    expLabel:setVisible(false)
    local goldImg = mainImg:getChildByName("gold_img")
    goldImg:setVisible(false)
    local goldLabel = mainImg:getChildByName("gold_tx")
    goldLabel:setVisible(false)

    local damageNameTx = ccui.Text:create()
    damageNameTx:setFontName("font/gamefont.ttf")
    damageNameTx:setFontSize(24)
    damageNameTx:setTextColor(COLOR_TYPE.YELLOW)
    damageNameTx:enableOutline(cc.c4b(138, 62, 16, 255), 1)
    damageNameTx:setString(GlobalApi:getLocalStr("STR_DAMAGE") .. "：")
    damageNameTx:setPosition(cc.p(160, 298))
    mainImg:addChild(damageNameTx)

    local damageTx = ccui.Text:create()
    damageTx:setFontName("font/gamefont.ttf")
    damageTx:setFontSize(22)
    damageTx:setAnchorPoint(cc.p(0, 0.5))
    damageTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    damageTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    damageTx:setString(GlobalApi:toWordsNumber(self.damage))
    damageTx:setPosition(cc.p(200, 298))
    mainImg:addChild(damageTx)

    local scoreNameTx = ccui.Text:create()
    scoreNameTx:setFontName("font/gamefont.ttf")
    scoreNameTx:setFontSize(24)
    scoreNameTx:setTextColor(COLOR_TYPE.YELLOW)
    scoreNameTx:enableOutline(cc.c4b(138, 62, 16, 255), 1)
    scoreNameTx:setString(GlobalApi:getLocalStr("SCORE"))
    scoreNameTx:setPosition(cc.p(360, 298))
    mainImg:addChild(scoreNameTx)

    local scoreTx = ccui.Text:create()
    scoreTx:setFontName("font/gamefont.ttf")
    scoreTx:setFontSize(22)
    scoreTx:setAnchorPoint(cc.p(0, 0.5))
    scoreTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    scoreTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    scoreTx:setString(tostring(self.score))
    scoreTx:setPosition(cc.p(400, 298))
    mainImg:addChild(scoreTx)

    local sv = mainImg:getChildByName("awards_sv")
    local svSize = sv:getContentSize()
    sv:setScrollBarEnabled(false)
    -- 奖励物品
    for i = 1, otherAwardNum do
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.displayAwards[i], sv)
        tab.lvTx:setAnchorPoint(cc.p(1, 0.5))
        tab.lvTx:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        tab.lvTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        tab.lvTx:setString(tostring(self.displayAwards[i]:getNum()))
        tab.lvTx:setPosition(cc.p(80, 16))
        tab.awardBgImg:setPosition(cc.p(55 + (i-1)*110, 60))
        ClassItemCell:setGodLight(tab.awardBgImg,self.displayAwards[i]:getGodId())
        if self.displayAwards[i]:getExtraBg() then
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
    victoryNode:addChild(ani)

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
                    BattleMgr:hideFriendsBossResult()
                    BattleMgr:exitBattleField()
                end
                if self.kingLvUpData and self.kingLvUpData.nowLv > self.kingLvUpData.lastLv then
                    GlobalApi:showKingLvUp(self.kingLvUpData.lastLv,self.kingLvUpData.nowLv,nil,exitBattleCallBack)
                else
                    exitBattleCallBack()
                end
            end
        end
    end)
end

return FriendsBossResultUI