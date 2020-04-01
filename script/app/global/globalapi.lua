local PIC_EXTENSION = ".png"
local targetPlatform = CCApplication:getInstance():getTargetPlatform()
-- if targetPlatform == kTargetAndroid then
--     PIC_EXTENSION = ".pkm"
-- elseif targetPlatform == kTargetIphone or targetPlatform == kTargetIpad then
--     PIC_EXTENSION = ".pvr.ccz"
-- end

cc.exports.GlobalApi = {
	seed = 0,
    armatureMap = {},
    jsonMap = {},
    runLock = {},
    confuseStr = "",
    confuseNumber = 0,
    fuckCheat = false,
    stopServer = {}
}

setmetatable(GlobalApi.armatureMap, {__mode = "k"})

function GlobalApi:tableFind(t, e)
    for i, v in ipairs(t) do
        if v == e then
            return i
        end
    end
    return 0
end

function GlobalApi:showAwards(awards,ntype,callback,confirmCallback)
    if #awards <= 0 then
        return
    end
    local showAwardUI = require('script/app/ui/tips/showawardui').new(awards,ntype,callback,confirmCallback)
    showAwardUI:showUI()
end


function GlobalApi:filterWords(s, nType)
    local ss = {}
    local k = 1
    while true do
        if k > #s then break end
        local c = string.byte(s,k)
        if not c then break end
        if c<192 then
            if nType == 1 then
                if (c>=48 and c<=57) or (c>= 65 and c<=90) or (c>=97 and c<=122) then
                    table.insert(ss, string.char(c))
                end
            end
            k = k + 1
        elseif c<224 then
            k = k + 2
        elseif c<240 then
            if c>=228 and c<=233 then
                local c1 = string.byte(s,k+1)
                local c2 = string.byte(s,k+2)
                if c1 and c2 then
                    local a1,a2,a3,a4 = 128,191,128,191
                    if c == 228 then a1 = 184
                    elseif c == 233 then a2,a4 = 190,c1 ~= 190 and 191 or 165
                    end
                    if c1>=a1 and c1<=a2 and c2>=a3 and c2<=a4 then
                        table.insert(ss, string.char(c,c1,c2))
                    end
                end
            end
            k = k + 3
        elseif c<248 then
            k = k + 4
        elseif c<252 then
            k = k + 5
        elseif c<254 then
            k = k + 6
        end
    end
    return table.concat(ss)
end    

function GlobalApi:checkSensitiveWords(str)
    local filterStr = GlobalApi:filterWords(str, 1)
    filterStr = GlobalApi:filterWords(str)
    if #filterStr > 0 then
        str = filterStr
    end
    local chunk = cc.FileUtils:getInstance():getStringFromFile('data/local/sensitivewords.txt')
    if not chunk then
        error("*** Failed to read data file: " .. filename)
        return false
    end
    -- print(chunk)
    chunk = string.gsub(chunk, "[\r]*", '')
    local rowDatas = string.split(chunk , '\n')
    local noSensitiveWords = true
    local function getStar(s)
        local len = string.len(s)
        local str = ''
        for i=1,math.ceil(len/3) do
            str = str .. '*'
        end
        return str
    end
    for i,v in pairs(rowDatas) do
        if v ~= '' then
            local a,b = string.find(str,v)
            if a or b then
                local str1 = string.gsub(str,v,getStar(v))
                str = str1
                -- return false,str1
                noSensitiveWords = false
            end
        end
    end
    return noSensitiveWords,str
end

function GlobalApi:showAwardsCommon(awards,ntype,callback,merge,delay)
    if #awards <= 0 then
        return
    end

    local function confirmCallback()

        local surfaceAward = self:showAwardsPeopleKingSurface(awards)
        if not next(surfaceAward) then
            GlobalApi:showAwardsCommonByText(awards,merge,delay)
        end  
    end

    local showAwardUI = require('script/app/ui/tips/showawardui').new(awards,ntype,callback,confirmCallback)
    showAwardUI:showUI()
end

--奖励展示人皇外观
function GlobalApi:showAwardsPeopleKingSurface(awards)

    local surfaceAward = {}
    local strKey = UserData:getUserObj():getUid()..'changelook_sign_'
    for i,v in ipairs(awards) do
        if v[1] == "skywing" or v[1] == "skyweapon" then
            surfaceAward[#surfaceAward+1] = v
            local ntype = v[1] == "skyweapon" and 1 or 2
            local surfaceId = tonumber(v[2])
            local str = strKey .. ntype .."_"..surfaceId
            cc.UserDefault:getInstance():setBoolForKey(str,true)  
        end
    end
    if next(surfaceAward) then
        PeopleKingMgr:showPeopleKingGetSurfaceUI(surfaceAward)
    end

    return surfaceAward    
end

-- 非新手引导下,这里加个判断
function GlobalApi:showKingLvUp(lastLv,nowLv,delay,callBack)
    if GuideMgr and GuideMgr.guideNode ~= nil then
        if callBack then
            callBack()
        end
        return
    end
    if nowLv > lastLv then
        local KingLvUpUI = require("script/app/ui/mainscene/kinglvup")
        local kingLvUpUI = KingLvUpUI.new(lastLv,nowLv,delay,callBack)
        kingLvUpUI:showUI()
        
        SdkData:SDK_setRoleData(3)
    else
        if callBack then
            callBack()
            RoleData:setAllFightForceDirty()
            RoleData:getFightForce()
        end
    end
end

--- 显示奖励品,以一行的文字显示的
-- @param awards 传入的奖励品
-- @param merge  同类型奖励品是否合并，默认不合并
-- @param delay  延迟显示时间,默认是0
function GlobalApi:showAwardsCommonByText(awards,merge,delay)
    if #awards <= 0 then
        return
    end

    local merge = merge or false
    local delay = delay or 0

    local showAwards = awards
    if merge then
        showAwards = self:mergeAwards(awards)
    end

    self:timeOut(function()
        local showWidgets = {}
		for i,v in ipairs(showAwards) do
			local awardTab = DisplayData:getDisplayObj(v)
			local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..awardTab:getName()..'x'..awardTab:getNum(), 'font/gamefont.ttf', 24)
			w:setTextColor(awardTab:getNameColor())
			w:enableOutline(awardTab:getNameOutlineColor(),1)
			w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
			table.insert(showWidgets, w)
		end
		promptmgr:showAttributeUpdate(showWidgets)
    end,delay)
end

