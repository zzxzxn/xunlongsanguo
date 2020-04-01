--===============================================================
-- 武将突破界面
--===============================================================
local ClassRoleBaseUI = require("script/app/ui/role/rolebaseui")
local ClassItemCell = require('script/app/global/itemcell')

local RoleTupo = class("RoleTupo", ClassRoleBaseUI)
local maxlv = 15

function RoleTupo:initPanel()
	self.panel = cc.CSLoader:createNode("csb/roletupopanel.csb")
	self.panel:setName("role_tupo_panel")
	local bgimg = self.panel:getChildByName('bg_img')
	self.nor_pl = bgimg:getChildByName('nor_pl')
	self.max_pl = bgimg:getChildByName('max_pl')
	self.attbg = self.nor_pl:getChildByName('att_img')
	self.attarr = {} --突破原始属性控件
	local att2bg = self.attbg:getChildByName('num_bg')
	for i=1,4 do
		local attatx = att2bg:getChildByName('atta_' .. i .. '_tx')
		local attbtx = att2bg:getChildByName('attb_' .. i .. '_tx')
		local attantx = att2bg:getChildByName('numa_' .. i .. '_tx')
		local attbntx = att2bg:getChildByName('numb_' .. i .. '_tx')
		local addarrow = att2bg:getChildByName('arrow_' .. i .. '_img')
		local arr = {}
		arr.atta = attatx
		arr.attan = attbtx
		arr.attb = attantx
		arr.attbn = attbntx
		arr.addarrow = addarrow
		self.attarr[i] = arr
	end
	local infobtnnor = att2bg:getChildByName('info_btn')
	infobtnnor:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleTupoInfoUI(self.obj)
        end
    end)
    self.needlvtx = self.nor_pl:getChildByName('needlv_tx')
    self.activatttx = att2bg:getChildByName('addatt_tx')
	self.ismaterialnumok = true
	self.obj = nil
	self.tupobtn = self.nor_pl:getChildByName("tupo_btn")
	self.btntx =self.tupobtn:getChildByName('func_tx')
	self.btntx:setString(GlobalApi:getLocalStr('STR_TUPO'))
    self.attneed = {}
    self.an = {}
    for i=1,2 do
    	local itemimg = self.nor_pl:getChildByName('iconbg_' .. i .. '_img')
    	local itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    	itemCell.awardBgImg:setPosition(cc.p(itemimg:getPosition()))
    	itemCell.lvTx:setPosition(cc.p(47, -15))
    	self.nor_pl:addChild(itemCell.awardBgImg)
    	self.an[i] = itemCell.awardBgImg:getPositionX()
    	self.attneed[i] = itemCell
    end

    self.richlabel = {}
    self.goldbg = self.nor_pl:getChildByName('gold_bg')
    local goldtx = self.goldbg:getChildByName('num_tx_1')
    self.richText = xx.RichText:create()
    self.richText:setContentSize(cc.size(200, 40))
    self.richlabel[1] = xx.RichTextLabel:create('',21, COLOR_TYPE.WHITE)
    self.richlabel[1]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richlabel[2] = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
    self.richlabel[2]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richText:addElement(self.richlabel[2])
    self.richText:addElement(self.richlabel[1])
    self.richText:setAnchorPoint(cc.p(0,0.5))
    self.richText:setPosition(cc.p(0,-6))
    goldtx:addChild(self.richText,9527)
    self.richText:setVisible(true)

    self.maxarr = {} --突破满级属性控件
    self.attmaxbg = self.max_pl:getChildByName('att_img')
    local att2maxbg = self.attmaxbg:getChildByName('num_bg')
	for i=1,4 do
		local attatx = att2maxbg:getChildByName('atta_' .. i .. '_tx')
		local attantx = att2maxbg:getChildByName('numa_' .. i .. '_tx')
		local arr = {}
		arr.atta = attatx
		arr.attan = attantx
		self.maxarr[i] = arr
	end
	local tiao2bg = att2maxbg:getChildByName('tiao_2')
	self.activattmaxtx = tiao2bg:getChildByName('addatt_tx')
	local infobtnmax = tiao2bg:getChildByName('info_btn')
	infobtnmax:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            RoleMgr:showRoleTupoInfoUI(self.obj)
        end
    end)
	self.costtab = {}
end

