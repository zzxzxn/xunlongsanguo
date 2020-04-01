local MapGodUI = class("MapGodUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function MapGodUI:ctor(award,desc,callback)
	self.uiIndex = GAME_UI.UI_MAP_GOD
    self.award = award
    self.desc = desc
    self.callback = callback
end

function MapGodUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local getBgImg = self.root:getChildByName('get_bg_img')
    local getDescTx = getBgImg:getChildByName('desc_tx')
    local getInfoTx = getBgImg:getChildByName('info_tx')
    self:adaptUI(getBgImg)
    getBgImg:setVisible(false)
    getDescTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
    getDescTx:setVisible(true)
    getDescTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
    getDescTx:setPosition(cc.p(winSize.width/2,100))
    getDescTx:setVisible(true)
    getInfoTx:setString(self.desc)
    getInfoTx:setPosition(cc.p(winSize.width/2,winSize.height/2 + 100))

    if self.award then
        if self.award ~= 0 then
            getInfoTx:setColor(COLOR_TYPE.BLUE)
            getInfoTx:enableOutline(COLOROUTLINE_TYPE.BLUE)
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.award, getBgImg)
            tab.awardBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
            tab.awardBgImg:setTouchEnabled(false)
            tab.lvTx:setString('Lv.'..self.award:getLevel())
            ClassItemCell:setGodLight(tab.awardBgImg,self.award:getGodId())
            tab.awardBgImg:runAction(cc.RepeatForever:create(
                cc.Sequence:create(cc.DelayTime:create(3),
                    cc.ScaleTo:create(0.2, 1.2),
                    cc.ScaleTo:create(0.2, 1),
                    cc.ScaleTo:create(0.2, 1.2),
                    cc.ScaleTo:create(0.2, 1)))
            )
        end
    else
        getInfoTx:setColor(COLOR_TYPE.RED)
        getInfoTx:enableOutline(COLOROUTLINE_TYPE.RED)
        local img = ccui.ImageView:create('uires/ui/activity/dididalong.png')
        img:setAnchorPoint(cc.p(0.5,0.5))
        img:setPosition(cc.p(winSize.width/2,winSize.height/2))
        getBgImg:addChild(img)
        img:runAction(cc.RepeatForever:create(
            cc.Sequence:create(cc.DelayTime:create(3),
                cc.ScaleTo:create(0.2, 1.2),
                cc.ScaleTo:create(0.2, 1),
                cc.ScaleTo:create(0.2, 1.2),
                cc.ScaleTo:create(0.2, 1)))
        )
    end
    getBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideGodPanel()
        end
    end)

    getBgImg:setVisible(true)
    getInfoTx:runAction(cc.Sequence:create(
        cc.ScaleTo:create(0.2, 1.2),
        cc.ScaleTo:create(0.2, 1),
        cc.ScaleTo:create(0.2, 1.2),
        cc.ScaleTo:create(0.2, 1))
    )
    if self.callback then
        self.callback()
    end

    if self.award == 0 then
        getDescTx:setVisible(false)
        self.root:runAction(cc.Sequence:create(
            cc.DelayTime:create(3),
            cc.CallFunc:create(function ()
                MapMgr:hideGodPanel()
            end)
        ))
    end
end

return MapGodUI