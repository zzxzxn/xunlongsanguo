--===============================================================
-- 好友主界面
--===============================================================
local FriendsMainPanelUI = class("FriendsMainPanelUI", BaseUI)
local ScrollViewGeneral = require("script/app/global/scrollviewgeneral")
local ClassItemCell = require('script/app/global/itemcell')

------------------------------- 聊天内容参数控制 -----------------------------------------
-- 右边聊天内容的间距
local CELL_SPACE = 30

-- 右边聊天内容项的基本宽和高
local CELL_WIDTH = 486
local CELL_HEIGHT = 76

-- 里面的项是纯文本的时候的高度
local CELL_TEXT_HEIGHT = 24

-- 右边聊天文本最大限制宽
local MAX_TEXT_WIDTH = 300

-- 右边聊天文本背景图片文字距离左、右、上、下边的间距像素
local LIMIT_TEXT_BG_LR_SPACE = 10       -- 左右
local LIMIT_TEXT_BG_UD_SPACE = 10       -- 上下
local LIMIT_TEXT_BG_ARROW_WIDTH = 5     -- 聊天背景图片箭头的宽度

-- 右边聊天项聊天文本背景图片基本高度,基本宽度(宽度也是最小的宽度)
local TEXT_BG_WIDTH = 62
local TEXT_BG_HEIGHT = 47

-- 语音的高度
local YUYIN_HEIGHT = 45

-- 语音图片的高度，数据有待测试
local YUYIN_IMG_HEIGHT = 40

-- 没文本的时候语音的宽度
local YUYIN_NOT_TEXT_WIDTH = 110
------------------------------- 聊天内容参数控制 -----------------------------------------

--------------------------------- 语音相关参数 -------------------------------------------
-- 最大录制时间
local MAX_RECORD_TIME = 20

-- 剩余倒计时时间
local REMAIN_RECORD_TIME = 10

-- 快速点击时间限制
local SPEED_CLICK_TIME = 0.3
--------------------------------- 语音相关参数 -------------------------------------------

function FriendsMainPanelUI:ctor()
    self.uiIndex = GAME_UI.UI_FRIENDS_MAIN_PANEL

    -- 是否是语音模式，false:文本，true：语音
    self.isVoice = false
    -- 语音触摸是否在范围内
    self.atRange = false
    -- 是否正在播放
    self.isPlaying = false
    -- 最大录音时间内是否发送
    self.isSendRecord = false
    self.isTouch = false
    self.allTime = 0

    -- 当前好友id
    self.curFriendIdIndex = 1
    self.curFriendUid = nil
    self.friendscelltab = {}
    self.friendconf = GameData:getConfData('friend')
end

function FriendsMainPanelUI:onShow()
    if FriendsMgr:getDirty() then
        self:update()
    end
    FriendsMgr:setDirty(false)
    self:updateBossBtnNewImg()
end

function FriendsMainPanelUI:updateBossBtnNewImg()
    self.findBossBtnNewImg:setVisible(UserData:getUserObj().friendExploreStatus)
    local explorationItemId = tonumber(self.friendconf['explorationItemId'].value)
    local obj = BagData:getMaterialById(explorationItemId)
    local num = 0
    if obj and obj:getNum() > 0 then
        num = obj:getNum()
    end
    if num > 0 then
        self.findBossBtnNewImg:setVisible(true)
    end
end

function FriendsMainPanelUI:onHide()
    -- 语音相关处理
    YVSdkMgr:stopPlay()
    YVSdkMgr.YVSdkCallBackList.recordVoiceCallBack = nil
end

function FriendsMainPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsMain()
        end
    end)
    self.bgimg2 = bgimg2
    self:adaptUI(bgimg1, bgimg2)

    --leftpl
    local basebg = bgimg2:getChildByName('left_pl')
    local friendsbg = basebg:getChildByName('friends_bg')
    local headpl = friendsbg:getChildByName('friends_head_pl')
    local combg1 = headpl:getChildByName('com_bg_1')
    self.friendnumtx = combg1:getChildByName('friends_num')
    self.addfriendsbtn = combg1:getChildByName('add_friend')
    self.addfriendsbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:showFriendsInfo()
        end
    end)
    self.newfriendsimg = self.addfriendsbtn:getChildByName('new_img')

    local combg2 = headpl:getChildByName('com_bg_2')
    self.attacknumtx = combg2:getChildByName('attack_num')
    

    self.friendsv = friendsbg:getChildByName('sv')
    self.friendsv:setScrollBarEnabled(false)
    -- rightpl
    local rightbasebg = bgimg2:getChildByName('right_pl')
    self.rightbasebg = rightbasebg

    self.nofriendsimg = rightbasebg:getChildByName('no_friends_img')
    self.nofriendsimg:setVisible(false)
    local nofriendstx = self.nofriendsimg:getChildByName('no_friends_tx')
    nofriendstx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_1'))

    local scrollbg = rightbasebg:getChildByName('scroll_bg')
    self.scrollbg = scrollbg
    self.drangonbg = scrollbg:getChildByName('dragon_icon')

    self.chatsvTemp = scrollbg:getChildByName('sv')
    self.chatsvTemp:setScrollBarEnabled(false)
    self.chatsvTemp:setVisible(false)

    self.chatMyCell = scrollbg:getChildByName('chat_my_cell')
    self.chatMyCell:setVisible(false)
    local headNode = self.chatMyCell:getChildByName('head_node')
    self.rightHeadNodePosX, self.rightHeadNodePosY = headNode:getPosition()
    self.chatOtherCell = scrollbg:getChildByName('chat_other_cell')
    self.chatOtherCell:setVisible(false)
    local headNode2 = self.chatOtherCell:getChildByName('head_node')
    self.leftHeadNodePosX, self.leftHeadNodePosY = headNode2:getPosition()
    self.chatTextCell = scrollbg:getChildByName('chat_text_cell')
    self.chatTextCell:setVisible(false)

    self.chatTx = self.scrollbg:getChildByName('chat_tx')
    self.chatTx:setVisible(false)
    local msg = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
	msg:setAnchorPoint(cc.p(0, 1))
	msg:setPosition(cc.p(262, 216))
	msg:setMaxLineWidth(MAX_TEXT_WIDTH)
	msg:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	msg:setColor(COLOR_TYPE.ORANGE)
	msg:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	msg:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    self.root:addChild(msg)
    self.heightComp = msg
    self.heightComp:setVisible(false)

    self.voicenode = rightbasebg:getChildByName('voice_node')
    self.voicenode:setVisible(false)

    local rightheadpl = rightbasebg:getChildByName('friends_info_bg')
    self.rightheadbg = rightheadpl:getChildByName('friends_info_img')
    self.rightheadnode = self.rightheadbg:getChildByName('head_node')

    local infobtn = self.rightheadbg:getChildByName('info_btn')
    infobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.curFriendUid ~= nil then
                BattleMgr:showCheckInfo(self.curFriendUid,'world','arena')
            end
        end
    end)
    local deletebtn = self.rightheadbg:getChildByName('delete_btn')
    deletebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then          
            promptmgr:showMessageBox(GlobalApi:getLocalStr('FRIENDS_DESC_24'), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                self:sendDeleteMsg()
            end)
        end
    end)
    local fightbtn = self.rightheadbg:getChildByName('fight_btn')
    fightbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.curFriendUid ~= nil then
                local obj = {
                    enemy = self.curFriendUid
                }
                MessageMgr:sendPost('challenge', 'friend', json.encode(obj), function (jsonObj)
                    -- print('****************************************************')
                    -- print(json.encode(jsonObj))
                    -- print('****************************************************')
                    if jsonObj.code == 0 then
                        local customObj = {
                            enemy = jsonObj.data.enemy,
                            rand1 = jsonObj.data.rand1,
                            rand2 = jsonObj.data.rand2,
                            rand_pos = jsonObj.data.rand_pos,
                            rand_attrs = jsonObj.data.rand_attrs,
                        }
                        BattleMgr:playBattle(BATTLE_TYPE.FRIENDS_COMBAT, customObj, function ()
                            MainSceneMgr:showMainCity(function()
                                FriendsMgr:showFriendsMain()
                            end, nil, GAME_UI.UI_FRIENDS_MAIN_PANEL)
                        end)
                    elseif code == 103 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_44'), COLOR_TYPE.RED)
                    end
                end)
            end
        end
    end)

    -- bottompl
    local findbossbtn = bgimg2:getChildByName('findbossbtn')
    findbossbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:showFriendsFindBoss()
        end
    end)
    local btnpl = findbossbtn:getChildByName('pl')
    local findbossbtntx = btnpl:getChildByName('btntext')
    findbossbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_2'))

    self.findBossBtnNewImg = ccui.ImageView:create('uires/ui/common/new_img.png')
    findbossbtn:addChild(self.findBossBtnNewImg)
    self.findBossBtnNewImg:setPosition(cc.p(124,60))
    self.findBossBtnNewImg:setVisible(UserData:getUserObj().friendExploreStatus)

    local giftbtn = bgimg2:getChildByName('havegift')
    giftbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local judge = false
            for k,v in pairs(self.frienddata.friends) do
                if v then
                    judge = true
                    break
                end
            end
            if judge == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_48'), COLOR_TYPE.RED)
                return
            end

            local obj = {
                id = self.curFriendUid
                }
            MessageMgr:sendPost('deal_gift','friend',json.encode(obj),function (response)    
                local code = response.code
                local data = response.data
                if code == 0 then
                    local awards = response.data.awards

                    -- 判断是否可以发礼物
                    local isSendGift = false
                    for k,v in pairs(self.frienddata.friends) do
                        if v and v.hasGiftSend == 0 then
                            isSendGift = true
                            break
                        end
                    end

                    if (awards and #awards > 0) or isSendGift == true then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_45'), COLOR_TYPE.GREEN)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_46'), COLOR_TYPE.GREEN)
                    end
                    local costs = response.data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    for k,v in pairs(self.frienddata.friends) do
                        if v ~= nil then
                            v.hasGiftSend = 1
                            v.hasGiftReceive = 0
                        end
                    end

                    self.frienddata.dailyGiftGetNum = response.data.getNum
                    self:update()
                end 
            end)
        end
    end)
    local btnpl = giftbtn:getChildByName('pl')
    local giftbtntx = btnpl:getChildByName('btntext')
    giftbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_3'))

    self:initVoice()
    self:update()
end

function FriendsMainPanelUI:sendDeleteMsg()
    if self.curFriendUid ~= nil then
        local obj = {
            id = self.curFriendUid
            }
        MessageMgr:sendPost('remove','friend',json.encode(obj),function (response)    
            local code = response.code
            local data = response.data
            if code == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_7'), COLOR_TYPE.RED)
                for k,v in pairs(self.frienddata.friends) do
                    if tonumber(v.uid) == tonumber(self.curFriendUid) then
                        self.frienddata.friends[k] = nil
                        break
                    end
                end
                self:refreshFriendData(self.curFriendUid)
                -- 清除聊天数据缓存
                FriendsMgr:clearUserCacheData(self.curFriendUid)

                self.curFriendIdIndex = 1
                self:update()
            elseif data.status == 8 then
                FriendsMgr:MsgPop(data.status)
                for k,v in pairs(self.frienddata.friends) do
                    if tonumber(v.uid) == tonumber(self.curFriendUid) then
                        self.frienddata.friends[k] = nil
                        break
                    end
                end
                self:refreshFriendData(self.curFriendUid)
                -- 清除聊天数据缓存
                FriendsMgr:clearUserCacheData(self.curFriendUid)

                self.curFriendIdIndex = 1
                self:update()
            end
        end)
    end
end

