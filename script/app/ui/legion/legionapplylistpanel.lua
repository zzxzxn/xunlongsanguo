local LegionApplyListUI = class("LegionApplyListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionApplyListUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONAPPLYLISTUI
  self.data = data
  self.membertab = {}
end

function LegionApplyListUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    self.bgimg3 = bgimg2:getChildByName('bg_img1')
    local closebtn = self.bgimg3:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionApplyListUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local titlebg = self.bgimg3:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_APPLY_LIST'))
    self.legionnumdesctx = self.bgimg3:getChildByName('legionmemnum_desctx')
    self.sv = self.bgimg3:getChildByName('role_sv')
    self.sv:setScrollBarEnabled(false)

    self.richText = xx.RichText:create()
    self.richText:setContentSize(cc.size(240, 40))
    self.re1 = xx.RichTextLabel:create('', 25, COLOR_TYPE.ORANGE)
    self.re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.re2 = xx.RichTextLabel:create('', 25, COLOR_TYPE.WHITE)
    self.re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richText:addElement(self.re1)
    self.richText:addElement(self.re2)
    self.richText:setPosition(cc.p(self.legionnumdesctx:getPositionX(),self.legionnumdesctx:getPositionY()))
    self.richText:setAlignment('middle')
    self.bgimg3:addChild(self.richText,9527)

    self.infoBg = self.bgimg3:getChildByName('info_bg')
    self.infoBg:getChildByName('text'):setString(GlobalApi:getLocalStr('LEGION_APPLY_LIST_DESC1'))

    self:update()

end

function LegionApplyListUI:update()

    self.sv:removeAllChildren()
    local legionglobalconf = GameData:getConfData('legion')
    local legionlvconf = GameData:getConfData('legionlevel')
    self.curnum = LegionMgr:getMemberCount(self.data.members)
    self.maxnum = legionlvconf[self.data.level].memberMax

    local winSize = cc.Director:getInstance():getWinSize()

    self.re1:setString(GlobalApi:getLocalStr('LEGION_MEMBER_DESC')..':')
    self.re2:setString(self.curnum..'/'..self.maxnum)
    if self.curnum == self.maxnum then
        self.re2:setColor(COLOR_TYPE.RED)
    end
    self.richText:format(true)

    self.memberarr = {}
    --printall(self.data.applicant_list)
    if self.data.applicant_list then
        for k,v in pairs (self.data.applicant_list) do 
            if v ~= nil then
                local arr = {}
                arr[1] = k
                arr[2] = v
                table.insert( self.memberarr,arr)
            end
        end
    end
    self.num = #self.memberarr
    if self.num == 0 then
        self.infoBg:setVisible(true)
    else
        self.infoBg:setVisible(false)
        for i=1,self.num do
           self:addCells(i,self.memberarr[i])
        end
    end

end

function LegionApplyListUI:addCells(index,data)
    local node = cc.CSLoader:createNode("csb/legionapplylistcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.membertab[index] = ccui.Widget:create()
    self.membertab[index]:addChild(bgimg)
    self:updateCell(index,data)
    local bgimg1 = bgimg:getChildByName('bg_img')
    if index%2 == 1 then
        bgimg1:setVisible(true)
    else
        bgimg1:setVisible(false)
    end
    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.sv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height-10
    self.membertab[index]:setPosition(cc.p(0,posy))
    self.sv:addChild(self.membertab[index])
end

function LegionApplyListUI:updateCell(index,data)
    local bgimg = self.membertab[index]:getChildByName("bg_img")
    local nametx = bgimg:getChildByName('legion_name_tx')
    --self.uid = data[1]
    nametx:setString(data[2].un)
    --
    local vipImg = bgimg:getChildByName('vip_img')
    vipImg:setPositionX(nametx:getPositionX() + nametx:getContentSize().width + 5)

    local viptx = bgimg:getChildByName('vip_tx')
    viptx:setPositionX(vipImg:getPositionX() + vipImg:getContentSize().width + 2)
    viptx:setString('')
    if viptx:getChildByName('vip_label') then
        viptx:removeChildByName('vip_label')
    end
    local viplabel = cc.LabelAtlas:_create(data[2].vip, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    viplabel:setName('vip_label')
    viplabel:setAnchorPoint(cc.p(0,0.5))
    viplabel:setPosition(cc.p(0,0))
    viplabel:setScale(0.7)
    viptx:addChild(viplabel)
    --
    local fightforcetx = bgimg:getChildByName('fight_force_tx')
    fightforcetx:setString('')
    if fightforcetx:getChildByName('left_label') then
        fightforcetx:removeChildByName('left_label')
    end
    local leftLabel = cc.LabelAtlas:_create(data[2].fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    leftLabel:setName('left_label')
    leftLabel:setAnchorPoint(cc.p(0,0.5))
    leftLabel:setPosition(cc.p(0,0))
    leftLabel:setScale(0.7)
    fightforcetx:addChild(leftLabel)

    local iconNode = bgimg:getChildByName('legion_icon_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    iconNode:addChild(cell.awardBgImg)
    cell.awardBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if tonumber(data[1]) ~= 0 then
                BattleMgr:showCheckInfo(tonumber(data[1]),'world','country')
            end
        end
    end) 
    local obj = RoleData:getHeadPicObj(data[2].headpic)
    cell.awardBgImg:loadTexture(COLOR_FRAME[data[2].quality])
    cell.awardImg:loadTexture(obj:getIcon())
    cell.lvTx:setString(data[2].level)
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(data[2].headframe))

    local applybtn = bgimg:getChildByName('apply_btn')
    local applybtntx = applybtn:getChildByName('btn_tx')
    applybtntx:setString(GlobalApi:getLocalStr('LEGION_APPLY_SUC_DESC'))
    applybtn:setPropagateTouchEvents(false)
    applybtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.curnum == self.maxnum then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_105'), COLOR_TYPE.RED)
            end
            local args = {
                uid = data[1],
            }
            MessageMgr:sendPost('approve','legion',json.encode(args),function (response)
                
                local code = response.code
                local rtdata = response.data
                if code == 0 then
                    self.data.members[tostring(data[1])] = rtdata.member[tostring(data[1])]
                    self.data.applicant_list[tostring(data[1])] = nil
                    self:update()
                elseif code == 100 then
                elseif code == 105 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_105'), COLOR_TYPE.RED)
                elseif code == 109 then
                    --玩家加入了别的军团
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_109'), COLOR_TYPE.RED) 
                elseif code == 118 then
                    --玩家取消了申请
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_118'), COLOR_TYPE.RED)                  
                end
            end)
        end
    end)
    local refusebtn = bgimg:getChildByName('refuse_btn')
    local refusebtntx = refusebtn:getChildByName('btn_tx')
    refusebtntx:setString(GlobalApi:getLocalStr('LEGION_APPLY_REFUSE'))
    refusebtn:setPropagateTouchEvents(false)
    refusebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                uid = data[1],
            }
            MessageMgr:sendPost('reject','legion',json.encode(args),function (response)
                
                local code = response.code
                local rtdata = response.data
                if code == 0 then
                    self.data.applicant_list[tostring(data[1])] = nil
                    self:update()
                    --promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SETTING_SUC'), COLOR_TYPE.GREEN)                    
                end
            end)
        end
    end)
end

return LegionApplyListUI