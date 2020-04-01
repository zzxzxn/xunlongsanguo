local PeopleKingSuitBuffUI = class("PeopleKingSuitBuffUI", BaseUI)

local iconRes = "uires/ui/peopleking/peopleking_"
function PeopleKingSuitBuffUI:ctor(weaponStage,wingStage)
    self.uiIndex = GAME_UI.UI_PEOLPLE_KING_SUIT_BUFF

    self.peopleKingData = UserData:getUserObj():getPeopleKing()
    self.weaponStage = self.peopleKingData.weapon_level or 0
    self.wingStage = self.peopleKingData.wing_level or 0

end

function PeopleKingSuitBuffUI:init()

	local bg_img = self.root:getChildByName("bg_img")
    local bg_img1 = bg_img:getChildByName("bg_img1")
    self:adaptUI(bg_img, bg_img1)

    local suitConf = GameData:getConfData("skybuff")
    local attrCfg = GameData:getConfData("attribute")

    local titleBg = bg_img1:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_5"))

    local innerbg = bg_img1:getChildByName("inner_bg")
    for i=1,2 do
    	local desc = innerbg:getChildByName("desc_tx"..i)
    	desc:setString(GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_"..i))
    end
    local stagenumTx = innerbg:getChildByName("desc_num_tx")
    local curStage = 0
    if self.weaponStage == self.wingStage then
    	curStage = self.weaponStage
    else
    	curStage = self.weaponStage < self.wingStage and self.weaponStage or self.wingStage
    end
    if curStage < 0 then
    	curStage = 0
    end

    local nextstageNum = curStage + 1
    local maxStage = #suitConf
    if nextstageNum > maxStage then
    	nextstageNum = maxStage
    end
    stagenumTx:setString(nextstageNum)

    for i=1,2 do
    	local progressbg = innerbg:getChildByName("progress_bg"..i)
    	local iconFrame = progressbg:getChildByName("icon_frame")
    	local icon = iconFrame:getChildByName("icon")
    	local resName = i==1 and "weapon.png" or "wing.png"
    	icon:loadTexture(iconRes..resName)
    	local nameTx = progressbg:getChildByName("name_tx")
    	local nameStr = i==1 and GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_3") or GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_4")
    	nameTx:setString(nameStr)

    	local progressnum = i==1 and self.weaponStage or self.wingStage
    	local barBg = progressbg:getChildByName("bar_bg")
    	local barTx = barBg:getChildByName("tx")
    	local bar = barBg:getChildByName("bar")
    	barTx:setString("Lv "..progressnum.."/"..nextstageNum)
    	local percent = math.floor(progressnum/nextstageNum*100)
        bar:setPercent(percent)
    end
    print("curStage" ,curStage)
    --属性展示
    local isMax = (curStage == maxStage) and true or false
    local img = innerbg:getChildByName("Image_1")
    img:setVisible(not isMax)
    local innerbgSize = innerbg:getContentSize()
    for i=1,2 do
    	local nameTx = innerbg:getChildByName("name_tx"..i)
    	local stagenum = (i==1) and curStage or nextstageNum
    	nameTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_SUIT_DESC_5") .. " Lv."..stagenum)

    	local deltaX = 0
    	if i==1 then
    		local posX = nameTx:getPositionX()
    		deltaX = innerbgSize.width/2-posX
    		if isMax then
    			nameTx:setPositionX(innerbgSize.width/2)
    		end
    	else
    		nameTx:setVisible(not isMax)
    	end
    	
    	for j=1,2 do
    		local attrNameTx = innerbg:getChildByName("attr_name_tx"..i.."_"..j)
    		local attrValueTx = innerbg:getChildByName("attr_value_tx"..i.."_"..j)
    		local attrId = suitConf[stagenum].att[j]
    		local attrvalue = suitConf[stagenum].value[j] or 0
    		if attrCfg[attrId] then
    			attrNameTx:setString(attrCfg[attrId].name)
    			attrValueTx:setString("+"..attrvalue.."%") 
    		end

    		if isMax then
    			if i==1 then
    				local attrnamePosX = attrNameTx:getPositionX() + deltaX
    				local attrValuePosX = attrValueTx:getPositionX() + deltaX
    				attrNameTx:setPositionX(attrnamePosX)
    				attrValueTx:setPositionX(attrValuePosX)
    			else
    				attrNameTx:setVisible(false)
    				attrValueTx:setVisible(false)
    			end
    		end
    	end
    end

    local close_btn = bg_img1:getChildByName("close_btn")
    close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            PeopleKingMgr:hidePeopleKingSuitBuffUI()
        end
    end)
end

return PeopleKingSuitBuffUI