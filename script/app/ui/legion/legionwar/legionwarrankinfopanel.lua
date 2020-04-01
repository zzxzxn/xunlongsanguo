local LegionWarRankInfoUI = class("LegionWarRankInfoUI", BaseUI)

local SVHEIGHT = 1450
function LegionWarRankInfoUI:ctor(rankdata)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_RANKINFO
  	self.data = rankdata
    self.rankconf = GameData:getConfData('legionwarrank')
    self.rankcelltab = {}
end

function LegionWarRankInfoUI:init()
	local bgimg1 = self.root:getChildByName("bg")
	local bgimg2 = bgimg1:getChildByName('bg1')
	local closebtn = bgimg2:getChildByName('close')
	self:adaptUI(bgimg1, bgimg2)
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarRankInfoUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC63'))
       
    self.sv = bgimg2:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self.svbg = self.sv:getChildByName('bg_sv')
    self:addCells()
    self:update()
end
function LegionWarRankInfoUI:update()
    --self:addCells()
    local myscore = LegionMgr:getLegionWarData().ownLegion.score
    local rankid = LegionMgr:calcRank(myscore)
    local posy =  self.rankcelltab[rankid]:getPositionY()-60
    local percent = ((SVHEIGHT-posy)/SVHEIGHT)*100
    self.sv:scrollToPercentVertical(percent,1.0,true)
end
function LegionWarRankInfoUI:addCells()
    local cellhight = 102
    local cellwidth = 412
    for i = 1, #self.rankconf do
        local node = cc.CSLoader:createNode("csb/legion_war_rank_info_cell.csb")
        local bgimg = node:getChildByName("bg_img1")
        bgimg:removeFromParent(false)
        self.rankcelltab[i] = ccui.Widget:create()
        self.rankcelltab[i]:addChild(bgimg)
        local posx = ((i-1)%2)*(cellwidth+10) + cellwidth/2 - 20

        self.cellTotalHeight = i*(cellhight/2+14) --+ ((i-1)%2)*14
        self.rankcelltab[i]:setPosition(cc.p(posx, self.cellTotalHeight))
        self.svbg:addChild(self.rankcelltab[i])
        self:initcell(i)
    end

    self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width, SVHEIGHT))
    self.svbg:setContentSize(cc.size(self.sv:getContentSize().width, SVHEIGHT))
end
function LegionWarRankInfoUI:initcell(index)
    local bg = self.rankcelltab[index]:getChildByName("bg_img1")
    local arrowimg = bg:getChildByName('arrow_img')
    local globalsvdesc = bg:getChildByName('desc_tx1')
    globalsvdesc:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC64'))
    local localsvdesc = bg:getChildByName('desc_tx2')
    localsvdesc:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC65'))
    local globalsvnum = bg:getChildByName('num_tx1')
    local localsvnum = bg:getChildByName('num_tx2')
    local name = bg:getChildByName('name_tx')
    local scorenum = bg:getChildByName('score_tx')
    local icon = bg:getChildByName('icon_img')
    local iconlv = icon:getChildByName('lv_tx')
    local scoreimg = bg:getChildByName('score_img')

    name:setString(self.rankconf[index].name)
    iconlv:setString(tostring((self.rankconf[index].id-1)%3 + 1))
    icon:loadTexture('uires/ui/legionwar/legionwar_'..tostring(self.rankconf[index].icon))
    scorenum:setString(self.rankconf[index].minScore..'-'..self.rankconf[index].maxScore)
    if index%2 ==0 then
        arrowimg:setScaleX(-1)
        arrowimg:setPosition(cc.p(-36,84))
    end
    globalsvnum:setString('0')
    localsvnum:setString('0')
    for k,v in pairs(self.data.global) do
        if tostring(index) == k then
            globalsvnum:setString(v)          
        end 
    end
    for k,v in pairs(self.data['local']) do
        if tostring(index) == k then
            localsvnum:setString(v)
        end 
    end
    local myscore = LegionMgr:getLegionWarData().ownLegion.score
    local rankid = LegionMgr:calcRank(myscore)
    if index == #self.rankconf then
        arrowimg:setVisible(false)
    end
    if index <= rankid then
        ShaderMgr:restoreWidgetDefaultShader(icon)
        ShaderMgr:restoreWidgetDefaultShader(bg)
        ShaderMgr:restoreWidgetDefaultShader(scoreimg)
        arrowimg:loadTexture('uires/ui/common/arrow12.png')
        name:enableOutline(COLOROUTLINE_TYPE.PALE,2)
        globalsvdesc:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
        localsvdesc:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
        globalsvnum:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
        localsvnum:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
        scorenum:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
        iconlv:enableOutline(COLOROUTLINE_TYPE.WHITE,1)

        globalsvdesc:setColor(cc.c4b(237,236,191,255))
        localsvdesc:setColor(cc.c4b(237,236,191,255))
        globalsvnum:setColor(cc.c4b(255,247,228,255))
        localsvnum:setColor(cc.c4b(255,247,228,255))
        scorenum:setColor(cc.c4b(237,236,191,255))
        iconlv:setColor(cc.c4b(255,247,228,255))
        if index == rankid then
            arrowimg:loadTexture('uires/ui/common/arrow13.png')
        end
    else
        ShaderMgr:setGrayForWidget(icon)
        ShaderMgr:setGrayForWidget(bg)
        ShaderMgr:setGrayForWidget(scoreimg)
        arrowimg:loadTexture('uires/ui/common/arrow13.png')
        name:enableOutline(COLOROUTLINE_TYPE.GRAY1,2)
        globalsvdesc:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        localsvdesc:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        globalsvnum:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        localsvnum:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        scorenum:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        iconlv:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)

        globalsvdesc:setColor(COLOR_TYPE.WHITE)
        localsvdesc:setColor(COLOR_TYPE.WHITE)
        globalsvnum:setColor(COLOR_TYPE.WHITE)
        localsvnum:setColor(COLOR_TYPE.WHITE)
        scorenum:setColor(COLOR_TYPE.WHITE)
        iconlv:setColor(COLOR_TYPE.WHITE)
    end
end

return LegionWarRankInfoUI