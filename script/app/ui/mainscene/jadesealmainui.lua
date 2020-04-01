local JadesealUI = class("JadesealUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local MAXAWARD = 6

local defaultNor = {  
    [1] = 'uires/ui/rankinglist_v3/rlistv3_huangcheng1.png',
    [2] = 'uires/ui/rankinglist_v3/rlistv3_shenjiang1.png',
}

local defaultSel = {
    
    [1] = 'uires/ui/rankinglist_v3/rlistv3_huangcheng2.png',
    [2] = 'uires/ui/rankinglist_v3/rlistv3_shenjiang2.png',
}
local defaultbtnbg = 'uires/ui/common/title_btn_nor_2.png'
local selbtnbg = 'uires/ui/common/title_btn_sel_2.png'

function JadesealUI:ctor()
	self.uiIndex = GAME_UI.UI_JADESEAL
    self.jadesealconf = GameData:getConfData('jadeseal')
    self.jadesealheroconf = GameData:getConfData('jadesealhero')
    self.selectid = 1
    self.selectpage = 1
    self.needref = true
end

function JadesealUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	local bgimg1 = bgimg:getChildByName("bg_img1")
    self:adaptUI(bgimg, bgimg1)
    self.jadesealbg = bgimg1:getChildByName('jadeseal_bg')
	self.jadesealpl = self.jadesealbg:getChildByName('jadeseal_pl')
    self.godpl = self.jadesealbg:getChildByName('god_pl')

    local bigtx = self.godpl:getChildByName('big_desc_tx')
    bigtx:setString(GlobalApi:getLocalStr('JADESEAL_DESC7'))

    local godnumtx = self.godpl:getChildByName('num_tx')
    godnumtx:setString('')
    local numtx = cc.LabelAtlas:_create('', "uires/ui/number/number1.png", 16, 22, string.byte('-'))
    numtx:setName('godnumtx')
    numtx:setAnchorPoint(cc.p(0.5,0.5))
    numtx:setPosition(cc.p(0,0))
    numtx:setScale(1.2)
    numtx:setString(MapData:getMaxStar())
    godnumtx:addChild(numtx)

    local winsize = cc.Director:getInstance():getWinSize()
    local closebtn = self.jadesealbg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideJadesealUI()
        end
    end)

    local action = cc.CSLoader:createTimeline("csb/jadesealmainpanel.csb")
    self.root:runAction(action)
    action:gotoFrameAndPlay(0,false)
    
    local titlebg = self.jadesealbg:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('JADESEAL_TITLE'))

    local listbg = self.jadesealpl:getChildByName('list_bg')
    self.listview = listbg:getChildByName('list_lv')
    self.listview:setScrollBarEnabled(false)

    local node = cc.CSLoader:createNode("csb/jadesealcell.csb")
    local cellbgimg = node:getChildByName("bg_img")
    self.listview:setItemModel(cellbgimg)
    self.num = #self.jadesealconf

    self.awardarr = {}
    local bgimg3 = self.jadesealpl:getChildByName('bg_img3')
    local funcpl = bgimg3:getChildByName('func_pl')
    local heropl = bgimg3:getChildByName('hero_pl')
    local functx = funcpl:getChildByName('f_tx')
    functx:setString(GlobalApi:getLocalStr('JADESEAL_DESC8'))
    local herotx = heropl:getChildByName('f_tx')
    herotx:setString(GlobalApi:getLocalStr('JADESEAL_DESC5'))

    for i=1,MAXAWARD do
        --local arr = {}
        local node = bgimg3:getChildByName('award_node_'..i)
        local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        -- arr.itembg = tab.awardBgImg
        -- arr.itembg:setScale(0.8)
        -- arr.numtx = tab.lvTx
        -- arr.iconimg = tab.awardImg
        -- arr.star = tab.starImg
        -- arr.starlv = tab.starLv
        tab.awardBgImg:setScale(0.8)
        node:addChild(tab.awardBgImg)
        self.awardarr[i] = tab
    end
    self.selbtn = {}
    self.selbtn[1] = self.jadesealbg:getChildByName('jadeseal_btn')
    self.selbtn[2] = self.jadesealbg:getChildByName('god_btn')
    local selbtntx1 = self.selbtn[1]:getChildByName('btn_tx')
    selbtntx1:setString(GlobalApi:getLocalStr('JADESEAL_DESC10'))
    local selbtntx2 = self.selbtn[2]:getChildByName('btn_tx')
    selbtntx2:setString(GlobalApi:getLocalStr('JADESEAL_DESC9'))
    self.btntx = {}
    self.btntx[1] = self.selbtn[1]:getChildByName('btn_tx')
    self.btntx[2] = self.selbtn[2]:getChildByName('btn_tx')
    self.btnimg = {}
    self.btnimg[1] = self.selbtn[1]:getChildByName('btn_img')
    self.btnimg[2] = self.selbtn[2]:getChildByName('btn_img')
    self.btnnewimg = {}
    self.btnnewimg[1] = self.selbtn[1]:getChildByName('new_img')
    self.btnnewimg[2] = self.selbtn[2]:getChildByName('new_img')
    for i=1,2 do
        self.selbtn[i]:addTouchEventListener(function (sender, eventType)
            if eventType ==ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then 
                for j=1,2 do
                    self.selbtn[j]:loadTextureNormal(defaultbtnbg)
                    self.btnimg[j]:loadTexture(defaultNor[j])
                    self.btntx[j]:setTextColor(COLOR_TYPE.DARK)
                    self.btntx[j]:enableOutline(COLOROUTLINE_TYPE.DARK)
                end
                self.selectpage = i
                self.selbtn[i]:loadTextureNormal(selbtnbg)
                self.btnimg[i]:loadTexture(defaultSel[i])
                self.btntx[i]:setTextColor(COLOR_TYPE.PALE)
                self.btntx[i]:enableOutline(COLOROUTLINE_TYPE.PALE)
                self:update()
            end
        end)
        self.btnnewimg[i]:setVisible(false)
    end
    self:updateSelPage()
    self:update()
