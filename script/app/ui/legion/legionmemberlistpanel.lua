local LegionMemberListUI = class("LegionMemberListUI", BaseUI)
local ClassRoleObj  =require('script/app/obj/roleobj')
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local ClassItemCell = require('script/app/global/itemcell')

local CELLWIDTH = 566
local CELLHEIGHT = 95

function LegionMemberListUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONMEMBERLISTUI
  self.data = data
  self.defaultIndex = 1
end

function LegionMemberListUI:init()
    local bgimg = self.root:getChildByName("bg_big_img")
    local bgimg1 = bgimg:getChildByName('bg_img')
    self:adaptUI(bgimg, bgimg1)
    local bgimg2 = bgimg1:getChildByName('bg_img1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionMemberListUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titlebigtx = titlebg:getChildByName('title_tx')
    titlebigtx:setString(GlobalApi:getLocalStr('LEGION_MEMBER_TITLE'))
    local rightbg = bgimg2:getChildByName('bg_img2')
    local right_bg_img = rightbg:getChildByName('bg_img')
    local right_icon_bg_node = right_bg_img:getChildByName('icon_bg_node')
    local right_me_img = right_icon_bg_node:getChildByName('me_img')
    right_me_img:setLocalZOrder(2)
    local right_cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    right_icon_bg_node:addChild(right_cell.awardBgImg)
    self.rightbg = rightbg

    self.scrollView_temp = rightbg:getChildByName('scroll_view')
    self.scrollView_temp:setScrollBarEnabled(false)
    self.scrollView_temp:setVisible(false)
    self.posY = self.scrollView_temp:getPositionY()
    self.svSize = self.scrollView_temp:getContentSize()

    self.leftbg = bgimg2:getChildByName('bg_img3')
    local bgimg6 = self.leftbg:getChildByName('bg_img4')
    local titletx = bgimg6:getChildByName('legion_pub_title')
    titletx:setString(GlobalApi:getLocalStr('LEGION_PUB'))
    self.legionpubtx = bgimg6:getChildByName('legion_pub_tx')
    self.legionpubtx:ignoreContentAdaptWithSize(false)
    self.richText = xx.RichText:create()
    self.richText:setContentSize(cc.size(220, 150))
    self.re1 = xx.RichTextLabel:create('',23, COLOR_TYPE.WHITE)
    self.re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richText:addElement(self.re1)
    self.richText:setAnchorPoint(cc.p(0,1))
    self.richText:setPosition(cc.p(0,10))
    self.legionpubtx:addChild(self.richText)
    self.managebtn = self.leftbg:getChildByName('manage_btn')
    local manageBtnNewImg = ccui.ImageView:create('uires/ui/common/new_img.png')
    manageBtnNewImg:setPosition(cc.p(98,51))
    self.managebtn:addChild(manageBtnNewImg)
    self.manageBtnNewImg = manageBtnNewImg
    local managebtntx =self.managebtn:getChildByName('btn_tx')
    managebtntx:setString(GlobalApi:getLocalStr('LEGION_MANAGE'))
    self.managebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionManageUI(self.data)
        end
    end)      
    self:setRightCenter()
    self:switchUpdate()
    self:update()
end

function LegionMemberListUI:onShow()
    self:update()
end

function LegionMemberListUI:setRightCenter()
    local centerBg = self.rightbg:getChildByName('center_img')
    self.centerData = {}
    for i = 1,4 do
        local bg = centerBg:getChildByName('bg_' .. i)
        bg.index = i
        local desTx = centerBg:getChildByName('des' .. i)
        bg.desTx = desTx
        if i == 1 then
            desTx:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES2'))
        elseif i == 2 then
            desTx:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES3'))
        elseif i == 3 then
            desTx:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES4'))
        else
            desTx:setString(GlobalApi:getLocalStr('LEGION_MENBER_DES5'))
        end

        bg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then               
                if sender.index ~= self.defaultIndex then
                    self.defaultIndex = bg.index
                    self:switchUpdate()
                    self:update()
                end

            end
        end)

        table.insert(self.centerData,bg)
    end

