local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")

local RoleLvUpUI = class("RoleLvUpUI", ClassRoleBaseUI)
local MAXDELTA = 0.2 -- 10s缩小一倍，最低0.05s
local FIRSTDELT = 1.0
local INTERVEAL = 10.0

local FRAME_COLOR = {
	[1] = 'GRAY',
	[2] = 'GREEN',
	[3] = 'BLUE',
	[4] = 'PURPLE',
	[5] = 'ORANGE',
}

function  RoleLvUpUI:sortByQuality(arr)
	table.sort(arr, function (a, b)
			local q1 = a.quality
			local q2 = b.quality
			if q1 == q2 then
				local f1 = a.id
				local f2 = b.id
				return f1 < f2
			else
				return q1 < q2
			end
	end)
end

function RoleLvUpUI:onMoveOut()
end

function RoleLvUpUI:initPanel()
    self.firstState = true
    self.isLvPostState = false
	self.panel = cc.CSLoader:createNode("csb/rolelvuppanel.csb")
	self.panel:setName("role_lvup_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	-- local bgimg1 = bgimg:getChildByName('bg_1_img')
	self.istouch = false
    self.count = 1
	self.tiemdelta = 0
    self.allTime = 0
    self.initSpeed = 0
	self.isfirst = true
	self.itemarr = {}
	self.itembg = {}
	self.curridx = 0
	self.mid = 0
	self.num = 0
	local descTx = bgimg:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr("ROLE_LVUP_DESC"))
	for i=1,3 do
		local item = {}
		self.itembg[i] = bgimg:getChildByName('itembg_' .. i .. '_img')
        self.itembg[i].index = i
		self.itembg[i]:addTouchEventListener(function (sender, eventType)

			if eventType ==  ccui.TouchEventType.canceled then -- 这里是鼠标拖到未选中的图片的区域的事件,逻辑和ended大部分一样
				self.itembg[i]:loadTexture('uires/ui/common/common_bg_6.png')   
                self.istouch = false
                if self:judge(i) == false then
                    for j=1,3 do
                        self.itembg[j]:setTouchEnabled(false)
                    end
                end

                if self.count == 2 then
                    return
                end
	   			if (self.isfirst  and self.tiemdelta < 0.5 ) then
                    if self:judge(i) == false then
                        self.count = 2
                    end
                    local function callBack()
                        self:lvUpPost(sender.index)
                    end			
                    self.isLvPostState = true
                    self:refreshLvPostState()
                    self:calFunction(sender.index,callBack)	
                    if self.num > 0 then
                        
                    else
                        self.tiemdelta = 0
		   			    self.mid = 0
		   			    self.level = 0
		   			    self.xp = 0
		   			    self.curridx = 0
                        for j=1,3 do
                            self.itembg[j]:setTouchEnabled(true)
                        end
                    end
                    return
	   			end
	   			if self.num > 0 then
                    self:lvUpPost(sender.index)
				else
					self.tiemdelta = 0
		   			self.mid = 0
		   			self.level = 0
		   			self.xp = 0
		   			self.curridx = 0
                    for j=1,3 do
                        self.itembg[j]:setTouchEnabled(true)
                    end
				end
			elseif eventType == ccui.TouchEventType.began then
                self.allTime = 0
                self.initSpeed = MAXDELTA  
				self.isfirst = true
				self.itembg[i]:loadTexture('uires/ui/common/common_bg_12.png')
				local rolelvconf = GameData:getConfData('level')
				local materialobj = BagData:getMaterialById(self.itemdata[i].id)
				if materialobj == nil or (materialobj and materialobj:getNum() < 1)  then
					self.istouch = false
					self.tiemdelta = 0 
					self.isfirst = false
					promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
					GetWayMgr:showGetwayUI(materialobj,true)
					return
				elseif tonumber(self.obj:getLevel()) >= #rolelvconf then
					self.istouch = false
					self.tiemdelta = 0 
					self.isfirst = false
					promptmgr:showSystenHint(GlobalApi:getLocalStr('MAX_LV'), COLOR_TYPE.RED)
					return
				elseif tonumber(self.obj:getLevel() )>= tonumber(UserData:getUserObj():getLv()) then
					self.istouch = false
					self.tiemdelta = 0 
					self.isfirst = false
					promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL2'), COLOR_TYPE.RED)
					return
				else
                    if self.count == 2 then
                        return
                    end
		   			self.istouch = true
		   			self.tiemdelta = 0
		   			self.mid = self.itemdata[i].id
		   			self.level = self.obj:getLevel()
		   			self.xp = self.obj:getXp()
		   			self.curridx = i

                    self:needExpNum(sender.index)
		   		end
	   		elseif eventType ==  ccui.TouchEventType.ended then
                self.itembg[i]:loadTexture('uires/ui/common/common_bg_6.png')   
                self.istouch = false
                if self:judge(i) == false then
                    for j=1,3 do
                        self.itembg[j]:setTouchEnabled(false)
                    end
                end
                if self.count == 2 then
                    return
                end
	   			if (self.isfirst and self.tiemdelta < 0.5) then
                    if self:judge(i) == false then
                        self.count = 2
                    end
                    
                    local function callBack()
                        self:lvUpPost(sender.index)
                    end
                    self.isLvPostState = true
                    self:refreshLvPostState()
	   				self:calFunction(sender.index,callBack)
                    if self.num > 0 then
                        
                    else
                        self.tiemdelta = 0
		   			    self.mid = 0
		   			    self.level = 0
		   			    self.xp = 0
		   			    self.curridx = 0
                    end
                    return
	   			end
	   			if self.num > 0 then
                    self:lvUpPost(sender.index)
				else    -- 按一次（不是长按），但是松手时间刚好大于0.5s，就会出现经验丹无法点击的情况
                    for j=1,3 do
                        self.itembg[j]:setTouchEnabled(true)
                    end
					self.tiemdelta = 0
		   			self.mid = 0
		   			self.level = 0
		   			self.xp = 0
		   			self.curridx = 0
				end
            elseif eventType ==  ccui.TouchEventType.moved then   					
	   		end

		end)
		local itemimg =self.itembg[i]:getChildByName('item_img')
		item.icon = itemimg:getChildByName('icon_img')
		item.icon:ignoreContentAdaptWithSize(true)
		--item.frame = itemimg:getChildByName('frame_img')
		--item.frame:ignoreContentAdaptWithSize(true)
		item.num = self.itembg[i]:getChildByName('num_tx')
		item.name = self.itembg[i]:getChildByName('item_name_tx')
		item.effect = self.itembg[i]:getChildByName('item_eff_tx')
		item.bg = itemimg
		self.itemarr[i] = item
	end
	self.itemdata = {}
	local itemdat = GameData:getConfData('item')
	for k,v in pairs(itemdat) do
		if tostring(v.useType) == 'xp' then
			table.insert(self.itemdata,v)
		end
	end
	self:sortByQuality(self.itemdata)
	self.panel:scheduleUpdateWithPriorityLua(function (dt)
		self:updatepush(dt)
	end, 0)

    local oneLevelBtn = bgimg:getChildByName('one_level_btn')
    self.oneLevelBtn = oneLevelBtn
    local oneLevelBtnTx = oneLevelBtn:getChildByName('text')
    self.oneLevelBtnTx = oneLevelBtnTx
	oneLevelBtnTx:setString(GlobalApi:getLocalStr("ROLE_LVUP_DESC1"))

    local stop_text1 = oneLevelBtn:getChildByName('stop_text1')
    self.stop_text1 = stop_text1
    stop_text1:setString(GlobalApi:getLocalStr('ROLE_LVUP_DESC2'))
    
    -- local stop_ani1 = oneLevelBtn:getChildByName('stop_ani1')
    -- self.stop_ani1 = stop_ani1
    -- local stop_ani2 = oneLevelBtn:getChildByName('stop_ani2')
    -- self.stop_ani2 = stop_ani2
    -- local stop_ani3 = oneLevelBtn:getChildByName('stop_ani3')
    -- self.stop_ani3 = stop_ani3
    -- stop_ani1:setString('.')
    -- stop_ani2:setString('.')
    -- stop_ani3:setString('.')

    oneLevelBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            if self.isLvPostState == true then
                return
            end
            local rolelvconf = GameData:getConfData('level')
            if tonumber(self.obj:getLevel()) >= #rolelvconf then
			    promptmgr:showSystenHint(GlobalApi:getLocalStr('MAX_LV'), COLOR_TYPE.RED)
			    return
            end
            if tonumber(self.obj:getLevel() )>= tonumber(UserData:getUserObj():getLv()) then
			    promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL2'), COLOR_TYPE.RED)
			    return
            end
            local oldlv = self.obj:getLevel()
            local remainXp = rolelvconf[oldlv].roleExp - self.obj:getXp()
            local temp = {}
            local xp = 0
            for i = 1,3 do
                local materialobj = BagData:getMaterialById(self.itemdata[i].id)
                if materialobj and materialobj:getNum() >= 1 then
                    local costExp = tonumber(materialobj.conf.useEffect)
                    local needMaxNum = 1
                    if remainXp <= costExp then
                        needMaxNum = 1
                    else
                        needMaxNum = math.ceil(remainXp/costExp)
                        if needMaxNum >= materialobj:getNum() then
                            needMaxNum = materialobj:getNum()
                        end
                    end
                    remainXp = remainXp - costExp*needMaxNum
                    local itemConf = {}
                    itemConf.id = self.itemdata[i].id
                    itemConf.needMaxNum = needMaxNum
                    table.insert(temp,itemConf)

                    xp = xp + costExp*needMaxNum
                    if remainXp <= 0 then
                        break
                    end
                end
            end
            if #temp == 0 or remainXp > 0 then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('STR_ROLE_LVUP_DES3'),self.obj:getName()), COLOR_TYPE.RED)
                local obj = BagData:getMaterialById(self.itemdata[1].id)
                GetWayMgr:showGetwayUI(obj,true)
            else
                local function callBack(jsonObj)
                    local code = jsonObj.code
		            if code == 0 then
			            local awards = jsonObj.data.awards
			            GlobalApi:parseAwardData(awards)
			            local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end

                        local nextLv = self.obj:getLevel() + 1
                        local maxLv = tonumber(UserData:getUserObj():getLv())
                        local allXp = xp + self.obj:getXp() - rolelvconf[self.obj:getLevel()].roleExp   -- 至少升1级
                        local remainXp = allXp
                        for i = nextLv,maxLv do
                            local roleExp = rolelvconf[i].roleExp
                            local nowXp = remainXp - roleExp
                            nextLv = i
                            if nowXp < 0 then
                                break
                            else
                                remainXp = remainXp - roleExp
                            end
                            if i == maxLv and nowXp >= 0 then
                                remainXp = roleExp - 1
                            end

                        end
                        --print('==============' .. nextLv .. '++++++++++' .. remainXp)
			            self.obj:setLevelandXp(nextLv,remainXp)
			            self.obj:setFightForceDirty(true)
                        self:playUpgradeEffect()
		            else
			            promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'),COLOR_TYPE.RED)
		            end
		            RoleMgr:updateRoleList()
		            RoleMgr:updateRoleMainUI()
                end
                RoleMgr:showRoleLvUpOneLevelPannel(temp,self.obj:getPosId(),callBack)
            end
        end
    end)
