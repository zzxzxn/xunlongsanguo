local PatrolSpeedUI = class("PatrolSpeedUI", BaseUI)
	
function PatrolSpeedUI:ctor(callback)
	self.uiIndex = GAME_UI.UI_PATROL_SPEED
    self.callback = callback
end

function PatrolSpeedUI:init()
	local bgImg = self.root:getChildByName("patrol_bg_img")
	local patrolImg = bgImg:getChildByName("patrol_img")
    self:adaptUI(bgImg, patrolImg)
    local closeBtn = patrolImg:getChildByName("close_btn")

    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MapMgr:hidePatrolSpeedPanel()
        end
    end)

    local cityNameTx = patrolImg:getChildByName("city_name_tx")
    cityNameTx:setString(GlobalApi:getLocalStr('ACCELERATE_PATROL'))
    local size = patrolImg:getContentSize()
    local richText = xx.RichText:create()
    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:setContentSize(cc.size(680, 30))
    local obj = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue('patrolMaterial')))
    local num = 0
    if obj then
        num = obj:getNum()
    end
    local tx1,tx2,re2
    if num <= 0 then
        tx1 = string.format(GlobalApi:getLocalStr('STR_ACCELERATE_DESC'),tonumber(GlobalApi:getGlobalValue('patrolCost')))
        re2 = xx.RichTextImage:create('uires/ui/res/res_cash.png')
    else
        tx1 = string.format(GlobalApi:getLocalStr('STR_ACCELERATE_DESC'),1)
        re2 = xx.RichTextImage:create('uires/ui/expedition/expedition_jiasuguajiling.png')
    end
    local tx2 = GlobalApi:getLocalStr('ACCELERATE_PATROL')..'?'
    local re1 = xx.RichTextLabel:create(tx1, 25, COLOR_TYPE.ORANGE)
    local re3 = xx.RichTextLabel:create(tx2, 25, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setAnchorPoint(cc.p(0.5,0.5))
    richText:setPosition(cc.p(size.width/2,295))
    patrolImg:addChild(richText)

    local vip = UserData:getUserObj():getVip()
    local conf = GameData:getConfData("vip")[tostring(vip)]
    local times = conf.patrol - MapData.patrolAccelerate
    local richText1 = xx.RichText:create()
    richText1:setContentSize(cc.size(360, 30))
    local tx11 = GlobalApi:getLocalStr('REMAINDER_PATROL_TIMES')
    local tx22 = tostring(times)
    local tx33 = GlobalApi:getLocalStr('TIMES')
    local re11 = xx.RichTextLabel:create(tx11, 25, COLOR_TYPE.ORANGE)
    local re22 = xx.RichTextLabel:create(tx22, 25, COLOR_TYPE.WHITE)
    local re33 = xx.RichTextLabel:create(tx33, 25, COLOR_TYPE.ORANGE)
    re11:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re22:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re33:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    richText1:addElement(re11)
    richText1:addElement(re22)
    richText1:addElement(re33)

    richText1:setAnchorPoint(cc.p(0.5,0.5))
    richText1:setPosition(cc.p(size.width/2,250))
    patrolImg:addChild(richText1)

    local label = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    label:setString(GlobalApi:getLocalStr('UP_PATROL_TIMES'))
    label:setColor(COLOR_TYPE.GREEN)
    label:enableOutline(COLOROUTLINE_TYPE.GREEN, 1)
    label:setPosition(cc.p(size.width/2, size.height*2/5 - 15))
    patrolImg:addChild(label)

    local okBtn = patrolImg:getChildByName("ok_btn")
    local infoTx = okBtn:getChildByName("info_tx")
    infoTx:setString(GlobalApi:getLocalStr('BEGIN'))
    okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local vip = UserData:getUserObj():getVip()
            local conf = GameData:getConfData("vip")[tostring(vip)]
            local times = conf.patrol - MapData.patrolAccelerate
            local obj = BagData:getMaterialById(tonumber(GlobalApi:getGlobalValue('patrolMaterial')))
            local needCash = tonumber(GlobalApi:getGlobalValue('patrolCost'))
            local num = 0
            if obj then
                num = obj:getNum()
                if num > 0 then
                    needCash = 0
                end
            end
            if num <= 0 then
                if times <= 0 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_PATROL_MAX_TIMES'), COLOR_TYPE.RED)
                    return
                end
            end
            if BagData:getEquipFull() then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('BAG_REACHED_MAX_AND_FUSION'), COLOR_TYPE.RED)
                return
            end
            local function callback()
                local args = {}
                MessageMgr:sendPost('patrol_accelerate','battle',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local lastLv = UserData:getUserObj():getLv()

                        MapMgr:hidePatrolSpeedPanel()
                        local awards = data.awards
                        local gold_xp = data.gold_xp
                        if #awards > 0 then
                            MapMgr:showPatrolAwardsPanel(awards,7200)
                        end
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:parseAwardData(gold_xp)
                        local costs = data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end
                        if needCash > 0 then
                            MapData.patrolAccelerate = MapData.patrolAccelerate + 1
                        end

                        local nowLv = UserData:getUserObj():getLv()
                        GlobalApi:showKingLvUp(lastLv,nowLv)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_PATROL_MAXTIME'), COLOR_TYPE.RED)
                    end
                end)
            end
            if needCash > 0 then
                UserData:getUserObj():cost('cash',needCash,function()
                    promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('NEED_CASH'),needCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                        callback()
                    end)
                end)
            else
                callback()
            end
        end
    end)

end

return PatrolSpeedUI