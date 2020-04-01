local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassGemSelectUI = require("script/app/ui/gem/gemselectui")
local ClassGemUpgradeUI = require("script/app/ui/gem/gemupgradenewui")
local RoleGemUI = class("RoleGemUI", ClassRoleBaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleGemUI:initPanel()
	self.panel = cc.CSLoader:createNode("csb/rolegempanel.csb")
	local bgimg = self.panel:getChildByName('bg_img')
	local bgimg1 = bgimg:getChildByName('bg_img1')
	local autobtn = bgimg:getChildByName('auto_btn')
	autobtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
        	local equipObj = self.roleObj:getEquipByIndex(self.equipPos)
			if equipObj then
                local gems = equipObj:getGems()
                local havegem = false
                for i=1,4 do
                	if gems[i] ~= nil then
                		havegem = true
                	end
                end
                if havegem then -- 已经有宝石了 
		           	local args = {
		    			eid = equipObj:getSId()
		    		}
					MessageMgr:sendPost("take_off_all_gems", "equip", json.encode(args), function (jsonObj)
						print(json.encode(jsonObj))
						local code = jsonObj.code
						if code == 0 then
							local awards = jsonObj.data.awards
							GlobalApi:parseAwardData(awards)
							local costs = jsonObj.data.costs
	                        if costs then
	                            GlobalApi:parseAwardData(costs)
	                        end
							self.equipObj:removeAllGem()
							self.roleObj:setFightForceDirty(true)
							RoleMgr:updateRoleMainUI()
							RoleMgr:updateRoleList()
							RoleMgr:setDirty("RoleMainUI",false)
						end
					end)
                end
            end
        end
    end)
	local autobtntx = autobtn:getChildByName('func_tx')
	autobtntx:setString(GlobalApi:getLocalStr('AUTOUNDRESS'))
	local gemalphabg = bgimg1:getChildByName('bg_alpha')
	self.gemarr = {}
	for i=1,4 do
		local arr = {}
		local gembg = gemalphabg:getChildByName('gem_'..i..'_bg')
		gembg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
        	if eventType == ccui.TouchEventType.ended then
	            for j=1,4 do
            		self.gemarr[j].selimg:setVisible(false)
            	end
        		local equipObj = self.roleObj:getEquipByIndex(self.equipPos)
        		local isCanEquipGem = equipObj:getEmptyGemNum()
				if equipObj then
                    local gems = equipObj:getGems()
                    if gems[i] then -- 已经有宝石了
                        self.gemarr[i].selimg:setVisible(true)
                    elseif isCanEquipGem == true then
                        local gemSelectUI = ClassGemSelectUI.new(i, equipObj, function ()
					 	    self.roleObj:setFightForceDirty(true)
						    RoleMgr:updateRoleMainUI()
						    RoleMgr:updateRoleList()
                        end)
                        local desc,isOpen = GlobalApi:getGotoByModule('gem_fill',true)
                        if desc then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')
                                ..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
                            return
                        end
                        gemSelectUI:showUI()
                    else
                    	promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_HAD_NO_EQUIPED_GEM'), COLOR_TYPE.RED)
                    end
				end
	        end
	    end)
		arr.selimg = gembg:getChildByName('sel_img')
		arr.undressbtn = arr.selimg:getChildByName('discharge_btn')
		local undressbtntx = arr.undressbtn:getChildByName('func_tx')
		undressbtntx:setString(GlobalApi:getLocalStr('DISCHRGE'))
		arr.undressbtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
	        if eventType == ccui.TouchEventType.ended then
	           local equipObj = self.roleObj:getEquipByIndex(self.equipPos)
				if equipObj then
	                local gems = equipObj:getGems()
	                if gems[i]  then -- 已经有宝石了
			           	local args = {
			    			eid = equipObj:getSId(),
			    			slot = i
			    		}
						MessageMgr:sendPost("take_off_gem", "equip", json.encode(args), function (jsonObj)
							print(json.encode(jsonObj))
							local code = jsonObj.code
							if code == 0 then
								local awards = jsonObj.data.awards
			                    if awards then
			                        GlobalApi:parseAwardData(awards)
			                    end
			                    local costs = jsonObj.data.costs
			                    if costs then
			                        GlobalApi:parseAwardData(costs)
			                    end
								self.equipObj:removeGem(i)
								self.roleObj:setFightForceDirty(true)
								RoleMgr:updateRoleMainUI()
								RoleMgr:updateRoleList()
							end
						end)
	                end
	            end

	        end
	    end)
		arr.upgradebtn = arr.selimg:getChildByName('upgrade_btn')
		local upgradebtntx = arr.upgradebtn:getChildByName('func_tx')
		upgradebtntx:setString(GlobalApi:getLocalStr('UPGRADE'))
		arr.upgradebtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
			end
	        if eventType == ccui.TouchEventType.ended then
	        	local gems = self.equipObj:getGems()
	           	local gemUpgradeUI = ClassGemUpgradeUI.new(gems[i]:getId(),i, self.equipObj, function ()
                   	self.roleObj:setFightForceDirty(true)
                    RoleMgr:updateRoleMainUI()
                    RoleMgr:updateRoleList()
                end)
	            local desc,isOpen = GlobalApi:getGotoByModule('gem_merge',true)
	            if desc then
	            	promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_DESC_1')
	            		..desc..GlobalApi:getLocalStr('FUNCTION_DESC_2'), COLOR_TYPE.RED)
	                return
	            end
                gemUpgradeUI:showUI()
	        end
	    end)
	    arr.gembg = gembg
	    local alphaBg = gembg:getChildByName('alpha_bg')
	    local alphaBgSize = alphaBg:getContentSize()
	    local gemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	    gemCell.awardBgImg:setTouchEnabled(false)
	    gemCell.awardBgImg:ignoreContentAdaptWithSize(true)
	    gemCell.awardImg:ignoreContentAdaptWithSize(true)
	    gemCell.awardBgImg:setPosition(cc.p(alphaBgSize.width/2, alphaBgSize.height/2))
		alphaBg:addChild(gemCell.awardBgImg)
		arr.gemCell = gemCell
		arr.gemname = gembg:getChildByName('name_tx')
		arr.gemnum = gembg:getChildByName('num_tx')
		arr.infotx = gembg:getChildByName('info_tx')
		arr.infotx:setString(GlobalApi:getLocalStr('GEMEQUIPINFO'))
		self.gemarr[i] = arr
	end

	local equipIconNode = bgimg1:getChildByName('equip_icon_node')
	local equipCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
	equipIconNode:addChild(equipCell.awardBgImg)
	self.equipCell = equipCell
	
	self.equipName = bgimg1:getChildByName('name_tx')
	self.equipFightforce = bgimg1:getChildByName('fightforce_tx')
	self.equipAtt = bgimg1:getChildByName('att_tx')