end

function RoleLvUpUI:judge(i)
    local rolelvconf = GameData:getConfData('level')
	local materialobj = BagData:getMaterialById(self.itemdata[i].id)
	if materialobj == nil then
		return true
	elseif tonumber(self.obj:getLevel()) >= #rolelvconf then
		return true
	elseif tonumber(self.obj:getLevel() )>= tonumber(UserData:getUserObj():getLv()) then
		return true
	else
        return false
    end
end

function RoleLvUpUI:updateUI(oldlv,level,xp,num,index,callBack)
	local rolelvconf = GameData:getConfData('level')[self.level]
	local percent = string.format("%.2f", xp / rolelvconf.roleExp*100) 
	local materialobj = BagData:getMaterialById(self.itemdata[self.curridx].id)
	local num = materialobj:getNum()-self.num
	RoleMgr:updateMainUIExpBar(oldlv,percent,level,index,callBack)
	self.itemarr[self.curridx].num:setString(GlobalApi:getLocalStr('NUMS')..' ' .. num)


	local midX, midY = RoleMgr:getRoleMainExpBarPos()
    local fSprite = self.itemarr[self.curridx].bg:clone()
    local eSprite = self.itemarr[self.curridx].icon:clone()
    --local frameSprite = self.itemarr[self.curridx].frame:clone()
    local size = self.itemarr[self.curridx].bg:getContentSize()
	local x, y = self.itemarr[self.curridx].bg:convertToWorldSpace(cc.p(self.itemarr[self.curridx].bg:getPosition(size.width / 2, size.height / 2)))
	fSprite:addChild(eSprite)
	--fSprite:addChild(frameSprite)
	fSprite:setPosition(cc.p(x,y))
	UIManager:addAction(fSprite)
   	-- UIManager:addToPromptNode(fSprite, 1)
   	local label = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
	label:setAnchorPoint(cc.p(0.5, 0.5))
	label:setTextColor(COLOR_TYPE.GREEN)
	label:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
	label:setPosition(cc.p(midX, midY))
	label:setString('EXP+'..materialobj:getUseEffect())
	UIManager:addAction(label)

    label:runAction(cc.Sequence:create(
	cc.MoveBy:create(1, cc.p(0, 100)), 
	cc.CallFunc:create(function (  )
		label:removeFromParent()
	end)))
			
   	local action = cc.Spawn:create(cc.ScaleTo:create(0.5, 0.2), cc.MoveTo:create(0.5, cc.p(midX, midY)))
    fSprite:runAction(cc.Sequence:create(action, cc.CallFunc:create(function ()
            fSprite:removeFromParent()
   	 end)))
