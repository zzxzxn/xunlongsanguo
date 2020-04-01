local InlayDragonGemUI = class("InlayDragonGemUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local DRAGON_FRAGMENT_ID = 300004
local DRAGON_GEM_NUM_EVERY_ROW = 3
local DRAGON_GEM_WIDTH = 94
local DRAGON_GEM_INTERVAL_R = 10
local DRAGON_GEM_INTERVAL_C = 16

function InlayDragonGemUI:ctor(dragonId)
	self.uiIndex = GAME_UI.UI_INLAY_DRAGON_GEM
    self.currDragonId = dragonId
    self.dragonSpines = {}
    self.currDragonSpine = nil
    self.maxDragon = 0
    self.maxDragongem = 0
    self.dragonGemTotalHeight = 0
    self.selectIndex = 0
    self.rightDragonGems = {}
    self.dirty = false
    self.currGemAdditions = {0,0,0,0}
end

function InlayDragonGemUI:init()
    self.root:registerScriptHandler(function (event)
        if event == "exit" then
            MainSceneMgr.uiClass["inlayDragonGemUI"] = nil
        end
    end)
    
    local winSize = cc.Director:getInstance():getVisibleSize()
    local bg_img = self.root:getChildByName("bg_img")
    local bg_alpha_img = bg_img:getChildByName("bg_alpha_img")
    self:adaptUI(bg_img, bg_alpha_img)

    local inlay_bg = bg_alpha_img:getChildByName("inlay_bg")
    local close_btn = inlay_bg:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideInlayDragonGemUI()
        end
    end)

    local title_bg = inlay_bg:getChildByName("title_bg")
    local title_tx = title_bg:getChildByName("title_tx")
    title_tx:setString(GlobalApi:getLocalStr("TITLE_INLAY_DRAGON_GEM"))

    local bag_btn = inlay_bg:getChildByName("bag_btn")
    local bag_tx = bag_btn:getChildByName("func_tx")
    bag_tx:setString(GlobalApi:getLocalStr("DRAGON_GEM_BAG"))
    bag_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.bag_img:isVisible() then
                self:closeDragonBag()
            else
                self:openDragonBagAndCompare()
            end
        end
    end)

    local convert_btn = inlay_bg:getChildByName("convert_btn")
    local convert_tx = convert_btn:getChildByName("func_tx")
    convert_tx:setString(GlobalApi:getLocalStr("EXCHANGE_DRAGON_GEM"))
    convert_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.dirty = true
            MainSceneMgr:showTreasureMerge(1)
        end
    end)

    local dig_btn = inlay_bg:getChildByName("dig_btn")
    local dig_tx = dig_btn:getChildByName("text")
    dig_tx:setLocalZOrder(2)
    dig_tx:setString(GlobalApi:getLocalStr("TREASURE_DESC_15"))

    local digeffect = GlobalApi:createLittleLossyAniByName("scene_tx_wakuang")
    local digSize = dig_btn:getContentSize()
    digeffect:setScaleX(-1)
    digeffect:setPosition(cc.p(digSize.width/2 + 20,digSize.height/2 - 15))
    digeffect:getAnimation():play("Animation2", -1, 1)
    dig_btn:addChild(digeffect)

    dig_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.dirty = true
            GlobalApi:getGotoByModule("digging")
        end
    end)

    self.addImgs = {}
    self.quanImgs = {}
    self.addTxs = {}
    local right_bg = inlay_bg:getChildByName("right_bg")
    self.select_img = right_bg:getChildByName("select_img")
    self.select_img:ignoreContentAdaptWithSize(true)
    self.select_img:setVisible(false)
    for i=1,5 do
        self.addImgs[i] = right_bg:getChildByName("add_" .. i)
        self.addImgs[i]:setLocalZOrder(3)
        self.addImgs[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1.5),cc.FadeOut:create(1.5),cc.DelayTime:create(0.5))))
        self.quanImgs[i] = right_bg:getChildByName("quan_" .. i)
        self.quanImgs[i]:setLocalZOrder(2)
        self.quanImgs[i]:ignoreContentAdaptWithSize(true)
        self.quanImgs[i]:setTouchEnabled(true)
        self.quanImgs[i]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.selectIndex ~= i then
                    self.selectIndex = i
                    self.select_img:setVisible(true)
                    if self.addImgs[i]:isVisible() then
                        self.select_img:loadTexture("uires/ui/treasure/treasure_select_bg_2.png")
                    -- else
                    --     self.select_img:loadTexture("uires/ui/treasure/treasure_select_bg_1.png")
                    end
                    self.select_img:setPosition(cc.p(self.quanImgs[i]:getPosition()))
                    self:openDragonBagAndCompare()
                end
            end
        end)
        self.addTxs[i] = right_bg:getChildByName("text_" .. i)
        self.addTxs[i]:setLocalZOrder(4)
    end

    local info_1 = right_bg:getChildByName("info_1")
    info_1:setString(GlobalApi:getLocalStr("STR_EVOLUTION_CONDITION"))

    local info_2 = right_bg:getChildByName("info_2")
    info_2:setString(GlobalApi:getLocalStr("ALL_LEGION_ATTR_ADDITION"))

    local info_3 = right_bg:getChildByName("info_3")
    info_3:setString(GlobalApi:getLocalStr("DRAGON_GEM_TOTAL_LEVEL"))

    local info_4 = right_bg:getChildByName("info_4")
    info_4:setString(GlobalApi:getLocalStr("LEGION_TRIAL_DESC22"))

    local attributeConf = GameData:getConfData("attribute")
    local info_5 = right_bg:getChildByName("info_5")
    info_5:setString(attributeConf[1].name)
    local info_6 = right_bg:getChildByName("info_6")
    info_6:setString(attributeConf[2].name)
    local info_7 = right_bg:getChildByName("info_7")
    info_7:setString(attributeConf[3].name)
    local info_8 = right_bg:getChildByName("info_8")
    info_8:setString(attributeConf[4].name)

    local helpbtn = right_bg:getChildByName("help_btn")
    helpbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(13)
        end
    end)

    self.attrTxs = {}
    for i = 1, 4 do
        self.attrTxs[i] = right_bg:getChildByName("attr_tx_" .. i)
    end

    self.gemMountAni = GlobalApi:createLittleLossyAniByName("ui_dragongem_mount")
    self.gemMountAni:getAnimation():setMovementEventCallFunc(function (armature, movementType, movementID)
        if movementType == 1 then
            self.gemMountAni:setVisible(false)
        end
    end)
    self.gemMountAni:setScale(1.4)
    self.gemMountAni:setVisible(false)
    right_bg:addChild(self.gemMountAni)

    self.upgrade_btn = right_bg:getChildByName("upgrade_btn")
    self.upgradeAni = GlobalApi:createLittleLossyAniByName("ui_xuanzhuan_01")
    self.upgradeAni:getAnimation():playWithIndex(0, -1, 1)
    self.upgradeAni:setPosition(cc.p(self.upgrade_btn:getPosition()))
    right_bg:addChild(self.upgradeAni)
    self.upgrade_btn:addClickEventListener(function ()
        local dragon = RoleData:getDragonById(self.currDragonId)
        local dragonLevel = GameData:getConfData("dragonlevel")[dragon:getLevel()]
        local cost = DisplayData:getDisplayObj(dragonLevel.cost[1])
        local currGold = UserData:getUserObj():getGold()
        if dragon:getDragonGemTotalLevel() < dragonLevel.require then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("DRAGON_GEM_LEVEL_NOT_ENOUGH"), COLOR_TYPE.RED)
        else
            if currGold < cost:getNum() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("STR_GOLD_NOTENOUGH"), COLOR_TYPE.RED)
            else
                local args = {
                    id = self.currDragonId
                }
                MessageMgr:sendPost("upgrade_dragon", "treasure", json.encode(args), function (response)
                    if response.code == 0 then
                        RoleMgr:showStengthenPopupUI(nil, "upgrade_dragon", {0,0,0,0}, {0,0,0,0}, function()
                            if response.data.costs then
                                GlobalApi:parseAwardData(response.data.costs)
                            end
                            local skills = UserData:getUserObj():getSkills()
                            for k,v in pairs(skills) do
                                if tonumber(v.id) == self.currDragonId then
                                    skills[k].level = skills[k].level + 1
                                end
                            end
                            UserData:getUserObj():setSkills(skills)
                            dragon:upgrade()
                            local dragonLevel = dragon:getLevel()
                            if self.currDragonSpine then
                                GlobalApi:changeModelEquip(self.currDragonSpine, dragon:getUrl(), dragon:getChangeEquipState(), 2)
                                local effect = self.currDragonSpine:getChildByName("dragon_effect")
                                if effect then
                                    effect:removeFromParent()
                                end
                                local playerSkillConf = GameData:getConfData("playerskill")
                                local url = playerSkillConf[self.currDragonId]["upgrade" .. dragonLevel]
                                if url then
                                    effect = GlobalApi:createLittleLossyAniByName(url)
                                    effect:setPosition(cc.p(playerSkillConf[self.currDragonId]["posx" .. dragonLevel], playerSkillConf[self.currDragonId]["posy" .. dragonLevel]))
                                    effect:setLocalZOrder(10000)
                                    effect:getAnimation():playWithIndex(0, -1, 1)
                                    effect:setName("dragon_effect")
                                    self.currDragonSpine:addChild(effect)
                                end
                            end
                            self:playUpgradeEffect(dragonLevel)
                            self:closeDragonBag()
                            self:update()
                            MainSceneMgr:maekSpineDirty()
                        end, dragon)
                    end
                end)
            end
        end
    end)

    self.upgrade_tx = right_bg:getChildByName("upgrade_tx")

    self.right_bg = right_bg

    local treasureInfo = UserData:getUserObj():getTreasure()
    local dragonInfo = RoleData:getDragonMap()
    for k,v in pairs(dragonInfo) do
        local level = v:getLevel()
        if level > 0 then
            self.maxDragon = self.maxDragon + 1
        end
    end

    local left_btn = bg_img:getChildByName("left_btn")
    local right_btn = bg_img:getChildByName("right_btn")
    left_btn:setPosition(cc.p(20, winSize.height/2))
    right_btn:setPosition(cc.p(winSize.width - 20, winSize.height/2))
    left_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.currDragonId = (self.currDragonId - 2)%self.maxDragon + 1
            self:closeDragonBag()
            self:update()
            MainSceneMgr:setCurrPos(self.currDragonId)
        end
    end)
    right_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.currDragonId = self.currDragonId%self.maxDragon + 1
            self:closeDragonBag()
            self:update()
            MainSceneMgr:setCurrPos(self.currDragonId)
        end
    end)
    if self.maxDragon <= 2 then
        left_btn:setTouchEnabled(false)
        right_btn:setTouchEnabled(false)
        left_btn:setBright(false)
        right_btn:setBright(false)
    end

    self.left_bg = inlay_bg:getChildByName("left_bg")
    self.name_img = self.left_bg:getChildByName("name_img")
    self.name_img:ignoreContentAdaptWithSize(true)

    local look_btn = self.left_bg:getChildByName("look_btn")
    look_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showDragonInfoUI(self.currDragonId)
        end
    end)

    self.stars = {}
    for i = 1, 5 do
        self.stars[i] = self.left_bg:getChildByName("star_bg_" .. i)
    end

    local down_bg = inlay_bg:getChildByName("down_bg")
    self.next_lv_tx = down_bg:getChildByName("next_lv_tx")

    self.richText = xx.RichText:create()
    self.richText:setScale(20/18)
    self.richText:setContentSize(cc.size(386, 54))
    self.richText:setPosition(cc.p(16, 66))
    self.richText:setAnchorPoint(cc.p(0,1))
    down_bg:addChild(self.richText)

    self.bag_img = inlay_bg:getChildByName("bag_img")
    self.bag_img:setVisible(false)
    self:initDragonBag()
    self:update()