end

function LegionMemberListUI:switchUpdate()
    for i = 1,#self.centerData do
        local bg = self.centerData[i]
        if bg.index == self.defaultIndex then
            bg:setOpacity(255)
            bg.desTx:setTextColor(COLOR_TYPE.ORANGE)
        else
            bg:setOpacity(0)    -- ���غ����޷�����ģ�������������͸���ȾͿ�����
            bg.desTx:setTextColor(COLOR_TYPE.WHITE)
        end
    end
end

function LegionMemberListUI:update()
    self:initLeftPl(self.leftbg)
    if self.data.notice == '' then    
        self.re1:setString(GlobalApi:getLocalStr('LEGION_PUB_DEFAULT'))
        self.richText:format(true)
    else
        self.re1:setString(self.data.notice)
        self.richText:format(true)
    end
    self.memberarr = {}
    if self.data.members then
        for k,v in pairs (self.data.members) do 
            local arr = {}
            arr[1] = k
            arr[2] = v
            table.insert( self.memberarr,arr)
            if v.duty == 1 then
                self.legionHeadData = arr
            end
        end
    end
    self:sortTab(self.memberarr)

    -- �����Լ�ˢ��
    self:refreshOwn(self.memberarr[1])
    UserData:getUserObj().lduty = self.memberarr[1][2].duty

    -- ������ˢ��
    self:sortTabByType(self.memberarr)
    if self.rightbg:getChildByName('scrollview_sv') then
        self.rightbg:removeChildByName('scrollview_sv')
        self.scrollView = nil
    end
    local scrollView = ccui.ScrollView:create()
    scrollView:setName('scrollview_sv')
	scrollView:setTouchEnabled(true)
	scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(self.scrollView_temp:getPosition())
    scrollView:setContentSize(self.scrollView_temp:getContentSize())
    self.rightbg:addChild(scrollView)
	self.scrollView = scrollView

    self.viewSize = self.scrollView:getContentSize() -- ��������Ĵ�С
    if #self.memberarr > 0 then
        self:initListView()
    end
    self.manageBtnNewImg:setVisible(UserData:getUserObj():getSignByType('legion_member_hall'))
end

function LegionMemberListUI:sortTab (arr)
    table.sort( arr, function (a,b)
        local uid = tonumber(UserData:getUserObj():getUid())
        if tonumber(a[1]) == uid and tonumber(b[1]) ~= uid then
            return true
        elseif tonumber(a[1]) ~= uid and tonumber(b[1]) == uid then
            return false
        else
            local pos1 = a[2].duty
            local pos2 = b[2].duty
            if pos1 == pos2 then
                local time1 = a[2].login_time
                local time2 = b[2].login_time
                if time1 == time2 then
                    return a[1] < b[1]
                else
                    return time1 > time2
                end
            else
                return pos1 < pos2
            end
        end
    end )  
end


