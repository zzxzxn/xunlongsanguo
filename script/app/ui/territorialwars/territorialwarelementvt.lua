local TerritorialWarsElementVTUI = class("TerritorialWarsElementVTUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')


local legionIconBg = {  
    nor = 'uires/ui/territorialwars/terwars_nomal.png',
    sel = 'uires/ui/territorialwars/terwars_icon_btn.png',
}

function TerritorialWarsElementVTUI:ctor(resId,cellId,around,tab,showType)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_ELEMENTVT
    self.resId = resId
    self.cellId = cellId
    self.around = around
    self.tab = tab
    self.showType = showType or nil
end

function TerritorialWarsElementVTUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local neiPl = bgImg:getChildByName('nei_pl')
    self:adaptUI(bgImg,neiPl)
    local winSize = cc.Director:getInstance():getVisibleSize()
    self.neiBgImg = neiPl:getChildByName('nei_bg_img')
    local descTx = neiPl:getChildByName('desc_tx')
    local size = self.neiBgImg:getContentSize()
    local size1 = neiPl:getContentSize()
    
    descTx:setPosition(cc.p(size1.width/2,descTx:getPositionY()))
    descTx:setString(GlobalApi:getLocalStr('CLICK_ANY_POS_CONTINUE'))
    descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
    
    self.pltab = {}
    for i=1,5 do
        local tab = {}
        tab.pl = self.neiBgImg:getChildByName('pl_'..i)
        tab.pl:setVisible(false)
        self.pltab[i] = tab
    end

    local effect = GlobalApi:createLittleLossyAniByName("ui_bossjieshaojiemiantexiao")  
    effect:setScale(1.5)
    effect:setPosition(cc.p(winSize.width/2,winSize.height/2))
    effect:getAnimation():play('Animation1', -1, -1)
    bgImg:addChild(effect)

    neiPl:setScaleX(1)
    neiPl:setScaleY(0.05)
    neiPl:setVisible(false)
    local act1=cc.Sequence:create(cc.DelayTime:create(0.3), cc.Show:create(), cc.ScaleBy:create(0.5,1,20))
    local act2 = cc.DelayTime:create(0.1)
    local act3 = cc.CallFunc:create(function()
        descTx:setVisible(true)
    end)
    local act4 = cc.CallFunc:create(function()
        bgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:hideElementVTUI()
            end
        end)
    end)
        
    neiPl:runAction(cc.Sequence:create(act1,act2,act3,act4))
    self:update()
end

function TerritorialWarsElementVTUI:onShow()
    self:update()
end

