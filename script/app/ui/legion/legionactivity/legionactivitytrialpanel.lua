local LegionActivityTrialUI = class("LegionActivityTrialUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegionActivityTrialUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONACTIVITYTRIALUI
  self.data = data
  self.time = 0
  --printall(self.data)
  self.legionconf = GameData:getConfData('legion')


    local obj = {
	    name = "",
	    pos = self.data.trial_robot
    }
    local enemyData = BattleMgr:createCommonEnemyDataByServer(obj)
    self.enemryFightforce = enemyData.fightforce

end

function LegionActivityTrialUI:onShow()
    self:update()
end
function LegionActivityTrialUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgAlphaImg2 = bgimg1:getChildByName("bg_img2")
    self.bgimg2 = bgAlphaImg2:getChildByName('bg_img1')
    -- bgimg1:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionActivityTrialUI()
    --     end
    -- end
    local cenerNode = self.root:getChildByName('cener_node')
    self.cenerNode = cenerNode
    self:adaptUI(bgimg1,bgAlphaImg2)

    -- 帮助按钮
    local winSize = cc.Director:getInstance():getWinSize()
    local helpBtn = HelpMgr:getBtn(17)
    helpBtn:setPosition(cc.p(40 ,winSize.height - 40))
    self.root:addChild(helpBtn)

    self:adaptUI2()
    local closebtn = self.root:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityTrialUI()
        end
    end)
    closebtn:setPosition(cc.p(winSize.width,winSize.height))
    self.timestx = self.root:getChildByName('times_tx')
    self.lvtx = self.root:getChildByName('lv_tx')
    local titletx = self.root:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_TITLE'))
    self.awardframe1 = self.bgimg2:getChildByName('award_1_img')
    self.awardframe1:ignoreContentAdaptWithSize(true)
    self.awardicon1 = self.awardframe1:getChildByName('icon_img')
    self.awardicon1:ignoreContentAdaptWithSize(true)
    self.awardname1 = self.awardframe1:getChildByName('name_tx')
    self.awardname1:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_DESC3'))
    self.awardframe2 = self.bgimg2:getChildByName('award_2_img')
    self.awardframe2:ignoreContentAdaptWithSize(true)
    self.awardframe2:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionActivityTrialStarUI(self.data)
        end
    end)
    self.awardframe1:setVisible(false)
    self.awardframe2:setVisible(false)


    self.awardicon2 = self.awardframe2:getChildByName('icon_img')
    self.awardicon2:ignoreContentAdaptWithSize(true)
    self.awardname2 = self.awardframe2:getChildByName('name_tx')
    self.awardname2:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_DESC4'))
    self.newimg = self.awardframe2:getChildByName('new_img')
    local funcbtn = self.cenerNode:getChildByName('func_btn')
    self.funcbtn = funcbtn
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local maxcount = self.legionconf['legionTrialMaxCount'].value
            if maxcount- self.data.trial_count <= 0 then              
               promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_7'), COLOR_TYPE.RED)
            else
               local customObj = {}
               customObj.trial_robot = self.data.trial_robot
               LegionMgr:showLegionActivitySelRoleListUI(BATTLE_TYPE.TRIAL,customObj)
            end
        end
    end)
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_BTN_TX1'))
    self.animpl = self.cenerNode:getChildByName('anim_bg')

    --[[
    local enemy_tx = self.bgimg2:getChildByName('enemy_tx')
    enemy_tx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_DESC5'))
    
    local fight_bg = self.bgimg2:getChildByName('fight_bg')

    local fightforceLabel = cc.LabelAtlas:_create(self.enemryFightforce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setScale(0.8)     
    fightforceLabel:setAnchorPoint(cc.p(0, 0.5))    
    self.bgimg2:addChild(fightforceLabel)
    fightforceLabel:setPosition(cc.p(fight_bg:getPositionX() + 10,fight_bg:getPositionY()))
    --]]

    local fightforceImg = self.cenerNode:getChildByName('fightforce_img')
    local fightforceTx = fightforceImg:getChildByName('fightforce_tx')
    local fightBg = self.cenerNode:getChildByName('fight_bg')
    local fightIcon = self.cenerNode:getChildByName('fight_icon')

    local fightforceLabel = cc.LabelAtlas:_create(self.enemryFightforce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
    fightforceLabel:setScale(0.8)     
    fightforceLabel:setAnchorPoint(cc.p(0.5, 0.5))    
    fightforceImg:addChild(fightforceLabel)
    fightforceLabel:setPosition(cc.p(fightforceTx:getPositionX(),fightforceTx:getPositionY()))

    self.fightforceImg = fightforceImg
    self.fightBg = fightBg
    self.fightIcon = fightIcon

    --self:initTop()
    local topBg = self.root:getChildByName('top_bg')
    topBg:setVisible(false)
    self:initBottom()
    self:initRightBottom()
    self:update()
    --local imgSize = bgimg1:getContentSize()
    --bgimg1:setScale(winSize.width/imgSize.width,winSize.height/imgSize.height)
    --bgimg1:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
end

function LegionActivityTrialUI:initTop()
    local topBg = self.root:getChildByName('top_bg')
    topBg:setVisible(false)

    local dropConf = GameData:getConfData('drop')

    local trialconf = GameData:getConfData('trial')[1]
    local dropId1 = trialconf.dropId1
    local dropId2 = trialconf.dropId2
    local dropId3 = trialconf.dropId3

    -- 1
    local des1 = topBg:getChildByName('des1')
    des1:setString(string.format(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC5"),120))

    local dropData1 = dropConf[dropId1]
    local awards1 = DisplayData:getDisplayObjs(dropData1.award2)[1]

    local img1 = topBg:getChildByName('img1')
    img1:loadTexture(awards1:getIcon())
    img1:setTouchEnabled(false)
    img1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI2(awards1,false)
        end
    end)
        
    -- 2
    local des2 = topBg:getChildByName('des2')
    des2:setString(string.format(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC5"),90))

    local dropData2 = dropConf[dropId2]
    local awards2 = DisplayData:getDisplayObjs(dropData2.award2)[1]

    local img2 = topBg:getChildByName('img2')
    img2:loadTexture(awards2:getIcon())
    img2:setTouchEnabled(false)
    img2:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI2(awards2,false)
        end
    end)

    local weight2_2 = dropData2.weight2
    local des2_2 = topBg:getChildByName('des2_2')
    if weight2_2 == 100 then
        des2_2:setString(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC7"))
    else
        des2_2:setString(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC6"))
    end

    local awards2_2 = DisplayData:getDisplayObjs(dropData2.award3)[1]

    local img2_2 = topBg:getChildByName('img2_2')
    if awards2_2 then
        img2_2:loadTexture(awards2_2:getIcon())
        img2_2:setTouchEnabled(false)
        img2_2:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI2(awards2_2,false)
            end
        end)
    else
        img2_2:setVisible(false)
        des2_2:setVisible(false)
    end

    -- 3
    local des3 = topBg:getChildByName('des3')
    des3:setString(string.format(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC5"),60))

    local dropData3 = dropConf[dropId3]
    local awards3 = DisplayData:getDisplayObjs(dropData3.award2)[1]

    local img3 = topBg:getChildByName('img3')
    img3:loadTexture(awards3:getIcon())
    img3:setTouchEnabled(false)
    img3:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI2(awards3,false)
        end
    end)

    local weight3_2 = dropData3.weight2
    local des3_2 = topBg:getChildByName('des3_2')
    if weight3_2 == 100 then
        des3_2:setString(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC7"))
    else
        des3_2:setString(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC6"))
    end

    local awards3_2 = DisplayData:getDisplayObjs(dropData3.award3)[1]
    local img3_2 = topBg:getChildByName('img3_2')
    if awards3_2 then
        img3_2:loadTexture(awards3_2:getIcon())
        img3_2:setTouchEnabled(false)
        img3_2:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                GetWayMgr:showGetwayUI2(awards3_2,false)
            end
        end)
    else
        img3_2:setVisible(false)
        des3_2:setVisible(false)
    end
end

function LegionActivityTrialUI:initBottom()
    local bottomBg = self.root:getChildByName('bottom_bg')

    local titleTx = bottomBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_DESC8'))

    local trialconf = GameData:getConfData('trial')[LegionMgr:calcTrialLv()]
    local dropConf = GameData:getConfData('drop')
    local dropData = dropConf[trialconf.showdropId]

    for i = 1,6,1 do
        local frame = bottomBg:getChildByName('icon_' .. i)
        local award = dropData["award" .. i]
        local awards = DisplayData:getDisplayObjs(award)[1]

        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, frame)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.lvTx:setString('x'..awards:getNum())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        cell.nameTx:setString(awards:getName())
        cell.nameTx:setColor(awards:getNameColor())
        cell.nameTx:enableOutline(awards:getNameOutlineColor(),1)

        local guangImg = bottomBg:getChildByName('guang_' .. i)
        if awards:getQuality() == 6 then
            guangImg:setVisible(true)
            guangImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(3, 360)))
        else
            guangImg:setVisible(false)
        end
    end
end

function LegionActivityTrialUI:initRightBottom()
    if self.data.trial_star == nil then
        self.data.trial_star = 0
    end
    local rightBottom = self.root:getChildByName('right_bottom')
    local nowOwnTx = rightBottom:getChildByName('now_own_tx')
    nowOwnTx:setString(string.format(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC9"),self.data.trial_star))

    local confData = GameData:getConfData('exchangekey')
    for i = 1,3 do
        local data = confData[i]
        local num = rightBottom:getChildByName('num_' .. i)
        num:setString(data.num)
        -- 可以兑换的奖励
        local gift = rightBottom:getChildByName('key_' .. i)
        local giftObj = DisplayData:getDisplayObjs(data.awards)[1]
        gift:loadTexture(giftObj:getIcon())

        local exchangeBtn = rightBottom:getChildByName('exchange_btn_' .. i)
        exchangeBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC10"))
        exchangeBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.trial_star < data.num then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_DESC11'), COLOR_TYPE.RED)
                    return
                end
                local awards = data.awards
                local str = string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_DESC12'),data.num,DisplayData:getDisplayObjs(awards)[1]:getName())
                promptmgr:showMessageBox(str, MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                    MessageMgr:sendPost('exchange_key','legion',json.encode({id = i}),function (response)
		                local code = response.code
		                local datas = response.data
		                if code == 0 then
			                local costs = datas.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            
                            local awards = datas.awards
                            if awards then
                                GlobalApi:parseAwardData(awards)
                                GlobalApi:showAwardsCommon(awards,nil,nil,true)
                            end

                            self.data.trial_star = self.data.trial_star - data.num
                            nowOwnTx:setString(string.format(GlobalApi:getLocalStr("LEGION_ACTIVITY_TRIAL_DESC9"),self.data.trial_star))
		                end
	                end)

                end,GlobalApi:getLocalStr('STR_OK2'),GlobalApi:getLocalStr('STR_CANCEL_1'))
            end
        end)

    end

end

function LegionActivityTrialUI:adaptUI2()
    local winSize = cc.Director:getInstance():getWinSize()
    local cener_node = self.root:getChildByName('cener_node')
    cener_node:setPosition(cc.p(winSize.width/2 + 10,40))

    local times_tx = self.root:getChildByName('times_tx')
    times_tx:setPosition(cc.p(winSize.width - (960 - 952),20))

    local title_tx = self.root:getChildByName('title_tx')
    title_tx:setPosition(cc.p(winSize.width/2,winSize.height - (640 - 590)))

    local lv_tx = self.root:getChildByName('lv_tx')
    lv_tx:setPosition(cc.p(winSize.width/2,winSize.height - (640 - 495)))

    local top_bg = self.root:getChildByName('top_bg')
    top_bg:setPosition(cc.p(0,winSize.height - (640 - 569)))

    local bottom_bg = self.root:getChildByName('bottom_bg')
    bottom_bg:setPosition(cc.p(5,6.46))

    local right_bottom = self.root:getChildByName('right_bottom')
    right_bottom:setPosition(cc.p(winSize.width - (960 - 900),150))
end

function LegionActivityTrialUI:update()
    
    local trialconf = GameData:getConfData('trial')[LegionMgr:calcTrialLv()]
    local maxcount = self.legionconf['legionTrialMaxCount'].value
    self.timestx:setString('')

    self.root:removeChildByTag(9527)
    local richText = xx.RichText:create()
    richText:setAnchorPoint(cc.p(1,0.5))
    local winSize = cc.Director:getInstance():getWinSize()
    richText:setContentSize(cc.size(240, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIAL_DESC2')..'：', 25, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create((maxcount- self.data.trial_count), 25, COLOR_TYPE.WHITE)
    if maxcount- self.data.trial_count <= 0 then
        re2 = xx.RichTextLabel:create(0, 25, COLOR_TYPE.RED)
    end
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FREE_TIMES_DESC'), 25, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setPosition(cc.p(self.timestx:getPositionX(),self.timestx:getPositionY()))
    richText:setAlignment('right')
    self.root:addChild(richText,9527)
    richText:setVisible(true)
    if (maxcount - self.data.trial_count) <= 0 then
        self.lvtx:setVisible(false)
        self.fightforceImg:setVisible(false)
        self.fightBg:setVisible(false)
        self.fightIcon:setVisible(false)
    else
        self.lvtx:setString(string.format(GlobalApi:getLocalStr("LEGION_MENBER_DES11"),self.data.trial_count + 1))
        self.lvtx:setVisible(true)
        self.fightforceImg:setVisible(true)
        self.fightBg:setVisible(true)
        self.fightIcon:setVisible(true)
    end
    self.lvtx:setVisible(false)

    local formationconf = GameData:getConfData('formation')[trialconf.trialId]
    local bosspos = formationconf.boss
    local bossid = formationconf[tostring('pos' .. bosspos)]
    local monsterconf = GameData:getConfData('monster')[bossid] 
    self:createAni(self.animpl,monsterconf.url,i,monsterconf.uiOffsetY)
    --[[
    local displayobj1 = DisplayData:getDisplayObj(trialconf['award'][1])
    self.awardframe1:loadTexture(displayobj1:getBgImg())
    self.awardframe1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI(displayobj1,false)
        end
    end)
    self.awardicon1:loadTexture(displayobj1:getIcon())
    local displayobj2 = DisplayData:getDisplayObj(trialconf['starAward3'][1])
    self.awardframe2:loadTexture(displayobj2:getBgImg())
    self.awardicon2:loadTexture(displayobj2:getIcon())
    self.newimg:setVisible(false)
    --]]
    --for i=1,5 do
        --if self.data.trial_stars >= i*3 then
            --if self.data.trial_award == nil or (self.data.trial_award ~= nil and tonumber(self.data.trial_award[tostring(i*3)]) ~= 1) then
                --self.newimg:setVisible(true)
                --break
            --end
        --end
    --end
end

function LegionActivityTrialUI:createAni(parentnode,url,index,uiOffsetY)
    parentnode:removeAllChildren()
    local spineAni = GlobalApi:createLittleLossyAniByName(url.."_display")
    if spineAni then
        spineAni:getAnimation():play('idle', -1, 1)
        spineAni:setPosition(cc.p(parentnode:getContentSize().width/2,uiOffsetY))
        parentnode:addChild(spineAni)
    end
end

return LegionActivityTrialUI