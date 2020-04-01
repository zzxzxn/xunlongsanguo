local GoldmineUI = class("GoldmineUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local NUM_MINE_TYPE = 5

local function getTime(t)
    local h = string.format("%02d", math.floor(t/3600))
    local m = string.format("%02d", math.floor(t%3600/60))
    local s = string.format("%02d", math.floor(t%3600%60%60))
    return h..':'..m..':'..s
end

function GoldmineUI:ctor(jsonObj)
    self.uiIndex = GAME_UI.UI_GOLDMINE
    self.ui = {}
    self.levelId = 0
    self.count = 0
    self.robCount = 0
    self.duration = 0
    self.zoneId = 0
    self.currMineIndex = 0
    self.currMineType = 0
    self.mines = {}
    self.mineArr = {}
    self.mineId = 0
    self.allowFlag = true
    self.moveFlag = 1
    self.touchMine = false
    self.selectAni = nil
    self.nowTime = 0
    self.jsonObj = jsonObj
    self.time = 0
    self.mineDeposit = {GlobalApi:getGlobalValue("mineDeposit5"),GlobalApi:getGlobalValue("mineDeposit4"),GlobalApi:getGlobalValue("mineDeposit3"),GlobalApi:getGlobalValue("mineDeposit2"),GlobalApi:getGlobalValue("mineDeposit1")}
    self.hasCostTime = UserData:getUserObj():getMineDuration()
end

function GoldmineUI:onShow()
    self.nowTime = GlobalData:getServerTime()
    local reportBtn = self.root:getChildByName("report_btn")
    local newImg = reportBtn:getChildByName("new_img")
    newImg:setVisible(UserData:getUserObj():judgeGoldMineIsHasReport())
end

function GoldmineUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bgPl = self.root:getChildByName("bg_pl")
    local mineNode = bgPl:getChildByName("mine_node")
    local bgImg = mineNode:getChildByName("bg_img")
    bgPl:setContentSize(winsize)

    self.selectAni = GlobalApi:createLittleLossyAniByName("goldmine_selected")
    self.selectAni:getAnimation():playWithIndex(0, -1, 1)
    self.selectAni:setVisible(false)
    mineNode:addChild(self.selectAni)

    local bottomNode = self.root:getChildByName("bottom_node")
    local infoImg = bottomNode:getChildByName("info_img")
    infoImg:setContentSize(cc.size(winsize.width, 146))
    local infoNeiImg = bottomNode:getChildByName("info_nei_img")
    infoNeiImg:setContentSize(cc.size(winsize.width - 14, 132))
    self.ui["bottomNode"] = bottomNode
    bottomNode:setPosition(cc.p(winsize.width/2, 0))

    self.mineKeepMaxTime = tonumber(GlobalApi:getGlobalValue("mineKeepMaxTime"))*60
    self.mineSafeTime = tonumber(GlobalApi:getGlobalValue("mineSafeTime"))*60

    local bgImgSize = bgImg:getContentSize()
    local limitLW = winsize.width - bgImgSize.width
    local limitRW = 0
    local preMovePos = nil
    local movePos = nil
    local bgImgDiffPos = nil
    local bgImgPosX = limitLW/2
    local bgImgPosY = -(bgImgSize.height-winsize.height)/2
    local beganPos = nil
    mineNode:setPosition(cc.p(bgImgPosX, bgImgPosY))
    bgPl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            preMovePos = movePos
            movePos = sender:getTouchMovePosition()
            if preMovePos then
                bgImgDiffPos = cc.p(movePos.x - preMovePos.x, movePos.y - preMovePos.y)
                local targetPos = cc.p(bgImgPosX + bgImgDiffPos.x, bgImgPosY)
                if targetPos.x > limitRW then
                    targetPos.x = limitRW
                end
                if targetPos.x < limitLW then
                    targetPos.x = limitLW
                end
                bgImgPosX = targetPos.x
                mineNode:setPosition(targetPos)
            end
            local dis = cc.pGetDistance(beganPos, movePos)
            if dis > 10 and self.moveFlag == 2 then
                bottomNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, -165)), cc.CallFunc:create(function ()
                    self.selectAni:setVisible(false)
                    self.moveFlag = 1
                end)))
                self.moveFlag = 3
            end
        elseif eventType == ccui.TouchEventType.began then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
            beganPos = sender:getTouchBeganPosition()
            self.touchMine = false
        elseif eventType == ccui.TouchEventType.ended then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
            if not self.touchMine and self.moveFlag == 2 then
                bottomNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, -165)), cc.CallFunc:create(function ()
                    self.selectAni:setVisible(false)
                    self.moveFlag = 1
                end)))
                self.moveFlag = 3
            end
        end
    end)

    local bgTimesImg = self.root:getChildByName("bg_times_img")
    local bgLvImg = self.root:getChildByName("bg_lv_img")
    bgTimesImg:setPosition(cc.p(winsize.width, winsize.height))
    bgLvImg:setPosition(cc.p(0, winsize.height))
    -- 剩余掠夺次数
    local timesInfoLabel = bgTimesImg:getChildByName("times_info_tx")
    timesInfoLabel:setString(GlobalApi:getLocalStr("GOLDMINE_OCCUPY_TIMES"))
    self.ui["timesLabel"] = bgTimesImg:getChildByName("times_tx")
    -- 剩余开采时间
    local remainInfoLabel = bgTimesImg:getChildByName("remain_info_tx")
    remainInfoLabel:setString(GlobalApi:getLocalStr("GOLDMINE_REMAIN_TIME"))
    self.ui["remainLabel"] = bgTimesImg:getChildByName("remain_tx")
    -- 金矿开采区
    local lvInfoLabel = bgLvImg:getChildByName("lv_info_tx")
    lvInfoLabel:setString(GlobalApi:getLocalStr("GOLDMINE_LEVEL"))
    self.ui["lvLabel"] = bgLvImg:getChildByName("lv_tx")
    -- 矿区人数
    local numInfoLabel = bgLvImg:getChildByName("num_info_tx")
    numInfoLabel:setString(GlobalApi:getLocalStr("GOLDMINE_PEOPLE_NUM"))
    self.ui["numLabel"] = bgLvImg:getChildByName("num_tx")

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.GOLDMINE)
    btn:setPosition(cc.p(53/2 + 5, winsize.height - 120 - 2))
    self.root:addChild(btn)

    local reportBtn = self.root:getChildByName("report_btn")
    local newImg = reportBtn:getChildByName("new_img")
    newImg:setVisible(UserData:getUserObj():judgeGoldMineIsHasReport())
    local returnBtn = self.root:getChildByName("return_btn")
    reportBtn:setPosition(cc.p(winsize.width - 40, winsize.height - 120))
    returnBtn:setPosition(cc.p(winsize.width, winsize.height + 5))
    reportBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
            GoldmineMgr:showGoldmineReport()
        end
    end)
    returnBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
           
            UserData:getUserObj().tips.mine_report = nil
            if self.mineId > 0 then
                UserData:getUserObj().goldMineTag = 1
                UserData:getUserObj().mine_id = 1
            else
                UserData:getUserObj().goldMineTag = 2
                UserData:getUserObj().mine_id = nil
            end
            --if self.time > 0 then
                --UserData:getUserObj():addMineDuration(math.floor(self.time*0.08) + self.duration)
            --else
                --UserData:getUserObj():addMineDuration(self.duration)
            --end
            UserData:getUserObj():setMineDuration(self.hasCostTime) 
            UserData:getUserObj():addGlobalTime()

            GoldmineMgr:hideGoldmine()
        end
    end)
    self.ui["goldDepositBg"] = infoNeiImg:getChildByName("gold_deposit_bg")
    self.ui["goldDepositBg"]:setPosition(cc.p(winsize.width-(960-909), 108))
    self.ui["goldDepositLabel"] = self.ui["goldDepositBg"]:getChildByName("gold_deposit_tx")
    local infoNeiImg2 = infoNeiImg:getChildByName("info_nei_img2")
    infoNeiImg2:setPosition(cc.p(winsize.width/2 + (516 - winsize.width/2), 48))
    local mineNameLabel = infoNeiImg2:getChildByName("mine_name_tx")
    local goldHourLabel = infoNeiImg2:getChildByName("gold_hour_tx")
    local goldHourInfoLabel = infoNeiImg2:getChildByName("gold_hour_info_tx")
    goldHourInfoLabel:setString(GlobalApi:getLocalStr("STR_GOLD_PERHOUR"))

    local addition_img = infoNeiImg2:getChildByName("addition_img")
    addition_img:setTouchEnabled(true)
    addition_img:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local additionPos = infoNeiImg2:convertToWorldSpace(cc.p(addition_img:getPosition()))
            TipsMgr:showJadeSealAdditionTips(additionPos, "mine")
        end
    end)
    local addition_tx = addition_img:getChildByName("addition_tx")
    local addition = UserData:getUserObj():getJadeSealAddition("mine")
    addition_tx:setString(addition[2] .. "%")
    if not addition[1] then
        ShaderMgr:setGrayForWidget(addition_img)
        addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
    end


	local nameBg = infoNeiImg:getChildByName('name_bg')
	self.ui["nameBg"] = nameBg
	self.ui["name"] = nameBg:getChildByName('name')
	self.ui["legionName"] = nameBg:getChildByName('legion_name')
	self.ui["legionImg"] = nameBg:getChildByName('legion_img')
	self.ui["fightforceTx"] = nameBg:getChildByName('fightforce_tx')
	self.ui["noCopyDesc"] = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    self.ui["noCopyDesc"]:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
    self.ui["noCopyDesc"]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.ui["noCopyDesc"]:setAnchorPoint(cc.p(0.5, 1))
    self.ui["noCopyDesc"]:setPosition(cc.p(65, 35))
    self.ui["noCopyDesc"]:setMaxLineWidth(110)
    infoNeiImg:addChild(self.ui["noCopyDesc"])

    self.ui["goldAccuInfoLabel"] = infoNeiImg2:getChildByName("gold_accu_info_tx")
    self.ui["goldAccuInfoLabel"]:setString(GlobalApi:getLocalStr("ACCUMULATE_GOLD"))
    self.ui["goldAccuLabel"] = self.ui["goldAccuInfoLabel"]:getChildByName("gold_accu_tx")
    self.ui["goldRemainInfoLabel"] = infoNeiImg2:getChildByName("gold_remain_info_tx")
    self.ui["goldRemainInfoLabel"]:setString(GlobalApi:getLocalStr("GOLDMINE_COLLECT_TIME"))
    self.ui["goldRemainLabel"] = self.ui["goldRemainInfoLabel"]:getChildByName("gold_remain_tx")
    self.ui["goldExtraInfoLabel"] = infoNeiImg2:getChildByName("gold_extra_info_tx")
    self.ui["goldExtraInfoLabel"]:setString(GlobalApi:getLocalStr("GOLDMINE_EXTRA_GOLD"))
    self.ui["goldExtraLabel"] = self.ui["goldExtraInfoLabel"]:getChildByName("gold_extra_tx")
    self.ui["goldExtraGoldLabel"] = self.ui["goldExtraInfoLabel"]:getChildByName("gold_extra_gold_tx")
    self.ui["goldExtraInfoLabel2"] = infoNeiImg2:getChildByName("gold_extra_info_tx2")
    self.ui["goldExtraInfoLabel2"]:setString(GlobalApi:getLocalStr("GOLDMINE_PROMPT_7"))
    
    local roleNode = infoNeiImg:getChildByName("role_node")
    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    roleNode:addChild(iconCell.awardBgImg)
    iconCell.awardBgImg:setScale(0.65)
    self.ui["headpicBg"]= iconCell.awardBgImg
    self.ui["headpicIcon"] = iconCell.awardImg
    self.ui["headpicFrame"] = iconCell.headframeImg

    local occupyBtn = infoNeiImg:getChildByName("occupy_btn")
    occupyBtn:setPosition(cc.p(winsize.width-47, 56))
    self.ui["occupyBtnLabel"] = occupyBtn:getChildByName("text")
    self.currMineStatus = 1
    occupyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
            self:occupy()
        end
    end)
    
    self.occupyAni = GlobalApi:createLittleLossyAniByName("goldmine_exploiting2")
    self.occupyAni:getAnimation():playWithIndex(0, -1, 1)
    self.occupyAni:setVisible(false)
    mineNode:addChild(self.occupyAni)
    
    -- 矿区
    local minesNum = {1, 4, 8, 10, 10}
    local minesCount = {0, 1, 5, 13, 23}
    local aniScale = {1, 0.9, 0.8, 0.7, 0.6}
    local aniOffsetY = {-50, -30, -30, -20, -20}
    local aniOffsetX = {20, 20, 20, 0, 0}
    local mineNames = {GlobalApi:getLocalStr("GOLDMINE_NAME_1"), GlobalApi:getLocalStr("GOLDMINE_NAME_2"), GlobalApi:getLocalStr("GOLDMINE_NAME_3"), GlobalApi:getLocalStr("GOLDMINE_NAME_4"), GlobalApi:getLocalStr("GOLDMINE_NAME_5")}
    for i = 1, NUM_MINE_TYPE do
        for j = 1, minesNum[i] do
            local mine = mineNode:getChildByName("mine_" .. i .. "_" .. j)
            mine:setLocalZOrder(1)
            local minePosX, minePosY = mine:getPosition()
            local size = mine:getContentSize()
            mine:setSwallowTouches(false)
            local labelBg = cc.Sprite:create("uires/ui/common/common_num_bg3.png")
            mine:addChild(labelBg)
            labelBg:setPosition(cc.p(size.width/2, 0))
            labelBg:setVisible(false)
            local label = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
            label:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
            label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            label:setAnchorPoint(cc.p(0, 0.5))
            label:setPosition(cc.p(60, 24))
            labelBg:addChild(label)
            local allowImg = cc.Sprite:create("uires/ui/goldmine/mianzhan.png")
            allowImg:setPosition(cc.p(size.width - 30, size.height - 20))
            allowImg:setVisible(false)
            mine:addChild(allowImg)
            -- 矿区有人开采的动画
            local exploitAni = GlobalApi:createLittleLossyAniByName("goldmine_exploiting")
            exploitAni:setPosition(cc.p(minePosX + aniOffsetX[i], minePosY + 40))
            exploitAni:getAnimation():playWithIndex(0, -1, 1)
            exploitAni:setVisible(false)
            exploitAni:setScale(aniScale[i])
            mineNode:addChild(exploitAni)
            local mineIndex = minesCount[i]+j
            self.mineArr[mineIndex] = {
                labelBg = labelBg,
                mine = mine,
                label = label,
                allowImg = allowImg,
                exploitAni = exploitAni
            }
            mine:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    AudioMgr.PlayAudio(11)
                    local point1 = sender:getTouchBeganPosition()
                    local point2 = sender:getTouchEndPosition()
                    local dis = cc.pGetDistance(point1,point2)
                    if dis > 10 then
                        return
                    end
                    self.touchMine = true
                    if self.moveFlag == 1 then
                        bottomNode:runAction(cc.Sequence:create(cc.MoveBy:create(0.2, cc.p(0, 165)), cc.CallFunc:create(function ()
                            self.moveFlag = 2
                        end)))
                        self.moveFlag = 3
                    end
                    if self.currMineIndex == mineIndex then
                        if not self.selectAni:isVisible() then
                            self.selectAni:setVisible(true)
                            self.selectAni:setScale(aniScale[i])
                            self.selectAni:setPosition(cc.p(minePosX, minePosY + aniOffsetY[i]))
                        end
                        return
                    end
                    self.selectAni:setVisible(true)
                    self.selectAni:setScale(aniScale[i])
                    self.selectAni:setPosition(cc.p(minePosX, minePosY + aniOffsetY[i]))
                    self.currMineIndex = mineIndex
                    self.currMineType = i
                    mineNameLabel:setString(GlobalApi:getLocalStr("GOLDMINE_NAME_" .. i))
                    goldHourLabel:setString(self.conf["level" .. NUM_MINE_TYPE-i+1])
                    self:updateBottom()
                    self:step(0)
                end
            end)
        end
    end

    self:getGoldmine(self.jsonObj)
    self.jsonObj = nil

    self.nowTime = GlobalData:getServerTime()
    local scheduler = self.root:getScheduler()
    local schedulerEntry = scheduler:scheduleScriptFunc(function (dt)
        self:step(dt)
    end, 0.08, false)
    local function onNodeEvent(event)
        if event == "exit" and schedulerEntry ~= 0 then
            scheduler:unscheduleScriptEntry(schedulerEntry)
            schedulerEntry = 0
            self.root:unregisterScriptHandler()
        end
    end
    self.root:registerScriptHandler(onNodeEvent)

    self:addCustomEventListener('mine_get',function(json)
        print('====================================')
        printall(json)
        -- self:praseJson(jsonObj)
    end)
    SocketMgr:send("set_flag","user",{
        flag = {['mine_'..self.levelId..'_'..self.zoneId] = 1}
    })
    -- SocketMgr:send("get_chat_log","chat",{flag = 'mine'})

    local addition = UserData:getUserObj():getJadeSealAddition("mine")
    self.jadeSealAddition = 1 + addition[2]/100