function FriendsMainPanelUI:update()
    self.frienddata = FriendsMgr:getFriendData()
    self.frienddataArr = {}

    for k,v in pairs(self.frienddata.friends) do
        if v ~= nil then
            local arr = {}
            arr[1] = v.uid
            arr[2] = v
            table.insert( self.frienddataArr, arr )
        end
    end

    if #self.frienddata.applied == 0 then
        self.newfriendsimg:setVisible(false)
    else
        self.newfriendsimg:setVisible(true)
    end

    if #self.frienddataArr > 0 then
        self.nofriendsimg:setVisible(false)
        self.drangonbg:setVisible(true)
        self.rightheadbg:setVisible(true)
        self.voiceMask:setVisible(false)
        self:updateFriendList()
    else
        self.nofriendsimg:setVisible(true)
        self.drangonbg:setVisible(false)
        self.rightheadbg:setVisible(false)
        self.curFriendIdIndex = 1
        self.curFriendUid = nil
        self.voiceMask:setVisible(true)
        self.friendsv:removeAllChildren()
        -- 清除聊天记录
        if self.scrollbg:getChildByName('scrollview_sv') then
            self.scrollbg:removeChildByName('scrollview_sv')
            self.chatsv = nil
        end
        self.scrollViewGeneral = nil
    end

    self.friendnumtx:setString(#self.frienddataArr..'/'..self.friendconf['friendNumLimit'].value)
    self.attacknumtx:setString(self.frienddata.assistfight ..'/'..self.friendconf['attackMax'].value)
    self:updateRight()
end

function FriendsMainPanelUI:updateRight()
    if #self.frienddataArr > 0 then
        self:chooseFriend()
        self:updateRightChatSV()
        self:initHeadNode(self.rightheadnode,self.frienddataArr[self.curFriendIdIndex][2],2)
    end
end

function FriendsMainPanelUI:updateFriendList()
    self.friendsv:removeAllChildren()

    -- 排序，boss>有新消息>在线时间
    local chatCacheFriendSendStatus = FriendsMgr.chatCacheFriendSendStatus
    local num = #self.frienddataArr
    for i = 1,num do
        local status = chatCacheFriendSendStatus[self.frienddataArr[i][1]]
        if status and status == 1 then
            self.frienddataArr[i][2].hasMsg = 1
        else
            local uid = self.frienddataArr[i][1]
            local offlineMessage = self.frienddataArr[i][2].offlineMessage
            local judge = false
            for k,v in pairs(offlineMessage) do
                if v then
                    judge = true
                    break
                end
            end
            if judge == true then
                self.frienddataArr[i][2].hasMsg = 1
                FriendsMgr.chatCacheFriendSendStatus[self.frienddataArr[i][1]] = 1
            else
                self.frienddataArr[i][2].hasMsg = 0
            end
        end
        self.frienddataArr[i][2].offlineMessage = {}

        local hasfightboss = self.frienddataArr[i][2].hasfightboss
        if hasfightboss == true then
            self.frienddataArr[i][2].hasBoss = 1
        else
            self.frienddataArr[i][2].hasBoss = 0
        end
    end
    table.sort(self.frienddataArr,function(a, b)
        if a[2].hasBoss == b[2].hasBoss then
            if a[2].hasMsg == b[2].hasMsg then
                return a[2].last_active > b[2].last_active
            else
                return a[2].hasMsg > b[2].hasMsg 
            end
        else
            return a[2].hasBoss > b[2].hasBoss
        end
	end)

    -- 默认看的第1条
    self:refreshFriendData(self.frienddataArr[1][1])

    self.curFriendUid = self.frienddataArr[self.curFriendIdIndex][1]

    print('================updateFriendListupdateFriendList==============================')

    local size = self.friendsv:getContentSize()
    local innerContainer = self.friendsv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local cellWidth = 408
    local cellHeight = 90

    local height = num * cellHeight + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = cellHeight
    for i = 1,num do
        local node = cc.CSLoader:createNode("csb/friendscell.csb")
        local bgpl = node:getChildByName("bg_pl")
        bgpl:removeFromParent(false)
        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        bgpl:setPosition(cc.p(cellWidth/2 + 1,allHeight - offset + cellHeight/2))
        self.friendsv:addChild(bgpl)
        self.friendscelltab[i] = bgpl
        self:updateFriendListItem(i,bgpl)
    end
    innerContainer:setPositionY(size.height - allHeight)
end

function FriendsMainPanelUI:updateFriendListItem(index,bgimg)
    
    local bgimg1  = bgimg:getChildByName('bg_img')
    local chatState = bgimg1:getChildByName('chat_state')   -- 这个只是有新消息的状态图片
    if self.frienddataArr[index][2].hasMsg and self.frienddataArr[index][2].hasMsg == 1 then
        chatState:setVisible(true)
        chatState:stopAllActions()
        local act1 = cc.DelayTime:create(0.1 * GlobalApi:random(2, 7))
        local act2 = cc.ScaleTo:create(0.2, 0.6)
        local act4 = cc.ScaleTo:create(0.2, 0.4)
        local act6 = cc.ScaleTo:create(0.2, 0.7)
        local act8 = cc.ScaleTo:create(0.2, 0.5)
        chatState:runAction(cc.RepeatForever:create(cc.Sequence:create(act1,act2,act4,act6,act8)))
    else
        chatState:setVisible(false)
    end

    local selectimg = bgimg:getChildByName('select_img')
    bgimg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.curFriendIdIndex ~= index then
                self.curFriendIdIndex = index
                self.curFriendUid = self.frienddataArr[self.curFriendIdIndex][1]
                for j=1,#self.frienddataArr do
                    local selectimg1 = self.friendscelltab[j]:getChildByName('select_img')
                    selectimg1:setVisible(false)
                end
                selectimg:setVisible(true)
                chatState:setVisible(false)
                self:refreshFriendData(self.curFriendUid)
                self:updateRight()
            end
        end
    end)
    if self.curFriendIdIndex == index then
        selectimg:setVisible(true)
    else
        selectimg:setVisible(false)
    end
    local headnode = bgimg1:getChildByName('head_node')
    local bossbtn = bgimg1:getChildByName('boss_btn')
    bossbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:showFriendsBoss(self.frienddataArr[index][1])
        end
    end)
    local lv = UserData:getUserObj():getLv()
    local limitlv = tonumber(self.friendconf['explorationLevel'].value)
    if self.frienddataArr[index][2].hasfightboss and (lv >= limitlv) then
        bossbtn:setVisible(true)
    else
        bossbtn:setVisible(false)
    end

    local giftbtn = bgimg1:getChildByName('gift_btn')
    local giftimg = giftbtn:getChildByName('btn_img')
    giftbtn:setTouchEnabled(true)
    giftimg:stopAllActions()
    giftimg:setAnchorPoint(cc.p(0.5,0))
    giftimg:setPosition(cc.p(25, 0))

    if self.frienddataArr[index][2].hasGiftReceive == 1 then
        if tonumber(self.frienddata.dailyGiftGetNum) >= tonumber(self.friendconf['dailyGiftGetLimit'].value) then
            giftimg:loadTexture('uires/ui/friends/friends_no_gift.png')
            giftbtn:setTouchEnabled(false)
        else
            giftimg:loadTexture('uires/ui/friends/friends_gift.png')
            local act1 = cc.DelayTime:create(0.1 * GlobalApi:random(2, 7))
            local act2 = cc.ScaleTo:create(0.2, 1.1)
            local act4 = cc.ScaleTo:create(0.2, 0.9)
            local act6 = cc.ScaleTo:create(0.2, 1.2)
            local act8 = cc.ScaleTo:create(0.2, 1)
            giftimg:runAction(cc.RepeatForever:create(cc.Sequence:create(act1,act2,act4,act6,act8)))
        end
    else
        if self.frienddataArr[index][2].hasGiftSend == 0 then
            giftimg:loadTexture('uires/ui/friends/friends_re_gift.png')
        else
            giftimg:loadTexture('uires/ui/friends/friends_no_gift.png')
            giftbtn:setTouchEnabled(false)
        end
    end

    giftbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.frienddataArr[index][2].hasGiftReceive == 1 then   
                self:getGiftMsg(index,self.frienddataArr[index][2].uid)
            elseif self.frienddataArr[index][2].hasGiftSend == 0 then
                self:sendGiftMsg(index,self.frienddataArr[index][2].uid,self.frienddataArr[index][2].name)
            end
        end
    end)
    local onlineimg = bgimg1:getChildByName('online_img')
    local onlinetx = onlineimg:getChildByName('online_tx')
    onlinetx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_12'))
    local offlinetx = bgimg1:getChildByName('offline_tx')
    self:initHeadNode(headnode,self.frienddataArr[index][2],1)
    local active_time = self.frienddataArr[index][2].last_active
    
    local legiondat = GameData:getConfData('legion')   

    local lastActiveTime = tonumber(GlobalApi:getGlobalValue('lastActiveTime'))
    if GlobalData:getServerTime() - active_time < lastActiveTime then
        onlinetx:setString(GlobalApi:getLocalStr("JUST_NOW1"))
        offlinetx:setVisible(false)
        onlineimg:setVisible(true)
     else
        offlinetx:setString(GlobalApi:toEasyTime(active_time))
        offlinetx:setVisible(true)
        onlineimg:setVisible(false)
    end

