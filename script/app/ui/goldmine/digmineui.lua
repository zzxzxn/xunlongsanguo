local DigMineUI = class("DigMineUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local MINE_TYPE = {
    EMPTY = "empty",
    DOOR = "door",
    MUD = "mud",
    ADAMAS = "adamas",
    DRAGON = "dragon",
    TREASURE = "treasure",
    GEM1 = "gem1",
    GEM2 = "gem2",
    GEM3 = "gem3",
    GEM4 = "gem4",
    GEM5 = "gem5",
    BOX0 = "box0",
    BOX1 = "box1",
    BOX2 = "box2",
    ENEMY1 = "enemy1",
    ENEMY2 = "enemy2",
    ENEMY3 = "enemy3",
    ERROR = "error"
}

local CAN_NOT_CROSS = {
    [MINE_TYPE.MUD] = 1,
    [MINE_TYPE.ADAMAS] = 1,
    [MINE_TYPE.TREASURE] = 1,
    [MINE_TYPE.DRAGON] = 1,
}

-- 横竖的矿的数量
local MAX_MINES_NUM_ROW = 10
local MAX_MINES_NUM_COL = 10

local LIGHT_ZORDER = 10000
local CONFIRM_BOMB_ZRODER = 20000
local BOMB_ANI_ZORDER = 30000
local DIG_EFFECT_ZORDER = 40000
local BOMB_CONFIRM_NODE_ZORDER = 100
local GUIDE_IMG_ZORDER = 9999

-- 每个矿的高宽
local MINE_WIDTH = 79
local MINE_HEIGHT = 79

-- 每个矿的横向和纵向间隔
local MINE_SPACE_ROW = 5
local MINE_SPACE_COL = 4

-- 矿区的可见区域的高
local MAX_DIG_HEIGHT = 550

-- 多个炸弹的间隔时间
local BOMB_INTERVAL = 0.05
-- 每个炸弹的动画持续时间
local BOMB_PLAY_TIME = 0.1

function DigMineUI:ctor(mineData)
    self.uiIndex = GAME_UI.UI_DIGMINE
    self.mineData = mineData
    self.digProductConf = GameData:getConfData("diggingproduct")
    self.treasureNum = 0    -- 宝藏数量
    self.maxTreasureNum = 1 -- 最大宝藏数量
    self.enemyNum = 0       -- 守护者数量
    self.boxNum = 0         -- 秘宝数量
    self.digTimes = self.mineData.digging.tool or 0       -- 剩余挖矿次数
    self.buyTimes = self.mineData.digging.buy or 0        -- 挖矿购买次数
    self.maxTims = tonumber(GlobalApi:getGlobalValue("diggingToolInit"))
    self.clickDragonRowIndex = 0
    self.clickDragonColIndex = 0
    self.minesObj = {}
    self.leftIsShow = true
    self.moveFlag = false
    if self.mineData.digging.level then
        self.mineLevel = tonumber(self.mineData.digging.level)
    else
        self.mineLevel = 1
    end
    self.bombAnis = {}
    self.confirmBombNode = {}
    local reward = self.mineData.digging.reward or {}
    self.boxReward = {}
    for k, v in pairs(reward) do
        self.boxReward[v] = true
    end
    self.bombObjs = {}
end

function DigMineUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bg_alpha = self.root:getChildByName("bg_alpha")
    bg_alpha:setContentSize(winsize)
    bg_alpha:setPosition(cc.p(winsize.width/2, winsize.height/2))

    self.bg_block_click = self.root:getChildByName("bg_block_click")
    self.bg_block_click:setContentSize(winsize)
    self.bg_block_click:setPosition(cc.p(winsize.width/2, winsize.height/2))
    self.bg_block_click:setVisible(false)

    self.bg_digmine = self.root:getChildByName("bg_digmine")
    self.bg_digmine:setPosition(cc.p(winsize.width/2, winsize.height/2))
    self:initMines()
    self:checkMinesClickable()
    self:initLeftPl(winsize)
    self:initRightProgressBar()
    self:initEatDragon(winsize)
    if self.treasureNum > 0 then
        self.isDigAllNormalMines = false
    else
        self.isDigAllNormalMines = true
    end
end

function DigMineUI:onShowUIAniOver()
    GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.DIGMINE)
end

function DigMineUI:onShow()
    self:updateLeftPl()
    local diggingbombConf = GameData:getConfData("diggingbomb")
    for i = 1, 2 do
        if diggingbombConf[i] then
            self.bombObjs[i] = BagData:getMaterialById(diggingbombConf[i].itemId)
            if self.bombObjs[i] == nil then
                self.bombObjs[i] = DisplayData:getDisplayObj({"material", diggingbombConf[i].itemId, 0})
            end
            if self.bombObjs[i]:getNum() > 0 then
                self.bombItemTx[i]:setVisible(true)
                self.bombItemTx[i]:setString(tostring(self.bombObjs[i]:getNum()))
            else
                self.bombItemTx[i]:setVisible(false)
            end
        end
    end
end

function DigMineUI:initEatDragon(winsize)
    self.bg_select_alpha = self.root:getChildByName("bg_select_alpha")
    self.bg_select_alpha:setVisible(false)
    self.bg_select_alpha:setPosition(cc.p(winsize.width/2, winsize.height/2))

    local bg_select = self.bg_select_alpha:getChildByName("bg_select")
    local title_bg = bg_select:getChildByName("title_bg")
    local title_tx = title_bg:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("SAVE_MR_DRAGON"))

    local restore_tx = bg_select:getChildByName("restore_tx")
    restore_tx:setString(GlobalApi:getGlobalValue("diggingDragonRecover"))

    local eat_btn = bg_select:getChildByName("eat_btn")
    local eat_tx = eat_btn:getChildByName("text")
    eat_tx:setString(GlobalApi:getLocalStr("EAT_DIG_DRAGON"))
    eat_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local obj = {
                x = self.clickDragonRowIndex,
                y = self.clickDragonColIndex,
                eat = 1
            }
            MessageMgr:sendPost("click_dragon", "digging", json.encode(obj), function(jsonObj)
                if jsonObj.code == 0 then
                    self:changeMine(self.clickDragonRowIndex, self.clickDragonColIndex, jsonObj.data.changed, false)
                    self.bg_select_alpha:setVisible(false)
                    local tool = jsonObj.data.tool or self.digTimes
                    local addDigTimes = tool - self.digTimes
                    self.digTimes = tool
                    if addDigTimes > 0 then
                        self.bg_block_click:setVisible(true)
                        self:showEatMeat(addDigTimes, function ()
                            self.bg_block_click:setVisible(false)
                            self:updateLeftPl()
                        end)
                    else
                        self:updateLeftPl()
                    end
                end
            end)
        end
    end)

    local release_btn = bg_select:getChildByName("release_btn")
    local release_tx = release_btn:getChildByName("text")
    release_tx:setString(GlobalApi:getLocalStr("RELEASE_DIG_DRAGON"))
    release_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local obj = {
                x = self.clickDragonRowIndex,
                y = self.clickDragonColIndex,
            }
            MessageMgr:sendPost("click_dragon", "digging", json.encode(obj), function(jsonObj)
                if jsonObj.code == 0 then
                    local updates = jsonObj.data.updates or {}
                    self.bg_select_alpha:setVisible(false)
                    self:bombOneRowOrCol(updates, jsonObj.data.change, self.clickDragonRowIndex, self.clickDragonColIndex)
                end
            end)
        end
    end)
    
    local dragonAni = ccui.ImageView:create('uires/ui/digmine/digmine_001.png')
    -- dragonAni:getAnimation():playWithIndex(0, -1, 1)
    dragonAni:setPosition(cc.p(374.5, 290))
    bg_select:addChild(dragonAni)

    local closeBtn = bg_select:getChildByName("close")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.bg_select_alpha:setVisible(false)
        end
    end)
end

