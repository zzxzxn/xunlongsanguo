local JadesealAwardUI = class("JadesealAwardUI", BaseUI)

local MAXAWARD = 6
function JadesealAwardUI:ctor(star,canget)
	self.uiIndex = GAME_UI.UI_JADESEALAWARD
    self.jadesealheroconf = GameData:getConfData('jadesealhero')
    self.star = star
    self.selectid = 0
    self.canget = canget
end
function JadesealAwardUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	--local bgimg1 = bgimg:getChildByName("bg_img1")
    self:adaptUI(bgimg)
    local winsize = cc.Director:getInstance():getWinSize()
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideJadesealAwardUI()
        end
    end)
    local awardtx = bgimg:getChildByName('awrad_tx')
    self.checkTx = bgimg:getChildByName('check_tx')
    awardtx:setPosition(cc.p(winsize.width*0.5,awardtx:getPositionY()))
    awardtx:setString(GlobalApi:getLocalStr('JADESEAL_DESC3'))
    local awards = self.jadesealheroconf[self.star].awards
    local displayobj = DisplayData:getDisplayObjs(awards)
    --printall(awards)
    self.cardtab = {}
    local havenum = 0
    for i=1,4 do
                
        local cardbg = bgimg:getChildByName('card_'..i..'_bg')
        cardbg:setLocalZOrder(1)
        cardbg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
                self.selectid = i
                self:update()
            end
        end)
        
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
            else
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
                        if roleobj:getCamp() == 0 then
                            --ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,roleobj)
                        elseif roleobj:getCamp() ~= 5 then 
                            ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,roleobj)
                        end
                    else
                        self.selectid = i
                        self:update(funcbtn)
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

    local funcbtn = bgimg:getChildByName('func_btn')
    funcbtn:setPosition(cc.p(winsize.width*0.5,funcbtn:getPositionY()))
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_GET_1'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectid == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('JADESEAL_DESC12'), COLOR_TYPE.RED)
                return
            end
            if self.canget then
                local args = {
                    star = self.star,
                    index = self.selectid
                }
                MessageMgr:sendPost('get_hero','jadeseal',json.encode(args),function (jsonObj)
                    print(json.encode(jsonObj))
                        if jsonObj.code == 0 then
                            self.jadesealherodata = UserData:getUserObj():getJadeSealHero() 
                            if not self.jadesealherodata or not self.jadesealherodata[tostring(self.star)] then
                                self.jadesealherodata[tostring(self.star)] = 1
                            end
                            
                            local awards = jsonObj.data.awards
                            if awards then
                                GlobalApi:parseAwardData(awards)
                                local awards1 = self.jadesealheroconf[self.star].awards
                                local displayobj = DisplayData:getDisplayObjs(awards1)
                                if displayobj[self.selectid]:getObjType() == 'card' and displayobj[self.selectid]:getId() < 10000 then
                                    TavernMgr:showTavernAnimate(awards, function ()
                                        TavernMgr:hideTavernAnimate()
                                    end, 4)
                                else
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                                end
                            end
                            local costs = jsonObj.data.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            MainSceneMgr:hideJadesealAwardUI()
                            MainSceneMgr:setGetJadesealState(true)
                        end
                    end)
                end
            else
                --promptmgr:showSystenHint(GlobalApi:getLocalStr('JADESEAL_DESC4'), COLOR_TYPE.RED)
            end
        end)
    if self.canget then
        funcbtn:setBright(true)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    else
        funcbtn:setBright(false)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
    end
    self:update()
end

function JadesealAwardUI:update()
    if self.selectid == 0 then
        self.lightimg:setVisible(false)
        self.checkTx:setVisible(false)
    else
        self.lightimg:setVisible(true)
        local x = self.cardtab[self.selectid]:getPositionX()
        local y = self.cardtab[self.selectid]:getPositionY()
        self.lightimg:setPosition(cc.p(x + 3,y + 17))
        self.checkTx:setVisible(true)
        self.checkTx:setPosition(x,182)

        local awards1 = self.jadesealheroconf[self.star].awards
        local displayobj = DisplayData:getDisplayObjs(awards1)
        if displayobj[self.selectid]:getObjType() == 'card' and displayobj[self.selectid]:getId() > 10000 then
            self.checkTx:setVisible(false)
        end
    end


end

return JadesealAwardUI