end

function JadesealUI:onShow()
    self:updateSelPage()
    self:update()
end

function JadesealUI:updateSelPage()
    for i=1,2 do
        if tonumber(self.selectpage) == i then
            self.selbtn[i]:loadTextureNormal(selbtnbg)
            self.btnimg[i]:loadTexture(defaultSel[i])
            self.btntx[i]:setTextColor(COLOR_TYPE.PALE)
            self.btntx[i]:enableOutline(COLOROUTLINE_TYPE.PALE)
        end
    end
end

function JadesealUI:update()
    self.jadesealdata = UserData:getUserObj():getJadeSeal() 
    self.jadesealherodata = UserData:getUserObj():getJadeSealHero() 
    for i=1,2 do
        self.btnnewimg[i]:setVisible(false)
    end
    self:calcHeros()
    self:calcJadeseal()
    printall(self.jadesealdata)
    if self.needref == true then
        self.listview:removeAllItems()
        for i=1,#self.jadesealconf do
            if  tonumber(self.jadesealdata[tostring(i)]) ~= 1 then
                self.selectid = i
                break
            end
        end
    end

    if self.selectid > #self.jadesealconf then
        self.selectid = #self.jadesealconf
    end
    --self:updateJadesealPl()
    if self.selectpage == 1 then
        self.jadesealpl:setVisible(true)
        self.godpl:setVisible(false)
        self:initListView()
        if self.needref == true then
            self.listview:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function ()
                self.needref = false
                self.listview:scrollToItem(self.selectid-1,cc.p(0,0),cc.p(0,0),0.3)
            end)))
        end
        -- for i=1,#self.jadesealconf do
        --     if self.jadesealstatetab[i] == 2 then
        --         self.selectid = i
        --         break
        --     end
        -- end
        --self.listview:jumpToItem(self.selectid,cc.p(240,230),cc.p(0.5,0.5))
        self:updateJadesealPl()

    else
        self.jadesealpl:setVisible(false)
        self.godpl:setVisible(true)
        self:updateGodPl()
    end
end

function JadesealUI:loadBy1FPS(amount, view, callback)
    local index = 0
    local function update()
        if index < amount then
            callback(index)
        else
            view:unscheduleUpdate()
        end
        index = index + 1
    end
    view:scheduleUpdateWithPriorityLua(update, 0)
end

