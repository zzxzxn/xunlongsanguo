local PeopleKingChangeLookUI = class("PeopleKingChangeLookUI", BaseUI)

function PeopleKingChangeLookUI:ctor(page,data,callback)

    self.uiIndex = GAME_UI.UI_PEOLPLE_KING_CHANGE_LOOK
    self.page = page or 1								--1-圣武幻形，2-圣翼幻形
    self.oldPosX = -1
    self.collectNum = 0									--总搜集数
    self.selectindex = 1								--临时列表或者永久列表中的索引
    self.selectType = 1									--临时还是永久

    self.suitdata = data.sky_suit
    self.weaponActive = self.suitdata.weapon_illusion_unlock	--武器激活列表
    self.wingActive = self.suitdata.wing_illusion_unlock		--翅膀激活列表
    
    self.weaponLockTime = self.suitdata.weapon_illusion_equip_time			--武器到期时间
    self.wingLockTime = self.suitdata.wing_illusion_equip_time				--翅膀到期时间

    self.equipWeaponId = self.suitdata.weapon_illusion or 0		--当前装备ID
    self.equipWingId = self.suitdata.wing_illusion or 0

    self.collectStage = 0

    self.peopleKingData = UserData:getUserObj():getPeopleKing()
    self.callback = callback
end

function PeopleKingChangeLookUI:onShowUIAniOver()
	printall(self.weaponActive)
	if self.weaponActive['1'] == 1 and self.page == 1 then
		GuideMgr:startGuideOnlyOnce(GUIDE_ONCE.PEOPLE_KING_1)
	end
end

function PeopleKingChangeLookUI:init()
	local bg_img = self.root:getChildByName("bg_img")
    local bg_img1 = bg_img:getChildByName("bg_img1")
    self:adaptUI(bg_img, bg_img1)

    local leftBg = bg_img1:getChildByName("left_bg")
    local titlebg = leftBg:getChildByName("title_img")
    local titleTx = titlebg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_TITLE"))
    self.pageBtns = {}

    for i=1,2 do
    	local pageBtn = leftBg:getChildByName("page_"..i.."_btn")
    	local infoTx = pageBtn:getChildByName("info_tx")
    	self.pageBtns[i] = {}
    	self.pageBtns[i].btn = pageBtn
    	self.pageBtns[i].tx = infoTx
    	infoTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_"..i))
    	pageBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            self:chooseWin(i)
	        end
	    end)
    end

    --列表信息
    local topimg = leftBg:getChildByName("top_img")
	self.cardSv = topimg:getChildByName("sv")

	self.bottombg = leftBg:getChildByName("bottom_img")

	self.cell= self.root:getChildByName('item_cell')
    self.cell:setVisible(false)
    self.item = self.root:getChildByName('item')
    self.item:setVisible(false)

    --右侧面板信息
    local rightBg = bg_img1:getChildByName("right_bg")
    local foundationBg = rightBg:getChildByName("foundation_img")
    self.timeTxR = foundationBg:getChildByName("time_tx")
    self.attrTxR = foundationBg:getChildByName("attr_tx")
    self.modeNode = rightBg:getChildByName("mode_node")
    local headline_img = rightBg:getChildByName("headline_img")
    self.headTx = headline_img:getChildByName("tx")
    self.changeBtn = rightBg:getChildByName("goto_btn")
    self.getwayDesc = rightBg:getChildByName("getway_desc")

	local closebtn = bg_img1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:hidePeopleKingChangeLookUI()
        end
    end)
    self.attrTxR:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:showPeopleKingDsiplayUI(self.currConf)
        end
    end)

    self:chooseWin(self.page)
end

function PeopleKingChangeLookUI:getCollectPro()

	if self.page == 1 then
		self.collectNum = self.suitdata.weapon_collect or 0
	else
		self.collectNum = self.suitdata.wing_collect or 0
	end
	self.collectNum = (self.collectNum <0) and 0 or self.collectNum

	local curStage = 0
	for i=self.maxProgress,0,-1 do
		local goalValue = self.collectCfg[i].goalValue
		if self.collectNum >= goalValue then
			curStage = i
			break
		end
	end
	return curStage,self.collectNum
end

