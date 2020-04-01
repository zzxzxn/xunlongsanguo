--===============================================================
-- 军团摇钱树
--===============================================================
local LegionActivityShakeUI = class("LegionActivityShakeUI", BaseUI)

function LegionActivityShakeUI:ctor(data,legiondata)
  self.uiIndex = GAME_UI.UI_LEGIONACTIVITYSHAKEUI
  self.data = data
  self.legiondata = legiondata
  self.time = 0
  self.legionconf = GameData:getConfData('legion')
  UserData:getUserObj():getLGoldtree().outcome = self.data.outcome
end

function LegionActivityShakeUI:onShow()
    self:update()
end

function LegionActivityShakeUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    self.bgimg3 = bgimg2:getChildByName('bg_img1')
    local closebtn = self.bgimg3:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityShakeUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)
    self.bgimg4 = self.bgimg3:getChildByName('bg_img2')
    local titlebg = self.bgimg3:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_TITLE'))
    
    local btnbg = self.bgimg3:getChildByName('btn_bg')
    self.shakebtn = btnbg:getChildByName('shake_btn')
    local shakebtntx = self.shakebtn:getChildByName('btn_tx')
    shakebtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_BTN_TX'))
    self.shakebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.selectAni:getAnimation():play('idle2', -1, 1)
            if self.legionconf['shakeGoldTreeCount'].value-self.data.shake_tree > 0 then
                MessageMgr:sendPost('shake_tree','legion','{}',function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        self.data.outcome = self.data.outcome - 1
                        UserData:getUserObj():getLGoldtree().outcome = self.data.outcome
                        local legioninfo = UserData:getUserObj():getLegionInfo()
                        self.data.shake_tree = self.data.shake_tree + 1
                        legioninfo.shake_tree = self.data.shake_tree
                        self.data.shake_time = GlobalData:getServerTime()
                        legioninfo.shake_time = self.data.shake_time
                        local awards = data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_4'),awards[1][3]), COLOR_TYPE.GREEN)
                        end
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        self:update()
                    elseif code == 101 then
                        self.data.outcome = 0
                        UserData:getUserObj():getLGoldtree().outcome = self.data.outcome
                        self:update()
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_2'), COLOR_TYPE.RED)
                    end    
                end) 

            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_3'), COLOR_TYPE.RED)
            end
        end
    end)
    --local shakebg = self.bgimg4:getChildByName('shake_img_2')
    local desctx1 = self.bgimg4:getChildByName('desc_tx_1')
    desctx1:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_DESC1'))
    local desctx2 = self.bgimg4:getChildByName('desc_tx_2')
    desctx2:setString('')
    local desctx3 = self.bgimg4:getChildByName('desc_tx_3')
    desctx3:setString('')
    local desctx4 = self.bgimg4:getChildByName('desc_tx_4')
    desctx4:setString("")
    self.richTextDesc1 = xx.RichText:create()
    self.richTextDesc1:setContentSize(cc.size(250, 40))
    local desec1re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_DESC2'),24, COLOR_TYPE.WHITE)
    desec1re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    desec1re1:setFont('font/gamefont.ttf')
    self.selftimestx = xx.RichTextLabel:create('   '..self.legionconf['shakeGoldTreeCount'].value-self.data.shake_tree,24, COLOR_TYPE.GREEN)
    self.selftimestx:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richTextDesc1:addElement(desec1re1)
    self.richTextDesc1:addElement(self.selftimestx)
    self.richTextDesc1:setAnchorPoint(cc.p(0,0.5))
    self.richTextDesc1:setVerticalAlignment('middle')
    self.richTextDesc1:setPosition(cc.p(0,0))
    desctx2:addChild(self.richTextDesc1)

    self.richTextDesc2 = xx.RichText:create()
    self.richTextDesc2:setContentSize(cc.size(250, 40))
    local desec2re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_DESC3'),24, COLOR_TYPE.WHITE)
    desec2re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    desec2re1:setFont('font/gamefont.ttf')
    self.legiontimestx = xx.RichTextLabel:create('  '..self.data.outcome,24, COLOR_TYPE.GREEN)
    self.legiontimestx:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local desec2re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_DESC5'),24, COLOR_TYPE.WHITE)
    desec2re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    desec2re3:setFont('font/gamefont.ttf')

    self.richTextDesc2:addElement(desec2re1)
    self.richTextDesc2:addElement(self.legiontimestx)
    self.richTextDesc2:addElement(desec2re3)
    self.richTextDesc2:setAnchorPoint(cc.p(0.5,0.5))
    self.richTextDesc2:setVerticalAlignment('middle')
    self.richTextDesc2:setPosition(cc.p(0,0))
    desctx3:addChild(self.richTextDesc2)


    self.richTextDesc3 = xx.RichText:create()
    self.richTextDesc3:setContentSize(cc.size(350, 40))
    local desec3re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_SHAKE_DESC4'),24, COLOR_TYPE.WHITE)
    desec3re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    desec3re1:setFont('font/gamefont.ttf')
    local str = Time.date('%H',math.floor((self.data.time/3600)*3600))  + self.legionconf['goldTreeResetInterval'].value
    if str >=24 then
        str = 0
    end

    self.refreshtimetx = xx.RichTextLabel:create('  '..str,24, COLOR_TYPE.GREEN)
    self.refreshtimetx:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local desec3re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_DIAN'),24, COLOR_TYPE.WHITE)
    desec3re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    desec3re3:setFont('font/gamefont.ttf')

    self.richTextDesc3:addElement(desec3re1)
    self.richTextDesc3:addElement(self.refreshtimetx)
    self.richTextDesc3:addElement(desec3re3)
    self.richTextDesc3:setAnchorPoint(cc.p(0,0.5))
    self.richTextDesc3:setVerticalAlignment('middle')
    self.richTextDesc3:setPosition(cc.p(0,0))
    desctx4:addChild(self.richTextDesc3)

    self.selectAni = GlobalApi:createAniByName('ui_legion_shake')
    self.selectAni:getAnimation():play('idle', -1, 1)
    self.selectAni:setPosition(cc.p(400,180))
    self.bgimg4:addChild(self.selectAni)

    self:update()
    self.root:scheduleUpdateWithPriorityLua(function (dt)
        self:updatepush(dt)
    end, 0)
