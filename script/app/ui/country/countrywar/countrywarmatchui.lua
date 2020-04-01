local CountryWarMatchUI = class("CountryWarMatchUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local MAX_LITTLE_MSG = 5
local MAX_SOLDIER_NUM = 9
local MAX_LEGION_NUM = 2
local MAX_CAMP_NUM = 3
local MAX_LITTLE_MSG1 = 3

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
    self.littleChatMsgs1 = {}
    self.littleChatRts1 = {}
    self.actionMsgs = {
        ['12'] = {},
        ['13'] = {},
        ['23'] = {},
    }
    local nowTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
    local time = CountryWarMgr.countrywar.coolTime
    if nowTime < time then
        self.battled = true
    end
    self.actionRun = {
        ['12'] = false,
        ['13'] = false,
        ['23'] = false,
    }
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
    local nowTime = GlobalData:getServerTime() + CountryWarMgr.diffTime
    print('=======================xxxx',CountryWarMgr.countrywar.coolTime,nowTime,GlobalData:getServerTime())
    local time = CountryWarMgr.countrywar.coolTime
    if nowTime >= time then
        self.battled = false
        self.timeBgImg:setVisible(false)
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

function CountryWarMatchUI:updateLittleChatMsg1()
    if #self.littleChatMsgs1 > MAX_LITTLE_MSG1 then
        table.remove(self.littleChatMsgs1,1)
    end
    local maxHeight = 0
    local heights = {}
    for i=1,MAX_LITTLE_MSG1 do
        if self.littleChatMsgs1[i] then
            local stype = ''
            local un = self.littleChatMsgs1[i].user.un or ''
            local content = self.littleChatMsgs1[i].content
            if not self.littleChatRts1[i] then
                local pl = ccui.Widget:create()
                pl:setAnchorPoint(cc.p(0,1))
                self.littleChatRts1[i] = pl
                self.chatSv1:addChild(pl)

                local channelTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                channelTx:setColor(cc.c3b(132,212,210))
                channelTx:enableOutline(COLOROUTLINE_TYPE.BLUE, 1)
                channelTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                channelTx:setAnchorPoint(cc.p(0,1))
                channelTx:setName('channel_tx')

                local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                nameTx:setColor(COLOR_TYPE.WHITE)
                nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                nameTx:setAnchorPoint(cc.p(0,1))
                nameTx:setName('name_tx')

                local contentTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                contentTx:setColor(cc.c3b(132,212,210))
                contentTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                contentTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                contentTx:setAnchorPoint(cc.p(0,1))
                contentTx:setName('content_tx')
                contentTx:setMaxLineWidth(306)


                pl:addChild(channelTx)
                pl:addChild(nameTx)
                pl:addChild(contentTx)
            end
            local pl = self.littleChatRts1[i]
            local channelTx = pl:getChildByName('channel_tx')
            local nameTx = pl:getChildByName('name_tx')
            local contentTx = pl:getChildByName('content_tx')
            channelTx:setString('['..self.littleChatMsgs1[i].user.serverId..GlobalApi:getLocalStr('FU')..']')
            nameTx:setString(un)
            contentTx:setString(content)
            local size = channelTx:getContentSize()
            local size1 = nameTx:getContentSize()
            heights[i] = contentTx:getContentSize().height
            pl:setContentSize(cc.size(250,heights[i]))
            channelTx:setPosition(cc.p(0,heights[i]))
            nameTx:setPosition(cc.p(5 + size.width,heights[i]))
            contentTx:setPosition(cc.p(10 + size.width + size1.width,heights[i]))
            pl:setVisible(true)
            maxHeight = maxHeight + heights[i]
        end
    end
    local size = self.chatSv1:getContentSize()
    if maxHeight > size.height then
        self.chatSv1:setInnerContainerSize(cc.size(306,maxHeight))
    else
        self.chatSv1:setInnerContainerSize(size)
        maxHeight = size.height
    end
    local currHeight = maxHeight
    for i=1,MAX_LITTLE_MSG1 do
        if self.littleChatRts1[i] then
            self.littleChatRts1[i]:setPosition(cc.p(0,currHeight))
            currHeight = currHeight - heights[i]
        end
    end
    self.chatSv1:jumpToBottom()
    self.chatBgImg1:setOpacity(255)
    self.chatBgImg1:runAction(cc.Sequence:create(cc.DelayTime:create(6),cc.FadeOut:create(0.5)))
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(6.3),cc.CallFunc:create(function()
        for i=1,MAX_LITTLE_MSG1 do
            if self.littleChatRts1[i] then
                self.littleChatRts1[i]:setVisible(false)
            end
        end
    end)))