end

function InlayDragonGemUI:initDragonBag()
    local bag_title = self.bag_img:getChildByName("bag_title")
    bag_title:setString(GlobalApi:getLocalStr("DRAGON_GEM_BAG_1"))

    local bag_close = self.bag_img:getChildByName("bag_close")
    bag_close:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:closeDragonBag()
        end
    end)

    self.bag_sv = self.bag_img:getChildByName("bag_sv")
    self.bagSize = self.bag_sv:getContentSize()
    self.bag_sv:setScrollBarEnabled(false)
    self.bag_no_gem = self.bag_img:getChildByName("bag_no_gem")
end

function InlayDragonGemUI:closeDragonBag()
    self.selectIndex = 0
    self.bag_img:setVisible(false)
    self.select_img:setVisible(false)
end

function InlayDragonGemUI:openDragonBagAndCompare()
    self.bag_img:setVisible(true)
    if #self.dragongemArr > 0 then
        if self.selectIndex > 0 then
            local selectDragonGem = self.rightDragonGems[self.selectIndex]
            local selectLv = 0
            if selectDragonGem then
                selectLv = selectDragonGem:getLevel()
            end
            for k, obj in ipairs(self.dragongemArr) do
                local dragongem_bg = self.bag_sv:getChildByName("dragongem_bg_" .. k)
                local new_img = dragongem_bg:getChildByName("up_img")
                if obj:getId() == DRAGON_FRAGMENT_ID then
                    new_img:setVisible(false)
                else
                    if selectLv < obj:getLevel() then
                        new_img:setVisible(true)
                    else
                        new_img:setVisible(false)
                    end
                end
            end
        else
            for k, obj in ipairs(self.dragongemArr) do
                local dragongem_bg = self.bag_sv:getChildByName("dragongem_bg_" .. k)
                local new_img = dragongem_bg:getChildByName("up_img")
                new_img:setVisible(false)
            end
        end
    end
