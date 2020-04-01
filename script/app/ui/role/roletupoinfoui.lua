local RoleTupoInfoUI = class("RoleTupoInfoUI", BaseUI)

local leftInterval = 5
local verticalInterval = 15
local infoInterval = 6
local fengexian_height = 3
function RoleTupoInfoUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_ROLETUPOINFO
	self.obj = obj
end

function RoleTupoInfoUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img_1')
    self:adaptUI(bgimg, bgimg1)
    local bgimg2 = bgimg1:getChildByName('bg_img_2')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideRoleTupoInfoUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('TITLE_TF')..' +'..self.obj:getTalent())
    local node = self:genTalent()
    local bgimg3 = bgimg2:getChildByName('bg_img_3')
    --node:setPosition(cc.p(0,0))
    --bgimg3:addChild(node)

    local sv = bgimg3:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    if node:getContentSize().height > sv:getContentSize().height then
        sv:setInnerContainerSize(cc.size(sv:getContentSize().width,node:getContentSize().height))
    end
    node:setAnchorPoint(cc.p(0, 0))
    node:setPosition(cc.p(0,0))
    sv:addChild(node)

end

function RoleTupoInfoUI:genTalent()
	local ret = cc.Node:create()

	local txTalentinfo = cc.Label:createWithTTF("", "font/gamefont.ttf", 21)
	txTalentinfo:setTextColor(cc.c3b(255,247,228))
	txTalentinfo:enableOutline(cc.c4b(78,49,17, 255), 1)
	txTalentinfo:enableShadow(cc.c4b(78,49,17, 255), cc.size(0, -1), 0)
	txTalentinfo:setPosition(cc.p(leftInterval+5, verticalInterval))
	txTalentinfo:setAnchorPoint(cc.p(0, 0))
	txTalentinfo:setString(GlobalApi:getLocalStr('STR_TUPOINFO'))

	local rt = xx.RichText:create()
	rt:setContentSize(cc.size(450, 500))
	rt:setAnchorPoint(cc.p(0, 0))
	rt:setPosition(cc.p(leftInterval, txTalentinfo:getContentSize().height + verticalInterval + infoInterval))

	local innateGroupId = self.obj:getInnateGroup()
	local groupconf = GameData:getConfData('innategroup')[innateGroupId]
	local teamnum = 1
	for i = 2, 16 do
		local innateid = groupconf[tostring('level' .. i-1)]
		local specialtab = groupconf['highlight']
		local teamtab = groupconf['teamvaluegroup']
		local effect =groupconf[tostring('value' .. i-1)]
		local innateconf = GameData:getConfData('innate')[innateid]
		local teamheroID = groupconf['teamheroID']
		local tx1 = ''
		local tx2 = ''
		local tx3 = ''
		local tx4 = ''
		local re1 = xx.RichTextLabel:create(tx1, 21, cc.c4b(163, 163, 163, 255))
		re1:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re1:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))
		local re3 = xx.RichTextLabel:create(tx3, 23, cc.c4b(163, 163, 163, 255))
		re3:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re3:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re2 = xx.RichTextLabel:create(tx2, 21, cc.c4b(163, 163, 163, 255))
		re2:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re2:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re5 = xx.RichTextLabel:create(tx4, 21, cc.c4b(163, 163, 163, 255))
		re5:setStroke(cc.c4b(0, 0, 0, 255), 1)
		re5:setShadow(cc.c4b(40, 40, 40, 255), cc.size(0, -1))

		local re6 = xx.RichTextImage:create('uires/ui/common/arrow5.png')
		re6:setScale(0.6)

		local s = GlobalApi:tableFind(teamtab,i-1)

		if s ~= 0 then
			tx4 =  groupconf[tostring('teamDes'..teamnum)]
			re5:setString(tx4)
			teamnum = teamnum + 1
		end
		if innateid < 1000 then
			tx1 = innateconf['desc'] .. effect .. '%'
			if innateconf['type'] ~= 2 then
				tx1 = innateconf['desc'] .. effect
			end
			tx3 =  '【' .. innateconf['name'] ..'】 '
			tx2 =  '（' .. GlobalApi:getLocalStr('TITLE_TP')  ..' '.. '+' .. i-1 ..' '.. GlobalApi:getLocalStr('STR_JIHUO') ..'）'
		else
            tx1 = groupconf[tostring('specialDes'..innateid%1000)]
			tx3 =  '【' .. groupconf[tostring('specialName'..innateid%1000)] ..'】 '
			tx2 =  '（' .. GlobalApi:getLocalStr('TITLE_TP')  ..' '.. '+' .. i-1 ..' '.. GlobalApi:getLocalStr('STR_JIHUO') ..'）'
		end
		local n  = GlobalApi:tableFind(specialtab,i-1)
		
		if  self.obj:getTalent() >= i -1 then
			re3:setColor(cc.c4b(254, 165, 0, 255))
			re2:setColor(cc.c4b(254, 165, 0, 255))
			
			re1:setString(tx1)
			re2:setString(tx2.. '\n')
			re3:setString(tx3)

			rt:addElement(re3)

			if n == 0 then
				re1:setColor(cc.c4b(36, 255, 0, 255))
				re5:setColor(cc.c4b(36, 255, 0, 255))
			else
				re1:setColor(cc.c4b(255, 0, 0, 255))
				re5:setColor(cc.c4b(255, 0, 0, 255))
				local re4 = xx.RichTextImage:create('uires/ui/common/icon_star3.png')
				re4:setScale(0.8)
				rt:addElement(re4)
			end

			rt:addElement(re1)
			if s ~= 0 then
				rt:addElement(re6)
				rt:addElement(re5)
				local obj = RoleData:getRoleById(teamheroID) 
				if not obj then
					re5:setColor(cc.c4b(163, 163, 163, 255))
				end
			end
			rt:addElement(re2)
		else
			re1:setColor(cc.c4b(163, 163, 163, 255))
			re3:setColor(cc.c4b(163, 163, 163, 255))
			re2:setColor(cc.c4b(163, 163, 163, 255))
			re5:setColor(cc.c4b(163, 163, 163, 255))
			re1:setString(tx1)
			re2:setString(tx2.. '\n')
			re3:setString(tx3)
			rt:addElement(re3)

			if n ~= 0 then
				local re4 = xx.RichTextImage:create('uires/ui/common/icon_star3_bg.png')
				re4:setScale(0.8)
				rt:addElement(re4)
			end
			rt:addElement(re1)
			if s ~= 0 then
				rt:addElement(re6)
				rt:addElement(re5)
			end
			rt:addElement(re2)

		end
	end
	rt:setRowSpacing(6)
 	rt:format(true)
 	local rteSize = rt:getElementsSize()
 	rt:setContentSize(rteSize)

	local frame = ccui.ImageView:create('uires/ui/common/touban.png')
	frame:setScale9Enabled(true)
	frame:setAnchorPoint(cc.p(0, 0))

	local frameHeight = rteSize.height + verticalInterval * 2 + infoInterval + txTalentinfo:getContentSize().height
	frame:setContentSize(cc.size(bgWidth, frameHeight))
	frame:addChild(rt)
	frame:addChild(txTalentinfo)


	local sumHeight = frameHeight
	ret:setContentSize(cc.size(bgWidth, sumHeight))

	ret:addChild(frame)
	return ret
end

return RoleTupoInfoUI