end

function CountryWarMatchUI:updateLittleChatMsg()
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
            local serverId = self.littleChatMsgs[i].user.serverId
            local position = self.littleChatMsgs[i].user.position
            local country = self.littleChatMsgs[i].user.country
            local content = self.littleChatMsgs[i].content
            local judge = false
            print('===================xxxxaaaa',serverId,position,country)
            if serverId then
                stype = string.format('%03d',serverId)..GlobalApi:getLocalStr('CHAT_DESC_10')
                judge = true
            elseif self.littleChatMsgs[i].mod == 'countrywarcity' then
                stype = GlobalApi:getLocalStr('CITY')
                un = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_22')
            else
                stype = GlobalApi:getLocalStr('CHAT_CHANNEL5')
                if un == '' then
                    un = GlobalApi:getLocalStr('COUNTRY_WAR_DESC_22')
                end
            end
            if not self.littleChatRts[i] then
                local pl = ccui.Widget:create()
                pl:setAnchorPoint(cc.p(0,1))
                self.littleChatRts[i] = pl
                self.chatSv:addChild(pl)

                local channelTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                channelTx:setColor(COLOR_TYPE.ORANGE)
                channelTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                channelTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                channelTx:setAnchorPoint(cc.p(0,1))
                channelTx:setName('channel_tx')

                local positionTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                positionTx:setColor(COLOR_TYPE.WHITE)
                positionTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                positionTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                positionTx:setAnchorPoint(cc.p(0,1))
                positionTx:setName('position_tx')

                local nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                nameTx:setColor(COLOR_TYPE.WHITE)
                nameTx:enableOutline(COLOROUTLINE_TYPE.WHITE, 1)
                nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                nameTx:setAnchorPoint(cc.p(0,1))
                nameTx:setName('name_tx')

                local vipTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
                vipTx:setColor(COLOR_TYPE.RED)
                vipTx:enableOutline(COLOROUTLINE_TYPE.ORANGE, 1)
                vipTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                vipTx:setAnchorPoint(cc.p(0,1))
                vipTx:setName('vip_tx')

                local contentTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 16)
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
                pl:addChild(positionTx)
                pl:addChild(nameTx)
                pl:addChild(vipTx)
                pl:addChild(contentTx)
                pl:addChild(voiceImg)
            end
            local pl = self.littleChatRts[i]
            local channelTx = pl:getChildByName('channel_tx')
            local positionTx = pl:getChildByName('position_tx')
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
            if judge == true and position and country then
                local positionData = GameData:getConfData('position')[position]
                local positionName = nil
                if position <= 3 then
                    positionName = positionData.title
                else
                    positionName = positionData.posName .. GlobalApi:getLocalStr('CHAT_DESC_11')
                end
                positionTx:setString('[' .. positionName .. ']')
                positionTx:setColor(COLOR_QUALITY[positionData.quality])
            else
                positionTx:setString('')
            end
            contentTx:setString(content)
            local size = channelTx:getContentSize()
            local size3 = positionTx:getContentSize()
            local size1 = nameTx:getContentSize()
            local size2 = vipTx:getContentSize()
            heights[i] = contentTx:getContentSize().height + size.height
            pl:setContentSize(cc.size(250,heights[i]))
            channelTx:setPosition(cc.p(0,heights[i]))
            positionTx:setPosition(cc.p(size.width,heights[i]))
            nameTx:setPosition(cc.p(size.width + size3.width,heights[i]))
            vipTx:setPosition(cc.p(size.width + size1.width + size3.width,heights[i]))
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

