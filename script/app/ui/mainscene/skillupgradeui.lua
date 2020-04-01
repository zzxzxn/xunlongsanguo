local SkillUpgradeUI = class("SkillUpgradeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function SkillUpgradeUI:ctor(pos,reset)
	self.uiIndex = GAME_UI.UI_SKILL_UPGRADE
    self.reset = reset
    self.currPos = pos
    local skills = UserData:getUserObj():getSkills()
    self.id = skills[tostring(self.currPos)].id
    self.addProb = 0
    -- self.maxUpgradeLv = MainSceneMgr:getSkillSlotUpgradeLimitLv()
    self.awardsRTs = {}
end

function SkillUpgradeUI:updateTopPanel()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local conf = GameData:getConfData("playerskill")
    local slotConf = GameData:getConfData("playerskillslot")
    local skills = UserData:getUserObj():getSkills()
    self.slotOpend = {}
    if not self.selected then
        self.selected = GlobalApi:createLittleLossyAniByName('ui_treasure_selected')
        self.selected:getAnimation():playWithIndex(0, -1, 1)
        self.selected:setScale(0.8)
        self.topImg:addChild(self.selected)
    end
    for i=1,5 do
        local treasureImg = self.topImg:getChildByName('treasure_'..i..'_img')
        local skillImg = treasureImg:getChildByName('skill_img')
        local levelImg = treasureImg:getChildByName('level_img')
        local lvTx = levelImg:getChildByName('lv_tx')
        local openTx = treasureImg:getChildByName('open_tx')
        local levelTx = treasureImg:getChildByName('level_tx')
        local openLevel = tonumber(slotConf[i].open)
        local level = UserData:getUserObj():getLv()
        treasureImg:setLocalZOrder(1)
        if level >= openLevel then
            openTx:setString('')
            levelTx:setString('')
            levelImg:setVisible(true)
            self.slotOpend[i] = true
        else
            openTx:setString(GlobalApi:getLocalStr('STR_POSCANTOPEN_1'))
            levelTx:setString(openLevel)
            levelImg:setVisible(false)
            self.slotOpend[i] = false
        end

        if skills[tostring(i)] then
            lvTx:setString(skills[tostring(i)].level)
            -- print(tonumber(skills[tostring(i)].id))
            if tonumber(skills[tostring(i)].id) > 0 then
                skillImg:loadTexture('uires/ui/treasure/treasure_'..conf[skills[tostring(i)].id].icon)
            else
                skillImg:loadTexture('uires/ui/common/bg1_alpha.png')
            end
        else
            skillImg:loadTexture('uires/ui/common/bg1_alpha.png')
            lvTx:setString(0)
        end
        -- local width = size.width + (winSize.width - size.width)/3*(((i%2==1) and 1) or 2)
        -- local height = (7 - i)/8*winSize.height
        -- treasureImg:setPosition(treasureImg:getPosition())
        treasureImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.currPos = i
                self.addProb = 0
                -- self.selected:setPosition(cc.p(width,height))
                self.id = skills[tostring(i)].id
                self:updatePanel()
            end
        end)
        if i == self.currPos then
            self.selected:setPosition(treasureImg:getPosition())
        end
    end
end

function SkillUpgradeUI:playUpgradeEffect()
    local skills = UserData:getUserObj():getSkills()
    local level = tonumber(skills[tostring(self.currPos)].level)
    local size1 = self.leftImg:getContentSize()
    local lvUp = GlobalApi:createLittleLossyAniByName('ui_treasure_lvup')
    lvUp:setPosition(cc.p(size1.width/2,115))
    lvUp:setAnchorPoint(cc.p(0.5,0))
    lvUp:setScale(1.4)
    self.leftImg:addChild(lvUp)
    local function movementFun1(armature, movementType, movementID)
        if movementType == 1 then
            lvUp:removeFromParent()
        end
    end
    lvUp:getAnimation():setMovementEventCallFunc(movementFun1)
    lvUp:getAnimation():playWithIndex(0, -1, 0)
