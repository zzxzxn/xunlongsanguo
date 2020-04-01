local CountryJadeSuccessUI = class("CountryJadeSuccessUI", BaseUI)

function CountryJadeSuccessUI:ctor(status)
	self.uiIndex = GAME_UI.UI_COUNTRY_JADE_SUCESS_PANEL
	self.status = status
end

function CountryJadeSuccessUI:init()
	local successBgImg = self.root:getChildByName("success_bg_img")
    self.successImg = successBgImg:getChildByName('success_img')
    self:adaptUI(successBgImg,  self.successImg)

	local OKBtn = self.successImg:getChildByName('ok_btn')
	local okTx = OKBtn:getChildByName('ok_tx')
	okTx:setString(GlobalApi:getLocalStr('STR_OK2'))
	OKBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType ==  ccui.TouchEventType.ended then
			CountryJadeMgr:hideCountryJadeSuccessUI()
		end
	end)

	local infoIco = self.successImg:getChildByName('info_ico')
	local infoTx = infoIco:getChildByName('info_tx')    -- ÃèÊö
	infoTx:setString('')

    local lightImg = self.successImg:getChildByName('light_img')
    local lightImg1 = lightImg:getChildByName('light_1_img')

	local textBgIco = self.successImg:getChildByName('text_bg_ico')
	local textIco = textBgIco:getChildByName('text_ico') -- ÎÄ×ÖÍ¼Æ¬
	
    local action = cc.RotateBy:create(3,360)
    lightImg1:runAction(cc.RepeatForever:create(action))

    if self.status == 1 then
        infoTx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES51'))
        textIco:loadTexture("uires/ui/country/jade/hebichenggong.png")
    else
        infoTx:setString(GlobalApi:getLocalStr('COUNTRY_JADE_DES52'))
        textIco:loadTexture("uires/ui/country/jade/yubibeiqiang.png")
        ShaderMgr:setGrayForWidget(lightImg)
        ShaderMgr:setGrayForWidget(lightImg1)
        ShaderMgr:setGrayForWidget(textBgIco)
        ShaderMgr:setGrayForWidget(textIco)
        ShaderMgr:setGrayForWidget(textBgIco:getChildByName('star_1_ico'))
        ShaderMgr:setGrayForWidget(textBgIco:getChildByName('star_2_ico'))
    end
    textIco:setPositionY(textIco:getPositionY() + 2)
end

return CountryJadeSuccessUI