local TagWallUI = class("TagWallUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassRoleObj = require('script/app/obj/roleobj')

function TagWallUI:ctor()
    self.uiIndex = GAME_UI.UI_TAGWALL
	
	self.selected=1

	self.heroList={}
    self.heroConfig = GameData:getConfData("hero")
	self.equipConfig = GameData:getConfData("equip")
	self.equipList={}

    self.numOfMaxTags = 7
    self.tags = {}

    self.unusedTags = {1,2,3,4,5,6,7}

end
function TagWallUI:init()
    
    local bg   =  self.root:getChildByName("bg")
    local root =  bg:getChildByName("root")

    self.tagRoot    =  ccui.Helper:seekWidgetByName(root,"tagRoot")
    self.roleRoot   =  ccui.Helper:seekWidgetByName(root,"roleRoot")
    
    self.headbg    =  ccui.Helper:seekWidgetByName(root, 'headbg')
    self.head_sv    =  ccui.Helper:seekWidgetByName(root, 'head_sv')
    self.head_sv:setScrollBarEnabled(false)

    self.closeBtn = ccui.Helper:seekWidgetByName(root,"closeBtn")

    self.title = ccui.Helper:seekWidgetByName(root,"title")
    self.title:setString(GlobalApi:getLocalStr("HONORHALL_TAGTITLE"))
    --tagview

    local title = ccui.Helper:seekWidgetByName(self.tagRoot,"title")
    title:setString(GlobalApi:getLocalStr("HONORHALL_TAGTITLE"))

    local tagContent = ccui.Helper:seekWidgetByName(self.tagRoot,"tagsBG")
    for i = 1,self.numOfMaxTags do
        print("tag_cell"..i)
        local tag = ccui.Helper:seekWidgetByName(tagContent,"tag_cell"..i)
        tag.text  = ccui.Helper:seekWidgetByName(tag,"text")
        tag:setVisible(false)
        table.insert(self.tags,tag)
    end

    self.editBG    = ccui.Helper:seekWidgetByName(self.tagRoot,"editBG")
    self.editText  = ccui.Helper:seekWidgetByName(self.editBG,"text")
    self.inputClip = ccui.Helper:seekWidgetByName(self.editBG,"clip")
    self.nameTx = ccui.Helper:seekWidgetByName(self.editBG,"inputText")
    self.editBtn   = ccui.Helper:seekWidgetByName(self.editBG,"inputBtn")
    self.editBtnTx = ccui.Helper:seekWidgetByName(self.editBG,"inputBtnText")
    self.editBtnTx:setString(GlobalApi:getLocalStr("HONORHALL_ADD"))
   

    --heroview
    self.armNodes = {}
    for i=1,6 do
		local armnode = self.roleRoot:getChildByName('arm_' .. i .. '_img')
        armnode:setLocalZOrder(2)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil, true)
        tab.awardBgImg:setPosition(cc.p(47,47))
        tab.awardImg:ignoreContentAdaptWithSize(true)
        armnode:addChild(tab.awardBgImg)
        tab.node = armnode
        table.insert(self.equipList, tab)
	end
	self.heroName   = ccui.Helper:seekWidgetByName(self.roleRoot,'name')
	self.roleBg     = self.roleRoot:getChildByName('roleBg')
	self.fightForce = ccui.Helper:seekWidgetByName(self.roleRoot,'fightforce_tx')	

   
    self.tempHeadCell=ccui.Helper:seekWidgetByName(self.headbg, 'headCell')
    self.tempHeadCell:setVisible(false)
	self.tempHeadCell:setTouchEnabled(false)


    self:adaptUI(bg,root,false)

    self:createEditBox(self.inputClip)

     local function clickClose(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            HonorHallMgr:hideTagWallUI()
        end
    end
    self.closeBtn:addTouchEventListener(clickClose)

    self.actionLine = cc.CSLoader:createTimeline("csb/tagwallui.csb")
    self.actionLine:gotoFrameAndPlay(0,55,false)
    self.root:runAction(self.actionLine)

end
function TagWallUI:ActionClose(call)

    self.actionLine:gotoFrameAndPlay(57,95,false)
    --self.root:runAction(action)
    self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.66),cc.CallFunc:create(function ()
            self:hideUI()
        end)))