end

function InlayDragonGemUI:onShow()
    if self.dirty then
        self.dirty = false
        self:update()
    end
end

function InlayDragonGemUI:update()
    local dragonObj = RoleData:getDragonById(self.currDragonId)
    self:updateLeft(dragonObj)
    self:updateRight(dragonObj)
    self:updateDown(dragonObj)
    self:updateDragonGemBag()
end

function InlayDragonGemUI:updateDown(dragonObj)
    local dragonLevel = dragonObj:getLevel()
    local playerSkillConf = GameData:getConfData("playerskill")
    local num
    local descStr
    local skillConf = GameData:getConfData("skill")
    local skillId = playerSkillConf[self.currDragonId].skillId
    local data1 = skillConf[skillId + (dragonLevel + 1)*2]
    if data1 == nil then
        data1 = skillConf[skillId + dragonLevel*2]
        self.next_lv_tx:setString(GlobalApi:getLocalStr("SKILL_EFFECT_DESC_2"))
    else
        self.next_lv_tx:setString(GlobalApi:getLocalStr("SKILL_EFFECT_DESC_1"))
    end
    descStr, num = self:getSkillDesc(data1)
    local strTab = string.split(tostring(descStr), "%s")
    if #strTab > 1 then
        descStr = strTab[1] .. num .. strTab[2]
    else
        descStr = strTab[1]
    end
    self.richText:clear()
    xx.Utils:Get():analyzeHTMLTag(self.richText, descStr)