end

--- 计算一直点击最多需要多少个同类型的经验丹
function RoleLvUpUI:needExpNum(index)
    local oldlv = self.level
    local newlv = UserData:getUserObj():getLv()
    local rolelvconf = GameData:getConfData('level')
    
    --if oldlv <= 98 then
        --newlv = newlv + 1  -- 99.99
    --end


    local allExp = 0
    for i = oldlv,newlv do
        allExp = allExp + rolelvconf[i].roleExp
    end

    local xp  = self.xp
    allExp = allExp - xp

    local materialobj = BagData:getMaterialById(self.itemdata[index].id)
    local costExp = tonumber(materialobj.conf.useEffect)
    if allExp <= costExp then
        self.maxNum = 1
    else
        self.maxNum = math.ceil(allExp/costExp)
    end
    print('====================' .. self.maxNum)

end


function RoleLvUpUI:calFunction(index,callBack)
	local oldlv  = self.level
    local judge = true
	if not self.itemdata[self.curridx] or (not self.itemdata[self.curridx].id) then
		return
	end
	local materialobj = BagData:getMaterialById(self.itemdata[self.curridx].id)
	local rolelvconf = GameData:getConfData('level')[self.level]
	if materialobj == nil then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
		return
	end
	local havenum = materialobj:getNum()
	local rolelvconf = GameData:getConfData('level')
	if tonumber(self.num) < tonumber(havenum) then
		--print('xxxxx')
		self.num = self.num + 1
        --print('sssssssssssssself.numaaaaaaa' .. self.num)
		self.xp = self.xp + tonumber(materialobj:getUseEffect())
		local needlvup = true
		local xp = 0
		while needlvup do 
            --print('xxxxxxxxxxself.xp===='..self.level .. 'xxxxxxxxxxself.dfaf====' .. UserData:getUserObj():getLv())
			if tonumber(self.level) >= tonumber(UserData:getUserObj():getLv()) then
				self.level = UserData:getUserObj():getLv()
				if self.xp >= rolelvconf[self.level].roleExp then
				    --print('xxxxxxxxxxself.xp===='..self.xp)
					--print('xxxxxxxxxxxxx222xself.xp===='..rolelvconf[self.level].roleExp)
					self.xp = rolelvconf[self.level].roleExp-1
                   -- print('sssssssssssssself.numbbbbbb' .. self.num)
				-- else
				-- 	self.xp  
				end
				--self:lvUpPost()
				--promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL2'), COLOR_TYPE.RED)
				break
			end
			if self.xp >= rolelvconf[self.level].roleExp then
				self.xp = self.xp - rolelvconf[self.level].roleExp
				--xp = xp + rolelvconf[self.level].roleExp
				self.level = self.level + 1
				--self:updateUI(oldlv,self.level,self.xp,self.num )
                --print('pppppppppppppppppppppppppppppppp')
			else
                --print('8888888888888888888888888888888')
				needlvup = false
			end
		end
	else
		if self.num > 0 then    -- 当道具数量到最后的时候，数量不足，则不更新ui
			self:lvUpPost(index)
            self.itembg[self.curridx]:loadTexture('uires/ui/common/common_bg_6.png')
            judge = false
		end
	end
    if judge == true then
	    self:updateUI(oldlv,self.level,self.xp,self.num,index,callBack)
    end
