local RolePromotedUI = class("RolePromotedUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local roleanim ={
		'attack',
		'run',
		'skill1',
		'skill2',
		'shengli'
	}
local herochangeconf = GameData:getConfData('herochange')
local MAXPROTYPE = #herochangeconf

local PRESSBG   = 'uires/ui/role/role_promoted_sel.png'
local DISBG = 'uires/ui/role/role_promoted_dis.png'

function RolePromotedUI:ctor(pos)
	self.uiIndex = GAME_UI.UI_ROLE_PROMOTED_PANEL
    self.obj = RoleData:getRoleByPos(pos)
    self.currHid = 0  
    self.lv = 0
	self.protype = 0
	self.promote = self.obj:getPromoted()
	if self.promote and self.promote[1] then
		self.protype = self.promote[1]
		self.lv = self.promote[2]
	end
end

function RolePromotedUI:init()
	self.bgimg = self.root:getChildByName("bg_img1")
	local bgimg1 = self.bgimg:getChildByName("bg_img2")
	local winSize = cc.Director:getInstance():getVisibleSize()
	local closeBtn = self.bgimg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRolePromotedUI()
        end
    end)
    closeBtn:setPosition(cc.p(winSize.width,winSize.height))
    bgimg1:setPosition(cc.p(winSize.width/2,winSize.height/2))
    local topimg = self.bgimg:getChildByName('bg_top')
    topimg:setPosition(cc.p(winSize.width/2,winSize.height))
    local titletx =self.bgimg:getChildByName('title_tx')
    titletx:setPosition(cc.p(30,winSize.height-30))
    titletx:setString(GlobalApi:getLocalStr('ROLE_DESC12'))
    local helpbtn = self.bgimg:getChildByName('help_btn')
    helpbtn:setPosition(cc.p(180,winSize.height-30))
    helpbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(HELP_SHOW_TYPE.ROLEPROMOTED)
        end
    end)

    self.objarr = {}
    local num = 0
	for k, v in pairs(RoleData:getRoleMap()) do
		if  v:getId() < 10000 and v:getId() > 0  and v:isJunZhu()== false and v:getRealQulity() >= tonumber(GlobalApi:getGlobalValue('promoteQualityLimit'))  then
			num = num + 1
			self.objarr[num] = v	
		end
	end
    local bgmid = bgimg1:getChildByName('bg_mid')
    self.qimg = bgmid:getChildByName('quan_img')
    self.leftpl = bgmid:getChildByName('left_pl')
    self:initleft()
    self.rightpl = bgmid:getChildByName('right_pl')
    self:initright()
	self.beginPoint = cc.p(0,0)
	self.endPoint = cc.p(0,0)
    self.bottompl = bgmid:getChildByName('bottom_pl')
    self:initbottom()
    self:createAnimation()
    self.obj:playSound('sound')
    RoleMgr:setCurHeroChange(false)
    if self.lv >= 1 then
	    self.lvpl:runAction(cc.RotateBy:create(0.1, (self.lv-1)*24))
	end
    self:update()
end

function RolePromotedUI:onShow()
	self:update()
	self.newImg:setVisible(RechargeMgr.vipChanged)
end

