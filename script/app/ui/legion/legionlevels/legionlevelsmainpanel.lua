local LegionLevelsMainUI = class("LegionLevelsMainUI", BaseUI)

local MAXLEVELS = 20
local MAXCOPY = 6
function LegionLevelsMainUI:ctor()
	self.uiIndex = GAME_UI.UI_LEGIONLEVELSMAIN
	self.data = LegionMgr:getLegionLevelsData()
	local legioncopyconf = GameData:getConfData("legioncopy")
	if self.data.chapter > #legioncopyconf then
		self.mode = math.floor((#legioncopyconf - 1)/MAXLEVELS)
	else
	    self.mode = math.floor((self.data.chapter - 1)/MAXLEVELS)
	end
	--printall(self.data)
end

function LegionLevelsMainUI:onShow()
    self.data = LegionMgr:getLegionLevelsData()
	local legioncopyconf = GameData:getConfData("legioncopy")
	if self.data.chapter > #legioncopyconf then
		self.mode = math.floor((#legioncopyconf - 1)/MAXLEVELS)
	else
	    self.mode = math.floor((self.data.chapter - 1)/MAXLEVELS)
	end
    self:update()
end
function LegionLevelsMainUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bgimg = self.root:getChildByName("bg_img")
    self.levesnode = bgimg:getChildByName('levels_node')
    local bgimg1 = self.levesnode:getChildByName("bg_img1")
    bgimg:setContentSize(winsize)
    local winsize = cc.Director:getInstance():getVisibleSize()
    self.bgImgSize = bgimg1:getContentSize()
    local limitLW = winsize.width - self.bgImgSize.width
    local limitRW = 0
    local preMovePos = nil
    local movePos = nil
    local bgImgDiffPos = nil
    local bgImgPosX = 0
    local bgImgPosY = -(self.bgImgSize.height-winsize.height)/2
    local beganPos = nil
    bgimg1:setPosition(cc.p(bgImgPosX, bgImgPosY))
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.moved then
            preMovePos = movePos
            movePos = sender:getTouchMovePosition()
            if preMovePos then
                bgImgDiffPos = cc.p(movePos.x - preMovePos.x, movePos.y - preMovePos.y)
                local targetPos = cc.p(bgImgPosX + bgImgDiffPos.x, bgImgPosY)
                if targetPos.x > limitRW then
                    targetPos.x = limitRW
                end
                if targetPos.x < limitLW then
                    targetPos.x = limitLW
                end
                bgImgPosX = targetPos.x
                bgimg1:setPosition(targetPos)
            end
        elseif eventType == ccui.TouchEventType.began then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
            beganPos = sender:getTouchBeganPosition()
            self.touchMine = false
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
        elseif eventType == ccui.TouchEventType.canceled then
            preMovePos = nil
            movePos = nil
            bgImgDiffPos = nil
        end
    end)

    local closebtn = bgimg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionLevelsMainUI()
        end
    end)
    closebtn:setPosition(cc.p(winsize.width,winsize.height - 20))

    local winSize = cc.Director:getInstance():getWinSize()
    local btn = HelpMgr:getBtn(HELP_SHOW_TYPE.LEGION_LEVEL_BATTLE)
    btn:setPosition(cc.p(40,winSize.height - 60))
    bgimg:addChild(btn)

    self.maptab = {}
    self.cloudtab = {}
    for i=1,MAXLEVELS do
        local arr = {}
        local pl = bgimg1:getChildByName('pl_'..i)
        arr.btn = pl:getChildByName('city_btn')
        arr.btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                LegionMgr:showLegionLevelsUI(i + self.mode*MAXLEVELS)
            end
        end)
        arr.pl = pl
        arr.btn:setTouchEnabled(false)
        arr.namebg = pl:getChildByName('name_bg')
        arr.namebg:setVisible(false)
        arr.nametx = arr.namebg:getChildByName('name_tx')
        arr.barbg = pl:getChildByName('bar_bg')
        arr.barbg:setVisible(false)
        arr.bar = arr.barbg:getChildByName('bar')

        arr.bar:setScale9Enabled(true)
        arr.bar:setCapInsets(cc.rect(10,15,1,1))

        arr.modeTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
        arr.modeTx:enableOutline(COLOR_TYPE.BLACK, 1)
        arr.modeTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        arr.modeTx:setAnchorPoint(cc.p(0.5,0.5))
        arr.modeTx:setName('mode_tx')
        arr.namebg:addChild(arr.modeTx)

        arr.bartx = arr.bar:getChildByName('bar_tx')
        arr.sucimg = pl:getChildByName('suc_img')
        arr.sucimg:setVisible(false)
        self.maptab[i] = arr
        self.cloudtab[i] = bgimg1:getChildByName('cloud_'..i..'_img')
    end
    local numbg = bgimg:getChildByName("num_bg")
    numbg:setPosition(cc.p(winsize.width/2,45))
    self.numtx = numbg:getChildByName('num_tx')
    local addbtn = numbg:getChildByName('add_btn')
    addbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local vip = UserData:getUserObj():getVip()
            local vipconf = GameData:getConfData("vip")
            local maxbuycount = vipconf[tostring(vip)].legionCopy
            local buyvalue = GameData:getConfData('buy')[self.data.copy_buy+1].legionCopyChallenge
            if self.data.copy_buy < maxbuycount then
                -- promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("LEGION_LEVELS_DESC13"), buyvalue,maxbuycount-self.data.copy_buy), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                --     self:sendMsg()
                -- end)
                local str = string.format(GlobalApi:getLocalStr("LEGION_LEVELS_DESC13"), buyvalue,maxbuycount-self.data.copy_buy)
                UserData:getUserObj():cost('cash',buyvalue,function()
                    self:sendMsg()
                end,true,str)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC14'), COLOR_TYPE.RED)
            end
        end
    end)
    self:update()