end

function FriendsMainPanelUI:sendGiftMsg(index,uid,name)
    if uid ~= nil then
        local obj = {
            id = uid
            }
        MessageMgr:sendPost('give_gift','friend',json.encode(obj),function (response)    
            local code = response.code
            local data = response.data
            if code == 0 then
                local awards = response.data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                end
                local costs = response.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                for k,v in pairs(self.frienddata.friends) do
                    if tonumber(v.uid) == tonumber(uid)  then
                        v.hasGiftSend = 1
                    end
                end
                if name then
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('FRIENDS_DESC_49'),name), COLOR_TYPE.GREEN)
                end
                self:updateFriendListItem(index,self.friendscelltab[index])
            end 
        end)
    end
end

function FriendsMainPanelUI:getGiftMsg(index,uid)
    if self.frienddata.dailyGiftGetNum >= self.friendconf['dailyGiftGetLimit'].value then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_29'), COLOR_TYPE.RED) 
        return
    end
    if uid ~= nil then
        local obj = {
            id = uid
            }
        MessageMgr:sendPost('get_gift','friend',json.encode(obj),function (response)    
            local code = response.code
            local data = response.data
            if code == 0 then
                local awards = response.data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                end
                local costs = response.data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                for k,v in pairs(self.frienddata.friends) do
                    if tonumber(v.uid) == tonumber(uid)  then
                        v.hasGiftReceive = 0
                    end
                end
                self:updateFriendListItem(index,self.friendscelltab[index])
            elseif code == 103 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_41'), COLOR_TYPE.RED)
            end 
        end)
    end
end
-- 看过的好友清除缓存数据
function FriendsMainPanelUI:refreshFriendData(uid)
    FriendsMgr.chatCacheFriendSendStatus[uid] = nil

    local num = #self.frienddataArr
    for i = 1,num do
        if self.frienddataArr[i][1] == uid then  -- 并且不是boss
            self.frienddataArr[i][2].hasMsg = 0
            break
        end
    end
end

function FriendsMainPanelUI:refresFriendItems(hasMsgIndex)
    local index1 = hasMsgIndex

    local judge = false
    if self.curFriendIdIndex < index1 then
        self.curFriendIdIndex = self.curFriendIdIndex + 1
        judge = true
    end

    local num = #self.frienddataArr
    local hasMsgData =  self.frienddataArr[index1]
    for i = num,1,-1 do
        local data = self.frienddataArr[i]
        if i < index1 then
            -- i 去刷新 i + 1
            self.frienddataArr[i + 1] = data
            self:updateFriendListItem(i + 1,self.friendscelltab[i + 1])
        end
    end
    self.frienddataArr[1] = hasMsgData
    self:updateFriendListItem(1,self.friendscelltab[1])

    if judge then
        self.curFriendUid = self.frienddataArr[self.curFriendIdIndex][1]
    end
end