function RolePromotedUI:initleft()
    local probtn = self.leftpl:getChildByName('pro_btn')
    probtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:changePos(self.obj:getPosId(),false)
        end
    end)
    local nextbtn = self.leftpl:getChildByName('next_btn')
    nextbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:changePos(self.obj:getPosId(),true)
        end
    end)
    self.nametx = self.leftpl:getChildByName('name_tx')
    self.tagimg = self.leftpl:getChildByName('tab_img')
    local infobg = self.leftpl:getChildByName('info_bg')
    self.infotx = infobg:getChildByName('info_tx')
    self.infotx:setString('')
    self.richText = xx.RichText:create()
	self.richText:setContentSize(cc.size(500, 30))
	self.richText:setAlignment('middle')
	local tx1 = GlobalApi:getLocalStr('ROLE_DESC15')
	local tx2 = 0
	local tx3 = GlobalApi:getLocalStr('ROLE_DESC27')
	self.re1 = xx.RichTextLabel:create(tx1,26,COLOR_TYPE.WHITE)
	self.re1:setFont('font/gamefont.ttf')
	self.re2 = xx.RichTextLabel:create(tx2,26,COLOR_TYPE.GREEN)
	self.re2:setFont('font/gamefont.ttf')
	self.re3 = xx.RichTextLabel:create(tx3,26,COLOR_TYPE.WHITE)
	self.re3:setFont('font/gamefont.ttf')
	self.re4 = xx.RichTextLabel:create(tx3,26,COLOR_TYPE.WHITE)
	self.re4:setFont('font/gamefont.ttf')
	self.re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.richText:addElement(self.re1)
	self.richText:addElement(self.re2)
	self.richText:addElement(self.re3)
	self.richText:addElement(self.re4)
	self.richText:setVerticalAlignment('middle')
    self.richText:setAnchorPoint(cc.p(0.5,0.5))
    self.richText:setPosition(cc.p(0,5))
    self.infotx:addChild(self.richText)

    self.funcbtn = self.leftpl:getChildByName('func_btn')
    self.funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
            if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
                self.funcbtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.5)
            end
        elseif eventType == ccui.TouchEventType.moved then
            if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
                self.funcbtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        elseif eventType == ccui.TouchEventType.canceled then
            if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
                self.funcbtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
                self.funcbtn:getChildByName('ui_yijianzhuangbei'):setScaleX(1.4)
            end
        	if self.protype == MAXPROTYPE then
        		promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC24'), COLOR_TYPE.RED)
        	else
        		self:sendMsg()
        	end       
        end
    end)
    self.functx = self.funcbtn:getChildByName('func_tx')
    local proviewbtn = self.leftpl:getChildByName('pro_view_btn')
    proviewbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	if self.protype == MAXPROTYPE then
        		promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC24'), COLOR_TYPE.RED)
        	else
        		RoleMgr:showRolePromotedProviewUI(self.obj,self.protype)
        	end
        end
    end)
    local proviewtx = proviewbtn:getChildByName('btn_tx')
    proviewtx:setString(GlobalApi:getLocalStr('ROLE_DESC14'))
    self.anim_pl = self.leftpl:getChildByName('hero_pl')

    self.resbg1 = self.leftpl:getChildByName('res_bg_1')
    self.resicon1 = self.resbg1:getChildByName('res_icon')
    self.restx1 = self.resbg1:getChildByName('res_tx')
    self.restx1:setString('')
    self.num1richText = xx.RichText:create()
	self.num1richText:setContentSize(cc.size(150, 25))
	self.num1richText:setAlignment('left')
	self.num1re1 = xx.RichTextLabel:create('',20,COLOR_TYPE.WHITE)
	self.num1re1:setFont('font/gamefont.ttf')
	self.num1re2 = xx.RichTextLabel:create('',20,COLOR_TYPE.WHITE)
	self.num1re2:setFont('font/gamefont.ttf')

	self.num1re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.num1re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

	self.num1richText:addElement(self.num1re1)
	self.num1richText:addElement(self.num1re2)

	self.num1richText:setVerticalAlignment('middle')
    self.num1richText:setAnchorPoint(cc.p(0.5,0.5))
    self.num1richText:setPosition(cc.p(25,1.5))
    self.restx1:addChild(self.num1richText)

    self.resbg2 = self.leftpl:getChildByName('res_bg_2')
    self.resicon2 = self.resbg2:getChildByName('res_icon')
    self.restx2 = self.resbg2:getChildByName('res_tx')
    self.restx2:setString('')
    self.num2richText = xx.RichText:create()
	self.num2richText:setContentSize(cc.size(150, 25))
	self.num2richText:setAlignment('left')
	self.num2re1 = xx.RichTextLabel:create('',20,COLOR_TYPE.WHITE)
	self.num2re1:setFont('font/gamefont.ttf')
	self.num2re2 = xx.RichTextLabel:create('',20,COLOR_TYPE.WHITE)
	self.num2re2:setFont('font/gamefont.ttf')

	self.num2re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	self.num2re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

	self.num2richText:addElement(self.num2re1)
	self.num2richText:addElement(self.num2re2)

	self.num2richText:setVerticalAlignment('middle')
    self.num2richText:setAnchorPoint(cc.p(0.5,0.5))
    self.num2richText:setPosition(cc.p(35,1.5))
    self.restx2:addChild(self.num2richText)

    self.wheelbtn = self.leftpl:getChildByName('wheel_btn')
    self.newImg = self.wheelbtn:getChildByName('new_img')
    self.newImg:setVisible(RechargeMgr.vipChanged)
    self.wheelbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	local openlimit = GlobalApi:getPrivilegeById("orangeDial")
		    local vip = tonumber(UserData:getUserObj():getVip())
			if vip < tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')) and (not openlimit) then
				local str = 'vip'..tostring(GlobalApi:getGlobalValue('promoteOrangeVipRestrict'))..GlobalApi:getLocalStr('GUARD_DESC19')
				promptmgr:showSystenHint(str, COLOR_TYPE.RED)
			else
				RoleMgr:showRolePromotedLuckyWheel()
			end
        	
        end
    end)

