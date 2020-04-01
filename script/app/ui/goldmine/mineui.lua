local MineUI = class("MineUI", BaseUI)
function MineUI:ctor()
    self.uiIndex = GAME_UI.UI_MINE

    self.MineCount = 10
	self.ToolCount = 2

    	--leftCon
	self.mineAxeCon = nil;
	self.mineAxeConEffect = nil;
	self.mineAxeText = nil;
	self.mineAxeLoadingBar = nil;
	self.mineAxeAddBtn = nil;
	self.mineAxe_Scheduler = nil;
	
	self.norCon = nil; --普通雕像
	self.norIcon = nil;
	self.norLev = nil;
	self.norNum = nil;
	
	self.bossCon = nil; --boss显示容器
	self.bossTime = nil;
	self.dropGoods= nil;
	self.StatueBoss_Scheduler = nil;
	self.bossFollowFlag = nil;

	self.pageUpBtn = nil;
	self.pageDownBtn = nil;
	self.locationBtn = nil;
	self.pushLocationBtn = false;
	self.curArea = nil;
	self.areaLoadingBar = nil;
	self.areaLBText = nil;
	
	self.backBtn = nil; --返回
	self.backBtnEffect = nil; --返回按钮所显示特效
	
	--rightCon
	self.resetTime = nil;
	self.resetBtn = nil;
	self.resetString = nil;
	self.reset_Scehduler = nil;
		
	self.mineCons = {}; --矿列表显示控件组
	
	self.lookCollectQueue = nil;
	self.getAllBtn = nil;
	self.vipTips = nil;
    	
	self.toolCons = {}; --炸弹表显示控件组
	self.drapBombEffect = nil; --拖拽的炸弹
	self.bombEffect = nil; --一个Layout，表现bomb的效果
	
	--middleCon
	self.isPerCreateCell = false;
	self.mineSV = nil;
	self.mineSVInner = nil;
	self.svSize = nil;
	self.svInnerSize = nil;
	self.svAutoScheduler = nil; --ScrollView自动滑动的定时器
	self.svMoveFlag = false; --矿区是否滑动标记
	
	self.mineCon = nil; --存矿UI的容器
	self.batchNode = nil;
	self.cellTable = {}; --存储矿区cell的容器
	self.freeCellTable = {}; --空闲表
	self.particleTable = {}; --存储正在使用的粒子
	self.cellWidthNum = 0; --矿区一屏横排包含多少个cell
	self.cellHeightNum = 0; --矿区一屏竖排包含多少个cell
	self.cellNum = 0; --矿区Cell一屏的数量
	self.svStartIndexPos = cc.p(0, 0);--每次滑动后，矿块的起始坐标
	self.viewRect = nil;
	
	--挖掘相关
	self.curDigPos = nil; --当前挖掘块索引
	self.curDigType = nil; --当前挖掘土块的类型
	self.dig_Scheduler = nil; --连续挖掘定时器(定时给服务器发送挖掘包)
	self.digLoadingBar = nil; --挖掘土壤进度条
	
	--收取相关
	self.getMineCon = nil; --一个Layout,表现收矿的倒计时控件
	self.getMine_Scheduler = nil; --收矿定时器
	self.getMineCloseBtn = nil; --收矿点击的关闭按钮
	self.getMineMusicFlag = nil; --收矿的音效开关


    self.scrollState = true

end
function MineUI:init()
    local root    =  self.root:getChildByName("root")
    self.Layer = self.root

    cc.SpriteFrameCache:getInstance():addSpriteFrames("uires/ui/mine/Mine.plist");
    --resize
    local winSize = cc.Director:getInstance():getWinSize()
	local scale =  winSize.height/winSize.width;
	local newHeight = 1024 * scale;
    root:setContentSize(cc.size(1024,newHeight))
    root:setScale(1024/winSize.width)

    self.conY = (newHeight - 576)/2

    self:adaptUI(root, nil,true)
    root:setPosition(cc.p(0,0))

    self.rootBG = root

    self:InitStaticUI()
    self:InitDynamicUI();
    self:Update()


end
function MineUI:onHide()
    if (self.mineAxe_Scheduler ~= nil) then
		self:unregisterScheduler(self.mineAxe_Scheduler);
	end
	
	if (self.StatueBoss_Scheduler ~= nil) then
		self:unregisterScheduler(self.StatueBoss_Scheduler);
	end
	
	if (self.reset_Scehduler ~= nil) then
		self:unregisterScheduler(self.reset_Scehduler);
	end
	
	if (self.dig_Scheduler ~= nil) then
		self:unregisterScheduler(self.dig_Scheduler);
	end
	
	if (self.getMine_Scheduler ~= nil) then
		self:unregisterScheduler(self.getMine_Scheduler);
	end
	
	if (self.svAutoScheduler ~= nil) then
		self:unregisterScheduler(self.svAutoScheduler);
	end

    if (self.bossStatue_Scheduler ~= nil) then
		self:unregisterScheduler(self.bossStatue_Scheduler);
	end


end
function MineUI:CreateEffect(path,armatureName,loop,removeCallBack,actionName)
	

    local jsonPath = string.format("%s.json",path)
	local plistPath = string.format("%s.plist",path)
	cc.SpriteFrameCache:getInstance():addSpriteFrames(plistPath)
    ccs.ArmatureDataManager:getInstance():addArmatureFileInfo(jsonPath)	

    local armature = CCArmature:create(armatureName)	

	if(armature == nil) then
		return nil
	end
	
	actionName = actionName or "run"
	if(loop) then
		armature:getAnimation():play(actionName)	
	else
		local function AnimationEvent(armatureBack,movementType,movementID)
			if (movementType ~= 0) then									
				--self.battleNode:removeChild(self.changeEffect,true)
				armature:removeFromParent(true)
				if(removeCallBack ~= nil) then
					removeCallBack()
				end
			end	
		end
		armature:getAnimation():play(actionName)	
		armature:getAnimation():setMovementEventCallFunc(AnimationEvent)
	end
	
	return armature