function FriendsMainPanelUI:initHeadNode(parent,arrdata,inittp)
    parent:removeAllChildren()
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    cell.awardBgImg:loadTexture(COLOR_FRAME[arrdata.quality])
    cell.awardBgImg:setScale(0.76)
    cell.lvTx:setString('Lv.'..arrdata.level)
    local obj = RoleData:getHeadPicObj(tonumber(arrdata.headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.awardImg:ignoreContentAdaptWithSize(true)
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(arrdata.headframe))
    cell.nameTx:setString('')
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(arrdata.name..' ', 28,COLOR_TYPE.WHITE)
    local rt2 = xx.RichTextImage:create("uires/ui/chat/chat_vip_small.png")
    rt2:setScale(1.3)
    local rt3 = xx.RichTextAtlas:create(arrdata.vip,"uires/ui/number/font_ranking.png", 20, 22, '0')
    rt3:setScale(1.3)
    rt:addElement(rt1)
    if tonumber(arrdata.vip) > 0 then
        rt:addElement(rt2)
        rt:addElement(rt3)
    end
    rt:setAlignment("left")
    rt:setVerticalAlignment('middle')
    rt:setPosition(cc.p(0, 0))
    rt:setContentSize(cc.size(400, 30))
    cell.nameTx:addChild(rt)
    cell.nameTx:setPosition(cc.p(100,75))

    if inittp == 1 then
        cell.nameTx:setVisible(true)
    else
        cell.nameTx:setVisible(false)
    end

    parent:addChild(cell.awardBgImg)
end

function FriendsMainPanelUI:initVoice()
    -- inputzone 
    self.inputzone  = self.bgimg2:getChildByName('inputzone')
    self.inputBtn   = self.inputzone:getChildByName('inputBtn')
    self.textClip   = self.inputzone:getChildByName('clip')
    self.inputText  = self.textClip:getChildByName('inputText')
    self:createEditBox(self.textClip)

    local function clickInputBtn(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:SendChatMessage()
        end
    end
    self.inputBtn:addTouchEventListener(clickInputBtn)
    
    -- voicePannel
    self.voiceMask = self.bgimg2:getChildByName('voice_mask')
    self.voiceMask:setVisible(false)

    self.voicePannel = self.bgimg2:getChildByName('voice_pannel')
    self.swithBtn = self.bgimg2:getChildByName('swith_btn')
    self.swithBtn:ignoreContentAdaptWithSize(true)
    local function swithBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self.isVoice = not self.isVoice
            self:switchVoiceState()
        end
    end
    self.swithBtn:addTouchEventListener(swithBtnCallBack)

    self.voiceBtn = self.voicePannel:getChildByName('voice_btn')

    local minX = self.voiceBtn:getPositionX()
    local maxX = minX + self.voiceBtn:getContentSize().width
    local minY = self.voiceBtn:getPositionY()
    local maxY = minY + self.voiceBtn:getContentSize().height

    local function stopRecordLogic(maxRecordState)
        self.isSendRecord = true
        if self.voiceRemainNode:getChildByTag(9527) then
            self.voiceRemainNode:removeChildByTag(9527)
        end

        self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
        self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
        self.voiceNode:setVisible(false)
        YVSdkMgr:stopRecord()

        YVSdkMgr:setRecordFinishCallBack(function(time)
            local time = time or 0
            time = math.floor((time/1000) + 0.5) -- 四舍五入
            if time >= MAX_RECORD_TIME then
                time = MAX_RECORD_TIME
            end

            if time == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                self.voiceMask:setVisible(false)
                return
            elseif self.atRange or maxRecordState then    -- 在范围内或者达到最大录音时间：发送到我们服务器,url,识别文本用content,语音时间,是否未读前端判断
                -- 语音识别并且上传
                YVSdkMgr:speechVoice()
                YVSdkMgr:setSpeechCallBack(function(data)
                    local url = data.url
                    local resultText = data.resultText  -- 文本如果识别为空，看发不
                    print('send to server =============' .. '\n time:' .. time .. '\n url:' .. url .. '\n resultText:' .. resultText)                  
                    self.voiceMask:setVisible(false)

                    -- 语音文字屏蔽
                    local maxLen = 64
                    local str = resultText
                    local unicode = GlobalApi:utf8_to_unicode(str)
                    local len = string.len(unicode)
                    unicode = string.sub(unicode,1,maxLen*6)
                    local utf8 = GlobalApi:unicode_to_utf8(unicode)
                    str = utf8
                    local isOk,str1 = GlobalApi:checkSensitiveWords(str)
                    if not isOk then
                        FriendsMgr:SendChatMsg(self.curFriendUid,str1 or '',url,time)
                    else
                        FriendsMgr:SendChatMsg(self.curFriendUid,resultText,url,time)
                    end
                    FriendsMgr:resetCdTime()
                end)
            else
                self.voiceMask:setVisible(false)
            end

        end)
    end
    self.stopRecordLogic = stopRecordLogic

    local function voiceBtnCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.began then
            if FriendsMgr:judgeSpeakIsOutTime() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_1'), COLOR_TYPE.RED)
                return
            end
            if YVSdkMgr.loginResult == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES7'), COLOR_TYPE.RED)
                return
            end
            self.isTouch = true
            self.allTime = 0
        elseif eventType == ccui.TouchEventType.ended then
            if FriendsMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++ended')
            self.isTouch = false
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
            if self.allTime < SPEED_CLICK_TIME then   
                if YVSdkMgr.loginResult == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                end             
            elseif self.isSendRecord == false then
                --print('max record time 20 s ==================')
                stopRecordLogic()
            end

        elseif eventType == ccui.TouchEventType.canceled then
            if FriendsMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++canceled')
            self.isTouch = false
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu1.png')
            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
            if self.allTime < SPEED_CLICK_TIME then       
                if YVSdkMgr.loginResult == true then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES5'), COLOR_TYPE.RED)
                end
            elseif self.isSendRecord == false then
                --print('max record time 20 s ==================')
                stopRecordLogic()
            end

        elseif eventType ==  ccui.TouchEventType.moved then
            if FriendsMgr:judgeSpeakIsOutTime() then
                return
            end
            --print('==============+++++++++++moved')
            self.voiceBtn:loadTextureNormal('uires/ui/chat/chat_anniu2.png')
            local pos = sender:getTouchMovePosition()
			local convertPos = self.voicePannel:convertToNodeSpace(pos)
            
            if convertPos.x > minX and convertPos.x < maxX and convertPos.y > minY and convertPos.y < maxY then
                self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES2'))
                self.atRange = true
                self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES3'))
                self.voiceNodeText:setTextColor(COLOR_TYPE.WHITE)
            else
                self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))
                self.atRange = false
                self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES4'))
                self.voiceNodeText:setTextColor(COLOR_TYPE.RED)
            end
        end
    end
    self.voiceBtn:addTouchEventListener(voiceBtnCallBack)

    self.voiceBtnText = self.voiceBtn:getChildByName('inputText')
    self.voiceBtnText:setPosition(cc.p(self.voiceBtn:getContentSize().width/2,self.voiceBtn:getContentSize().height/2))
    self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES1'))

    -- node
    self.voiceNode = self.rightbasebg:getChildByName('voice_node')
    self.voiceNodeText = self.voiceNode:getChildByName('text')
    self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES3'))
    self.huaTong = self.voiceNode:getChildByName('huatong')
    self.voiceTab = {}
    for i = 1,5 do
        table.insert(self.voiceTab,self.voiceNode:getChildByName('voice' .. i))
    end
    self.voiceNode:setVisible(false)

    self.voiceRemainNode = self.voiceNode:getChildByName('time')

    local function gLuaRecordVoiceCallBack_(volume)
        local volume = volume or 0
        local value = math.floor(volume/20)
        for i = 1,5 do
            if i <= (value + 1) then
                self.voiceTab[i]:setVisible(true)
            else
                self.voiceTab[i]:setVisible(false)
            end
        end

    end
    YVSdkMgr:setRecordVoiceCallBack(gLuaRecordVoiceCallBack_)

    self.root:scheduleUpdateWithPriorityLua(function (dt)
		self:updateTime(dt)
	end, 0)

    self:chooseFriend()
end

function FriendsMainPanelUI:updateTime(dt)
    if self.isTouch == true then
        self.allTime = self.allTime + dt
        if self.allTime > SPEED_CLICK_TIME then
            -- 开始录音
            self.isTouch = false
            self.voiceMask:setVisible(true)

            self.voiceBtnText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES2'))
            self.voiceNode:setVisible(true)
            self.atRange = true
            self.voiceNodeText:setString(GlobalApi:getLocalStr('CHAT_VOICE_DES3'))
            self.voiceNodeText:setTextColor(COLOR_TYPE.WHITE)
            YVSdkMgr:startRecord()

            self.isSendRecord = false
            self.huaTong:setVisible(true)

            -- 添加时间倒计时
            self:timeoutCallback(MAX_RECORD_TIME - REMAIN_RECORD_TIME,false)
        end
    end
end

function FriendsMainPanelUI:timeoutCallback(diffTime,isSendMsg)
	local diffTime = diffTime - 1
	local node = cc.Node:create()
	node:setTag(9527)		 
	node:setPosition(cc.p(0,0))
	if self.voiceRemainNode:getChildByTag(9527) then
        self.voiceRemainNode:removeChildByTag(9527)
    end
	self.voiceRemainNode:addChild(node)
    if isSendMsg == false then
        node:setVisible(false)
    end
	Utils:createCDLabel(node,diffTime,COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.YELLOW,CDTXTYPE.NONE,nil,nil,nil,40,function ()
        if isSendMsg == false then
            self:timeoutCallback(REMAIN_RECORD_TIME,true)
            self.huaTong:setVisible(false)
        else
            self.stopRecordLogic(true)
        end
	end,1)
end

function FriendsMainPanelUI:createEditBox(attachNode)
    local maxLen = 64
    self.editbox = cc.EditBox:create(attachNode:getContentSize(), 'uires/ui/friends/friends_input.png')
    self.editbox:setPosition(cc.p(attachNode:getContentSize().width/2,attachNode:getContentSize().height/2))
    self.editbox:setFont('font/gamefont.ttf',22)
    self.editbox:setFontColor(cc.c4b(100,45,16,255))
    self.editbox:setPlaceholderFontColor(cc.c4b(100,45,16,255))
    self.editbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.editbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.editbox:setMaxLength(maxLen*10)
    attachNode:addChild(self.editbox)
    self.editbox:setLocalZOrder(0)
    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 22)
    self.nameTx:setPosition(cc.p(0,attachNode:getContentSize().height/2))
    self.nameTx:setColor(cc.c4b(100,45,16,255))
    --self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    --self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0,0.5))
    self.nameTx:setName('name_tx')
    attachNode:addChild(self.nameTx)

    local oldStr = ''
    self.editbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.editbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
        elseif event == "ended" then
            local str = self.editbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.editbox:setText('')
        end
    end)
