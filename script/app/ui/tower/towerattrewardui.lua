local TowerAttRewardUI = class("TowerAttRewardUI", BaseUI)
function TowerAttRewardUI:ctor(awards,refresh_num,data,isFromBtn)
    self.uiIndex = GAME_UI.UI_TOWER_ATTAWARD
    self.awards = awards
    self.data = data
    self.isFromBtn = isFromBtn
    self.selectindex = {0,0,0}
    self.stars = {0,0,0}
end

function TowerAttRewardUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    --local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('TOWER_STARAWARD_TITLE'))
    self.stararray = {}
    for i=1,3 do
        local arrary = {}
        arrary.starbg = bgimg1:getChildByName('starbg_'..i..'_img')
        arrary.starbg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.selectindex[i] == 1 then
                    self.selectindex[i] = 0
                    self.stars[i] = 0
                else
                    local haveCostStars = 0
                    for i = 1,3 do
                        haveCostStars = haveCostStars + self.stars[i]
                    end
                    local remainStars = TowerMgr:getTowerData().cur_star - haveCostStars
                    if remainStars < i * 3 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_NEED_STAR'), COLOR_TYPE.RED)
                        return
                    end
                    self.selectindex[i] = 1
                    self.stars[i] = i * 3
                end               
                self:update()

                --[[if TowerMgr:getTowerData().star >= i*3 then
                    self.selectindex = i
                    self:update()
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_NEED_STAR'), COLOR_TYPE.RED)
                end
                --]]
            end
        end) 
        arrary.startypetx = arrary.starbg:getChildByName('atttype_tx')
        arrary.starnumtx = arrary.starbg:getChildByName('attnum_tx')
        arrary.needtx = arrary.starbg:getChildByName('need_tx')
        arrary.needtx:setString('')

        arrary.needtxrichtext  = xx.RichText:create()
        arrary.needtxrichtext:setContentSize(cc.size(140, 30))
        arrary.needtxlabel = xx.RichTextLabel:create('', 21, COLOR_TYPE.ORANGE)
        arrary.needtxlabel:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
        arrary.needtxrichtext:addElement(arrary.needtxlabel)
        arrary.needtxrichtext:addElement(re2)
        arrary.needtxrichtext:setAnchorPoint(cc.p(0.5,0.5))
        arrary.needtxrichtext:setPosition(cc.p(0,0))
        arrary.needtxrichtext:setAlignment('middle')
        arrary.needtx:addChild(arrary.needtxrichtext,9527)
        arrary.needtxrichtext:setVisible(true)

        arrary.checkboxgoimg = arrary.starbg:getChildByName('checkbox_go_img')
        arrary.startypeimg = arrary.starbg:getChildByName('attimg')
        arrary.startypebigimg =arrary.startypeimg:getChildByName('atttype_big_img')
        self.stararray[i] = arrary
    end
    local desctx = bgimg1:getChildByName('desc_tx')
    desctx:setString(GlobalApi:getLocalStr('TOWER_ATTADD_DESC'))
    local goonbtn = bgimg1:getChildByName('goon_btn')
    local goonbtntx =goonbtn:getChildByName('btn_tx')
    goonbtntx:setString(GlobalApi:getLocalStr('TOWER_NEXT'))
    goonbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local allNum = self.data.cur_floor - 1
            if not self.data.cur_selected then
                self.data.cur_selected = 0
            end
            if allNum - self.data.cur_selected <= 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('TOWER_DESC_12'), COLOR_TYPE.RED)
                return
            end

            local judge = false
            local args = {}
            args.ids = {}
            for i = 1,#self.selectindex do
                if self.selectindex[i] == 1 then
                    args.ids[tostring(i)] = i
                    judge = true
                end
            end

            local function callBack2()
                MessageMgr:sendPost('select_award','tower',json.encode(args),function (response)                
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        GlobalApi:parseAwardData(response.data.awards)
                        local costs = response.data.costs
                        if costs then
                            GlobalApi:parseAwardData(costs)
                        end

                        if not self.data.cur_selected then
                            self.data.cur_selected = 0
                        end
                        self.data.cur_selected = self.data.cur_selected + 1
                        self.awards = response.data.reward

                        local haveCostStars = 0
                        for i = 1,3 do
                            haveCostStars = haveCostStars + self.stars[i]
                        end
                        local remainStars = TowerMgr:getTowerData().cur_star - haveCostStars
                        TowerMgr:getTowerData().cur_star = remainStars

                        self.selectindex = {0,0,0}
                        self.stars = {0,0,0}
                        if allNum - self.data.cur_selected <= 0 then
                            if self.isFromBtn == true then
                                TowerMgr:hideAttReward()
                            else
                                TowerMgr:setTowerAction(true)
                                TowerMgr:hideAttReward()
                            end
                        else
                            self:update()
                        end

                    end
                end)

            end

            if judge == false then
                promptmgr:showMessageBox(GlobalApi:getLocalStr("TOWER_DESC_13"), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
					callBack2()
				end)
            else
                callBack2()
            end

        end
    end)
    local totalstartx = bgimg1:getChildByName('totalstar_tx')
    totalstartx:setString('') 
    local richtext = xx.RichText:create()
    richtext:setContentSize(cc.size(480, 40))
    local re1 = xx.RichTextLabel:create(tostring(GlobalApi:getLocalStr('TOWER_CANUSE').. TowerMgr:getTowerData().cur_star), 21, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
    richtext:addElement(re1)
    richtext:addElement(re2)
    --richtext:setAnchorPoint(cc.p(0,0.5))
    richtext:setAlignment('middle')
    richtext:setPosition(cc.p(0,3))
    totalstartx:addChild(richtext,9527)
    richtext:setVisible(true)   
    richtext.re1 = re1
    self.richtext = richtext

    -- 刷新
    local refreshBtn = bgimg1:getChildByName('refresh_btn')
    refreshBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('TOWER_DESC_8'))
    refreshBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local function callBack()
                self.selectindex = {0,0,0}
                self.stars = {0,0,0}
                self:update()
            end

            local buyConf = GameData:getConfData("buy")
            local allNum = #buyConf
            local num = self.data.refresh_num + 1
            if self.data.refresh_num + 1 >= allNum then
                num = allNum
            end
            local cost = buyConf[num].towerAttrRefresh
            local cash = UserData:getUserObj():getCash()
            UserData:getUserObj():cost('cash',cost,function()
                self:refreshAttr(callBack)
            end)
        end
    end)

    local infoBg = bgimg1:getChildByName('info_bg')
    local numTx = infoBg:getChildByName('num_tx')
    --numTx:setTextColor(cc.c4b(147, 244, 255, 255))
    --numTx:setTextColor(COLOR_TYPE.WHITE)
    self.numTx = numTx

    local closebtn = bgimg1:getChildByName('closebtn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self.isFromBtn == true then
                TowerMgr:hideAttReward()
            else
                TowerMgr:setTowerAction(true)
                TowerMgr:hideAttReward()
            end
        end
    end)

    -- 剩余选择次数
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 26))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TOWER_DESC_11'), 20, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
    
	local re2 = xx.RichTextLabel:create('', 20,COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(371.45,110))
    richText:format(true)
    bgimg1:addChild(richText)

    richText.re2 = re2
    self.remainRichText = richText

    self:update()