end

function RolePromotedUI:initright()
	self.headnode = self.rightpl:getChildByName('head_node')
	self.lvpl = self.rightpl:getChildByName('lv_pl')
	self.lvtab = {}
	for i=1,MAXPROMOTEDLV do
		local tab = {}
		tab.btn = self.lvpl:getChildByName('lv_'..i)
	    tab.btn:addTouchEventListener(function (sender, eventType)

        	if eventType == ccui.TouchEventType.began then
				self.beginPoint = sender:getTouchBeganPosition()
			end

			if 	eventType == ccui.TouchEventType.moved then
				self.endPoint = sender:getTouchMovePosition()
				local deltaxtemp = self.beginPoint.x - self.endPoint.x
				local deltax = self.beginPoint.x - self.endPoint.x
				local deltay = self.beginPoint.y - self.endPoint.y
				local delta =  math.abs(deltax)

				local angle = -delta/360*4
				if deltaxtemp > 0  then
					angle = math.abs(angle)
				end
				self.lvpl:setRotation(self.lvpl:getRotationSkewX()+angle)
			end
			if eventType ==  ccui.TouchEventType.ended then 
				if self.protype == MAXPROTYPE  then
		    		promptmgr:showSystenHint(GlobalApi:getLocalStr('ROLE_DESC24'), COLOR_TYPE.RED)
		    		return
		    	else
					local endPoint = sender:getTouchEndPosition()
					local deltax = self.beginPoint.x - endPoint.x
					local deltay = self.beginPoint.y - endPoint.y
					local delta =  math.abs(deltax)

					if delta < 10 then
						if i == MAXPROMOTEDLV then
							RoleMgr:showRolePromotedTipsUI(self.obj,self.protype+1,0)
						else
							RoleMgr:showRolePromotedTipsUI(self.obj,self.protype,i)
						end					
					end			    		
		    	end
			end

	    end)
		tab.tx = tab.btn:getChildByName('lv_tx')
		tab.starimg = tab.btn:getChildByName('star_img')
		self.lvtab[i] = tab
	end
end

function RolePromotedUI:initbottom()
	self.norpl = self.bottompl:getChildByName('nor_pl')
    self.protx = self.norpl:getChildByName('pro_tx')
    self.nexttx = self.norpl:getChildByName('next_tx')
    local arrowimg = self.norpl:getChildByName('arrow_img')
    self.maxpl = self.bottompl:getChildByName('max_pl')
    self.maxtx = self.maxpl:getChildByName('pro_tx')
    self.maxtx:setString(GlobalApi:getLocalStr('ROLE_DESC21'))
    local norprotxarr = {}
    self.norpronumarr = {}
    local nornexttxarr = {}
    self.nornextnumarr = {}
    local maxtxarr = {}
    self.maxnumarr = {}
    for i = 1, 4 do
        norprotxarr[i] = self.norpl:getChildByName('pro_att_'..i)
        norprotxarr[i]:setString(GlobalApi:getLocalStr('STR_ATT'..i))
        self.norpronumarr[i] = self.norpl:getChildByName('pro_attnum_'..i)
        nornexttxarr[i] = self.norpl:getChildByName('next_att_'..i)
        nornexttxarr[i]:setString(GlobalApi:getLocalStr('STR_ATT'..i))
        self.nornextnumarr[i] = self.norpl:getChildByName('next_attnum_'..i)
        maxtxarr[i] = self.maxpl:getChildByName('pro_att_'..i)
        maxtxarr[i]:setString(GlobalApi:getLocalStr('STR_ATT'..i))
        self.maxnumarr[i] = self.maxpl:getChildByName('pro_attnum_'..i)
    end
