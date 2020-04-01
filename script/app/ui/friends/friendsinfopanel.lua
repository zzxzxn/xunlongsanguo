--===============================================================
-- 好友搜索添加界面
--===============================================================
local FriendsInfoPanelUI = class("FriendsInfoPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local defaultNor = 'uires/ui/common/title_btn_nor_2.png'
local defaultSel = 'uires/ui/common/title_btn_sel_2.png'
local defaultColor = cc.c4b(207, 186, 141, 255)
local selectColor = cc.c4b(255, 247, 228, 255)

function FriendsInfoPanelUI:ctor(page)
    self.uiIndex = GAME_UI.UI_FRIENDS_FIND_PANEL
    self.page = page or 1
    self.applydata = FriendsMgr:getFriendData().applied
end

function FriendsInfoPanelUI:onShow()
    self:update()
end

function FriendsInfoPanelUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local alphabg = bgimg1:getChildByName('bg_img1')
    local bgimg2 = alphabg:getChildByName('bg_img_1')
    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            FriendsMgr:hideFriendsInfo()
        end
    end)
    self:adaptUI(bgimg1, alphabg)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_4'))
    self.friendbtnarr = {}
    for i=1,2 do
        local arr = {}
        arr.btn = bgimg2:getChildByName('friend_'..i..'_btn')
        arr.btntx = arr.btn:getChildByName('btn_tx')
        arr.btntx:setString(GlobalApi:getLocalStr('FRIENDS_BTN_'..i))
        arr.btnimg = arr.btn:getChildByName('new_img')
        arr.btnimg:setVisible(false)
        self.friendbtnarr[i] = arr
        self.friendbtnarr[i].btn:addTouchEventListener(function (sender, eventType)
            if eventType ==ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.page and self.page == i then
                    return
                end
                self.page = i
                self:swapList()
                for j=1,2 do
                    self.friendbtnarr[j].btn:loadTextureNormal(defaultNor)
                    self.friendbtnarr[j].btntx:setColor(defaultColor)
                end
                self.friendbtnarr[i].btn:loadTextureNormal(defaultSel)
                self.friendbtnarr[i].btntx:setColor(selectColor)
            end
        end)
    end
    --推荐好友界面
    local friendsbg = bgimg2:getChildByName('friends_bg')
    self.addfriendspl = friendsbg:getChildByName('add_friend_pl')
    local findbtn = self.addfriendspl:getChildByName('find_btn')
    findbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local tx = self.nameTx:getString()
            if tx == "" then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_42'), COLOR_TYPE.RED)
                return
            end

            if tx == UserData:getUserObj():getName() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_43'), COLOR_TYPE.RED)
                return
            end

            local obj = {
                name = self.nameTx:getString()
                }
            MessageMgr:sendPost('applyByName','friend',json.encode(obj),function (response)    
                local code = response.code
                local data = response.data
                if code == 0 then
                    if response.data.status == 5 then
                        self.frienddata = FriendsMgr:getFriendData().friends
                        table.insert(self.frienddata,data.basedata)

                        -- 找到这个名字的uid
                        for k,v in pairs(self.applydata) do
                            if tonumber(v.uid) == tonumber(data.basedata.uid) then
                                self.applydata[k] = nil
                                break
                            end
                        end
                        FriendsMgr:setDirty(true)
                    end
                    FriendsMgr:MsgPop(response.data.status)
                    self:update()
                end
            end)
        end
    end)
    local btntx = findbtn:getChildByName('btntext')
    btntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_6'))
    local addposttx = self.addfriendspl:getChildByName('post_desc')
    addposttx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_5')..':')
    self.addsv = friendsbg:getChildByName('add_sv')
    self.addsv:setScrollBarEnabled(false)
    self:createEditbox(self.addfriendspl)
    --申请列表界面
    self.applylistpl = friendsbg:getChildByName('applylist_pl')
    local deleteallbtn = self.applylistpl:getChildByName('delete_all_btn')
    deleteallbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local judge = false
            for k,v in pairs(self.applydata) do
                if v then
                    judge = true
                    break
                end
            end
            if judge == false then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_36'), COLOR_TYPE.RED)
                return
            end
            MessageMgr:sendPost('remove_apply','friend',"{}",function (response)    
                local code = response.code
                local data = response.data
                if code == 0 then
                    FriendsMgr:setDirty(true)
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_47'), COLOR_TYPE.RED)
                    for k,v in pairs(self.applydata) do
                        self.applydata[k] = nil
                    end
                    self:update()
                end 
            end)
        end
    end)
    local delbtntx = deleteallbtn:getChildByName('btntext')
    delbtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_9'))
    self.applyposttx = self.applylistpl:getChildByName('post_desc')

    self:update()

