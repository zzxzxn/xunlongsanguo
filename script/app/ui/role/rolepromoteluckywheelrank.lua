local RolePromoteLuckyWheelRankUI = class("RolePromoteLuckyWheelRankUI", BaseUI)
local WIDTH = 805
local HEIGHT = 80
local ClassItemCell = require('script/app/global/itemcell')
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")

function RolePromoteLuckyWheelRankUI:ctor(msg,startTime,endTime)
    self.uiIndex = GAME_UI.UI_ROLE_PROMOTED_LUCKY_WHEEL_RANK_PANEL
    self.msg = msg
    self.startTime = startTime
    self.endTime = endTime
    self:initData()
end

function RolePromoteLuckyWheelRankUI:initData()
    self.conf = GameData:getConfData('promoterankred')
end

-- 初始化
function RolePromoteLuckyWheelRankUI:init()
    local bg = self.root:getChildByName("bg")
	local bg1 = bg:getChildByName("bg1")
	self:adaptUI(bg, bg1)

    local closeBtn = bg1:getChildByName("close")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			RoleMgr:hideRolePromotedLuckyWheelRank()
	    end
	end)

    local titleBg = bg1:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr('ROLE_DESC33'))

    local topTx = bg1:getChildByName("top_tx")
    topTx:setFontSize(19)
    topTx:setPositionY(topTx:getPositionY() - 2)
    --topTx:setString(string.format(GlobalApi:getLocalStr("REFRESH_TIME2"),tonumber(1)))
    
    local startTime = self.startTime
    local endTime = self.endTime
    local nowTime = Time.getCorrectServerTime()
    local time = endTime - nowTime 
    if time > 0 then
        local node = cc.Node:create()
        node:setPosition(cc.p(172,topTx:getPositionY()))
        bg1:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.GREEN,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.BLACK,20)

        topTx:setString(GlobalApi:getLocalStr('ROLE_DESC35'))
    end

    local bottomTx = bg1:getChildByName("bottom_tx")
    bottomTx:setString(string.format(GlobalApi:getLocalStr("ROLE_DESC34"),tonumber(GlobalApi:getGlobalValue('promoteRedRankRestrict'))))

    local topbg = bg1:getChildByName('top_bg')
    self:initself(topbg,self.msg)
    -- sv
    local bgSv = bg1:getChildByName('bg_sv')
    local sv = bgSv:getChildByName('sv')
	sv:setScrollBarEnabled(false)
    self.sv = sv
    self:refreshScrollView()
end

function RolePromoteLuckyWheelRankUI:refreshScrollView()
    self.viewSize = self.sv:getContentSize() -- 可视区域的大小
	self:initListView()
end

function RolePromoteLuckyWheelRankUI:initListView()
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

function RolePromoteLuckyWheelRankUI:initItemData(index)
    local w = WIDTH
    local h = HEIGHT

    self.allHeight = h + self.allHeight
    local tempCellData = {}
    tempCellData.index = index
    tempCellData.h = h
    tempCellData.w = w

    table.insert(self.cellsData,tempCellData)
end

function RolePromoteLuckyWheelRankUI:addItem(tempCellData,widgetItem)
    local msg = self.msg.rank_list
    local index = tempCellData.index

    local cell = self:getCell(index,msg[index])

    local w = tempCellData.w
    local h = tempCellData.h

    widgetItem:addChild(cell)
    cell:setPosition(cc.p(0,0))
end

function RolePromoteLuckyWheelRankUI:getCell(i,data)
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
        local nameLabel = cc.Label:createWithTTF(data.score, "font/gamefont.ttf", 22)
	    nameLabel:setTextColor(cc.c4b(102, 51, 0, 255))
	    --nameLabel:enableOutline(cc.c4b(110, 71, 48, 255), 1)
	    --:enableShadow(cc.c4b(110, 71, 48, 255), cc.size(0, -1))
	    nameLabel:setPosition(cc.p(WIDTH/2, HEIGHT/2-10))
	    bg:addChild(nameLabel)
    else
        local richText = xx.RichText:create()
        richText:setName(richTextName)
	    richText:setContentSize(cc.size(500, 40))

	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr("ROLE_DESC36"), 22, cc.c4b(230,210,160))
	    --re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        --re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0.5,0.5))

        bg:addChild(richText)
        richText:setPosition(cc.p(260,HEIGHT/2-10))
        richText:format(true)

    end


    -- 奖励,从右向左
    local baseWidht = WIDTH - 50
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

function RolePromoteLuckyWheelRankUI:initself(parent,data)
    --if data then
    local vipImg = parent:getChildByName('vip_img')

    local vipLabel = parent:getChildByName('vip_al')
    vipLabel:setString(UserData:getUserObj():getVip())

    local nametx = parent:getChildByName('name_tx')
    -- 名字,uid除以100万就是区服
    local richText = xx.RichText:create()
    richText:setName(richTextName)
    richText:setContentSize(cc.size(500, 40))

    local server = 'S' .. math.floor(UserData:getUserObj():getUid()/1000000) .. '.'
    local re1 = xx.RichTextLabel:create(server, 22, COLOR_TYPE.YELLOW)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    --re1:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

    local re2 = xx.RichTextLabel:create(UserData:getUserObj():getName(), 22, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    --re2:setShadow(cc.c4b(239, 219, 176, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:setAnchorPoint(cc.p(0.5,0.5))

    nametx:addChild(richText)
    richText:setPosition(cc.p(20,0))
    richText:format(true)

    -- 分数
    local scoretx = parent:getChildByName('tx')
    scoretx:setString(data.rank_score)

    local ranknum = self.msg.self_rank_num
    local confData= self.conf[ranknum]
    if ranknum < 1 then
        confData = nil
    elseif ranknum >= 4 and ranknum <= 10 then
        confData = self.conf[10]
    elseif ranknum >= 11 and ranknum <= 30 then
        confData = self.conf[30]
    elseif ranknum >= 31 and ranknum <= 50 then
        confData = self.conf[50]
    end

    if confData then
        local awardData = confData.award
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        for j = 1,#disPlayData do
            local awards = disPlayData[j]
            local node = parent:getChildByName('node_'..j)
            if awards then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, node)
                cell.awardBgImg:setScale(68/94)
                cell.lvTx:setString('x'..awards:getNum())
                local godId = awards:getGodId()
                awards:setLightEffect(cell.awardBgImg)
            end
        end 
    end

        -- 名次label
    local rankAl = parent:getChildByName("rank_al")
    local rankImg = parent:getChildByName('rank_img')
    local ranktx = parent:getChildByName('rank_tx')
    if ranknum > 0 and ranknum <= 3 then
        rankImg:loadTexture("uires/ui/rankinglist_v3/rlistv3_rank_" .. ranknum .. ".png")
        rankImg:setVisible(true)
        rankAl:setVisible(false)
        ranktx:setVisible(false)
    elseif ranknum > 3 and ranknum <= 50 then
        rankImg:setVisible(false)
        rankAl:setVisible(true)
        rankAl:setString(tostring(ranknum))
        ranktx:setVisible(false)
    else
        rankImg:setVisible(false)
        rankAl:setVisible(false)
        ranktx:setVisible(true)
        ranktx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_33'))
    end

end
return RolePromoteLuckyWheelRankUI