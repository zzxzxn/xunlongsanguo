local TerritorialwarBossTips = class("TerritorialwarBossTips", BaseUI)

function TerritorialwarBossTips:ctor(position,resCount,scoreParam,key)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_BOSS_TIP
    self.tipsPosition = position
    self.key = key
    self.resCount = resCount
    self.scoreParam = scoreParam
end

function TerritorialwarBossTips:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local bg_img = self.root:getChildByName("bg_img")
    self:adaptUI(bg_img)
    bg_img:addClickEventListener(function ()
        TipsMgr:hideTerritorialwarBossTips()
    end)
    
    local dragonBg = self.root:getChildByName("dragon_bg")
    local addX = 0
    local addY = 0
    if winSize.width - self.tipsPosition.x < 330 then
        addX = -160
    else
        addX = 160
    end
    if self.tipsPosition.y > winSize.height/2 then
        addY = -60
    else
        addY = 60
    end
    dragonBg:setPosition(cc.pAdd(self.tipsPosition, cc.p(addX, addY)))

    local icon = dragonBg:getChildByName("icon")
    local iconTx = icon:getChildByName("info_tx")
    for i=1,3 do
        local tipTx = dragonBg:getChildByName("tip_tx" .. i)
        tipTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT" .. (37+i-1)))
    end
    local numTx = dragonBg:getChildByName("tip_num")
    local scoreTx = dragonBg:getChildByName("tip_score")

    local addParam = self.scoreParam*self.resCount
    local addparaStr = addParam*100 .. "%"
    iconTx:setString(addparaStr)
    numTx:setString("x" .. self.resCount)
    scoreTx:setString("+" .. addparaStr)

end

return TerritorialwarBossTips