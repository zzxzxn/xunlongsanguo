local PatrolAwardsUI = class("PatrolAwardsUI", BaseUI)

local COLOR_FONT = {
    [1] = 'WHITE',
    [2] = 'GREEN',
    [3] = 'BLUE',
    [4] = 'PURPLE',
    [5] = 'ORANGE',
    [6] = 'ORANGE',
    [7] = 'ORANGE',
}

function PatrolAwardsUI:ctor(awards,time)
    self.uiIndex = GAME_UI.UI_PATROL_AWARDS
    -- self.awards = DisplayData:getDisplayObjs(awards)
    self.time = time
    self:sortAwards(awards)
end

function PatrolAwardsUI:sortAwards(awards)
    local awardsTab = DisplayData:getDisplayObjs(awards)
    local tab = {}
    local tab1 = {}
    for i,v in ipairs(awardsTab) do
        local ntype = v:getType()
        local id = v:getId()
        if ntype == 'user' then
            if not tab[id] then
                tab[id] = {1,v:getNum(),v:getName()}
            else
                tab[id] = {1,(tab[id][2] or 0) + v:getNum(),v:getName()}
            end
        elseif ntype == 'equip' then
            local q = v:getQuality()
            if not tab1[q] then
                tab1[q] = {q,1}
            else
                tab1[q] = {q,(tab1[q][2] or 0) + 1}
            end
        end
    end
    self.awardsInfo =tab
    self.awardsInfo1 =tab1
    self.num = #awardsTab
end

function PatrolAwardsUI:updatePanel()
    self.tab = {}
    local diffTime = 0
    if self.time then
        diffTime = self.time
    else
        diffTime = GlobalData:getServerTime() - MapData.patrol
    end
    if MapData.patrol == 0 then
        diffTime = 3600
    end
    if diffTime > tonumber(GlobalApi:getGlobalValue('patrolMaxTime')) then
        diffTime = tonumber(GlobalApi:getGlobalValue('patrolMaxTime'))
    end
    local h = math.floor(diffTime/3600)
    local m = math.floor((diffTime%3600)/60)
    local s = math.floor(diffTime%60)
    -- local str = string.format(GlobalApi:getLocalStr('ON_HOOK_AWARDS'),h,m,s)
    -- self.timeTx:setString(str)
    -- self.rts = {richText = richText,re1 = re1,re3 = re3,re5 = re5}
    self.rts.re1:setString(h)
    self.rts.re3:setString(m)
    self.rts.re5:setString(s)
    self.rts.richText:format(true)

    local index = 0
    local sizeX = 0
    local function createCell(q,name,num)
        local cellNode = cc.CSLoader:createNode("csb/onhookcell.csb")
        local awardsBgImg = cellNode:getChildByName('award_bg_img')
        local bgImg = awardsBgImg:getChildByName('bg_img')
        local nameTx = awardsBgImg:getChildByName('name_tx')
        local numTx = awardsBgImg:getChildByName('num_tx')
        bgImg:loadTexture('uires/ui/expedition/expedition_equip_'..q..'.png')
        nameTx:setString(name)
        nameTx:setColor(COLOR_TYPE[COLOR_FONT[q]])
        nameTx:enableOutline(COLOROUTLINE_TYPE[COLOR_FONT[q]], 1)
        nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        numTx:setString(num)

        awardsBgImg:removeFromParent(false)
        local size = awardsBgImg:getContentSize()
        sizeX = size.width + 30
        awardsBgImg:setPosition(cc.p((index - 1)*sizeX + size.width/2 + 15,size.height/2))
        self.cellSv:addChild(awardsBgImg)
        self.tab[#self.tab + 1] = {GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..name..'x'..num,COLOR_FONT[q]}

        local time = 0.025
        awardsBgImg:setScale(0.2)
        -- awardsBgImg:runAction(cc.RepeatForever:create(cc.Sequence:create(
        --     cc.ScaleTo:create(time*11,1.2),
        --     cc.ScaleTo:create(time*4,0.8),
        --     cc.ScaleTo:create(time*3*0.9,1.1),
        --     cc.ScaleTo:create(time*2*0.8,0.9),
        --     cc.ScaleTo:create(time*1*0.7,1)
        --     )))
        awardsBgImg:runAction(cc.Sequence:create(
            cc.ScaleTo:create(time*10,1.2),
            cc.ScaleTo:create(time*4,0.8),
            cc.ScaleTo:create(time*3*0.9,1.1),
            cc.ScaleTo:create(time*2*0.8,0.9),
            cc.ScaleTo:create(time*1*0.7,1)
            ))
    end
    for k,v in pairs(self.awardsInfo) do
        index = index + 1
        if k == 'gold' then
            createCell(6,v[3],v[2])
        else
            createCell(7,v[3],v[2])
        end
    end
    for i,v in ipairs(self.awardsInfo1) do
        index = index + 1
        local name = GlobalApi:getLocalStr('COLOR_EQUIP_'..v[1])
        createCell(v[1],name,v[2])
    end

    local size = self.cellSv:getContentSize()
    if index * sizeX > size.width then
        self.cellSv:setInnerContainerSize(cc.size(index * sizeX,size.height))
    else
        self.cellSv:setInnerContainerSize(size)
    end
end

function PatrolAwardsUI:init()
    local awardsBgImg = self.root:getChildByName("award_bg_img")
    local awardsImg = awardsBgImg:getChildByName("award_img")
    self:adaptUI(awardsBgImg, awardsImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    awardsImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

    local okBtn = awardsImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hidePatrolAwardsPanel()
            local showWidgets = {}
            for i,v in ipairs(self.tab) do
                local w = cc.Label:createWithTTF(v[1], 'font/gamefont.ttf', 25)
                w:setColor(COLOR_TYPE[v[2]])
                w:enableOutline(COLOROUTLINE_TYPE[v[2]], 1)
                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                table.insert(showWidgets, w)
            end
            promptmgr:showAttributeUpdate(showWidgets)
        end
    end)

    local gotoBtn = awardsImg:getChildByName('goto_btn')
    local infoTx = gotoBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('GOTO_FUSION'))
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hidePatrolAwardsPanel()
            BagMgr:showFusion()
        end
    end)

    local neiBgImg = awardsImg:getChildByName('nei_bg_img')
    self.cellSv = neiBgImg:getChildByName('cell_sv')
    self.cellSv:setScrollBarEnabled(false)
    -- self.timeTx = neiBgImg:getChildByName('time_tx')

    local richText = xx.RichText:create()
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(680, 40))
    local re1 = xx.RichTextLabel:create('', 28, COLOR_TYPE.WHITE)
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_HOUR'), 28, COLOR_TYPE.WHITE)
    re2:setFont('font/gamefont.ttf')
    local re3 = xx.RichTextLabel:create('', 28, COLOR_TYPE.WHITE)
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_MINUTE'), 28, COLOR_TYPE.WHITE)
    re4:setFont('font/gamefont.ttf')
    local re5 = xx.RichTextLabel:create('', 28, COLOR_TYPE.WHITE)
    local re6 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_SECOND'), 28, COLOR_TYPE.WHITE)
    re6:setFont('font/gamefont.ttf')
    re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re4:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re5:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re6:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:addElement(re5)
    richText:addElement(re6)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(455,-33))
    neiBgImg:addChild(richText)
    self.rts = {richText = richText,re1 = re1,re3 = re3,re5 = re5}

    self:updatePanel()
end

return PatrolAwardsUI