local TavernMasterUI = class("TavernMasterUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function TavernMasterUI:ctor(func,data)
	self.uiIndex = GAME_UI.UI_TAVERN_MASTER
    self.func = func
    self.data = data
end

function TavernMasterUI:init()
	local bgimg = self.root:getChildByName('bg')
	local bgimg1 = bgimg:getChildByName('bg1')
	self:adaptUI(bgimg, bgimg1)
    local closebtn = bgimg1:getChildByName('close')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TavernMgr:hideTavernMasterUI()
        end
    end)
    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('TRVEN_DESC_15'))
    local bgimg2 = bgimg1:getChildByName('bg_sv')
    self.sv = bgimg2:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self.contentWidget = ccui.Widget:create()
    self.contentWidget:setPosition(cc.p(339,380))
    self.sv:addChild(self.contentWidget)
    

    local funcbtn = bgimg1:getChildByName('fun_btn')
    local funcbtntx = funcbtn:getChildByName('func_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('TRVEN_DESC_16'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.func then
                TavernMgr:hideTavernMasterUI()
                self.func(0)
            end
        end
    end)
    local content = bgimg1:getChildByName('content')
    local selfframe = content:getChildByName('self_frame')
    self.rankimg = selfframe:getChildByName('rank_img')
    self.posimg = selfframe:getChildByName('pos_img')
    self.posimg:ignoreContentAdaptWithSize(true)
    self.postx = selfframe:getChildByName('pos_tx')
    self.myranktx = selfframe:getChildByName('my_rank_tx')
    self.myranktx:setString(GlobalApi:getLocalStr("STR_MY_RANK"))

    local headpicNode = selfframe:getChildByName('headpic_node')
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headpicNode:addChild(headpicCell.awardBgImg)
    headpicCell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
    headpicCell.awardBgImg:loadTexture(RoleData:getMainRole():getBgImg())
    headpicCell.lvTx:setString(UserData:getUserObj():getLv())
    headpicCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
    headpicCell.headframeImg:setVisible(true)
    local nametx = selfframe:getChildByName('name_tx')
    nametx:setString(UserData:getUserObj():getName())
    local rpal = selfframe:getChildByName('rp_al')
    rpal:setString(self.data.luck)
    local vipal = selfframe:getChildByName('vip_al')
    vipal:setString(UserData:getUserObj():getVip())
    self.rankal = selfframe:getChildByName('rank_al')

    self:update()
end

function TavernMasterUI:update()
    for i=1,#self.data.luck_list do
        self:addcell(i)
    end
    self.myranktx:setVisible(false)
    if self.data.rank == 0 then
        self.myranktx:setVisible(true)
        self.postx:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
    elseif self.data.rank == 1 then
        self.posimg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_1.png")
        self.postx:setString(GlobalApi:getLocalStr('TRVEN_DESC_18'))
        self.postx:setTextColor(COLOR_TYPE.ORANGE)
    elseif self.data.rank == 2 then
        self.posimg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_2.png")
        self.postx:setString(GlobalApi:getLocalStr('TRVEN_DESC_19'))
        self.postx:setTextColor(COLOR_TYPE.PURPLE)
    elseif self.data.rank == 3 then
        self.posimg:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_3.png")
        self.postx:setString(GlobalApi:getLocalStr('TRVEN_DESC_20'))
        self.postx:setTextColor(COLOR_TYPE.BLUE)
    else
        self.posimg:setVisible(false)
        self.rankimg:setVisible(true)
        self.rankal:setString(self.data.rank)
    end
end

function TavernMasterUI:addcell(index)
    local node = cc.CSLoader:createNode("csb/tavernmastercell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.contentsize = bgimg:getContentSize()
    local cell = ccui.Widget:create()
    cell:addChild(bgimg)

    local rankicon = bgimg:getChildByName('rank_icon')
    local ranktx = rankicon:getChildByName('rank_tx')
    local rankal = bgimg:getChildByName('rank_al')
    local headnode = bgimg:getChildByName('head_node')
    local nametx = bgimg:getChildByName('name_tx')
    local rpal = bgimg:getChildByName('rp_al')
    local vipal = bgimg:getChildByName('vip_al')
    local funcbtn = bgimg:getChildByName('fun_btn')
    local functx = funcbtn:getChildByName('func_tx')
    functx:setString(GlobalApi:getLocalStr('TRVEN_DESC_17'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.func then
                TavernMgr:hideTavernMasterUI()
                self.func(self.data.luck_list[index].uid)
            end
        end
    end)
    rankal:setVisible(false)
    rankicon:setVisible(true)
    if index == 1 then
        rankicon:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_1.png")
        ranktx:setString(GlobalApi:getLocalStr('TRVEN_DESC_18'))
        ranktx:setTextColor(COLOR_TYPE.ORANGE)
    elseif index == 2 then
        rankicon:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_2.png")
        ranktx:setString(GlobalApi:getLocalStr('TRVEN_DESC_19'))
        ranktx:setTextColor(COLOR_TYPE.PURPLE)
    elseif index == 3 then
        rankicon:loadTexture("uires/ui/rankinglist_v3/rlistv3_crown_3.png")
        ranktx:setString(GlobalApi:getLocalStr('TRVEN_DESC_20'))
        ranktx:setTextColor(COLOR_TYPE.BLUE)
    else
        rankicon:setVisible(false)
        rankal:setVisible(true)
        rankal:setString(index)
    end
    nametx:setString(self.data.luck_list[index].un)
    rpal:setString(self.data.luck_list[index].luck)
    vipal:setString(self.data.luck_list[index].vip)

    local tab = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    local obj = RoleData:getHeadPicObj(self.data.luck_list[index].headpic)
    tab.awardBgImg:setSwallowTouches(false)
    tab.awardImg:loadTexture(obj:getIcon())
    tab.awardBgImg:loadTexture(COLOR_FRAME[self.data.luck_list[index].quality])
    tab.lvTx:setString('Lv.'..self.data.luck_list[index].level)
    tab.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.data.luck_list[index].headframe))

    headnode:addChild(tab.awardBgImg)
    local posy = -(self.contentsize.height+3)*(index-1) - self.contentsize.height/2-5
    cell:setPosition(cc.p(0,posy))
    self.contentWidget:addChild(cell)
    if index*(self.contentsize.height+3) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,index*(self.contentsize.height+3)))
    end
    self.contentWidget:setPosition(cc.p(self.sv:getInnerContainerSize().width/2,self.sv:getInnerContainerSize().height))
end

return TavernMasterUI