function PeopleKingChangeLookUI:getCollectAttr(stage)
    local extraWidgets = {}
    local function addWidget(color, name)
        local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
        w:setTextColor(color)
        w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
        w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        return w
    end

    if self.collectCfg[stage] then
        if self.collectCfg[stage - 1] then

            local attrId = self.collectCfg[stage].att1
            local name
            if self.collectCfg[stage].value1 > self.collectCfg[stage-1].value1 then
                local attrValue = self.collectCfg[stage].value1 - self.collectCfg[stage-1].value1
                name = GlobalApi:getLocalStr("TREASURE_DESC_13").."  "..self.attrCfg[attrId].name .. " + " .. attrValue
            elseif self.collectCfg[stage].value1 < self.collectCfg[stage-1].value1 then
                local attrValue = self.collectCfg[stage-1].value1 - self.collectCfg[stage].value1
                name = GlobalApi:getLocalStr("TREASURE_DESC_13").."  "..self.attrCfg[attrId].name .. " - " .. attrValue
            end
            if name then
                if self.attrCfg[attrId].desc ~= "0" then
                    name = name .. self.attrCfg[attrId].desc
                end
                table.insert(extraWidgets, addWidget(COLOR_TYPE.YELLOW, name))
            end
        else
            local attrId = self.collectCfg[stage].att1
            local attrValue = self.collectCfg[stage].value1
            local name = GlobalApi:getLocalStr("TREASURE_DESC_13").."  "..self.attrCfg[attrId].name .. " + " .. attrValue
            if self.attrCfg[attrId].desc ~= "0" then
                name = name .. self.attrCfg[attrId].desc
            end
            table.insert(extraWidgets, addWidget(COLOR_TYPE.YELLOW, name))
        end
    end
    local str = self.page == 1 and GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_5") or GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_6")
    local name = GlobalApi:getLocalStr("FATE_SPECIAL_DES5") .. "  " .. str .. "Lv." .. stage
    table.insert(extraWidgets, addWidget(COLOR_TYPE.YELLOW, name))
    return extraWidgets
end

