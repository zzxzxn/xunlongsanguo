local LegionCityMainUI = class("LegionCityMainUI", BaseUI)

local ClassLegionCityCompareUI = require('script/app/ui/legion/legioncity/legioncitycompare')
local ClassItemCell = require('script/app/global/itemcell')

function LegionCityMainUI:ctor(data)
    self.uiIndex = GAME_UI.UI_LEGIONCITYMAINUI
    self.data = data
end

function LegionCityMainUI:onShow()
    self:update()
end
function LegionCityMainUI:init()
    self.bgimg = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getWinSize()
    self.bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))

    self.bgimg:getChildByName('guaji_bg'):getChildByName('name_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC30'))
    self.bgimg:getChildByName('guaji_bg'):setVisible(false)

    local bottompl = self.root:getChildByName('bottom_pl')
    local plunderName = bottompl:getChildByName('plunder_name')
    plunderName:getChildByName('name_tx'):setString(GlobalApi:getLocalStr('LEGION_CITY_DESC31'))
    bottompl:setPosition(cc.p(winSize.width/2,0))
    plunderName:setVisible(false)

    self.listbtn = self.root:getChildByName('list_btn')
    self.listbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionCityListUI(self.memberarr)
        end
    end)   
    -- local listbtntx = self.listbtn:getChildByName('btn_tx')
    -- listbtntx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC6'))
    self.listbtn:setPosition(cc.p(winSize.width,0))

    local suipian = self.root:getChildByName('sui_bg')
    local suipianTx = self.root:getChildByName('sui_text')
    self.mycitybtn = self.root:getChildByName('mycity_btn')
    self.mycitybtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {}
            MessageMgr:sendPost("get_city_info", "legion", json.encode(args), function (jsonObj)
            
                print(json.encode(jsonObj))
                local code = jsonObj.code
                if code == 0 then
                    UserData:getUserObj():setLegionCityInfo(jsonObj.data.city)
                    LegionMgr:showLegionCityUpgradeUI()
                end
            end)
        end
    end)   
    -- local listbtntx = self.listbtn:getChildByName('btn_tx')
    -- listbtntx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC6'))
    self.mycitybtn:setPosition(cc.p(winSize.width,100))
    local btnSize = self.mycitybtn:getContentSize()
    suipian:setPosition(cc.p(winSize.width-btnSize.width/2-20,100+btnSize.height))
    suipianTx:setPosition(cc.p(winSize.width-btnSize.width/2-20,110+btnSize.height))
    suipianTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT52"))
    local step = UserData:getUserObj():getMark().step or {}
    local flag = (not step[tostring(GUIDE_ONCE.TERRITORIAL_CITY)]) and true or false
    if flag then
        suipian:setVisible(false)
        suipianTx:setVisible(false)
    else
        --判断碎片
        suipianTx:setVisible(self.data.full)
        suipian:setVisible(self.data.full)
    end

    local backbtn = self.root:getChildByName('back_btn')
    backbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionCityMainUI()
        end
    end)
    self.probtn = self.root:getChildByName('pro_btn')
    self.probtn:setPosition(cc.p(0,winSize.height/2))
    self.probtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            self.selectPage = self.selectPage - 1 
            if self.selectPage < 1 then 
                self.selectPage = self:getTotalPage()
            end
            self:update()
            --self:changePos(self.obj:getPosId(),false)
        end
    end) 
    self.nextbtn = self.root:getChildByName('next_btn')
    GlobalApi:arrowBtnMove(self.probtn,self.nextbtn)
    self.nextbtn:setPosition(cc.p(winSize.width,winSize.height/2))
    self.nextbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            self.selectPage = self.selectPage + 1
            if self.selectPage > self:getTotalPage() then
                self.selectPage = 1
            end
            self:update()
            --self:changePos(self.obj:getPosId(),false)
        end
    end) 
    backbtn:setPosition(cc.p(winSize.width,winSize.height))
    -- local backbtntx = backbtn:getChildByName('btn_tx')
    -- backbtntx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC7'))

    self.plunderbtn = bottompl:getChildByName('plunder_btn')
    self.plunderbtn:setTouchEnabled(false)
    self.plunderbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --LegionMgr:showLegionCityAttackListUI(self.data)
            --promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_CITY_DESC23'), COLOR_TYPE.RED)
            promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED) 
        end
    end)  

    local guajibtn = self.bgimg:getChildByName('guaji_btn')
    guajibtn:setVisible(false)
    guajibtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
        end
    end)      
    local areabg = self.root:getChildByName('area_bg')
    areabg:setPosition(cc.p(0,winSize.height-10))
    areabg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionCityAreaSelectUI(self.data)
        end
    end)
    self.areaimg = areabg:getChildByName('area_img')
    self.areanumbg = areabg:getChildByName('num_bg')
    self.areanumtx =self.areanumbg:getChildByName('num_tx')
    local mainbg = self.bgimg:getChildByName('city_main_pl')
    local namebg = mainbg:getChildByName('name_bg')
    local mainbtn = mainbg:getChildByName('city_btn')
    local nameTx = namebg:getChildByName('name_tx')
    nameTx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC33'))
    mainbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            --promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_CITY_DESC8'), COLOR_TYPE.RED)
            --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
            --����̽����ͼ
            TerritorialWarMgr:showMapUI()
        end
    end)

    --满行动力提示
    local fullactionBg = mainbg:getChildByName("fullaction_bg")
    local actiontx = mainbg:getChildByName("action_tx")
    actiontx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT51"))
    local step = UserData:getUserObj():getMark().step or {}
    local flag = (not step[tostring(GUIDE_ONCE.TERRITORIAL_CITY)]) and true or false
    if flag then
        actiontx:setVisible(false)
        fullactionBg:setVisible(false)
    else
        local curPoint = UserData:getUserObj():getActionPoint()
        local actionPointMax = tonumber(GameData:getConfData('dfbasepara').actionLimit.value[1])
        local max = TerritorialWarMgr:getRealCount('actionMax',actionPointMax)
        actiontx:setVisible(curPoint >= max)
        fullactionBg:setVisible(curPoint >= max)
    end

    self.cityarr = {}
    for i=1,7 do
        local arr = {}
        arr.bg = self.bgimg:getChildByName('city_'..i..'_pl')
        arr.bg:setVisible(true)
        arr.funcbtn = arr.bg:getChildByName('city_btn')
        arr.namebg = arr.bg:getChildByName('name_bg')
        arr.posbg = arr.namebg:getChildByName('pos_bg')
        arr.postx = arr.posbg:getChildByName('pos_tx')
        local nameLabel = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
        nameLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
        nameLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        nameLabel:setLineSpacing(-5)
        nameLabel:setAnchorPoint(cc.p(0.5, 0.5))
        nameLabel:setPosition(cc.p(19, 72))
        arr.namebg:addChild(nameLabel)
        arr.nametx = nameLabel
        self.cityarr[i] = arr
    end
    self.memberarr = {}
    if self.data.castle.members then
        for k,v in pairs (self.data.castle.members) do 
            local arr = {}
            arr[1] = k
            if not v.build_progress  then
                v.build_progress = 0
            end
            arr[2] = v
            table.insert( self.memberarr,arr)
        end
    end
    table.sort( self.memberarr, function(a,b)
        if a[2].build_progress == b[2].build_progress then
            local f1 = a[2].fight_force
            local f2 = b[2].fight_force
            return f1 > f2
        end
        return a[2].build_progress > b[2].build_progress
    end )
    local selfpos, selfpage,realindex = self:getSelfPos()
    if self:getTotalPage() > 1 then
        self.probtn:setVisible(true)
        self.nextbtn:setVisible(true)
    else
        self.probtn:setVisible(false)
        self.nextbtn:setVisible(false)
    end
    self.selectPage = selfpage
    if self.selectPage < 1 then
        self.selectPage = 1
    end 

    local arrowImg = self.bgimg:getChildByName("arrow_img")
    arrowImg:setLocalZOrder(4)
    local headpicNode = arrowImg:getChildByName("headpic_node")
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headpicNode:addChild(headpicCell.awardBgImg)

    self:update()
