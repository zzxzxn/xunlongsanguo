local AltarMainUI = class("AltarMainUI", BaseUI)

function AltarMainUI:ctor(id)
	self.uiIndex = GAME_UI.UI_ALTARMAINUI
    self.altarconf = GameData:getConfData('altar')
    self.globalconf = GameData:getConfData('global')
    self.selectpos = id or 1
end
function AltarMainUI:init()
	local bgimg = self.root:getChildByName("bg_img")
	local bgimg1 = bgimg:getChildByName("bg_img1")
    local pl = bgimg:getChildByName("pl")
    if self.selectpos  ~= 1 then
        local action = cc.CSLoader:createTimeline("csb/altarmainpanel.csb")
        self.root:runAction(action)
        -- action:play("show"..(self.selectpos - 1), false)
        -- action:gotoFrameAndPlay(0, false)
    end
    self:adaptUI(bgimg, bgimg1)
    local winsize = cc.Director:getInstance():getWinSize()
    -- bgimg:setPosition(cc.p(winsize.width/2,winsize.height/2))
    local closebtn = self.root:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideAltar()
        end
    end)
    closebtn:setPosition(cc.p(winsize.width,winsize.height))
    self.praytabel = {}
    self.praybg = {}
    for i=1,4 do
        local arr = {}
        local  bg = bgimg1:getChildByName('pray_'..i.."_bg")
        self.praybg[i] = bg

        --local bg1 = bg:getChildByName('bg_img2')
        arr.pl = bg:getChildByName('bottom_pl')
        --arr.titlename = bg:getChildByName('title_name')
        arr.nameimg = bg:getChildByName('name_img')
        arr.iconimg = bg:getChildByName('icon_img')
        local barbg = arr.pl:getChildByName('bar_bg')
        arr.bar = barbg:getChildByName('bar')
        arr.bartx = arr.bar:getChildByName('bar_tx')
        arr.awardbg = arr.iconimg:getChildByName('award_bg')
        arr.exchangebtn = arr.iconimg:getChildByName('func_btn')
        arr.itemarr = {}
        -- for j=1,3 do
        --     local arrb = {}
        --     arrb.bg = arr.awardbg:getChildByName('item_'..j..'_bg')
        --     arrb.icong = arrb.bg:getChildByName('item_icon')
        --     arr.itemarr[j]= arrb
        -- end
        arr.numBgImg = bg:getChildByName('num_bg_img')
        arr.descTx1 = arr.numBgImg:getChildByName('desc_tx')
        arr.resImg = arr.numBgImg:getChildByName('res_img')
        arr.numTx = arr.numBgImg:getChildByName('num_tx')
        local infobg1 = arr.pl:getChildByName('info_bg')
        local infodesc1 = infobg1:getChildByName('desc_tx1')
        infodesc1:setString(GlobalApi:getLocalStr('ATLAR_DESC2'))
        arr.costtx = infobg1:getChildByName('num_tx1')
        arr.desctx = bg:getChildByName('desc_tx')
        arr.cash = infobg1:getChildByName('cash_img')
        local infobg2 = arr.pl:getChildByName('info_bg2')
        local infodesc2 = infobg2:getChildByName('desc_tx2')
        infodesc2:setString(GlobalApi:getLocalStr('ATLAR_DESC1'))
        arr.counttx= infobg2:getChildByName('num_tx2')
        arr.fastBtn = arr.pl:getChildByName('fast_btn')
        arr.fastbtntx = arr.fastBtn:getChildByName('btn_tx')
        arr.fastbtntx:setString(GlobalApi:getLocalStr('AUTO_ALTAR'))
        arr.paraybtn = arr.pl:getChildByName('func_btn')
        arr.fastBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if i == 2 then
                    local food = UserData:getUserObj():getFood()
                    local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                    if food >= maxFood then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                        return
                    end
                end
                local altar = UserData:getUserObj():getAltar()
                local count = tonumber(altar[tostring(i)]) or 0
                local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())]
                local levelConf = GameData:getConfData('level')[UserData:getUserObj():getLv()]
                local award = DisplayData:getDisplayObj(self.altarconf[i]['award'][1])
                --local displayobj = DisplayData:getDisplayObj(self.altarconf[i]['cost'][1])
                --local cost = self.altarconf[i]['cost'] + self.altarconf[i]['inc']*(count-self.altarconf[i].free)
                local round = math.ceil((count + 1)/5)
                if round == 0 then
                    round = 1
                elseif round > 12 then
                    round = 12
                end
                local cost = self.altarconf[i]['cost' .. round]

                if count >= vipconf[tostring('altar'..i)]  then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ATLAR_DESC5'), COLOR_TYPE.RED)
                    return
                else
                    if UserData:getUserObj():getLv() < self.altarconf[i].level then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'), COLOR_TYPE.RED)
                        return
                    end
                    local needNum = 5 - count%5
                    local function auto(num,num1)
                        self:sendAutoMsg(i,bg,num1,num*cost,string.format(GlobalApi:getLocalStr('AUTO_ALTAR_COST'),num*cost,
                            num1,(num1 + 4)*levelConf['altar'..i],award:getName()))
                        --[[
                        promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('AUTO_ALTAR_COST'),num*cost,
                            num1,(num1 + 4)*levelConf['altar'..i],award:getName()),
                            MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                            self:sendAutoMsg(i,bg,num1,num*cost)
                        end)
                        --]]
                    end
                    if count + 1 > self.altarconf[i].free then
                        print(needNum)
                        auto(needNum,needNum)
                    else
                        print(needNum - self.altarconf[i].free + count)
                        auto(needNum - self.altarconf[i].free + count,needNum)
                    end
                end
            end
        end)
        arr.paraybtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if i == 2 then
                    local food = UserData:getUserObj():getFood()
                    local maxFood = tonumber(GlobalApi:getGlobalValue('maxFood'))
                    if food >= maxFood then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FOOD_MAX'), COLOR_TYPE.RED)
                        return
                    end
                end
                local altar = UserData:getUserObj():getAltar()
                local count = tonumber(altar[tostring(i)]) or 0
                local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())]
                --local displayobj = DisplayData:getDisplayObj(self.altarconf[i]['cost'][1])
                --local cost = self.altarconf[i]['cost'] + self.altarconf[i]['inc']*(count-self.altarconf[i].free)
                local round = math.ceil((count + 1)/5)
                if round == 0 then
                    round = 1
                elseif round > 12 then
                    round = 12
                end
                local cost = self.altarconf[i]['cost' .. round]

                if count >= vipconf[tostring('altar'..i)]  then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ATLAR_DESC5'), COLOR_TYPE.RED)
                    return
                else
                    if UserData:getUserObj():getLv() < self.altarconf[i].level then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'), COLOR_TYPE.RED)
                        return
                    end
                    if count+1 > self.altarconf[i].free then
                        local str = string.format(GlobalApi:getLocalStr('ATLAR_DESC4'),cost)
                        UserData:getUserObj():cost('cash',cost,function()
                            self:sendMsg(i,bg)
                        end,true,str)
                    else
                        self:sendMsg(i,bg)
                    end
                end
 
            end
        end)
        arr.paraybtntx = arr.paraybtn:getChildByName('btn_tx')
        arr.infoimg = bg:getChildByName('info_img')
        self.praytabel[i]= arr
    end
    self:update()
    local allPos = {cc.p(480,250),cc.p(720,324),cc.p(480,400),cc.p(240,324)}
    GlobalApi:setCardRunRound(pl,self.praybg,self.selectpos,1,2,200,true,3,nil,function(pos)
        self.selectpos = pos
        for i=1,4 do
            self.praytabel[i].paraybtn:setTouchEnabled(false)
            self.praytabel[i].fastBtn:setTouchEnabled(false)
        end
        self.praytabel[self.selectpos].paraybtn:setTouchEnabled(true)
        self.praytabel[self.selectpos].fastBtn:setTouchEnabled(true)
    end,allPos)
    

