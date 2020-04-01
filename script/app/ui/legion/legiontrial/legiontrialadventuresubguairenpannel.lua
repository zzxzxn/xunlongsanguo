local LegionTrialAdventureSubGuaiRenPannelUI = class("LegionTrialAdventureSubGuaiRenPannelUI")
local ClassItemCell = require('script/app/global/itemcell')

-- 怪人
function LegionTrialAdventureSubGuaiRenPannelUI:init(pos,serverData,trial,parent)
    self.rootBG = self.root:getChildByName("root")
    self.pos = pos
    self.serverData = serverData
    self.trial = trial
    self.parent = parent

    self:initLeft()
    self:initRight()
    self:refreshStartBtnState()
end

function LegionTrialAdventureSubGuaiRenPannelUI:initLeft()
    local leftPanel = self.rootBG:getChildByName('leftPanel')
    local tipsBg = leftPanel:getChildByName('tipsBg')

    local tips = tipsBg:getChildByName('tips')
    tips:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC34'))

    local tips2 = tipsBg:getChildByName('tips2')
    tips2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC35'))

    local tips3 = tipsBg:getChildByName('tips3')
    tips3:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC36'))

    -- spine
    if leftPanel:getChildByName('left_spine') then
        leftPanel:removeChildByName('left_spine')
    end
    local spine = GlobalApi:createSpineByName('trial_monster', "spine/city_building/trial_monster", 1)
    spine:setName('left_spine')
    spine:setPosition(cc.p(152,55))
    leftPanel:addChild(spine)
    spine:setAnimation(0, 'idle', true)
    spine:setVisible(false)
    -- 
    local leftNode = leftPanel:getChildByName('left_node')
    local fightforceImg = leftNode:getChildByName('fightforce_img')
    local fightforceTx = fightforceImg:getChildByName('fightforce_tx')

    if fightforceImg:getChildByName('fightforceLabel') then
        fightforceImg:removeChildByName('fightforceLabel')
    end
    local fightforceLabel = cc.LabelAtlas:_create(self.serverData.data.param1, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setName('fightforceLabel')
    fightforceLabel:setScale(0.8)     
    fightforceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    fightforceImg:addChild(fightforceLabel)
    fightforceLabel:setPosition(cc.p(fightforceTx:getPositionX(),fightforceTx:getPositionY()))
    
    leftPanel:getChildByName('img'):setLocalZOrder(1000)
    spine:setLocalZOrder(105)
    tipsBg:setLocalZOrder(101)
    leftNode:setLocalZOrder(200)
end

function LegionTrialAdventureSubGuaiRenPannelUI:initRight()
    self.legionTrialBaseConfig = GameData:getConfData('legiontrialbaseconfig')
    local legionTrialBaseConfigData = self.legionTrialBaseConfig[LegionTrialMgr:calcTrialLv(self.trial.join_level)]
    local serverData = self.serverData
    local data = serverData.data

    local rightPanel = self.rootBG:getChildByName('panel1')

    self.startBtn = rightPanel:getChildByName('rise_btn')
    self.autoStartBtn = rightPanel:getChildByName('auto_rise_btn')
    local autoInfoTx = self.autoStartBtn:getChildByName('info_tx')
    autoInfoTx:setString(GlobalApi:getLocalStr('STR_AUTO_CHALLENGE'))
    self.autoStartBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local nowTime = GlobalData:getServerTime()
            if nowTime >= self.serverData.data.time then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end
            LegionTrialMgr:legionTrialStartChallengeMonsterFromServer(self.serverData.index,function (data)
                local customObj = {}
                customObj.trial_robot = data.trial_robot
                customObj.index = self.serverData.index
                customObj.skipFight = true
                local function callBack(starNum)
                    -- 刷新数据
                    self.serverData.data.pass = 1
                    self.serverData.data.param2 = starNum
                    self:refreshStartBtnState()
                    LegionTrialMgr:refreshLegionTrialAdventure(self.serverData)

                    self.parent.adventures[self.pos] = self.serverData
                    self.parent:refreshMark()
                    self:initRight()
                end
                LegionMgr:showLegionActivitySelRoleListNewLegionTrialUI(BATTLE_TYPE.NEW_LEGION_TRIAL, customObj,callBack)
            end)
        end
    end)
    -- 显示
    local realBg = rightPanel:getChildByName('real_bg')
    local desc = realBg:getChildByName('desc')
    desc:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC45'))

    local base_desc = realBg:getChildByName('base_desc')
    base_desc:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC46'))

    local base_desc2 = realBg:getChildByName('base_desc2')
    base_desc2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC47'))

    local reward_des2 = realBg:getChildByName('reward_des2')
    reward_des2:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC48'))

    -- 奖励品
    local baseAward = realBg:getChildByName('base_award')
    local crackpotBaseAward = legionTrialBaseConfigData.crackpotBaseAward
    local disPlayData1 = DisplayData:getDisplayObjs(crackpotBaseAward)[1]

    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, disPlayData1, baseAward)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.lvTx:setString('x'..disPlayData1:getNum())
    local godId = disPlayData1:getGodId()
    disPlayData1:setLightEffect(cell.awardBgImg)

    --
    for i = 1,3 do
        local star = realBg:getChildByName('star' .. i)
        if data.param2 >= i then
            star:setVisible(true)
        else
            star:setVisible(false)
        end
    end

    -- 货币数量
    local rewardNum = realBg:getChildByName('reward_num')
    local crackpotAdditionalAward = legionTrialBaseConfigData['crackpotAdditionalAward' .. data.param2]
    local disPlayData2 = DisplayData:getDisplayObjs(crackpotAdditionalAward)[1]
    rewardNum:setString(disPlayData2:getNum())

    -- 战斗力self.serverData.data.param1

