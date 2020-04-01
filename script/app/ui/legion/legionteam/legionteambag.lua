local LegionTeamBagUI = class("LegionTeamBagUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionTeamBagUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONTEAMBAG
  self.data = data
  self.page = 1
  self.vol = self.data.hook_vol
end

function LegionTeamBagUI:updateRightPanel()
    local num = self.vol
    local maxH = math.ceil(num/4)
    local maxW = 4
    local size = self.rightSv:getContentSize()
    local size1
    local conf = GameData:getConfData('hookrepos')
    for i=1,num do
        local awardBgImg = self.rightSv:getChildByName('award_bg_'..i..'_img')
        if not awardBgImg then
            local tab = ClassItemCell:create()
            awardBgImg = tab.awardBgImg
            self.rightSv:addChild(awardBgImg)
        end
        size1 = awardBgImg:getContentSize()
        local awardImg = awardBgImg:getChildByName('award_img')
        local lvTx = awardBgImg:getChildByName('lv_tx')
        local chipimg = awardBgImg:getChildByName('chip_img')
        local awardTab = self.data.repos[i]
        if awardTab then
            local award = DisplayData:getDisplayObj(conf[tonumber(awardTab[2])].award[1])
            awardBgImg:loadTexture(award:getBgImg())
            awardImg:loadTexture(award:getIcon())
            awardImg:ignoreContentAdaptWithSize(true)
            if award:getObjType() == 'equip' then
                lvTx:setString('Lv.'..award:getLevel())
            else
                lvTx:setString('x'..award:getNum())
            end
            if award:getObjType() == "fragment" then
                chipimg:setVisible(true)
                chipimg:loadTexture(award:getChip())
            else
                chipimg:setVisible(false)
            end
            chipimg:ignoreContentAdaptWithSize(true)
        else
            awardImg:loadTexture('uires/ui/common/bg1_alpha.png')
            chipimg:loadTexture('uires/ui/common/bg1_alpha.png')
            lvTx:setString('')
        end
    end

    local diffSize = (size.width - size1.width*4)/5
    print(maxH * (size1.height + diffSize) , size.height)
    if size1 and maxH * (size1.height + diffSize) - diffSize > size.height then
        self.rightSv:setInnerContainerSize(cc.size(size.width,maxH * (size1.height + diffSize) - diffSize))
    else
        self.rightSv:setInnerContainerSize(size)
    end
    local size2 = self.rightSv:getInnerContainerSize()
    local function getPos(i,size1)
        local h = maxH - math.ceil(i/4)
        local w = 5 - ((i - 1)%4 + 1)
        -- print(diffSize*w + (w-0.5)*size1.width,(maxH - h + 0.5)*size1.height - (h - 1)*diffSize)
        return cc.p(diffSize*w + (w-0.5)*size1.width,(maxH - h)*size1.height - (h - 1)*diffSize)
    end
    for i=1,num do
        local awardBgImg = self.rightSv:getChildByName('award_bg_'..i..'_img')
        awardBgImg:setPosition(getPos(num - i + 1,size1))
    end
    local descTx = self.rightImg:getChildByName('desc_tx')
    local numTx = self.rightImg:getChildByName('num_tx')
    numTx:setString(#self.data.repos..'/'..num)
end

local function getTime(diffTime)
    local str = ''
    if diffTime > 86400 then
        str = string.format(GlobalApi:getLocalStr('DAY_AGO'),math.floor(diffTime/86400))
    elseif diffTime > 3600 then
        str = string.format(GlobalApi:getLocalStr('HOUR_AGO'),math.floor(diffTime/3600))
    elseif diffTime > 60 then
        str = string.format(GlobalApi:getLocalStr('MINUTE_AGO'),math.floor(diffTime/60))
    else
        str = string.format(GlobalApi:getLocalStr('SECOND_AGO'),diffTime)
    end
    return str
end

function LegionTeamBagUI:updateLeftPanel()
    local repos = self.data.repos
    local pl = self.leftImg:getChildByName('pl')
    pl:setVisible(self.page == 2)
    self.leftSv:setVisible(self.page == 1)
    local conf = GameData:getConfData('hookrepos')
    if self.page == 1 then
        local height = 28
        local size = self.leftSv:getContentSize()
        if #repos * height > size.height then
            self.leftSv:setInnerContainerSize(cc.size(size.width,#repos * height))
        else
            self.leftSv:setInnerContainerSize(size)
        end
        local size1 = self.leftSv:getInnerContainerSize()

        local descRT = self.leftSv:getChildByName('desc_rt')
        if descRT then
            descRT:removeFromParent()
        end
        descRT = xx.RichText:create()
        descRT:setContentSize(cc.size(350, height))
        descRT:setAlignment('left')
        descRT:setName('desc_rt')
        descRT:setAnchorPoint(cc.p(0,1))
        descRT:setPosition(cc.p(0,size.height))
        self.leftSv:addChild(descRT)

        for i=#repos,1,-1 do
            local awardTab = repos[i]
            local conf1 = conf[tonumber(awardTab[2])]
            local award = DisplayData:getDisplayObj(conf1.award[1])
            if i ~= #repos then
                local re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.WHITE)
                re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
                descRT:addElement(re1)
            end
            local diffTime = GlobalData:getServerTime() - awardTab[1]
            local str = getTime(diffTime)..string.format(conf1.desc,'张飞',award:getName()..'x'..award:getNum())
            xx.Utils:Get():analyzeHTMLTag(descRT,str)
        end
    else
        for i=1,6 do
            local award = DisplayData:getDisplayObj(conf[i].award[1])
            local roleBgImg = pl:getChildByName('role_bg_'..i..'_img')
            local bgImg = roleBgImg:getChildByName('bg_img')
            local awardBgImg = bgImg:getChildByName('award_bg_img')
            if not awardBgImg then
                local tab = ClassItemCell:create()
                awardBgImg = tab.awardBgImg
                awardBgImg:setPosition(cc.p(61.5,95))
                awardBgImg:setName('award_bg_img')
                bgImg:addChild(awardBgImg)
            end
            local awardImg = awardBgImg:getChildByName('award_img')
            local lvTx = awardBgImg:getChildByName('lv_tx')
            local nameTx = bgImg:getChildByName('name_tx')
            local chipimg = awardBgImg:getChildByName('chip_img')
            awardBgImg:loadTexture(award:getBgImg())
            awardImg:loadTexture(award:getIcon())
            awardImg:ignoreContentAdaptWithSize(true)
            if award:getObjType() == 'equip' then
                lvTx:setString('Lv.'..award:getLevel())
            else
                lvTx:setString('x'..award:getNum())
            end
            if award:getObjType() == "fragment" then
                chipimg:setVisible(true)
                chipimg:loadTexture(award:getChip())
            else
                chipimg:setVisible(false)
            end
            nameTx:setString(award:getName())
            nameTx:setColor(award:getNameColor())
            nameTx:enableOutline(award:getNameOutlineColor(),1)
            nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        end
    end
end

function LegionTeamBagUI:updatePanel()
    self:updateLeftPanel()
    self:updateRightPanel()
    -- printall(self.data)
    for i=1,2 do
        if i == self.page then
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
            self.pageBtns[i]:setTouchEnabled(false)
        else
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
            self.pageBtns[i]:setTouchEnabled(true)
        end
    end
end

function LegionTeamBagUI:init()
    local teamBgImg = self.root:getChildByName('team_bg_img')
    local teamImg = teamBgImg:getChildByName('team_img')
    self:adaptUI(teamBgImg, teamImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn = teamImg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionTeamBagUI()
        end
    end)
    local titleBgImg = teamImg:getChildByName('title_bg_img')
    local titleTx = titleBgImg:getChildByName('info_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC32'))
    self.leftImg = teamImg:getChildByName('left_img')
    self.leftSv = self.leftImg:getChildByName('left_sv')
    self.rightImg = teamImg:getChildByName('right_img')
    self.rightSv = self.rightImg:getChildByName('right_sv')
    self.leftSv:setScrollBarEnabled(false)
    self.rightSv:setScrollBarEnabled(false)

    self.rightImg:getChildByName('desc_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC33'))

    self.pageBtns = {}
    for i=1,2 do
        local btn = teamImg:getChildByName('page_'..i..'_btn')
        self.pageBtns[i] = btn
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:updatePanel()
            end
        end)
    end

    local addBtn = self.rightImg:getChildByName('get_btn')
    addBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC34'))
    addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:extendBag(function(vol)
                self.vol = vol or self.vol
                self:updatePanel()
            end)
        end
    end)
    self:updatePanel()
end

return LegionTeamBagUI