local GemUpgradeUI = class("GemUpgradeUI", BaseUI)
local ClassGemObj = require('script/app/obj/gemobj')
local MAXDELTA = 0.5

function GemUpgradeUI:ctor(gid,slotIndex, equipObj, callback)
    self.uiIndex = GAME_UI.UI_GEMUPGRADE
    self.equipObj = equipObj or nil
    self.callback = callback or nil
    self.slotIndex = slotIndex or 0
    if gid > 0 then
        self.gid = gid
    else
        local equipGems = self.equipObj:getGems()
        local gem = equipGems[self.slotIndex]
        self.gid = gem:getId()
    end
end

function GemUpgradeUI:init()
    local gemSelectBgImg = self.root:getChildByName("bg_img")
    local gemSelectImg = gemSelectBgImg:getChildByName("bg_alpha")
    self:adaptUI(gemSelectBgImg, gemSelectImg)
    local gemSelect = gemSelectImg:getChildByName("bg_img1")
    -- local goldBgImg =gemSelect:getChildByName('gold_bg_img')
    -- local infoTx =goldBgImg:getChildByName('info_tx')
    -- infoTx:setString(GlobalApi:getLocalStr('HAD_GOLD'))
    -- self.numTx =goldBgImg:getChildByName('num_tx')
    self.closeBtn = gemSelect:getChildByName("close_btn")
    self.closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self:hideUI()
        end
    end)

    local helpBtn = HelpMgr:getBtn(19)
    helpBtn:setPosition(cc.p(40 ,gemSelect:getContentSize().height - 40))
    gemSelect:addChild(helpBtn)

    local titlebg  = gemSelect:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('GEMUPGRADE'))
    local svBg = gemSelect:getChildByName("scroll_bg_img")
    self.svBg = svBg
    --local titlebg = gemSelect:getChildByName('title_left_img')
    -- local desc1 = svBg:getChildByName('desc_tx1')
    -- desc1:setString(GlobalApi:getLocalStr('GEMUPGERADE_DESC1'))
    local desc2 = svBg:getChildByName('desc_tx2')
    desc2:setScale(0.9)
    desc2:setString(GlobalApi:getLocalStr('GEMUPGERADE_DESC2'))
    self.lowpl = gemSelect:getChildByName('low_pl')
    self.lvbtn = self.lowpl:getChildByName('lvup_btn')
    local lvupbtntx = self.lvbtn:getChildByName('func_tx')
    lvupbtntx:setString(GlobalApi:getLocalStr('UPGRADE'))
    self.lvbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
        end       
        if eventType ==  ccui.TouchEventType.ended then
            local gemconf = GameData:getConfData("gem")[self.gid]
            local award = DisplayData:getDisplayObj(gemconf.cost[1])
            if (self.needgold + award:getNum()) <= UserData:getUserObj():getGold() then
                self.num = 1
                self.time = GlobalData:getServerTime()
                GlobalApi:setRandomSeed(self.time%10000)
                self.istouch = false
                self:calFunction()
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
                return
            end

        end
    end)

    -- self.goldbg = gemSelect:getChildByName('gold_bg')
    local goldbg = self.lowpl:getChildByName('gold_bg')
    self.goldnum1 = goldbg:getChildByName('gold_tx')
    self.gemname = svBg:getChildByName('name_tx')
    local gemselbg = svBg:getChildByName('gemsel_bg')
    self.gembg = svBg:getChildByName('gem_bg')
    self.gemicon = self.gembg:getChildByName('gem_icon')
    --self.gemframe = self.gembg:getChildByName('gem_frame')
    local barbg = svBg:getChildByName('bar_bg')
    self.expbar = barbg:getChildByName('bar')
    self.exptx = self.expbar:getChildByName('bar_tx')
    self.luck = 0   --幸运值
    self.tid = 0    --宝石目标等级
    self.time = 0   --时间
    self.needgold = 0 --需要的金币
    self.eid = 0 --装备ID
    self.index = 0 --点击的索引
    self.istouch = false 
    self.tiemdelta = 0
    self.cgid = 0 --消耗的宝石ID
    self.maxluck = 0 --当前必升级幸运值

    self.num = 0  --数量
    self.heightpl = gemSelect:getChildByName('height_pl')
    local goldbg = self.heightpl:getChildByName('gold_bg')
    self.goldnum2 = goldbg:getChildByName('gold_tx')
    self.gemarr = {}
    for i=1,3 do
        local arr = {}
        local gemarrbg = self.heightpl:getChildByName('gem_'..i..'_bg')
        local eatBtn = gemarrbg:getChildByName('eat_btn')
        local infoTx = eatBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('GEM_EAT_ALL'))
        eatBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType ==  ccui.TouchEventType.ended then
                self.index = i
                local gemconf = GameData:getConfData("gem")[self.gid]
                local gemtype =  math.floor(self.gid/100)
                local costarr = self:getCostGemArr(gemconf.costQuality, gemtype)
                local gemobj = BagData:getGemById(costarr[i].id)
                if not gemobj then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                    return
                end
                if not self.equipObj and self.gid == costarr[i].id then
                    if gemobj:getNum() <= 1 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                        return
                    end
                end

                local oldluck = UserData:getUserObj():getLuck()
                local isUp,num,newLuck,costGoldNum,goldNotEnough = gemobj:eatAll(self.gid,self.equipObj)
                if goldNotEnough then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
                    return
                end
                self.cgid = gemobj:getId()
                self.num = num
                self.luck = newLuck
                self.time = GlobalData:getServerTime()
                if isUp then
                    self.tid = gemconf['getGem']
                else
                    self.tid = self.gid
                end
                self:lvUpPost(function()
                    local str = string.format(GlobalApi:getLocalStr('LVUP_FAIL3'),newLuck-oldluck)
                    promptmgr:showSystenHint(str,COLOR_TYPE.YELLOW)
                end)
            end
        end) 
        gemarrbg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                self.closeBtn:setTouchEnabled(false)
                self.index = i
                local gemconf = GameData:getConfData("gem")[self.gid]
                local award = DisplayData:getDisplayObj(gemconf.cost[1])
                if (self.needgold + award:getNum()) <= UserData:getUserObj():getGold() then
                    self.istouch = true
                    self.tiemdelta = 0
                    self.time = GlobalData:getServerTime()
                    GlobalApi:setRandomSeed(self.time%10000)
                else
                    return
                end
            elseif eventType ==  ccui.TouchEventType.canceled then
                self.closeBtn:setTouchEnabled(true)
                self.istouch = false
                self:calFunction()
            elseif eventType ==  ccui.TouchEventType.ended then
                self.closeBtn:setTouchEnabled(true)
                self.istouch = false
                self:calFunction()
            end
        end) 
        arr.bg = gemarrbg
        arr.icon = gemarrbg:getChildByName('gem_icon')
        arr.numtx = gemarrbg:getChildByName('gem_num')
        arr.entx = gemarrbg:getChildByName('gem_en')
        arr.nametx = gemarrbg:getChildByName('name_tx')
        self.gemarr[i] = arr
    end
    self.maxpl = gemSelect:getChildByName('max_pl')
    self.root:scheduleUpdateWithPriorityLua(function (dt)
            self:updatepush(dt)
        end, 0)
    if self.equipObj then
        self.eid = self.equipObj:getSId()
    end
    self.luck = UserData:getUserObj():getLuck()
    self:update()