end

-- 切换语音和文字的状态
function FriendsMainPanelUI:switchVoiceState()
    self.voicePannel:setVisible(self.isVoice)
    self.inputzone:setVisible(not self.isVoice)
    if self.isVoice then    -- 语音状态
        self.swithBtn:loadTextureNormal("uires/ui/friends/friends_keyboard.png")
    else
        self.swithBtn:loadTextureNormal("uires/ui/friends/friends_siri.png")
    end
end

-- 切换到某个好友
function FriendsMainPanelUI:chooseFriend()
    self:switchVoiceState()
end

function FriendsMainPanelUI:SendChatMessage()
    local sendString = self.nameTx:getString()
    if sendString == "" then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_39'), COLOR_TYPE.RED)
        return
    end
    if FriendsMgr:judgeSpeakIsOutTime() then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_DESC_1'), COLOR_TYPE.RED)
        return
    end
    FriendsMgr:resetCdTime()
    FriendsMgr:SendChatMsg(self.curFriendUid,sendString)
    self.nameTx:setString("")
    self.inputText:setString("")
end

function FriendsMainPanelUI:updateRightChatSV()
    if self.scrollbg:getChildByName('scrollview_sv') then
        self.scrollbg:removeChildByName('scrollview_sv')
        self.chatsv = nil
    end
    self.scrollViewGeneral = nil

    local scrollView = ccui.ScrollView:create()
    scrollView:setName('scrollview_sv')
	scrollView:setTouchEnabled(true)
	scrollView:setBounceEnabled(true)
    scrollView:setScrollBarEnabled(false)
    scrollView:setPosition(self.chatsvTemp:getPosition())
    scrollView:setContentSize(self.chatsvTemp:getContentSize())
    self.scrollbg:addChild(scrollView)
	self.chatsv = scrollView

    self.chatDatas = FriendsMgr.chatCacheDatas[self.curFriendUid]
	if self.chatDatas and #self.chatDatas > 0 then
        self.viewSize = self.chatsv:getContentSize() -- 可视区域的大小
		self:initListView()
	end
end

function FriendsMainPanelUI:initListView()
    self.cellSpace = CELL_SPACE
    self.allHeight = 0
    self.cellsData = {}

    local allNum = #self.chatDatas
    for i = 1,allNum do
        self:initItemData(i)
    end

    self.allHeight = self.allHeight + (allNum - 1) * self.cellSpace

    local function callback(tempCellData,widgetItem)
        self:addItem(tempCellData,widgetItem)
    end
    if self.scrollViewGeneral == nil then
        self.scrollViewGeneral = ScrollViewGeneral.new(self.chatsv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil,0)
    else
        self.scrollViewGeneral:resetScrollView(self.chatsv,self.cellsData,self.allHeight,self.viewSize,self.cellSpace,callback,nil,0)
    end
end

function FriendsMainPanelUI:initItemData(index)
    if self.chatDatas[index] then
        local w,h = self:getItemWH(index)

        self.allHeight = h + self.allHeight
        local tempCellData = {}
        tempCellData.index = index
        tempCellData.h = h
        tempCellData.w = w

        table.insert(self.cellsData,tempCellData)
    end
end

function FriendsMainPanelUI:getItemWH(index)
    local chatData = self.chatDatas[index]

    if chatData.showType and chatData.showType == 1 then
        local w = CELL_WIDTH
        local h = CELL_TEXT_HEIGHT
        return w,h
    end

    local w = CELL_WIDTH
    local h = CELL_HEIGHT

    self.chatTx:setString(chatData.content)
    local width = self.chatTx:getContentSize().width    -- 文本的宽度
    local textHeight = TEXT_BG_HEIGHT
    if width > MAX_TEXT_WIDTH then
        width = MAX_TEXT_WIDTH
        self.heightComp:setString(chatData.content)
        textHeight = self.heightComp:getContentSize().height + LIMIT_TEXT_BG_UD_SPACE * 2
    end
    
    -- 判断是否是语音
    if FriendsMgr.judgeIsVoice(chatData) and chatData.content ~= "" then
        textHeight = textHeight + YUYIN_HEIGHT
    end

    if textHeight > TEXT_BG_HEIGHT then
        h = h + (textHeight - TEXT_BG_HEIGHT)
    end

    self.chatDatas[index].textBgHeight = textHeight

    width = width + 2*LIMIT_TEXT_BG_LR_SPACE + LIMIT_TEXT_BG_ARROW_WIDTH
    if width > TEXT_BG_WIDTH then    -- 设置聊天内容背景宽度
        self.chatDatas[index].textBgWidth = width
    else
        self.chatDatas[index].textBgWidth = TEXT_BG_WIDTH
    end

    if FriendsMgr.judgeIsVoice(chatData) then
        if chatData.content ~= "" then
            self.chatDatas[index].textBgWidth = MAX_TEXT_WIDTH + 2*LIMIT_TEXT_BG_LR_SPACE + LIMIT_TEXT_BG_ARROW_WIDTH
        else
            self.chatDatas[index].textBgWidth = YUYIN_NOT_TEXT_WIDTH
        end
    end

    self.chatDatas[index].cellHeight = h
    self.chatDatas[index].offsetHeight = textHeight - TEXT_BG_HEIGHT
    
    return w,h
end

function FriendsMainPanelUI:addItem(tempCellData,widgetItem)
    if self.chatDatas[tempCellData.index] then
        local chatData = self.chatDatas[tempCellData.index]
        local index = tempCellData.index

        local cell = nil

        if chatData.showType and chatData.showType == 1 then
            cell = self.chatTextCell:clone()
            self:updateRightTextCell(cell,index)
        else
            if tonumber(chatData.senduid) == UserData:getUserObj():getUid() then
                cell = self.chatMyCell:clone()
                self:updateRightMyCell(cell,index)
            else
                cell = self.chatOtherCell:clone()
                self:updateRightOtherCell(cell,index)
            end
        end
        cell:setVisible(true)

        local w = tempCellData.w
        local h = tempCellData.h

        widgetItem:addChild(cell)
        cell:setPosition(cc.p(cc.p(0,0)))
    end
end

function FriendsMainPanelUI:updateRightTextCell(cell,index)
    local size = cell:getContentSize()

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, CELL_TEXT_HEIGHT))
	local re1 = xx.RichTextImage:create('uires/ui/common/plaint_1.png')
    re1:setScale(0.5)
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FRIENDS_CHAT_DESC_1'), 18,COLOR_TYPE.WHITE)
	re2:setStroke(COLOR_TYPE.WHITE,0)
    re2:setShadow(COLOROUTLINE_TYPE.BLACK, cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(size.width/2,size.height/2))
    richText:format(true)
    cell:addChild(richText)