end

function LegionCityMainUI:update()
    local legionconf = GameData:getConfData('legion')
    local legioncitymainconf = GameData:getConfData('legioncitymain')

    local selfpos, selfpage,realindex = self:getSelfPos()
    local arrowImg = self.bgimg:getChildByName("arrow_img")
    local headpicNode = arrowImg:getChildByName("headpic_node")
    local bgImg = headpicNode:getChildByName("award_bg_img")
    local headIcon = bgImg:getChildByName("award_img")
    local headframe = bgImg:getChildByName('headframeImg')
    local obj = RoleData:getHeadPicObj(UserData:getUserObj().headpic)
    local obj1 = RoleData:getMainRole()
    headIcon:loadTexture(obj:getIcon())
    bgImg:loadTexture(obj1:getBgImg())
    headframe:loadTexture(UserData:getUserObj():getHeadFrame())

    if self.selectPage then
        selfpage = self.selectPage
    end
    if realindex == (selfpage-1)*7+selfpos then
        arrowImg:setVisible(true)
        local posx = self.cityarr[selfpos].bg:getPositionX() + self.cityarr[selfpos].bg:getContentSize().width/2
        local posy = self.cityarr[selfpos].bg:getPositionY() + self.cityarr[selfpos].bg:getContentSize().height/2
        arrowImg:stopAllActions()
        arrowImg:setPosition(cc.p(posx,posy))
        arrowImg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.MoveBy:create(0.5, cc.p(0, 10)), cc.MoveBy:create(0.5, cc.p(0, -10)))))
    else
        arrowImg:setVisible(false)
    end
    if selfpage < 4 then
        self.areaimg:loadTexture('uires/ui/legion/legion_area_'..selfpage..'_img.png')
        self.areanumtx:setString('1')
    else
        self.areaimg:loadTexture('uires/ui/legion/legion_area_4_img.png')
        self.areanumtx:setString(selfpage-3)
    end
    if tonumber(self.data.castle.lid) == UserData:getUserObj():getLid() then
        self.listbtn:setVisible(true)
        self.plunderbtn:setVisible(true)
    else
        self.listbtn:setVisible(false)
        self.plunderbtn:setVisible(false)
    end

    for i=1,7 do
        --self.cityarr[i].funcbtn:normalTextureScaleChangedWithSize()
        self.cityarr[i].funcbtn:setVisible(true)
        if (selfpage-1)*7+i <= #self.memberarr  then
            --print('xxxxx'..(selfpage-1)*7+i)
            local memberdata = self.memberarr[(selfpage-1)*7+i]
            local castleconf = legioncitymainconf[tonumber(memberdata[2].castle_level)]
            -- print('i===='.. i)
            -- printall(memberdata)
            -- print('i====~~~~~~~~~')
            self.cityarr[i].nametx:setString(memberdata[2].un)
            self.cityarr[i].namebg:setVisible(true)
            local flag = GlobalApi:isContainEnglish(tostring(memberdata[2].un))
            if flag then
                self.cityarr[i].nametx:setAnchorPoint(cc.p(0.5, 0.5))
                self.cityarr[i].nametx:setRotation(90)
                self.cityarr[i].nametx:setMaxLineWidth(0)
            else
                self.cityarr[i].nametx:setAnchorPoint(cc.p(0.5, 0.5))
                self.cityarr[i].nametx:setRotation(0)
                self.cityarr[i].nametx:setMaxLineWidth(20)
            end
            if castleconf then
                local img = ccui.ImageView:create('uires/ui/citycraft/'..castleconf.url)
                self.cityarr[i].funcbtn:loadTextures('uires/ui/citycraft/'..castleconf.url,'','')
                self.cityarr[i].funcbtn:setPosition(cc.p(castleconf['pos'][1],castleconf['pos'][2]))
                -- self.cityarr[i].funcbtn:setScale(castleconf['scale'])
                self.cityarr[i].funcbtn:setCapInsets(img:getContentSize())
            end
            if memberdata[2].duty ~= 4 then
                self.cityarr[i].posbg:setVisible(true)
                self.cityarr[i].postx:setString(GlobalApi:getLocalStr('LEGION_CITY_DESC'..memberdata[2].duty))
            else
                self.cityarr[i].posbg:setVisible(false)
            end
            self.cityarr[i].funcbtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then   
                    local targetUid = tonumber(memberdata[1]) 
                    if (targetUid == UserData:getUserObj():getUid()) then
                        local args = {}
                        MessageMgr:sendPost("get_city_info", "legion", json.encode(args), function (jsonObj)
                        
		                    print(json.encode(jsonObj))
	                        local code = jsonObj.code
		                    if code == 0 then
                                UserData:getUserObj():setLegionCityInfo(jsonObj.data.city)
                                LegionMgr:showLegionCityUpgradeUI()
                            end
	                    end)
                    else
                        local args = {
                            target_uid = targetUid,
                        }
                        MessageMgr:sendPost("get_player_territory_war_info", "territorywar", json.encode(args), function (jsonObj)
		                    -- print(json.encode(jsonObj))
	                        local code = jsonObj.code
		                    if code == 0 then
                                local newUI = ClassLegionCityCompareUI.new(jsonObj.data, memberdata)
                                newUI:showUI()
                            end
	                    end)
                    end	
                    
                    --LegionMgr:showLegionCityInfoUI(memberdata,self.data.lid,self.data.rescue,self.data.occupy)
                    --promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'),COLOR_TYPE.RED)
                end
            end)
            self.cityarr[i].funcbtn:setVisible(true)
        else
            local img = ccui.ImageView:create('uires/ui/legion/legion_city_bg.png')
            self.cityarr[i].funcbtn:loadTextureNormal('uires/ui/legion/legion_city_bg.png')
            self.cityarr[i].funcbtn:setVisible(false)
            self.cityarr[i].funcbtn:setCapInsetsNormalRenderer(img:getContentSize())
            self.cityarr[i].funcbtn:setPosition(cc.p(101.00,36.00))
            self.cityarr[i].funcbtn:setScale(1)
            self.cityarr[i].nametx:setString('')
            self.cityarr[i].namebg:setVisible(false)
            self.cityarr[i].funcbtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_CITY_DESC16'), COLOR_TYPE.RED)
                end
            end)
        end
    end
end

function LegionCityMainUI:onShowUIAniOver()
    GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.TERRITORIAL_CITY)
end

function LegionCityMainUI:getTotalPage()
    return math.ceil(#self.memberarr/7)
end

function LegionCityMainUI:getSelfPos()
    local index = 0
    for i=1,#self.memberarr do
        if tonumber(self.memberarr[i][1]) == (GlobalData:getSelectUid()) then
            index = i
            break
        end
    end
    -- pos,page
    return (index - 1)%7 + 1 , math.ceil(index/7),index 
end

function LegionCityMainUI:changeToPage(page)
    local totalpage = self:getTotalPage()
    if page > totalpage then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_CITY_DESC10'), COLOR_TYPE.RED)
        return
    end
    self.selectPage = page
    self:update()
    -- body
end
return LegionCityMainUI