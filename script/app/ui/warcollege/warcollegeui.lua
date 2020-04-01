local WarCollegeUI = class("WarCollegeUI", BaseUI)

local function createCell(index, data, progress, cityProgress,isFromTrain)
	local bgImg = ccui.ImageView:create()
	bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(608, 100))

    local book = ccui.ImageView:create("uires/ui/warcollege/warcollege_book.png")
    book:setPosition(cc.p(90, 50))
    bgImg:addChild(book)

    local contentBg = ccui.ImageView:create("uires/ui/common/skill_tips_bg.png")
    contentBg:setOpacity(150)
    contentBg:setScale9Enabled(true)
    contentBg:setContentSize(cc.size(236, 80))
    contentBg:setPosition(cc.p(300, 50))
    bgImg:addChild(contentBg)

    local function afterBattle()
        if isFromTrain == true then
            MainSceneMgr:showMainCity(function()
                TrainingMgr:showTrainingMain2()
            end, nil, GAME_UI.UI_TRAININGMAIN)
        else
            if UserData:getUserObj():judgeWarCollegeSign() == true then
                MainSceneMgr:showMainCity(function()
                    WarCollegeMgr:showWarCollege()
                end, nil, GAME_UI.UI_WAR_COLLEGE)
            else
                MainSceneMgr:showMainCity()
            end
        end
    end

    -- 挑战
    local challegeBtn = ccui.Button:create("uires/ui/common/common_btn_5.png")
    challegeBtn:setPosition(cc.p(520, 50))
    bgImg:addChild(challegeBtn)
    challegeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local playerskills = {}
            for k, v in ipairs(data.skillIds) do
                playerskills[tostring(k)] = {
                    id = v,
                    level = data.levels[k]
                }
            end
            local customObj = {
                formation1 = data.formation1,
                formation2 = data.formation2,
                playerskills = playerskills,
                lessonId = data.lessonId,
                challenge = index,
                replay = false
            }
            BattleMgr:playBattle(BATTLE_TYPE.WARCOLLEGE, customObj, function ()
                afterBattle()
            end)
        end
    end)

    local challegeTx = ccui.Text:create()
    challegeTx:setFontName("font/gamefont.ttf")
    challegeTx:setFontSize(30)
    challegeTx:enableOutline(COLOROUTLINE_TYPE.WHITE1, 2)
    challegeTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    challegeTx:setString(GlobalApi:getLocalStr("CHALLENGE_1"))
    challegeTx:setPosition(cc.p(67, 37))
    challegeBtn:addChild(challegeTx)

    -- 重玩
    local replayBtn = ccui.Button:create("uires/ui/common/common_btn_7.png")
    replayBtn:setPosition(cc.p(520, 50))
    bgImg:addChild(replayBtn)
    replayBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local playerskills = {}
            for k, v in ipairs(data.skillIds) do
                playerskills[tostring(k)] = {
                    id = v,
                    level = data.levels[k]
                }
            end
            local customObj = {
                formation1 = data.formation1,
                formation2 = data.formation2,
                playerskills = playerskills,
                lessonId = data.lessonId,
                challenge = index,
                replay = true
            }
            BattleMgr:playBattle(BATTLE_TYPE.WARCOLLEGE, customObj, function ()
                afterBattle()
            end)
        end
    end)

    local replayTx = ccui.Text:create()
    replayTx:setFontName("font/gamefont.ttf")
    replayTx:setFontSize(30)
    replayTx:enableOutline(COLOROUTLINE_TYPE.WHITE2, 2)
    replayTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    replayTx:setString(GlobalApi:getLocalStr("STR_PLAY_AGAIN"))
    replayTx:setPosition(cc.p(67, 37))
    replayBtn:addChild(replayTx)

    local limitTx = ccui.Text:create()
    limitTx:setFontName("font/gamefont.ttf")
    limitTx:setFontSize(24)
    limitTx:setTextColor(COLOR_TYPE.RED)
    limitTx:enableOutline(COLOR_TYPE.BLACK, 1)
    limitTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    limitTx:setPosition(cc.p(516, 50))
    bgImg:addChild(limitTx)

    local lessonIndexTx = ccui.Text:create()
    lessonIndexTx:setAnchorPoint(cc.p(1, 0.5))
    lessonIndexTx:setFontName("font/gamefont.ttf")
    lessonIndexTx:setFontSize(24)
    lessonIndexTx:enableOutline(COLOR_TYPE.BLACK, 1)
    lessonIndexTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lessonIndexTx:setString(string.format(GlobalApi:getLocalStr("INDEX_OF_LESSON"), index))
    lessonIndexTx:setPosition(cc.p(264, 68))
    bgImg:addChild(lessonIndexTx)

    local lessonNameTx = ccui.Text:create()
    lessonNameTx:setAnchorPoint(cc.p(0, 0.5))
    lessonNameTx:setFontName("font/gamefont.ttf")
    lessonNameTx:setFontSize(24)
    lessonNameTx:setTextColor(COLOR_TYPE.ORANGE)
    lessonNameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    lessonNameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    lessonNameTx:setString(data.name)
    lessonNameTx:setPosition(cc.p(280, 68))
    bgImg:addChild(lessonNameTx)

    local awardTx = ccui.Text:create()
    awardTx:setAnchorPoint(cc.p(1, 0.5))
    awardTx:setFontName("font/gamefont.ttf")
    awardTx:setFontSize(24)
    awardTx:enableOutline(COLOR_TYPE.BLACK, 1)
    awardTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    awardTx:setString(GlobalApi:getLocalStr("STR_AWARDS"))
    awardTx:setPosition(cc.p(264, 32))
    bgImg:addChild(awardTx)

    local getImg = ccui.ImageView:create("uires/ui/common/had_get.png")
    getImg:setScale(0.8)
    getImg:setPosition(cc.p(320, 32))
    getImg:setRotation(22)
    bgImg:addChild(getImg)

    local award = DisplayData:getDisplayObj(data.award[1])

    local awardNumTx = ccui.Text:create()
    awardNumTx:setAnchorPoint(cc.p(0, 0.5))
    awardNumTx:setFontName("font/gamefont.ttf")
    awardNumTx:setFontSize(24)
    awardNumTx:enableOutline(COLOR_TYPE.BLACK, 1)
    awardNumTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    awardNumTx:setString(tostring(award:getNum()))
    awardNumTx:setPosition(cc.p(280, 32))
    bgImg:addChild(awardNumTx)

    local awardIcon = ccui.ImageView:create(award:getIcon())
    awardIcon:setScale(0.6)
    awardIcon:setPosition(cc.p(280 + awardNumTx:getContentSize().width + 24, 32))
    bgImg:addChild(awardIcon)

    if index <= progress then
        bgImg:loadTexture("uires/ui/common/common_bg_27.png")
        challegeBtn:setVisible(false)
        limitTx:setVisible(false)
        awardNumTx:setVisible(false)
        awardIcon:setVisible(false)
    else
        bgImg:loadTexture("uires/ui/common/common_bg_2.png")
        getImg:setVisible(false)
        replayBtn:setVisible(false)
        if cityProgress >= data.condition then
            if index == progress + 1 then
                limitTx:setVisible(false)
            else
                challegeBtn:setVisible(false)
                limitTx:setString(GlobalApi:getLocalStr("OPEN_AFTER_LAST_LESSON"))
            end
        else
            challegeBtn:setVisible(false)
            limitTx:setString(string.format(GlobalApi:getLocalStr("OPEN_AFTER_STAGE"), data.condition))
        end
    end

	return bgImg
