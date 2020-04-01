local GemFillUI = class("GemFillUI", BaseUI)
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemUpgradeUI = require("script/app/ui/gem/gemupgradenewui")
local ClassItemCell = require('script/app/global/itemcell')

function GemFillUI:ctor(pos)
	self.uiIndex = GAME_UI.UI_GEM_FILL
	self.pos = pos
	self.obj = RoleData:getRoleByPos(pos)
end

function GemFillUI:onShow()
	self:updatePanel()
end

function GemFillUI:updateGem(i,equipObj)
	local gemTabs = {}
    local pl = self.gemPl:getChildByName('pl_'..i)
    local nameTx = pl:getChildByName('name_tx')
	if not equipObj then
		for i=1,4 do
			local gemBgImg = pl:getChildByName('gem_bg_'..i..'_img')
			if gemBgImg then
				gemBgImg:setVisible(false)
			end
			nameTx:setVisible(false)
		end
		return
	end
	local maxNum = equipObj:getMaxGemNum()
	nameTx:setString('Lv.'..equipObj:getLevel()..' '..equipObj:getName())
	nameTx:setColor(equipObj:getNameColor())
	nameTx:enableOutline(equipObj:getNameOutlineColor(),1)
	nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	local isCanEquipGem = equipObj:getEmptyGemNum()
	local isGemOpen,_,cityId,level = GlobalApi:getOpenInfo('gem')
	for i=1,4 do
		local gemBgImg = pl:getChildByName('gem_bg_'..i..'_img')
		if maxNum >= i then
			if not gemBgImg then
				local gemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
				gemCell.awardImg:ignoreContentAdaptWithSize(true)
				gemCell.awardBgImg:setName('gem_bg_'..i..'_img')
				gemCell.awardBgImg:ignoreContentAdaptWithSize(true)
				gemCell.awardBgImg:setPosition(cc.p(55 + 96*(i-1), 52))
				pl:addChild(gemCell.awardBgImg)
				gemBgImg = gemCell.awardBgImg
			end
			local gems = equipObj:getGems()
			gemBgImg:setVisible(true)
			local gemImg = gemBgImg:getChildByName('award_img')
			local addImg = gemBgImg:getChildByName('add_img')
			local lvTx = gemBgImg:getChildByName('lv_tx')
			local upImg = gemBgImg:getChildByName('up_img')
			if gems and gems[i] then
				lvTx:setVisible(true)
				gemImg:setVisible(true)
				gemImg:loadTexture(gems[i]:getIcon())
				lvTx:setString('Lv'..gems[i]:getLevel())
				gemBgImg:loadTexture(gems[i]:getBgImg())
				addImg:setVisible(false)
				upImg:setVisible(gems[i]:getScalable())
				gems[i]:setLightEffect(gemBgImg)
			else
				gemImg:setVisible(false)
				addImg:setVisible(isCanEquipGem == true and isGemOpen)
				if isCanEquipGem == true and isGemOpen then
                    gemBgImg:loadTexture('uires/ui/common/frame_default2.png')
                else
                    gemBgImg:loadTexture('uires/ui/common/frame_bg_gem.png')
                end
				lvTx:setVisible(false)
				upImg:setVisible(false)
				GlobalApi:setLightEffect(gemBgImg,0)
			end
	        gemBgImg:addTouchEventListener(function (sender, eventType)
	    		if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				end
	            if eventType == ccui.TouchEventType.ended then
	            	if not isGemOpen then
				        if cityId then -- 没开
			                local tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
			                local tx2 = GlobalApi:getLocalStr('FUNCTION_DESC_2')
			                promptmgr:showSystenHint(tx1 .. cityId .. tx2, COLOR_TYPE.RED)
			            else
			                local tx1 = GlobalApi:getLocalStr('STR_POSCANTOPEN_1')
			                promptmgr:showSystenHint(level .. tx1, COLOR_TYPE.RED)
				        end
	            		return
	            	end
                    if not gems[i] and isCanEquipGem == true then -- 已经有宝石了
		          	    local gemSelectUI = ClassGemSelectUI.new(i, equipObj, function ()
                            self.obj:setFightForceDirty(true)
                            RoleMgr:updateRoleMainUIForce()
                            RoleMgr:updateRoleList()
                        end)
                        gemSelectUI:showUI()
                    elseif not gems[i] then
                    	promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_HAD_NO_EQUIPED_GEM'), COLOR_TYPE.RED)
                    else
			        	local gemUpgradeUI = ClassGemUpgradeUI.new(gems[i]:getId(),i, equipObj, function ()
		                   	self.obj:setFightForceDirty(true)
                            RoleMgr:updateRoleMainUIForce()
                            RoleMgr:updateRoleList()
                            self:updatePanel()
		                end)
			            local desc,isOpen = GlobalApi:getGotoByModule('gem_merge',true)
			            if desc then
			            	promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')
			            		..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
			                return
			            end
		                gemUpgradeUI:showUI()
                    end
	            end
	        end)
		else
			if gemBgImg then
				gemBgImg:setVisible(false)
			end
		end
	end
end

function GemFillUI:updatePanel()
	local nameTx = self.gemPl:getChildByName('name_tx')
	nameTx:setString(self.obj:getName()..GlobalApi:getLocalStr('WHOS_EQUIP'))
	nameTx:setColor(self.obj:getNameColor())
	nameTx:enableOutline(self.obj:getNameOutlineColor(),1)
	local equips = {}
	for i=1,6 do
		local equipObj = self.obj:getEquipByIndex(i)
		if equipObj then
			equips[#equips + 1] = equipObj
		end
	end
	for i=1,6 do
		self:updateGem(i,equips[i])
	end
end

function GemFillUI:init()
	local bgImg = self.root:getChildByName("suit_bg_img")
	local suitImg = bgImg:getChildByName("suit_img")
    self:adaptUI(bgImg, suitImg)
    local winSize = cc.Director:getInstance():getWinSize()
    suitImg:setPosition(cc.p(winSize.width/2,winSize.height/2-30))
    self.gemPl = suitImg:getChildByName('gem_fill_pl')
    local titleImg = suitImg:getChildByName('tile_img')
    local infoTx = titleImg:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('TITLE_BSXQ'))

    local closeBtn = suitImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideGemFill()
        end
    end)
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
        	self:updatePanel()
        end
    end)
    self:updatePanel()
end

return GemFillUI