function DigMineUI:initRightProgressBar()
    local winsize = cc.Director:getInstance():getWinSize()

    local bg_progress = self.root:getChildByName("bg_progress")
    bg_progress:setPosition(cc.p(winsize.width - 48, winsize.height / 2))
    self.progress_bar = bg_progress:getChildByName("progress_bar")
    local barSize = bg_progress:getContentSize()
    local diggingprogressConf = GameData:getConfData("diggingprogress")
    local diggingeventConf = GameData:getConfData("diggingevent")
    self.maxTreasureNum = diggingprogressConf[3].progress
    self.digBoxArr = {}
    for i = 1, 3 do
        local needNum = diggingprogressConf[i].progress
        local box_node = bg_progress:getChildByName("box_node_" .. i)
        local box_img = box_node:getChildByName("box_img")
        local num_tx = box_node:getChildByName("num_tx")
        num_tx:setString(tostring(needNum))
        local unknow_light = box_node:getChildByName("unknow_light")
        unknow_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
        local unknow_img = box_node:getChildByName("unknow_img")
        self.digBoxArr[i] = {}
        self.digBoxArr[i].box = box_img
        self.digBoxArr[i].numTx = num_tx
        self.digBoxArr[i].light = unknow_light
        self.digBoxArr[i].unknowImg = unknow_img
        box_node:setPositionX(barSize.width*needNum/self.maxTreasureNum - 10)
        if self.boxReward[i] then
            self.digBoxArr[i].status = 2
            self.digBoxArr[i].numTx:setVisible(false)
            self.digBoxArr[i].light:setVisible(false)
            self.digBoxArr[i].unknowImg:setVisible(false)
            box_img:loadTexture("uires/ui/common/box" .. i .. ".png")
        else
            if self.maxTreasureNum - self.treasureNum >= needNum then
                self.digBoxArr[i].status = 1
                local boxSize = self.digBoxArr[i].box:getContentSize()
                local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
                particle:setLocalZOrder(-1)
                particle:setScale(0.5)
                particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                particle:setPosition(cc.p(boxSize.width/2, boxSize.height/2))
                self.digBoxArr[i].box:addChild(particle)
                self.digBoxArr[i].particle = particle
            else
                ShaderMgr:setGrayForWidget(box_img)
                self.digBoxArr[i].status = 0
            end
        end
        self.digBoxArr[i].needNum = needNum

        local boxObj = nil
        if i == 3 then
            boxObj = DisplayData:getDisplayObj({"material", diggingeventConf[self.mineLevel].endBox, 0})
        else
            boxObj = DisplayData:getDisplayObj({"material", diggingprogressConf[i].boxId, 0})
        end
        box_img:setTouchEnabled(true)
        box_img:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.digBoxArr[i].status == 0 then
                    GetWayMgr:showGetwayUI2(boxObj, false)
                elseif self.digBoxArr[i].status == 1 then
                    if i == 3 then
                        DigMineMgr:showDigMineEvent("reward", nil, function ()
                            self:openRewardBox(i)
                        end)
                    else
                        self:openRewardBox(i)
                    end
                end
            end
        end)
    end
    local progress = 100*(self.maxTreasureNum - self.treasureNum)/self.maxTreasureNum
    progress = progress > 100 and 100 or progress
    self.progress_bar:setPercent(progress)

    local help_btn = HelpMgr:getBtn(HELP_SHOW_TYPE.MINEUI)
    help_btn:setPosition(cc.p(900, 670))
    self.bg_digmine:addChild(help_btn)
end

function DigMineUI:updateRightProgressBar()
    for i = 1, 3 do
        if self.digBoxArr[i].status == 0 and self.maxTreasureNum - self.treasureNum >= self.digBoxArr[i].needNum then
            ShaderMgr:restoreWidgetDefaultShader(self.digBoxArr[i].box)
            self.digBoxArr[i].status = 1
            local boxSize = self.digBoxArr[i].box:getContentSize()
            local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
            particle:setLocalZOrder(-1)
            particle:setScale(0.5)
            particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
            particle:setPosition(cc.p(boxSize.width/2, boxSize.height/2))
            self.digBoxArr[i].box:addChild(particle)
            self.digBoxArr[i].particle = particle
        end
    end
    local progress = 100*(self.maxTreasureNum - self.treasureNum)/self.maxTreasureNum
    progress = progress > 100 and 100 or progress
    self.progress_bar:setPercent(progress)
end

