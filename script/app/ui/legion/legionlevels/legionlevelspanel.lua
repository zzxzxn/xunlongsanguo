local LegionLevelsUI = class("LegionLevelsUI", BaseUI)
local ClassActiveBox = require('script/app/ui/mainscene/activeboxui')
local MAXCOPY = 6
function LegionLevelsUI:ctor(index)
    self.uiIndex = GAME_UI.UI_LEGIONLEVELS
    self.data = LegionMgr:getLegionLevelsData()
    self.index = index
    self.legioncopyconf = GameData:getConfData("legioncopy")
    self.legionconf = GameData:getConfData('legion')
end

function LegionLevelsUI:onShow()
    self.data = LegionMgr:getLegionLevelsData()
    self:update()
    self.cdlabel:setTime(Time.beginningOfWeek(GlobalApi:getGlobalValue('resetHour')*3600)+7*24*3600+GlobalApi:getGlobalValue('resetHour')*3600 - (GlobalData:getServerTime()))
end

function LegionLevelsUI:onCover()
    --self.cdlabel:pause()
end
function LegionLevelsUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bgimg = self.root:getChildByName("bg_img")
    bgimg:setPosition(cc.p(winsize.width/2,winsize.height/2))
    local bgimg1 = bgimg:getChildByName('bg_img_1')
    local closebtn = bgimg1:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionLevelsUI()
        end
    end)
    local numtx = bgimg1:getChildByName('num_tx')
    self.richText = xx.RichText:create()
    self.richText:setContentSize(cc.size(300, 30))
    self.richText:setAlignment('middle')
    self.richText:setVerticalAlignment('middle')
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_LEVELS_NUMS1'), 25,COLOR_TYPE.WHITE)
    re1:setFont('font/gamefont.ttf')
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.re2 = xx.RichTextLabel:create('',28,COLOR_TYPE.WHITE)
    
    self.re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richText:addElement(re1)
    self.richText:addElement(self.re2)
    self.richText:setPosition(cc.p(0,0))
    numtx:addChild(self.richText)
    local addbtn = bgimg1:getChildByName('add_btn')
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
    local citybg = bgimg1:getChildByName('city_bg')
    self.cityimg = citybg:getChildByName('city_img')
    local awardbg = bgimg1:getChildByName('award_bg')
    local awarddesctx =awardbg:getChildByName('award_desc_tx')
    awarddesctx:setString(string.format(GlobalApi:getLocalStr('LEGION_LEVELS_DESC17'),self.legioncopyconf[self.index].name))
    local dmbtn = awardbg:getChildByName('dm_btn')
    dmbtn:setVisible(false)

    local awardimg = awardbg:getChildByName('award_img')
    awardimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local conf = GameData:getConfData('legioncopy')[self.index]
            local richText = xx.RichText:create()
            richText:setContentSize(cc.size(400, 30))
            richText:setAlignment('middle')
            local tx1 = GlobalApi:getLocalStr('FUNCTION_DESC_1')
            local tx2 = conf.name
            local tx3 = GlobalApi:getLocalStr('LEGION_LEVELS_DESC7')
            local re1 = xx.RichTextLabel:create(tx1, 25,COLOR_TYPE.ORANGE)
            local re2 = xx.RichTextLabel:create(tx2,25,COLOR_TYPE.WHITE)
            local re3 = xx.RichTextLabel:create(tx3,25,COLOR_TYPE.ORANGE)
            re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
            re2:setStroke(COLOR_TYPE.BLACK, 1)
            re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
            richText:addElement(re1)
            richText:addElement(re2)
            richText:addElement(re3)
            local awards = conf.reward
            local classActiveBox = ClassActiveBox.new(GlobalApi:getLocalStr('LEGION_LEVELS_DESC8'),GlobalApi:getLocalStr('STR_OK2'),richText,awards,false)
            classActiveBox:showUI()
        end
    end)

    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(self.legioncopyconf[self.index].name)
    local barbg = bgimg1:getChildByName('bar_bg')
    -- 主进度
    self.bar = barbg:getChildByName('bar')
    self.bar:setScale9Enabled(true)
    self.bar:setCapInsets(cc.rect(10,15,1,1))
    self.bartx = self.bar:getChildByName('bar_tx')
    self.bar:setPercent(LegionMgr:calccopypercent(self.data,self.index))
    self.bartx:setString(LegionMgr:calccopypercent(self.data,self.index)..'%')
    self.maptab = {}
    local charpterbg = bgimg1:getChildByName('charpter_bg')
    for i=1,MAXCOPY do
        local arr = {}
        local bg = charpterbg:getChildByName('enemy_'..i..'_bg')
        arr.smallbg = bg:getChildByName('enemy_small_bg')
        arr.bg = bg
        arr.bg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.chapter == self.index then
                    if i == self.data.progress then
                        if  self.legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy > 0 then
                            LegionMgr:showLegionLevelsBattleUI(i,self.index)
                        else
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC10'), COLOR_TYPE.RED)
                        end
                    elseif i > self.data.progress then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC1'), COLOR_TYPE.RED)
                    elseif i < self.data.progress then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC16'), COLOR_TYPE.RED)
                    end
                elseif self.data.chapter > self.index then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_LEVELS_DESC16'), COLOR_TYPE.RED)
                end
            end
        end)
        -- 子进度
        arr.barbg = arr.smallbg:getChildByName('bar_bg')
        arr.bar = arr.barbg:getChildByName('bar')
        arr.bar:setPercent(100)

        arr.bar:setScale9Enabled(true)
        arr.bar:setCapInsets(cc.rect(10,15,1,1))


        arr.bartx = arr.bar:getChildByName('bar_tx')
        arr.bartx:setString('100%')
        arr.frame = arr.smallbg:getChildByName('frame_bg')
        arr.headicon = arr.frame:getChildByName('frame_img')
        arr.sucimg = bg:getChildByName('suc_img')
        arr.suctx = bg:getChildByName('suc_tx')
        arr.suctx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC15'))
        self.maptab[i]=arr
    end

    self.resettx = bgimg1:getChildByName('resettime_tx')
    self.resettx:setString('')
    local diffTime = Time.beginningOfWeek(GlobalApi:getGlobalValue('resetHour')*3600)+7*24*3600+GlobalApi:getGlobalValue('resetHour')*3600 - (GlobalData:getServerTime())
    self.cdlabel = Utils:createCDLabel(self.resettx,diffTime,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.WHITE,CDTXTYPE.BACK, GlobalApi:getLocalStr('LEGION_LEVELS_DESC2'),COLOR_TYPE.ORANGE,COLOROUTLINE_TYPE.WHITE,25,function()
        self.data.chapter = 1
        self.data.progress = 1
        for i=1,9 do
            self.data.healths[i] = 100
        end
        LegionMgr:hideLegionLevelsUI()
        LegionMgr:hideLegionLevelsMainUI()
    end)

    self:update()
