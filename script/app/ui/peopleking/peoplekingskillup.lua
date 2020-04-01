local PeopleKingSkillUpUI = class("PeopleKingSkillUpUI", BaseUI)

local iconRes = "uires/icon/skill/"

function PeopleKingSkillUpUI:ctor(pageType,callback)

    self.uiIndex = GAME_UI.UI_PEOLPLE_KING_SKILL_UP
    self.pageType = pageType or 1
    self.peopleKingData = UserData:getUserObj():getPeopleKing()

    self.skillLvInfo = {}
    local skillLvInfo = self.pageType == 1 and self.peopleKingData.weapon_skills or self.peopleKingData.wing_skills
    for k,v in pairs(skillLvInfo) do
        self.skillLvInfo[tonumber(k)] = v
    end
    
    self.skillConf = GameData:getConfData("skyskill")[self.pageType]
    self.skillupConf = GameData:getConfData("skyskillup")
    self.JieShu = self.pageType == 1 and self.peopleKingData.weapon_level or self.peopleKingData.wing_level

    --升级成功的回调
    self.callback = callback
end

function PeopleKingSkillUpUI:init()

	local bg_img = self.root:getChildByName("bg_img")
    local bg_img1 = bg_img:getChildByName("bg_img1")
    self:adaptUI(bg_img, bg_img1)

    local titlebg = bg_img1:getChildByName("title_bg")
    local titletx = titlebg:getChildByName("title_tx")
    titletx:setString(GlobalApi:getLocalStr("PEOPLE_KING_SKILL_TITLE_" .. self.pageType))

    self.innerBg = bg_img1:getChildByName("inner_bg")
    for i=1,4 do

    	local skillbg = self.innerBg:getChildByName("skill_bg" .. i)
    	--升级按钮
        local upBtn = skillbg:getChildByName("up_btn")
        local tx = upBtn:getChildByName("info_tx")
        tx:setString(GlobalApi:getLocalStr("UPGRADE1"))
        upBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:sendUpLvMsg(1,i)
            end
        end)

        --Max
    	local maxBtn = skillbg:getChildByName("max_btn")
    	local tx = maxBtn:getChildByName("info_tx")
    	tx:setString("MAX")
    	maxBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            self:sendUpLvMsg(2,i)
	        end
	    end)
    end

    --技能信息
    self:updateSkillInfo()

    local close_btn = bg_img1:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:hidePeopleKingSkillUpUI()
        end
    end)
end

function PeopleKingSkillUpUI:sendUpLvMsg(clicktype,id)
	local fitcondition = self:checkupCondition(id)
	if fitcondition then
		local upMaxLv = self:getUpMaxLv(clicktype,id)
        print("upMaxLv" ,upMaxLv)
        local currAttr = self.pageType == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
        for i = 1, 4 do
            currAttr[i] = currAttr[i] or 0
        end
        local oldfightforce = RoleData:getFightForce()
        local act = clicktype == 1 and "upgrade_sky_skill" or "upgrade_sky_skill_max"
		if upMaxLv then
            local args = {
                type = self.pageType,
                skill = id
            }
            MessageMgr:sendPost(act, 'hero', json.encode(args), function (jsonObj)
                local code = jsonObj.code
                local data = jsonObj.data
                if code == 0 then

                    local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end

                    local lv = upMaxLv
                    local skills = data.sky_skill
                    if skills then
                        lv = skills[tostring(id)] or 0
                    end

                    if self.pageType == 1 then
                        self.peopleKingData.weapon_skills[tostring(id)] = lv
                    else
                       self.peopleKingData.wing_skills[tostring(id)] = lv
                    end

                    local newAttr = self.pageType == 1 and RoleData:getPeopleKingWeaponAttr() or RoleData:getPeopleKingWingAttr()
                    for i = 1, 4 do
                        newAttr[i] = newAttr[i] or 0
                    end
                    RoleData:setAllFightForceDirty()
                    local newfightforce = RoleData:getFightForce()
                    GlobalApi:popupTips(currAttr, newAttr, oldfightforce, newfightforce)

                    self.skillLvInfo[id] = lv
                    self:updateSkillInfo()

                    if self.callback then
                        self.callback()
                    end
                end
            end)
		end
	end
end

function PeopleKingSkillUpUI:checkupCondition(id)

	if not self.skillConf[id] then
		return false
	end

	local skillId = self.pageType*100+id
	if not self.skillupConf[skillId] then
		return false
	end

	local maxLvOfStage = self.skillConf[id].levelLimit*self.JieShu
	local curLv = self.skillLvInfo[id]

	if curLv >= maxLvOfStage then
		 local hitStr = self.pageType == 1 and GlobalApi:getLocalStr('PEOPLE_KING_SKILL_DESC_6') or GlobalApi:getLocalStr('PEOPLE_KING_SKILL_DESC_7')
		 promptmgr:showSystenHint(hitStr, COLOR_TYPE.RED)
		 return false
    else
    	local costnum = self.skillupConf[skillId][curLv].cost[1][3] or 0
        local ownbooks = UserData:getUserObj():getSkybook()
    	if ownbooks < -costnum then
            local award = DisplayData:getDisplayObj(self.skillupConf[skillId][curLv].cost[1])
    		promptmgr:showSystenHint(GlobalApi:getLocalStr('PEOPLE_KING_SKILL_DESC_8'), COLOR_TYPE.RED)
            GetWayMgr:showGetwayUI(award, true)
    		return false
    	end
	end
	return true
end

