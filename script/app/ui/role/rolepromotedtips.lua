local RolePromotedTipsUI = class("RolePromotedTipsUI", BaseUI)

function RolePromotedTipsUI:ctor(obj,protype,lv)
	self.uiIndex = GAME_UI.UI_ROLE_PROMOTED_TIPS_PANEL
    self.obj = obj
    self.conf = self.obj:getPromotedConf()
    self.professtype = self.obj:getProfessionType()
    self.lv = lv
    self.protype = protype
end

function RolePromotedTipsUI:init()
	local bgimg = self.root:getChildByName("bg_img_1")
	self.bgimg1 = bgimg:getChildByName("bg_img_2")
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRolePromotedTipsUI()
        end
    end)
    self:adaptUI(bgimg, self.bgimg1)
    self.midimg = self.bgimg1:getChildByName('mid_img')
    self.tiaoimg1 = self.midimg:getChildByName('tiao_img_1')
    self.tiaoimg2 = self.midimg:getChildByName('tiao_img_2')
    self.dragonimg = self.midimg:getChildByName('dragon_img')
    self.nametx = self.bgimg1:getChildByName('name_tx')
    self.starimg = self.bgimg1:getChildByName('star_img')
    self.attpl = self.midimg:getChildByName('att_pl')
    self.infotx = self.attpl:getChildByName('info_tx')
    local proattbase = {}
    local att = {}
    self.atttx = {}
    self.attnumtx = {}
    local disnumatt = {}
    proattbase = self:getAtt(0,0)
    att = self:getAtt(self.protype,self.lv)

   	disnumatt[1] = att[1]-proattbase[1]
	disnumatt[2] = att[4]-proattbase[4]
	disnumatt[3] = att[2]-proattbase[2]
	disnumatt[4] = att[3]-proattbase[3]

	local num = 0
	for i=1,4 do
		if att[i] - proattbase[i] > 0 then
			num = num + 1
		end
		self.atttx[i] = self.attpl:getChildByName('att_'..i)
		self.atttx[i]:setString(GlobalApi:getLocalStr('STR_ATT'..i))
		self.attnumtx[i]= self.attpl:getChildByName('num_'..i)
		if disnumatt[i] > 0 then
			self.attnumtx[i]:setString(' +'..disnumatt[i])
		else
			self.attnumtx[i]:setString(disnumatt[i])
		end
	end

	if self.lv == 0 and self.protype ~= 3 then
		self:setSize(398,254)
	else
		self:setSize(398,204)
	end

	self.starimg:setVisible(self.obj:getPromotedIshaveStar(self.protype,self.lv - 1))
	self.nametx:setString(self.conf[tonumber(self.protype)][self.professtype*100+self.lv]['promoteName'])
	if self.lv ~= 0 then
		self.nametx:setTextColor(COLOR_QUALITY[tonumber(self.conf[tonumber(self.protype)][self.professtype*100+self.lv]['quality'])])
		self.infotx:setTextColor(COLOR_QUALITY[tonumber(self.conf[tonumber(self.protype)][self.professtype*100+self.lv]['quality']+1)])
	else
		self.nametx:setTextColor(COLOR_QUALITY[tonumber(self.conf[tonumber(self.protype)][self.professtype*100+self.lv]['quality'])])
		self.infotx:setTextColor(COLOR_QUALITY[tonumber(self.conf[tonumber(self.protype)][self.professtype*100+self.lv]['quality'])])
	end
end

function RolePromotedTipsUI:getAtt(protype,lv)
	local objtemp = clone(self.obj)
	local promotedtemp = {}
	promotedtemp[1] = protype
	promotedtemp[2] = lv
	objtemp:setPromoted(promotedtemp)
	local atttemp = RoleData:CalPosAttByPos(objtemp,true)
	return atttemp
end

function RolePromotedTipsUI:setSize(width,height)
	self.bgimg1:setContentSize(cc.size(width,height))
	local midwidth  = width-4
	local midheight = height-50
	self.midimg:setContentSize(cc.size(midwidth,midheight))
	self.midimg:setPosition(cc.p(width/2,height/2-10))
	self.tiaoimg1:setContentSize(cc.size(midwidth,1))
	self.tiaoimg1:setPosition(cc.p(midwidth/2,0))
	self.tiaoimg2:setContentSize(cc.size(midwidth,1))
	self.tiaoimg2:setPosition(cc.p(midwidth/2,midheight))
	self.dragonimg:setScale(height/(self.dragonimg:getContentSize().height*1.1))
	self.dragonimg:setPosition(cc.p(midwidth/2,midheight/2))

	self.attpl:setContentSize(cc.size(midwidth,midheight))
	self.attpl:setPosition(cc.p(midwidth/2,midheight/2))
	self.nametx:setPosition(cc.p(width/2,height-20))
	self.starimg:setPosition(cc.p(width/2+80,height-20))

	if  self.lv ~= 0 or self.protype == 3 then
		self.infotx:setVisible(false)
	else
		for i=1,4 do
			self.atttx[i]:setPosition(cc.p(self.atttx[i]:getPositionX(),self.atttx[i]:getPositionY()+50))
			self.attnumtx[i]:setPosition(cc.p(self.attnumtx[i]:getPositionX(),self.attnumtx[i]:getPositionY()+50))
		end
		self.infotx:setVisible(true)
		if self.protype == 2 then
			self.infotx:setString(GlobalApi:getLocalStr('ROLE_DESC22'))
		-- elseif self.protype == 3 then
		-- 	self.infotx:setString(GlobalApi:getLocalStr('ROLE_DESC23'))
		end	
	end
end

return RolePromotedTipsUI