end

function InlayDragonGemUI:updateDragonGemBag()
    self.dragongemArr = {}
    local dragongems = BagData:getAllDragongems()
    for k, v in ipairs(dragongems) do
        for k2, v2 in pairs(v) do
            table.insert(self.dragongemArr, v2)
        end
    end
    table.sort(self.dragongemArr, function (a, b)
        if a:getQuality() == b:getQuality() then
            if a:getId() == b:getId() then
                return a:getAttNum() > b:getAttNum()
            else
                return a:getId() < b:getId()
            end
        else
            return a:getQuality() > b:getQuality()
        end
    end)
    local fragmentObj = BagData:getMaterialById(DRAGON_FRAGMENT_ID)
    if fragmentObj:getNum() > 0 then
        table.insert(self.dragongemArr, 1, fragmentObj)
    end
    local maxDragongem = #self.dragongemArr
    if maxDragongem > 0 then
        local maxRow = math.floor((maxDragongem - 1)/DRAGON_GEM_NUM_EVERY_ROW) + 1
        self.dragonGemTotalHeight = maxRow * (DRAGON_GEM_WIDTH + DRAGON_GEM_INTERVAL_R)
        if self.dragonGemTotalHeight > self.bagSize.height then
            self.bag_sv:setInnerContainerSize(cc.size(self.bagSize.width, self.dragonGemTotalHeight))
        else
            self.dragonGemTotalHeight = self.bagSize.height
            self.bag_sv:setInnerContainerSize(self.bagSize)
        end
    else
        self.dragonGemTotalHeight = self.bagSize.height
    end
    local selectLv
    if self.selectIndex > 0 then
        if self.rightDragonGems[self.selectIndex] then
            selectLv = self.rightDragonGems[self.selectIndex]:getLevel()
        else
            selectLv = 0
        end
    end
    for i, v in ipairs(self.dragongemArr) do
        local awardBgImg = self.bag_sv:getChildByName("dragongem_bg_" .. i)
        local awardImg,lvTx,godLight,newImg
        if awardBgImg then
            awardBgImg:setVisible(true)
            lvTx = awardBgImg:getChildByName("lv_tx")
            newImg = awardBgImg:getChildByName("up_img")
        else
            local equipTab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            awardBgImg = equipTab.awardBgImg
            awardBgImg:setName("dragongem_bg_" .. i)
            equipTab.awardImg:ignoreContentAdaptWithSize(true)
            lvTx = equipTab.lvTx
            lvTx:setVisible(true)
            lvTx:setPositionX(lvTx:getPositionX()-30)
            newImg = equipTab.upImg
            self.bag_sv:addChild(awardBgImg)
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local position = awardBgImg:getParent():convertToWorldSpace(cc.p(awardBgImg:getPosition()))
                    local inlayDragonGem = self.dragongemArr[i]
                    if inlayDragonGem:getId() == DRAGON_FRAGMENT_ID then
                        TipsMgr:showDragonGemFragmentTips(position, inlayDragonGem, function ()
                            local allUseNum = math.floor(inlayDragonGem:getNum()/inlayDragonGem:getMergeNum())*inlayDragonGem:getMergeNum()
                            if allUseNum > inlayDragonGem:getMergeNum()*99 then
                                allUseNum = inlayDragonGem:getMergeNum()*99
                            end
                            local args = {
                                type = "dragon",
                                id = inlayDragonGem:getId(),
                                num = allUseNum
                            }
                            MessageMgr:sendPost("use", "bag", json.encode(args),function (response)
                                local code = response.code
                                local data = response.data
                                if code == 0 then
                                    local awards = data.awards
                                    if awards then
                                        GlobalApi:parseAwardData(awards)
                                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
                                    end
                                    if data.costs then
                                        GlobalApi:parseAwardData(data.costs)
                                    end
                                    TipsMgr:hideDragonGemFragmentTips()
                                    self:updateDragonGemBag()
                                end
                            end)
                        end)
                    else
                        TipsMgr:showDragonGemTips(position, inlayDragonGem, function ()
                            if self.selectIndex > 0 then
                                local selectDragonGem = self.rightDragonGems[self.selectIndex]
                                if selectDragonGem and selectDragonGem:getLevel() > inlayDragonGem:getLevel() then
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr("EXCHANGE_DRAGON_GEM_ERROR"), COLOR_TYPE.RED)
                                    return
                                end
                                self.gemMountAni:setVisible(true)
                                local oldfight = RoleData:getFightForce()
                                local obj = RoleData:getRoleByPos(1)
                                local oldatt = RoleData:getPosAttByPos(obj)
                                self.gemMountAni:getAnimation():playWithIndex(0, -1, 0)
                                self.gemMountAni:setPosition(cc.p(self.quanImgs[self.selectIndex]:getPosition()))
                                local args = {
                                    id = self.currDragonId,
                                    slot = self.selectIndex,
                                    gid = inlayDragonGem:getSId()
                                }
                                MessageMgr:sendPost("exchange_gem", "treasure", json.encode(args),function (response)
                                    local code = response.code
                                    if code == 0 then
                                        RoleData:setAllFightForceDirty()
                                        local dragon = RoleData:getDragonById(self.currDragonId)
                                        if dragon then
                                            dragon:mountDragonGem(self.selectIndex, inlayDragonGem)
                                            self:update()
                                        end
                                        TipsMgr:hideDragonGemTips()
                                        for j= 1, 7 do
                                            local obj = RoleData:getRoleByPos(j)
                                            if obj and obj:getId() > 0 then
                                                RoleMgr:popupTips(obj, true)
                                            end
                                        end
                                        local newfightforce = RoleData:getFightForce()
                                        local newatt = RoleData:getPosAttByPos(obj)
                                        GlobalApi:popupTips(oldatt, newatt, oldfight, newfightforce)
                                    end
                                end)
                            else
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("SELECT_BEFORE_INLAY"), COLOR_TYPE.RED)
                            end
                        end)
                    end
                end
            end)
        end
        local row = math.floor((i-1)/DRAGON_GEM_NUM_EVERY_ROW) + 1
        local col = (i - 1)%DRAGON_GEM_NUM_EVERY_ROW + 1
        local posx = col * (DRAGON_GEM_WIDTH + DRAGON_GEM_INTERVAL_C) - DRAGON_GEM_WIDTH/2
        local posy = self.dragonGemTotalHeight - (row * (DRAGON_GEM_WIDTH + DRAGON_GEM_INTERVAL_R) - DRAGON_GEM_WIDTH/2 - DRAGON_GEM_INTERVAL_R/2)
        
        ClassItemCell:updateItem(awardBgImg, v, 2)
        awardBgImg:setPosition(cc.p(posx, posy))
        if v:getId() == DRAGON_FRAGMENT_ID then
            lvTx:setString(v:getNum())
            newImg:setVisible(false)
        else
            lvTx:setString(v:getAttNum() .. "%")
            if selectLv and selectLv < v:getLevel() then
                newImg:setVisible(true)
            else
                newImg:setVisible(false)
            end
        end
    end

    if maxDragongem < self.maxDragongem then
        for i = maxDragongem + 1, self.maxDragongem do
            local awardBgImg = self.bag_sv:getChildByName("dragongem_bg_" .. i)
            if awardBgImg then
                awardBgImg:setVisible(false)
            end
        end
    end

    if maxDragongem <= 0 then
        self.bag_no_gem:setVisible(true)
    else
        self.bag_no_gem:setVisible(false)
    end
    self.maxDragongem = maxDragongem
