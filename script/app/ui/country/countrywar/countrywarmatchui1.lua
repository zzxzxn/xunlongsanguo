local CountryWarMatchUI = class("CountryWarMatchUI", BaseUI)
local MAX_LITTLE_MSG = 5
local MAX_SOLDIER_NUM = 9
local MAX_LEGION_NUM = 6

local CAMP_COLOR = {
    COLOR_TYPE.BLUE,
    COLOR_TYPE.GREEN,
    COLOR_TYPE.RED,
}

function CountryWarMatchUI:ctor(cityId)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_MATCH
    self.matched = false
    self.battled = false
    self.cityId = cityId
    -- self.data = data
    self.hideLeft = true
    self.littleChatMsgs = {}
    self.littleChatRts = {}
    self.actionMsgs = {}
    self.actionRun = {}
    self.leftPlayersNum = 0
    self.rightPlayersNum = 0
    local nowTime = GlobalData:getServerTime()
    local time = CountryWarMgr.countrywar.coolTime
    if nowTime < time then
        self.battled = true
    end
end

local COUNTRY_COLOR_TYPE = {
    [1] = COLOR_TYPE.BLUE,
    [2] = COLOR_TYPE.GREEN,
    [3] = COLOR_TYPE.RED,
    [6] = COLOR_TYPE.YELLOW,
    [7] = COLOR_TYPE.ORANGE1,
}
function CountryWarMatchUI:battleCoolingTime()
    -- local diffTime = tonumber(CountryWarMgr:getBaseValue('battleDiffTime'))
    local label = self.timeBgImg:getChildByName('match_time_tx')
    if label then
        label:removeFromParent()
    end
    local nowTime = GlobalData:getServerTime()
    print('=======================xxxx',CountryWarMgr.countrywar.coolTime)
    local time = CountryWarMgr.countrywar.coolTime
    if nowTime >= time then
        self.battled = false
        return
    end
    local diffTime = time - nowTime
    -- local winSize = cc.Director:getInstance():getVisibleSize()
    local size = self.timeBgImg:getContentSize()
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    label:setName('match_time_tx')
    label:setPosition(cc.p(size.width/2 + 45,size.height/2))
    label:setAnchorPoint(cc.p(0,0.5))
    self.timeBgImg:addChild(label)
    self.timeBgImg:setVisible(true)
    -- GlobalApi:getLocalStr('TODAY_DOUBLE_DES11')
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT,GlobalApi:getLocalStr('COUNTRY_WAR_DESC_28'),
        COLOR_TYPE.RED,COLOROUTLINE_TYPE.RED,25,function()
        label:removeFromParent()
        self.timeBgImg:setVisible(false)
        self.battled = false
    end,2)
end

function CountryWarMatchUI:matchCoolingTime()
    self.matchBgImg:setVisible(false)
    self.timeBgImg:setVisible(true)
    self.matched = false
    -- self.battled = true
    -- self:battleCoolingTime()
end

