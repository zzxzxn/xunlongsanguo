local LegionWarCityDefListUI = class("LegionWarCityDefListUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function LegionWarCityDefListUI:ctor(legiondata,cityinfo,cityid,posid)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_CITYDEFLIST
  	self.data = legiondata
    self.cityinfo = cityinfo
    self.cityid = cityid
    self.posid = posid
    self.celltab = {}
end

function LegionWarCityDefListUI:init()
	local bgimg1 = self.root:getChildByName("bg_img")
	local bgimg2 = bgimg1:getChildByName('bg_img1')
	self:adaptUI(bgimg1, bgimg2)
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarCityDefListUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx =titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC28'))
    local desctx = bgimg2:getChildByName('desc_tx_1')
    desctx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC27'))
    local bgimg3 = bgimg2:getChildByName('bg_img2')   
    self.sv = bgimg3:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self.noimg = bgimg3:getChildByName('no_tx')
    self.contentWidget = ccui.Widget:create()
    self.contentWidget:setPosition(cc.p(342,444))
    self.sv:addChild(self.contentWidget)
    self:update()
end

function LegionWarCityDefListUI:update()
    local legionconf = GameData:getConfData('legion')
    self.memberarr = {}
    if self.data.members then
        for k,v in pairs (self.data.members) do 
            local arr = {}
            arr[1] = k
            arr[2] = v
            if LegionMgr:getLegionBattleData().ownLegion.garrion and LegionMgr:getLegionBattleData().ownLegion.garrion[tostring(k)] then
                local time = tonumber(legionconf['legionWarDispatchNum'].value) - LegionMgr:getLegionBattleData().ownLegion.garrion[tostring(k)]
                if time > 0 then
                    table.insert(self.memberarr,arr)
                end
            else
                table.insert(self.memberarr,arr)
            end
        end
    end
    self.num = #self.memberarr
    if self.num == 0 then
        self.noimg:setVisible(true)
    else
        self.noimg:setVisible(false)
        for i=1,self.num do
            self:addCells(i,self.memberarr[i])
        end  
    end
  
end
function LegionWarCityDefListUI:addCells(index,celldata)
    local node = cc.CSLoader:createNode("csb/legion_war_city_def_cell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.contentsize = bgimg:getContentSize()
    self.celltab[index] = ccui.Widget:create()
    self.celltab[index]:addChild(bgimg)

    local headbg = bgimg:getChildByName('head_node')
    local obj = RoleData:getHeadPicObj(celldata[2].headpic)

    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headbg:addChild(cell.awardBgImg)
    cell.awardBgImg:loadTexture(COLOR_FRAME[celldata[2].quality])
    cell.awardImg:loadTexture(obj:getIcon())
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(celldata[2].headframe))

    local nametx = bgimg:getChildByName('name_tx')
    nametx:setString(celldata[2].un)
    local timetx = bgimg:getChildByName('time_tx')
    local legionconf = GameData:getConfData('legion')
    local battledata = LegionMgr:getLegionBattleData()
    if not battledata.ownLegion.garrion[tostring(celldata[1])] then
        battledata.ownLegion.garrion[tostring(celldata[1])] = 0 
    end
    local time = tonumber(legionconf['legionWarDispatchNum'].value) - battledata.ownLegion.garrion[tostring(celldata[1])]

    timetx:setString(GlobalApi:getLocalStr('SHIPPER_REMAINDER')..time..GlobalApi:getLocalStr('FREE_TIMES_DESC'))
    local fightforceal = bgimg:getChildByName('fightforce_al')
    fightforceal:setString(celldata[2].fight_force)
    local vipal = bgimg:getChildByName('vip_al')
    vipal:setString(celldata[2].vip)

    local funcbtn = bgimg:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('btn_tx')

    if self:checkIsPersonInCity(celldata[1]) or time <= 0 then
        funcbtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(funcbtn)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
    else
        funcbtn:setTouchEnabled(true)
        ShaderMgr:restoreWidgetDefaultShader(funcbtn)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    end
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if time > 0 then
                self:sendMsg(self.cityid,celldata)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC33'),COLOR_TYPE.RED)
            end
        end
    end)

    local posy = -(self.contentsize.height+5)*(index-1) - self.contentsize.height/2
    self.celltab[index]:setPosition(cc.p(0,posy))
    self.contentWidget:addChild(self.celltab[index])
    if index*(self.contentsize.height+5) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,index*(self.contentsize.height+5)))
    end
    self.contentWidget:setPosition(cc.p(self.sv:getInnerContainerSize().width/2,self.sv:getInnerContainerSize().height))
end

function LegionWarCityDefListUI:sendMsg(cityid,celldata)
    local args = {
        city = cityid,
        arm = self.posid,
        arm_uid = celldata[1]
    }
    MessageMgr:sendPost("add_city_force", "legionwar", json.encode(args), function (response)
        local code = response.code
        if code == 0 then
            self.cityinfo.city.arms[tostring(self.posid)].uid = celldata[1]
            self.cityinfo.city_users[tostring(celldata[1])] = celldata[2]
            self.cityinfo.city.aliveArm = self.cityinfo.city.aliveArm + 1 
            local battledata = LegionMgr:getLegionBattleData()
            battledata.ownLegion.cities[tostring(self.cityid)].aliveArm = battledata.ownLegion.cities[tostring(self.cityid)].aliveArm + 1
            battledata.ownLegion.garrion[tostring(celldata[1])] = battledata.ownLegion.garrion[tostring(celldata[1])] + 1
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC32'),COLOR_TYPE.GREEN)
            LegionMgr:hideLegionWarCityDefListUI()
        else
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WAR_DESC33'),COLOR_TYPE.RED)
        end
    end)
end

function LegionWarCityDefListUI:checkIsPersonInCity(uid)
    local value = false
    for k,v in pairs(self.cityinfo.city.arms) do
        if tostring(uid) == tostring(v.uid) then
            value = true
        end
    end
    return value
end

return LegionWarCityDefListUI