end

function InlayDragonGemUI:updateLeft(dragonObj)
    local treasureConf = GameData:getConfData("treasure")
    local playerSkillConf = GameData:getConfData("playerskill")
    local treasureInfo = UserData:getUserObj():getTreasure()
    local level = 1

    if self.currDragonSpine then
        self.currDragonSpine:setVisible(false)
    end
    local dragonLevel = dragonObj:getLevel()
    if self.dragonSpines[self.currDragonId] then
        self.dragonSpines[self.currDragonId]:setVisible(true)
    else
        local dragonSpine = GlobalApi:createLittleLossyAniByName(treasureConf[self.currDragonId][level].url, nil, dragonObj:getChangeEquipState())
        local url = playerSkillConf[self.currDragonId]["upgrade" .. dragonLevel]
        if url then
            local effect = GlobalApi:createLittleLossyAniByName(url)
            effect:setPosition(cc.p(playerSkillConf[self.currDragonId]["posx" .. dragonLevel], playerSkillConf[self.currDragonId]["posy" .. dragonLevel]))
            effect:setLocalZOrder(10000)
            effect:getAnimation():playWithIndex(0, -1, 1)
            effect:setName('dragon_effect')
            dragonSpine:addChild(effect)
        end
        dragonSpine:getAnimation():play("idle", -1, 1)
        dragonSpine:setPosition(cc.p(180, 60))
        self.left_bg:addChild(dragonSpine)
        self.dragonSpines[self.currDragonId] = dragonSpine
    end
    self.currDragonSpine = self.dragonSpines[self.currDragonId]

    self.name_img:loadTexture("uires/ui/treasure/treasure_skill_name_" .. self.currDragonId .. ".png")

    for i = 1, 5 do
        if i <= dragonLevel then
            self.stars[i]:setVisible(true)
        else
            self.stars[i]:setVisible(false)
        end
    end
