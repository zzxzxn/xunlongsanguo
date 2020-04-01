local CityCraftRemark = class("CityCraftRemark", BaseUI)

function CityCraftRemark:ctor()
	self.uiIndex = GAME_UI.UI_CITY_CRAFT_REMARK_PANEL
    self.curCityCraftType = 1
end

-- 初始化
function CityCraftRemark:init()
	local bgImg = self.root:getChildByName('bg_img')
	local bgImg1 = bgImg:getChildByName('bg_img1')
	self:adaptUI(bgImg, bgImg1)

    local closeBtn = bgImg1:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideCityCraftRemarkUI()
        end
    end) 

    self.cell = bgImg:getChildByName('cell')
    self.cell:setVisible(false)

    local leftImg = bgImg1:getChildByName('left_img')
    bgImg1:getChildByName('text'):setString(GlobalApi:getLocalStr('JADESEAL_DESC13'))

    local infoTx = bgImg1:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('JADESEAL_DESC14'))

    local svBg = bgImg1:getChildByName('sv_bg')
    self.svBg = svBg
    local sv_temp = svBg:getChildByName('sv')
    sv_temp:setScrollBarEnabled(false)
    sv_temp:setVisible(false)
    self.sv_temp = sv_temp

    self.noImg = bgImg1:getChildByName('no_friends_img')
    self.noImg:getChildByName('no_friends_tx'):setString(GlobalApi:getLocalStr('JADESEAL_DESC18'))

    self.btns = {}
    for i = 1,3 do
        local btn = bgImg1:getChildByName('btn' .. i)
        table.insert(self.btns,btn)
        btn.text = btn:getChildByName('text')

        if i == 1 then
            btn.text:setString(GlobalApi:getLocalStr('JADESEAL_DESC15'))
        elseif i == 2 then
            btn.text:setString(GlobalApi:getLocalStr('JADESEAL_DESC16'))
        else
            btn.text:setString(GlobalApi:getLocalStr('JADESEAL_DESC17'))
        end

        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.curCityCraftType == i then
                    return
                end
                self.curCityCraftType = i
                self:swithState()
            end
        end)
    end

    self.cityInfoDataObj = {}
    self.cityNormalInfoDataObj = {}
    self.cityInfoEliteDataObj = {}

    local curNormalProgress = MapData:getFightedCityId()
    local curEliteProgress = MapData:getFightedEliteCityId()
    local currProgress = MapData.currProgress   -- 普通关卡当前可打的进度
    local judge = false
    if currProgress ~= curNormalProgress then
        judge = true
    end

    for i = 1,#MapData.data do
        local obj = clone(MapData.data[i])
        local id = obj:getId()
        if (id <= curNormalProgress and obj:getStar(1) < 3) or (id == currProgress and judge == true) then
            obj.monsterType = 1
            table.insert(self.cityNormalInfoDataObj,obj)
        end
    end

    for i = 1,#MapData.data do
        local obj = clone(MapData.data[i])
        local id = obj:getId()
        if (id <= curEliteProgress and obj:getStar(2) < 3) or (id == MapData:getCurrEliteCityId() and obj:getStar(2) < 3) then
            obj.monsterType = 2
            table.insert(self.cityInfoEliteDataObj,obj)
        end
    end

    for i = 1,#MapData.data do
        local obj = clone(MapData.data[i])
        local id = obj:getId()
        local judge1 = false
        if (id <= curNormalProgress and obj:getStar(1) < 3) or (id == currProgress and judge == true)  then
            judge1 = true
        end
        local judge2 = false
        if (id <= curEliteProgress and obj:getStar(2) < 3) or (id == MapData:getCurrEliteCityId() and obj:getStar(2) < 3) then
            judge2 = true
        end
        if (judge1 == true and judge2 == true) or (judge1 == true and judge2 == false) then
            obj.monsterType = 1
            table.insert(self.cityInfoDataObj,obj)
        elseif (judge1 == false and judge2 == true) then
            obj.monsterType = 2
            table.insert(self.cityInfoDataObj,obj)
        end
    end

    table.sort(self.cityNormalInfoDataObj, function(obj1,obj2)
        local monsterGroup = obj1:getFormation(obj1.monsterType)
	    local monsterConf = GameData:getConfData("formation")[monsterGroup]
        local fightForce1 = monsterConf.fightforce

        local monsterGroup = obj2:getFormation(obj2.monsterType)
	    local monsterConf = GameData:getConfData("formation")[monsterGroup]
        local fightForce2 = monsterConf.fightforce

		return fightForce1 < fightForce2
	end)

    
    table.sort(self.cityInfoEliteDataObj, function(obj1,obj2)
        local monsterGroup = obj1:getFormation(obj1.monsterType)
	    local monsterConf = GameData:getConfData("formation")[monsterGroup]
        local fightForce1 = monsterConf.fightforce

        local monsterGroup = obj2:getFormation(obj2.monsterType)
	    local monsterConf = GameData:getConfData("formation")[monsterGroup]
        local fightForce2 = monsterConf.fightforce

		return fightForce1 < fightForce2
	end)

    table.sort(self.cityInfoDataObj, function(obj1,obj2)
        local monsterGroup = obj1:getFormation(obj1.monsterType)
	    local monsterConf = GameData:getConfData("formation")[monsterGroup]
        local fightForce1 = monsterConf.fightforce

        local monsterGroup = obj2:getFormation(obj2.monsterType)
	    local monsterConf = GameData:getConfData("formation")[monsterGroup]
        local fightForce2 = monsterConf.fightforce

		return fightForce1 < fightForce2
	end)

    self:swithState()