function LegionMemberListUI:sortTabByType(arr)
    if self.defaultIndex == 1 then
        table.sort( arr, function (a,b)
            return a[2].level > b[2].level
        end)  
    elseif self.defaultIndex == 2 then
        table.sort( arr, function (a,b)
            return a[2].fight_force > b[2].fight_force
        end)  
    elseif self.defaultIndex == 3 then
        table.sort( arr, function (a,b)
            return a[2].duty < b[2].duty
        end)  
    else
        table.sort( arr, function (a,b)
            local aActive = a[2].active[#a[2].active]
            local bActive = b[2].active[#b[2].active]
            return aActive > bActive
        end)  
    end
end

function LegionMemberListUI:initListView()
    self.cellSpace = 5
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.memberarr
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace
    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.scrollView,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)
    else
        self.scrollViewGeneral:resetScrollView(self.scrollView,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback)
    end
end

function LegionMemberListUI:initItemData(index)
    if self.memberarr[index] then
        local w = CELLWIDTH
        local h = CELLHEIGHT
        
        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function LegionMemberListUI:addItem(tempCellData,widgetItem)
    if self.memberarr[tempCellData.index] then
        local index = tempCellData.index

        local node = cc.CSLoader:createNode("csb/legionmembercell.csb")
        local cell = (node:getChildByName("bg_img")):clone()
        local icon_bg_img = cell:getChildByName('icon_bg_img')
        local meimg = cell:getChildByName('me_img')
        meimg:setLocalZOrder(2)
        local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
        headpicCell.awardBgImg:setScale(0.8)
        cell:addChild(headpicCell.awardBgImg)
        headpicCell.awardBgImg:setPosition(cc.p(icon_bg_img:getPosition()))
        self:updatecell2(cell,self.memberarr[index])

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(cell)
        cell:setPosition(cc.p(0,0))
    end
end

function LegionMemberListUI:refreshOwn(data)
    if not data then
        return
    end

    local parent = self.rightbg:getChildByName('bg_img')
    parent:setSwallowTouches(false)
    parent:setPropagateTouchEvents(false)
    local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    parent:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            beginPoint = sender:getTouchBeganPosition()
            AudioMgr.PlayAudio(11)
        end  
        
        if eventType ==  ccui.TouchEventType.ended then
            endPoint= sender:getTouchEndPosition()
            local deltax = math.abs(beginPoint.x -endPoint.x)
            local deltay = math.abs(beginPoint.y -endPoint.y)
            if deltax > 25 or deltay > 25 then 
                return
            end
            LegionMgr:showLegionMemberInfoUI(self.data , data)
        end
    end)
    local nametx = parent:getChildByName('name_tx')
    nametx:setString(data[2].un)
    local lvtx = parent:getChildByName('lv_tx')
    lvtx:setString(data[2].level)
    local postx = parent:getChildByName('pos_tx')
    local activeValue = data[2].active[#data[2].active]

    postx:setString(string.format(GlobalApi:getLocalStr("LEGION_MENBER_DES1"), activeValue))

    local fightforcetx = parent:getChildByName('fight_force_tx')
    fightforcetx:setString('')
    if fightforcetx:getChildByName('left_label') then
        fightforcetx:removeChildByName('left_label')
    end
    local leftLabel = cc.LabelAtlas:_create(data[2].fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    leftLabel:setName('left_label')
    leftLabel:setAnchorPoint(cc.p(0,0.5))
    leftLabel:setPosition(cc.p(0,0))
    leftLabel:setScale(0.7)
    fightforcetx:addChild(leftLabel)


    local vipImg = parent:getChildByName('vip_img')
    vipImg:setPositionX(nametx:getPositionX() + nametx:getContentSize().width + 5)

    local viptx = parent:getChildByName('vip_tx')
    viptx:setPositionX(vipImg:getPositionX() + vipImg:getContentSize().width + 2)
    viptx:setString('')
    if viptx:getChildByName('vip_label') then
        viptx:removeChildByName('vip_label')
    end
    local viplabel = cc.LabelAtlas:_create(data[2].vip, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    viplabel:setName('vip_label')
    viplabel:setAnchorPoint(cc.p(0,0.5))
    viplabel:setPosition(cc.p(0,0))
    viplabel:setScale(0.7)
    viptx:addChild(viplabel)

    local icon_bg_node = parent:getChildByName('icon_bg_node')
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    --headpicCell.awardBgImg:setScale(0.8)
    icon_bg_node:addChild(headpicCell.awardBgImg)
    headpicCell.awardBgImg:setPosition(cc.p(0,0))
    local award_bg_img = headpicCell.awardBgImg
    --local award_bg_img = icon_bg_node:getChildByName('award_bg_img')
    
    local award_bg = headpicCell.awardImg
    local headframeImg = headpicCell.headframeImg
    local obj = RoleData:getHeadPicObj(tonumber(data[2].headpic))
    award_bg:loadTexture(obj:getIcon())
    award_bg_img:loadTexture(COLOR_FRAME[data[2].quality])
    headframeImg:loadTexture(GlobalApi:getHeadFrame(data[2].headframe))

end

function LegionMemberListUI:updatecell2(parent,data)
    parent:setSwallowTouches(false)
    parent:setPropagateTouchEvents(false)
    local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    parent:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            beginPoint = sender:getTouchBeganPosition()
            AudioMgr.PlayAudio(11)
        end  
        
        if eventType ==  ccui.TouchEventType.ended then
            endPoint= sender:getTouchEndPosition()
            local deltax = math.abs(beginPoint.x -endPoint.x)
            local deltay = math.abs(beginPoint.y -endPoint.y)
            if deltax > 25 or deltay > 25 then 
                return
            end
            LegionMgr:showLegionMemberInfoUI(self.data , data)
        end
    end)
    local nametx = parent:getChildByName('name_tx')
    nametx:setString(data[2].un)
    local lvtx = parent:getChildByName('lv_tx')
    lvtx:setString(data[2].level)
    local postx = parent:getChildByName('pos_tx')
    local activeValue = data[2].active[#data[2].active]

    postx:setString(string.format(GlobalApi:getLocalStr("LEGION_MENBER_DES1"), activeValue))

    local fightforcetx = parent:getChildByName('fight_force_tx')
    fightforcetx:setString('')
    if fightforcetx:getChildByName('left_label') then
        fightforcetx:removeChildByName('left_label')
    end
    local leftLabel = cc.LabelAtlas:_create(data[2].fight_force, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    leftLabel:setName('left_label')
    leftLabel:setAnchorPoint(cc.p(0,0.5))
    leftLabel:setPosition(cc.p(0,0))
    leftLabel:setScale(0.7)
    fightforcetx:addChild(leftLabel)

    local vipImg = parent:getChildByName('vip_img')
    vipImg:setPositionX(nametx:getPositionX() + nametx:getContentSize().width + 5)

    local viptx = parent:getChildByName('vip_tx')
    viptx:setPositionX(vipImg:getPositionX() + vipImg:getContentSize().width + 2)
    viptx:setString('')
    if viptx:getChildByName('vip_label') then
        viptx:removeChildByName('vip_label')
    end
    local viplabel = cc.LabelAtlas:_create(data[2].vip, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    viplabel:setName('vip_label')
    viplabel:setAnchorPoint(cc.p(0,0.5))
    viplabel:setPosition(cc.p(0,0))
    viplabel:setScale(0.7)
    viptx:addChild(viplabel)


    local awardBgImg = parent:getChildByName('award_bg_img')
    awardBgImg:loadTexture(COLOR_FRAME[data[2].quality])

    local awardImg = awardBgImg:getChildByName('award_img')
    local obj = RoleData:getHeadPicObj(tonumber(data[2].headpic))
    awardImg:loadTexture(obj:getIcon())
    
    local headframeImg = awardBgImg:getChildByName('headframeImg')
    headframeImg:loadTexture(GlobalApi:getHeadFrame(data[2].headframe))

    local meimg = parent:getChildByName('me_img')
    local tx = meimg:getChildByName('tx')
    if data[2].duty == 1 then
        tx:setString(GlobalApi:getLocalStr("LEGION_MENBER_DES6"))
    elseif data[2].duty == 2 then
        tx:setString(GlobalApi:getLocalStr("LEGION_MENBER_DES7"))
    elseif data[2].duty == 3 then
        tx:setString(GlobalApi:getLocalStr("LEGION_MENBER_DES8"))
    else
        meimg:setVisible(false)
    end

    local lasttimetx = parent:getChildByName('last_line_tx')
    lasttimetx:setString(GlobalApi:toEasyTime(data[2].login_time))
    local legiondat = GameData:getConfData('legion')
    local legionLastActiveTime = tonumber(GlobalApi:getGlobalValue('lastActiveTime'))
    local active_time = data[2].active_time or 0
    if GlobalData:getServerTime() - active_time < legionLastActiveTime then
        lasttimetx:setString(GlobalApi:getLocalStr("JUST_NOW1"))
        lasttimetx:setTextColor(COLOR_TYPE.GREEN)
        lasttimetx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        lasttimetx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    else
        if GlobalData:getServerTime() - data[2].login_time < 60 then
            lasttimetx:setTextColor(COLOR_TYPE.GREEN)
            lasttimetx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            lasttimetx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        else
            lasttimetx:setTextColor(COLOR_TYPE.BROWN)
            lasttimetx:enableOutline(COLOROUTLINE_TYPE.BROWN,1)
            lasttimetx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BROWN))
        end
    end

    local againstBtn = parent:getChildByName('against_btn')
    againstBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr("LEGION_MENBER_DES15"))
    local againstTx = parent:getChildByName('against_tx')
    againstTx:setString(GlobalApi:getLocalStr("LEGION_MENBER_DES14"))
    local againstTxTime = parent:getChildByName('against_tx_time')

    local legionHeadNotOnlineTimeLimit = tonumber(legiondat['legionHeadNotOnlineTimeLimit'].value)*3600
    local legionHeadLeaveTimeLimit = tonumber(legiondat['legionHeadLeaveTimeLimit'].value)*3600
    local impeachmentInitiatorId = self.data.impeachmentInitiatorId or 0
    local impeachmentTime = self.data.impeachmentTime or 0
    if data[2].duty == 1 then
        if impeachmentInitiatorId ~= 0 then   -- ������
            againstBtn:setVisible(false)
            againstTx:setVisible(true)
            againstTxTime:setVisible(true)
            postx:setVisible(false)
            lasttimetx:setVisible(false)
            self:timeoutCallback(againstTxTime,impeachmentTime + legionHeadNotOnlineTimeLimit)
        else
            local active_time = self.legionHeadData[2].active_time
            local a = GlobalData:getServerTime() - active_time
            if GlobalData:getServerTime() - active_time > legionHeadLeaveTimeLimit then     -- ���Ե���
                againstBtn:setVisible(true)
                againstTx:setVisible(false)
                againstTxTime:setVisible(false)
                postx:setVisible(false)
                lasttimetx:setVisible(false)
            else    -- ���ܵ���
                againstBtn:setVisible(false)
                againstTx:setVisible(false)
                againstTxTime:setVisible(false)
                postx:setVisible(true)
                lasttimetx:setVisible(true)
            end
        end
    else
        againstBtn:setVisible(false)
        againstTx:setVisible(false)
        againstTxTime:setVisible(false)
        postx:setVisible(true)
        lasttimetx:setVisible(true)
    end

    againstBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end  
        if eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionMemberAgainstUI(self.data,self.legionHeadData[1])
        end
    end)
end

function LegionMemberListUI:timeoutCallback(parent,time)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
	if parent:getChildByTag(9527) then
        parent:removeChildByTag(9527)
    end
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.BLACK,CDTXTYPE.NONE,nil,nil,nil,24,function ()
		if diffTime <= 0 then
            MessageMgr:sendPost('get_hall','legion',"{}",function (response)
			    local code = response.code
			    local data = response.data
			    if code == 0 then
                    self.data = data.legion
                    self:update()
			    end
		    end)
		else
			self:timeoutCallback(parent,time)
		end
	end)