--- 合并奖励品
function GlobalApi:mergeAwards(awards)
    local userAwards = {}
	local materialAwards = {}
    local gemAwards = {}
    local fragmentAwards = {}
    local dressAwards = {}
    local cardAwards = {}
    local otherTab = {}

    for i,v in ipairs(awards) do
        if v[1] == 'user' then
            userAwards[v[2]] = (userAwards[v[2]] or 0) + v[3]
        elseif v[1] == 'material' then
            materialAwards[v[2]] = (materialAwards[v[2]] or 0) + v[3]
        elseif v[1] == 'gem' then
            gemAwards[v[2]] = (gemAwards[v[2]] or 0) + v[3]
        elseif v[1] == 'fragment' then
            fragmentAwards[v[2]] = (fragmentAwards[v[2]] or 0) + v[3]
        elseif v[1] == 'dress' then
            dressAwards[v[2]] = (dressAwards[v[2]] or 0) + v[3]
        elseif v[1] == 'card' then
            cardAwards[v[2]] = (cardAwards[v[2]] or 0) + v[3]
        else
            otherTab[#otherTab + 1] = v
        end
    end

    for i,v in pairs(userAwards) do
        otherTab[#otherTab + 1] = {'user',i,tonumber(v)}
    end

    for i,v in pairs(materialAwards) do
        otherTab[#otherTab + 1] = {'material',i,tonumber(v)}
    end

    for i,v in pairs(gemAwards) do
        otherTab[#otherTab + 1] = {'gem',i,tonumber(v)}
    end

    for i,v in pairs(fragmentAwards) do
        otherTab[#otherTab + 1] = {'fragment',i,tonumber(v)}
    end

    for i,v in pairs(dressAwards) do
        otherTab[#otherTab + 1] = {'dress',i,tonumber(v)}
    end

    for i,v in pairs(cardAwards) do
        otherTab[#otherTab + 1] = {'card',i,tonumber(v)}
    end
    
    return otherTab
end

--- 延迟执行,和页面没关系，退出页面也会执行
-- @param self
-- @param callback 回调函数
-- @param delaySec 延迟的秒数
-- @return 任务ID
function GlobalApi:timeOut(callback,delaySec)
	if callback == nil then
		return
	end

    local delaySec = delaySec or 0
	local sId
    local scheduler = cc.Director:getInstance():getScheduler()

	local function tick()
		callback()
		scheduler:unscheduleScriptEntry(sId)
        sId = nil
	end
	sId = scheduler:scheduleScriptFunc(tick,delaySec,false)

	return sId
end


--- 间隔调用
-- @param callback 回调函数
-- @param delaySec 延迟的秒数
-- @return 任务ID
function GlobalApi:interval(callback,delaySec)
	if callback == nil then
		print("callback is nil")
		return
	end

	return cc.Director:getInstance():getScheduler():scheduleScriptFunc(callback,delaySec,false)
end

--- 清除任务(间隔调用/延迟执行)
-- @param self
-- @param schedulerId 任务ID
function GlobalApi:clearScheduler(schedulerId)
	if schedulerId then

	   cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerId)
	end

end

function GlobalApi:getLocalStr(key)
	local gamedata = GameData:getConfData("local/localtext")
    if gamedata[key] then
	    return gamedata[key].Chstr or ''
    else
        return ''
    end
end

function GlobalApi:getGlobalValue(key)

    local conf = GameData:getConfData("global")
    if conf[key] then

        local value = conf[key].value or ""
        if "foodMax" == key then
            value = value + (self:getPrivilegeById("maxFood")  or 0)
        end
        return value or ""
    else
        return ''
    end
end

-- 红色碎片特效
function GlobalApi:setLightEffect(awardBgImg,scale)
    local effect = awardBgImg:getChildByName('chip_light')
    local size = awardBgImg:getContentSize()
    if not effect then
        effect = GlobalApi:createLittleLossyAniByName("chip_light")
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('chip_light')
        effect:setVisible(true)
        effect:setPosition(cc.p(size.width/2,size.height/2))
        effect:setScale(scale or 1)
        awardBgImg:addChild(effect)
    else
        effect:setVisible(true)
    end
end

function GlobalApi:createAniByRoleId(id, changeEquipObj)
    local aniName = GameData:getConfData("hero")[id].url
    return self:createAniByName(aniName, nil, changeEquipObj)
end

function GlobalApi:createLittleLossyAniByRoleId(id, changeEquipObj)
    local aniName = GameData:getConfData("hero")[id].url
    return self:createLittleLossyAniByName(aniName .. "_display", nil, changeEquipObj)
end

function GlobalApi:createAniByName(aniName, url, changeEquipObj)
    if aniName == "NA" then
        aniName = "guanyu"
    end
    url = url or "animation/" .. aniName .. "/" .. aniName
    if self.jsonMap[url] == nil then
        -- if string.sub(aniName, 1, 4) == "nan_" then
        --     ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation/nan/nan" .. PIC_EXTENSION, "animation/nan/nan.plist", url .. ".json")
        -- else
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(url  .. PIC_EXTENSION, url .. ".plist", url .. ".json")
        -- end
        self.jsonMap[url] = 1
    end
    local armature = ccs.Armature:create(aniName)
    self:changeModelEquip(armature, aniName, changeEquipObj, 1)
    -- if targetPlatform == kTargetAndroid then
    --     ShaderMgr:setShaderForArmature(armature, "default_etc")
    -- end
    self.armatureMap[armature] = url
    return armature
end

function GlobalApi:createLittleLossyAniByName(aniName, url, changeEquipObj)
    url = url or "animation_littlelossy/" .. aniName .. "/" .. aniName
    -- dump("-------------------log url:"..url)
    -- dump("-------------------log aniName:"..aniName)
    if self.jsonMap[url] == nil then
        -- if string.sub(aniName, 1, 4) == "nan_" then
        --     ccs.ArmatureDataManager:getInstance():addArmatureFileInfo("animation_littlelossy/nan_display/nan_display" .. PIC_EXTENSION, "animation_littlelossy/nan_display/nan_display.plist", url .. ".json")
        -- else
            ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(url  .. PIC_EXTENSION, url .. ".plist", url .. ".json")
        -- end
        self.jsonMap[url] = 1
    end
    local armature = ccs.Armature:create(aniName)
    self:changeModelEquip(armature, aniName, changeEquipObj, 1)
    -- if targetPlatform == kTargetAndroid then
    --     ShaderMgr:setShaderForArmature(armature, "default_etc")
    -- end
    self.armatureMap[armature] = url
    return armature
end

function GlobalApi:createLosslessAniByName(aniName, url, changeEquipObj)
    url = url or "animation_lossless/" .. aniName .. "/" .. aniName
    if self.jsonMap[url] == nil then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(url  .. ".png", url .. ".plist", url .. ".json")
        self.jsonMap[url] = 1
    end
    local armature = ccs.Armature:create(aniName)
    self:changeModelEquip(armature, aniName, changeEquipObj, 1)
    self.armatureMap[armature] = url
    return armature
end

-- imgType:1、资源中度压缩，2、资源轻度压缩，3资源无压缩
function GlobalApi:createArmature(aniName, jsonRes, plistRes, imgType, changeEquipObj)
    plistRes = plistRes or jsonRes
    cc.SpriteFrameCache:getInstance():addSpriteFrames(plistRes .. ".plist")
    if self.jsonMap[jsonRes] == nil then
        ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(jsonRes .. ".json")
        self.jsonMap[jsonRes] = 1
    end
    local armature = ccs.Armature:create(aniName)
    self:changeModelEquip(armature, aniName, changeEquipObj, 1)
    if targetPlatform == kTargetAndroid and imgType < 3 then
        ShaderMgr:setShaderForArmature(armature, "default_etc")
    end
    self.armatureMap[armature] = jsonRes
    return armature
end

function GlobalApi:onlyCreateArmature(name, changeEquipObj)
    local armature = ccs.Armature:create(name)
    self:changeModelEquip(armature, name, changeEquipObj, 1)
    -- if targetPlatform == kTargetAndroid then
    --     ShaderMgr:setShaderForArmature(armature, "default_etc")
    -- end
    return armature
end

function GlobalApi:changeModelAdvanced(armature, aniName, advanced, createOrChange)
    local advancedModelConf = GameData:getConfData("advancedmodel")
    if advancedModelConf[aniName] then
        if createOrChange == 2 then
            local hideBones1 = advancedModelConf[aniName]["level" .. (advanced-1)]
            if hideBones1 then 
                for k, v in ipairs(hideBones1) do
                    local bone = armature:getBone("advanced_" .. v)
                    if bone and bone:isIgnoreMovementBoneData() then
                        bone:setIgnoreMovementBoneData(false)
                        bone:changeDisplayWithIndex(0, false)
                    end
                end
            end
        end
        local hideBones2 = advancedModelConf[aniName]["level" .. advanced]
        if hideBones2 then
            for k, v in ipairs(hideBones2) do
                local bone = armature:getBone("advanced_" .. v)
                if bone then
                    bone:setIgnoreMovementBoneData(true)
                    bone:changeDisplayWithIndex(-1, true)
                end
            end
        end
    end
end

function GlobalApi:changeModelEquip(armature, aniName, changeEquipObj, createOrChange)
    if changeEquipObj then
        local changeequipConf = GameData:getConfData("changeequip")
        if changeEquipObj.advanced then
            self:changeModelAdvanced(armature, aniName, changeEquipObj.advanced, createOrChange)
        else
            self:changeModelAdvanced(armature, aniName, 0, createOrChange)
        end
        if changeEquipObj.bones then
            if changeequipConf[aniName] then
                for k, v in ipairs(changeEquipObj.bones) do
                    local boneName = changeequipConf[aniName]["bone" .. v]
                    local newEquipName = changeequipConf[aniName]["equip" .. v]
                    if boneName and newEquipName and changeEquipObj.equips[k] then
                        -- newEquipName = newEquipName .. "_" .. changeEquipObj.equips[k] .. ".png"
                        local bone = armature:getBone(boneName)
                        if bone then
                            if v == 1 then
                                local res = 'uires/ui/nan/wuqi/'..newEquipName.."_"..changeEquipObj.equips[v]..'.png'
                                local newEquip = ccs.Skin:create(res)
                                bone:addDisplay(newEquip, 0)
                            else
                                local res = nil 
                                if not changeEquipObj.equips[v] then 
                                    res = 'uires/ui/nan/chibang/'..newEquipName.."_"..changeEquipObj.equips[tonumber(v) - 1]..'.png'
                                else
                                    res = 'uires/ui/nan/chibang/'..newEquipName.."_"..changeEquipObj.equips[v]..'.png'
                                end

                                -- local res = 'uires/ui/nan/chibang/'..newEquipName.."_"..changeEquipObj.equips[v]..'.png'
                                if changeEquipObj.equips[v] == 0 then
                                    res = 'uires/ui/common/bg1_alpha.png'
                                end
                                local newEquip = ccs.Skin:create(res)
                                bone:addDisplay(newEquip, 0)
                            end
                        end
                    end
                end
            end
        end
    else
        self:changeModelAdvanced(armature, aniName, 0, createOrChange)
    end
end

-- imgType:1、资源轻压缩，2、资源无压缩
function GlobalApi:createSpineByName(spineName, url, imgType)
    local spineData = SpineLoader:Get():load(spineName, url)
    local spineAni = SpineCreater:createWithData(spineData)
    if imgType == 1 and targetPlatform == kTargetAndroid then
        ShaderMgr:setShaderForSpine(spineAni, "default_etc_mvp")
    end
    return spineAni
end

function GlobalApi:createSpineAsyncByName(spineName, url, func)
    url = url or "spine/" .. spineName .. "/" .. spineName
    SpineLoader:Get():loadAsync(spineName, url, func)
end

function GlobalApi:createWithSpriteFrameName(name)
    local sprite = cc.Sprite:createWithSpriteFrameName(name)
    -- if targetPlatform == kTargetAndroid then
    --     ShaderMgr:setShaderForSprite(sprite, "default_etc")
    -- end
    return sprite
end

function GlobalApi:parseAwardData(awards,specaward)
    specaward = tonumber(specaward) or 0
    if awards and specaward == 0 then
    	for k, v in ipairs(awards) do
    		if v[1] == "user" then
    			UserData:addAttrData(v)
    		elseif v[1] == "equip" then
                BagData:parseEquipAward(v)
    		elseif v[1] == "material" then
                BagData:parseMaterialAward(v)
    		elseif v[1] == "card" then
                BagData:parseCardAward(v)
    		elseif v[1] == "gem" then
                BagData:parseGemAward(v)
    		elseif v[1] == "fragment" then
                BagData:parseFragmentAward(v)
            elseif v[1] == "dress" then
                BagData:parseDressAward(v)
            elseif v[1] == "dragon" then
                BagData:parseDragonGemAward(v)
            elseif v[1] == "limitmat" then
                BagData:parseLimitMatAward(v)
            elseif v[1] == "exclusive" then
                BagData:parseExclusiveAward(v)
    		end
    	end
    elseif awards and specaward ==1 then
        for i=1,#awards do
            local award = awards[i]
            for k, v in ipairs(award) do
                if v[1] == "user" then
                    UserData:addAttrData(v)
                elseif v[1] == "equip" then
                    BagData:parseEquipAward(v)
                elseif v[1] == "material" then
                    BagData:parseMaterialAward(v)
                elseif v[1] == "card" then
                    BagData:parseCardAward(v)
                elseif v[1] == "gem" then
                    BagData:parseGemAward(v)
                elseif v[1] == "fragment" then
                    BagData:parseFragmentAward(v)
                elseif v[1] == "dress" then
                    BagData:parseDressAward(v)
                elseif v[1] == "dragon" then
                    BagData:parseDragonGemAward(v)
                elseif v[1] == "limitmat" then
                    BagData:parseLimitMatAward(v)
                elseif v[1] == "exclusive" then
                    BagData:parseExclusiveAward(v)
                end
            end
        end
    end
end

function GlobalApi:setRandomSeed(seed)
	self.seed = seed
end

function GlobalApi:random(min, max)
	max = max or 1
    min = min or 0
    self.seed = (self.seed*9301 + 49297)%233280
    local rnd = self.seed/233280
    return min + math.floor(rnd*(max - min))
end

function GlobalApi:getAssistLvByNum(num)
	local lv = 0
	local lvconf = GameData:getConfData('level')
	for k, v in ipairs(lvconf) do
		if  tonumber(num) == tonumber(v.heroNum) then
			lv = k
			return lv
		end
	end
	return lv
end

function GlobalApi:toWordsNumber(num)
    if not num then
        return 0
    end
    local str = ""
    if num > 100000000 then
        str = string.format(self:getLocalStr('ONE_HUNDRED_MILLION'), math.floor(num / 100000000))
    elseif num > 100000 then
        str = string.format(self:getLocalStr('TEN_THOUSAND'), math.floor(num / 10000))
    else
        str = tostring(num)
    end
    return str
end

function GlobalApi:runNum(label,labeltype,plKey,old,new,scale)
    local endScale = (scale or 1)*1.1
    if old and new ~= old then
        self.runLock[plKey] = true
        label:setString(old)
        label:stopAllActions()
        label:setScale(endScale)
        label:runAction(cc.DynamicNumberTo:create(labeltype, 1, new, function()
            self.runLock[plKey] = false
            label:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                if self.runLock[plKey] == true then
                    return
                end
                label:runAction(cc.ScaleTo:create(0.3,scale or 1))
                label:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                    label:setString(self:toWordsNumber(new))
                    end)))
            end)))
        end))
    else
        label:setString(self:toWordsNumber(new))
    end
end

function GlobalApi:toWordsNumberImg(parnet,node1,node2,num)
    local str = ""
    local bgSize = parnet:getContentSize()

    if num > 100000000 then
        str = math.floor(num / 100000000)
        node1:setVisible(true)
        node1:loadTexture('uires/ui/text/hundred_million.png')
        node1:setAnchorPoint(cc.p(1,0.5))
        node1:ignoreContentAdaptWithSize(true)
        local size = node1:getContentSize()
        node2:setPosition(cc.p(bgSize.width - 50 - size.width,bgSize.height/2))
    elseif num > 100000 then
        str = math.floor(num / 10000)
        node1:setVisible(true)
        node1:loadTexture('uires/ui/text/ten_thousand.png')
        node1:setAnchorPoint(cc.p(1,0.5))
        node1:ignoreContentAdaptWithSize(true)
        local size = node1:getContentSize()
        node2:setPosition(cc.p(bgSize.width - 50 - size.width,bgSize.height/2))
    else
        node1:setVisible(false)
        str = tostring(num)
        node2:setPosition(cc.p(bgSize.width - 50,bgSize.height/2))
    end
    node2:setString(str)
end

function GlobalApi:rotateShake(duration, count, range, delay)
    local action = {}
    action[1] = cc.DelayTime:create(delay)
    action[2] = cc.RotateBy:create(duration / count / 4, range)
    action[3] = cc.RotateBy:create(duration / count / 2, range * (-2))
    action[4] = cc.RotateBy:create(duration / count / 2, range * 2)
    action[5] = cc.RotateBy:create(duration / count / 2, range * (-2))
    action[6] = cc.RotateBy:create(duration / count / 4, range)
    action[7] = cc.DelayTime:create(delay)
    local array = {}
    for i = 1, count do
        for _,v in ipairs(action) do
            table.insert(array, v)
        end
    end
    return cc.Sequence:create(array)
end

