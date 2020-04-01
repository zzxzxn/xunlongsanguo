local RoleFateFateConspiracyActiveUI = class("RoleFateFateConspiracyActiveUI", BaseUI)

local function tablefind(value, tab)
	for k , v in pairs (tab) do
		if tonumber(value) == tonumber(v) then
			return true
		end
 	end
 	return false
end

function RoleFateFateConspiracyActiveUI:ctor(type)
	self.uiIndex = GAME_UI.UI_ROLE_FATE_FATE_CONSPIRACY_ACTIVE
    self.type = type
    self.heroIds = {0,0,0,0}
end
 
-- 初始化
function RoleFateFateConspiracyActiveUI:init()
	local bgImg = self.root:getChildByName("exchange_bg_img")
	local exchangeImg = bgImg:getChildByName("exchange_img")
    self.exchangeImg = exchangeImg
    self:adaptUI(bgImg, exchangeImg)

	local closebtn = exchangeImg:getChildByName('close_btn')
	closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
			RoleMgr:hideRoleLvUpOneLevelPannelUI()
	    end
	end)

    self:initTop()
    self:initBottom()
end

function RoleFateFateConspiracyActiveUI:initTop()
    local type = self.type
    local fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[type]
    local attributeConf = GameData:getConfData('attribute')
    local fateadvancedConf = GameData:getConfData('fateadvancedconf')
    local maxLv = #fateadvancedConf[type]

    local topImg = self.exchangeImg:getChildByName('top_img')
    local leftNameTx = topImg:getChildByName('left_name_tx')
    leftNameTx:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES2'),fateAdvancedTypeData.fateName))

    local descTx = topImg:getChildByName('desc_tx')
    descTx:setPositionX(138)
    descTx:setString(fateAdvancedTypeData.attEffDesc)

    local leftImg = topImg:getChildByName('left_img')
    local frame = leftImg:getChildByName('frame')
    frame:loadTexture(COLOR_FRAME[tonumber(fateAdvancedTypeData.fateIconQuality)])
    local icon = frame:getChildByName('icon')
    icon:loadTexture('uires/icon/fate_icon/' .. fateAdvancedTypeData.fateIcon2)

    -- 是否激活
    local nowLv = UserData:getUserObj():getConspiracy()[tostring(type)] or 0
    local notActiveImg = leftImg:getChildByName('not_active_img')

    local reachMaxLvImg = topImg:getChildByName('reach_max_lv_img')
    if nowLv >= maxLv then
        reachMaxLvImg:setVisible(true)
    else
        reachMaxLvImg:setVisible(false)
    end

    if nowLv <= 0 then
        notActiveImg:setVisible(true)
    else
        notActiveImg:setVisible(false)
        -- 左边等级
        local lvRichText = leftImg:getChildByName('reichtext_lv')
        if not lvRichText then
            local richText = xx.RichText:create()
            richText:setName('reichtext_lv')
	        richText:setContentSize(cc.size(200, 40))

	        local re1 = xx.RichTextImage:create('uires/ui/common/lv_art.png')
    
	        local re2 = xx.RichTextLabel:create(100, 22,COLOR_TYPE.WHITE)
	        re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re2:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:setAlignment('middle')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0.5,0.5))
	        richText:setPosition(cc.p(notActiveImg:getPositionX(),notActiveImg:getPositionY() - 8))
            leftImg:addChild(richText)

            richText.re2 = re2
            lvRichText = richText
        end
        lvRichText.re2:setString(nowLv)
        lvRichText:format(true)
    end

    -- 右边属性
    local richTextAttSpecial = topImg:getChildByName('reichtext_att_spacial')
    if not richTextAttSpecial then
        local richText = xx.RichText:create()
        richText:setName('reichtext_att_spacial')
	    richText:setContentSize(cc.size(500, 40))

	    local re1 = xx.RichTextLabel:create('', 22,COLOR_TYPE.RED)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create('', 22,COLOR_TYPE.YELLOW)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

        local re3 = xx.RichTextLabel:create('', 22,cc.c4b(163, 163, 163, 255))
	    re3:setStroke(cc.c4b(0, 0, 0, 255),1)
        re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)

        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(138,136))
        topImg:addChild(richText)

        richText.re1 = re1
        richText.re2 = re2
        richText.re3 = re3
        richTextAttSpecial = richText
    end
    local fateadvancedData = fateadvancedConf[type]
    local attSpecialId = fateAdvancedTypeData.attSpecialId
    richTextAttSpecial.re1:setString(attributeConf[attSpecialId].name)
    local re3Desc = ''
    local nextLv = nowLv + 1
    if nowLv <= 0 then
        richTextAttSpecial.re2:setString(' +' .. 0 .. '%')
        if fateadvancedData[nextLv].attSpecialValue > 0 then
            re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES6'),fateadvancedData[nextLv].attSpecialValue/100) .. '%】'
        end
    else
        richTextAttSpecial.re2:setString(' +' .. fateadvancedData[nowLv].attSpecialValue/100 .. '%')
        if nowLv < maxLv then
            if fateadvancedData[nowLv].attSpecialValue ~= fateadvancedData[nextLv].attSpecialValue then
                re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES7'),nextLv,fateadvancedData[nextLv].attSpecialValue/100) .. '%】'
            end
        end
    end
    richTextAttSpecial.re3:setString(re3Desc)
    richTextAttSpecial:format(true)

    for i = 1,4 do
        local reichtextAtt = topImg:getChildByName('reichtext_att_' .. i)
        if not reichtextAtt then
            local richText = xx.RichText:create()
            richText:setName('reichtext_att_' .. i)
	        richText:setContentSize(cc.size(500, 40))

	        local re1 = xx.RichTextLabel:create('', 20,COLOR_TYPE.WHITE)
	        re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re1:setFont('font/gamefont.ttf')

	        local re2 = xx.RichTextLabel:create('', 20,COLOR_TYPE.GREEN)
	        re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re2:setFont('font/gamefont.ttf')

            local re3 = xx.RichTextLabel:create('', 20,cc.c4b(163, 163, 163, 255))
	        re3:setStroke(cc.c4b(0, 0, 0, 255),1)
            re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
            re3:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:addElement(re3)

            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0,0.5))
	        richText:setPosition(cc.p(138,135 - i * 30))
            topImg:addChild(richText)

            richText.re1 = re1
            richText.re2 = re2
            richText.re3 = re3
            reichtextAtt = richText
        end
        local fateadvancedData = fateadvancedConf[type]
        local attSpecialId = fateAdvancedTypeData['attId' .. i]
        reichtextAtt.re1:setString(attributeConf[attSpecialId].name)
        local re3Desc = ''
        local nextLv = nowLv + 1
        if nowLv <= 0 then
            reichtextAtt.re2:setString(' +' .. 0)
            if fateadvancedData[nextLv]['attValue' .. i] > 0 then
                re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES8'),fateadvancedData[nextLv]['attValue' .. i])
            end
        else
            reichtextAtt.re2:setString(' +' .. fateadvancedData[nowLv]['attValue' .. i])
            if nowLv < maxLv then
                if fateadvancedData[nowLv]['attValue' .. i] ~= fateadvancedData[nextLv]['attValue' .. i] then
                    re3Desc = string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES9'),nextLv,fateadvancedData[nextLv]['attValue' .. i])
                end
            end
        end
        reichtextAtt.re3:setString(re3Desc)
        reichtextAtt:format(true)
    end