end

function CityCraftRemark:swithState()
    for i = 1,#self.btns do
        if i == self.curCityCraftType then
            self.btns[i]:loadTextureNormal('uires/ui/common/title_btn_sel_3.png')
            self.btns[i].text:setTextColor(cc.c3b(0xff, 0xff, 0xff))
        else
            self.btns[i]:loadTextureNormal('uires/ui/common/title_btn_nor_3.png')
            self.btns[i].text:setTextColor(cc.c3b(0xcf, 0xba, 0x8d))
        end
    end
    self:updateSv()
end

function CityCraftRemark:updateSv()
    if self.svBg:getChildByName('scrollView_sv') then
        self.svBg:removeChildByName('scrollView_sv')
    end

    local svData = {}
    if self.curCityCraftType == 1 then
        svData = self.cityInfoDataObj
    elseif self.curCityCraftType == 2 then
        svData = self.cityNormalInfoDataObj
    else
        svData = self.cityInfoEliteDataObj
    end

    local sv = self.sv_temp:clone()
    sv:setVisible(true)
    sv:setName('scrollView_sv')
    self.svBg:addChild(sv)

    local num = #svData
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 18

    if num <= 0 then
        self.noImg:setVisible(true)
        return
    end
    
    self.noImg:setVisible(false)
    local width = num * self.cell:getContentSize().width + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = self.cell:getContentSize().width
    for i = 1,num,1 do
        local tempCell = self.cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

        self:updateCell(tempCell,svData[i])
    end
    innerContainer:setPositionX(0)
end

function CityCraftRemark:updateCell(img,data)
    local topImg = img:getChildByName('top_img')
    local name = topImg:getChildByName('name')
    name:setString(data:getName())

    local jingImg = img:getChildByName('jing_img')
    jingImg:setLocalZOrder(9999)
    if data.monsterType == 2 then
        jingImg:setVisible(true)
    else
        jingImg:setVisible(false)
    end

    local monsterGroup = data:getFormation(data.monsterType)
	local monsterConf = GameData:getConfData("formation")[monsterGroup]
	local monsterId = monsterConf['pos'..monsterConf.boss]
	local monsterObj = GameData:getConfData("monster")[monsterId]

    local roleBg = img:getChildByName('role_bg')
    roleBg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GlobalApi:getGotoByModule('expedition',nil,{data:getId(),data.monsterType})
        end
    end) 

    local spineAni = GlobalApi:createLittleLossyAniByName(monsterObj.url..'_display')
    spineAni:setScale(0.82)
	spineAni:setPosition(cc.p(100,20 + monsterObj.uiOffsetY))
	roleBg:addChild(spineAni)
	spineAni:getAnimation():play('idle', -1, 1)

    local fightforceImg = img:getChildByName('fightforce_img')
    local fightforceTx = fightforceImg:getChildByName('fightforce_tx')
    local fightforceLabel = cc.LabelAtlas:_create(monsterConf.fightforce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setName('fightforceLabel')
    fightforceLabel:setScale(0.8)     
    fightforceLabel:setAnchorPoint(cc.p(0.5, 0.5))
    fightforceImg:addChild(fightforceLabel)
    fightforceLabel:setPosition(cc.p(fightforceTx:getPositionX(),fightforceTx:getPositionY()))

    for i = 1,6 do
        local star = img:getChildByName('star' .. i)
        if i <= 3 then
            local starNum = data:getStar(1)
            if starNum >= i then
                star:loadTexture('uires/ui/common/icon_star3.png')
            else
                star:loadTexture('uires/ui/common/icon_star3_bg.png')
            end
            if starNum <= 0 then
                star:setVisible(false)
            end
        else
            local starNum = data:getStar(2)
            if starNum >= (i - 3) then
                star:loadTexture('uires/ui/common/icon_star3.png')
            else
                star:loadTexture('uires/ui/common/icon_star3_bg.png')
            end
            if starNum <= 0 then
                star:setVisible(false)
            end
        end

    end

end

return CityCraftRemark