function GlobalApi:regiesterBtnHandler(btn,callback)
    local point1
    local point2
    local beginTime = 0
    local endTime = 0
    btn:setSwallowTouches(false)
    btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            beginTime = socket.gettime()
            AudioMgr.PlayAudio(11)
            point1 = sender:getTouchBeganPosition()
        end
        if eventType == ccui.TouchEventType.ended then
            endTime = socket.gettime()
            point2 = sender:getTouchEndPosition()
            if point1 then
                local dis =cc.pGetDistance(point1,point2)
                if dis <= 5 then
                    if callback then
                        callback()
                    end
                end
            end
        end
    end)
end

function GlobalApi:getFightForcePre(attarr)
    local arr = attarr
    local attconf =GameData:getConfData('attribute')
    local fightforce = 0
    for i=1,#attconf do
        if type(arr[i]) == 'table' then
            fightforce = fightforce + math.floor((tonumber(arr[i].value) or 0)*attconf[i].factor)
        elseif arr[i] then
            fightforce = fightforce + math.floor((tonumber(arr[i]) or 0 )*attconf[i].factor)
        end
    end
    return fightforce
end

function GlobalApi:getProFightForce(attarr,eauiped,maxNum)
    local fightforce = 0
    local attconf =GameData:getConfData('attribute')
    local att = {}
    for i=1,#attconf do
        att[i] = 0
    end
    for i=1,maxNum do
        local gemObj = eauiped:getGems()[i]
        if gemObj then
            local attrId = gemObj:getAttrId()
            att[attrId] = att[attrId] + gemObj:getValue()
        end
    end
    local attemp = {}
    for i=1,#attconf do
        attemp[i] = 0
        attemp[i] = att[i]
    end
    fightforce =self:getFightForcePre(attemp)
    if not attarr.getFightForce then
        fightforce = fightforce  + self:getFightForcePre(attarr)
    else
        local arr = attarr:getSubAttribute()
        local arr1 = eauiped:getSubAttribute()
        local num = 0
        for k,v in pairs(arr) do
            num = num + 1
        end
        if num > 0 then
            fightforce = fightforce  + self:getFightForcePre(arr)
        else
            fightforce = fightforce  + self:getFightForcePre(arr1)
        end
        fightforce = fightforce  + attarr:getFightForce()
    end
    local fightforce1 = eauiped:getFightForce()
    return fightforce > fightforce1
end

-- 时间转换：返回字符串描述的时间的秒数
-- ttype == 1  <------>  timeStr format : 2014:5:22:0:0:0
-- ttype == 2  <------>  timeStr format : 20140522
function GlobalApi:convertTime( ttype , timeStr )
    if ttype == 1 then
        local dateTab = string.split(timeStr , ':')
        local length = #dateTab
        if length < 6 then
            return 0
        end
        local tab = {}
        tab['year'] = dateTab[1] or 1970
        tab['month'] = dateTab[2] or 1
        tab['day'] = dateTab[3] or 1
        tab['hour'] = dateTab[4] or 0
        tab['min'] = dateTab[5] or 0
        tab['sec'] = dateTab[6] or 0

        return Time.time(tab)
    elseif ttype == 2 then
        if string.len(timeStr) ~= 8 then
            return 0
        end
        local y = tonumber( string.sub(timeStr , 1, 4) )
        local m = tonumber( string.sub(timeStr , 5, 6) )
        local d = tonumber( string.sub(timeStr , 7) )

        return Time.time({year = y , month = m , day = d , hour = 0 , min = 0 , sec = 0})
    else
        return 0
    end
end

--四舍五入
function GlobalApi:roundOff(num, n)
    if n > 0 then
        local scale = math.pow(10, n-1)
        return math.floor(num / scale + 0.5) * scale
    elseif n < 0 then
        local scale = math.pow(10, n)
        return math.floor(num / scale + 0.5) * scale
    elseif n == 0 then
        return num
    end
end

-- format time to Easy Time
function GlobalApi:toEasyTime(tt)
    local dt = GlobalData:getServerTime() - tt
    if dt < 60 then
        return GlobalApi:getLocalStr('JUST_NOW')
    elseif dt < 60 * 60 then
        return string.format(GlobalApi:getLocalStr('MINUTE_AGO'), dt / 60)
    elseif dt < 60 * 60 * 24 then
        return string.format(GlobalApi:getLocalStr('HOUR_AGO'), dt / (60 * 60))
    elseif dt < 60 * 60 * 24 * 6 then
        return string.format(GlobalApi:getLocalStr('DAY_AGO'), dt / (60 * 60 * 24))
    else
        return GlobalApi:getLocalStr('A_WEEK_AGO')
    end
end

-- format time to String Time
-- ty ===== type
-- t ===== time
-- type 1 时间戳
--      2 剩余时间
function GlobalApi:toStringTime(t, tp ,timetype)
    timetype = timetype or 1
    -- y年m月d日
    if timetype == 1 then
        if tp == 'YMD' then
            return Time.date(GlobalApi:getLocalStr('YY_MM_DD'), t)
        -- h:m:s
        elseif tp == 'HMS' then
            return Time.date(GlobalApi:getLocalStr('HH_MM_SS'), t)
        elseif tp == 'HM' then
            return Time.date(GlobalApi:getLocalStr('HH_MM'), t)
        elseif tp == 'H' then
            return Time.date(GlobalApi:getLocalStr('HH'), t)
        end
    else
        local hour = 0
        local min = 0
        local second = 0
        local day = 0
        hour = math.floor(t/3600)
        min = math.floor((t%3600)/60)
        second = math.floor(t%60)
        day = math.floor(t/86400)
        if tp == 'HMS' then
            return string.format(GlobalApi:getLocalStr('STR_TIME3'),hour,min,second)
        elseif tp == 'HM' then
            return string.format(GlobalApi:getLocalStr('STR_TIME4'),hour,min)
        elseif tp == "D" then
            return string.format(GlobalApi:getLocalStr('STR_TIME6'),day)
        end       
    end
    return nil
end

-- left widget, edit box, right widget, min number, max number
function GlobalApi:genNumberEditor(l, b, r, min, max, func)
    local addFunc = function (  )
        local num = 0
        if b.getText ~= nil then
            num = tonumber(b:getText())
        elseif b.getString ~= nil then
            num = tonumber(b:getString())
        else
            print('WTF .. getText && getString == nil???')
        end
        if num < max then
            num = num + 1
            if b.setText ~= nil then
                b:setText(tostring(num))
            elseif b.setString ~= nil then
                b:setString(tostring(num))
            else
                print('WTf .. setText && setString == nil???')
            end
        end
        if func ~= nil then
            func()
        end
    end

    local decFunc = function (  )
        local num = 0
        if b.getText ~= nil then
            num = tonumber(b:getText())
        elseif b.getString ~= nil then
            num = tonumber(b:getString())
        else
            print('WTF .. getText && getString == nil???')
        end
        if num > min then
            num = num - 1
            if b.setText ~= nil then
                b:setText(tostring(num))
            elseif b.setString ~= nil then
                b:setString(tostring(num))
            else
                print('WTf .. setText && setString == nil???')
            end
        end
        if func ~= nil then
            func()
        end
    end

    local intervalTime = 0
    if l then
        l:addTouchEventListener(function ( sender, eventType )
            -- num--
            print('left button pressed ...')
            if eventType == ccui.TouchEventType.began then
                decFunc()
                AudioMgr.PlayAudio(11)
                b:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function (  )
                    b:scheduleUpdateWithPriorityLua(function (dt)
                        intervalTime = intervalTime + dt
                        if intervalTime > 0.1 then
                            intervalTime = 0
                            decFunc()
                        end
                    end, 0)
                end)))
            elseif eventType == ccui.TouchEventType.ended then
                intervalTime = 0
                b:unscheduleUpdate()
                b:stopAllActions()
            elseif eventType == ccui.TouchEventType.canceled then
                intervalTime = 0
                b:unscheduleUpdate()
                b:stopAllActions()
            end
        end)
    end

    if r then
        r:addTouchEventListener(function ( sender, eventType )
            -- num++
            print('right button pressed ...')
            if eventType == ccui.TouchEventType.began then
                addFunc()
                AudioMgr.PlayAudio(11)
                b:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function (  )
                    b:scheduleUpdateWithPriorityLua(function (dt)
                        intervalTime = intervalTime + dt
                        if intervalTime > 0.1 then
                            intervalTime = 0
                            addFunc()
                        end
                    end, 0)
                end)))
            elseif eventType == ccui.TouchEventType.ended then
                intervalTime = 0
                b:unscheduleUpdate()
                b:stopAllActions()
            elseif eventType == ccui.TouchEventType.canceled then
                intervalTime = 0
                b:unscheduleUpdate()
                b:stopAllActions()
            end
        end)
    end
    return b:getText()
end

function GlobalApi:getLabelCustomShadow(shadowType)
    if shadowType == ENABLESHADOW_TYPE.NORMAL then
        return cc.c4b(64,64,64, 255), cc.size(0, -1), 0
    elseif shadowType == ENABLESHADOW_TYPE.TITLE then
        return cc.c4b(78,49,17, 255), cc.size(0, -1), 0
    elseif shadowType == ENABLESHADOW_TYPE.FIGHTFORCE then
        return cc.c4b(64,64,64, 255), cc.size(0, -2), 0
    elseif shadowType == ENABLESHADOW_TYPE.BUTTON then
        return cc.c4b(25,25,25, 255), cc.size(0, -1), 0
    elseif shadowType == ENABLESHADOW_TYPE.BROWN then
        return cc.c4b(0,0,0, 0), cc.size(0, 0), 0
    elseif shadowType == ENABLESHADOW_TYPE.WHITE then
        return cc.c4b(255,255,255,255), cc.size(0, -1), 0
    elseif shadowType == ENABLESHADOW_TYPE.RED then
        return cc.c4b(255,30,0, 255), cc.size(0, -1), 0
    elseif shadowType == ENABLESHADOW_TYPE.YELLOW then
        return cc.c4b(254,165,0, 255), cc.size(0, -1), 0
    else
        return cc.c4b(64,64,64, 255), cc.size(0, -1), 0
    end
end

function GlobalApi:secondTransformationToHHMMSS(time)
    local hour = 0
    local min = 0
    local second = 0
    hour = math.floor(time/3600)
    min = math.floor((time-hour*3600)/60)
    second = math.floor(time%60)
    return hour,min,second
end

