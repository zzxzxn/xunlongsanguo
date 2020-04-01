local TowerAwardUI = class("TowerAwardUI", BaseUI)
local ClassTowerAwardCell = require("script/app/ui/tower/towerawardscell")
local maxnum = 8
function TowerAwardUI:ctor()
  self.uiIndex = GAME_UI.UI_TOWER_AWARDS
  self.num = 0
  self.cellTotalHeight = 10
  self.sv = nil
  self.awardtab = {}
  self.index = 1
  self.maxindex = 0
end

function TowerAwardUI:addCells()
    for i = 1, self.num do
        local cell = ClassTowerAwardCell.new(i,self.awardtab[i].starNum)

        local bg = cell:getPanel():getChildByName('awardcell_img')
        local w = bg:getContentSize().width
        local h = bg:getContentSize().height
        self.cellTotalHeight = self.cellTotalHeight + h
        cell:getPanel():setPosition(cc.p(0, h*0.5 - self.cellTotalHeight + 10))
        self.contentWidget:addChild(cell:getPanel())
    end
    local posY = self.sv:getContentSize().height
    if self.cellTotalHeight > posY then
        posY = self.cellTotalHeight
    end
    self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width, posY))
    self.contentWidget:setPosition(cc.p(self.sv:getContentSize().width*0.5, posY))
end

function TowerAwardUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideTowerAwards()
        end
    end)    
    local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    local closebtn = bgimg1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideTowerAwards()
        end
    end)
    --local bgimg2 = bgimg1:getChildByName('bg_img_1')
    self.sv = bgimg1:getChildByName("cell_sv")
    self.sv:setScrollBarEnabled(false)
    self.contentWidget = ccui.Widget:create()
    self.sv:addChild(self.contentWidget)

    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    local totalstardesc = bgimg1:getChildByName('total_star_desc')
    self.rt = xx.RichText:create()
    self.rt:setPosition(cc.p(0,3))
    self.rt:setContentSize(cc.size(450, 40))
    self.re1 = xx.RichTextLabel:create('', 25, COLOR_TYPE.ORANGE)
    self.re1:setStroke(cc.c4b(0, 0, 0, 255), 1)
    self.re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
    self.re1:setString(GlobalApi:getLocalStr('TOWER_TOTAL_STAR'))
    self.re2 = xx.RichTextLabel:create('', 25, COLOR_TYPE.WHITE)
    self.re2:setStroke(cc.c4b(0, 0, 0, 255), 1)
    self.re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
    local re3 = xx.RichTextImage:create('uires/ui/common/icon_star2.png')
    self.rt:addElement(self.re1)
    self.rt:addElement(self.re2)
    self.rt:addElement(re3)
    self.rt:setAlignment('middle')
    self.rt:setVerticalAlignment('middle')
    totalstardesc:addChild(self.rt)
    titletx:setString(GlobalApi:getLocalStr('TOWER_AWARD_TITLE'))
    self:update()
end

function TowerAwardUI:update()
    local conf = GameData:getConfData('towerstarreward')
    for k, v in pairs(conf) do
        if TowerMgr:getTowerData().got == nil or (TowerMgr:getTowerData().got ~= nil and tonumber(TowerMgr:getTowerData().got[tostring(k)]) ~= 1) then
            table.insert(self.awardtab, v)         
        end
    end
    table.sort(self.awardtab,function (a,b)
        return a.starNum < b.starNum
    end)
    
    self.num = #self.awardtab
    if self.num > maxnum then 
        self.num = maxnum
    end
    self:addCells()
    self.re2:setString(TowerMgr:getTowerData().max_star)
    self.rt:format(true)
end


return TowerAwardUI