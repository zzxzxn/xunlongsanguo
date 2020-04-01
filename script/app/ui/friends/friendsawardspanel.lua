--===============================================================
-- 好友排行奖励展示界面
--===============================================================
local FriendsAwardsPanelUI = class("FriendsAwardsPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function FriendsAwardsPanelUI:ctor()
  self.uiIndex = GAME_UI.UI_FRIENDS_AWARDS_PANEL
  
end

function FriendsAwardsPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local alphabg = bgimg1:getChildByName('bg_img1')
    local bgimg2 = alphabg:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsAwards()
        end
    end)
    self:adaptUI(bgimg1, alphabg)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_15'))

    local friendsbg = bgimg2:getChildByName('friends_bg')
    self.friendsbg = friendsbg
    self.timedesctx = friendsbg:getChildByName('friends_rank_desc')
    --self.timedesctx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_25'))

    local serverTime = GlobalData:getServerTime()
    local now = Time.date('*t',serverTime)
    local wday = tonumber(Time.date('%w', serverTime))      -- 这个日期是周几
    if wday == 0 then
        wday = 7
    end

    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local time1 = Time.time({year = now.year, month = now.month, day = now.day, hour = resetHour, min = 0, sec = 0})
    local difftime = (8 - wday)*24*3600 - (GlobalData:getServerTime() - time1)
    self:timeoutCallback(difftime)

    self.timedesctx:setPositionX(self.timedesctx:getPositionX() + 220)

    self.sv = friendsbg:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    local awardsconf = GameData:getConfData('friendweek')
    self.num = #awardsconf
    for i,v in ipairs(awardsconf) do
        self:addCell(i)
    end
end

function FriendsAwardsPanelUI:timeoutCallback(difftime)
    if difftime <= 0 then
        return
    end

	local node = cc.Node:create()
    node:setPosition(cc.p(self.timedesctx:getPositionX() + 100,self.timedesctx:getPositionY()))
	node:setTag(9527)		 
	if self.friendsbg:getChildByTag(9527) then
        self.friendsbg:removeChildByTag(9527)
    end
	self.friendsbg:addChild(node)

    Utils:createCDLabel(node,difftime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.WHITE,
        CDTXTYPE.BACK,GlobalApi:getLocalStr('FRIENDS_DESC_25'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,22,function()
    end)
end

function FriendsAwardsPanelUI:addCell(index)
    local awardsconf = GameData:getConfData('friendweek')
    local node = cc.CSLoader:createNode("csb/friendsawardscell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local cellbg = ccui.Widget:create()
    cellbg:addChild(bgimg)

    local rankimg = bgimg:getChildByName('rank_img')
    local ranktx = bgimg:getChildByName('rank_tx')
    ranktx:setString('')
    if awardsconf[index]['rank'] <= 3 then
        rankimg:loadTexture("uires/ui/report/report_rank_" .. index .. ".png")
        rankimg:setVisible(true)
        ranktx:setVisible(false)
    else
        local str = ''
        if index > 1 then
            str = tostring(awardsconf[index-1]['rank']+1)..'-'..awardsconf[index]['rank']
        end
        if index > 1 and index == #awardsconf then
            str = tostring(awardsconf[index-1]['rank']..GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC4'))
        end
        rankimg:setVisible(false)
        ranktx:setVisible(true)
        ranktx:setString(str)
    end

    local disPlayData = DisplayData:getDisplayObjs(awardsconf[index]['award'])
    for i=1,4 do
        local node = bgimg:getChildByName('item_node_'..i)
        local awards = disPlayData[i]
        if awards then
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, bgimg)
            cell.lvTx:setString('x'..awards:getNum())
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
            cell.awardBgImg:setPosition(cc.p(node:getPosition()))
        end
    end
    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.sv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height/2
    cellbg:setPosition(cc.p(contentsize.width/2+10,posy))
    self.sv:addChild(cellbg)
    self.sv:scrollToTop(0.1,true)
end

return FriendsAwardsPanelUI