end

function RolePromotedUI:update()
    if RoleMgr:getCurHeroChange() then
        self.obj = RoleData:getRoleByPos(RoleMgr:getSelectRolePos())
		self:createAnimation()
		self.obj:playSound('sound')
		RoleMgr:setCurHeroChange(false)
	end

	self.promotedconf = self.obj:getPromotedConf()
	self.promote = self.obj:getPromoted()
	self.professtype = self.obj:getProfessionType()
	self.headnode:removeAllChildren()
	local cell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, self.obj, self.headnode)
	cell.awardBgImg:setTouchEnabled(false)
	if self.obj:getTalent() > 0 then
		self.nametx:setString(self.obj:getName()..' + ' .. self.obj:getTalent())
	else
		self.nametx:setString(self.obj:getName())
	end
	self.nametx:setColor(self.obj:getNameColor())
    self.tagimg:loadTexture(COLOR_TABBG[tonumber(self.obj:getQuality())])

	self.lv = 0
	self.protype = 0
	if self.promote and self.promote[1] then
		self.protype = self.promote[1]
		self.lv = self.promote[2]
	end
	self.nextlv = 0
	self.nextprotype = self.protype 
	if self.lv + 1 >= MAXPROMOTEDLV then
		self.nextlv = 0
		if self.nextprotype + 1 <= MAXPROTYPE then
			self.nextprotype = self.nextprotype + 1
		end
	else
		self.nextlv = self.lv + 1
	end
	if self.nextprotype == MAXPROTYPE then
		self.nextlv = 0
	end
	self.protype ,self.nextprotype  = self.obj:checkPromoteType(self.protype ,self.nextprotype)
	self.qimg:loadTexture('uires/ui/role/'..self.promotedconf[self.protype][self.professtype*100+self.lv]['qIcon'])
	local baseatt = self:getAtt(0,0)
	local proatt = self:getAtt(self.protype,self.lv)
	local nextatt = self:getAtt(self.nextprotype,self.nextlv)
	local maxatt = self:getAtt(MAXPROTYPE,0)
	self.proattdis = {}
	self.nextattdis = {}
	local maxattdis = {}
	self.proattdis[1] = proatt[1]-baseatt[1]
	self.proattdis[2] = proatt[4]-baseatt[4]
	self.proattdis[3] = proatt[2]-baseatt[2]
	self.proattdis[4] = proatt[3]-baseatt[3]

	self.nextattdis[1] = nextatt[1]-baseatt[1]
	self.nextattdis[2] = nextatt[4]-baseatt[4]
	self.nextattdis[3] = nextatt[2]-baseatt[2]
	self.nextattdis[4] = nextatt[3]-baseatt[3]

	maxattdis[1] = maxatt[1]-baseatt[1]
	maxattdis[2] = maxatt[4]-baseatt[4]
	maxattdis[3] = maxatt[2]-baseatt[2]
	maxattdis[4] = maxatt[3]-baseatt[3]

	if self.obj:getQuality() < 7 then
		self.re1:setString(GlobalApi:getLocalStr('ROLE_DESC15'))
		self.re3:setString(GlobalApi:getLocalStr('ROLE_DESC27'))
		self.norpl:setVisible(true)
		self.maxpl:setVisible(false)
		self.protx:setString( self.lv..GlobalApi:getLocalStr('ROLE_DESC19'))
		self.nexttx:setString((self.lv+1)..GlobalApi:getLocalStr('ROLE_DESC19'))
		for i=1,4 do
			self.norpronumarr[i]:setString(self.proattdis[i])
			self.nornextnumarr[i]:removeAllChildren()
			self.nornextnumarr[i]:setString('')
			local richText = xx.RichText:create()
			local re1 = xx.RichTextLabel:create(self.nextattdis[i].."   ",28, cc.c4b(249,221,84, 255))
	    	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    	local re2 = xx.RichTextImage:create('uires/ui/common/arrow_up2.png')
	    	richText:addElement(re1)
	    	
			if self.nextattdis[i] - self.proattdis[i] > 0 then
				re1:setColor(COLOR_TYPE.GREEN)
				richText:addElement(re2)
			end
			richText:setAnchorPoint(cc.p(0,0.5))
		    richText:setPosition(cc.p(0,15))
			richText:setVerticalAlignment('middle')
		    self.nornextnumarr[i]:addChild(richText,9527)

		end
		self.re2:setString(MAXPROMOTEDLV-self.lv)
		if self.obj:getQuality() == 5 then
			self.re4:setString(GlobalApi:getLocalStr('ROLE_DESC16'))
			self.re4:setColor(COLOR_TYPE.RED)
		elseif self.obj:getQuality() == 6 then
			self.re4:setString(GlobalApi:getLocalStr('ROLE_DESC17'))
			self.re4:setColor(COLOR_TYPE.GOLD)
		end
		self.richText:format(true)
	elseif self.obj:getQuality() == 7 then
		self.norpl:setVisible(false)
		self.maxpl:setVisible(true)
		self.re1:setString(GlobalApi:getLocalStr('ROLE_DESC21'))
		self.re2:setString('')
		self.re3:setString('')
		self.re4:setString('')
		self.richText:format(true)
		for i=1,4 do
			self.maxnumarr[i]:setString(maxattdis[i])
		end
    	self.num1re1:setString(0)
		self.num1re2:setString('')
		self.num1re1:setColor(COLOR_TYPE.WHITE)
		self.num1re2:setColor(COLOR_TYPE.WHITE)
		self.num2re1:setString(0)
		self.num2re2:setString('')
		self.num2re1:setColor(COLOR_TYPE.WHITE)
		self.num2re2:setColor(COLOR_TYPE.WHITE)
		self.num1richText:format(true)
		self.num2richText:format(true)
	end

	for i=1,MAXPROMOTEDLV do
		self.lvtab[i].starimg:setVisible(false)
	end
	self.resicon1:ignoreContentAdaptWithSize(true)
	self.resicon2:ignoreContentAdaptWithSize(true)
	self.resicon1:setScale(0.625)
	self.resicon2:setScale(0.625)
	for i=1,MAXPROMOTEDLV do
		self.lvtab[i].btn:loadTextureNormal('uires/ui/role/'..self.promotedconf[self.protype][self.professtype*100+self.lv]['btnIcon'])
		if self.protype == 3 then		
			if i == MAXPROMOTEDLV then
				self.lvtab[i].tx:setString(self.promotedconf[self.protype][self.professtype*100+0]['promoteName'])
			else
				self.lvtab[i].tx:setString(self.promotedconf[self.protype-1][self.professtype*100+i]['promoteName'])
			end
		else
			
			if i == MAXPROMOTEDLV then
				self.lvtab[i].tx:setString(self.promotedconf[self.protype+1][self.professtype*100+0]['promoteName'])
			else
				self.lvtab[i].tx:setString(self.promotedconf[self.protype][self.professtype*100+i]['promoteName'])
			end
		end

		ShaderMgr:restoreSpriteDefaultShader(self.lvtab[i].starimg)
		self.lvtab[i].tx:enableOutline(COLOROUTLINE_TYPE.GRAY, 1)
		self.lvtab[i].tx:setTextColor(COLOR_TYPE.WHITE)
		self.lvtab[i].btn:setTouchEnabled(true)
		local size = self.lvtab[i].btn:getContentSize()
		local selectImg = self.lvtab[i].btn:getChildByName('ui_fengjiang')
		if not selectImg then
			selectImg = GlobalApi:createLittleLossyAniByName('ui_fengjiang')
			selectImg:setPosition(cc.p(size.width/2,size.height/2))
			selectImg:getAnimation():playWithIndex(0, -1, 1)
			selectImg:setName('ui_fengjiang')
			selectImg:setVisible(false)
			self.lvtab[i].btn:addChild(selectImg)
		end

    	self.lvtab[i].starimg:setVisible(self.obj:getPromotedIshaveStar(self.protype,i - 1))
		if self.protype == MAXPROTYPE then
			selectImg:setVisible(false)
			if i == MAXPROMOTEDLV then
				self.lvtab[i].btn:loadTextureNormal('uires/ui/role/'..self.promotedconf[self.protype][self.professtype*100+self.lv]['btnIcon'])
				selectImg:setVisible(true)
			else
				self.lvtab[i].btn:loadTextureNormal('uires/ui/role/'..self.promotedconf[self.protype-1][self.professtype*100+self.lv]['btnIcon'])
	    		self.lvtab[i].tx:setTextColor(COLOR_TYPE.WHITE)
	    		ShaderMgr:setGrayForSprite(self.lvtab[i].starimg)
				selectImg:setVisible(false)
			end
		else
			if self.lv == 0 and i == 1 then
	    		self.lvtab[i].btn:loadTextureNormal(DISBG)
				if self.protype ~= MAXPROTYPE then
					selectImg:setVisible(true)
				end
			elseif self.lv == i then
				self.lvtab[i].btn:loadTextureNormal('uires/ui/role/'..self.promotedconf[self.protype][self.professtype*100+self.lv]['btnIcon'])
				selectImg:setVisible(true)
	    	elseif  self.lv > i then
	    		self.lvtab[i].btn:loadTextureNormal('uires/ui/role/'..self.promotedconf[self.protype][self.professtype*100+self.lv]['btnIcon'])
	    		self.lvtab[i].btn:setTouchEnabled(false)
				selectImg:setVisible(false)
	    	elseif  self.lv < i then
	    		self.lvtab[i].btn:loadTextureNormal(DISBG)
	    		self.lvtab[i].tx:setTextColor(COLOR_TYPE.GRAY)
	    		ShaderMgr:setGrayForSprite(self.lvtab[i].starimg)
				selectImg:setVisible(false)
	    	else
	    		self.lvtab[i].btn:loadTextureNormal('uires/ui/role/'..self.promotedconf[self.protype][self.professtype*100+self.lv]['btnIcon'])
				selectImg:setVisible(false)
	    	end	
		end
    end

    
    if self.protype == MAXPROTYPE then
    	local awards = DisplayData:getDisplayObjs(self.promotedconf[self.protype][self.professtype*100+self.lv]['cost'])
    	if awards[1] then
    		self.resicon1:loadTexture(awards[1]:getIcon())
    	end
    	if awards[2] then
    		self.resicon2:loadTexture(awards[2]:getIcon())
    	end
    	self.num1re1:setString(0)
		self.num1re2:setString('')
		self.num1re1:setColor(COLOR_TYPE.WHITE)
		self.num1re2:setColor(COLOR_TYPE.WHITE)
		self.num2re1:setString(0)
		self.num2re2:setString('')
		self.num2re1:setColor(COLOR_TYPE.WHITE)
		self.num2re2:setColor(COLOR_TYPE.WHITE)
		self.num1richText:format(true)
		self.num2richText:format(true)
		self.resbg1:setTouchEnabled(false)
		self.resbg2:setTouchEnabled(false)
    	self.functx:setString(GlobalApi:getLocalStr('ROLE_DESC26'))
		if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
            self.funcbtn:removeChildByName('ui_yijianzhuangbei')
        end
        self.lvpl:setRotation(-24)
    else
    	local awards = DisplayData:getDisplayObjs(self.promotedconf[self.nextprotype][self.professtype*100+self.nextlv]['cost'])
    	if awards[1] then
    		--self.restx1:setString(awards[1]:getNum())
    		self.num1re1:setString(GlobalApi:toWordsNumber(awards[1]:getOwnNum()))
			self.num1re2:setString('/'..awards[1]:getNum())
			if awards[1]:getOwnNum() >= awards[1]:getNum() then
				self.num1re1:setColor(COLOR_TYPE.GREEN)
			else
				self.num1re1:setColor(COLOR_TYPE.RED)
			end
			self.num1richText:format(true)

    		self.resicon1:loadTexture(awards[1]:getIcon())
    	end
    	if awards[2] then
    		--self.restx2:setString(awards[2]:getNum())
    		self.num2re1:setString(GlobalApi:toWordsNumber(awards[2]:getOwnNum()))
			self.num2re2:setString('/'..awards[2]:getNum())
			if awards[2]:getOwnNum() >= awards[2]:getNum() then
				self.num2re1:setColor(COLOR_TYPE.GREEN)
			else
				self.num2re1:setColor(COLOR_TYPE.RED)
			end
			self.num2richText:format(true)

    		self.resicon2:loadTexture(awards[2]:getIcon())
    	end
    	self.resbg1:setTouchEnabled(true)
		self.resbg2:setTouchEnabled(true)
    	self.resbg1:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
        		GetWayMgr:showGetwayUI(awards[1],true)
	        end
	    end)

    	self.resbg2:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	       		GetWayMgr:showGetwayUI(awards[2],true)
	        end
	    end)

    	self.functx:setString(GlobalApi:getLocalStr('ROLE_DESC13'))
    	local judge = false
    	if awards[1] and awards[1]:getOwnNum() >= awards[1]:getNum() and awards[2] and awards[2]:getOwnNum() >= awards[2]:getNum() then
    		judge = true
    	end
    	if judge then
	        if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
	            self.funcbtn:removeChildByName('ui_yijianzhuangbei')
	        end
	        local size = self.funcbtn:getContentSize()
	        local effect = GlobalApi:createLittleLossyAniByName('ui_yijianzhuangbei')
	        effect:setScaleX(1.4)
	        effect:setName('ui_yijianzhuangbei')
	        effect:setPosition(cc.p(size.width/2 ,size.height/2))
	        effect:setAnchorPoint(cc.p(0.5,0.5))
	        effect:getAnimation():playWithIndex(0, -1, 1)
	        self.funcbtn:addChild(effect)
		else
	        if self.funcbtn:getChildByName('ui_yijianzhuangbei') then
	            self.funcbtn:removeChildByName('ui_yijianzhuangbei')
	        end
		end
		if self.lv >= 1  then
		    self.lvpl:setRotation((self.lv-1)*24)
		else
			self.lvpl:setRotation(0)
		end
    end
    local newImg = self.leftpl:getChildByName('new_img')
    local promoteFirst = cc.UserDefault:getInstance():getBoolForKey('promote_first',true)
    newImg:setVisible(promoteFirst)