end

function LegionLevelsMainUI:update()
    local MODE_COLOR = {COLOR_TYPE.BLUE,COLOR_TYPE.YELLOW}
    local legioncopyconf = GameData:getConfData("legioncopy")
    local legionconf = GameData:getConfData('legion')
    local currId = 1
	if self.data.chapter > #legioncopyconf then
		currId = self.data.chapter
	else
	    currId = (self.data.chapter - 1) % MAXLEVELS + 1
	end
    for i=1,MAXLEVELS do
        self.maptab[i].btn:removeChildByTag(9527)
        self.maptab[i].namebg:setVisible(false)
        self.maptab[i].sucimg:setVisible(true)
        self.maptab[i].sucimg:ignoreContentAdaptWithSize(true)
        self.maptab[i].barbg:setVisible(false)
        if i < currId then
            self.maptab[i].sucimg:loadTexture('uires/ui/text/tx_yijipo.png')
            if self.cloudtab[i] then
                self.cloudtab[i]:setVisible(false)
            end
            self.maptab[i].btn:setBright(true)
            self.maptab[i].btn:setTouchEnabled(false)
            self.maptab[i].barbg:setVisible(false)
        elseif i == currId then
            local tab = string.split(legioncopyconf[i + self.mode*MAXLEVELS].name,'·')
            self.maptab[i].btn:setTouchEnabled(true)
            self.maptab[i].namebg:setVisible(true)
            self.maptab[i].modeTx:setString(tab[1]..'·')
            self.maptab[i].modeTx:setColor(MODE_COLOR[self.mode + 1])
            self.maptab[i].nametx:setString(tab[#tab])
            self.maptab[i].barbg:setVisible(true)
            local size = self.maptab[i].modeTx:getContentSize()
            local size1 = self.maptab[i].nametx:getContentSize()
            local size2 = self.maptab[i].namebg:getContentSize()
            self.maptab[i].modeTx:setPosition(cc.p(size2.width/2 - size1.width/2,size2.height/2))
            self.maptab[i].nametx:setPosition(cc.p(size2.width/2 + size.width/2,size2.height/2))
            
            self.maptab[i].barbg:setVisible(true)
            self.maptab[i].bar:setPercent(LegionMgr:calccopypercent(self.data,self.data.chapter))
            self.maptab[i].sucimg:setVisible(false)
            self.maptab[i].bartx:setString(LegionMgr:calccopypercent(self.data,self.data.chapter).."%")
            self.maptab[i].btn:setBright(true)
            if self.cloudtab[currId] then
                self.cloudtab[currId]:setVisible(false)
            end
            local fightainmintion = GlobalApi:createSpineByName("map_fight", "spine/map_fight/map_fight", 1)
            if fightainmintion then
                fightainmintion:setPosition(cc.p(80,60))
                fightainmintion:setTag(9527)
                fightainmintion:setAnimation(0, 'animation', true)
                self.maptab[i].btn:addChild(fightainmintion)
            end

            local pos = self.maptab[i].pl:getPositionX()
            local winsize = cc.Director:getInstance():getWinSize()
            local limitLW = winsize.width - self.bgImgSize.width
            local limitRW = 0
            if pos > limitRW then
                pos = limitRW
            end
            if pos < limitLW then
                pos = limitLW
            end
            self.levesnode:setPosition(cc.p(pos,self.levesnode:getPositionY()))
        elseif i > currId and i < currId + 4 then  
            self.maptab[i].sucimg:setVisible(false)
            self.cloudtab[i]:setVisible(false) 
            if self.cloudtab[i] then
                self.cloudtab[i]:setVisible(false)
            end
            self.maptab[i].btn:setBright(false)
        elseif i > currId then
            --self.maptab[i].sucimg:loadTexture('uires/ui/guard/guard_lock.png')
            self.maptab[i].sucimg:setVisible(false)
            self.cloudtab[i]:setVisible(true) 
            if self.cloudtab[i] then
                self.cloudtab[i]:setVisible(true)
            end
            self.maptab[i].btn:setBright(false)       
        end
    end
    self.numtx:setString(string.format(GlobalApi:getLocalStr('LEGION_LEVELS_NUMS'),legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy))
    UserData:getUserObj():setLegionCopyCount(self.data.copy_count)
end

function LegionLevelsMainUI:sendMsg()
    MessageMgr:sendPost('buy_count','legion','{}',function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,nil,nil,true)
            end
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            self.data.copy_buy = self.data.copy_buy + 1
            UserData:getUserObj():setLegionCopyBuy(self.data.copy_buy)
            self:update()   
            promptmgr:showSystenHint(GlobalApi:getLocalStr('SUCCESS_BUY'), COLOR_TYPE.GREEN) 
        end
    end)  
end
return LegionLevelsMainUI