end

function GoldmineUI:updateBottom()
    local cunrrMine = self.mines[tostring(self.currMineIndex)] 
	self.ui["noCopyDesc"]:setVisible(false)
	self.ui["nameBg"]:setVisible(false)
    if cunrrMine then
		self.ui["nameBg"]:setVisible(true)
        self.ui["name"]:setString(cunrrMine.name)
		if cunrrMine.legion_name then
			self.ui["legionName"]:setString(cunrrMine.legion_name)
			self.ui["legionName"]:setVisible(true)
		else
			self.ui["legionName"]:setVisible(false)
		end
		if cunrrMine.fight_force then
			self.ui["fightforceTx"]:setString(cunrrMine.fight_force)
			self.ui["fightforceTx"]:setVisible(true)
		else
			self.ui["fightforceTx"]:setVisible(false)
		end
		if cunrrMine.legion_icon then
			self.ui["legionImg"]:loadTexture('uires/ui/legion/legion_' .. cunrrMine.legion_icon .. '_jun.png')
			self.ui["legionImg"]:setVisible(true)
		else
			self.ui["legionImg"]:setVisible(false)
		end
		
        self.ui["goldAccuInfoLabel"]:setVisible(true)
        self.ui["goldRemainInfoLabel"]:setVisible(true)
        if self.currMineIndex == self.mineId then
            self.currMineStatus = 3
            self.ui["occupyBtnLabel"]:setString(GlobalApi:getLocalStr("STR_RETREAT1"))
            self.ui["goldDepositBg"]:setVisible(false)
            self.ui["goldExtraInfoLabel"]:setVisible(true)
            self.ui["goldExtraInfoLabel2"]:setVisible(false)
        else
            self.currMineStatus = 2
            if self.robCount > 0 then
                self.ui["occupyBtnLabel"]:setString(GlobalApi:getLocalStr("STR_ROB"))
                self.ui["goldDepositBg"]:setVisible(true)
            else
                self.ui["occupyBtnLabel"]:setString(GlobalApi:getLocalStr("STR_DRIVE"))
                self.ui["goldDepositBg"]:setVisible(false)
            end
            self.ui["goldExtraInfoLabel"]:setVisible(false)
            self.ui["goldExtraInfoLabel2"]:setVisible(true)
        end
        local heroConf = GameData:getConfData("hero")
        local headpicUrl
        if tonumber(cunrrMine.headpic) == 0 then
            headpicUrl = GameData:getConfData('settingheadicon')[1].icon
        else
            headpicUrl = GameData:getConfData('settingheadicon')[tonumber(cunrrMine.headpic)].icon
        end
        self.ui["headpicBg"]:loadTexture(COLOR_FRAME[heroConf[cunrrMine.main_role].quality])
        self.ui["headpicIcon"]:setVisible(true)
        self.ui["headpicIcon"]:loadTexture(headpicUrl)
        self.ui["headpicFrame"]:setVisible(true)
        self.ui["headpicFrame"]:loadTexture(GlobalApi:getHeadFrame(cunrrMine.headframe))
    else
        self.currMineStatus = 1
        self.ui["noCopyDesc"]:setString(GlobalApi:getLocalStr("STR_NOBODY_OCCUPY"))
		self.ui["noCopyDesc"]:setVisible(true)
        self.ui["goldAccuInfoLabel"]:setVisible(false)
        self.ui["goldRemainInfoLabel"]:setVisible(false)
        self.ui["occupyBtnLabel"]:setString(GlobalApi:getLocalStr("STR_OCCUPY2"))
        self.ui["goldDepositBg"]:setVisible(false)
        self.ui["headpicBg"]:loadTexture("uires/ui/common/frame_default.png")
        self.ui["headpicIcon"]:setVisible(false)
        self.ui["headpicFrame"]:setVisible(false)
        self.ui["goldExtraInfoLabel"]:setVisible(false)
        self.ui["goldExtraInfoLabel2"]:setVisible(false)
    end
