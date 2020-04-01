local DragonInfoUI = class("DragonInfoUI", BaseUI)

function DragonInfoUI:ctor(id,isHide,callback)
    self.uiIndex = GAME_UI.UI_DRAGON_INFO
    self.index = id
    self.isHide = isHide
    self.callback = callback
end

function DragonInfoUI:init()
    local bgImg = self.root:getChildByName("dragon_info_img")
    bgImg:setTouchEnabled(true)
    bgImg:setSwallowTouches(true)
    local neiPl = bgImg:getChildByName('nei_pl')
    local btn_ok = neiPl:getChildByName('btn_ok')
    btn_ok:setVisible(false)
    local btnTitle = btn_ok:getTitleRenderer()
    btnTitle:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
    local pl = neiPl:getChildByName('pl')
    local size1 = neiPl:getContentSize()
    local descTx = neiPl:getChildByName('desc_tx')
    descTx:setVisible(false)
    self:adaptUI(bgImg,neiPl)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local dragonImg = neiPl:getChildByName('dragon_img')
    local conf1 = GameData:getConfData("treasure")[self.index]
    local conf = conf1[#conf1]
    local playerSkillConf = GameData:getConfData("playerskill")[self.index]
    local originalStr = playerSkillConf.desc2
    local effect = GlobalApi:createLittleLossyAniByName("ui_bossjieshaojiemiantexiao")  
    effect:setScale(1.5)
    effect:setPosition(cc.p(winSize.width/2,winSize.height/2))
    effect:getAnimation():play('Animation1', -1, -1)
    bgImg:addChild(effect)

    local descTx1 = neiPl:getChildByName('desc_tx1')
    descTx1:setString("")
    local spine = GlobalApi:createLittleLossyAniByName(conf.url)
    local dragonLevel = 0
    local url = playerSkillConf['upgrade'..dragonLevel]
    if url then
        local effect = GlobalApi:createLittleLossyAniByName(url)
        effect:setPosition(cc.p(playerSkillConf['posx'..dragonLevel], playerSkillConf['posy'..dragonLevel]))
        effect:setLocalZOrder(10000)
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('dragon_effect')
        spine:addChild(effect)
    end
    spine:getAnimation():play('idle', -1, 1)
    spine:setScale(1.2*playerSkillConf.scale)
    spine:setPosition(cc.p(winSize.width/6,size1.height/2 - 100))
    -- dragonImg:setPosition(cc.p(winSize.width/5,winSize.height/2 + 30))
    dragonImg:setPosition(cc.p(winSize.width/6,size1.height/2))
    neiPl:addChild(spine)
    local nameImg = neiPl:getChildByName('name_img')
    nameImg:setPosition(cc.p(size1.width/2,nameImg:getPositionY()))
    nameImg:loadTexture('uires/ui/treasure/treasure_'..string.gsub(playerSkillConf.icon,'icon','name'))
    local dragon = RoleData:getDragonById(self.index)
    local dragonLevel = dragon:getLevel()
    local neiBgImg = neiPl:getChildByName('nei_bg_img')
    local infoTx = pl:getChildByName('info_tx')
    local size = neiBgImg:getContentSize()
    pl:setPosition(cc.p(size1.width/5*3.4,size1.height/2))
    descTx:setPosition(cc.p(size1.width/2,descTx:getPositionY()))
    neiBgImg:setPosition(cc.p(size1.width/2,size1.height/2))
    neiBgImg:setContentSize(cc.size(winSize.width,size.height))
    descTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
    descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
    infoTx:setString(GlobalApi:getLocalStr('TASK_DESC_4'))

    descTx1:setCascadeOpacityEnabled(true)
    descTx:setVisible(false)
    -- descTx1:setString(playerSkillConf.desc2)

    local attributeConf = GameData:getConfData("attribute")
    local attr = dragon:getAttr()
    local attrDescTxs = {}
    local numTxs = {}
    for i=1,4 do
        local attrDescTx = pl:getChildByName('attr_desc_tx_'..i)
        local numTx = pl:getChildByName('num_tx_'..i)
        attrDescTx:setString(attributeConf[i].name..' + ')
        numTx:setString(math.floor(attr[i]))
        attrDescTxs[i] = attrDescTx
        numTxs[i] = numTx
        attrDescTx:setOpacity(0)
        numTx:setOpacity(0)
    end
    spine:setOpacity(0)
    dragonImg:setOpacity(0)
    neiPl:setScaleX(1)
    neiPl:setScaleY(0.05)
    neiPl:setVisible(false)

    local act1=cc.Sequence:create(cc.DelayTime:create(0.6), cc.Show:create(), cc.ScaleBy:create(0.5,1,20))
    local act2 = cc.CallFunc:create(function()
        spine:runAction(cc.FadeIn:create(1))
        dragonImg:runAction(cc.FadeIn:create(1))
    end)
    local delayTime = 0.00000015
    local len = math.ceil(string.len(originalStr)/3)
    local abc
    local function setSingleString(index)
        local str = string.sub(originalStr,1,index*3)
        descTx1:setString(str)
        self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.000001),cc.CallFunc:create(function()
            if index >= len then
                abc()
            else
                setSingleString(index + 1)
            end
        end)))
    end
    local act3 = cc.CallFunc:create(function()
        setSingleString(1)
    end)
    infoTx:setOpacity(0)
    abc = function()
        local act5 = cc.CallFunc:create(function()
            local posY = infoTx:getPositionY()
            infoTx:setPosition(cc.p(250,posY))
            infoTx:runAction(cc.Sequence:create(cc.EaseElasticOut:create(cc.MoveTo:create(0.5,cc.p(0,posY)))))
            infoTx:runAction(cc.FadeIn:create(0.5))
        end)
        local act6 = cc.DelayTime:create(0.5)
        local act7 = cc.CallFunc:create(function()
            for i=1,4 do
                local posY = attrDescTxs[i]:getPositionY()
                local posX = attrDescTxs[i]:getPositionX()
                attrDescTxs[i]:setPosition(cc.p(posX + 250,posY))
                attrDescTxs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*((2 * i) - 1)),cc.EaseElasticOut:create(cc.MoveTo:create(0.5,cc.p(posX,posY)))))
                attrDescTxs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*((2 * i) - 1)),cc.FadeIn:create(0.5)))

                local posY1 = numTxs[i]:getPositionY()
                local posX1 = numTxs[i]:getPositionX()
                numTxs[i]:setPosition(cc.p(posX + 250,posY))
                numTxs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(2 * i)),cc.EaseElasticOut:create(cc.MoveTo:create(0.5,cc.p(posX1,posY1)))))
                numTxs[i]:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*(2 * i)),cc.FadeIn:create(0.5)))
            end
        end)
        local act8 = cc.DelayTime:create(0.8)
        local act9 = cc.CallFunc:create(function()
            if not self.callback then
                descTx:setVisible(true)
            else
                btn_ok:setVisible(true)
                btn_ok:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                    elseif eventType == ccui.TouchEventType.ended then
                        self.callback()
                        self:hideUI()
                    end
                end)
            end

            if self.index == 1 and GuideMgr:isRunning() and not self.isHide then
                GuideMgr:finishCurrGuide()
            end
        end)
        local act10 = cc.DelayTime:create(1.6)
        local act11 = cc.CallFunc:create(function()
            bgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if not self.callback then
                        if not self.isHide then
                            MainSceneMgr:hideDragonInfoUI()
                        end
                    end
                end
            end)
        end)
        neiPl:runAction(cc.Sequence:create(act5,act6,act7,act8,act9,act10,act11))
    end
    neiPl:runAction(cc.Sequence:create(act1,act2,act3))
end
    
return DragonInfoUI