end
function MineUI:InitStaticUI()
	local root = self.rootBG;
	
	--设置LeftCon
	local leftCon = root:getChildByName("left_con");
	local leftCon_Con = ccui.Helper:seekWidgetByName(leftCon, "con");

    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.MINEUI)
    btn:setPosition(cc.p(50 ,394))
    leftCon_Con:addChild(btn)

    local mask = leftCon_Con:getChildByName('mask')
    mask:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            -- 下点矿锄恢复：6:30
            -- 全部矿锄恢复：12:30:20
            -- 矿锄恢复时间：6分钟
            local sum = MineMgr._sumDigCount
	        local remain = MineMgr._remainDigCount

            if remain < sum then
                if self.remainTime then 
                    local remainTime =self.remainTime             
                    local function getTime(t)
                        local h = string.format("%02d", math.floor(t/3600))
                        local m = string.format("%02d", math.floor(t%3600/60))
                        local s = string.format("%02d", math.floor(t%3600%60%60))
                        if tonumber(h) < 0 then
                            return GlobalApi:getLocalStr("STR_ONEDAY_BEFORE")
                        else
                            return h..':'..m..':'..s
                        end
                    end

                    local sumTime = MineMgr._mineAxeRecoverCD * 60
                    local endTime = getTime(GlobalData:getServerTime() + remainTime - Time.beginningOfToday())
                    local allTime = remainTime + (sum - remain - 1) * sumTime
                    local allEndTime
                    if allTime > 86400 then
                        allEndTime = GlobalApi:getLocalStr("MINE_DES100")
                    else
                        allEndTime = getTime(GlobalData:getServerTime() + allTime - Time.beginningOfToday())
                    end

                    local des1 = string.format(GlobalApi:getLocalStr('MINE_DES103'),sumTime/60)
                    local des2 = string.format(GlobalApi:getLocalStr('MINE_DES101'),endTime)
                    local des3 = string.format(GlobalApi:getLocalStr('MINE_DES102'),allEndTime)

                    --print(des1)
                    --print(des2)
                    --print(des3)

                    local pos = mask:convertToWorldSpace(cc.p(0, 0))
                    TipsMgr:showCommonTips(des1,des2,des3,cc.p(pos.x + 220,pos.y - 75))

                end
            end
        end
    end)

	if (nil ~= leftCon_Con) then
        leftCon_Con:setPositionY(self.conY + 98)
		self.mineAxeCon = ccui.Helper:seekWidgetByName(leftCon_Con, "mine_axe_con");--设置矿镐恢复相关
		if (nil ~= self.mineAxeCon) then
			--AddUIObjectTips(self.mineAxeCon,TipsData:SetString(GlobalApi:getLocalStr("TIPS_AXE")));<TIPS>
			self.mineAxeText       = ccui.Helper:seekWidgetByName(self.mineAxeCon, "mine_axe_text")
			self.mineAxeAddBtn     = ccui.Helper:seekWidgetByName(self.mineAxeCon, "axe_add_btn")
			self.mineAxeLoadingBar = ccui.Helper:seekWidgetByName(self.mineAxeCon, "axe_loading_bar")
		end


        self.bossCue = ccui.Helper:seekWidgetByName(leftCon_Con, "boss_cue")
        self.bossSV = ccui.Helper:seekWidgetByName(leftCon_Con, "boss_sv"); --雕像显示容器
        self.bossSV:setScrollBarEnabled(false)
        
        local function scrollViewEvent(sender, evenType)
            --print('ddddddddddddddddddddddddddddd')
            if self.scrollState == false then
                return
            end

            if not self.nowInnerPos then
                return
            end

            local innnerContainer = self.bossSV:getInnerContainer()
            local innerPosX = innnerContainer:getPositionX()

            print('aaaaaaaaaa' .. innerPosX)

            local x1 = math.abs(innerPosX)
            local x2 = math.abs(self.nowInnerPos)  -- 这里从-180到0变化

            if math.abs(x1 - x2) > 50 then
                
                if self.nowInnerPos == -180 then
                    self.scrollState = false
                    self:SetBossSV(false)
                    GlobalApi:timeOut(function()
                        self.nowInnerPos = -180
                        self.scrollState = true
                    end,0.35)
                    
                    

                elseif self.nowInnerPos == 0 then
                    self.scrollState = false
                    self:SetBossSV(true)
                    GlobalApi:timeOut(function()
                        self.nowInnerPos = 0
                        self.scrollState = true
                    end,0.35)

                end
            end



        end

        self.bossSV:addEventListenerScrollView(scrollViewEvent)






        self.bossLeftButton  = ccui.Helper:seekWidgetByName(leftCon_Con, "left_button"); --雕像显示容器
        self.bossRightButton = ccui.Helper:seekWidgetByName(leftCon_Con, "right_button");
        self.NormalStatueIcon = ccui.Helper:seekWidgetByName(self.bossSV, "normal_statue_icon");
        self.BossStatueIcon   = ccui.Helper:seekWidgetByName(self.bossSV, "boss_statue_icon");

        self.bossLeftButton:addTouchEventListener(function (sender, eventType)
		    if (eventType == ccui.TouchEventType.ended) then
			    self:SetBossSV(true);
		    end
	    end)

        self.bossRightButton:addTouchEventListener(function (sender, eventType)
		    if (eventType == ccui.TouchEventType.ended) then
			    self:SetBossSV(false);
		    end
	    end)

        local callBack = function (sender, eventType)
		 if (eventType == ccui.TouchEventType.ended) then
			    self:LookAtStatuePos(true);
		    end
	    end
	    self.NormalStatueIcon:addTouchEventListener(callBack);

        local callBack = function (sender, eventType)
		 if (eventType == ccui.TouchEventType.ended) then
			    self:LookAtStatuePos(false);
		    end
	    end
	    self.BossStatueIcon:addTouchEventListener(callBack);
		
		
		self.norCon = ccui.Helper:seekWidgetByName(leftCon_Con, "normal_statue_con"); --雕像显示容器
        self.norCon:getChildByName('level_tx'):setString(GlobalApi:getLocalStr('MINE_DES1'))
        self.norCon:getChildByName('number_tx'):setString(GlobalApi:getLocalStr('MINE_DES2'))
		if (nil ~= self.norCon) then
			--AddUIObjectTips(self.norCon,TipsData:SetString(GlobalApi:getLocalStr("TIPS_STATUE_NORMAL")));;<TIPS>
			self.norIcon = ccui.Helper:seekWidgetByName(self.norCon, "icon")
			self.norLev = ccui.Helper:seekWidgetByName(self.norCon, "level")
			self.norNum = ccui.Helper:seekWidgetByName(self.norCon, "number")
		end
		
		self.bossCon = ccui.Helper:seekWidgetByName(leftCon_Con, "boss_statue_con"); --雕像显示容器
        self.bossCon:getChildByName('time_tx'):setString(GlobalApi:getLocalStr('MINE_DES3'))
		if (self.bossCon ~= nil) then
			--AddUIObjectTips(self.bossCon,TipsData:SetString(GlobalApi:getLocalStr("TIPS_STATUE_BOSS")));;<TIPS>
			self.bossTime = ccui.Helper:seekWidgetByName(self.bossCon, "number")
		end

      
		

		self.pageUpBtn = ccui.Helper:seekWidgetByName(leftCon_Con, "page_up_btn")
        self.pageUpBtn:getChildByName('btn_text'):setString(GlobalApi:getLocalStr('MINE_DES4'))
		self.pageDownBtn = ccui.Helper:seekWidgetByName(leftCon_Con, "page_down_btn")
        self.lockNext = ccui.Helper:seekWidgetByName(leftCon_Con, "lock_next")
        self.pageDownBtn:getChildByName('btn_text'):setString(GlobalApi:getLocalStr('MINE_DES5'))
		self.locationBtn = ccui.Helper:seekWidgetByName(leftCon_Con, "location_btn")
		self.curArea = ccui.Helper:seekWidgetByName(leftCon_Con, "cur_layer")
		self.areaLoadingBar = ccui.Helper:seekWidgetByName(leftCon_Con, "layer_loading_bar")
		self.areaLBText = ccui.Helper:seekWidgetByName(leftCon_Con, "layer_lb_text")
		self.backBtn = ccui.Helper:seekWidgetByName(leftCon, "back_btn")
        self.backBtn:setPositionY(self.conY - 5)

        self.dropGoods = {}
        for i = 1,2 do
            self.dropGoods[i] = ccui.Helper:seekWidgetByName(leftCon_Con, "drop_good"..i)
            self.dropGoods[i].icon = ccui.Helper:seekWidgetByName( self.dropGoods[i],"icon")
            self.dropGoods[i].num = ccui.Helper:seekWidgetByName( self.dropGoods[i], "num")
        end
        
	end
	
	--设置RightCon
	local rightCon = root:getChildByName("right_con");
    self.rightCon = rightCon
	local rightCon_Con = ccui.Helper:seekWidgetByName(rightCon, "con");
	if (nil ~= rightCon_Con) then
         rightCon_Con:setPositionY(self.conY)
        self.hideButton = rightCon_Con:getChildByName("hide_button");
         local callBack = function (sender, eventType)
		 if (eventType == ccui.TouchEventType.ended) then
			    self:ClickHideRightButton();
		    end
	    end
	    self.hideButton:addTouchEventListener(callBack);

		local resetTimeCon = ccui.Helper:seekWidgetByName(rightCon_Con, "reset_time_con");--重置时间
		if (nil ~= resetTimeCon) then
			self.resetTime = ccui.Helper:seekWidgetByName(rightCon_Con, "reset_time")
			self.resetBtn = ccui.Helper:seekWidgetByName(rightCon_Con, "reset_btn")
			self.resetString = ccui.Helper:seekWidgetByName(rightCon_Con, "rest_text")
		end
		
		--设置显示矿物
        local mineNumSV =  ccui.Helper:seekWidgetByName(rightCon_Con, "mine_num_sv");
		for i=1, self.MineCount do
			repeat
				local mineCon = ccui.Helper:seekWidgetByName(mineNumSV, "mine_con" .. i);
				if (nil == mineCon) then
					break;
				end
				
				self.mineCons[i] = {};
				local con = self.mineCons[i];
				
				local icon = mineCon:getChildByName("icon")
				if (nil ~= icon) then
					con.icon = icon;
				end
				
				local num = mineCon:getChildByName("num")
				if (nil ~= num) then
					con.num = num;
				end
			until true
		end
        mineNumSV:setScrollBarEnabled(false)
		
		--查看收取列表,一键收取按钮
		self.lookCollectQueue = ccui.Helper:seekWidgetByName(rightCon_Con, "look_collect_list_btn")
        self.lookCollectQueue:getChildByName('btn_text'):setString(GlobalApi:getLocalStr('MINE_DES6'))
		self.getAllBtn = ccui.Helper:seekWidgetByName(rightCon_Con, "one_key_collect_btn")
        self.getAllBtn:getChildByName('btn_text'):setString(GlobalApi:getLocalStr('MINE_DES7'))
		self.vipTips = ccui.Helper:seekWidgetByName(rightCon_Con, "vip_tips")
        self.OneKeyCollectCon = ccui.Helper:seekWidgetByName(rightCon_Con, "one_key_collect_con")

        local richText = xx.RichText:create()
        self.OneKeyCollectCon:addChild(richText)
        richText:setContentSize(cc.size(170, 28))
        richText:setPosition(cc.p(self.vipTips:getPosition()))
        richText:setAlignment('left')
	    local re1 = xx.RichTextLabel:create("", 20, COLOR_TYPE.PALE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        re1:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
        richText:setAnchorPoint(cc.p(0,1))
        self.vipTipsTx   = richText;
        self.vipTipsElem = re1
		
		--设置工具显示
		for i=1, self.ToolCount do
			repeat
				local toolCon = ccui.Helper:seekWidgetByName(rightCon_Con, "tool_con" .. i);--alignMent:getChildByName("ToolCon" .. i);
				if (nil == toolCon) then
					break;
				end
				
				self.toolCons[i] = {};
				local con = self.toolCons[i];

                local bg = toolCon:getChildByName("bg")
				if (nil ~= bg) then
					con.bg = bg;
				end
				
				local icon = toolCon:getChildByName("icon")
				if (nil ~= icon) then
					con.icon = icon
                    if i == 1 then
                        icon.tag = 1
                    else
                        icon.tag = 2
                    end
				end
				
				local num = toolCon:getChildByName("num")
				if (nil ~= num) then
					con.num = num;
				end
			until true
		end
	end
	
	--设置MineSV	
    local svSize = cc.size(1024-251,self.rootBG:getContentSize().height)
	self.mineSV = root:getChildByName("mine_sv")
	self.mineSV:setScrollBarEnabled(false);
    self.mineSV:setContentSize(svSize)
	self.mineCon = self.mineSV:getChildByName("sv_mine_con")
    self.mineCon:setContentSize(svSize)
end
function MineUI:InitDynamicUI()
	if (nil == self.mineAxeConEffect) then --矿镐计数的特效
		self.mineAxeConEffect = self:CreateEffect("particle/skill83","skill83", true);
		self.mineAxeCon:addChild(self.mineAxeConEffect);
		self.mineAxeConEffect:setPosition(cc.p(self.mineAxeCon:getContentSize().width/2.0, self.mineAxeCon:getContentSize().height/2.0));
		self.mineAxeConEffect:setVisible(false);
	end
	
	if (nil == self.backBtnEffect) then --返回按钮的特效
		self.backBtnEffect = self:CreateEffect("particle/skill56","skill56", true);
		self.backBtn:addChild(self.backBtnEffect,1);
        local contensize = self.backBtn:getContentSize()		
		self.backBtnEffect:setPosition(cc.p(contensize.width/2,contensize.height/2 - 5));

		local array = {}
        table.insert(array,cc.ScaleTo:create(0.6, 1.1, 1.0))
        table.insert(array,cc.ScaleTo:create(0.6, 1.1, 1.1))
		local repeatAction = CCRepeatForever:create(CCSequence:create(array));
		self.backBtnEffect:runAction(repeatAction);
		self.backBtnEffect:setVisible(false);
	end
	
	if (nil == self.drapBombEffect) then --拖拽炸弹的UI
		self.drapBombEffect = ccui.ImageView:create();
        self.drapBombEffect:loadTexture("uires/ui/commmon/bg_white.png")
        self.drapBombEffect:setContentSize(cc.p(80,80))
		self.drapBombEffect:setPosition(cc.p(0, 0));
		self.root:addChild(self.drapBombEffect);
		self.drapBombEffect:setVisible(false);
        self.drapBombEffect:setLocalZOrder(9999)
	end
	
	if (nil == self.bombEffect) then --炸弹放置后在矿区的UI
		self.bombEffect = ccui.Layout:create();
		self.bombEffect:setTouchEnabled(true);
		self.bombEffect:setBackGroundColorType(1);
		self.bombEffect:setBackGroundColorOpacity(80);
        self.bombEffect:setLocalZOrder(10000)
        self.bombEffect:setContentSize(cc.p(80,80))
		
		local sureBtn = ccui.Button:create();
		sureBtn:setName("SureBtn");
		sureBtn:setTouchEnabled(true);
		sureBtn:loadTextureNormal("uires/ui/mine/checkmark_1.png")
		self.bombEffect:addChild(sureBtn);
		self.bombEffect.sureBtn = sureBtn;
		
		local cancelBtn = ccui.Button:create();
		cancelBtn:setName("CancelBtn");
		cancelBtn:setTouchEnabled(true);
		cancelBtn:loadTextureNormal("uires/ui/mine/close_1.png")
		self.bombEffect:addChild(cancelBtn);
		self.bombEffect.cancelBtn = cancelBtn;
		
		self.mineCon:addChild(self.bombEffect);
		self.bombEffect:setLocalZOrder(4);
		self.bombEffect:setVisible(false);
	end
	
	if (nil == self.getMineCloseBtn) then --取消收取矿石的取消按钮
		self.getMineCloseBtn = ccui.Button:create();
		self.getMineCloseBtn:setTouchEnabled(true);
		self.getMineCloseBtn:loadTextureNormal("uires/ui/mine/close_1.png")
		self.mineCon:addChild(self.getMineCloseBtn);
		self.getMineCloseBtn:setLocalZOrder(4);
		self.getMineCloseBtn:setVisible(false);
	end
	
	if (nil == self.digLoadingBar) then --挖掘土壤计时条
		self.digLoadingBar = ccui.LoadingBar:create();
		self.digLoadingBar:setContentSize(cc.size(80, 14))
		self.digLoadingBar:loadTexture("uires/ui/mine/t2.png");
		self.digLoadingBar:setPercent(0);
		self.digLoadingBar:setAnchorPoint(cc.p(0.5, 1.0));
		self.mineCon:addChild(self.digLoadingBar);
		self.digLoadingBar:setLocalZOrder(4);
		self.digLoadingBar:setVisible(false);
	end
	
	if (nil == self.getMineCon) then --收矿计时条
		self.getMineCon = ccui.Layout:create();
		self.getMineCon:setContentSize(cc.size(80, 50));
		
		--label
		local label = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
		label:setPosition(cc.p(40, 40));
		self.getMineCon:addChild(label);
		self.getMineCon.label = label;
		
		--loadingbar
		local loadingBar = ccui.LoadingBar:create();
		loadingBar:setContentSize(cc.size(80, 14));
		loadingBar:loadTexture("uires/ui/mine/t2.png");
		loadingBar:setPercent(100);
		loadingBar:setPosition(cc.p(40, 15));
		loadingBar:setPercent(0);
		self.getMineCon:addChild(loadingBar);
		self.getMineCon.loadingBar = loadingBar;
		
		self.mineCon:addChild(self.getMineCon);
		self.getMineCon:setLocalZOrder(4);
	end
end

function MineUI:Update()
	self:SetMineAxeText();
	self:SetMineAxeAddBtn()
	self:SetMineAxeLoadingBar();
    self:SetBossSV(true)
	----self:SetDropGoods(true);
	self:SetPositionInfo();
	self:SetAreaLoadingBar();
	self:SetBackBtn();
		
	self:SetResetTime();
	self:SetResetBtn();
	self:SetMineCons();
	self:SetGetAllBtn();
	self:SetLookCollectQueueBtn();
	self:SetToolCons();
    
	
	self:SetMineCon();
end
function MineUI:refreshMineCons()
    self:SetMineCons()
end

function MineUI:registerScheduler(call,interval,paused)
    local scheduler = cc.Director:getInstance():getScheduler()
    return scheduler:scheduleScriptFunc(call,interval,paused)
end
function MineUI:unregisterScheduler(entry)
    local scheduler = cc.Director:getInstance():getScheduler()
	 scheduler:unscheduleScriptEntry(entry)
end
--====================================================================
--****************************LeftCon*********************************
--====================================================================
function MineUI:SetMineAxeText()
	if (nil == self.mineAxeText) then
		return;
	end
	
	if (nil == self.mineAxeConEffect) then
		return;
	end
	
	local sum = MineMgr._sumDigCount or 0;
	local remain = MineMgr._remainDigCount or 0;
	local str = string.format(GlobalApi:getLocalStr("MINE_AXE_TEXT"), remain,sum);
	self.mineAxeText:setString(str);
	self.mineAxeConEffect:setVisible((remain>=sum));
end

function MineUI:SetMineAxeLoadingBar()
	if (nil == self.mineAxeLoadingBar) then
		return;
	end

    if(self.mineAxe_Scheduler ~= nil) then
         return;
    end

    local remainTime = (GlobalData:getServerTime() -  MineMgr._mineAxeRecoverTime);
    local sumTime = MineMgr._mineAxeRecoverCD * 60;
    self.remainTime = sumTime - remainTime
	local mineAxe_Scheduler_CallBack = function (delta)
		remainTime = remainTime + delta

        self.remainTime = self.remainTime - delta

		if (remainTime >= sumTime) then
            MineMgr._remainDigCount = MineMgr._remainDigCount + 1
            if( MineMgr._remainDigCount >= MineMgr._sumDigCount) then
                self:unregisterScheduler(self.mineAxe_Scheduler);
			    self.mineAxe_Scheduler = nil;
                MineMgr._mineAxeRecoverTime = GlobalData:getServerTime()
            end
			remainTime = 0

            self.remainTime = GlobalData:getServerTime() -  MineMgr._mineAxeRecoverTime

            self:SetMineAxeText()
		end
		self.mineAxeLoadingBar:setPercent(remainTime/sumTime*100);
	end
	
	local sum = MineMgr._sumDigCount;
	local remain = MineMgr._remainDigCount;
	if (remain < sum) then
		if (nil == self.mineAxe_Scheduler) then
            self.mineAxeLoadingBar:setPercent(remainTime/sumTime*100);
			self.mineAxe_Scheduler = self:registerScheduler(mineAxe_Scheduler_CallBack, 0, false);
		end
	else
		self.mineAxeLoadingBar:setPercent(0);
	end
end

function MineUI:SetMineAxeAddBtn()
	if (nil == self.mineAxeAddBtn) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            -- vip次数限制
            local vip = UserData:getUserObj():getVip()
            local count =  GameData:getConfData("vip")[tostring(vip)].diggingBuy

            if vip == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_DESC_5"), COLOR_TYPE.RED);
                return
            end


            if MineMgr._buy >= count then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("BUY_COUTN_NOT_ENOUGH"), COLOR_TYPE.RED);
                return
            end

			local consumeJewel = MineMgr._diggingToolPerDeal *MineMgr._diggingToolPrice;
			local str1 = string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL"), consumeJewel,MineMgr._diggingToolPerDeal)
            local str2 = string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL2"),vip,count - MineMgr._buy,count)
			local call = function ()
				local ownJewel = UserData:getUserObj():getCash()
                print(ownJewel)
                print(consumeJewel)
				-- if (ownJewel>=consumeJewel) then
    --                 MineMgr:SendBuyToolsMessage()
				-- else
				-- 	promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CASH_NOT_ENOUGH'),1000,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
    --                     RechargeMgr:showRecharge()
    --                 end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
    --                 UserData:getUserObj():cost('cash',conf.towerReset,function()
    --                     self:Reset(true)
    --                 end,true,str)
				-- end
				UserData:getUserObj():cost('cash',consumeJewel,function()
                    MineMgr:SendBuyToolsMessage()
                end)
			end

            local contentWidget = ccui.Widget:create()
            contentWidget:setAnchorPoint(cc.p(0.5,0.5))
            contentWidget:setPosition(cc.p(92, 250))


            --[[local richText = xx.RichText:create()
	        richText:setContentSize(cc.size(424, 40))
	        richText:setAnchorPoint(cc.p(0,1))
	        richText:setPosition(cc.p(0, 10))
	        local re1 = xx.RichTextLabel:create(str1,25, COLOR_TYPE.ORANGE)
	        re1:setFont('font/gamefont.TTF')
	        re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			re1:setShadow(cc.c4b(25,25,25, 255), cc.size(0, -1))
	        richText:addElement(re1)


            local richText2 = xx.RichText:create()
	        richText2:setContentSize(cc.size(424, 40))
	        richText2:setAnchorPoint(cc.p(0,1))
	        richText2:setPosition(cc.p(5, -45))
	        local re2 = xx.RichTextLabel:create(str2,25, COLOR_TYPE.ORANGE)
	        re2:setFont('font/gamefont.TTF')
	        re2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
			re2:setShadow(cc.c4b(25,25,25, 255), cc.size(0, -1))
	        richText2:addElement(re2)
            --]]

            local richText = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
			richText:setAnchorPoint(cc.p(0, 1))
			richText:setPosition(cc.p(0, 10))
			richText:setColor(COLOR_TYPE.ORANGE)
			richText:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
			richText:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
            richText:setString(str1)


            local richText2 = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
			richText2:setAnchorPoint(cc.p(0, 1))
			richText2:setPosition(cc.p(5, -45))
			richText2:setColor(COLOR_TYPE.ORANGE)
			richText2:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
			richText2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
            richText2:setString(str2)


            contentWidget:addChild(richText)
            contentWidget:addChild(richText2)
			promptmgr:showMessageBox(contentWidget,MESSAGE_BOX_TYPE.MB_OK_CANCEL,call);
            contentWidget:setLocalZOrder(10000)
		end
	end
	self.mineAxeAddBtn:addTouchEventListener(callBack);