function DigMineUI:initLeftPl(winsize)
    local left_node = self.root:getChildByName("left_node") 
    left_node:setPosition(cc.p(0, winsize.height/2))
    local left_img = left_node:getChildByName("left_img")
    local close_btn = left_img:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            DigMineMgr:hideDigMine()
        end
    end)

    local unknow_light = left_img:getChildByName("unknow_light")
    unknow_light:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))

    local desc_tx_1 = left_img:getChildByName("desc_tx_1")
    desc_tx_1:setString(GlobalApi:getLocalStr("DIG_MINE_TREASURE") .. "：")

    local desc_tx_2 = left_img:getChildByName("desc_tx_2")
    desc_tx_2:setString(GlobalApi:getLocalStr("DIG_MINE_ENEMY") .. "：")

    local desc_tx_3 = left_img:getChildByName("desc_tx_3")
    desc_tx_3:setString(GlobalApi:getLocalStr("DIG_MINE_BOX") .. "：")

    local desc_tx_4 = left_img:getChildByName("desc_tx_4")
    desc_tx_4:setString(GlobalApi:getLocalStr("DIG_MINE_TIPS_1"))

    local desc_tx_5 = left_img:getChildByName("desc_tx_5")
    desc_tx_5:setString(GlobalApi:getLocalStr("CLICK_USE_ITEM"))

    self.unknow_tx = left_img:getChildByName("unknow_tx")
    self.unknow_tx:setString(tostring(self.treasureNum))

    self.monster_tx = left_img:getChildByName("monster_tx")
    self.monster_tx:setString(tostring(self.enemyNum))

    self.box_tx = left_img:getChildByName("box_tx")
    self.box_tx:setString(tostring(self.boxNum))

    local diggingeventConf = GameData:getConfData("diggingevent")
    local boxObj = DisplayData:getDisplayObj({"material", diggingeventConf[self.mineLevel].endBox, 0})
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, boxObj, left_img)
    cell.awardBgImg:setScale(0.8)
    local box_posX, box_posY = self.box_tx:getPosition()
    cell.awardBgImg:setPosition(cc.p(box_posX - 10, box_posY - 110))

    local diggingbombConf = GameData:getConfData("diggingbomb")
    self.bombItemImg = {}
    self.bombItemTx = {}
    for i = 1, 2 do
        if diggingbombConf[i] then
            self.bombObjs[i] = BagData:getMaterialById(diggingbombConf[i].itemId)
            if self.bombObjs[i] == nil then
                self.bombObjs[i] = DisplayData:getDisplayObj({"material", diggingbombConf[i].itemId, 0})
            end
            self.bombItemImg[i] = ccui.ImageView:create(self.bombObjs[i]:getIcon())
            self.bombItemImg[i]:setVisible(false)
            left_node:addChild(self.bombItemImg[i])
            local confirmBombImg = ccui.ImageView:create(self.bombObjs[i]:getIcon())
            local confirmBombSize = confirmBombImg:getContentSize()
            confirmBombImg:setVisible(false)
            confirmBombImg:setLocalZOrder(CONFIRM_BOMB_ZRODER)
            self.mine_node:addChild(confirmBombImg)
            local confirmBombRedImg = ccui.ImageView:create("uires/ui/common/bg_red2.png")
            confirmBombRedImg:setScale9Enabled(true)
            if diggingbombConf[i].effect == "row" then
                local rowWidth = MAX_MINES_NUM_ROW*MINE_WIDTH + MINE_SPACE_ROW*(MAX_MINES_NUM_ROW + 1)
                confirmBombRedImg:setContentSize(cc.size(rowWidth*3, MINE_HEIGHT + MINE_SPACE_COL))
            else
                local colHeight = MAX_MINES_NUM_COL*MINE_HEIGHT + MINE_SPACE_COL*(MAX_MINES_NUM_COL + 1)
                confirmBombRedImg:setContentSize(cc.size(MINE_WIDTH + MINE_SPACE_ROW, colHeight*3))
            end
            confirmBombRedImg:setPosition(cc.p(confirmBombSize.width/2, confirmBombSize.height/2))
            confirmBombImg:addChild(confirmBombRedImg)

            local confirmNode = cc.Node:create()
            confirmNode:setVisible(false)
            confirmNode:setLocalZOrder(BOMB_CONFIRM_NODE_ZORDER)
            local confirmImg = ccui.ImageView:create("uires/ui/digmine/confirm_img.png")
            local cancelImg = ccui.ImageView:create("uires/ui/digmine/cancel_img.png")
            confirmImg:setTouchEnabled(true)
            cancelImg:setTouchEnabled(true)
            confirmImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local obj = {
                        id = i,
                        x = self.confirmBombNode[i].row,
                        y = self.confirmBombNode[i].col
                    }
                    MessageMgr:sendPost("bomb", "digging", json.encode(obj), function(jsonObj)
                        if jsonObj.code == 0 then
                            self.confirmBombNode[i].img:setVisible(false)
                            self.confirmBombNode[i].confirm:setVisible(false)
                            if jsonObj.data.costs then
                                GlobalApi:parseAwardData(jsonObj.data.costs)
                            end
                            local diggingbombConf2 = GameData:getConfData("diggingbomb")
                            if diggingbombConf2[i] then
                                self.bombObjs[i] = BagData:getMaterialById(diggingbombConf2[i].itemId)
                                if self.bombObjs[i] == nil then
                                    self.bombObjs[i] = DisplayData:getDisplayObj({"material", diggingbombConf2[i].itemId, 0})
                                end
                                if self.bombObjs[i]:getNum() > 0 then
                                    self.bombItemTx[i]:setVisible(true)
                                    self.bombItemTx[i]:setString(tostring(self.bombObjs[i]:getNum()))
                                else
                                    self.bombItemTx[i]:setVisible(false)
                                end
                            end
                            local updates = jsonObj.data.updates or {}
                            self:bombOneRowOrCol(updates, jsonObj.data.change, self.confirmBombNode[i].row, self.confirmBombNode[i].col)
                        end
                    end)
                end
            end)
            cancelImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self.confirmBombNode[i].img:setVisible(false)
                    self.confirmBombNode[i].confirm:setVisible(false)
                    self.bg_block_click:setVisible(false)
                end
            end)
            confirmImg:setPosition(cc.p(-60, 0))
            cancelImg:setPosition(cc.p(60, 0))
            confirmNode:addChild(confirmImg)
            confirmNode:addChild(cancelImg)
            self.root:addChild(confirmNode)
            self.confirmBombNode[i] = {
                img = confirmBombImg,
                confirm = confirmNode,
                row = 1,
                col = 1
            }

            local awardCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.bombObjs[i], left_img)
            awardCell.awardBgImg:setPosition(cc.p(80*i, 160))
            awardCell.awardBgImg:setScale(0.7)
            if self.bombObjs[i]:getNum() > 0 then
                awardCell.lvTx:setString(tostring(self.bombObjs[i]:getNum()))
            end
            self.bombItemTx[i] = awardCell.lvTx
            local startPos
            local itemCurrPos
            local movePos
            local startShow = false
            awardCell.awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                    if self.bombObjs[i]:getNum() <= 0 then
                        return
                    end
                    startPos = sender:getTouchBeganPosition()
                    itemCurrPos = left_img:convertToWorldSpace(cc.p(awardCell.awardBgImg:getPosition()))
                elseif eventType == ccui.TouchEventType.canceled then
                    if self.bombObjs[i]:getNum() <= 0 then
                        return
                    end
                    if movePos then
                        local mineObj = self:getMineByPosition(movePos)
                        if mineObj and mineObj.mineType == MINE_TYPE.EMPTY then
                            self:showBombRowOrCol(i, mineObj)
                        else
                            promptmgr:showSystenHint(GlobalApi:getLocalStr("DIG_MINE_BOMB_TIPS_1"), COLOR_TYPE.RED)
                        end
                    end
                    self.bombItemImg[i]:setVisible(false)
                    startShow = false
                    movePos = nil
                elseif eventType == ccui.TouchEventType.ended then
                    if self.bombObjs[i]:getNum() > 0 then
                        GetWayMgr:showGetwayUI(self.bombObjs[i], false)
                    else
                        GetWayMgr:showGetwayUI(self.bombObjs[i], true)
                    end
                    self.bombItemImg[i]:setVisible(false)
                    startShow = false
                    movePos = nil
                elseif eventType == ccui.TouchEventType.moved then
                    if self.bombObjs[i]:getNum() <= 0 then
                        return
                    end
                    movePos = sender:getTouchMovePosition()
                    if not startShow then
                        local dis = cc.pGetDistance(movePos,itemCurrPos)
                        if dis > 40 then
                            self:hideLeftPl()
                            self.bombItemImg[i]:setVisible(true)
                            startShow = true
                        end
                    end
                    self.bombItemImg[i]:setPosition(left_node:convertToNodeSpace(movePos))
                end
            end)
        end
    end

    self.hide_btn = left_img:getChildByName("hide_btn")
    self.hide_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:showOrHideLeftPl()
        end
    end)

    self.block_left_img = left_img:getChildByName("block_left_img")
    self.leftImgSize = left_img:getContentSize()
    self.block_left_img:setContentSize(self.leftImgSize)
    self.block_left_img:setVisible(false)
    self.left_img = left_img

    local bg_meat = left_node:getChildByName("bg_meat")
    self.meat_tx = bg_meat:getChildByName("meat_tx")
    self.meat_tx:setString(self.digTimes .. "/" .. self.maxTims)
    bg_meat:setPosition(cc.p(60, winsize.height/2 - 30))
    local add_btn = bg_meat:getChildByName("add_btn")
    add_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.digTimes >= self.maxTims then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("TIMES_FULL_NO_NEED_BUY"), COLOR_TYPE.RED)
            else
                local buyConf = GameData:getConfData("buy")
                local costCash = nil
                if self.buyTimes >= #buyConf then
                    costCash = buyConf[#buyConf].diggingBuy
                else
                    costCash = buyConf[self.buyTimes+1].diggingBuy
                end
                local cash = UserData:getUserObj():getCash()
                if cash < costCash then -- 元宝不足
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
                else
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL"), costCash, tonumber(GlobalApi:getGlobalValue("diggingToolPerDeal"))), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        MessageMgr:sendPost("buy_tool", "digging", "{}", function(jsonObj)
                            if jsonObj.code == 0 then
                                self.buyTimes = self.buyTimes + 1
                                self.digTimes = jsonObj.data.tool or self.digTimes
                                if jsonObj.data.costs then
                                    GlobalApi:parseAwardData(jsonObj.data.costs)
                                end
                                self:updateLeftPl()
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("SUCCESS_BUY"), COLOR_TYPE.GREEN)
                            end
                        end)
                    end)
                end
            end
        end
    end)
end

function DigMineUI:showOrHideLeftPl()
    if self.left_img:getNumberOfRunningActions() > 0 then
        return
    end
    if self.leftIsShow then
        self.block_left_img:setVisible(true)
        self.hide_btn:setTouchEnabled(false)
        local winsize = cc.Director:getInstance():getWinSize()
        self.left_img:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-self.leftImgSize.width, -10)),cc.CallFunc:create(function()
            self.hide_btn:loadTexture("uires/ui/digmine/btn_show.png")
            self.block_left_img:setVisible(false)
            self.hide_btn:setTouchEnabled(true)
        end)))
        self.leftIsShow = false
    else
        self.block_left_img:setVisible(true)
        self.hide_btn:setTouchEnabled(false)
        local winsize = cc.Director:getInstance():getWinSize()
        self.left_img:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(0, -10)),cc.CallFunc:create(function()
            self.hide_btn:loadTexture("uires/ui/digmine/btn_hide.png")
            self.block_left_img:setVisible(false)
            self.hide_btn:setTouchEnabled(true)
        end)))
        self.leftIsShow = true
    end