end

function GemUpgradeUI:update()
    local gemconf = GameData:getConfData("gem")[self.gid]
    if gemconf then
        self.gemicon:loadTexture("uires/icon/gem/" .. gemconf['icon'])
        self.gembg:loadTexture(COLOR_FRAME[gemconf['color']])
        self.gemname:setTextColor(COLOR_QUALITY[gemconf['color']])
        self.gemname:setString(gemconf['name'])
        self.tid = self.gid
        local percent =string.format("%.2f", (UserData:getUserObj():getLuck()/gemconf['levelUpLucky'])*100)
        self.expbar:setPercent(percent)
        self.exptx:setString(GlobalApi:getLocalStr('GEMUPGERADE_VALUE') .. UserData:getUserObj():getLuck() ..'/' .. gemconf['levelUpLucky'])
        
        local award = DisplayData:getDisplayObj(gemconf.cost[1])
        self.goldnum1:setString(award:getNum())
        self.goldnum2:setString(award:getNum())
        if award:getOwnNum() < award:getNum() then
            self.ismaterialnumok  = false
            self.goldnum1:setTextColor(COLOR_TYPE.RED)
            self.goldnum2:setTextColor(COLOR_TYPE.RED)
        else
            self.goldnum1:setTextColor(COLOR_TYPE.WHITE)
            self.goldnum2:setTextColor(COLOR_TYPE.WHITE)
        end
        if tonumber(gemconf.costQuality) == 0 then
            self.svBg:setContentSize(cc.size(448,325))
            self.gemname:setPosition(cc.p(224,300))
            self.lowpl:setVisible(true)
            self.heightpl:setVisible(false)
            -- self.goldbg:setVisible(true)
            self.maxpl:setVisible(false)
        elseif gemconf['getGem'] == 0 then
            self.svBg:setContentSize(cc.size(448,325))
            self.gemname:setPosition(cc.p(224,300))
            self.maxpl:setVisible(true)
            -- self.goldbg:setVisible(false)
            self.lowpl:setVisible(false)
            self.heightpl:setVisible(false)
        else
            self.svBg:setContentSize(cc.size(448,275))
            self.gemname:setPosition(cc.p(224,253))
            self.lowpl:setVisible(false)
            self.maxpl:setVisible(false)
            self.heightpl:setVisible(true)
            -- self.goldbg:setVisible(true)
            local gemtype =  math.floor(self.gid/100)
            local costarr = self:getCostGemArr(gemconf.costQuality, gemtype)
            for i =1,3 do
                self.gemarr[i].bg:setVisible(false)
            end
            for i=1,#costarr do
                self.gemarr[i].icon:loadTexture("uires/icon/gem/" .. costarr[i].icon)
                self.gemarr[i].bg:loadTexture(COLOR_FRAME[costarr[i].color])
                self.gemarr[i].nametx:setString(costarr[i].name)
                self.gemarr[i].nametx:setTextColor(COLOR_QUALITY[costarr[i].color])
                self.gemarr[i].nametx:enableOutline(COLOROUTLINE_QUALITY,1)
                
                local gemobj = BagData:getGemById(costarr[i].id)
                self.gemarr[i].entx:setString('+'..self:getEnofGem(costarr[i].id))
                local num = 0
                if gemobj then
                    num = gemobj:getNum()
                end
                if not self.equipObj and self.gid == costarr[i].id then
                    num = ((num > 0 ) and num - 1) or num
                    self.gemarr[i].numtx:setString('x'..num)
                else
                    self.gemarr[i].numtx:setString('x'..num)
                end
                self.gemarr[i].bg:setVisible(true)
            end
        end
    end
