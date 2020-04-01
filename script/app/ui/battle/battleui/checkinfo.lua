local CheckInfoUI = class("CheckInfoUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassRoleObj = require('script/app/obj/roleobj')

function CheckInfoUI:ctor(data, uid)
    self.uiIndex = GAME_UI.UI_CHECKINFO
	self.data=data
	self.selected=1
	self.targetName=data.info.un
	self.isfriend = data.isFriend
	self.uid = tonumber(uid)
	self.heroList={}
	local tempList={}
	
	local isDroid=self:isDroid(uid)
	local headIcon=""
	local dragonUrl=""
	if isDroid==false then
		headIcon=GameData:getConfData("settingheadicon")[data.info.headpic].icon
		local id = tonumber(data.info.dragon)
		if id <= 0 then
			id = 1
		end
		dragonUrl=GameData:getConfData("playerskill")[id].roleRes
	end
	
	self.heroConfig = GameData:getConfData("hero")
	self.equipConfig = GameData:getConfData("equip")
	for k,v in pairs(data.info.pos) do
		local hero={}
		local info=self.heroConfig[tonumber(v.hid)]
        local obj = ClassRoleObj.new(tonumber(v.hid),0)
        obj:setPromoted(v.promote)
		if info~=nil then
			hero.hid=tonumber(v.hid)
			hero.pos=k
			hero.fightForce=v.fight_force
			hero.level=v.level
			hero.talent=v.talent
			hero.quality=obj:getQuality()
			hero.uiOffsetY = info.uiOffsetY
			hero.isKing = (tonumber(k)==1) and true or false
			hero.icon=(hero.isKing==true and isDroid==false) and headIcon or "uires/icon/hero/" .. info.heroIcon
			hero.url=(hero.isKing==true and isDroid==false) and dragonUrl or info.url			
			hero.name=(hero.isKing==true) and GlobalApi:getLocalStr('STR_MAIN_NAME') or info.heroName
			hero.name=(hero.talent>0) and hero.name.."+"..hero.talent or hero.name
			hero.equips={}
            hero.promoteSpecial = v.promote
            hero.camp = info.camp
			for m,n in pairs(v.equip) do
				local equip={}
				local equipInfo=self.equipConfig[tonumber(n.id)]
				if equipInfo~=nil then
					equip.pos=equipInfo.type
					equip.god=n.god
					equip.god_id=n.god_id
					equip.id=n.id
					equip.icon="uires/icon/equip/" .. equipInfo.icon
					equip.quality=equipInfo.quality
					equip.level=equipInfo.level
                    if v.part and v.part[tostring(m)] then
                        equip.partLevel = v.part[tostring(m)].level or 0
                    else
                        equip.partLevel = 0
                    end
					table.insert(hero.equips, equip)
				end
			end
			if hero.isKing == true then
				table.insert(self.heroList, hero)
			else
				table.insert(tempList, hero)
			end
			if v.promote and v.promote[1] then
				hero.promote = v.promote[1]
			end
		end
	end
	table.sort(tempList, function (a, b)
        return a.fightForce > b.fightForce
    end)
	for i=1, #tempList do
		table.insert(self.heroList, tempList[i])
	end
	self.equipList={}
end	

function CheckInfoUI:onShow()
	self:updatePanel()
end

function CheckInfoUI:updatePanel()
	
end

function CheckInfoUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2))
	
	local panel = bg2:getChildByName('contentPanel')
	self.title = bg2:getChildByName('title')
	self.title:setString(self.targetName)
	
	self.tempHeadCell=ccui.Helper:seekWidgetByName(bg2, 'headCell')
    self.tempHeadCell:setVisible(false)
	self.tempHeadCell:setTouchEnabled(false)
	
	--hero head
	self.headSv = bg2:getChildByName('head_sv')
    local contentWidget = ccui.Widget:create()
    self.headSv:addChild(contentWidget)
    local svSize = self.headSv:getContentSize()
    self.headSv:setScrollBarEnabled(false)
    contentWidget:setPosition(cc.p(0, svSize.height))
	
	--contentWidget:removeAllChildren()
	local innerHeight=0
	for i = 1, #self.heroList do
		local headPic = self:createHeadCell(i)
		innerHeight = i*115
		headPic:setPosition(cc.p(svSize.width/2, 50-innerHeight))
		contentWidget:addChild(headPic)
	end
	innerHeight = innerHeight < svSize.height and svSize.height or innerHeight
	self.headSv:setInnerContainerSize(cc.size(svSize.width, innerHeight))
	contentWidget:setPosition(cc.p(0, innerHeight))
	
    --[[
	self.addfriendbtn = bg2:getChildByName('add_friend_btn')
	self.addfriendbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local obj = {
		        id = tonumber(self.uid)
		    }
		    MessageMgr:sendPost('apply','friend',json.encode(obj),function (response)    
		        local code = response.code
		        local data = response.data
		        if code == 0 then
				    if response.data.status == 0 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_5'), COLOR_TYPE.GREEN)
				    elseif response.data.status == 1 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_8'), COLOR_TYPE.RED)
				    elseif response.data.status == 2 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_9'), COLOR_TYPE.RED)
				    elseif response.data.status == 3 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_3'), COLOR_TYPE.RED) 
				    elseif response.data.status == 4 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_2'), COLOR_TYPE.RED) 
				    elseif response.data.status == 5 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_6'), COLOR_TYPE.GREEN) 
				    elseif response.data.status == 6 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_1'), COLOR_TYPE.RED)
				    elseif response.data.status == 7 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_10'), COLOR_TYPE.RED)    
                    elseif response.data.status == 8 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_12'), COLOR_TYPE.RED)
                    elseif response.data.status == 9 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_4'), COLOR_TYPE.RED) 
                    elseif response.data.status == 10 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_14'), COLOR_TYPE.RED)    
				    end
		        else
		        end      
		    end)
        end
    end)
	self.addfriendbtntx = self.addfriendbtn:getChildByName('btntext')
	
	if not self.isfriend then
 		self.addfriendbtn:setBright(true)
        self.addfriendbtn:setEnabled(true)
        self.addfriendbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        self.addfriendbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_27'))
 	else
 		self.addfriendbtn:setBright(false)
 		self.addfriendbtn:setEnabled(false)
 		self.addfriendbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
 		self.addfriendbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_28'))
 	end
    --]]
	--hero view
	for i=1,6 do
		local armnode = panel:getChildByName('arm_' .. i .. '_img')
		armnode:setLocalZOrder(2)
		local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, nil, nil, true)
    	tab.awardBgImg:ignoreContentAdaptWithSize(true)
		local equiparr = {}
	    equiparr.icon = tab.awardImg
	    equiparr.icon:ignoreContentAdaptWithSize(true)
	    equiparr.fram = tab.awardBgImg
	    equiparr.node = armnode
	    equiparr.star = tab.starImg
	    equiparr.num = tab.starLv
	    equiparr.lv = tab.lvTx
	    equiparr.rhombImgs = tab.rhombImgs
		
		equiparr.fram:loadTexture('uires/ui/common/frame_default.png')
		equiparr.icon:loadTexture(DEFAULTEQUIP[i])
		
		table.insert(self.equipList, equiparr)
		armnode:addChild(tab.awardBgImg)
	end
	self.heroName=panel:getChildByName('name')
	self.roleBg=panel:getChildByName('roleBg')
	self.fightForce=ccui.Helper:seekWidgetByName(panel,'fightforce_tx')	
	
	self:setHeroView(self.selected)
	
	--close btn
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			BattleMgr:hideCheckLastInfo()
	    end
	end)
	
	--self:updatePanel()