end

function RoleLvUpUI:updatepush(dt)
    if self.istouch then
        self.allTime = self.allTime + dt
        --print('8888888888888ppppp' .. self.allTime)
        if self.allTime > 5 then    -- 5秒缩小一倍
            self.allTime = 0
            self.initSpeed = self.initSpeed/2
            --print('77777777777777777dfdsafafasf' .. self.initSpeed)
            if self.initSpeed < 0.05 then
                self.initSpeed = 0.05
            end
        end
    end


    --print('555555555555555555555')
	self.tiemdelta = self.tiemdelta + dt 
	if self.isfirst then
		if self.istouch and self.tiemdelta > FIRSTDELT then
            self.isLvPostState = true
            self:refreshLvPostState()
			self:calFunction(self.obj)
			self.tiemdelta = 0
			self.isfirst = false
		end
	else
		if self.istouch and self.tiemdelta > self.initSpeed then
        
            if self.maxNum and self.num < self.maxNum then
                --print('9999999999999999999999aaaa' .. self.maxNum)
                self:calFunction(self.obj)
            else
                --print('666666666666666666666666')
            end	
		    self.tiemdelta = 0
		end
	end


end

function RoleLvUpUI:lvUpPost(index)
	for i=1,3 do
		self.itembg[i]:setTouchEnabled(false)
	end
	self.istouch = false
	local args = {
		mid = self.mid,
		num = self.num,
		pos = self.obj:getPosId(),
		level = self.level,
		xp = self.xp
	}
	MessageMgr:sendPost("level_up", "hero", json.encode(args), function (jsonObj)
		print(json.encode(jsonObj))
		local code = jsonObj.code
		if code == 0 then
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
			local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			self.obj:setLevelandXp(self.level,self.xp)
			self.obj:setFightForceDirty(true)

            if index and index == 1 and self.obj:getLevelIsChange() then
                self:playUpgradeEffect()     
            end
		else
			promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'),COLOR_TYPE.RED)
		end
		RoleMgr:updateRoleList()
		RoleMgr:updateRoleMainUI()
		self.num = 0
		self.xp = 0
		self.level = 0
		self.tiemdelta = 0
		self.mid = 0
		self.curridx = 0
        GlobalApi:timeOut(function()
            self.isLvPostState = false
            for i=1,3 do
                if self.firstState and self.itembg[i] then
                    self.itembg[i]:setTouchEnabled(true)
                    self.itembg[i]:loadTexture('uires/ui/common/common_bg_6.png')
                end
			    self.count = 1
		    end
            self:refreshLvPostState()
        end,0.5)
	end)
