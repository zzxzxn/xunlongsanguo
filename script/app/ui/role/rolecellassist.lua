local RoleCellUI = class("RoleCellUI")
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')
local defIcon = 'uires/ui/common/add_01.png'
local defequipIcon = 'uires/ui/common/add_02.png'
local defecanquipIcon = 'uires/ui/common/add_01.png'
local defframeIcon = 'uires/ui/common/frame_default.png'
local lockIcon = 'uires/ui/common/lock_3.png'

function RoleCellUI:ctor(parentUI, index, obj)
	self.parentUI = parentUI
	self.obj = obj
	self.nor_pl = nil     		--右边主panel
	self.openinfotx = nil 		--同norpanel同级的其他提示信息
	--self.openinfoImg = nil 		--同norpanel同级的其他提示信息
	self.equip_pl = nil			--装备panel	
	self.lv = nil				--等级
	self.soldiertypeimg = nil   --兵种类型
	self.name = nil				--武将名称
	self.equipTab = {}
	self.info = nil				--提示
	self.pos = self.obj:getPosId()
	self.index = index
	self.iscanmerge = false
	self:initPanel()
	-- dump(self.obj)
end

function RoleCellUI:initPanel()
	local panel = cc.CSLoader:createNode("csb/rolecellassist.csb")
	local bgimg = panel:getChildByName("bg_img")
	bgimg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(bgimg)
	self.panel:setName("rolecellassist_" .. self.index)
	self.nor_pl = bgimg:getChildByName('nor_pl')
	self.openinfotx = bgimg:getChildByName('openinfo_tx')
	local bgicon = bgimg:getChildByName('icon_img')
	local bgiconSize = bgicon:getContentSize()
	local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.obj, bgicon)
	iconCell.awardBgImg:setPosition(cc.p(bgiconSize.width/2, bgiconSize.height/2))
	iconCell.awardBgImg:setTouchEnabled(false)
	iconCell.awardBgImg:ignoreContentAdaptWithSize(true)
	iconCell.awardImg:ignoreContentAdaptWithSize(true)
	self.iconCell = iconCell
	self.probgimg = self.nor_pl:getChildByName('probg_img')
	
	local namebg = self.nor_pl:getChildByName('namebg_img')
	self.name = namebg:getChildByName('name_tx')
	self.info = self.nor_pl:getChildByName('info_img')
	self.lv = namebg:getChildByName('lv_tx')
	self.soldiertypeimg = namebg:getChildByName('soldiertype_img')
	self.equip_pl = self.nor_pl:getChildByName('equip_pl')
	for i=1,6 do
		local node = self.equip_pl:getChildByName('node_' .. i)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
		tab.awardBgImg:ignoreContentAdaptWithSize(true)
		tab.awardImg:ignoreContentAdaptWithSize(true)
		tab.upImg:setAnchorPoint(cc.p(1,1))
		tab.upImg:setPosition(cc.p(94,94))
		tab.upImg:setScale(1.5)
		tab.awardBgImg:setTouchEnabled(false)
		tab.awardBgImg:setScale(0.5)
		tab.addImg:ignoreContentAdaptWithSize(true)
		node:addChild(tab.awardBgImg)
		self.equipTab[i] = tab
	end
   	bgimg:setTouchEnabled(true)
   	local beginPoint = cc.p(0,0)
    local endPoint = cc.p(0,0)
    bgimg:addClickEventListener(function ()
    	if RoleData:getRoleByPos(self.pos):getId() > 0 then 
			RoleMgr:showRoleMain(self.obj:getPosId())
			RoleMgr:setSelectRolePos(self.obj:getPosId())
		else
			if UserData:getUserObj():getLv() >= GlobalApi:getAssistLvByNum(self.pos) then
				RoleMgr:showRoleSelectListOutSide()
				RoleMgr:setSelectRolePos(self.obj:getPosId())
			else
				local s = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN') , GlobalApi:getAssistLvByNum(self.pos))
				self.openinfotx:setString(s)
			end
		end
    end)
end

function RoleCellUI:getPanel()
	return self.panel
end

function RoleCellUI:setVisible(vis)
	self.panel:setVisible(vis)
end