--得到可以升级的最大等级
function PeopleKingSkillUpUI:getUpMaxLv(cliketype,id)

	if not self.skillConf[id] then
		return
	end
	local skillId = self.pageType*100+id
	local skillupcfg = self.skillupConf[skillId]
	if not skillupcfg then
		return
	end

	local curLv = self.skillLvInfo[id]
	local maxLv = #skillupcfg
	local upMaxLv = curLv + 1
	local maxLvOfStage = self.skillConf[id].levelLimit*self.JieShu
	if cliketype == 2 then

		--技能书可以满足的最大等级
		local lv = curLv
		local costnum = skillupcfg[curLv].cost[1][3] or 0
		local ownbooks = UserData:getUserObj():getSkybook()
		while ownbooks >= (-costnum) do
			ownbooks = ownbooks + costnum
			lv = lv + 1
			if lv >= maxLvOfStage or lv >= maxLv then
				break
			end
			costnum = skillupcfg[lv].cost[1][3] or 0
    	end
    	upMaxLv = lv
	end

	return upMaxLv
end

function PeopleKingSkillUpUI:updateSkillInfo()

	local attrCfg = GameData:getConfData("attribute")
	for i=1,4 do

    	local skillbg = self.innerBg:getChildByName("skill_bg" .. i)
    	if not self.skillConf[i] then
    		return
    	end
    	local skillconf = self.skillConf[i]

    	local id = self.pageType*100+i
    	local skillupcfg = self.skillupConf[id]
    	if not skillupcfg then
    		return
    	end

    	local curLv = self.skillLvInfo[i]
    	if curLv >= #skillupcfg then
    		curLv = #skillupcfg
    	end
        if curLv <= 0 then
            curLv = 1
        end

    	local isMaxLv = (curLv == #skillupcfg) and true or false
    	local nextLv = curLv + 1
    	if nextLv >= #skillupcfg then
    		nextLv = #skillupcfg
    	end

    	--技能图标，名字，等级
    	local iconframe = skillbg:getChildByName("icon_frame")
    	local skillIcon = iconframe:getChildByName("icon")
    	local skilllvTx = iconframe:getChildByName("lv_tx")
    	local skillNameTx = skillbg:getChildByName("name_tx")
        
    	skillIcon:loadTexture(iconRes..skillconf.icon)
    	skillNameTx:setString(skillconf.name)
    	skilllvTx:setString("Lv."..curLv)
        skilllvTx:setVisible(self.skillLvInfo[i] ~= 0)
        
    	local desc = skillbg:getChildByName("desc_tx3")
    	desc:setString(GlobalApi:getLocalStr("PEOPLE_KING_SKILL_DESC_1"))

    	--加成属性
		local attrNameTx1 = skillbg:getChildByName("desc_tx1")
		local attrNameTx2 = skillbg:getChildByName("desc_tx2")
		local attrvalue1 = skillbg:getChildByName("add_value1")
    	local attrvalue2 = skillbg:getChildByName("add_value2")

    	local attrname = GlobalApi:getLocalStr("PEOPLE_KING_SKILL_DESC_5") .. attrCfg[skillconf.att].name
    	attrNameTx1:setString(attrname)
    	attrNameTx2:setString(attrname)
    	attrvalue1:setString("+" .. skillupcfg[curLv].attValue)
    	attrvalue2:setString("+" .. skillupcfg[nextLv].attValue)

    	attrNameTx2:setVisible(not isMaxLv)
    	attrvalue2:setVisible(not isMaxLv)
    	desc:setVisible(not isMaxLv)

    	--解锁或满级文字
    	local lockTx = skillbg:getChildByName("lock_tx")
    	local str = self.pageType == 1 and GlobalApi:getLocalStr("PEOPLE_KING_SKILL_DESC_2") or GlobalApi:getLocalStr("PEOPLE_KING_SKILL_DESC_3")
    	lockTx:setString(string.format(str,skillconf.unlock))
    	if isMaxLv then
    		lockTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_SKILL_DESC_4"))
    	end

    	--花费
    	local cost_bg = skillbg:getChildByName("cost_bg")
    	local costTx = cost_bg:getChildByName("cost_tx")
        local icon = cost_bg:getChildByName("icon")
        icon:loadTexture("uires/ui/res/res_skybook.png")
    	local costnum = skillupcfg[curLv].cost[1][3] or 0
        
    	costTx:setString(-costnum)
        local ownbooks = UserData:getUserObj():getSkybook()
    	if ownbooks < -costnum then
    		costTx:setColor(COLOR_TYPE.RED)
    	else
    		costTx:setColor(COLOR_TYPE.GREEN)
    	end

        local typestr = self.pageType == 1 and GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1") or GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2")
        local maxLvOfStage = skillconf.levelLimit*self.JieShu
        if curLv >= maxLvOfStage and not isMaxLv and maxLvOfStage > 0 then
            local nextJie = self.JieShu+1
            local lvrange = nextJie*skillconf.levelLimit
            local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_SKILL_DESC_9"),nextJie,typestr)
            str = str .. "Lv."..lvrange
            lockTx:setString(str)
        end

    	--升级按钮
    	local maxBtn = skillbg:getChildByName("max_btn")
    	local upBtn = skillbg:getChildByName("up_btn")
    	local show = false
    	if self.JieShu >= skillconf.unlock and not isMaxLv and curLv < maxLvOfStage then
    		show = true
    	end
        --
        
    	cost_bg:setVisible(show)
    	upBtn:setVisible(show)
    	maxBtn:setVisible(show)
    	lockTx:setVisible(not show)
    end
end

return PeopleKingSkillUpUI