end
function TagWallUI:displayByData(data,typeString,uid)
    self.data=data
    self.typeString = typeString
    self.uid = uid

    for k,hero in pairs(data.info.pos) do
		local info=self.heroConfig[tonumber(hero.hid)]
        local obj = ClassRoleObj.new(hero.hid,0)
        obj:setPromoted(hero.promote)
		if info~=nil then
            hero.hid=hero.hid
			hero.pos=k
			hero.icon="uires/icon/hero/" .. info.heroIcon
			hero.isKing = (tonumber(k)==1) and true or false
            hero.quality=obj:getQuality()
			hero.equips={}
            hero.offsetY = info.uiOffsetY
            hero.name=(hero.isKing==true) and GlobalApi:getLocalStr('STR_MAIN_NAME') or info.heroName
            hero.promoteSpecial = hero.promote
			for m,equip in pairs(hero.equip) do
				local equipInfo=self.equipConfig[tonumber(equip.id)]
                local equipObj = DisplayData:getDisplayObj({'equip',equip.id,equip.god_id,1})
                if equipInfo~=nil then
                    equip.pos=equipInfo.type
                    equip.obj = equipObj:getObj()
                    equip.award = equipObj
                    if hero.part then
                        equip.partLevel = hero.part[tostring(m)].level or 0
                    else
                        equip.partLevel = 0
                    end
                    -- equip.icon="uires/icon/equip/" .. equipInfo.icon
                    -- equip.level=equipInfo.level
                    -- equip.god=equip.god
                    -- equip.god_id=equip.god_id
                    -- equip.quality=equipInfo.quality
                    -- equip.equipObj = equipObj
                end
			end
			table.insert(self.heroList, hero)
		end
	end
    table.sort(self.heroList, function (a, b)
        return (a.isKing or a.fight_force > b.fight_force) and not b.isKing
    end)
    self.targetName=data.info.un

    local numOfHero = #self.heroList
    local maxX = (numOfHero)*104 +(numOfHero-1)* 10 + 12
    local svSize = self.head_sv:getContentSize()

    if(maxX > svSize.width) then
        self.head_sv:setInnerContainerSize(cc.size(maxX,svSize.height))
    end

    for i = 1, numOfHero do
		local headPic = self:createHeadCell(i)
		local innerX = 12 + (i-1)*(104 + 10)
		headPic:setPosition(cc.p(innerX, svSize.height/2))
		self.head_sv:addChild(headPic)
	end

    self:setHeroView(1)

    self:showTags()