-- bg 滑动背景
-- cards 卡片的控件数组
-- pos 当前的卡片id
-- leftNum 坐标卡片数量
-- rightNum 右边卡片数量
-- maxLenght 滑动快慢，跟卡片坐标距离一样，滑动为1:1
-- notHideLastOne 是否隐藏层级最低的卡片
-- small 最小的卡片
-- callback 卡片位置更新后需要刷新的回调
function GlobalApi:setCardRunRound(bg,cards,pos,leftNum,rightNum,maxLenght,notHideLastOne,small,scaleTab,callback,allPos,clickCallback,allScales,shades)
    local pl = bg
    local imgs = cards
    local POS = {}
    local MAX_NUM = #imgs
    local MAX_LENGTH = maxLenght
    local LEFT_NUM = leftNum
    local RIGHT_NUM = rightNum
    local sPer = 0
    self.cardPos = pos
    local currPos1 = pos
    local isMove = false
    local left = true
    local smallOne = small
    local maxNum = leftNum + rightNum + 1
    local isNotHideLastOne = ((notHideLastOne == nil) and true) or notHideLastOne
    if allPos then
        POS = allPos
    else
        for i,v in ipairs(imgs) do
            POS[i] = cc.p(v:getPositionX(),v:getPositionY())
        end
    end
    local scales = scaleTab or {1,0.9,0.8}
    local shades = shades or {255,175,95}
    local allScales = allScales

    local function setImgsPosition(isMove,isCallback)
        local leftPos = (self.cardPos - LEFT_NUM - 1)%MAX_NUM + 1
        local rightPos = (self.cardPos - 1 + RIGHT_NUM)%MAX_NUM + 1
        for i=1, MAX_NUM do
            local index = (i-self.cardPos)%MAX_NUM + 1
            
            -- imgs[i]:setOpacity(((index == 1)and 255) or 80)
            imgs[i]:setLocalZOrder(maxNum + 1 - index)
            -- if index == smallOne then
            --     imgs[i]:setLocalZOrder(0)
            -- end

            if index == 1 then
                -- imgs[i]:setSwallowTouches(true)
                imgs[i]:setSwallowTouches(false)        --AD修改：现在可以一直接滑动
                imgs[i]:setScale(scales[1])
                imgs[i]:setOpacity(shades[1])
            elseif index == smallOne then
                imgs[i]:setScale(scales[3])
                imgs[i]:setOpacity(shades[3])
                imgs[i]:setLocalZOrder(0)
                imgs[i]:setSwallowTouches(false)
            else
                imgs[i]:setScale(scales[2])
                imgs[i]:setOpacity(shades[2])
                imgs[i]:setSwallowTouches(false)
            end

            if allScales then
                imgs[i]:setScale(allScales[index])
            end

            if isMove then
                imgs[i]:stopAllActions()
                local posX,posY = imgs[i]:getPositionX(),imgs[i]:getPositionY()
                local time = math.abs(posX - POS[index].x)/1000
                imgs[i]:runAction(cc.Sequence:create(cc.MoveTo:create(0.1,POS[index]),cc.CallFunc:create(function()
                    imgs[i]:setVisible(true)
                end)))
            else
                imgs[i]:setPosition(POS[index])
            end
        end
        if not isCallback then
            if callback then
                callback(self.cardPos)
            end
        end
    end

    local touchImgIdx = -1
    local function registerCardHandler()
        for i,v in ipairs(imgs) do
            v:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                    if touchImgIdx == -1 then
                        touchImgIdx = i
                    end
                elseif eventType == ccui.TouchEventType.ended then
                    if touchImgIdx ~= i then
                        return
                    end
                    local point1 = sender:getTouchBeganPosition()
                    local point2 = sender:getTouchEndPosition()
                    local dis =cc.pGetDistance(point1,point2)
                    if dis <= 10 then
                        if self.cardPos == i then
                            if clickCallback then
                                clickCallback()
                            end
                        else
                            self.cardPos = i
                            -- 点击卡片触发pl的began事件，但是不会触发ended事件，点击其他任意地方会触发ended事件
                            -- 切换卡片后点第一次选择难度正常，然后会触发ended事件，导致self.cardPos又被重置了，点击无效
                            self.isChangePos = true
                            setImgsPosition(true)
                        end
                    end
                    touchImgIdx = -1
                elseif eventType == ccui.TouchEventType.canceled then
                    touchImgIdx = -1
                end
            end)
        end
    end

    local function getMove(index,bgPanelPos,bgPanelPrePos)
        local bgPanelDiffPos = nil
        local isEnd = false
        local diffPosX = (bgPanelPos.x - bgPanelPrePos.x)/2
        local per = math.abs(diffPosX/MAX_LENGTH)
        local per1
        local lePosX,lePosY,sPosX,sPosY,cPosX,cPosY,rePosX,rePosY
        local startIndex = (index-self.cardPos)%MAX_NUM + 1
        local lEndIndex = (index-self.cardPos - 1)%MAX_NUM + 1
        local rEndIndex = (index-self.cardPos + 1)%MAX_NUM + 1

        lePosX = POS[lEndIndex].x
        lePosY = POS[lEndIndex].y
        rePosX = POS[rEndIndex].x
        rePosY = POS[rEndIndex].y
        sPosX = POS[startIndex].x
        sPosY = POS[startIndex].y
        cPosX = imgs[index]:getPositionX()
        cPosY = imgs[index]:getPositionY()
        local isBig
        local diffPosX1
        local diffPosY1
        if cPosX < sPosX then
            -- left = true
            if diffPosX < 0 then
                bgPanelDiffPos = cc.p(per*(lePosX - sPosX),per*(lePosY - sPosY))
            else
                bgPanelDiffPos = cc.p(per*(sPosX - lePosX),per*(sPosY - lePosY))
            end
            isBig = self.cardPos%MAX_NUM + 1
            diffPosX1 = lePosX - sPosX
            diffPosY1 = lePosY - sPosY
        elseif cPosX > sPosX then
            -- left = false
            if diffPosX < 0 then
                bgPanelDiffPos = cc.p(per*(sPosX - rePosX),per*(sPosY - rePosY))
            else
                bgPanelDiffPos = cc.p(per*(rePosX - sPosX),per*(rePosY - sPosY))
            end
            isBig = (self.cardPos - 2)%MAX_NUM + 1
            diffPosX1 = rePosX - sPosX
            diffPosY1 = rePosY - sPosY
        else
            if diffPosX < 0 then
                bgPanelDiffPos = cc.p(per*(lePosX - sPosX),per*(lePosY - sPosY))
                isBig = self.cardPos%MAX_NUM + 1
                diffPosX1 = lePosX - sPosX
                diffPosY1 = lePosY - sPosY
            else
                bgPanelDiffPos = cc.p(per*(rePosX - sPosX),per*(rePosY - sPosY))
                isBig = (self.cardPos - 2)%MAX_NUM + 1
                diffPosX1 = rePosX - sPosX
                diffPosY1 = lePosY - sPosY
            end
        end
        local pos = cc.pAdd(cc.p(cPosX,cPosY),bgPanelDiffPos)
        if startIndex == 1 then
            left = cPosX <= sPosX
            sPer = (pos.x - sPosX)/diffPosX1
        end
        if left == true then
            pos = cc.p((lePosX - sPosX)*sPer + sPosX,sPer*(lePosY - sPosY) + sPosY)
        else
            pos = cc.p((rePosX - sPosX)*sPer + sPosX,sPer*(rePosY - sPosY) + sPosY)
        end

        local diffLendX = pos.x - lePosX
        local diffLharfEndX = pos.x - ((lePosX + sPosX)/2)
        local diffRendX = pos.x - rePosX
        local diffRharfEndX = pos.x - ((rePosX + sPosX)/2)
        local diffStartX = pos.x - sPosX
        local per1 = math.abs((pos.x - sPosX)/diffPosX1)
        local bCanMove = false
        if startIndex == 1 then
            if math.abs(diffStartX) > 0 and isMove == false then
                isMove = true
            end
            if (diffLendX >= 0 and diffRendX <= 0) then
                isEnd = false
            elseif diffLendX < 0 then
                self.cardPos = self.cardPos%MAX_NUM + 1
                isEnd = true
            elseif diffRendX > 0 then
                self.cardPos = (self.cardPos - 2)%MAX_NUM + 1
                isEnd = true
            end
            if isEnd == false then
                if diffLharfEndX < 0 then
                    currPos1 = self.cardPos%MAX_NUM + 1
                elseif diffRharfEndX > 0 then
                    currPos1 = (self.cardPos - 2)%MAX_NUM + 1
                else
                    currPos1 = self.cardPos
                end
            end
        end
        return isEnd,pos
    end

    local function registerHandler()
        -- imgs = {}
        -- sPer = 0
        for i = 1,MAX_NUM do
            -- local flag = pl:getChildByName("flag_" .. i)
            -- imgs[i] = flag
            -- imgs[i]:setScale(((i == 1)and 1) or 0.7)
            -- imgs[i]:setOpacity(((i == 1)and 255) or 80)
            if i == 1 then
                imgs[i]:setScale(scales[1])
                imgs[i]:setOpacity(shades[1])
            elseif i == smallOne then
                imgs[i]:setScale(scales[3])
                imgs[i]:setOpacity(shades[3])
            else
                imgs[i]:setScale(scales[2])
                imgs[i]:setOpacity(shades[2])
            end
        end
        local bgPanelPrePos = nil
        local bgPanelPos = nil
        isMove = false
        pl:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.moved then
                bgPanelPrePos = bgPanelPos
                bgPanelPos = sender:getTouchMovePosition()
                if bgPanelPrePos then
                    local isEnd = getMove(self.cardPos,bgPanelPos,bgPanelPrePos)
                    if isEnd == false then
                        local leftPos = (self.cardPos - LEFT_NUM - 1)%MAX_NUM + 1
                        local rightPos = (self.cardPos - 1 + RIGHT_NUM)%MAX_NUM + 1
                        local leftOne = (self.cardPos - 2)%MAX_NUM + 1
                        local rightOne = self.cardPos%MAX_NUM + 1
                        imgs[leftPos]:setVisible(isNotHideLastOne or (left ~= true))
                        imgs[rightPos]:setVisible(isNotHideLastOne or (left == true))
                        for i=1, MAX_NUM do
                            local scale = 0.7
                            local shade = 80
                            local startIndex = (i-self.cardPos)%MAX_NUM + 1
                            local lEndIndex = (i-self.cardPos - 1)%MAX_NUM + 1
                            local rEndIndex = (i-self.cardPos + 1)%MAX_NUM + 1
                            if startIndex == 1 then
                                scale = scales[1]
                                shade = shades[1]
                            elseif startIndex == smallOne then
                                scale = scales[3]
                                shade = shades[3]
                            else
                                scale = scales[2]
                                shade = shades[2]
                            end

                            if i == self.cardPos then
                                scale = 1 - math.abs(sPer)*(scales[1] - scales[2])
                                shade = shades[1] - math.abs(sPer)*(shades[1] - shades[2])
                            elseif (left == true and i == rightOne) or (left ~= true and i == leftOne) then
                                scale = scale + math.abs(sPer)*(scales[1] - scales[2])
                                shade = shade + math.abs(sPer)*(shades[1] - shades[2])
                            elseif (left == true and lEndIndex == smallOne) or (left ~= true and rEndIndex == smallOne) then
                                scale = scale - math.abs(sPer)*(scales[2] - scales[3])
                                shade = shade - math.abs(sPer)*(shades[2] - shades[3])
                            elseif startIndex == smallOne then
                                scale = scale + math.abs(sPer)*(scales[2] - scales[3])
                                shade = shade + math.abs(sPer)*(shades[2] - shades[3])
                            end

                            local _,pos = getMove(i,bgPanelPos,bgPanelPrePos)
                            if left == true then
                                imgs[i]:setLocalZOrder(maxNum + 1 - startIndex)
                                if currPos1 ~= self.cardPos then
                                    imgs[self.cardPos]:setLocalZOrder(maxNum - 2)
                                    if lEndIndex == smallOne then
                                        imgs[i]:setLocalZOrder(0)
                                    end
                                else
                                    if startIndex == smallOne then
                                        imgs[i]:setLocalZOrder(0)
                                    end
                                end
                            else
                                imgs[i]:setLocalZOrder((startIndex - 2)%maxNum + 1)
                                if currPos1 ~= self.cardPos then
                                    imgs[self.cardPos]:setLocalZOrder(maxNum - 2)
                                    if rEndIndex == smallOne then
                                        imgs[i]:setLocalZOrder(0)
                                    end
                                else
                                    if startIndex == smallOne then
                                        imgs[i]:setLocalZOrder(0)
                                    end
                                end
                            end
                            imgs[i]:setPosition(pos)
                            imgs[i]:setScale(scale)
                            imgs[i]:setOpacity(shade)
                        end
                    else
                        bgPanelPrePos = nil
                        setImgsPosition()
                        --updatePanel()
                    end
                end
            else
                bgPanelPrePos = nil
                bgPanelPos = nil
                if eventType == ccui.TouchEventType.began then
                    currPos1 = self.cardPos
                else
                    if not self.isChangePos then
                        self.cardPos = currPos1
                        if isMove == true then
                            -- self.cardPos = currPos1
                            setImgsPosition(true)
                            --updatePanel()
                        end
                        isMove = false
                        local beginPos = sender:getTouchBeganPosition()
                        local endPos = sender:getTouchEndPosition()
                        if math.abs(endPos.x - beginPos.x) < 10 then
                            -- if clickCallback then
                            --     clickCallback()
                            -- end
                        end
                    end
                    self.isChangePos = false
                end
            end
        end)
    end

    registerHandler()
    registerCardHandler()
    setImgsPosition(false,true)
end

