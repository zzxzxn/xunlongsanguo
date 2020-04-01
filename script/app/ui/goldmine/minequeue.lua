local MineQueueUI = class("MineQueueUI", BaseUI)
function MineQueueUI:ctor()
    self.uiIndex = GAME_UI.UI_MINECOLLECTQUEUE
end
function MineQueueUI:init()
	
	self.rootbg = self.root:getChildByName("bg")
    self.bg = ccui.Helper:seekWidgetByName(self.rootbg, "root")

    self:adaptUI(self.rootbg,self.bg)

	self.sumNum  = self.bg:getChildByName("sum_num")
	self.sumTime = self.bg:getChildByName("sum_time")
	if (nil ~= self.sumTime) then
		local str = string.format(GlobalApi:getLocalStr("MINE_QUEUE_SUM_TIME"), GlobalApi:toStringTime(0,"HMS"));
		self.sumTime:setString(str);
	end
	
	self.sv       = ccui.Helper:seekWidgetByName(self.bg,"sv")
	self.clearBtn = self.bg:getChildByName("clear_btn")
    self.btnText  = self.clearBtn:getChildByName("text")
	
	self:Update();

    local close_btn = self.bg:getChildByName("close_btn")

    local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            MineMgr:hideMineQueueUI()
		end
	end
	close_btn:addTouchEventListener(callBack)

end


function MineQueueUI:Update()
    self.sv:removeAllChildren()
	self:SetBG();
	self:SetSV();
	self:SetClearBtn();
	self:SetSumNum();
end

function MineQueueUI:SetBG()
	local ctr = self.rootbg;
	if (nil == ctr) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            MineMgr:hideMineQueueUI()
		end
	end
	ctr:addTouchEventListener(callBack);
end

function MineQueueUI:SetSumNum()
	local ctr = self.sumNum;
	if (nil == ctr) then
		return;
	end
	
	local num = #MineMgr._collectQueue;
	local max = MineMgr._maxQueueCount;
	local str = string.format("%d/%d", num, max);
	ctr:setString(str);
end

function MineQueueUI:SetClearBtn()
	local ctr = self.clearBtn;
	if (nil == ctr) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            -- µ¯¿ò
            promptmgr:showMessageBox(GlobalApi:getLocalStr("MINE_CLEAR_QUEUE_SURE"),
                                        MESSAGE_BOX_TYPE.MB_OK_CANCEL,
                                    function () MineMgr:SendCancelAllMessage(); end )

		end
	end

    self.btnText:setString(GlobalApi:getLocalStr("MINE_CLEAR_QUEUETX"))
	
	local queue = MineMgr._collectQueue;
	local len = #queue;
	if (len <= 0) then
		ctr:setColor(cc.c3b(123, 158, 129));
        ctr:setTouchEnabled(false)
	else
		ctr:setColor(cc.c3b(255, 255, 255));
        ctr:setTouchEnabled(true)
	end
	ctr:addTouchEventListener(callBack);
end

function MineQueueUI:SetSV()
	local ctr = self.sv;
	if (nil == ctr) then
		return;
	end
	
	local clearSV = function ()
		local count = 1;
		while true do
			local layout = ctr:getChildByName("head_layout" .. tostring(count))
			if (nil == layout) then
				break;
			end
			
			if (nil ~= ctr) then
				ctr:removeChild(layout, true);
			end
			count = count + 1;
		end
	end
	
	local svSize = ctr:getSize();
	local cellSize = cc.size(80, 80);
	local queue = MineMgr._collectQueue;
	local len = #queue;
	local hNum = 1;
	local vNum = len/hNum;
	local space = cc.size(20, 20);
	local innerWidth = cellSize.width*vNum+vNum*space.width+20;
	local innerHeight = cellSize.height*hNum+(hNum-1)*space.height;
	innerHeight = ((innerHeight<=svSize.height) and svSize.height or innerHeight);
	local startPosX = 18.0;
	local startPosY = innerHeight-cellSize.height-20.0;
	
	clearSV();
	ctr:setTouchEnabled(true);
	ctr:setInnerContainerSize(cc.size(innerWidth, innerHeight));
	ctr:setClippingEnabled(true);
	ctr:setClippingType(1);
	ctr:setDirection(2);
	
	for i=1, len do
		repeat
		local value = queue[i];
		if (nil == value) then
			break;
		end
        local mineType = MineMgr:getMineType(value.data);
		local mineIni = MineMgr.config_mine[mineType];

		local posX = startPosX+(i-1)%vNum*(cellSize.width+space.width);
		local posY = startPosY-math.floor((i-1)/vNum)*(cellSize.height+space.height)-10;
		local award = DisplayData:getDisplayObj(mineIni.product[1])

		local layout = ccui.Layout:create();
		layout:setSize(cc.size(80, 80));
		layout:setBackGroundImage(award:getBgImg());
		layout:setPosition(ccp(posX, posY));
		layout:setName("HeadLayout" .. tostring(i));
        layout:setLocalZOrder(len - i)

		
		local icon = ccui.ImageView:create();
		icon:loadTexture(mineIni.path, 1);
		icon:setPosition(ccp(40, 40));
		icon:setName("icon");
		layout:addChild(icon);

        local label = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
        label:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
		label:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        label:setString(GlobalApi:toStringTime(value.remainTime,2))
		label:setPosition(ccp(40, 10));
		label:setName("label");
		layout:addChild(label);
		
		local callBack = function (sender, eventType)
			if (eventType == ccui.TouchEventType.ended) then
				--MineMgr:c2sCancelMine(sender.indexX, sender.indexY, sender.id);
                MineMgr:SendCancelMessage(sender.indexX, sender.indexY);
				--DelGetMineScheduler();
			end
		end
		local btn = ccui.Button:create();
		btn:setTouchEnabled(true);
		btn:loadTextureNormal("uires/ui/mine/close_1.png");
		btn:setPosition(ccp(82, 83));
		btn.indexX = value.x;
		btn.indexY = value.y;
		btn.id = value.id;
		btn:setScale(0.5);
		btn:addTouchEventListener(callBack);
		layout:addChild(btn);
		ctr:addChild(layout);
		until true
	end
end

function MineQueueUI:SetSumTime(headTime)
	local time = headTime;
	
	local ctr = self.sumTime;
	if (nil == ctr) then
		return;
	end
	
	local queue = MineMgr._collectQueue;
	self.sumTimeValue = 0.0;
	for i=1, #queue do
		repeat
		local cell = queue[i];
		if (nil == cell) then
			break;
		end
		
		self.sumTimeValue = self.sumTimeValue + cell.remainTime;
		until true
	end
	
	self.sumTimeValue = self.sumTimeValue + headTime;
    --print('timetimetimetimetimetimetimetimetime' .. self.sumTimeValue)
	local str = string.format(GlobalApi:getLocalStr("MINE_QUEUE_SUM_TIME"), GlobalApi:toStringTime(self.sumTimeValue,"HMS",2));
	ctr:setString(str);

    

end
function MineQueueUI:SetSVHeadCellTime(headTime)
	
	local headLayout = self.sv:getChildByName("head_layout1")
	if (nil == headLayout) then
		return;
	end
	
	local label = headLayout:getChildByName("label")
	if (nil == label) then
		return;
	end
	
	label:setString(GlobalApi:toStringTime(headTime,"HMS",2));
end

return MineQueueUI