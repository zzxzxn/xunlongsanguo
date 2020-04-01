local LegionActivityRoleListUI = class("LegionActivityRoleListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionActivityRoleListUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONACTIVITYROLELISTUI
  self.data = data
  self.roletab = {}
end

function LegionActivityRoleListUI:onShow()
    self:update()
end
function LegionActivityRoleListUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionActivityRoleListUI()
    --     end
    -- end)
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityRoleListUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_ROLELIST_TITLE'))
    self.noroleimg = bgimg2:getChildByName('norole_img')
    self.sv = bgimg2:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function LegionActivityRoleListUI:update()
    
    self.objarr = {}
    self.num  = 0
    for k, v in pairs(RoleData:getRoleMap()) do   
        if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== false and tonumber(v:getId()) < 10000 then    
            self.num = self.num + 1
            self.objarr[self.num] = v
        end 
    end
    for i=1,self.num do
       self:addCells(i)
    end
    if self.num < 1 then
        self.noroleimg:setVisible(true)
    else
        self.noroleimg:setVisible(false)
    end
end

function LegionActivityRoleListUI:addCells(index)
    local node = cc.CSLoader:createNode("csb/legionactivityrolelistcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.roletab[index] = ccui.Widget:create()
    self.roletab[index]:addChild(bgimg)
    self:initCell(index, bgimg)
    local contentsize = bgimg:getContentSize()
    if math.ceil(self.num/2)*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,math.ceil(self.num/2)*(contentsize.height+5)+20))
    end
    local posx = -1*(index%2)*(contentsize.width+4) + contentsize.width+6
    local posy = self.sv:getInnerContainerSize().height-math.ceil(index/2)*(5 + contentsize.height)-10 
    self.roletab[index]:setPosition(cc.p(posx,posy))
    self.sv:addChild(self.roletab[index])
end

function LegionActivityRoleListUI:initCell(index, bgimg)
    local iconBgImg = bgimg:getChildByName("icon_bg_img")
    local frameAlphaImg = iconBgImg:getChildByName("frame_alpha_img")
    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.objarr[index], iconBgImg)
    headCell.awardBgImg:setPosition(cc.p(frameAlphaImg:getPosition()))
    headCell.awardBgImg:setTouchEnabled(false)

    local namebg = bgimg:getChildByName('namebg_img')
    local nametx = namebg:getChildByName('name_tx')
    local soldierimg = namebg:getChildByName('soldiertype_img')
    if  self.objarr[index]:getTalent() > 0  then
        nametx:setString(self.objarr[index]:getName().. ' +' .. self.objarr[index]:getTalent())
    else
        nametx:setString(self.objarr[index]:getName())
    end
    nametx:setTextColor(self.objarr[index]:getNameColor())
    soldierimg:loadTexture('uires/ui/common/soldier_'..self.objarr[index]:getSoldierId()..'.png')
    soldierimg:ignoreContentAdaptWithSize(true)
    local lvtx = namebg:getChildByName('lv_tx')
    lvtx:setString(self.objarr[index]:getLevel())
    
    local funcbtn = bgimg:getChildByName('func_btn')
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                pos = self.objarr[index]:getPosId()
            }
            MessageMgr:sendPost('send_mercenary','legion',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    local arr = {}
                    arr.time_gold = 0
                    arr.hire_gold = 0
                    arr.duration = 0
                    self.data.mercenaries[self.objarr[index]:getId()] = arr
                    local legioninfo = UserData:getUserObj():getLegionInfo()
                    legioninfo.mercenary = self.data.mercenaries
                    LegionMgr:hideLegionActivityRoleListUI()
                    local str = string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC4'),self.objarr[index]:getName())
                    promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
                end    
            end) 
        end
    end)
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_BTN_TX3'))
    local haveselectimg = bgimg:getChildByName('haveselect_img')
    haveselectimg:setVisible(false)
    if self.data.mercenaries then
        for k,v in pairs(self.data.mercenaries) do
            if tonumber(self.objarr[index]:getId()) == tonumber(k) then
                haveselectimg:setVisible(true)
            end
        end
    end
end
return LegionActivityRoleListUI