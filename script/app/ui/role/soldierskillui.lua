local SoldierSkillUI = class("SoldierSkillUI", BaseUI)


function SoldierSkillUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_SOLDOER_SKILL
	self.dirty = false
	self.obj = obj
    self.cells = {}
end

function SoldierSkillUI:setDirty(onlychild)
	self.dirty = true
end
function SoldierSkillUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	bgimg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideSoldierSkill()
        end
    end)
    local bgalpha = bgimg:getChildByName('bg_alpha')
	local bgimg1 =bgalpha:getChildByName('bg_img1')

	local goldBgImg =bgimg1:getChildByName('gold_bg_img')
	local infoTx =goldBgImg:getChildByName('info_tx')
	infoTx:setString(GlobalApi:getLocalStr('HAD_GOLD'))
	self.numTx =goldBgImg:getChildByName('num_tx')
	self:adaptUI(bgimg, bgalpha)
	local titlebg  = bgimg1:getChildByName('title_bg')
	local titletx = titlebg:getChildByName('title_tx')
	titletx:setString(GlobalApi:getLocalStr('SOLDIERSKILL'))
	self.sv = bgimg1:getChildByName('info_sv')
	self.sv:setInertiaScrollEnabled(true)
	self.sv:setBounceEnabled(false)
	self.sv:setScrollBarEnabled(false)
	self.sv:setInnerContainerSize(self.sv:getContentSize())
	self.rolecards = {}
	self.cardsNum = 0
	self.roleCellNum = 0
	self.cellTotalHeight = 10
	self.canlvup = {}
	self.contentWidget = ccui.Widget:create()
	self.sv:addChild(self.contentWidget)
	local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            self:addCells()
        end
    end

    local closebtn = bgimg1:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideSoldierSkill()
        end
    end)

    self.sv:addEventListener(scrollViewEvent)
    self:update()
end

function SoldierSkillUI:update()
	self.canlvup = {}
	self.cardsNum = 4
    self.cells = {}
	self.contentWidget:removeAllChildren()
	self.cellTotalHeight = 10
	self.roleCellNum = 0
	if self.cardsNum > 0 then
		self.sv:setContentSize(self.sv:getContentSize())
		self:addCells()
	end
	--self.sv:scrollToTop(0.01, false)
	-- self.numTx:setString(GlobalApi:toWordsNumber(UserData:getUserObj():getGold()))
	local gold = UserData:getUserObj():getGold()
    GlobalApi:runNum(self.numTx,'Text','soldierskillui',self.oldNum,gold)
    self.oldNum = gold
end