end

function RoleFateFateConspiracyActiveUI:initBottom()
    -- 描述
    local descTx = self.exchangeImg:getChildByName('desc_tx')
    local nowLv = UserData:getUserObj():getConspiracy()[tostring(self.type)] or 0
    local fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[self.type]
    local fateadvancedConf = GameData:getConfData('fateadvancedconf')
    local maxLv = #fateadvancedConf[self.type]
    print('====================++++++++++++++++++++' .. maxLv)

    if nowLv >= maxLv then
        descTx:setVisible(true)
        local reichtextAtt = self.exchangeImg:getChildByName('reichtext_desc')
        if reichtextAtt then
            reichtextAtt:setVisible(false)
        end
        descTx:setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES20'))
    elseif nowLv <= 0 then
        descTx:setVisible(true)
        local reichtextAtt = self.exchangeImg:getChildByName('reichtext_desc')
        if reichtextAtt then
            reichtextAtt:setVisible(false)
        end
        descTx:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES12'),fateAdvancedTypeData.desc,GlobalApi:getLocalStr('FATE_SPECIAL_DES21')))
    else
        descTx:setVisible(false)

        local reichtextAtt = self.exchangeImg:getChildByName('reichtext_desc')
        if not reichtextAtt then
            local richText = xx.RichText:create()
            richText:setName('reichtext_desc')
	        richText:setContentSize(cc.size(500, 26))

	        local re1 = xx.RichTextLabel:create('', 20,COLOR_TYPE.WHITE)
	        re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re1:setFont('font/gamefont.ttf')
  
	        local re2 = xx.RichTextImage:create('uires/ui/common/lv_art.png')

            local re3 = xx.RichTextLabel:create('', 20,COLOR_TYPE.WHITE)
	        re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re3:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
            re3:setFont('font/gamefont.ttf')

	        richText:addElement(re1)
	        richText:addElement(re2)
            richText:addElement(re3)

            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0,0.5))
	        richText:setPosition(cc.p(descTx:getPositionX(),descTx:getPositionY()))
            self.exchangeImg:addChild(richText)

            richText.re1 = re1
            richText.re2 = re2
            richText.re3 = re3
            reichtextAtt = richText
        end
        reichtextAtt:setVisible(true)

        reichtextAtt.re1:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES12'),fateAdvancedTypeData.desc,GlobalApi:getLocalStr('FATE_SPECIAL_DES22')))
        reichtextAtt.re3:setString(nowLv + 1)
        reichtextAtt:format(true)
    end

    local uplvBtn = self.exchangeImg:getChildByName('uplv_btn')
    uplvBtn:getChildByName('func_tx'):setString(GlobalApi:getLocalStr('FATE_SPECIAL_DES10'))

	uplvBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            local nowLv = UserData:getUserObj():getConspiracy()[tostring(self.type)] or 0
            if nowLv >= maxLv then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FATE_SPECIAL_DES17'), COLOR_TYPE.RED)
                return
            end

            local num = 0
            for i = 1,4 do
                if self.heroIds[i] > 0 then
                    num = num + 1
                end
            end
            if num < 4 then
                if nowLv <= 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FATE_SPECIAL_DES19'), COLOR_TYPE.RED)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FATE_SPECIAL_DES18'), COLOR_TYPE.RED)
                end
                return
            end

            promptmgr:showMessageBox(GlobalApi:getLocalStr("FATE_SPECIAL_DES23"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()               
                local args = {
                    fateType = self.type,
                    heroIds = self.heroIds
                }
	            MessageMgr:sendPost('conspiracy','hero',json.encode(args),function (response)
	                local code = response.code
	                local data = response.data
	                if code == 0 then
                        local oldfight = RoleData:getFightForce()
		                if data.awards then
		            	    GlobalApi:parseAwardData(data.awards)
		                end
		                if data.costs then
		            	    GlobalApi:parseAwardData(data.costs)
		                end
                        local nowLv = UserData:getUserObj():getConspiracy()[tostring(self.type)] or 0
                        UserData:getUserObj():getConspiracy()[tostring(self.type)] = nowLv + 1
                        RoleData:setAllFightForceDirty()
                        for j= 1, 7 do
                            local obj = RoleData:getRoleByPos(j)
                            if obj and obj:getId() > 0 then
                                RoleMgr:popupTips(obj, true)
                            end
                        end
                        local newfightforce = RoleData:getFightForce()
                        local function callBack()
                            RoleMgr:popupFateConspiracyTips(self.type,nowLv,nowLv + 1,oldfight,newfightforce)
                            self.heroIds = {0,0,0,0}
                            self:initTop()
                            self:initBottom()
                        end
                        RoleMgr:showRoleFateFateConspiracyUpgradeUI(self.type,oldfight,newfightforce,nowLv,callBack)
                    end
	            end)
			end)

	    end
	end)

    for i = 1,4 do
        local frame = self.exchangeImg:getChildByName('frame_' .. i)
        self:updateCell(i,frame)
    end