end

function MineUI:SetDropGoods(bNormal)

    
    local enemyData = MineMgr.config_enemy[MineMgr._statueLev];
    if(enemyData == nil) then
        return;
    end


    local awards = nil
    if(bNormal) then
        awards = DisplayData:getDisplayObjs(enemyData.award)
    else
        awards = DisplayData:getDisplayObjs(enemyData.bossAward)
    end

    if(#awards > 1) then
        self.dropGoods[1]:setVisible(true);
        self.dropGoods[1]:setPositionX(40)
        self.dropGoods[2]:setVisible(true);
    else
        self.dropGoods[1]:setVisible(true);
        self.dropGoods[1]:setPositionX(83)
        self.dropGoods[2]:setVisible(false);
    end

    local showNum = math.min(2,#awards)

    for i = 1,showNum do
        self.dropGoods[i]:loadTexture(awards[i]:getBgImg());
        self.dropGoods[i].icon:loadTexture(awards[i]:getIcon());
        self.dropGoods[i].num:setString(awards[i]:getNum())
        self.dropGoods[i]:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.ended then
				AudioMgr.PlayAudio(11)
				GetWayMgr:showGetwayUI(awards[i],false)
		    end
		end)
    end
    


end

function MineUI:SetBossSV(showNormal)
    local isShowingNoraml = showNormal
    if(isShowingNoraml == nil) then  isShowingNoraml = self.showingNormal end
    if(isShowingNoraml) then
        self.bossSV:scrollToLeft(0.3,true);
        self.bossRightButton:setVisible(true)
        self.bossLeftButton:setVisible(false)
        self:SetDropGoods(true)

        self.bossCon:setVisible(false);
        self.norCon:setPositionX(78)

	    local num = MineMgr._statueCount;
	    self.norNum:setString(tostring(num));

        local level = MineMgr._statueLev;
	    self.norLev:setTextAreaSize(cc.size(0, 0));
	    self.norLev:setString(tostring(level));

        local bossList = MineMgr._areas[MineMgr._curAreaID].bossList
        if(bossList ~= nil and #bossList > 0) then 
            self.bossCue:setVisible(true)
        else
            self.bossCue:setVisible(false)
        end

        GlobalApi:timeOut(function()
            self.nowInnerPos = -180
        end,0.35)

    else
        self.bossSV:scrollToRight(0.3,true);
        self.bossRightButton:setVisible(false)
        self.bossLeftButton:setVisible(true)
        self:SetDropGoods(false)
        self.bossCon:setVisible(true);
        self.norCon:setPositionX(30)

        if(MineMgr._bossRemainTime == 0) then
	        self.norNum:setString(0);
        else
            self.norNum:setString(1)
        end

        local level = MineMgr._bossLev;
	    self.norLev:setString(tostring(level));

        local remainTime = MineMgr._bossRemainTime;
	    local str = (((remainTime<=0) and GlobalApi:getLocalStr("MINE_NO_EXIST")) or GlobalApi:toStringTime(remainTime,"HMS",2));
	    self.bossTime:setString(str);

	    local BossStatue_Scheduler_CallBack = function (delta)
		    local remainTime = MineMgr._bossRemainTime;
		    remainTime = remainTime - delta;
		    if (remainTime <= 0) then
			    remainTime = 0;
			    self:unregisterScheduler(self.bossStatue_Scheduler);
			    self.bossStatue_Scheduler = nil;
                MineMgr._bossRemainTime = 0
		    end
		
		    MineMgr._bossRemainTime = remainTime;
            self.bossTime:setString(GlobalApi:toStringTime(remainTime,"HMS",2));
	    end
	
	    if (remainTime>0) and (nil==self.bossStatue_Scheduler) then
		    self.bossStatue_Scheduler = self:registerScheduler(BossStatue_Scheduler_CallBack, 1, false);
            self.bossCue:setVisible(true)
        else
            self.bossCue:setVisible(false)		
	    end

        GlobalApi:timeOut(function()
            self.nowInnerPos = 0
        end,0.35)

    end



   	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
			self:SetDropGoods(true);
		end
	end


    self.showingNormal = isShowingNoraml
end


function MineUI:SetCurArea(index)
	if (nil == self.curArea) then
		return;
	end
	
	self.curArea:setString(MineMgr._curAreaID);

    if index and index == 1 then -- 表示单次挖
        return
    end

    self:SetAreaLoadingBar()

end

function MineUI:SetAreaLoadingBar()
	if (nil == self.areaLBText) then
		return;
	end
	
	if (nil == self.areaLoadingBar) then
		return;
	end
	
	local curMaxDepthY = MineMgr:getMaxDeepForArea();
	local curAreaID = MineMgr._curAreaID;
	local areaLimitDepth = MineMgr.height
	curMaxDepthY = ((curMaxDepthY>areaLimitDepth) and areaLimitDepth) or curMaxDepthY;
	self.areaLBText:setTextAreaSize(cc.size(0, 0));
	self.areaLBText:setString(string.format("%d/%d", curMaxDepthY, areaLimitDepth));
	self.areaLoadingBar:setPercent(curMaxDepthY/areaLimitDepth*100);
end

function MineUI:SetPositionInfo()
	self:SetCurArea();
	self:SetPageUpBtn();
	self:SetPageDownBtn();
	self:SetPageBtnState();
	self:SetLocationBtn();
end

function MineUI:SetPageUpBtn()
	local ctr = self.pageUpBtn;
	if (nil == ctr) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
			local curPage = MineMgr._curAreaID;
			curPage = curPage - 1;
			if (curPage <= 0) then
				curPage = 1;
				return;
			end
			self:SetPage(curPage);
		end
	end		
	ctr:addTouchEventListener(callBack);
end

function MineUI:SetPageDownBtn()
	local ctr = self.pageDownBtn;
	if (nil == ctr) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            local userLv = UserData:getUserObj():getLv()
            local lvLimit =  MineMgr:getLimitLv()
            if lvLimit > userLv then
                promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('GOLDMINE_DESC_6'),lvLimit), COLOR_TYPE.RED)
                return
            end

			local maxY = MineMgr:getMaxDeepForArea();
			local curPage = MineMgr._curAreaID;
			local areaLimitDepth =  tonumber(GlobalApi:getGlobalValue("diggingNextLevelRequire"))
			if (maxY < areaLimitDepth) then
				return;
			end
			
			local curPage = MineMgr._curAreaID;
			curPage = curPage + 1;
			if (curPage > MineMgr.areaMaxID) then
				curPage = MineMgr.areaMaxID;
				return;
			end
			self:SetPage(curPage);
		end
	end
	ctr:addTouchEventListener(callBack);
end

function MineUI:SetPage(page)
	local bHas = MineMgr:IsHasArea(page);
    
    MineMgr:SendChangeLevelMessage(page)
end

function MineUI:SetPageBtnState()
	if (nil == self.Layer) then
		return;
	end
	
	local curPage = MineMgr._curAreaID;
	self.lockNext:setVisible(false)

	--set page up
	if (nil ~= self.pageUpBtn) then
		if (1~=curPage) then
			self.pageUpBtn:setColor(cc.c3b(255, 255, 255));
            self.pageUpBtn:setTouchEnabled(true)
		else
			self.pageUpBtn:setColor(cc.c3b(123, 158, 129));
            self.pageUpBtn:setTouchEnabled(false)
		end
	end
	--set page down
	if (nil ~= self.pageDownBtn) then
		local maxY = MineMgr:getMaxDeepForArea();
		local areaLimitDepth = tonumber(GlobalApi:getGlobalValue("diggingNextLevelRequire"))
		
		local bGrey = false;
		if (maxY<areaLimitDepth) or (MineMgr.areaMaxID == curPage) then
			bGrey = true;
		end
		
		if (bGrey) then
			self.pageDownBtn:setColor(cc.c3b(123, 158, 129));
			if (self.pageDownBtn.armature ~= nil) then
				self.pageDownBtn.armature:setVisible(false);
			end
            self.pageDownBtn:setTouchEnabled(false)
		else
            if (self.pageDownBtn.armature ~= nil) then
                local size = self.pageDownBtn:getContentSize();
				self.pageDownBtn.armature:setVisible(true);
                self.pageDownBtn.armature:setScaleY(0.85)
                self.pageDownBtn.armature:setScaleX(0.65)
				self.pageDownBtn.armature:setPosition(cc.p(size.width/2.0 - 2, size.height/2.0));
            else
                local size = self.pageDownBtn:getContentSize();
				self.pageDownBtn.armature = self:CreateEffect("particle/skill83","skill83",true,nil,run2)
                self.pageDownBtn.armature:setScaleY(0.85)
                self.pageDownBtn.armature:setScaleX(0.65)
				self.pageDownBtn.armature:setPosition(cc.p(size.width/2.0 - 2, size.height/2.0));
				self.pageDownBtn:addChild(self.pageDownBtn.armature);
			end
            self.pageDownBtn:setTouchEnabled(true)
			self.pageDownBtn:setColor(cc.c3b(255, 255, 255));
		end
	end

    local userLv = UserData:getUserObj():getLv()
    local lvLimit =  MineMgr:getLimitLv()
    if lvLimit > userLv then
        self.pageDownBtn:setVisible(false)
        self.lockNext:setVisible(true)
        self.lockNext:setString(string.format(GlobalApi:getLocalStr('GOLDMINE_DESC_7'),lvLimit))
    end
end

function MineUI:SetLocationBtn()
	local ctr = self.locationBtn;
	if (nil == ctr) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
			self:LookAtLastDigPos()
            self:UpdateCell();
		end
	end
	
	ctr:addTouchEventListener(callBack);
end

function MineUI:SetBackBtn()
	if (nil == self.backBtn) then
		return;
	end
	
	if (nil == self.backBtnEffect) then
		return;
	end
	
	local callBack = function (sender, event)
		if (event == ccui.TouchEventType.ended) then
            -- 计算上一次恢复的时间点
            local sumTime = MineMgr._mineAxeRecoverCD * 60
            --print('{{{{}}}}' .. self.remainTime)
            local time = GlobalData:getServerTime() + self.remainTime - sumTime

            UserData:getUserObj().digging = MineMgr._remainDigCount
            UserData:getUserObj().digging_time = time

			MineMgr:hideMineUI();
		end
	end
	self.backBtn:addTouchEventListener(callBack);
	self.backBtnEffect:setVisible(true);
end

