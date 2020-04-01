local CampaignBasePanel = require("script/app/ui/campaign/campaignbasepanel")
local CampaignInfiniteBattlePanel = class("CampaignInfiniteBattlePanel", CampaignBasePanel)

local CELL_WIDTH = 244
local CELL_HEIGHT = 306
local CELL_SPACE = 40
local CELL_SPACE_LR = 50

function CampaignInfiniteBattlePanel:ctor(page, showByClick)
	local winSize = cc.Director:getInstance():getWinSize()
    self.root = cc.Node:create()
    local bgImg = ccui.ImageView:create("uires/ui/campaign/bg_img_1.jpg")
    self.root:addChild(bgImg)
    self.sv = ccui.ScrollView:create()
    self.sv:setScrollBarEnabled(false)
    self.sv:setDirection(ccui.ScrollViewDir.horizontal)
    self.sv:setAnchorPoint(cc.p(0.5, 0.5))
    local svWidth = winSize.width - 140 + CELL_SPACE_LR*2
    self.sv:setContentSize(svWidth, 360)
    self.root:addChild(self.sv)

    self.select_img = ccui.ImageView:create("uires/ui/infinitebattle/infinitebattle_card_sel.png")
    self.sv:addChild(self.select_img)

    self.cells = {}
    local chapterId = UserData:getUserObj():getInfinite().chapter_id
    local selConf = GameData:getConfData("itsection")
    local totalWidth = #selConf*(CELL_WIDTH + CELL_SPACE) +  CELL_SPACE_LR*2
    for i = 1, #selConf do
        local cell
        if i == chapterId and InfiniteBattleMgr.nextChapter then
            cell = self:createCell(i, selConf[i], chapterId, false, true)
            self.playAnimationCell = cell
            InfiniteBattleMgr.nextChapter = false
        else
            cell = self:createCell(i, selConf[i], chapterId, i <= chapterId, false)
        end
    	cell:setPosition(cc.p((i-0.5)*(CELL_WIDTH + CELL_SPACE) + CELL_SPACE_LR, 160))
    	self.sv:addChild(cell)
        self.cells[i] = cell
    end
    self.sv:setInnerContainerSize(cc.size(totalWidth, 360))

    if showByClick then
        if UserData:getUserObj():getInfinite() then
            self.page = UserData:getUserObj():getInfinite().chapter_id or 1
        else
            self.page = 1
        end
    else
        self.page = page or 1
    end

    local diffWidth = totalWidth - svWidth
    local currDiffX = (self.page-0.5)*(CELL_WIDTH + CELL_SPACE) + CELL_SPACE_LR - svWidth/2
    local percent = 100*currDiffX/diffWidth
    if percent < 0 then
        percent = 0
    elseif percent > 100 then
        percent = 100
    end
    self.sv:jumpToPercentHorizontal(percent)

    self.select_img:setPosition(cc.p((self.page-0.5)*(CELL_WIDTH + CELL_SPACE) + CELL_SPACE_LR, 160))
    self:playActivateEffect()
end

function CampaignInfiniteBattlePanel:enterCampaign()
	self:selectPageAndEnter()
end

function CampaignInfiniteBattlePanel:selectPageAndEnter()
    self.select_img:setPosition(cc.p((self.page-0.5)*(CELL_WIDTH + CELL_SPACE) + CELL_SPACE_LR, 160))
    GlobalApi:getGotoByModule('infinite_battle',nil,self.page)
end