function GlobalApi:getOpenInfo(key)
    local conf = GameData:getConfData('moduleopen')[key]
    if not conf then
        return false,true
    end
    local currProgress = MapData:getFightedCityId()
    if not MapData.data[conf.cityId] then
        return false,nil,conf.cityId
    end
    local isFirst = MapData.data[conf.cityId]:getBfirst()
    local level = UserData:getUserObj():getLv()
    if currProgress >= conf.cityId and (conf.cityId == 0 or isFirst ~= true) then
        if level >= conf.level then
            return true
        else
            return false,nil,nil,conf.level
        end
    else
        return false,nil,conf.cityId
    end
    -- return 1,nil,conf.cityId
end

-- stype 为true 开启返回空，未开启返回描述 false或者不存在 直接前往功能
-- ntype 前往功能需要的参数
function GlobalApi:getGotoByModule(key,stype,ntype)
    local isOpen,isNotIn,id,level = self:getOpenInfo(key)
    local str = ''
    local cityData = MapData.data[id]
    local desc = ''
    local errCode = 0
    if level then
        str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),level)
        desc = level
        errCode = 2
    elseif cityData then
        desc = cityData:getName()
        str = string.format(GlobalApi:getLocalStr('FUNCTION_OPEN_NEED'),cityData:getName())
        errCode = 1
    else
        str = GlobalApi:getLocalStr('FUNCTION_NOT_OPEN')
    end
    if stype then
        if isOpen or isNotIn then
            return
        else
            return desc,errCode
        end
    end
    if not isOpen and not isNotIn then
        promptmgr:showSystenHint(str, COLOR_TYPE.RED)
        return
    end
    local functions = {
        -- 武将
        ['hero'] = function()RoleMgr:showRoleMain(1,ntype)end,
        ['reborn'] = function()RoleMgr:showRoleMain(1,2)end,
        ['heroList'] = function()RoleMgr:showRoleList(ntype)end,
        ['roleQuality'] = function()RoleMgr:showRoleMain(1)end,
        ['equipStar'] = function()RoleMgr:showRoleMain(1)end,
        ['soldierLevel'] = function()RoleMgr:showRoleMain(1)end,
        ['roleReborn'] = function()RoleMgr:showRoleMain(1)end,
        ['destiny'] = function()RoleMgr:showRoleMain(1,5)end,
        ['heroLv'] = function()
            local maxfight = 0
            local roleMap = RoleData:getRoleMap()
            local pos
            for i=2,#roleMap do
                local fightforce = roleMap[i]:getFightForce()
                if fightforce and fightforce >= maxfight then
                    maxfight = fightforce
                    pos = i
                end
            end
            if not pos then
                RoleMgr:showRoleMain(1,1)
            end
            local roleObj  = RoleData:getRoleByPos(pos)
            if roleObj and roleObj:getId() > 0 then
                RoleMgr:showRoleMain(pos,9)
            else
               RoleMgr:showRoleMain(1,1) 
            end
        end,
        --套装界面
        ['suit'] = function() 
            local roleObj = RoleData:getRoleByPos(1)
            if roleObj then
                RoleMgr:showSuit(roleObj:getPosId(),ntype) 
            end
        end,
        ['refine'] = function()
            local roleObj = RoleData:getRoleByPos(1)
            if roleObj then
                RoleMgr:showSuit(roleObj:getPosId(),4) 
            end
        end,
        
        ['promote']= function()RoleMgr:showRoleList(ntype)end,

        -- 大地图
        ['tribute'] = function()
            MapMgr:showTributePanel()
        end,
        ['battle'] = function()
            MapMgr.locatePage = 1
            MapMgr:showMainScene(2,nil,function()
                MapMgr:showExpeditionPanel(nil,1)
            end)
        end,
        ['elite'] = function()
            MapMgr.locatePage = 2
            local eliteId = MapData:getCanFighttingIdByPage(2)
            MapMgr:showMainScene(2,eliteId,function()
                MapMgr:showExpeditionPanel(eliteId,2)
            end)
        end,
        ['level'] = function()
            MapMgr.locatePage = 1
            MapMgr:showMainScene(2)
        end,
        ['battleFight'] = function()
            MapMgr.locatePage = 1
            MapMgr:showMainScene(2)
        end,
        ['thief'] = function()
            MapMgr.locatePage = 1
            MapMgr:showMainScene(2)
        end,

        ['combat'] = function()
            if type(ntype) == 'table' then
                MapMgr:showMainScene(2,ntype[1],function()
                    MapMgr:showCombatPanel(ntype[1],ntype[2])
                end)
            else
                MapMgr:showCombatPanel(ntype)
            end
        end,
        ['lord'] = function()
            if not ntype then
                MapMgr:showMainScene(2,nil,function()
                    MapMgr:showPrefecturePanel()
                end)
            elseif type(ntype) == 'table' then
                MapMgr:showMainScene(2,ntype[1],function()
                    MapMgr:showPrefecturePanel(ntype[1])
                end)
            else
                MapMgr:showPrefecturePanel(ntype)
            end
        end,
        ['expedition'] = function()
            if type(ntype) == 'table' then
                MapMgr.locatePage = ntype[2]
                MapMgr:showMainScene(2,ntype[1],function()
                    MapMgr:showExpeditionPanel(ntype[1],ntype[2],ntype[3],ntype[4])
                end)
            else
                MapMgr:showExpeditionPanel(ntype)
            end
        end,
        -- 擂台
        ['arenaVictory'] = function()ArenaMgr:showArenaV2()end,
        ['arenaRank'] = function()ArenaMgr:showArenaV2()end,
        ['arena'] = function()ArenaMgr:showArenaV2()end,
        -- 金矿
        ['goldmine'] = function()GoldmineMgr:showGoldmine()end,
        ['goldmine_enter'] = function()GoldmineMgr:showMineEntrance()end,
        ['mineRob'] = function()GoldmineMgr:showGoldmine()end,
        ['mine'] = function()GoldmineMgr:showGoldmine()end,
        -- 铁匠铺
        ['blacksmith'] = function()BagMgr:showFusion()end,
        ['equipSmelt'] = function()BagMgr:showFusion()end,
        ['autofunsion'] = function()BagMgr:showAutoFusion()end,
        -- 军团
        ['legion'] = function()
            local lid = UserData:getUserObj().lid
            if lid and lid ~= 0 then
                if ntype == 51 or ntype == 52 or ntype == 53 or ntype == 54 then
                    MainSceneMgr:showShop(ntype,{min = 51,max = 54})
                else
                    LegionMgr:showMainUI()
                end
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
            end
        end,
        ['legionMember'] = function()LegionMgr:showMainUI()end,
        ['legionTrial'] = function() 
            local lid = UserData:getUserObj().lid
            if lid and lid ~= 0 then
                LegionTrialMgr:showLegionTrialMainPannelUI() 
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('GUARD_DESC25'), COLOR_TYPE.RED)
            end
        end,
        -- 商店
        ['shop'] = function()
            if ntype then
                if ntype == 11 or ntype == 12 or ntype == 13 then
                    MainSceneMgr:showShop(ntype,{min = 11,max = 13})
                end
            else
                MainSceneMgr:showMainShop()
            end
        end,
        ['shopBuy'] = function()MainSceneMgr:showMainShop()end,
        -- 挂机
        ['hook'] = function()MapMgr:showPatrolPanel()end,
        ['patrolAccelerate'] = function()MapMgr:showPatrolPanel()end,
        -- 酒馆
        ['pub'] = function()
			local isOpen2,isNotIn2,id2,level2 = self:getOpenInfo('exclusive_check')
			if isOpen2 then
				ExclusiveMgr:showExclusiveRecruitEntranceUI()
			else
				TavernMgr:showTavernMain()
			end
        end,
        ['tavern'] = function()TavernMgr:showTavernMain()end,
        -- 千层塔
        ['tower'] = function()
            if not ntype then
                TowerMgr:showTowerMain()
            elseif ntype == 1 then
                TowerMgr:showTowerMain('shop1')
                -- MainSceneMgr:showShop(22,{min = 21,max = 22},0)
            end
        end,
        -- 邮箱
        ['mail'] = function()MainSceneMgr:showEmail()end,
        -- 宝物
        ['treasure'] = function()MainSceneMgr:showTreasure()end,
        ['digging'] = function()DigMineMgr:showDigMine()end,
        ['dragongem'] = function()
            local skillsTab = UserData:getUserObj():getSkills()
            local id
            for i=1,5 do
                if skillsTab[tostring(i)].id and skillsTab[tostring(i)].id > 1 then
                    id = skillsTab[tostring(i)].id
                    break;
                end 
            end
            if id then
                MainSceneMgr:showInlayDragonGemUI(id)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'), COLOR_TYPE.RED) 
            end
        end,
        --背包
        ['bag'] = function()BagMgr:showBag()end,
        -- 任务
        ['task'] = function()MainSceneMgr:showTaskNewUI()end,
        -- 国家
        ['country'] = function()CountryMgr:showCountryMain()end,
        ['citycraft'] = function()
            local countryId = UserData:getUserObj():getCountry()
            if countryId > 0 then
                CityCraftMgr:showCityCraft()
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'), COLOR_TYPE.RED)
            end
        end,
        ['countryJade'] = function()
            local countryId = UserData:getUserObj():getCountry()
            if countryId > 0 then
                CountryJadeMgr:showMyOwnCountryJadeMainUI()
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES16'), COLOR_TYPE.RED)
            end
        end,
        -- 玉玺
        ['jadeSeal'] = function()MainSceneMgr:showJadesealUI()end,
        -- 训练馆
        ['train'] = function()TrainingMgr:showTrainingMain()end,
        ['training'] = function()TrainingMgr:showTrainingMain()end,
        -- 活动副本
        ['boat'] = function()CampaignMgr:showCampaignMain()end,
        ['xpRescopy'] = function()CampaignMgr:showCampaignMain(1,2)end,
        ['rebornRescopy'] = function()CampaignMgr:showCampaignMain(1,1)end,
        ['goldRescopy'] = function()CampaignMgr:showCampaignMain(1,3)end,
        ['destinyRescopy'] = function()CampaignMgr:showCampaignMain(1,4)end,
        -- 战役
        -- ['infinite'] = function()
        --         local chapterId = UserData:getUserObj():getInfinite().chapter_id
        --         CampaignMgr:showCampaignMain(4,chapterId)
        --     end,
        ['infinite_battle'] = function()InfiniteBattleMgr:showInfiniteBattleMain(ntype)end,
        -- 运镖
        ['shipper'] = function()ShippersMgr:showShippersMain()end,
        -- 巡逻
        ['patrol'] = function()GuardMgr:showGuardMap()end,
        -- 祭坛
        ['altar'] = function()MainSceneMgr:showAltar(ntype)end,
        -- 群雄争霸
        ['worldwar'] = function()WorldWarMgr:showWorldWar()end,
        -- 排行榜
        ['list'] = function()HonorHallMgr:showUI()end,
        ['statue'] = function()
                UserData:getUserObj().statueStatus = false
                HonorHallMgr:showUI()
            end,
        -- 资源
        ['cash'] = function()RechargeMgr:showRecharge()end,
        ['gold'] = function()MainSceneMgr:showAltar(1)end,
        ['food'] = function()MainSceneMgr:showAltar(2)end,
        ['destinyFete'] = function()MainSceneMgr:showAltar(4)end,
        -- 月卡
        ['monthCard'] = function()RechargeMgr:showRecharge()end,
        ['longCard'] = function()RechargeMgr:showRecharge()end,

        --行动力
        ['action_point'] = function()TerritorialWarMgr:showMsgUI(2) end,

        ['friend'] = function()FriendsMgr:showFriendsMain()end,
        ['pokedex'] = function()ChartMgr:showChartMain()end,
        ['report'] = function()BattleMgr:showTotalBattleReport(1)end,
        ['weapon'] = function()PeopleKingMgr:showPeopleKingMainUI(1)end,
        ['exclusive'] = function()ExclusiveMgr:showExclusiveMainUI()end,
        -- 鉴宝
        ['exclusive_check'] = function()ExclusiveMgr:showExclusiveCheckMainUI()end,
		-- 宝物重铸
        ['exclusive_recast'] = function()ExclusiveMgr:showExclusiveMainUI(4)end,

    }
    if functions[key] then
        print(key)
        functions[key]()
    else
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FUNCTION_NOT_OPEN'), COLOR_TYPE.RED)
    end