--====================================================================
--****************************RightCon********************************
--====================================================================
function MineUI:ClickHideRightButton()
    print(111)
    if(self.hidingRight) then
        self.hidingRight = false
        self.rightCon:runAction(cc.MoveTo:create(0.3,cc.p(742,self.rightCon:getPositionY())))
        self.hideButton:loadTextureNormal("uires/ui/mine/anniu2.png")
    else
        self.rightCon:runAction(cc.MoveTo:create(0.3,cc.p(1004,self.rightCon:getPositionY())))
        self.hideButton:loadTextureNormal("uires/ui/mine/anniu1.png")
        self.hidingRight = true
    end
end
function MineUI:SetResetTime()
	if (self.resetString == nil) then
		return;
	end
	
	if (self.resetTime == nil) then
		return;
	end
	
	local time = MineMgr._refreshTime - GlobalData:getServerTime();
	self.resetString:setVisible((time<=0));
	self.resetTime:setVisible(not (time<=0));
	self.resetTime:setString(GlobalApi:toStringTime(time,"HMS",2));
	
	local reset_Scheduler_CallBack = function (detal)
		self.resetCount = 0.0;
		time = MineMgr._refreshTime - GlobalData:getServerTime();
		if (time <= 0) then
			self:unregisterScheduler(self.reset_Scehduler);
			self.reset_Scehduler = nil;
		end
		self.resetTime:setString(GlobalApi:toStringTime(time,"HMS",2));
	end
	
	if (time>0) and (nil==self.reset_Scehduler) then
		self.reset_Scehduler = self:registerScheduler(reset_Scheduler_CallBack, 1, false);
	end
end

function MineUI:SetResetBtn()
	local ctr = self.resetBtn;
	if (nil == ctr) then
		return;
	end

	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
			local time = MineMgr._refreshTime - GlobalData:getServerTime();
			if (time<=0) then
				 promptmgr:showMessageBox(GlobalApi:getLocalStr("MINE_RESET_CUE"), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function ()
                    MineMgr:SendResetMessage(true)
                end);
			else
				local consumeJewelTime = math.ceil(time/MineMgr._refreshConsumeJewelTime);
				local consumeJewel = MineMgr._refreshConsumeJewel*consumeJewelTime;
				local str = string.format(GlobalApi:getLocalStr("MINE_RESET_CONSUME_JEWEL"), consumeJewel);
				local call = function ()
					local ownJewel = UserData:getUserObj():getCash()
                    print(ownJewel)
                    print(consumeJewel)
					-- if (ownJewel>=consumeJewel) then
     --                     MineMgr:SendResetMessage(false)
					-- else
					-- 	 --promptmgr:showMessageBox(GlobalApi:getLocalStr("CASH_NOT_ENOUGH"),MESSAGE_BOX_TYPE.MB_OK);

     --                      promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CASH_NOT_ENOUGH'),1000,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
     --                           RechargeMgr:showRecharge();
     --                     end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
					-- end    
					UserData:getUserObj():cost('cash',consumeJewel,function()
	                    MineMgr:SendResetMessage(false)
	                end)       
				end
				promptmgr:showMessageBox(str,MESSAGE_BOX_TYPE.MB_OK_CANCEL, call);
			end
		end
	end
	ctr:addTouchEventListener(callBack);
end

function MineUI:SetMineCons()
	if (nil == self.mineCons) then
		return;
	end
	
	local arrLen = #self.mineCons;
	if (nil == arrLen or 0 == arrLen) then
		return;
	end
	
    local index1 = 1
    local index2 = 1

	local ctr = nil;
	for i=1, arrLen do
		repeat
			ctr = self.mineCons[i];
			if (nil == ctr) then
				break;
			end
			
			if (nil == ctr.icon) then
				break;
			end
			
			if (nil == ctr.num) then
				break;
			end
			
            local ini
            if i % 2 == 0 then
                ini = MineMgr.config_show_mine[index1]
                index1 = index1 + 1
            else
            	ini = MineMgr.config_mine[index2]
                index2 = index2 + 1
            end
            
			if (nil == ini) then
				ctr.icon:setVisible(false);
				ctr.num:setVisible(false);
				break;
			end
			
			ctr.icon:setVisible(true); --设置图标
			ctr.icon:loadTexture(ini.path);
			
			ctr.num:setVisible(true); --设置数量
            local award = DisplayData:getDisplayObj(ini.product[1])
			--local num = award:getOwnNum()
			--ctr.num:setTextAreaSize(cc.size(0, 0));

            local dragonGems = BagData:getAllDragongems()
            local judge = false
            local num = 0
            local lv = 0
            if award:getId() == 300009 then
                judge = true
                lv = 1
            elseif award:getId() == 300010 then
                judge = true
                lv = 2
            elseif award:getId() == 300011 then
                judge = true
                lv = 3
            elseif award:getId() == 300012 then
                judge = true
                lv = 4
            elseif award:getId() == 300013 then
                judge = true
                lv = 5
            end

            if judge == true then
                for k = 1,4 do
                    local item = dragonGems[k]
                    for k,v in pairs(item) do
                        if v.conf and v.conf.level == lv then
                            num = num + 1
                        end
                    end
                end
            else
                num = award:getOwnNum()
            end

            ctr.num:setString(num)

            ctr.icon:setTouchEnabled(true)
            ctr.icon:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.ended then
				    AudioMgr.PlayAudio(11)
				    GetWayMgr:showGetwayUI(award,false)
		        end
		    end)


		until true
	end
end

function MineUI:SetLookCollectQueueBtn() --lookCollectQueue
	if (nil == self.lookCollectQueue) then
		return;
	end
	
	local callBack = function (sender, eventType)
		if (eventType == ccui.TouchEventType.ended) then
            MineMgr:showMineQueueUI();
		end
	end
	self.lookCollectQueue:addTouchEventListener(callBack);
end

function MineUI:SetGetAllBtn()
	local ctr = self.getAllBtn;
	if (nil == ctr) then
		return;
	end
	
	local tips = self.vipTipsTx;
	if (nil == tips) then
		return;
	end

    local diggingCollectAllVIP = tonumber(GlobalApi:getGlobalValue("diggingCollectAllVIP"))
	
	if(UserData:getUserObj():getVip() < diggingCollectAllVIP) then	
		tips:setVisible(true);
		ctr:setVisible(false);
		
		local str = string.format(GlobalApi:getLocalStr("MINE_VIP_TIPS"), diggingCollectAllVIP);
		self.vipTipsElem:setString(str);
        tips:format(true)
	else
		ctr:setVisible(true);
		tips:setVisible(false);
	
		local callBack = function (sender, eventType)
			if (eventType == ccui.TouchEventType.ended) then


                  MessageMgr:sendPost('get_collect_all_time','digging',json.encode(msg),function(jsonObj)
                        if(jsonObj.code ~= 0) then
                            return
                        end


                         local consumeJewel = (math.floor(jsonObj.data.time_cost/MineMgr._diggingCollectAllUnitTime)+ 1) * MineMgr._diggingCollectAllPrice;
                         local consumeJewel = math.abs(consumeJewel)
                         if(jsonObj.data.time_cost == 0) then
                            return 
                         end

                         local str = string.format(GlobalApi:getLocalStr("MINE_COLLECTALL_JEWEL"), consumeJewel);
			             local call = function ()

                             local function callBackCall()
                                local ownJewel = UserData:getUserObj():getCash()
				                if (ownJewel>=consumeJewel) then
                                      MineMgr:SendCollectAllMessage(consumeJewel)
				                else
					                promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CASH_NOT_ENOUGH'),1000,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                                           RechargeMgr:showRecharge();
                                     end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
				                end

                             end

                             local queue = MineMgr._collectQueue;
	                         local len = #queue;
	                         --if (len <= 0) then                              
                                --promptmgr:showMessageBox(GlobalApi:getLocalStr('CONFIRM_COLLECT'),MESSAGE_BOX_TYPE.MB_OK_CANCEL, callBackCall)

	                         --else
                                callBackCall()
	                         --end

			            end
			            promptmgr:showMessageBox(str,MESSAGE_BOX_TYPE.MB_OK_CANCEL, call);

                  end)
			end
		end
		ctr:addTouchEventListener(callBack);
	end
end

function MineUI:SetToolCons()
	if (nil == self.toolCons) then
		return;
	end
	
	local arrLen = #self.toolCons;
	if (nil == arrLen or 0 == arrLen) then
		return;
	end
	
	local ctr = nil;
	for i=1, arrLen do
		repeat
			
			ctr = self.toolCons[i];
			if (nil == ctr) then
				break;
			end
			
			if (nil == ctr.icon) then
				break;
			end
			
			if (nil == ctr.num) then
				break;
			end
			
			local ini = MineMgr.config_bomb[i];
            local award = DisplayData:getDisplayObj({"material",ini.itemId,1})
			local num = award:getOwnNum()
			if (nil == ini) then
                ctr.bg:setVisible(false)
				ctr.icon:setVisible(false);
				ctr.num:setVisible(false);
				break;
			end
			
			local setBombEffect = function (pos, id) --创建炸弹的效果
				if (nil == self.bombEffect) then
					return;
				end
				
				if (self.bombEffect:isVisible()) then
					return;
				end
				
				local radius = ini.range*2+1;
				local size = cc.size(MineMgr.cellWidth*radius, MineMgr.cellHeight*radius);
				local startPos = cc.p(pos.x-size.width/2.0, pos.y-size.height/2.0);
				self.bombEffect:setVisible(true);
				self.bombEffect:setContentSize(size);
				self.bombEffect:setPosition(startPos);
				self.bombEffect:setColor(cc.c3b(ini.R, ini.G, ini.B)); -- 背景颜色，读取表
				self.bombEffect:setBackGroundImage(path);
				self.bombEffect.areaID = MineMgr._curAreaID;
				
				local leftPos = cc.p(pos.x-MineMgr.cellWidth/2.0, pos.y-MineMgr.cellHeight/2.0);
				local sureBtnPos = cc.p(0.0, 0.0);
				local cancelBtnPos = cc.p(0.0, 0.0);
				local midPos = cc.p((size.width-MineMgr.cellWidth)/2.0, (size.height-MineMgr.cellHeight)/2.0);
				if (0==leftPos.x) and (0==leftPos.y) then --左下角
					sureBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y+MineMgr.cellHeight);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth, midPos.y+MineMgr.cellHeight/2.0);
				elseif (0==leftPos.x) and (leftPos.y~=0) and (leftPos.y~=self.svInnerSize.height-MineMgr.cellHeight) then --左边
					sureBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y+MineMgr.cellHeight);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y);
				elseif (0==leftPos.x) and (leftPos.y==self.svInnerSize.height-MineMgr.cellHeight) then --左上角
					sureBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth, midPos.y+MineMgr.cellHeight/2.0);
				elseif (leftPos.x==self.svInnerSize.width-MineMgr.cellWidth) and (leftPos.y==self.svInnerSize.height-MineMgr.cellHeight) then --右上角
					sureBtnPos = cc.p(midPos.x, midPos.y+MineMgr.cellHeight/2.0);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y);
				elseif (leftPos.x==self.svInnerSize.width-MineMgr.cellWidth) and (leftPos.y~=self.svInnerSize.height-MineMgr.cellHeight) and (leftPos.y~=0) then --右边
					sureBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y+MineMgr.cellHeight);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y);
				elseif (leftPos.x==self.svInnerSize.width-MineMgr.cellWidth) and (leftPos.y==0) then --右下角
					sureBtnPos = cc.p(midPos.x, midPos.y+MineMgr.cellHeight/2.0);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth/2.0, midPos.y);
				elseif (leftPos.x~=0) and (leftPos.x~=self.svInnerSize.width-MineMgr.cellWidth) and (leftPos.y==0) then --下边
					sureBtnPos = cc.p(midPos.x, midPos.y+MineMgr.cellHeight);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth, midPos.y+MineMgr.cellHeight);
				else --上边 or 中间
					sureBtnPos = cc.p(midPos.x, midPos.y);
					cancelBtnPos = cc.p(midPos.x+MineMgr.cellWidth, midPos.y);
				end
				
				--sureBtn
				if (nil ~= self.bombEffect.sureBtn) then
					local sureCallBack = function (sender, eventType)
						if (eventType == ccui.TouchEventType.ended) then
							local indexX = (pos.x-MineMgr.cellWidth/2.0)/MineMgr.cellWidth;
							local indexY = (pos.y-MineMgr.cellHeight/2.0)/MineMgr.cellHeight;
							self.bombEffect:setVisible(false);
                            MineMgr:SendBombMessage(indexX, indexY, i)
							self.bombPos = pos;
                            self.bombRange = ini.range
						end
					end
					local sureBtnSize = self.bombEffect.sureBtn:getContentSize();
					self.bombEffect.sureBtn:setPosition(sureBtnPos);				
					self.bombEffect.sureBtn:addTouchEventListener(sureCallBack);
				end
				
				--cancelBtn
				if (nil ~= self.bombEffect.cancelBtn) then
					local cancelCallBack = function (sender, eventType)
						if (eventType == ccui.TouchEventType.ended) then			
							self.bombEffect.areaID = 0;
							self.bombEffect:setVisible(false);
						end
					end
					local cancelBtnSize = self.bombEffect.cancelBtn:getContentSize();
					self.bombEffect.cancelBtn:setPosition(cancelBtnPos);
					self.bombEffect.cancelBtn:addTouchEventListener(cancelCallBack);
				end
				
