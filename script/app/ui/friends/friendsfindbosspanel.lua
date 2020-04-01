--===============================================================
-- 好友搜寻boss界面
--===============================================================
local FriendsFindBossPanelUI = class("FriendsFindBossPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function FriendsFindBossPanelUI:ctor(data)
    self.uiIndex = GAME_UI.UI_FRIENDS_FINDBOSS_PANEL
    self.friendconf = GameData:getConfData('friend')
    self.friendsdata = FriendsMgr:getFriendData()
    self.bossPercent = 100
    self.bossId = 1
	self.bossStartTime = nil
    if data then
        self.bossPercent = data.healths
        self.bossId = data.bossId
		self.bossStartTime = data.boss_start_time
    else
        self.friendsdata.hasfightboss = false
    end
end

function FriendsFindBossPanelUI:onShow()
    self:update()
end

function FriendsFindBossPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local alphabg = bgimg1:getChildByName('bg_img1')
    local bgimg2 = alphabg:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsFindBoss()
        end
    end)
    self:adaptUI(bgimg1, alphabg)
	self.bgimg2 = bgimg2
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_13'))

    local rankbtn = bgimg2:getChildByName('rank_btn')
    local rankbtntx = rankbtn:getChildByName('btntext')
    rankbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_14'))
    rankbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:showFriendsRank()
        end
    end)
    local awardsbtn = bgimg2:getChildByName('awards_btn')
    local awardsbtntx = awardsbtn:getChildByName('btntext')
    awardsbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_15'))
    awardsbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:showFriendsAwards()
        end
    end)
    local helpbtn = bgimg2:getChildByName('help_btn')
    helpbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            HelpMgr:showHelpUI(21)
        end
    end)
    -- helpbtn:runAction(cc.Sequence:create(cc.RotateBy:create(3,720), cc.CallFunc:create(function()
    --     print('xxxx')
    -- end)))
    local friendsbg = bgimg2:getChildByName('friends_bg')
    self.findbigpl = friendsbg:getChildByName('find_big_pl')
    self.findbossbtn = self.findbigpl:getChildByName('find_btn')
    self.findbossbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:findAction(false)
        end
    end)
    self.findbossbtntx = self.findbossbtn:getChildByName('btntext')
    self.findbossbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_29'))
    self.fidnbosscdtx = self.findbigpl:getChildByName('find_time_tx')

    self.bossbigpl = friendsbg:getChildByName('boss_big_pl')
    local fightbtn = self.bossbigpl:getChildByName('fight_btn')
    fightbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:showFriendsBoss(UserData:getUserObj():getUid())
        end
    end)
    local fightbtntx = fightbtn:getChildByName('btntext')
    fightbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_22'))
    local infopl = friendsbg:getChildByName('info_bg')
    self.findpl = infopl:getChildByName('find_pl')
    self.mapbg = self.findpl:getChildByName('map_img')
    self.mapbg:setVisible(false)
    self.light = GlobalApi:createLittleLossyAniByName("ui_sousuo_2")
    self.light:setPosition(cc.p(344,105))
    self.findpl:addChild(self.light)
    --self.magnifierimg = self.mapbg:getChildByName('magnifier_img')

    --
    local searchbtn = friendsbg:getChildByName('search_btn')
    searchbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:findAction(true)
        end
    end)
    searchbtn:getChildByName('btntext'):setString(GlobalApi:getLocalStr('FRIENDS_DESC_30'))
    self.searchbtn = searchbtn
    self.searchbg = friendsbg:getChildByName('bg')
    self.searchbg:getChildByName('cost_desc'):setString(GlobalApi:getLocalStr('FRIENDS_DESC_34'))


    self.bosspl = infopl:getChildByName('boss_pl')
    self.bossimg = self.bosspl:getChildByName('boss_img')
    self.nametx = self.bosspl:getChildByName('name_tx')
    local barbg = self.bosspl:getChildByName('bar_bg')
    self.bar = barbg:getChildByName('bar')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(10,15,1,1))
    self.bartx = barbg:getChildByName('bar_tx')
    local desctx1 = self.bosspl:getChildByName('desc_1')
    desctx1:setString(GlobalApi:getLocalStr('FRIENDS_DESC_18')..':')
    local desctx2 = self.bosspl:getChildByName('desc_2')
    desctx2:setString(GlobalApi:getLocalStr('FRIENDS_DESC_19'))
    self.killbossawardnode = {}
    for i=1,2 do
        self.killbossawardnode[i] = self.bosspl:getChildByName('award_node_'..i)
    end

    local sidebarImg = self.root:getChildByName('sidebar_img')
    local winSize = cc.Director:getInstance():getVisibleSize()
    sidebarImg:setPosition(cc.p(winSize.width - 10,winSize.height - 10))

    local explorationItemId = tonumber(self.friendconf['explorationItemId'].value)
    local obj = BagData:getMaterialById(explorationItemId)
    local num = 0
    if obj and obj:getNum() > 0 then
        num = obj:getNum()
    end
    self.lastNum = num
    local numTx = cc.LabelAtlas:_create(num, "uires/ui/number/font_sz.png", 17, 23, string.byte('.'))
    numTx:setScale(0.9)
    numTx:setAnchorPoint(cc.p(1, 0.5))
    local bgSize = sidebarImg:getContentSize()
    numTx:setPosition(cc.p(bgSize.width - 10,bgSize.height/2))
    self.numTx = numTx
    sidebarImg:addChild(numTx)

    self:timeoutCallback()
    self:update()
