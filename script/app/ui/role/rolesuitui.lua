local SuitUI = class("SuitUI", BaseUI)
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemUpgradeUI = require("script/app/ui/gem/gemupgradenewui")
local ClassEquipSelectUI = require("script/app/ui/equip/equipselectui")
local ClassItemCell = require('script/app/global/itemcell')
local ClassEquipObj = require('script/app/obj/equipobj')

local MAX_PAGE = 4
function SuitUI:ctor(pos,page)
	self.uiIndex = GAME_UI.UI_SUIT
	self.pos = pos
	self.obj = RoleData:getRoleByPos(pos)
	self.page = page
	self.suitLv = {}
end

function SuitUI:onShow()
	self:updatePanel()
end

function SuitUI:createRts(desc1,desc2,desc3)
	if not self.titleRts then
		local richText = xx.RichText:create()
		richText:setContentSize(cc.size(600, 40))
		richText:setAnchorPoint(cc.p(0.5, 0.5))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
		local re = xx.RichTextLabel:create(tx, 22, COLOR_TYPE.WHITE)
		re:setMinWidth(120)
		re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
		local re = xx.RichTextImage:create('uires/ui/common/title_bg_small_right.png')
		re:setScaleX(-1)
		local re1 = xx.RichTextLabel:create(desc1, 28, COLOR_TYPE.PALE)
		re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
		re1:setFont('font/gamefont.ttf')
		re1:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		local re2 = xx.RichTextLabel:create(desc2, 28, COLOR_TYPE.GREEN)
		re2:setStroke(COLOROUTLINE_TYPE.GREEN, 2)
		re2:setFont('font/gamefont.ttf')
		re2:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		local re3 = xx.RichTextLabel:create(desc3, 28, COLOR_TYPE.PALE)
		re3:setStroke(COLOROUTLINE_TYPE.PALE, 2)
		re3:setFont('font/gamefont.ttf')
		re3:setShadow(cc.c4b(64, 64, 64, 255), cc.size(0, -1))
		local re4 = xx.RichTextImage:create('uires/ui/common/title_bg_small_right.png')
		richText:addElement(re)
		richText:addElement(re1)
		richText:addElement(re2)
		richText:addElement(re3)
		richText:addElement(re4)
		local size = self.gemPl:getContentSize()
		richText:setPosition(cc.p(size.width/2,460))
		self.gemPl:addChild(richText)
		self.titleRts = {richText = richText ,re = re,re1 = re1,re2 = re2,re3 = re3,re4 = re4}
	else
		self.titleRts.re1:setString(desc1)
		self.titleRts.re2:setString(desc2)
		self.titleRts.re3:setString(desc3)
		self.titleRts.richText:format(true)
	end
end

function SuitUI:changeEquip(img,i)
	img:addTouchEventListener(function (sender, eventType)
   		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
	        local equipObj = self.obj:getEquipByIndex(i)
	        local obj = {}
			if equipObj then
				obj[equipObj:getSId()] = equipObj
			end
			local level = self.obj:getLevel()
			level = (level - level%10) + 10
			local roleobj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
            local equipSelectUI = ClassEquipSelectUI.new(roleobj,obj, 0, i, 0, 100000, function (map)
            	for k,v in pairs(map) do
            		if v then
			            local obj = self.obj:getEquipByIndex(v:getType())
			            local equipObj = v
			            if obj and obj:getGodId() ~= 0 and equipObj:getGodId() == 0 then
			                local godLevel = obj:getGodLevel()
			                local godEquipConf = GameData:getConfData("godequip")
			                local godEquipObj = godEquipConf[equipObj:getType()][godLevel]
			                local cost = -obj:getInheritCost()
			                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('MESSAGE_3'),cost,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
			                        self:SendPost(equipObj,1,cost)
			                  end,GlobalApi:getLocalStr('TAVERN_YES'),GlobalApi:getLocalStr('TAVERN_NO'),function ()
			                        self:SendPost(equipObj,0)
			                  end)                 
			            else
			                self:SendPost(equipObj,0)
			            end
            		end
            	end
            	return true
            end,2)
            equipSelectUI:showUI()
        end
    end)
end

