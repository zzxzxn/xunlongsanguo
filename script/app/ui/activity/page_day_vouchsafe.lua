local DayVouchsafe = class("DayVouchsafe")
local ClassSellTips = require('script/app/ui/tips/selltips')
local ClassItemCell = require('script/app/global/itemcell')

local OPEN_BOX = {
    'uires/ui/common/box1.png',
    'uires/ui/common/box1.png',
    'uires/ui/common/box2.png',
    'uires/ui/common/box2.png',
    'uires/ui/common/box3.png',
    'uires/ui/common/box3.png',
}
function DayVouchsafe:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg.day_vouchsafe
    UserData:getUserObj().activity.day_vouchsafe = self.msg
    local nowTime = GlobalData:getServerTime()
    local resetHour = tonumber(GlobalApi:getGlobalValue('resetHour'))
    local time = os.date('*t',nowTime - resetHour *3600)
    local now =tonumber(time.year..string.format('%02d',time.month)..string.format('%02d',time.day))
    self.now = now
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
    if self.msg.rewards and #self.msg.rewards >= 1 then
        self.nowDay = #self.msg.rewards
        if now > tonumber(self.msg.day_pay) or (now == tonumber(self.msg.day_pay) and self.msg.day_money < num) then
            self.nowDay = self.nowDay + 1
        end
    else
        self.nowDay = 1
    end
    local conf = GameData:getConfData('avdayvouchsafe')
    self.nowPage = self.nowDay
    if self.nowPage > #conf then
        self.nowPage = #conf
    end
    if self.nowDay > #conf then
        self.nowDay = #conf
    end
    ActivityMgr:showRightDayVouchsafeRemainTime()
    self:updatePanel()
    self:updateMark()
    cc.UserDefault:getInstance():setIntegerForKey(UserData:getUserObj():getUid()..'day_vouchsafe',GlobalData:getServerTime())
end

function DayVouchsafe:updateMark()
    local isCanGet = false
    for i=1,self.nowDay - 1 do
        if not self.msg.rewards[i] or self.msg.rewards[i] ~= 1 then
            isCanGet = true
            break
        end
    end
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
    if (self.msg.rewards[self.nowDay] and self.msg.rewards[self.nowDay] == 0) 
        or (self.msg.day_money >= num and self.now == tonumber(self.msg.day_pay) 
        and (not self.msg.rewards[self.nowDay] or self.msg.rewards[self.nowDay] ~= 1) ) then
        isCanGet = true
    end
    ActivityMgr:showMark("day_vouchsafe", isCanGet)
end