function CampaignInfiniteBattlePanel:createCell(index, data, chapterId, isOpen, nextChapter)
	local bg = ccui.ImageView:create("uires/ui/infinitebattle/infinitebattle_" .. data.url)
    bg:setTouchEnabled(true)

	local titleImg = ccui.ImageView:create("uires/ui/common/title_yellow.png")
	titleImg:setScale(1.35)
	titleImg:setPosition(cc.p(CELL_WIDTH/2, CELL_HEIGHT - 27))

    if isOpen then
        bg:addChild(titleImg)

    	local nameBg = ccui.ImageView:create("uires/ui/common/name_bg23.png")
    	nameBg:setScale(0.4, 1)
    	nameBg:setPosition(cc.p(CELL_WIDTH/2, CELL_HEIGHT - 28))
    	bg:addChild(nameBg)

    	local starImg = ccui.ImageView:create("uires/ui/common/icon_star3.png")
    	starImg:setPosition(cc.p(CELL_WIDTH/2 - 60, CELL_HEIGHT - 28))
    	bg:addChild(starImg)

    	local starTx = ccui.Text:create()
    	starTx:setAnchorPoint(cc.p(0.5, 0.5))
        starTx:setFontName("font/gamefont.ttf")
        starTx:setFontSize(34)
        starTx:enableOutline(COLOR_TYPE.BLACK, 1)
        starTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        local starNum,allNum = InfiniteBattleMgr:getStarByChapterId(data.id)
        starTx:setString(starNum..'/'..allNum)
        starTx:setPosition(cc.p(CELL_WIDTH/2 + 10, CELL_HEIGHT - 28))
        bg:addChild(starTx)

        bg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = data.id
                self:selectPageAndEnter()
            end
        end)
        if UserData:getUserObj():getUnlimitedStarsShowStatus(index) or UserData:getUserObj():getUnlimitedBossBoxShowStatus(index) then
            local newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
            newImg:setName("new_img")
            bg:addChild(newImg)
            newImg:setPosition(cc.p(CELL_WIDTH - 15, CELL_HEIGHT - 5))
        elseif index == chapterId and UserData:getUserObj():getUnlimitedShasShowStatus() then
            local newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
            newImg:setName("new_img")
            bg:addChild(newImg)
            newImg:setPosition(cc.p(CELL_WIDTH - 15, CELL_HEIGHT - 5))
        end
    else
        local grayBg = ccui.ImageView:create("uires/ui/common/bg_gray50.png")
        grayBg:setName("gray_bg")
        grayBg:setScale9Enabled(true)
        grayBg:setContentSize(cc.size(CELL_WIDTH - 7, CELL_HEIGHT - 8))
        grayBg:setPosition(cc.p(CELL_WIDTH/2, CELL_HEIGHT/2))
        bg:addChild(grayBg)

        bg:addChild(titleImg)

        local infoTx = ccui.Text:create()
        infoTx:setName("info_tx")
        infoTx:setAnchorPoint(cc.p(0.5, 0.5))
        infoTx:setFontName("font/gamefont.ttf")
        infoTx:setFontSize(26)
        infoTx:setTextColor(COLOR_TYPE.RED)
        infoTx:enableOutline(COLOR_TYPE.BLACK, 1)
        infoTx:setString(data.openCondition)
        infoTx:setPosition(cc.p(CELL_WIDTH/2, CELL_HEIGHT - 28))
        bg:addChild(infoTx)

        if nextChapter then
            local nameBg = ccui.ImageView:create("uires/ui/common/name_bg23.png")
            nameBg:setName("name_bg")
            nameBg:setScale(0.4, 1)
            nameBg:setPosition(cc.p(CELL_WIDTH/2, CELL_HEIGHT - 28))
            bg:addChild(nameBg)
            nameBg:setVisible(false)

            local starImg = ccui.ImageView:create("uires/ui/common/icon_star3.png")
            starImg:setName("star_img")
            starImg:setPosition(cc.p(CELL_WIDTH/2 - 60, CELL_HEIGHT - 28))
            bg:addChild(starImg)
            starImg:setVisible(false)

            local starTx = ccui.Text:create()
            starTx:setName("star_tx")
            starTx:setAnchorPoint(cc.p(0.5, 0.5))
            starTx:setFontName("font/gamefont.ttf")
            starTx:setFontSize(34)
            starTx:enableOutline(COLOR_TYPE.BLACK, 1)
            starTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            local starNum,allNum = InfiniteBattleMgr:getStarByChapterId(data.id)
            starTx:setString(starNum..'/'..allNum)
            starTx:setPosition(cc.p(CELL_WIDTH/2 + 10, CELL_HEIGHT - 28))
            bg:addChild(starTx)
            starTx:setVisible(false)

            bg:setTouchEnabled(false)
            bg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self.page = data.id
                    self:selectPageAndEnter()
                end
            end)
        else
            bg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    promptmgr:showSystenHint(data.openCondition .. GlobalApi:getLocalStr("STR_OPEN_AFTER"), COLOR_TYPE.RED)
                end
            end)
        end
    end

    local nameTx = ccui.Text:create()
    nameTx:setFontName("font/gamefont.ttf")
    nameTx:setFontSize(36)
    nameTx:setTextColor(COLOR_TYPE.PALE)
    nameTx:enableOutline(COLOROUTLINE_TYPE.PALE, 2)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    nameTx:setString(data.name)
    nameTx:setPosition(cc.p(CELL_WIDTH/2, 28))
    bg:addChild(nameTx)

	return bg