function CountryWarMatchUI:updateLittleChatMsg()
    -- self.chatBgImg:stopAllActions()
    -- self.root:stopAllActions()
    if #self.littleChatMsgs > MAX_LITTLE_MSG then
        table.remove(self.littleChatMsgs,1)
    end
    local maxHeight = 0
    local heights = {}
    for i=1,MAX_LITTLE_MSG do
        if self.littleChatMsgs[i] then
            local stype = ''
            local un = self.littleChatMsgs[i].user.un or ''
            local vip = self.littleChatMsgs[i].user.vip
            local content = self.littleChatMsgs[i].content
            if self.littleChatMsgs[i].mod == 'world' then
                stype = GlobalApi:getLocalStr('CHAT_CHANNEL1')
            elseif self.littleChatMsgs[i].mod == 'countrywar' then
                stype = GlobalApi:getLocalStr('CHAT_CHANNEL5')
                un = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_22')
            elseif self.littleChatMsgs[i].mod == 'countrywarcity' then
                stype = GlobalApi:getLocalStr('CITY')
                un = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_22')
            end
            if not self.littleChatRts[i] then
                local pl = ccui.Widget:create()
                pl:setAnchorPoint(cc.p(0,1))
                self.littleChatRts[i] = pl
                self.chatSv:addChild(pl)

                local channelTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
                channelTx:setColor(COLOR_TYPE.ORANGE)
                channelTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                channelTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                channelTx:setAnchorPoint(cc.p(0,1))
                channelTx:setName('channel_tx')

                local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
                nameTx:setColor(COLOR_TYPE.WHITE)
                nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                nameTx:setAnchorPoint(cc.p(0,1))
                nameTx:setName('name_tx')

                local vipTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
                vipTx:setColor(COLOR_TYPE.RED)
                vipTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                vipTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                vipTx:setAnchorPoint(cc.p(0,1))
                vipTx:setName('vip_tx')

                local contentTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
                contentTx:setColor(cc.c3b(132,212,210))
                contentTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                contentTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                contentTx:setAnchorPoint(cc.p(0,1))
                contentTx:setName('content_tx')
                contentTx:setMaxLineWidth(306)

                local voiceImg = ccui.ImageView:create('uires/ui/chat/chat_yuyin.png')
                voiceImg:setScale(0.5)
                voiceImg:setAnchorPoint(cc.p(0,1))
                voiceImg:setName('voice_img')

                pl:addChild(channelTx)
                pl:addChild(nameTx)
                pl:addChild(vipTx)
                pl:addChild(contentTx)
                pl:addChild(voiceImg)
            end
            local pl = self.littleChatRts[i]
            local channelTx = pl:getChildByName('channel_tx')
            local nameTx = pl:getChildByName('name_tx')
            local vipTx = pl:getChildByName('vip_tx')
            local contentTx = pl:getChildByName('content_tx')
            local voiceImg = pl:getChildByName('voice_img')
            channelTx:setString('['..stype..']')
            if un then
                nameTx:setString(un..':')
            else
                nameTx:setString('')
            end
            if vip then
                vipTx:setString('VIP'..vip)
            else
                vipTx:setString('')
            end
            contentTx:setString(content)
            local size = channelTx:getContentSize()
            local size1 = nameTx:getContentSize()
            local size2 = vipTx:getContentSize()
            heights[i] = contentTx:getContentSize().height + size.height
            pl:setContentSize(cc.size(250,heights[i]))
            channelTx:setPosition(cc.p(0,heights[i]))
            nameTx:setPosition(cc.p(5 + size.width,heights[i]))
            vipTx:setPosition(cc.p(10 + size.width + size1.width,heights[i]))
            voiceImg:setPosition(cc.p(10 + size.width + size1.width + size1.width,heights[i]))
            contentTx:setPosition(cc.p(0,heights[i] - size.height))
            if isVoice then    -- 是语音
                voiceImg:setVisible(true)
            else
                voiceImg:setVisible(false)
            end
            pl:setVisible(true)
            maxHeight = maxHeight + heights[i]
        end
    end
    local size = self.chatSv:getContentSize()
    if maxHeight > size.height then
        self.chatSv:setInnerContainerSize(cc.size(306,maxHeight))
    else
        self.chatSv:setInnerContainerSize(size)
        maxHeight = size.height
    end
    local currHeight = maxHeight
    for i=1,MAX_LITTLE_MSG do
        if self.littleChatRts[i] then
            self.littleChatRts[i]:setPosition(cc.p(0,currHeight))
            currHeight = currHeight - heights[i]
        end
    end
    self.chatSv:jumpToBottom()
    self.chatBgImg:setOpacity(255)
    -- self.chatBgImg:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.FadeOut:create(0.5)))
    -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(16.3),cc.CallFunc:create(function()
    --     for i=1,MAX_LITTLE_MSG do
    --         if self.littleChatRts[i] then
    --             self.littleChatRts[i].richText:setVisible(false)
    --         end
    --     end
    -- end)))
    -- self.littleChatRts[1].richText:setOpacity(0)
end