function RoleCellUI:upDateUI()
	if tonumber(self.obj:getId()) and tonumber(self.obj:getId()) > 0 then
		if  self.obj:getTalent() > 0  then
			self.name:setString(self.obj:getName().. '+' .. self.obj:getTalent())
		else
			self.name:setString(self.obj:getName())
		end
		self.name:setTextColor(self.obj:getNameColor())

		--xyh
		--显示类型图标
		-- self.soldiertypeimg:loadTexture('uires/ui/common/soldier_'..self.obj:getSoldierId()..'.png')
		self.soldiertypeimg:loadTexture(self.obj:getAbilityImg())
		self.soldiertypeimg:ignoreContentAdaptWithSize(true)
		local ishavebetterarr = {}
		--local infoarr = RoleData:getWorstEquipArr()	
		for i=1,6 do
			local ishaveeq,canequip = self.obj:isHavebetterEquip(i)
			local equipObj = self.obj:getEquipByIndex(i)
			if equipObj then	
				ClassItemCell:updateItem(self.equipTab[i], equipObj, 1)
				self.equipTab[i].starImg:setVisible(false)
				self.equipTab[i].addImg:setVisible(false)
				ClassItemCell:setGodLight(self.equipTab[i].awardBgImg, equipObj:getGodId())
				if ishaveeq and canequip then
					self.equipTab[i].upImg:setVisible(true)
					ishavebetterarr[i] = true 
				else
					self.equipTab[i].upImg:setVisible(false)
					ishavebetterarr[i] = false 
				end
			else
				self.equipTab[i].starImg:setVisible(false)
			 	self.equipTab[i].awardBgImg:loadTexture(defframeIcon)
			 	self.equipTab[i].awardImg:loadTexture(DEFAULTEQUIP[i]) 
			 	if ishaveeq then
			 		self.equipTab[i].addImg:setVisible(true)
					self.equipTab[i].upImg:setVisible(false)
					if canequip then
						self.equipTab[i].addImg:loadTexture(defecanquipIcon) 
						ishavebetterarr[i] = true
					else
						self.equipTab[i].addImg:loadTexture(defequipIcon) 
						ishavebetterarr[i] = false
					end
				else
					self.equipTab[i].addImg:setVisible(false)
					self.equipTab[i].upImg:setVisible(false)
					ishavebetterarr[i] = false
				end
			end
		end

		for i=1,6 do
			if ishavebetterarr[i] == true then
				self.info:setVisible(false)
				break
			else
				self.info:setVisible(false)
			end
		end

		if self.obj:isTupo() then
			self.info:setVisible(true)
			return
		elseif self.obj:isSoldierCanLvUp() then
			self.info:setVisible(true)
			return
		elseif self.obj:isSoldierSkillCanLvUp() then
			self.info:setVisible(true)
			return
		elseif self.obj:isCanRiseStar() then
			self.info:setVisible(true)
			return
		elseif self.obj:isCanUpdateLv() then
			self.info:setVisible(true)
			return
		-- 是否能够升品
		elseif self.obj:isCanRiseQuality() then
			self.info:setVisible(true)
			return 
		else
			self.info:setVisible(false)
			return
		end
	end
end

function RoleCellUI:setType(isBeassist )

	if self.obj:getId() ~= 0 then
		self.lv:setString(self.obj:getLevel())
	else
		self.nor_pl:setVisible(false)
		self.lv:setVisible(false)
		if tonumber(UserData:getUserObj():getLv()) >= tonumber(GlobalApi:getAssistLvByNum(self.pos)) then
			local allcards = BagData:getAllCards()
			local cardarr = {}
			for k, v in pairs(allcards) do
			 	if v:getId() < 10000 then
				 	local canassist = true
					for j = 1,MAXROlENUM do
						local hid = RoleData:getRoleByPos(j):getId()
						if hid == v:getId() then
							canassist = false
						end
					end
					if canassist then
			        	table.insert(cardarr, v)
					end
			    end
		    end
		    local num = #cardarr
		    if num > 0 then
				self.openinfotx:setVisible(true)
				self.openinfotx:setString(GlobalApi:getLocalStr('STR_POSCANTOPEN2'))
				self.openinfotx:setTextColor(COLOR_TYPE.GREEN)
				self.iconCell.awardImg:loadTexture(defIcon)
			else
				self.openinfotx:setVisible(true)
				self.openinfotx:setString(GlobalApi:getLocalStr('STR_POSCANTOPEN3'))
				self.openinfotx:setTextColor(COLOR_TYPE.YELLOW)
				self.iconCell.awardImg:loadTexture(defequipIcon)
			end
		else
			self.openinfotx:setVisible(true)
			local s = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN') , GlobalApi:getAssistLvByNum(self.pos))
			self.openinfotx:setString(s)
			self.openinfotx:setTextColor(COLOR_TYPE.RED)
			self.iconCell.awardImg:loadTexture(lockIcon)
		end
	end

	self:upDateUI()
end

return RoleCellUI