local MapAwardsUI = class("MapAwardsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function MapAwardsUI:ctor(awards,id,ntype)
	self.uiIndex = GAME_UI.UI_MAPAWARD
    printall(awards)
    -- self.awards = DisplayData:getDisplayObjs(awards)
    self.awards = awards
    self.id = id
    self.ntype = ntype
    self.pos = {}
    self.zorder = 10
    self.awardImgs = {}
    self.progressEnd = true 
    self.imgEnd = true
end

-- function MapAwardsUI:onShow()
--     if self.num - 1 >= #self.awards then
--         MapMgr:hideAwardPanel()
--     end
-- end

function MapAwardsUI:getEquip()
    local tab = {}
    local tab1 = {}
    local tab2 = {}
    local num = 0
    local num1 = 0
    local level = nil
    for i,v in ipairs(self.awards) do
        num = num + 1
        local award = DisplayData:getDisplayObj(v)
        level = award:getLevel()
        tab[#tab + 1] = award
    end
    num = #self.awards
    
    for i=self.id - 1,1,-1 do
        local cityEquip = MapData.data[i]:getPatrolEquip()
        for _,v in pairs(cityEquip) do
            local award = DisplayData:getDisplayObj(v)
            local lv = award:getLevel()
            level = level or lv
            if level == lv then
                tab1[#tab1 + 1] = award
                if num + #tab1 >= 6 then
                    break
                end
            elseif lv < level then
                break
            end
        end
    end
    num1 = #tab1

    self.allEquip = {}
    for i,v in ipairs(tab1) do
        self.allEquip[#self.allEquip + 1] = v
    end
    for i,v in ipairs(tab) do
        self.allEquip[#self.allEquip + 1] = v
    end
    for i=1,10 do
        local id = self.id + i
        local cityData = MapData.data[id]
        if cityData then
            local cityEquip = cityData:getPatrolEquip()
            for _,v in pairs(cityEquip) do
                local award = DisplayData:getDisplayObj(v)
                local lv = award:getLevel()
                if level == lv then
                    self.allEquip[#self.allEquip + 1] = award
                    if #self.allEquip >= 6 then
                        break
                    end
                elseif lv > level then
                    break
                end
            end
        end
    end
    self.beginIndex = num1
end

function MapAwardsUI:awardFly1()
    local awardBgImg = nil
    local index = self.num - 1
    if not self.awardImgs[index] then
        return
    else
        awardBgImg = self.awardImgs[index].awardBgImg
        awardBgImg:setVisible(true)
    end
    local winSize = cc.Director:getInstance():getWinSize()
    awardBgImg:setPosition(cc.p(winSize.width/2 + 230,winSize.height/2 + 24))
    local isHide = UIManager:getSidebar():getIsHide()
    if isHide then
        -- UIManager:getSidebar():setFrameBtnsVisible(true)
    end
    awardBgImg:setLocalZOrder(self.zorder - self.num)
    self.awardsBgImg:setTouchEnabled(false)
    awardBgImg:runAction(cc.Sequence:create(
        cc.JumpTo:create(0.5,cc.p(winSize.width/2 + 195,winSize.height/2 + 24),15,1),
        cc.CallFunc:create(function()
            self.awardsBgImg:setTouchEnabled(true)
        end),
        cc.JumpTo:create(0.5,cc.p(winSize.width/2 + 160,winSize.height/2 + 24),15,1),
        cc.JumpTo:create(1,cc.p(winSize.width/2 + 90,winSize.height/2 + 24),15,2),
        cc.CallFunc:create(function()
            awardBgImg:runAction(cc.MoveTo:create(0.5,cc.p(winSize.width - 185,119)))
            awardBgImg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.5,0.1),cc.CallFunc:create(function()
                awardBgImg:removeFromParent()
            end)))
        end)
    ))
    awardBgImg:runAction(cc.ScaleTo:create(2,1))
end

function MapAwardsUI:awardFly()
end

function MapAwardsUI:click()
    if #self.awards - (self.num - 1) < 0 then
        self.numTx:setString(0)
    else
        self.numTx:setString(#self.awards - (self.num - 1))
    end
    if self.num == 1 then
        local size = self.pl:getContentSize()
        self.progress:setPercentage(100)
        if self.ntype == 1 then
            self.index = 2
            local spine = GlobalApi:createSpineByName('ui_map_award2', "spine/ui_map_award2/ui_map_award2", 1)
            spine:setScale(0.5)
            self.pl:addChild(spine,1)
            spine:setAnimation(0, 'idle', true)
            spine:setPosition(cc.p(size.width/2,size.height/2))
            spine:setName('spine_2')
        else
            self.index = 3
            self.equipImg:setVisible(true)
            self.bgImg = {}
            for i=1,6 do
                local bgImg = self.equipImg:getChildByName('award_bg_'..i..'_img')
                local lockImg = bgImg:getChildByName('lock_img')
                local nameTx = bgImg:getChildByName('name_tx')
                if self.allEquip[i] then
                    local award = self.allEquip[i]
                    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, bgImg)
                    tab.awardBgImg:setTouchEnabled(false)
                    tab.awardBgImg:setPosition(cc.p(64,56))
                    local obj = award:getObj()
                    if obj then
                        nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..obj:getType()))
                    end
                    tab.lvTx:setString('Lv.'..award:getLevel())
                    if i > self.beginIndex then
                        tab.addImg:loadTexture('uires/ui/common/frame_gray1.png')
                        tab.addImg:ignoreContentAdaptWithSize(true)
                        tab.addImg:setVisible(true)
                        lockImg:setVisible(true)
                    else
                        lockImg:setVisible(false)
                    end
                    tab.bgImg = bgImg
                    tab.lockImg = lockImg
                    self.bgImg[i] = tab
                    local pos = bgImg:convertToWorldSpace(cc.p(0,0))
                    self.pos[i] = cc.p(pos.x + 64 + 90,pos.y + 56 + 64)
                else
                    bgImg:setVisible(false)
                end
                lockImg:setLocalZOrder(4)
            end
        end
        self:runTxImgs()
        local spine1 = self.pl:getChildByName('spine_1')
        spine1:removeFromParent()
        self.awardsBgImg:setTouchEnabled(false)
        self.progressEnd = false
        self.progress:runAction(cc.Sequence:create(cc.ProgressTo:create(1.5, 0),cc.CallFunc:create(function()
            self.progressEnd = true
            self:setBgTouchEnabled()
        end)))
    else
        if self.ntype == 1 then
            for i=1,#self.awards do
                local award = DisplayData:getDisplayObj(self.awards[i])
                local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, award, self.awardsBgImg)
                tab.awardBgImg:setTouchEnabled(false)
                tab.awardBgImg:setScale(0.1)
                if 'equip' == award:getType() then
                    tab.lvTx:setString('Lv.'..award:getLevel())
                else
                    tab.lvTx:setString(award:getNum())
                end
                self.awardImgs[i] = tab
            end
            self:awardFly1()
        else
            local img = self.bgImg[self.num - 1 + self.beginIndex]
            if img then
                -- local lockImg = img:getChildByName('lock_img')
                -- local bgImg = img:getChildByName('award_bg_img')
                -- local addImg = bgImg:getChildByName('add_img')
                img.lockImg:setVisible(false)
                local spine = GlobalApi:createSpineByName('ui_suo', "spine/ui_suo/ui_suo", 1)
                img.bgImg:addChild(spine,2)

                spine:registerSpineEventHandler(function (event)
                    if event.animation == 'idle' then
                        img.addImg:setVisible(false)
                        self:awardFly()
                    end
                end, sp.EventType.ANIMATION_END)
                spine:setPosition(cc.p(64,68))
                spine:setAnimation(0, 'idle', false)
            end
        end
    end