function CountryWarMatchUI:setLittleChatMsg(msg)
    self.littleChatMsgs[#self.littleChatMsgs + 1] = msg
    self:updateLittleChatMsg()
end

function CountryWarMatchUI:updateTopPanel()
    local topImg = self.bgImg1:getChildByName('top_img')
    local attackTx = topImg:getChildByName('attack_tx')
    local defenseTx = topImg:getChildByName('defense_tx')
    local leftPl = topImg:getChildByName('left_pl')
    local rightPl = topImg:getChildByName('right_pl')
    attackTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_10'))
    defenseTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_11'))

    local cityData = CountryWarMgr.citys[tostring(self.cityId)]
    -- if cityData.hold_camp == self.camp then
    -- local country = UserData:getUserObj():getCountry()
    local tab = {1,2,3}
    table.remove(tab,cityData.hold_camp)
    local tab1 = {cityData.hold_camp,6}
    local players = {}
    local robots = {}
    local allPlayers = clone(CountryWarMgr.citys[tostring(self.cityId)].players)
    for i,v in ipairs(allPlayers[tostring(cityData.hold_camp)]) do
        if not v.uid or v.uid < 1000000 then
            robots[#robots + 1] = v
        else
            players[#players + 1] = v
        end
    end
    allPlayers[tostring(cityData.hold_camp)] = players
    allPlayers['6'] = robots
    -- print('======================xxx1')
    -- printall(allPlayers)
    -- print('======================xxx2')
    for i=2,1,-1 do
        if not tab[i] or #allPlayers[tostring(tab[i])] <= 0 then
            table.remove(tab,i)
        end
        if not tab1[i] or #allPlayers[tostring(tab1[i])] <= 0 then
            table.remove(tab1,i)
        end
    end

    for i=1,2 do
        local leftBgImg = leftPl:getChildByName('bg_img_'..i)
        local rightBgImg = rightPl:getChildByName('bg_img_'..i)
        local leftRoundImg = leftBgImg:getChildByName('round_img')
        local leftCountryTx = leftRoundImg:getChildByName('country_tx')
        local leftNumTx = leftBgImg:getChildByName('num_tx')
        local rightRoundImg = rightBgImg:getChildByName('round_img')
        local rightCountryTx = rightRoundImg:getChildByName('country_tx')
        local rightNumTx = rightBgImg:getChildByName('num_tx')

        local leftFightForceBgImg = leftPl:getChildByName('fight_force_img_'..i)
        local rightFightForceBgImg = rightPl:getChildByName('fight_force_img_'..i)
        local leftRoundImg1 = leftFightForceBgImg:getChildByName('round_img')
        local leftCountryTx1 = leftRoundImg1:getChildByName('country_tx')
        local leftNumTx1 = leftFightForceBgImg:getChildByName('num_tx')
        local rightRoundImg1 = rightFightForceBgImg:getChildByName('round_img')
        local rightCountryTx1 = rightRoundImg1:getChildByName('country_tx')
        local rightNumTx1 = rightFightForceBgImg:getChildByName('num_tx')

        if tab[i] then
            leftBgImg:setVisible(true)
            leftFightForceBgImg:setVisible(true)
            leftCountryTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_CAMP_'..tab[i]))
            leftCountryTx:setColor(COUNTRY_COLOR_TYPE[tab[i]])
            leftNumTx:setString(#allPlayers[tostring(tab[i])]..' '..GlobalApi:getLocalStr('SOLDIER_REN'))
            local fightForce = 0
            for i,v in ipairs(allPlayers[tostring(tab[i])]) do
                fightForce = fightForce + (v.fight_force or 0)
            end
            leftCountryTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_65'))
            leftCountryTx1:setColor(COUNTRY_COLOR_TYPE[7])
            leftNumTx1:setString(GlobalApi:toWordsNumber(fightForce))
        else
            leftBgImg:setVisible(false)
            leftFightForceBgImg:setVisible(false)
        end
        if tab1[i] then
            rightBgImg:setVisible(true)
            rightFightForceBgImg:setVisible(true)
            rightCountryTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_CAMP_'..tab1[i]))
            rightCountryTx:setColor(COUNTRY_COLOR_TYPE[tab1[i]])
            rightNumTx:setString(#allPlayers[tostring(tab1[i])]..' '..GlobalApi:getLocalStr('SOLDIER_REN'))
            local fightForce = 0
            for i,v in ipairs(allPlayers[tostring(tab1[i])]) do
                fightForce = fightForce + (v.fight_force or 0)
            end
            rightCountryTx1:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_65'))
            rightCountryTx1:setColor(COUNTRY_COLOR_TYPE[7])
            rightNumTx1:setString(GlobalApi:toWordsNumber(fightForce))
        else
            rightBgImg:setVisible(false)
            rightFightForceBgImg:setVisible(false)
        end
    end
end

function CountryWarMatchUI:runLeftPlAction()
    self.arrowBtn:setTouchEnabled(false)
    local posX,posY = self.leftPl:getPosition()
    local size = self.leftPl:getContentSize()
    if self.hideLeft then
        self.leftPl:runAction(cc.Sequence:create(cc.MoveTo:create(0.25, cc.p(posX - size.width,posY)) ,cc.CallFunc:create(function()
            self.leftPl:setPosition(cc.p(-size.width,posY))
            self.arrowBtn:setTouchEnabled(true)
        end)))
        self.arrowBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
            self.arrowBtn:loadTextures('uires/ui/chat/chat_btn_arrow_right_1.png','','')
        end)))
    else
        self.leftPl:runAction(cc.Sequence:create(cc.MoveTo:create(0.25, cc.p(posX + size.width,posY)) ,cc.CallFunc:create(function()
            self.leftPl:setPosition(cc.p(0,posY))
            self.arrowBtn:setTouchEnabled(true)
        end)))
        self.arrowBtn:runAction(cc.Sequence:create(cc.DelayTime:create(0.2),cc.CallFunc:create(function()
            self.arrowBtn:loadTextures('uires/ui/chat/chat_btn_arrow_left_1.png','','')
        end)))
    end
end

function CountryWarMatchUI:updateLeftPanel()
    for i=1,7 do
        local roleBgImg = self.leftPl:getChildByName('role_bg_img_'..i)
        local roleImg = roleBgImg:getChildByName('role_img')
        local barBg = roleBgImg:getChildByName('bar_bg')
        local bar = barBg:getChildByName('bar')

        local pos = CountryWarMgr.countrywar.pos
        local obj = RoleData:getRoleByPos(i)
        if obj and obj:getId() > 0 then
            roleBgImg:setVisible(true)
            roleBgImg:loadTexture(obj:getBgImg())
            roleImg:loadTexture(obj:getIcon())
            roleBgImg:ignoreContentAdaptWithSize(true)
            roleImg:ignoreContentAdaptWithSize(true)
            local quality = obj:getQuality()
            GlobalApi:setHeroPromoteAction(roleBgImg,quality)
            local conf = obj:getConfig('soldierlevel')
            -- local per = pos[tostring(i)].hp*0.9 + pos[tostring(i)].soldierNum/conf.num*100*0.1
            local per = pos[tostring(i)].hp
            if per <= 0 then
                ShaderMgr:setGrayForWidget(roleBgImg)
                ShaderMgr:setGrayForWidget(roleImg)
            else
                ShaderMgr:restoreWidgetDefaultShader(roleBgImg)
                ShaderMgr:restoreWidgetDefaultShader(roleImg)
            end
            bar:setPercent(per)
        else
            roleBgImg:setVisible(false)
        end
    end
end

function CountryWarMatchUI:createSoldier(name)
    -- cc.SpriteFrameCache:getInstance():addSpriteFrames("animation_littlelossy/xiaobing/xiaobing.plist")
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/" .. name .. "/" .. name .. ".json")
    local armature = ccs.Armature:create(name)
    armature:getAnimation():play('idle',-1,1)
    return armature
end

function CountryWarMatchUI:createHero(name)
    local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    nameTx:setColor(COLOR_TYPE.WHITE)
    nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    nameTx:setAnchorPoint(cc.p(0.5,0.5))
    nameTx:setName('name_tx')

    local fuTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 18)
    fuTx:setColor(COLOR_TYPE.YELLOW)
    fuTx:enableOutline(COLOR_TYPE.BLACK, 1)
    fuTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    fuTx:setAnchorPoint(cc.p(1,0.5))
    fuTx:setName('fu_tx')

    local armature = GlobalApi:createLittleLossyAniByName('nan_display')
    armature:setScale(0.35)
    armature:getAnimation():play('idle',-1,1)
    return armature,nameTx,fuTx
end

function CountryWarMatchUI:setSoldierPosition(index,soldierObj,stype)
    local maxR = 3
    local maxC = 3
    local leftDiffX = 110
    local rightDiffX = 80
    local diffY = 50
    local r = math.ceil(index/maxC)
    local c = (index - 1) % maxC + 1
    if stype == 'left' then
        soldierObj:setPosition(cc.p((maxC - c)*30 - (maxR - r)*15 - leftDiffX,(maxR - r)*25 - diffY))
    else
        soldierObj:setScaleX(-0.8)
        soldierObj:setPosition(cc.p((maxC - c)*30 - (maxR - r)*15 + rightDiffX,(maxR - r)*25 - diffY))
    end
end

function CountryWarMatchUI:createLegion(node,index,url,stype)
    local heroObj,nameTx,fuTx = self:createHero()
    heroObj:setName('hero')
    nameTx:setPosition(cc.p(0,50))
    fuTx:setString('')
    -- nameTx:setString('这是个玩家'..index)
    nameTx:setString('')
    node:addChild(heroObj)
    node:addChild(nameTx)
    node:addChild(fuTx)

    if stype ~= 'left' then
        heroObj:setScaleX(-0.35)
        heroObj:setPosition(cc.p(0,-35))
    else
        heroObj:setPosition(cc.p(0,-35))
    end

    for i = 1, MAX_SOLDIER_NUM do
        local soldierObj = self:createSoldier(url)
        soldierObj:setScale(0.8)
        soldierObj:setName('soldier_'..i)
        node:addChild(soldierObj)
        self:setSoldierPosition(i,soldierObj,stype)
    end
end

function CountryWarMatchUI:setLegionPosition(node,index,stype)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local diffMid = 100
    local diffX = 70
    local diffXc = 190
    local diffY = 125
    local leftPos = {
        cc.p(winSize.width/2 - diffMid,winSize.height/2),
        cc.p(winSize.width/2 - diffX - diffMid,winSize.height/2 + diffY),
        cc.p(winSize.width/2 + diffX - diffMid,winSize.height/2 - diffY),
        cc.p(winSize.width/2 - diffXc - diffMid,winSize.height/2),
        cc.p(winSize.width/2 - diffXc - diffX - diffMid,winSize.height/2 + diffY),
        cc.p(winSize.width/2 - diffXc + diffX - diffMid,winSize.height/2 - diffY),
    }
    local rightPos = {
        cc.p(winSize.width/2 + diffMid,winSize.height/2),
        cc.p(winSize.width/2 - diffX + diffMid,winSize.height/2 + diffY),
        cc.p(winSize.width/2 + diffX + diffMid,winSize.height/2 - diffY),
        cc.p(winSize.width/2 + diffXc + diffMid,winSize.height/2),
        cc.p(winSize.width/2 + diffXc - diffX + diffMid,winSize.height/2 + diffY),
        cc.p(winSize.width/2 + diffXc + diffX + diffMid,winSize.height/2 - diffY),
    }
    self.originalLeftPos = leftPos
    self.originalRightPos = rightPos
    if stype == 'left' then
        node:setPosition(leftPos[index])
    else
        node:setPosition(rightPos[index])
    end
end

function CountryWarMatchUI:createAllLegion()
    local leftUrls = {'daobing_2_g','qibing_2_g','gongbing_2_g'}
    local rightUrls = {'daobing_2_r','qibing_2_r','gongbing_2_r'}
    for i=1,MAX_LEGION_NUM do
        local node = self.bgImg1:getChildByName('left_node_'..i)
        if not node then
            node = cc.Node:create()
            node:setName('left_node_'..i)
            -- node:setPosition(leftPos[i])
            self:setLegionPosition(node,i,'left')
            local image = ccui.ImageView:create('uires/ui/countrywar/dian_1_1.png')
            node:addChild(image,999)
            image:setVisible(false)
            self.bgImg1:addChild(node)
            node:setCascadeOpacityEnabled(true)
            node:setOpacity(0)
            local url = leftUrls[math.random(1,3)]
            self:createLegion(node,i,url,'left')
        end
    end

    for i=1,MAX_LEGION_NUM do
        local node = self.bgImg1:getChildByName('right_node_'..i)
        if not node then
            node = cc.Node:create()
            node:setName('right_node_'..i)
            -- node:setPosition(rightPos[i])
            self:setLegionPosition(node,i,'right')
            local image = ccui.ImageView:create('uires/ui/countrywar/dian_2_1.png')
            node:addChild(image,999)
            image:setVisible(false)
            self.bgImg1:addChild(node)
            node:setCascadeOpacityEnabled(true)
            node:setOpacity(0)
            local url = rightUrls[math.random(1,3)]
            self:createLegion(node,i,url,'right')
        end
    end
end

function CountryWarMatchUI:setActionMsg(msg)
    self.actionMsgs[#self.actionMsgs + 1] = msg
    self:actionMgr()
end

function CountryWarMatchUI:actionMgr(isActionEnd)
    local num = 0
    for i=1,3 do
        if self.actionRun[i] then
            num = num + 1
        end
    end
    print('==================xxx1',num)
    if isActionEnd and num > 0 then
        return
    end
    if num == 0 then
        for i=1,MAX_LEGION_NUM do
            print('=====================xxx2',#self.actionMsgs)
            if #self.actionMsgs > 0 and (i <= self.leftPlayersNum and i <= self.rightPlayersNum) then
                self:playAction(i)
            end
        end
    elseif num < 3 then
        for i=1,3 do
            if not self.actionRun[i] and #self.actionMsgs > 0 and (i <= self.leftPlayersNum and i <= self.rightPlayersNum) then
                self:playAction(i)
            end
        end
    end
end

function CountryWarMatchUI:playSoldierAction(node,action,again)
    for i=1,MAX_SOLDIER_NUM do
        local soldierAni = node:getChildByName('soldier_'..i)
        soldierAni:getAnimation():play(action == 'shengli' and 'idle' or action ,-1,again == -1 and again or 1)
    end
    local heroObj = node:getChildByName('hero')
    heroObj:getAnimation():play(action,-1,again == -1 and again or 1)
end

function CountryWarMatchUI:revivePlayers(node,index,maxNum)
    if maxNum >= index then
        node:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
    else
        node:runAction(cc.Sequence:create(cc.FadeOut:create(0.5)))
    end
end

function CountryWarMatchUI:reviveAllPlayers()
    for i=1,6 do
        if not self.actionRun[i] then
            local leftNode = self.bgImg1:getChildByName('left_node_'..i)
            local rightNode = self.bgImg1:getChildByName('right_node_'..i)
            self:revivePlayers(leftNode,i,self.leftPlayersNum)
            self:revivePlayers(rightNode,i,self.rightPlayersNum)
        end
    end
end

function CountryWarMatchUI:updatePrompt(msg)
    local showWidgets = {}
    local function updateShowWidgets(str)
        local w = cc.Label:createWithTTF(str, 'font/gamefont.ttf', 24)
        w:setTextColor(COLOR_TYPE.ORANGE)
        w:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
        w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        table.insert(showWidgets, w)
    end
    updateShowWidgets(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_75"))
    updateShowWidgets(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_35")..'+'..(msg.score or 0))
    promptmgr:showAttributeUpdate(showWidgets)
end

function CountryWarMatchUI:updateCountryWarMatchPlayers()
    self.leftPlayersNum = 0
    self.rightPlayersNum = 0
    local cityData = CountryWarMgr.citys[tostring(self.cityId)]
    local allPlayers = CountryWarMgr.citys[tostring(self.cityId)].players
    local tab = {1,2,3}
    table.remove(tab,cityData.hold_camp)
    self.leftPlayersNum = #allPlayers[tostring(tab[1])] + #allPlayers[tostring(tab[2])]
    self.rightPlayersNum = #allPlayers[tostring(cityData.hold_camp)]
    print('=====================xxxx',self.leftPlayersNum,self.rightPlayersNum)
    self:reviveAllPlayers()
end

function CountryWarMatchUI:playAction(index)
    self.actionRun[index] = true
    local msg = clone(self.actionMsgs[1])
    table.remove(self.actionMsgs,1)

    local cityData = CountryWarMgr.citys[tostring(self.cityId)]
    local str1,str2,re1,re2,name1,name2
    if msg.camp1 ~= cityData.hold_camp then
        if msg.winner == msg.uid1 then 
            str1 = 'shengli'
            re1 = 1
            str2 = 'dead'
            re2 = -1
        else
            str2 = 'shengli'
            re2 = 1
            str1 = 'dead'
            re1 = -1
        end
        name1 = msg.name1
        name2 = msg.name2
    else
        if msg.winner == msg.uid1 then 
            str2 = 'shengli'
            re2 = 1
            str1 = 'dead'
            re1 = -1
        else
            str1 = 'shengli'
            re1 = 1
            str2 = 'dead'
            re2 = -1
        end
        name1 = msg.name2
        name2 = msg.name1
    end

    local diffMid = 50
    local leftNode = self.bgImg1:getChildByName('left_node_'..index)
    local rightNode = self.bgImg1:getChildByName('right_node_'..index)
    local leftNameTx = leftNode:getChildByName('name_tx')
    local rightNameTx = rightNode:getChildByName('name_tx')
    local leftFuTx = leftNode:getChildByName('fu_tx')
    local rightFuTx = rightNode:getChildByName('fu_tx')
    leftNode:stopAllActions()
    rightNode:stopAllActions()
    leftNode:setOpacity(255)
    rightNode:setOpacity(255)
    leftNameTx:setOpacity(0)
    rightNameTx:setOpacity(0)
    leftNameTx:setString(name1)
    leftNameTx:setColor(CAMP_COLOR[msg.camp1])
    rightNameTx:setString(name2)
    rightNameTx:setColor(CAMP_COLOR[msg.camp2])
    local size = leftNameTx:getContentSize()
    local size1 = rightNameTx:getContentSize()
    local posX,posY = leftNameTx:getPosition()
    local posX1,posY1 = rightNameTx:getPosition()
    leftFuTx:setOpacity(0)
    rightFuTx:setOpacity(0)
    if msg.uid1 < 100000 then
        leftFuTx:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_52"))
    else
        leftFuTx:setString(msg.serverId1..GlobalApi:getLocalStr('FU'))
    end
    if msg.uid2 < 100000 then
        rightFuTx:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_52"))
    else
        rightFuTx:setString(msg.serverId2..GlobalApi:getLocalStr('FU'))
    end
    leftFuTx:setPosition(cc.p(posX - size.width/2 - 5,posY))
    rightFuTx:setPosition(cc.p(posX1 - size1.width/2 - 5,posY1))
    leftNameTx:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.CallFunc:create(function()
        self:playSoldierAction(leftNode,'run')
    end)))
    rightNameTx:runAction(cc.Sequence:create(cc.FadeIn:create(0.5),cc.CallFunc:create(function()
        self:playSoldierAction(rightNode,'run')
    end)))
    leftFuTx:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
    rightFuTx:runAction(cc.Sequence:create(cc.FadeIn:create(0.5)))
    leftNode:setPosition(self.originalLeftPos[index])
    rightNode:setPosition(self.originalRightPos[index])
    local lPosX,lPosY = leftNode:getPosition()
    local rPosX,rPosY = rightNode:getPosition()
    leftNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.MoveTo:create(1,cc.p(lPosX + diffMid,lPosY)),
        cc.CallFunc:create(function()
            self:playSoldierAction(leftNode,'attack')
        end),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
            self:playSoldierAction(leftNode,str1,re1)
        end),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function()
            self:playSoldierAction(leftNode,'idle',1)
            self:setLegionPosition(leftNode,index,'left')
        end),
        cc.CallFunc:create(function()
            leftNameTx:setString('')
            leftFuTx:setString('')
            self.actionRun[index] = false
            self:updateCountryWarMatchPlayers()
            self:actionMgr(true)
        end)
    ))
    rightNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        cc.MoveTo:create(1,cc.p(rPosX - diffMid,rPosY)),
        cc.CallFunc:create(function()
            self:playSoldierAction(rightNode,'attack')
        end),
        cc.DelayTime:create(0.5),
        cc.CallFunc:create(function()
            self:playSoldierAction(rightNode,str2,re2)
        end),
        cc.DelayTime:create(0.5),
        cc.FadeOut:create(0.5),
        cc.CallFunc:create(function()
            self:playSoldierAction(rightNode,'idle',1)
            self:setLegionPosition(rightNode,index,'right')
        end),
        cc.CallFunc:create(function()
            rightNameTx:setString('')
            rightFuTx:setString('')
        end)
    ))
