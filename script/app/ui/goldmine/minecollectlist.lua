local MineCollectListUI = class("MineCollectListUI", BaseUI)
function MineCollectListUI:ctor()
    self.uiIndex = GAME_UI.UI_MINECOLLECTLIST
end
function MineCollectListUI:init()
	
    con = cc.UIHelper:seekWidgetByName(self.root, "con")
    con:getChildByName('titletx'):setString(GlobalApi:getLocalStr('MINE_DES8'))


	if (nil == con ) then
		return;
	end
	
	for i=1, 8 do
		repeat
		
		local name = "mine_con" .. tostring(i);
		local cell = con:getChildByName(name)
		if (nil == cell) then
			break;
		end
		
		local icon = cell:getChildByName("icon")
		if (nil == icon) then
			break;
		end
		
		local num = cell:getChildByName("num")
		if (nil == num) then
			break;
		end
		
		table.insert(self.mineCons, {layout=cell, icon=icon, num=num,});
		until true
	end
	
	self.sureBtn = con:getChildByName("sure_btn")
	self.sureBtn:getChildByName('text'):setString(GlobalApi:getLocalStr('MINE_DES9'))

    self.mineCons = {}
	self:Update();
end

function MineCollectListUI:Update()
	self:SetMineCon();
	self:SetSureBtn();
end

function MineCollectListUI:SetMineCon()
	if (nil == self.mineCons) then
		return;
	end
	
	local arrLen = #self.mineCons;
	if (nil == arrLen or 0 == arrLen) then
		return;
	end
		
	for i=1, arrLen do
		repeat
			local ctr = self.mineCons[i];
			if (nil == ctr) then
				break;
			end
			
			if (nil == ctr.icon) then
				break;
			end
			
			if (nil == ctr.num) then
				break;
			end
			ctr.icon:setVisible(false);
			ctr.num:setVisible(false);
		until true
	end
	
	local list = MineMgr:getCollectList();
	local len = #list;
	for i=1, len do
		repeat
			local ctr = self.mineCons[i];
			if (nil == ctr) then
				break;
			end
			
			if (nil == ctr.icon) then
				break;
			end
			
			if (nil == ctr.num) then
				break;
			end
			
			local data = list[i];
			if (nil == data) then
				break;
			end
			
			local ini = MineIcon[data.type];
			if (nil == ini) then
				break;
			end
			ctr.icon:setVisible(true);
			local path = MineMgr.getMinePath(ini.id);
			ctr.icon:loadTexture(path, 1);
			ctr.num:setVisible(true);
			ctr.num:setTextAreaSize(CCSize(0, 0));
			ctr.num:setText(tostring(data.count));
			
			if (len == 1) then
				ctr.layout:setPosition(ccp(210, 240));
			else
				if (i == 1) then
					ctr.layout:setPosition(ccp(120, 380));
				end
			end
		until true
	end
end

function MineCollectListUI:SetSureBtn()
	local ctr = self.sureBtn;
	if (nil == ctr) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
			CloseUI("MineCollectListUI");
			MineClearOP(0);
		end
	end		

	ctr:addTouchEventListener(callBack);
end
return MineCollectListUI