end

-- stype 为true 开启返回空，未开启返回描述 false或者不存在 直接前往功能
-- ntype 前往功能需要的参数
function GlobalApi:getGotoLegionModule(key,sType)
    
    if not key then
        return
    end

    local errStr
    local conf = GameData:getConfData("legion")
    local limitLv = tonumber(conf[key].value)
    local llevel = tonumber(UserData:getUserObj():getLLevel())
          llevel = llevel and llevel or 0

    local lid = UserData:getUserObj().lid
    if not lid or lid == 0 then
       errStr = GlobalApi:getLocalStr('LEGION_JION')
    else
        if llevel < limitLv then
            errStr = string.format(GlobalApi:getLocalStr('MILITARY_DESC_20'),limitLv)
        end   
    end

    if sType then
        return errStr
    end

    local functions = {

        ['leigionWishOpenLevel'] = function()
            LegionWishMgr:showLegionWishGiveMainPanelUI()
        end,

        ['legionBuild'] = function()
            LegionMgr:showMainUI(function() LegionMgr:showLegionDonateUI() end)
        end,
        ['legionMercenaryOpenLevel'] = function()      
            LegionMgr:showMainUI(function() 
                local legionData = UserData:getUserObj():getLegionData()
                LegionMgr:showLegionActivityMercenaryUI(legionData) 
            end)
        end,
        ['legionTrialOpenLevel'] = function()
            LegionMgr:showLegionActivityTrialUI()
        end,

        ['legionWarMinJoinLevel'] = function()  --军团战
            LegionMgr:showLegionWarMainUI()
        end,

        ['legionGoldTreeOpenLevel'] = function()
            LegionMgr:showMainUI(function() 
                local legionData = UserData:getUserObj():getLegionData()
                LegionMgr:showLegionActivityShakeUI(legionData)
             end)
        end,
        ['legionDfOpenLevel'] = function()  --领地boss
            local step = UserData:getUserObj():getMark().step or {}
            if step[tostring(GUIDE_ONCE.TERRITORIAL_WARS)] then
                TerritorialWarMgr:shoWarBossListUI()
                
            else
                TerritorialWarMgr:showMapUI()
            end
        end,
        ['legionCopyOpenLevel'] = function()
            LegionMgr:showLegionLevelsMainUI()
        end,
    }
    if functions[key] then
        functions[key]()
    end
end

function GlobalApi:RandomName()
    local nameConf = GameData:getConfData('name')
    math.randomseed(os.clock()*10000)
    local sex = math.random(0,1)
    local firstidx = math.random(1,#nameConf)
    local name = nameConf[firstidx].first
    if sex == 0 then
        local maleidx = math.random(1,#nameConf)
        name = name .. nameConf[maleidx].male
    else
        local femaleidx = math.random(1,#nameConf)
        name = name .. nameConf[femaleidx].female
    end
    return name
end

function GlobalApi:isContainEnglish(str)
    local lenInByte = #str
    local flag = false
    for i = 1, lenInByte do
        if string.byte(str, i) <= 127 then
            flag = true
            break
        end
    end
    return flag
end

cc.bit={data32={}}
for i=1,32 do
	bit.data32[i] = 2^(32-i)
end

function bit:d2b(arg)
	local tr={}
	for i=1,32 do
		if arg >= self.data32[i] then
			tr[i] = 1
			arg = arg - self.data32[i]
		else
			tr[i]=0		
		end
	end
	return tr
end

function bit:b2d(arg)
	local nr=0
	for i=1,32 do
		if arg[i] == 1 then
			nr = nr + 2^(32-i)
		end
	end
	return nr
end

function bit:_and(a,b)
	local op1=self:d2b(a)
	local op2=self:d2b(b)
	local r={}
	for i=1,32 do
		if op1[i] == 1 and op2[i]==1 then
			r[i]=1
		else
			r[i]=0
		end
	end
	return self:b2d(r)
end

function bit:_or(a,b)
	local op1=self:d2b(a)
	local op2=self:d2b(b)
	local r={}
	for i=1,32 do
		if op1[i]==1 or op2[i]==1 then
			r[i]=1
		else
			r[i]=0
		end
	end
	return self:b2d(r)
end

function bit:_rshift(a,n)
	if n==0 then
		return a
	end
	local op1=self:d2b(a)
	local r=self:d2b(0)
	if n<32 and n>0 then
		for i=1,n do
			for i=31,1,-1 do
				op1[i+1]=op1[i]
			end
			op1[1]=0
		end
	r=op1
	end
	return self:b2d(r)
end


function bit:_lshift(a,n)
	if n==0 then
		return a
	end
	local op1=self:d2b(a)
	local r=self:d2b(0)
	if n<32 and n>0 then
		for i=1,n do
			for i=1,31 do
				op1[i]=op1[i+1]
			end
			op1[32]=0
		end
		r=op1
	end
	return self:b2d(r)
end

function GlobalApi:unicode_to_utf8(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    local hadC = false
    while true do
        local num1=string.byte(convertStr,i)
        local unicode
        if num1~=nil and string.sub(convertStr,i,i+1)=="\\u" then
            unicode=tonumber("0x"..string.sub(convertStr,i+2,i+5))
            i=i+6
        elseif num1~=nil then
            unicode=num1
            i=i+1
        else
            break
        end
        if unicode <= 0x007f then
            resultStr=resultStr..string.char(bit:_and(unicode,0x7f))
        elseif unicode >= 0x0080 and unicode <= 0x07ff then
            resultStr=resultStr..string.char(bit:_or(0xc0,bit:_and(bit:_rshift(unicode,6),0x1f)))
            resultStr=resultStr..string.char(bit:_or(0x80,bit:_and(unicode,0x3f)))
            hadC = true
        elseif unicode >= 0x0800 and unicode <= 0xffff then
            resultStr=resultStr..string.char(bit:_or(0xe0,bit:_and(bit:_rshift(unicode,12),0x0f)))
            resultStr=resultStr..string.char(bit:_or(0x80,bit:_and(bit:_rshift(unicode,6),0x3f)))
            resultStr=resultStr..string.char(bit:_or(0x80,bit:_and(unicode,0x3f)))
            hadC = true
        end
    end
    resultStr=resultStr..'\0'
    return resultStr,hadC
end

function GlobalApi:getAllCharIndex(str,without)
	local colorTab = {}
	local len  = string.len(str)
	local left = len
	local oldLeft = len
	local cnt  = 0
	local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
	while left ~= 0 do
		local tmp = string.byte(str, -left)
		local i = #arr
		while arr[i] do
			if tmp >= arr[i] then
				left = left - i
				break
			end
			i = i - 1
		end
		cnt = cnt + 1
		if without and type(without) == 'table' then
			local out = true
			for k,v in pairs(without) do
				if tmp == v then
					out = false
					break
				end
			end
			if out then
				if oldLeft - left == 1 then
					colorTab[cnt] = true
				end
			end
		else
			if oldLeft - left == 1 then
				colorTab[cnt] = true
			end
		end
		oldLeft = left
	end
	-- printall(colorTab)
	return colorTab
end

function GlobalApi:utf8len(input)
    local len  = string.len(input)
    local left = len  
    local cnt  = 0  
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}  
    while left ~= 0 do  
        local tmp = string.byte(input, -left)  
        local i   = #arr  
        while arr[i] do  
            if tmp >= arr[i] then  
                left = left - i  
                break  
            end  
            i = i - 1  
        end  
        cnt = cnt + 1  
    end  
    return cnt  
end  

function GlobalApi:utf8_to_unicode(convertStr)
    if type(convertStr)~="string" then
        return convertStr
    end
    local resultStr=""
    local i=1
    local num1=string.byte(convertStr,i)
    while num1~=nil do
        local tempVar1,tempVar2
        if num1 >= 0x00 and num1 <= 0x7f then
            tempVar1=num1
            tempVar2=0
        elseif bit:_and(num1,0xe0)== 0xc0 then
            local t1 = 0
            local t2 = 0
            t1 = bit:_and(num1,bit:_rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit:_and(num1,bit:_rshift(0xff,2))
            tempVar1=bit:_or(t2,bit.lshift(bit:_and(t1,bit:_rshift(0xff,6)),6))
            tempVar2=bit:_rshift(t1,2)
        elseif bit:_and(num1,0xf0)== 0xe0 then
            local t1 = 0
            local t2 = 0
            local t3 = 0
            t1 = bit:_and(num1,bit:_rshift(0xff,3))
            i=i+1
            num1=string.byte(convertStr,i)
            t2 = bit:_and(num1,bit:_rshift(0xff,2))
            i=i+1
            num1=string.byte(convertStr,i)
            t3 = bit:_and(num1,bit:_rshift(0xff,2))
            tempVar1=bit:_or(bit.lshift(bit:_and(t2,bit:_rshift(0xff,6)),6),t3)
            tempVar2=bit:_or(bit.lshift(t1,4),bit:_rshift(t2,2))
        end
        if tempVar2 and tempVar1 then
            resultStr=resultStr..string.format("\\u%02x%02x",tempVar2,tempVar1)
        end
        i=i+1
        num1=string.byte(convertStr,i)
    end
    return resultStr
end

function GlobalApi:arrowBtnMove(leftBtn,rightBtn)
    leftBtn:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(2,cc.p(25,0)),
            cc.MoveBy:create(2,cc.p(-25,0))
    )))
    rightBtn:runAction(cc.RepeatForever:create(
        cc.Sequence:create(
            cc.MoveBy:create(2,cc.p(-25,0)),
            cc.MoveBy:create(2,cc.p(25,0))
    )))
end

function GlobalApi:getMouthCannotSignDay()
    local day = 0
    local opentime = UserData:getUserObj():getServerOpenTime()
    --本年
    local curyear = Time.date("%y", GlobalData:getServerTime())%100
    --本月
    local curmonth = Time.date("%m", GlobalData:getServerTime())%100
    --本日
    local curday = Time.date("%d", GlobalData:getServerTime())%100

    --开服年
    local openyear = Time.date("%y", opentime)%100
    --开服月
    local openmonth = Time.date("%m", opentime)%100

    if openyear == curyear and openmonth == curmonth then
        local openday = Time.date("%d", opentime)%100
        day = openday
    else
        day = 0
    end
    return day
end

--返回当前字符实际占用的字符数
function GlobalApi:_subStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1
    if curByte == nil then
        byteCount = 0
    elseif curByte > 240 then
        byteCount = 4
    elseif curByte > 225 then
        byteCount = 3
    elseif curByte > 192 then
        byteCount = 2
    end
    return byteCount
end

function GlobalApi:splitStringToTable(str)
    local t = {}
    local indexs = {}
    local index = 1
    local lastIndex = 1
    repeat
        table.insert(indexs, index)
        lastIndex = self:_subStringGetByteCount(str, index)
        index = index + lastIndex
    until(lastIndex == 0)
    for j = 1, #indexs-1 do
        table.insert(t, string.sub(str, indexs[j], indexs[j+1]-1))
    end
    return t
end

function GlobalApi:initConfuseStr()
    local maxRandomNum = 99999999
    local randomNum = math.random(9999)
    randomNum = tostring(randomNum)
    local diffNum = #tostring(maxRandomNum) - #randomNum
    for i = 1, diffNum do
        randomNum = "f" .. randomNum
    end
    self.confuseStr = "f" .. randomNum .. "msanguo"
    self.confuseNumber = -#self.confuseStr - 1
end

function GlobalApi:fuckAttribute(attNumber)
    return tostring(attNumber) .. self.confuseStr
end

function GlobalApi:defuckAttribute(attr)
    return tonumber(string.sub(attr, 1, self.confuseNumber))
end

function GlobalApi:checkAttribute(attNumberForShow, originAtt)
    if UserData:isVerify() and string.sub(originAtt, 1, self.confuseNumber) ~= tostring(attNumberForShow) then
        self.fuckCheat = true
        self:kickBecauseCheat()
    end
end

function GlobalApi:isCheat()
    return self.fuckCheat
end

function GlobalApi:kickBecauseCheat()
    if self.quitNode == nil then
        SocketMgr:send("trick", "user", {})
        self.quitNode = cc.CSLoader:createNode("csb/quitgame.csb")
        local bgImg = self.quitNode:getChildByName('messagebox_bg_img')
        local messageboxImg = bgImg:getChildByName('messagebox_img')
        local closeBtn = messageboxImg:getChildByName('close_btn')
        closeBtn:setVisible(false)
        local winSize = cc.Director:getInstance():getWinSize()
        bgImg:setScale9Enabled(true)
        bgImg:setContentSize(winSize)
        bgImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
        messageboxImg:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
        local neiBgImg = messageboxImg:getChildByName('nei_bg_img')
        local okBtn1 = neiBgImg:getChildByName('ok_1_btn')
        okBtn1:setVisible(false)
        local okBtn2 = neiBgImg:getChildByName('ok_2_btn')
        local cancelBtn = neiBgImg:getChildByName('cancel_btn')
        cancelBtn:setVisible(false)
        local okTx2 = okBtn2:getChildByName('info_tx')
        okTx2:setString(GlobalApi:getLocalStr("STR_OK2"))
        okBtn2:addClickEventListener(function ()
            cc.Director:getInstance():endToLua()
        end)
        local msg = cc.Label:createWithTTF(GlobalApi:getLocalStr("KICK_BECAUSE_CHEAT"), "font/gamefont.ttf", 25)
        msg:setAnchorPoint(cc.p(0.5, 0.5))
        msg:setPosition(cc.p(262, 216))
        msg:setMaxLineWidth(424)
        msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
        msg:setColor(COLOR_TYPE.ORANGE)
        msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
        msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
        neiBgImg:addChild(msg)
        UIManager:getMainScene():addChild(self.quitNode)
        self.quitNode:setLocalZOrder(888)
    end
end

function GlobalApi:getHeadFrame(headframeid)
    local path = 'uires/ui/common/bg1_alpha.png' 
    if headframeid and headframeid ~= 0 then
        path = GameData:getConfData('settingheadframe')[headframeid].icon
    end
    return path
end

--依据key值查找是否激活该特权(返回是否激活，加成数字)
function GlobalApi:getPrivilegeById(keyName)

    local privilegeId = 0
    local privilegeCfg = GameData:getConfData("nobiltytitle")
    for i=1,#privilegeCfg do
        if keyName == privilegeCfg[i].key then
            privilegeId = i
            break;
        end
    end

    if privilegeId == 0 then
        print("no key name")
        return
    end
    if not UserData:getUserObj() then
        return
    end

    local addValue = UserData:getUserObj():getPrivilege(privilegeId)
    return addValue
end

function GlobalApi:getMaxVip()
    local vipConf = GameData:getConfData("vip")
    local userVip = 0
    for k, v in pairs(vipConf) do
        if userVip < tonumber(k) then
            userVip = tonumber(k)
        end
    end
    return userVip
end

function GlobalApi:popupTips(oldatt, newatt, oldfightforce, newfightforce, extraWidgets)
    local attchange = {}
    local arr1 = {}
    local arr2 = {}
    local attconf = GameData:getConfData('attribute')
    local isnew = true
    local attcount = #attconf
    for i=1, attcount do
        arr1[i] = newatt[i] or 0
        arr2[i] = oldatt[i] or 0
        if arr2[i] - arr1[i] ~= 0 then
            isnew = false
        end
    end
    local showWidgets = {}
    if not isnew then
        for i = 1, attcount do
            attchange[i] = arr1[i] - arr2[i]
            local desc = attconf[i].desc
            if desc == "0" then
                desc = ''
            end
            if attchange[i] > 0 then
                local str = math.abs(math.floor(attchange[i]))
                local name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' + '.. str..desc
                local color = COLOR_TYPE.GREEN
                if i == 10 then
                    name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' - '.. str..desc
                    color = COLOR_TYPE.RED
                end
                local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
                w:setTextColor(color)
                w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                table.insert(showWidgets, w)
            elseif attchange[i] < 0 then
                local str = math.abs(math.floor(attchange[i]))
                local name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' - '.. str..desc
                local color = COLOR_TYPE.RED
                if i == 10 then
                    name = GlobalApi:getLocalStr('TREASURE_DESC_13').."  "..attconf[i].name ..' + '.. str..desc
                    color = COLOR_TYPE.GREEN
                end
                local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
                w:setTextColor(color)
                w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                table.insert(showWidgets, w)
            end
        end
        if extraWidgets and #extraWidgets > 0 then
            for k, v in ipairs(extraWidgets) do
                table.insert(showWidgets, v)
            end
        end
        if newfightforce - oldfightforce > 0 then
            local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' + '.. math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 26)
            w:setTextColor(cc.c3b(0,252,255))
            w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            table.insert(showWidgets, w)
        elseif newfightforce - oldfightforce < 0 then
            local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('TREASURE_DESC_14').." "..' - '..math.abs(newfightforce - oldfightforce), 'font/gamefont.ttf', 24)
            w:setTextColor(COLOR_TYPE.RED)
            w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
            w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
            table.insert(showWidgets, w)
        end
    else
        if extraWidgets and #extraWidgets > 0 then
            for k, v in ipairs(extraWidgets) do
                table.insert(showWidgets, v)
            end
        end
    end
    if #showWidgets > 0 then
        promptmgr:showAttributeUpdate(showWidgets)
        RoleData:cleanOldAtt()
    end
