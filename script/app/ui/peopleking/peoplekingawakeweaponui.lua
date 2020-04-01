local PeopleKingAwakeWeaponUI = class("PeopleKingAwakeWeaponUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local STYPE = {'atk','hp','def','mdef'}
local TITLE_DESC = {
    [1] = GlobalApi:getLocalStr('PEOPLE_KING_TITLE_DESC_1'),
    [2] = GlobalApi:getLocalStr('PEOPLE_KING_TITLE_DESC_2'),
}
local BUTTON_RES = {
    [1] = 'uires/ui/peopleking/peopleking_button_1.png',
    [2] = 'uires/ui/peopleking/peopleking_button_2.png', 
}
local M_IDS = {
    [1] = tonumber(GlobalApi:getGlobalValue('skyGasCostId')),
    [2] = tonumber(GlobalApi:getGlobalValue('skyBloodCostId')),
}
function PeopleKingAwakeWeaponUI:ctor(page)
    self.uiIndex = GAME_UI.UI_PEOLPLE_KING_AWAKE_WEAPON
    self.page = page or 1
    self.conf = {
        [1] = GameData:getConfData('skygasawaken'),
        [2] = GameData:getConfData('skybloodawaken'),
    }
    self.leftPage = 1
    self.rightPage = 1
    self.effectCount = 0
    self.data = UserData:getUserObj():getPeopleKing()
end

function PeopleKingAwakeWeaponUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bgImg = self.root:getChildByName("bg_img")
    local bgImg2 = bgImg:getChildByName("bg_img2")
    self:adaptUI(bgImg, bgImg2)

    local bgImg3 = bgImg2:getChildByName("bg_img3")

    local titleImg = bgImg3:getChildByName("title_img")
    local titleTx = titleImg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_TITLE_AWAKE_"..self.page))

    local closeBtn = bgImg3:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:hidePeopleKingAwakeWeaponUI()
        end
    end)

    self:setOldData()
    self.bgImg3 = bgImg3
    self:createRichTextDesc()
    self:updatePanel()
end

function PeopleKingAwakeWeaponUI:createRichTextDesc()
    local leftNode = self.bgImg3:getChildByName("left_node")
    local rightNode = self.bgImg3:getChildByName("right_node")
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(310, 54))
    richText:setPosition(cc.p(20, 292))
    richText:setAnchorPoint(cc.p(0,1))
    leftNode:addChild(richText)
    local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('PEOPLE_KING_DESC_2'),TITLE_DESC[self.page]), 20,cc.c3b(64,16,16))
    re1:setStroke(COLOROUTLINE_TYPE.GREEN, 0)
    re1:clearShadow()
    richText:addElement(re1)
    local richText1 = xx.RichText:create()
    richText1:setContentSize(cc.size(310, 54))
    richText1:setPosition(cc.p(20, 267))
    richText1:setAnchorPoint(cc.p(0,1))
    leftNode:addChild(richText1)

    local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('PEOPLE_KING_DESC_3'),TITLE_DESC[self.page]), 20,cc.c3b(64,16,16))
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('PEOPLE_KING_DESC_6'), 20,cc.c3b(36,255,0))
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('PEOPLE_KING_DESC_15'), 20,cc.c3b(64,16,16))
    re1:setStroke(COLOROUTLINE_TYPE.GREEN, 0)
    re1:clearShadow()
    re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    re2:clearShadow()
    re3:setStroke(COLOROUTLINE_TYPE.GREEN, 0)
    re3:clearShadow()
    richText1:addElement(re1)
    richText1:addElement(re2)
    richText1:addElement(re3)

    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(310, 54))
    richText:setPosition(cc.p(20, 292))
    richText:setAnchorPoint(cc.p(0,1))
    rightNode:addChild(richText)

    local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('PEOPLE_KING_DESC_2'),TITLE_DESC[self.page]), 20,cc.c3b(64,16,16))
    re1:setStroke(COLOROUTLINE_TYPE.GREEN, 0)
    re1:clearShadow()
    richText:addElement(re1)
    local richText1 = xx.RichText:create()
    richText1:setContentSize(cc.size(310, 54))
    richText1:setPosition(cc.p(20, 267))
    richText1:setAnchorPoint(cc.p(0,1))
    rightNode:addChild(richText1)

    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('PEOPLE_KING_DESC_7'), 20,cc.c3b(36,255,0))
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('PEOPLE_KING_DESC_4'), 20,cc.c3b(64,16,16))
    re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    re2:clearShadow()
    re3:setStroke(COLOROUTLINE_TYPE.GREEN, 0)
    re3:clearShadow()
    richText1:addElement(re2)
    richText1:addElement(re3)

    local nodes = {leftNode,rightNode}
    local page = {self.leftPage,self.rightPage}
    for i,v in ipairs(M_IDS) do
        local material = BagData:getMaterialById(v)
        local iconNode = nodes[i]:getChildByName('icon_node')
        local nameTx = nodes[i]:getChildByName('name_tx')
        local awardBgImg = iconNode:getChildByName('award_bg_img')
        if not awardBgImg then
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            awardBgImg = tab.awardBgImg
            iconNode:addChild(awardBgImg)
        end
        local lvTx = awardBgImg:getChildByName('lv_tx')
        ClassItemCell:updateItem(awardBgImg,material,2)
        lvTx:setVisible(false)
        nameTx:setString(material:getName())
        nameTx:setColor(material:getNameColor())

        local additionBtn = nodes[i]:getChildByName("addition_btn")
        local text = additionBtn:getChildByName('text')
        text:setString(GlobalApi:getLocalStr("PEOPLE_KING_BOTTON_DESC_"..page[i]))
        additionBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if i == 1 then
                    self.leftPage = self.leftPage%2 + 1
                    text:setString(GlobalApi:getLocalStr("PEOPLE_KING_BOTTON_DESC_"..self.leftPage))
                    self:updateLeft()
                else
                    self.rightPage = self.rightPage%2 + 1
                    text:setString(GlobalApi:getLocalStr("PEOPLE_KING_BOTTON_DESC_"..self.rightPage))
                    self:updateRight()
                end
            end
        end)
    end