--收集进度
function PeopleKingChangeLookUI:collectInfo(showAttrTip)

	if not self.collectCfg or not self.attrCfg then
		return
	end
          
	--当前收集进度和下一进度
	local curProgress,value = self:getCollectPro()
	if not curProgress or not value then
		return
	end
	if curProgress >= self.maxProgress then
		curProgress = self.maxProgress
	end

	local nextProgress = curProgress + 1
	if nextProgress >= self.maxProgress then
		nextProgress = self.maxProgress
	end

    --收集进度升级
    if self.collectStage < curProgress and showAttrTip then
        local widget = self:getCollectAttr(curProgress)
        local newAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
        RoleData:setAllFightForceDirty()
        local newfightforce = RoleData:getFightForce()
        GlobalApi:popupTips(self.collectbeforAttr, newAttr, self.collectfightforce, newfightforce,widget)  
    end

    self.collectStage = curProgress

	local isMax = (curProgress == self.maxProgress) and true or false

	local goalValue = self.collectCfg[nextProgress].goalValue or 1

    local img = self.bottombg:getChildByName("Image_1") 
    img:setVisible(not isMax)
    local barbg = self.bottombg:getChildByName("bar_bg")
    local tx = barbg:getChildByName("tx")
    tx:setString(value.."/"..goalValue)
    local bar = barbg:getChildByName("bar")
    local percent = math.floor(value/goalValue*100)
    bar:setPercent(percent) 

    local size = self.bottombg:getContentSize()
    local newPosx = 150
    local delta = 0
    local descTitle = self.bottombg:getChildByName("title_tx1")
    local preStr = (self.page == 1) and "PEOPLE_KING_CHANGELOOK_DESC_3" or "PEOPLE_KING_CHANGELOOK_DESC_4"
    descTitle:setString(GlobalApi:getLocalStr(preStr))
    for i=1,2 do

    	local coloctNameTx = self.bottombg:getChildByName("name_"..i)
    	local localStrId = (self.page == 1) and "PEOPLE_KING_CHANGELOOK_DESC_5" or "PEOPLE_KING_CHANGELOOK_DESC_6"
    	coloctNameTx:setString(GlobalApi:getLocalStr(localStrId))

    	local progressnum = (i == 1) and curProgress or nextProgress
    	local lvtx = self.bottombg:getChildByName("lv_tx"..i)
    	lvtx:setString("Lv."..progressnum)

    	local attrId = self.collectCfg[progressnum].att1 or 1
    	local attrvalue = self.collectCfg[progressnum].value1 or 0
    	local attrNameStr = self.attrCfg[attrId].name or ""
    	local attrNameTx = self.bottombg:getChildByName("attr_name_tx"..i)
    	attrNameTx:setString(attrNameStr)
    	local attrValueTx = self.bottombg:getChildByName("attr_value_tx"..i)
    	attrValueTx:setString("+"..attrvalue.."%")

        local allAttrNameTx = self.bottombg:getChildByName("all_attr"..i)
        local allAtterValueTx = self.bottombg:getChildByName("all_attrvalue"..i)
        local typenameStr = (self.page == 1) and GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1") or GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2")
        local allValue = self.collectCfg[progressnum].attribute or 0
        local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_16"),typenameStr)
        allAttrNameTx:setString(str)
        allAtterValueTx:setString("+"..allValue.."%")

    	if i==1 then
    		local posX = coloctNameTx:getPositionX()
    		if self.oldPosX == -1 then
    			self.oldPosX = posX
    		end
    		delta = newPosx - self.oldPosX
    	end

		if i==1 then
			local deltaX = isMax and delta or -delta
			if isMax then
				local nameX = coloctNameTx:getPositionX()+deltaX
				coloctNameTx:setPositionX(nameX)
				local posX = lvtx:getPositionX()+deltaX
				lvtx:setPositionX(posX)
				local attrPosX = attrNameTx:getPositionX()+deltaX
				attrNameTx:setPositionX(attrPosX)
				local attrValuePosX = attrValueTx:getPositionX()+deltaX
				attrValueTx:setPositionX(attrValuePosX)
                local allAttrPosX = allAttrNameTx:getPositionX()+deltaX
                allAttrNameTx:setPositionX(allAttrPosX)
                local allAttrValuePosX = allAtterValueTx:getPositionX()+deltaX
                allAtterValueTx:setPositionX(allAttrValuePosX)
			else
				coloctNameTx:setPositionX(self.oldPosX)
				lvtx:setPositionX(coloctNameTx:getContentSize().width+self.oldPosX)
				attrNameTx:setPositionX(self.oldPosX)
				attrValueTx:setPositionX(attrNameTx:getContentSize().width+self.oldPosX)
                allAttrNameTx:setPositionX(self.oldPosX)
                allAtterValueTx:setPositionX(allAttrNameTx:getContentSize().width+self.oldPosX)
			end
		else
			coloctNameTx:setVisible(not isMax)
			lvtx:setVisible(not isMax)
			attrNameTx:setVisible(not isMax)
			attrValueTx:setVisible(not isMax)
            allAttrNameTx:setVisible(not isMax)
            allAtterValueTx:setVisible(not isMax)
		end
    end

end

function PeopleKingChangeLookUI:getActiveInfo(surfaceId)

    --[[取消等阶判断永久道具的激活性
    local conditionType = itemCfg[index].condition
    local conditionValue = itemCfg[index].value
    local weaponJie = self.peopleKingData.weapon_level or 0
    local wingJie = self.peopleKingData.wing_level or 0
    local level = (self.page == 1) and weaponJie or wingJie
    local isActive = false
    if conditionType == "level" then
        isActive = conditionValue <= level
    else
        --临时性的
        isActive = false
    end]]

    local activeTab = (self.page == 1) and self.weaponActive or self.wingActive
    return activeTab[tostring(surfaceId)]
end