end

function FriendsInfoPanelUI:createEditbox(parent)
    --self.createpl = bgimg3:getChildByName('create_pl')
    local nameidboxbg = parent:getChildByName('idbox_bg')
    local nameidboxtx = nameidboxbg:getChildByName('idbox_tx')
    nameidboxbg:setLocalZOrder(1)
    nameidboxtx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_7'))

    local maxLen = 20--self.legionglobalconf['legionNameMax'].value
    self.nameeditbox = cc.EditBox:create(cc.size(464, 50), 'uires/ui/friends/friends_input.png')
    self.nameeditbox:setPlaceholderFontColor(cc.c4b(0,0,0,255))
    self.nameeditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.nameeditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nameeditbox:setPlaceHolder('')
    self.nameeditbox:setPosition(242, 60)
    self.nameeditbox:setFontSize(25)
    self.nameeditbox:setText('')
    self.nameeditbox:setFontColor(cc.c4b(0,0,0,255))
    self.nameeditbox:setMaxLength(maxLen)
    -- self.nameeditbox:setOpacity(0)
    parent:addChild(self.nameeditbox)

    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    self.nameTx:setPosition(cc.p(242, 60))
    self.nameTx:setColor(COLOR_TYPE.WHITE)
    self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0.5,0.5))
    self.nameTx:setName('name_tx')
    parent:addChild(self.nameTx)

    local oldStr = ''
    self.nameeditbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.nameeditbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
            nameidboxtx:setString('')
        elseif event == "ended" then
            local str = self.nameeditbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.nameeditbox:setText('')
            if self.nameTx:getString() == '' then
                nameidboxtx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_7'))
            else
                nameidboxtx:setString('')
            end
        end
    end)
end

function FriendsInfoPanelUI:swapList()
    self:updateCell()
end

function FriendsInfoPanelUI:updateCell()
    self.addsv:removeAllChildren()
    for j=1,2 do
        self.friendbtnarr[j].btn:loadTextureNormal(defaultNor)
        self.friendbtnarr[j].btntx:setColor(defaultColor)
    end
    self.friendbtnarr[self.page].btn:loadTextureNormal(defaultSel)
    self.friendbtnarr[self.page].btntx:setColor(selectColor)

    if #FriendsMgr:getFriendData().applied > 0 then
        self.friendbtnarr[2].btnimg:setVisible(true)
    else
        self.friendbtnarr[2].btnimg:setVisible(false)
    end
    --添加好友界面
    if self.page == 1 then
        self.addfriendspl:setVisible(true)
        self.applylistpl:setVisible(false)
        self:updateAddFriend()
    --申请列表界面
    elseif self.page == 2 then
        self.addfriendspl:setVisible(false)
        self.applylistpl:setVisible(true)
        self:updateApplylist()
    end
end

function FriendsInfoPanelUI:update()
    self:swapList()
end