end

function SkillUpgradeUI:updateRightPanel()
    local skillSlotConf = GameData:getConfData('skillslot')
    local skillSlotRobConf = GameData:getConfData('skillslotprob')
    local skills = UserData:getUserObj():getSkills()
    local level = tonumber(skills[tostring(self.currPos)].level)
    local awards = DisplayData:getDisplayObjs(skillSlotConf[level].cost)
    for i=1,3 do
        local awardBgImg = self.rightImg:getChildByName('award_bg_'..i..'_img')
        if not awardBgImg then
            local tab = ClassItemCell:create()
            awardBgImg = tab.awardBgImg
            local size = awardBgImg:getContentSize()
            self.rightImg:addChild(awardBgImg)
            awardBgImg:setName('award_bg_'..i..'_img')
            awardBgImg:setAnchorPoint(cc.p(0.5,0.5))
            awardBgImg:setPosition(cc.p((i - 1)*120 + 95,315))
            -- tab.nameTx:setPosition(cc.p(size.width/2,-20))
        end
        if awards[i] then
            awardBgImg:setVisible(true)
            -- local nameTx = awardBgImg:getChildByName('name_tx')
            -- local lvTx = awardBgImg:getChildByName('lv_tx')
            local awardImg = awardBgImg:getChildByName('award_img')
            awardBgImg:loadTexture(awards[i]:getBgImg())
            awardImg:loadTexture(awards[i]:getIcon())
            local obj = BagData:getMaterialById(awards[i]:getId())
            local num = 0
            if obj then
                num = obj:getNum()
            end
            local color,color1
            if awards[i]:getNum() > num then
                color = COLOR_TYPE.RED
                color1 = COLOR_TYPE.WHITE
            else
                color = COLOR_TYPE.GREEN
                color1 = COLOR_TYPE.GREEN
            end
            local size = awardBgImg:getContentSize()

            if not self.awardsRTs[i] then
                local richText = xx.RichText:create()
                richText:setAlignment('middle')
                richText:setVerticalAlignment('middle')
                richText:setContentSize(cc.size(230, 30))
                local re1 = xx.RichTextLabel:create(GlobalApi:toWordsNumber(num),22,color)
                local re2 = xx.RichTextLabel:create('/'..awards[i]:getNum(),22,color1)
                re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                re2:setStroke(COLOR_TYPE.BLACK, 1)
                richText:addElement(re1)
                richText:addElement(re2)
                richText:setAnchorPoint(cc.p(0.5,0.5))
                richText:setPosition(cc.p(size.width/2,-20))
                awardBgImg:addChild(richText)
                self.awardsRTs[i] = {richText = richText,re2 = re2,re1 = re1}
            else
                self.awardsRTs[i].re1:setString(GlobalApi:toWordsNumber(num))
                self.awardsRTs[i].re2:setString('/'..awards[i]:getNum())
                self.awardsRTs[i].re1:setColor(color)
                self.awardsRTs[i].re2:setColor(color1)
                self.awardsRTs[i].richText:format(true)
            end

            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(awards[i],false)
                end
            end)
        else
            awardBgImg:setVisible(false)
        end
    end

    self.baseProb = skillSlotConf[level].baseProb
    -- self.maxAddProb = 100 - self.baseProb
    self.maxAddProb = 0
    for i,v in ipairs(skillSlotRobConf) do
        local cost = DisplayData:getDisplayObj(v.cost[1])
        local obj = BagData:getMaterialById(cost:getId())
        if obj and obj:getNum() >= cost:getNum() and self.maxAddProb < 100 - self.baseProb then
            self.maxAddProb = i
        end
    end

    local barBg = self.rightImg:getChildByName('bar_bg')
    local bar = barBg:getChildByName('bar')
    local perTx = bar:getChildByName('per_tx')
    perTx:setString(GlobalApi:getLocalStr('SKILL_UPGRADE_DESC_5')..(self.baseProb + self.addProb)..'%')
    bar:setPercent(self.baseProb + self.addProb)
    local lessBtn = barBg:getChildByName('less_btn')
    local addBtn = barBg:getChildByName('add_btn')
    if self.baseProb + self.addProb <= self.baseProb then
        lessBtn:setBright(false)
        lessBtn:setTouchEnabled(false)
    else
        lessBtn:setBright(true)
        lessBtn:setTouchEnabled(true)
    end
    if self.baseProb + self.addProb >= 100 or self.baseProb + self.addProb == 0 then
        addBtn:setBright(false)
        addBtn:setTouchEnabled(false)
    else
        addBtn:setBright(true)
        addBtn:setTouchEnabled(true)
    end

    local size = self.rightImg:getContentSize()
    local num = 0
    local award
    if self.addProb > 0 then
        award = DisplayData:getDisplayObj(skillSlotRobConf[self.addProb].cost[1])
        num = award:getNum()
    else
        award = DisplayData:getDisplayObj(skillSlotRobConf[1].cost[1])
    end
    local obj = BagData:getMaterialById(award:getId())
    local num1 = 0
    if obj then
        num1 = obj:getNum()
    end
    if not self.costRt then
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(400, 34))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
        -- xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_CONSUME'),24,COLOR_TYPE.WHITE)
        local re2 = xx.RichTextImage:create(award:getIcon())
        local re3 = xx.RichTextLabel:create(num..'('..GlobalApi:getLocalStr('REMAINDER')..num1..')',24,COLOR_TYPE.WHITE)
        re2:setScale(0.5)
        re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        --richText:formatText()
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:setPosition(cc.p(size.width/2,120))
        self.rightImg:addChild(richText)
        self.costRt = {richText = richText,re1 = re1,re3 = re3}
    else
        self.costRt.re3:setString(num..'('..GlobalApi:getLocalStr('REMAINDER')..num1..')')
        self.costRt.richText:format(true)
    end
    local descRt = self.rightImg:getChildByName('desc_rt')
    if not descRt then
        descRt = xx.RichText:create()
        descRt:setContentSize(cc.size(600, 34))
        descRt:setAlignment('middle')
        descRt:setVerticalAlignment('middle')
        -- xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKILL_UPGRADE_DESC_1'),20,COLOR_TYPE.ORANGE)
        local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKILL_UPGRADE_DESC_2'),20,COLOR_TYPE.GREEN)
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SKILL_UPGRADE_DESC_3'),20,COLOR_TYPE.ORANGE)
        re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
        re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        re1:setFont('font/gamefont.ttf')
        re2:setFont('font/gamefont.ttf')
        re3:setFont('font/gamefont.ttf')
        descRt:addElement(re1)
        descRt:addElement(re2)
        descRt:addElement(re3)
        --richText:formatText()
        descRt:setAnchorPoint(cc.p(0.5,0.5))
        descRt:setPosition(cc.p(size.width/2,-21.5))
        self.rightImg:addChild(descRt)
        descRt:setName('desc_rt')
    end

    -- local upgradeBtn = self.rightImg:getChildByName('upgrade_btn')
    -- local infoTx = upgradeBtn:getChildByName('info_tx')
    -- local skills = UserData:getUserObj():getSkills()
    -- local visible = false
    -- for i=1,5 do
    --     local id = tonumber(skills[tostring(i)].id)
    --     if self.id == id then
    --         visible = true
    --     end
    -- end
    -- upgradeBtn:setBright(visible)
    -- upgradeBtn:setTouchEnabled(visible)
    -- if visible then
    --     infoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1)
    -- else
    --     infoTx:enableOutline(COLOROUTLINE_TYPE.GRAY1)
    -- end