end

function GemUpgradeUI:getCostGemArr(gemquality,gemtype)
    local gemconf = GameData:getConfData("gem")
    local gemarr = {}
    for k, v in pairs(gemconf) do
        if math.floor(v.id/100 ) == tonumber(gemtype) then
            if tonumber(v.quality) == tonumber(gemquality) then
                table.insert(gemarr, v)
            end
        end
    end
    table.sort(gemarr, function (a,b)
        return a.id < b.id
    end )
    return gemarr
end

function GemUpgradeUI:getEnofGem(id)
    local en = 0
    local gemconf = GameData:getConfData("gem")
    if gemconf[id] and gemconf[id].promoteLucky then
        en = gemconf[id].promoteLucky
    end
    return en
end
function GemUpgradeUI:updategemSingle(index,num,luck,maxluck,oldluck)
    if index > 0 then
        self.gemarr[index].numtx:setString(num)
    end
    local percent =string.format("%.2f", (luck/maxluck)*100)  
    self.expbar:setPercent(percent)
    self.exptx:setString(GlobalApi:getLocalStr('GEMUPGERADE_VALUE') .. luck ..'/' .. maxluck)
    if oldluck and luck - oldluck > 0 then
        local str = string.format(GlobalApi:getLocalStr('LVUP_FAIL3'),luck-oldluck)
        promptmgr:showSystenHint(str,COLOR_TYPE.YELLOW)
    end
end

function GemUpgradeUI:lvUpPost(callback)
    for i=1,3 do
        self.gemarr[i].bg:setTouchEnabled(false)
    end
    self.lvbtn:setTouchEnabled(false)
    self.istouch = false
    local args = {
        gid = self.gid,
        num = self.num,
        luck = self.luck,
        tgid = self.tid,
        eid = self.eid,
        time = self.time,
        cgid = self.cgid
    }
    MessageMgr:sendPost("upgrade_gem", "equip", json.encode(args), function (jsonObj)
        print(json.encode(jsonObj))
        local code = jsonObj.code
        if code == 0 then
            local awards = jsonObj.data.awards
            GlobalApi:parseAwardData(awards)
            local costs = jsonObj.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            if self.equipObj then
                local gemobj = ClassGemObj.new(self.tid, 1)
                self.equipObj:upgradeGem(self.slotIndex,gemobj)
            end
            local gemobj = ClassGemObj.new(self.tid, 1)
            self.lvbtn:setTouchEnabled(true)
            local isupgrade = false
            if self.tid ~= self.gid then
                isupgrade = true
            end
            self.gid = self.tid
            self:update()
            self.tid = 0
            self.time = 0
            self.num = 0
            self.needgold = 0
            self.index = 0 
            if isupgrade then
                local str = string.format(GlobalApi:getLocalStr('LVUP_SUCC'),gemobj:getName()..'X'..'1')
                promptmgr:showSystenHint(str,COLOR_TYPE.GREEN)
                if self.callback then
                    self.callback()
                end
            else
                if callback then
                    callback()
                end
            end
        else
            self.num = 0
            self.lvbtn:setTouchEnabled(true)
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL'),COLOR_TYPE.RED)
        end
        for i=1,3 do
            self.gemarr[i].bg:setTouchEnabled(true)
        end
        self.closeBtn:setTouchEnabled(true)     -- 防止这个heightpl隐藏后，bg接受不到取消和拖动结束事件，那closeBtn触摸一直是false,所以这里最后再设置一次
    end)