function SuitUI:updateEquipRifineBottomPanel(minGodNum,maxGodNum)
	local attributeConf = GameData:getConfData("attribute")
	local conf = GameData:getConfData("equiprefinesuit")
	local bottomImg = self.gemPl:getChildByName('bottom_img')
	local leftPl = bottomImg:getChildByName('left_pl')
	local rightPl = bottomImg:getChildByName('right_pl')
	local arrowImg = bottomImg:getChildByName('arrow_img')
	local pls = {leftPl,rightPl}
	local lvs = {minGodNum,maxGodNum}
	local pos = {cc.p(204,0),cc.p(584,0)}
	for i,v in ipairs(pls) do
		local nameTx = v:getChildByName('name_tx')
		local lvTx = v:getChildByName('lv_tx')
		local descTx1 = v:getChildByName('desc_tx_1')
		local descTx2 = v:getChildByName('desc_tx_2')
		local numTx1 = v:getChildByName('num_tx_1')
		local numTx2 = v:getChildByName('num_tx_2')
		local attrTxs = {numTx1,numTx2}
		local descTxs = {descTx1,descTx2}
		v:setPosition(pos[i])
		lvTx:setString('Lv.'..lvs[i])
		nameTx:setString(GlobalApi:getLocalStr('SUIT_DESC_11'))
		local attributes = conf[lvs[i]].attribute
		for j,v1 in ipairs(attributes) do
			local tab = string.split(v1, ':')
			local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
			attrTxs[j]:setString('+'..tonumber(tab[2])..per)
			descTxs[j]:setString(attributeConf[tonumber(tab[1])].name)
			if i == 2 then
				local upImg = rightPl:getChildByName('arrow_img_1')
				upImg:setPosition(cc.p(lvTx:getPositionX() + lvTx:getContentSize().width + 15,lvTx:getPositionY()))
				local upImg = rightPl:getChildByName('arrow_img_'..(j + 1))
				upImg:setPosition(cc.p(attrTxs[j]:getPositionX() + attrTxs[j]:getContentSize().width + 15,attrTxs[j]:getPositionY()))
			end
		end
	end
	if minGodNum == maxGodNum then
		leftPl:setPosition(cc.p(394,0))
		rightPl:setVisible(false)
		arrowImg:setVisible(false)
	else
		leftPl:setPosition(cc.p(204,0))
		rightPl:setPosition(cc.p(584,0))
		rightPl:setVisible(true)
		arrowImg:setVisible(true)
	end
end

