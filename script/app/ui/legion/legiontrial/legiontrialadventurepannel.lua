local LegionTrialAdventurePannelUI = class("LegionTrialAdventurePannelUI", BaseUI)
local GUAIREN_IMG = 'uires/ui/legion/legiontrial/legiontrial_guairen2.png'
local SHANGREN_IMG = 'uires/ui/legion/legiontrial/legiontrial_shangren2.png'

local ClassLegionTrialAdventureSubPannelUI = require('script/app/ui/legion/legiontrial/legiontrialadventuresubpannel')
local LegionTrialAdventureSubGuaiRenPannelUI = require('script/app/ui/legion/legiontrial/legiontrialadventuresubguairenpannel')

function LegionTrialAdventurePannelUI:ctor(trial,index)
    self.uiIndex = GAME_UI.UI_LEGION_TRIAL_ADVENTURE_PANNEL

    self.trial = trial
    self.adventure = self.trial.adventure
    self.index = index
    self:initData()
end

function LegionTrialAdventurePannelUI:init()
	local root = self.root:getChildByName("root")
    local rootBG = root:getChildByName("bg")
    self.panelBg = rootBG:getChildByName('panel_bg')
    self.rootBG = rootBG
    self:adaptUI(root, rootBG)

    self.curBG = ccui.Helper:seekWidgetByName(root,"cue_bg")
    self.pageContent = ccui.Helper:seekWidgetByName(root,"page_content")
    self.tempCell = ccui.Helper:seekWidgetByName(root,"menu_cell")
    self.tempCell:setVisible(false)

    self.menuView = ccui.Helper:seekWidgetByName(root,"menuView")
    self.menuView:setScrollBarEnabled(false)

    local closeBtn =  ccui.Helper:seekWidgetByName(rootBG,"close_btn")
    local function clickClose(sender, eventType)
       if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionTrialMgr:hideLegionTrialAdventurePannelUI()
        end
    end
    closeBtn:addTouchEventListener(clickClose)

    self.pageWidth = self.pageContent:getContentSize().width
    self.pageHeight = self.pageContent:getContentSize().height

    self:showMenus()
    if self.index then
        local num = #self.adventures
        local switchPos = 1
        for i = 1,num do
            local serverData = self.adventures[i]
            if serverData.index == self.index then
                switchPos = i
                break
            end
        end
        self:openPage(switchPos,self.adventures[switchPos])
    else
        if #self.adventures > 0 then
            self:openPage(1,self.adventures[1])
        end
    end

    self:refreshMark()
end

function LegionTrialAdventurePannelUI:initData()
    self.menus = {}
    self.lastSelectMenu = nil
    self.lastPage = nil

    self.adventures = {}
    for k,v in pairs(self.adventure) do
        if v.award_got == 0 and v.type ~= 3 then
            local time = v.time
            local nowTime = GlobalData:getServerTime()
            if nowTime < time then
                local temp = {}
                temp.index = tonumber(k)
                temp.data = v
                table.insert(self.adventures,temp)
            end
        end
    end
end