end

function LegionLevelsUI:update()
    self.bar:setPercent(LegionMgr:calccopypercent(self.data,self.index))
    self.bartx:setString(LegionMgr:calccopypercent(self.data,self.index)..'%')
    self.cityimg:loadTexture('uires/ui/mainscene/mainscene_' .. self.legioncopyconf[self.index].icon)
    self.cityimg:setScale(self.legioncopyconf[self.index].scale)
    local formationconf = GameData:getConfData("formation")
    local monsterconf = GameData:getConfData('monster')
    --printall(formationawardconf[500].reward)
    --print('xxxx'..self.data.progress)
    for i=1,6 do
        local formationid = self.legioncopyconf[self.index][tostring('formation'..i)]
        local bosspos = formationconf[formationid].boss
        local bossid = formationconf[formationid][tostring('pos'..bosspos)]
        local monsterurl = 'uires/icon/hero/'..monsterconf[bossid].url .. '_icon.png'
        self.maptab[i].headicon:loadTexture(monsterurl)
        self.maptab[i].bar:setPercent(100)
        self.maptab[i].bartx:setString('100%')
        ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].bg)
        ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].smallbg)
        ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].frame)
        ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].headicon)
        ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].barbg)
        ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].bar)
        --ShaderMgr:restoreWidgetDefaultShader(self.maptab[i].bartx)
        if self.data.chapter == self.index then
            if i < self.data.progress then           
                self.maptab[i].sucimg:setVisible(true)
                self.maptab[i].suctx:setVisible(true)
                ShaderMgr:setGrayForWidget(self.maptab[i].bg)
                ShaderMgr:setGrayForWidget(self.maptab[i].smallbg)
                ShaderMgr:setGrayForWidget(self.maptab[i].frame)
                ShaderMgr:setGrayForWidget(self.maptab[i].headicon)
                ShaderMgr:setGrayForWidget(self.maptab[i].bar)
                --ShaderMgr:setGrayForWidget(self.maptab[i].bartx)
                ShaderMgr:setGrayForWidget(self.maptab[i].barbg)
            elseif i == self.data.progress then
                self.maptab[i].sucimg:setVisible(false)
                self.maptab[i].suctx:setVisible(false)
                self.maptab[i].bar:setPercent(LegionMgr:calccopyHp(self.data,self.index))
                self.maptab[i].bartx:setString(LegionMgr:calccopyHp(self.data,self.index)..'%')
            elseif i > self.data.progress then
                self.maptab[i].sucimg:setVisible(false)
                self.maptab[i].suctx:setVisible(false)
            end
        elseif self.data.chapter > self.index then
            self.maptab[i].sucimg:setVisible(true)
            self.maptab[i].suctx:setVisible(true)
            ShaderMgr:setGrayForWidget(self.maptab[i].bg)
            ShaderMgr:setGrayForWidget(self.maptab[i].smallbg)
            ShaderMgr:setGrayForWidget(self.maptab[i].frame)
            ShaderMgr:setGrayForWidget(self.maptab[i].headicon)
            ShaderMgr:setGrayForWidget(self.maptab[i].bar)
            --ShaderMgr:setGrayForWidget(self.maptab[i].bartx)
            ShaderMgr:setGrayForWidget(self.maptab[i].barbg)
        end
        self.re2:setString(self.legionconf['legionCopyFightLimit'].value-self.data.copy_count + self.data.copy_buy)
        self.richText:format(true)
    end
end

function LegionLevelsUI:sendMsg()
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

return LegionLevelsUI