end

function FriendsFindBossPanelUI:timeoutCallback()
    local explorationInterval = tonumber(self.friendconf['explorationInterval'].value*3600)
    local difftime = explorationInterval-(GlobalData:getServerTime() - self.friendsdata.explorationtime)
    if difftime <= 0 then
        return
    end

	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
	if self.fidnbosscdtx:getChildByTag(9527) then
        self.fidnbosscdtx:removeChildByTag(9527)
    end
	self.fidnbosscdtx:addChild(node)

    Utils:createCDLabel(node,difftime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.WHITE,
        CDTXTYPE.FRONT,GlobalApi:getLocalStr('FRIENDS_DESC_16'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,24,function()
        self:update()
    end)
end

function FriendsFindBossPanelUI:bossTimeCallback()
	if self.bgimg2:getChildByTag(9529) then
        self.bgimg2:removeChildByTag(9529)
    end
	if not self.bossStartTime then
		return
	end
    local bossDeleteTime = tonumber(self.friendconf['bossDeleteTime'].value*3600)
    local difftime = bossDeleteTime + self.bossStartTime - GlobalData:getServerTime()
    if difftime <= 0 then
        return
    end
	local node = cc.Node:create()
	node:setAnchorPoint(cc.p(0.5,0.5))
	node:setTag(9529)
	node:setLocalZOrder(9999)
	node:setPosition(cc.p(405,132))
	self.bgimg2:addChild(node)

    Utils:createCDLabel(node,difftime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.WHITE,
        CDTXTYPE.FRONT,GlobalApi:getLocalStr('FRIENDS_DESC_50'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,24,function()
		local obj = {
            bossOwnerId = UserData:getUserObj():getUid()
        }
		MessageMgr:sendPost("get_boss", "friend", json.encode(obj), function (jsonObj)
	        print(json.encode(jsonObj))
	        self.bossPercent = nil
			self.bossId = nil
			self.bossStartTime = nil
			self.friendsdata.hasfightboss = false
			self:update()
	    end)
    end)
end

function FriendsFindBossPanelUI:update()
    if self.fidnbosscdtx:getChildByTag(9527) then
        self.fidnbosscdtx:removeChildByTag(9527)
    end

    local lv = UserData:getUserObj():getLv()
    local limitlv = tonumber(self.friendconf['explorationLevel'].value)
    local dt = GlobalData:getServerTime() - self.friendsdata.explorationtime
    local explorationInterval = tonumber(self.friendconf['explorationInterval'].value*3600)
    self.bossbigpl:setVisible(false)
    self.bosspl:setVisible(false)
    self.findbigpl:setVisible(true)
    self.findpl:setVisible(true)
    self.searchbtn:setVisible(false)
    self.searchbg:setVisible(false)
    self.findbossbtn:setVisible(false)
    if lv >= limitlv then
        if self.friendsdata.hasfightboss then
            self.bosspl:setVisible(true)
            self.bossbigpl:setVisible(true)
            self.findbigpl:setVisible(false)
            self.findpl:setVisible(false)
            local bossconf = GameData:getConfData('friendboss')
            print('self.bossId'..self.bossId)
            self.nametx:setString(bossconf[tonumber(self.bossId)].name)
            self.bar:setPercent(self.bossPercent)
            self.bartx:setString(self.bossPercent.."%")
            local formationconf = GameData:getConfData('formation')[bossconf[tonumber(self.bossId)].formation]
            local mosterid = formationconf[tostring('pos'..formationconf.boss)]
            local bigimg = 'uires/icon/big_hero/'..GameData:getConfData('monster')[mosterid].url..'.png'
            self.bossimg:loadTexture(bigimg)
            local disPlayData = DisplayData:getDisplayObjs(GameData:getConfData('drop')[bossconf[tonumber(self.bossId)].killPrize].fixed)
            for i=1,2 do
                local node = self.killbossawardnode[i]
                local awards = disPlayData[i]
                if awards then
                    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, node)
                    cell.lvTx:setString('x'..awards:getNum())
                    local godId = awards:getGodId()
                    awards:setLightEffect(cell.awardBgImg)
                end
            end
        else
            if  dt >= explorationInterval then
                self.findbossbtn:setVisible(true)
                self.findbossbtn:setBright(true)
                self.findbossbtn:setEnabled(true)
                self.findbossbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
            else
                self.findbossbtn:setVisible(true)
                self.findbossbtn:setBright(false)
                self.findbossbtn:setEnabled(false)
                self.findbossbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)

                -- 判断是否有道具
                local explorationItemId = tonumber(self.friendconf['explorationItemId'].value)
                local obj = BagData:getMaterialById(explorationItemId)
                if obj and obj:getNum() > 0 then
                    self.searchbtn:setVisible(true)
                    self.searchbg:setVisible(true)
                    self.findbossbtn:setVisible(false)
                    self.searchbg:getChildByName('cost_num'):setString("1")
                end
				self:timeoutCallback()
            end
        end
    else
        self.findbossbtn:setVisible(true)
        self.findbossbtn:setBright(false)
        self.findbossbtn:setEnabled(false)
        self.findbossbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        self.findbossbtntx:setString(tostring(limitlv)..GlobalApi:getLocalStr('FRIENDS_DESC_32'))       
    end
	self:bossTimeCallback()
