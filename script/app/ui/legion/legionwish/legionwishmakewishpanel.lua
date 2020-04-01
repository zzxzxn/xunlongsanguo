local LegionWishMakeWishPanelUI = class("LegionWishMakeWishPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local CHOOSE_NOMRL = 'uires/ui/common/common_bg_5.png'
local CHOOSE_PRESS = 'uires/ui/common/common_bg_27.png'

local function tablefind(value, tab)
	for k , v in pairs (tab) do
		if tonumber(value) == tonumber(v) then
			return true
		end
 	end
 	return false
end

function LegionWishMakeWishPanelUI:ctor()
	self.uiIndex = GAME_UI.UI_LEGION_WISH_MAKE_WISH
    self.wishItems = {}
    self.selectId = 0
end

function LegionWishMakeWishPanelUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local bgImg1 = bgImg:getChildByName('bg_img1')
    self.bgImg1 = bgImg1
    self:adaptUI(bgImg, bgImg1)

    local closebtn = bgImg1:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:hideLegionWishMakeWishPanelUI()
        end
    end)

    local titleBg = bgImg1:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC10'))

    self:initTop()
    self:initBottom()
    self:refreshChoose()
end

function LegionWishMakeWishPanelUI:initTop()
    local topImg = self.bgImg1:getChildByName('top_img')
    local sv = topImg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local noWishTx = topImg:getChildByName('no_wish_tx')

    local roleId = {}
    local cardId = {}
    local listId = {}

    local roleTab = RoleData:getRoleMap()
    for k, v in pairs(roleTab) do
    	if tonumber(v:getId()) ~= 0 and not v:isJunZhu() and tonumber(v:getId()) < 10000 and v.quality > 3 and v.quality <= 7 then
    		table.insert(roleId, tonumber(v:getId()))
    	end 
    end

    local cardTab = BagData:getAllCards()
    for k, v in pairs(cardTab) do
        if tonumber(v:getId()) ~= 0 and not v:isJunZhu() and tonumber(v:getId()) < 10000 and v.quality > 3 and v.quality <= 7 then
            table.insert(cardId, tonumber(v:getId()))
        end
    end

    listId = cardId

    local fragmentTab = BagData:getFragment()
    for k, v in pairs(fragmentTab) do
        local quality = GameData:getConfData("item")[tonumber(v:getId())].quality
        if tonumber(v:getId()) ~= 0 and tonumber(v:getId()) < 10000 and quality > 3 and quality <= 7 and not tablefind(tonumber(v:getId()), cardId) then
            local wishLimit = LegionWishMgr:getLegionConfDataByQuality(quality).wishLimit
            if v:getNum() >= wishLimit then
                table.insert(listId, tonumber(v:getId()))
            end
        end
    end

    table.sort(listId, function (rid1, rid2)
     	local rObj1 = RoleData:getRoleInfoById(rid1)
     	local rObj2 = RoleData:getRoleInfoById(rid2)
    	local quality1 = rObj1:getRealQulity()
    	local quality2 = rObj2:getRealQulity()
    	if quality1 > quality2 then
    		return true
        end
    end)

    table.sort(roleId, function (rid1, rid2)
     	local rObj1 = RoleData:getRoleInfoById(rid1)
     	local rObj2 = RoleData:getRoleInfoById(rid2)
    	local quality1 = rObj1:getRealQulity()
    	local quality2 = rObj2:getRealQulity()
    	if quality1 > quality2 then
    		return true
        end
    end)

    local listViewId = roleId
    for k, v in pairs(listId) do
        if not tablefind(v, roleId) then
            table.insert(listViewId, v)
        end
    end

	table.sort(listViewId, function (rid1, rid2)
     	local rObj1 = RoleData:getRoleInfoById(rid1)
     	local rObj2 = RoleData:getRoleInfoById(rid2)
    	local quality1 = rObj1:getRealQulity()
    	local quality2 = rObj2:getRealQulity()
    	if quality1 > quality2 then
    		return true
        end
    end)

    self.listViewId = listViewId
    local num = #listViewId
    if num <= 0 then
        sv:setVisible(false)
        noWishTx:setVisible(true)
        noWishTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC15'))
    else
        sv:setVisible(true)
        noWishTx:setVisible(false)
        local cell = sv:getChildByName('cell')
        cell:setVisible(false)

        local size = sv:getContentSize()
        local innerContainer = sv:getInnerContainer()
        local allWidth = size.width
        local cellSpaceX = 10
        local cellSpaceY = 10

        local realNum = math.ceil(num/2)
        local width = realNum * cell:getContentSize().width + (realNum - 1)*cellSpaceX
        if num > 5 then
            if width > size.width then
                innerContainer:setContentSize(cc.size(width,size.height))
                allWidth = width
            else
                allWidth = size.width
                innerContainer:setContentSize(size)
            end
        else
            allWidth = size.width
            innerContainer:setContentSize(size)
        end

        local tempWidth = cell:getContentSize().width
        for i = 1,num,1 do
            local tempCell = cell:clone()
            tempCell:setVisible(true)
            local size = tempCell:getContentSize()
        
            local posX = 0
            if i ~= 1 and i ~= 2 then
                local xOffset = math.ceil(i/2)
                posX = (xOffset - 1) * (cell:getContentSize().width + cellSpaceX)
            end

            local poxY = 0
            if i % 2 == 1 then
                poxY = cell:getContentSize().height + cellSpaceY
            end

            tempCell:setPosition(cc.p(posX,poxY))
            sv:addChild(tempCell)
            local id = listViewId[i]
            table.insert(self.wishItems,tempCell)
            self:updateItem(i,tempCell,id)
        end
        innerContainer:setPositionX(0)
    end