end

function CheckInfoUI:ActionClose(call)
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

function CheckInfoUI:createHeadCell(idx)
	local hero=self.heroList[idx]
	
    local newCell = self.tempHeadCell:clone()
    ---------------------------
    ClassItemCell:setHeroPromote(newCell,hero.hid,hero.promoteSpecial)
    ---------------------------
	newCell:setName('cell'..idx)
	newCell.icon = ccui.Helper:seekWidgetByName(newCell,"icon")
    newCell.selectPic = ccui.Helper:seekWidgetByName(newCell,"selectPic")
    newCell.kingPic = ccui.Helper:seekWidgetByName(newCell,"kingPic")
	newCell.lvText = ccui.Helper:seekWidgetByName(newCell,"lv")
	
	newCell.icon:loadTexture(hero.icon)
	newCell.selectPic:setVisible(false)
	newCell.kingPic:setVisible(hero.isKing)
	newCell.lvText:setString("Lv."..hero.level)
	
    newCell:setVisible(true)
	newCell:setTouchEnabled(true)
	
	newCell:addClickEventListener(function ()
			self:setHeroView(idx)
        end)
		
    return newCell
end

function CheckInfoUI:setHeroView(idx)
	self.selected=idx
	for i = 1, #self.heroList do
		local cell=ccui.Helper:seekWidgetByName(self.headSv, 'cell'..i)
		cell.selectPic:setVisible( (i==idx) and true or false )
	end
	
	local hero=self.heroList[idx]
	if hero==nil then
		return
	end
	
	for i=1, 6 do
		local equipObj=nil
		local partLevel = 0
		for k,v in pairs(hero.equips) do
			if v.pos==i then
				equipObj=v
				partLevel = v.partLevel
			end
		end

		local num = 0
		local num1 = 1
		local pos = {
			[1] = {cc.p(48,91)},
			[2] = {cc.p(40,91),cc.p(56,91)},
			[3] = {cc.p(32,91),cc.p(48,91),cc.p(64,91)},
			[4] = {cc.p(24,91),cc.p(40,91),cc.p(56,91),cc.p(72,91)},
			[5] = {cc.p(16,91),cc.p(32,91),cc.p(48,91),cc.p(64,91),cc.p(80,91)},
		}
		if partLevel == 10 then
			num = 4
			num1 = 3
        elseif partLevel == 0 then
            num = 0
            num1 = 0
		else
			num = (partLevel - 1)%3 + 1
			num1 = math.ceil(partLevel/3)
		end

		if partLevel > 10 then
			num = partLevel - 10
			num1 = 4
		end

		for j=1,5 do
			if j <= num then
				self.equipList[i].rhombImgs[j]:loadTexture('uires/ui/common/rhomb_'..num1..'.png')
				self.equipList[i].rhombImgs[j]:setVisible(true)
				self.equipList[i].rhombImgs[j]:setPosition(pos[num][j])
			else
				self.equipList[i].rhombImgs[j]:setVisible(false)
			end
		end

		if equipObj~=nil then
			local equip = DisplayData:getDisplayObj({'equip',equipObj.id,equipObj.god_id,1})
			self.equipList[i].icon:loadTexture(equip:getIcon()) 
			self.equipList[i].fram:loadTexture(equip:getBgImg())
			ClassItemCell:setGodLight(self.equipList[i].fram,equipObj.god_id)
			local godlv = equipObj.god
			self.equipList[i].lv:setString('Lv.'..equipObj.level)
			if godlv > 0 then
				self.equipList[i].star:setVisible(true)
				self.equipList[i].num:setString(godlv)
			else
				self.equipList[i].star:setVisible(false)
				self.equipList[i].star:setVisible(false)
			end
			self.equipList[i].icon:setTouchEnabled(true)
            self.equipList[i].icon:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
		        	if equipObj then
						GetWayMgr:showGetwayUI(equip,false)
					end
		        end
		    end)
		else
			self.equipList[i].fram:loadTexture('uires/ui/common/frame_default.png')
			self.equipList[i].star:setVisible(false)
			self.equipList[i].icon:loadTexture(DEFAULTEQUIP[i]) 
			self.equipList[i].lv:setString('')
			ClassItemCell:setGodLight(self.equipList[i].fram,0)
			self.equipList[i].icon:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
		        	if equipObj then
						GetWayMgr:showGetwayUI(equip,false)
					end
		        end
		    end)
		end
	end
	
	local promote = hero.promote
	local weapon_illusion = nil
	local wing_illusion = nil
	if hero.camp == 5 then
		if self.data.info.weapon_illusion and self.data.info.weapon_illusion > 0 then
            weapon_illusion = self.data.info.weapon_illusion
        end
        if self.data.info.wing_illusion and self.data.info.wing_illusion > 0 then
            wing_illusion = self.data.info.wing_illusion
        end
	end
	local changeEquipObj = GlobalApi:getChangeEquipState(promote, weapon_illusion, wing_illusion)
	local model = GlobalApi:createLittleLossyAniByName(hero.url .. "_display", nil, changeEquipObj)
	self.roleBg:removeAllChildren()
	if model~=nil then
		model:getAnimation():play('idle', -1, 1)
		model:setPosition(cc.p(0,20+hero.uiOffsetY))
		self.roleBg:addChild(model)
	end
	
	self.fightForce:setString(hero.fightForce)
	self.heroName:setString(hero.name)
	self.heroName:setTextColor(COLOR_QUALITY[hero.quality])
end

function CheckInfoUI:isDroid(uid)
	if tonumber(uid) <= 1000000 then
		return true
	else
		return false
	end
end

return CheckInfoUI