end

function RolePromotedUI:changePos( currpos,isright )
	self.anim_pl:setTouchEnabled(false)
	self.anim_pl:runAction(cc.Sequence:create(cc.DelayTime:create(1.0), cc.CallFunc:create(function (  )
		self.anim_pl:setTouchEnabled(true)
	end)))

	self.posarr = {}
	for i=1,#self.objarr do
		self.posarr[i] = self.objarr[i]:getPosId()
	end
	local inposarrpos = 0
	for i=1,#self.objarr do
		if self.posarr[i] == currpos then
			inposarrpos = i
		end
	end
	local postemp = 0
	if isright then
		local pos = inposarrpos
		local needdoing = true
		while needdoing do
			pos = pos +1
			if pos > #self.objarr then
				pos = 1
			end
			if RoleData:getRoleByPos(self.posarr[pos]):getId() > 0 then
				RoleMgr:setSelectRolePos(self.posarr[pos])
				RoleMgr:updateRoleList()
				needdoing = false
			end
		end
		postemp = pos
	else
		local pos = inposarrpos
		local needdoing = true
		while needdoing do
			pos = pos -1
			if pos < 1 then
				pos = #self.objarr
			end
			if RoleData:getRoleByPos(self.posarr[pos]):getId() > 0 then
				RoleMgr:setSelectRolePos(self.posarr[pos])
				RoleMgr:updateRoleList()
				needdoing = false
			end
		end
		postemp = pos
	end

	if inposarrpos ~= postemp then
		RoleMgr:setCurHeroChange(true)
	end
	self:update()