end

function LegionWishMakeWishPanelUI:updateItem(i,tempCell,id)
    tempCell.selectId = i
    tempCell.id = id
    tempCell.bg = tempCell
    tempCell.guangImg = tempCell:getChildByName('guang_img')

    local icon = tempCell:getChildByName('icon')
    local nameTx = tempCell:getChildByName('name_tx')

    local awardData = {{'fragment',tostring(id),1}}
    local disPlayData = DisplayData:getDisplayObjs(awardData)
    local awards = disPlayData[1]
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,icon)
    cell.awardBgImg:setTouchEnabled(false)
    cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    cell.awardBgImg:loadTexture(awards:getBgImg())
    cell.chipImg:setVisible(true)
    cell.chipImg:loadTexture(awards:getChip())
    cell.lvTx:setString('x'..awards:getNum())
    cell.awardImg:loadTexture(awards:getIcon())
    local godId = awards:getGodId()
    awards:setLightEffect(cell.awardBgImg)

    local roleObj = RoleData:getRoleInfoById(id)
    nameTx:setString(roleObj:getName())
    nameTx:setColor(awards:getNameColor())
    nameTx:enableOutline(awards:getNameOutlineColor(),1)

    tempCell:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectId == i then
                return
            end
            self.selectId = i
            self:refreshChoose()
        end
    end)

    local quality = roleObj:getQuality()
    local wishFragmentMax = LegionWishMgr:getLegionConfDataByQuality(quality).wishFragmentMax
    cell.lvTx:setString('x'..wishFragmentMax)
end

function LegionWishMakeWishPanelUI:initBottom()
    local descTx1 = self.bgImg1:getChildByName('desc_tx_1')
    descTx1:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC11'))
	local legionWishConf = GameData:getConfData('legionwishconf')
    for i = 1,#legionWishConf do
        local desc = self.bgImg1:getChildByName('desc_' .. i)
        local descConditonTx = self.bgImg1:getChildByName('desc_conditon_tx_' .. i)
        desc:setString(GlobalApi:getLocalStr('LEGION_WISH_COLOR_' .. i))

        descConditonTx:setString(string.format(GlobalApi:getLocalStr('LEGION_WISH_DESC12'),legionWishConf[i].wishLimit))
    end

    local remainNumDesc = self.bgImg1:getChildByName('remain_num_desc')
    remainNumDesc:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC13'))

    local remainNumTx = self.bgImg1:getChildByName('remain_num_tx')
    local remainNum = LegionWishMgr:getLeigionWishTimes() - LegionWishMgr:getOwnNum()
    remainNumTx:setString(remainNum)
    if remainNum <= 0 then
        remainNumTx:setString(0)
        remainNumTx:setColor(COLOR_TYPE.RED)
    else    
        remainNumTx:setColor(COLOR_TYPE.WHITE)
    end

    local wishBtn = self.bgImg1:getChildByName('wish_btn')
    local funcTx = wishBtn:getChildByName('func_tx')
    funcTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC14'))
    wishBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.selectId == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC23'), COLOR_TYPE.RED)
                return
            end

            if LegionWishMgr:getLeigionWishTimes() - LegionWishMgr:getOwnNum() <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC24'), COLOR_TYPE.RED)
                return
            end

            local args = {id = self.listViewId[self.selectId]}
            MessageMgr:sendPost('wish','legion',json.encode(args),function (response)
                local code = response.code
		        local data = response.data
		        if code == 0 then
                    LegionWishMgr:setLegionOwnData(LegionWishMgr:getOwnNum() + 1)
	                local legionWishData = LegionWishMgr:getLegionWishData()
                    if not legionWishData.own_wish[tostring(UserData:getUserObj():getUid())] then
                        local progress = {}
                        progress.fragment = self.listViewId[self.selectId]
                        progress.has_got = 0
                        progress.has_collect = 0
                        legionWishData.own_wish[tostring(UserData:getUserObj():getUid())] = {}
                        legionWishData.own_wish[tostring(UserData:getUserObj():getUid())][tostring(1)] = progress
                    end
                    LegionWishMgr:setDirty(true)
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_WISH_DESC25'), COLOR_TYPE.GREEN)
                    LegionWishMgr:hideLegionWishMakeWishPanelUI()
                else
                    LegionWishMgr:popWindowErrorCode(code)
		        end
	        end)

        end
    end)

    if #self.listViewId <= 0 or remainNum <= 0 then
        ShaderMgr:setGrayForWidget(wishBtn)
        funcTx:setColor(COLOR_TYPE.GRAY)
        funcTx:enableOutline(COLOR_TYPE.BLACK)
        wishBtn:setTouchEnabled(false)
    end
end

function LegionWishMakeWishPanelUI:refreshChoose()
    for i = 1,#self.wishItems do
        if self.wishItems[i].selectId == self.selectId then
            self.wishItems[i].guangImg:setVisible(true)
        else
            self.wishItems[i].guangImg:setVisible(false)
        end
        self.wishItems[i].bg:loadTexture(CHOOSE_PRESS)
    end
end

return LegionWishMakeWishPanelUI