end

function LegionMemberListUI:initLeftPl( parent )
    local legionlvconf = GameData:getConfData('legionlevel')
    local legionnametx = parent:getChildByName('legion_name_tx')
    legionnametx:setString(self.data.name)
    local legionlvtx = parent:getChildByName('lv_tx')
    legionlvtx:setString('Lv.'..self.data.level)
    legionlvtx:setTextColor(COLOR_TYPE.ORANGE)
    local activenumtx = parent:getChildByName('active_num_tx')
    activenumtx:setString(self.data.xp..'/'..legionlvconf[self.data.level].xp)
    local activetodaytx = parent:getChildByName('active_today_tx')
    activetodaytx:setString('')

    local activetodayRtx = activetodaytx:getChildByName('active_today_rtx')
    if activetodayRtx then
        activetodayRtx:removeFromParent()
    end
    activetodayRtx = xx.RichText:create()
    activetodayRtx:setContentSize(cc.size(260, 40))
    local legionnumre1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DESC3'),22, COLOR_TYPE.WHITE)
    legionnumre1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    legionnumre1:setFont('font/gamefont.ttf')
    local legionnumre2 = xx.RichTextLabel:create(LegionMgr:getActiveCount(self.data.members)..'/'..LegionMgr:getMemberCount(self.data.members)..'  ',22, COLOR_TYPE.ORANGE)
    legionnumre2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    activetodayRtx:setName('active_today_rtx')
    activetodayRtx:addElement(legionnumre1)
    activetodayRtx:addElement(legionnumre2)
    activetodayRtx:setAnchorPoint(cc.p(0.5,0.5))
    activetodayRtx:setAlignment('middle')
    activetodayRtx:setVerticalAlignment('middle')
    activetodayRtx:setPosition(cc.p(0,-3))
    activetodaytx:addChild(activetodayRtx,9527)
    local helppl = parent:getChildByName('help_pl')
    helppl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TipsMgr:showLegionExpTips()
        end
    end) 
    local legionnumtx = parent:getChildByName('legion_num_tx')
    legionnumtx:setString('')
    local legionnumRtx = legionnumtx:getChildByName('legion_num_rtx')
    if legionnumRtx then
        legionnumRtx:removeFromParent()
    end
    legionnumRtx = xx.RichText:create()
    legionnumRtx:setContentSize(cc.size(260, 40))
    local legionnumre1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_DESC2'),22, COLOR_TYPE.ORANGE)
    legionnumre1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local legionnumre2 = xx.RichTextLabel:create(LegionMgr:getMemberCount(self.data.members)..'/'..legionlvconf[self.data.level].memberMax,22, COLOR_TYPE.WHITE)
    legionnumre2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    legionnumRtx:setName('legion_num_rtx')
    legionnumRtx:addElement(legionnumre1)
    legionnumRtx:addElement(legionnumre2)
    legionnumRtx:setAnchorPoint(cc.p(0.5,0.5))
    legionnumRtx:setAlignment('middle')
    legionnumRtx:setVerticalAlignment('middle')
    legionnumRtx:setPosition(cc.p(0,-3))
    legionnumtx:addChild(legionnumRtx,9527)


    if self:getSelfPos() < 4 then
        self.managebtn:setVisible(true)
    else
        self.managebtn:setVisible(false)
    end

    local iconbg = parent:getChildByName('icon_bg_img')
    local iconimg = iconbg:getChildByName('icon_img')
    iconimg:ignoreContentAdaptWithSize(true)
    local iconConf = GameData:getConfData("legionicon") 
    iconbg:loadTexture(COLOR_FRAME[iconConf[self.data.icon].frameQuality])
    iconimg:loadTexture(iconConf[self.data.icon].icon)
    iconbg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionInfoUI(self.data)
        end
    end) 
end

function LegionMemberListUI:getSelfPos()
    local pos = 4
    for k,v in pairs (self.data.members) do 
        if tonumber(GlobalData:getSelectUid()) == tonumber(k) then
            pos = v.duty
        end
    end
    LegionMgr:setSelfLegionPos(pos)
    return pos
end

return LegionMemberListUI