local CountryWarVictoryUI = class("CountryWarVictoryUI", BaseUI)
function CountryWarVictoryUI:ctor(data,enemy,callback)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_VICTORY
    self.data = data
    self.enemy = enemy
    self.callback = callback
end

function CountryWarVictoryUI:updatePanel()

end

function CountryWarVictoryUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local neiPl = bgImg:getChildByName("nei_pl")
    self:adaptUI(bgImg, neiPl)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = bgImg:getChildByName("close_btn")
    local infoTx = closeBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr("STR_OK2"))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarVictory()
            if self.callback then
                self.callback()
            end
        end
    end)

    local leftImg = neiPl:getChildByName("left_img")
    local rightImg = neiPl:getChildByName("right_img")
    local resultImg = leftImg:getChildByName("result_img")
    local numTx = resultImg:getChildByName('num_tx')
    local pl1 = leftImg:getChildByName('pl')
    local pl2 = rightImg:getChildByName('pl')
    local rolePl1 = pl1:getChildByName('role_pl')
    local rolePl2 = pl2:getChildByName('role_pl')
    local lightImg = leftImg:getChildByName('light_img')
    lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(8, 360)))
    numTx:setString(GlobalApi:getLocalStr("COUNTRY_WAR_DESC_35")..'+'..self.data.score)
    numTx:setOpacity(0)
    numTx:setScale(5)
    numTx:setPosition(cc.p(104,0))
    numTx:runAction(cc.FadeIn:create(0.2))
    numTx:runAction(cc.ScaleTo:create(0.2,1))
    numTx:runAction(cc.Sequence:create(cc.MoveTo:create(0.2,cc.p(104,-40))))

    local armyMapTemp = self.data.armyMap
    local armyMap = {}
    local fightForce1 = 0
    for k,v in pairs(armyMapTemp) do
        armyMap[v.legionInfo.rolePos] = v
    end
    local enemyMapTemp = self.data.enemyMap
    local enemyMap = {}
    for k,v in pairs(enemyMapTemp) do
        enemyMap[#enemyMap + 1] = v
    end
    local imgs = {leftImg,rightImg}
    local pls = {pl1,pl2}
    local data = {
        {
            armyMap[1].heroObj,
            CountryWarMgr.camp,
            UserData:getUserObj():getFightforce(),
            GlobalData:getSelectSeverUid()..GlobalApi:getLocalStr('FU')..' '..UserData:getUserObj():getName()..' Lv.'..UserData:getUserObj():getLv()
        },
        {
            enemyMap[1].heroObj,
            self.enemy.camp,
            self.data.enemyData.fightforce,
            self.enemy.server..GlobalApi:getLocalStr('FU')..' '..self.enemy.un..' Lv.'..(self.enemy.level or 0)
        },
    }
    if self.enemy.uid < 100000 then
        data[2][4] = GlobalApi:getLocalStr("COUNTRY_WAR_DESC_52")..' '..self.enemy.un..' Lv.'..(self.enemy.level or 0)
        data[2][2] = self.enemy.country
    end
    for i=1,2 do
        local diImg = pls[i]:getChildByName('di_img')
        local flagImg = pls[i]:getChildByName('flag_img')
        local dianImg1 = pls[i]:getChildByName('dian_img_1')
        local dianImg2 = pls[i]:getChildByName('dian_img_2')
        local nameTx = dianImg1:getChildByName('name_tx')
        local fightForceTx = dianImg2:getChildByName('fight_force_tx')
        flagImg:loadTexture("uires/ui/countrywar/countrywar_flag_" .. data[i][2] ..  ".png")
        fightForceTx:setString(data[i][3])
        nameTx:setString(data[i][4])

        local obj = RoleData:getRoleInfoById(data[i][1].heroId)
        local spineAni = GlobalApi:createLittleLossyAniByName(obj:getUrl()..'_display', nil, data[i][1].changeEquipObj)
        spineAni:setScaleX(0.8 * (i == 2 and -1 or 1))
        spineAni:setScaleY(0.8)
        spineAni:setPosition(cc.p(80,20))
        spineAni:getAnimation():play('idle', -1, -1)
        diImg:addChild(spineAni)
    end
    for i=1,7 do
        local roleBgImg1 = rolePl1:getChildByName('role_bg_img_'..i)
        local roleBgImg2 = rolePl2:getChildByName('role_bg_img_'..i)
        local posX,posY = roleBgImg1:getPosition()
        local posX1,posY1 = roleBgImg2:getPosition()
        local diffWidth = (winSize.width - 960)/20 * (i + 1)
        roleBgImg1:setPosition(cc.p(posX + diffWidth,posY))
        roleBgImg2:setPosition(cc.p(posX1 - diffWidth,posY1))
        if armyMap[i] then
            local obj = RoleData:getRoleByPos(i)
            local pos = self.data.winner_pos[tostring(i)]
            if obj then
                roleBgImg1:setVisible(true)
                local roleImg = roleBgImg1:getChildByName('role_img')
                local barBg = roleBgImg1:getChildByName('bar_bg')
                local bar = barBg:getChildByName('bar')
                roleBgImg1:loadTexture(obj:getBgImg())
                roleImg:loadTexture(obj:getIcon())
                roleImg:ignoreContentAdaptWithSize(true)
                local quality = obj:getQuality()
                GlobalApi:setHeroPromoteAction(roleBgImg1,quality)
                local conf = obj:getConfig('soldierlevel')
                -- local per = pos.hp*0.9 + pos.soldierNum/conf.num*100*0.1
                local per = pos.hp
                bar:setPercent(per)
                if per == 0 then
                    ShaderMgr:setGrayForWidget(roleBgImg1)
                    ShaderMgr:setGrayForWidget(roleImg)
                end
            else
                roleBgImg1:setVisible(false)
            end
        else
            roleBgImg1:setVisible(false)
        end

        if enemyMap[i] then
            local obj = enemyMap[i].heroObj
            if obj then
                local obj1 = RoleData:getRoleInfoById(obj.heroId)
                roleBgImg2:setVisible(true)
                local roleImg = roleBgImg2:getChildByName('role_img')
                local barBg = roleBgImg2:getChildByName('bar_bg')
                local bar = barBg:getChildByName('bar')
                roleBgImg2:loadTexture('uires/ui/common/frame_blue.png')
                roleImg:loadTexture(obj1:getIcon())
                roleImg:ignoreContentAdaptWithSize(true)
                local quality = obj1:getQuality()
                GlobalApi:setHeroPromoteAction(roleBgImg2,quality)
                bar:setPercent(0)
                ShaderMgr:setGrayForWidget(roleBgImg2)
                ShaderMgr:setGrayForWidget(roleImg)
            else
                roleBgImg2:setVisible(false)
            end
        else
            roleBgImg2:setVisible(false)
        end
    end

    local size = pl1:getContentSize()
    pl1:setContentSize(cc.size(size.width + (winSize.width - 960)/2,size.height))
    local posX,posY = pl2:getPosition()
    pl2:setPosition(cc.p(posX + (winSize.width - 960)/2,posY))
    closeBtn:setPosition(cc.p(winSize.width/2,80))
    -- local posX1 = leftImg:getPositionX()
    -- leftImg:setPosition(cc.p(posX1,80))

    self:updatePanel()
end

return CountryWarVictoryUI