end

function CountryWarMatchUI:updatePanel()
    -- if data then
    --     self.data = data
    -- end
    self:updateTopPanel()
    self:updateLeftPanel()
    self:battleCoolingTime()
    self:updateMatchBtn()
    -- self:createAllLegion()
end

function CountryWarMatchUI:responseBtn(callback)
    if self.matched then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_30'), COLOR_TYPE.RED)
        return
    end
    if self.battled then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_31'), COLOR_TYPE.RED)
        return
    end
    if callback then
        callback()
    end
end

function CountryWarMatchUI:updateMatchBtn()
    local winSize = cc.Director:getInstance():getVisibleSize()
    local matchBtn1 = self.bgImg1:getChildByName('match_btn_1')
    local matchBtn2 = self.bgImg1:getChildByName('match_btn_2')
    local moveBtn = self.bgImg1:getChildByName('move_btn')
    local btns = {matchBtn1,matchBtn2}

    local country = CountryWarMgr.camp
    local tab = {1,2,3}
    table.remove(tab,country)
    local allPlayers = clone(CountryWarMgr.citys[tostring(self.cityId)].players)
    local num = 0
    local attacker = {}
    for i,v in ipairs(tab) do
        if #allPlayers[tostring(v)] > 0 then
            num = num + 1
            table.insert(attacker,v)
        end
    end
    if num == 0 then
        matchBtn1:setVisible(false)
        matchBtn2:setVisible(false)
    elseif num == 1 then
        matchBtn1:setVisible(true)
        matchBtn2:setVisible(false)
        matchBtn1:setPosition(cc.p(winSize.width/2,100))
    elseif num == 2 then
        matchBtn1:setVisible(true)
        matchBtn2:setVisible(true)
        matchBtn1:setPosition(cc.p(winSize.width/3*1.2,100))
        matchBtn2:setPosition(cc.p(winSize.width/3*1.8,100))
    end
    for i=1,num do
        local infoTx = btns[i]:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_9')..GlobalApi:getLocalStr('COUNTRY_WAR_COUNTRYNAME_'..(attacker[i] or attacker[i - 1])))
        btns[i]:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:responseBtn(function()
                    self.matched = true
                    self.matchBgImg:setVisible(true)
                    CountryWarMgr:matchEnemy(self.bgImg1,self.cityId,attacker[i] or attacker[i - 1],function()
                        self:matchCoolingTime()
                        self.battled = true
                        self:battleCoolingTime()
                    end,function()
                        self.battled = false
                        self.matched = false
                        self.timeBgImg:setVisible(false)
                        self.matchBgImg:setVisible(false)
                    end)
                end)
            end
        end)
    end

    local conf = GameData:getConfData("countrywarcity")
    local cityData = CountryWarMgr.citys[tostring(self.cityId)]
    local playerNum = #cityData.players[tostring(country)]
    local playerNum1 = #cityData.players[tostring(cityData.hold_camp)]
    local endConf = conf[self.cityId]
    local adjoin = endConf.adjoin
    local canMove = false
    if cityData.hold_camp ~= country and playerNum >= playerNum1*2 then
        canMove = true
    end
    moveBtn:setVisible(false)
    if canMove then
        for i,v in ipairs(adjoin) do
            local cityData1 = CountryWarMgr.citys[tostring(v)]
            if cityData1.hold_camp ~= country then
                moveBtn:setVisible(true)
                CountryWarMgr:updateSpecialMoveImg()
                break
            end
        end
    end