end

function RolePromotedUI:createAnimation()
	self.anim_pl:removeAllChildren()
	local actionisruning = false
	local spineAni = GlobalApi:createLittleLossyAniByName(self.obj:getUrl() .. "_display", nil, self.obj:getChangeEquipState())
	local heroconf = GameData:getConfData('hero')[self.obj:getId()]
	if spineAni then
		local shadow = spineAni:getBone(self.obj:getUrl() .. "_display_shadow")
		if shadow then
			shadow:changeDisplayWithIndex(-1, true)
			shadow:setIgnoreMovementBoneData(true)
		end
		spineAni:setPosition(cc.p(self.anim_pl:getContentSize().width/2,10+heroconf.uiOffsetY))
		spineAni:setLocalZOrder(999)
		self.anim_pl:addChild(spineAni)
		spineAni:getAnimation():play('idle', -1, 1)
		spineAni:setScale(1.1)
		self.anim_pl:addTouchEventListener(function (sender, eventType)
			if eventType ==  ccui.TouchEventType.ended or 
				eventType == ccui.TouchEventType.canceled then
                if actionisruning  ~= true then
                    actionisruning = true
                    self:swapanimation(spineAni)
                end
			end
		end) 

		local function movementFun1(armature, movementType, movementID)
			if movementType == 1 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			elseif movementType == 2 then
				spineAni:getAnimation():play('idle', -1, 1)
				actionisruning = false
			end
		end
		spineAni:getAnimation():setMovementEventCallFunc(movementFun1)
	end
