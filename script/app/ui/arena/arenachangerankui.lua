local ArenaChangeRankUI = class("ArenaChangeRankUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ArenaChangeRankUI:ctor(headpic, quality,frame, name1, fightforce1, name2, fightforce2, rank1, rank2, diff)
    self.uiIndex = GAME_UI.UI_ARENA_CHANGERANK
    self.headpic = headpic
    self.quality = quality
    self.headframe = frame
    self.name1 = name1
    self.name2 = name2
    self.fightforce1 = fightforce1
    self.fightforce2 = fightforce2
    self.rank1 = rank1
    self.rank2 = rank2
    self.diff = diff
end

function ArenaChangeRankUI:init()
    local runFlag = true
    local arenarankBgImg = self.root:getChildByName("arenarank_bg_img")
    self:adaptUI(arenarankBgImg)

    local winSize = cc.Director:getInstance():getWinSize()
    local bgTx = arenarankBgImg:getChildByName("bg_tx")
    bgTx:setPosition(cc.p(winSize.width/2, winSize.height - 110))
    local infoLabel = arenarankBgImg:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:setPosition(cc.p(winSize.width/2, 30))

    local cardImg1 = arenarankBgImg:getChildByName("card_img_1")
    local cardImg2 = arenarankBgImg:getChildByName("card_img_2")
    local whiteImg1 = cardImg1:getChildByName("white_img")
    local whiteImg2 = cardImg2:getChildByName("white_img")
    whiteImg1:setVisible(false)
    whiteImg2:setVisible(false)
    cardImg2:setPosition(cc.p(winSize.width/2 - 150, winSize.height - 280))
    cardImg1:setPosition(cc.p(winSize.width/2 + 150, 150))

    local nameBg1 = cardImg1:getChildByName("name_bg")
    local nameLabel1 = nameBg1:getChildByName("name_tx")
    local rankImg1 = cardImg1:getChildByName("rank_img")
    local rankIconLabel1 = rankImg1:getChildByName("text")
    rankIconLabel1:setString(GlobalApi:getLocalStr("STR_RANK_1"))
    local rankLabel1 = cardImg1:getChildByName("rank_tx")
    local diffLabel1 = cardImg1:getChildByName("diff_tx")
    nameLabel1:setString(self.name1)
    rankLabel1:setString(self.rank1)
    diffLabel1:setString(self.diff)
    local fightforceLabel1 = cc.LabelAtlas:_create(tostring(self.fightforce1), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel1:setScale(0.7)
    fightforceLabel1:setPosition(cc.p(455, 50))
    fightforceLabel1:setAnchorPoint(cc.p(0, 0.5))
    cardImg1:addChild(fightforceLabel1)

    local nameBg2 = cardImg2:getChildByName("name_bg")
    local nameLabel2 = nameBg2:getChildByName("name_tx")
    local rankImg2 = cardImg2:getChildByName("rank_img")
    local rankIconLabel2 = rankImg2:getChildByName("text")
    rankIconLabel2:setString(GlobalApi:getLocalStr("STR_RANK_1"))
    local rankLabel2 = cardImg2:getChildByName("rank_tx")
    local diffLabel2 = cardImg2:getChildByName("diff_tx")
    
    nameLabel2:setString(self.name2)
    rankLabel2:setString(self.rank2)
    diffLabel2:setString(self.diff)
    local fightforceLabel2 = cc.LabelAtlas:_create(tostring(self.fightforce2), "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel2:setScale(0.7)
    fightforceLabel2:setPosition(cc.p(455, 50))
    fightforceLabel2:setAnchorPoint(cc.p(0, 0.5))
    cardImg2:addChild(fightforceLabel2)

    local headConf = GameData:getConfData("settingheadicon")
    local headpicUrl
    if tonumber(self.headpic) == 0 then
        headpicUrl = "uires/icon/hero/caocao_icon.png"
    else
        headpicUrl = headConf[self.headpic].icon
    end

    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    local headpicNode = cardImg1:getChildByName("headpic_node")
    headpicNode:addChild(cell.awardBgImg)
    cell.awardBgImg:loadTexture(RoleData:getMainRole():getBgImg())
    cell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
    cell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())

    local cell2 = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    local headpicNode2 = cardImg2:getChildByName("headpic_node")
    headpicNode2:addChild(cell2.awardBgImg)
    cell2.awardBgImg:loadTexture(COLOR_FRAME[self.quality])
    cell2.awardImg:loadTexture(headpicUrl)
    cell2.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.headframe))
    local bezier1 ={
        cc.p(winSize.width/2 + 150, 150),
        cc.p(winSize.width/2 + 400, winSize.height - 280),
        cc.p(winSize.width/2 - 150, winSize.height - 280)
    }
    local bezierAction1 = cc.BezierTo:create(0.5, bezier1)
    cardImg1:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), bezierAction1, cc.ScaleTo:create(0.1, 1.1), cc.CallFunc:create(function ()
            whiteImg1:setVisible(true)
            whiteImg1:setOpacity(0)
            whiteImg1:runAction(cc.Sequence:create(cc.FadeTo:create(0.1, 150), cc.FadeOut:create(0.1)))
        end), cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(function ()
        runFlag = false
    end)))

    local bezier2 ={
        cc.p(winSize.width/2 - 150, winSize.height - 280),
        cc.p(winSize.width/2 - 400, 150),
        cc.p(winSize.width/2 + 150, 150)
    }
    local bezierAction2 = cc.BezierTo:create(0.5, bezier2)
    cardImg2:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), bezierAction2, cc.ScaleTo:create(0.1, 1.1), cc.CallFunc:create(function ()
            whiteImg2:setVisible(true)
            whiteImg2:setOpacity(0)
            whiteImg2:runAction(cc.Sequence:create(cc.FadeTo:create(0.1, 150), cc.FadeOut:create(0.1)))
        end), cc.ScaleTo:create(0.1, 1), cc.CallFunc:create(function ()
        runFlag = false
    end)))

    arenarankBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if runFlag then
                runFlag = false
                cardImg1:stopAllActions()
                cardImg2:stopAllActions()
                whiteImg1:setVisible(false)
                whiteImg2:setVisible(false)
                cardImg1:setPosition(cc.p(winSize.width/2 - 150, winSize.height - 280))
                cardImg2:setPosition(cc.p(winSize.width/2 + 150, 150))
            else
                ArenaMgr:hideArenaChangeRank()
            end
        end
    end)
end

return ArenaChangeRankUI