end

function PeopleKingAwakeWeaponUI:getAttr(conf,level,ntype)
    local allAttr = {0,0,0,0}
    local attr = {0,0,0,0}
    local useNum = self:getUseCount(ntype)
    for i,v in ipairs(conf) do
        for j=1,4 do
            if i == level then
                attr[j] = v[STYPE[j]]
                allAttr[j] =  v[STYPE[j]]*useNum
            end
        end
    end
    return {attr,allAttr}
end

function PeopleKingAwakeWeaponUI:getLevel()
    local levels = {self.data.weapon_level,self.data.wing_level}
    return levels[self.page]
end

function PeopleKingAwakeWeaponUI:getUseCount(ntype)
    local counts = {
        [1] = {self.data.weapon_gas,self.data.weapon_blood},
        [2] = {self.data.wing_gas,self.data.wing_blood}
    }
    return counts[self.page][ntype]
end

function PeopleKingAwakeWeaponUI:setOldData(currAttr,fightforce)
    if currAttr then
        self.currAttr = currAttr
    else
        local attr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
        self.currAttr = {}
        for i = 1, 4 do
            self.currAttr[i] = attr[i] or 0
        end
    end
    self.oldfightforce = fightforce or RoleData:getFightForce()
end

function PeopleKingAwakeWeaponUI:popupTips()
    local newAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
    for i = 1, 4 do
        newAttr[i] = newAttr[i] or 0
    end
    RoleData:setAllFightForceDirty()
    local newfightforce = RoleData:getFightForce()
    GlobalApi:popupTips(self.currAttr, newAttr, self.oldfightforce, newfightforce)
    self:setOldData(newAttr,newfightforce)
end

function PeopleKingAwakeWeaponUI:lvUp(ntype,callback)

    -- 人皇圣武觉醒 mod: 'hero' act: 'awaken_sky_weapon' args:utype  1:精气石 2: 精血石
    -- 人皇圣翼觉醒 mod: 'hero' act: 'awaken_sky_wing' args:utype  1:精气石 2: 精血石
    -- local currAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
    -- for i = 1, 4 do
    --     currAttr[i] = currAttr[i] or 0
    -- end
    -- local oldfightforce = RoleData:getFightForce()
    self.effectCount = self.effectCount + 1
    local act = {
        [1] = 'awaken_sky_weapon',
        [2] = 'awaken_sky_wing',
    }
    local args = {
        utype = ntype
    }
    MessageMgr:sendPost(act[self.page],'hero',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            if self.page == 1 then
                if ntype == 1 then
                    self.data.weapon_gas = self.data.weapon_gas + 1
                else
                    self.data.weapon_blood = self.data.weapon_blood + 1
                end
            else
                if ntype == 1 then
                    self.data.wing_gas = self.data.wing_gas + 1
                else
                    self.data.wing_blood = self.data.wing_blood + 1
                end
            end
            -- local newAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
            -- for i = 1, 4 do
            --     newAttr[i] = newAttr[i] or 0
            -- end
            -- local newfightforce = RoleData:getFightForce()
            -- GlobalApi:popupTips(currAttr, newAttr, oldfightforce, newfightforce)
                    
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            if callback then
                callback()
            end
        else
            self.effectCount = self.effectCount - 1
            if self.effectCount <= 0 then
                self:popupTips()
            end
        end
    end)
