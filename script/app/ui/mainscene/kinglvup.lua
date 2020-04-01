local KingLvUpUI = class("KingLvUpUI", BaseUI)

function KingLvUpUI:ctor(lastLv,nowLv,delay,callBack)
    self.uiIndex = GAME_UI.UI_KING_LVUP
    self.lastLv = lastLv or 1
    self.nowLv = nowLv or 2
    self.delay = delay or 5
    self.callBack = callBack
end

function KingLvUpUI:init()
    local lastLv = self.lastLv
    local nowLv = self.nowLv
    local delay = self.delay
    UserData:getUserObj().islvChange = false

    local bgImgM = self.root:getChildByName("bg_img")
    local bgImg = bgImgM:getChildByName("bg_img1")
    self.bgImg = bgImg
    self:adaptUI(bgImgM,bgImg)
    bgImg:setTouchEnabled(true)
    bgImg:addClickEventListener(function ()
        self:hideUI()
        if self.callBack then
            self.callBack()
        end
    end)

    local infoLabel = bgImg:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local textBg = bgImg:getChildByName("text_bg")
    local label = textBg:getChildByName("text")
    label:setString(GlobalApi:getLocalStr("KING_LV_UP_LABEL"))

    local img = bgImg:getChildByName("img")
    img:setLocalZOrder(50)

    local lvBg = bgImg:getChildByName("lv_bg")
    local textLv = lvBg:getChildByName("text")

    textLv:setString(nowLv)

    local posX = lvBg:getPositionX()
    local posY = lvBg:getPositionY()

    local size = bgImg:getContentSize()
    local lvUp = GlobalApi:createLittleLossyAniByName('ui_dengjishengji_01')
    --lvUp:setScale(1)
    lvUp:setPosition(cc.p(posX ,posY))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    textBg:setLocalZOrder(200)
    lvBg:setLocalZOrder(201)
    bgImg:addChild(lvUp)
    lvUp:getAnimation():playWithIndex(0, -1, 1)
    

    local line1 = bgImg:getChildByName('line1')
    local line2 = bgImg:getChildByName('line2')
    local line3 = bgImg:getChildByName('line3')

    -- 文字展示
        -- 位置坐标,从上往下，1，2，3
        local pos1Center = {390,230}
        local pos2Center = {390,230 - 40}
        local pos3Center = {390,230 - 40*2}
        local pos1Left = {310,230}
        local pos1Right = {524,230}
        local pos2Left = {310,230 - 40}
        local pos2Right = {524,230 - 40}
        local pos3Left = {310,230 - 40*2}
        local pos3Right = {524,230 - 40*2}

        local richText = {}
        -- 几档加速
        local speedUpLv1 = tonumber(GlobalApi:getGlobalValue("battleSpeedUpLvLimit1"))
	    local speedUpLv2 = tonumber(GlobalApi:getGlobalValue("battleSpeedUpLvLimit2"))
        local speedLv
        if speedUpLv1 == nowLv then
            speedLv = 2
        elseif speedUpLv2 == nowLv then
            speedLv = 3
        end

        if speedLv then
            local richTextRoleLv = xx.RichText:create()
            richTextRoleLv:setLocalZOrder(300)

	        richTextRoleLv:setContentSize(cc.size(500, 40))
	        local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('KING_LV_UPDES3'), 22, COLOR_TYPE.ORANGE)
	        re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re1:setFont('font/gamefont.ttf')

            local re2 = xx.RichTextLabel:create(speedLv, 22, COLOR_TYPE.GREEN)
	        re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re2:setFont('font/gamefont.ttf')

	        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('KING_LV_UPDES7'), 22, COLOR_TYPE.ORANGE)
	        re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
            re3:setFont('font/gamefont.ttf')

	        richTextRoleLv:addElement(re1)
            richTextRoleLv:addElement(re2)
            richTextRoleLv:addElement(re3)

            richTextRoleLv:setAlignment('left')
            richTextRoleLv:setVerticalAlignment('middle')

	        richTextRoleLv:setAnchorPoint(cc.p(0,0.5))
	        richTextRoleLv:setPosition(cc.p(pos1Center[1],pos1Center[2]))
            richTextRoleLv:format(true)
            bgImg:addChild(richTextRoleLv)
            table.insert(richText,richTextRoleLv)
        end

        -- 等级礼包
        local avlevelgiftConfData = GameData:getConfData("avlevelgift")
        for i = 1,#avlevelgiftConfData do
            if avlevelgiftConfData[i].level == nowLv then
                local richTextTemp = self:getRichText(GlobalApi:getLocalStr('KING_LV_UPDES5'),nowLv,pos3Center,true)
                table.insert(richText,richTextTemp)
                break
            end
        end

        -- 上阵武将数
        local levelConfData = GameData:getConfData("level")
        local lastHeroNum = levelConfData[lastLv].heroNum
        local nowHeroNum = levelConfData[nowLv].heroNum
        local addHeroNum = nowHeroNum - lastHeroNum
        if addHeroNum > 0 then
            local richTextTemp = self:getRichText(GlobalApi:getLocalStr('KING_LV_UPDES6'),'+' .. addHeroNum,pos3Center)
            table.insert(richText,richTextTemp)
        end

        -- 君主等级
        local richTextRoleLv = xx.RichText:create()
        richTextRoleLv:setLocalZOrder(300)

	    richTextRoleLv:setContentSize(cc.size(500, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('KING_LV_UPDES1'), 22, COLOR_TYPE.ORANGE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setFont('font/gamefont.ttf')

        local re2 = xx.RichTextLabel:create(' ' .. lastLv .. '   ', 22, COLOR_TYPE.WHITE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setFont('font/gamefont.ttf')

        local re3 = xx.RichTextImage:create('uires/ui/common/arrow5.png')
        re3:setScale(0.5)

        local re4 = xx.RichTextLabel:create(' ' .. nowLv, 22, COLOR_TYPE.GREEN)
	    re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re4:setFont('font/gamefont.ttf')

	    richTextRoleLv:addElement(re1)
        richTextRoleLv:addElement(re2)
        richTextRoleLv:addElement(re3)
        richTextRoleLv:addElement(re4)

        richTextRoleLv:setAlignment('left')
        richTextRoleLv:setVerticalAlignment('middle')

	    richTextRoleLv:setAnchorPoint(cc.p(0,0.5))
	    richTextRoleLv:setPosition(cc.p(pos1Center[1],pos1Center[2]))
        richTextRoleLv:format(true)
        bgImg:addChild(richTextRoleLv)

        -- 等级上限
        local richTextRoleAddLv = self:getRichText(GlobalApi:getLocalStr('KING_LV_UPDES2'),'+' .. nowLv - lastLv,pos2Center)

        local levelConf = GameData:getConfData('level')[nowLv]
        local descs = levelConf.moduleopen
        local descRT
        if #descs > 0 and descs[1] ~= '0' then
            descRT = xx.RichText:create()
            descRT:setContentSize(cc.size(500, 40))
            descRT:setAlignment('left')
            descRT:setVerticalAlignment('middle')
            descRT:setName('desc_rt')
            descRT:setAnchorPoint(cc.p(0,0.5))
            for i=1,#descs do
		        if i ~= 1 then
			        local re1 = xx.RichTextLabel:create('\n',22, COLOR_TYPE.WHITE)
			        re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
			        descRT:addElement(re1)
		        end
		        xx.Utils:Get():analyzeHTMLTag(descRT,descs[i])
	        end
            bgImg:addChild(descRT)
	        descRT:format(true)
            table.insert(richText,descRT)
        end

        if #richText == 0 then
            line3:setVisible(false)
            --richTextRoleLv:setPosition(cc.p(pos2Center[1],pos2Center[2]))
            --richTextRoleAddLv:setPosition(cc.p(pos3Center[1],pos3Center[2]))
        elseif #richText == 1 then
            richText[1]:setPosition(cc.p(pos3Center[1],pos3Center[2]))
        elseif #richText == 2 then
            richText[1]:setPosition(cc.p(pos3Left[1],pos3Left[2]))
            richText[2]:setPosition(cc.p(pos3Right[1],pos3Right[2]))
        elseif #richText == 3 then
            richTextRoleAddLv:setPosition(cc.p(pos2Left[1],pos2Left[2]))
            richText[1]:setPosition(cc.p(pos2Right[1],pos2Right[2]))
            richText[2]:setPosition(cc.p(pos3Left[1],pos3Left[2]))
            richText[3]:setPosition(cc.p(pos3Right[1],pos3Right[2]))
        elseif #richText == 4 then
            richTextRoleLv:setPosition(cc.p(pos1Left[1],pos1Left[2]))
            richTextRoleAddLv:setPosition(cc.p(pos1Right[1],pos1Right[2]))
            richText[1]:setPosition(cc.p(pos2Left[1],pos2Left[2]))
            richText[2]:setPosition(cc.p(pos2Right[1],pos2Right[2]))
            richText[3]:setPosition(cc.p(pos3Left[1],pos3Left[2]))
            richText[4]:setPosition(cc.p(pos3Right[1],pos3Right[2]))
        end


        
    --self:adaptUI(bgImg)
    local act1=cc.DelayTime:create(delay)
	local act2=cc.CallFunc:create(
		function ()
            self:hideUI()
            if self.callBack then
                self.callBack()
            end
		end
	)
	bgImg:runAction(cc.Sequence:create(act1, act2))
end

function KingLvUpUI:getRichText(des,num,pos,back)
    local richTextRoleAddLv = xx.RichText:create()
    richTextRoleAddLv:setLocalZOrder(300)

	richTextRoleAddLv:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(des, 22, COLOR_TYPE.ORANGE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

    local re2
    if num then
        re2 = xx.RichTextLabel:create(num, 22, COLOR_TYPE.GREEN)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setFont('font/gamefont.ttf')
    end

    if not back then
	    richTextRoleAddLv:addElement(re1)
        if re2 then
            richTextRoleAddLv:addElement(re2)
        end
    else
        if re2 then
            richTextRoleAddLv:addElement(re2)
        end
        richTextRoleAddLv:addElement(re1)
    end

    richTextRoleAddLv:setAlignment('left')
    richTextRoleAddLv:setVerticalAlignment('middle')

	richTextRoleAddLv:setAnchorPoint(cc.p(0,0.5))
	richTextRoleAddLv:setPosition(cc.p(pos[1],pos[2]))
    richTextRoleAddLv:format(true)
    self.bgImg:addChild(richTextRoleAddLv)

    return richTextRoleAddLv
end

return KingLvUpUI