end

function RolePromotedUI:swapanimation(spineAni)
	-- local seed = math.random(1, 5)
	-- if self.action ~= roleanim[seed] then
	-- 	self.action = roleanim[seed]
	-- 	spineAni:getAnimation():play(roleanim[seed], -1, -1)
	-- end
end

function RolePromotedUI:getAtt(protype,lv)
	local objtemp = clone(self.obj)
	local promotedtemp = {}
	promotedtemp[1] = protype
	promotedtemp[2] = lv
	objtemp:setPromoted(promotedtemp)
	local atttemp = RoleData:CalPosAttByPos(objtemp,true)
	return atttemp
end

function RolePromotedUI:sendMsg()
	local havegoods = true
    if self.lv+1 < MAXPROMOTEDLV and self.protype < MAXPROTYPE then
    	local awards = DisplayData:getDisplayObjs(self.promotedconf[self.protype][self.professtype*100+self.lv+1]['cost'])
    	if awards[1] and awards[1]:getOwnNum() < awards[1]:getNum() then
    		havegoods = false
    	end
    	if awards[2] and awards[2]:getOwnNum() < awards[2]:getNum() then
    		havegoods = false
    	end
    end
    if havegoods then
	   	local args = {
	        pos = self.obj:getPosId()
	    }
	    MessageMgr:sendPost("promote", "hero", json.encode(args), function (jsonObj)
	        local code = jsonObj.code
	        if code == 0 then
		        local awards = jsonObj.data.awards
		        if awards then
		            GlobalApi:parseAwardData(awards)
		        end
		        local costs = jsonObj.data.costs
		        if costs then
		            GlobalApi:parseAwardData(costs)
		        end
		        local  name  = self.promotedconf[tonumber(self.nextprotype)][tonumber(self.professtype*100+self.nextlv)]['promoteName']
				RoleMgr:showRolePromotedUpgradeUI(self.obj,self.proattdis,self.nextattdis,name,function ()
					if  jsonObj.data.promote[2] == 0 then
						if jsonObj.data.promote[1] == MAXPROTYPE then
	        	        	RoleMgr:showRolePromotedUpgradeMaxUI(self.obj,self.proattdis,self.nextattdis,function ()
	        	        		RoleMgr:setCurHeroChange(true)
								self:updateAtt(jsonObj.data.promote)
				        	end)   
						else
	        	        	RoleMgr:showRolePromotedUpgradeSkillUI(self.obj,self.proattdis,self.nextattdis,function ()
	        	        		RoleMgr:setCurHeroChange(true)
								self:updateAtt(jsonObj.data.promote)
				        	end)							
						end						
					else
						self:updateAtt(jsonObj.data.promote)
					end
				end)
	        end
	    end)
	else
		promptmgr:showSystenHint(GlobalApi:getLocalStr('NO_SKILL_UPGRADE_M'), COLOR_TYPE.RED)
	end
end

function RolePromotedUI:updateAtt(promote)
	self.obj:setPromoted(promote)
	self.obj:setFightForceDirty(true)
	RoleData:getPosFightForceByPos(self.obj)
	RoleMgr:popupTips(self.obj)
	RoleMgr:updateRoleList()
	self:update()
end

return RolePromotedUI