function SuitUI:updateEquipRifineTopPanel()
	local conf = GameData:getConfData("equiprefine")
	local minPartLv = #conf[1]
	local maxPartLv = 0
	for i=1,6 do
		local partInfo = self.obj:getPartInfoByPos(i)
		local level = partInfo.level
		minPartLv = (level > minPartLv) and minPartLv or level
	end
	if minPartLv >= #conf[1] then
		maxPartLv = #conf[1]
	elseif minPartLv == 0 then
		maxPartLv = 1
	else
		maxPartLv = minPartLv + 1
	end
	self:createRts(self.obj:getName()..GlobalApi:getLocalStr('SUIT_DESC_12'),maxPartLv,GlobalApi:getLocalStr('SOLDIER0'))
	for i=1,6 do
		local partInfo = self.obj:getPartInfoByPos(i)
		local godId = 0
		local currLv = 1
		local equipImg = self.gemPl:getChildByName('equip_img_'..i)
		equipImg:setTouchEnabled(true)
		local barbg = equipImg:getChildByName('bar_bg')
		local bar = barbg:getChildByName('bar')
		local barTx = bar:getChildByName('bar_tx')
		local starImg = barbg:getChildByName('star_img')
		local awardBgImg = equipImg:getChildByName('award_bg_img')
		if not awardBgImg then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			awardBgImg = tab.awardBgImg
			awardBgImg:setPosition(cc.p(47,56))
			awardBgImg:setScale(0.8)
			awardBgImg:setTouchEnabled(false)
			equipImg:addChild(awardBgImg)
		end
		local starImg1 = awardBgImg:getChildByName('star_img')
		starImg1:setVisible(false)
		local nameTx = awardBgImg:getChildByName('name_tx')
		starImg:setVisible(false)
		barbg:setVisible(true)
		nameTx:setString(GlobalApi:getLocalStr('EQUIP_TYPE_'..i))
		nameTx:setScale(1.25)
		nameTx:setPosition(cc.p(195,69))
		nameTx:setColor(COLOR_TYPE.RED)
		nameTx:enableOutline(COLOROUTLINE_TYPE.RED,1)
		awardBgImg:loadTexture("uires/ui/common/frame_gray.png")
		local awardImg = awardBgImg:getChildByName('award_img')
		awardImg:loadTexture(DEFAULTEQUIPPART[i])
		local percent =string.format("%.2f", partInfo.level/#conf[i]*100)
		bar:setPercent(percent)
		barTx:setString(partInfo.level..'/'..#conf[i])
		equipImg:addTouchEventListener(function (sender, eventType)
	   		if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	RoleMgr:showEquipRefine(self.pos,i)
	        end
	    end)
	    ClassItemCell:setGodLight(awardBgImg,0)
		awardBgImg:ignoreContentAdaptWithSize(true)
	end
	self:updateEquipRifineBottomPanel(minPartLv,maxPartLv)
end

function SuitUI:updateEquipGemBottomPanel(minGemLv,maxGemLv)
	local attributeConf = GameData:getConfData("attribute")
	local conf = GameData:getConfData("gemsuit")
	local bottomImg = self.gemPl:getChildByName('bottom_img')
	local leftPl = bottomImg:getChildByName('left_pl')
	local rightPl = bottomImg:getChildByName('right_pl')
	local arrowImg = bottomImg:getChildByName('arrow_img')
	local pls = {leftPl,rightPl}
	local lvs = {minGemLv,maxGemLv}
	local pos = {cc.p(204,0),cc.p(584,0)}
	for i,v in ipairs(pls) do
		local nameTx = v:getChildByName('name_tx')
		local lvTx = v:getChildByName('lv_tx')
		local descTx1 = v:getChildByName('desc_tx_1')
		local descTx2 = v:getChildByName('desc_tx_2')
		local numTx1 = v:getChildByName('num_tx_1')
		local numTx2 = v:getChildByName('num_tx_2')
		local attrTxs = {numTx1,numTx2}
		local descTxs = {descTx1,descTx2}
		v:setPosition(pos[i])
		lvTx:setString('Lv.'..lvs[i])
		nameTx:setString(GlobalApi:getLocalStr('SUIT_DESC_7'))
		local attributes = conf[lvs[i]].attribute
		for j,v1 in ipairs(attributes) do
			local tab = string.split(v1, ':')
			local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
			attrTxs[j]:setString('+'..tonumber(tab[2])..per)
			descTxs[j]:setString(attributeConf[tonumber(tab[1])].name)
			if i == 2 then
				local upImg = rightPl:getChildByName('arrow_img_1')
				upImg:setPosition(cc.p(lvTx:getPositionX() + lvTx:getContentSize().width + 15,lvTx:getPositionY()))
				local upImg = rightPl:getChildByName('arrow_img_'..(j + 1))
				upImg:setPosition(cc.p(attrTxs[j]:getPositionX() + attrTxs[j]:getContentSize().width + 15,attrTxs[j]:getPositionY()))
			end
		end
	end
	if minGemLv == maxGemLv then
		leftPl:setPosition(cc.p(394,0))
		rightPl:setVisible(false)
		arrowImg:setVisible(false)
	else
		leftPl:setPosition(cc.p(204,0))
		rightPl:setPosition(cc.p(584,0))
		rightPl:setVisible(true)
		arrowImg:setVisible(true)
	end
end

function SuitUI:updateEquipGemTopPanel()
	local minGemLv = 12
	local maxGemLv = 0
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		if equipObj then
			local gems = equipObj:getGems()
			for i=1,4 do
				local gem = gems[i]
				if gem then
					local gemLv = gem:getLevel()
					minGemLv = (gemLv > minGemLv) and minGemLv or gemLv
				else
					minGemLv = 0
					break
				end
			end
		else
			minGemLv = 0
			break
		end
	end
	if minGemLv >= 12 then
		maxGemLv = 12
	elseif minGemLv == 0 then
		maxGemLv = 1
	else
		maxGemLv = minGemLv + 1
	end
	self:createRts(self.obj:getName()..GlobalApi:getLocalStr('SUIT_DESC_4'),maxGemLv,GlobalApi:getLocalStr('SUIT_DESC_10'))
	local maxGemNum = 4
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		local godId = 0
		local currLv = 1
		local equipImg = self.gemPl:getChildByName('equip_img_'..i)
		equipImg:setTouchEnabled(true)
		local barbg = equipImg:getChildByName('bar_bg')
		local bar = barbg:getChildByName('bar')
		local barTx = bar:getChildByName('bar_tx')
		local starImg = barbg:getChildByName('star_img')
		local awardBgImg = equipImg:getChildByName('award_bg_img')
		if not awardBgImg then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			awardBgImg = tab.awardBgImg
			awardBgImg:setPosition(cc.p(47,56))
			awardBgImg:setScale(0.8)
			awardBgImg:setTouchEnabled(false)
			equipImg:addChild(awardBgImg)
		end
		local addImg = awardBgImg:getChildByName('add_img')
		local nameTx = awardBgImg:getChildByName('name_tx')
		addImg:loadTexture('uires/ui/common/add_04.png')
		if equipObj then
			ClassItemCell:updateItem(awardBgImg, equipObj, 2)
			nameTx:setString(equipObj:getName())
			nameTx:setColor(equipObj:getNameColor())
			nameTx:enableOutline(equipObj:getNameOutlineColor(),1)
			addImg:setVisible(false)
			nameTx:setScale(1.25*22/24)
			local gems = equipObj:getGems()
			local num = 0
			for j=1,4 do
				local gem = gems[j]
				if gem then
					local gemLv = gem:getLevel()
					if gemLv >= maxGemLv then
						num = num + 1
					end
				end
			end
			nameTx:setPosition(cc.p(195,69))
			barbg:setVisible(true)
			barTx:setString(num..'/'..maxGemNum)
			local percent =string.format("%.2f", num/maxGemNum*100)
			bar:setPercent(percent)
			starImg:loadTexture('uires/icon/gem/gem'..(maxGemLv + 100)..'.png')
			starImg:setPosition(cc.p(0,13))
			equipImg:addTouchEventListener(function (sender, eventType)
		   		if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	RoleMgr:showGemFill(self.pos)
		        end
		    end)
		    godId = equipObj:getGodId()
		else
			local starImg1 = awardBgImg:getChildByName('star_img')
			starImg1:setVisible(false)
			local awardImg = awardBgImg:getChildByName('award_img')
			awardImg:loadTexture(DEFAULTEQUIP[i])
			awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
			barbg:setVisible(false)
			nameTx:setPosition(cc.p(195,47))
			nameTx:setScale(1.25)
			nameTx:setString(GlobalApi:getLocalStr('SUIT_DESC_6'))
			nameTx:setColor(COLOR_TYPE.RED)
			nameTx:enableOutline(COLOROUTLINE_TYPE.RED,1)
			local tab = BagData:getEquipMapByType(i)
			local index = 0
			if tab then
				local level = UserData:getUserObj():getLv()
				for k,v in pairs(tab) do
					if level + 10 >= v:getLevel() then
						index = index + 1
					end
				end
				if index > 0 then
					addImg:setVisible(true)
				else
					addImg:setVisible(false)
				end
			end
			self:changeEquip(equipImg,i)
		end
		ClassItemCell:setGodLight(awardBgImg, godId)
	end
	self:updateEquipGemBottomPanel(minGemLv,maxGemLv)
end

function SuitUI:updateEquipGodBottomPanel(minGodNum,maxGodNum)
	local attributeConf = GameData:getConfData("attribute")
	local conf = GameData:getConfData("equipsuit")
	local bottomImg = self.gemPl:getChildByName('bottom_img')
	local leftPl = bottomImg:getChildByName('left_pl')
	local rightPl = bottomImg:getChildByName('right_pl')
	local arrowImg = bottomImg:getChildByName('arrow_img')
	local pls = {leftPl,rightPl}
	local lvs = {minGodNum,maxGodNum}
	local pos = {cc.p(204,0),cc.p(584,0)}
	for i,v in ipairs(pls) do
		local nameTx = v:getChildByName('name_tx')
		local lvTx = v:getChildByName('lv_tx')
		local descTx1 = v:getChildByName('desc_tx_1')
		local descTx2 = v:getChildByName('desc_tx_2')
		local numTx1 = v:getChildByName('num_tx_1')
		local numTx2 = v:getChildByName('num_tx_2')
		local attrTxs = {numTx1,numTx2}
		local descTxs = {descTx1,descTx2}
		v:setPosition(pos[i])
		lvTx:setString('Lv.'..lvs[i])
		nameTx:setString(GlobalApi:getLocalStr('SUIT_DESC_5'))
		local attributes = conf[lvs[i]].attribute
		for j,v1 in ipairs(attributes) do
			local tab = string.split(v1, ':')
			local per = (attributeConf[tonumber(tab[1])].desc == '0') and '' or '%'
			attrTxs[j]:setString('+'..tonumber(tab[2])..per)
			descTxs[j]:setString(attributeConf[tonumber(tab[1])].name)
			if i == 2 then
				local upImg = rightPl:getChildByName('arrow_img_1')
				upImg:setPosition(cc.p(lvTx:getPositionX() + lvTx:getContentSize().width + 15,lvTx:getPositionY()))
				local upImg = rightPl:getChildByName('arrow_img_'..(j + 1))
				upImg:setPosition(cc.p(attrTxs[j]:getPositionX() + attrTxs[j]:getContentSize().width + 15,attrTxs[j]:getPositionY()))
			end
		end
	end
	if minGodNum == maxGodNum then
		leftPl:setPosition(cc.p(394,0))
		rightPl:setVisible(false)
		arrowImg:setVisible(false)
	else
		leftPl:setPosition(cc.p(204,0))
		rightPl:setPosition(cc.p(584,0))
		rightPl:setVisible(true)
		arrowImg:setVisible(true)
	end
end

function SuitUI:updateEquipGodTopPanel()
	local minGodNum = 15
	local maxGodNum = 0
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		if equipObj then
			local godlv = equipObj:getGodLevel()
			minGodNum = (godlv > minGodNum) and minGodNum or godlv
		else
			minGodNum = 0
			break
		end
	end
	if minGodNum >= 15 then
		maxGodNum = 15
	elseif minGodNum == 0 then
		maxGodNum = 1
	else
		maxGodNum = minGodNum + 1
	end
	self:createRts(self.obj:getName()..GlobalApi:getLocalStr('SUIT_DESC_3'),maxGodNum,GlobalApi:getLocalStr('SUIT_DESC_9'))
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		local godId = 0
		local currLv = 1
		local equipImg = self.gemPl:getChildByName('equip_img_'..i)
		equipImg:setTouchEnabled(true)
		local barbg = equipImg:getChildByName('bar_bg')
		local bar = barbg:getChildByName('bar')
		local barTx = bar:getChildByName('bar_tx')
		local starImg = barbg:getChildByName('star_img')
		local awardBgImg = equipImg:getChildByName('award_bg_img')
		if not awardBgImg then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
			awardBgImg = tab.awardBgImg
			awardBgImg:setPosition(cc.p(47,56))
			awardBgImg:setScale(0.8)
			awardBgImg:setTouchEnabled(false)
			equipImg:addChild(awardBgImg)
		end
		local addImg = awardBgImg:getChildByName('add_img')
		local nameTx = awardBgImg:getChildByName('name_tx')
		addImg:loadTexture('uires/ui/common/add_04.png')
		if equipObj then
			ClassItemCell:updateItem(awardBgImg, equipObj, 2)
			local godlv = equipObj:getGodLevel()
			nameTx:setString(equipObj:getName())
			nameTx:setColor(equipObj:getNameColor())
			nameTx:enableOutline(equipObj:getNameOutlineColor(),1)
			addImg:setVisible(false)
			nameTx:setScale(1.25*22/24)
			starImg:loadTexture('uires/ui/common/icon_star3.png')
			starImg:setPosition(cc.p(0,16))
			godId = equipObj:getGodId()
			if godlv > 0 then
				nameTx:setPosition(cc.p(195,69))
				barbg:setVisible(true)
				local num = (godlv > maxGodNum) and maxGodNum or godlv
				barTx:setString(num..'/'..maxGodNum)
				local percent =string.format("%.2f", num/maxGodNum*100)
				bar:setPercent(percent)
				equipImg:addTouchEventListener(function (sender, eventType)
			   		if eventType == ccui.TouchEventType.began then
						AudioMgr.PlayAudio(11)
			        elseif eventType == ccui.TouchEventType.ended then
				        local equipUpgradeStarUI = require("script/app/ui/equip/equipupgradestarui").new(equipObj)
                		equipUpgradeStarUI:showUI()
			        end
			    end)
			else
				nameTx:setPosition(cc.p(195,47))
				barbg:setVisible(false)
				self:changeEquip(equipImg,i)
			end
		else
			local starImg1 = awardBgImg:getChildByName('star_img')
			starImg1:setVisible(false)
			local awardImg = awardBgImg:getChildByName('award_img')
			awardImg:loadTexture(DEFAULTEQUIP[i])
			awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
			barbg:setVisible(false)
			nameTx:setPosition(cc.p(195,47))
			nameTx:setScale(1.25)
			nameTx:setString(GlobalApi:getLocalStr('SUIT_DESC_2'))
			nameTx:setColor(COLOR_TYPE.RED)
			nameTx:enableOutline(COLOROUTLINE_TYPE.RED,1)
			local tab = BagData:getEquipMapByType(i)
			local index = 0
			if tab then
				local level = UserData:getUserObj():getLv()
				for k,v in pairs(tab) do
					if level + 10 >= v:getLevel() then
						index = index + 1
					end
				end
				if index > 0 then
					addImg:setVisible(true)
				else
					addImg:setVisible(false)
				end
			end
			self:changeEquip(equipImg,i)
		end
		ClassItemCell:setGodLight(awardBgImg, godId)
	end
	self:updateEquipGodBottomPanel(minGodNum,maxGodNum)
end

function SuitUI:updateEquipBottomPanel(equipLv,equipNumTab)
	local attributeConf = GameData:getConfData("attribute")
	local conf = GameData:getConfData("equiplvsuit")
	local bottomImg = self.equipPl:getChildByName("bottom_img")
	local infoTx = bottomImg:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('SUIT_DESC_8'))
	local currAttrIndex = 0
	for i=1,4 do
		local effectImg = bottomImg:getChildByName('effect_img_'..i)
		local descTx = effectImg:getChildByName("desc_tx")
		local attrTx1 = effectImg:getChildByName("attr_tx_1")
		local attrTx2 = effectImg:getChildByName("attr_tx_2")
		local attrTxs = {attrTx1,attrTx2}
		for j=currAttrIndex + 1,6 do
			if conf[equipLv]['attribute'..j] then
				currAttrIndex = j
				break
			end
		end
		descTx:setString(currAttrIndex..GlobalApi:getLocalStr('SUIT_DESC_1')..':')
		if equipNumTab[equipLv] and equipNumTab[equipLv] >= currAttrIndex then
			descTx:setColor(COLOR_TYPE.ORANGE)
			descTx:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
		else
			descTx:setColor(COLOR_TYPE.GRAY)
			descTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
		end
		local attributes = conf[equipLv]['attribute'..currAttrIndex]
		for j,v in ipairs(attributes) do
			local tab = string.split(v, ':')
			attrTxs[j]:setString(attributeConf[tonumber(tab[1])].name..'+'..tonumber(tab[2]))
			if equipNumTab[equipLv] and equipNumTab[equipLv] >= currAttrIndex then
				attrTxs[j]:setColor(COLOR_TYPE.GREEN)
				attrTxs[j]:enableOutline(COLOROUTLINE_TYPE.GREEN,1)
			else
				attrTxs[j]:setColor(COLOR_TYPE.GRAY)
				attrTxs[j]:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
			end
		end
	end
	self.nameTx:setString(self.obj:getName()..GlobalApi:getLocalStr('SHIPPER_DE')..conf[equipLv].name)
end

function SuitUI:updateEquipTopPanel()
	local lv = UserData:getUserObj():getLv()
	-- local roleLevel = lv - lv%10 + 10
	-- if roleLevel > 100 then
	-- 	roleLevel = 100
	-- elseif roleLevel < 60 then
	-- 	roleLevel = 1
	-- end
	local conf = GameData:getConfData("equiplvsuit")
	local equipLv = 1
	local equipNumTab= {}
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		local godId = 0
		local currLv = 1
		if equipObj and equipObj:isAncient() then
			ClassItemCell:updateItem(self.equipTab[i], equipObj, 1)
			ShaderMgr:restoreWidgetDefaultShader(self.equipTab[i].awardImg)
			ShaderMgr:restoreWidgetDefaultShader(self.equipTab[i].awardBgImg)
			self.equipTab[i].nameTx:setString(equipObj:getName())
			self.equipTab[i].nameTx:setScale(18/24)
			self.equipTab[i].nameTx:setColor(equipObj:getNameColor())
			self.equipTab[i].nameTx:enableOutline(equipObj:getNameOutlineColor(),1)
			self.equipTab[i].lvTx:setString('Lv.'..equipObj:getLevel())
			self.equipTab[i].lvTx:setVisible(true)
			godId = equipObj:getGodId()
			currLv = equipObj:getLevel()
			equipNumTab[currLv] = (equipNumTab[currLv] or 0) + 1
	    	self.equipTab[i].awardBgImg:addTouchEventListener(function (sender, eventType)
		   		if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	self.currSelectLevel = currLv
			        self:updateEquipTopPanel()
		        end
		    end)
		else
			local id = conf[self.currSelectLevel]['equip'..i]
			local obj = ClassEquipObj.new(tonumber(id))
			ClassItemCell:updateItem(self.equipTab[i], obj, 1)
			ShaderMgr:setGrayForWidget(self.equipTab[i].awardImg)
			ShaderMgr:setGrayForWidget(self.equipTab[i].awardBgImg)
			self.equipTab[i].nameTx:setString(obj:getName())
			self.equipTab[i].nameTx:setScale(18/24)
			self.equipTab[i].nameTx:setColor(COLOR_TYPE.GRAY)
			self.equipTab[i].nameTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
	    	self.equipTab[i].awardBgImg:addTouchEventListener(function (sender, eventType)
		   		if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
			        GetWayMgr:showGetwayUI(obj,true)
		        end
		    end)
		end
		ClassItemCell:setGodLight(self.equipTab[i].awardBgImg,godId)
	end
	self:updateEquipBottomPanel(self.currSelectLevel,equipNumTab)
end

function SuitUI:updatePanel()
	if self.page == 1 then
		if not self.currSelectEquip then
			local currIndex = 1
			local currLevel = 1
			local equipTab = {[1] = {},[60] = {},[70] = {},[80] = {},[90] = {},[100] = {},[105] = {}}
			for i=1,6 do
				local equipObj = self.obj:getEquipByIndex(i)
				if equipObj and equipObj:isAncient() then
					currIndex = i
					currLevel = equipObj:getLevel()
					local level = equipObj:getLevel()
					equipTab[level][#equipTab[level] + 1] = i
				end
			end
			for k,v in pairs(equipTab) do
				if #v >= 2 then
					self.currSelectEquip = v[1]
					self.currSelectLevel = tonumber(k)
					break
				end
			end
			if not self.currSelectEquip then
				self.currSelectEquip = currIndex
				self.currSelectLevel = currLevel
			end
		end
		self.equipPl:setVisible(true)
		self.gemPl:setVisible(false)
		self:updateEquipTopPanel()
	else
		self.equipPl:setVisible(false)
		self.gemPl:setVisible(true)
		if self.page == 2 then
			self:updateEquipGodTopPanel()
		elseif self.page == 3 then
			self:updateEquipGemTopPanel()
		else
			self:updateEquipRifineTopPanel()
		end

	end

	if self.page == 1 then
	    local obj = RoleData:getRoleByPos(self.pos)
	    local suitFlag = obj:getSuitFlag()
	    if suitFlag then
	    	RoleMgr:showEquipRefineLvUp(self.pos,nil,nil,nil,self.page,function()
	    		obj:updateSuitFlag()
	    		RoleMgr:updateRoleMainUI()
	    	end)
	    else
	    	obj:updateSuitFlag()
	    end
	elseif self.page > 1 then
		local _,suit = self.obj:getSuitAttr()
		if self.suitLv[self.page] and self.suitLv[self.page] < suit[self.page - 1][1] then
			RoleMgr:showEquipRefineLvUp(self.pos,nil,self.suitLv[self.page],suit[self.page - 1][1],self.page,self.callback)
		end
		self.suitLv[self.page] = suit[self.page - 1][1]
	end
	self.callback = nil
    for i=1,MAX_PAGE do
    	local infoTx = self.pageBtns[i]:getChildByName('info_tx')
    	if i == self.page then
    		self.pageBtns[i]:loadTexture('uires/ui/common/title_btn_sel_1.png')
    		infoTx:setColor(COLOR_TYPE.PALE)
    		infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
    		infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    	else
    		self.pageBtns[i]:loadTexture('uires/ui/common/title_btn_nor_1.png')
    		infoTx:setColor(COLOR_TYPE.DARK)
    		infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
    		infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
    	end
    end
end

function SuitUI:SendPost(equipObj,isinherit,cost)
    cost = cost or 0
    if UserData:getUserObj():getGold() < cost then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'), COLOR_TYPE.RED)
        return
    end
    local rolePos = self.obj:getPosId()
    local args = {
        eid = equipObj:getSId(),
        pos = rolePos,
        inherit = isinherit
    }
    MessageMgr:sendPost("wear", "hero", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        local code = jsonObj.code
        if code == 0 then
            if tonumber(isinherit) > 0 then
                local roleObj =RoleData:getRoleByPos(rolePos)
                local obj = roleObj:getEquipByIndex(equipObj:getType())
                if obj == nil then
                    return
                end
                equipObj:inheritGod(obj)
                GlobalApi:parseAwardData(jsonObj.data.awards)
                local costs = jsonObj.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
            end
            RoleData:putOnEquip(rolePos, equipObj)
            self.callback = function()
            	RoleMgr:showChildPanelByIdx(ROLEPANELTYPE.UI_EQUIP_INFO, equipObj:getType())
	            RoleMgr:updateRoleList()
	            RoleMgr:updateRoleMainUI()
            end
            self:updatePanel()
        end
    end)
end

function SuitUI:init()
	local bgImg = self.root:getChildByName("suit_bg_img")
	local suitImg = bgImg:getChildByName("suit_img")
    self:adaptUI(bgImg, suitImg)
    local winSize = cc.Director:getInstance():getWinSize()
    suitImg:setPosition(cc.p(winSize.width/2,winSize.height/2-30))

    local closeBtn = suitImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideSuit()
        end
    end)

    self.equipPl = suitImg:getChildByName("equip_pl")
    local topImg = self.equipPl:getChildByName("top_img")
    local bottomImg = self.equipPl:getChildByName("bottom_img")
    local cloudImg = self.equipPl:getChildByName("cloud_img")
    self.nameTx = topImg:getChildByName('info_tx')
    self.gemPl = suitImg:getChildByName("gem_pl")
    self.equipTab = {}

    local diffSize = 36.3
    for i=1,6 do
    	local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    	local size = tab.awardBgImg:getContentSize()
    	tab.awardBgImg:setPosition(cc.p((i - 1)*(size.width + diffSize) + size.width/2 + diffSize,95))
    	tab.awardBgImg:setTouchEnabled(true)
    	topImg:addChild(tab.awardBgImg)
    	tab.addImg:loadTexture('uires/ui/common/add_04.png')
    	tab.addImg:ignoreContentAdaptWithSize(true)
    	self.equipTab[i] = tab
    end
    self.pageBtns = {}
    local opens = {'hero','hero','hero','legionTrial'}
    for i=1,MAX_PAGE do
    	local pageBtn = suitImg:getChildByName('page_'..i..'_btn')
    	local infoTx = pageBtn:getChildByName('info_tx')
    	infoTx:setString(GlobalApi:getLocalStr('SUIT_'..i))
    	pageBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            local isOpen,_,cityId,level = GlobalApi:getOpenInfo(opens[i])
	            if not isOpen then
	                if cityId then
	                    local cityData = MapData.data[cityId]
	                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')..
	                        cityData:getName()..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
	                    return
	                end
	                if level then
	                    promptmgr:showSystenHint(level..GlobalApi:getLocalStr('STR_POSCANTOPEN_1'), COLOR_TYPE.RED)
	                    return
	                end
	            end
	            self.page = i
	            self:updatePanel()
	        end
	    end)
	    self.pageBtns[i] = pageBtn
    end
    local leftBtn = bgImg:getChildByName('left_btn')
    local rightBtn = bgImg:getChildByName('right_btn')
    leftBtn:setPosition(cc.p(0,winSize.height/2))
    rightBtn:setPosition(cc.p(winSize.width,winSize.height/2))
    GlobalApi:arrowBtnMove(leftBtn,rightBtn)
	leftBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local maxNum = RoleData:getRoleNum()
        	while true
        	do
        		self.pos = (self.pos - 2)%maxNum + 1
        		local obj = RoleData:getRoleByPos(self.pos)
        		if obj and obj:getId() > 0 then
        			self.obj = obj
        			RoleMgr:setCurHeroChange(self.pos)
        			break
        		end
        	end
        	self.currSelectEquip = nil
        	self.suitLv = {}
        	self:updatePanel()
        end
    end)
	rightBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local maxNum = RoleData:getRoleNum()
        	while true
        	do
        		self.pos = self.pos%maxNum + 1
        		local obj = RoleData:getRoleByPos(self.pos)
        		if obj and obj:getId() > 0 then
        			self.obj = obj
        			RoleMgr:setCurHeroChange(self.pos)
        			break
        		end
        	end
        	self.currSelectEquip = nil
        	self.suitLv = {}
        	self:updatePanel()
        end
    end)
    self:updatePanel()
end

return SuitUI