--				local guideID = GuideInstance.getGuideID();
--				local stepID = GuideInstance.getStepID();
--				if (guideID==8) and (stepID==13) then
--					GuideInstance.continueGuide();
--				end
			end
			
			local callBack = function (sender, eventType) --炸弹工具按钮的回调
				local button = sender
				local itemId = button:getTag();
				if (eventType == ccui.TouchEventType.moved) then
					local num = award:getOwnNum();
					if (num <= 0) then
						return;
					end
					

					local curUseNum = 0;
					self.drapBombEffect:setVisible(true);
					local nodePos = self.root:convertToNodeSpace(button:getTouchMovePosition());
					self.drapBombEffect:loadTexture(award:getIcon());
					self.drapBombEffect:setPosition(nodePos);
				else
					if (eventType == ccui.TouchEventType.began) then
						--local num = award:getOwnNum();
                        local num = tonumber(sender.num:getString())
						if (num <= 0) then
                            local buyDes = GlobalApi:getLocalStr("MINE_BOMB_NOT_ENOUGH")
                            if sender.tag == 1 then -- 炸弹
                                buyDes = GlobalApi:getLocalStr("MINE_BOMB_NOT_ENOUGH")
                                --promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_BOMB_NOT_ENOUGH"), COLOR_TYPE.RED);
                            else -- 雷管
                                buyDes = GlobalApi:getLocalStr("MINE_DETONATOR_NOT_ENOUGH")
                                --promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_DETONATOR_NOT_ENOUGH"), COLOR_TYPE.RED);
                            end


                            local call = function()
                                local level = UserData:getUserObj():getLv()
                                if MainSceneMgr.openLevelTab[13] > level then
                                    promptmgr:showSystenHint(GlobalApi:getLocalStr('BLACK_MACKET_NOT_OPEN'), COLOR_TYPE.RED)
                                else
                                    --MainSceneMgr:showShop(3,{min = 1,max = 3})
                                    GlobalApi:getGotoByModule('shop')
                                    MineMgr:hideMineUI() -- 刷新数据
                                end
			                end
			                promptmgr:showMessageBox(buyDes,MESSAGE_BOX_TYPE.MB_OK_CANCEL,call,GlobalApi:getLocalStr('TAVERN_BUY'));


							return;
						end
					else
						if (nil ~= self.drapBombEffect) then
							self.drapBombEffect:setVisible(false);
						end
						
						local num = award:getOwnNum();
						if (num <= 0) then
							return;
						end
                        
----						if (IsUIVisble("MineCollectList")) then
----							return;
----						end
						
						--获得相对放置坐标
						local nodePos = self.mineCon:convertToNodeSpace(button:getTouchEndPosition());
							
						--检测是否在规定范围内放置炸弹
						local rect = cc.rect(0, 0, MineMgr:getWidth()*MineMgr.cellWidth, MineMgr:getHeight()*MineMgr.cellHeight);
						local bHit = cc.rectContainsPoint(rect,nodePos)
						if (not bHit) then
							return;
						end
							
						--检测是否把炸弹放在已经挖掘过的格子上
						local indexX = math.floor(nodePos.x/MineMgr.cellWidth);
						local indexY = math.floor(nodePos.y/MineMgr.cellHeight);
						local earth, mine = MineMgr:getTypeInCell(cc.p(indexX, indexY));
						if (nil ~= earth) then
                            if sender.tag == 1 then -- 炸弹
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_BOMB_ERROR"), COLOR_TYPE.RED)
                            else -- 雷管
                                promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_DETONATOR_ERROR"), COLOR_TYPE.RED)
                            end
                               
							return;
						end
							
						--放置炸弹ui在矿区
						local pos = cc.p(indexX*MineMgr.cellWidth+MineMgr.cellWidth/2.0,
						indexY*MineMgr.cellHeight+MineMgr.cellHeight/2.0);
						setBombEffect(pos, itemId);

					end
				end
			end
			
			local path = award:getIcon()
			ctr.icon:setVisible(true);
			ctr.icon:loadTexture(award:getIcon());
            ctr.bg:loadTexture(award:getBgImg());
			--ctr.icon:setTag(ini.id);
			ctr.icon:addTouchEventListener(callBack);
			ctr.icon.num = ctr.num
			ctr.num:setString(num);
		until true
	end
end

--====================================================================
--****************************矿区操作********************************
--====================================================================
function MineUI:SetMineCon()
	local ctr = self.mineSV;
	if (nil == ctr) then
		return;
	end

    local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrolling then
            --if((cc.pGetLength(cc.pSub(sender:getTouchBeganPosition(),sender:getTouchMovePosition()))) > 20) then
                local innerContainer = self.mineSV:getInnerContainer()
                local y = self.mineSV:getContentSize().height - innerContainer:getContentSize().height
                if self.mineSV:getInnerContainerPosition().y > 0 then
                    innerContainer:setPositionY(0)
                elseif self.mineSV:getInnerContainerPosition().y < y then
                    innerContainer:setPositionY(y)
                end

                self:UpdateCell();
                self.svMoveFlag = true;
                --print('+++++++++++++++' .. self.mineSV:getInnerContainerPosition().y)
           -- end
        end
    end
    self.mineSV:addEventListener(scrollViewEvent)
	
	--ScrollView回调
	local callBack = function (sender, eventType)
----		if (IsUIVisble("Guide")) then --新手引导中不能移动矿区
----			local guideID = GuideInstance.getGuideID();
----			if (8 == guideID) then
----				self.mineSV:setDirection(0);
----			end
----		else
----			self.mineSV:setDirection(3);
----		end
		if (eventType == ccui.TouchEventType.ended) then --设置连续挖掘标志
            --挖掘，收矿...
			if (self.svMoveFlag) then
--					self:unregisterScheduler(self.svAutoScheduler);
--					self.svAutoScheduler = nil;
                --promptmgr:showSystenHint('problem 1', COLOR_TYPE.RED)
				self.svMoveFlag = false;
				return;
			end
				
			if (eventType == ccui.TouchEventType.ended) then
				local nodePos = self.mineCon:convertToNodeSpace(self.mineSV:getTouchEndPosition());
				nodePos = cc.p(math.floor(nodePos.x/MineMgr.cellWidth)*MineMgr.cellWidth, 
								math.floor(nodePos.y/MineMgr.cellHeight)*MineMgr.cellHeight);
				local hitCell = self:CellHitTest(nodePos, "Earth");
				if (nil == hitCell) then
					hitCell = self:CellHitTest(nodePos, "Mine");
					if (nil == hitCell) then
                        --promptmgr:showSystenHint('problem 4', COLOR_TYPE.RED)
						return;
					end
				end
				self:PreDig(hitCell);
			end
		end
	end
	
	--设置scrollview，设置scrollview内部容器
	local width = MineMgr:getWidth();
	local height = MineMgr:getHeight();
	self.svInnerSize = cc.size(width*MineMgr.cellWidth, height*MineMgr.cellHeight);
	self.mineSV:setTouchEnabled(true);
	self.mineSV:setDirection(3);
	self.mineSV:setInnerContainerSize(self.svInnerSize);
	self.mineSV:setClippingEnabled(true);
	self.mineSV:setClippingType(1);
    self.mineSV:setInertiaScrollEnabled(false);
	self.mineCon:setAnchorPoint(cc.p(0.0, 0));
    self.mineCon:setPosition(cc.p(0,0))
	self.mineCon:setContentSize(self.svInnerSize);
	self.mineCon:setContentSize(self.svInnerSize);
	self.mineSVInner = self.mineSV:getInnerContainer();
	self.mineSV:addTouchEventListener(callBack);
    self.mineSV:setTouchEnabled(true)
	
	--预生成矿块
	if (not self.isPerCreateCell) then
		self.isPerCreateCell = true;
		self.svSize = self.mineSV:getContentSize();
		self.cellWidthNum = math.ceil(self.svSize.width / MineMgr.cellWidth)+2;
		self.cellHeightNum = math.ceil(self.svSize.height / MineMgr.cellHeight)+2;
		self.cellNum = self.cellWidthNum * self.cellHeightNum;
		self.batchNode = CCSpriteBatchNode:create("uires/ui/mine/Mine.pvr.ccz");
		self.mineCon:addChild(self.batchNode);
		for i=1, 3*self.cellNum do
			self:CreateFreeCell();
		end
	end
	
    if(self.lookAtBoss) then
        self:LookAtStatuePos(false)
        self.lookAtBoss = false
    else
        self:LookAtLastDigPos();
    end
	
	--刷新
	self:UpdateCell();
end
--定位
function MineUI:LookAtLastDigPos(args)
	local lastAreaID = MineMgr._mineAxeAreaID;
	local curAreaID = MineMgr._curAreaID;
	local width = MineMgr:getWidth();
	local height = MineMgr:getHeight();

    local x = MineMgr._lastX * MineMgr.cellWidth  + MineMgr.cellWidth/2.0;
    local y = MineMgr._lastY * MineMgr.cellHeight + MineMgr.cellWidth/2.0;

    local numCellInSV_X = self.mineSV:getContentSize().width/MineMgr.cellWidth;
    local numCellInSV_Y = self.mineSV:getContentSize().height/MineMgr.cellWidth;
    local px =  (MineMgr._lastX - numCellInSV_X * 0.5) /(MineMgr.width - numCellInSV_X) * 100
    local py =  (1-(MineMgr._lastY - numCellInSV_Y * 0.5)/(MineMgr.height - numCellInSV_Y))*100
    if(px < 0 ) then px = 0 elseif (px > 100) then px = 100 end
    if(py < 0)  then py = 0 elseif (py > 100) then py = 100 end
	self.mineSV:jumpToPercentBothDirection(cc.p(px,py))
	self.pushLocationBtn = false;
	local locationEffectPos = cc.p(x,y);
    if self.mineCon:getChildByName('skill54_effect') then
        self.mineCon:getChildByName('skill54_effect'):setPosition(locationEffectPos)
    else
        local effect = self:CreateEffect("particle/skill54","skill54",false) 
        effect:setName('skill54_effect')
	    effect:setPosition(locationEffectPos)
	    self.mineCon:addChild(effect)
    end

end
function MineUI:LookAtStatuePos(lookAtNormal)
    local p = nil
    if(lookAtNormal) then
        p = MineMgr:GetNextStatePos()
        if(p == nil) then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_GOLD_DES1"), COLOR_TYPE.RED)
            return
        end
    else
        --[[p = MineMgr:GetBossPos()
        if(p == nil) then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_GOLD_DES2"), COLOR_TYPE.RED)
            return
        end
        --]]
        if(MineMgr._bossAreaID == MineMgr._curAreaID) then
            p = MineMgr:GetBossPos()
            if(p == nil) then
                return
            end
        else
            self.lookAtBoss = true
            MineMgr:SendChangeLevelMessage(MineMgr._bossAreaID)
            return
        end
    end

    local x = p.x * MineMgr.cellWidth  + MineMgr.cellWidth/2.0;
    local y = p.y * MineMgr.cellHeight + MineMgr.cellWidth/2.0;

    local numCellInSV_X = self.mineSV:getContentSize().width/MineMgr.cellWidth;
    local numCellInSV_Y = self.mineSV:getContentSize().height/MineMgr.cellWidth;
    local px =  (p.x - numCellInSV_X * 0.5) /(MineMgr.width - numCellInSV_X) * 100
    local py =  (1-(p.y - numCellInSV_Y * 0.5)/(MineMgr.height - numCellInSV_Y))*100
    if(px < 0 ) then px = 0 elseif (px > 100) then px = 100 end
    if(py < 0)  then py = 0 elseif (py > 100) then py = 100 end
	self.mineSV:jumpToPercentBothDirection(cc.p(px,py))
	self.pushLocationBtn = false;
	local locationEffectPos = cc.p(x,y);
    if self.mineCon:getChildByName('skill54_effect') then
        self.mineCon:getChildByName('skill54_effect'):setPosition(locationEffectPos)
    else
        local effect = self:CreateEffect("particle/skill54","skill54",false) 
        effect:setName('skill54_effect')
	    effect:setPosition(locationEffectPos)
	    self.mineCon:addChild(effect)
    end


    self:UpdateCell();
end