end

function DigMineUI:hideLeftPl()
    if self.leftIsShow then
        self.block_left_img:setVisible(true)
        self.hide_btn:setTouchEnabled(false)
        local winsize = cc.Director:getInstance():getWinSize()
        self.left_img:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(-self.leftImgSize.width, -10)),cc.CallFunc:create(function()
            self.hide_btn:loadTexture("uires/ui/digmine/btn_show.png")
            self.block_left_img:setVisible(false)
            self.hide_btn:setTouchEnabled(true)
        end)))
        self.leftIsShow = false
    end
end

function DigMineUI:showLeftPl()
    if not self.leftIsShow then
        self.block_left_img:setVisible(true)
        self.hide_btn:setTouchEnabled(false)
        local winsize = cc.Director:getInstance():getWinSize()
        self.left_img:runAction(cc.Sequence:create(cc.MoveTo:create(0.2, cc.p(0, -10)),cc.CallFunc:create(function()
            self.hide_btn:loadTexture("uires/ui/digmine/btn_hide.png")
            self.block_left_img:setVisible(false)
            self.hide_btn:setTouchEnabled(true)
        end)))
        self.leftIsShow = true
    end
end

function DigMineUI:updateLeftPl()
    self.meat_tx:setString(self.digTimes .. "/" .. self.maxTims)
    self.unknow_tx:setString(tostring(self.treasureNum))
    self.monster_tx:setString(tostring(self.enemyNum))
    self.box_tx:setString(tostring(self.boxNum))
end

function DigMineUI:checkMinesClickable()
    for rowIndex, rowMines in pairs(self.minesObj) do
        for colIndex, mineObj in pairs(rowMines) do
            if mineObj.mineType == MINE_TYPE.EMPTY or mineObj.mineType == MINE_TYPE.DOOR then
                self:lightRoundMines(rowIndex, colIndex)
            elseif CAN_NOT_CROSS[mineObj.mineType] == nil then
                if not self:checkRoundMines(rowIndex, colIndex) then
                    self:lightRoundMines(rowIndex, colIndex)
                end
            end
        end
    end
end

function DigMineUI:initMines()
    local touch_img = self.bg_digmine:getChildByName("touch_img")
    touch_img:setSwallowTouches(false)
    local beganPos = nil
    local preMovePos = nil
    local movePos = nil
    local limitLH = 0
    local limitRH = MAX_MINES_NUM_COL*MINE_HEIGHT + (MAX_MINES_NUM_COL + 1)*MINE_SPACE_COL - MAX_DIG_HEIGHT
    local targetPos = cc.p(0, 0)
    local bgImgPosY = 0
    touch_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            preMovePos = movePos
            movePos = sender:getTouchMovePosition()
            if preMovePos then
                targetPos.y = bgImgPosY + movePos.y - preMovePos.y
                if targetPos.y < limitLH then
                    targetPos.y = limitLH
                end
                if targetPos.y > limitRH then
                    targetPos.y = limitRH
                end
                bgImgPosY = targetPos.y
                self.mine_node:setPosition(targetPos)
            end
            if not self.moveFlag then
                local dis = cc.pGetDistance(beganPos, movePos)
                if dis > MINE_WIDTH/2 then
                    self.moveFlag = true
                end
            end
        elseif eventType == ccui.TouchEventType.began then
            touch_img:stopAllActions()
            preMovePos = nil
            movePos = nil
            beganPos = sender:getTouchBeganPosition()
            self.moveFlag = false
        elseif eventType == ccui.TouchEventType.ended or eventType == ccui.TouchEventType.canceled then
            touch_img:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
                self.moveFlag = false
            end)))
        end
    end)

    local winsize = cc.Director:getInstance():getWinSize()

    self.block_img = self.bg_digmine:getChildByName("block_img")
    self.block_img:setVisible(false)
    self.mine_pl = self.bg_digmine:getChildByName("mine_pl")
    self.mine_pl:setPositionX(self.mine_pl:getPositionX() + (winsize.width - 960) / 4)

    self.minePlSize = self.mine_pl:getContentSize()
    self.mine_node = self.mine_pl:getChildByName("mine_node")

    local rowWidth = MAX_MINES_NUM_ROW*MINE_WIDTH + MINE_SPACE_ROW*(MAX_MINES_NUM_ROW + 1)
    local colHeight = MAX_MINES_NUM_COL*MINE_HEIGHT + MINE_SPACE_COL*(MAX_MINES_NUM_COL + 1)
    local bg_mine = ccui.ImageView:create("uires/ui/digmine/bg_mine.png")
    local bgMineSize = bg_mine:getContentSize()
    bg_mine:setPosition(cc.p(0, MAX_DIG_HEIGHT))
    self.mine_node:addChild(bg_mine)
    local bgMineRowNum = math.ceil(rowWidth/bgMineSize.width) + 1
    local bgMineColNum = math.ceil(colHeight/bgMineSize.height) + 1
    for i = 1, bgMineRowNum do
        for j = 1, bgMineColNum do
            if i ~= 1 or j ~= 1 then
                local bg_mine2 = ccui.ImageView:create("uires/ui/digmine/bg_mine.png")
                bg_mine2:setPosition(cc.p((i-1)*bgMineSize.width, MAX_DIG_HEIGHT - (j-1)*bgMineSize.height))
                self.mine_node:addChild(bg_mine2)
            end
        end
    end

    local mines = self.mineData.digging.ground
    for rowIndex, rowMines in pairs(mines) do
        for colIndex, mineType in pairs(rowMines) do
            rowIndex = tonumber(rowIndex)
            colIndex = tonumber(colIndex)
            self.minesObj[rowIndex] = self.minesObj[rowIndex] or {}
            self.minesObj[rowIndex][colIndex] = self.minesObj[rowIndex][colIndex] or {}
            self.minesObj[rowIndex][colIndex].row = rowIndex
            self.minesObj[rowIndex][colIndex].col = colIndex
            local node = nil
            local mineTypeName = nil
            if mineType == 0 then
                mineTypeName = MINE_TYPE.EMPTY
            elseif self.digProductConf[mineType] then
                mineTypeName = self.digProductConf[mineType].key
                node = self:createMine(mineType, mineTypeName, rowIndex, colIndex)
            else
                mineTypeName = MINE_TYPE.ERROR
            end
            self.minesObj[rowIndex][colIndex].node = node
            self.minesObj[rowIndex][colIndex].mineType = mineTypeName
            self.minesObj[rowIndex][colIndex].mineId = mineType
        end
    end
end

function DigMineUI:createNormalMine(rowIndex, colIndex)
    local normalMineImg = ccui.ImageView:create("uires/ui/digmine/mine_1.png")
    normalMineImg:setTouchEnabled(true)
    normalMineImg:addClickEventListener(function ()
        if not self.moveFlag then
            if self.minesObj[rowIndex][colIndex] and self.minesObj[rowIndex][colIndex].clickable then
                if self.digTimes > 0 then
                    local obj = {
                        x = rowIndex,
                        y = colIndex
                    }
                    MessageMgr:sendPost("dig", "digging", json.encode(obj), function(jsonObj)
                        if jsonObj.code == 0 then
                            self.block_img:setVisible(true)
                            self:showDigEffect(rowIndex, colIndex)
                            local changed = jsonObj.data.changed
                            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),cc.CallFunc:create(function()
                                self.block_img:setVisible(false)
                                self:changeMine(rowIndex, colIndex, changed, true)
                            end)))
                        end
                    end)
                else
                    local buyConf = GameData:getConfData("buy")
                    local costCash = nil
                    if self.buyTimes >= #buyConf then
                        costCash = buyConf[#buyConf].diggingBuy
                    else
                        costCash = buyConf[self.buyTimes+1].diggingBuy
                    end
                    local cash = UserData:getUserObj():getCash()
                    if cash < costCash then -- 元宝不足
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                            GlobalApi:getGotoByModule("cash")
                        end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                    else
                        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL"), costCash, tonumber(GlobalApi:getGlobalValue("diggingToolPerDeal"))), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            MessageMgr:sendPost("buy_tool", "digging", "{}", function(jsonObj)
                                if jsonObj.code == 0 then
                                    self.buyTimes = self.buyTimes + 1
                                    self.digTimes = jsonObj.data.tool or self.digTimes
                                    if jsonObj.data.costs then
                                        GlobalApi:parseAwardData(jsonObj.data.costs)
                                    end
                                    self:updateLeftPl()
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr("SUCCESS_BUY"), COLOR_TYPE.GREEN)
                                end
                            end)
                        end)
                    end
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_NO_DIG"), COLOR_TYPE.RED)
            end
        end
    end)
    normalMineImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(normalMineImg)
    return normalMineImg
