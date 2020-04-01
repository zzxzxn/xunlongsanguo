local TavernRecruitAwardUI = class("TavernRecruitAwardUI", BaseUI)

function TavernRecruitAwardUI:ctor(awards,parent,isLevel)
	self.uiIndex = GAME_UI.UI_ACTIVE_TAVERN_ACTIVE_AWARD
    self.selectid = 0
    self.canget = true
    self.awards = awards
    self.parent = parent
    self.isLevel = isLevel
end
function TavernRecruitAwardUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    self:adaptUI(bgimg)
    local winsize = cc.Director:getInstance():getWinSize()
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)
    local awardtx = bgimg:getChildByName('awrad_tx')
    self.checkTx = bgimg:getChildByName('check_tx')
    awardtx:setPosition(cc.p(winsize.width*0.5,awardtx:getPositionY()))
    awardtx:setString(GlobalApi:getLocalStr('JADESEAL_DESC3'))
    local awards = self.awards
    local displayobj = DisplayData:getDisplayObjs(awards)
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
                nametx:setPositionX(74)
            else
                nametx:setPositionX(92)
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
                    index = self.selectid
                }
                local act = 'get_tavern_recruit_generals'
                if self.isLevel then
                    act = 'get_tavern_recruit_level_generals'
                end
                MessageMgr:sendPost(act,'activity',json.encode(args),function (jsonObj)
                    print(json.encode(jsonObj))
                        if jsonObj.code == 0 then
                            local awards = jsonObj.data.awards
                            if awards then
                                GlobalApi:parseAwardData(awards)
                                local awards1 = self.awards
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
                        end
                    end)
                end
            else
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

function TavernRecruitAwardUI:update()
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

        local awards1 = self.awards
        local displayobj = DisplayData:getDisplayObjs(awards1)
        if displayobj[self.selectid]:getObjType() == 'card' and displayobj[self.selectid]:getId() > 10000 then
            self.checkTx:setVisible(false)
        end
    end
end

return TavernRecruitAwardUI
