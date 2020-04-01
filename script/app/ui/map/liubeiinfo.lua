local LiubeiInfo = class("LiubeiInfo", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
	
function LiubeiInfo:ctor(id)
    self.uiIndex = GAME_UI.UI_LIUBEI_INFO
end

function LiubeiInfo:init()
    local guardBgImg = self.root:getChildByName("guard_bg_img")
    local bgImg = guardBgImg:getChildByName("bg_img1")
    local guardImg = bgImg:getChildByName("guard_img")
    self:adaptUI(guardBgImg, bgImg)
    local winSize = cc.Director:getInstance():getWinSize()

    local closeBtn = guardImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideLiubeiInfoPanel()
        end
    end)

    local mainImg = guardImg:getChildByName("main_img")
    local leftPl = mainImg:getChildByName("left_pl")
    local rightBgImg = mainImg:getChildByName("right_bg_img")

    local godBtn = leftPl:getChildByName("god_btn")
    local fangdaBtn = leftPl:getChildByName("fangda_btn")
    local descTx = leftPl:getChildByName("desc_tx")
    local mergeBtn = leftPl:getChildByName("merge_btn")
    local infoTx = mergeBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('STR_MERGE_1'))
    local barBg = leftPl:getChildByName("bar_bg")
    local bar = barBg:getChildByName('bar')
    local barTx = bar:getChildByName('bar_tx')
    local list = rightBgImg:getChildByName("list")
    godBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            ChartMgr:showChartMain(4)
        end
    end)
    local obj = BagData:getFragmentById(4208)
    if not obj then
        obj = DisplayData:getDisplayObj({'fragment',4208,0})
    end
    fangdaBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleCardInfo(obj,true, 2)
        end
    end)
    mergeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                id = obj:getId(),
                num = 80
            }
            MessageMgr:sendPost("use", "bag", json.encode(args), function (jsonObj)
                print(json.encode(jsonObj))
                local code = jsonObj.code
                if code == 0 then
                    local awards = jsonObj.data.awards
                    GlobalApi:parseAwardData(awards)
                    TavernMgr:showTavernAnimate(awards, function (  )
                        local costs = jsonObj.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_SUCC'), COLOR_TYPE.GREEN)
                    end, 4)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('MEGRE_FAIL'), COLOR_TYPE.RED)
                end
            end)
        end
    end)
    local num = obj:getNum()
    local percent = num/80*100
    if percent > 100 then
        percent = 100
    end
    barTx:setString(percent..'%')
    bar:setPercent(percent)

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
        mergeBtn:setVisible(true)
        descTx:setString('')
    else
        mergeBtn:setVisible(false)
        descTx:setString(string.format(GlobalApi:getLocalStr('LIUBEI_INFO_DESC_1'),id - fightedId,num))
    end

    local cell = cc.CSLoader:createNode('csb/liubeiinfocell.csb')
    local template = cell:getChildByName('cell_bg_img')
    list:setItemModel(template)
    list:setScrollBarEnabled(false)
    local feilongConf = GameData:getConfData('feilongfly')
    local num = 0
    for k,v in pairs(feilongConf) do
        local equip = nil
        local cityId = nil
        if v.awards then
            local awardTab = DisplayData:getDisplayObjs(v.awards)
            for j,v1 in ipairs(awardTab) do
                if v1:getObjType() == 'equip' then
                    equip = v1
                    cityId = v.id
                    break
                end
            end
        end
        if equip then
            list:pushBackDefaultItem()
            local cell = list:getItem(num)
            num = num + 1
            local getImg = cell:getChildByName('get_img')
            local gotoBtn = cell:getChildByName('goto_btn')
            local nameTx = cell:getChildByName('name_tx')
            local descTx = cell:getChildByName('desc_tx')
            local equipBgImg = cell:getChildByName('equip_bg_img')
            local equipImg = equipBgImg:getChildByName('equip_img')
            local cityData = MapData.data[cityId]
            local keyArr = string.split(cityData:getName() , '.')
            descTx:setString(string.format(GlobalApi:getLocalStr('LIUBEI_INFO_DESC_2'),keyArr[#keyArr]))
            nameTx:setString(equip:getName())
            equipBgImg:loadTexture(equip:getBgImg())
            equipImg:loadTexture(equip:getIcon())
            equipImg:ignoreContentAdaptWithSize(true)
            ClassItemCell:setGodLight(equipBgImg,equip:getGodId())
            local infoTx = gotoBtn:getChildByName("info_tx")
            infoTx:setString(GlobalApi:getLocalStr('GOTO_1'))
            if fightedId >= cityId then
                getImg:setVisible(true)
                gotoBtn:setVisible(false)
            else
                getImg:setVisible(false)
                gotoBtn:setVisible(true)
            end
            gotoBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GlobalApi:getGotoByModule('battle')
                    MapMgr:hideLiubeiInfoPanel()
                end
            end)
        end
    end

    local spineAni = GlobalApi:createLittleLossyAniByRoleId(4208)
    -- spineAni:setScale(0.4)
    spineAni:setPosition(cc.p(195,152))
    spineAni:getAnimation():play('idle', -1, -1)
    leftPl:addChild(spineAni)
end

return LiubeiInfo