end

function AltarMainUI:update()
    for i=1,4 do
        self.praytabel[i].paraybtn:setTouchEnabled(false)
        self.praytabel[i].fastBtn:setTouchEnabled(false)
    end
    self.praytabel[self.selectpos].paraybtn:setTouchEnabled(true)
    self.praytabel[self.selectpos].fastBtn:setTouchEnabled(true)
    local vipconf = GameData:getConfData('vip')[tostring(UserData:getUserObj():getVip())]  
    local levelconf = GameData:getConfData('level')
    local num = 0
    local icon = nil
    for i=1,4 do
        --self.praytabel[i].titlename:setString('')
        self.praytabel[i].desctx:setString('')
        self.praytabel[i].paraybtntx:setString(GlobalApi:getLocalStr('ATLAR_BTNTX'..i))
        self.praytabel[i].iconimg:loadTexture('uires/ui/altar/'..self.altarconf[i].bg)
        -- if i ~= 3 then
        if self.altarconf[i]['award'] and self.altarconf[i]['award'][1] then
            local displayobj = DisplayData:getDisplayObj(self.altarconf[i]['award'][1])
            num = math.floor(displayobj:getNum()*levelconf[UserData:getUserObj():getLv()][tostring('altar'..i)]/100)
            icon =displayobj:getIcon()
            self:initState(self.praytabel[i].nameimg,i,num,icon)
        else
            self:initState(self.praytabel[i].nameimg,i,nil,nil)
        end
        local award = DisplayData:getDisplayObj(self.altarconf[i]['award'][1])
        local levelConf = GameData:getConfData('level')[UserData:getUserObj():getLv()]
        self.praytabel[i].resImg:loadTexture(award:getIcon())
        local altar = UserData:getUserObj():getAltar()
        local str = tostring('altar'..i)
        --self.praytabel[i].costtx:removeAllChildren()
        if altar and altar[tostring(i)] then
            local count = tonumber(altar[tostring(i)])
            self.praytabel[i].bartx:setString((count%5)..'/'..'4')
            --self.praytabel[i].bar:setPercent(math.floor(100*((count%5)/4)))
            self:updatelvbar(i,count,math.floor(100*((count%5)/4)),false)
            self.praytabel[i].counttx:setString(vipconf[str]-count)

            if count >= self.altarconf[i].free then
                --local displayobj = DisplayData:getDisplayObj(self.altarconf[i]['cost'][1])
                local round = math.ceil((count + 1)/5)
                if round == 0 then
                    round = 1
                elseif round > 12 then
                    round = 12
                end
                local cost = self.altarconf[i]['cost' .. round]
                self.praytabel[i].costtx:setString(cost)
                self.praytabel[i].cash:setVisible(true)
                self.praytabel[i].infoimg:setVisible(false)
                if count%5 == 4 then
                    self.praytabel[i].numTx:setString(levelConf['altar'..i] * 5)
                else
                    self.praytabel[i].numTx:setString(levelConf['altar'..i])
                end
            else
                self.praytabel[i].numTx:setString(levelConf['altar'..i])
                if UserData:getUserObj():getLv() < self.altarconf[i].level then
                    self.praytabel[i].infoimg:setVisible(false)
                else
                    self.praytabel[i].infoimg:setVisible(true)
                end
                self.praytabel[i].cash:setVisible(false)
                self.praytabel[i].costtx:setString(GlobalApi:getLocalStr('STR_FREE'))
            end
        else
            self.praytabel[i].numTx:setString(levelConf['altar'..i])
            self.praytabel[i].bartx:setString('0/4')
            self.praytabel[i].bar:setPercent(0)
            self.praytabel[i].counttx:setString(vipconf[tostring(str)])
            self.praytabel[i].costtx:setString(GlobalApi:getLocalStr('STR_FREE'))
        end
    end