end

function SkillUpgradeUI:updateLeftPanel()
    local pl = self.leftImg:getChildByName('pl')
    pl:getChildByName('info_2_tx'):setString(GlobalApi:getLocalStr('SKILL_UPGRADE_DES2'))
    local skillImg = self.leftImg:getChildByName('skill_img')
    local conf = GameData:getConfData("playerskill")
    local slotConf = GameData:getConfData("playerskillslot")
    local skillConf = GameData:getConfData("skill")
    local buffConf = GameData:getConfData("buff")
    local skills = UserData:getUserObj():getSkills()
    local level = tonumber(skills[tostring(self.currPos)].level)

    local kuangImg = self.leftImg:getChildByName('kuang_img')
    local descTx1 = pl:getChildByName('desc_1_tx')
    local descTx2 = pl:getChildByName('desc_2_tx')
    local levelImg1 = pl:getChildByName('level_1_img')
    local lvTx1 = levelImg1:getChildByName('lv_tx')
    local levelImg2 = pl:getChildByName('level_2_img')
    local lvTx2 = levelImg2:getChildByName('lv_tx')
    local updateImg = self.leftImg:getChildByName('update_img')
    local descTx = updateImg:getChildByName('desc_tx')
    local arrowImg = pl:getChildByName('arrow_img')
    -- if self.slotOpend[self.currPos] == false then
    --     -- descTx:setString(GlobalApi:getLocalStr('SKILL_SLOT_CANNOT_UPGRADE'))
    --     skillImg:loadTexture('uires/ui/common/bg1_alpha.png')
    -- else
    local lv = UserData:getUserObj():getLv()
    local function getStr(conf)
        local str = ''
        if conf.coefficient == 0 and conf.buffId == 0 then
            str = conf.skillDesc[1]
        elseif conf.coefficient ~= 0 then
            local num = math.floor(conf.coefficient*(lv*26 + 620)/100 + conf.fixedDamage)
            local str1 = string.format(conf.skillDesc[1],tostring(num))
            local arr = string.split(tostring(str1),'=')
            if #arr > 1 then
                str = arr[1]..'%'..arr[2]
            else
                str = arr[1]
            end
        elseif conf.buffId ~= 0 then
            local tab = buffConf[conf.buffId]
            local num = math.floor(tab.coefficient*(lv*26 + 620)/100 + tab.fixedDamage)
            local str1 = string.format(conf.skillDesc[1],tostring(num))
            local arr = string.split(tostring(str1),'=')
            if #arr > 1 then
                str = arr[1]..'%'..arr[2]
            else
                str = arr[1]
            end
        end
        return str
    end
    if self.id and self.id > 0 then
        skillImg:loadTexture('uires/ui/treasure/treasure_'..conf[self.id].icon)
        local skillId = conf[self.id].skillId
        local data = skillConf[skillId + level]
        local data1 = skillConf[skillId + level + 1]
        if data1 then
            descTx2:setString(getStr(data1))
        end
        arrowImg:setVisible(true)
        descTx1:setString(getStr(data))
        descTx:setString(getStr(skillConf[skillId + 10]))
    else
        skillImg:loadTexture('uires/ui/common/bg1_alpha.png')
        descTx1:setString('')
        descTx2:setString('')
        arrowImg:setVisible(false)
        descTx:setString('')
    end
    lvTx1:setString(level)
    lvTx2:setString(((level + 1) > 10 and 10) or level + 1)
    if level >= 10 then
        updateImg:setVisible(true)
        pl:setVisible(false)
    else
        updateImg:setVisible(false)
        pl:setVisible(true)
    end
    -- end

    kuangImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- self.pl:setVisible(true)
            MainSceneMgr:showSkillSelect(function(id)
                self.id = id
                self:updatePanel()
            end,GlobalApi:getLocalStr('SELECT_SKILL'))
        end
    end)