end

function RoleFateFateConspiracyActiveUI:updateCell(i,frameBg)
    local fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[self.type]

    local icon = frameBg:getChildByName('icon')
    local titleTx = frameBg:getChildByName('title_tx')
    titleTx:setString(fateAdvancedTypeData.fateName)
    local addImg = frameBg:getChildByName('add_img')

    local id = self.heroIds[i]
    if id > 0 then  -- 有武将
        addImg:setVisible(false)
        titleTx:setVisible(false)
        local awardData = {{'fragment',tostring(id),1}}
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]
        icon:loadTexture(awards:getIcon())

        --xyh
        --新增阵营图标：1神、2妖、3人、4佛、5主角
        local campType = GameData:getConfData("hero")[id].camp
        if campType ~= 5 and campType then 
            local imgCamp = ccui.ImageView:create('uires/ui/common/camp_'..campType..'.png')
            imgCamp:setScale(0.6)
            imgCamp:addTo(icon ,1)
            imgCamp:setPosition(cc.p(10 ,10))
        end


        frameBg:loadTexture(awards:getBgImg())
    else
        addImg:setVisible(true)
        titleTx:setVisible(true)
        frameBg:loadTexture('uires/ui/common/frame_default.png')

        local fateHeroId = fateAdvancedTypeData.fateHeroId
        local allcards = BagData:getAllCards()
        local judge = false
        for k, v in pairs(allcards) do
		    if v:getId() < 10000 and tablefind(v:getId(),fateHeroId) then        
                local obj = BagData:getCardById(v:getId())
                local num = obj:getNum()
                for j = 1,4 do
                    if self.heroIds[j] == v:getId() then
                        num = num - 1
                    end
                end
                if self.heroIds[i] == v:getId() then
                    num = num + 1
                end
                if num > 0 then
		            judge = true
                    break
                end
		    end
	    end
        if judge == true then   -- 有武将
            addImg:loadTexture('uires/ui/common/add_01.png')
        else    
            addImg:loadTexture('uires/ui/common/add_02.png')
        end
        icon:loadTexture('uires/ui/fateshow/fateshow_' .. fateAdvancedTypeData.fateIcon1)
    end

    frameBg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
		if eventType == ccui.TouchEventType.ended then
            local function callBack(heroIds)
                self.heroIds = heroIds
                for i = 1,4 do
                    local frame = self.exchangeImg:getChildByName('frame_' .. i)
                    self:updateCell(i,frame)
                end
            end
			RoleMgr:showRoleFateFateConspiracyChooseHerolPannel(self.type,self.heroIds,i,callBack)
	    end
	end)
end

return RoleFateFateConspiracyActiveUI