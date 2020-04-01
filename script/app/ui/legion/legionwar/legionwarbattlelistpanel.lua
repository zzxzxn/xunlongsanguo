local LegionWarBattleListUI = class("LegionWarBattleListUI", BaseUI)

function LegionWarBattleListUI:ctor(historydata)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_BATTLELIST
  	self.data = historydata
end

function LegionWarBattleListUI:init()
	local bgimg1 = self.root:getChildByName("bg_img")
	local bgimg2 = bgimg1:getChildByName('bg_img1')
	self:adaptUI(bgimg1, bgimg2)
	local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarBattleListUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC60'))

    local bgimg3 = bgimg2:getChildByName('bg_img2')   
    self.sv = bgimg3:getChildByName('sv_1')
    self.sv:setScrollBarEnabled(false)
    self.contentWidget = ccui.Widget:create()
    self.contentWidget:setPosition(cc.p(342,448))
    self.sv:addChild(self.contentWidget)
    self.noimg = bgimg3:getChildByName('no_img')
    self:update()
end

function LegionWarBattleListUI:update()
    self.dataarr = {}
    for k,v in pairs(self.data) do
        local tab = {}
        tab[1] = v.time
        tab[2] = v
        table.insert(self.dataarr,tab)
    end
    table.sort( self.dataarr,function (a,b)
        return a[1] > b[1]
    end)
    self.num = #self.dataarr
    for i=1,self.num do
        self:addCells(i,self.dataarr[i])
    end 
    if self.num == 0 then
        self.noimg:setVisible(true)
    else
        self.noimg:setVisible(false)
    end
end
function LegionWarBattleListUI:addCells(index,celldata)
    local node = cc.CSLoader:createNode("csb/legion_war_battlelist_cell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.contentsize = bgimg:getContentSize()
    local cell = ccui.Widget:create()
    cell:addChild(bgimg)
    self.num = self.num + 1
    local bluebg = bgimg:getChildByName('blue_bg')
    local legionflag1 = bluebg:getChildByName('legion_flag_1_img')
    legionflag1:loadTexture('uires/ui/legion/legion_'..celldata[2].own.icon..'_jun.png')
    local legionflag2 = bluebg:getChildByName('legion_flag_2_img')
    legionflag2:loadTexture('uires/ui/legion/legion_'..celldata[2].enemy.icon..'_jun.png')
    local legionnametx1 = bluebg:getChildByName('legion_name_1_tx')
    legionnametx1:setString(celldata[2].own.name)
    local legionnametx2 = bluebg:getChildByName('legion_name_2_tx')
    legionnametx2:setString(celldata[2].enemy.name)
    local legionqutx1 = bluebg:getChildByName('legion_qu_1_tx')
    legionqutx1:setString(celldata[2].own.sid..GlobalApi:getLocalStr('FU'))
    local legionqutx2 = bluebg:getChildByName('legion_qu_2_tx')
    legionqutx2:setString(celldata[2].enemy.sid..GlobalApi:getLocalStr('FU'))
    local legionscore1 = bluebg:getChildByName('score_1_tx')
    legionscore1:setString(celldata[2].own.score)
    local legionscore2 = bluebg:getChildByName('score_2_tx')
    legionscore2:setString(celldata[2].enemy.score)
    local dattx = bluebg:getChildByName('day_tx')
    dattx:setString(GlobalApi:toStringTime(tonumber(celldata[1]),'YMD'))
    local myscore = bluebg:getChildByName('my_score_tx')
    myscore:setString('')
    local fightbg = bluebg:getChildByName('fight_bg')
    local wlimg = fightbg:getChildByName('wl_img')
    if celldata[2].own.win == true then
        wlimg:loadTexture('uires/ui/worldwar/worldwar_red_victory.png')
    else
        wlimg:loadTexture('uires/ui/legionwar/legionwar_bai.png')
    end

    local posy = -(self.contentsize.height)*(index-1) - self.contentsize.height/2
    cell:setPosition(cc.p(0,posy))
    self.contentWidget:addChild(cell)
    if index*(self.contentsize.height) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,index*(self.contentsize.height)))
    end
    self.contentWidget:setPosition(cc.p(self.sv:getInnerContainerSize().width/2,self.sv:getInnerContainerSize().height))
end

return LegionWarBattleListUI