end

function TowerAttRewardUI:refreshAttr(callBack)
    MessageMgr:sendPost('refresh_attr','tower',json.encode({}),function (response)             
        local code = response.code
        local data = response.data
        if code == 0 then
            if response.data.awards then
                GlobalApi:parseAwardData(response.data.awards)
            end
            local costs = response.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
            -- 更新self.awards数据
            self.awards = response.data.reward

            self.data.refresh_num = self.data.refresh_num + 1

            if callBack then
                callBack()
            end
        end
    end)
end

function TowerAttRewardUI:update()
    local conf = GameData:getConfData('towerattreward')
    local attconf = GameData:getConfData('attribute')
    for i=1,3 do
        local arwardid = self.awards[i]
        -- print('arwardid==='..arwardid)
        local name = attconf[tonumber(arwardid)].name
        local num = conf[tonumber(arwardid)][tostring('rewardLevel'..i)]
        self.stararray[i].startypetx:setString(name)
        self.stararray[i].starnumtx:setString('+'..num..'%')
        --self.stararray[i].needtx:setString(tostring(GlobalApi:getLocalStr('TOWER_NEED_DESC')..i*3))
        self.stararray[i].needtxlabel:setString(tostring(GlobalApi:getLocalStr('TOWER_NEED_DESC')..i*3))
        self.stararray[i].needtxrichtext:format(true)
        self.stararray[i].startypebigimg:loadTexture('uires/ui/tower/tower_att_'..tonumber(arwardid)..'.png')
    end
    for i=1,3 do
        if self.selectindex[i] == 0 then
            self.stararray[i].checkboxgoimg:setVisible(false)
        else
            self.stararray[i].checkboxgoimg:setVisible(true)
        end  
    end
    --self.stararray[self.selectindex].checkboxgoimg:setVisible(true)

    -- 刷新免费状态重置
    local buyConf = GameData:getConfData("buy")
    local allNum = #buyConf
    local num = self.data.refresh_num + 1
    if self.data.refresh_num + 1 >= allNum then
        num = allNum
    end
    local cost = buyConf[num].towerAttrRefresh

    if cost == 0 then
        self.numTx:setTextColor(cc.c4b(147, 244, 255, 255))
        self.numTx:setString(GlobalApi:getLocalStr('TOWER_DESC_9'))
    else
        self.numTx:setTextColor(COLOR_TYPE.WHITE)
        self.numTx:setString(cost)
    end

    -- 剩余次数
    local allNum = self.data.cur_floor - 1
    if not self.data.cur_selected then
        self.data.cur_selected = 0
    end
    if allNum - self.data.cur_selected <= 0 then
        self.remainRichText.re2:setColor(COLOR_TYPE.RED)
        self.remainRichText.re2:setString(0)
    else
        self.remainRichText.re2:setColor(COLOR_TYPE.WHITE)
        self.remainRichText.re2:setString(allNum - self.data.cur_selected)
    end
    self.remainRichText:format(true)

    self.richtext.re1:setString(tostring(GlobalApi:getLocalStr('TOWER_CANUSE').. TowerMgr:getTowerData().cur_star))
    self.richtext:format(true)
end

return TowerAttRewardUI