end

function MapAwardsUI:hideSelf()
    local id = self.id
    local cityData = MapData.data[id]
    MapMgr:sendTribute(id,function()
        MapData.data[id]:setBfirst(false)
        MapMgr:hideAwardPanel()
        if cityData.conf.guideIndex > 0 then
            print('=================================',cityData.conf.guideIndex)
            if cityData.conf.guideIndex == 114 then
                local finishFirstpay = UserData:getUserObj():getMark().first_pay >= 2 and true or false
                if not finishFirstpay then
                    GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
                end
            else
                GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
            end
        end
    end)
    -- local cityData = MapData.data[self.id]
    -- local args = {}
    -- MessageMgr:sendPost('get_tribute','battle',json.encode(args),function (response)
    --     
    --     local code = response.code
    --     local data = response.data
    --     if code == 0 then
    --         local awards = data.awards
    --         if awards then
    --             GlobalApi:parseAwardData(awards)
    --         end
    --         -- if MapData.data[self.id].conf.moduleOpenId <= 0 or MapData.data[self.id].conf.moduleOpenId > 100 then
    --         --     MapData.data[self.id]:setBfirst(false)
    --         -- end
    --         if cityData.conf.guideIndex > 0 then
    --             MapMgr:hideAwardPanel()
    --             GuideMgr:startCityOpenGuide(cityData.conf.guideIndex, 1)
    --         else
    --             MapData.data[self.id]:setBfirst(false)
    --             MapMgr:hideAwardPanel()
    --         end
    --     end
    -- end)