function MineUI:UpdateCell() --argument:是否局部更新
	if (nil == self.Layer) then
		return;
	end
	
	local innW = self.mineSV:getInnerContainerSize().width;
	local innH = self.mineSV:getInnerContainerSize().height;
	local leftBottomPos = cc.p(math.abs(self.mineSVInner:getLeftBoundary()), math.abs(self.mineSVInner:getBottomBoundary()));
	local curStartIndexPos = cc.p(math.floor(leftBottomPos.x/MineMgr.cellWidth), math.floor(leftBottomPos.y/MineMgr.cellHeight));
	local curNumW = math.ceil((leftBottomPos.x+self.svSize.width)/MineMgr.cellWidth)-curStartIndexPos.x;
	local curNumH = math.ceil((leftBottomPos.y+self.svSize.height)/MineMgr.cellHeight)-curStartIndexPos.y;
	local curViewRect = cc.rect(curStartIndexPos.x, curStartIndexPos.y, curStartIndexPos.x+curNumW-1, curStartIndexPos.y+curNumH-1);
	
	local updateAll = function ()
		self:ClearUpCell();
		for i=0, curNumW*curNumH-1 do
			local x = curStartIndexPos.x+i%curNumW;
			local y = curStartIndexPos.y+math.floor(i/curNumW);
			self:UpdateCellByPos(cc.p(x, y));
		end
	end
	
	if (self.viewRect == nil) then
		updateAll();
	else
		--相交区域
		local intersectX = ((curViewRect.x>self.viewRect.x) and curViewRect.x) or self.viewRect.x;
		local intersectY = ((curViewRect.y>self.viewRect.y) and curViewRect.y) or self.viewRect.y;
		local intersectEndX = ((curViewRect.width<self.viewRect.width) and curViewRect.width) or self.viewRect.width;
		local intersectEndY = ((curViewRect.height<self.viewRect.height) and curViewRect.height) or self.viewRect.height;
		
		if (intersectX>=intersectEndX) or (intersectY>=intersectEndY) then --无相交区域
			updateAll();
		else
			local intersect = cc.rect(intersectX, intersectY, intersectEndX-intersectX, intersectEndY-intersectY); --相交区域
			for k, v in pairs(self.cellTable) do
				repeat
					if (v == nil) then
						break;
					end
					
					local testPos = cc.p(v.x, v.y);
					local bHit = cc.rectContainsPoint(intersect,testPos)
					if (not bHit) then
						self:RecoverCell(testPos);
					end
				until true
			end
			
			for i=0, curNumW*curNumH-1 do
				local x = curStartIndexPos.x+i%curNumW;
				local y = curStartIndexPos.y+math.floor(i/curNumW);
				local testPos = cc.p(x, y);
				local bHit = cc.rectContainsPoint(intersect,testPos)
				if (not bHit) then
					self:UpdateCellByPos(testPos);
				end
			end
		end
	end
	
	self.svStartIndexPos.x = curStartIndexPos.x;
	self.svStartIndexPos.y = curStartIndexPos.y;
	self.viewRect = curViewRect;
	
	self.batchNode:reorderBatch(true);
	--self:SetBossFollowFlag();
end

function MineUI:UpdateCellByPos(indexPos)
	local posX = indexPos.x*MineMgr.cellWidth+MineMgr.cellWidth/2.0;
	local posY = indexPos.y*MineMgr.cellHeight+MineMgr.cellHeight/2.0;
	local cellPos = cc.p(posX, posY);
	local earth, mine, unmask = MineMgr:getTypeInCell(indexPos);
	
	--设置阴影
	local key = tostring(indexPos.x) .. "@" .. tostring(indexPos.y) .. "@Mask";
	local value = self.cellTable[key];
	if (nil == value) then --上帧不存在阴影Cell
		if (unmask == nil) then
			local cell = self:GetFreeCell();
            if cell:getChildByName('num') then
                cell:removeChildByName('num')
            end
			self.cellTable[key] = {};
			self.cellTable[key].x = indexPos.x;
			self.cellTable[key].y = indexPos.y;
			self.cellTable[key].cell = cell;
			local maskSprite = self.cellTable[key].cell;
			
			--local maskFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName();
			maskSprite:setSpriteFrame("uires/ui/mine/hei.png");
			maskSprite:setPosition(cellPos);
			maskSprite:setVisible(true);
			maskSprite:setLocalZOrder(3);
			
			self:RecoverCell(indexPos, "MineParticle");
			return;
		end
	else --上帧存在阴影Cell
		if (unmask ~= nil) then
			self:RecoverCell(indexPos, "Mask");
		else
			return;
		end
	end
	
	--设置矿土
	key = tostring(indexPos.x) .. "@" .. tostring(indexPos.y) .. "@Earth";
	value = self.cellTable[key];
	if (nil == value) then --上帧不存在矿土Cell
		if (earth ~= nil) then
			local earthIni = MineMgr.config_earth[earth];
			if (nil ~= earthIni) then
				local cell = self:GetFreeCell();
                if indexPos.x == 29 and indexPos.y == 78 then
                    cell:setName('earth2978')
                end
                if cell:getChildByName('num') then
                    cell:removeChildByName('num')
                end
				self.cellTable[key] = {};
				self.cellTable[key].x = indexPos.x;
				self.cellTable[key].y = indexPos.y;
				self.cellTable[key].cell = cell;
				local earthSprite = self.cellTable[key].cell;
				
				--local spriteFrame = CCSpriteFrameCache:sharedSpriteFrameCache():spriteFrameByName(earthIni.path);
				earthSprite:setSpriteFrame(earthIni.path);
				earthSprite:setPosition(cellPos);
				earthSprite:setVisible(true);
				earthSprite:setLocalZOrder(1);
			end
		end
	else --上帧存在矿土Cell
		if (earth == nil) then
			self:RecoverCell(indexPos, "Earth");
		end
	end
	
	--设置矿
	key = tostring(indexPos.x) .. "@" .. tostring(indexPos.y) .. "@Mine";
	value = self.cellTable[key];
	if (nil == value) then --上帧不存在矿Cell
		if (mine ~= nil) then
			local mineIni = MineMgr.config_mine[mine];
			if (nil ~= mineIni) then
				local cell = self:GetFreeCell();
                if cell:getChildByName('num') then
                    cell:removeChildByName('num')
                end
				self.cellTable[key] = {};
				self.cellTable[key].x = indexPos.x;
				self.cellTable[key].y = indexPos.y;
				self.cellTable[key].cell = cell;
				local mineSprite = self.cellTable[key].cell;
				
				local path = mineIni.path
                local judge = true
                
                ----MineMgr:getMinePath(mineIni.id);
				if (eResourceAreaResourceType.eResourceAreaResourceType_Statue == mine) then
					local pos = cc.p(MineMgr._bossPosX, MineMgr._bossPosY);
					if (pos.x == indexPos.x) and (pos.y == indexPos.y) then
						path = "uires/ui/mine/boss.png";
                        judge = false
					else
						path = "uires/ui/mine/monster.png";
                        judge = false
					end
				end
				mineSprite:setSpriteFrame(path);
				mineSprite:setPosition(cellPos);
				mineSprite:setVisible(true);
				mineSprite:setLocalZOrder(2);
			

                if judge == true then
                    local award = DisplayData:getDisplayObj(mineIni.product[1])
                    local hasNum = award:getNum()

                    if hasNum > 1 then
                        local num = cc.Sprite:createWithSpriteFrameName("uires/ui/mine/num.png")
                        num:setName('num')
	                    num:setPosition(cc.p(62, 20))
	                    cell:addChild(num)               
                    end
                end



				local lev = MineMgr:getMineLevInCell(indexPos);
				if (lev > 1) and (lev <= 3) then
					local file  = "particle/kuang_" .. tostring(lev-1) .. ".plist";
					local emitter=CCParticleSystemQuad:create(file);
					if (emitter) then
						emitter:setPositionType(kCCPositionTypeGrouped);
						self.particleTable[key] = {};
						self.particleTable[key].x = indexPos.x;
						self.particleTable[key].y = indexPos.y;
						self.particleTable[key].emitter = emitter;
						emitter:setPosition(cellPos);
						emitter:setLocalZOrder(10);
						self.mineCon:addChild(emitter);
					end
				end
			
				local waitCell = MineMgr:getWaitInCell(indexPos);
				if (nil ~= waitCell) then
					local headCell = MineMgr._collectQueue[1];
					if (headCell.x~=waitCell.x) or (headCell.y~=waitCell.y) then
						key = tostring(indexPos.x) .. "@" .. tostring(indexPos.y) .. "@Sleep";
						value = self.cellTable[key];
						if (nil == value) then
							local cell = self:GetFreeCell();
                            if cell:getChildByName('num') then
                                cell:removeChildByName('num')
                            end
							self.cellTable[key] = {};
							self.cellTable[key].x = indexPos.x;
							self.cellTable[key].y = indexPos.y;
							self.cellTable[key].cell = cell;
							local sleepSprite = self.cellTable[key].cell;
							
							sleepSprite:setSpriteFrame("uires/ui/mine/sleepyoursisterssleep.png");
							sleepSprite:setPosition(cc.p(cellPos.x+MineMgr.cellWidth/2.0, cellPos.y+MineMgr.cellHeight/2.0));
							sleepSprite:setVisible(true);
							sleepSprite:setLocalZOrder(4);
						end
					end
				end
			end
		end
	else --上帧存在矿Cell
		if (mine == nil) then
			self:RecoverCell(indexPos, "Mine");
		end
	end
end

function MineUI:ForceUpdateCellByPos(indexPos)
	if (not IsUIVisble("Mine")) then
		return;
	end
	self:RecoverCell(indexPos);
	self:UpdateCellByPos(indexPos);
end

function MineUI:UpdateGrids(tab, op)
	local grids = MineMgr._grid;
	for i=1, #tab do
		repeat
			local key = tab[i];
			if (nil == key) then
				break;
			end
			
			local grid = grids[key];
			if (nil == grid) then
				break;
			end
			
			local indexPos = cc.p(grid.x, grid.y);
			self:UpdateCellByPos(indexPos);
		until true
	end
	self.batchNode:reorderBatch(true);
end

function MineUI:ClearUpCell()
	for k, v in pairs(self.cellTable) do
		repeat
			v.cell:setPosition(cc.p(0.0, 0.0));
			v.cell:setVisible(false);
			v.cell:setColor(cc.c3b(255, 255, 255));
			v.cell:stopAllActions();
			v.cell:setRotation(0.0);
			v.cell:setLocalZOrder(0);
			table.insert(self.freeCellTable, v.cell);
		until true
	end
	self.cellTable = {};
	
	for k, v in pairs(self.particleTable) do
		repeat
			v.emitter:removeFromParent(true);
		until true
	end
	self.particleTable = {};
end

function MineUI:CreateFreeCell()	
	local cell = cc.Sprite:createWithSpriteFrameName("uires/icon/dragon/dragon_fragment_1.png");
	cell:setPosition(cc.p(0.0, 0.0));
	cell:setVisible(false);
	self.batchNode:addChild(cell);
	table.insert(self.freeCellTable, cell);
end

function MineUI:GetFreeCell()
	if (nil == self.freeCellTable) then
		return nil;
	end
	return table.remove(self.freeCellTable);
end

function MineUI:CellHitTest(touchPos, cellType)
	if (nil == self.cellTable) then
        promptmgr:showSystenHint('problem 2' .. cellType, COLOR_TYPE.RED)
		return nil;
	end
	
	cellType = cellType or "Earth";
	local touchPosX = math.floor(touchPos.x/MineMgr.cellWidth);--*MineMgr.cellWidth;
	local touchPosY = math.floor(touchPos.y/MineMgr.cellHeight);--*MineMgr.cellHeight;
	local index = tostring(touchPosX) .. "@" .. tostring(touchPosY) .. "@" .. cellType;
	local hit = self.cellTable[index];
	if (nil == hit) then
        --promptmgr:showSystenHint('problem 3' .. cellType, COLOR_TYPE.RED)
		return nil;
	end
	return hit.cell;
end

function MineUI:RecoverCell(indexPos, cellType)
	local restParticle = function (t)
		local key = tostring(indexPos.x) .. "@" .. tostring(indexPos.y) .. "@" .. t;
		local value = self.particleTable[key];
		if (value ~= nil) then
			value.emitter:removeFromParent(true);
			self.particleTable[key] = nil;
		end
	end
	
	local restCell = function (v)
		local key = tostring(indexPos.x) .. "@" .. tostring(indexPos.y) .. "@" .. v;
		local value = self.cellTable[key];
		if (value ~= nil) then
			value.cell:setPosition(cc.p(0.0, 0.0));
			value.cell:setVisible(false);
			value.cell:setColor(cc.c3b(255, 255, 255));
			value.cell:stopAllActions();
			value.cell:setRotation(0.0);
			value.cell:setLocalZOrder(0);
			table.insert(self.freeCellTable, value.cell);
			self.cellTable[key] = nil;
		end
		
		if (v == "Mine") then
			restParticle(v);
		end
	end
	
	if (cellType == nil) then
		restCell("Mask");
		restCell("Earth");
		restCell("Mine");
		restCell("Sleep");
		restParticle("Mine");
	else
		if ("MineParticle" == cellType) then
			restParticle("Mine");
		else
			restCell(cellType);
		end
	end
end

function MineUI:GetCellByKey(key)
	return self.cellTable[key].cell;
end

function MineUI:SetMineSleepEffect()
	local delTable = {};
	for k, v in pairs(self.cellTable) do
		repeat
		if (nil == string.find(k, "Sleep")) then
			break;
		end
		
		v.cell:setPosition(cc.p(0.0, 0.0));
		v.cell:setVisible(false);
		v.cell:setColor(cc.c3b(255, 255, 255));
		v.cell:stopAllActions();
		v.cell:setRotation(0.0);
		v.cell:setLocalZOrder(0);
		table.insert(self.freeCellTable, v.cell);
		table.insert(delTable, k);
		until true
	end
	
	for i=1, #delTable do
		repeat
			local key = delTable[i];
			local value = self.cellTable[key];
			if (nil == value) then
				break;
			end
			
			self.cellTable[key] = nil;
		until true
	end
	
	local queue = MineMgr._collectQueue;
	for i=1, #queue do
		repeat
		local cell = queue[i];
		if (nil == cell) then
			break;
		end
		
		if (cell.id ~= MineMgr._curAreaID) then
			break;
		end
		
		local posX = cell.x;--*MineMgr.cellWidth;
		local posY = cell.y;--*MineMgr.cellHeight;
		
		if (1 == i) then
			self:RecoverCell(cc.p(posX, posY), "Sleep");
			break;
		end
		
		local key = tostring(posX) .. "@" .. tostring(posY) .. "@Sleep";
		local value = self.cellTable[key];
		if (nil == value) then
			local cell = self:GetFreeCell();
            if cell:getChildByName('num') then
                cell:removeChildByName('num')
            end
			self.cellTable[key] = {};
			self.cellTable[key].x = posX;
			self.cellTable[key].y = posY;
			self.cellTable[key].cell = cell;
			local sleepSprite = self.cellTable[key].cell;
			
			sleepSprite:setSpriteFrame("uires/ui/mine/sleepyoursisterssleep.png");
			sleepSprite:setPosition(cc.p(posX*MineMgr.cellWidth+MineMgr.cellWidth, posY*MineMgr.cellHeight+MineMgr.cellHeight));
			sleepSprite:setVisible(true);
			sleepSprite:setLocalZOrder(4);
		end
		until true
	end
	self.batchNode:reorderBatch(true);
