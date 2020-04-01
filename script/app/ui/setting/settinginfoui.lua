
local SettingInfoUI = class("SettingInfoUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function SettingInfoUI:ctor(obj,callback)
	self.uiIndex = GAME_UI.UI_SETTINGINFO
	self.callback = callback
	self.frameBg=""
	--UserData:getUserObj().headId=1
	self.conf = GameData:getConfData('settingheadicon')
end

function SettingInfoUI:onShow()
	self:updatePanel()
end

function SettingInfoUI:updatePanel()
	print("***************** SettingInfoUI:updatePanel headId = "..UserData:getUserObj().headpic)
	self.icon:loadTexture(UserData:getUserObj():getHeadpic())	
	self.nameTx:setString(UserData:getUserObj():getName())
	self.headframe:loadTexture(UserData:getUserObj():getHeadFrame())
end	

function SettingInfoUI:init()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))
	
	--title
	local titleBgImg = bg2:getChildByName('title_img')
	local infoTx = titleBgImg:getChildByName('tx')
	infoTx:setString(GlobalApi:getLocalStr('SETTING_INFO_TITLE'))
	
	--change name button
	local changeNameBtn = bg2:getChildByName('changename_btn')
	local tx = changeNameBtn:getChildByName('tx')
	tx:setString(GlobalApi:getLocalStr('SETTING_INFO_BTN1'))
	changeNameBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:showSettingChangeName()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--change head button
	local changeHeadBtn = bg2:getChildByName('changehead_btn')
	local tx = changeHeadBtn:getChildByName('tx')
	tx:setString(GlobalApi:getLocalStr('SETTING_INFO_BTN2'))
	changeHeadBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:showSettingChangeHead()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--exchange button
	local userObj = UserData:getUserObj()
	local exchangeBtn = bg2:getChildByName('exchange_btn')
	if userObj:isOpenCDKey() then
		local tx = exchangeBtn:getChildByName('tx')
		tx:setString(GlobalApi:getLocalStr('SETTING_INFO_BTN3'))
		exchangeBtn:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.ended then
				SettingMgr:showSettingExchange()
				AudioMgr.PlayAudio(11)
		    end
		end)
	else
		exchangeBtn:setVisible(false)
	end
	
	--system set button
	local systemBtn = bg2:getChildByName('system_btn')
	local tx = systemBtn:getChildByName('tx')
	tx:setString(GlobalApi:getLocalStr('SETTING_INFO_BTN4'))
	systemBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:showSettingSystem()
			AudioMgr.PlayAudio(11)
	    end
	end)

	local exchangeheadframeBtn = bg2:getChildByName('changehead_frame_btn')
	local tx = exchangeheadframeBtn:getChildByName('tx')
	tx:setString(GlobalApi:getLocalStr('SETTING_INFO_BTN5'))
	exchangeheadframeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:showSettingChangeHeadFrame()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	--info panel
	local contentPanel = bg2:getChildByName('contentPanel')
	local lvconf  = GameData:getConfData('level')
	
	--head icon
	for k, v in pairs(RoleData:getRoleMap()) do   
        if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== true then    
            self.frameBg=v:getBgImg()
        end 
    end

    local iconNode = contentPanel:getChildByName('icon_node')
    local iconCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    iconNode:addChild(iconCell.awardBgImg)

	self.iconBg = iconCell.awardBgImg
	self.headframe = iconCell.headframeImg
	self.iconBg:loadTexture(self.frameBg)
	self.headframe:loadTexture(UserData:getUserObj():getHeadFrame())
	self.headframe:setVisible(true)
	self.icon = iconCell.awardImg
	
	self.nameTx = contentPanel:getChildByName('name_tx')
	local levelTx = contentPanel:getChildByName('level_tx')
	local guildNameTx = contentPanel:getChildByName('gulidName')
	local guildLvTx = contentPanel:getChildByName('gulidLv')
	local serverNameTx = contentPanel:getChildByName('serverName')
	local userIdTx = contentPanel:getChildByName('userId')
	--self.nameTx:setString(UserData:getUserObj():getName())
    levelTx:setString(GlobalApi:getLocalStr('SETTING_INFO_LV')..UserData:getUserObj():getLv())
	
	local guildNameStr=""
	local guildLvStr=""
	if UserData:getUserObj():getLid() > 0 then
		guildNameStr=UserData:getUserObj().lname
		guildLvStr=UserData:getUserObj().llevel
	else
		guildNameStr=GlobalApi:getLocalStr('SETTING_INFO_EMPTY')
		guildLvStr=GlobalApi:getLocalStr('SETTING_INFO_EMPTY')
	end
	guildNameTx:setString(GlobalApi:getLocalStr('SETTING_INFO_GUILDNAME')..guildNameStr)
	guildLvTx:setString(GlobalApi:getLocalStr('SETTING_INFO_GUILDLEVEL')..guildLvStr)
	
	local serverId=GlobalData:getSelectSeverUid()
	local tab = GlobalData:getServerInfoById(serverId)
	serverNameTx:setString(GlobalApi:getLocalStr('SETTING_INFO_SERVERNAME')..tab.name)
	userIdTx:setString(GlobalApi:getLocalStr('SETTING_INFO_USERID')..GlobalData:getSelectUid())
	
	local expBar=contentPanel:getChildByName('expBar')
    expBar:setScale9Enabled(true)
    expBar:setCapInsets(cc.rect(10,15,1,1))

	local expVal=expBar:getChildByName('expVal')
	local curExp=userObj:getXp()
	local lvExp=lvconf[userObj:getLv()]['exp']
	expVal:setString(curExp.."/"..lvExp)
	expBar:setPercent(curExp/lvExp*100)
	
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingInfo()
			AudioMgr.PlayAudio(11)
	    end
	end)

	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
	
	self:updatePanel()
end

function SettingInfoUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bg1")
	local panel=ccui.Helper:seekWidgetByName(bg1,"bg2")
     panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
     panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
            self:hideUI()
            if(call ~= nil) then
                return call()
            end
        end)))
end

return SettingInfoUI