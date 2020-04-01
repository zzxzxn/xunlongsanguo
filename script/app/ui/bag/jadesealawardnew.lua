local JadeSealAwardNewUI = class("JadeSealAwardNewUI", BaseUI)

function JadeSealAwardNewUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_JADE_SEAL_AWARD_NEW
    self.obj = obj
    local userEffect = tonumber(self.obj:getUseEffect())
    self.conf = GameData:getConfData("herobox")[userEffect]
    self.selectid = nil
end 

function JadeSealAwardNewUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    self:adaptUI(bgimg)

    local winsize = cc.Director:getInstance():getWinSize()
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            BagMgr:hideJadeSealAwardNewUI()
        end
    end)

    local cell = bgimg:getChildByName('cell')
    cell:setVisible(false)

    local sv = bgimg:getChildByName('sv')
    sv:setContentSize(cc.size(winsize.width - 2*40,sv:getContentSize().height))
    sv:getInnerContainer():setContentSize(cc.size(winsize.width - 2*40,sv:getContentSize().height))
    sv:setPosition(cc.p(40,sv:getPositionY()))
    sv:setScrollBarEnabled(false)
    sv:setSwallowTouches(false)
    sv:setPropagateTouchEvents(true)

    local awards = self.conf.awards
    local displayobj = DisplayData:getDisplayObjs(awards)
    local num = #displayobj
    local cellSpace = 30
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width

    local width = num * cell:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    self.cardtab = {}

    local offset = 0
    local tempWidth = cell:getContentSize().width
    for i = 1,num,1 do
        local tempCell = cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

        local lightimg = tempCell:getChildByName('light_bg')
        lightimg:setVisible(false)
        local lightimg2 = GlobalApi:createLittleLossyAniByName('ui_tavern_card_effect')
        lightimg2:setScale(2.2)
        lightimg2:setPosition(cc.p(lightimg:getPositionX() + 3,lightimg:getPositionY() + 17))
        lightimg2:getAnimation():playWithIndex(0, -1, 1)
        lightimg2:getAnimation():setSpeedScale(0.8)
        lightimg2:setVisible(false)
        tempCell:addChild(lightimg2)
        tempCell.lightimg2 = lightimg2
        tempCell.i = i
        
        -- 
        local cardbg = tempCell:getChildByName('card_bg')
        local checkTx = cardbg:getChildByName('check_tx')
        checkTx:setVisible(false)
        tempCell.checkTx = checkTx

        if displayobj[i] then
            local roleobj = RoleData:getRoleInfoById(displayobj[i]:getId())
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

            cardbg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    if self.selectid == i then
                        ChartMgr:showChartInfo(nil,ROLE_SHOW_TYPE.NORMAL,roleobj)
                        return
                    end
                    self.selectid = i
                    for j = 1,#self.cardtab do
                        if j == i then
                            self.cardtab[j].lightimg2:setVisible(true)
                            self.cardtab[j].checkTx:setVisible(true)
                        else
                            self.cardtab[j].lightimg2:setVisible(false)
                            self.cardtab[j].checkTx:setVisible(false)
                        end
                    end
                end
            end)
        end
        table.insert(self.cardtab,tempCell)
    end
    innerContainer:setPositionX(0)

    --
    local awardtx = bgimg:getChildByName('awrad_tx')
    awardtx:setPosition(cc.p(winsize.width*0.5,awardtx:getPositionY()))
    awardtx:setString(GlobalApi:getLocalStr('JADESEAL_DESC3'))

    local desc = bgimg:getChildByName('desc')
    desc:setPosition(cc.p(winsize.width*0.5,desc:getPositionY()))
    desc:setString(self.obj:getDesc())

    -- ¡Ï»°
    local funcbtn = bgimg:getChildByName('func_btn')
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
            local args = {
                id = self.obj:getId(),
                index = self.selectid,
                num = 1,
            }
            MessageMgr:sendPost('use','bag',json.encode(args),function (jsonObj)
                print(json.encode(jsonObj))
                    if jsonObj.code == 0 then
                        BagMgr:hideJadeSealAwardNewUI()
                        local awards = jsonObj.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true) 
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

end

return JadeSealAwardNewUI
