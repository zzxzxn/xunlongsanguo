local GuardMapUI = class("GuardMapUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function GuardMapUI:ctor(data)
	self.uiIndex = GAME_UI.UI_GUARDMAP
    self.cityBtn = {}
    self.data = GuardMgr:getAllCityData()
    self.enterdata = data --进入领地的玩家信息学，如果是自己的领地，则为nil
end

function GuardMapUI:init()
	self.bgImg = self.root:getChildByName("guard_bg_img")

    local winSize = cc.Director:getInstance():getVisibleSize()
    self.bgImg:setPosition(cc.p(winSize.width / 2, winSize.height /2))

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.GUARD)
    btn:setPosition(cc.p(35,winSize.height - 75))
    self.root:addChild(btn)


    self.closebtn = self.root:getChildByName('close_btn')
    self.closebtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
          GuardMgr:hideGuardMap()
        end
    end)
    self.closebtn:setPosition(cc.p(winSize.width,winSize.height))
    self.skillBtn = self.root:getChildByName('skill_btn')
    self.skillBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
           GuardMgr:showGuardSkill()
        end
    end)

    self.skillBtnNewImg = ccui.ImageView:create('uires/ui/common/new_img.png')
    self.skillBtn:addChild(self.skillBtnNewImg)
    self.skillBtnNewImg:setPosition(cc.p(90,79))
    self.skillBtnNewImg:setVisible(UserData:getUserObj().friendExploreStatus)

	self.skillBtn:setAnchorPoint(cc.p(0,0))
	self.skillBtn:setPosition(cc.p(5,5))
	self.friendBtn = self.root:getChildByName('friend_btn')
    self.friendBtn:addTouchEventListener(function (sender, eventType)
        if eventType ==  ccui.TouchEventType.ended then
            if UserData:getUserObj():getLid() > 0 then
                GuardMgr:showGuardFriendList()
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
            end
        end
    end)
	self.friendBtn:setAnchorPoint(cc.p(1,0.5))
	self.friendBtn:setPosition(cc.p(winSize.width-5,160))
	self.backBtn = self.root:getChildByName('back_btn')
	self.backBtn:setAnchorPoint(cc.p(1,0))
	self.backBtn:setPosition(cc.p(winSize.width-5,5))
	self.backBtn:addTouchEventListener(function (sender, eventType)
		if eventType ==  ccui.TouchEventType.ended then
            self.enterdata = nil
            GuardMgr:setEnterdata(nil)
		    self:update()
		end
	end)
    self.namebg = self.root:getChildByName('name_bg')
    self.nametx = self.namebg:getChildByName('name_tx')
    self.namebg:setPosition(cc.p(-1,winSize.height))

    self:update()
    self:updateNewImg()
    GuardMgr:getFreeTimes()
end

function GuardMapUI:onShow()
    self.enterdata = GuardMgr:getEnterdata()
    self:update()
    self:updateNewImg()
end

function GuardMapUI:updateNewImg()
    local judge = false

    local data = GuardMgr:getAllCityData()
	local guardSkillConf  = GameData:getConfData('guardskill')	
	for i = 1,6 do
		local skillConf = guardSkillConf[i]
        local guard = data.guard
        local field = data.guard.field

        if field[tostring(i)] then
            local skill = field[tostring(i)].skill
            if skill == 0 then
                if tonumber(guard.accumulate) >= skillConf[tonumber(field[tostring(i)].skill) + 1]['need'] then
                    local cost = skillConf[tonumber(field[tostring(i)].skill) + 1]['costs'][1]
				    local displayobj = DisplayData:getDisplayObj(cost)
                    if displayobj:getNum() <= UserData:getUserObj():getCash() then
                        judge = true
                        break
                    end
                end
            end
        end

     end

    self.skillBtnNewImg:setVisible(judge)
end

function GuardMapUI:update()
    local winSize = cc.Director:getInstance():getVisibleSize()
    if self.enterdata and tonumber(self.enterdata[1]) > 0 then
        self.closebtn:setVisible(false)
        self.backBtn:setVisible(true)
        self.friendBtn:setAnchorPoint(cc.p(1,0.5))
        self.friendBtn:setPosition(cc.p(winSize.width-5,160))       
    else
        self.closebtn:setVisible(true)
        self.backBtn:setVisible(false)
        self.friendBtn:setAnchorPoint(cc.p(1,0))
        self.friendBtn:setPosition(cc.p(winSize.width-5,5))
    end 
    local redbg = self.friendBtn:getChildByName('info_img')
    local repressnumtx = redbg:getChildByName('info_num') 
    local repressnum = GlobalApi:getGlobalValue('guardRepressLimitEachDay') - UserData:getUserObj():getGuard().repress
    repressnumtx:setString(repressnum)
    if repressnum > 0  and UserData:getUserObj():getLid() > 0 then
        redbg:setVisible(true)
    else
        redbg:setVisible(false)
    end
    for i = 1, 6 do
        self:updateCity(i)
    end
