local LegionActivityBoonUI = class("LegionActivityBoonUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function LegionActivityBoonUI:ctor(data)
    self.uiIndex = GAME_UI.UI_LEGIONACTIVITYBOONUI
    self.data = data
    self.lightarr = {}
    local legionconf = GameData:getConfData('legion')
    local awrads = legionconf['boonDropId'].value
    local dropconf = GameData:getConfData('drop')[tonumber(awrads)]
    self.maxNum = 0
    for i=1,10 do
        local str = 'award' ..i
        if dropconf[str] and dropconf[str][1] then
        self.maxNum = self.maxNum + 1
        end
    end
end

function LegionActivityBoonUI:onShow()
    self:update()
end
function LegionActivityBoonUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    local  basebg = bgimg2:getChildByName('bg_img1')
    local closebtn = basebg:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityBoonUI()
        end
    end)
    self:adaptUI(bgimg1, bgimg2)

    local bgimg3 = basebg:getChildByName('bg_img2')
    local bgimg4 = basebg:getChildByName('bg_img3')

    local awardbg = bgimg4:getChildByName('award_bg_img')
    self.itemtab  = {}
    for i=1,6 do
        local arr = {}
        arr.itembg = awardbg:getChildByName('node_'..i)
        self.itemtab[i] = arr
    end
    self.onebtn = bgimg3:getChildByName('one_btn')
    local onebtntx = self.onebtn:getChildByName('btn_tx')
    onebtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_BOON_ONE'))
    self.onebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if UserData:getUserObj():getBoon() > 0 then
                self:sendMsg(0)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_1'), COLOR_TYPE.RED)
            end
        end
    end)
    self.tenbtn = bgimg3:getChildByName('ten_btn')
    local tenbtntx = self.tenbtn:getChildByName('btn_tx')
    tenbtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_BOON_TEN'))
    self.tenbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if UserData:getUserObj():getBoon() >= 1 then
                self:sendMsg(1)
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_1'), COLOR_TYPE.RED)
            end
        end
    end)
    local talkbg = bgimg3:getChildByName('talk_bg_img')
    local talktx = talkbg:getChildByName('talk_tx')
    talktx:ignoreContentAdaptWithSize(false)
    talktx:setTextAreaSize(cc.size(150,80))
    talktx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_BOON_DESC'))
    local boonnumbg = bgimg4:getChildByName('boon_numbg')
    self.boonnumtx = boonnumbg:getChildByName('boon_num_tx')
    local nametx  = bgimg4:getChildByName('boon_name_tx')
    nametx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_BOON_AWARD_NAME'))
    local titlebg = basebg:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_BOON_TITLE'))
    self:update()
end

function LegionActivityBoonUI:update()
    local legionconf = GameData:getConfData('legion')
    local awrads = legionconf['boonDropId'].value
    local dropconf = GameData:getConfData('drop')[tonumber(awrads)]
    for i=1,self.maxNum do
        local str = 'award' ..i
        if dropconf[str] and dropconf[str][1] then
            local displayobj = DisplayData:getDisplayObj(dropconf[str][1])
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj, self.itemtab[i].itembg)
            local effect = GlobalApi:createLittleLossyAniByName('sign_light')
            local awardsize = tab.awardBgImg:getContentSize()
            effect:setPosition(cc.p(awardsize.width/2,awardsize.height/2))
            effect:getAnimation():playWithIndex(0, -1, -1)
            effect:setTag(9527)
            effect:setVisible(false)
            effect:setScale(1.25)
            self.lightarr[i] = effect
            tab.awardBgImg:addChild(effect)
        end
    end
    self.boonnumtx:setString(UserData:getUserObj():getBoon())
end

function LegionActivityBoonUI:sendMsg(ntype)
    local obj = {
        type = ntype
    }
    MessageMgr:sendPost('use_boon','legion',json.encode(obj),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            local awards = data.awards
            if awards then
                GlobalApi:parseAwardData(awards)
                local pos = self:getLastPos(awards)
                self:showLight(3, pos, awards) 
            end

            local costs = data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
               
        end
    end)  
end

function LegionActivityBoonUI:lockBtn()
    self.onebtn:setTouchEnabled(false) 
    self.tenbtn:setTouchEnabled(false)
end

function LegionActivityBoonUI:unlockBtn()
    self.onebtn:setTouchEnabled(true) 
    self.tenbtn:setTouchEnabled(true)
end

-- awardtype = 1 单一奖励   awardtype = 2 多个奖励
function LegionActivityBoonUI:showLight(turns, target, awards)
    self:lockBtn()
    local actiontab = {}
    for i = 1, self.maxNum do
        self.lightarr[i]:setVisible(false)
    end
    local time1 = CCDelayTime:create(0.3)
    local time2 = CCDelayTime:create(0.2)
    local fun3 = CCCallFunc:create(function ()
        GlobalApi:showAwardsCommon(awards,true,nil,false)
        for i = 1, self.maxNum do
            self.lightarr[i]:setVisible(false)
        end
        self:unlockBtn()
        self:update()
    end)
    for j = 1, turns do
        for i = 1, self.maxNum do
            local fun1 = CCCallFunc:create(function() 
                self.lightarr[i]:setVisible(true)
             end)

            local fun2 = CCCallFunc:create(function()
                self.lightarr[i]:setVisible(false)
            end)
         
            if j < turns then 
                table.insert( actiontab, fun1)
                table.insert( actiontab, time2)
                table.insert( actiontab, fun2)
            elseif j >= turns then
                if i > target then
                   table.insert( actiontab, fun2)
                elseif i == target then
                    table.insert( actiontab, fun1)
                    table.insert( actiontab, time1)
                    table.insert( actiontab, fun3)
                else
                    table.insert( actiontab, fun1)
                    table.insert( actiontab, time1)
                    table.insert( actiontab, fun2)
                end
            end
            self.lightarr[i]:runAction(CCSequence:create(actiontab))
        end
    end
end

function LegionActivityBoonUI:getLastPos(awards)
   -- printall(awards[#awards])
    local pos = 1
    local legionconf = GameData:getConfData('legion')
    local awrads = legionconf['boonDropId'].value
    local dropconf = GameData:getConfData('drop')[tonumber(awrads)]
    for i=1,self.maxNum do
        local str = 'award' ..i
        local displayobj = DisplayData:getDisplayObj(dropconf[str][1])
        if tostring(awards[#awards][1]) == tostring(dropconf[str][1][1]) 
            and tostring(awards[#awards][2]) == tostring(dropconf[str][1][2])
            and tostring(awards[#awards][3]) == tostring(dropconf[str][1][3]) then
            pos = i
            break
        end
    end
    return pos
end
return LegionActivityBoonUI