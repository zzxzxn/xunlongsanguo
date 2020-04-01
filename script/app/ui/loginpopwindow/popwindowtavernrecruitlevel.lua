local PopWindowTavernRecruitLevelUI = class("PopWindowTavernRecruitLevelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function PopWindowTavernRecruitLevelUI:ctor(data)
    self.data = data
    self:init()
end

function PopWindowTavernRecruitLevelUI:init()
    local node = cc.CSLoader:createNode("csb/pop_window_tavern_recruit_level.csb")
    local bgImg = node:getChildByName("bg")
    bgImg:removeFromParent(false)
    self.bgImg = bgImg

    local bgImg1 = bgImg:getChildByName("bg_img1")
    local bgImg2 = bgImg1:getChildByName("bg_img2")
    local bgImg3 = bgImg2:getChildByName("bg_img3")
	
    local time = ActivityMgr:getActivityTime("tavern_recruit_level")
    if time > 0 then
        local time_desc = bgImg3:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_16'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 55,time_desc:getPositionY()))
        bgImg3:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,22)
    end

    local centerImg = bgImg3:getChildByName('center_img')
    local gotoBtn = centerImg:getChildByName('goto_btn')
    gotoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('POP_WINDOW_DES3'))
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ActivityMgr:showActivityPage('tavern_recruit_level')
        end
    end)

    local frame = bgImg3:getChildByName('frame')
    frame:setVisible(false)
    local bottomImg = bgImg3:getChildByName('bottom_img')
    local sv = bottomImg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local avTavernRecruitFrequencyConf = GameData:getConfData('avtavernrecruitfrequency')
    local awardData = avTavernRecruitFrequencyConf[1].awards
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local num = #disPlayData
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 15
    local WIDTH = 80.84
    local width = num * WIDTH + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = WIDTH
    for i = 1,num,1 do
        local tempCell = frame:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

        local awards = disPlayData[i]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,tempCell)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.awardBgImg:loadTexture(awards:getBgImg())
        cell.chipImg:setVisible(true)
        cell.chipImg:loadTexture(awards:getChip())
        cell.lvTx:setString('x'..awards:getNum())
        cell.lvTx:setVisible(false)
        cell.awardImg:loadTexture(awards:getIcon())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

    end
    innerContainer:setPositionX(0)

    local layout = ccui.Layout:create()
	layout:setContentSize(cc.size(100, 30))

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES15'), 40, COLOR_TYPE.WHITE)
    re1:setStroke(COLOR_TYPE.RED,2)
    re1:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('POP_WINDOW_DES16'), 40, COLOR_TYPE.WHITE)
    re2:setStroke(cc.c4b(78,49,17,255),2)
    re2:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
    re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(252,260))
    richText:format(true)
    bgImg3:addChild(richText)
end

function PopWindowTavernRecruitLevelUI:getPanel()
    return self.bgImg
end
            
return PopWindowTavernRecruitLevelUI