function JadesealUI:initListView()
    if table.getn(self.listview:getItems()) == 0 then
        local function callback(index)
            self:initListItem(index)
        end
        self:loadBy1FPS(#self.jadesealconf, self.root, callback)
    end
end

function JadesealUI:initListItem(index)
    self.listview:pushBackDefaultItem()
    self:setListItem(index)
    local item = self.listview:getItem(index)
end

function JadesealUI:setListItem( index)
    local item = self.listview:getItem(index)
    local data = self.jadesealconf[index+1]
    local databefor = self.jadesealconf[index]
    local star = 0
    if databefor and databefor.star then
        star = databefor.star
    end
    item:setVisible(true)
    local bgimg = item:getChildByName('bg_img1')
    local iconimg = bgimg:getChildByName('icon_img')
    iconimg:loadTexture('uires/ui/jadeseal/jadeseal_'..data.jadesealicon)
    local nametx = bgimg:getChildByName('name_tx')
    local numbertx = bgimg:getChildByName('number_tx')
    local lightimg = item:getChildByName('light_img')
    lightimg:setVisible(false)
    local getimg = bgimg:getChildByName('get_img')
    local starimg = bgimg:getChildByName('star_img')

    if self.selectid-1 == index then
        lightimg:setVisible(true)
        local spineAni = GlobalApi:createLittleLossyAniByName('ui_jadeseal_select_effect')
        spineAni:setPosition(cc.p(lightimg:getContentSize().width/2,lightimg:getContentSize().height/2))
        spineAni:setLocalZOrder(101)
        lightimg:addChild(spineAni)
        spineAni:getAnimation():playWithIndex(0, -1, 1)
    else
        bgimg:removeChildByTag(9527)
        lightimg:removeAllChildren()
    end
    
    nametx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --if MapData:getMaxStar() >= star then
                self.selectid = index+1
                self:updateJadesealPl()        
            -- else
            --     promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('JADESEAL_DESC2'),star), COLOR_TYPE.RED)
            -- end
            for j=1,self.num do
                local item = self.listview:getItem(j-1)
                local lightimg = item:getChildByName('light_img')
                local bgimg = item:getChildByName('bg_img1')
                lightimg:removeAllChildren()
                bgimg:removeChildByTag(9527)
                if j ~= index+1 then
                    lightimg:setVisible(false)
                else
                    lightimg:setVisible(true)
                    local spineAni = GlobalApi:createLittleLossyAniByName('ui_jadeseal_select_effect')
                    spineAni:setPosition(cc.p(lightimg:getContentSize().width/2,lightimg:getContentSize().height/2))
                    spineAni:setLocalZOrder(101)
                    lightimg:addChild(spineAni)
                    spineAni:getAnimation():playWithIndex(0, -1, 1)
                    -- local particle = cc.ParticleSystemQuad:create("particle/ui_jadeseal_select_effect_p.plist")
                    -- particle:setTag(9527)
                    -- particle:setPosition(cc.p(bgimg:getContentSize().width/2,bgimg:getContentSize().height/2))
                    -- item:addChild(particle,999)
                end
            end
        end 
    end)
    numbertx:removeAllChildren()
    if self.jadesealdata and self.jadesealdata[tostring(index+1)]  then
        nametx:setString(data.name)
        nametx:setFontName('font/gamefont.ttf')
        nametx:setVisible(true)
        starimg:setVisible(false)
        numbertx:setVisible(false)
        getimg:setVisible(false)
    else
        -- 暂时去掉领取图标
        -- getimg:setVisible(true) 
        getimg:setVisible(false)
        nametx:setVisible(false)
        nametx:setFontName('font/gamefont.ttf')
        --numbertx:setString(MapData:getMaxStar()..'/'..data.star)
        --numbertx:removeAllChildren()
        numbertx:setString('')
        local numtx = cc.LabelAtlas:_create('', "uires/ui/number/number1.png", 16, 22, string.byte('-'))
        numtx:setName('lv_tx')
        numtx:setAnchorPoint(cc.p(0.5,0.5))
        numtx:setPosition(cc.p(0,0))
        numtx:setScale(0.8)
        numtx:setString(MapData:getMaxStar().."/".. data.star)
        numbertx:addChild(numtx)
        starimg:setVisible(true)
    end
    if MapData:getMaxStar() >= star then
        ShaderMgr:restoreSpriteDefaultShader(bgimg)
        ShaderMgr:restoreSpriteDefaultShader(iconimg)           
        nametx:enableOutline(COLOR_TYPE.BLACK, 1)
        nametx:setTextColor(COLOR_TYPE.WHITE)
               
    else
        ShaderMgr:setGrayForWidget(bgimg)
        ShaderMgr:setGrayForWidget(iconimg)
        nametx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 2)
        nametx:setTextColor(COLOR_TYPE.WHITE) 
        numbertx:setString('')
        local numtx = cc.LabelAtlas:_create('', "uires/ui/number/number1.png", 16, 22, string.byte('-'))
        numtx:setName('lv_tx')
        numtx:setAnchorPoint(cc.p(0.5,0.5))
        numtx:setPosition(cc.p(0,0))
        numtx:setScale(0.8)
        numtx:setString(MapData:getMaxStar().."/".. data.star)
        numbertx:addChild(numtx)
       -- getimg:setVisible(false)
    end

    if MapData:getMaxStar() >= data.star then
        --getimg:setVisible(true)
    else
        getimg:setVisible(false)
    end