end

function InlayDragonGemUI:updateRight(dragonObj)
    for i = 1, 4 do
        self.currGemAdditions[i] = 0
    end
    for i = 1,5 do
        local dragonGem = dragonObj:getDragonGemBySlot(i)
        self.addImgs[i]:stopAllActions()
        if dragonGem then
            self.rightDragonGems[i] = dragonGem
            self.addImgs[i]:setVisible(false)
            self.quanImgs[i]:setScale(0.7)
            self.quanImgs[i]:loadTexture(dragonGem:getIcon())
            self.addTxs[i]:setVisible(true)
            self.addTxs[i]:setString(dragonGem:getAttName() .. "+" .. dragonGem:getAttNum() .. "%")
            self.currGemAdditions[dragonGem:getAttId()] = self.currGemAdditions[dragonGem:getAttId()] + dragonGem:getAttNum()
        else
            self.rightDragonGems[i] = nil
            self.addImgs[i]:setOpacity(255)
            self.addImgs[i]:setVisible(true)
            self.addImgs[i]:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeIn:create(1.5),cc.FadeOut:create(1.5),cc.DelayTime:create(0.5))))
            self.quanImgs[i]:setScale(1)
            self.quanImgs[i]:loadTexture("uires/ui/treasure/treasure_inlay_quan.png")
            self.addTxs[i]:setVisible(false)
        end
    end
    local dragonLevelConf = GameData:getConfData("dragonlevel")[dragonObj:getLevel()]
    local total_lv_tx = self.right_bg:getChildByName("total_lv_tx")
    local cost_tx = self.right_bg:getChildByName("cost_tx")
    local glod_img = self.right_bg:getChildByName("glod_img")
    local info_4 = self.right_bg:getChildByName("info_4")
    if dragonLevelConf.require > 0 then
        total_lv_tx:setString(dragonObj:getDragonGemTotalLevel() .. "/" .. dragonLevelConf.require)
        local cost = DisplayData:getDisplayObj(dragonLevelConf.cost[1])
        cost_tx:setVisible(true)
        cost_tx:setString(GlobalApi:toWordsNumber(cost:getNum()))
        glod_img:setVisible(true)
        glod_img:setPositionX(cost_tx:getPositionX() + cost_tx:getContentSize().width + 20)
        info_4:setPosition(cc.p(332, 252))
        info_4:setString(GlobalApi:getLocalStr("LEGION_TRIAL_DESC22"))
        self.upgrade_tx:setString(GlobalApi:getLocalStr("STR_EVOLVE"))
        if dragonObj:getDragonGemTotalLevel() >= dragonLevelConf.require then
            self.upgrade_btn:setBright(true)
            self.upgrade_btn:setTouchEnabled(true)
            self.upgradeAni:setVisible(true)
        else
            self.upgrade_btn:setBright(false)
            self.upgrade_btn:setTouchEnabled(false)
            self.upgradeAni:setVisible(false)
        end
    else
        total_lv_tx:setString(dragonObj:getDragonGemTotalLevel())
        glod_img:setVisible(false)
        cost_tx:setVisible(false)
        info_4:setPosition(cc.p(402, 252))
        info_4:setString(GlobalApi:getLocalStr("MAX_LV"))
        self.upgrade_tx:setString(GlobalApi:getLocalStr("STR_MAX_LEVEL"))
        self.upgrade_btn:setBright(false)
        self.upgrade_btn:setTouchEnabled(false)
        self.upgradeAni:setVisible(false)
    end

    local totalAttr = {0,0,0,0}
    local dragons = RoleData:getDragonMap()
    for k, dragon in pairs(dragons) do
        local attr = dragon:getAttr()
        for i = 1, 4 do
            if attr[i] then
                totalAttr[i] = totalAttr[i] + attr[i]
            end
        end
    end
    
    for i = 1, 4 do
        self.attrTxs[i]:setString("+" .. math.floor(totalAttr[i]*self.currGemAdditions[i]/100))
    end

    if self.selectIndex > 0 then
        if self.addImgs[self.selectIndex]:isVisible() then
            self.select_img:loadTexture("uires/ui/treasure/treasure_select_bg_2.png")
        -- else
        --     self.select_img:loadTexture("uires/ui/treasure/treasure_select_bg_1.png")
        end
    end
