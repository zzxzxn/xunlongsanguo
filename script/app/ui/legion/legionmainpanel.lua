local LegionMainUI = class("LegionMainUI", BaseUI)
function LegionMainUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONMAIN
  self.data = data
  self.membertab = {}
  self.selectsorttype = 3 --默认职位排序
end

function LegionMainUI:onShow()
    self:update()
    if self.guideWhenOnShow then
        self.guideWhenOnShow = nil
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.LEGION)
    end
end
function LegionMainUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getWinSize()
    bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    self.alphabg = self.root:getChildByName('alpha_bg')
    self.alphabg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    -- self.alphabg:setTouchEnabled(false)
    local stageImg = bgimg:getChildByName('stage_img')
    stageImg:setLocalZOrder(4)
    local closebtn = self.root:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionMainUI()
        end
    end)
    closebtn:setPosition(cc.p(winSize.width,winSize.height))

    local conf = GameData:getConfData('local/legionbuilding')
    self.plarr = {}
    for i=1,#conf do
        self.plarr[i] = bgimg:getChildByName('func_'..i..'_pl') 
        self.plarr[i]:setSwallowTouches(false)
    end
    for i,v in ipairs(conf) do
        local plPos = cc.p(self.plarr[v.pos]:getPositionX(),self.plarr[v.pos]:getPositionY())
        self.plarr[v.pos]:setLocalZOrder(v.zorder)
        if tonumber(conf.visble) == 0 then
            self.plarr[v.pos]:setVisible(false)
        end
        local namebg = self.plarr[v.pos]:getChildByName('name_bg')
        namebg:setLocalZOrder(99999)

        if i == 13 then
            self.donateinfo = namebg:getChildByName("new_img")
        end
        if  i == 2  then
            self.plarr[i]:setVisible(false)
        end
        local nametx = namebg:getChildByName('name_tx')
        nametx:setString('')
        local newimg = namebg:getChildByName('new_img')
        newimg:setVisible(false)
        local nameimg = namebg:getChildByName('name_img')
        nameimg:loadTexture('uires/ui/legion/legion_'..v.nameurl)
        nameimg:ignoreContentAdaptWithSize(true)
        local building = ccui.ImageView:create('uires/ui/legion/legion_'..v.url..'.png')
        local size = self.plarr[v.pos]:getContentSize()
        building:setPosition(cc.p(size.width/2,size.height/2))
        self.plarr[v.pos]:addChild(building)
        building:setTouchEnabled(true)
        building:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                building:runAction(cc.ScaleTo:create(0.1,0.85))
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.moved then
                building:runAction(cc.ScaleTo:create(0.1,1))
            elseif eventType == ccui.TouchEventType.ended then
                building:runAction(cc.ScaleTo:create(0.1,1))
                self:openPanel(i)
                -- self.alphabg:setTouchEnabled(false)
            end
        end)

        --玩家城池满行动力
        if i == 6 then
            self:showFullActionTip(self.plarr[v.pos])
        end

        -- self.plarr[v.pos]:addTouchEventListener(function (sender, eventType)
        --     if i == 2  then
        --         return
        --     end
        --     if eventType == ccui.TouchEventType.began then
        --         AudioMgr.PlayAudio(11)
        --     elseif eventType == ccui.TouchEventType.ended then
        --         self.alphabg:setTouchEnabled(true)
        --     end
        -- end)
        
    end

    local arr = {
        [1] = {1,4},
        [2] = {5,8},
        [3] = {9,12},
    }
    local roles = {'lvbu','daqiao','xiaoqiao'}
    for i=1,#roles do
        local ran = math.random(1, #roles)
        self:runRole(roles[ran], arr[ran])
        table.remove(roles, ran)
        table.remove(arr, ran)
    end
    -- self:runRole()
    self:update()
end

function LegionMainUI:showFullActionTip(obj)
    local step = UserData:getUserObj():getMark().step or {}
    local flag = (not step[tostring(GUIDE_ONCE.TERRITORIAL_CITY)]) and true or false
    if flag then
        return
    end

    local maopaoBg = ccui.ImageView:create('uires/ui/activity/limitbuy_qipao.png')
    maopaoBg:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height-20))
    obj:addChild(maopaoBg,9998)
    maopaoBg:setScale(0.4)
    local maopaoTx = ccui.Text:create()
    maopaoTx:setFontName("font/gamefont.ttf")
    maopaoTx:setFontSize(20)
    maopaoTx:setColor(COLOR_TYPE.OFFWHITE)
    maopaoTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    maopaoTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT51"))
    maopaoTx:setPosition(cc.p(obj:getContentSize().width/2,obj:getContentSize().height-12))
    obj:addChild(maopaoTx,9999)

    --满行动力提示
    local curPoint = UserData:getUserObj():getActionPoint()
    local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
    local max = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
    maopaoTx:setVisible(curPoint >= max)
    maopaoBg:setVisible(curPoint >= max)
end

function LegionMainUI:onShowUIAniOver()
    if not UserData:getUserObj():getName() or UserData:getUserObj():getName() == "" then
        self.guideWhenOnShow = true
    else
        GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.LEGION)
    end
end