function CountryWarMatchUI:setLittleChatMsg1(msg)
    self.littleChatMsgs1[#self.littleChatMsgs1 + 1] = msg
    self:updateLittleChatMsg1()
end

function CountryWarMatchUI:setLittleChatMsg(msg)
    self.littleChatMsgs[#self.littleChatMsgs + 1] = msg
    self:updateLittleChatMsg()
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

function CountryWarMatchUI:createLegion(node,index,index1)
    local scale = {
        [1] = {
            [2] = -1,
            [3] = 1,
        },
        [2] = {
            [1] = 1,
            [3] = 1,
        },
        [3] = {
            [1] = -1,
            [2] = -1,
        }
    }
    local heroObj,nameTx,fuTx = self:createHero()
    heroObj:setName('hero')
    nameTx:setPosition(cc.p(0,50))
    fuTx:setString('')
    -- nameTx:setString('这是个玩家'..index..index1)
    -- nameTx:setString('')
    node:addChild(heroObj)
    node:addChild(nameTx)
    node:addChild(fuTx)

    heroObj:setScaleX(0.35*scale[index][index1])
    heroObj:setPosition(cc.p(0,-35))
end

function CountryWarMatchUI:setLegionPosition(node,index,index1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local diffMid = 100
    local diffX = 70
    local diffXc = 190
    local diffY = 125
    local pos = {
        ['12'] = cc.p(winSize.width/2 - 188,winSize.height/2 + 197),
        ['13'] = cc.p(winSize.width/2 - 173,winSize.height/2 + 208),
        ['21'] = cc.p(winSize.width/2 - 314,winSize.height/2 - 59),
        ['23'] = cc.p(winSize.width/2 - 261,winSize.height/2 - 90),
        ['31'] = cc.p(winSize.width/2 + 272,winSize.height/2 + 18),
        ['32'] = cc.p(winSize.width/2 + 270,winSize.height/2 - 8),
    }
    local beziers = {
        ['12'] = {cc.p(winSize.width/2 - 188,winSize.height/2 + 197),
                cc.p(winSize.width/2 - 207,winSize.height/2 + 143),
                cc.p(winSize.width/2 - 224,winSize.height/2 + 71)},
        ['13'] = {cc.p(winSize.width/2 - 173,winSize.height/2 + 208),
                cc.p(winSize.width/2 - 60,winSize.height/2 + 163),
                cc.p(winSize.width/2 + 33,winSize.height/2 + 121)},
        ['21'] = {cc.p(winSize.width/2 - 314,winSize.height/2 - 59),
                cc.p(winSize.width/2 - 275,winSize.height/2 - 4),
                cc.p(winSize.width/2 - 266,winSize.height/2 + 58)},
        ['23'] = {cc.p(winSize.width/2 - 261,winSize.height/2 - 90),
                cc.p(winSize.width/2 - 147,winSize.height/2 - 83),
                cc.p(winSize.width/2 - 4,winSize.height/2 - 108)},
        ['31'] = {cc.p(winSize.width/2 + 272,winSize.height/2 + 18),
                cc.p(winSize.width/2 + 146,winSize.height/2 + 83),
                cc.p(winSize.width/2 + 82,winSize.height/2 + 120)},
        ['32'] = {cc.p(winSize.width/2 + 270,winSize.height/2 - 8),
                cc.p(winSize.width/2 + 163,winSize.height/2 - 90),
                cc.p(winSize.width/2 + 79,winSize.height/2 - 108)},
    }
    local zOrder = {
        ['12'] = 3,
        ['13'] = 3,
        ['21'] = 1,
        ['23'] = 3,
        ['31'] = 3,
        ['32'] = 3,
    }
    self.originalPos = pos
    self.beziers = beziers
    node:setPosition(pos[index..index1])
    node:setLocalZOrder(zOrder[index..index1])
end

function CountryWarMatchUI:createSingleLegion(camp1,camp2)
    local min,max
    if camp1 < camp2 then
        min = camp1
        max = camp2
    else
        min = camp2
        max = camp1
    end
    local node = cc.Node:create()
    self:setLegionPosition(node,min,max)
    -- local image = ccui.ImageView:create('uires/ui/countrywar/dian_1_1.png')
    -- node:addChild(image,999)
    self.bgImg1:addChild(node)
    node:setCascadeOpacityEnabled(true)
    -- node:setOpacity(0)
    self:createLegion(node,min,max)

    local node1 = cc.Node:create()
    self:setLegionPosition(node1,max,min)
    -- local image = ccui.ImageView:create('uires/ui/countrywar/dian_1_1.png')
    -- node1:addChild(image,999)
    self.bgImg1:addChild(node1)
    node1:setCascadeOpacityEnabled(true)
    -- node:setOpacity(0)
    self:createLegion(node1,max,min)
    return node,node1
end

function CountryWarMatchUI:setActionMsg(msg)
    local str = ''
    local str1 = ''
    local index1 = self:getCountryIndex(msg.camp1)
    local index2 = self:getCountryIndex(msg.camp2)
    if index1 < index2 then
        -- str = msg.camp1 .. msg.camp2
        str = index1..index2
        str1 = index2..index1
    else
        str = index2..index1
        str1 = index1..index2
    end
    -- self.actionMsgs[#self.actionMsgs + 1] = msg
    if not self.actionMsgs[str] then
        self.actionMsgs[str] = {}
    end
    self.actionMsgs[str][#self.actionMsgs[str] + 1] = msg
    self:actionMgr(str,str1)
end

function CountryWarMatchUI:actionMgr(stype,stype1,isActionEnd)
    -- local num = 0
    -- for i=1,3 do
    --     if self.actionRun[i] then
    --         num = num + 1
    --     end
    -- end
    -- print('==================xxx1',num)
    -- if isActionEnd and num > 0 then
    --     return
    -- end
    -- if num == 0 then
    --     for i=1,MAX_LEGION_NUM do
    --         print('=====================xxx2',#self.actionMsgs)
    --         if #self.actionMsgs > 0 and (i <= self.leftPlayersNum and i <= self.rightPlayersNum) then
    --             self:playAction(i)
    --         end
    --     end
    -- elseif num < 3 then
    --     for i=1,3 do
    --         if not self.actionRun[i] and #self.actionMsgs > 0 and (i <= self.leftPlayersNum and i <= self.rightPlayersNum) then
    --             self:playAction(i)
    --         end
    --     end
    -- end
    if #self.actionMsgs[stype] > 0 then
        self:playAction(stype,stype1)
    end
end

function CountryWarMatchUI:playSoldierAction(node,action,again)
    -- for i=1,MAX_SOLDIER_NUM do
    --     local soldierAni = node:getChildByName('soldier_'..i)
    --     soldierAni:getAnimation():play(action == 'shengli' and 'idle' or action ,-1,again == -1 and again or 1)
    -- end
    local heroObj = node:getChildByName('hero')
    heroObj:getAnimation():play(action,-1,again == -1 and again or 1)
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
    local cityData = CountryWarMgr.citys[tostring(self.cityId)]
    local allPlayers = CountryWarMgr.citys[tostring(self.cityId)].players
    local tab = {1,2,3}
    table.remove(tab,cityData.hold_camp)
    self:updateMatchBtn()
end

function CountryWarMatchUI:playAction(stype,stype1)
    local msg = clone(self.actionMsgs[stype][1])
    table.remove(self.actionMsgs[stype],1)
    local index1 = self:getCountryIndex(msg.camp1)
    local index2 = self:getCountryIndex(msg.camp2)
    print('=============playAction',msg.camp1,msg.camp2,index1,index2)
    local leftNode,rightNode = self:createSingleLegion(index1,index2)
    self.actionRun[stype] = true
    local cityData = CountryWarMgr.citys[tostring(self.cityId)]
    local str1,str2,re1,re2,name1,name2,color1,color2
    if index1 < index2 then
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
        color1 = CAMP_COLOR[msg.camp1]
        color2 = CAMP_COLOR[msg.camp2]
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
        color1 = CAMP_COLOR[msg.camp2]
        color2 = CAMP_COLOR[msg.camp1]
    end

    local diffMid = 50
    -- local leftNode = self.bgImg1:getChildByName('left_node_'..index)
    -- local rightNode = self.bgImg1:getChildByName('right_node_'..index)
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
    leftNameTx:setColor(color1)
    rightNameTx:setString(name2)
    rightNameTx:setColor(color2)
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
    leftNode:setPosition(self.originalPos[stype])
    rightNode:setPosition(self.originalPos[stype1])
    local lPosX,lPosY = leftNode:getPosition()
    local rPosX,rPosY = rightNode:getPosition()
    print('================xxxxx',stype,stype1)
    local bezierTo = cc.BezierTo:create(1, self.beziers[stype])
    local bezierTo1 = cc.BezierTo:create(1, self.beziers[stype1])
    leftNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        bezierTo,
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
        end),
        cc.CallFunc:create(function()
            leftNameTx:setString('')
            leftFuTx:setString('')
            self.actionRun[stype] = false
            self:updateCountryWarMatchPlayers()
            self:actionMgr(stype,stype1)
        end)
    ))
    rightNode:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.5),
        bezierTo1,
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
        end),
        cc.CallFunc:create(function()
            rightNameTx:setString('')
            rightFuTx:setString('')
        end)
    ))
