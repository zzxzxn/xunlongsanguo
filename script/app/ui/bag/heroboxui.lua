local HeroBoxUI = class("HeroBoxUI", BaseUI)

function HeroBoxUI:ctor(id,itemId,maxNum)
	self.uiIndex = GAME_UI.UI_HEROBOX
    self.selectid = nil
    self.itemId = itemId
    self.jadesealheroconf = GameData:getConfData('jadesealhero')
    self.conf = GameData:getConfData("herobox")[id]
    self.maxTimes = maxNum or 0
    self.times = 1
end

function HeroBoxUI:update()
    if self.maxTimes > 99 then
        self.maxTimes = 99
    end
    if self.maxTimes < 0 then
        self.maxTimes = 0
    end
    if self.times > self.maxTimes then
        self.times = self.maxTimes 
    end
    if self.times == 0 then
        self.times = 1
    end
    self.timesTx:setString(self.times)

    if self.times <= 1 then
        self.lessBtn:setTouchEnabled(false)
        self.lessBtn:setBright(false)
    else
        self.lessBtn:setTouchEnabled(true)
        self.lessBtn:setBright(true)
    end

    if self.times >= self.maxTimes then
        self.addBtn:setTouchEnabled(false)
        self.addBtn:setBright(false)
    else
        self.addBtn:setTouchEnabled(true)
        self.addBtn:setBright(true)
    end

    -- self.numTx:setString(string.format(GlobalApi:getLocalStr('HAD_NUM'),num))
end

function HeroBoxUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	--local bgimg1 = bgimg:getChildByName("bg_img1")
    self:adaptUI(bgimg)
    local winsize = cc.Director:getInstance():getWinSize()
    local closebtn = ccui.Button:create("uires/ui/common/btn_close.png")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BagMgr:hideHeroBox()
        end
    end)
    
    closebtn:setAnchorPoint(cc.p(1,1))
    closebtn:setPosition(cc.p(winsize.width,winsize.height))
    bgimg:addChild(closebtn)
    local pl = bgimg:getChildByName('pl')
    pl:setVisible(true)
    self.lessBtn = pl:getChildByName("less_btn")
    self.addBtn = pl:getChildByName("add_btn")
    self.timesTx = pl:getChildByName("times_tx")
    local maxBtn = pl:getChildByName("max_btn")
    local btnTx = maxBtn:getChildByName("info_tx")
    btnTx:setString(GlobalApi:getLocalStr('MAX'))
    pl:setPosition(cc.p(winsize.width/2,pl:getPositionY()))

    self.editbox = cc.EditBox:create(cc.size(120, 40), 'uires/ui/common/name_bg9.png')
    self.editbox:setPosition(self.timesTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    pl:addChild(self.editbox)
    self.timesTx:setLocalZOrder(2)

    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
        local edit = pSender
        local strFmt 
        if event == "began" then
            self.editbox:setText(self.times)
            self.timesTx:setString('')
        elseif event == "ended" then
            local num = tonumber(self.editbox:getText())
            if not num then
                self.editbox:setText('')
                self.timesTx:setString('0')
                self.times = 0
                return
            end
            if num > self.maxTimes then
                self.times = self.maxTimes
            elseif num < 1 then
                self.times = 0
            else
                self.times = num
            end
            self.editbox:setText('')
            self:update()
        end
    end)
    maxBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.times = self.maxTimes
            self:update()
        end
    end)
    self.lessBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.times > 1 then
                self.times = self.times - 1
                self:update()
            end
        end
    end)

    self.addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.times < self.maxTimes then
                self.times = self.times + 1
                self:update()
            end
        end
    end)

    local awardtx = bgimg:getChildByName('awrad_tx')
    self.checkTx = bgimg:getChildByName('check_tx')
    awardtx:setPosition(cc.p(winsize.width*0.5,awardtx:getPositionY()))
    awardtx:setString(GlobalApi:getLocalStr('JADESEAL_DESC3'))
    local awards = self.conf.awards
    local displayobj = DisplayData:getDisplayObjs(awards)
    --printall(awards)
    self.cardtab = {}
    local funcbtn = bgimg:getChildByName('func_btn')
    local havenum = 0
    for i=1,4 do
        local cardbg = bgimg:getChildByName('card_'..i..'_bg')
        cardbg:setLocalZOrder(1)
        if displayobj[i] then
            local roleobj = RoleData:getRoleInfoById(displayobj[i]:getId())
            havenum = havenum + 1
            cardbg:setVisible(true)
            cardbg:loadTexture(roleobj:getCardIcon())
            local heroimg = cardbg:getChildByName('hero_img')
            heroimg:loadTexture(roleobj:getBigIcon())
            local nametx = cardbg:getChildByName('name_tx')
            nametx:setString(roleobj:getName())
            local flagImg = cardbg:getChildByName('flag_img')
            local camp = roleobj:getCamp()
            if camp == 0 then
                flagImg:setVisible(false)
                nametx:setPositionX(82)
            else
                nametx:setPositionX(82)
                flagImg:setVisible(true)
                -- flagImg:loadTexture('uires/ui/citycraft/citycraft_flag_'..camp..'.png')
                flagImg:loadTexture('uires/ui/common/camp_'..camp..'.png')

            end
            local soldierimg  = cardbg:getChildByName('soldier_img')
            soldierimg:loadTexture('uires/ui/common/'..'soldier_'..roleobj:getSoldierId()..'.png')
            local chipimg = cardbg:getChildByName('chip_img')
            local chipnum = cardbg:getChildByName('chip_num')
            chipnum:setString('x ' .. displayobj[i]:getNum())
            if displayobj[i]:getObjType() == 'fragment' then
                chipnum:setVisible(true)
                chipimg:setVisible(true)
            else
                chipimg:setVisible(false)
                chipnum:setVisible(false)
            end
            self.cardtab[i] = cardbg

            cardbg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if self.selectid == i then
                        ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,roleobj)
                    else
                        self.selectid = i
                        self:updatePanel(funcbtn)
                    end
                end
            end)
        else
            cardbg:setVisible(false)
        end
    end
    if havenum == 1 then
        self.cardtab[1]:setPosition(cc.p(winsize.width*0.5,winsize.height*0.5))
        self.selectid = 1
    elseif havenum == 2 then
        self.cardtab[1]:setPosition(cc.p(winsize.width*0.35,winsize.height*0.5))
        self.cardtab[2]:setPosition(cc.p(winsize.width*0.65,winsize.height*0.5))
    elseif havenum == 3 then
        self.cardtab[1]:setPosition(cc.p(winsize.width*0.25,winsize.height*0.5))
        self.cardtab[2]:setPosition(cc.p(winsize.width*0.5,winsize.height*0.5))
        self.cardtab[3]:setPosition(cc.p(winsize.width*0.75,winsize.height*0.5))
    elseif havenum == 4 then
        self.cardtab[1]:setPosition(cc.p(winsize.width*0.16,winsize.height*0.5))
        self.cardtab[2]:setPosition(cc.p(winsize.width*0.3885,winsize.height*0.5))
        self.cardtab[3]:setPosition(cc.p(winsize.width*0.6115,winsize.height*0.5))
        self.cardtab[4]:setPosition(cc.p(winsize.width*0.8396,winsize.height*0.5))
    end
    local lightimg = bgimg:getChildByName('light_bg')
    lightimg:setVisible(false)
    self.lightimg = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
    self.lightimg:setScale(2.2)
    self.lightimg:setPosition(lightimg:getPosition())
    self.lightimg:getAnimation():playWithIndex(0, -1, 1)
    self.lightimg:getAnimation():setSpeedScale(0.8)
    bgimg:addChild(self.lightimg)
    self.lightimg:setVisible(true)
    
    funcbtn:setPosition(cc.p(winsize.width*0.5,funcbtn:getPositionY()))
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_GET_1'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if not self.selectid or self.selectid < 1 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('JADESEAL_DESC12'), COLOR_TYPE.RED)
                return
            end
            if self.maxTimes == 0 or self.times == 0 then
                return
            end
            local args = {
                id = self.itemId,
                index = self.selectid,
                num = self.times,
            }
            MessageMgr:sendPost('use','bag',json.encode(args),function (jsonObj)
                print(json.encode(jsonObj))
                    if jsonObj.code == 0 then
                        BagMgr:hideHeroBox()
                        local awards = jsonObj.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            local a = DisplayData:getDisplayObj(awards)
                            if a:getObjType() == 'card' then
                                TavernMgr:showTavernAnimate(awards, function ()
                                    TavernMgr:hideTavernAnimate()
                                end, 4)
                            else
                                GlobalApi:showAwards(awards)
                            end
                        end
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                    end
                end)
            end
        end)


    self:updatePanel(funcbtn)
    self:update()
end

function HeroBoxUI:updatePanel(funcbtn)
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    if self.selectid then
        local x = self.cardtab[self.selectid]:getPositionX()
        local y = self.cardtab[self.selectid]:getPositionY()
        self.lightimg:setVisible(true)
        self.lightimg:setPosition(cc.p(x + 3,y + 17))
        funcbtn:setBright(true)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        self.checkTx:setVisible(true)
        self.checkTx:setPosition(x,182)
    else
        self.lightimg:setVisible(false)
        funcbtn:setBright(false)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        self.checkTx:setVisible(false)
    end
end

return HeroBoxUI
