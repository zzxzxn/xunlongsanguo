local MapTalkUI = class("MapTalkUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local allPos = {
    [1] = cc.p(125,540),
    [2] = cc.p(125,180),
    [3] = cc.p(345,540),
    [4] = cc.p(345,180),
    [5] = cc.p(565,540),
    [6] = cc.p(565,180),
    [7] = cc.p(785,540),
    [8] = cc.p(785,180),
    [9] = cc.p(1005,540),
    [10] = cc.p(1005,180),
}

function MapTalkUI:ctor(cityId,callback,ntype)
	self.uiIndex = GAME_UI.UI_MAPTALK
    self.cityId = cityId
    self.callback = callback
    self.ntype = ntype
    self.step = 0
end

function MapTalkUI:updatePanel()
    local mapBgImg = self.root:getChildByName('map_bg_img')
    local size = mapBgImg:getContentSize()
    local winSize = cc.Director:getInstance():getWinSize()
    local attconf = GameData:getConfData('feilongfly')[self.cityId]
    local getBgImg = self.root:getChildByName('get_bg_img')
    local getDescTx = getBgImg:getChildByName('desc_tx')
    local getInfoTx = getBgImg:getChildByName('info_tx')
    self:adaptUI(getBgImg)
    getBgImg:setVisible(false)
    getDescTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
    getDescTx:setVisible(true)
    getDescTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
    getDescTx:setPosition(cc.p(winSize.width/2,100))
    getInfoTx:setString(GlobalApi:getLocalStr('FIRST_HORE'))
    getInfoTx:setPosition(cc.p(winSize.width/2,winSize.height/2 + 100))

    local first = MapData.data[self.cityId]:getFirst(1)
    local card
    for i,v in ipairs(first) do
        if v[1] == 'card' then
            card = v
        end
    end
    if not card then
        MapMgr:hideTalkPanel()
        return
    end
    local award = DisplayData:getDisplayObj(card)
    local id = award:getId()
    local obj = RoleData:getRoleInfoById(id)
    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, obj, getBgImg)
    tab.awardBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    tab.awardBgImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(3), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1))))

    getBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.callback then
                self.callback()
            end
            MapData.data[self.cityId]:setBfirst(false)
            MapMgr:hideTalkPanel()
        end
    end)

    getBgImg:setVisible(true)
    getInfoTx:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1)))
        
    -- self.getBgImg = getBgImg
    -- self.getInfoTx = getInfoTx
    -- local beginX = 400
    -- local spine,spine1
    -- local act1 = cc.CallFunc:create(
    --     function ()
    --         local mainObj = RoleData:getMainRole()
    --         spine = GlobalApi:createLittleLossyAniByName(mainObj:getUrl()..'_display')
    --         spine:setScaleX(-0.6)
    --         spine:setScaleY(0.6)
    --         spine:getAnimation():play('run', -1, 1)
    --         spine:setName('spine_1')
    --         spine:setLocalZOrder(99)
    --         if spine ~= nil then
    --             spine:setPosition(cc.p(1260, 250 + mainObj:getUiOffsetY()))
    --             local diffx = (1260 - beginX + attconf.move)
    --             if attconf.move - beginX > 0 then
    --                 diffx = 1260
    --             end
    --             self.dialogImg1:setPosition(cc.p(diffx, 250 + obj:getUiOffsetY() + 100))
    --             spine:runAction(cc.Sequence:create(cc.MoveTo:create(1.5, cc.p(diffx, 250 + obj:getUiOffsetY())),cc.CallFunc:create(function()
    --                 spine:getAnimation():play('idle', -1, 1)
    --             end)))
    --             mapBgImg:addChild(spine)
    --         end
    --         spine1 = GlobalApi:createLittleLossyAniByName(obj:getUrl()..'_display')
    --         spine1:setScale(0.6)
    --         spine1:getAnimation():play('run', -1, 1)
    --         spine1:setName('spine_2')
    --         spine1:setLocalZOrder(99)
    --         if spine1~=nil then
    --             spine1:setPosition(cc.p(attconf.move/2 -150, 250 + obj:getUiOffsetY()))
    --             local diffx = (beginX + attconf.move - 150)
    --             if diffx > 660 then
    --                 diffx = 660
    --             end
    --             self.dialogImg2:setPosition(cc.p(diffx, 250 + obj:getUiOffsetY() + 100))
    --             spine1:runAction(cc.Sequence:create(cc.MoveTo:create(1.5, cc.p(diffx, 250 + obj:getUiOffsetY())),cc.CallFunc:create(function()
    --                 spine1:getAnimation():play('idle', -1, 1)
    --             end)))
    --             mapBgImg:addChild(spine1)
    --         end
    --         local diff = 0
    --         if attconf.move*self.scale + winSize.width > size.width*self.scale then
    --             diff = size.width*self.scale - winSize.width
    --         else
    --             diff = attconf.move*self.scale
    --         end
    --         mapBgImg:runAction(cc.MoveBy:create(1.5,cc.p(0 - diff,0)))
    --     end
    -- )
    -- local act2 = cc.DelayTime:create(1.5)
    -- self.root:runAction(cc.Sequence:create(act1,act2,cc.CallFunc:create(function()
    --     self:runNextStep()
    -- end)))
end

function MapTalkUI:runNextStep()
    self.step = self.step + 1
    if self.step > #self.conf then
        if self.ntype then
            self.getBgImg:setVisible(true)
            self.getInfoTx:runAction(cc.Sequence:create(cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1), cc.ScaleTo:create(0.2, 1.2), cc.ScaleTo:create(0.2, 1)))
        else
            if self.callback then
                self.callback()
            end
            MapMgr:hideTalkPanel()
        end
        return
    end
    self:runTalk()
