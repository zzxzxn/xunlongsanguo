local DragonDiDiUI = class("DragonDiDiUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local LOCKIMG =  'uires/ui/common/lock_4.png'

function DragonDiDiUI:ctor(data,showAnimation)
    self.uiIndex = GAME_UI.UI_DRAGON_DIDI_PANEL
    self.drops_dragon = data.drops_dragon

    MapData:setDropDragons(self.drops_dragon)

    UserData:getUserObj().activity.drops_dragon.use = self.drops_dragon.use

    -- 当前可用次数
    local nowCount = self.drops_dragon.num
    self.surplus_frequency = nowCount - self.drops_dragon.use

    self.showAnimation = showAnimation or false
    if self.showAnimation == true then
        local fightedId = MapData:getFightedCityId()
        --print('===========++++++++++++++++' .. fightedId)
        local nowLockId = nil
        if fightedId == 4 then
            nowLockId = 2
        elseif fightedId == 12 then
            nowLockId = 3
        elseif fightedId == 18 then
            nowLockId = 5
        elseif fightedId == 24 then
            nowLockId = 6
        end

        self.nowLockId = nowLockId
    end

    -- lock
    local tempData = GameData:getConfData('avdropsdragon')
    local fightedId = MapData:getFightedCityId()
    self.lock = {}
    for i = 1,#tempData do
        local data = tempData[i]
        if fightedId >= data.cityid then
            self.lock[tostring(i)] = 1
        end
    end

end

function DragonDiDiUI:init()
    local guardBgImg = self.root:getChildByName("guard_bg_img")
    local bgImg = guardBgImg:getChildByName("bg_img1")
    local guardImg = bgImg:getChildByName("guard_img")
    self.guardImg = guardImg
    local mainImg = guardImg:getChildByName("main_img")
    self.mainImg = mainImg
    self:adaptUI(guardBgImg, bgImg)
    local winSize = cc.Director:getInstance():getWinSize()

    local closeBtn = guardImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideDragonDiDiPanel()
        end
    end)
    self.closeBtn = closeBtn

    local titleBg = guardImg:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr("ACTIVE_DRAGON_DIDI_DES1"))

    self:initData()
    self:initLeft()
    self:initRight()
    self:refreshCount()

    if self.showAnimation == true then
        self:playAnimation()
    end
end

function DragonDiDiUI:initData()
    self.tempData = GameData:getConfData('avdropsdragon')
    self.gotoBtn = {}
    self.leftCells = {}
    self.rightCells = {}
end

function DragonDiDiUI:refreshCount()
    self.numTx:setString(self.surplus_frequency or 0)
end

function DragonDiDiUI:initLeft()
    local help = self.mainImg:getChildByName("help")
    self.help = help

    help:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(HELP_SHOW_TYPE.DRAGON_DIDI)
        end
    end)

    local tips = self.mainImg:getChildByName("tips")
    tips:setString(GlobalApi:getLocalStr("ACTIVE_DRAGON_DIDI_DES2"))

    -- 抽奖
    local tenAwardBtn = self.mainImg:getChildByName("ten_award_btn")
    tenAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:scrollToServer()
        end
    end)
    tenAwardBtn:getChildByName("tx"):setString(GlobalApi:getLocalStr("ACTIVE_DRAGON_DIDI_DES3"))
    self.lottoryBtn = tenAwardBtn

    -- 转盘
    local wheel = self.mainImg:getChildByName("wheel")
    local arrow = wheel:getChildByName('arrow')
    self.arrow = arrow

    local img = wheel:getChildByName('img')
    local title = img:getChildByName('title')
    title:setString(GlobalApi:getLocalStr('ACTIVE_DRAGON_DIDI_DES4'))

    local numTx = img:getChildByName('num_tx')
    self.numTx = numTx

    local num = #self.tempData
    for i = 1,num do
        local data = self.tempData[i]
        local frame = wheel:getChildByName('icon_' .. i)

        local awardData = data.awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
            
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)
        table.insert(self.leftCells,cell)

        -- 锁,判断是否解锁
        local size = cell.awardBgImg:getContentSize()
        local lockImg = ccui.ImageView:create(LOCKIMG)
        cell.lockImg = lockImg
        lockImg:setPosition(cc.p(size.width * 0.5,size.height * 0.5))
        cell.awardBgImg:addChild(lockImg)

        local lock = self.lock
        local judge = false
        if lock[tostring(i)] and lock[tostring(i)] == 1 then
            judge = true
        end

        if i == 1 or i == 4 then
            lockImg:setVisible(false)
        else
            if judge == true then   -- 解锁
                lockImg:setVisible(false)
            else
                lockImg:setVisible(true)
            end
            if self.nowLockId == i then   -- 未解锁
                lockImg:setVisible(true)
            end
        end

    end