function LegionTrialAdventurePannelUI:showMenus()
    local num = #self.adventures
    for i = 1,num do
        local serverData = self.adventures[i]
        local newCell = self.tempCell:clone()
        newCell.titleBG = ccui.Helper:seekWidgetByName(newCell,"titlebg")
        newCell.titleTx = ccui.Helper:seekWidgetByName(newCell,"titletx")
        newCell.icon    = ccui.Helper:seekWidgetByName(newCell,"icon")
		newCell.mark	= ccui.Helper:seekWidgetByName(newCell,"mark")

        --newCell.titleTx:setString(data.titleString)
        if serverData.data.type == 1 then
            newCell.icon:loadTexture(SHANGREN_IMG)
        else
            newCell.icon:loadTexture(GUAIREN_IMG)
        end
        newCell:setVisible(true)
		newCell.mark:setVisible(false)

        self.menus[i] = newCell
        self.menuView:addChild(newCell)

        local function clickMenu(sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if self.lastSelectMenu == i then   
                    return
                end
                AudioMgr.PlayAudio(11)
                self:playEffect(sender)

                self:openPage(i,serverData)
            end
        end
        newCell:addTouchEventListener(clickMenu)

        -- 刷新时间
        self:timeoutCallback(i,newCell,serverData.data.time)

    end
end

function LegionTrialAdventurePannelUI:timeoutCallback(i,parent,time)
	local diffTime = 0
	if time ~= 0 then
		diffTime = time - GlobalData:getServerTime()
	end
	local node = cc.Node:create()
    node:setLocalZOrder(10000)
    node:setName('show_time' .. i)
	--node:setTag(9527)		 
	node:setPosition(parent.titleTx:getPosition())
	--if parent:getChildByTag(9527) then
        --parent:removeChildByTag(9527)
    --end
    if parent:getChildByName('show_time' .. i) then
        parent:removeChildByName('show_time' .. i)
    end
	parent:addChild(node)
	Utils:createCDLabel(node,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.YELLOW,CDTXTYPE.NONE,nil,nil,nil,25,function ()
		if diffTime <= 0 then
            if parent:getChildByName('show_time' .. i) then
                parent:removeChildByName('show_time' .. i)
                parent.titleTx:setString(GlobalApi:getLocalStr('LEGION_TRIAL_DESC43'))
                parent.titleTx:setVisible(true)
                self:refreshMark()
            end
		else
			self:timeoutCallback(i,parent,time)
		end
	end)
end

function LegionTrialAdventurePannelUI:playEffect(img)
    if self.lvUp then
        self.lvUp:removeFromParent()
        self.lvUp = nil
    end
    
    local size = img:getContentSize()
    local size1 = img:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(size.width/2 - 5 ,size.height/2 - 25))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img.icon:setLocalZOrder(101)
    img.titleBG:setLocalZOrder(102)
    img.titleTx:setLocalZOrder(103)
    img.mark:setLocalZOrder(104)
    img:addChild(lvUp)

    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)
    self.lvUp = lvUp
end

function LegionTrialAdventurePannelUI:openPage(pos,serverData)
    local data = serverData.data
    local pageUI,newPage
    if data.type == 1 then
        pageUI = cc.CSLoader:createNode('csb/legiontrialadventuresubpannel.csb')
        newPage = ClassLegionTrialAdventureSubPannelUI:new()
    else
        pageUI = cc.CSLoader:createNode('csb/legiontrialadventuresubguairenpannel.csb')
        newPage = LegionTrialAdventureSubGuaiRenPannelUI:new()
    end

    newPage.root = pageUI
    newPage:init(pos,serverData,self.trial,self)

    self.pageContent:addChild(pageUI)
    if(self.lastSelectMenu ~= nil and self.lastPage ~= nil) then
        local lastPage = self.lastPage
        local moveDir = 0
        if pos < self.lastSelectMenu then
            pageUI:setPositionX(-self.pageWidth) 
            moveDir = self.pageWidth 
        else
            pageUI:setPositionX(self.pageWidth) 
            moveDir = -self.pageWidth 
        end
            lastPage:runAction(cc.Sequence:create(cc.MoveBy:create(0.3,cc.p(moveDir,0)),cc.CallFunc:create(function ()
            self.pageContent:removeChild(lastPage)
        end)))
        pageUI:runAction(cc.MoveBy:create(0.3,cc.p(moveDir,0)))
    end

    for k = 1,#self.adventures do
        local menu = self.menus[k]
        if k == pos then           
            menu.titleBG:loadTexture("uires/ui/activity/biaoti.png")
            --menu.titleTx:setTextColor(cc.c4b(128,67,13, 255))
            self:playEffect(menu)
        else
            menu.titleBG:loadTexture("uires/ui/activity/biaoti2.png")
            --menu.titleTx:setTextColor(cc.c4b(110,73,48,255))
        end
    end

    self.lastPage = pageUI
    self.lastSelectMenu = pos
end

function LegionTrialAdventurePannelUI:refreshMark()
    local menus = self.menus
    
    for i = 1,#menus do
        local serverData = self.adventures[i]
        local mark = menus[i].mark

        local judge = false
        local data = serverData.data
        local time = data.time
        local nowTime = GlobalData:getServerTime()
        if nowTime < time and data.type == 2 then
            if data.pass == 1 then     -- 已经通关,未领取 
                if data.award_got == 0 then
                    judge = true
                end
            else
                judge = true
            end
        end
        mark:setVisible(judge)
    end
end

return LegionTrialAdventurePannelUI