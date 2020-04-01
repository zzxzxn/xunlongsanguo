local InfiniteStarAwardUI = class("InfiniteStarAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function InfiniteStarAwardUI:ctor(chapterId)
	self.uiIndex = GAME_UI.UI_INFINITE_STAR_AWARD
    self.chapterId = chapterId
    self.cells = {}
end

function InfiniteStarAwardUI:createAward(index, img,conf)
    local pos = {cc.p(260,57),cc.p(380,57),cc.p(500,57)}
    local awards = DisplayData:getDisplayObjs(conf.award)
    for i=1,3 do
        local awardBgImg = img:getChildByName('award_bg_img_'..i)
        if not awardBgImg then
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[i], img)
            awardBgImg = tab.awardBgImg
            awardBgImg:setName('award_bg_img_'..i)
            awardBgImg:setPosition(pos[i])
            self.cells[index][i] = tab
        end
        if awards[i] then
            awardBgImg:setVisible(true)
            ClassItemCell:updateItem(self.cells[index][i], awards[i], 1)
            awardBgImg:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:showGetwayUI(awards[i],false)
                end
            end)
        else
            awardBgImg:setVisible(false)
        end
    end
end

function InfiniteStarAwardUI:updatePanel()
    local chapterId = self.chapterId
    local conf = GameData:getConfData("itsectionbox")[chapterId]
    local tab = {}
    local starNum,allNum = InfiniteBattleMgr:getStarByChapterId(self.chapterId)
    for i,v in ipairs(conf) do
        tab[i] = v
        tab[i].id = i
        if InfiniteBattleMgr.chapters[self.chapterId].stars[tostring(i)] then
            tab[i].got = 2
        elseif starNum >= v.needStar then
            tab[i].got = 0
        else
            tab[i].got = 1
        end
    end
    table.sort(tab,function(a,b)
        if a.got == b.got then
            return a.needStar < b.needStar
        end
        return a.got < b.got
    end )

    local size1
    local size = self.sv:getContentSize()
    local starNum,allNum = InfiniteBattleMgr:getStarByChapterId(self.chapterId)
    for i,v in ipairs(tab) do
        local bgImg = self.sv:getChildByName('bg_img_'..i)
        if not bgImg then
            local node = cc.CSLoader:createNode('csb/infinitestarawardcell.csb')
            bgImg = node:getChildByName('bg_img')
            size1 = bgImg:getContentSize()
            bgImg:removeFromParent(false)
            bgImg:setName('bg_img_'..i)
            bgImg:setPosition(cc.p(size.width/2,(#tab - i)*(size1.height + 10)))
            self.sv:addChild(bgImg)
            self.cells[i] = {}
        end
        size1 = bgImg:getContentSize()
        local numTx = bgImg:getChildByName('num_tx')
        local getImg = bgImg:getChildByName('get_img')
        local getBtn = bgImg:getChildByName('get_btn')
        local infoTx = getBtn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
        local num = starNum
        if num >= v.needStar then
            num = v.needStar
        end
        numTx:setString(num..'/'..v.needStar)
        self:createAward(i, bgImg, v)

        if v.got == 2 then
            getBtn:setVisible(false)
            getImg:setVisible(true)
            getImg:loadTexture('uires/ui/activity/yilingq.png')
        elseif v.got == 0 then
            getBtn:setVisible(true)
            getImg:setVisible(false)
        else
            getBtn:setVisible(false)
            getImg:setVisible(true)
            getImg:loadTexture('uires/ui/activity/weidac.png')
        end
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local args = {
                    id = self.chapterId,
                    level = v.id
                }
                MessageMgr:sendPost('get_stars_awards','unlimited',json.encode(args),function (response)
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        local awards = data.awards
                        if awards then
                            GlobalApi:parseAwardData(awards)
                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                        end
                        InfiniteBattleMgr.chapters[self.chapterId].stars[tostring(v.id)] = 1
                        local itsectionboxConf = GameData:getConfData("itsectionbox")[self.chapterId]
                        local starNum, allNum = InfiniteBattleMgr:getStarByChapterId(self.chapterId)
                        local allGet = true
                        for i,v in ipairs(itsectionboxConf) do
                            if InfiniteBattleMgr.chapters[self.chapterId].stars[tostring(i)] == nil and starNum >= v.needStar then -- 可领取
                                allGet = false
                                break
                            end
                        end
                        if allGet then
                            local infinite = UserData:getUserObj():getInfinite()
                            if infinite.tip and infinite.tip.stars then
                                for k, v in ipairs(infinite.tip.stars) do
                                    if v == self.chapterId then
                                        table.remove(infinite.tip.stars, k)
                                        break
                                    end
                                end
                            end
                        end
                        self:updatePanel()
                    end
                end)
            end
        end)
    end

    if size1 then
        if #tab * (size1.height + 10) > size.height then
            self.sv:setInnerContainerSize(cc.size(size.width,(#tab * (size1.height + 10) - 10)))
        else
            self.sv:setInnerContainerSize(size)
        end
    end
end

function InfiniteStarAwardUI:init()
	local bgImg = self.root:getChildByName("award_bg_img")
	self.awardImg = bgImg:getChildByName("award_img")
    self:adaptUI(bgImg, self.awardImg)
	local closeBtn = self.awardImg:getChildByName("close_btn")
	local winSize = cc.Director:getInstance():getVisibleSize()
	self.awardImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))
	local titleImg = self.awardImg:getChildByName("title_img")
	local titleTx = titleImg:getChildByName("title_tx")
	titleTx:setString(GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_5'))

    local neiBgImg = self.awardImg:getChildByName("nei_bg_img")
    self.sv = neiBgImg:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            InfiniteBattleMgr:hideInfiniteStarAward()
        end
    end)

    self:updatePanel()
end

return InfiniteStarAwardUI