function TerritorialWarsElementVTUI:update()
    local dfelementConfig = GameData:getConfData("dfelement")[self.resId]
    local dfbaseparaConfig = GameData:getConfData("dfbasepara")
    
    local nametx = self.neiBgImg:getChildByName('name_tx')
    nametx:setString(dfelementConfig.name)
    local addtx = self.neiBgImg:getChildByName('add_desc')
    addtx:setString('')
    local  infodesctx = self.neiBgImg:getChildByName('info_desc_tx')
    local talkbg = self.neiBgImg:getChildByName('talk_bg')
    local talktx = talkbg:getChildByName('talk_tx')
    local buildimg = self.neiBgImg:getChildByName('build_img')

    local confirmBtn = self.neiBgImg:getChildByName('confirm_btn')
    local btnText = confirmBtn:getChildByName('info_tx')
    ShaderMgr:setGrayForWidget(talkbg)
    talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO33'))
    local belongtx = self.neiBgImg:getChildByName('belong_tx')
    belongtx:setString(dfelementConfig['affiliationHint'] or '')
    
    local flag = 1
    if self.around == true then
        confirmBtn:setVisible(true)
        flag = 2
    else
        confirmBtn:setVisible(false)
        flag = 1
    end   
    
    local showType = dfelementConfig.showType
    if self.showType  then
        showType = self.showType
    end
    self.pltab[showType].pl:setVisible(true)
    local pl = self.pltab[showType].pl
    print('showType ' ,showType)

    --矿
    if showType == 1 then
        local dfmapmineConfig = GameData:getConfData("dfmapmine")[self.resId]
        local disPlayData = DisplayData:getDisplayObjs(dfelementConfig.award)
        belongtx:setString(GlobalApi:getLocalStr('CHAT_CHANNEL2'))
        if self.showType then
            nametx:setString(dfmapmineConfig.name)
            infodesctx:setString(dfmapmineConfig['desc'])
            if self.tab.myselfLand == true then
                disPlayData = DisplayData:getDisplayObjs(dfmapmineConfig['award1'])
                printall(dfmapmineConfig['award1'])
            else
                disPlayData = DisplayData:getDisplayObjs(dfmapmineConfig['award2'])
                printall(dfmapmineConfig['award2'])
            end
            buildimg:ignoreContentAdaptWithSize(true)
            local animation = self.tab.visited and 'open' or 'close'
            local model = GlobalApi:createLittleLossyAniByName(dfmapmineConfig.url)
            if model~=nil then
                local winSize = buildimg:getSize()
                model:setScale(2.3)
                model:setAnchorPoint(cc.p(0.5,0.5))
                model:getAnimation():play(animation, -1, 1)
                model:setPosition(cc.p(winSize.width/2,winSize.height/2))
                buildimg:addChild(model)
            end 
        else
            infodesctx:setString(dfelementConfig['desc'..flag])
        end
        
        local tabletIncreaseValues = dfbaseparaConfig['stoneTabletIncrease'].value
        local desctx = pl:getChildByName('desc_tx')
        local infotx = pl:getChildByName('info_tx')       
        infotx:setString('')

        --已加成
        local tabletCount = TerritorialWarMgr:getSteleCount()                   --石碑访问次数
        if tabletCount > #tabletIncreaseValues then
            tabletCount = #tabletIncreaseValues
        end

        local nAddValue = 0
        if tabletCount >= 1 then
            nAddValue = tabletIncreaseValues[tabletCount]
        end

        --下阶加成
        local nextCount,nextValue = tabletCount + 1,0
        if nextCount <= #tabletIncreaseValues then
            nextValue = tabletIncreaseValues[nextCount]
        end
        

        local occupyCount = self.tab.robCount or 0                  --矿产占领次数
        local perValue = tonumber(dfbaseparaConfig['pillageLose'].value[1])
        local surplusCount = 100-perValue*occupyCount
        if surplusCount < 0 then
            surplusCount = 0
        end

        for i=1,2 do
            local awardsnode = pl:getChildByName('award_node_'..i)
            local awards = disPlayData[i]
            if awards then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardsnode)
                local formulaParam = 'mineAward'
                if self.tab.myselfLand == false then
                    formulaParam = 'minePillageAward'
                end
                local num = TerritorialWarMgr:getRealCount(formulaParam,awards:getNum(),surplusCount,nAddValue)
                cell.lvTx:setString('x'..num)
                cell.awardBgImg:setScale(0.9)
            end
        end

        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(280, 80))
        richText:setAlignment('left')
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO1'), 22,COLOR_TYPE.ORANGE)
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextLabel:create(surplusCount .. '%', 22, cc.c4b(249,227,204, 255))
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re3 = xx.RichTextLabel:create('+' .. nAddValue .. '%'..'\n', 22, COLOR_TYPE.YELLOW)
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

        local str = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO3'),nextCount,nextValue) .. '%'..'\n'
        local color = COLOR_TYPE.GRAY
        if tabletCount >= #tabletIncreaseValues then
            str =  GlobalApi:getLocalStr('TERRITORIAL_WAL_INF23')
            color = cc.c4b(249,227,204, 255)
        end

        local re4 = xx.RichTextLabel:create(str, 22, color)
        re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:addElement(re4)
        richText:format(true)
        richText:setPosition(cc.p(0,0))
        infotx:addChild(richText)
        addtx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO4'))
        confirmBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:occupyMineral(self.cellId,dfmapmineConfig.name)
            end
        end)

        if self.tab.myselfLand == true then
            btnText:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO2'))
            desctx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO'))
            --占领判断
            if self.tab.hold == 1 then
                talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO34'))
                ShaderMgr:restoreWidgetDefaultShader(talkbg)
                confirmBtn:setVisible(false)
            else
                talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO35'))
                confirmBtn:setVisible(self.around)
            end
        else
            desctx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO42')) 
            btnText:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO6'))
            if self.tab.visited == true then   --表示已掠夺
                talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO36'))
                ShaderMgr:restoreWidgetDefaultShader(talkbg)
                confirmBtn:setVisible(false)
            else
                talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO37'))
                confirmBtn:setVisible(self.around)
            end
            infotx:removeAllChildren()
            infotx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO7'))
        end 

    elseif showType == 2 then           --水井，雕像，石塔

        local animation = self.tab.visited and 'open' or 'close'
        local model = GlobalApi:createLittleLossyAniByName(dfelementConfig.url)
        if model~=nil then
            local winSize = buildimg:getSize()
            model:setScale(2.3*dfelementConfig.scale)
            model:setAnchorPoint(cc.p(0.5,0.5))
            model:getAnimation():play(animation, -1, 1)
            model:setPosition(cc.p(winSize.width/2,winSize.height/2))
            buildimg:addChild(model)
        end 
        local disPlayData = DisplayData:getDisplayObjs(dfelementConfig.award)
        for i=1,2 do
            local awardsnode = pl:getChildByName('award_node_'..i)
            local awards = disPlayData[i]
            if awards then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, awardsnode)
                local num = awards:getNum()
                local subType = awards:getSubtype()
                if self.resId == TerritorialWarMgr.resourceType.well then
                    if subType == 'staying_power' then
                        num = TerritorialWarMgr:getRealCount('enduranceRecover',num)
                    elseif subType == 'action_point' then
                        num =TerritorialWarMgr:getRealCount('actionRecover',num)
                    end
                end
                cell.lvTx:setString('x'..num)
                cell.awardBgImg:setScale(0.9)
            end
        end
        confirmBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:collectElement(self.cellId,dfelementConfig.isCost)
            end
        end)
        btnText:setString(dfelementConfig.btText)
        --访问图标
        if self.tab.visited == true then
            confirmBtn:setVisible(false)
            ShaderMgr:restoreWidgetDefaultShader(talkbg)
            talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO38'))
            flag = 3
        end
        infodesctx:setString(dfelementConfig['desc'..flag])
    elseif showType == 3 then                   --传送门

        --获取军团传送等级
        local openLv = tonumber(dfbaseparaConfig['portalOpenLevel'].value[1])
        local llevel = UserData:getUserObj():getLLevel()
        local legionOpen = (llevel >= openLv) and true or false 
        local infoTxtab = {}
        local infoTx1 = pl:getChildByName('info_tx1')
        infoTx1:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_INFO45"))
        infoTxtab[1] = infoTx1
        local infoTx2 = pl:getChildByName('info_tx2')
        infoTx2:setString(openLv .. GlobalApi:getLocalStr("LEGION_LV_DESC"))
        infoTxtab[2] = infoTx2
        local color = legionOpen and COLOR_TYPE.GREEN or COLOR_TYPE.RED
        infoTx2:setColor(color)
        local infoTx3 = pl:getChildByName('info_tx3')
        infoTx3:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT36"))
        infoTxtab[3] = infoTx3
        --访问自己领地石碑总量
        local limitCount = tonumber(dfbaseparaConfig['invadeLimit'].value[1])
        local steleCount = TerritorialWarMgr:getSteleCount()
        if steleCount == nil then
            return
        end
        local animation = (steleCount >= limitCount) and 'open' or 'close'
        local model = GlobalApi:createLittleLossyAniByName(dfelementConfig.url)
        if model~=nil then
            local winSize = buildimg:getSize()
            model:setScale(2.3*dfelementConfig.scale)
            model:setAnchorPoint(cc.p(0.5,0.5))
            model:getAnimation():play('close', -1, 1)
            model:setPosition(cc.p(winSize.width/2,winSize.height/2))
            buildimg:addChild(model)
        end 
        local disPlayData = DisplayData:getDisplayObjs(dfelementConfig.award)
        self.chooseLid = 1
        self.enemylegion = {}
        self.enemyData = self.tab.data
        local flag = 1              --访问石碑数达到传送开启条件且有地方军团 flag = 3
        local enemyCount =  #self.enemyData.enemyList
        if steleCount >= limitCount and  enemyCount == 2 and legionOpen then
            flag = 3
        elseif steleCount >= limitCount and enemyCount ~= 2 and legionOpen then
            flag = 2   
        end

        --开启图标
        if steleCount >= limitCount then
            talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO39'))
            ShaderMgr:restoreWidgetDefaultShader(talkbg)
        else
            talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO40'))
        end
        local desctx = pl:getChildByName('desc_tx')
        local infotx = pl:getChildByName('info_tx')

        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(280, 80))
        richText:setAlignment('left')
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF12'), 22,cc.c4b(249,227,204, 255))
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextLabel:create(steleCount, 22, cc.c4b(249,227,204, 255))
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        if steleCount < limitCount then
            re2:setColor(COLOR_TYPE.RED)
        else
            re2:setColor(COLOR_TYPE.GREEN)
        end
        local re3 = xx.RichTextLabel:create('/'..limitCount, 22, cc.c4b(249,227,204, 255))
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:format(true)
        richText:setPosition(cc.p(135,0))
        infotx:addChild(richText)

        local iconConf = GameData:getConfData("legionicon")
        for i=1,2 do
            local awardsnode = pl:getChildByName('award_node_'..i)
            local legionbg = awardsnode:getChildByName('legion_bg')
            local legionicon = legionbg:getChildByName('legion_icon')
            local legionnametx = legionbg:getChildByName('name_tx')
            self.enemylegion[i] = legionbg
            if self.enemyData.enemyList and self.enemyData.enemyList[i] then
                legionnametx:setString(self.enemyData.enemyList[i].name)
                local iconId = self.enemyData.enemyList[i].icon or i
                legionnametx:setTextColor(COLOR_TYPE[iconConf[iconId].nameColor])
                legionbg:loadTexture(COLOR_FRAME[iconConf[iconId].frameQuality])
                legionicon:loadTexture(iconConf[iconId].icon)
            end
            legionbg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    self:chooseEnemy(i)
                end
            end)
        end

        confirmBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then               
                --传送到目标军团
                 MessageMgr:sendPost('transfer','territorywar',json.encode({targetLid = self.chooseLid}),function (response)
                    local code = response.code
                    local data = response.data
                    if code ~= 0 then
                        TerritorialWarMgr:handleErrorCode(code)
                        return
                    end
                    TerritorialWarMgr:setBattleEnd(nil,nil,nil)
                    TerritorialWarMgr:hideElementVTUI()
                    TerritorialWarMgr:showMapUI()
                end)
            end
        end)
        btnText:setString(dfelementConfig.btText)
        if flag == 3 then
            confirmBtn:setVisible(self.around)
            for i=1,2 do
                if self.enemylegion[i] then
                    self.enemylegion[i]:setVisible(true)
                end
            end
            desctx:setString('')
            infotx:removeAllChildren()
            for i=1,3 do
                infoTxtab[i]:setString("")
            end
            self:chooseEnemy(1)
        else
            confirmBtn:setVisible(false)
            for i=1,2 do
                self.enemylegion[i]:setVisible(false)
            end
            if flag == 2 then
                for i=1,3 do
                    infoTxtab[i]:setString("")
                end
                infotx:removeAllChildren()
                desctx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF22'))
            else
               desctx:setString('')
            end
        end
        infodesctx:setString(dfelementConfig['desc'..flag])
    elseif showType == 4 then                       --哨塔，石碑，遗迹
        
        local visited = self.tab.visited
        if self.resId == TerritorialWarMgr.resourceType.stele then
            visited = TerritorialWarMgr:getSteleState(self.cellId)
        end
        local animation = visited and 'open' or 'close'
        local model = GlobalApi:createLittleLossyAniByName(dfelementConfig.url)
        if model~=nil then
            local winSize = buildimg:getSize()
            model:setScale(2.3*dfelementConfig.scale)
            model:setAnchorPoint(cc.p(0.5,0.5))
            model:getAnimation():play(animation, -1, 1)
            model:setPosition(cc.p(winSize.width/2,winSize.height/2))
            buildimg:addChild(model)
        end
        local disPlayData = DisplayData:getDisplayObjs(dfelementConfig.award)
        local infotx = pl:getChildByName('info_tx')
        infotx:setString('')
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(400, 300))
        richText:setAnchorPoint(cc.p(0,1))
        richText:setPosition(cc.p(0,0))
        richText:setAlignment('left')
        richText:setVerticalAlignment('top')
        infotx:addChild(richText)

        local str = dfelementConfig['fucDesc']
        for i=1,#str do
            if i ~= 1 then
                local re1 = xx.RichTextLabel:create('\n',22, COLOR_TYPE.WHITE)
                re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
                richText:addElement(re1)
            end
            xx.Utils:Get():analyzeHTMLTag(richText,str[i])
        end
        richText:format(true)


        confirmBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                TerritorialWarMgr:collectElement(self.cellId,dfelementConfig.isCost)
            end
        end)
        btnText:setString(dfelementConfig.btText)
        if visited == true then
            confirmBtn:setVisible(false)
            ShaderMgr:restoreWidgetDefaultShader(talkbg)
            talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO38'))
            flag = 3
        end
        infodesctx:setString(dfelementConfig['desc'..flag])
    elseif showType == 5 then                       --敌方进入入口

        local limitCount = tonumber(dfbaseparaConfig['invadeLimit'].value[1])
        local steleCount = TerritorialWarMgr:getSteleCount()
        if steleCount == nil then
            return
        end
        local animation = (steleCount >= limitCount) and 'open' or 'close'
        local model = GlobalApi:createLittleLossyAniByName(dfelementConfig.url)
        if model~=nil then
            local winSize = buildimg:getSize()
            model:setScale(2.3*dfelementConfig.scale)
            model:setAnchorPoint(cc.p(0.5,0.5))
            model:getAnimation():play(animation, -1, 1)
            model:setPosition(cc.p(winSize.width/2,winSize.height/2))
            buildimg:addChild(model)
        end
        --开启图标
        if steleCount >= limitCount then
            talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO39'))
            ShaderMgr:restoreWidgetDefaultShader(talkbg)
            flag = 2
        else
            talktx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO40'))
            flag = 1
        end

        local infotx = pl:getChildByName('info_tx')
        infotx:setString('')
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(400, 300))
        richText:setAnchorPoint(cc.p(0,1))
        richText:setPosition(cc.p(0,0))
        richText:setAlignment('left')
        richText:setVerticalAlignment('top')
        infotx:addChild(richText)
        local str = dfelementConfig['fucDesc']
        for i=1,#str do
            if i ~= 1 then
                local re1 = xx.RichTextLabel:create('\n',22, COLOR_TYPE.WHITE)
                re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
                richText:addElement(re1)
            end
            xx.Utils:Get():analyzeHTMLTag(richText,str[i])
        end
        richText:format(true)
        confirmBtn:setVisible(false)
        infodesctx:setString(dfelementConfig['desc'..flag])
    end

    if TerritorialWarMgr.resourceType.stone_heap <= self.resId and self.resId <= TerritorialWarMgr.resourceType.signet then
       talkbg:setVisible(false)
    else
       talkbg:setVisible(true)
    end
end

function TerritorialWarsElementVTUI:chooseEnemy(index)
    
    if index == nil or index < 1 or index > 2 then
        return
    end
    self.chooseLid = self.enemyData.enemyList[index].lid
    for i=1,2 do
        if index == i then
            self.enemylegion[i]:loadTexture(legionIconBg.sel)
        else
            self.enemylegion[i]:loadTexture(legionIconBg.nor)
        end
    end
end

return TerritorialWarsElementVTUI