end

function JadesealUI:updateJadesealPl()
    local bgimg3 = self.jadesealpl:getChildByName('bg_img3')
    local conf = self.jadesealconf[self.selectid]
    local displayobjs = DisplayData:getDisplayObjs(conf.awards)
    for i=1,MAXAWARD do
        if displayobjs[i] then
            ClassItemCell:updateItem(self.awardarr[i], displayobjs[i], 1)
            self.awardarr[i].awardBgImg:setVisible(true)
            self.awardarr[i].awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(displayobjs[i],false)
                end
            end)
            ClassItemCell:setGodLight(self.awardarr[i].awardBgImg, displayobjs[i]:getGodId())
        else
            self.awardarr[i].awardBgImg:setVisible(false)
        end
    end

    local att = clone(RoleData:getPosAttByPos(RoleData:getMainRole()))
    local curatt = {}
    curatt[1] = math.floor(att[1])
    curatt[2] = math.floor(att[4])
    curatt[3] = math.floor(att[2])
    curatt[4] = math.floor(att[3])
    local funcbtn = bgimg3:getChildByName('func_btn')
    -- 按钮小红点
    local btnred = funcbtn:getChildByName('red_img')
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    local funcpl = bgimg3:getChildByName('func_pl')
    local funcimg = funcpl:getChildByName('func_img')
    local heropl = bgimg3:getChildByName('hero_pl')
    local heroimg = heropl:getChildByName('hero_1_img')
    local heroimg2 = heropl:getChildByName('hero_2_img')
    local txbg = funcimg:getChildByName('functxbg_img')
    funcimg:removeChildByTag(9527)
    local img = ccui.ImageView:create('uires/ui/text/tx_yidacheng.png')
    img:setVisible(false)
    img:setTag(9527)
    funcimg:addChild(img)
    local tx = txbg:getChildByName('func_tx')
    tx:removeAllChildren()
    funcbtntx:setString(GlobalApi:getLocalStr('JADESEAL_DESC6'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if MapData:getMaxStar() >= conf.star then
                local args = {
                    jadeId = self.selectid,
                }
                MessageMgr:sendPost('get_awards','jadeseal',json.encode(args),function (jsonObj)
                    print(json.encode(jsonObj))
                    if jsonObj.code == 0 then
                        if not self.jadesealdata[tostring(self.selectid)] then
                            self.jadesealdata[tostring(self.selectid)] = 1
                        end
                        --判断是否是hero表的ID
                        local awards = jsonObj.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                        end
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        if tonumber(conf.unlock) and tonumber(conf.unlock) >1000 then
                            -- RoleData:setJunzhuObjId(conf.unlock)
                            -- local obj = RoleData:getMainRole()
                            -- local id = obj:getId()
                            -- id = id + 1000
                            RoleData:setJunzhuObjId(RoleData:getMainRole():getId()+1000) 
                            local obj1 = RoleData:getRoleInfoById(tonumber(conf.unlock))
                            local attnew = clone(RoleData:getPosAttByPos(RoleData:getMainRole()))
                            local nowatt = {}
                            nowatt[1] = math.floor(attnew[1])
                            nowatt[2] = math.floor(attnew[4])
                            nowatt[3] = math.floor(attnew[2])
                            nowatt[4] = math.floor(attnew[3])
                            RoleMgr:showStengthenPopupUI(RoleData:getMainRole(), 'upgrade_junzhu', curatt,nowatt , function ()
                                MainSceneMgr:showJadesealGetAwardUI(self.selectid,awards)
                                self.needref = true
                            end)
                        else
                            img:setRotation(-45)
                            img:setPosition(cc.p(29,-200))
                            img:setVisible(true)
                            img:setScale(2.0)
                            local action = cc.Spawn:create(cc.ScaleTo:create(0.2,1.0),cc.MoveTo:create(0.2, cc.p(29, 220)),cc.RotateTo:create(0.2,0))
                            img:runAction(cc.Sequence:create(action,cc.CallFunc:create(function ()
                                MainSceneMgr:showJadesealGetAwardUI(self.selectid,awards)
                                self.needref = true
                            end)))
                        end
                    end
                end)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('JADESEAL_DESC4'), COLOR_TYPE.RED)
            end
        end
    end)

    if tonumber(conf.unlock) and tonumber(conf.unlock) >1000 then
        heropl:setVisible(true)
        funcpl:setVisible(false)
        local obj = RoleData:getMainRole()
        local obj1 = RoleData:getRoleInfoById(tonumber(conf.unlock))
        local heroname = heroimg:getChildByName('hero_name_tx')
        heroname:setString(GlobalApi:getLocalStr('COLOR_'..(obj1:getQuality()-1))..GlobalApi:getLocalStr('QUALITY_DESC'))
        heroname:enableOutline(COLOROUTLINE_QUALITYFORJADESEAL[tonumber(obj1:getQuality()-1)],2)
        heroimg:loadTexture(COLOR_TABBG[tonumber(obj1:getQuality()-1)])
        heroimg:removeChildByTag(9527)
        local spineAni = GlobalApi:createLittleLossyAniByName(obj:getUrl() .. "_display", nil, obj:getChangeEquipState())
        if spineAni then
            spineAni:setScale(0.7)
            spineAni:setPosition(cc.p(55,30+ obj:getUiOffsetY()))
            spineAni:setTag(9527)
            spineAni:getAnimation():play('idle', -1, 1)
            heroimg:addChild(spineAni)
        end
        heroimg2:loadTexture(COLOR_TABBG[tonumber(obj1:getQuality())])
        heroimg2:removeChildByTag(9527)
        local heroname2 = heroimg2:getChildByName('hero_name_tx')
        heroname2:setString(GlobalApi:getLocalStr('COLOR_'..obj1:getQuality())..GlobalApi:getLocalStr('QUALITY_DESC'))
        heroname2:enableOutline(COLOROUTLINE_QUALITYFORJADESEAL[tonumber(obj1:getQuality())],2)
        local spineAni2 = GlobalApi:createLittleLossyAniByName(obj:getUrl() .. "_display", nil, obj:getChangeEquipState())
        if spineAni2 then
            spineAni2:setScale(0.7)
            spineAni2:setPosition(cc.p(55,30+ obj:getUiOffsetY()))
            spineAni2:setTag(9527)
            spineAni2:getAnimation():play('idle', -1, 1)
            heroimg2:addChild(spineAni2)
        end
    else
        funcpl:setVisible(true)
        heropl:setVisible(false)
        funcimg:ignoreContentAdaptWithSize(true)
        funcimg:loadTexture('uires/ui/jadeseal/jadeseal_'..conf.funcicon)
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(186, 33))
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
        tx:addChild(richText)
        xx.Utils:Get():analyzeHTMLTag(richText,conf.desc)
    end 

    if MapData:getMaxStar() >= conf.star then
        funcbtn:setBright(true)
        btnred:setVisible(true)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    else
        funcbtn:setBright(false)
        btnred:setVisible(false)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
    end
    if self.jadesealdata and self.jadesealdata[tostring(self.selectid)]  then
        funcbtn:setBright(false)
        btnred:setVisible(false)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        funcbtntx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
        img:setPosition(cc.p(29, 220))
        img:setTag(9527)
        img:setVisible(true)
    else
        funcbtn:setTouchEnabled(true)
    end