end

-- 计时器
function GoldmineUI:step(dt)
    --print('+++++++++++++++++' ..self.mineId)
    if self.mineId > 0 then
        self.time = self.time + 1
    end
    if dt then
        self.nowTime = self.nowTime + dt
    else
        self.nowTime = GlobalData:getServerTime()
    end
    for k, v in pairs(self.mines) do
        local occupyTime = self.nowTime - tonumber(v.time) -- 占领时间
        local remainTime = self.mineKeepMaxTime - occupyTime - tonumber(v.duration)
        self.hasCostTime = self.mineKeepMaxTime - remainTime
        --print('remainTime______________++++++++' .. self.hasCostTime)
        if occupyTime < self.mineSafeTime or remainTime < self.mineSafeTime then -- 保护时间内
            self.mineArr[tonumber(k)].allowImg:setVisible(true)
            self.mineArr[tonumber(k)].label:setTextColor(COLOR_TYPE.RED)
        else
            self.mineArr[tonumber(k)].allowImg:setVisible(false)
            self.mineArr[tonumber(k)].label:setTextColor(COLOR_TYPE.ORANGE)
        end
        if remainTime <= 0 then -- 到时间了
            self.mineArr[tonumber(k)].labelBg:setVisible(false)
            self.mineArr[tonumber(k)].label:setString("")
            self.mineArr[tonumber(k)].allowImg:setVisible(false)
            self.mineArr[tonumber(k)].exploitAni:setVisible(false)
            self.mines[k] = nil
            if tonumber(k) == self.mineId then -- 如果到时间的是我的矿
                self.occupyAni:setVisible(false)
            end
            if tonumber(k) == self.currMineIndex then -- 如果到时间的是当前选中的矿
				self.ui["noCopyDesc"]:setVisible(true)
				self.ui["nameBg"]:setVisible(false)
                self.currMineStatus = 1
                self.ui["noCopyDesc"]:setString(GlobalApi:getLocalStr("STR_NOBODY_OCCUPY"))
                self.ui["goldAccuInfoLabel"]:setVisible(false)
                self.ui["goldRemainInfoLabel"]:setVisible(false)
                self.ui["goldExtraInfoLabel"]:setVisible(false)
                self.ui["goldExtraInfoLabel2"]:setVisible(false)
                self.ui["occupyBtnLabel"]:setString(GlobalApi:getLocalStr("STR_OCCUPY2"))
                self.ui["goldDepositBg"]:setVisible(false)
            end
        else
            self.mineArr[tonumber(k)].labelBg:setVisible(true)
            self.mineArr[tonumber(k)].exploitAni:setVisible(true)
            local timeStr = getTime(remainTime)
            self.mineArr[tonumber(k)].label:setString(timeStr)
            if self.mineId == tonumber(k) then -- 这个矿是我占的
                self.ui["remainLabel"]:setString(timeStr)
            end
        end
    end
    local currMine = self.mines[tostring(self.currMineIndex)]
    if currMine then -- 如果当前选中的矿有人占领
        local isActiveAddition = currMine.ext or 0
        local occupyTime = self.nowTime - tonumber(currMine.time) -- 占领时的时间
        local remainTime = self.mineKeepMaxTime - occupyTime  -- 剩余时间
        self.ui["goldAccuInfoLabel"]:setVisible(true)
        self.ui["goldRemainInfoLabel"]:setVisible(true)
        self.ui["goldRemainLabel"]:setString(getTime(occupyTime))
        local aleadyHour = math.ceil(occupyTime/3600)
        aleadyHour = aleadyHour <= 0 and 1 or aleadyHour
        aleadyHour = aleadyHour > 4 and 4 or aleadyHour
        local timeAward = self.conf["hour" .. aleadyHour]
        aleadyHour = aleadyHour - 1
        local baseGold = self.conf["level" .. NUM_MINE_TYPE-self.currMineType+1]
        local extraTime = remainTime%3600
        self.ui["goldExtraLabel"]:setString(getTime(extraTime))
        -- 累积金币
        local accuGold = currMine.gold + math.floor(occupyTime/3600*baseGold)
        local accuGold2 = currMine.gold + math.floor(self.mineKeepMaxTime/3600*baseGold)
        while aleadyHour > 0 do
            accuGold = accuGold + baseGold*self.conf["hour" .. aleadyHour]
            accuGold2 = accuGold2 + baseGold*self.conf["hour" .. aleadyHour]
            aleadyHour = aleadyHour - 1
        end
        if isActiveAddition == 1 then
            accuGold = math.floor(accuGold*self.jadeSealAddition)
        end
        if timeAward and timeAward > 0 then
            self.ui["goldExtraInfoLabel"]:setString(GlobalApi:getLocalStr("GOLDMINE_EXTRA_GOLD"))
            if isActiveAddition == 1 then
                self.ui["goldExtraGoldLabel"]:setString(math.floor(timeAward*baseGold*self.jadeSealAddition))
            else
                self.ui["goldExtraGoldLabel"]:setString(math.floor(timeAward*baseGold))
            end
        else
            if isActiveAddition == 1 then
                accuGold2 = math.floor(accuGold2*self.jadeSealAddition)
            end
            self.ui["goldExtraInfoLabel"]:setString(GlobalApi:getLocalStr("GOLDMINE_EXTRA_GOLD_1"))
            self.ui["goldExtraGoldLabel"]:setString(tostring(accuGold2))
        end
        self.ui["goldAccuLabel"]:setString(tostring(math.floor(accuGold)))
        local needGold = math.floor(accuGold/100*self.mineDeposit[self.currMineType])
        self.ui["goldDepositLabel"]:setString(needGold)
    end