end

function RoleGemUI:update(obj,equipPos)
	self.roleObj = obj
	self.equipPos = equipPos
	local equipObj = self.roleObj:getEquipByIndex(equipPos)
	if equipObj == nil then
		return
	end
    self.equipObj = equipObj
	self:updateUI()
end

function RoleGemUI:updateUI()
    local equipObj = self.equipObj
    local quality = equipObj:getQuality()

    ClassItemCell:updateItem(self.equipCell, equipObj, 1)
	self.equipName:setString("Lv." .. equipObj:getLevel() ..' ' .. equipObj:getName())
    self.equipName:setTextColor(equipObj:getNameColor())
    self.equipName:enableOutline(equipObj:getNameOutlineColor(),1)
    self.equipName:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	local fightforceStr = GlobalApi:getLocalStr("STR_TOTAL_FIGHTFORCE") .. ": " .. equipObj:getFightForce()
	self.equipFightforce:setString(fightforceStr)
	self.equipFightforce:setTextColor(COLOR_TYPE.BLUE)
    self.equipFightforce:enableOutline(COLOROUTLINE_TYPE.BLUE,1)
    self.equipFightforce:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	local mainAttribute = equipObj:getMainAttribute()
	local mainAttributeStr = mainAttribute.name .. " +" .. mainAttribute.value
	self.equipAtt:setString(mainAttributeStr)

	 local gemNum = equipObj:getMaxGemNum()
	 local gems = equipObj:getGems()
	 local isCanEquipGem = equipObj:getEmptyGemNum()
	 for i=1,4 do
	 	self.gemarr[i].selimg:setVisible(false)
	 	local gem = gems[i]
	 	self.gemarr[i].gembg:setVisible(gemNum >= i)
 		if gem then
 			ClassItemCell:updateItem(self.gemarr[i].gemCell, gem, 1)
 			self.gemarr[i].gemCell.awardImg:setVisible(true)
            self.gemarr[i].gemname:setTextColor(gem:getNameColor())
           	self.gemarr[i].gemname:setString( gem:getName())
            self.gemarr[i].gemnum:setTextColor(COLOR_TYPE.WHITE)
           	self.gemarr[i].gemnum:setString(gem:getAttrName() .. "+" .. gem:getValue())
           	self.gemarr[i].infotx:setVisible(false)
           	self.gemarr[i].gemCell.upImg:setVisible(equipObj:getGemUp(i))
           	gem:setLightEffect(self.gemarr[i].gemCell.awardBgImg)
		else
			self.gemarr[i].gemCell.awardImg:setVisible(isCanEquipGem == true)
			self.gemarr[i].gemCell.awardImg:loadTexture("uires/ui/common/add_01.png")
			self.gemarr[i].gemCell.upImg:setVisible(false)
			self.gemarr[i].gemname:setString('')
			self.gemarr[i].gemnum:setString('')
			self.gemarr[i].infotx:setVisible(true)
			if isCanEquipGem == true then
				self.gemarr[i].gemCell.awardBgImg:loadTexture('uires/ui/common/frame_default2.png')
			else
				self.gemarr[i].gemCell.awardBgImg:loadTexture('uires/ui/common/frame_bg_gem.png')
			end
			GlobalApi:setLightEffect(self.gemarr[i].gemCell.awardBgImg,0)
		end
		self.gemarr[i].gemCell.lvTx:setVisible(false)
	 end
end

return RoleGemUI