local LegionTrialAchievementPannelUI = class("LegionTrialAchievementPannelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local HASGETAWARD = 'uires/ui/activity/yilingq.png'
local NOTREATCH = 'uires/ui/activity/weidac.png'

local GETSTATENORMAL = 'uires/ui/common/common_bg_5.png'
local GETSTATEPRESS = 'uires/ui/common/common_bg_27.png'

function LegionTrialAchievementPannelUI:ctor(trial,callBack)
    self.uiIndex = GAME_UI.UI_LEGION_TRIAL_ACHIEVEMENT_PANNEL
    self.trial = trial
    self.callBack = callBack

    self.legionTrialAchievementType = GameData:getConfData('legiontrialachievementtype')
    self.legionTrialAchievement = GameData:getConfData('legiontrialachievement')

end

function LegionTrialAchievementPannelUI:init()
	local bg_img = self.root:getChildByName("bg_img")
    local alpha_img = bg_img:getChildByName("alpha_img")
    self:adaptUI(bg_img, alpha_img)

    local main_img = alpha_img:getChildByName("main_img")
    
    local close_btn = main_img:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialAchievementPannelUI()
        end
    end)

    local title_bg = main_img:getChildByName('title_bg')
    local title_tx = title_bg:getChildByName('title_tx')
    title_tx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC25'))

    -- 
    local sv = main_img:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = main_img:getChildByName('cell')
    rewardCell:getChildByName('get_btn'):getChildByName('text'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell

    self:updateSV()

end

function LegionTrialAchievementPannelUI:updateSV()
    local achievement = self.trial.achievement

    local temp = {}
    for i = 1,#self.legionTrialAchievementType do
        local data = clone(self.legionTrialAchievementType[i])
        data.type = i
        data.sortId = 0

        local achivementConfData = self.legionTrialAchievement[i]

        local allNum = #achivementConfData  -- 进度总数量
        local achivementSeverData = achievement[tostring(i)]
        local award_got_level = 0
        local progress = 0
        if achivementSeverData then
            award_got_level = achivementSeverData.award_got_level     -- 进度goalId
            progress = achivementSeverData.progress                   -- target
        end
        local isHasGet = false
        local award_got_level = award_got_level + 1
        if award_got_level >= allNum then
            award_got_level = allNum
            isHasGet = true     -- 达到最大进度，已经领取完了 
        end
        local gotLevelData = achivementConfData[award_got_level]    -- 该领取的等级

        if gotLevelData.target <= progress and progress > 0 then -- 达成
            if isHasGet == true then    -- 已领取
            else    -- 未领取
                data.sortId = 1
            end
        end
        table.insert(temp,data)
    end

    table.sort(temp, function (a, b)
		return a.sortId > b.sortId
	end)
    self.legionTrialAchievementType = temp

    --
    local num = #self.legionTrialAchievementType
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * self.rewardCell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = self.rewardCell:getContentSize().height
    for i = 1,num do
        local data = self.legionTrialAchievementType[i]
        local achivementConfData = self.legionTrialAchievement[data.type]

        local tempCell = self.rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        self.sv:addChild(tempCell)

        local leftImg = tempCell:getChildByName('left_img')
        leftImg:ignoreContentAdaptWithSize(true)
        leftImg:loadTexture(data.icon)

        local bg = tempCell:getChildByName('bg')
        if data.type > 4 then
            bg:setVisible(true)
        else
            bg:setVisible(false)
        end

        -- 描述1
        local desc1 = data.desc1
        local desc2 = data.desc2

        local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(500, 38))

	    local re1 = xx.RichTextLabel:create(desc1, 34, cc.c4b(255, 247, 229, 255))
	    re1:setStroke(cc.c4b(78, 49, 17, 255),2)
        re1:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')
    
	    local re2 = xx.RichTextLabel:create('', 34,COLOR_TYPE.GREEN)
	    re2:setStroke(cc.c4b(78, 49, 17, 255),2)
        re2:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

	    local re3 = xx.RichTextLabel:create(desc2, 34, cc.c4b(255, 247, 229, 255))
	    re3:setStroke(cc.c4b(78, 49, 17, 255),2)
        re3:setShadow(cc.c4b(78, 49, 17, 255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)

        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(128,66))
        richText:format(true)
        tempCell:addChild(richText)

        local got = tempCell:getChildByName('got')
        local getBtn = tempCell:getChildByName('get_btn')
        local getBtnTx = getBtn:getChildByName('text')

        -- 进度字,红色和白色的
        local richText2 = xx.RichText:create()
	    richText2:setContentSize(cc.size(500, 38))

	    local re3 = xx.RichTextLabel:create('', 28, COLOR_TYPE.WHITE)
	    re3:setStroke(COLOR_TYPE.BLACK,1)
        re3:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')
    
	    local re4 = xx.RichTextLabel:create('', 28,COLOR_TYPE.WHITE)
	    re4:setStroke(COLOR_TYPE.BLACK,1)
        re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
        re4:setFont('font/gamefont.ttf')

	    richText2:addElement(re3)
	    richText2:addElement(re4)

        richText2:setAlignment('middle')
        richText2:setVerticalAlignment('bottom')

	    richText2:setAnchorPoint(cc.p(0.5,0))
	    richText2:setPosition(cc.p(got:getPositionX(),got:getPositionY() + 20))
        richText2:format(true)
        tempCell:addChild(richText2)


        tempCell.data = data
        tempCell.achivementConfData = achivementConfData

        tempCell.richText = richText
        tempCell.re2 = re2

        tempCell.got = got
        tempCell.getBtn = getBtn
        tempCell.i = data.type

        tempCell.re3 = re3
        tempCell.re4 = re4
        tempCell.richText2 = richText2

        tempCell.frame = tempCell:getChildByName('frame')
        -- 奖励


        self:refreshItem(tempCell)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function LegionTrialAchievementPannelUI:refreshItem(tempCell)
    local data = tempCell.data
    local achivementConfData = tempCell.achivementConfData
    local allNum = #achivementConfData  -- 进度总数量
    local got = tempCell.got
    local getBtn = tempCell.getBtn
    local i = tempCell.i
    local frame = tempCell.frame

    local achievement = self.trial.achievement
    --
    local achivementSeverData = achievement[tostring(i)]
    local award_got_level = 0
    local progress = 0
    if achivementSeverData then
        award_got_level = achivementSeverData.award_got_level     -- 进度goalId
        progress = achivementSeverData.progress                   -- target
    end
    local isHasGet = false
    local award_got_level = award_got_level + 1
    if award_got_level >= allNum then
        award_got_level = allNum
        isHasGet = true     -- 达到最大进度，已经领取完了 
    end
    local gotLevelData = achivementConfData[award_got_level]    -- 该领取的等级
    

    -- 加入道具显示
    local awardData = gotLevelData.award
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]

    if frame:getChildByName('award_bg_img') then
        frame:removeChildByName('award_bg_img')
    end
     
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.lvTx:setString('x'..awards:getNum())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)

    -- 描述1
    tempCell.re2:setString(gotLevelData.target)
    tempCell.richText:format(true)

    -- 进度字,红色和白色的
    local showProgress = progress
    if progress >= gotLevelData.target then
        showProgress = gotLevelData.target
    end
    tempCell.re3:setString(showProgress)
    tempCell.re4:setString('/' .. gotLevelData.target)

    tempCell.re3:setColor(COLOR_TYPE.WHITE)
    tempCell:loadTexture(GETSTATENORMAL)
    if gotLevelData.target <= progress and progress > 0 then -- 达成
        if isHasGet == true then    -- 已领取
            got:setVisible(true)
            got:loadTexture(HASGETAWARD)
            getBtn:setVisible(false)
            tempCell.richText2:setVisible(true)
        else    -- 未领取
            got:setVisible(false)
            getBtn:setVisible(true)
            tempCell.richText2:setVisible(false)
            tempCell:loadTexture(GETSTATEPRESS)
        end
    else    -- 未达成
        got:setVisible(true)
        got:loadTexture(NOTREATCH)
        getBtn:setVisible(false)

        tempCell.re3:setColor(COLOR_TYPE.RED)
        tempCell.richText2:setVisible(true)
    end
    tempCell.richText2:format(true)

    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callBack(datas)
                local awards = datas.awards
			    if awards then
				    GlobalApi:parseAwardData(awards)
				    GlobalApi:showAwardsCommon(awards,nil,nil,true)
			    end
                if self.trial.achievement[tostring(i)] == nil then
                    self.trial.achievement[tostring(i)] = {}
                end
                self.trial.achievement[tostring(i)].award_got_level = award_got_level
                self.callBack(self.trial.achievement)

                self:refreshItem(tempCell)
            end
            LegionTrialMgr:legionTrialGetAchievementAwardFromServer(i,award_got_level,callBack)
        end
    end)
end

return LegionTrialAchievementPannelUI