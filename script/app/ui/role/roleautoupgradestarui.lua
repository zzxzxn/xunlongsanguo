local RoleAutoUpgradeStarUI = class("RoleAutoUpgradeStarUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleAutoUpgradeStarUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_AUTOUPGRADESTAR
	self.obj = obj
	self.times = 1
	self.min = 1
	self.maxTimes = RoleMgr:clacUpgradeStarMaxNum(self.obj)
end

function RoleAutoUpgradeStarUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    local bgimg2 = bgimg1:getChildByName('bg_img2')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleAutoUpgradeStar()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg_img')
    local titletx = titlebg:getChildByName('info_tx')
    titletx:setString(GlobalApi:getLocalStr('STR_AUTO_UPGRADESTAR_2'))

    local funcbtn = bgimg2:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('info_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_AUTO_UPGRADESTAR_2'))
    funcbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
    		RoleMgr:sendUpgradeStarMsg(self.obj, self.times, self.curattarr, self.nextattarr, function ()
    			self:update(obj)
    		end)
    		RoleMgr:hideRoleAutoUpgradeStar()
        end
    end)
    self.lessBtn = bgimg2:getChildByName("less_btn")
	self.addBtn = bgimg2:getChildByName("add_btn")
    self.resicon = bgimg2:getChildByName('res_img')
    local diimg = bgimg2:getChildByName('di_img')
	self.costNumTx = diimg:getChildByName('num_tx')
	self.timesTx = bgimg2:getChildByName("times_tx")
	self.editbox = cc.EditBox:create(cc.size(130, 40), 'uires/ui/common/name_bg9.png')
    self.editbox:setPosition(self.timesTx:getPosition())
    self.editbox:setMaxLength(10)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_NUMERIC)
    bgimg2:addChild(self.editbox)
    self.timesTx:setLocalZOrder(2)

    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
    	local edit = pSender
		local strFmt 
		if event == "began" then
			self.editbox:setText(self.times)
			self.timesTx:setString('')
		elseif event == "ended" then
			local num = tonumber(self.editbox:getText())
			if not num then
				self.editbox:setText('')
				self.timesTx:setString('0')
				self.times = 0
				return
			end
			local times = num
			if times > self.maxTimes then
				self.times = self.maxTimes
			elseif times < 1 then
				self.times = 0
			else
				self.times = times
			end
			self.editbox:setText('')
			self:update()
		end
    end)
    self.lessBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           	if self.times > 1 then
           		self.times = self.times - 1
           		self:update()
           	end
        end
    end)

    self.addBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.times < self.maxTimes then
           		self.times = self.times + 1
           		self:update()
           	end
        end
    end)
   	local maxBtn = bgimg2:getChildByName("max_btn")
	local btnTx = maxBtn:getChildByName("info_tx")
	btnTx:setString(GlobalApi:getLocalStr('MAX'))
	maxBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
       		self.times = self.maxTimes
       		self:update()
        end
    end)
    
    self.attneed = {}
    local timesdesctx = bgimg2:getChildByName('times_select_tx')
    timesdesctx:setString(GlobalApi:getLocalStr('STR_AUTO_UPGRADESTAR_3'))

    self.riseStarBtna = bgimg2:getChildByName("rise_btn_a")
    local quality = self.obj:getHeroQuality()
    local conf = GameData:getConfData('heroquality')[quality]
    self.riseStarBtna:loadTextureNormal('uires/ui/role/role_flag_'..conf.quality..'.png')
    for i=1,3 do
        local starBgImg = bgimg2:getChildByName('star_bg_a_'..i..'_img')
        local starImg = bgimg2:getChildByName('star_a_'..i..'_img')
        if conf.quality < 1 then
            starBgImg:setVisible(false)
            starImg:setVisible(false)
        else
            starBgImg:setVisible(true)
            starImg:setVisible(conf.star >= i)
        end
    end
    self.riseStarBtnb = bgimg2:getChildByName("rise_btn_b")
    self.bg = bgimg2
    self:update()
end

function RoleAutoUpgradeStarUI:update()
    if self.maxTimes < 0 then
    	self.maxTimes = 0
    end

    if self.times > self.maxTimes then
    	self.times = self.maxTimes 
    end
    self.timesTx:setString(self.times)
    self.addBtn:setTouchEnabled(true)
	self.addBtn:setBright(true)
	self.lessBtn:setTouchEnabled(true)
	self.lessBtn:setBright(true)
	if self.times <= 1 then
		self.lessBtn:setTouchEnabled(false)
		self.lessBtn:setBright(false)
    end

    if self.times >= self.maxTimes then
		self.addBtn:setTouchEnabled(false)
		self.addBtn:setBright(false)
    end
    self.costNumTx:setString('')
    local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
    local itemobj = BagData:getMaterialById(itemId)
    if not itemobj then
        itemobj = ClassItemObj.new(tonumber(itemId),0)
    end
    self.resicon:loadTexture(itemobj:getIcon())
	local att = RoleData:getPosAttByPos(self.obj)
	self.curattarr = {}
    self.curattarr[1] = math.floor(att[1])
    self.curattarr[2] = math.floor(att[4])
    self.curattarr[3] = math.floor(att[2])
    self.curattarr[4] = math.floor(att[3])
    self.nextattarr = {}
    local objtemp = clone(self.obj)
    objtemp:setHeroQuality(self.obj:getHeroQuality()+self.times)
    local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    self.nextattarr[1] = math.floor(atttemp[1])
    self.nextattarr[2] = math.floor(atttemp[4])
    self.nextattarr[3] = math.floor(atttemp[2])
    self.nextattarr[4] = math.floor(atttemp[3])

    local costobjs = RoleMgr:calcUpgradeStarCost(self.obj,self.obj:getHeroQuality(),self.times)
    self.costNumTx:setString(GlobalApi:toWordsNumber(costobjs[1]:getOwnNum())..'/'..GlobalApi:toWordsNumber(costobjs[1]:getNum()))

    local quality = self.obj:getHeroQuality()+self.times
    local conf = GameData:getConfData('heroquality')[quality]
    self.riseStarBtnb:loadTextureNormal('uires/ui/role/role_flag_'..conf.quality..'.png')
    for i=1,3 do
        local starBgImg = self.bg:getChildByName('star_bg_b_'..i..'_img')
        local starImg = self.bg:getChildByName('star_b_'..i..'_img')
        if conf.quality < 1 then
            starBgImg:setVisible(false)
            starImg:setVisible(false)
        else
            starBgImg:setVisible(true)
            starImg:setVisible(conf.star >= i)
        end
    end

end

return RoleAutoUpgradeStarUI