end

function AltarMainUI:updatelvbar(index,count,percent,needupdate)
    require('script/app/utils/scheduleActions'):runExpBar(
        self.praytabel[index].bar, 0.2, 1, tonumber(percent),function (lv)
        self.praytabel[index].bartx:setString((count%5)..'/'..'4')
        if needupdate then
            self:update()
        end
    end,nil)
    
end

function AltarMainUI:initState(node,index,num,awardIcon)
    local richText = xx.RichText:create()
    if UserData:getUserObj():getLv() < self.altarconf[index].level then
        -- self.praytabel[index].titlename:removeAllChildren()
         local str =string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN'),self.altarconf[index].level)
         if self.altarconf[index].level > 100 then
            str = ''
        end
        -- self.praytabel[index].titlename:setString(GlobalApi:getLocalStr('STR_JUNZHU')..str)
        -- self.praytabel[index].paraybtn:setEnabled(false)
        -- self.praytabel[index].paraybtn:setBright(false)
        -- self.praytabel[index].paraybtntx:enableOutline(cc.c3b(59,59,59),1)
        self.praytabel[index].infoimg:setVisible(false)
        self.praytabel[index].desctx:setString(str)
        self.praytabel[index].pl:setVisible(false)
        self.praytabel[index].numBgImg:setVisible(false)
    else
        self.praytabel[index].numBgImg:setVisible(true)
        self.praytabel[index].pl:setVisible(true)
        self.praytabel[index].desctx:setString('')
    end
    --self.praytabel[index].titlename:setString('')
    self.praytabel[index].paraybtn:setEnabled(true)
    self.praytabel[index].paraybtn:setBright(true)
    self.praytabel[index].paraybtntx:enableOutline(cc.c3b(165,70,6),1)
    self.praytabel[index].fastBtn:setEnabled(true)
    self.praytabel[index].fastBtn:setBright(true)
    self.praytabel[index].fastbtntx:enableOutline(cc.c3b(165,70,6),1)
    --node:setString(GlobalApi:getLocalStr('ATLAR_TITLE'..index))
    node:loadTexture('uires/ui/altar/'..self.altarconf[index].title)
    -- if index ~= 4 then  
        -- richText:setContentSize(cc.size(300,30))
        -- local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ATLAR_DESC3'), 30, COLOR_TYPE.WHITE)
        -- re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
        -- re1:setFont('font/gamefont.ttf')
        -- local re2 = xx.RichTextAtlas:create(num,"uires/ui/number/font_fightforce_2.png", 16, 20, '0')
        -- --re2:setStroke(COLOROUTLINE_TYPE.GREEN, 1)
        -- local re3 = xx.RichTextImage:create(awardIcon)
        -- re3:setScale(0.5)
        -- richText:addElement(re1)
        -- richText:addElement(re2)
        -- richText:addElement(re3)
        -- richText:setPosition(cc.p(0,5))
        -- richText:setVerticalAlignment('middle')
        -- richText:setCascadeOpacityEnabled(true)
        -- richText:setAlignment('middle')

        -- node:addChild(richText)
    -- else
    --     richText:setContentSize(cc.size(300,30))
    --     local re1 = xx.RichTextImage:create('uires/ui/text/altar_gemtitle.png')
    --     richText:addElement(re1)
    --     richText:setPosition(cc.p(0,0))
    --     richText:setAlignment('middle')
    --     richText:setCascadeOpacityEnabled(true)
    --     richText:setVerticalAlignment('middle')
    --     node:addChild(richText)
    -- end
    --return richText