end

function MapAwardsUI:setBgTouchEnabled()
    if self.progressEnd == true and self.imgEnd == true then
        self.awardsBgImg:setTouchEnabled(true)
    end
end

function MapAwardsUI:runTxImgs()
    self.awardsBgImg:setTouchEnabled(false)
    self.imgEnd = false
    local titleBgImg = self.neiBgImg:getChildByName('title_bg_img')
    local pos1 = {cc.p(30,300),cc.p(111,300),cc.p(174,300),cc.p(255,300)}
    local pos2 = {cc.p(48,88),cc.p(111,88),cc.p(174,88),cc.p(237,88)}
    local time = 0.3
    for i=1,4 do
        local titleImg = titleBgImg:getChildByName('title_'..i..'_img')
        titleImg:stopAllActions()
        titleImg:loadTexture('uires/ui/mapaward/tx_'..self.index..'_'..i..'.png')
        titleImg:setOpacity(0)
        titleImg:setScale(0.01)
        titleImg:setPosition(pos1[i])
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(i*time/2),cc.CallFunc:create(function()
            titleImg:runAction(cc.MoveTo:create(time,pos2[i]))
            titleImg:runAction(cc.ScaleTo:create(time,1))
            titleImg:runAction(cc.FadeIn:create(time))
            if i == 4 then
                self.imgEnd = true
                self:setBgTouchEnabled()
            end
        end)))
    end

end

function MapAwardsUI:init()
    self.index = 1
	self.awardsBgImg = self.root:getChildByName("awards_bg_img")
    local bgImg = self.awardsBgImg:getChildByName("bg_img")
	
    -- self:adaptUI(self.awardsBgImg,bgImg)
    local winSize = cc.Director:getInstance():getWinSize()
    local bgImg1 = self.root:getChildByName('bg_img')
    bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.awardsBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    -- local winSize = cc.Director:getInstance():getWinSize()
    -- print(winSize.width,winSize.height)
    -- bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.awardsBgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.num > #self.awards then
                self:hideSelf()
                return
            end
            self.num = self.num + 1
            self:click()
        end
    end)
    local cityData = MapData.data[self.id]
    local kapaiImg = bgImg:getChildByName('kapai_img')
    self.numTx = kapaiImg:getChildByName('num_tx')
    local descTx = bgImg:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
    descTx:setVisible(true)
    descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))

    self.neiBgImg = bgImg:getChildByName("nei_bg_img")
    self.equipImg = self.neiBgImg:getChildByName('equip_img')
    self.equipImg:setVisible(false)

    self.pl = self.neiBgImg:getChildByName('pl')
    local size = self.pl:getContentSize()
    local spine = GlobalApi:createSpineByName('ui_map_award1', "spine/ui_map_award1/ui_map_award1", 1)
    spine:setScale(0.5)
    self.pl:addChild(spine,2)
    spine:setAnimation(0, 'idle', true)
    spine:setPosition(cc.p(size.width/2,size.height/2))
    spine:setName('spine_1')
    local sprite = cc.Sprite:create('uires/ui/mapaward/action.png')
    self.progress = cc.ProgressTimer:create(sprite)
    self.progress:setType(cc.PROGRESS_TIMER_TYPE_RADIAL)
    self.progress:setPosition(self.pl:getPosition())
    self.neiBgImg:addChild(self.progress)
    self.progress:setPercentage(0)

    self.num = 0
    self.numTx:setString(#self.awards)

    local winSize = cc.Director:getInstance():getWinSize()
    local mainObj = RoleData:getMainRole()
    -- local mainSpine = GlobalApi:createLittleLossyAniByName(mainObj:getUrl()..'_display')
    local mainSpine = GlobalApi:createLittleLossyAniByName('guide_npc_8')
    mainSpine:setScale(0.8)
    mainSpine:setScaleX(-0.8)
    self.neiBgImg:addChild(mainSpine)
    mainSpine:getAnimation():play('idle', -1, 1)
    mainSpine:setPosition(cc.p(210,80))

    local act1 = cc.CallFunc:create(function()
        mainSpine:runAction(cc.MoveTo:create(1,cc.p(190,50)))
    end)

    self:runTxImgs()
    -- self.root:runAction(cc.Sequence:create(act1))
    self:getEquip()
end

return MapAwardsUI