end

--====================================================================
--************************矿区矿块操作****************************
--====================================================================
function MineUI:SetBossFollowFlag()
	local bossTime = MineMgr._bossRemainTime;
	if (bossTime <= 0) then
		if (self.bossFollowFlag ~= nil) then
			self.bossFollowFlag:setVisible(false);
		end
		return;
	end
	
	if (nil == self.bossFollowFlag) then
		self.bossFollowFlag = Layout:create();
		self.bossFollowFlag:setContentSize(cc.size(70, 70));
		self.bossFollowFlag:setBackGroundImage("uires/ui/mine/boss.png", 1);
		
		local xLabel = Label:create();
		xLabel:setName("X");
		xLabel:setAnchorPoint(cc.p(0.0, 0.0));
		xLabel:setPosition(cc.p(0.0, 0.0));
		xLabel:setFontSize(18);
		self.bossFollowFlag:addChild(xLabel);
		
		local yLabel = Label:create();
		yLabel:setName("Y");
		yLabel:setAnchorPoint(cc.p(0.0, 0.0));
		yLabel:setPosition(cc.p(35.0, 0.0));
		yLabel:setFontSize(18);
		self.bossFollowFlag:addChild(yLabel);
		
		self.bossFollowFlag:setLocalZOrder(5);
		self.mineCon:addChild(self.bossFollowFlag);
	end
	
	local bossID = MineMgr._bossAreaID;
	local curID = MineMgr._curAreaID;
	if (bossID ~= curID) then
		self.bossFollowFlag:setVisible(false);
		return;
	end
	
	local startPosX = math.floor(math.abs(self.mineSVInner:getLeftBoundary())/MineMgr.cellWidth);
	local startPosY = math.floor(math.abs(self.mineSVInner:getBottomBoundary())/MineMgr.cellHeight);
	local bossPos = cc.p(MineMgr._bossPosX, MineMgr._bossPosY);

	local xLabel = self.bossFollowFlag:getChildByName("x")
	if (nil ~= xLabel) then
		xLabel:setTextAreaSize(cc.size(0, 0));
		xLabel:setString(startPosX-bossPos.x);
	end
	
	local yLabel = self.bossFollowFlag:getChildByName("y")
	if (nil ~= yLabel) then
		yLabel:setTextAreaSize(cc.size(0, 0));
		yLabel:setString(startPosY-bossPos.y);
	end
	
	local rect = cc.rect(startPosX, 
							startPosY, 
							math.ceil(self.svSize.width / MineMgr.cellWidth), 
							math.ceil(self.svSize.height / MineMgr.cellHeight));
	local startPos = cc.p(math.abs(self.mineSVInner:getLeftBoundary()), math.abs(self.mineSVInner:getBottomBoundary()));	
	local flagSize = self.bossFollowFlag:getContentSize();
	local pos = cc.p(0, 0);
	
	local bossPosX = bossPos.x;
	local bossPosY = bossPos.y;
	local rectX = rect.x;
	local rectY = rect.y;
	local rectW = rect.width;
	local rectH = rect.height;
	
	if (bossPos.x<rect.x) and (bossPos.y<rect.y) then --左下
		pos = startPos;
	elseif (bossPos.x<rect.x) and (bossPos.y>=rect.y) and (bossPos.y<rect.y+rect.height) then --左
		pos = cc.p(startPos.x, startPos.y+self.svSize.height/2.0);
	elseif (bossPos.x<rect.x) and (bossPos.y>=rect.y+rect.height) then --左上
		pos = cc.p(startPos.x, startPos.y+self.svSize.height-flagSize.height);
	elseif (bossPos.x>=rect.x) and (bossPos.x<rect.x+rect.width) and (bossPos.y>=rect.y+rect.height) then --上
		pos = cc.p(startPos.x+self.svSize.width/2.0, startPos.y+self.svSize.height-flagSize.height);
	elseif (bossPos.x>=rect.x+rect.width) and (bossPos.y>=rect.y+rect.height) then --右上
		pos = cc.p(startPos.x+self.svSize.width-flagSize.width, startPos.y+self.svSize.height-flagSize.height);
	elseif (bossPos.x>=rect.x+rect.width) and (bossPos.y<rect.y+rect.height) and (bossPos.y>=rect.y) then --右
		pos = cc.p(startPos.x+self.svSize.width-flagSize.width, startPos.y+self.svSize.height/2.0);
	elseif (bossPos.x>=rect.x+rect.width) and (bossPos.y<rect.y) then --右下
		pos = cc.p(startPos.x+self.svSize.width-flagSize.width, startPos.y);
	elseif (bossPos.x>=rect.x) and (bossPos.x<rect.x+rect.width) and (bossPos.y<rect.y) then --下
		pos = cc.p(startPos.x+self.svSize.width/2.0, startPos.y);
	else
		self.bossFollowFlag:setVisible(false);
		return;
	end
	self.bossFollowFlag:setVisible(true);
	self.bossFollowFlag:setPosition(pos);
end

function MineUI:Convert(pos) --坐标转换为索引
	local indexX = (pos.x-MineMgr.cellWidth/2.0)/MineMgr.cellWidth;
	local indexY = (pos.y-MineMgr.cellHeight/2.0)/MineMgr.cellHeight;
	return cc.p(indexX, indexY);
end

function MineUI:CheckDig(index) --检测是否能挖掘
	local width = MineMgr:getWidth();
	local height = MineMgr:getHeight();
	local x, y = index.x, index.y; --检测的索引值
	local earth, mine = nil, nil; --初始值
	
	--检测上面
	if (y+1 <= height-1) then
		earth, mine = MineMgr:getTypeInCell(cc.p(x, y+1));
		if (earth == nil) then
			return true;
		end
	end
	
	--检测下面
	if (y-1 >= 0) then
		earth, mine = MineMgr:getTypeInCell(cc.p(x, y-1));
		if (earth == nil) then
			return true;
		end
	end
	
	--检测左面
	if (x-1 >= 0) then
		earth, mine = MineMgr:getTypeInCell(cc.p(x-1, y));
		if (earth == nil) then
			return true;
		end
	end
	
	--检测右面
	if (x+1 <= width-1) then
		earth, mine = MineMgr:getTypeInCell(cc.p(x+1, y));
		if (earth == nil) then
			return true;
		end
	end
	return false;
end

--穿件挖矿矿镐消耗跳字
function MineUI:CreateAxeConsumeJump(consume, pos)
    print('aaaaa' ..consume)
    local labelAtlas = cc.LabelAtlas:_create('-' .. consume, "uires/ui/number/number1.png", 16, 22, string.byte('-'))
	labelAtlas:setPosition(pos);
	labelAtlas:setScale(1.2);
	labelAtlas:setAnchorPoint(cc.p(0.5,0.5));
    labelAtlas:setLocalZOrder(999)
	self.mineCon:addChild(labelAtlas);

	local function deleteCallBack()
		self.mineCon:removeChild(labelAtlas,true)
	end	
	local array = {}
    table.insert(array,CCMoveBy:create(0.4,cc.p(0,90)))
    table.insert(array,CCFadeOut:create( 0.7))
    table.insert(array,CCCallFunc:create(deleteCallBack))
	labelAtlas:runAction(CCSequence:create(array));
end


--矿区前置操作
--1.单块挖掘:c2sDig->s2cUpdateGrid->display loadingbar->updateUI
--				   |
--				   ->s2cUpdateMineAxeInfo->updateUI
function MineUI:PreDig(hitCell)

    if(self.dig_Scheduler ~= nil) then
        --promptmgr:showSystenHint('problem 5', COLOR_TYPE.RED)
        return
    end
    local hitPos = cc.p(hitCell:getPositionX(), hitCell:getPositionY());
	local index = self:Convert(hitPos);
	local earth, mine = MineMgr:getTypeInCell(index);
	
	if (earth ~= nil) then --单块挖掘
        self.curDigPos = hitPos;
		self.curDigType = earth;

	    --检测该索引是否能被挖掘
	    local bOp = self:CheckDig(index);
	    if (not bOp) then
		    promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_NO_DIG"), COLOR_TYPE.RED)
		    return;
	    end
	
	    --检测此次挖掘次数是否足够
	    local earth, mine = MineMgr:getTypeInCell(cc.p(index.x, index.y));
	    local consume = MineMgr.config_earth[earth].cost+MineMgr._statueCount;
	    local remain = MineMgr._remainDigCount;
	    if (consume > remain) then


            -- vip次数限制
            local vip = UserData:getUserObj():getVip()
            local count =  GameData:getConfData("vip")[tostring(vip)].diggingBuy

            if vip == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("GOLDMINE_DESC_5"), COLOR_TYPE.RED);
                return
            end

            if MineMgr._buy >= count then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_NOT_ENOUGH_AXE"), COLOR_TYPE.RED)
                return
            end

		    local consumeJewel = MineMgr._diggingToolPerDeal *MineMgr._diggingToolPrice;
		    local str1 = string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL"), consumeJewel,MineMgr._diggingToolPerDeal)
            local str2 = string.format(GlobalApi:getLocalStr("MINE_BUY_TOOL2"),vip,count - MineMgr._buy,count)
		    local call = function ()
			    local ownJewel = UserData:getUserObj():getCash()
                print(ownJewel)
                print(consumeJewel)
			    -- if (ownJewel>=consumeJewel) then
    --                 MineMgr:SendBuyToolsMessage()
			    -- else
			    -- 	promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('CASH_NOT_ENOUGH'),1000,2), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
    --                     RechargeMgr:showRecharge()
    --                 end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
    --                 UserData:getUserObj():cost('cash',conf.towerReset,function()
    --                     self:Reset(true)
    --                 end,true,str)
			    -- end
			    UserData:getUserObj():cost('cash',consumeJewel,function()
                    MineMgr:SendBuyToolsMessage()
                end)
		    end

            local contentWidget = ccui.Widget:create()
            contentWidget:setAnchorPoint(cc.p(0.5,0.5))
            contentWidget:setPosition(cc.p(92, 250))


            local richText = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
			richText:setAnchorPoint(cc.p(0, 1))
			richText:setPosition(cc.p(0, 10))
			richText:setColor(COLOR_TYPE.ORANGE)
			richText:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
			richText:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
            richText:setString(str1)


            local richText2 = cc.Label:createWithTTF('', 'font/gamefont.ttf', 25)
			richText2:setAnchorPoint(cc.p(0, 1))
			richText2:setPosition(cc.p(5, -45))
			richText2:setColor(COLOR_TYPE.ORANGE)
			richText2:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
			richText2:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
            richText2:setString(str2)


            contentWidget:addChild(richText)
            contentWidget:addChild(richText2)        
		    promptmgr:showMessageBox(contentWidget,MESSAGE_BOX_TYPE.MB_OK_CANCEL,call);
            contentWidget:setLocalZOrder(10000)

		    return

	    end
	    MineMgr:SendDigMessage(index.x, index.y,consume);--发送挖掘消息

        self:ShowPreDigginBar();
	else       
		if (mine ~= nil) then --收集(收集矿石,打雕像)
			self:PreCollectMine(index, mine);
		end
	end


end

--3.收矿:c2sCollectMine->s2cUpdateQueue->play loading->c2sUpdateQueue->s2cUpdateGrid
--						   |		check	m._collectQueue		|
--						   <-----------------------------------<-
function MineUI:PreCollectMine(index, mine)
	local bExist = MineMgr:IsInCollectQueue(index);
	if (bExist) then
----		local guideID = GuideInstance.getGuideID();
----		local stepID = GuideInstance.getStepID();
----		if (guideID==8) and (stepID==12) then
----			return;
----		end
		
		local callBack = function (sender, eventType)
			if (eventType == ccui.TouchEventType.ended) then
				MineMgr:SendCancelMessage(index.x, index.y);
				self.getMineCloseBtn:setVisible(false);
				if (nil ~= self.getMine_Scheduler) then
					self:unregisterScheduler(self.getMine_Scheduler);
					self.getMine_Scheduler = nil;
				end
			end
		end
		self.getMineCloseBtn:addTouchEventListener(callBack);
		self.getMineCloseBtn:setVisible(true);
		self.getMineCloseBtn:setPosition(cc.p(index.x*MineMgr.cellWidth+MineMgr.cellWidth, 
												 index.y*MineMgr.cellHeight+MineMgr.cellHeight));
	else
		if (mine == eResourceAreaResourceType.eResourceAreaResourceType_Statue) then --雕像
             self.rootBG:runAction(cc.Sequence:create(cc.DelayTime:create(0),cc.CallFunc:create(function ()
                MineMgr:DoBattle(index.x,index.y)
            end)))
            
		else
			local curNum = #MineMgr._collectQueue;
			local maxNum = MineMgr._maxQueueCount;
			if (curNum >= maxNum) then
				promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_COLLECTLIST_FULL"), COLOR_TYPE.RED);
				return;
			end
			MineMgr:SendCollectMessage(index.x, index.y);
		end
	end
end