end

function DigMineUI:createDoor(rowIndex, colIndex)
    local doorImg = ccui.ImageView:create("uires/ui/digmine/door.png")
    doorImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    doorImg:setTouchEnabled(true)
    doorImg:addClickEventListener(function ()
        DigMineMgr:hideDigMine()
    end)
    self.mine_node:addChild(doorImg)
    return doorImg
end

function DigMineUI:createAdamas(rowIndex, colIndex)
    local adamasImg = ccui.ImageView:create("uires/ui/digmine/mine_2.png")
    adamasImg:setTouchEnabled(true)
    adamasImg:addClickEventListener(function ()
        if not self.moveFlag then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("CAN_NOT_DIG_ADAMAS"), COLOR_TYPE.RED)
        end
    end)
    adamasImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(adamasImg)
    return adamasImg
end

function DigMineUI:createDragon(rowIndex, colIndex)
    local dragonWidget = ccui.Widget:create()
    dragonWidget:setContentSize(cc.size(MINE_WIDTH, MINE_HEIGHT))
    dragonWidget:setTouchEnabled(true)
    dragonWidget:addClickEventListener(function ()
        if not self.moveFlag then
            if self.minesObj[rowIndex][colIndex] and self.minesObj[rowIndex][colIndex].clickable then
                self.clickDragonRowIndex = rowIndex
                self.clickDragonColIndex = colIndex
                self.bg_select_alpha:setVisible(true)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_NO_DIG"), COLOR_TYPE.RED)
            end
        end
    end)
    local dragonAni = ccui.ImageView:create('uires/ui/digmine/digmine_001.png')
    dragonAni:setScale(0.5)
    -- dragonAni:getAnimation():playWithIndex(0, -1, 1)
    dragonAni:setPosition(cc.p(MINE_WIDTH/2, MINE_HEIGHT/2))
    dragonWidget:addChild(dragonAni)
    dragonWidget:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(dragonWidget)
    return dragonWidget
end

function DigMineUI:createTreasure(rowIndex, colIndex)
    self.treasureNum = self.treasureNum + 1
    local treasureBgImg = ccui.ImageView:create("uires/ui/digmine/mine_1.png")
    local treasureLight = ccui.ImageView:create("uires/ui/digmine/digmine_unknow_light.png")
    treasureLight:setPosition(cc.p(MINE_WIDTH/2, MINE_HEIGHT/2))
    treasureBgImg:addChild(treasureLight)
    local treasureImg = ccui.ImageView:create("uires/ui/digmine/digmine_unknow.png")
    treasureImg:setPosition(cc.p(MINE_WIDTH/2, MINE_HEIGHT/2))
    treasureBgImg:addChild(treasureImg)
    treasureLight:runAction(cc.RepeatForever:create(cc.RotateBy:create(4, 360)))
    treasureBgImg:setTouchEnabled(true)
    treasureBgImg:addClickEventListener(function ()
        if not self.moveFlag then
            if self.minesObj[rowIndex][colIndex] and self.minesObj[rowIndex][colIndex].clickable then
                if self.digTimes > 0 then
                    local obj = {
                        x = rowIndex,
                        y = colIndex
                    }
                    MessageMgr:sendPost("dig", "digging", json.encode(obj), function(jsonObj)
                        if jsonObj.code == 0 then
                            self.block_img:setVisible(true)
                            self:showDigEffect(rowIndex, colIndex)
                            local changed = jsonObj.data.changed
                            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1.2),cc.CallFunc:create(function()
                                self.block_img:setVisible(false)
                                self:changeMine(rowIndex, colIndex, changed, true)
                                self:digAllNormalMines()
                            end)))
                        end
                    end)
                else
                    local buyConf = GameData:getConfData("buy")
                    local costCash = nil
                    if self.buyTimes >= #buyConf then
                        costCash = buyConf[#buyConf].diggingBuy
                    else
                        costCash = buyConf[self.buyTimes+1].diggingBuy
                    end
                    local cash = UserData:getUserObj():getCash()
                    if cash < costCash then -- 元宝不足
                        promptmgr:showMessageBox(GlobalApi:getLocalStr("NOT_ENOUGH_GOTO_BUY"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                            GlobalApi:getGotoByModule("cash")
                        end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
                    else
                        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL"), costCash, tonumber(GlobalApi:getGlobalValue("diggingToolPerDeal"))), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            MessageMgr:sendPost("buy_tool", "digging", "{}", function(jsonObj)
                                if jsonObj.code == 0 then
                                    self.buyTimes = self.buyTimes + 1
                                    self.digTimes = jsonObj.data.tool or self.digTimes
                                    if jsonObj.data.costs then
                                        GlobalApi:parseAwardData(jsonObj.data.costs)
                                    end
                                    self:updateLeftPl()
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr("SUCCESS_BUY"), COLOR_TYPE.GREEN)
                                end
                            end)
                        end)
                    end
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_NO_DIG"), COLOR_TYPE.RED)
            end
        end
    end)
    treasureBgImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(treasureBgImg)
    return treasureBgImg
end

function DigMineUI:createBox(mineType, rowIndex, colIndex, boxType)
    self.boxNum = self.boxNum + 1
    local boxImg = ccui.ImageView:create("uires/ui/digmine/digmine_box.png")
    local numTx = ccui.Text:create()
    numTx:setFontName("font/gamefont.ttf")
    numTx:setFontSize(24)
    numTx:enableOutline(COLOR_TYPE.BLACK, 1)
    numTx:setPosition(cc.p(70, 10))
    numTx:setAnchorPoint(cc.p(1,0.5))
    numTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    numTx:setString(tostring(3 - boxType))
    boxImg:addChild(numTx)
    boxImg:setTouchEnabled(true)
    boxImg:addClickEventListener(function ()
        if not self.moveFlag then
            local needCash = 0
            if self.digProductConf[mineType] then
                needCash = self.digProductConf[mineType].cash
            end
            if UserData:getUserObj():getCash() >= needCash then
                local eventObj = {
                    times = boxType,
                    needCash = needCash
                }
                DigMineMgr:showDigMineEvent("box", eventObj, function ()
                    local obj = {
                        x = rowIndex,
                        y = colIndex
                    }
                    MessageMgr:sendPost("open_box", "digging", json.encode(obj), function(jsonObj)
                        if jsonObj.code == 0 then
                            if jsonObj.data.awards then
                                GlobalApi:parseAwardData(jsonObj.data.awards)
                                if jsonObj.data.awards[1] then
                                    local diggingeventConf = GameData:getConfData("diggingevent")
                                    local itemConf = GameData:getConfData("item")
                                    local dropConf = GameData:getConfData("drop")
                                    local itemId = diggingeventConf[self.mineLevel]["box" .. boxType]
                                    local tab = string.split(itemConf[itemId].useEffect, ":")
                                    local tab2 = string.split(tab[1], ".")
                                    local dropObj = dropConf[tonumber(tab2[2])]
                                    local randAwards = {}
                                    if next(dropObj.fixed) ~= nil then
                                        table.insert(randAwards, dropObj.fixed)
                                    end
                                    for i = 1, 15 do
                                        if dropObj["award" .. i] and next(dropObj["award" .. i]) ~= nil then
                                            table.insert(randAwards, dropObj["award" .. i])
                                        end
                                    end
                                    DigMineMgr:showSixSelectOneAward(jsonObj.data.awards, randAwards)
                                end
                            end
                            if jsonObj.data.costs then
                                GlobalApi:parseAwardData(jsonObj.data.costs)
                            end
                            self:changeMine(rowIndex, colIndex, jsonObj.data.changed, false)
                        end
                    end)
                end)
            else
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("CASH_NOT_ENOUGH_GOTO_RECHARGE"), needCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        GlobalApi:getGotoByModule("cash")
                    end,GlobalApi:getLocalStr("MESSAGE_GO_CASH"),GlobalApi:getLocalStr("MESSAGE_NO"))
            end
        end
    end)
    boxImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(boxImg)
    return boxImg