end

function GlobalApi:setHeroPromoteAction(root,quality)
    local goldframeImg = root:getChildByName('ui_jinjiangtouxiang')
    if quality >= 7 then
        local size = root:getContentSize()
        if not goldframeImg then
            goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
            goldframeImg:setPosition(cc.p(size.width/2,size.height/2))
            goldframeImg:getAnimation():playWithIndex(0, -1, 1)
            goldframeImg:setName('ui_jinjiangtouxiang')
            root:addChild(goldframeImg)
        else
            goldframeImg:setVisible(true)
        end
    else
        if goldframeImg then
            goldframeImg:setVisible(false)
        end
    end
end

function GlobalApi:countDown(root,time,callback)
    local countDownTime = time or 3
    local winSize = cc.Director:getInstance():getVisibleSize()
    local bgImg = ccui.ImageView:create('uires/ui/common/bg1_gray11.png')
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(winSize.width,winSize.height))
    bgImg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    root:addChild(bgImg)
    bgImg:setLocalZOrder(99999)

    local label = cc.LabelBMFont:create()
    label:setFntFile("uires/ui/number/font1_yellownum.fnt")
    label:setString(countDownTime)
    label:setScale(2)
    bgImg:addChild(label)
    label:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
        countDownTime = countDownTime - 1
        label:setString(tostring(countDownTime))
        if countDownTime <= 0 then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
            bgImg:removeFromParent()
            if callback then
                callback()
            end
        end
    end, 1, false)
end

function GlobalApi:setLightEffect(awardBgImg,scale)
    local isNotLight = false
    if scale == 0 then
        isNotLight = true
    end

    if isNotLight then
        local effect = awardBgImg:getChildByName('chip_light')
        if effect then
            effect:setVisible(false)
        end
        return
    end
    local effect = awardBgImg:getChildByName('chip_light')
    local size = awardBgImg:getContentSize()
    if not effect then
        effect = GlobalApi:createLittleLossyAniByName("chip_light")
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('chip_light')
        effect:setVisible(true)
        effect:setPosition(cc.p(size.width/2,size.height/2))
        effect:setScale(scale or 1)
        awardBgImg:addChild(effect)
    else
        effect:setVisible(true)
    end
end

function GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion, dragon)
    local s = {}
    if promote then
        s.advanced = promote
    end
    local skychangeConf = GameData:getConfData("skychange")
    if weapon_illusion and skychangeConf[1][weapon_illusion] then
        s.bones = s.bones or {}
        local boneIds = skychangeConf[1][weapon_illusion].boneId
        for k, v in ipairs(boneIds) do
            table.insert(s.bones, v)
        end

        s.equips = s.equips or {}
        local equipIds = skychangeConf[1][weapon_illusion].equipId
        for k, v in ipairs(equipIds) do
            table.insert(s.equips, v)
        end
    end
    if wing_illusion and skychangeConf[2][wing_illusion] then
        s.bones = s.bones or {}
        local boneIds = skychangeConf[2][wing_illusion].boneId
        for k, v in ipairs(boneIds) do
            table.insert(s.bones, v)
        end

        s.equips = s.equips or {}
        local equipIds = skychangeConf[2][wing_illusion].equipId
        for k, v in ipairs(equipIds) do
            table.insert(s.equips, v)
        end
    end
    s.dragon = dragon
    return s
end

local __base64code = {
    'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P',
    'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 'e', 'f',
    'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v',
    'w', 'x', 'y', 'z', '0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '+', '/',
}
local __base64decode = {}
for k, v in pairs(__base64code) do
    __base64decode[string.byte(v,1)] = k - 1
end

local function base64left1(res, index,text, len)
    local num = string.byte(text, len + 1)
    num = num * 16 
    local tmp = math.floor(num / 64)
    local curPos = tmp % 64 + 1
    res[index ] = __base64code[curPos]

    curPos = num % 64 + 1
    res[index + 1] = __base64code[curPos]
    
    res[index + 2] = "=" 
    res[index + 3] = "=" 
end


local function base64left2(res, index, text, len)
    local num1 = string.byte(text, len + 1)
    num1 = num1 * 1024 --lshift 10 
    local num2 = string.byte(text, len + 2)
    num2 = num2 * 4 --lshift 2 
    local num = num1 + num2
   
    local tmp1 = math.floor(num / 4096) --rShift 12
    local curPos = tmp1 % 64 + 1
    res[index] = __base64code[curPos]
    
    local tmp2 = math.floor(num / 64)
    curPos = tmp2 % 64 + 1
    res[index + 1] = __base64code[curPos]

    curPos = num % 64 + 1
    res[index + 2] = __base64code[curPos]
    
    res[index + 3] = "=" 
end

local function decodeBase64Left1(res, index, text, len)
    local a = __base64decode[string.byte(text, len + 1)] 
    local b = __base64decode[string.byte(text, len + 2)] 
    local c = __base64decode[string.byte(text, len + 3)] 
    local num = a * 4096 + b * 64 + c
    
    local num1 = math.floor(num / 1024) % 256
    local num2 = math.floor(num / 4) % 256
    res[index] = string.char(num1)
    res[index + 1] = string.char(num2)
end

local function decodebase64Left2(res, index, text, len)
    local a = __base64decode[string.byte(text, len + 1)] 
    local b = __base64decode[string.byte(text, len + 2)]
    local num = a * 64 + b
    num = math.floor(num / 16)
    res[index] = string.char(num)
end

function GlobalApi:encodeBase64(text)
    local len = string.len(text)
    local left = len % 3
    len = len - left
    local res = {}
    local index  = 1
    for i = 1, len, 3 do
        local a = string.byte(text, i )
        local b = string.byte(text, i + 1)
        local c = string.byte(text, i + 2)
        -- num = a<<16 + b<<8 + c
        local num = a * 65536 + b * 256 + c 
        for j = 1, 4 do
            --tmp = num >> ((4 -j) * 6)
            local tmp = math.floor(num / (2 ^ ((4-j) * 6)))
            local curPos = tmp % 64 + 1
            res[index] = __base64code[curPos]
            index = index + 1
        end
    end
    if left == 1 then
        base64left1(res, index, text, len)
    elseif left == 2 then
        base64left2(res, index, text, len)        
    end
    return table.concat(res)
end