end

function MapTalkUI:runTalk()
    local data = self.conf[self.step]
    self.dialogImg1:runAction(cc.FadeOut:create(0.5))
    self.dialogImg2:runAction(cc.FadeOut:create(0.5))
    if data.name == 'talk' then
        local powerConf = GameData:getConfData("local/powertext")[data.text]
        local descTx,dialogImg,directionImg
        if data.direction == 'left' then
            descTx = self.descTx2
            dialogImg = self.dialogImg2
            directionImg = self.directionImg2
        else
            descTx = self.descTx1
            dialogImg = self.dialogImg1
            directionImg = self.directionImg1
        end
        if data.emoticon then
            directionImg:loadTexture('uires/ui/guide/guide_emoticon_'..data.emoticon..'.png')
        else
            directionImg:loadTexture('uires/ui/common/bg1_alpha.png')
        end
        dialogImg:stopAllActions()
        descTx:setString(powerConf.text)
        dialogImg:setScale(0)
        dialogImg:setOpacity(0)
        dialogImg:runAction(cc.FadeIn:create(0.5))
        dialogImg:runAction(cc.ScaleTo:create(0.5,1))
        dialogImg:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
            self.mapBgImg:setTouchEnabled(true)
        end)))
        -- self.root:runAction(cc.Sequence:create(cc.DelayTime:create(1.5),cc.CallFunc:create(function()
        --     self:runNextStep()
        -- end)))
        self.mapBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:runNextStep()
                self.mapBgImg:setTouchEnabled(false)
            end
        end)
    elseif data.name == 'action' then
        local str = 'spine/treasure/'.. data.longname
        local spine = GlobalApi:createSpineByName(data.longname, str, 1)
        spine:setScale(0)
        spine:setOpacity(0)
        spine:setLocalZOrder(100)
        self.mapBgImg:addChild(spine)
        spine:setAnimation(0, 'idle', true)
        local spine1 = self.mapBgImg:getChildByName('spine_1')
        local spine2 = self.mapBgImg:getChildByName('spine_2')
        local posX1 = spine1:getPositionX()
        local posX2 = spine2:getPositionX()
        local posY2 = spine2:getPositionY()
        spine:setPosition(cc.p(posX2,posY2))
        -- spine:setPosition(cc.p((posX1 + posX2)/2,250))
        local bezierTo = cc.BezierTo:create(0.5,{cc.p(posX2,posY2),cc.p(posX2 + 100,posY2 + 100),cc.p((posX1 + posX2)/2,250)})
        spine:runAction(bezierTo)
        spine:runAction(cc.ScaleTo:create(0.5,0.5))
        spine:runAction(cc.FadeIn:create(0.5))
        spine:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.MoveTo:create(2,allPos[data.id]),cc.CallFunc:create(function()
            self:runNextStep()
        end)))
    end
end

function MapTalkUI:createSpine()
    local treasureInfo = UserData:getUserObj():getTreasure()
    local id = tonumber(treasureInfo.id)
    local playerSkillConf = GameData:getConfData("playerskill")
    local tConf = GameData:getConfData("treasure")
    for i=2,id do
        if i <= #tConf then
            local str = 'spine/treasure/'.. tConf[i][#tConf[i]].url
            local spine = GlobalApi:createSpineByName(tConf[i][#tConf[i]].url, str, 1)
            spine:setName(tConf[#tConf].url)
            spine:setPosition(allPos[i - 1])
            spine:setScale(0.6)
            spine:setAnimation(0, 'idle', true)
            if (i - 1)%2 == 1 then
                spine:setLocalZOrder(98)
            else
                spine:setLocalZOrder(100)
            end
            self.mapBgImg:addChild(spine)
        end
    end
end
function MapTalkUI:init()
    local mapBgImg = self.root:getChildByName("map_bg_img")
    local winSize = cc.Director:getInstance():getWinSize()
    mapBgImg:setPosition(cc.p(0,0))
    local size = mapBgImg:getContentSize()
    mapBgImg:setScale(winSize.height / size.height)
    self.scale = winSize.height / size.height
    mapBgImg:setVisible(false)

    -- local dialogImg1 = mapBgImg:getChildByName('dialog_1_img')
    -- local descTx1 = dialogImg1:getChildByName('desc_tx')
    -- self.directionImg1 = dialogImg1:getChildByName('direction_img')
    -- local dialogImg2 = mapBgImg:getChildByName('dialog_2_img')
    -- local neiBgImg = dialogImg2:getChildByName('nei_bg_img')
    -- local descTx2 = neiBgImg:getChildByName('desc_tx')
    -- self.directionImg2 = dialogImg2:getChildByName('direction_img')
    -- dialogImg1:setOpacity(0)
    -- dialogImg2:setOpacity(0)
    -- dialogImg1:setLocalZOrder(99)
    -- dialogImg2:setLocalZOrder(99)
    -- self.dialogImg1 = dialogImg1
    -- self.dialogImg2 = dialogImg2
    -- self.descTx1 = descTx1
    -- self.descTx2 = descTx2
    -- self.mapBgImg = mapBgImg

    -- local attconf = GameData:getConfData('local/feilongfly')[self.cityId]
    -- self.conf = require("data/power/power_" .. attconf.index)
    -- self:createSpine()
    self:updatePanel()
end

return MapTalkUI