end

function FriendsFindBossPanelUI:findAction(judge)
    self.searchbtn:setTouchEnabled(false)
    local args = {
        isUseItem = judge or false
    }
    self.light:getAnimation():playWithIndex(0, -1, 0)
    local fn1 = cc.CallFunc:create(function ()
       MessageMgr:sendPost("exploration", "friend",  json.encode(args), function (jsonObj)
            print(json.encode(jsonObj))
            if jsonObj.code == 0 then
                local awards = jsonObj.data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    local function callBack()
                        self:runNum()
                    end
                    GlobalApi:showAwardsCommon(awards,nil,callBack,true) 
                end
                local costs = jsonObj.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                self.friendsdata.explorationtime = GlobalData:getServerTime() - 1

                if jsonObj.data.bossId and jsonObj.data.bossId > 0 then
                    self.friendsdata.hasfightboss = true
					self.bossPercent = 100
					self.bossStartTime = GlobalData:getServerTime()
                    self.bossId = jsonObj.data.bossId
                    self:update()
                end
                self:timeoutCallback()

                UserData:getUserObj():getFriendsysInfo().explorationtime = self.friendsdata.explorationtime
                UserData:getUserObj():getFriendsysInfo().hasfightboss = self.friendsdata.hasfightboss
                UserData:getUserObj():addGlobalTime()
            end
            self.searchbtn:setTouchEnabled(true)
        end)
    end)
    self.findpl:runAction(cc.Sequence:create(cc.DelayTime:create(2.3),fn1))
end

function FriendsFindBossPanelUI:runNum()
    local explorationItemId = tonumber(self.friendconf['explorationItemId'].value)
    local obj = BagData:getMaterialById(explorationItemId)
    local nowNum = 0
    if obj and obj:getNum() > 0 then
        nowNum = obj:getNum()
    end

	if self.lastNum and self.lastNum ~= nowNum then
        self.runLock = true
        self.numTx:setString(self.lastNum)
        self.numTx:stopAllActions()
        self.numTx:setScale(1.1)
        self.numTx:runAction(cc.DynamicNumberTo:create('LabelAtlas', 1, nowNum, function()
            self.runLock = false
            self.numTx:runAction(cc.Sequence:create(cc.DelayTime:create(0.5),cc.CallFunc:create(function()
                if self.runLock == true then
                    return
                end
                self.numTx:runAction(cc.ScaleTo:create(0.3,1))
                self.numTx:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function()
                	self.numTx:setString(nowNum)
                    self.lastNum = nowNum
                    end)))
            end)))
        end))
	else
		self.numTx:setString(nowNum)
        self.lastNum = nowNum
	end
end
return FriendsFindBossPanelUI