end

function GemUpgradeUI:updatepush(dt)
    self.tiemdelta = self.tiemdelta + dt 
    if self.istouch and self.tiemdelta > MAXDELTA then
        self:calFunction()
        self.tiemdelta = 0
    end
end

function GemUpgradeUI:calFunction()
    local rand = GlobalApi:random(0, 10000)
    local rand1 = GlobalApi:random(0, 10000)
    GlobalApi:setRandomSeed(rand1)
    local gemconf = GameData:getConfData("gem")[self.gid]
    local upgrade = false
    local extraProb = 0
    self.maxluck = gemconf['levelUpLucky']
    if gemconf then
        local award = DisplayData:getDisplayObj(gemconf.cost[1])
        local havenum  = 0
        if self.index > 0 then
            local gemtype =  math.floor(self.gid/100)
            local costarr = self:getCostGemArr(gemconf.costQuality, gemtype)
            local gemobj = BagData:getGemById(costarr[self.index].id)
            if gemobj then
                havenum = gemobj:getNum()
            end
            self.cgid = costarr[self.index].id
            if not self.equipObj and self.gid == self.cgid then
                havenum = ((havenum > 0 ) and havenum - 1) or havenum
            end
            local taggemconf = GameData:getConfData("gem")[self.cgid]
            extraProb = taggemconf['extraProb']
        end
        local award = DisplayData:getDisplayObj(gemconf.cost[1])
        self.goldnum1:setString(award:getNum())
        self.goldnum2:setString(award:getNum())
        if (self.needgold + award:getNum())<= UserData:getUserObj():getGold()
            and ((gemconf['costQuality'] > 0 and havenum-self.num > 0) or gemconf['costQuality'] == 0 ) then
            
            if self.index > 0 then
                self.num = self.num + 1
            end
            self.tid = self.gid
  
            self.needgold = self.needgold + award:getNum()

            if self.luck >= self.maxluck and self.needgold <= UserData:getUserObj():getGold() then
                if self.cgid and self.cgid > 0 then
                    local gemconf1 = GameData:getConfData("gem")[self.cgid]
                    self.luck = self.luck + gemconf1.promoteLucky

                else
                    self.luck = self.luck + gemconf.promoteLucky
                end
                upgrade = true
            elseif self.luck >= self.maxluck and self.needgold > UserData:getUserObj():getGold() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
                return
            else
                local chance = (gemconf['baseProb'] + extraProb)/100
                if rand/10000 < chance and self.needgold <= UserData:getUserObj():getGold() then
                    if self.cgid and self.cgid > 0 then
                        local gemconf1 = GameData:getConfData("gem")[self.cgid]
                        self.luck = self.luck + gemconf1.promoteLucky

                    else
                        self.luck = self.luck + gemconf.promoteLucky
                    end
                    upgrade = true
                elseif rand/10000 < chance and self.needgold > UserData:getUserObj():getGold() then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
                    return  
                else
                    local addluck =  0
                    if self.cgid > 0 then
                        local taggemconf = GameData:getConfData("gem")[self.cgid]
                        addluck = taggemconf['promoteLucky']
                    else
                        addluck = gemconf['basePromoteLucky']
                    end
                    local luck = clone(self.luck)
                    self.luck = self.luck + addluck
                    self:updategemSingle(self.index,havenum-self.num,self.luck,self.maxluck,luck )
                end                 
            end

            if self.luck >= self.maxluck then
                upgrade = true
            end
            if upgrade then
                self.tid = gemconf['getGem']
                self.luck = self.luck - self.maxluck
                if self.luck < 0 then
                    self.luck = 0
                end
                local taggemconf = GameData:getConfData("gem")[gemconf['getGem']]
                self.maxluck = taggemconf['levelUpLucky']
                self:lvUpPost()
            elseif self.index == 0 or (self.istouch ==false and self.index > 0) then
                self:lvUpPost()
            end
        else
            if self.num > 0 then
                self:lvUpPost()
            else
                if (self.needgold + award:getNum())<= UserData:getUserObj():getGold() then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'),COLOR_TYPE.RED)
                else
                     promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_GOLD_NOTENOUGH'),COLOR_TYPE.RED)
                end
                return
            end
        end
        self:updategemSingle(self.index,havenum-self.num,self.luck,self.maxluck )
    end
end

return GemUpgradeUI