end

function DigMineUI:createEnemy(rowIndex, colIndex, mineTypeName, enemyLevel)
    self.enemyNum = self.enemyNum + 1
    local enemyImg
    if enemyLevel > 1 then
        enemyImg = ccui.ImageView:create("uires/ui/digmine/digmine_monster.png")
    else
        enemyImg = ccui.ImageView:create("uires/ui/digmine/digmine_monster2.png")
    end
    enemyImg:setTouchEnabled(true)
    enemyImg:addClickEventListener(function ()
        if not self.moveFlag then
            DigMineMgr:showDigMineEvent("monster", nil, function ()
                local obj = {
                    x = rowIndex,
                    y = colIndex
                }
                if enemyLevel == 1 then
                    MessageMgr:sendPost("click_enemy", "digging", json.encode(obj), function(jsonObj)
                        if jsonObj.code == 0 then
                            local awards = jsonObj.data.awards
                            if awards then
                                GlobalApi:parseAwardData(awards)
                                GlobalApi:showAwardsCommon(awards,nil,nil,true)
                            end
                            self:changeMine(rowIndex, colIndex, 0, false)
                        end
                    end)
                else
                    MessageMgr:sendPost("get_enemy", "digging", json.encode(obj), function(jsonObj)
                        if jsonObj.code == 0 then
                            local customObj  = {
                                x = rowIndex,
                                y = colIndex,
                                info = jsonObj.data.enemy
                            }
                            BattleMgr:playBattle(BATTLE_TYPE.DIGGING, customObj, function ()
                                MainSceneMgr:showMainCity(function()
                                    DigMineMgr:showDigMine()
                                end, nil, GAME_UI.UI_DIGMINE)
                            end)
                        end
                    end)
                end
            end)
        end
    end)
    enemyImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(enemyImg)
    return enemyImg
end

function DigMineUI:createGem(rowIndex, colIndex, gemLevel)
    local gemImg = ccui.ImageView:create("uires/icon/dragon/dragon_fragment_1.png")
    gemImg:setTouchEnabled(true)
    gemImg:addClickEventListener(function ()
        if not self.moveFlag then
            local obj = {
                x = rowIndex,
                y = colIndex
            }
            MessageMgr:sendPost("collect", "digging", json.encode(obj), function(jsonObj)
                if jsonObj.code == 0 then
                    if jsonObj.data.awards then
                        GlobalApi:parseAwardData(jsonObj.data.awards)
                        GlobalApi:showAwardsCommon(jsonObj.data.awards)
                    end
                    self:changeMine(rowIndex, colIndex, 0, false)
                end
            end)
        end
    end)
    gemImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    self.mine_node:addChild(gemImg)
    return gemImg
end

function DigMineUI:createMine(mineType, mineTypeName, rowIndex, colIndex)
    local node
    if mineTypeName == MINE_TYPE.DOOR then
        node = self:createDoor(rowIndex, colIndex)
    elseif mineTypeName == MINE_TYPE.MUD then
        node = self:createNormalMine(rowIndex, colIndex)
    elseif mineTypeName == MINE_TYPE.ADAMAS then
        node = self:createAdamas(rowIndex, colIndex)
        self.minesObj[rowIndex][colIndex].clickable = false
    elseif mineTypeName == MINE_TYPE.DRAGON then
        node = self:createDragon(rowIndex, colIndex)
    elseif mineTypeName == MINE_TYPE.TREASURE then
        node = self:createTreasure(rowIndex, colIndex)
    elseif mineTypeName == MINE_TYPE.GEM1 then
        node = self:createGem(rowIndex, colIndex, 1)
    elseif mineTypeName == MINE_TYPE.GEM2 then
        node = self:createGem(rowIndex, colIndex, 2)
    elseif mineTypeName == MINE_TYPE.GEM3 then
        node = self:createGem(rowIndex, colIndex, 3)
    elseif mineTypeName == MINE_TYPE.GEM4 then
        node = self:createGem(rowIndex, colIndex, 4)
    elseif mineTypeName == MINE_TYPE.GEM5 then
        node = self:createGem(rowIndex, colIndex, 5)
    elseif mineTypeName == MINE_TYPE.BOX0 then
        node = self:createBox(mineType, rowIndex, colIndex, 0)
    elseif mineTypeName == MINE_TYPE.BOX1 then
        node = self:createBox(mineType, rowIndex, colIndex, 1)
    elseif mineTypeName == MINE_TYPE.BOX2 then
        node = self:createBox(mineType, rowIndex, colIndex, 2)
    elseif mineTypeName == MINE_TYPE.ENEMY1 then
        node = self:createEnemy(rowIndex, colIndex, mineTypeName, 1)
    elseif mineTypeName == MINE_TYPE.ENEMY2 then
        node = self:createEnemy(rowIndex, colIndex, mineTypeName, 2)
    elseif mineTypeName == MINE_TYPE.ENEMY3 then
        node = self:createEnemy(rowIndex, colIndex, mineTypeName, 3)
    end
    if node then
        node:setLocalZOrder(mineType*10)
    end
    return node
end

function DigMineUI:checkRoundMines(rowIndex, colIndex)
    local block = 0
    if rowIndex > 1 then
        if self.minesObj[rowIndex-1][colIndex] and CAN_NOT_CROSS[self.minesObj[rowIndex-1][colIndex].mineType] then
            block = block + 1
        end
    else
        block = block + 1
    end
    if rowIndex < MAX_MINES_NUM_ROW then
        if self.minesObj[rowIndex+1][colIndex] and CAN_NOT_CROSS[self.minesObj[rowIndex+1][colIndex].mineType] then
            block = block + 1
        end
    else
        block = block + 1
    end
    if colIndex > 1 then
        if self.minesObj[rowIndex][colIndex-1] and CAN_NOT_CROSS[self.minesObj[rowIndex][colIndex-1].mineType] then
            block = block + 1
        end
    else
        block = block + 1
    end
    if colIndex < MAX_MINES_NUM_COL then
        if self.minesObj[rowIndex][colIndex+1] and CAN_NOT_CROSS[self.minesObj[rowIndex][colIndex+1].mineType] then
            block = block + 1
        end
    else
        block = block + 1
    end
    return block >= 4
end

function DigMineUI:lightRoundMines(rowIndex, colIndex)
    -- 左
    if rowIndex > 1 then
        self:lightMine(rowIndex-1, colIndex)
    end
    -- 右
    if rowIndex < MAX_MINES_NUM_ROW then
        self:lightMine(rowIndex+1, colIndex)
    end
    -- 上
    if colIndex > 1 then
        self:lightMine(rowIndex, colIndex-1)
    end
    -- 下
    if colIndex < MAX_MINES_NUM_COL then
        self:lightMine(rowIndex, colIndex+1)
    end
end

function DigMineUI:lightMine(rowIndex, colIndex)
    local mineObj = self.minesObj[rowIndex][colIndex]
    if mineObj then
        if mineObj.mineType ~= MINE_TYPE.ADAMAS then
            mineObj.clickable = true
            if mineObj.light == nil then
                if mineObj.mineType == MINE_TYPE.MUD or mineObj.mineType == MINE_TYPE.TREASURE then
                    self:showLightEffect(rowIndex, colIndex, mineObj)
                end
            end
        end
    end
