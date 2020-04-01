local WorldWarMySupportUI = class("WorldWarMySupportUI", BaseUI)

function WorldWarMySupportUI:ctor(top32,records,replays)
	self.uiIndex = GAME_UI.UI_WORLDWARMYSUPPORT
    self.infoTxs = {}
    self.infoRts = {}
    self.records = records
    self.top32 = top32
    self.replays = replays
end

function WorldWarMySupportUI:getProgressInfo(progressNum,i)
    local desc = ''
    local isEnd = false
    local recordsIndex = {0,0}
    local index = 0
    if progressNum == 1 then
        desc = '16'..GlobalApi:getLocalStr('KNOCK_QIANG')
        isEnd = WorldWarMgr.progress ~= 'sup_16'
        recordsIndex = {1,16}
        index = (i - 1 - (i - 1)%2)/2 + 1
    elseif progressNum == 2 then
        desc = '8'..GlobalApi:getLocalStr('KNOCK_QIANG')
        isEnd = WorldWarMgr.progress ~= 'sup_8'
        recordsIndex = {17,24}
        index = 16 + (i - 1 - (i - 1)%4)/4 + 1
    elseif progressNum == 3 then
        desc = '4'..GlobalApi:getLocalStr('KNOCK_QIANG')
        isEnd = WorldWarMgr.progress ~= 'sup_4'
        recordsIndex = {25,28}
        index = 24 + (i - 1 - (i - 1)%8)/8 + 1
    elseif progressNum == 4 then
        desc = '2'..GlobalApi:getLocalStr('KNOCK_QIANG')
        isEnd = WorldWarMgr.progress ~= 'sup_2'
        recordsIndex = {29,30}
        index = 28 + (i - 1 - (i - 1)%16)/16 + 1
    elseif progressNum == 5 then
        desc = '1'..GlobalApi:getLocalStr('KNOCK_QIANG')
        isEnd = WorldWarMgr.progress ~= 'sup_1'
        recordsIndex = {31,31}
        index = 31
    end
    return desc,index,recordsIndex
end

function WorldWarMySupportUI:updatePanel()
    -- WorldWarMgr:getProgressInfo(style)
    local supportData = WorldWarMgr.supportData--[tostring(WorldWarMgr.count)]
    local index = 0
    local tab = {'16','8','4','2','1'}
    for i=1,5 do
        if supportData[tab[i]] then
            index = index + 1
            local player = WorldWarMgr:getPlayerById(supportData[tab[i]][1],self.top32)
            local desc,index1,recordsIndex = self:getProgressInfo(i,player.index)
            self.infoTxs[index]:setString(desc)
            local height = self.infoTxs[index]:getPositionY()
            if not self.infoRts[index] then
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(520, 30))
                -- richText:setAlignment('right')
                local re = xx.RichTextLabel:create('',21,COLOR_TYPE.WHITE)
                re:setStroke(COLOR_TYPE.BLACK, 1)
                local re1 = xx.RichTextLabel:create('',21,COLOR_TYPE.RED)
                re1:setStroke(COLOROUTLINE_TYPE.RED, 1)
                local re2 = xx.RichTextLabel:create('',21,COLOR_TYPE.WHITE)
                re2:setStroke(COLOR_TYPE.BLACK, 1)
                local re3 = xx.RichTextLabel:create('',21,COLOR_TYPE.YELLOW)
                re3:setStroke(COLOROUTLINE_TYPE.YELLOW, 1)
                richText:addElement(re)
                richText:addElement(re1)
                richText:addElement(re2)
                richText:addElement(re3)
                richText:setAnchorPoint(cc.p(0,0.5))
                richText:setPosition(cc.p(172,height))
                self.bgImg:addChild(richText)
                self.infoRts[index] = {richText = richText,re = re,re1 = re1,re2 = re2,re3 = re3}
            end
            if WorldWarMgr.records[index1] and WorldWarMgr.records[index1] ~= -1 then
                if  WorldWarMgr.records[index1] + 1 == player.index then
                    local num = tonumber(supportData[tab[i]][2])
                    self.infoRts[index].re:setString(player.name..string.format(GlobalApi:getLocalStr('FU_1'),player.sid))
                    self.infoRts[index].re1:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC24'))
                    self.infoRts[index].re2:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC25'))
                    self.infoRts[index].re3:setString(num)
                    self.infoRts[index].richText:format(true)
                else
                    self.infoRts[index].re:setString(player.name..string.format(GlobalApi:getLocalStr('FU_1'),player.sid))
                    self.infoRts[index].re1:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC26'))
                    self.infoRts[index].re2:setString(GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC27'))
                    self.infoRts[index].re3:setString('')
                    self.infoRts[index].richText:format(true)
                end
            else
                self.infoRts[index].re:setString(player.name..string.format(GlobalApi:getLocalStr('FU_1'),player.sid))
                self.infoRts[index].re1:setString('')
                self.infoRts[index].re2:setString('')
                self.infoRts[index].re3:setString('')
                self.infoRts[index].richText:format(true)
            end
        end
    end
    self.times:setString(string.format(GlobalApi:getLocalStr('HAD_SUPPORT_TIMES'),index))
end

function WorldWarMySupportUI:init()
    local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn1 = worldwarImg:getChildByName("close_1_btn")
	local closeBtn = worldwarImg:getChildByName("close_btn")
    local infoTx = closeBtn1:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('CLOSE_1'))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideMySupport()
        end
    end)
    closeBtn1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideMySupport()
        end
    end)

    local titleBgImg = worldwarImg:getChildByName('title_bg_img')
    local titleTx = titleBgImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('MY_SUPPORT'))

    self.bgImg = worldwarImg:getChildByName('bg_img')
    for i=1,5 do
        local infoTx = self.bgImg:getChildByName('info_'..i..'_tx')
        self.infoTxs[i] = infoTx
    end
    self.times = self.bgImg:getChildByName('times_tx')

    local roundTx = self.bgImg:getChildByName('round_tx')
    infoTx = self.bgImg:getChildByName('info_tx')
    roundTx:setString(GlobalApi:getLocalStr('ROUND'))
    infoTx:setString(GlobalApi:getLocalStr('SUPPORT_INFO'))

    self:updatePanel()
end

return WorldWarMySupportUI