function DayVouchsafe:updateAwards()
    local conf = GameData:getConfData('avdayvouchsafe')
    local awards = DisplayData:getDisplayObjs(conf[self.nowPage].awards)
    for j=1,4 do
        local awardBgImg = self.rootBG:getChildByName('award_bg_img_'..j)
        if not awardBgImg then
            local tab = ClassItemCell:create()
            awardBgImg = tab.awardBgImg
            self.rootBG:addChild(awardBgImg)
            awardBgImg:setName('award_bg_img_'..j)
            awardBgImg:setPosition(cc.p(j*150 - 25,95))
        end
        if awards[j] then
            awardBgImg:setVisible(true)
            local awardImg = awardBgImg:getChildByName('award_img')
            local nameTx = awardBgImg:getChildByName('name_tx')
            local lvTx = awardBgImg:getChildByName('lv_tx')
            lvTx:setString('x'..awards[j]:getNum())
            awardBgImg:loadTexture(awards[j]:getBgImg())
            awardImg:loadTexture(awards[j]:getIcon())
            nameTx:setString(awards[j]:getName())
            nameTx:enableOutline(awards[j]:getNameOutlineColor(),1)
            nameTx:setColor(awards[j]:getNameColor())
            nameTx:setScale(22/24)
            awards[j]:setLightEffect(awardBgImg)

            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(awards[j])
                end
            end)
        else
            awardBgImg:setVisible(false)
        end
    end

    local hadGetImg  = self.rootBG:getChildByName('had_get_img')
    local rechargeBtn = self.rootBG:getChildByName('recharge_btn')
    local lightEffect = rechargeBtn:getChildByName('light_effect')
    if not lightEffect then
        local size = rechargeBtn:getContentSize()
        lightEffect = GlobalApi:createLittleLossyAniByName('ui_yijianzhuangbei')
        lightEffect:setScaleX(1.4)
        lightEffect:setName('light_effect')
        lightEffect:setPosition(cc.p(size.width/2 ,size.height/2))
        lightEffect:setAnchorPoint(cc.p(0.5,0.5))
        lightEffect:getAnimation():playWithIndex(0, -1, 1)
        rechargeBtn:addChild(lightEffect)
    end
    local infoTx = rechargeBtn:getChildByName('info_tx')
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
    local descTx = self.rootBG:getChildByName('desc_tx')
    local descTx1 = self.rootBG:getChildByName('desc_tx_1')
    descTx1:setString(GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE_DESC_6'))
    descTx:setString(GlobalApi:getLocalStr('ROLE_RISE_STAR_4'))
    local hadNum = 0
    if self.now == tonumber(self.msg.day_pay) then
        hadNum = self.msg.day_money
    end
    if not self.richTextNumRts then
        local richText = xx.RichText:create()
        richText:setContentSize(cc.size(200, 30))
        richText:setAlignment('middle')
        richText:setVerticalAlignment('middle')
        local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE_DESC_1'),24,COLOR_TYPE.WHITE)
        local re1 = xx.RichTextLabel:create(hadNum,24,COLOR_TYPE.RED)
        local re2 = xx.RichTextLabel:create('/'..num,24,COLOR_TYPE.WHITE)
        re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
        re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        richText:addElement(re)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setAnchorPoint(cc.p(0.5,0.5))
        richText:setPosition(cc.p(752,176))
        self.rootBG:addChild(richText)
        self.richTextNumRts = {richText = richText,re = re,re1 = re1,re2 = re2}
    else
        self.richTextNumRts.re1:setString(hadNum)
        self.richTextNumRts.richText:format(true)
    end

    local rechargeBtn = self.rootBG:getChildByName('recharge_btn')
    local infoTx = rechargeBtn:getChildByName('info_tx')
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))
    local function rechargeFunc()
        hadGetImg:setVisible(false)
        rechargeBtn:setVisible(true)
        lightEffect:setVisible(false)
        descTx:setVisible(false)
        if self.richTextNumRts then
            if self.nowPage == self.nowDay then
                self.richTextNumRts.richText:setVisible(true)
            else
                self.richTextNumRts.richText:setVisible(false)
            end
        end
        infoTx:setString(GlobalApi:getLocalStr('PAY_1'))
        rechargeBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                lightEffect:setScaleX(1.5)
            elseif eventType == ccui.TouchEventType.moved then
                lightEffect:setScaleX(1.4)
            elseif eventType == ccui.TouchEventType.canceled then
                lightEffect:setScaleX(1.4)
            elseif eventType == ccui.TouchEventType.ended then
                lightEffect:setScaleX(1.4)
                RechargeMgr:showRecharge()
            end
        end)
    end
    local function getFunc()
        hadGetImg:setVisible(false)
        rechargeBtn:setVisible(true)
        lightEffect:setVisible(true)
        descTx:setVisible(true)
        if self.richTextNumRts then
            self.richTextNumRts.richText:setVisible(false)
        end
        infoTx:setString(GlobalApi:getLocalStr('FWACT_GET'))
        rechargeBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
                lightEffect:setScaleX(1.5)
            elseif eventType == ccui.TouchEventType.moved then
                lightEffect:setScaleX(1.4)
            elseif eventType == ccui.TouchEventType.canceled then
                lightEffect:setScaleX(1.4)
            elseif eventType == ccui.TouchEventType.ended then
                lightEffect:setScaleX(1.4)
                local args = {
                    day = self.nowPage
                }
                MessageMgr:sendPost('get_day_vouchsafe_award','activity',json.encode(args),function (response)
                    local code = response.code
                    if code == 0 then
                        local awards = response.data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end
                        self.msg.rewards[self.nowPage] = 1
                        UserData:getUserObj().activity.day_vouchsafe = self.msg
                        self:updateAwards()
                        self:updateMark()
                    end
                end)
            end
        end)
    end
    local function hadGet()
        hadGetImg:setVisible(true)
        rechargeBtn:setVisible(false)
        lightEffect:setVisible(false)
        descTx:setVisible(true)
        if self.richTextNumRts then
            self.richTextNumRts.richText:setVisible(false)
        end
    end
    if self.nowPage < self.nowDay then
        descTx1:setVisible(false)
        if self.msg.rewards[self.nowPage] == 0 then
            getFunc()
        else
            hadGet()
        end
    elseif self.nowPage == self.nowDay then
        descTx1:setVisible(false)
        if (self.msg.rewards[self.nowPage] and self.msg.rewards[self.nowPage] == 0) 
            or (self.msg.day_money >= num and self.now == tonumber(self.msg.day_pay) and (not self.msg.rewards[self.nowPage] or self.msg.rewards[self.nowPage] ~= 1) ) then
            getFunc()
        elseif (self.msg.rewards[self.nowPage] and self.msg.rewards[self.nowPage] == 1) then
            hadGet()
        else
            rechargeFunc()
        end
    elseif self.nowPage > self.nowDay then
        descTx1:setVisible(true)
        descTx:setVisible(false)
        hadGetImg:setVisible(false)
        rechargeBtn:setVisible(false)
    end

    local nameDescTx = self.rootBG:getChildByName('name_tx')
    nameDescTx:setString(GlobalApi:getLocalStr('DAY_'..self.nowPage)..GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE'))

    local conf = GameData:getConfData('avdayvouchsafe')
    local expBarBg = self.rootBG:getChildByName('exp_bar_bg')
    for i,v in ipairs(conf) do
        local boxImg = expBarBg:getChildByName('box_'..i..'_btn')
        local gouImg = expBarBg:getChildByName('gou_img_'..i)
        local newImg = boxImg:getChildByName('new_img')
        newImg:setVisible(false)
        if self.msg.rewards[i] and self.msg.rewards[i] == 1 then
            boxImg:loadTextures(OPEN_BOX[i],'','')
            gouImg:setVisible(true)
        elseif self.msg.rewards[i] and self.msg.rewards[i] == 0 then
            newImg:setVisible(true)
        end
    end
end

function DayVouchsafe:updatePanel()
    local conf = GameData:getConfData('avdayvouchsafe')
    local expBarBg = self.rootBG:getChildByName('exp_bar_bg')
    expBarBg:setPosition(cc.p(455,230))
    local bar = expBarBg:getChildByName('exp_bar')
    local pers = {13,31,49,67,85,100}
    bar:setPercent(pers[self.nowDay])
    local size = expBarBg:getContentSize()
    for i,v in ipairs(conf) do
        local boxImg = expBarBg:getChildByName('box_'..i..'_btn')
        local dayBgImg = expBarBg:getChildByName('day_bg_img_'..i)
        local gouImg = expBarBg:getChildByName('gou_img_'..i)
        local dayTx = dayBgImg:getChildByName('day_tx')
        dayTx:setString(GlobalApi:getLocalStr('DAY_'..i))
        local newImg = boxImg:getChildByName('new_img')
        newImg:setVisible(false)
        if i == self.nowDay then
            dayTx:setColor(COLOR_TYPE.YELLOW)
        end
        boxImg:setPosition(cc.p(size.width/#conf*i - 65,18))
        dayBgImg:setPosition(cc.p(size.width/#conf*i - 65,35))
        gouImg:setPosition(cc.p(size.width/#conf*i - 65,12.5))
        gouImg:setVisible(false)
        boxImg:setTouchEnabled(true)
        boxImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
             AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.nowPage = i
                self:updateAwards()
            end
        end)
    end

    local lightImg1 = self.rootBG:getChildByName('light_img_1')
    local lightImg2 = self.rootBG:getChildByName('light_img_2')
    lightImg1:setPosition(cc.p(size.width/#conf*5 - 10,276))
    lightImg2:setPosition(cc.p(size.width - 10,276))
    lightImg1:runAction(cc.RepeatForever:create(cc.RotateBy:create(6, 360)))
    lightImg2:runAction(cc.RepeatForever:create(cc.RotateBy:create(6, 360)))
    local num = tonumber(GlobalApi:getGlobalValue('vouchmoney'))

    local richText = self.rootBG:getChildByName('richText')
    if not richText then
        richText = xx.RichText:create()
        richText:setContentSize(cc.size(840, 30))
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
        -- local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('TREASURE_DESC_1'),28,COLOR_TYPE.WHITE)
        local re = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE_DESC_2'),24,COLOR_TYPE.WHITE)
        local re1 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE_DESC_7'),num,num),24,COLOR_TYPE.GREEN)
        local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE_DESC_3'),24,COLOR_TYPE.WHITE)
        local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_DAY_VOUCHSAFE_DESC_4'),24,COLOR_TYPE.ORANGE)
        re:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        re1:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
        re2:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
        re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        richText:addElement(re)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAnchorPoint(cc.p(0,0.5))
        richText:setPosition(cc.p(40,365))
        richText:setName('richText')
        self.rootBG:addChild(richText)
    end
    self:updateAwards()
end

return DayVouchsafe