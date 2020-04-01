local RoleAutoRebornUI = class("RoleAutoRebornUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function RoleAutoRebornUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_AUTOREBORN
	self.obj = obj
	self.times = 1
	self.min = 1
	self.maxTimes = RoleMgr:calcRebornLvUpMaxNum(self.obj)
end

function RoleAutoRebornUI:init()
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
            RoleMgr:hideRoleAutoReborn()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg_img')
    local titletx = titlebg:getChildByName('info_tx')
    titletx:setString(GlobalApi:getLocalStr('STR_AUTO_TUPO_1'))

    local funcbtn = bgimg2:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('info_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_AUTO_TUPO_1'))
    funcbtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
    		RoleMgr:sendRebornMsg(self.obj, self.times, self.curattarr, self.nextattarr, function ()
    			self:update(obj)
    		end)
    		RoleMgr:hideRoleAutoReborn()
        end
    end)
    self.lessBtn = bgimg2:getChildByName("less_btn")
	self.addBtn = bgimg2:getChildByName("add_btn")
	self.costNumTx = bgimg2:getChildByName('cost_num_tx')
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
    
    --self.nodetab = {}
    self.attneed = {}
    for i=1,3 do
    	local itembg  = bgimg2:getChildByName('node_'..i)
    	local itemCell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
    	itemCell.awardBgImg:setPosition(cc.p(itembg:getPosition())) 
    	itemCell.awardBgImg:setScale(0.8)
    	itemCell.lvTx:setPosition(cc.p(47, -15))
    	itemCell.lvTx:setAnchorPoint(cc.p(0.5,0.5))
    	bgimg2:addChild(itemCell.awardBgImg)
    	self.attneed[i] = itemCell
    end
    local lvdesctx = bgimg2:getChildByName('lv_desc_tx')
	self.richText = xx.RichText:create()
	self.richText:setAlignment('middle')
    self.richText:setVerticalAlignment('middle')
    self.richText:setContentSize(cc.size(500, 75))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_AUTO_TUPO_3'), 24, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
	self.re2 = xx.RichTextLabel:create('',24,COLOR_TYPE.GREEN)
    self.re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
    
	self.richText:addElement(re1)
	self.richText:addElement(self.re2)
    self.richText:setAnchorPoint(cc.p(0.5,0.5))
    self.richText:setPosition(cc.p(0,-20))
    lvdesctx:addChild(self.richText)
    local timesdesctx = bgimg2:getChildByName('times_select_tx')
    timesdesctx:setString(GlobalApi:getLocalStr('STR_AUTO_TUPO_2'))

    self:update()
end

function RoleAutoRebornUI:update()
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

	local att = RoleData:getPosAttByPos(self.obj)
	self.curattarr = {}
    self.curattarr[1] = math.floor(att[1])--(conf['baseAtk']+obj:getLevel()*conf['atkGrowth'])
    self.curattarr[2] = math.floor(att[4]) --(conf['baseHp']+obj:getLevel()*conf['hpGrowth'])
    self.curattarr[3] = math.floor(att[2]) --(conf['baseDef']+obj:getLevel()*conf['defGrowth'])
    self.curattarr[4] = math.floor(att[3]) --(conf['baseMagDef']+obj:getLevel()*conf['magDefGrowth'])
    self.nextattarr = {}
    local objtemp = clone(self.obj)
    objtemp:setTalent(self.obj:getTalent()+self.times)
    local atttemp = RoleData:CalPosAttByPos(objtemp,true)
    self.nextattarr[1] = math.floor(atttemp[1])
    self.nextattarr[2] = math.floor(atttemp[4])
    self.nextattarr[3] = math.floor(atttemp[2])
    self.nextattarr[4] = math.floor(atttemp[3])

    local tx = GlobalApi:getLocalStr('STR_AUTO_TUPO_4')..'+'..tostring(self.obj:getTalent()+self.times)
    self.re2:setString(tx)
    self.richText:format(true)

    local costobjs = RoleMgr:calcRebornCost(self.obj,self.obj:getTalent(),self.times)
    local num = 1
    local costnum = 0
    for i,v in ipairs(costobjs) do
    	if v:getType() ~= 'user' and v:getNum() > 0 then
    		ClassItemCell:updateItem(self.attneed[num], v, 1)
    		self.attneed[num].lvTx:setString(GlobalApi:toWordsNumber(v:getOwnNum())..'/'..GlobalApi:toWordsNumber(v:getNum()))
    		costnum = costnum + 1
    		num = num + 1
    	elseif v:getType() == 'user' then
    		self.costNumTx:setString(GlobalApi:toWordsNumber(v:getOwnNum())..'/'..GlobalApi:toWordsNumber(v:getNum()))
    	end
    end
    for i=1,3 do
    	self.attneed[i].awardBgImg:setVisible(false)
    end
   	for i=1,costnum do
    	self.attneed[i].awardBgImg:setVisible(true)
    end
    if costnum == 1 then
    	self.attneed[1].awardBgImg:setPosition(cc.p(169,334))
    elseif costnum == 2 then
    	self.attneed[1].awardBgImg:setPosition(cc.p(80,334))
    	self.attneed[2].awardBgImg:setPosition(cc.p(200,334))
    elseif costnum == 3 then
    	self.attneed[1].awardBgImg:setPosition(cc.p(169,334))
    	self.attneed[2].awardBgImg:setPosition(cc.p(79,334))
    	self.attneed[3].awardBgImg:setPosition(cc.p(262,334))
    end
end

return RoleAutoRebornUI