local ActivityPromoteGetSoul = class("ActivityPromoteGetSoul", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function ActivityPromoteGetSoul:ctor(msg)
	self.uiIndex = GAME_UI.UI_ACTIVITY_PROMOTE_GET_SOUL
    self.promote_get_soul = msg.promote_get_soul
    UserData:getUserObj().activity.promote_get_soul = self.promote_get_soul
end

function ActivityPromoteGetSoul:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = self.root:getChildByName('bg_img_1')

    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hidePromoteGetSoulUI()
        end
    end)
    self.closebtn = closebtn
    self.bgimg2 = bgimg2

    local winsize = cc.Director:getInstance():getWinSize()
    bgimg1:setContentSize(winsize)
    bgimg1:setPosition(cc.p(winsize.width/2,winsize.height/2))
    bgimg2:setPosition(cc.p(winsize.width/2 - (480 - 438),winsize.height - (640 - 362)))

    local descTx = self.bgimg2:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES1'))

    local _,time = ActivityMgr:getActivityTime("promote_get_soul")
    if time > 0 then
        local refTime = self.bgimg2:getChildByName('ref_time')
        refTime:setString(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES2'))

        local node = cc.Node:create()
        node:setPosition(cc.p(188,14))
        refTime:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES3'),math.floor(time / (24 * 3600))) 
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.WHITE,COLOR_TYPE.FRONT,CDTXTYPE.FRONT,str,COLOR_TYPE.WHITE,COLOROUTLINE_TYPE.BLACK,22)
    end

    self.tempData = GameData:getConfData('avpromotegetsoul')
    local bg = self.bgimg2:getChildByName('bg')
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = self.bgimg2:getChildByName('cell')
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell
    self:refreshSV()
end

function ActivityPromoteGetSoul:refreshSV()
    self.datas = {}
    for i = 1,#self.tempData do
        local v = clone(self.tempData[i])
        -- 充值档位数量
        local rechargeNum = self.promote_get_soul.progress[tostring(i)] or 0
        -- 已经领取数量
        local hasGetNum = self.promote_get_soul.rewards[tostring(i)] or 0
        -- 最大领取数量
        local maxGetNum = v.limitCount
        if hasGetNum >= maxGetNum then  -- 已领完
            v.showStatus = 1
        elseif hasGetNum < rechargeNum then -- 可领取
            v.showStatus = 3
        else    -- 未达成
            v.showStatus = 2
        end
        table.insert(self.datas,v)
    end

    table.sort(self.datas,function(a, b)
        if a.showStatus == b.showStatus then
            return a.id < b.id
        else
            return a.showStatus > b.showStatus
        end
	end)

    self.sv:removeAllChildren()
    self:updateSV()
end

function ActivityPromoteGetSoul:updateSV()
    local num = #self.datas
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * self.rewardCell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = self.rewardCell:getContentSize().height
    for i = 1,num do
        local tempCell = self.rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(6,allHeight - offset))
        self.sv:addChild(tempCell)

        local confData = self.datas[i]

        local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(500, 26))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES4'), 24, COLOR_TYPE.WHITE)
	    --re1:setStroke(cc.c4b(140,56,0,255),1)
        --re1:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
        re1:setFont('font/gamefont.ttf')
	    local re2 = xx.RichTextLabel:create(confData.cost/10, 24, COLOR_TYPE.YELLOW)
	    --re2:setStroke(cc.c4b(140,56,0,255),1)
        --re2:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
        re2:setFont('font/gamefont.ttf')
	    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES5'), 24, COLOR_TYPE.WHITE)
	    --re3:setStroke(cc.c4b(140,56,0,255),1)
        --re3:setShadow(COLOR_TYPE.WHITE, cc.size(0, 0))
        re3:setFont('font/gamefont.ttf')
	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(20,107))
        tempCell:addChild(richText)
        richText:format(true)

        local awards = DisplayData:getDisplayObjs(confData.awards)
        for j = 1,#awards do
            if awards[j] then
                local tab = ClassItemCell:create()
                local awardBgImg = tab.awardBgImg
                awardBgImg:setScale(0.8)
                tempCell:addChild(awardBgImg)
                awardBgImg:setPosition(cc.p((j - 1)*90 + 60,44))

                local awardImg = awardBgImg:getChildByName('award_img')
                local nameTx = awardBgImg:getChildByName('name_tx')
                local lvTx = awardBgImg:getChildByName('lv_tx')
                lvTx:setString('x'..awards[j]:getNum())
                awardBgImg:loadTexture(awards[j]:getBgImg())
                awardImg:loadTexture(awards[j]:getIcon())
                nameTx:setString(awards[j]:getName())
                nameTx:enableOutline(awards[j]:getNameOutlineColor(),1)
                nameTx:setColor(awards[j]:getNameColor())
                nameTx:setScale(22/24)
                nameTx:setVisible(false)
                local godId = awards[j]:getGodId()
                awards[j]:setLightEffect(tab.awardBgImg)

                awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.ended then
                        GetWayMgr:showGetwayUI(awards[j])
                    end
                end)
            end
        end

        -- 充值档位数量
        local rechargeNum = self.promote_get_soul.progress[tostring(confData.id)] or 0

        -- 已经领取数量
        local hasGetNum = self.promote_get_soul.rewards[tostring(confData.id)] or 0

        -- 最大领取数量
        local maxGetNum = confData.limitCount

        local infoTx = tempCell:getChildByName('info_tx')
        infoTx:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES6'),hasGetNum,maxGetNum)) 

        local got = tempCell:getChildByName('got')
        local tx = tempCell:getChildByName('tx')
        tx:setString(GlobalApi:getLocalStr('ACTIVITY_PROMOTE_GET_SOUL_DES7'))
        local getBtn = tempCell:getChildByName('get_btn')
        getBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))

        local gotoBtn = tempCell:getChildByName('goto_btn')
        gotoBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_VIPLIMIT4'))

        local judge = 1
        if hasGetNum >= maxGetNum then
            getBtn:setVisible(false)
            got:setVisible(true)
            tx:setVisible(true)
            gotoBtn:setVisible(false)
        elseif hasGetNum < rechargeNum then
            getBtn:setVisible(true)
            got:setVisible(false)
            tx:setVisible(false)
            gotoBtn:setVisible(false)
            judge = 1
        else
            getBtn:setVisible(false)
            got:setVisible(false)
            tx:setVisible(false)
            gotoBtn:setVisible(true)
            judge = 2
        end

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                if judge == 1 then
                    MessageMgr:sendPost('get_promote_soul_reward','activity',json.encode({id = confData.id}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end
                    
                        local hasGetNum = self.promote_get_soul.rewards[tostring(confData.id)] or 0
                        self.promote_get_soul.rewards[tostring(confData.id)] = hasGetNum + 1
                        UserData:getUserObj().activity.promote_get_soul = self.promote_get_soul
                        self:refreshSV()
		            end)
                else
                    GlobalApi:getGotoByModule('cash')
                    MainSceneMgr:hidePromoteGetSoulUI()
                end
            end 
        end)

        gotoBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                GlobalApi:getGotoByModule('cash')
                MainSceneMgr:hidePromoteGetSoulUI()
            end 
        end)
    end
    innerContainer:setPositionY(size.height - allHeight)

end

return ActivityPromoteGetSoul