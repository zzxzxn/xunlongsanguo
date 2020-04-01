local LegionActivityMainUI = class("LegionActivityMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function LegionActivityMainUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONACTIVITYMAINUI
  self.data = data
  self.functab = {}
  self.selectid = 1
end

function LegionActivityMainUI:onShow()
    self:update()
end
function LegionActivityMainUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionActivityMainUI()
    --     end
    -- end)
    local bgimg3 = bgimg2:getChildByName('bg_img1')
    local closebtn = bgimg3:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityMainUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)

    local bgimg4 = bgimg3:getChildByName('bg_img3')
    self.sv = bgimg4:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self.bigbg = bgimg3:getChildByName('big_func_bg')
    -- local titlebg = bgimg3:getChildByName('title_bg')
    -- local titletx = titlebg:getChildByName('title_tx')
    -- titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TITLE_TX'))
    self:update()
end

function LegionActivityMainUI:update()
    self.sv:removeAllChildren()
    local legionactivityconf = GameData:getConfData('local/legionactivity')
    local conf = GameData:getConfData('legion')
    local legioninfo = UserData:getUserObj():getLegionInfo()
    self.selcetimgtab = {}
    self.cells = {}
    for i=1,#legionactivityconf do
        local node = cc.CSLoader:createNode("csb/legionactivityfuncell.csb")
        local bgimg = node:getChildByName("bg_img")
        bgimg:removeFromParent(false)
        local cell = ccui.Widget:create()
        cell:addChild(bgimg)
        table.insert(self.cells,cell)
        local titletx = bgimg:getChildByName('title_tx')
        titletx:setString(legionactivityconf[i].name)
        local limittx = bgimg:getChildByName('limit_tx')

        bgimg:loadTexture(legionactivityconf[i].titleIcon)
        self.selcetimgtab[i] = bgimg:getChildByName('select_img')
        self.selcetimgtab[i]:setVisible(false)
        local infoimg = bgimg:getChildByName('info_img')    -- 这个是红点
        infoimg:setVisible(false)
        -- print('bbbbbbbb')
        -- printall(self.data)
        if i == 1 then
            if self.data.level < tonumber(conf['legionBoonOpenLevel'].value) then
                limittx:setVisible(true)
                ShaderMgr:setGrayForWidget(bgimg)
                limittx:setString(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionBoonOpenLevel'].value))
            else
                ShaderMgr:restoreWidgetDefaultShader(bgimg)
                limittx:setVisible(false)
                if UserData:getUserObj():getBoon() >= 10 then
                    infoimg:setVisible(true)
                end
            end
        elseif i == 2 then
            if self.data.level  < tonumber(conf['legionMercenaryOpenLevel'].value) then
                limittx:setVisible(true)
                ShaderMgr:setGrayForWidget(bgimg)
                limittx:setString(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionMercenaryOpenLevel'].value))
            else
                ShaderMgr:restoreWidgetDefaultShader(bgimg)
                limittx:setVisible(false)
                local mercenaryarr = {}
                if legioninfo.mercenary then
                    for k,v in pairs (legioninfo.mercenary) do 
                        local arr = {}
                        arr[1] = k
                        arr[2] = v
                        table.insert( mercenaryarr,arr)
                    end
                end
                local vip = UserData:getUserObj():getVip()
                local num = GameData:getConfData('vip')[tostring(vip)].mercenary
                if #mercenaryarr < num then
                    infoimg:setVisible(true)
                end
            end
        elseif i == 3 then
            if self.data.level  < tonumber(conf['legionTrialOpenLevel'].value) then
                limittx:setVisible(true)
                ShaderMgr:setGrayForWidget(bgimg)
                limittx:setString(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionTrialOpenLevel'].value))
            else
                ShaderMgr:restoreWidgetDefaultShader(bgimg)
                limittx:setVisible(false)
                if legioninfo.trial_count < tonumber(conf['legionTrialMaxCount'].value) then
                    infoimg:setVisible(true)
                end
                for i=1,5 do
                    --[[if legioninfo.trial_stars >= i*3 then
                        if legioninfo.trial_award == nil or (legioninfo.trial_award ~= nil and tonumber(legioninfo.trial_award[tostring(i*3)]) ~= 1) then
                            infoimg:setVisible(true)
                            break
                        end
                    end
                    --]]
                end
            end
        elseif i == 4 then
            if self.data.level < tonumber(conf['leigionWishOpenLevel'].value) then
                limittx:setVisible(true)
                ShaderMgr:setGrayForWidget(bgimg)
                limittx:setString(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['leigionWishOpenLevel'].value))
            else
                infoimg:setVisible(UserData:getUserObj():getSignByType('legion_wish'))
                ShaderMgr:restoreWidgetDefaultShader(bgimg)
                limittx:setVisible(false)
            end
        end

        if #legionactivityconf*(bgimg:getContentSize().height+2) > self.sv:getContentSize().height then
            self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,#legionactivityconf*(bgimg:getContentSize().height+10)))
        end
        local posy = self.sv:getInnerContainerSize().height-(5 + bgimg:getContentSize().height)*(i)-10 + bgimg:getContentSize().height/2
        cell:setPosition(cc.p(bgimg:getContentSize().width/2+7,posy))
        self.sv:addChild(cell)
        bgimg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then

                if i == 1 then
                    if self.data.level < tonumber(conf['legionBoonOpenLevel'].value) then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionBoonOpenLevel'].value), COLOR_TYPE.RED)
                        return
                    end
                    self.selectid = 1
                    for j=1,#legionactivityconf do
                        self.selcetimgtab[j]:setVisible(false)
                    end
                    self.selcetimgtab[self.selectid]:setVisible(true)
                    self:updateRight()
                elseif i == 2 then
                    if self.data.level  < tonumber(conf['legionMercenaryOpenLevel'].value) then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionMercenaryOpenLevel'].value), COLOR_TYPE.RED)
                        return
                    end
                    self.selectid = 2
                    for j=1,#legionactivityconf do
                        self.selcetimgtab[j]:setVisible(false)
                    end
                    self.selcetimgtab[self.selectid]:setVisible(true)
                    self:updateRight()
                elseif i == 3 then
                    if self.data.level  < tonumber(conf['legionTrialOpenLevel'].value) then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionTrialOpenLevel'].value), COLOR_TYPE.RED)
                        return
                    end
                    self.selectid = 3
                    for j=1,#legionactivityconf do
                        self.selcetimgtab[j]:setVisible(false)
                    end
                    self.selcetimgtab[self.selectid]:setVisible(true)
                    self:updateRight()
                elseif i == 4 then
                    if self.data.level < tonumber(conf['leigionWishOpenLevel'].value) then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['leigionWishOpenLevel'].value), COLOR_TYPE.RED)
                        return
                    end
                    self.selectid = 4
                    for j=1,#legionactivityconf do
                        self.selcetimgtab[j]:setVisible(false)
                    end
                    self.selcetimgtab[self.selectid]:setVisible(true)
                    self:updateRight()
                end
            end
        end)
    end
    self.selcetimgtab[self.selectid]:setVisible(true)
    self:updateRight()
    local pos2 = cc.p(self.cells[2]:getPositionX(),self.cells[2]:getPositionY())
    local pos4 = cc.p(self.cells[4]:getPositionX(),self.cells[4]:getPositionY())
    self.cells[2]:setPosition(pos4)
    self.cells[4]:setPosition(pos2)