end

function SkillUpgradeUI:onShow()
    -- self.maxUpgradeLv = MainSceneMgr:getSkillSlotUpgradeLimitLv()
    self:updatePanel()
end

function SkillUpgradeUI:updatePanel()
    self:updateTopPanel()
    self:updateRightPanel()
    self:updateLeftPanel()
end

function SkillUpgradeUI:init()
    local skillBgImg = self.root:getChildByName("skill_bg_img")
    local skillImg = skillBgImg:getChildByName("skill_img")
    local bgImg = self.root:getChildByName("bg_img")
    self:adaptUI(skillBgImg,skillImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    skillImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.topImg = skillImg:getChildByName('top_img')
    self.leftImg = skillImg:getChildByName('left_img')
    self.rightImg = skillImg:getChildByName('right_img')
    
    self.leftImg:getChildByName('info_1_tx'):setString(GlobalApi:getLocalStr('SKILL_UPGRADE_DES1'))
    self.rightImg:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('SKILL_UPGRADE_DES3'))

    self.help_btn = self.leftImg:getChildByName('help_btn')
    self.help_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GoldmineMgr:showDragonHelp()
        end
    end)

    local digBtn = self.rightImg:getChildByName('dig_btn')
    digBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('digging')
        end
    end)
    local exchangeBtn = self.rightImg:getChildByName('exchange_btn')
    exchangeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showExchangeEgg()
        end
    end)
    
    local closeBtn = skillImg:getChildByName('close_btn')
    -- closeBtn:setAnchorPoint(cc.p(1,1))
    -- closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideSkillUpgrade()
        end
    end)

    local barBg = self.rightImg:getChildByName('bar_bg')
    local bar = barBg:getChildByName('bar')
    local perTx = bar:getChildByName('per_tx')
    local lessBtn = barBg:getChildByName('less_btn')
    local addBtn = barBg:getChildByName('add_btn')
    addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.addProb = self.addProb + 1
            self:updateRightPanel()
        end
    end)
    lessBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.addProb = self.addProb - 1
            self:updateRightPanel()
        end
    end)

    local upgradeBtn = self.rightImg:getChildByName('upgrade_btn')
    local infoTx = upgradeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('SKILL_UPGRADE_DESC_4'))
    upgradeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local skills = UserData:getUserObj():getSkills()
            local level = tonumber(skills[tostring(self.currPos)].level)
            if self.slotOpend[self.currPos] == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('SKILL_SLOT_CANNOT_UPGRADE'), COLOR_TYPE.RED)
                return
            end
            -- if level > self.maxUpgradeLv then
            --     promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_SKILL_UPGRADE_M'), COLOR_TYPE.RED)
            --     return
            -- end
            if self.addProb > self.maxAddProb then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_ADD_PROB_M'), COLOR_TYPE.RED)
                return
            end
            if self.addProb + self.baseProb <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('MAX_LV'), COLOR_TYPE.RED)
                return
            end
            local function callback()
                local args = {slot = self.currPos,prob = self.addProb}
                MessageMgr:sendPost('skill_slot_upgrade','treasure',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        if skills[tostring(self.currPos)].level == data.skill then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('UPGRADE_FAIL'), COLOR_TYPE.RED)
                        else
                            skills[tostring(self.currPos)].level = level + 1
                            UserData:getUserObj():setSkills(skills)
                            self:playUpgradeEffect()
                        end
                        -- self.maxUpgradeLv = MainSceneMgr:getSkillSlotUpgradeLimitLv()
                        self:updatePanel()
                    end
                end)
            end
            if self.addProb + self.baseProb < 100 then
                promptmgr:showMessageBox(GlobalApi:getLocalStr('SKILL_SLOT_DESC_1'), MESSAGE_BOX_TYPE.MB_OK_CANCEL, callback)
            else
                callback()
            end
        end
    end)

    -- self:createCards()
    self:updatePanel()

    if self.reset and self.reset == true then
        GlobalApi:getGotoByModule('digging')
    end

end
    
return SkillUpgradeUI