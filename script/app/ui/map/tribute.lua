local TributeUI = class("TributeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TributeUI:ctor()
	self.uiIndex = GAME_UI.UI_TRIBUTE
end

function TributeUI:updatePanel()
    local conf = GameData:getConfData('citytribute')
    local singleSize
    local function getPos(i,size,size1)
        local diff = (size.width - 3 * size1.width)/4
        local posX = (i - 1)*(size1.width + diff) + diff
        return cc.p(posX,size.height/2)
    end
    local cityTribute = MapData.cityTribute
    for i=1,#self.tab do
        local cityData = MapData.data[self.tab[i].id]
        local node = cc.CSLoader:createNode("csb/tributecell.csb")
        local pl = node:getChildByName('pl')
        local bgImg = node:getChildByName('bg_img')
        singleSize = pl:getContentSize()
        local keyArr = string.split(cityData:getName() , '.')
        local nameTx = pl:getChildByName('name_tx')
        local nameTx1 = pl:getChildByName('name_tx2')
        local occupyImg = pl:getChildByName('occupy_img')
        local bgImg1 = pl:getChildByName('bg_img1')
        local gotBgImg = bgImg1:getChildByName('got_bg_img')
        gotBgImg:setLocalZOrder(2)
        nameTx:setString(keyArr[#keyArr])
        self.sv:addChild(node)
        node:setPosition(cc.p(5,(i - 1) * 175))

        if not self.tab[i].isPass then
            bgImg:loadTexture('uires/ui/common/common_bg_3.png')
            nameTx1:setString(GlobalApi:getLocalStr('TRIBUTE_DESC_1'))
            nameTx1:setColor(COLOR_TYPE.WHITE)
            nameTx1:enableOutline(COLOROUTLINE_TYPE.WHITE,1)
            occupyImg:setVisible(false)
            gotBgImg:setVisible(false)
        else
            nameTx1:setString(keyArr[#keyArr]..GlobalApi:getLocalStr('TRIBUTE_DESC_2'))
            nameTx1:setColor(COLOR_TYPE.ORANGE)
            nameTx1:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
            occupyImg:setVisible(true)
            if cityTribute[tostring(#self.tab + 1 - i)] then
                gotBgImg:setVisible(true)
            else
                gotBgImg:setVisible(false)
            end
        end

        local size = bgImg1:getContentSize()
        local awards = DisplayData:getDisplayObjs(conf[#self.tab + 1 - i].award)
        for i,v in ipairs(awards) do
            local awardBgImg = bgImg1:getChildByName('award_bg_img_'..i)
            if not awardBgImg then
                local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
                awardBgImg = tab.awardBgImg
                awardBgImg:setName('award_bg_img_'..i)
                bgImg1:addChild(awardBgImg)
                awardBgImg:setAnchorPoint(cc.p(0,0.5))
                local size1 = awardBgImg:getContentSize()
                awardBgImg:setPosition(getPos(i,size,size1))
            end
            ClassItemCell:updateItem(awardBgImg, v, 2)
            local lvTx = awardBgImg:getChildByName('lv_tx')
            lvTx:setVisible(true)
            if stype == 'equip' then
                lvTx:setString('Lv.'..v:getLevel())
            else
                lvTx:setString('x'..v:getNum())
            end
            awardBgImg:setSwallowTouches(false)
            awardBgImg:setTouchEnabled(true)
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    local point1 = sender:getTouchBeganPosition()
                    local point2 = sender:getTouchEndPosition()
                    if point1 then
                        local dis =cc.pGetDistance(point1,point2)
                        if dis <= 5 then
                            GetWayMgr:showGetwayUI(v,false)
                        end
                    end
                end
            end)
        end
    end
    local size = self.sv:getContentSize()
    -- if self.currMax * (self.singleSize.width + self.intervalSize) > size.width then
    --     self.cardSv:setInnerContainerSize(cc.size(size.width,(math.floor((self.currMax - 1)/self.maxNum) + 1) * (self.singleSize.height + self.intervalSize)))
    -- else
    --     self.cardSv:setInnerContainerSize(size)
    -- end
    self.sv:setInnerContainerSize(cc.size(size.width,(singleSize.height + 5)*#self.tab ))
end

function TributeUI:getFightedIds()
    self.tab = {}
    local fighted = MapData:getFightedCityId()
    for i=#MapData.data,1,-1 do
        local cityData = MapData.data[i]
        local type1,type2 = cityData:getType(),cityData:getType1()
        if type1 == 1 and type2 == 2 then
            if i <= fighted then
                self.tab[#self.tab + 1] = {id = i,isPass = true}
            else
                self.tab[#self.tab + 1] = {id = i,isPass = false}
            end
        end
    end
end

function TributeUI:init()
	self.bgImg = self.root:getChildByName("bg_img")
    self.bgImg1 = self.bgImg:getChildByName("bg_img_1")
    self:adaptUI(self.bgImg)
    local winsize = cc.Director:getInstance():getWinSize()
    self.bgImg1:setPosition(cc.p(winsize.width/2,winsize.height/2 - 30))

    local closeBtn = self.bgImg1:getChildByName('close_btn')
    local getBtn = self.bgImg1:getChildByName('get_btn')
    local infoTx = getBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('TRIBUTE_DESC_5'))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideTributePanel()
        end
    end)
    self.bgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hideTributePanel()
        end
    end)
    getBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local conf = GameData:getConfData('citytribute')
            local fightedId = MapData:getFightedCityId()
            local cityTribute = MapData.cityTribute
            local canGet = false
            for i,v in ipairs(conf) do
                if v.cityId <= fightedId and not cityTribute[tostring(i)] then
                    canGet = true
                    break
                end
            end
            if canGet then
                local args = {}
                MessageMgr:sendPost('get_city_tribute','battle',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local awards = response.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end
                        local cityTribute = MapData.cityTribute
                        local tab = {}
                        for i,v in ipairs(conf) do
                            if v.cityId <= fightedId then
                                tab[tostring(i)] = 1
                            end
                        end
                        MapData:setCityTribute(tab)
                        MapMgr:hideTributePanel()
                    end
                end)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TRIBUTE_DESC_4'), COLOR_TYPE.RED)
            end
        end
    end)
    local titleIimg = self.bgImg1:getChildByName('title_img')
    local titleTx = titleIimg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('TRIBUTE_DESC_3'))
    local bgImg1 = self.bgImg1:getChildByName('bg_img1')
    self.sv = bgImg1:getChildByName('info_sv')
    self.sv:setScrollBarEnabled(false)

    self:getFightedIds()
    self:updatePanel()
end

return TributeUI