end

function RoleLvUpUI:update(obj)
	self.obj = obj
	for i=1,3 do
        if self.isLvPostState == false then -- 切换页面的时候，不在升级的状态设置可触摸
            self.itembg[i]:setTouchEnabled(true)
        end
		self.itemarr[i].bg:loadTexture(COLOR_ITEMFRAME[FRAME_COLOR[self.itemdata[i].quality]])
		--print(self.itemdata[i].icon)
		self.itemarr[i].icon:loadTexture('uires/icon/material/' .. self.itemdata[i].icon)
		--self.itemarr[i].frame:loadTexture('uires/ui/common/bg1_alpha.png')
		local itemobj = BagData:getMaterialById(self.itemdata[i].id)
		if itemobj then
			self.itemarr[i].num:setString(GlobalApi:getLocalStr('NUMS') ..' '.. itemobj:getNum())
		else
			self.itemarr[i].num:setString(GlobalApi:getLocalStr('NUMS') ..' '..'0')
		end
		self.itemarr[i].name:setString(self.itemdata[i].name)
		self.itemarr[i].name:setTextColor(   COLOR_TYPE[FRAME_COLOR[self.itemdata[i].quality]])
		--self.itemarr[i].name:enableOutline(COLOROUTLINE_TYPE[FRAME_COLOR[self.itemdata[i].quality]],2)
		self.itemarr[i].effect:setString(GlobalApi:getLocalStr('STR_XP') ..'  +' .. self.itemdata[i].useEffect)
	end
    self:refreshLvPostState()