end

function LegionActivityMainUI:updateRight()
    local conf = GameData:getConfData('legion')
    local legionactivityconf = GameData:getConfData('local/legionactivity')
    self.bigbg:loadTexture(legionactivityconf[self.selectid].icon)
    local btn = self.bigbg:getChildByName('func_btn')
    local btntx = btn:getChildByName('btn_tx')
    btntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_9'))
    local titlebg = self.bigbg:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(legionactivityconf[self.selectid].name)
    local pl1 = self.bigbg:getChildByName('pl_1')
    local pl2 = self.bigbg:getChildByName('pl_2')
    local pl3 = self.bigbg:getChildByName('pl_3')
    local pl4 = self.bigbg:getChildByName('pl_4')
    pl1:setVisible(false)
    pl2:setVisible(false)
    pl3:setVisible(false)
    pl4:setVisible(false)
    if self.selectid == 1 then
        pl1:setVisible(true)
        local desctx1 = pl1:getChildByName('desc_tx_1')
        desctx1:setString(legionactivityconf[self.selectid].desc)
        local desctx2 = pl1:getChildByName('desc_tx_2')
        desctx2:setString(legionactivityconf[self.selectid].desc2)
        local numtx = pl1:getChildByName('num_tx')
        numtx:setString('x '..UserData:getUserObj():getBoon())
    elseif self.selectid == 2 then
        pl2:setVisible(true)
        local desctx1 = pl2:getChildByName('desc_tx_1')
        desctx1:setString(legionactivityconf[self.selectid].desc)
        local awardnode = pl2:getChildByName('award_node')
        local displayobj = DisplayData:getDisplayObj({'user','gold',1})
        local itemnode = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj, awardnode)
        itemnode.lvTx:setVisible(false)
    elseif self.selectid == 3 then
        pl3:setVisible(true)
        local desctx1 = pl3:getChildByName('desc_tx_1')
        desctx1:setString(legionactivityconf[self.selectid].desc)
        local awardnode1 = pl3:getChildByName('award_node_1')

        local trialconf = GameData:getConfData('trial')[LegionMgr:calcTrialLv()]
        local awards = trialconf.showAward
        local displayobj1 = DisplayData:getDisplayObjs(awards)[1]

        local itemnode1 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj1, awardnode1)
        local awardnode2 = pl3:getChildByName('award_node_2')
        local displayobj2 = DisplayData:getDisplayObj({'material',300018,1})
        local itemnode2 = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj2, awardnode2)
        itemnode1.lvTx:setVisible(false)
        itemnode2.lvTx:setVisible(false)
    elseif self.selectid == 4 then
        pl4:setVisible(true)
        local desctx1 = pl4:getChildByName('desc_tx_1')
        desctx1:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC1'))
        local desctx2 = pl4:getChildByName('desc_tx_2')
        desctx2:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC2'))
        local desctx3 = pl4:getChildByName('desc_tx_3')
        desctx3:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC3'))

        local remainSendCountTx = pl4:getChildByName('desc_tx_2_1')
        local remainSendCount = LegionWishMgr:getLeigionWishGiveTimes() - LegionWishMgr:getGiveNum()
        remainSendCountTx:setString(remainSendCount)
        if remainSendCount <= 0 then
            remainSendCountTx:setColor(COLOR_TYPE.RED)
            remainSendCountTx:setString(0)
        end

        local remainWishCountTx = pl4:getChildByName('desc_tx_3_1')
        local remainWishCount = LegionWishMgr:getLeigionWishTimes() - LegionWishMgr:getOwnNum()
            remainWishCountTx:setString(remainWishCount)
        if remainWishCount <= 0 then
            remainWishCountTx:setString(0)
            remainWishCountTx:setColor(COLOR_TYPE.RED)
        end

    end
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectid == 1 then
                if self.data.level < tonumber(conf['legionBoonOpenLevel'].value) then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionBoonOpenLevel'].value), COLOR_TYPE.RED)
                    return
                end
                LegionMgr:showLegionActivityBoonUI()
            elseif self.selectid == 2 then
                if self.data.level  < tonumber(conf['legionMercenaryOpenLevel'].value) then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionMercenaryOpenLevel'].value), COLOR_TYPE.RED)
                    return
                end
                LegionMgr:showLegionActivityMercenaryUI(self.data)
            elseif self.selectid == 3 then
                if self.data.level  < tonumber(conf['legionTrialOpenLevel'].value) then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['legionTrialOpenLevel'].value), COLOR_TYPE.RED)
                    return
                end
                LegionMgr:showLegionActivityTrialUI()
            elseif self.selectid == 4 then
                if self.data.level  < tonumber(conf['leigionWishOpenLevel'].value) then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),conf['leigionWishOpenLevel'].value), COLOR_TYPE.RED)
                    return
                end
                LegionWishMgr:showLegionWishGiveMainPanelUI()
            end
        end
    end)
end

return LegionActivityMainUI