end

function GoldmineUI:update()
    for k, v in pairs(self.mines) do
        if self.mineId == tonumber(k) then -- 这个矿是我占的
            local posx, posy = self.mineArr[tonumber(k)].mine:getPosition()
            local size = self.mineArr[tonumber(k)].mine:getContentSize()
            self.occupyAni:setVisible(true)
            self.occupyAni:setPosition(cc.p(posx, posy + size.height/2 + 30))
            break
        end
    end
    local lastTime = self.mineKeepMaxTime - self.duration
    if lastTime < 0 then
        lastTime = 0
    end
    self.ui["remainLabel"]:setString(getTime(lastTime))
    self:step()
end
-- "idle" 没占到矿
-- "occupy_mine" 成功占领了矿
-- "prepare_mine" 掠夺矿
-- 1：占领 2：掠夺 3：撤退
function GoldmineUI:occupy()
    local myMine = self.mines[tostring(self.mineId)]
    local currMine = self.mines[tostring(self.currMineIndex)]
    if self.currMineStatus == 1 then -- 占领
        if self.duration < self.mineKeepMaxTime then
            if myMine and self.mineArr[self.mineId].allowImg:isVisible() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_1"), COLOR_TYPE.RED)
                return
            end
            local function callback()
                local obj = {
                    id = self.currMineIndex
                }
                MessageMgr:sendPost("occupy", "mine", json.encode(obj), function (jsonObj)
                    if jsonObj.code == 0 then
                        if jsonObj.data.status == "occupy_mine" then -- 占领成功
                            if jsonObj.data.mine then
                                if myMine then -- 如果当前我有矿
                                    self.mineArr[self.mineId].allowImg:setVisible(false)
                                    self.mineArr[self.mineId].labelBg:setVisible(false)
                                    self.mineArr[self.mineId].exploitAni:setVisible(false)
                                    self.mineArr[self.mineId].label:setString("")
                                    self.mines[tostring(self.mineId)] = nil
                                end
                                self.mines[tostring(self.currMineIndex)] = jsonObj.data.mine
                                self.duration = jsonObj.data.mine.duration
                                self.mineId = self.currMineIndex
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_OCCUPY_SUCCESS"), COLOR_TYPE.GREEN)
                                self:updateBottom()
                                self:update()
                            end
                        elseif jsonObj.data.status == "prepare_mine" then -- 当前矿有人,刷新界面
                            promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_8"), MESSAGE_BOX_TYPE.MB_OK, function ()
                                self:getGoldmine()
                            end)
                        else -- 其他情况,刷新界面
                            self:getGoldmine()
                        end
                    else
                        self:errorCode(jsonObj.code)
                    end
                end)
            end
            if myMine then
                promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_DESC_1"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    callback()
                end)
            else
                callback()
            end
        else
            promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_5"), COLOR_TYPE.RED)
        end
    elseif self.currMineStatus == 2 then -- 掠夺
        if self.duration < self.mineKeepMaxTime then
            if self.mineArr[self.currMineIndex].allowImg:isVisible() then
               promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_4"), COLOR_TYPE.RED)
               return
            end
            if myMine and self.mineArr[self.mineId].allowImg:isVisible() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_2"), COLOR_TYPE.RED)
                return
            end
            local gold = UserData:getUserObj():getGold()
            local depositGold = tonumber(GlobalApi:getGlobalValue("mineDeposit" .. NUM_MINE_TYPE-self.currMineType+1)) -- 保证金比例
            local needGold = tonumber(self.ui["goldDepositLabel"]:getString())
            if gold >= needGold then
                local function callback()
                    local obj = {
                        id = self.currMineIndex
                    }
                    MessageMgr:sendPost("occupy", "mine", json.encode(obj), function (jsonObj)
                        if jsonObj.code == 0 then
                            if jsonObj.data.status == "prepare_mine" then
                                if jsonObj.data.info then
                                    local customObj = {
                                        mineIndex = self.currMineIndex,
                                        info = jsonObj.data.info,
                                        enemy = jsonObj.data.enemy,
                                        rand1 = jsonObj.data.rand1,
                                        rand2 = jsonObj.data.rand2,
                                        rand_pos = jsonObj.data.rand_pos,
                                        rand_attrs = jsonObj.data.rand_attrs
                                    }
                                    BattleMgr:playBattle(BATTLE_TYPE.GOLDMINE, customObj, function ()
                                        MainSceneMgr:showMainCity(function()
                                            GoldmineMgr:showGoldmine()
                                        end, nil, GAME_UI.UI_GOLDMINE)
                                    end)
                                end
                            elseif jsonObj.data.status == "occupy_mine" then -- 当前矿没人，直接占领成功
                                if jsonObj.data.mine then
                                    if myMine then -- 如果当前我有矿
                                        self.mineArr[self.mineId].allowImg:setVisible(false)
                                        self.mineArr[self.mineId].labelBg:setVisible(false)
                                        self.mineArr[self.mineId].exploitAni:setVisible(false)
                                        self.mineArr[self.mineId].label:setString("")
                                        self.mines[tostring(self.mineId)] = nil
                                    end
                                    self.mines[tostring(self.currMineIndex)] = jsonObj.data.mine
                                    self.duration = jsonObj.data.mine.duration
                                    self.mineId = self.currMineIndex
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_6"), COLOR_TYPE.GREEN)
                                    self:updateBottom()
                                    self:update()
                                end
                            else -- 其他情况,刷新界面
                                self:getGoldmine()
                            end
                        else
                            self:errorCode(jsonObj.code)
                        end
                    end)
                end
                if needGold == 0 then
                    callback()
                else
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("GOLDMINE_DESC_2"), depositGold .. "%"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        callback()
                    end)
                end
            else
                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("GOLDMINE_OCCUPY_MSG_1"), depositGold .. "%"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                    GlobalApi:getGotoByModule('gold')
                end, GlobalApi:getLocalStr("GO_AND_GET"), GlobalApi:getLocalStr("MESSAGE_NO"))
            end
        else
            promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_5"), COLOR_TYPE.RED)
        end
    elseif self.currMineStatus == 3 then -- 撤退
        if myMine and self.mineArr[self.mineId].allowImg:isVisible() then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_PROMPT_3"), COLOR_TYPE.RED)
            return
        end
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_OCCUPY_MSG_2"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
            local obj = {
                id = self.currMineIndex
            }
            MessageMgr:sendPost("leave", "mine", json.encode(obj), function (jsonObj)
                if jsonObj.code == 0 then
                    self.duration = jsonObj.data.duration
                    self.mines[tostring(self.currMineIndex)] = nil
                    self.mineId = 0
                    local mine = self.mineArr[self.currMineIndex]
                    if mine then
                        mine.allowImg:setVisible(false)
                        mine.labelBg:setVisible(false)
                        mine.exploitAni:setVisible(false)
                        mine.label:setString("")
                    end
                    self.occupyAni:setVisible(false)
                    self:updateBottom()
                    GlobalApi:parseAwardData(jsonObj.data.awards)
                    local costs = jsonObj.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_RETREAT_SUCCESS"), COLOR_TYPE.GREEN)
                    local currLv = UserData:getUserObj():getLv()
                    if currLv >= self.levelId*10 then
                        self:changeMines()
                    end
                else
                    self:errorCode(jsonObj.code)
                end
            end)
        end, GlobalApi:getLocalStr("STR_RETREAT1"), GlobalApi:getLocalStr("MESSAGE_NO"))
    end