function LegionMainUI:openPanel(index)
    local legionconf = GameData:getConfData('legion')
    if index == 1 then
        --军团战
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        if self.data.level < tonumber(legionconf['legionWarShowMinJoinLevel'].value) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionWarShowMinJoinLevel'].value), COLOR_TYPE.RED)
            return
        end
        LegionMgr:showLegionWarMainUI()
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 2 then
        --后宫
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 3 then
        --摇钱树
        if self.data.level < tonumber(legionconf['legionGoldTreeOpenLevel'].value) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionGoldTreeOpenLevel'].value), COLOR_TYPE.RED)
            return
        end
        LegionMgr:showLegionActivityShakeUI(self.data)
    elseif index == 4 then
        --活动大厅
        LegionMgr:showLegionActivityMainUI(self.data)
    elseif index == 5 then
        LegionMgr:showLegionMemberListUI()
        --成员大厅
    elseif index == 6 then

        --玩家城池
        local legionCfg = GameData:getConfData("legion")
        local limitLv = tonumber(legionCfg["legionDfOpenLevel"].value)
        local llevel = tonumber(UserData:getUserObj():getLLevel())
              llevel = llevel and llevel or 0
        local legionOpen = (llevel >= limitLv) and true or false 
        if not legionOpen then
            local errStr = string.format(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO46'),limitLv)
            promptmgr:showSystenHint(errStr, COLOR_TYPE.RED)
            return
        end
        
        LegionMgr:showLegionCityMainUI()
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 7 then
        --组队挂机
        --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        GlobalApi:getGotoByModule('legionTrial')
    elseif index == 8 then
        --待定
        -- promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        MainSceneMgr:showShop(51,{min = 51,max = 54})
    elseif index == 9 then
        --待定
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
    elseif index == 10 then
        if self.data.level < tonumber(legionconf['legionCopyOpenLevel'].value) then
            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT2'),legionconf['legionCopyOpenLevel'].value), COLOR_TYPE.RED)
            return
        end
        LegionMgr:showLegionLevelsMainUI()
        --军团远征
    elseif index == 11 then
        --排行榜
        RankingListMgr:showRankingListMain(5,nil)
    elseif index == 12 then
        --仙盟使馆
        LegionMgr:showLegionLogUI()
    elseif index == 13 then
        --修缮
        LegionMgr:showLegionDonateUI()
    end
end

function LegionMainUI:runRole(url, rans)
    local bgimg = self.root:getChildByName("bg_img")
    local obj = RoleData:getMainRole()
    local conf = GameData:getConfData('local/legionnpcpos')
    -- local id = math.random(1,#conf)
    local id = math.random(rans[1], rans[2])
    local spine = GlobalApi:createLittleLossyAniByName(url.."_display")
    spine:setScale(0.2)
    spine:setLocalZOrder(conf[id].order)
    spine:setPosition(cc.p(conf[id].posX + 110,conf[id].posY + 40))
    spine:setAnchorPoint(cc.p(0.5,0))
    bgimg:addChild(spine)

    local oldId = id
    local function run(currId)
        spine:getAnimation():play('idle', -1, 1)
        local arr = conf[currId].nextIds
        local function getRandom()
            -- repeat
                local random = math.random(1,#arr)
                -- if arr[random] ~= oldId then
                if arr[random] then
                    return arr[random]
                end
            -- until false
        end
        local endId = getRandom()
        local pos = cc.p(spine:getPositionX(),spine:getPositionY())
        local endPos = cc.p(conf[endId].posX + 110,conf[endId].posY + 40)
        spine:runAction(cc.Sequence:create(cc.DelayTime:create(math.random(3,5)),
            cc.CallFunc:create(function()
                local order = spine:getLocalZOrder()
                if conf[endId].order < order then
                    spine:setLocalZOrder(conf[endId].order)
                end
                if conf[endId].order == conf[currId].order then
                    spine:setLocalZOrder(conf[endId].order)
                end
                if pos.x < endPos.x then
                    spine:setScaleX(math.abs(spine:getScaleX()))
                else
                    spine:setScaleX(-math.abs(spine:getScaleX()))
                end
                spine:getAnimation():play('run', -1, 1)
            end),
            cc.MoveTo:create(5,cc.p(endPos)),
            cc.CallFunc:create(function()
                oldId = currId
                run(endId)
            end)))
    end
    run(id)
end

function LegionMainUI:update()

    local function getState()
        local step = UserData:getUserObj():getMark().step or {}
        local flag = (not step[tostring(GUIDE_ONCE.TERRITORIAL_CITY)]) and true or false
        return flag
    end

    local conf = GameData:getConfData('legion')
    local buildingconf = GameData:getConfData('local/legionbuilding')
    local legioninfo = UserData:getUserObj():getLegionInfo()
    local llevel = UserData:getUserObj():getLLevel()
    local status = {
        UserData:getUserObj():getSignByType('legion_war'),
        false,
        UserData:getUserObj():getSignByType('legion_goldtree'),
        UserData:getUserObj():getSignByType('legion_boon') or 
        UserData:getUserObj():getSignByType('legion_trial') or 
        UserData:getUserObj():getSignByType('legion_mercenary') or
        UserData:getUserObj():getSignByType('legion_wish'),
        UserData:getUserObj():getSignByType('legion_member_hall'),
        getState(),
        UserData:getUserObj():getSignByType('legionTrial'),
        false,
        false,
        UserData:getUserObj():getSignByType('legion_copy'),
    }
    for i=1,10 do
        local namebg = self.plarr[buildingconf[i].pos]:getChildByName('name_bg')
        local newimg = namebg:getChildByName('new_img')
        if newimg then
            newimg:setVisible(status[i])
        end
    end
    if UserData:getUserObj():getSignByType('legion_construct') then
        self.donateinfo:setVisible(true)
    else
        self.donateinfo:setVisible(false)
    end

end

function LegionMainUI:CalcRedInfo()
    
end
return LegionMainUI