end

function WarCollegeUI:ctor(isFromTrain)
    self.uiIndex = GAME_UI.UI_WAR_COLLEGE
    self.conf = GameData:getConfData("warcollege")
    self.sv = nil
    local collegeInfo = UserData:getUserObj():getWarCollege()
    self.progress = collegeInfo.challenge
    self.isFromTrain = isFromTrain
end

function WarCollegeUI:init()
	local bg_img = self.root:getChildByName("bg_img")
    local alpha_img = bg_img:getChildByName("alpha_img")
    self:adaptUI(bg_img, alpha_img)

    local main_img = alpha_img:getChildByName("main_img")
    
    local close_btn = main_img:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WarCollegeMgr:hideWarCollege()
        end
    end)

    local image4 = main_img:getChildByName("image4")
    local text4 = image4:getChildByName("text")
    text4:setString(GlobalApi:getLocalStr("STR_WAR_COLLEGE"))

    local text1 = main_img:getChildByName("text1")
    text1:setString(GlobalApi:getLocalStr("GOOD_STUDY_GET_AWARDS"))

    self.sv = main_img:getChildByName("sv")
    self.sv:setScrollBarEnabled(false)
    self.svSize = self.sv:getContentSize()
    self:initCell()
end

function WarCollegeUI:initCell()
    local cityProgress = MapData:getFightedCityId()
	local cellNum = #self.conf
	local totalHeight = cellNum*100 + 4*cellNum
	for i = 1, cellNum do
		local cell = createCell(i, self.conf[i], self.progress, cityProgress,self.isFromTrain)
		cell:setPosition(cc.p(self.svSize.width/2, totalHeight - i*104 + 52))
		self.sv:addChild(cell)
	end
	self.sv:getInnerContainer():setContentSize(cc.size(self.svSize.width, totalHeight))
    local percent = 100*104*(self.progress - 1)/(totalHeight - self.svSize.height)
    if percent < 0 then
        percent = 0
    elseif percent > 100 then
        percent = 100
    end
    self.sv:jumpToPercentVertical(percent)
end

return WarCollegeUI 