function SoldierSkillUI:addCells()
   	if self.roleCellNum < self.cardsNum then -- 每次创建7个
		local currNum = self.roleCellNum
		self.roleCellNum = self.roleCellNum + 7
		self.roleCellNum = self.roleCellNum > self.cardsNum and self.cardsNum or self.roleCellNum
		local lvconf  = GameData:getConfData('level')

		for i = currNum+1, self.roleCellNum do
			self.canlvup[i] = 0
			local costvalue = 0
			if lvconf[self.obj:getSoldier().skills[tostring(i)]] and self.obj:getSoldier().skills[tostring(i)] < #lvconf then
                --print('rrrrrrr' .. self.obj:getSoldier().skills[tostring(i)])
				costvalue = lvconf[self.obj:getSoldier().skills[tostring(i)]]['soldierskilllevelupcost']

			end
			local cellNode = cc.CSLoader:createNode("csb/soldierskillcell.csb")
			local bgimg = cellNode:getChildByName("bg_img")
			bgimg:removeFromParent(false)
			local cell = ccui.Widget:create()
			cell:addChild(bgimg)
			local funcbtn = bgimg:getChildByName('func_btn')
			funcbtn:setPropagateTouchEvents(false)

            self.cells[#self.cells + 1] = funcbtn
            
			funcbtn:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
					AudioMgr.PlayAudio(11)
				end
		        if eventType == ccui.TouchEventType.ended then
		        	if self.obj:getLevel() <= self.obj:getSoldier().skills[tostring(i)] then
		        		promptmgr:showSystenHint(GlobalApi:getLocalStr('SOIDIER_SKILLCANNT_LVUP'),COLOR_TYPE.RED)
		        	elseif self.obj:getLevel() > self.obj:getSoldier().skills[tostring(i)] and UserData:getUserObj():getGold() < tonumber(costvalue) then
		        		promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
		        	elseif self.canlvup[i]  == 1 and self.obj:getLevel() >= self.obj:getSoldier().skills[tostring(i)] then
                        for k = 1,#self.cells do
                            if self.cells[i] then
                                self.cells[i]:setTouchEnabled(false)
                            end
                        end
			           	local args = {
			    			pos = self.obj:getPosId(),
			    			skill = i
			    		}
						MessageMgr:sendPost("upgrade_soldier_skill", "hero", json.encode(args), function (jsonObj)
							print(json.encode(jsonObj))
							local code = jsonObj.code
							if code == 0 then
								local awards = jsonObj.data.awards
								GlobalApi:parseAwardData(awards)
								local costs = jsonObj.data.costs
		                        if costs then
		                            GlobalApi:parseAwardData(costs)
		                        end
								self.obj:setSoldierSkillLv(i)
								self.obj:setFightForceDirty(true)
                                RoleMgr:updateRoleList()
                                RoleData:getPosFightForceByPos(self.obj)
								RoleMgr:popupTips(self.obj)
								self:updateCell(bgimg,i)
								local gold = UserData:getUserObj():getGold()
							    GlobalApi:runNum(self.numTx,'Text','soldierskillui',self.oldNum,gold)
							    self.oldNum = gold

                                for k = 1,#self.cells do
                                    if self.cells[i] then
                                        self.cells[i]:setTouchEnabled(true)
                                    end
                                end

							end
						end)
					else
						print('d')
					end
		        end
		    end)
			local contentsize = bgimg:getContentSize()
			self.cellTotalHeight = self.cellTotalHeight + contentsize.height+ 2
			cell:setPosition(cc.p(0, contentsize.height*0.5 - self.cellTotalHeight+10))
			self:updateCell(bgimg,i)
			self.contentWidget:addChild(cell)

            -- 最大
            local funcbtnMax = bgimg:getChildByName('func_btn_max')
			funcbtnMax:setPropagateTouchEvents(false)

		    funcbtnMax:addTouchEventListener(function (sender, eventType)
				    if eventType == ccui.TouchEventType.began then
					    AudioMgr.PlayAudio(11)
				    end
		            if eventType == ccui.TouchEventType.ended then
                        if self.obj:getLevel() <= self.obj:getSoldier().skills[tostring(i)] then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('SOIDIER_SKILLCANNT_LVUP'),COLOR_TYPE.RED)
                            return
                        end

                        local costMaxValue = 0
                        local oldLv = 0
                        local newLv = 0
			            if lvconf[self.obj:getSoldier().skills[tostring(i)]] and self.obj:getSoldier().skills[tostring(i)] < #lvconf then
                            oldLv = self.obj:getSoldier().skills[tostring(i)]
                            newLv = oldLv

                            local userGold = UserData:getUserObj():getGold()
                            local canUpgradeMaxLv = self.obj:getLevel() - 1
                            for p = oldLv,canUpgradeMaxLv do
                                local cost = lvconf[p]['soldierskilllevelupcost']
                                if userGold >= cost then
                                    newLv = newLv + 1
                                    userGold = userGold - cost
                                    costMaxValue = costMaxValue + cost
                                else
                                    break
                                end
                            end

			            end
                        print('costMaxValue=============' .. costMaxValue .. '====oldlv====' .. oldLv .. '=====newLv======' .. newLv)

                        -- 这里至少要升一级才行
                        if newLv <= oldLv then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
                            return
                        end

                        local args = {
			    			pos = self.obj:getPosId(),
			    			skill = i
			    		}
						MessageMgr:sendPost("upgrade_soldier_skill_max", "hero", json.encode(args), function (jsonObj)
							print(json.encode(jsonObj))
							local code = jsonObj.code
							if code == 0 then
								local awards = jsonObj.data.awards
								GlobalApi:parseAwardData(awards)
								local costs = jsonObj.data.costs
		                        if costs then
		                            GlobalApi:parseAwardData(costs)
		                        end
								self.obj:setSoldierSkillLvByLv(i,newLv)
								self.obj:setFightForceDirty(true)
                                RoleMgr:updateRoleList()
                                RoleData:getPosFightForceByPos(self.obj)
								RoleMgr:popupTips(self.obj)
								self:updateCell(bgimg,i)
								local gold = UserData:getUserObj():getGold()
							    GlobalApi:runNum(self.numTx,'Text','soldierskillui',self.oldNum,gold)
							    self.oldNum = gold

							end
						end)


		            end
		        end)


		end
		local posY = self.sv:getContentSize().height
		if self.cellTotalHeight > posY then
			posY = self.cellTotalHeight
		end
		self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width, posY))
		self.contentWidget:setPosition(cc.p(self.sv:getContentSize().width*0.5, posY))
	end
