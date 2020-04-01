--===============================================================
-- 好友伤害排行界面
--===============================================================
local FriendsRankPanelUI = class("FriendsRankPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function FriendsRankPanelUI:ctor(msg)
    self.uiIndex = GAME_UI.UI_FRIENDS_RANK_PANEL
    self.msg = msg
end

function FriendsRankPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local alphabg = bgimg1:getChildByName('bg_img1')
    local bgimg2 = alphabg:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsRank()
        end
    end)
    self:adaptUI(bgimg1, alphabg)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_14'))

    local friendsBg = bgimg2:getChildByName('friends_bg')
    local selfinfoBg = friendsBg:getChildByName('selfinfo_bg')
    self.sv = friendsBg:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self:updateItem(nil,selfinfoBg)

    self:updateSV()
end


function FriendsRankPanelUI:updateSV()
    local num = #self.msg.rank_list
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local cellWidth = 748
    local cellHeight = 114

    local height = num * cellHeight + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = cellHeight
    for i = 1,num do
        local node = cc.CSLoader:createNode("csb/friendsrankcell.csb")
        local bgImg = node:getChildByName("bg_img")
        bgImg:removeFromParent(false)
        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        bgImg:setPosition(cc.p(cellWidth/2 + 12,allHeight - offset + cellHeight/2))
        self.sv:addChild(bgImg)
        self:updateItem(i,bgImg)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function FriendsRankPanelUI:updateItem(i,bgImg)
    local data = nil
    local rankNum = i
    if i == nil then
        local rank = {}
        rank.boss_score = self.msg.score or 0
        rank.level = UserData:getUserObj():getLv()
        rank.headpic = UserData:getUserObj().headpic
        rank.headframe = UserData:getUserObj():getHeadFrame()
        rank.name = UserData:getUserObj():getName()
        rank.vip = UserData:getUserObj():getVip()
        rank.fight_force = UserData:getUserObj():getFightforce()

        local frameBg = nil
        for k, v in pairs(RoleData:getRoleMap()) do   
            if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== true then    
                frameBg = v:getBgImg()
                break
            end 
        end
        if frameBg then
            rank.frameBg = frameBg
        end
        rank.quality = 1

        rankNum = self.msg.rank
        data = rank
    else
        data = self.msg.rank_list[i]
    end

    if not data then
        return
    end

    local rankimg = bgImg:getChildByName('rank_img')
    local ranktx = bgImg:getChildByName('rank_tx')
    ranktx:setString('')
    if rankNum <= 3 then
        rankimg:loadTexture("uires/ui/report/report_rank_" .. rankNum .. ".png")
        rankimg:setVisible(true)
        ranktx:setVisible(false)
    else
        rankimg:setVisible(false)
        ranktx:setVisible(true)
        ranktx:setString(rankNum)
    end

    if i == nil then
        local notRankTx = bgImg:getChildByName('not_rank_tx')
        if data.boss_score == 0 then
            rankimg:setVisible(false)
            ranktx:setVisible(false)
            if notRankTx then
                notRankTx:setVisible(true)
                notRankTx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_33'))
            end
        else
            if notRankTx then
                notRankTx:setVisible(false)
            end
        end
    end
    
    local headnode = bgImg:getChildByName('head_node')
    self:initHeadNode(headnode,data)

    local scoreDesc = bgImg:getChildByName('score_desc')
    scoreDesc:setString(GlobalApi:getLocalStr('FRIENDS_DESC_35'))

    local scoreNum = bgImg:getChildByName('score_num')
    scoreNum:setString(data.boss_score)
end

function FriendsRankPanelUI:initHeadNode(parent,arrdata)
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    if arrdata.frameBg then
        cell.awardBgImg:loadTexture(arrdata.frameBg)
    else
        cell.awardBgImg:loadTexture(COLOR_FRAME[arrdata.quality])
    end
    cell.lvTx:setString('Lv.'..arrdata.level)
    local obj = RoleData:getHeadPicObj(tonumber(arrdata.headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.awardImg:ignoreContentAdaptWithSize(true)
    cell.headframeImg:loadTexture(arrdata.headframe)
    cell.nameTx:setString('')
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(arrdata.name..' ', 24,COLOR_TYPE.WHITE)
    local rt2 = xx.RichTextImage:create("uires/ui/chat/chat_vip_small.png")
    local rt3 = xx.RichTextAtlas:create(arrdata.vip,"uires/ui/number/font_ranking.png", 20, 22, '0')
    rt:addElement(rt1)
    if tonumber(arrdata.vip) > 0 then
        rt:addElement(rt2)
        rt:addElement(rt3)
    end
    rt:setAlignment("left")
    rt:setVerticalAlignment('middle')
    rt:setPosition(cc.p(0, 0))
    rt:setContentSize(cc.size(400, 30))
    cell.nameTx:addChild(rt)
    cell.nameTx:setPosition(cc.p(100,70))

    local rtfightforce = xx.RichText:create()
    rtfightforce:setAnchorPoint(cc.p(0, 0.5))
    local rtfightforce1= xx.RichTextImage:create("uires/ui/common/fightbg.png")
    local rtfightforce2 = xx.RichTextAtlas:create(arrdata.fight_force,"uires/ui/number/font_fightforce_3.png", 26, 38, '0')
    rtfightforce:addElement(rtfightforce1)
    rtfightforce:addElement(rtfightforce2)
    rtfightforce:setAlignment("left")
    rtfightforce:setVerticalAlignment('middle')
    rtfightforce:setPosition(cc.p(0, -40))
    rtfightforce:setContentSize(cc.size(400, 30))
    rtfightforce:setScale(0.8)
    cell.nameTx:addChild(rtfightforce)
    cell.nameTx:setPosition(cc.p(100,70))

    parent:addChild(cell.awardBgImg)
end

return FriendsRankPanelUI