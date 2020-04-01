--===============================================================
-- 好友boss界面
--===============================================================
local FriendsBossPanelUI = class("FriendsBossPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function FriendsBossPanelUI:ctor(data,bossownerid)
    self.uiIndex = GAME_UI.UI_FRIENDS_BOSS_PANEL
    self.friendconf = GameData:getConfData('friend')
    self.friendsdata = FriendsMgr:getFriendData()
	self.bossStartTime = nil
    if data then
        self.bossPercent = data.healths
        self.bossId = data.bossId
		self.bossStartTime = data.boss_start_time
    end
    self.bossownerid = bossownerid or 0
end

function FriendsBossPanelUI:onShow()
    self:update()
end

function FriendsBossPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local alphabg = bgimg1:getChildByName('bg_img1')
    local bgimg2 = alphabg:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsBoss()
        end
    end)
    self:adaptUI(bgimg1, alphabg)
	self.bgimg2 = bgimg2
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_20'))

    self.timetx = bgimg2:getChildByName('time_tx')
    local combg = bgimg2:getChildByName('com_bg')
    self.attacktx = combg:getChildByName('attack_num')

    local friendsbg = bgimg2:getChildByName('friends_bg')
    local bossbigpl = friendsbg:getChildByName('boss_big_pl')
    local costtx = bossbigpl:getChildByName('cost_tx')
    costtx:setString('')
    
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0.5, 0.5))
    local rt1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_CONSUME')..' ', 28,COLOR_TYPE.WHITE)
    local rt2 = xx.RichTextImage:create("uires/ui/friends/friends_attack.png")
    local rt3 = xx.RichTextLabel:create(self.friendconf['attackCost'].value, 28,COLOR_TYPE.WHITE)
    rt:addElement(rt1)
    rt:addElement(rt2)
    rt:addElement(rt3)

    rt:setAlignment("middle")
    rt:setVerticalAlignment('middle')
    rt:setPosition(cc.p(0, 0))
    rt:setContentSize(cc.size(400, 30))
    costtx:addChild(rt)

    local fightbtn = bossbigpl:getChildByName('fight_btn')
    fightbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.friendsdata.assistfight < tonumber(self.friendconf['attackCost'].value) then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_31'), COLOR_TYPE.RED)
            else
                local args = {
                    bossOwnerId = self.bossownerid
                }
                MessageMgr:sendPost('get_enemy','friend',json.encode(args),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local conf = GameData:getConfData("friendboss")
                        local customObj = {
                            bossownerid = self.bossownerid,
                            id = conf[tonumber(self.bossId)].formation,
                            healths = data.healths,
                            radio = conf[tonumber(self.bossId)].radio
                        }
                        local bossid = self.bossownerid
                        BattleMgr:playBattle(BATTLE_TYPE.FRIENDS_BOSS, customObj, function ()
                            MainSceneMgr:showMainCity(function()
                                FriendsMgr:showFriendsMain()
                            end, nil, GAME_UI.UI_FRIENDS_MAIN_PANEL)
                        end)
                    elseif code == 100 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_13'), COLOR_TYPE.RED)
                        self.friendsdata.hasfightboss = false
                        FriendsMgr:hideFriendsBoss()
					elseif code == 104 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_51'), COLOR_TYPE.RED)
                        self.friendsdata.hasfightboss = false
                        FriendsMgr:hideFriendsBoss()
                    end
                end)
            end
        end
    end)
    local fightbtntx = fightbtn:getChildByName('btntext')
    fightbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_22'))

    local infobg = friendsbg:getChildByName('info_bg')
    local bosspl = infobg:getChildByName('boss_pl')
    self.bossimg = bosspl:getChildByName('boss_img')
    self.nametx = bosspl:getChildByName('name_tx')
    local desctx1 = bosspl:getChildByName('desc_1')
    desctx1:setString(GlobalApi:getLocalStr('FRIENDS_DESC_23')..':')

    local barbg = bosspl:getChildByName('bar_bg')
    self.bar = barbg:getChildByName('bar')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(10,15,1,1))
    self.bartx = barbg:getChildByName('bar_tx')

    self.awardsnode = {}
    for i=1,2 do
        self.awardsnode[i] = bosspl:getChildByName('award_node_'..i)
    end
    local attackInterval = tonumber(self.friendconf['attackInterval'].value*3600)
    local difftime = attackInterval-(GlobalData:getServerTime() - self.friendsdata.assistupdatetime)
    -- if difftime > 0 and self.friendsdata.assistfight < tonumber(self.friendconf['attackMax'].value) then
    --     Utils:createCDLabel(self.timetx,difftime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.WHITE,
    --         CDTXTYPE.FRONT,GlobalApi:getLocalStr('FRIENDS_DESC_21'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,24,function()
    --         self:update()
    --     end)
    -- end
    self:update()
	self:bossTimeCallback()
end

function FriendsBossPanelUI:update()
    -- local percent = 32.4
    -- self.bar:setPercent(percent)
    -- self.bartx:setString(percent .. '%')
    -- self.nametx:setString('猥琐的高翔')
    local bossconf = GameData:getConfData('friendboss')
    self.nametx:setString(bossconf[tonumber(self.bossId)].name)
    self.bar:setPercent(self.bossPercent)
    self.bartx:setString(self.bossPercent.."%")
    self.frienddata = FriendsMgr:getFriendData()
    self.attacktx:setString(self.frienddata.assistfight ..'/'..self.friendconf['attackMax'].value)
    local formationconf = GameData:getConfData('formation')[bossconf[tonumber(self.bossId)].formation]
    local mosterid = formationconf[tostring('pos'..formationconf.boss)]
    local bigimg = 'uires/icon/big_hero/'..GameData:getConfData('monster')[mosterid].url..'.png'
    self.bossimg:loadTexture(bigimg)
    local disPlayData = DisplayData:getDisplayObjs(GameData:getConfData('drop')[bossconf[tonumber(self.bossId)].attackPrize].fixed)
    for i=1,2 do
        local node = self.awardsnode[i]
        local awards = disPlayData[i]
        if awards then
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, node)
            cell.lvTx:setString('x'..awards:getNum())
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
        end
    end
end

function FriendsBossPanelUI:bossTimeCallback()
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
	node:setTag(9529)
	node:setLocalZOrder(9999)
	node:setPosition(cc.p(377,406))
	self.bgimg2:addChild(node)

    Utils:createCDLabel(node,difftime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.WHITE,
        CDTXTYPE.FRONT,GlobalApi:getLocalStr('FRIENDS_DESC_50'),COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,24,function()
		self.bossStartTime = nil
        self:bossTimeCallback()
    end)
end

return FriendsBossPanelUI