end

-- 换矿区了,更新金矿所有界面
function GoldmineUI:changeMines()
    local winsize = cc.Director:getInstance():getWinSize()
    self.currMineIndex = 0
    self.ui["bottomNode"]:stopAllActions()
    self.ui["bottomNode"]:setPosition(cc.p(winsize.width/2, 0))
    self.moveFlag = 1
    for k, v in pairs(self.mines) do
        self.mineArr[tonumber(k)].allowImg:setVisible(false)
        self.mineArr[tonumber(k)].labelBg:setVisible(false)
        self.mineArr[tonumber(k)].exploitAni:setVisible(false)
        self.mineArr[tonumber(k)].label:setString("")
        self.occupyAni:setVisible(false)
    end
    self.selectAni:setVisible(false)
    self:getGoldmine()
end

function GoldmineUI:praseJson(jsonObj)
    if jsonObj.code == 0 then
        self.levelId = jsonObj.data.level_id
        self.count = jsonObj.data.count
        self.robCount = tonumber(GlobalApi:getGlobalValue("mineRobMaxCount")) - jsonObj.data.rob_count
        self.duration = jsonObj.data.duration
        self.zoneId = jsonObj.data.zone_id
        self.mineId = jsonObj.data.mine_id
        self.mines = jsonObj.data.mines
        local levelConf = GameData:getConfData("level")
        local maxLevel = #levelConf
        local playerLevel = UserData:getUserObj():getLv()
        self.levelId = self.levelId <= 0 and 1 or self.levelId
        if playerLevel >= maxLevel then -- 满级了
            self.ui["lvLabel"]:setString("Lv." .. self.levelId*10 .. "-" .. playerLevel .. "(" .. self.zoneId .. GlobalApi:getLocalStr("STR_AREA") .. ")")
        else
            self.ui["lvLabel"]:setString("Lv." .. self.levelId*10 .. "-" .. ((self.levelId+1)*10-1).. "(" .. self.zoneId .. GlobalApi:getLocalStr("STR_AREA") .. ")")
        end
        self.ui["timesLabel"]:setString(self.robCount)
        local mineConf = GameData:getConfData("goldmine")
        self.conf = mineConf[self.levelId]
        self.ui["numLabel"]:setString(self.count .. "/" .. self.conf.mineUserMaxCount)
        if jsonObj.data.deposit then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("GOLDMINE_DESC_3"),jsonObj.data.deposit), COLOR_TYPE.GREEN)
        end
        self.time = 0
        if self.mineId > 0 then
            local mine = self.mines[tostring(self.mineId)]
            local time = GlobalData:getServerTime() - mine.time
            UserData:getUserObj():setMineDuration(time + self.duration)
        else
            UserData:getUserObj():setMineDuration(self.duration)
        end
        self:updateBottom()
        self:update()
    end
end

function GoldmineUI:getGoldmine(jsonObj)
    if jsonObj then
        self:praseJson(jsonObj)
    else
        MessageMgr:sendPost("get", "mine", "{}", function (jsonObj)
            self:praseJson(jsonObj)
        end)
    end
end

function GoldmineUI:errorCode(code)
    if code == 101 then -- 要掠夺的矿换人了
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_1"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 102 then -- 自己占领的矿被攻击中，不能掠夺其他矿
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_2"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 103 then -- 别人当前正处于保护时间
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_3"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 104 then -- 最后5分钟不能被掠夺
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_4"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 105 then -- 我的占领时间用完了
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_PROMPT_5"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 106 then -- 我当前正处于保护时间
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_5"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 107 then -- 我的矿处于最后5分钟不能被掠夺
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_6"), MESSAGE_BOX_TYPE.MB_OK)
    elseif code == 108 then -- 对方已经撤离，直接占领成功
        promptmgr:showMessageBox(GlobalApi:getLocalStr("GOLDMINE_ERROR_7"), MESSAGE_BOX_TYPE.MB_OK)
    end
    self:getGoldmine()
end

return GoldmineUI