function FriendsInfoPanelUI:updateAddFriend()
    self.recommenddata = FriendsMgr:getRecommendData().recommend
    self.recommenddataArr =  {}
    for k,v in pairs(self.recommenddata) do
        if v ~= nil then
            table.insert(self.recommenddataArr,v) 
        end
    end
    if #self.recommenddataArr == 0 then
            MessageMgr:sendPost("recommend", "friend", "{}", function (jsonObj)
            --print(json.encode(jsonObj))
            if jsonObj.code == 0 then
                FriendsMgr:setRecommendData(jsonObj.data)
                self.recommenddata = FriendsMgr:getRecommendData().recommend
                for k,v in pairs(self.recommenddata) do
                    if v ~= nil then
                        table.insert(self.recommenddataArr,v) 
                    end
                end
                self:updateAddFriendCell()
            end
        end)
    else
        self:updateAddFriendCell()
    end
end

function FriendsInfoPanelUI:updateAddFriendCell()
    for i=1,#self.recommenddataArr do
        self:addFriendsCell(i,self.recommenddataArr[i])
    end
end

function FriendsInfoPanelUI:updateApplylist()
    self.applydata = FriendsMgr:getFriendData().applied
    self.applydataArr =  {}
    for k,v in pairs(self.applydata) do
        if v ~= nil then
            table.insert(self.applydataArr,v) 
        end
    end
    self.applyposttx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_8')..':'..#self.applydataArr)
    for i=1,#self.applydataArr do
        self:addApplyCell(i,self.applydataArr[i])
    end
end