end

function CountryWarMatchUI:init()
    local bgImg = self.root:getChildByName("countrywar_bg_img")
    local bgImg1 = bgImg:getChildByName("countrywar_img")
    -- self:adaptUI(bgImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    bgImg1:setContentSize(winSize)
    self.bgImg1 = bgImg1
    local closeBtn = bgImg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarMatch()
        end
    end)
    self.timeBgImg = bgImg1:getChildByName("time_bg_img")
    local reliveBtn = self.timeBgImg:getChildByName('relive_btn')
    self.matchBgImg = bgImg1:getChildByName("match_bg_img")
    self.topImg = bgImg1:getChildByName("top_img")
    self.matchBgImg:setVisible(false)
    self.timeBgImg:setVisible(false)
    self.leftPl = bgImg1:getChildByName("left_pl")
    self.leftPl:setLocalZOrder(10)
    self.matchBgImg:setLocalZOrder(10)

    self.chatBgImg = self.bgImg1:getChildByName('chat_bg_img')
    self.chatBgImg:setLocalZOrder(10)
    self.chatBgImg:setCascadeOpacityEnabled(true)
    self.chatBgImg:setOpacity(0)
    self.chatSv = self.chatBgImg:getChildByName('sv')
    self.chatSv:setScrollBarEnabled(false)

    reliveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.battled then
                CountryWarMgr:cleanUpCooltime(function()
                    self.timeBgImg:setVisible(false)
                    self.battled = false
                    self:updatePanel()
                end)
            end
        end
    end)

    local matchBtn1 = bgImg1:getChildByName('match_btn_1')
    local matchBtn2 = bgImg1:getChildByName('match_btn_2')
    local retreatBtn = bgImg1:getChildByName('retreat_btn')
    local moveBtn = bgImg1:getChildByName('move_btn')
    local logBtn = bgImg1:getChildByName('log_btn')
    logBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:showCountryWarCityLog()
        end
    end)
    moveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarMatch()
        end
    end)
    retreatBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:responseBtn(function()
                CountryWarMgr:goBack(function()
                    CountryWarMgr:hideCountryWarMatch()
                    CountryWarMgr:updateCountryWarMap()
                    CountryWarMgr:setWinPosition()
                end)
            end)
        end
    end)

    local dartBtn = bgImg1:getChildByName('dart_btn')
    dartBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:responseBtn(function()
                CountryWarMgr:showCountryWarOrder()
            end)
        end
    end)

    local arrowBtn = self.leftPl:getChildByName('arrow_btn')
    self.arrowBtn = arrowBtn
    arrowBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.hideLeft = not self.hideLeft
            self:runLeftPlAction()
        end
    end)

    local size = bgImg:getContentSize()
    local size1 = dartBtn:getContentSize()
    bgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    bgImg1:setPosition(cc.p(size.width/2, size.height/2))
    closeBtn:setPosition(cc.p(winSize.width - 15,winSize.height - 35))
    -- matchBtn1:setPosition(cc.p(winSize.width/3*1.2,100))
    -- matchBtn2:setPosition(cc.p(winSize.width/3*1.8,100))
    retreatBtn:setPosition(cc.p(winSize.width- size1.width/2*3,size1.height/2))
    dartBtn:setPosition(cc.p(winSize.width- size1.width/2,size1.height/2))
    logBtn:setPosition(cc.p(winSize.width- size1.width/2*5,size1.height/2))
    moveBtn:setPosition(cc.p(winSize.width- size1.width/2*7,size1.height/2))
    self.matchBgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.timeBgImg:setPosition(cc.p(winSize.width/2, winSize.height - 105))
    self.topImg:setPosition(cc.p(winSize.width/2, winSize.height))
    self.leftPl:setPosition(cc.p(0, winSize.height/2*1.2))
    matchBtn1:setLocalZOrder(9)
    matchBtn2:setLocalZOrder(9)

    self:runLeftPlAction()
    self:updatePanel()
    self:createAllLegion()
    self:updateCountryWarMatchPlayers()
end

return CountryWarMatchUI