function RoleTupo:onMoveOut()
end

function RoleTupo:updateNorPanel(obj)
	local str = GlobalApi:getLocalStr('TITLE_TP') 
	if self.obj:getTalent() > 0 then
		str = GlobalApi:getLocalStr('TITLE_TP')..GlobalApi:getLocalStr('ROLE_DESC2')..' + '..tostring(self.obj:getTalent()+1)
	end
    RoleMgr:setRoleMainTitle(str)
	self.max_pl:setVisible(false)
	self.nor_pl:setVisible(true)
	local attacitvetx = self.attbg:getChildByName('att_active_tx')
	attacitvetx:setString(GlobalApi:getLocalStr('TITLE_TF')..' +'..self.obj:getTalent())
	local attacitvetx2 = self.attbg:getChildByName('att_active_tx_2')
	attacitvetx2:setString(GlobalApi:getLocalStr('ROLE_DESC1'))
	local  conf = obj:getrebornConfByLv(obj:getTalent())
	local  conf1 = obj:getrebornConfByLv(obj:getTalent()+1)
	local gold = UserData:getUserObj():getGold()

	self.activatttx:removeAllChildren()
	local richlabelatt = {}
	local att2bg = self.attbg:getChildByName('num_bg')
	
	self.attText = xx.RichText:create()
    self.attText:setContentSize(cc.size(450, 80))
    richlabelatt[1] = xx.RichTextLabel:create('',23, COLOR_TYPE.ORANGE)
    richlabelatt[1]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richlabelatt[2] = xx.RichTextLabel:create(tx2,23, COLOR_TYPE.GREEN)
    richlabelatt[2]:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.attText:addElement(richlabelatt[1])
    self.attText:addElement(richlabelatt[2])
    self.attText:setAnchorPoint(cc.p(0.5,0.5))
    self.attText:setPosition(cc.p(0,-10))
    self.attText:setAlignment('middle')
    self.activatttx:addChild(self.attText,9527)
    self.attText:setVisible(true)

    self.richlabel[2]:setString(GlobalApi:toWordsNumber(UserData:getUserObj():getGold()))
    self.oldNum = gold
	 --突破激活属性
	local att = RoleData:getPosAttByPos(obj)
	self.curattarr = {}
    self.curattarr[1] = math.floor(att[1])--(conf['baseAtk']+obj:getLevel()*conf['atkGrowth'])
    self.curattarr[2] = math.floor(att[4]) --(conf['baseHp']+obj:getLevel()*conf['hpGrowth'])
    self.curattarr[3] = math.floor(att[2]) --(conf['baseDef']+obj:getLevel()*conf['defGrowth'])
    self.curattarr[4] = math.floor(att[3]) --(conf['baseMagDef']+obj:getLevel()*conf['magDefGrowth'])
    self.nextattarr = {}
    local objtemp = clone(self.obj)
    objtemp:setTalent(self.obj:getTalent()+1)
    local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    self.nextattarr[1] = math.floor(atttemp[1])
    self.nextattarr[2] = math.floor(atttemp[4])
    self.nextattarr[3] = math.floor(atttemp[2])
    self.nextattarr[4] = math.floor(atttemp[3])

    local addarr = {}
    addarr[1] = math.floor(self.nextattarr[1] -self.curattarr[1])
    addarr[2] = math.floor(self.nextattarr[2] -self.curattarr[2])
    addarr[3] = math.floor(self.nextattarr[3] -self.curattarr[3])
    addarr[4] = math.floor(self.nextattarr[4] -self.curattarr[4])

    for i=1,4 do
    	self.attarr[i].attbn:removeAllChildren()
    	self.attarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.attarr[i].attan:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.attarr[i].attb:setString(self.curattarr[i])
		self.attarr[i].attbn:setString("")
		self.attarr[i].addarrow:setVisible(false)
		--self.attarr[i].add:setString('+'..addarr[i])
		local richText = xx.RichText:create()
		local re1 = xx.RichTextLabel:create(self.nextattarr[i].."   ",25, COLOR_TYPE.GREEN)
    	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    	local re2 = xx.RichTextImage:create('uires/ui/common/arrow_up2.png')
    	richText:addElement(re1)
    	
		if addarr[i] > 0 then
			richText:addElement(re2)
		end
		richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(0,15))
	    --richText:setAlignment('middle')
		richText:setVerticalAlignment('middle')
	    self.attarr[i].attbn:addChild(richText,9527)
	    richText:setVisible(true)
    end

	local innateGroupId = obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
	local innateid = groupconf[tostring('level' .. obj:getTalent()+1)]
	local effect =groupconf[tostring('value' .. obj:getTalent()+1)]
	local innateconf = GameData:getConfData('innate')[innateid]
	local specialtab = groupconf['highlight']
	local teamnum = 0
	local teamheroID = groupconf['teamheroID']
	local teamtab = groupconf['teamvaluegroup']
	for k,v in pairs(teamtab) do
		teamnum = teamnum +1
		if (self.obj:getTalent()+1) == v then
			break
		end
	end

	local tx1 = ''
	local tx2 = ''
	local tx3 = ''
	local tx4 = ''
	local s = GlobalApi:tableFind(teamtab,self.obj:getTalent()+1)
	local n  = GlobalApi:tableFind(specialtab,self.obj:getTalent()+1)
	local re6 = xx.RichTextImage:create('uires/ui/common/arrow5.png')
		re6:setScale(0.6)

	local re5 = xx.RichTextLabel:create(tx4, 19, cc.c4b(255, 0, 0, 255))
	re5:setStroke(cc.c4b(0, 0, 0, 255), 1)
	re5:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

	if innateid < 1000 then
		tx1 = innateconf['desc'] .. effect .. '%'
		if innateconf['type'] ~= 2 then
			tx1 = innateconf['desc'] .. effect
		end
		tx2 =  '【' .. innateconf['name'] ..'】 '
	else
		tx1 = groupconf[tostring('specialDes'..innateid%1000)]
		tx2 =  '【' .. groupconf[tostring('specialName'..innateid%1000)] ..'】 '
	end

	if s ~= 0 then
		tx4 =  groupconf[tostring('teamDes'..teamnum)] 
		if groupconf[tostring('teamDes'..teamnum)] ~= '0' then
			tx4 =  groupconf[tostring('teamDes'..teamnum)]
			re5:setString(tx4)
			self.attText:addElement(re6)
			self.attText:addElement(re5)
		end
	end

 	self.activatttx:setString('')
 	richlabelatt[1]:setString(tx2)
 	richlabelatt[2]:setString(tx1)
 	self.attText:format(true)
 	if self.attText:getBrushY() < 40 then
 		self.attText:setPosition(cc.p(0,-20))
 	else
 		self.attText:setPosition(cc.p(0,-10))
 	end
	local str = string.format(GlobalApi:getLocalStr('STR_NEEDTUPOLV'),self.obj:getLevel(),conf1['roleLevel'])
	self.needlvtx:setString(str)	
 	if self.obj:getLevel() < conf1['roleLevel'] then
 		self.needlvtx:setColor(COLOR_TYPE.RED)
 		self.tupobtn:setBright(false)
 		self.tupobtn:setEnabled(false)
 		self.goldbg:setVisible(false)
 		self.btntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
 	else
 		self.needlvtx:setColor(COLOR_TYPE.GREEN)
 		self.goldbg:setVisible(true)
 		self.tupobtn:setBright(true)
        self.tupobtn:setEnabled(true)
        self.btntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
 	end


	local award = DisplayData:getDisplayObj(conf1['cost'][1])

		self.richlabel[1]:setString('/'..GlobalApi:toWordsNumber(award:getNum()))
   	if award:getOwnNum() < award:getNum() then
    	self.ismaterialnumok  = false
    	self.materialObj = award
    	self.richlabel[2]:setColor(COLOR_TYPE.RED)
    else
    	self.richlabel[2]:setColor(COLOR_TYPE.WHITE)
	end
	self.richText:format(true)
	local award2 = DisplayData:getDisplayObj(conf1['cost'][2])

	ClassItemCell:updateItem(self.attneed[1], award2, 1)

	local richText2 = xx.RichText:create()
	local tx1 = award2:getOwnNum()
    local tx2 = '/' ..award2:getNum()
    richText2:setContentSize(cc.size(150, 20))
    local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    if award2:getOwnNum() < award2:getNum() then
    	self.ismaterialnumok  = false
    	self.materialObj = award2
    	re1:setColor(COLOR_TYPE.RED)
    end
    richText2:addElement(re1)
    richText2:addElement(re2)
    richText2:setAnchorPoint(cc.p(0.5,0.5))
    richText2:setAlignment('middle')
    richText2:setPosition(cc.p(0,0))
    richText2:format(true)
    self.attneed[1].lvTx:setVisible(true)
    self.attneed[1].lvTx:setString("")
    self.attneed[1].lvTx:removeAllChildren()
    self.attneed[1].lvTx:addChild(richText2)
    self.attneed[1].awardBgImg:setTouchEnabled(true)
   	self.attneed[1].awardBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI(award2,true)
        end
    end)

   	local maxlvnum = RoleMgr:calcRebornLvUpMaxNum(obj)
   	-- print('maxlvnum===========..'..maxlvnum)
   	-- print('obj:getTalent()=='..obj:getTalent())
   	local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('autotupo')
    if maxlvnum > 1 and isOpen then
    	self.btntx:setString(GlobalApi:getLocalStr('STR_AUTO_TUPO'))
    	self.tupobtn:addTouchEventListener(function (sender, eventType)
	    	if eventType ==  ccui.TouchEventType.ended then
	    		-- RoleMgr:sendRebornMsg(obj, maxlvnum, self.curattarr, self.nextattarr, function ()
	    		-- 	self:update(obj)
	    		-- end)
	    		RoleMgr:showRoleAutoReborn(obj)
			end
	    end)
    else
    	self.btntx:setString(GlobalApi:getLocalStr('STR_TUPO'))
    	self.tupobtn:addTouchEventListener(function (sender, eventType)
	    	if eventType ==  ccui.TouchEventType.ended then
	    		RoleMgr:sendRebornMsg(obj, 1, self.curattarr, self.nextattarr, function ()
	    			self:update(obj)
	    		end)
			end
	    end)
    end 

    -- JunZhu 
    local hid = obj:getId()
	if GameData:getConfData("hero")[hid].camp == 5 or  (conf1['cardCost'] < 1 and conf1['fragmentCost'] < 1 ) then
		self.attneed[1].awardBgImg:setPositionX((self.an[1] + self.an[2]) / 2)
		self.attneed[2].awardBgImg:setVisible(false)
		return
	end
	self.attneed[2].awardBgImg:setTouchEnabled(true)
    self.attneed[2].awardBgImg:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
        	if conf1['cardCost'] > 0 then
	        	GetWayMgr:showGetwayUI(obj,true,conf1['cardCost'])
	        else
	        	-- local str = 'fragment.'..hid..':1'
	        	local fragmentobj = BagData:getFragmentById(obj:getId())
	        	local num = 0
				if fragmentobj ~= nil then
					num =fragmentobj:getNum()
				end
	        	local displayobj = DisplayData:getDisplayObj({'fragment',hid,num})
	        	GetWayMgr:showGetwayUI(displayobj,true,conf1['fragmentCost'])
	        end
        end
    end)
    local objtemp  = RoleData:getRoleInfoById(hid)
	self.attneed[2].awardBgImg:setVisible(true)
	self.attneed[1].awardBgImg:setPositionX(self.an[1])
	ClassItemCell:updateItem(self.attneed[2], objtemp, 1)
    local richText2 = xx.RichText:create()
    local tx1 = ''
    local tx2 = ''
    local havecardnum = 0
    local fragmentonum = 0
	local cardobj =BagData:getCardById(obj:getId())
	if cardobj ~= nil then
		havecardnum =cardobj:getNum()
	end
	local fragmentobj = BagData:getFragmentById(obj:getId())
	if fragmentobj ~= nil then
		fragmentonum = fragmentobj:getNum()
	end
	
	if conf1['cardCost'] > 0 then
		tx1 = havecardnum
		tx2 = '/' .. conf1['cardCost']
		self.attneed[2].chipImg:setVisible(false)
	elseif conf1['fragmentCost'] > 0 then
		tx1 = fragmentonum
		tx2 = '/' .. conf1['fragmentCost']
		self.attneed[2].chipImg:setVisible(true)
		self.attneed[2].chipImg:loadTexture(obj:getChip())
	end
    local richText3 = xx.RichText:create()
    richText3:setContentSize(cc.size(150, 20))
    local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- if award2:getOwnNum() < award2:getNum() then
    -- 	self.ismaterialnumok  = false
    -- 	re1:setColor(COLOR_TYPE.RED)
    -- end

   	if conf1['cardCost'] > 0 then
		if conf1['cardCost'] > havecardnum then
			self.ismaterialnumok  = false
			re1:setColor(COLOR_TYPE.RED)
		end
	elseif conf1['fragmentCost'] > 0 then
		if conf1['fragmentCost'] > fragmentonum then
			self.ismaterialnumok  = false
			re1:setColor(COLOR_TYPE.RED)
		end
	end
	
    richText3:addElement(re1)
    richText3:addElement(re2)
    richText3:setAnchorPoint(cc.p(0.5,0.5))
    richText3:setAlignment('middle')
    richText3:setPosition(cc.p(0,0))
    richText3:format(true)
    self.attneed[2].lvTx:setString("")
    self.attneed[2].lvTx:setVisible(true)
    self.attneed[2].lvTx:removeAllChildren()
    self.attneed[2].lvTx:addChild(richText3)
