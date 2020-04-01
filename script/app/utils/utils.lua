cc.exports.Utils = {
    
}
-- timeShowType显示规则，timeShowType存在并且为2：显示m,s；timeShowType存在并且为1：显示s；timeShowType不存在显示nil
function Utils:createCDLabel(richtext, time,timecolor,timeoutlencolor,postype,str,stringcolor,stringoutlencolor,fontsize, callback,timeShowType,noStroke,shadow)
    local cdLabel = {}

    timecolor = timecolor or COLOR_TYPE.WHITE
    timeoutlencolor = timeoutlencolor  or COLOROUTLINE_TYPE.WHITE
    stringcolor = stringcolor or COLOR_TYPE.ORANGE
    stringoutlencolor = stringoutlencolor  or COLOROUTLINE_TYPE.ORANGE
    str = str or ''
    postype = postype or CDTXTYPE.NONE
    local label1visible = true
    local label2visible = true
    local scheduler = richtext:getScheduler()
    time = time + 1
    local schedulerEntry = nil
    local pauseFlag = false
    local function getTime(time1)
        local h = string.format("%02d", math.floor(time1/3600))
        local m = string.format("%02d", math.floor(time1%3600/60))
        local s = string.format("%02d", math.floor(time1%3600%60%60))
            
        if timeShowType == 1 then
            return string.format("%d", math.floor(time1%3600%60%60))
        elseif timeShowType == 2 then
            return m..':'..s
        elseif timeShowType == 3 then
            return string.format(GlobalApi:getLocalStr('STR_TIME7'),h,m,s)
        elseif timeShowType == 4 then
            local day = string.format("%02d", math.floor(h/24))
            local hour = string.format("%02d", math.floor(h%24))
            return string.format(GlobalApi:getLocalStr('STR_TIME8'),day,hour,m,s)
        elseif timeShowType == 5 then
            return h..':'..m
        else
            return h..':'..m..':'..s
        end
    end
    local function  labelinfo()
        if richtext then
            local label1 = richtext:getChildByTag(9527)
            if not label1 then
                label1 = cc.Label:createWithTTF("", "font/gamefont.ttf", fontsize or 20)
                label1:setTag(9527)
                label1:setAnchorPoint(cc.p(0,0.5))
                if postype == CDTXTYPE.FRONT  then
                    label1:setString(str)
                    label1:setTextColor(stringcolor)
                    label1:enableOutline(stringoutlencolor, not noStroke and 1 or 0)
                    label1:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
                    label1:setPosition(cc.p(-label1:getContentSize().width,0))
                elseif postype == CDTXTYPE.BACK then
                    label1:setString(getTime(time))
                    label1:setTextColor(timecolor)
                    label1:enableOutline(timeoutlencolor, not noStroke and 1 or 0)
                    label1:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
                    label1:setPosition(cc.p(-label1:getContentSize().width,0))
                elseif postype == CDTXTYPE.NONE then
                    label1:setString(getTime(time))
                    label1:setTextColor(timecolor)
                    label1:enableOutline(timeoutlencolor, not noStroke and 1 or 0)
                    label1:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
                    label1:setPosition(cc.p(-label1:getContentSize().width/2,0))
                end
                richtext:addChild(label1)
            end
            local label2 = richtext:getChildByTag(9528)
            if not label2 then
                label2 = cc.Label:createWithTTF("", "font/gamefont.ttf", fontsize or 20)
                label2:setTag(9528)

                label2:setAnchorPoint(cc.p(0,0.5))
                if postype == CDTXTYPE.FRONT  then
                    label2:setString(' ' .. getTime(time))
                    label2:setTextColor(timecolor)
                    label2:enableOutline(timeoutlencolor, not noStroke and 1 or 0)
                    label2:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
                    label2:setPosition(cc.p(0,0))
                elseif postype == CDTXTYPE.BACK then
                    label2:setString(' ' .. str)
                    label2:setTextColor(stringcolor)
                    label2:enableOutline(stringoutlencolor, not noStroke and 1 or 0)
                    label2:enableShadow(GlobalApi:getLabelCustomShadow(shadow or ENABLESHADOW_TYPE.NORMAL))
                    label2:setPosition(cc.p(0,0))
                elseif postype == CDTXTYPE.NONE then
                end
                richtext:addChild(label2)
            end
            label1:setVisible(label1visible)
            label2:setVisible(label2visible)
            if postype == CDTXTYPE.FRONT  then
                label1:setString(str)
                label2:setString(' ' .. getTime(time))
            elseif postype == CDTXTYPE.BACK  then
                label1:setString(getTime(time))
                label2:setString(' ' .. str)
            elseif postype == CDTXTYPE.NONE then
                label1.time = time
                label1:setString(getTime(time))
                label2:setString('')
            end
        end
    end

    local function step(dt)
        time = time - dt
        if time <= 0 then
            if schedulerEntry ~= 0 then
                scheduler:unscheduleScriptEntry(schedulerEntry)
                schedulerEntry = 0
            end
            if callback then
                callback()
            end
            return
        end
        labelinfo()
    end
    local function onNodeEvent(event)
        if event == "exit" then
            callback = nil
            if schedulerEntry ~= 0 then
                scheduler:unscheduleScriptEntry(schedulerEntry)
                schedulerEntry = 0
            end
        end
    end
    richtext:registerScriptHandler(onNodeEvent)
    labelinfo()
    schedulerEntry = scheduler:scheduleScriptFunc(step, 1, false)

    function cdLabel:pause()
        if schedulerEntry ~= 0 then
            scheduler:unscheduleScriptEntry(schedulerEntry)
            schedulerEntry = 0
        end
    end

    function cdLabel:continue()
        if schedulerEntry == 0 then
            schedulerEntry = scheduler:scheduleScriptFunc(step, 1, false)
        end
    end

    function cdLabel:setTime(newTime)
        time = newTime + 1
        if schedulerEntry == 0 then
            schedulerEntry = scheduler:scheduleScriptFunc(step, 1, false)
        end
    end

    function cdLabel:setString(newstr)
        str = newstr
    end

    function cdLabel:setVisible(visible)
        label1visible = visible
        label2visible = visible
    end

    return cdLabel
end