end

function FriendsMainPanelUI:updateRightMyCell(cell,index)
    local chatData = self.chatDatas[index]
    local cellHeight = chatData.cellHeight
    local textBgHeight = chatData.textBgHeight
    local textBgWidth = chatData.textBgWidth
    local offsetHeight = chatData.offsetHeight
    
    cell:setContentSize(cc.size(cell:getContentSize().width,cellHeight)) 
    
    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headCell.awardBgImg:setPosition(cc.p(self.rightHeadNodePosX, self.rightHeadNodePosY + offsetHeight))
    headCell.awardBgImg:setScale(0.7)
    cell:addChild(headCell.awardBgImg)

    local frameBg = nil
    for k, v in pairs(RoleData:getRoleMap()) do   
        if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== true then    
            frameBg = v:getBgImg()
            break
        end 
    end
    if frameBg then
        headCell.awardBgImg:loadTexture(frameBg) 
    end

    headCell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
    -- headCell.awardImg:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         if self.curFriendUid ~= nil then
    --             BattleMgr:showCheckInfo(self.curFriendUid)
    --         end
    --     end
    -- end)

    headCell.lvTx:setString(UserData:getUserObj():getLv())
    headCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
    local name = cell:getChildByName('name')
    name:setPositionY(name:getPositionY() + offsetHeight)
    name:setString(UserData:getUserObj():getName())

    local imgV = cell:getChildByName('img_v')
    imgV:setPositionY(imgV:getPositionY() + offsetHeight)

    local vip = UserData:getUserObj():getVip()
    if vip > 0 then
        local vipLabel = cc.LabelAtlas:_create(vip, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	    vipLabel:setAnchorPoint(cc.p(1, 0.5))
	    cell:addChild(vipLabel)
        vipLabel:setPosition(cc.p(391,imgV:getPositionY()))
        imgV:setPositionX(vipLabel:getPositionX() - vipLabel:getContentSize().width)
        name:setPositionX(imgV:getPositionX() - imgV:getContentSize().width)
    else
        imgV:setVisible(false)
    end
    
    -- 文本
    local textBg = cell:getChildByName('text_bg')
    textBg:setContentSize(textBgWidth,textBgHeight)

    local chatText = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
	chatText:setAnchorPoint(cc.p(0, 1))
	chatText:setMaxLineWidth(MAX_TEXT_WIDTH)
	chatText:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	chatText:setColor(cc.c4b(100,45,16,255))
	--chatText:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	--chatText:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    chatText:setString(chatData.content)
    textBg:addChild(chatText)
    chatText:setPosition(cc.p(LIMIT_TEXT_BG_LR_SPACE,textBgHeight - LIMIT_TEXT_BG_UD_SPACE))
    if FriendsMgr.judgeIsVoice(chatData) and chatData.content ~= "" then
        chatText:setPosition(cc.p(LIMIT_TEXT_BG_LR_SPACE,textBgHeight - LIMIT_TEXT_BG_UD_SPACE - YUYIN_IMG_HEIGHT))
    end

    -- 语音
    local yuyinNode = cell:getChildByName('yuyin_node')
    cell.playBtn = yuyinNode:getChildByName('play_btn')
    cell.isReadImg = yuyinNode:getChildByName('is_read')
    cell.seconds = yuyinNode:getChildByName('seconds')
    cell.yuyin1 = yuyinNode:getChildByName('yuyin1')
    cell.yuyin2 = yuyinNode:getChildByName('yuyin2')
    cell.yuyin3 = yuyinNode:getChildByName('yuyin3')
    if FriendsMgr.judgeIsVoice(chatData) then
        yuyinNode:setVisible(true)
        yuyinNode:setPositionY(yuyinNode:getPositionY() + offsetHeight)
        cell.seconds:setString(chatData.voice_time .. '"')
    else
        yuyinNode:setVisible(false)
    end
    cell.isReadImg:setVisible(false)

    local function playCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:playRecord(cell,chatData.voice_url)
        end
    end
    cell.playBtn:addTouchEventListener(playCallBack)
end

function FriendsMainPanelUI:updateRightOtherCell(cell,index)
    local chatData = self.chatDatas[index]
    local cellHeight = chatData.cellHeight
    local textBgHeight = chatData.textBgHeight
    local textBgWidth = chatData.textBgWidth
    local offsetHeight = chatData.offsetHeight
    
    cell:setContentSize(cc.size(cell:getContentSize().width,cellHeight)) 
    
    local friendChatData = nil
    for k,v in pairs(self.frienddataArr) do
        if v[1] == chatData.senduid then
            friendChatData = v[2]
            break
        end
    end

    local headCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    headCell.awardBgImg:setPosition(cc.p(self.leftHeadNodePosX, self.leftHeadNodePosY + offsetHeight))
    headCell.awardBgImg:setScale(0.7)
    headCell.awardBgImg:loadTexture(COLOR_FRAME[friendChatData.quality]) 
    cell:addChild(headCell.awardBgImg)

    local settingHeadIconData = GameData:getConfData('settingheadicon')
    headCell.awardImg:loadTexture(settingHeadIconData[friendChatData.headpic].icon)
    -- headCell.awardBgImg:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.began then
    --         AudioMgr.PlayAudio(11)
    --     elseif eventType == ccui.TouchEventType.ended then
    --         if self.curFriendUid ~= nil then
    --             BattleMgr:showCheckInfo(self.curFriendUid)
    --         end
    --     end
    -- end)
    headCell.lvTx:setString(friendChatData.level)
    headCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(friendChatData.headframe))
    
    local name = cell:getChildByName('name')
    name:setPositionY(name:getPositionY() + offsetHeight)
    name:setString(friendChatData.name)

    local imgV = cell:getChildByName('img_v')
    imgV:setPositionY(imgV:getPositionY() + offsetHeight)

    local vip = friendChatData.vip
    if vip > 0 then
        local vipLabel = cc.LabelAtlas:_create(vip, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	    vipLabel:setAnchorPoint(cc.p(0, 0.5))
	    cell:addChild(vipLabel)
        imgV:setPositionX(name:getPositionX() + name:getContentSize().width)
        vipLabel:setPosition(cc.p(imgV:getPositionX() + imgV:getContentSize().width,imgV:getPositionY()))
    else
        imgV:setVisible(false)
    end

    -- 文本
    local textBg = cell:getChildByName('text_bg')
    textBg:setContentSize(textBgWidth,textBgHeight)

    local chatText = cc.Label:createWithTTF('', "font/gamefont.ttf", 20)
	chatText:setAnchorPoint(cc.p(0, 1))
	chatText:setMaxLineWidth(MAX_TEXT_WIDTH)
	chatText:setHorizontalAlignment(cc.TEXT_ALIGNMENT_LEFT)
	chatText:setColor(cc.c4b(100,45,16,255))
	--chatText:enableOutline(COLOROUTLINE_TYPE.ORANGE,1)
	--chatText:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BUTTON))
    chatText:setString(chatData.content)
    textBg:addChild(chatText)
    chatText:setPosition(cc.p(LIMIT_TEXT_BG_LR_SPACE + LIMIT_TEXT_BG_ARROW_WIDTH,textBgHeight - LIMIT_TEXT_BG_UD_SPACE))
    if FriendsMgr.judgeIsVoice(chatData) and chatData.content ~= "" then
        chatText:setPosition(cc.p(LIMIT_TEXT_BG_LR_SPACE,textBgHeight - LIMIT_TEXT_BG_UD_SPACE - YUYIN_IMG_HEIGHT))
    end

    -- 语音
    local yuyinNode = cell:getChildByName('yuyin_node')
    cell.playBtn = yuyinNode:getChildByName('play_btn')
    cell.isReadImg = yuyinNode:getChildByName('is_read')
    cell.seconds = yuyinNode:getChildByName('seconds')
    cell.yuyin1 = yuyinNode:getChildByName('yuyin1')
    cell.yuyin2 = yuyinNode:getChildByName('yuyin2')
    cell.yuyin3 = yuyinNode:getChildByName('yuyin3')
    if FriendsMgr.judgeIsVoice(chatData) then
        yuyinNode:setVisible(true)
        yuyinNode:setPositionY(yuyinNode:getPositionY() + offsetHeight)
        cell.seconds:setString(chatData.voice_time .. '"')
    else
        yuyinNode:setVisible(false)
    end
    cell.isReadImg:setVisible(false)

    local function playCallBack(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:playRecord(cell,chatData.voice_url)
        end
    end
    cell.playBtn:addTouchEventListener(playCallBack)
end

-- 播放语音
function FriendsMainPanelUI:playRecord(widget,url)
    if YVSdkMgr.loginResult == false then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES7'), COLOR_TYPE.RED)
        return
    end

    if self.isPlaying then
        print('isPlaying=========================')
        YVSdkMgr:stopPlay()
        return
    end

    if not url or url == '' then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('CHAT_VOICE_DES6'), COLOR_TYPE.RED)
        return
    end
    -- 加入动画
    widget.yuyin1:setVisible(false)
    widget.yuyin2:setVisible(false)
    widget.yuyin3:setVisible(false)

    widget.playBtn:setOpacity(0)

    local act1 = cc.CallFunc:create(
	    function ()
            widget.yuyin1:setVisible(true)
            widget.yuyin2:setVisible(false)
            widget.yuyin3:setVisible(false)
		end
    )
    local act2 = cc.CallFunc:create(
	    function ()
            widget.yuyin1:setVisible(true)
            widget.yuyin2:setVisible(true)
            widget.yuyin3:setVisible(false)
		end
    )
    local act3 = cc.CallFunc:create(
	    function ()
            widget.yuyin1:setVisible(true)
            widget.yuyin2:setVisible(true)
            widget.yuyin3:setVisible(true)
		end
    )
    local actDelay = cc.DelayTime:create(0.4)
    widget.playBtn:runAction(cc.RepeatForever:create(
    cc.Sequence:create(actDelay,act1,actDelay,act2,actDelay,act3)))

    self.isPlaying = true
    YVSdkMgr:playRecordFromUrl(url)
    local function callBack(result)
        -- 已读的变为未读的,客户端处理
        print('chatui=========================')
        if not self then
            return
        end
        if not widget or (widget and not widget.playBtn) then
            return
        end

        self.isPlaying = false
        if widget then
            widget.playBtn:stopAllActions()
            widget.yuyin1:setVisible(false)
            widget.yuyin2:setVisible(false)
            widget.yuyin3:setVisible(false)

            widget.playBtn:setOpacity(255)
        end
        widget.isReadImg:setVisible(false)
    end
    YVSdkMgr:setFinishPlayCallBack(callBack)