end

function LegionTrialAdventureSubGuaiRenPannelUI:refreshStartBtnState()
    local startBtn = self.startBtn
    local infoTx = startBtn:getChildByName('info_tx')

    local state = 1

    infoTx:setColor(COLOR_TYPE.WHITE)
    infoTx:enableOutline(cc.c4b(165, 70, 0, 255), 1)

    startBtn:setTouchEnabled(true)
    if self.serverData.data.pass == 1 then    -- 已经通关
        if self.serverData.data.award_got == 1 then -- 已经领取
            infoTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC50'))
            startBtn:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(startBtn)

            infoTx:setColor(COLOR_TYPE.GRAY)
            infoTx:enableOutline(COLOR_TYPE.BLACK)
        else
            infoTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC49'))
            state = 1
        end
        self.autoStartBtn:setVisible(false)
        startBtn:setPosition(cc.p(294, 48))
    else
        infoTx:setString(GlobalApi:getLocalStr('STR_MANUAL_CHALLENGE'))
        state = 2
        startBtn:setPosition(cc.p(180, 48))
        self.autoStartBtn:setVisible(true)
        self.autoStartBtn:setPosition(cc.p(416, 48))
    end

    startBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 判断时间到了没
            local nowTime = GlobalData:getServerTime()
            if nowTime >= self.serverData.data.time then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_TRIAL_DESC39'), COLOR_TYPE.RED)
                return
            end

            if state == 1 then  -- 领取
                local function callBack(data)
                    local awards = data.awards
				    if awards then
					    GlobalApi:parseAwardData(awards)
					    GlobalApi:showAwardsCommon(awards,nil,nil,true)
				    end
				    local costs = data.costs
				    if costs then
					    GlobalApi:parseAwardData(costs)
				    end

                    -- 刷新数据
                    self.serverData.data.award_got = 1
                    self:refreshStartBtnState()
                    LegionTrialMgr:refreshLegionTrialAdventure(self.serverData)

                    self.parent.adventures[self.pos] = self.serverData
                    self.parent:refreshMark()

                    -- 达成成就
                    LegionTrialMgr:refreshLegionTrialAchievement(data.achievement)

                end
                LegionTrialMgr:legionTrialGetMonsterAwardFromServer(self.serverData.index,callBack)
            else
                local function callBack(data)
                    local customObj = {}
                    customObj.trial_robot = data.trial_robot
                    customObj.index = self.serverData.index
                    LegionMgr:showLegionActivitySelRoleListNewLegionTrialUI(BATTLE_TYPE.NEW_LEGION_TRIAL,customObj)
                end
                LegionTrialMgr:legionTrialStartChallengeMonsterFromServer(self.serverData.index,callBack)
            end

        end
    end)

end

return LegionTrialAdventureSubGuaiRenPannelUI