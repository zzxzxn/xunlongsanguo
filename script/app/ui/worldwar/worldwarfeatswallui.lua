local WorldWarFeatsWallUI = class("WorldWarFeatsWallUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function WorldWarFeatsWallUI:ctor(data)
    self.uiIndex = GAME_UI.UI_WORLDWARFEATSWALL
    self.data = data
    self.page = 1
    self.awardImgs = {}
    self.conf = GameData:getConfData('exploitwall')
end

function WorldWarFeatsWallUI:getData(page)
    local num,got
    local conf = clone(self.conf[page])
    num = self.data.exploit[conf[1].key]
    got = self.data.reward[conf[1].key] or {}
    if page == 2 or page == 4 then
        for i,v in ipairs(conf) do
            conf[i].status = got[tostring(i)] or 0
            conf[i].index = i
            if got[tostring(i)] and got[tostring(i)] == 1 then
                conf[i].canGet = 2
            elseif  num <= v.target and num ~= 0 then
                conf[i].canGet = 0
            else
                conf[i].canGet = 1
            end
        end
    else
        for i,v in ipairs(conf) do
            conf[i].status = got[tostring(i)] or 0
            conf[i].index = i
            if got[tostring(i)] and got[tostring(i)] == 1 then
                conf[i].canGet = 2
            elseif  num >= v.target then
                conf[i].canGet = 0
            else
                conf[i].canGet = 1
            end
        end
    end
    table.sort(conf,function(a,b)
        if a.canGet == b.canGet then
            return a.rank < b.rank
        end
        return a.canGet < b.canGet
    end )
    return num,conf
end

function WorldWarFeatsWallUI:updateNewImgs()
    local canGet = 0
    for i=1,5 do
        local num,conf = self:getData(i)
        local isNew = false
        for j,v in ipairs(conf) do
            if v.canGet == 0 then
                isNew = true
                canGet = 1
                break
            end
        end
        self.newImgs[i]:setVisible(isNew)
    end
    UserData:getUserObj():setSignByType('exploit_wall',canGet)
end

function WorldWarFeatsWallUI:updateCell()
    local num,conf = self:getData(self.page)
    local bottomImg1 = self.bgImg:getChildByName('bottom_img_1')
    local descTx = bottomImg1:getChildByName('desc_tx')
    local sv = bottomImg1:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local str = ''
    if conf[1].cycle > 1 then
        str = conf[1].cycle
    end
    descTx:setString(GlobalApi:getLocalStr('FEATS_WALL_TITLE_'..self.page)..
        string.format(GlobalApi:getLocalStr("FEATS_WALL_DESC"),str))
    local size1
    for i,v in ipairs(conf) do
        local bgImg = sv:getChildByName('cell_bg_img_'..i)
        if not bgImg then
            local cellNode = cc.CSLoader:createNode("csb/worldwarfeatswallcell.csb")
            bgImg = cellNode:getChildByName('bg_img')
            bgImg:removeFromParent(false)
            bgImg:setName('cell_bg_img_'..i)
            sv:addChild(bgImg)
        end
        size1 = bgImg:getContentSize()
        bgImg:setPosition(cc.p(3,(size1.height + 5)* (#conf - i)))
        bgImg:setVisible(true)
        local titleTx = bgImg:getChildByName('title_tx')
        local titleTx1 = bgImg:getChildByName('title_tx_1')
        local getBtn = bgImg:getChildByName('get_btn')
        local infoTx = getBtn:getChildByName('info_tx')
        local newImg = getBtn:getChildByName('new_img')
        local getImg = bgImg:getChildByName('get_img')
        titleTx:setString(v.desc)
        infoTx:setString(GlobalApi:getLocalStr("STR_GET_1"))
        if self.page == 4 then
            if v.canGet == 2 or v.canGet == 0 then
                titleTx1:setString('(1/1)')
            else
                titleTx1:setString('(0/1)')
            end
        else
            titleTx1:setString('('..num..'/'..v.target..')')
        end
        if v.canGet == 2 then
            getBtn:setVisible(false)
            getImg:setVisible(true)
            getImg:loadTexture('uires/ui/activity/yilingq.png')
            titleTx1:setColor(COLOR_TYPE.GREEN)
        elseif v.canGet == 0 then
            self.newImgs[self.page]:setVisible(true)
            getBtn:setVisible(true)
            getImg:setVisible(false)
            titleTx1:setColor(COLOR_TYPE.GREEN)
        else
            getBtn:setVisible(false)
            getImg:setVisible(true)
            getImg:loadTexture('uires/ui/activity/weidac.png')
            titleTx1:setColor(COLOR_TYPE.RED)
        end
            
        local size = titleTx:getContentSize()
        local posX,posY = titleTx:getPosition()
        titleTx1:setPosition(cc.p(posX + size.width + 5,posY))
        local awards = DisplayData:getDisplayObjs(v.awards)
        for j=1,3 do
            local awardBgImg = bgImg:getChildByName('award_bg_img_'..j)
            if not awardBgImg then
                local cell = ClassItemCell:create(awards,frame)
                awardBgImg = cell.awardBgImg
                awardBgImg:setName('award_bg_img_'..j)
                awardBgImg:setScale(0.7)
                awardBgImg:setPosition(cc.p(380 + (j - 1)*80,41))
                bgImg:addChild(awardBgImg)
            end
            if awards[j] then
                awardBgImg:setVisible(true)
                local awardImg = awardBgImg:getChildByName('award_img')
                local lvTx = awardBgImg:getChildByName('lv_tx')
                awardBgImg:loadTexture(awards[j]:getBgImg())
                awardImg:loadTexture(awards[j]:getIcon())
                lvTx:setString('x'..awards[j]:getNum())
                awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        GetWayMgr:showGetwayUI(awards[j],false)
                    end
                end)
            else
                awardBgImg:setVisible(false)
            end
        end
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    type = v.key,
                    target = v.index,
                }
                MessageMgr:sendPost('get_exploit_award', 'worldwar', json.encode(args), function( response )
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        -- self.data.reward = data.reward
                        self.data.reward[v.key][tostring(v.index)] = 1
                        local awards = data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end
                        self:updatePanel()
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("E_STR_PVP_WAR_DESC2"), COLOR_TYPE.RED)
                    end
                end)
            end
        end)
    end
    local size = sv:getContentSize()
    if #conf * (size1.height + 5) > size.height then
        sv:setInnerContainerSize(cc.size(size.width,(#conf * (size1.height + 5) - 5)))
    else
        sv:setInnerContainerSize(size)
    end
    if self.maxCellNum then
        for i=#conf + 1,self.maxCellNum do
            local bgImg = sv:getChildByName('cell_bg_img_'..i)
            if bgImg then
                bgImg:setVisible(false)
            end
        end
    end
    self.maxCellNum = #conf
end

function WorldWarFeatsWallUI:updatePanel()
    for i=1,5 do
        if self.page == i then
            self.taskBgImgs[i]:setVisible(false)
        else
            self.taskBgImgs[i]:setVisible(true)
        end
    end
    self:updateNewImgs()
    self:updateCell()
end

function WorldWarFeatsWallUI:init()
    local worldwarBgImg = self.root:getChildByName("worldwar_bg_img")
    local worldwarImg = worldwarBgImg:getChildByName("worldwar_img")
    self:adaptUI(worldwarBgImg,worldwarImg)
    local winSize = cc.Director:getInstance():getVisibleSize()

    local closeBtn = worldwarImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            WorldWarMgr:hideFeatsWall()
        end
    end)

    local titleBgImg = worldwarImg:getChildByName('title_bg_img')
    local titleTx = titleBgImg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('FEATS_WALL'))

    self.bgImg = worldwarImg:getChildByName('bg_img')

    self.taskBgImgs = {}
    self.taskImgs = {}
    self.newImgs = {}
    for i=1,5 do
        local pl = self.bgImg:getChildByName('pl_'..i)
        local taskBgImg = pl:getChildByName('task_bg_'..i..'_img')
        local taskImg = pl:getChildByName('task_'..i..'_img')
        local newImg = pl:getChildByName('new_img')
        local titleTx = pl:getChildByName('title_tx')
        titleTx:setString(GlobalApi:getLocalStr('FEATS_WALL_TITLE_'..i))
        taskBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:updatePanel()
            end
        end)
        self.taskBgImgs[i] = taskBgImg
        self.taskImgs[i] = taskImg
        self.newImgs[i] = newImg
    end
    self:updatePanel()
end

return WorldWarFeatsWallUI