end
function TagWallUI:showTags()
    
    self.unusedTags = {2,3,4,5,6,7}
    if(self.data.info.bullet ~= nil) then
        local tag = nil
        local maxNum = #self.data.info.bullet
        local startNum = 1
        if(maxNum > 7) then
            startNum = maxNum - 7 + 1
        end 

        for i = startNum,maxNum do
            if(i == startNum) then
                tag = self.tags[i]
            else
                local index = math.random(1,#self.unusedTags)
                local tagIndex = self.unusedTags[index]
                tag = self.tags[tagIndex] 
                table.remove(self.unusedTags,index)
            end
            tag:setVisible(true)
            tag.text:setString(self.data.info.bullet[i])
        end
    end

    for k,index in pairs(self.unusedTags) do
        self.tags[index]:setVisible(false)
    end

    local richText = xx.RichText:create()
    self.editBG:addChild(richText)
    richText:setContentSize(cc.size(400, 28))
    richText:setPosition(cc.p(self.editText:getPosition()))
    richText:setAlignment('left')
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('HONORHALL_ADDTAG1'), 20, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re2 = xx.RichTextLabel:create(self.data.info.un, 20, COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('HONORHALL_ADDTAG2'), 20, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
    richText:format(true)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setContentSize(richText:getElementsSize())
	
    
    
    
end
function TagWallUI:createHeadCell(idx)
	local hero=self.heroList[idx]
	
    local newCell = self.tempHeadCell:clone()
    ---------------------------
    ClassItemCell:setHeroPromote(newCell,hero.hid,hero.promoteSpecial)
    ---------------------------
	newCell:setName('cell'..idx)
	newCell.icon = ccui.Helper:seekWidgetByName(newCell,"icon")
    newCell.selectPic = ccui.Helper:seekWidgetByName(newCell,"selectPic")
    newCell.kingPic = ccui.Helper:seekWidgetByName(newCell,"kingPic")
	newCell.lvText = ccui.Helper:seekWidgetByName(newCell,"lv")
	
	newCell.icon:loadTexture(hero.icon)
	newCell.selectPic:setVisible(false)
	newCell.kingPic:setVisible(hero.isKing)
	newCell.lvText:setString("Lv."..hero.level)
	
    newCell:setVisible(true)
	newCell:setTouchEnabled(true)
	newCell:addClickEventListener(function ()
			self:setHeroView(idx)
        end)
    
		
    return newCell 
end
function TagWallUI:createEditBox(attachNode)
    local maxLen = 8
    self.editbox = cc.EditBox:create(cc.size(attachNode:getContentSize().width,32), 'uires/ui/common/bg1_alpha.png')
    self.editbox:setPosition(ccp(attachNode:getContentSize().width/2,attachNode:getContentSize().height/2))
    self.editbox:setFont('font/gamefont.ttf',20)
    self.editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editbox:setMaxLength(maxLen*10)
    attachNode:addChild(self.editbox)
    self.editbox:setLocalZOrder(0)
    self.editbox:setContentSize(cc.size(176,32))

    -- self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    -- self.nameTx:setPosition(cc.p(10, attachNode:getContentSize().height/2))
    -- self.nameTx:setColor(COLOR_TYPE.WHITE)
    -- self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    -- self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    -- self.nameTx:setAnchorPoint(cc.p(0,0.5))
    -- self.nameTx:setName('name_tx')
    -- attachNode:addChild(self.nameTx)

    self.editBtn:addTouchEventListener(function(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if(self.nameTx:getString() == "") then
                promptmgr:showMessageBox(GlobalApi:getLocalStr('HONORHALL_ADDTAG3'), MESSAGE_BOX_TYPE.MB_OK)
                return
            end
            local hero=self.heroList[self.selected]
            if hero==nil then
                return
            end
            HonorHallMgr:AddTag(self.typeString,self.uid,self.nameTx:getString())
            self.nameTx:setString("")
        end
    end)

    local oldStr = ''
    self.editbox:registerScriptEditBoxHandler(function(event, editbox)
        if event == "began" then
            self.editbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
        elseif event == "ended" then
            local str = self.editbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.editbox:setText('')
        end
    end) 
end
function TagWallUI:refreshTag(bullets)
        self.data.info.bullet = bullets
        self:showTags()
end
function TagWallUI:setHeroView(idx)
	self.selected=idx
	for i = 1, #self.heroList do
		local cell=ccui.Helper:seekWidgetByName(self.head_sv, 'cell'..i)
        if(i == idx) then
            cell.selectPic:setOpacity(0)
            cell.selectPic:runAction(cc.FadeIn:create(0.2))
            cell.selectPic:setVisible(true)
        else
            cell.selectPic:setVisible(false)
        end
	end
	
	local hero=self.heroList[idx]
	if hero==nil then
		return
	end
	
	for i=1, 6 do
		local equipObj=nil
        local partLevel = 0
		for k,v in pairs(hero.equip) do
			if v.pos==i then
				equipObj=v
                partLevel = v.partLevel
			end
		end

        local num = 0
        local num1 = 1
        local pos = {
            [1] = {cc.p(48,91)},
            [2] = {cc.p(40,91),cc.p(56,91)},
            [3] = {cc.p(32,91),cc.p(48,91),cc.p(64,91)},
            [4] = {cc.p(24,91),cc.p(40,91),cc.p(56,91),cc.p(72,91)},
			[5] = {cc.p(16,91),cc.p(32,91),cc.p(48,91),cc.p(64,91),cc.p(80,91)},
        }
        if partLevel == 10 then
            num = 4
            num1 = 3
        elseif partLevel == 0 then
            num = 0
            num1 = 0
        else
            num = (partLevel - 1)%3 + 1
            num1 = math.ceil(partLevel/3)
        end
		
		if partLevel > 10 then
			num = partLevel - 10
			num1 = 4
		end

        for j=1,5 do
            if j <= num then
                self.equipList[i].rhombImgs[j]:loadTexture('uires/ui/common/rhomb_'..num1..'.png')
                self.equipList[i].rhombImgs[j]:setVisible(true)
                self.equipList[i].rhombImgs[j]:setPosition(pos[num][j])
            else
                self.equipList[i].rhombImgs[j]:setVisible(false)
            end
        end

		if equipObj~=nil then
            local obj = equipObj.obj
            ClassItemCell:updateItem(self.equipList[i], equipObj.obj, 1)
			ClassItemCell:setGodLight(self.equipList[i].awardBgImg, equipObj.obj:getGodId())
            self.equipList[i].lvTx:setVisible(true)
			self.equipList[i].lvTx:setString('Lv.'..equipObj.obj:getLevel())	
            self.equipList[i].awardBgImg:setTouchEnabled(true)
            self.equipList[i].awardBgImg:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(equipObj.award, false)
		        end
		    end)		

            local godlv = equipObj.god
			if godlv > 0 then
				self.equipList[i].starImg:setVisible(true)
				self.equipList[i].starLv:setString(godlv)
			else
				self.equipList[i].starImg:setVisible(false)
				self.equipList[i].starLv:setVisible(false)
			end

		else
			self.equipList[i].awardBgImg:loadTexture('uires/ui/common/frame_default.png')
			self.equipList[i].starImg:setVisible(false)
            self.equipList[i].starLv:setVisible(false)
			self.equipList[i].awardImg:loadTexture(DEFAULTEQUIP[i]) 
			self.equipList[i].lvTx:setVisible(false)
			ClassItemCell:setGodLight(self.equipList[i].awardBgImg, 0)
            self.equipList[i].awardBgImg:setTouchEnabled(false)
		end
	end
    local promote = nil
    local weapon_illusion = nil
    local wing_illusion = nil
    if hero.promote and hero.promote[1] then
        promote = hero.promote[1]
    end
    local heroConf = GameData:getConfData("hero")
    if heroConf[tonumber(hero.hid)].camp == 5 then
        if self.data.info.weapon_illusion and self.data.info.weapon_illusion > 0 then
            weapon_illusion = self.data.info.weapon_illusion
        end
        if self.data.info.wing_illusion and self.data.info.wing_illusion > 0 then
            wing_illusion = self.data.info.wing_illusion
        end
    end
    local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
	local model = GlobalApi:createLittleLossyAniByRoleId(tonumber(hero.hid), changeEquipObj)
	self.roleBg:removeAllChildren()
	if model~=nil then
		model:getAnimation():play('idle', -1, 1)
		self.roleBg:addChild(model)
        model:setPosition(cc.p(0,hero.offsetY))
	end
	
	self.fightForce:setString(hero.fight_force)
	self.heroName:setString(hero.name)
	self.heroName:setTextColor(COLOR_QUALITY[hero.quality])
end
function TagWallUI:isDroid(uid)
	if tonumber(uid) <= 1000000 then
		return true
	else
		return false
	end
end


return TagWallUI