end
function AltarMainUI:sendMsg(index,bg)
    local args = {
        type = index,
    }
    MessageMgr:sendPost('pray','altar',json.encode(args),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            GlobalApi:parseAwardData(awards)
            GlobalApi:showAwardsCommon(awards,true,nil,false)
            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            -- local showarr = {}
            local showWidgets = {}
            local displayobj = DisplayData:getDisplayObjs(awards)
            local nums = self.globalconf['altarRewardTime'].value --祭坛翻倍倍数
            local praybox = self.globalconf['altarRewardPrayCount'].value --祭坛翻倍奖励祈祷次数
            if displayobj[1] then    
                -- local num = 1
                -- local altar = UserData:getUserObj():getAltar()
                -- if altar[tostring(index)] and (altar[tostring(index)] + 1)%praybox == 0 then
                --     local popnum = 1
                --     num = praybox
                --     for index=1,num do
                --         local name = displayobj[1]:getName()..'*'..math.floor(displayobj[1]:getNum()/nums)
                --         local color = COLOR_TYPE.GREEN
                --         local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
                --         w:setTextColor(color)
                --         w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
                --         w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                --         table.insert(showWidgets, w)
                --         -- local att = {}
                --         -- att[1] = displayobj[1]:getName()..'*'..math.floor(displayobj[1]:getNum()/nums)
                --         -- att[2] = 'GREEN'
                --         -- showarr[popnum] = att
                --         -- popnum = popnum + 1
                --     end
                -- else
                --     local name = displayobj[1]:getName()..'*'..displayobj[1]:getNum()
                --     local color = COLOR_TYPE.GREEN
                --     local w = cc.Label:createWithTTF(name, 'font/gamefont.ttf', 24)
                --     w:setTextColor(color)
                --     w:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
                --     w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                --     table.insert(showWidgets, w)
                --     -- local att = {}
                --     -- att[1] = displayobj[1]:getName()..'*'..displayobj[1]:getNum()
                --     -- att[2] = 'GREEN'
                --     -- showarr[1] = att
                --end
                --promptmgr:showAttributeUpdate(showWidgets)
                -- local sz = bg:getContentSize()
                -- local x, y = bg:convertToWorldSpace(cc.p(sz.width / 2, sz.height/ 2))
                -- promptmgr:showAttributeUpdate(x, y, showarr)
                UserData:getUserObj():setAddAltar(index) 
            end
            local altar = UserData:getUserObj():getAltar()
            --print('math.floor(100*((altar[tostring(index)]%5)/4))..'..math.floor(100*((altar[tostring(index)]%5)/4)))
            self:updatelvbar(index,altar[tostring(index)],math.floor(100*((altar[tostring(index)]%5)/4)),true)
        end
    end)              
