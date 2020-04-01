local ShopUI = class("ShopMainUI", BaseUI)
function ShopUI:ctor(data)
	self.uiIndex = GAME_UI.UI_SHOPMAIN
    self.data = data
end

function ShopUI:updateTime(img,diffTime,pos,i)
    local label = img:getChildByTag(9999 + i)
    local size = img:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 38)
    label:setTag(9999 + i)
    label:setPosition(pos)
    label:setAnchorPoint(cc.p(0.5,0.5))
    img:addChild(label)
    Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, nil,nil,nil,38,function ()
        local args = {}
        MessageMgr:sendPost('shop_get','user',json.encode(args),function (response)
            
            local code = response.code
            local data = response.data
            if code == 0 then
                self.data = data
                self:updatePanel()
            end
        end)
    end)
end

function ShopUI:updatePanel()
    local bgImg = self.root:getChildByName("shop_bg_img")
    local shopImg = bgImg:getChildByName("shop_img")
    local timeTab = {self.data.mystery,self.data.god,self.data.black}
    local beginTime = MainSceneMgr.refreshIntervalTab[11]*3600 - (Time.getCorrectServerTime() - Time.beginningOfToday())%(MainSceneMgr.refreshIntervalTab[11]*3600)
    local beginTime1 = MainSceneMgr.refreshIntervalTab[12]*3600 - (Time.getCorrectServerTime() - Time.beginningOfToday())%(MainSceneMgr.refreshIntervalTab[12]*3600)
    local beginTime2 = MainSceneMgr.refreshIntervalTab[13]*3600 - (Time.getCorrectServerTime() - Time.beginningOfToday())%(MainSceneMgr.refreshIntervalTab[13]*3600) + 5*3600
    local beginTimes = {beginTime,beginTime1,beginTime2}
    local vip = UserData:getUserObj():getVip()
    local needVip = tonumber(GlobalApi:getGlobalValue('blackShopVipLimit'))
    local level = UserData:getUserObj():getLv()
    -- local diffTime = (self.data.black or 0) - GlobalData:getServerTime() + MainSceneMgr.refreshIntervalTab[13]*60
    -- local isBlackOpen = (vip >= needVip) or (diffTime > 0) or false
    local winSize = cc.Director:getInstance():getVisibleSize()

    local pos = {cc.p(120,85),cc.p(380,85),cc.p(638,85)}
    for i=1,3 do
        local shopBgImg = shopImg:getChildByName('shop_bg_'..i..'_img')
        local size = shopBgImg:getContentSize()
        local infoTx2 = shopBgImg:getChildByName('info_2_tx')
        if MainSceneMgr.openLevelTab[i + 10] > level then
            infoTx2:setString(string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),MainSceneMgr.openLevelTab[i + 10]))
        else
            -- infoTx2:setString(((vip < needVip and i == 3) and GlobalApi:getLocalStr('REMAINDER_TIME1')) or GlobalApi:getLocalStr('REFRESH_TIME1'))
            infoTx2:setVisible(false)
            self:updateTime(shopImg,beginTimes[i],pos[i],i)
        end
        shopBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if MainSceneMgr.openLevelTab[i + 10] > level then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'), COLOR_TYPE.RED)
                -- elseif i == 3 and vip < needVip and (diffTime <= 0) then
                --     promptmgr:showSystenHint(GlobalApi:getLocalStr('BLACK_SHOP_NOT_OPEN'), COLOR_TYPE.RED)
                else
                    MainSceneMgr:showShop(i + 10,{min = 11,max = 13})
                    -- MainSceneMgr:hideMainShop()
                end
            end
        end)
    end
end

function ShopUI:init()
    local bgImg = self.root:getChildByName("shop_bg_img")
    local shopImg = bgImg:getChildByName("shop_img")
    self:adaptUI(bgImg, shopImg)
    -- self:adaptUI(shopImg)
    -- local winSize = cc.Director:getInstance():getVisibleSize()
    -- bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    -- local size = bgImg:getContentSize()
    -- shopImg:setPosition(cc.p(size.width/2 + 20,size.height/2 - 10))
    -- shopImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))
    local closeBtn = shopImg:getChildByName('close_btn')
    -- closeBtn:setAnchorPoint(cc.p(1,1))
    -- closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideMainShop()
        end
    end)

    -- local spine = GlobalApi:createSpineByName("shop", "spine/city_building/shop", 1)
    -- -- local size = self.buildingPls[v.pos]:getContentSize()
    -- spine:setPosition(cc.p(-150,0))
    -- shopImg:addChild(spine)
    -- spine:setAnimation(0, 'idle_in', true)
    -- spine:setScale(1.5)
    -- spine:setLocalZOrder(2)

    self:updatePanel()
end
    
return ShopUI