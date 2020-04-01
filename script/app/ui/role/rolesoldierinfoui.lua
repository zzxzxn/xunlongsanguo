local RoleSoldierInfoUI = class("RoleSoldierInfoUI", BaseUI)

function RoleSoldierInfoUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_SOLDIERINFO
	self.dirty = false
	self.obj = obj
end

function RoleSoldierInfoUI:setDirty(onlychild)
	self.dirty = true
end
function RoleSoldierInfoUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionActivityMainUI()
    --     end
    -- end)
    local bgimg3 = bgimg2:getChildByName('bg_img1')
    local closebtn = bgimg3:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            RoleMgr:hideSoldierinfo()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    local titlebg = bgimg3:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('SOLDIERINFO'))
    local bgimg4 = bgimg3:getChildByName('bg_img3')
    self.soldierarr = {}
    for i=1,5 do
    	local arr = {}
    	local bg = bgimg4:getChildByName('soldier_'..i..'_bg')
    	arr.soldierimg = bg:getChildByName('soldier_img')
    	local namebg = bg:getChildByName('name_bg')
    	arr.nametx = namebg:getChildByName('name_tx')
    	arr.statetx = bg:getChildByName('state_tx')
    	arr.nameimg = bg:getChildByName('name_img')
    	self.soldierarr[i] = arr
    end
    self:update()
end

function RoleSoldierInfoUI:update()
	local arr = self.obj:getSoldierInfoArr()
	local soldlevelconf = GameData:getConfData('soldierlevel')[self.obj:getSoldierId()][self.obj:getSoldier().level]
	
	for i=1,5 do
		self.soldierarr[i].soldierimg:loadTexture('uires/ui/role/role_' ..arr[i][2])
		
		local soldlevelconftemp = GameData:getConfData('soldierlevel')[self.obj:getSoldierId()][arr[i][1]]
		local soldconf = GameData:getConfData('soldier')[soldlevelconftemp['soldierId']]
		self.soldierarr[i].nametx:setString(soldlevelconftemp['name'])
		self.soldierarr[i].nametx:setTextColor(COLOR_QUALITY[soldlevelconftemp['quality']])
		-- if soldlevelconf
		if soldlevelconftemp['soldierIcon'] ~= soldlevelconf['soldierIcon'] and self.obj:getSoldier().level < arr[i][1] then
			self.soldierarr[i].nameimg:setVisible(false)
			self.soldierarr[i].statetx:setVisible(true)
			self.soldierarr[i].statetx:setTextColor(COLOR_TYPE.RED)
			self.soldierarr[i].statetx:setString(arr[i][1]..GlobalApi:getLocalStr('SOLDIERINFO_DESC3'))
		elseif soldlevelconftemp['soldierIcon'] ~= soldlevelconf['soldierIcon'] and self.obj:getSoldier().level > arr[i][1] then
			self.soldierarr[i].nameimg:setVisible(false)
			self.soldierarr[i].statetx:setVisible(true)
			self.soldierarr[i].statetx:setTextColor(COLOR_TYPE.GREEN)
			self.soldierarr[i].statetx:setString(GlobalApi:getLocalStr('SOLDIERINFO_DESC2'))
		else
			self.soldierarr[i].nameimg:setVisible(true)
			self.soldierarr[i].statetx:setVisible(false)
			--self.soldierarr[i].statetx:setString(GlobalApi:getLocalStr('SOLDIERINFO_DESC1'))
		end
	end
end

function RoleSoldierInfoUI:calcLvLimit()
	local data
end

return RoleSoldierInfoUI