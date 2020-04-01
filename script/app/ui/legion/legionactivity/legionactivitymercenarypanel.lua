local LegionActivityMercenaryUI = class("LegionActivityMercenaryUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionActivityMercenaryUI:ctor(data,legiondata)
    self.uiIndex = GAME_UI.UI_LEGIONACTIVITYMERCENARYUI
    self.data = data
    self.legiondata = legiondata
    self.mercenarytab = {}
    self.cells = {}
end

function LegionActivityMercenaryUI:onShow()
    self:update()
end
function LegionActivityMercenaryUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityMercenaryUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_TITLE'))
    self.sv = bgimg2:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function LegionActivityMercenaryUI:update()

    self.mercenaryarr = {}
    if self.data.mercenaries then
        for k,v in pairs (self.data.mercenaries) do 
            local arr = {}
            arr[1] = k
            arr[2] = v
            table.insert( self.mercenaryarr,arr)
        end
    end
    --printall(self.mercenaryarr)
    local vip = UserData:getUserObj():getVip()
    self.num = GameData:getConfData('vip')[tostring(vip)].mercenary

    for i=1,self.num do
       self:addCells(i)
    end
    self.sv:scrollToTop(0.1,true)
end

function LegionActivityMercenaryUI:addCells(index)
    local node = cc.CSLoader:createNode("csb/legionactivitymercenarycell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local icon_bg_img = bgimg:getChildByName("icon_bg_img")
    local frame_img_node = icon_bg_img:getChildByName("frame_img_node")
    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO)
    headCell.awardBgImg:setTouchEnabled(false)
    frame_img_node:addChild(headCell.awardBgImg)
    self.mercenarytab[index] = ccui.Widget:create()
    self.mercenarytab[index]:addChild(bgimg)
    self.cells[index] = headCell
    self:updateCell(index)
    local bgimg = self.mercenarytab[index]:getChildByName("bg_img")
    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.sv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height-10
    self.mercenarytab[index]:setPosition(cc.p(2,posy))
    self.sv:addChild(self.mercenarytab[index])
end

function LegionActivityMercenaryUI:updateCell(index)
    local bgimg = self.mercenarytab[index]:getChildByName('bg_img')
    local funcpl = bgimg:getChildByName('func_pl')
    local desctx = bgimg:getChildByName('desc_tx')
    desctx:setTextAreaSize(cc.size(300,170))
    desctx:ignoreContentAdaptWithSize(false)

    local funcbtn = bgimg:getChildByName('func_btn')
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.mercenaryarr[index]  then
                local args = {
                    hid = self.mercenaryarr[index][1]
                }
                MessageMgr:sendPost('recall_mercenary','legion',json.encode(args),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        self.data.mercenaries[self.mercenaryarr[index][1]] = nil
                        local awards = data.awards
                        if awards and awards[1] then
                            GlobalApi:parseAwardData(awards)
                            local obj = RoleData:getRoleById(self.mercenaryarr[index][1])
                            local h,m,s = GlobalApi:secondTransformationToHHMMSS(self.mercenaryarr[index][2].duration)
                            local str2 = string.format(GlobalApi:getLocalStr('STR_TIME2'),h,m,s)
                            if h >= 24 then
                                h = 24
                                m = 0
                                s = 0
                            end
                            local str = string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC5'),obj:getName(),str2,awards[1][3])
                            promptmgr:showSystenHint(str, COLOR_TYPE.GREEN)
                        end
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self:update()
                    end    
                end) 
            else
                LegionMgr:showLegionActivityRoleListUI(self.data)
            end
        end
    end)

    local funcbtntx = funcbtn:getChildByName('btn_tx')

    if self.mercenaryarr and self.mercenaryarr[index] then
        desctx:setVisible(false)
        funcpl:setVisible(true)
        funcbtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_BTN_TX1'))

        local obj = RoleData:getRoleById(self.mercenaryarr[index][1])
        ClassItemCell:updateHero(self.cells[index], obj, 1)
        self.cells[index].awardImg:setVisible(true)

        local desctx1 = funcpl:getChildByName('desc_tx_1')
        desctx1:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC3'))
        local desctx2 = funcpl:getChildByName('desc_tx_2')
        desctx2:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC6'))
        local desctx3 = funcpl:getChildByName('desc_tx_3')
        
        local numtx1 = funcpl:getChildByName('num_tx_1')
        numtx1:setString(self.mercenaryarr[index][2].time_gold)
        local numtx2 = funcpl:getChildByName('num_tx_2')
        numtx2:setString(self.mercenaryarr[index][2].hire_gold)
        local namebg = funcpl:getChildByName('namebg_img')
        local h,m,s = GlobalApi:secondTransformationToHHMMSS(self.mercenaryarr[index][2].duration)
        local str = string.format(GlobalApi:getLocalStr('STR_TIME2'),h,m,s)
        if h >= 24 then
            desctx3:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC2')..'24'..GlobalApi:getLocalStr('HOUR')) 
        else
            desctx3:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC2')..str) 
        end
        
        
        local nametx = namebg:getChildByName('name_tx')
        local lvtx = namebg:getChildByName('lv_tx')
        local soldiertypeimg = namebg:getChildByName('soldiertype_img')
        if  obj:getTalent() > 0  then
            nametx:setString(obj:getName().. ' +' .. obj:getTalent())
        else
            nametx:setString(obj:getName())
        end
        nametx:setTextColor(obj:getNameColor())
        soldiertypeimg:loadTexture('uires/ui/common/soldier_'..obj:getSoldierId()..'.png')
        soldiertypeimg:ignoreContentAdaptWithSize(true)
        lvtx:setString(obj:getLevel())
    else
        desctx:setVisible(true)
        desctx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_DESC1'))
        funcpl:setVisible(false)
        funcbtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_MERCENARY_BTN_TX2'))

        self.cells[index].awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
        self.cells[index].awardImg:setVisible(false)
    end
end
return LegionActivityMercenaryUI