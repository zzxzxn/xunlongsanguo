local LegionDonateUI = class("LegionDonateUI", BaseUI)
local ClassActiveBox = require('script/app/ui/mainscene/activeboxui')
function LegionDonateUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGION_DONATE
  self.data = data
end

function LegionDonateUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    local bgimg3 = bgimg2:getChildByName('bg_img1')
    self:adaptUI(bgimg1, bgimg2)
    local closebtn = bgimg3:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionDonateUI()
        end
    end)

    local titlebg = bgimg3:getChildByName('title_bg')
    local titletx =titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_DONATE_TITLE'))
    self.celltab = {}
    for i=1,3 do
        local tab = {}
        local cellbg = bgimg3:getChildByName('cell_'..i..'_bg')
        tab.name = cellbg:getChildByName('name_tx')
        tab.exptx = cellbg:getChildByName('exp_tx')
        tab.legiontx = cellbg:getChildByName('legion_tx')
        tab.buildtx = cellbg:getChildByName('build_tx')
        tab.btn = cellbg:getChildByName('build_btn')
        tab.btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())] 
                if vipconf['legionConstruct'] - self.data.count > 0 then
                    local constructconf = GameData:getConfData('legionconstruct')[i]                   
                    local displayobj = DisplayData:getDisplayObj(constructconf.cost[1])
                    local userconf = GameData:getConfData('user')[tostring(displayobj:getSubtype())]
                    local str = string.format(GlobalApi:getLocalStr('LEGION_DONATE_DESC10'),displayobj:getNum(),userconf.name)
                    UserData:getUserObj():cost(displayobj:getSubtype(),displayobj:getNum(),function()
                        self:buildMsg(i)
                    end,true,str)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_DONATE_DESC11'),COLOR_TYPE.RED)
                end
            end
        end)
        tab.btndesc = tab.btn:getChildByName('build_tx')
        tab.btnicon = tab.btn:getChildByName('build_icon')
        tab.btnnum =tab.btn:getChildByName('build_num') 
        self.celltab[i] = tab
    end

    for i=1,3 do
        local constructconf = GameData:getConfData('legionconstruct')[i]
        self.celltab[i].name:setString(constructconf.name)
        local richText = xx.RichText:create()
        self.celltab[i].exptx:addChild(richText)
        richText:setContentSize(cc.size(160, 28))
        richText:setPosition(cc.p(0,0))
        richText:setAlignment('left')
        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DONATE_DESC2')..":", 20, COLOR_TYPE.WHITE)
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re1:setFont('font/gamefont.ttf')
        local re2 = xx.RichTextLabel:create('+'..constructconf.xp, 20, COLOR_TYPE.GREEN)
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re2:setFont('font/gamefont.ttf')
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setVerticalAlignment('middle')
        richText:format(true)
        richText:setAnchorPoint(cc.p(0,0.5))

        local richText2 = xx.RichText:create()
        self.celltab[i].legiontx:addChild(richText2)
        richText2:setContentSize(cc.size(160, 28))
        richText2:setPosition(cc.p(0,0))
        richText2:setAlignment('left')
        local re21 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DONATE_DESC3')..":", 20, COLOR_TYPE.WHITE)
        re21:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re21:setFont('font/gamefont.ttf')
        local re22 = xx.RichTextLabel:create('+'..constructconf.legionCoin, 20, COLOR_TYPE.GREEN)
        re22:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re22:setFont('font/gamefont.ttf')
        richText2:addElement(re21)
        richText2:addElement(re22)
        richText2:setVerticalAlignment('middle')
        richText2:format(true)
        richText2:setAnchorPoint(cc.p(0,0.5))

        local richText3 = xx.RichText:create()
        self.celltab[i].buildtx:addChild(richText3)
        richText3:setContentSize(cc.size(160, 28))
        richText3:setPosition(cc.p(0,0))
        richText3:setAlignment('left')
        local re31 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DONATE_DESC4')..":", 20, COLOR_TYPE.WHITE)
        re31:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re31:setFont('font/gamefont.ttf')
        local re32 = xx.RichTextLabel:create('+'..constructconf.progress, 20, COLOR_TYPE.GREEN)
        re32:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re32:setFont('font/gamefont.ttf')
        richText3:addElement(re31)
        richText3:addElement(re32)
        richText3:setVerticalAlignment('middle')
        richText3:format(true)
        richText3:setAnchorPoint(cc.p(0,0.5))

        self.celltab[i].btndesc:setString(GlobalApi:getLocalStr('LEGION_DONATE_DESC5'))
        local displayobj = DisplayData:getDisplayObj(constructconf.cost[1])
        self.celltab[i].btnnum:setString(displayobj:getNum())
        self.celltab[i].btnicon:loadTexture(displayobj:getIcon())
    end

    self.buildnum = bgimg3:getChildByName('build_num') 

    self.buildnumrichText = xx.RichText:create()
    self.buildnum:addChild(self.buildnumrichText)
    self.buildnumrichText:setContentSize(cc.size(200, 28))
    self.buildnumrichText:setPosition(cc.p(0,0))
    self.buildnumrichText:setAlignment('left')
    local buildnumre1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DONATE_DESC6')..":", 20, COLOR_TYPE.WHITE)
    buildnumre1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    buildnumre1:setFont('font/gamefont.ttf')
    self.buildnumre2 = xx.RichTextLabel:create('23/61', 20, COLOR_TYPE.ORANGE)
    self.buildnumre2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.buildnumre2:setFont('font/gamefont.ttf')
    self.buildnumrichText:addElement(buildnumre1)
    self.buildnumrichText:addElement(self.buildnumre2)
    self.buildnumrichText:setVerticalAlignment('middle')
    self.buildnumrichText:format(true)
    self.buildnumrichText:setAnchorPoint(cc.p(0,0.5))

    self.canbuildnum = bgimg3:getChildByName('can_build_num')

    self.canbuildnumrichText = xx.RichText:create()
    self.canbuildnum:addChild(self.canbuildnumrichText)
    self.canbuildnumrichText:setContentSize(cc.size(300, 28))
    self.canbuildnumrichText:setPosition(cc.p(0,0))
    self.canbuildnumrichText:setAlignment('right')
    local canbuildnumre1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DONATE_DESC7')..":", 20, COLOR_TYPE.WHITE)
    canbuildnumre1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    canbuildnumre1:setFont('font/gamefont.ttf')
    self.canbuildnumre2 = xx.RichTextLabel:create('15', 20, COLOR_TYPE.GREEN)
    self.canbuildnumre2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.canbuildnumre2:setFont('font/gamefont.ttf')
    self.canbuildnumrichText:addElement(canbuildnumre1)
    self.canbuildnumrichText:addElement(self.canbuildnumre2)
    self.canbuildnumrichText:setVerticalAlignment('middle')
    self.canbuildnumrichText:format(true)
    self.canbuildnumrichText:setAnchorPoint(cc.p(1,0.5))


    local topbg = bgimg3:getChildByName('top_bg')
    self.totaltx = topbg:getChildByName('total_tx')

    self.totalrichText = xx.RichText:create()
    self.totaltx:addChild(self.totalrichText)
    self.totalrichText:setContentSize(cc.size(160, 28))
    self.totalrichText:setPosition(cc.p(0,0))
    self.totalrichText:setAlignment('left')
    local totalre1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DONATE_DESC1')..":", 20, COLOR_TYPE.ORANGE)
    totalre1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    totalre1:setFont('font/gamefont.ttf')
    self.totalre2 = xx.RichTextLabel:create('61', 20, COLOR_TYPE.WHITE)
    self.totalre2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.totalre2:setFont('font/gamefont.ttf')
    self.totalrichText:addElement(totalre1)
    self.totalrichText:addElement(self.totalre2)
    self.totalrichText:setVerticalAlignment('middle')
    self.totalrichText:format(true)
    self.totalrichText:setAnchorPoint(cc.p(0,0.5))

    self.barbg = topbg:getChildByName('bar_bg')
    self.bar = self.barbg:getChildByName('bar')
    self.barbox = {}
    for i=1,4 do
        local tab = {}
        tab.box = topbg:getChildByName('box_'..i..'_img')
        tab.num = tab.box:getChildByName('num_tx')
        self.barbox[i] = tab
    end
    local logbtn = bgimg3:getChildByName('log_btn')
    local logbtntx =logbtn:getChildByName("btn_tx")
    logbtntx:setString(GlobalApi:getLocalStr('LEGION_DONATE_DESC8'))
    logbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionLogUI()
        end
    end)

    self:update()