end

function DragonDiDiUI:initRight()
    local rightBgImg = self.mainImg:getChildByName("right_bg_img")

    local sv = rightBgImg:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    self.sv = sv

    local temp = {}
    for i = 1,#self.tempData do
        local data = self.tempData[i]
        if data.cityid > 0 then
            table.insert(temp,data)
        end
    end

    local num = #temp
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5
    local cellHeight = 104
    local cellWidht = 498

    local height = num * cellHeight + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = cellHeight
    for i = 1,num do
        local tempCell = cc.CSLoader:createNode('csb/dragon_didi_cell.csb')
        local tempData = self.tempData[i]

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0 + cellWidht/2,allHeight - offset + cellHeight/2))
        self.sv:addChild(tempCell)
        
        local cellBgImg = tempCell:getChildByName('cell_bg_img')

        local equipBgImg2 = cellBgImg:getChildByName('equip_bg_img1')-- you
        local equipBgImg1 = cellBgImg:getChildByName('equip_bg_img2')-- you

        local getImg = cellBgImg:getChildByName('get_img')
        local gotoBtn = cellBgImg:getChildByName('goto_btn')
        table.insert(self.gotoBtn,gotoBtn)
        local infoTx = gotoBtn:getChildByName("info_tx")
        infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
        local nameTx = cellBgImg:getChildByName('name_tx')-- you
        local descTx = cellBgImg:getChildByName('desc_tx')-- you

        local cityId = temp[i].cityid
        local cityData = MapData.data[cityId]
        local feilongConf = GameData:getConfData('feilongfly')
        local awards1 = feilongConf[cityId].awards
        
        -- 道具1
        local equip = nil
        local awardTab = DisplayData:getDisplayObjs(awards1)
        for j,v1 in ipairs(awardTab) do
            if v1:getObjType() == 'equip' then
                equip = v1
                break
            end
        end
        if i == 4 then
            equip = DisplayData:getDisplayObj({'card',4208,0})
        end

        if equip then
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, equip, equipBgImg1)
            cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
            cell.lvTx:setString('x'..equip:getNum())
            local godId = equip:getGodId()
            equip:setLightEffect(cell.awardBgImg)

            local keyArr = string.split(cityData:getName() , '.')
            descTx:setString(string.format(GlobalApi:getLocalStr('LIUBEI_INFO_DESC_2'),keyArr[#keyArr]))
            nameTx:setString(equip:getName())

            if i == 4 then
                local effect = GlobalApi:createLittleLossyAniByName("chip_light")
                effect:getAnimation():playWithIndex(0, -1, 1)
                effect:setName('chip_light')
                effect:setPosition(cc.p(94 * 0.5,94 * 0.5))
                cell.awardBgImg:addChild(effect)      
                cell.lvTx:setString('x'..1)
            else
                nameTx:setColor(equip:getNameColor())
                nameTx:enableOutline(equip:getNameOutlineColor())
            end
        else
            descTx:setVisible(false)
            nameTx:setVisible(false)
        end

        -- 道具2      
        local awardData = temp[i].awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, equipBgImg2)
        cell.awardBgImg:setPosition(cc.p(94 * 0.5,94 * 0.5))
        self.rightCells[temp[i].id] = cell.awardBgImg
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        -- 玩家是否解锁
        local tips = cellBgImg:getChildByName('tips')

        local lock = self.lock
        local judge = false
        local tempId = temp[i].id
        if tempId == 1 and tempId == 4 then
            judge = true
        else
            if lock[tostring(tempId)] and lock[tostring(tempId)] == 1 then
                judge = true
            end
        end

        if judge == true then   -- 解锁
            getImg:setVisible(true)
            gotoBtn:setVisible(false)
            tips:setString(GlobalApi:getLocalStr("ACTIVE_DRAGON_DIDI_DES6"))
        else
            getImg:setVisible(false)
            gotoBtn:setVisible(true)
            tips:setString(GlobalApi:getLocalStr("ACTIVE_DRAGON_DIDI_DES5"))
        end

        gotoBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GlobalApi:getGotoByModule('battle')
                MapMgr:hideDragonDiDiPanel()
            end
        end)

        cell.lvTx:setPositionY(cell.lvTx:getPositionY() + 8)
        tips:setPositionY(tips:getPositionY() - 2)

    end
    innerContainer:setPositionY(size.height - allHeight)


    -- 底部 描述
    local descTx = rightBgImg:getChildByName("desc_tx")
    local fightedId = MapData:getFightedCityId()
    local id = 0
    local num = 0
    for i= fightedId + 1,#MapData.data do
        local conf = GameData:getConfData('feilongfly')[i]
        if i > 24 then
            id = 24
            break
        end
        if conf and conf.awards then
            local awardTab = DisplayData:getDisplayObjs(conf.awards)
            for j,v in ipairs(awardTab) do
                if v:getObjType() == 'fragment' then
                    id = i
                    num = v:getNum()
                    break
                end
            end
            if id ~= 0 then
                break
            end
        end
    end
    
    if fightedId >= 24 then
        descTx:setString(GlobalApi:getLocalStr('ACTIVE_DRAGON_DIDI_DES8'))
    else
        descTx:setString(string.format(GlobalApi:getLocalStr('LIUBEI_INFO_DESC_1'),id - fightedId,num))
    end

    --[[
    local obj = BagData:getFragmentById(4208)
    if not obj then
        obj = DisplayData:getDisplayObj({'fragment',4208,0})
    end

    local barBg = rightBgImg:getChildByName("bar_bg")
    local bar = barBg:getChildByName('bar')
    local barTx = bar:getChildByName('bar_tx')

    local objNum = obj:getNum()
    local percent = objNum/80*100
    if percent > 100 then
        percent = 100
    end
    barTx:setString(percent..'%')
    bar:setPercent(percent)
    --]]

    -- 根据解救次数
    local barBg = rightBgImg:getChildByName("bar_bg")
    local bar = barBg:getChildByName('bar')
    local barTx = bar:getChildByName('bar_tx')


    local tempData = GameData:getConfData('avdropsdragon')
    local fightedId = MapData:getFightedCityId()
    local num = 0
    for i = 1,#tempData do
        local data = tempData[i]
        if fightedId >= data.cityid and data.cityid > 0 then
            num = num + 1
        end
    end

    local percent = num/4*100
    if percent > 100 then
        percent = 100
    end
    barTx:setString(percent..'%')
    bar:setPercent(percent)

end

-- 转动通讯
function DragonDiDiUI:scrollToServer()
    -- 剩余次数
    local remainCount = self.surplus_frequency
    if remainCount <= 0 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_DRAGON_DIDI_DES7'), COLOR_TYPE.RED)
        return
    end

    self:disableBtn()
    MessageMgr:sendPost('get_drops_dragon_award','activity',json.encode({}),
	function(response)
		if(response.code ~= 0) then
            self:openBtn()
			return
		end
        self.surplus_frequency = self.surplus_frequency - 1
        self.drops_dragon.use = self.drops_dragon.use + 1
        UserData:getUserObj().activity.drops_dragon.use = self.drops_dragon.use
        MapData:setDropDragons(self.drops_dragon)
        self:refreshCount()
        -- 开始转动
        self:scrollStart(response.data)
	end)
end

function DragonDiDiUI:scrollStart(data)
    local id = data.ids
    local awards = data.awards

    if not id or id <= 0 then
        if awards then
			GlobalApi:parseAwardData(awards)
		end
        self:openBtn()
        return
    end
    
    local endDeg = (id - 1) * 60 - 30 + GlobalApi:random(3, 57)
    local act1 = cc.Sequence:create(CCEaseSineIn:create(cc.RotateBy:create(0.5, 360)),cc.RotateBy:create(0.4,360),cc.EaseSineOut:create(cc.RotateBy:create(1.5, endDeg + 360 * 2)))
    local act2 = cc.DelayTime:create(0.4)
    local act3 = cc.CallFunc:create(
	    function ()
            local function callBack()
                -- 刷新显示
                self.arrow:setRotation(0)
            end
			GlobalApi:showAwardsCommon(awards,true,callBack,false)

            if awards then
			    GlobalApi:parseAwardData(awards)
		    end
            self:openBtn()
	    end)
    self.arrow:runAction(cc.Sequence:create(act1,act2,act3))
end

-- 禁用按钮
function DragonDiDiUI:disableBtn()
    self.closeBtn:setTouchEnabled(false)
    self.lottoryBtn:setTouchEnabled(false)
    self.help:setTouchEnabled(false)
    for i = 1,#self.gotoBtn do
        if self.gotoBtn[i] then
            self.gotoBtn[i]:setTouchEnabled(false)
            ShaderMgr:setGrayForWidget(self.gotoBtn[i])
        end
    end

    ShaderMgr:setGrayForWidget(self.closeBtn)
    ShaderMgr:setGrayForWidget(self.lottoryBtn)
    ShaderMgr:setGrayForWidget(self.help)
end

-- 启用按钮
function DragonDiDiUI:openBtn()
    self.closeBtn:setTouchEnabled(true)
    self.lottoryBtn:setTouchEnabled(true)
    self.help:setTouchEnabled(true)
    for i = 1,#self.gotoBtn do
        if self.gotoBtn[i] then
            self.gotoBtn[i]:setTouchEnabled(true)
            ShaderMgr:restoreWidgetDefaultShader(self.gotoBtn[i])
        end
    end

    ShaderMgr:restoreWidgetDefaultShader(self.closeBtn)
    ShaderMgr:restoreWidgetDefaultShader(self.lottoryBtn)
    ShaderMgr:restoreWidgetDefaultShader(self.help)
end

-- 打开界面解锁动画
function DragonDiDiUI:playAnimation()
    local nowLockId = self.nowLockId

    local cell = self.leftCells[nowLockId]
    local awardBgImg = cell.awardBgImg

    local rightAwardBgImg = self.rightCells[nowLockId]
    if not rightAwardBgImg or not nowLockId then
        return
    end

    awardBgImg:runAction(cc.Sequence:create(
        cc.DelayTime:create(0.2),
        cc.ScaleTo:create(0.2, 1.2),
        cc.ScaleTo:create(0.2, 1),
        cc.ScaleTo:create(0.2, 1.2),
        cc.ScaleTo:create(0.2, 1),
        cc.CallFunc:create(function()
            local size = awardBgImg:getContentSize()
            local particle = cc.ParticleSystemQuad:create("particle/getitem.plist")
            particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
            particle:setPosition(awardBgImg:getPosition())
            particle:setName('getitem')
            particle:setScale(1.5)
            cell.awardBgImg:addChild(particle)
            --[[
            cell.lockImg:setVisible(false)
            local spine = GlobalApi:createSpineByName('ui_suo', "spine/ui_suo/ui_suo", 1)
            awardBgImg:addChild(spine,100)
            spine:setPosition(cell.lockImg:getPosition())
            spine:setAnimation(0, 'idle', false)
            --]]
        end),
        cc.DelayTime:create(0.2),
        cc.CallFunc:create(function()
            cell.lockImg:setVisible(false)
        end)
    ))
end

return DragonDiDiUI