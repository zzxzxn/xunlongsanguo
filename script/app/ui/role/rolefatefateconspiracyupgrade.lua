local RoleFateFateConspiracyUpgradeUI = class('RoleFateFateConspiracyUpgradeUI', BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleFateFateConspiracyUpgradeUI:ctor(type,oldfight,newfightforce,nowLv,func)
	self.uiIndex = GAME_UI.UI_ROLE_FATE_FATE_CONSPIRACY_UPGRADE
	-- logic data
	self.type = type
    self.oldfight = oldfight
    self.newfightforce = newfightforce
    self.nowLv = nowLv
    self.nextLv = nowLv + 1
	self.func = func
	-- ui data
	self.bg_node = nil

    self.fateAdvancedTypeData = GameData:getConfData('fateadvancedtype')[type]
    self.attributeConf = GameData:getConfData('attribute')
    self.fateadvancedConf = GameData:getConfData('fateadvancedconf')
end

function RoleFateFateConspiracyUpgradeUI:init()
	local bg = self.root:getChildByName('bg')
	local bg1 = bg:getChildByName('bg1')
	self.bg_node = bg1

	self:adaptUI(bg, bg1)

    local winSize = cc.Director:getInstance():getWinSize()

   
	local attribute_bg = bg1:getChildByName('upgrade_bg')
		:getChildByName('attribute_bg')

	local upgradebg = bg1:getChildByName('upgrade_bg')
	local titlebg = upgradebg:getChildByName('title_bg')
	local titilename = titlebg:getChildByName('title_tx')

    local nameImg = titlebg:getChildByName('name_img')
    if self.nowLv <= 0 then
        nameImg:loadTexture('uires/ui/fateshow/fateshow_active_img.png')
    else
        nameImg:loadTexture('uires/ui/fateshow/fateshow_upgrade_img.png')
    end

    -- 特殊属性加成
    local richTextAttSpecial = titlebg:getChildByName('reichtext_att_spacial')
    if not richTextAttSpecial then
        local richText = xx.RichText:create()
        richText:setName('reichtext_att_spacial')
	    richText:setContentSize(cc.size(500, 26))

	    local re1 = xx.RichTextLabel:create('', 23,COLOR_TYPE.RED)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create('', 23,COLOR_TYPE.YELLOW)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)

        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0.5,0.5))
	    richText:setPosition(cc.p(148.00,-9))
        titlebg:addChild(richText)

        richText.re1 = re1
        richText.re2 = re2
        richTextAttSpecial = richText
    end
    local fateadvancedData = self.fateadvancedConf[self.type]
    local attSpecialId = self.fateAdvancedTypeData.attSpecialId
    richTextAttSpecial.re1:setString(self.attributeConf[attSpecialId].name)
    richTextAttSpecial.re2:setString(' +' .. fateadvancedData[self.nextLv].attSpecialValue/100 .. '%')
    richTextAttSpecial:format(true)

    -- 属性

	for i = 1, 4 do
        local fateadvancedData = self.fateadvancedConf[self.type]
        local attSpecialId = self.fateAdvancedTypeData['attId' .. i]
		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('tx_1')
			:setString(self.attributeConf[attSpecialId].name)

        local oldValue = 0
        if self.nowLv <= 0 then
            oldValue = 0
        else
            oldValue = fateadvancedData[self.nowLv]['attValue' .. i]
        end
        local newValue = fateadvancedData[self.nextLv]['attValue' .. i]

        attribute_bg:getChildByName('att_' .. i)
			    :getChildByName('num_1')
			    :setString(oldValue)

		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('tx_2')
			:setString(self.attributeConf[attSpecialId].name)

		attribute_bg:getChildByName('att_' .. i)
			:getChildByName('num_2')
			:setString(newValue)

        if newValue - oldValue <= 0 then
            attribute_bg:getChildByName('att_' .. i)
			    :getChildByName('up')
			    :setVisible(false)

	        attribute_bg:getChildByName('att_' .. i)
		        :getChildByName('num_2')
		        :setTextColor(COLOR_TYPE.WHITE)
        end
	end

    -- 属性


	--titilename:setString(self.name)
	self:inithead()
	-- play effect
	AudioMgr.playEffect("media/effect/soldier_upgrade.mp3", false)
	bg1:getChildByName('light')
		:runAction(cc.RepeatForever:create(
			cc.RotateBy:create(0.5, 20)))

	local bg_size = bg:getContentSize()
	bg:getChildByName('press_tx')
		:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
		:setPositionX(bg_size.width / 2)
		:setLocalZOrder(9999)
		:setVisible(false)
	local tip_frame = bg1:getChildByName('tip_frame')
	tip_frame:setPositionY(tip_frame:getPositionY() + 50)
	bg1:setScale(0.1)
	bg1:runAction(cc.Sequence:create(
		cc.ScaleTo:create(0.3, 1), 
		cc.CallFunc:create(function ()
			tip_frame:runAction(cc.Sequence:create(
				cc.JumpBy:create(0.13, cc.p(0, -50), 0, 1),
				cc.JumpBy:create(0.2, cc.p(0, 0), 20, 1),
				cc.JumpBy:create(0.08, cc.p(0, 0), 5, 1),
				cc.CallFunc:create(function ()
					bg:addClickEventListener(function ()
						bg:addClickEventListener(function()end)
							RoleMgr:hideRoleFateFateConspiracyUpgradeUI()
							if self.func ~= nil then
								self.func()
							end
					end)
					bg:getChildByName('press_tx')
						:setVisible(true)
						:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
						:setFontName('font/gamefont.ttf')
						:runAction(cc.RepeatForever:create(
							cc.Sequence:create(cc.FadeOut:create(1.2),
							cc.FadeIn:create(1.2))))
				end)))
		end)))
end

function RoleFateFateConspiracyUpgradeUI:inithead()
	local tip_frame = self.bg_node:getChildByName('tip_frame')
	local name = tip_frame:getChildByName('title_tx')
    name:setString(string.format(GlobalApi:getLocalStr('FATE_SPECIAL_DES2'),self.fateAdvancedTypeData.fateName))

    local frame = tip_frame:getChildByName('frame')
    frame:loadTexture(COLOR_FRAME[tonumber(self.fateAdvancedTypeData.fateIconQuality)])
    local icon = frame:getChildByName('icon')
    icon:loadTexture('uires/icon/fate_icon/' .. self.fateAdvancedTypeData.fateIcon2)

    local lvRichText = tip_frame:getChildByName('reichtext_lv')
    if not lvRichText then
        local richText = xx.RichText:create()
        richText:setName('reichtext_lv')
	    richText:setContentSize(cc.size(200, 26))

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
	    richText:setPosition(cc.p(83.50,38.00))
        tip_frame:addChild(richText)

        richText.re2 = re2
        lvRichText = richText
    end
    lvRichText.re2:setString(self.nextLv)
    lvRichText:format(true)
end

return RoleFateFateConspiracyUpgradeUI