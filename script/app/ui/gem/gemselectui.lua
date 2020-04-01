local GemSelectUI = class("GemSelectUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local function sortByQuality(arr)
    table.sort(arr, function (a, b)
        local q1 = a:getQuality()
        local q2 = b:getQuality()
        if q1 == q2 then
            local l1 = a:getLevel()
            local l2 = b:getLevel()
            return l1 > l2
        else
            return q1 > q2
        end
    end)
end

function GemSelectUI:ctor(slotIndex, equipObj, callback)
    self.uiIndex = GAME_UI.UI_GEMSELECT
    self.equipObj = equipObj
    self.callback = callback
    self.slotIndex = slotIndex
end

function GemSelectUI:init()
    local gemSelectBgImg = self.root:getChildByName("gem_select_bg_img")
    local gemSelectImg = gemSelectBgImg:getChildByName("gem_select_img")
    self:adaptUI(gemSelectBgImg, gemSelectImg)
    local gemSelect = gemSelectImg:getChildByName("gem_select")
    gemSelect:getChildByName('title_img'):getChildByName('title_txt'):setString(GlobalApi:getLocalStr('GEMSELECT_TITLE'))
    local closeBtn = gemSelectImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)
    local svBg = gemSelect:getChildByName("scroll_bg_img")
    local gemSv = svBg:getChildByName("gem_sv")
    local nogemimg = gemSelect:getChildByName('no_gem_img')
    local titlebg = gemSelect:getChildByName('title_left_img')
    local contentWidget = ccui.Widget:create()
    gemSv:addChild(contentWidget)
    local svSize = gemSv:getContentSize()
    gemSv:setScrollBarEnabled(false)
    contentWidget:setPosition(cc.p(0, svSize.height))
    local allGems = BagData:getAllGems()
    local equipGems = self.equipObj:getGems()
    local showedGemNum = 0
    local currGemNum = 0
    local innerHeight = 0
    local showedGemArr = {}
    local equipedType = {}
    for k2, v2 in pairs(equipGems) do
        equipedType[v2:getType()] = 1
    end
    for k, v in pairs(allGems) do
        if not equipedType[k] then
            for k2, v2 in pairs(v) do
                table.insert(showedGemArr, v2)
                showedGemNum = showedGemNum + 1
            end
        end
    end
    local function createGemItem(obj)
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
        ClassItemCell:updateItem(cell, obj, 1)
        cell.nameTx:setString(obj:getName())
        cell.nameTx:setScale(20/24)
        cell.awardBgImg:setTouchEnabled(true)
        obj:setLightEffect(cell.awardBgImg)
        cell.awardBgImg:addClickEventListener(function ()
            local args = {
                eid = self.equipObj:getSId(),
                gid = obj:getId(),
                slot = self.slotIndex
            }
            MessageMgr:sendPost("fill_gem", "equip", json.encode(args), function (jsonObj)
                local code = jsonObj.code
                if code == 0 then
                    self.equipObj:addGem(self.slotIndex, obj)
                    if self.callback then
                        self.callback()
                    end
                    self:hideUI()
                end
            end)
        end)
        return cell.awardBgImg
    end
    local gemDis = (svSize.width - 100)/3
    local gemHeight = 130
    local function addGems()
        if currGemNum < showedGemNum then -- 每次创建12个
            local currNum = currGemNum
            currGemNum = currGemNum + 16
            currGemNum = currGemNum > showedGemNum and showedGemNum or currGemNum
            local innerHeight
            for i = currNum + 1, currGemNum do
                local gemItem = createGemItem(showedGemArr[i])
                innerHeight = math.ceil(i/4)*gemHeight
                gemItem:setPosition(cc.p(((i-1)%4)*gemDis + 50, 80-innerHeight))
                contentWidget:addChild(gemItem)
            end
            innerHeight = innerHeight < svSize.height and svSize.height or innerHeight
            gemSv:setInnerContainerSize(cc.size(svSize.width, innerHeight))
            contentWidget:setPosition(cc.p(0, innerHeight))
        end
    end
    if showedGemNum > 0 then
        sortByQuality(showedGemArr)
        addGems()
        nogemimg:setVisible(false)
    else
        nogemimg:setVisible(true)
    end
    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            addGems()
        end
    end
    gemSv:addEventListener(scrollViewEvent)
end

return GemSelectUI