end

function LegionDonateUI:onShow()
    self:update()
end
function LegionDonateUI:update()
    self:updateTop()
    self:updateBottom()
end

function LegionDonateUI:isget(progress)
    local value = false
    for k,v in pairs(self.data.rewards) do
        if tostring(k) == tostring(progress) then
            value = true
            break
        end
    end
    return value
end
function LegionDonateUI:updateTop()
    self.totalre2:setString(self.data.progress)
    self.totalrichText:format(true)
    --local conf = GameData:getConfData('legionconstructreward')
    local temp = GameData:getConfData('legionconstructreward')
    local conf = {}
    for k,v in pairs(temp) do
        conf[#conf + 1] = v
    end
    table.sort( conf, function(a,b)
        return a.progress < b.progress
    end )
    local maxprogress = conf[#conf].progress
    local progress = self.data.progress or 0
    local index = 1
    local boxId = {1,1,2,3}
    local size = self.barbg:getContentSize()

    for i=1,4 do
        if progress >= conf[i].progress and self:isget(conf[i].progress) then
            index = index + 1
            self.barbox[i].box:loadTexture('uires/icon/material/box'..boxId[i]..'.png')
            ShaderMgr:setGrayForWidget(self.barbox[i].box)
            self.barbox[i].box:setTouchEnabled(false)
        end
        local isOpen = false
        local info
        if self:isget(conf[i].progress) == false and progress >= conf[i].progress then
            ShaderMgr:restoreWidgetDefaultShader(self.barbox[i].box)
            -- self.barbox[i].box:setTouchEnabled(true)
            isOpen = true
            info = GlobalApi:getLocalStr('STR_GET_1')
        else
            ShaderMgr:setGrayForWidget(self.barbox[i].box)
            -- self.barbox[i].box:setTouchEnabled(false)
            isOpen = false
            if i >= index then
                self.barbox[i].box:loadTexture('uires/icon/material/box'..boxId[i]..'.png')
            else
                self.barbox[i].box:loadTexture('uires/ui/common/box'..boxId[i]..'.png')
            end
            info = GlobalApi:getLocalStr('STR_OK2')
        end

        local numTx = self.barbox[i].box:getChildByName('num_tx')
        numTx:setString(conf[i].progress)
        self.barbox[i].box:ignoreContentAdaptWithSize(true)
        self.barbox[i].box:setLocalZOrder(2)
        self.barbox[i].box:setPosition(cc.p(conf[i].progress/maxprogress*size.width + 40,34))
        self.barbox[i].box:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local conf = GameData:getConfData('legionconstructreward')
                local tab = {}
                for k,v in pairs(conf) do
                    tab[#tab + 1] = v
                end
                table.sort( tab, function(a,b)
                    return a.progress < b.progress
                end )
                local confi = tab[i]
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(300, 30))
                richText:setAlignment('middle')
                local tx1 = GlobalApi:getLocalStr('LEGION_DONATE_DESC9')
                local tx2 = tostring(confi.progress)
                local tx3 = GlobalApi:getLocalStr('STR_CANGET')
                local re1 = xx.RichTextLabel:create(tx1, 25,COLOR_TYPE.ORANGE)
                local re2 = xx.RichTextLabel:create(tx2,25,COLOR_TYPE.WHITE)
                local re3 = xx.RichTextLabel:create(tx3,25,COLOR_TYPE.ORANGE)
                re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                re2:setStroke(COLOR_TYPE.BLACK, 1)
                re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                richText:addElement(re1)
                richText:addElement(re2)
                richText:addElement(re3)
                local awards = confi.award
                local ClassActiveBox = ClassActiveBox.new(GlobalApi:getLocalStr('LEGION_DONATE_DESC9'),info,richText,awards,isOpen,function(callback)
                    local args = {progress = confi.progress}
                    MessageMgr:sendPost('get_construct_reward','legion',json.encode(args),function (response)                  
                        local code = response.code
                        local data = response.data
                        if code == 0 then
                            local awards = data.awards
                            if awards then
                                GlobalApi:parseAwardData(awards)
                                GlobalApi:showAwardsCommon(awards,nil,nil,true)
                            end
                            
                            if not self.data.rewards then
                                local tab = {}
                                tab[tostring(confi.progress)] = 1
                                self.data.rewards = tab
                            else
                                self.data.rewards[tostring(confi.progress)] = 1
                            end
                            self:update()
                            if callback then
                                callback()
                            end
                        end
                    end)
                end)
                ClassActiveBox:showUI()
            end
        end)
        if isOpen and isOpen == true then
            self:playEffect(self.barbox[i].box)
        else
            if self.barbox[i].box.lvUp then
                self.barbox[i].box.lvUp:removeFromParent()
                self.barbox[i].box.lvUp = nil
            end
        end
    end
    self.bar:setPercent(self.data.progress/maxprogress*100)
end

function LegionDonateUI:playEffect(img)
    if img.lvUp then
        img.lvUp:removeFromParent()
        img.lvUp = nil
    end

    local parent = img:getParent()
    local img = img
    local posX = img:getPositionX()
    local posY = img:getPositionY()

    local size1 = img:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(posX ,posY + 32))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img:setLocalZOrder(101)
    --lvUp:setScale(0.75)
    parent:addChild(lvUp)

    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)

    img.lvUp = lvUp
end

function LegionDonateUI:updateBottom()
    local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())] 
    --local constnum = vipconf['legionConstruct']
    for i=1,3 do
    end
    self.buildnumre2:setString(self.data.all_count..'/'..self.data.member_count)
    self.buildnumrichText:format(true)
    self.canbuildnumre2:setString(vipconf['legionConstruct']-self.data.count)
    self.canbuildnumrichText:format(true)
end

function LegionDonateUI:buildMsg(typeid)
    local constructconf = GameData:getConfData('legionconstruct')[typeid]
    local args = {id = typeid}
    MessageMgr:sendPost('build_construct','legion',json.encode(args),function (response)                  
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end

            if self.data.count == 0 then
                self.data.all_count = self.data.all_count + 1 
            end
            self.data.count = self.data.count + 1
            UserData:getUserObj():setLegionConstructCount(self.data.count)
            self.data.progress = self.data.progress + constructconf.progress
            LegionMgr:setLegionConstructProgress(self.data.progress)
            self:update()
        end
    end)  
end
return LegionDonateUI