end

function RoleTupo:updateMaxPanel(obj)
	local str = GlobalApi:getLocalStr('TITLE_TP')..' + '..self.obj:getTalent()
    RoleMgr:setRoleMainTitle(str)
	self.max_pl:setVisible(true)
	self.nor_pl:setVisible(false)
	local  conf = obj:getrebornConfByLv(maxlv)

	local att = RoleData:getPosAttByPos(obj)
	local curattarr = {}
    curattarr[1] = math.floor(att[1]) --(conf['baseAtk']+obj:getLevel()*conf['atkGrowth'])
    curattarr[2] = math.floor(att[4]) --(conf['baseHp']+obj:getLevel()*conf['hpGrowth'])
    curattarr[3] = math.floor(att[2]) --(conf['baseDef']+obj:getLevel()*conf['defGrowth'])
    curattarr[4] = math.floor(att[3]) --(conf['baseMagDef']+obj:getLevel()*conf['magDefGrowth'])

    for i=1,4 do
    	self.maxarr[i].atta:setString(GlobalApi:getLocalStr('STR_ATT' .. i))
		self.maxarr[i].attan:setString(curattarr[i])
    end

	local attacitvetx = self.attmaxbg:getChildByName('att_active_tx')
	attacitvetx:setString(GlobalApi:getLocalStr('TITLE_TF')..' +'..self.obj:getTalent())

	local innateGroupId = obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
	local innateid = groupconf[tostring('level' .. maxlv)]
	local effect =groupconf[tostring('value' .. maxlv)]
	local innateconf = GameData:getConfData('innate')[innateid]
	local tx1 = ''
	local tx2 = ''
	if innateid < 1000 then
		tx1 = innateconf['desc'] .. effect .. '%'
		if innateconf['type'] ~= 2 then
			tx1 = innateconf['desc'] .. effect
		end
			tx2 =  '【' .. innateconf['name'] ..'】 '
	else
		tx1 = groupconf[tostring('specialDes'..innateid%1000)]
		tx2 =  '【' .. groupconf[tostring('specialName'..innateid%1000)] ..'】 '
	end
	self.activattmaxtx:removeAllChildren()
 	self.activattmaxtx:setString('')
 	local attText = xx.RichText:create()
    attText:setContentSize(cc.size(450, 80))
    local richlabelatt1 = xx.RichTextLabel:create(tx2,23, COLOR_TYPE.ORANGE)
    richlabelatt1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local richlabelatt2 = xx.RichTextLabel:create(tx1,23, COLOR_TYPE.GREEN)
    richlabelatt2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    attText:addElement(richlabelatt1)
    attText:addElement(richlabelatt2)
    attText:setAnchorPoint(cc.p(0.5,0.5))

    attText:setAlignment('middle')
    self.activattmaxtx:addChild(attText,9527)
    attText:setVisible(true)
    attText:format(true)
    if attText:getBrushY() < 40 then
 		attText:setPosition(cc.p(0,-20))
 	else
 		attText:setPosition(cc.p(0,-10))
 	end

end

function RoleTupo:update(obj)
	self.obj = obj
	self.ismaterialnumok = true
	if self.obj:getTalent() >= maxlv then
		self:updateMaxPanel(self.obj)
	else
		self:updateNorPanel(self.obj)
	end
end

return RoleTupo