function FriendsInfoPanelUI:addFriendsCell(index,arrdata)
    local node = cc.CSLoader:createNode("csb/friendsfindcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local cellbg = ccui.Widget:create()
    cellbg:addChild(bgimg)
    local headnode = bgimg:getChildByName('head_node')
    local addbtn = bgimg:getChildByName('apply_btn')
    addbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:applyFriend(arrdata.uid)
        end
    end)
    local btntx = addbtn:getChildByName('btntext')
    btntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_6'))
    self:initHeadNode(headnode,arrdata)
    local contentsize = bgimg:getContentSize()
    if #self.recommenddataArr*(contentsize.height+10) > self.addsv:getContentSize().height then
        self.addsv:setInnerContainerSize(cc.size(self.addsv:getContentSize().width,#self.recommenddataArr*(contentsize.height+5)))
    else
        self.addsv:setInnerContainerSize(self.addsv:getContentSize())
    end

    local posy = self.addsv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height/2
    cellbg:setPosition(cc.p(contentsize.width/2+10,posy))
    self.addsv:addChild(cellbg)
    self.addsv:scrollToTop(0.1,true)
end

function FriendsInfoPanelUI:addApplyCell( index,arrdata )
    local node = cc.CSLoader:createNode("csb/friendsapplylistcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local cellbg = ccui.Widget:create()
    cellbg:addChild(bgimg)
    local headnode = bgimg:getChildByName('head_node')
    local okbtn = bgimg:getChildByName('ok_btn')
    okbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendHandleApplyMsg(1,arrdata.uid)
        end
    end)
    local btntx = okbtn:getChildByName('btntext')
    btntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_10'))

    local deletebtn = bgimg:getChildByName('cannel_btn')
    deletebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendHandleApplyMsg(0,arrdata.uid)
        end
    end)
    local deletebtntx = deletebtn:getChildByName('btntext')
    deletebtntx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_11'))

    self:initHeadNode(headnode,arrdata)

    local contentsize = bgimg:getContentSize()
    if #self.applydataArr*(contentsize.height+10) > self.addsv:getContentSize().height then
        self.addsv:setInnerContainerSize(cc.size(self.addsv:getContentSize().width,#self.applydataArr*(contentsize.height+5)))
    else
        self.addsv:setInnerContainerSize(self.addsv:getContentSize())
    end

    local posy = self.addsv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height/2
    cellbg:setPosition(cc.p(contentsize.width/2+10,posy))
    self.addsv:addChild(cellbg)
    self.addsv:scrollToTop(0.1,true)
end

function FriendsInfoPanelUI:sendHandleApplyMsg( agree, uid)
    local obj = {
        id = tonumber(uid),
        agree = agree
    }
    MessageMgr:sendPost('handle_apply','friend',json.encode(obj),function (response)    
        local code = response.code
        local data = response.data
        if response.data.status == 11 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_15'), COLOR_TYPE.RED) 
            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
            self:update()
            return
        end
        if response.data.status == 4 then
            FriendsMgr:MsgPop(response.data.status)
            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
            self:update()
            return
        end
        if code == 0 then
            if agree == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_37'), COLOR_TYPE.RED) 
            elseif agree == 1 then
                self.frienddata = FriendsMgr:getFriendData().friends
                table.insert(self.frienddata,data.basedata)
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_DESC_38'), COLOR_TYPE.GREEN)  
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_7'), COLOR_TYPE.RED)   
            end
            FriendsMgr:MsgPop(response.data.status)
            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
            self:update()
        else
        end

    end)
end

function FriendsInfoPanelUI:applyFriend(uid)
    local obj = {
        id = tonumber(uid)
    }
    MessageMgr:sendPost('apply','friend',json.encode(obj),function (response)    
        local code = response.code
        local data = response.data

        if response.data.status == 5 then
            self.frienddata = FriendsMgr:getFriendData().friends
            table.insert(self.frienddata,data.basedata)

            for k,v in pairs(self.applydata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.applydata[k] = nil
                    break
                end
            end
            FriendsMgr:setDirty(true)
        end
        if code == 0 then
            FriendsMgr:MsgPop(response.data.status)
            for k,v in pairs(self.recommenddata) do
                if tonumber(v.uid) == tonumber(uid) then
                    self.recommenddata[k] = nil
                    break
                end
            end
            self:update()
        else
        end      
    end)
end

function FriendsInfoPanelUI:initHeadNode(parent,arrdata)
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    cell.awardBgImg:loadTexture(COLOR_FRAME[arrdata.quality])
    cell.lvTx:setString('Lv.'..arrdata.level)
    local obj = RoleData:getHeadPicObj(tonumber(arrdata.headpic))
    cell.awardImg:loadTexture(obj:getIcon())
    cell.awardImg:ignoreContentAdaptWithSize(true)
    cell.headframeImg:loadTexture(GlobalApi:getHeadFrame(arrdata.headframe))
    cell.nameTx:setString('')
    local rt = xx.RichText:create()
    rt:setAnchorPoint(cc.p(0, 0.5))
    local rt1 = xx.RichTextLabel:create(arrdata.name..' ', 24,COLOR_TYPE.WHITE)
    local rt2 = xx.RichTextImage:create("uires/ui/chat/chat_vip_small.png")
    local rt3 = xx.RichTextAtlas:create(arrdata.vip,"uires/ui/number/font_ranking.png", 20, 22, '0')
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
    cell.nameTx:setPosition(cc.p(100,70))

    local rtfightforce = xx.RichText:create()
    rtfightforce:setAnchorPoint(cc.p(0, 0.5))
    local rtfightforce1= xx.RichTextImage:create("uires/ui/common/fightbg.png")
    local rtfightforce2 = xx.RichTextAtlas:create(arrdata.fight_force,"uires/ui/number/font_fightforce_3.png", 26, 38, '0')
    rtfightforce:addElement(rtfightforce1)
    rtfightforce:addElement(rtfightforce2)
    rtfightforce:setAlignment("left")
    rtfightforce:setVerticalAlignment('middle')
    rtfightforce:setPosition(cc.p(0, -40))
    rtfightforce:setContentSize(cc.size(400, 30))
    rtfightforce:setScale(0.8)
    cell.nameTx:addChild(rtfightforce)
    cell.nameTx:setPosition(cc.p(100,70))

    parent:addChild(cell.awardBgImg)
end
return FriendsInfoPanelUI