--展示收集道具
function PeopleKingChangeLookUI:showCollectItem()

	self.cardSv:setScrollBarEnabled(false)
    self.cardSv:setInertiaScrollEnabled(true)
    self.cardSv:removeAllChildren()

    local innerContainer = self.cardSv:getInnerContainer()
    local size = self.cardSv:getContentSize()
    
    local svwidth = 466
    local svheight = 200
    local cellheight = {}
    for i = 1,2 do
        cellheight[i] = 0
    end

    self.selectImg = ccui.ImageView:create('uires/ui/common/head_select.png')
    self.selectImg:setName("selectimg")
    self.selectImg:setScale(1.2)
   
    for i=2,1,-1 do

		local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local namebg = tempCell:getChildByName('name_bg')
        local nametx = tempCell:getChildByName('name_tx')
        local name = GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_TITLE"..self.page)
        local localStr = i==1 and GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_7") or GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_8")
        local nameStr = string.format(localStr,name)
        nametx:setString(nameStr)

        local pl = tempCell:getChildByName('item_pl')
        local itemCfg = i ==1 and self.longTimeItem or self.shortTimeItem
        local plheight = 95*(math.ceil(#itemCfg/5))
        pl:setContentSize(cc.size(svwidth,plheight))
        svheight = 40+plheight
        cellheight[i] = svheight
        tempCell:setContentSize(cc.size(svwidth,svheight))
        pl:setPosition(cc.p(0,plheight))
        namebg:setPosition(cc.p(0,svheight))
        nametx:setPosition(cc.p(0,svheight-15))
        for j = 1, #itemCfg do
            local cell = self.item:clone()
            cell:setVisible(true)
            cell:setScale(0.8)
            cell:setName('item_'..i..j)
            local icon = cell:getChildByName("icon")
            icon:loadTexture(itemCfg[j].icon)

            local attrTx = cell:getChildByName("attr")
            attrTx:setString("+"..itemCfg[j].attribute.."%")       
            local attrTxGray = cell:getChildByName("attr_gray")
            attrTxGray:setString("+"..itemCfg[j].attribute.."%")

            local showAttr = (itemCfg[j].attribute ~= 0) and true or false
            local userimg = cell:getChildByName("user_img")
            local usertx = userimg:getChildByName("tx")
            usertx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_12"))
            local surfaceId = tonumber(itemCfg[j].id)
            local equipId = (self.page == 1) and self.equipWeaponId  or self.equipWingId
            if equipId == surfaceId then
            	userimg:setVisible(true)
            else
            	userimg:setVisible(false)
            end 
            
            local isActive = self:getActiveInfo(surfaceId)       --是否激活
            if not isActive then
                ShaderMgr:setGrayForWidget(cell)
                ShaderMgr:setGrayForWidget(icon)
                ShaderMgr:setGrayForWidget(userimg)
                attrTx:setVisible(false)
                attrTxGray:setVisible(showAttr)
            else
            	ShaderMgr:restoreWidgetDefaultShader(cell)
            	ShaderMgr:restoreWidgetDefaultShader(icon)
            	ShaderMgr:restoreWidgetDefaultShader(userimg)
            	attrTx:setVisible(showAttr)
            	attrTxGray:setVisible(false)
           	end

           	--是否是新激活的
           	local newImg = cell:getChildByName("new_img")
           	local keyType = self.page.."_"..surfaceId
           	local key = UserData:getUserObj():getUid()..'changelook_sign_'..keyType
           	local value = cc.UserDefault:getInstance():getBoolForKey(key) or false
           	newImg:setVisible(value)

            cell:setTouchEnabled(true)
            cell:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                	if self.selectindex == j and self.selectType == i then
                		return
                	end
                	self.selectindex = j
                	local img = cell:getChildByName("selectimg") 
                	if img then
                		img:setVisible(true)
                		if self.oldSelectImg then
                			self.oldSelectImg:setVisible(false)
                		end
                		self.oldSelectImg = img
                	end
                    self:updateRigthInfo(i,j)
                    cc.UserDefault:getInstance():setBoolForKey(key,false)
                    newImg:setVisible(false)
                end
            end)

            local x = 60+90*((j-1)%5)
            local y = plheight-45-90*(math.ceil(j/5)-1)
            cell:setPosition(cc.p(x,y))

            local size = cell:getContentSize()
            local selectImg = self.selectImg:clone()
            selectImg:setPosition(cc.p(size.width/2,size.height/2))
            cell:addChild(selectImg)

            if j == self.selectindex and self.selectType == i then
            	self.oldSelectImg = selectImg
            	selectImg:setVisible(true)
            else
            	selectImg:setVisible(false)
            end
            pl:addChild(cell)
        end

        local heighttemp = 0 
        for k = 1, 2 do
            heighttemp = heighttemp + cellheight[k]
        end
        local tcellheight = 0
        for n = i,2 do
            if n == 2 then
                break
            else
               tcellheight = tcellheight + cellheight[n+1]
            end
        end  
        if heighttemp > size.height then
            innerContainer:setContentSize(cc.size(svwidth,heighttemp))
        end
        tempCell:setPosition(cc.p(0,tcellheight))

        self.cardSv:addChild(tempCell)

    end
end

function PeopleKingChangeLookUI:updateTime(timeTx,deadline,id)

	local diffTime = deadline - GlobalData:getServerTime()
    if diffTime < 0 then
        return
    end

    local label = timeTx:getChildByTag(9999)
    local size = timeTx:getContentSize()
    if label then
        label:removeFromParent()
    end
    label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
    label:setTag(9999)
    label:setPosition(cc.p(-110, size.height/2))
    label:setAnchorPoint(cc.p(0.5,0.5))
    timeTx:addChild(label)
    Utils:createCDLabel(label,diffTime,cc.c4b(255,247,229,255),COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT,'',COLOR_TYPE.WHITE,COLOR_TYPE.BLACK,25,function ()

		--取消激活,减少收集进度，如果是当前装备，当前装备ID=0
        local equipid,index = 0,1
        local lv =  self.suitdata.weapon_level or self.suitdata.wing_level
        for i=#self.longTimeItem,1,-1 do
            if self.longTimeItem[i].condition == "level" and self.longTimeItem[i].value <= lv then
                equipid = tonumber(self.longTimeItem[i].id)
                index = i
                break
            end
        end

        self.collectbeforAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
        for i = 1, 4 do
            self.collectbeforAttr[i] = self.collectbeforAttr[i] or 0
        end
        self.collectfightforce = RoleData:getFightForce()

        if self.page == 1 then
    		self.weaponActive[id] = nil
    		self.suitdata.weapon_collect = self.suitdata.weapon_collect - 1
            UserData:getUserObj():getPeopleKing().weapon_collect = self.suitdata.weapon_collect
    		if self.equipWeaponId == tonumber(id) then
    			self.equipWeaponId = equipid
                self.peopleKingData.weapon_illusion = equipid
    		end
    	else
    		self.wingActive[id] = nil
    		self.suitdata.wing_collect = self.suitdata.wing_collect - 1
            UserData:getUserObj():getPeopleKing().wing_collect = self.suitdata.wing_collect
    		if self.equipWingId == tonumber(id) then
    			self.equipWingId = equipid
                self.peopleKingData.wing_illusion = equipid
    		end
    	end

    	local keyType = self.page.."_"..id
	    local key = UserData:getUserObj():getUid()..'changelook_sign_'..keyType
	    cc.UserDefault:getInstance():setBoolForKey(key,false)

        --重新定位
        self.selectType = 1
        self.selectindex = index
        
        self:collectInfo(true)
        self:showCollectItem()
        self:updateRigthInfo(self.selectType,self.selectindex)
    end,4)
end

function PeopleKingChangeLookUI:updateRigthInfo(ntype,index)

	self.selectType = ntype
	ntype = ntype or 1
	index = index or 1
	if ntype < 1 or ntype > 2 then
		return
	end
	local itemCfg = ntype ==1 and self.longTimeItem or self.shortTimeItem
	if not itemCfg or not itemCfg[index] then
		print("wrong param" ,ntype,index)
		return
	end
    self.currConf = itemCfg[index]
    local surfaceId = itemCfg[index].id
	local isActive = self:getActiveInfo(surfaceId)
	local desc,key = itemCfg[index].getWayDesc,itemCfg[index].key
	--显示时间
	local time = itemCfg[index].baseLifeTime 
	if time == 0 then
		self.timeTxR:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_9"))
		local label = self.timeTxR:getChildByTag(9999)
	    if label then
	        label:removeFromParent()
	    end
	else 
		if not isActive then
			local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_11"),time)
			self.timeTxR:setString(str)
			local label = self.timeTxR:getChildByTag(9999)
		    if label then
		        label:removeFromParent()
		    end
		else
			--倒计时
    		local locktime = self.page == 1 and self.weaponLockTime or self.wingLockTime
    		local deadline = locktime[tostring(surfaceId)] or 0
			self.timeTxR:setString("")
			self:updateTime(self.timeTxR,deadline,surfaceId)
		end
	end
	
	--显示属性
    local str = GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_10")
    local funcname = GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_TITLE"..self.page)
    local attrValue = itemCfg[index].attribute
    
    local attrDescs = {'addAtk','addHp','addDef','addMdef'}
    local value = 0
    for i=1,4 do
        value = value + itemCfg[index][attrDescs[i]]
    end
    if attrValue > 0 then
        self.attrTxR:setString(string.format(str,funcname,attrValue).."%")
        self.attrTxR:setTouchEnabled(false)
    else
        self.attrTxR:setString(GlobalApi:getLocalStr("NB_SKY_DISPLAY_DESC_3"))
        self.attrTxR:setTouchEnabled(true)
    end
    self.attrTxR:setVisible((value + attrValue) > 0)

    --名字信息
   	local name = itemCfg[index].name 
   	self.headTx:setString(name)

   	--模型展示
    local roleObj = RoleData:getMainRole()
    local customObj = {}
    if self.page == 1 then
        customObj.weapon_illusion = tonumber(surfaceId)
    else
        customObj.wing_illusion = tonumber(surfaceId)
    end
    if not self.mainRoleAni then
        self.mainRoleAni = GlobalApi:createLittleLossyAniByName(roleObj:getUrl() .. "_display", nil, roleObj:getChangeEquipState(customObj))
        self.mainRoleAni:getAnimation():play("idle", -1, 1)
        self.mainRoleAni:setPosition(cc.p(0, 0))
        self.modeNode:addChild(self.mainRoleAni)
    else
        GlobalApi:changeModelEquip(self.mainRoleAni, roleObj:getUrl() .. "_display", roleObj:getChangeEquipState(customObj), 2)
    end

    local conditionType = itemCfg[index].condition
    local conditionValue = itemCfg[index].value
    local infoTx = self.changeBtn:getChildByName("info_tx")
    local cashIcon = self.changeBtn:getChildByName("cash")
    cashIcon:loadTexture('uires/ui/res/res_cash.png')
    self.getwayDesc:setString("")
    if isActive then
    	local equipId = (self.page == 1) and self.equipWeaponId  or self.equipWingId
    	if equipId == tonumber(surfaceId) then
    		infoTx:setString(GlobalApi:getLocalStr("STR_CANCEL_1"))
    	else
    		infoTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_TITLE"))	
    	end
    	self.changeBtn:setVisible(true)
    	cashIcon:setVisible(false)
    else
    	self.changeBtn:setVisible(conditionType == "buy")
    	cashIcon:setVisible(conditionType == "buy") 
	    if conditionType == "buy" then
	    	local cashTx = cashIcon:getChildByName("num_tx")
	    	cashTx:setString(conditionValue)
	    	local cash = UserData:getUserObj():getCash()
	    	local color = cash >= conditionValue and COLOR_TYPE.WHITE or COLOR_TYPE.RED
	    	cashTx:setColor(color)
	    	infoTx:setString("")
	    else
	    	infoTx:setString("")
	    	self.getwayDesc:setString(desc)	
	    end
    end
 
    self.changeBtn:addTouchEventListener(function (sender,eventType)
    	if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if isActive then
            	--佩戴
            	local choosId = tonumber(surfaceId)
            	local args = {
            		type = self.page,
            		id = choosId
            	}
                local actStr = 'illusion_sky'
                local equipId = choosId
                local equipedId =  self.page == 1 and self.equipWeaponId or self.equipWingId
                if equipedId ==  choosId then
                    actStr = 'cancel_illusion_sky' 
                    equipId = 0
                end
                MessageMgr:sendPost(actStr, 'hero', json.encode(args), function (jsonObj)
                    local code = jsonObj.code
                    local data = jsonObj.data
                    if code == 0 then
                        if self.page == 1 then
                            self.equipWeaponId = equipId
                            self.peopleKingData.weapon_illusion = equipId
                        else
                            self.equipWingId = equipId
                            self.peopleKingData.wing_illusion = equipId
                        end

                        local keyType = self.page.."_"..choosId
                        local key = UserData:getUserObj():getUid()..'changelook_sign_'..keyType
                        cc.UserDefault:getInstance():setBoolForKey(key,false)

                        self:showCollectItem()
                        self:updateRigthInfo(self.selectType,self.selectindex)

                        if self.callback then
                            self.callback()
                        end
                    end
                end)
            else
            	if conditionType == "buy" then

                    self.collectbeforAttr = self.page == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
                    for i = 1, 4 do
                        self.collectbeforAttr[i] = self.collectbeforAttr[i] or 0
                    end
                    self.collectfightforce = RoleData:getFightForce()

            		local function sendToServer()
                        --local choosId = tonumber(surfaceId)
                        local args = {
                            type = self.page,
                            id = surfaceId
                        }
                        MessageMgr:sendPost('illusion_sky_buy', 'hero', json.encode(args), function (jsonObj)
                            local code = jsonObj.code
                            local data = jsonObj.data
                            if code == 0 then
                                if self.page == 1 then
                                    self.weaponActive[surfaceId] = 1
                                    self.suitdata.weapon_collect = self.suitdata.weapon_collect+1
                                    UserData:getUserObj():getPeopleKing().weapon_collect = self.suitdata.weapon_collect
                                    self.weaponLockTime = data.weapon_illusion_equip_time
                                    local ownWeapon = self.peopleKingData.ownWeapon
                                    ownWeapon[#ownWeapon+1] = tonumber(surfaceId)
                                    UserData:getUserObj():getPeopleKing().ownWeapon = ownWeapon
                                else
                                    self.wingActive[surfaceId] = 1
                                    self.suitdata.wing_collect = self.suitdata.wing_collect+1
                                    UserData:getUserObj():getPeopleKing().wing_collect = self.suitdata.wing_collect
                                    self.wingLockTime = data.wing_illusion_equip_time
                                    local ownWing = self.peopleKingData.ownWing
                                    ownWing[#ownWing+1] = tonumber(surfaceId)
                                    UserData:getUserObj():getPeopleKing().ownWing = ownWing
                                end

                                local costs = data.costs
                                if costs then
                                    GlobalApi:parseAwardData(costs)
                                end
                                
                                --[[local keyType = self.page.."_"..surfaceId
                                local key = UserData:getUserObj():getUid()..'changelook_sign_'..keyType
                                cc.UserDefault:getInstance():setBoolForKey(key,true)]]

                                self:collectInfo(true)
                                self:showCollectItem()
                                self:updateRigthInfo(self.selectType,self.selectindex)

                                if self.callback then
                                    self.callback()
                                end
                            end
                        end)
                    end
                    local str = string.format(GlobalApi:getLocalStr('PEOPLE_KING_CHANGELOOK_DESC_13'),conditionValue,itemCfg[index].name)
                    if ntype == 2 then
                        str = string.format(GlobalApi:getLocalStr('PEOPLE_KING_CHANGELOOK_DESC_14'),conditionValue,itemCfg[index].name,itemCfg[index].baseLifeTime)
                    end
                    UserData:getUserObj():cost('cash',conditionValue,sendToServer,true,str,conditionValue)
                end
            end
        end
    end)
end

function PeopleKingChangeLookUI:chooseWin(page)
    local openStr = page == 1 and "weapon" or "wing"
    local isOpen,isnotIn,cityId,level = GlobalApi:getOpenInfo(openStr)
    if not isOpen and not isNotIn then
        local str
        if level then
            str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
        elseif cityData then
            str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
        else
            str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
        end
        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
        return
    end
    self.page = page
    for i = 1,2 do
        if i == self.page then
            self.pageBtns[i].btn:setBrightStyle(ccui.BrightStyle.highlight)
            self.pageBtns[i].btn:setTouchEnabled(false)
            self.pageBtns[i].tx:setColor(COLOR_TYPE.PALE)
            self.pageBtns[i].tx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            self.pageBtns[i].tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i].btn:setBrightStyle(ccui.BrightStyle.normal)
            self.pageBtns[i].btn:setTouchEnabled(true)
            self.pageBtns[i].tx:setColor(COLOR_TYPE.DARK)
            self.pageBtns[i].tx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            self.pageBtns[i].tx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
    self.attrCfg = GameData:getConfData("attribute")
    local collectCnf = GameData:getConfData("skycollect")[self.page]
    self.maxProgress = #collectCnf
    self.collectCfg = {}
    for k,v in pairs(collectCnf) do
    	if type(k) == "number" then
    		self.collectCfg[k] = v
    	end
    end

    local collectItemCfg = GameData:getConfData("skychange")[self.page]
    self.longTimeItem = {}				--永久
    self.shortTimeItem = {}				--临时
    for i=1,#collectItemCfg do
    	local ntype = collectItemCfg[i].kind
    	if ntype == 1 then
    		self.longTimeItem[#self.longTimeItem+1] = collectItemCfg[i]
    	else
    		self.shortTimeItem[#self.shortTimeItem+1] = collectItemCfg[i]
    	end
    end
    self.oldPosX = -1
    self.selectindex = 1
    self.selectType = 1
    self:collectInfo()
    self:showCollectItem()
    self:updateRigthInfo(self.selectType,self.selectindex)
    self.cardSv:scrollToTop(0.01, false)
end
return PeopleKingChangeLookUI