end

function SoldierSkillUI:updateCell(bgimg,index)
	local funcbtn = bgimg:getChildByName('func_btn')
    funcbtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('UPGRADE1'))

    local funcbtnTx = funcbtn:getChildByName('btn_tx')

    local funcbtnMax = bgimg:getChildByName('func_btn_max')
    funcbtnMax:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('SOLDIERINFO_DESC4'))

    local funcbtnMaxTx = funcbtnMax:getChildByName('btn_tx')

	local skillarr = self.obj:getSoldierSkillArr()
	local lvlimit = skillarr[index][1]
	local lv = self.obj:getSoldier().skills[tostring(index)] 
	if lv < 1 then
		lv = 1
	end
	local soldierSkillConf = GameData:getConfData('soldierskill')
	local img = 'uires/icon/skill/' .. soldierSkillConf[skillarr[index][2]]['icon']
	local skillbg = bgimg:getChildByName('skilla_1_img')
	local skillimg = skillbg:getChildByName('skill_img')
	skillimg:ignoreContentAdaptWithSize(true)
	skillimg:loadTexture(img)
	local goldbg = bgimg:getChildByName('gold_bg_img')
	local goldtx = goldbg:getChildByName('gold_tx')
	local lvtx = bgimg:getChildByName('lv_tx')
	local desctx = bgimg:getChildByName('desc_tx')
	local desctx1 = bgimg:getChildByName('desc_tx_1')
	local nametx = bgimg:getChildByName('name_tx')
	local lvconf = GameData:getConfData('level')
	local costvalue = lvconf[lv]['soldierskilllevelupcost']
	if self.obj:getSoldier().level >= lvlimit then
		lvtx:setString('Lv.' .. lv)
		goldbg:setVisible(true)
		local cost = soldierSkillConf[skillarr[index][2]].cost
		funcbtn:setEnabled(true)
		goldtx:setString(tostring(costvalue))

        funcbtnTx:setTextColor(COLOR_TYPE.WHITE)
        funcbtnTx:enableShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        funcbtnTx:enableOutline(cc.c4b(165,70,6,255), 1)

		if  UserData:getUserObj():getGold() >= tonumber(costvalue) and (lv+1) <= self.obj:getLevel()  then
			goldtx:setTextColor(COLOR_TYPE.WHITE)
			funcbtn:setEnabled(true)
			funcbtn:setBright(true)
			self.canlvup[index] = 1

		elseif  UserData:getUserObj():getGold() < tonumber(costvalue) then
			goldtx:setTextColor(COLOR_TYPE.RED)
			funcbtn:setBright(false)
            funcbtnTx:setTextColor(COLOR_TYPE.GRAY)
            funcbtnTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
			funcbtnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.GRAY))
		elseif lv >= self.obj:getLevel() then
			goldtx:setTextColor(COLOR_TYPE.WHITE)
			funcbtn:setBright(false)
            funcbtnTx:setTextColor(COLOR_TYPE.GRAY)
            funcbtnTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
			funcbtnTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.GRAY))
		end

		lvtx:setTextColor(COLOR_TYPE.WHITE)
		--lvtx:enableOutline(cc.c4b(80,68,52,255),2)
		--bgimg:loadTexture('uires/ui/common/common_small_bg_19.png')
		lvtx:setVisible(true)
		desctx:setVisible(true)
		desctx1:setVisible(false)
		funcbtn:setVisible(true)
        funcbtnMax:setVisible(true)



        funcbtnMax:setBright(true)
        funcbtnMaxTx:setTextColor(COLOR_TYPE.WHITE)
        funcbtnMaxTx:enableShadow(cc.c4b(25,25,25,255), cc.size(0, -1))
        funcbtnMaxTx:enableOutline(cc.c4b(25,25,25,255), 1)

        if lv >= self.obj:getLevel() then
            funcbtnMax:setBright(false)
            funcbtnMaxTx:setTextColor(COLOR_TYPE.GRAY)
            funcbtnMaxTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
			funcbtnMaxTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.GRAY))
        else
            local costMaxValue = 0
            local oldLv = 0
            local newLv = 0
		    if lvconf[self.obj:getSoldier().skills[tostring(index)]] and self.obj:getSoldier().skills[tostring(index)] < #lvconf then
                oldLv = self.obj:getSoldier().skills[tostring(index)]
                newLv = oldLv

                local userGold = UserData:getUserObj():getGold()
                local canUpgradeMaxLv = self.obj:getLevel() - 1
                for p = oldLv,canUpgradeMaxLv do
                    local cost = lvconf[p]['soldierskilllevelupcost']
                    if userGold >= cost then
                        newLv = newLv + 1
                        userGold = userGold - cost
                        costMaxValue = costMaxValue + cost
                    else
                        break
                    end
                end

		    end
            --print('costMaxValue=============' .. costMaxValue .. '====oldlv====' .. oldLv .. '=====newLv======' .. newLv)

            -- 这里至少要升一级才行
            if newLv <= oldLv then
                funcbtnMax:setBright(false)
                funcbtnMaxTx:setTextColor(COLOR_TYPE.GRAY)
                funcbtnMaxTx:enableOutline(COLOROUTLINE_TYPE.GRAY,1)
			    funcbtnMaxTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.GRAY))
            end

        end


	else
		lvtx:setVisible(false)
		--bgimg:loadTexture('uires/ui/common/common_small_bg_18.png')
		goldbg:setVisible(false)
		funcbtn:setVisible(false)
        funcbtnMax:setVisible(false)
		desctx1:setVisible(true)
		desctx1:setString(string.format(GlobalApi:getLocalStr('SOLDIERSKILLLIMIT'),lvlimit))
	end
	
	if lv >= #lvconf then
		lvtx:setVisible(false)
		--bgimg:loadTexture('uires/ui/common/common_small_bg_18.png')
		goldbg:setVisible(false)
		funcbtn:setVisible(false)
        funcbtnMax:setVisible(false)
		desctx1:setVisible(true)
		desctx1:setString(GlobalApi:getLocalStr('MAX_LV'))	
	end
	nametx:setString(soldierSkillConf[skillarr[index][2]]['name'])
	desctx:ignoreContentAdaptWithSize(false)
	desctx:setTextAreaSize(cc.size(200,76))

	local skillarr = self.obj:getSoldierSkillArr()
	local att = 0
	local attid = 0
	local isdef = false
	local skillconf = GameData:getConfData('soldierskill')[skillarr[index][2]]
	
	attid = tonumber(skillconf['att'][1])
	local skillvalue = skillconf['value']
	local attBase1 = skillconf['attBase1']
    local attBase2 = skillconf['attBase2']
    local attBase3 = skillconf['attBase3']
	if skillconf['att'][2] then
		isdef = true
	end
    for i = 1,lv do
        att = att + skillvalue + i*i*attBase1 + i*attBase2 + attBase3
    end

	local attconf = GameData:getConfData('attribute')[attid]
	local soldierid = self.obj:getSoldierId()
	local soldlevelconf = GameData:getConfData('soldierlevel')[soldierid][self.obj:getSoldier().level]
	local soldconf = GameData:getConfData('soldier')[soldlevelconf['soldierId']]
	local curattarr = 0
	-- if attid > 4 then
	-- 	curattarr = math.floor(att)
	-- 	local str1 = self.obj:getName() ..attconf.name .. GlobalApi:getLocalStr('STR_ADD') ..math.floor(att)
	-- 	desctx:setString(str1)
	-- 	return
	-- end

	if attid == 1 then
		curattarr = math.floor(att*soldconf['attPowPercent']/100)
	elseif attid == 4 then
		curattarr = math.floor(att*soldconf['heaPowPercent']/100)
	elseif attid == 2 then
		curattarr = math.floor(att*soldconf['phyArmPowPercent']/100) 
	elseif attid == 3 then
		curattarr = math.floor(att*soldconf['magArmPowPercent']/100) 
	else
		--小兵假属性
		curattarr = math.floor(att*soldconf['magArmPowPercent']/100) 
	end
	
	if isdef then
		curattarr = math.floor(att*soldconf['phyArmPowPercent']/100) 
		local str1 = self.obj:getName() .. GlobalApi:getLocalStr('PROFESSION_NAME3') .. GlobalApi:getLocalStr('STR_ADD')
		local str2 = math.floor(att) .. GlobalApi:getLocalStr('STR_SOLDIER_SKILL_DESC') .. GlobalApi:getLocalStr('PROFESSION_NAME3').. curattarr
		desctx:setString(str1 ..str2)		
	else
		local str1 = self.obj:getName() ..attconf.name .. GlobalApi:getLocalStr('STR_ADD') ..math.floor(att)
		local str2 =  GlobalApi:getLocalStr('STR_SOLDIER_SKILL_DESC') .. attconf.name .. curattarr
		desctx:setString(str1 ..str2)
	end		

end
return SoldierSkillUI