function GlobalApi:decodeBase64(text)
    local len = string.len(text)
    local left = 0 
    if string.sub(text, len - 1) == "==" then
        left = 2 
        len = len - 4
    elseif string.sub(text, len) == "=" then
        left = 1
        len = len - 4
    end

    local res = {}
    local index = 1
    for i =1, len, 4 do
        local a = __base64decode[string.byte(text,i    )] 
        local b = __base64decode[string.byte(text,i + 1)] 
        local c = __base64decode[string.byte(text,i + 2)] 
        local d = __base64decode[string.byte(text,i + 3)]

        --num = a<<18 + b<<12 + c<<6 + d
        local num = a * 262144 + b * 4096 + c * 64 + d
        
        local e = string.char(num % 256)
        num = math.floor(num / 256)
        local f = string.char(num % 256)
        num = math.floor(num / 256)
        res[index ] = string.char(num % 256)
        res[index + 1] = f
        res[index + 2] = e
        index = index + 3
    end

    if left == 1 then
        decodeBase64Left1(res, index, text, len)
    elseif left == 2 then
        decodeBase64Left2(res, index, text, len)
    end
    return table.concat(res)
end

function GlobalApi:readBinaryfile(path)
    local file = io.open(path, "rb")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

function GlobalApi:saveActivityConfig(avConf, percentAfterSuccess, runPercnetFunc, callBack)
    local totalPencent = 10
    if avConf and next(avConf) then
        local confArr = {}
        for k, v in pairs(avConf) do
            table.insert(confArr, k)
        end
        MessageMgr:getActivityConf(confArr, function (serverConfData)
            local schedulerEntry = 0
            local function removeListenerAndSchedule()
                if schedulerEntry > 0 then
                    cc.Director:getInstance():getScheduler():unscheduleScriptEntry(schedulerEntry)
                    schedulerEntry = 0
                end
                CustomEventMgr:removeEventListener(CUSTOM_EVENT.BACK_TO_LOGIN, self)
                CustomEventMgr:removeEventListener(CUSTOM_EVENT.RESTART_GAME, self)
            end
            if not cc.FileUtils:getInstance():isDirectoryExist(cc.FileUtils:getInstance():getWritablePath() .. "update_activity/avdata") then
                cc.FileUtils:getInstance():createDirectory(cc.FileUtils:getInstance():getWritablePath() .. "update_activity/avdata")
            end
            local avMd5FilePath = cc.FileUtils:getInstance():getWritablePath() .. "update_activity/activity_md5.txt"
            local avMd5 = cc.FileUtils:getInstance():getStringFromFile(avMd5FilePath)
            local avObj = json.decode(avMd5) or {}
            local handleNum = 0
            local countPerFrame = 5 -- 每帧存5个配置文件
            local savePercent = 0
            local percentPerFile = totalPencent/#confArr
            local percent = 0
            local serverConfDataStartIndex = 1
            local serverConfDataEndIndex = 0
            local completeIndex = 1
            local co = coroutine.create(function ()
                while completeIndex <= #confArr do
                    local confName = confArr[completeIndex]
                    local filePath = cc.FileUtils:getInstance():getWritablePath() .. "update_activity/avdata/" .. confName .. ".luac"
                    local confContent = avConf[confName]
                    local dataEndIndex = serverConfDataEndIndex + confContent.length
                    local writeContent = string.sub(serverConfData, serverConfDataStartIndex, dataEndIndex)
                    local success = io.writefile(filePath, writeContent)
                    if success then
                        local fileContent = GlobalApi:readBinaryfile(filePath)
                        if fileContent then
                            local fileBase64 = GlobalApi:encodeBase64(fileContent)
                            local fileMd5 = xx.Utils:Get():generateMD5(fileBase64)
                            if fileMd5 ~= confContent.md5 then
                                removeListenerAndSchedule()
                                promptmgr:showMessageBox(GlobalApi:getLocalStr("DOWNLOAD_ACTIVITY_CONF_FAILED"), MESSAGE_BOX_TYPE.MB_OK, function ()
                                    runPercnetFunc(-savePercent)
                                    callBack(-1)
                                end)
                                return
                            end
                            serverConfDataStartIndex = dataEndIndex + 1
                            serverConfDataEndIndex = dataEndIndex
                            avObj[confName] = confContent.md5
                            percent = percent + percentPerFile
                            completeIndex = completeIndex + 1
                        end
                    end
                    handleNum = handleNum + 1
                    if handleNum%countPerFrame == 0 then
                        if percent >= 1 then
                            local roundPercent = math.floor(percent)
                            percent = percent - roundPercent
                            if savePercent + roundPercent <= totalPencent then
                                savePercent = savePercent + roundPercent
                                runPercnetFunc(roundPercent)
                            end
                        end
                        coroutine.yield()
                    end
                end
                local writeMd5Over = false
                while not writeMd5Over do
                    writeMd5Over = cc.FileUtils:getInstance():writeStringToFile(json.encode(avObj), avMd5FilePath)
                    coroutine.yield()
                end
            end)
            local cancel = false
            schedulerEntry = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
                if not coroutine.resume(co) then
                    if not cancel then
                        removeListenerAndSchedule()
                        runPercnetFunc(totalPencent - savePercent + percentAfterSuccess)
                        callBack(0)
                    end
                end
            end, 0.001, false)
            CustomEventMgr:addEventListener(CUSTOM_EVENT.BACK_TO_LOGIN, self, function ()
                cancel = true
                removeListenerAndSchedule()
            end)
            CustomEventMgr:addEventListener(CUSTOM_EVENT.RESTART_GAME, self, function ()
                cancel = true
                removeListenerAndSchedule()
            end)
        end)
    else
        runPercnetFunc(totalPencent + percentAfterSuccess)
        callBack(0)
    end
end


-- 获取字符串的长度（任何单个字符长度都为1）
function GlobalApi:getStringLength(inputstr)
    if not inputstr or type(inputstr) ~= "string" or #inputstr <= 0 then
        return nil
    end
    local length = 0  -- 字符的个数
    local i = 1
    while true do
        local curByte = string.byte(inputstr, i)
        local byteCount = 1
        if curByte > 239 then
            byteCount = 4  -- 4字节字符
        elseif curByte > 223 then
            byteCount = 3  -- 汉字
        elseif curByte > 128 then
            byteCount = 2  -- 双字节字符
        else
            byteCount = 1  -- 单字节字符
        end

        i = i + byteCount
        length = length + 1
        if i > #inputstr then
            break
        end
    end
    return length
end


--TX添加,处理含有表情的字符串,例如:啊啊啊#01啊啊啊(#后只能跟2位数字)
function GlobalApi:getFaceString(str)
    local imgs = {}
    local strs = {}

    local j = 0
    while (string.find(str, "#")) do
        j = j + 1

        local idex = string.find(str, "#")
        local img = string.sub(str, idex+1, idex+1)
        local str1 = string.sub(str, 1, idex-1)
        imgs[j] = img
        strs[j] = str1

        str = string.sub(str, idex+2, -1)
    end
    strs[#strs + 1] = str

    return strs, imgs   --strs包含几段字符串,imgs包含几张图
end

-- TX添加,创建含有表情的字符串
-- *标识为必须传
--*str         - 字符串
--posX         - 文字起始X坐标
--posY         - 文字起始Y坐标
--txSize       - 文字字体大小(默认20)
--imgScale     - 图片缩放大小(默认1)
--txType       - 是否使用gamefont.ttf字体(默认不使用)
--size         - 文字区域
function GlobalApi:createFaceString(str, posX, posY, txSize, imgScale, txType, size)
    posX = posX or 0
    posY = posY or 0
    imgScale = imgScale or 1
    size = size or cc.size(720, 100)

    local rt = xx.RichText:create()
    rt:setContentSize(size)
    rt:setPosition(cc.p(posX, posY))
    rt:setAnchorPoint(cc.p(0,1))

    local strs, imgRes = GlobalApi:getFaceString(str)
    for k,v in ipairs(strs) do
        local lable = xx.RichTextLabel:create(v, txSize, COLOR_TYPE.WHITE)
        if txType then
            lable:setFont('font/gamefont.ttf')
        end
        rt:addElement(lable)

        local img = nil
        if imgRes[k] then
            img = xx.RichTextImage:create("uires/icon/face/"..imgRes[k]..".png")
            img:setScale(imgScale)
            rt:addElement(img)
        end
    end

    return rt
end

--全屏图片根据屏幕适配缩放
function GlobalApi:imgScaleWinSize(imgBG)
    local winSize = cc.Director:getInstance():getVisibleSize()
    imgBG:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    local size = imgBG:getContentSize()
    if size.width < winSize.width then
        imgBG:setScaleX(winSize.width/size.width)
    elseif size.height < winSize.height then
        imgBG:setScaleY(winSize.height/size.height)
    end
end

--TX添加,打印元表
function GlobalApi:printMetaTableFun(t)
    local rs_tb={}

    local function tmp(t)
        if t then
            for _val, _val_type in pairs(t) do
                if type(_val_type)~="userdata" then 
                    if not string.find(_val,"_") then                   
                        table.insert(rs_tb,_val)
                    end      
                end
            end
            local ft=getmetatable(t)
            if ft then
                tmp(ft)    
            end          
        end
    end
    tmp(getmetatable(t))

    table.sort(rs_tb) 
    local rs_str=""
    for i=1,#rs_tb do
        rs_str=rs_str .. rs_tb[i] .. "\n"
    end

    print(rs_str)
end

--给按钮添加点击效果
function GlobalApi:setClickAction(node)
    node:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            print("     111111111111111    ")
            node:runAction(cc.ScaleTo:create(0.7, 0.3))
        elseif eventType == ccui.TouchEventType.ended then
            print("     2222222222222222    ")
            node:runAction(cc.ScaleTo:create(1, 0.3))
        end
    end)
end


--=================== 字符串中文切割处理 ===================--

--截取中英混合的UTF8字符串，endIndex可缺省
function GlobalApi:SubStringUTF8(str, startIndex, endIndex)
    if startIndex < 0 then
        startIndex = GlobalApi:SubStringGetTotalIndex(str) + startIndex + 1;
    end

    if endIndex ~= nil and endIndex < 0 then
        endIndex = GlobalApi:SubStringGetTotalIndex(str) + endIndex + 1;
    end

    if endIndex == nil then 
        return string.sub(str, GlobalApi:SubStringGetTrueIndex(str, startIndex));
    else
        return string.sub(str, GlobalApi:SubStringGetTrueIndex(str, startIndex), GlobalApi:SubStringGetTrueIndex(str, endIndex + 1) - 1);
    end
end

--获取中英混合UTF8字符串的真实字符数量
function GlobalApi:SubStringGetTotalIndex(str)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = GlobalApi:SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(lastCount == 0);
    return curIndex - 1;
end

function GlobalApi:SubStringGetTrueIndex(str, index)
    local curIndex = 0;
    local i = 1;
    local lastCount = 1;
    repeat 
        lastCount = GlobalApi:SubStringGetByteCount(str, i)
        i = i + lastCount;
        curIndex = curIndex + 1;
    until(curIndex >= index);
    return i - lastCount;
end

--返回当前字符实际占用的字符数
function GlobalApi:SubStringGetByteCount(str, index)
    local curByte = string.byte(str, index)
    local byteCount = 1;
    if curByte == nil then
        byteCount = 0
    elseif curByte > 0 and curByte <= 127 then
        byteCount = 1
    elseif curByte>=192 and curByte<=223 then
        byteCount = 2
    elseif curByte>=224 and curByte<=239 then
        byteCount = 3
    elseif curByte>=240 and curByte<=247 then
        byteCount = 4
    end
    return byteCount;
end

--将橫版label转成竖版
function GlobalApi:getVerticalText(str)
    local resultStr = ""
    local strLen = GlobalApi:SubStringGetTotalIndex(str)
    for i = 1, strLen do
        local subStr = GlobalApi:SubStringUTF8(str, i, i)
        resultStr = resultStr..subStr
        if i < strLen then
            resultStr = resultStr.."\n"
        end
    end
    return resultStr
end

-- 停服状态弹窗
function GlobalApi:setStopServer(jsonData)
    self.stopServer = jsonData
end

function GlobalApi:getStopServer()
    return self.stopServer
end