end

function JadesealUI:updateGodPl()
    local gotobtn = self.godpl:getChildByName('func_btn')
    gotobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --GlobalApi:getGotoByModule('battle')
            --MainSceneMgr:hideJadesealUI()
            MainSceneMgr:showCityCraftRemarkUI()
        end
    end) 
    local gototx =gotobtn:getChildByName('btn_tx')
    gototx:setString(GlobalApi:getLocalStr('JADESEAL_DESC11'))
    local listbg = self.godpl:getChildByName('list_bg') 
    self.goldview = listbg:getChildByName('list_lv')
    self.goldview:setScrollBarEnabled(false)
    if MainSceneMgr:getGetJadesealState() then
        self.goldview:removeAllItems()
    end
    local node = cc.CSLoader:createNode("csb/jadesealgodcell.csb")
    local cellbgimg = node:getChildByName("bg_img")
    MainSceneMgr:setGetJadesealState(false)
    self.goldview:setItemModel(cellbgimg) 
    self:godinitListView()
end

function JadesealUI:godloadBy1FPS(amount, view, callback)
    local index = 0
    local function updategod()
        if index < amount then
            callback(index)
        else
            view:unscheduleUpdate()
        end
        index = index + 1
    end
    view:scheduleUpdateWithPriorityLua(updategod, 0)
