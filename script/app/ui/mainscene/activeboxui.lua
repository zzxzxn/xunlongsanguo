local ActiveBoxUI = class("ActiveBoxUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function ActiveBoxUI:ctor(info,info1,richText,awards,isOpen,callback)
    self.uiIndex = GAME_UI.UI_ACTIVEBOX
    self.richText = richText
    self.callback = callback
    self.awards = awards
    self.info = info
    self.info1 = info1
    self.hadEquip = false
    self.isOpen = isOpen
end

function ActiveBoxUI:getPos(i)
    local awardBgImg = self.neiBgImg:getChildByName('award_bg_img')
    local size = awardBgImg:getContentSize()
    if #self.awards == 1 then
        return cc.p(size.width/2,size.height/2)
    elseif #self.awards == 2 then
        return cc.p(size.width/3*i,size.height/2)
    elseif #self.awards == 3 then
        return cc.p(size.width/4*i,size.height/2)
    end
end

function ActiveBoxUI:updatePanel()
	local conf = GameData:getConfData('dailytaskreward')
	-- local tab = {}
	-- for k,v in pairs(conf) do
	-- 	tab[#tab + 1] = v
	-- end
	-- table.sort( tab, function(a,b)
	-- 	return a.active < b.active
	-- end )
	-- self.data = tab[self.index]
 --    local richText = xx.RichText:create()
 --    richText:setContentSize(cc.size(300, 30))
 --    richText:setAlignment('middle')
 --    local tx1 = GlobalApi:getLocalStr('ACTIVE_ACHIEVE')
 --    local tx2 = tostring(self.data.active)
 --    local tx3 = GlobalApi:getLocalStr('STR_CANGET')
 --    local re1 = xx.RichTextLabel:create(tx1, 25,COLOR_TYPE.ORANGE)
 --    local re2 = xx.RichTextLabel:create(tx2,25,COLOR_TYPE.WHITE)
 --    local re3 = xx.RichTextLabel:create(tx3,25,COLOR_TYPE.ORANGE)
 --    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
 --    re2:setStroke(COLOR_TYPE.BLACK, 1)
 --    re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
 --    richText:addElement(re1)
 --    richText:addElement(re2)
 --    richText:addElement(re3)
    if self.richText then
        self.richText:setAnchorPoint(cc.p(0.5,0.5))
        self.richText:setPosition(cc.p(262 ,110))
        self.neiBgImg:addChild(self.richText)
    end

    local awardBgImg1 = self.neiBgImg:getChildByName('award_bg_img')
    for i,v in ipairs(self.awards) do
        local award = DisplayData:getDisplayObj(v)
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, awardBgImg1)
	    self.singleSize = tab.awardBgImg:getContentSize()
	    tab.lvTx:setString(GlobalApi:toWordsNumber(award:getNum()))
	    tab.awardBgImg:setPosition(cc.p(self:getPos(i)))
        award:setLightEffect(tab.awardBgImg)
        if award:getType() == 'equip' then
            self.hadEquip = true
        end
    end
end

function ActiveBoxUI:init()
    local activeBgImg = self.root:getChildByName("active_bg_img")
    local activeImg = activeBgImg:getChildByName("active_img")
    self:adaptUI(activeBgImg, activeImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    activeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))

    self.neiBgImg = activeImg:getChildByName('nei_bg_img')
    local closeBtn = activeImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)
    local titleTx = activeImg:getChildByName('title_tx')
    titleTx:setString(self.info)
    local okBtn = self.neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(self.info1)

    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.callback and self.isOpen == true then
                if self.hadEquip == true then
                    if BagData:getEquipFull() then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
                        return
                    end
                end
                self.callback(function()
                    self:hideUI()
                end)
            else
                self:hideUI()
            end
        end
    end)
    self:updatePanel()
end

return ActiveBoxUI