--====================================================================
--************************消息后处理****************************
--====================================================================
--同步更新矿镐更新消息(上次挖掘坐标, 当前挖掘次数, 挖掘一次所需要时间)
function MineUI:PostUpdateMineAxeInfo()

	self:SetMineAxeText();
	self:SetMineAxeLoadingBar();
	self:SetAreaLoadingBar();
end

--同步更新雕像信息
function MineUI:PostUpdateStatueInfo()
--	if (not IsUIVisble("Mine")) then
--		return;
--	end

--	self:SetNormalStatueCon();

--	local remainTime = MineMgr._bossRemainTime;
--	if (remainTime > 0) then
----		self:SetBossStatueCon();
----		self:SetBossFollowFlag();
--		self:ForceUpdateCellByPos(cc.p(MineMgr._bossPosX, MineMgr._bossPosY))
--	end
end

--同步更新队列
function MineUI:postUpdateQueueUI()
	
	self:SetMineSleepEffect(); --队列等待特效
	local head = MineMgr._collectQueue[1];
	if (head == nil) then
		if (nil ~= self.getMine_Scheduler) then
			self:unregisterScheduler(self.getMine_Scheduler);
			self.getMine_Scheduler = nil;
		end
		self.getMineCon:setVisible(false);
		self.getMineCloseBtn:setVisible(false);
		
		if (MineMgr.uiClass.mineQueueUI ~= nil) then
			MineMgr.uiClass.mineQueueUI:SetSumTime(0);
		end
		
		if (self.getMineMusicFlag) then
			self.getMineMusicFlag = false;
			AudioMgr.playEffectByIndex(43);
		end
		return;
	end
	
	if (self.getMineMusicFlag) then --加进队列播放音效
		self.getMineMusicFlag = false;
		local mineType = MineMgr:getMineType(head.data);
		if ((mineType>=1) and (mineType<=3)) then
			AudioMgr.playEffectByIndex(9);
		elseif ((mineType>3) and (mineType<=6)) then
			AudioMgr.playEffectByIndex(10);
		end
	end

    if(self.getMine_Scheduler ~= nil) then
        self:unregisterScheduler(self.getMine_Scheduler);
		self.getMine_Scheduler = nil;
    end

	if (nil == self.getMine_Scheduler) then
		local sumStep = 0.0;
		local getMine_Scheduler_CallBack = function (delta)
			sumStep = sumStep + delta;
			
			head.remainTime = head.remainTime - delta;
            if(head.remainTime < 0) then
                head.remainTime = 0
            end
			if (sumStep > 1.0) then
				sumStep = sumStep-1.0;
				self.getMineCon.label:setString(GlobalApi:toStringTime(head.remainTime,"HMS",2));
			end
			self.getMineCon.loadingBar:setPercent(head.remainTime/head.allTime*100);
			if (head.remainTime <= 0) then
				self.getMineMusicFlag = true;
				self.getMineCon:setVisible(false);
				self.getMineCloseBtn:setVisible(false);
				self:unregisterScheduler(self.getMine_Scheduler);
				self.getMine_Scheduler = nil;
                MineMgr:SendDequeueMessage();
				
----				local guideID = GuideInstance.getGuideID();
----				local stepID = GuideInstance.getStepID();
----				if (guideID==8) and (stepID==12) then
----					GuideInstance.continueGuide();
----				end
			end
			
            if (MineMgr.uiClass.mineQueueUI ~= nil) then
			    MineMgr.uiClass.mineQueueUI:SetSumTime(0);
                MineMgr.uiClass.mineQueueUI:SetSVHeadCellTime(head.remainTime);
		    end
		end
		
		--[[local y = head.y*MineMgr.cellHeight+MineMgr.cellHeight;
		if (y >= self.svInnerSize.height) then
			y = y - MineMgr.cellHeight;
		end--]]
		--self.getMineCon:setPosition(cc.p(head.x*MineMgr.cellWidth, y));
		self.getMine_Scheduler = self:registerScheduler(getMine_Scheduler_CallBack, 0, false);
		--self.getMineCon:setVisible(true);
		--self.getMineCon.label:setString(FormatTime(head.remainTime));
		--self.getMineCon.loadingBar:setPercent(head.remainTime/head.allTime*100);
	end
	
	if (head.id ~= MineMgr._curAreaID) then
		self.getMineCon:setVisible(false);
		self.getMineCloseBtn:setVisible(false);
	else
		local y = head.y*MineMgr.cellHeight+MineMgr.cellHeight;
		if (y >= self.svInnerSize.height) then
			y = y - MineMgr.cellHeight;
		end
		self.getMineCon:setPosition(cc.p(head.x*MineMgr.cellWidth, y));
		self.getMineCon:setVisible(true);
		self.getMineCon.label:setString(GlobalApi:toStringTime(head.remainTime,"HMS",2));
		self.getMineCon.loadingBar:setPercent(head.remainTime/head.allTime*100);
	end
end

--同步更新收集列表，操作全部收取,炸弹后触发
function MineUI:UpdateCollectListUI(collectList)
	local op = MineMgr:getOp();
	if (op == eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerUseBomb) then
		local callBack = function ()
			if (#collectList==0) then
				promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_COLLECTLIST_EMPTY"),COLOR_TYPE.RED);
				if (self.bombEffect ~= nil) then
					self.bombEffect.areaID = 0;
				end
			else
				OpenUI("MineCollectList");
			end
		end

	elseif (op == eResourceAreaOpFlag.eResourceAreaOpFlag_GetAllRes) then
		if (#collectList==0) then
			promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_COLLECTLIST_EMPTY"),COLOR_TYPE.RED);
		else
			OpenUI("MineCollectList");
		end
	end
end	

function MineUI:ShowPreDigginBar(args)
    local sumDigTime = MineMgr.config_earth[self.curDigType].time/1000;
	local dig_Schedluer_CallBack = function (delta)
		sumDigTime = sumDigTime - delta;
		
		if (sumDigTime <= 0) then
			self:unregisterScheduler(self.dig_Scheduler);
			self.dig_Scheduler = nil;
			sumDigTime = 0;
			self.digLoadingBar:setVisible(false);
            MineMgr:DelayProcessDigResult();
            self.isDigBarVisible = false;
--			self:UpdateGrids(MineMgr._updateDigGrid);
--			MineMgr:clearUpdateDigGrid();
--			self:SetPageBtnState();
--			self:PostCueNormal();
			----AudioMgr.playEffectByIndex(8); --播放挖土音效
			----SkillManager:CueBackEvent();
				
----				local guideID = GuideInstance.getGuideID();
----				local stepID = GuideInstance.getStepID();
----				if (guideID==8) and (stepID==11) then
----					GuideInstance.continueGuide();
----				end
		end
		--self.digLoadingBar:setPercent(sumDigTime/(MineMgr.config_earth[self.curDigType].time/1000)*100);
	end
--	self.digLoadingBar:setVisible(true);
--	self.digLoadingBar:setPosition(cc.p(self.curDigPos.x, self.curDigPos.y+MineMgr.cellHeight/2.0));
    local armature = GlobalApi:createLittleLossyAniByName("scene_tx_wakuang")
	local actionName = actionName or "run"
	local function AnimationEvent(armatureBack,movementType,movementID)
		if (movementType ~= 0) then									
			armature:removeFromParent(true)
		end
	end
	armature:getAnimation():play(actionName)	
	armature:getAnimation():setMovementEventCallFunc(AnimationEvent)
    armature:getAnimation():play('Animation1', -1, -1)
	armature:setPosition(cc.p(self.curDigPos.x, self.curDigPos.y))
	self.mineCon:addChild(armature);

     --local effect = self:CreateEffect("animation_littlelossy/scene_tx_wakuang/scene_tx_wakuang","scene_tx_wakuang",false);
     --effect:getAnimation():play('Animation1', -1, -1)
	 --effect:setPosition(cc.p(self.curDigPos.x, self.curDigPos.y))
	 --self.mineCon:addChild(effect);


	self.dig_Scheduler = self:registerScheduler(dig_Schedluer_CallBack, 0, false);
    self.isDigBarVisible = true;

end

--同步更新格子UI
function MineUI:postUpdateGridUI(op,isBombAwards)
	
	if  (eResourceAreaOpFlag.eResourceAreaOpFlag_FightWithStatue == op)
		or (eResourceAreaOpFlag.eResourceAreaOpFlag_UpdateGetResQueue == op) 
		or (eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerUseBomb == op)
		or (eResourceAreaOpFlag.eResourceAreaOpFlag_GetAllRes == op) then
		self:UpdateGrids(MineMgr._updateGrid);
		self:PostCueNormal(isBombAwards);
		if (eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerUseBomb == op) then
			self:SetPageBtnState();

           -- for i = -self.bombRange,self.bombRange  do
                 local effect = self:CreateEffect("particle/scene_tx_baozha_01","scene_tx_baozha_01",false);
                 effect:getAnimation():play('Animation1', -1, -1)
		         effect:setPosition(self.bombPos);
                 effect:setScale(self.bombRange * 2 + 1)
		         self.mineCon:addChild(effect);
            --end
            


           
--            effect:getAnimation():play('Animation1', -1, -1)
--            local x = MineMgr._lastX * MineMgr.cellWidth  + MineMgr.cellWidth/2.0;
--            local y = MineMgr._lastY * MineMgr.cellHeight + MineMgr.cellWidth/2.0;
--	        effect:setPosition(ccp(x,y));
--	        self.mineCon:addChild(effect);
		end
	elseif (eResourceAreaOpFlag.eResourceAreaOpFlag_PlayerExplore == op) then
		if (nil == self.curDigPos) then
			return;
		end
		
--		local sumDigTime = MineMgr.config_earth[self.curDigType].time/1000;
--		local dig_Schedluer_CallBack = function (delta)
--			sumDigTime = sumDigTime - delta;

--			if (sumDigTime <= 0) then
--				self:unregisterScheduler(self.dig_Scheduler);
--				self.dig_Scheduler = nil;
--				sumDigTime = 0;
--				self.digLoadingBar:setVisible(false);
--				self:UpdateGrids(MineMgr._updateDigGrid);
--				MineMgr:clearUpdateDigGrid();
--				self:SetPageBtnState();
--				self:PostCueNormal();
--				----AudioMgr.playEffectByIndex(8); --播放挖土音效
--				----SkillManager:CueBackEvent();

------				local guideID = GuideInstance.getGuideID();
------				local stepID = GuideInstance.getStepID();
------				if (guideID==8) and (stepID==11) then
------					GuideInstance.continueGuide();
------				end
--			end
--			self.digLoadingBar:setPercent(sumDigTime/(MineMgr.config_earth[self.curDigType].time/1000)*100);
--		end
        self:UpdateGrids(MineMgr._updateDigGrid);
		MineMgr:clearUpdateDigGrid();
		self:SetPageBtnState();
		self:PostCueNormal(isBombAwards);
		local statueCount = MineMgr._statueCount;
		local consume = MineMgr.config_earth[self.curDigType].cost + statueCount;
		self:CreateAxeConsumeJump(consume, cc.p(self.curDigPos.x, self.curDigPos.y+MineMgr.cellHeight/2.0));
       
	end
end



function MineUI:PostUpdateMineMgr(index)
	self.viewRect = nil;
	self:ClearUpCell();
	self:SetCurArea(index);
	self:SetAreaLoadingBar();
	self:SetMineCon();
	self:SetPageBtnState();
	---self:PostUpdateQueueUI();
	
	local curAreaID = MineMgr._curAreaID;
	if (self.bombEffect ~= nil) then
		self.bombEffect:setVisible((curAreaID==self.bombEffect.areaID));
	end
end




--提示监工出现
function MineUI:PostCueNormal(isBombAwards)
	local flag = MineMgr._statueCueFlag;
    if(MineMgr._bossCueFlag) then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_BOSS_APPEAR"), COLOR_TYPE.RED);
    elseif(MineMgr._statueCueFlag) then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("MINE_NORMAL_APPEAR"), COLOR_TYPE.RED);
    elseif isBombAwards == true then
        promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_BOMB_EVERYTHING"), COLOR_TYPE.RED);
    end

	MineMgr._statueCueFlag = false;
    MineMgr._bossCueFlag = false;
end



function MineUI:PostUpdateBombNum()
	
    if (nil == self.toolCons) then
		return;
	end
	
	local arrLen = #MineMgr.config_bomb;
	if (nil == arrLen or 0 == arrLen) then
		return;
	end
	
	local ctr = nil;
	local ini = nil;
	for i=1, arrLen do
		repeat
		ctr = self.toolCons[i];
    	if (nil == ctr) then
				break;
			end
			
			if (nil == ctr.icon) then
				break;
			end
			
			if (nil == ctr.num) then
				break;
			end
			
			local ini = MineMgr.config_bomb[i];
            local award = DisplayData:getDisplayObj({"material",ini.itemId,1})
			local num = award:getOwnNum()
			if (nil == ini) then
				ctr.icon:setVisible(false);
				ctr.num:setVisible(false);
				break;
			end
			
			ctr.num:setString(num);
		until true
	end
end

function MineUI:Reset()
	if (self.bombEffect ~= nil) then
		self.bombEffect.areaID = 0;
		self.bombEffect:setVisible(false);
	end
	self.viewRect = nil;
	self:ClearUpCell();
	self:Update();
end







--function DelGetMineScheduler()
--	if (self.getMine_Scheduler ~= nil) then
--		self:unregisterScheduler(self.getMine_Scheduler);
--		self.getMine_Scheduler = nil;
--	end
--end

--function MineClearOP(op)
--	if (self.bombEffect ~= nil) then
--		self.bombEffect.areaID = 0;
--	end
--end
return MineUI