end

function PeopleKingAwakeWeaponUI:updatePanel()
    self:updateLeft()
    self:updateRight()
end

function PeopleKingAwakeWeaponUI:playAction(node,callback)
    local particle = cc.ParticleSystemQuad:create("particle/bullet_guojia_2_p1.plist")
    particle:setPosition(cc.p(70, 350))
    -- particle:setScale(0.5)
    node:addChild(particle)

    local bezier = {
        cc.p(72,262),
        cc.p(92,222),
        cc.p(174,134)
    }
    local time = 0.5
    local bezierTo = cc.BezierTo:create(time, bezier)
    particle:runAction(cc.Sequence:create(bezierTo,cc.CallFunc:create(function()
        particle:removeFromParent()
        if callback then
            callback()
        end
    end)))
end

function PeopleKingAwakeWeaponUI:updateLeft()
    local ntype = 1
    local conf = self.conf[ntype][self.page]
    local level = self:getLevel()
    local material = BagData:getMaterialById(M_IDS[ntype])
    local leftNode = self.bgImg3:getChildByName("left_node")
    local descTx1 = leftNode:getChildByName("desc_tx_1")
    local descTx2 = leftNode:getChildByName("desc_tx_2")
    local descTx3 = leftNode:getChildByName("desc_tx_3")
    local descTx4 = leftNode:getChildByName("desc_tx_4")
    local useTx = leftNode:getChildByName("use_tx")
    local numTx = leftNode:getChildByName("num_tx")
    local additionBtn = leftNode:getChildByName("addition_btn")
    local text = additionBtn:getChildByName('text')
    local useBtn = leftNode:getChildByName("use_btn")
    local useTx1 = useBtn:getChildByName('use_tx')
    local num = material:getNum()
    local useNum = self:getUseCount(ntype)
    local maxNum = conf[level].num
    local needLevel = 0
    for i,v in ipairs(conf) do
        if v.num > 0 then
            needLevel = i
            break
        end
    end
    descTx1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_1"))
    descTx2:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_8"),TITLE_DESC[self.page],needLevel))
    descTx2:setVisible(level < needLevel)
    descTx3:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_AWAKE_DESC_" .. self.leftPage), GlobalApi:getLocalStr("PEOPLE_KING_DESC_6")))
    descTx4:setString(GlobalApi:getLocalStr("TAVERN_NOW_OWN") .. GlobalApi:getLocalStr("PEOPLE_KING_DESC_6") .. "：")
    useTx:setString(useNum..'/'..maxNum)
    numTx:setString(num)
    if num > 0 then
        numTx:setColor(COLOR_TYPE.GREEN)
        useTx1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_9"))
    else
        numTx:setColor(COLOR_TYPE.RED)
        useTx1:setString(GlobalApi:getLocalStr("GET_TEXT"))
    end
    additionBtn:loadTextures(BUTTON_RES[self.leftPage],'','')
    
    local attrConf = GameData:getConfData("attribute")
    local leftImg2 = leftNode:getChildByName("left_img_2")
    local attrTab = self:getAttr(conf,level,ntype)
    local showAttr = {}
    showAttr[1] = attrTab[self.leftPage][1] or 0
    showAttr[2] = attrTab[self.leftPage][4] or 0
    showAttr[3] = attrTab[self.leftPage][2] or 0
    showAttr[4] = attrTab[self.leftPage][3] or 0
    for i = 1, 4 do
        local attrName = leftImg2:getChildByName("attr_name_" .. i)
        local attrNum = leftImg2:getChildByName("attr_num_" .. i)
        attrName:setString(attrConf[i].name)
        attrNum:setString(' +'.. showAttr[i]) 
    end

    useBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if num > 0 then
                if level < needLevel then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_8"),TITLE_DESC[self.page],needLevel), COLOR_TYPE.RED)
                    return
                end
                if useNum >= maxNum then
                    if level >= #conf then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_11'), COLOR_TYPE.RED)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_10'), COLOR_TYPE.RED)
                    end
                else
                    self:lvUp(ntype,function()
                        self:playAction(leftNode,function()
                            self.leftPage = 2
                            text:setString(GlobalApi:getLocalStr("PEOPLE_KING_BOTTON_DESC_"..self.leftPage))
                            self.effectCount = self.effectCount - 1
                            if self.effectCount <= 0 then
                                self:popupTips()
                            end
                            self:updateLeft()
                        end)
                    end)
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                GetWayMgr:showGetwayUI(material,true)
            end
        end
    end)