end

function JadesealUI:godinitListView()
    if table.getn(self.goldview:getItems()) == 0 then
        local function callback(index)
            self:godinitListItem(index)
        end
        self:godloadBy1FPS(#self.herotab, self.root, callback)
    end
end

function JadesealUI:godinitListItem(index)
    self.goldview:pushBackDefaultItem()
    self:godsetListItem(index)
    local item = self.goldview:getItem(index)
end

function JadesealUI:godsetListItem( index)
    local item = self.goldview:getItem(index)
    item:setName("item_" .. index)
    local data = self.jadesealconf[index+1]
    item:setVisible(true)
    local bgimg = item:getChildByName('bg_img1')
    local titlebg = bgimg:getChildByName('title_bg')
    local numbertx = titlebg:getChildByName('number_tx')
    local starimg = titlebg:getChildByName('star_img')
    local tableimg = bgimg:getChildByName('tab_img')
    local heroimg = bgimg:getChildByName('hero_img')
    local newimg = bgimg:getChildByName('new_img')
    --local jadeid = math.floor((self.herotab[index+1][1]-1)/3 +1)
    --local heroindex = self.heroimg
    local awards = self.jadesealheroconf[self.herotab[index+1][1]].awards
    local displayobj = DisplayData:getDisplayObjs(awards)

    local roleobj = RoleData:getRoleInfoById(displayobj[1]:getId())
    tableimg:loadTexture(roleobj:getTabIcon())
    titlebg:loadTexture(roleobj:getTitleIcon())
    if self.herotab[index+1][2] == 1 then   
        heroimg:loadTexture(roleobj:getBigIcon())
    else
        heroimg:loadTexture('uires/ui/jadeseal/jadeseal_hero.png')
    end
    numbertx:removeAllChildren()
    numbertx:setString('')
    local numtx = cc.LabelAtlas:_create('', "uires/ui/number/number1.png", 16, 22, string.byte('-'))
    numtx:setName('lv_tx')
    numtx:setAnchorPoint(cc.p(0.5,0.5))
    numtx:setPosition(cc.p(0,0))
    numtx:setScale(0.8)
    numtx:setString(MapData:getMaxStar().."/".. self.herotab[index+1][1])
    numbertx:addChild(numtx)
    local canget = false 
    if MapData:getMaxStar() >= self.herotab[index+1][1] then
        canget = true
        newimg:setVisible(true)
    else
        newimg:setVisible(false)
    end
    item:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:showJadesealAwardUI(self.herotab[index+1][1],canget)
        end
    end) 
end

function JadesealUI:calcHeros()
    local herarr = {}
    self.herotab = {}
    local havenum = 0
    local iscanget = false

    for k,v in pairs(self.jadesealheroconf) do
        local smallarr = {}
        local haveawardnum = 0
        if self.jadesealherodata and self.jadesealherodata[tostring(k)] then
            --herarr[k] = 1
            smallarr[1] = 1
        else
            --herarr[k] = 0
            smallarr[1] = 0
            if MapData:getMaxStar() >= k then
                -- print('xxxxxxxxxxxxx')
                iscanget = true
            end
        end
        local awards = v.awards
        for x=1,4 do
            if awards[x]  then
                haveawardnum = haveawardnum + 1
            end
        end
        smallarr[2] = haveawardnum
        herarr[k] = smallarr
    end
    for k,v in pairs(herarr) do
        if v[1] == 0 then
            local arr = {}
            arr[1] = k
            arr[2] = v[2]
            table.insert(self.herotab,arr)
        end
    end
   -- printall(self.herotab)
    table.sort(self.herotab,function (a,b)
        return a[1] < b[1]
    end)
    if iscanget then
        self.btnnewimg[2]:setVisible(true)
    end
end

function JadesealUI:calcJadeseal()
    self.jadesealstatetab = {}
    for i=1,#self.jadesealconf do
        if self.jadesealdata and  self.jadesealdata[tostring(i)]  then
            self.jadesealstatetab[i] = 3
        else
            if  tonumber(self.jadesealdata[tostring(i)]) ~= 1 and MapData:getMaxStar() >= self.jadesealconf[i]['star']  then
                self.btnnewimg[1]:setVisible(true)
                self.jadesealstatetab[i] = 2
            else
                self.jadesealstatetab[i] = 1
            end
        end     
    end
end
return JadesealUI