end

function RoleLvUpUI:refreshLvPostState()
    -- self.stop_ani1:setVisible(false)
    -- self.stop_ani2:setVisible(false)
    -- self.stop_ani3:setVisible(false)

    local probtn,nextbtn = RoleMgr:getRoleMainUIChangeBtn()
    if self.isLvPostState == false then
        self.oneLevelBtn:stopAllActions()
        ShaderMgr:restoreWidgetDefaultShader(self.oneLevelBtn)
        self.oneLevelBtn:setTouchEnabled(true)
        self.oneLevelBtnTx:setVisible(true)
        self.stop_text1:setVisible(false)
        probtn:setTouchEnabled(true)
        nextbtn:setTouchEnabled(true)
    else
        ShaderMgr:setGrayForWidget(self.oneLevelBtn)
        self.oneLevelBtn:setTouchEnabled(false)
        self.oneLevelBtnTx:setVisible(false)
        self.stop_text1:setVisible(true)
        print('tttttttt=======================')
        self.stopIndex = 0
        self:animalAction(self.oneLevelBtn)
        probtn:setTouchEnabled(false)
        nextbtn:setTouchEnabled(false)
    end
end

function RoleLvUpUI:animalAction(node)
    self.stopIndex = self.stopIndex + 1
    if self.stopIndex > 3 then
        self.stopIndex = 1
    end

    local action1 = cc.DelayTime:create(0.1)
    local action2 = cc.CallFunc:create(function ()
        for i = 1,3 do
            local aniText = node:getChildByName('stop_ani' .. i)
            if i <= self.stopIndex then
                aniText:setVisible(true)
            else
                aniText:setVisible(false)
            end
        end
    end)
    local action3 = cc.DelayTime:create(0.1)
    local action4 = cc.CallFunc:create(function ()
        self:animalAction(node)
    end)
    node:runAction(cc.Sequence:create(action1,action2,action3,action4))
end

function RoleLvUpUI:playUpgradeEffect()
    RoleMgr:playRoleUpgradeEffect()
end


return RoleLvUpUI