end

function CampaignInfiniteBattlePanel:playActivateEffect()
    if self.playAnimationCell then
        local animation = GlobalApi:createLittleLossyAniByName('ui_jueseshengji_01')
        animation:setPosition(cc.p(CELL_WIDTH/2, CELL_HEIGHT/2 - 130))
        animation:setScale(1.6)
        self.playAnimationCell:addChild(animation)
        animation:getAnimation():playWithIndex(0, -1, 0)
        animation:runAction(cc.Sequence:create(cc.DelayTime:create(0.3), cc.CallFunc:create(function()
            local gray_bg = self.playAnimationCell:getChildByName("gray_bg")
            gray_bg:runAction(cc.FadeOut:create(0.1))
            local info_tx = self.playAnimationCell:getChildByName("info_tx")
            info_tx:setVisible(false)
            local name_bg = self.playAnimationCell:getChildByName("name_bg")
            name_bg:setVisible(true)
            local star_img = self.playAnimationCell:getChildByName("star_img")
            star_img:setVisible(true)
            local star_tx = self.playAnimationCell:getChildByName("star_tx")
            star_tx:setVisible(true)
            self.playAnimationCell:setTouchEnabled(true)
            self.playAnimationCell = nil
            self:updatePanel()
        end)))
    end
end

function CampaignInfiniteBattlePanel:getExtraInfos()
    local num = UserData:getUserObj():getShas()
    local extraInfos = {GlobalApi:getLocalStr("STR_SHAS") .. num .. "/" .. GlobalApi:getGlobalValue("shasMaxCount")}
    return extraInfos
end

function CampaignInfiniteBattlePanel:updatePanel()
    local chapterId = UserData:getUserObj():getInfinite().chapter_id
    for index, cell in ipairs(self.cells) do
        local newImg = cell:getChildByName("new_img")
        if index <= chapterId then
            if UserData:getUserObj():getUnlimitedStarsShowStatus(index) or UserData:getUserObj():getUnlimitedBossBoxShowStatus(index) then
                if newImg then
                    newImg:setVisible(true)
                else
                    newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
                    newImg:setName("new_img")
                    cell:addChild(newImg)
                    newImg:setPosition(cc.p(CELL_WIDTH - 15, CELL_HEIGHT - 5))
                end
            elseif index == chapterId and UserData:getUserObj():getUnlimitedShasShowStatus() then
                if newImg then
                    newImg:setVisible(true)
                else
                    newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
                    newImg:setName("new_img")
                    cell:addChild(newImg)
                    newImg:setPosition(cc.p(CELL_WIDTH - 15, CELL_HEIGHT - 5))
                end
            elseif newImg then
               newImg:setVisible(false) 
            end
        elseif newImg then
            newImg:setVisible(false)
        end
    end
end

return CampaignInfiniteBattlePanel