end

function CountryWarMatchUI:getCountryIndex(camp)
    local index
    for i,v in ipairs(self.countryIndex) do
        if camp == v then
            index = i
            break
        end
    end
    return index
end

function CountryWarMatchUI:updatePanel()
    self:updateLeftPanel()
    -- self:battleCoolingTime()
    self:updateMatchBtn()
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
    local moveBtn = self.bgImg1:getChildByName('move_btn')

    local country = CountryWarMgr.camp
    local camp = CountryWarMgr.citys[tostring(self.cityId)].hold_camp
    local tab = {1,2,3}
    table.remove(tab,camp)
    tab[#tab + 1] = camp
    local allPlayers = CountryWarMgr.citys[tostring(self.cityId)].players
    local pos = {
        [1] = cc.p(winSize.width/2 - 205,winSize.height/2 + 207),
        [2] = cc.p(winSize.width/2 - 340,winSize.height/2 - 107),
        [3] = cc.p(winSize.width/2 + 358,winSize.height/2 + 55)
    }
    self.countryIndex = tab
    for i=1,3 do
        local cityBgImg = self.bgImg1:getChildByName('city_img_'..i)
        local bgImg = cityBgImg:getChildByName('bg_img')
        local flagImg = bgImg:getChildByName('flag_img')
        local numTx = bgImg:getChildByName('num_tx')
        local matchBtn = bgImg:getChildByName('match_btn')
        local infoTx = matchBtn:getChildByName('info_tx')
        local fangdaBtn = cityBgImg:getChildByName('fangda_btn')
        local nameBgImg = cityBgImg:getChildByName('name_bg_img')
        if nameBgImg then
            local nameTx = nameBgImg:getChildByName('name_tx')
            local conf = GameData:getConfData("countrywarcity")[self.cityId]
            local keyArr = string.split(conf.name, '.')
            nameTx:setString(keyArr[#keyArr])
        end
        if CountryWarMgr.camp == tab[i] then
            self.awardBgImg:stopAllActions()
            self.awardBgImg:setPosition(cc.p(pos[i].x,pos[i].y + 100))
            self.awardBgImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
                cc.MoveTo:create(0.5,cc.p(pos[i].x,pos[i].y + 115)), 
                cc.MoveTo:create(0.5,cc.p(pos[i].x,pos[i].y + 100)))))
        end
        if i == 3 then
            cityBgImg:loadTexture('uires/ui/countrywar/city_3_'..tab[i]..'.png')
        end
        cityBgImg:setPosition(pos[i])
        cityBgImg:setLocalZOrder(2)
        infoTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO8'))
        flagImg:loadTexture('uires/ui/countrywar/countrywar_flag_small_'..tab[i]..'.png')
        numTx:setString(#allPlayers[tostring(tab[i])])
        matchBtn:setVisible(tab[i] ~= country and #allPlayers[tostring(tab[i])] > 0)
        matchBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                -- local msg = 
                -- {
                --     city = 20,
                --     camp2 = 2,
                --     serverId1 = 28,
                --     name2 = 'AAA',
                --     act = 'on_player_fight',
                --     camp1 = 1,
                --     mod = 'countrywar',
                --     winner  = 28000002,
                --     uid1 = 28000002,
                --     serverId2 = 0,
                --     uid2 = 222,
                --     name1 = '忠诚的琼华',
                -- }
                -- self:setActionMsg(msg)
                self:responseBtn(function()
                    self.matched = true
                    self.matchBgImg:setVisible(true)
                    CountryWarMgr:matchEnemy(self.bgImg1,self.cityId,tab[i],function()
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
        fangdaBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                CountryWarMgr:showCountryWarCityPlayerInfo(tab[i])
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

    self.chatBgImg1 = self.bgImg1:getChildByName('chat_bg_img_1')
    self.chatBgImg1:setLocalZOrder(10)
    self.chatBgImg1:setCascadeOpacityEnabled(true)
    self.chatBgImg1:setOpacity(0)
    self.chatSv1 = self.chatBgImg1:getChildByName('sv')
    self.chatSv1:setScrollBarEnabled(false)

    reliveBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.battled then
                CountryWarMgr:cleanUpCooltime(function()
                    self.timeBgImg:setVisible(false)
                    self.battled = false
                    self:updatePanel()
                    self:battleCoolingTime()
                end)
            end
        end
    end)

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


    local mainRole = RoleData:getMainRole()
    local obj = RoleData:getHeadPicObj(UserData:getUserObj().headpic)
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    self.bgImg1:addChild(headpicCell.awardBgImg)
    headpicCell.awardBgImg:loadTexture(mainRole:getBgImg())
    headpicCell.awardImg:loadTexture(obj:getIcon())
    headpicCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
    headpicCell.headframeImg:setVisible(true)
    headpicCell.lvTx:setString(UserData:getUserObj():getLv())
    headpicCell.addImg:loadTexture('uires/ui/common/arrow7.png')
    headpicCell.addImg:ignoreContentAdaptWithSize(true)
    headpicCell.addImg:setVisible(true)
    local size = headpicCell.awardBgImg:getContentSize()
    headpicCell.addImg:setPosition(cc.p(size.width/2,-15))
    self.awardBgImg = headpicCell.awardBgImg
    self.awardBgImg:setScale(0.7)
    self.awardBgImg:setLocalZOrder(4)

    local size = bgImg:getContentSize()
    local size1 = dartBtn:getContentSize()
    bgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    bgImg1:setPosition(cc.p(size.width/2, size.height/2))
    closeBtn:setPosition(cc.p(winSize.width - 15,winSize.height - 35))
    retreatBtn:setPosition(cc.p(winSize.width- size1.width/2*3,size1.height/2))
    dartBtn:setPosition(cc.p(winSize.width- size1.width/2,size1.height/2))
    logBtn:setPosition(cc.p(winSize.width- size1.width/2*5,size1.height/2))
    moveBtn:setPosition(cc.p(winSize.width- size1.width/2*7,size1.height/2))
    self.matchBgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.timeBgImg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.leftPl:setPosition(cc.p(0, winSize.height/2*1.2))
    self.chatBgImg1:setPosition(cc.p(winSize.width - 10,size1.height))

    self:runLeftPlAction()
    self:updatePanel()
    self:battleCoolingTime()
    -- self:createAllLegion()
    self:updateCountryWarMatchPlayers()
end

return CountryWarMatchUI