end

function GuardMapUI:updateCity(id)
    local conf = GameData:getConfData('guardfield')[id]  
    local cityBtn = self.bgImg:getChildByName('city_' .. id .. '_btn')
    local nameTx = cityBtn:getChildByName('name_tx')
    nameTx:setString(conf.name)
    local lvLimitTx = cityBtn:getChildByName('lv_limit_tx')
    local topIco = cityBtn:getChildByName('top_ico')
    topIco:removeAllChildren()
    topIco:ignoreContentAdaptWithSize(true)
    if self.enterdata and tonumber(self.enterdata[1]) > 0 then
        self.nametx:setString(self.enterdata[2].un)
        local playerLv = self.enterdata[2].level
        cityBtn:addTouchEventListener(function (sender, eventType)
            if eventType ==  ccui.TouchEventType.ended then
                if tonumber(self.enterdata[5][tonumber(id)]) == 1 then
                    local args = {
                        target = self.enterdata[1],
                        id = id
                    }
                    MessageMgr:sendPost('repress','guard',json.encode(args),function (response)
                        
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

                            self.enterdata[5][tonumber(id)] = 0
                            
                            table.insert(UserData:getUserObj():getGuard().repress_list,tonumber(self.enterdata[1]))
                            UserData:getUserObj():getGuard().repress = UserData:getUserObj():getGuard().repress + 1
                            GuardMgr:getAllCityData().guard.repress = GuardMgr:getAllCityData().guard.repress + 1
                            --repress = repress - 1
                            self:update()
                        elseif code == 102 then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC38'), COLOR_TYPE.RED)
                        end
                    end)
                elseif self.enterdata[2].field  then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC36'), COLOR_TYPE.RED)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC35'), COLOR_TYPE.RED)
                end
            end
        end)
        topIco:addTouchEventListener(function (sender, eventType)
            if eventType ==  ccui.TouchEventType.ended then
                if tonumber(self.enterdata[5][tonumber(id)]) == 1 then
                    local args = {
                        target = self.enterdata[1],
                        id = id
                    }
                    MessageMgr:sendPost('repress','guard',json.encode(args),function (response)
                        
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

                            self.enterdata[5][tonumber(id)] = 0
                            table.insert(UserData:getUserObj():getGuard().repress_list,tonumber(self.enterdata[1]))
                            UserData:getUserObj():getGuard().repress = UserData:getUserObj():getGuard().repress + 1
                            GuardMgr:getAllCityData().guard.repress = GuardMgr:getAllCityData().guard.repress + 1
                            self:update()
                        elseif code == 102 then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC38'), COLOR_TYPE.RED)
                        end
                    end)
                elseif self.enterdata[2].field and self.enterdata[2].field[id] then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC36'), COLOR_TYPE.RED)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC35'), COLOR_TYPE.RED)
                end
            end
        end)
        if playerLv >= tonumber(conf.level) then
            cityBtn:setTouchEnabled(true)
            topIco:setTouchEnabled(true)
            topIco:setVisible(true)
            lvLimitTx:setVisible(false)
            cityBtn:setBright(true)
            --ShaderMgr:restoreWidgetDefaultShader(cityBtn)
            id = tostring(id)
            if self.enterdata[2].field then
                if self.enterdata[5] and tonumber(self.enterdata[5][tonumber(id)]) == 1 then
                    -- 暴乱
                    topIco:setVisible(true)
                    topIco:loadTexture('uires/ui/guard/guard_baodong.png')
                else
                    topIco:loadTexture('uires/ui/common/bg1_alpha.png')
                end
            else
                topIco:setVisible(true)
                topIco:loadTexture('uires/ui/common/bg1_alpha.png')
                --print(#self.data.field)
                local num = 0
                for k,v in pairs(self.data.guard.field) do
                    num = num + 1
                end
                if tonumber(id) == num + 1 and self.enterdata == nil then
                    local fightainmintion = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
                    if fightainmintion then
                        fightainmintion:setPosition(cc.p(topIco:getContentSize().width/2,topIco:getContentSize().height/2))
                        fightainmintion:setTag(9527)
                        fightainmintion:setAnimation(0, 'animation', true)
                        topIco:addChild(fightainmintion)
                    end
                end

            end
        else
           -- ShaderMgr:setGrayForWidget(cityBtn)
            cityBtn:setBright(false)
            cityBtn:setTouchEnabled(false)
            topIco:setVisible(false)
            topIco:setTouchEnabled(false)
            lvLimitTx:setVisible(false)
            lvLimitTx:setString('')
        end
    else
        local playerLv = UserData:getUserObj():getLv()
        topIco:setTouchEnabled(true)
        cityBtn:addTouchEventListener(function (sender, eventType)
            if eventType ==  ccui.TouchEventType.ended then
                if playerLv >= tonumber(conf.level) then
                    GuardMgr:showGuardMain(id)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC1'), COLOR_TYPE.RED)
                    return
                end
            end
        end)

        topIco:addTouchEventListener(function (sender, eventType)
            if eventType ==  ccui.TouchEventType.ended then
                if playerLv >= tonumber(conf.level) then
                    GuardMgr:showGuardMain(id)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC1'), COLOR_TYPE.RED)
                    return
                end
            end
        end)

        self.nametx:setString(string.format(GlobalApi:getLocalStr('GUARD_DESC33'),GuardMgr:getFreeTimes()))
        local num = 0
        for k,v in pairs(self.data.guard.field) do
            num = num + 1
        end
        if playerLv >= tonumber(conf.level) and id <= num+1 then
            --ShaderMgr:restoreWidgetDefaultShader(cityBtn)
            cityBtn:setBright(true)
            cityBtn:setTouchEnabled(true)
            topIco:setVisible(true)
            lvLimitTx:setVisible(false)
            nameTx:setVisible(true)
            --printall(self.data.guard.field)
            id = tostring(id)
            if self.data.guard.field and self.data.guard.field[id] then
                --local types = self.data.guard.field[id].type
                local status = self.data.guard.field[id].status
                local time = self.data.guard.field[id].time
                local hid = self.data.guard.field[id].hid


                if status == 0 and time == 0 then
                    --未巡逻
                    topIco:loadTexture('uires/ui/guard/guard_add_ico.png')
                elseif status == 0 and time ~= 0 then
                    --领奖
                    topIco:loadTexture('uires/ui/guard/guard_jiangli.png')
                elseif status == 1 then
                    -- 巡逻中
                    topIco:loadTexture('uires/ui/common/bg1_alpha.png')
                    local roleobj = RoleData:getRoleInfoById(hid)
                    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, roleobj, topIco)
                    local awardsize = cell.awardBgImg:getContentSize()
                    local chipImg = ccui.ImageView:create('uires/ui/guard/guard_xunluo.png')
                    chipImg:setAnchorPoint(cc.p(0.5,0.5))
                    chipImg:setPosition(cc.p(awardsize.width/2,-10)) 
                    cell.awardBgImg:setTouchEnabled(false)
                    cell.awardBgImg:addChild(chipImg)
                    cell.awardBgImg:setPosition(cc.p(topIco:getContentSize().width/2,topIco:getContentSize().height/2))
                elseif status == 2 then
                    -- 暴乱
                    topIco:loadTexture('uires/ui/guard/guard_baodong.png')
                elseif status == 3 then
                    -- 暴乱
                end
            else
                topIco:setVisible(true)
                topIco:loadTexture('uires/ui/common/bg1_alpha.png')
                if tonumber(id) == num + 1 then
                    local fightainmintion = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
                    if fightainmintion then
                        fightainmintion:setPosition(cc.p(topIco:getContentSize().width/2,topIco:getContentSize().height/2))
                        fightainmintion:setTag(9527)
                        fightainmintion:setAnimation(0, 'animation', true)
                        topIco:addChild(fightainmintion)
                    end
                end

            end
        else
           -- ShaderMgr:setGrayForWidget(cityBtn)
            cityBtn:setBright(false)
            cityBtn:setTouchEnabled(false)
            topIco:setVisible(false)
            lvLimitTx:setVisible(true)
            nameTx:setVisible(false)
           if playerLv < tonumber(conf.level) then              
                lvLimitTx:setString(string.format(GlobalApi:getLocalStr('GUARD_LVLIMIT'),conf.level))
            else
                local conf1 = GameData:getConfData('guardfield')[id-1]
                if conf1 then
                    local str = string.format(GlobalApi:getLocalStr('GUARD_DESC34'),conf1.name)
                    lvLimitTx:setString(str)
                else
                    lvLimitTx:setString('')
                end
            end
        end
    end

    if CampaignMgr then
        CampaignMgr:updateShowGuard()
    end
end

return GuardMapUI
