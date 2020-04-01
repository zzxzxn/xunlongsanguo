local LuckyWheelRankUI = class("LuckyWheelRankUI", BaseUI)
local WIDTH = 776
local HEIGHT = 80
local ClassItemCell = require('script/app/global/itemcell')
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

function LuckyWheelRankUI:ctor(msg)
    self.uiIndex = GAME_UI.UI_LUCKY_WHEEL_RANK
    self.msg = msg
    self:initData()
end

function LuckyWheelRankUI:initData()
    self.conf = GameData:getConfData('avluckywheelrank')
end

-- 初始化
function LuckyWheelRankUI:init()
    local bg = self.root:getChildByName("bg")
	local bg1 = bg:getChildByName("bg1")
	self:adaptUI(bg, bg1)

    local closeBtn = bg1:getChildByName("close")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			self:hideUI()
	    end
	end)

    local titleBg = bg1:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES14'))

    local topTx = bg1:getChildByName("top_tx")
    topTx:setString(string.format(GlobalApi:getLocalStr("ACTIVE_LUCKY_WHEEL_DES15"),tonumber(GlobalApi:getGlobalValue('luckyWheelRankRequire'))))
    
    local bottomTx = bg1:getChildByName("bottom_tx")
    bottomTx:setString(GlobalApi:getLocalStr('ACTIVE_LUCKY_WHEEL_DES16'))

    -- sv
    local bgSv = bg1:getChildByName('bg_sv')
    local sv = bgSv:getChildByName('sv')
	sv:setScrollBarEnabled(false)
    self.sv = sv
    self:refreshScrollView()
end

function LuckyWheelRankUI:refreshScrollView()
    self.viewSize = self.sv:getContentSize() -- 可视区域的大小
	self:initListView()
end

function LuckyWheelRankUI:initListView()
    self.cellSpace = 4
    self.allHeight = 0
    self.cellsData = {}

    local allNum = 50
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace

    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.sv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil)
    else
        self.scrollViewGeneral:resetScrollView(self.sv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil)
    end
end

function LuckyWheelRankUI:initItemData(index)
    local w = WIDTH
    local h = HEIGHT

    self.allHeight = h + self.allHeight
    local tempCellData = {}
    tempCellData.index = index
    tempCellData.h = h
    tempCellData.w = w

    table.insert(self.cellsData,tempCellData)
end

function LuckyWheelRankUI:addItem(tempCellData,widgetItem)
    local msg = self.msg
    local index = tempCellData.index

    local cell = self:getCell(index,msg[index])

    local w = tempCellData.w
    local h = tempCellData.h

    widgetItem:addChild(cell)
    cell:setPosition(cc.p(0,0))
end

function LuckyWheelRankUI:getCell(i,data)
    local widget = ccui.Widget:create()

    local bg = ccui.ImageView:create("uires/ui/common/common_bg_24.png")
    bg:setAnchorPoint(cc.p(0.5,0.5))
	bg:setCapInsets(cc.rect(120, 33, 33, 32))
	bg:setScale9Enabled(true)
	bg:setContentSize(cc.size(WIDTH, HEIGHT))
    bg:setPosition(cc.p(WIDTH/2,HEIGHT/2))
    widget:addChild(bg)

    -- 名次图片
	local rankImg = ccui.ImageView:create()
	rankImg:ignoreContentAdaptWithSize(true)
	rankImg:setPosition(cc.p(53, HEIGHT/2))
	bg:addChild(rankImg)

    -- 名次label
	local rankLabel = cc.LabelAtlas:_create("", "uires/ui/number/rlv3num.png", 31, 41, string.byte('0'))
	rankLabel:setAnchorPoint(cc.p(0.5, 0.5))
	rankLabel:setPosition(cc.p(53, HEIGHT/2))
	bg:addChild(rankLabel)

    if i <= 3 then
		rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. i .. ".png")
		rankImg:setVisible(true)
		rankLabel:setVisible(false)
	else
		rankImg:setVisible(false)
		rankLabel:setVisible(true)
		rankLabel:setString(tostring(i))
	end

    -- vip等级
    if data then
	    local vipImg = ccui.ImageView:create()
	    vipImg:ignoreContentAdaptWithSize(true)
	    bg:addChild(vipImg)
	    local vipLabel = cc.LabelAtlas:_create(data.vip, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	    vipLabel:setAnchorPoint(cc.p(0, 0.5))
	    vipImg:addChild(vipLabel)
	    vipLabel:setPosition(cc.p(50, 11.5))

        vipImg:loadTexture("uires/ui/rech/rech_vip_small.png")
        vipImg:setPosition(cc.p(180, HEIGHT/2 + 15))

        -- 名字,uid除以100万就是区服
        local richText = xx.RichText:create()
        richText:setName(richTextName)
	    richText:setContentSize(cc.size(500, 40))

        local server = 'S' .. math.floor(data.uid/1000000) .. '.'
	    local re1 = xx.RichTextLabel:create(server, 22, COLOR_TYPE.YELLOW)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        --re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create(data.name, 22, COLOR_TYPE.WHITE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        --re2:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))

        bg:addChild(richText)
        richText:setPosition(cc.p(180 + vipLabel:getContentSize().width/2 + 1,HEIGHT/2 - 25))
        richText:format(true)

        -- 分数
        local nameLabel = cc.Label:createWithTTF(data.score, "font/gamefont.ttf", 25)
	    nameLabel:setTextColor(cc.c4b(102, 51, 0, 255))
	    --nameLabel:enableOutline(cc.c4b(110, 71, 48, 255), 1)
	    --:enableShadow(cc.c4b(110, 71, 48, 255), cc.size(0, -1))
	    nameLabel:setPosition(cc.p(330, HEIGHT/2))
	    bg:addChild(nameLabel)
    else
        local richText = xx.RichText:create()
        richText:setName(richTextName)
	    richText:setContentSize(cc.size(500, 40))

	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("ACTIVE_LUCKY_WHEEL_DES19"), 25, COLOR_TYPE.WHITE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        --re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))

        bg:addChild(richText)
        richText:setPosition(cc.p(260,HEIGHT/2))
        richText:format(true)

    end


    -- 奖励,从右向左
    local baseWidht = WIDTH - 50
    --local pos = {{baseWidht,HEIGHT/2},{baseWidht - 94 ,HEIGHT/2},{baseWidht - 94 * 2,HEIGHT/2}}
    local pos = {{baseWidht - 94 * 3,HEIGHT/2},{baseWidht - 94 * 2,HEIGHT/2},{baseWidht - 94 ,HEIGHT/2},{baseWidht,HEIGHT/2}}

    local confData = self.conf[i]

    if i >= 4 and i <= 10 then
        confData = self.conf[10]
    elseif i >= 11 and i <= 30 then
        confData = self.conf[30]
    elseif i >= 31 and i <= 50 then
        confData = self.conf[50]
    end

    if confData then
        local awardData = confData.award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        for j = 1,#disPlayData do
            local awards = disPlayData[j]
            if awards then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, bg)
                cell.awardBgImg:setScale(68/94)
                cell.awardBgImg:setPosition(cc.p(pos[j][1],pos[j][2]))
                cell.lvTx:setString('x'..awards:getNum())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            end
        end
    end
    return widget
end

return LuckyWheelRankUI