local ActivityPetitionTipsUI = class("ActivityPetitionTipsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActivityPetitionTipsUI:ctor(item, isGet, callback)
	self.uiIndex = GAME_UI.UI_ACTIVITY_PETITIONTIPS
	self.obj=item
	self.isGet=isGet
	self.callback=callback
end

function ActivityPetitionTipsUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2))
	
	local panel = bg2:getChildByName('contentPanel')
	
	local itemNode=panel:getChildByName('itemNode')
	self.tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, itemNode)
	self.tab.awardBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			GetWayMgr:showGetwayUI(self.obj,false)
		end
	end)
	
	--item name
	local nameTx=panel:getChildByName('name')
	nameTx:setString(self.obj:getName())
	nameTx:enableOutline(self.obj:getNameOutlineColor(),1)
    nameTx:setColor(self.obj:getNameColor())
    nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	
	--info
	self.infoTxs = {}
    for i=1,3 do
        self.infoTxs[i]=ccui.Helper:seekWidgetByName(panel,'info_'..i..'_tx')
    end

	--get btn
	local getBtn = panel:getChildByName("getBtn")	
    getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_PETITION_DES4'))
	getBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			self:hideUI()
			if self.callback then
                self.callback()
            end
	    end
	end)
	if self.isGet==false then
		getBtn:setTouchEnabled(false)
		ShaderMgr:setGrayForWidget(getBtn)
	end
	
	--close btn
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
			self:hideUI()
	    end
	end)
	
	self:updatePanel()
end

function ActivityPetitionTipsUI:updatePanel()
    local stype = self.obj:getCategory()
    local num = 0
    local num1 = self.obj:getNum()
    local name = self.obj:getName()
    local visible = true
    for i=1,3 do
        self.infoTxs[i]:ignoreContentAdaptWithSize(false)
        self.infoTxs[i]:setTextAreaSize(cc.size(360,150))
    end
    print(stype)
    if stype == 'material' then
        local obj = BagData:getMaterialById(self.obj:getId())
        num = 0
        if obj then
            num = obj:getNum()
        end
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    elseif stype == 'card' then
        -- local obj = BagData:getCardById(tonumber(self.obj:getId()))
        local obj = RoleData:getRoleInfoById(tonumber(self.obj:getId()))
        num = obj:getNum()
        num1 = self.sztab.sellNum
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    elseif stype == 'gem' then
        -- local obj = BagData:getCardById(tonumber(self.obj:getId()))
        local obj = BagData:getGemById(self.obj:getId())
        num = 0
        if obj then
            num = obj:getNum()
        end
        num1 = self.sztab.sellNum
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    elseif stype == 'fragment' then
        local obj = BagData:getFragmentById(self.obj:getId())
        if not obj then
            obj = RoleData:getRoleInfoById(tonumber(self.obj:getId()))
            num = 0
        else
            num = obj:getNum()
        end
        self.tab.awardBgImg:setTouchEnabled(true)
        self.tab.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, self.obj)
            end
        end)
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    elseif stype == 'equip' then
        num = 0
        local equipObj = self.obj:getObj()
        local mainInfo = equipObj:getMainAttribute()
        self.infoTxs[1]:setString(mainInfo.name..':  +'..mainInfo.value)
        self.infoTxs[1]:enableOutline(COLOR_TYPE.BLACK,1)
        self.infoTxs[1]:setColor(COLOR_TYPE.WHITE)
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        local godId = equipObj:getGodId()
        print(godId)
        if godId > 0 then
            local godInfo = clone(equipObj:getGodAttr())
            for i,v in ipairs(godInfo) do
                if godInfo[i].type == 1 then
                    godInfo[i].value = math.floor(godInfo[i].value/100)
                end
                self.infoTxs[i+1]:setString(godInfo[i].name..'    +'..godInfo[i].value.."%")
                self.infoTxs[i+1]:enableOutline(COLOROUTLINE_TYPE[godInfo[i].color],1)
                self.infoTxs[i+1]:setColor(COLOR_TYPE[godInfo[i].color])
                self.infoTxs[i+1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            end
        end
        name = 'Lv. '..self.obj:getLevel()..'  '..name
        visible = false
    elseif stype == 'user' then
        num = UserData:getUserObj()[self.obj:getId()]
        self.infoTxs[1]:setString(self.obj:getDesc())
        self.infoTxs[1]:enableOutline(self.obj:getNameOutlineColor(),1)
        self.infoTxs[1]:setColor(self.obj:getNameColor())
        self.infoTxs[1]:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    end
   
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(230, 30))
    local tx1 = GlobalApi:getLocalStr('STR_HAD')
    local tx2 = GlobalApi:toWordsNumber(num)
    local tx3 = GlobalApi:getLocalStr('STR_JIAN')
    local re1 = xx.RichTextLabel:create(tx1,23,COLOR_TYPE.ORANGE)
    local re2 = xx.RichTextLabel:create(tx2,23,COLOR_TYPE.WHITE)
    local re3 = xx.RichTextLabel:create(tx3,23,COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re2:setStroke(COLOR_TYPE.BLACK, 1)
    re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    --richText:formatText()
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(105 ,37))
    self.tab.awardBgImg:addChild(richText)
    richText:setVisible(visible)
end

return ActivityPetitionTipsUI