end

function InlayDragonGemUI:getSkillDesc(conf)
    local lv = UserData:getUserObj():getLv()
    local str = ''
    local num = nil
    if conf.coefficient == 0 and conf.buffId == 0 then
        str = conf.skillDesc[1]
    elseif conf.coefficient ~= 0 then
        num = math.floor(conf.coefficient*(lv*26 + 856)/100 + conf.fixedDamage)
        local str1 = conf.skillDesc[1]
        local arr = string.split(tostring(str1),'@')
        if #arr > 1 then
            str = arr[1]..'%'..arr[2]
        else
            str = arr[1]
        end
    elseif conf.buffId ~= 0 then
        local buffConf = GameData:getConfData("buff")
        local tab = buffConf[conf.buffId]
        num = math.floor(tab.coefficient*(lv*26 + 856)/100 + tab.fixedDamage)
        local str1 = conf.skillDesc[1]
        local arr = string.split(tostring(str1),'@')
        if #arr > 1 then
            str = arr[1]..'%'..arr[2]
        else
            str = arr[1]
        end
    end
    return str,num
end

function InlayDragonGemUI:playUpgradeEffect(dragonLevel)
    local lvMark = GlobalApi:createLittleLossyAniByName('ui_treasure_lvmark')
    lvMark:setPosition(self.stars[dragonLevel]:getPosition())
    self.stars[dragonLevel]:getParent():addChild(lvMark)
    local function movementFun(armature, movementType, movementID)
        if movementType == 1 then
            lvMark:removeFromParent()
        end
    end
    lvMark:getAnimation():setMovementEventCallFunc(movementFun)
    lvMark:getAnimation():playWithIndex(0, -1, -1)
end
    
return InlayDragonGemUI