end

function AltarMainUI:sendAutoMsg(index,bg,num,cost,str)
    local function callBack()        
        local args = {
            type = index,
        }
        MessageMgr:sendPost('one_key','altar',json.encode(args),function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                local awards = data.awards
                GlobalApi:parseAwardData(awards)
                GlobalApi:showAwardsCommon(awards,true,nil,false)
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end
                -- local showarr = {}
                local showWidgets = {}
                local displayobj = DisplayData:getDisplayObjs(awards)
                local nums = self.globalconf['altarRewardTime'].value --祭坛翻倍倍数
                local praybox = self.globalconf['altarRewardPrayCount'].value --祭坛翻倍奖励祈祷次数
                if displayobj[1] then    
                    UserData:getUserObj():setAddAltar(index,num) 
                end
                local altar = UserData:getUserObj():getAltar()
                print('=======================',num,altar[tostring(index)])
                self:updatelvbar(index,altar[tostring(index)],math.floor(100*((altar[tostring(index)]%5)/4)),true)
            end
        end)        
    end      

    --[[local str = str
    UserData:getUserObj():cost('cash',cost,function()
        callBack()
    end,true,str)
    --]]
    promptmgr:showMessageBox(str,MESSAGE_BOX_TYPE.MB_OK_CANCEL,
	    function ()
            local userCash = UserData:getUserObj():getCash()
            if userCash >= cost then
                callBack()
            else
                UserData:getUserObj():cost('cash',cost,function()
                    callBack()
                end,true,str)
            end
	    end)

end
return AltarMainUI