end

function FriendsMainPanelUI:showNewMessage()
    if not self.scrollViewGeneral then  -- 1条聊天数据也没有
        self:updateRightChatSV()
    else    -- 底部插入一条或者两条
        self.chatDatas = FriendsMgr.chatCacheDatas[self.curFriendUid]
        local index = #self.chatDatas
        if self.chatDatas[index].showType and self.chatDatas[index].showType == 1 then
            local w,h = self:getItemWH(index - 1)
            local tempCellData = {}
            tempCellData.index = index - 1
            tempCellData.h = h
            tempCellData.w = w
            self.scrollViewGeneral:insertCell(self.scrollViewGeneral.INSERT_TYPE[3],tempCellData)

            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.5), cc.CallFunc:create(function ()
                local w,h = self:getItemWH(index)
                local tempCellData = {}
                tempCellData.index = index
                tempCellData.h = h
                tempCellData.w = w
                self.scrollViewGeneral:insertCell(self.scrollViewGeneral.INSERT_TYPE[3],tempCellData)
            end)))
        else
            local w,h = self:getItemWH(index)
            local tempCellData = {}
            tempCellData.index = index
            tempCellData.h = h
            tempCellData.w = w

            self.scrollViewGeneral:insertCell(self.scrollViewGeneral.INSERT_TYPE[3],tempCellData)
        end
    end

end

function FriendsMainPanelUI:refreshLeftShow(msg)
    if msg.senduid == self.curFriendUid then
        return
    end

    local hasMsgIndex = nil
    local judge = false
    local num = #self.frienddataArr
    for i = 1,num do
        local data = self.frienddataArr[i]
        if data[1] == msg.senduid then
            if self.frienddataArr[i][2].hasMsg == 1 then
                judge = true
            end
            hasMsgIndex = i
            self.frienddataArr[i][2].hasMsg = 1
            break
        end
    end
    if hasMsgIndex then
        if hasMsgIndex > 1 or (hasMsgIndex == 1 and judge == false) then
            self:refresFriendItems(hasMsgIndex)
        end
    end
end

function FriendsMainPanelUI:refreshBossLeftShow(msg)
    if msg.uid == self.curFriendUid then
        return
    end

    local hasMsgIndex = nil
    local num = #self.frienddataArr
    for i = 1,num do
        local data = self.frienddataArr[i]
        if tonumber(data[1]) == tonumber(msg.uid) then
            local hasGiftSend = self.frienddataArr[i][2].hasGiftSend
            local hasGiftReceive = self.frienddataArr[i][2].hasGiftReceive
            msg.uid = tostring(msg.uid)
            hasMsgIndex = i
            self.frienddataArr[i][2] = msg
            self.frienddataArr[i][2].hasGiftSend = hasGiftSend
            self.frienddataArr[i][2].hasGiftReceive = hasGiftReceive
            self.frienddataArr[i][2].hasBoss = 1
            break
        end
    end
    if hasMsgIndex and hasMsgIndex > 1 then
        self:refresFriendItems(hasMsgIndex)
    end
end

return FriendsMainPanelUI