end

function PeopleKingAwakeWeaponUI:updateRight()
    local ntype = 2
    local conf = self.conf[ntype][self.page]
    local level = self:getLevel()
    local material = BagData:getMaterialById(M_IDS[ntype])
    local rightNode = self.bgImg3:getChildByName("right_node")
    local descTx1 = rightNode:getChildByName("desc_tx_1")
    local descTx2 = rightNode:getChildByName("desc_tx_2")
    local descTx3 = rightNode:getChildByName("desc_tx_3")
    local descTx4 = rightNode:getChildByName("desc_tx_4")
    local useTx = rightNode:getChildByName("use_tx")
    local numTx = rightNode:getChildByName("num_tx")
    local additionBtn = rightNode:getChildByName("addition_btn")
    local text = additionBtn:getChildByName('text')
    local useBtn = rightNode:getChildByName("use_btn")
    local useTx1 = useBtn:getChildByName('use_tx')
    local num = material:getNum()
    local useNum = self:getUseCount(ntype)
    local maxNum = conf[level].num
    local needLevel = 0
    for i,v in ipairs(conf) do
        if v.num > 0 then
            needLevel = i
            break
        end
    end
    descTx1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_1"))
    descTx2:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_8"),TITLE_DESC[self.page],needLevel))
    descTx2:setVisible(level < needLevel)
    descTx3:setString(string.format(GlobalApi:getLocalStr("PEOPLE_KING_AWAKE_DESC_" .. self.rightPage), GlobalApi:getLocalStr("PEOPLE_KING_DESC_7")))
    descTx4:setString(GlobalApi:getLocalStr("TAVERN_NOW_OWN") .. GlobalApi:getLocalStr("PEOPLE_KING_DESC_7") .. "：")
    useTx:setString(useNum..'/'..maxNum)
    numTx:setString(num)
    if num > 0 then
        numTx:setColor(COLOR_TYPE.GREEN)
        useTx1:setString(GlobalApi:getLocalStr("PEOPLE_KING_DESC_9"))
    else
        numTx:setColor(COLOR_TYPE.RED)
        useTx1:setString(GlobalApi:getLocalStr("GET_TEXT"))
    end
    additionBtn:loadTextures(BUTTON_RES[self.rightPage],'','')

    local attrConf = GameData:getConfData("attribute")
    local rightImg2 = rightNode:getChildByName("right_img_2")
    local attrTab = self:getAttr(conf,level,ntype)
    for i = 1, 4 do
        local attrName = rightImg2:getChildByName("attr_name_" .. i)
        local attrNum = rightImg2:getChildByName("attr_num_" .. i)
        attrName:setString(attrConf[i].name)
        attrNum:setString(' +'..attrTab[self.rightPage][i]..'%')
    end

    useBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if num > 0 then
                if level < needLevel then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("PEOPLE_KING_DESC_8"),TITLE_DESC[self.page],needLevel), COLOR_TYPE.RED)
                    return
                end
                if useNum >= maxNum then
                    if level >= #conf then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_11'), COLOR_TYPE.RED)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_DESC_10'), COLOR_TYPE.RED)
                    end
                else
                    self:lvUp(ntype,function()
                        self:playAction(rightNode,function()
                            self.rightPage = 2
                            text:setString(GlobalApi:getLocalStr("PEOPLE_KING_BOTTON_DESC_"..self.rightPage))
                            self.effectCount = self.effectCount - 1
                            if self.effectCount <= 0 then
                                self:popupTips()
                            end
                            self:updateRight()
                        end)
                    end)
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                GetWayMgr:showGetwayUI(material,true)
            end
        end
    end)
end

return PeopleKingAwakeWeaponUI