end

function LegionActivityShakeUI:update()
    
    local legionoutcome = GameData:getConfData('legionlevel')[self.legiondata.level].goldOutcome
    self.legiontimestx:setString(self.data.outcome)
    self.richTextDesc2:format(true)
    local str = Time.date('%H',math.floor((self.data.time/3600)*3600))  + self.legionconf['goldTreeResetInterval'].value
    if str >=24 then
        str = 0
    end
    self.refreshtimetx:setString(str)
    self.richTextDesc3:format(true)
    self.selftimestx:setString('   '..self.legionconf['shakeGoldTreeCount'].value-self.data.shake_tree)
    self.richTextDesc1:format(true)
    if GlobalData:getServerTime() - self.data.shake_time <= self.legionconf['shakeGoldTreeInterval'].value*60 
    and self.legionconf['shakeGoldTreeCount'].value-self.data.shake_tree > 0 then
        self.shakebtn:setVisible(false)
        self.bgimg3:removeChildByTag(9527)
        local label = cc.Label:createWithTTF('', "font/gamefont.ttf", 25)
        label:setAnchorPoint(cc.p(0.5,0.5))
        label:setPosition(cc.p(360,121))
        label:setTag(9527)
        label:setLocalZOrder(9999)
        
        self.bgimg3:addChild(label)
        local diffTime = self.legionconf['shakeGoldTreeInterval'].value*60 - (GlobalData:getServerTime() - self.data.shake_time)
        Utils:createCDLabel(label,diffTime,COLOR_TYPE.GREEN,COLOROUTLINE_TYPE.GREEN,CDTXTYPE.FRONT, '',COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,25,function()
            self.shakebtn:setVisible(true)
            self.bgimg3:removeChildByTag(9527)
        end)
    elseif GlobalData:getServerTime() - self.data.shake_time > self.legionconf['shakeGoldTreeInterval'].value*60 then
        self.shakebtn:setVisible(true)
        self.bgimg3:removeChildByTag(9527)
    else 
        self.bgimg3:removeChildByTag(9527)
        self.shakebtn:setVisible(true)

    end
end

function LegionActivityShakeUI:updatepush(dt)
    self.time = self.time + dt
    if self.time > 30 then
        local min = Time.date('%M',GlobalData:getServerTime())
        if min == 0 then
            self.data.outcome = legionoutcome
            self:update()
        end
    end
end

function LegionActivityShakeUI:goldFly()
    local x1 = 0
    local y1 = 100
    local num = 20
    for i=1,num do
        local x = math.random(x1 - 200,x1 + 200)
        local y = math.random(y1,y1 + 150)
        local diffx = math.random(x+25,x+50)
        local diffy = math.random(y+25,y+50)
        local diffx1 = math.random(diffx-25,diffx+50)
        local diffy1 = math.random(diffy-400,diffy-300)
        local time = 0.4 + math.random(50,200)*0.001
        local delaytime = i*0.1+ math.random(0,200)*0.001
        local bezier = {
            cc.p(x,y),
            cc.p(diffx,diffy),
            cc.p(diffx1,diffy1)
        }
        local bezierTo = cc.BezierTo:create(time, bezier)
        local goldImg = ccui.ImageView:create('uires/ui/res/res_gold.png')
        goldImg:setPosition(cc.p(x,y))
        self.selectAni:addChild(goldImg)
        goldImg:runAction(cc.FadeIn:create(0.2))
            goldImg:runAction(cc.Sequence:create(cc.DelayTime:create(delaytime),
        bezierTo,
        cc.CallFunc:create(function ()
            goldImg:removeFromParent()
        end))
    )
    end
end

return LegionActivityShakeUI