end

function DigMineUI:showLightEffect(rowIndex, colIndex, mineObj)
    local lightImg = ccui.ImageView:create("uires/ui/digmine/mine_light.png")
    lightImg:setLocalZOrder(LIGHT_ZORDER)
    lightImg:setPosition(self:getMinePosition(rowIndex, colIndex))
    mineObj.light = lightImg
    self.mine_node:addChild(lightImg)
end

function DigMineUI:getMinePosition(rowIndex, colIndex)
    return cc.p((rowIndex-1)*MINE_WIDTH + MINE_SPACE_ROW*rowIndex + MINE_WIDTH/2, MAX_DIG_HEIGHT - (colIndex-1)*MINE_HEIGHT - MINE_SPACE_COL*colIndex - MINE_HEIGHT/2)
end

function DigMineUI:showDigEffect(rowIndex, colIndex)
    if self.digAnimation then
        self.digAnimation:setVisible(true)
    else
        self.digAnimation = GlobalApi:createLittleLossyAniByName("scene_tx_wakuang")
        self.digAnimation:setLocalZOrder(DIG_EFFECT_ZORDER)
        self.digAnimation:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                self.digAnimation:setVisible(false)
            end
        end)
        self.mine_node:addChild(self.digAnimation)
    end
    self.digAnimation:setPosition(cc.pAdd(self:getMinePosition(rowIndex, colIndex), cc.p(2, 5)))
    self.digAnimation:getAnimation():playWithIndex(0, -1, 0)
end

function DigMineUI:changeMine(rowIndex, colIndex, changed, reduceTimes)
    if self.minesObj[rowIndex][colIndex].mineId == changed then
        return
    end
    if reduceTimes then
        self.digTimes = self.digTimes - 1
    end
    if self.minesObj[rowIndex][colIndex] and self.minesObj[rowIndex][colIndex].node then
        local mineType = self.minesObj[rowIndex][colIndex].mineType
        if mineType == MINE_TYPE.TREASURE then
            self.treasureNum = self.treasureNum - 1
        elseif mineType == MINE_TYPE.BOX0 or mineType == MINE_TYPE.BOX1 or mineType == MINE_TYPE.BOX2 then
            self.boxNum = self.boxNum - 1
        elseif mineType == MINE_TYPE.ENEMY1 or mineType == MINE_TYPE.ENEMY2 or mineType == MINE_TYPE.ENEMY3 then
            self.enemyNum = self.enemyNum - 1
        end
        self.minesObj[rowIndex][colIndex].node:removeFromParent()
        self.minesObj[rowIndex][colIndex].node = nil
        if self.minesObj[rowIndex][colIndex].light then
            self.minesObj[rowIndex][colIndex].light:removeFromParent()
            self.minesObj[rowIndex][colIndex].light = nil
        end
        self.minesObj[rowIndex][colIndex].mineType = MINE_TYPE.EMPTY
        self.minesObj[rowIndex][colIndex].mineId = 0
        self.minesObj[rowIndex][colIndex].clickable = false
    end
    if changed and changed > 0 then
        if self.digProductConf[changed] then
            self.minesObj[rowIndex][colIndex].mineType = self.digProductConf[changed].key
            self.minesObj[rowIndex][colIndex].mineId = changed
            self.minesObj[rowIndex][colIndex].node = self:createMine(changed, self.digProductConf[changed].key, rowIndex, colIndex)
            if CAN_NOT_CROSS[self.minesObj[rowIndex][colIndex].mineType] == nil then
                self:lightRoundMines(rowIndex, colIndex)
            end
        end
    else
        self:lightRoundMines(rowIndex, colIndex)
    end
    self:updateLeftPl()
    self:updateRightProgressBar()
end

function DigMineUI:bombOneRowOrCol(updates, change, row, col)
    if change == "row" then
        self.bg_block_click:setVisible(true)
        local interval = 0
        local startRow1 = row
        local startRow2 = row
        self:changeMine(row, col, updates[row], false)
        self:updateLeftPl()
        self.root:scheduleUpdateWithPriorityLua(function (dt)
            interval = interval + dt
            if startRow1 <= 1 and startRow2 >= 10 then
                if interval >= BOMB_INTERVAL + 0.1 then
                    self.bg_block_click:setVisible(false)
                    self.root:unscheduleUpdate()
                    self:digAllNormalMines()
                end
            else
                if interval >= BOMB_INTERVAL then
                    interval = 0
                    if startRow1 > 1 then
                        startRow1 = startRow1 - 1
                        self:bombMine(startRow1, col, updates[startRow1])
                    end
                    if startRow2 < 10 then
                        startRow2 = startRow2 + 1
                        self:bombMine(startRow2, col, updates[startRow2])
                    end
                end
            end
        end, 0)
    elseif change == "col" then
        self.bg_block_click:setVisible(true)
        local interval = 0
        local startCol1 = col
        local startCol2 = col
        self:changeMine(row, col, updates[col], false)
        self:updateLeftPl()
        self.root:scheduleUpdateWithPriorityLua(function (dt)
            interval = interval + dt
            if startCol1 <= 1 and startCol2 >= 10 then
                if interval >= BOMB_INTERVAL + 0.1 then
                    self.bg_block_click:setVisible(false)
                    self.root:unscheduleUpdate()
                    self:digAllNormalMines()
                end
            else
                if interval >= BOMB_INTERVAL then
                    interval = 0
                    if startCol1 > 1 then
                        startCol1 = startCol1 - 1
                        self:bombMine(row, startCol1, updates[startCol1])
                    end
                    if startCol2 < 10 then
                        startCol2 = startCol2 + 1
                        self:bombMine(row, startCol2, updates[startCol2])
                    end
                end
            end
        end, 0)
    end
end

function DigMineUI:bombMine(rowIndex, colIndex, changed)
    local ani = self:getBombAnimation()
    ani:setPosition(self:getMinePosition(rowIndex, colIndex))
    if changed and self.minesObj[rowIndex][colIndex] and self.minesObj[rowIndex][colIndex].node then
        self.mine_node:runAction(cc.Sequence:create(cc.DelayTime:create(BOMB_PLAY_TIME),cc.CallFunc:create(function()
            self:changeMine(rowIndex, colIndex, changed, false)
        end)))
    end
end

function DigMineUI:getBombAnimation()
    local ani
    if #self.bombAnis > 0 then
        ani = table.remove(self.bombAnis)
        ani:setVisible(true)
    else
        ani = GlobalApi:createLittleLossyAniByName("ui_paolong")
        ani:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
            if movementType == 1 then
                ani:setVisible(false)
            end
        end)
        ani:setLocalZOrder(BOMB_ANI_ZORDER)
        self.mine_node:addChild(ani)
    end
    ani:getAnimation():playWithIndex(0, -1, 0)
    return ani
end

function DigMineUI:getMineByPosition(position)
    local mineObj = nil
    local convertPosition1 = self.mine_pl:convertToNodeSpace(position)
    if convertPosition1.x > 0 and convertPosition1.x < self.minePlSize.width and convertPosition1.y > 0 and convertPosition1.y < self.minePlSize.height then
        local convertPosition2 = self.mine_node:convertToNodeSpace(position)
        local posx = convertPosition2.x - MINE_SPACE_ROW
        local row = 1
        if posx > 0 then
            row = math.ceil(posx/(MINE_WIDTH+MINE_SPACE_ROW))
        end
        if row < 1 then
            row = 1
        elseif row > MAX_MINES_NUM_ROW then
            row = MAX_MINES_NUM_ROW
        end
        local diffColHeight = MAX_MINES_NUM_COL*MINE_HEIGHT + (MAX_MINES_NUM_COL + 1)*MINE_SPACE_COL - MAX_DIG_HEIGHT
        local posy = convertPosition2.y + diffColHeight
        local col = MAX_MINES_NUM_COL
        if posy > 0 then
            col = MAX_MINES_NUM_COL - math.floor(posy/(MINE_WIDTH+MINE_SPACE_COL))
        end
        if col < 1 then
            col = 1
        elseif col > MAX_MINES_NUM_COL then
            col = MAX_MINES_NUM_COL
        end
        mineObj = self.minesObj[row][col]
    end
    return mineObj
end

function DigMineUI:showBombRowOrCol(rowOrCol, mineObj)
    self.bg_block_click:setVisible(true)
    local imgPosition = self:getMinePosition(mineObj.row, mineObj.col)
    local confirmPosition = self.mine_node:convertToWorldSpace(imgPosition)
    self.confirmBombNode[rowOrCol].img:setVisible(true)
    self.confirmBombNode[rowOrCol].img:setPosition(imgPosition)
    self.confirmBombNode[rowOrCol].confirm:setVisible(true)
    local winsize = cc.Director:getInstance():getWinSize()
    if confirmPosition.y > winsize.height - 100 then
        confirmPosition.y = confirmPosition.y - 60
    else
        confirmPosition.y = confirmPosition.y + 60
    end
    if confirmPosition.x < 100 then
       confirmPosition.x = confirmPosition.x + 60 
    elseif confirmPosition.x > winsize.width - 100 then
        confirmPosition.x = confirmPosition.x - 60 
    end
    self.confirmBombNode[rowOrCol].confirm:setPosition(confirmPosition)
    self.confirmBombNode[rowOrCol].row = mineObj.row
    self.confirmBombNode[rowOrCol].col = mineObj.col
end

function DigMineUI:digAllNormalMines()
    if not self.isDigAllNormalMines and self.treasureNum <= 0 then
        self.isDigAllNormalMines = true
        self.bg_block_click:setVisible(true)
        local startIndex1 = 1
        local startIndex2 = 1
        local interval = 0
        self.root:scheduleUpdateWithPriorityLua(function (dt)
            interval = interval + dt
            if startIndex1 > MAX_MINES_NUM_ROW and startIndex2 >= MAX_MINES_NUM_COL then
                if interval >= BOMB_INTERVAL + 0.1 then
                    DigMineMgr:showDigMineEvent("reward", nil, function ()
                        self:openRewardBox(3)
                    end)
                    self.bg_block_click:setVisible(false)
                    self.root:unscheduleUpdate()
                end
            else
                if interval >= BOMB_INTERVAL then
                    interval = 0
                    local i = startIndex1
                    local j = startIndex2
                    for k = startIndex1, startIndex2 do
                        if self.minesObj[i][j].mineType == MINE_TYPE.MUD then
                            self:bombMine(i, j, 0)
                        else
                            self:bombMine(i, j)
                        end
                        i = i + 1
                        j = j - 1
                    end
                    if startIndex2 >= MAX_MINES_NUM_COL then
                        startIndex1 = startIndex1 + 1
                    else
                        startIndex2 = startIndex2 + 1
                    end
                end
            end
        end, 0)
    end
end

function DigMineUI:showEatMeat(addDigTimes, callback)
    local winsize = cc.Director:getInstance():getWinSize()
    if self.eatMeatImg then
        -- self.eatMeatAnimation:setVisible(true)
        self.eatMeatImg:setVisible(true)
    else
        self.eatMeatImg = ccui.ImageView:create("uires/ui/common/bg1_gray33.png")
        self.eatMeatImg:setScale9Enabled(true)
        self.eatMeatImg:setContentSize(winsize)
        self.eatMeatImg:setPosition(cc.p(winsize.width/2, winsize.height/2))
        self.root:addChild(self.eatMeatImg)
        -- self.eatMeatAnimation = GlobalApi:createLittleLossyAniByName("ui_chirou")
        -- self.eatMeatAnimation:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        --     if movementType == 1 then
        --         self.eatMeatAnimation:setVisible(false)
        --     end
        -- end)
        -- self.eatMeatAnimation:setPosition(cc.p(winsize.width/2, winsize.height/2))
        -- self.eatMeatImg:addChild(self.eatMeatAnimation)
        self.addDigTimesTx = ccui.Text:create()
        self.addDigTimesTx:setFontName("font/gamefont.ttf")
        self.addDigTimesTx:setFontSize(28)
        self.addDigTimesTx:setTextColor(COLOR_TYPE.GREEN)
        self.addDigTimesTx:enableOutline(COLOR_TYPE.BLACK, 1)
        self.addDigTimesTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        self.eatMeatImg:addChild(self.addDigTimesTx)
        self.addDigTimesTx:setVisible(false)
    end
    -- self.eatMeatAnimation:getAnimation():playWithIndex(0, -1, 0)
    self.addDigTimesTx:setString(GlobalApi:getLocalStr("STR_VITALITY") .. "+" .. addDigTimes)
    self.addDigTimesTx:setPosition(cc.p(winsize.width/2, winsize.height/2 + 60))
    self.addDigTimesTx:runAction(cc.Sequence:create(cc.DelayTime:create(1.2), cc.CallFunc:create(function ()
        self.addDigTimesTx:setVisible(true)
    end), cc.MoveBy:create(1.5, cc.p(0, 30)), cc.CallFunc:create(function ()
        self.eatMeatImg:setVisible(false)
        self.addDigTimesTx:setVisible(false)
        if callback then
            callback()
            callback = nil
        end
    end)))
end

function DigMineUI:showGuideImg()
    local bgImg = ccui.ImageView:create('uires/ui/common/bg1_gray22.png')
    bgImg:setName("guide_bg_img")
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgImg:setTouchEnabled(true)
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(winSize.width,winSize.height))
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.root:addChild(bgImg)
    bgImg:setLocalZOrder(GUIDE_IMG_ZORDER)

    local guideImg = ccui.ImageView:create('uires/ui/digmine/guide_digmine.png')
    guideImg:setName("guide_img")
    bgImg:addChild(guideImg)
    guideImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.guideBgImg = bgImg
    GuideMgr:finishCurrGuide()
end

function DigMineUI:hideGuideImg()
    if self.guideBgImg then
        self.guideBgImg:removeFromParent()
        self.guideBgImg = nil
    end
    GuideMgr:finishCurrGuide()
end

function DigMineUI:openRewardBox(index)
    if self.digBoxArr[index].status ~= 1 then
        return
    end
    local args = {
        id = index
    }
    MessageMgr:sendPost("click_box", "digging", json.encode(args), function(jsonObj)
        if jsonObj.code == 0 then
            ShaderMgr:restoreWidgetDefaultShader(self.digBoxArr[index].box)
            self.digBoxArr[index].box:loadTexture("uires/ui/common/box" .. index .. ".png")
            self.digBoxArr[index].status = 2
            self.boxReward[index] = true
            self.digBoxArr[index].numTx:setVisible(false)
            self.digBoxArr[index].light:setVisible(false)
            self.digBoxArr[index].unknowImg:setVisible(false)
            if self.digBoxArr[index].particle then
                self.digBoxArr[index].particle:removeFromParent()
                self.digBoxArr[index].particle = nil
            end
            local tool = jsonObj.data.tool or self.digTimes
            local addDigTimes = tool - self.digTimes
            self.digTimes = tool
            if jsonObj.data.awards and #jsonObj.data.awards > 0 then
                GlobalApi:parseAwardData(jsonObj.data.awards)
                GlobalApi:showAwardsCommon(jsonObj.data.awards, nil, function ()
                    if addDigTimes > 0 then
                        self.bg_block_click:setVisible(true)
                        self:showEatMeat(addDigTimes, function ()
                            self.bg_block_click:setVisible(false)
                            self:updateLeftPl()
                        end)
                    else
                        self:updateLeftPl()
                    end
                end)
            else
                if addDigTimes > 0 then
                    if addDigTimes > 0 then
                        self.bg_block_click:setVisible(true)
                        self:showEatMeat(addDigTimes, function ()
                            self.bg_block_click:setVisible(false)
                            self:updateLeftPl()
                        end)
                    else
                        self:updateLeftPl()
                    end
                else
                    self:updateLeftPl()
                end
            end
        end
    end)
end

return DigMineUI