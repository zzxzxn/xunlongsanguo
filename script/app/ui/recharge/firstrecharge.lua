local FirstRechargeUI = class("FirstRechargeUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local NOTREATCH = 'uires/ui/activity/weidac.png'
local HASGETAWARD = 'uires/ui/activity/yilingq.png'

function FirstRechargeUI:ctor(data)
    self.uiIndex = GAME_UI.UI_FIRSTRECHARGE
	self.data = data
	self.cfg = GameData:getConfData("specialreward")["first_pay"]
    self.extra = GameData:getConfData("specialreward")["firstExtra_pay"]


    UserData:getUserObj().activity.first_pay = self.data.first_pay
    UserData:getUserObj().tips.first_pay = 0
end	

function FirstRechargeUI:onShow()
	self:updatePanel()
end

function FirstRechargeUI:updatePanel()
	self.gotoTx = self.goto_Btn:getChildByName("tx")		
    local val = self.data.first_pay.rechargeId or 0
    self.goto_Btn:setVisible(false)
	local str=''
	self.isCanGetAwards=false
	if val==0 then
        str = GlobalApi:getLocalStr('STR_ONDOING')
	else
        str = GlobalApi:getLocalStr('STR_GET')
		self.isCanGetAwards=true
        self.goto_Btn:setVisible(true)
	end
    if self.gotoTx then
        self.gotoTx:setString(str)
    end

	self.goto_Btn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			AudioMgr.PlayAudio(11)
            if self.isCanGetAwards==true then
				local args = {}
				MessageMgr:sendPost('get_first_pay_reward','user',json.encode(args),function (response)
					local code = response.code
					if code == 0 then
						local awards = response.data.awards
						if awards then
							GlobalApi:parseAwardData(awards)
							GlobalApi:showAwardsCommon(awards,nil,nil,true)
                            UserData:getUserObj():getMark().first_pay_get_reward_time = 2
						end
						
                        UserData:getUserObj().tips.first_pay = 0
                        self.data.first_pay = response.data.first_pay
                        UserData:getUserObj().activity.first_pay = self.data.first_pay

                        self.bg2:setVisible(false)
                        self.bg3:setVisible(true)
                        self:refreshSV()
					end
				end)

			end
	    end
	end)

    -- 预处理按钮状态
    if self.isCanGetAwards then
        for i=1,4 do
            -- 按钮无法触发事件
            local btn = self.chargeBtn:getChildByName('chargeGrade_btn_'..i)
            btn:setTouchEnabled(false)
        end
    end
end

function FirstRechargeUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
    local bg3 = bg1:getChildByName("bg3")
    self.bg2 = bg2
    self.bg3 = bg3
	self:adaptUI(bg1, bg2)
    self:adaptUI(bg1, bg3)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 20))
    bg3:setPosition(cc.p(winSize.width/2,winSize.height/2 - 20))

    local val=UserData:getUserObj():getMark().first_pay_get_reward_time
    if val ~= 0 then
        bg2:setVisible(false)
        bg3:setVisible(true)
    else
        bg2:setVisible(true)
        bg3:setVisible(false)
    end


    CustomEventMgr:addEventListener("get_recharge_raward",self,function (code) 
        self:buyCallback(code)
    end)
    self.bg2:registerScriptHandler(function (event)
        if "exit" == event then
            -- print("注销回调函数")
            CustomEventMgr:removeEventListener("get_recharge_raward",self)
        end
    end)

    self:initBg2()
    self:initBg3()
end

function FirstRechargeUI:initBg2()
    local bg2 = self.bg2
    self.hadFood = false
    local hadFoodNum = 0

    local firstPayShowAwards = GameData:getConfData("avfirstpayshowawards")[1]
    local showAwards = DisplayData:getDisplayObjs(firstPayShowAwards.awards)

	for i=1,3 do
		local bg = bg2:getChildByName('node_'..(i + 1))
		if showAwards[i] then
			local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, showAwards[i], bg)
			local bgSize=bg:getContentSize()
			tab.awardBgImg:setPosition(cc.p(bgSize.width/2, bgSize.height/2))
            tab.awardBgImg:setScale(0.7)
			
			local effect = tab.awardBgImg:getChildByName('chip_light')
			local size = tab.awardBgImg:getContentSize()
			if not effect then
				effect = GlobalApi:createLittleLossyAniByName("chip_light")
				effect:getAnimation():playWithIndex(0, -1, 1)
				effect:setName('chip_light')
				effect:setVisible(true)
				effect:setPosition(cc.p(size.width/2,size.height/2))
				tab.awardBgImg:addChild(effect)
			else
				effect:setVisible(true)
			end
            if showAwards[i]:getId() == 'food' then
			    hadFoodNum = hadFoodNum + 1
		    end
		end
	end

    if hadFoodNum > 0 then
        self.hadFood = true
    end
	
    local tempData = GameData:getConfData('hero')

    local awards = DisplayData:getDisplayObjs(self.cfg.reward)
    local bg = bg2:getChildByName("node_1")

    local desc1 = bg2:getChildByName('desc_tx_1')
    -- desc1:setString(awards[1]:getName())
    -- 创建特效文字
    self.name = xx.RichTextLabel:create()
    self.rtname = xx.RichText:create()
    desc1:addChild(self.rtname)
    self.rtname:setContentSize(cc.size(200, 47))
    self.rtname:setPosition(cc.p(0, -8))
    self.rtname:setAlignment('middle')
    self.name:setFontSize(24)
    self.name:setFont("font/gamefont.ttf")
    self.rtname:addElement(self.name)   

    self.name:setString(awards[1]:getName())
    self.name:setColor(awards[1]:getNameColor())

    -- 创建anim动画
    local spineAni = GlobalApi:createLittleLossyAniByName(awards[1].baseinfo.url.."_display",nil,nil)
	local bgSize = bg:getContentSize()
    if spineAni then
        local shadow = spineAni:getBone(awards[1].baseinfo.url .. "_display_shadow")
        if shadow then
            shadow:changeDisplayWithIndex(-1, true)
            shadow:setIgnoreMovementBoneData(true)
        end
        spineAni:setPosition(cc.p(bg:getContentSize().width/2,0))
        spineAni:setScale(0.5)
        spineAni:setLocalZOrder(999)
        bg:addChild(spineAni)
        spineAni:getAnimation():play('idle', -1, 1)
    end

    local cardData = tempData[tonumber(self.cfg.reward[1][2])]
    -- 添加卡牌信息的展示
    bg:setTouchEnabled(true)
    bg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            -- 修改成没有试玩按钮
            ChartMgr:showChartInfo(cardData,ROLE_SHOW_TYPE.NORMAL)
        end

    end)

    -- 额外奖励显示
    local bg5 = bg2:getChildByName("node_5")
    local heroImg = bg5:getChildByName("hero_img")
    local nameTx = bg5:getChildByName("name_tx")
    local soldierImg = bg5:getChildByName("soldier_img")
    local typeImg = bg5:getChildByName("type_img")
    local img1 = bg5:getChildByName("img_1")
    -- 获取额外奖励信息
    local awards = DisplayData:getDisplayObjs(self.extra.reward)

    -- 初始化显示
    bg5:loadTexture(COLOR_CARDBG[awards[1]:getQuality()] or COLOR_CARDBG[1])
    heroImg:loadTexture('uires/icon/big_hero/' .. awards[1].baseinfo.bigIcon)
    soldierImg:loadTexture('uires/ui/common/'..'soldier_'..awards[1].baseinfo.soldierId..'.png')
    typeImg:loadTexture('uires/ui/common/camp_'..awards[1].baseinfo.camp..'.png')
    img1:loadTexture('uires/ui/common/professiontype_'..awards[1].baseinfo.ability..'.png')
    -- nameTx:setString(awards[1]:getName())
    self.name2 = xx.RichTextLabel:create()
    self.rtname2 = xx.RichText:create()
    nameTx:addChild(self.rtname2)
    self.rtname2:setContentSize(cc.size(200, 47))
    self.rtname2:setPosition(cc.p(0, -8))
    self.rtname2:setAlignment('middle')
    self.name2:setFontSize(18)
    self.name2:setFont("font/gamefont.ttf")
    self.rtname2:addElement(self.name2)   
    self.name2:setString(awards[1]:getName())
    self.name2:setColor(awards[1]:getNameColor())

    local cardData2 = tempData[tonumber(self.extra.reward[1][2])]

    -- 添加卡牌信息的展示
    bg5:setTouchEnabled(true)
    bg5:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        end
        if eventType == ccui.TouchEventType.ended then
            -- 修改成没有试玩按钮
            ChartMgr:showChartInfo(cardData2,ROLE_SHOW_TYPE.NORMAL)
        end

    end)


	for i=1,3 do
		local descTx = bg2:getChildByName('desc_tx_'..(i+1))
        -- 获取物品名称
        if showAwards[i] then
            descTx:setString(showAwards[i]:getName())
        end
	end

    -- 初始化充值按钮的显示
    local chargeInfo = GameData:getConfData("recharge")
    local chargeBtn = bg2:getChildByName('charge_btn')
    self.chargeBtn = chargeBtn

    -- 支付信息
    local buyBtns ={}
    local rechargeName = SdkData:getRechargeConfName()
    local tempConf = GameData:getConfData(rechargeName)

    for i=1,4 do
        local btn = chargeBtn:getChildByName('chargeGrade_btn_'..i)
        table.insert(buyBtns, btn)
        local info = chargeInfo[100+i]
        if btn then
            local size = btn:getContentSize()
            -- 给按钮添加动画效果
            local animEffect = self:createEffectAnim(size)                   
            btn:addChild(animEffect)
            btn.animEffect = animEffect  
            -- 给按钮添加粒子效果
            local particleEffect1 = self:createParticleEffect("animation_littlelossy/ui_light_effect2/ui_light_effect2.plist",3)      
            particleEffect1:setPosition(cc.p(size.width/2, size.height/2+60))     
            btn:addChild(particleEffect1)
            btn.particleEffect1 = particleEffect1

            if i == 4 then
                local particleEffect2 = self:createParticleEffect("animation_littlelossy/ui_light_effect3/ui_light_effect3.plist",1)   
                particleEffect2:setPosition(cc.p(size.width/2-20, size.height/2+20))           
                btn:addChild(particleEffect2)
                btn.particleEffect2 = particleEffect2
            end
            -- 初始化充值按钮的显示
            local value = btn:getChildByName('value_tx_'..i)
            local gold = btn:getChildByName('gold_tx_'..i)
            value:setString(info.amount.."元")
            gold:setString(info.cash + info.extra)
            -- 给按钮添加功能
            btn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    btn:runAction(cc.Sequence:create(cc.DelayTime:create(1),cc.CallFunc:create(function()
                        btn:setBright(true)
                        for k, v in ipairs(buyBtns) do
                            v:setTouchEnabled(true)
                        end
                    end)))
                    -- print("开始支付")
                    -- 支付功能
                    -- if SdkData:getSDKPlatform() ~= "dev" then
                    --  local RechargeHelper = require("script/app/ui/recharge/rechargehelper_" .. SdkData:getSDKPlatform())
                    --  RechargeHelper:recharge(i, conf[i])
                    -- end
                    RechargeMgr:pay(info,function(code)
                        self:buyCallback(code)
                    end)
                end
            end)
        end
    end

    self.buyBtns = buyBtns
	
	--goto btn
	self.goto_Btn = bg2:getChildByName("goto_btn")

	--close btn
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RechargeMgr:hideFirstRecharge()
	    end
	end)

	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
	self:updatePanel()

end

function FirstRechargeUI:buyCallback(code)
    print("进入回调")
    if code == 1 then -- sdk购买成功
        -- 所有按钮无法点击
        for i = 1,4 do
            self.buyBtns[i]:setTouchEnabled(false)
        end
        -- 显示可领取按钮
        self.goto_Btn:setVisible(true)
        self.goto_Btn:setTouchEnabled(true)
        self.gotoTx:setString(GlobalApi:getLocalStr('STR_GET_1'))
        self.isCanGetAwards = true
    elseif jsonObj.code == 100 then
        promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
    end
    -- self:refreshBtnStatus()
end


function FirstRechargeUI:initBg3()
    local bg3 = self.bg3

    local closeBtn = bg3:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			RechargeMgr:hideFirstRecharge()
	    end
	end)
	

    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_5'), 26, COLOR_TYPE.RED)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_6'), 26,COLOR_TYPE.WHITE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	richText:addElement(re2)
    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(238,365))
    richText:format(true)
    bg3:addChild(richText)


    local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(500, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('FIRSTRECHARGE_7'), 26, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setShadow(cc.c4b(0, 0, 0, 255), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

	richText2:addElement(re1)
    richText2:setAlignment('left')
    richText2:setVerticalAlignment('middle')
	richText2:setAnchorPoint(cc.p(1,0.5))
	richText2:setPosition(cc.p(260 + 758,365 - 40))
    richText2:format(true)
    bg3:addChild(richText2)

    self.tempData = GameData:getConfData('avfirstpay')
    local bg = bg3:getChildByName('bg')
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    local rewardCell = bg3:getChildByName('cell')
    rewardCell:setVisible(false)
    self.sv = sv
    self.rewardCell = rewardCell
    self:refreshSV()

    bg3:setOpacity(0)
    bg3:runAction(cc.FadeIn:create(0.3))
end

function FirstRechargeUI:refreshSV()
    local val = UserData:getUserObj():getMark().first_pay_get_reward_time
    if val == 0 then
        return
    end
    self.datas = {}
    for i = 1,#self.tempData do
        local v = clone(self.tempData[i])
        
        local target1 = v.target1
        local target2 = v.target2
        local progress = self.data.first_pay.progress[tostring(i)]
        local rewards = self.data.first_pay.rewards

        local progress1 = progress[tostring(1)] or 0
        local progress2 = progress[tostring(2)] or 0
        if (progress1 >= target1) or (target2 > 0 and progress2 >= target2) then
            if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                v.showStatus = 1
            else
                v.showStatus = 3
            end
        else
            v.showStatus = 2
        end
        table.insert(self.datas,v)
    end

    table.sort(self.datas,function(a, b)
        if a.showStatus == b.showStatus then
            return tonumber(a.id) < tonumber(b.id)
        else
            return a.showStatus > b.showStatus
        end
	end)

    self.sv:removeAllChildren()
    self:updateSV()
end

function FirstRechargeUI:updateSV()
    local num = #self.datas
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = math.ceil(num/2) * self.rewardCell:getContentSize().height +  (math.ceil(num/2) - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local cellTotalHeight = 0
    local tempHeight = self.rewardCell:getContentSize().height
    for i = 1,num do
        local tempCell = self.rewardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local posx = 3
        if i%2 == 0 then
            posx = 384 + 10
        end

        local curCellHeight = 0
        if i%2 == 1 then
            curCellHeight = tempCell:getContentSize().height
        end

        local curSpace = 0
        if i == 1 or i == 2 then
            curSpace = 0
        else
            if i%2 == 1 then
                curSpace = cellSpace
            end
        end
        cellTotalHeight = cellTotalHeight + curCellHeight + curSpace
        tempCell:setPosition(cc.p(posx,allHeight - cellTotalHeight))
        self.sv:addChild(tempCell)

        local confData = self.datas[i]
        tempCell:loadTexture('uires/ui/common/common_bg_26.png')

        local awards = DisplayData:getDisplayObjs(confData.awards)
        for j = 1,2 do
            local icon = tempCell:getChildByName('icon' .. j)
            if awards[j] then
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards[j],icon)
                cell.awardBgImg:setPosition(cc.p(94/2,94/2))
                cell.awardBgImg:loadTexture(awards[j]:getBgImg())
                cell.chipImg:setVisible(true)
                cell.chipImg:loadTexture(awards[j]:getChip())
                cell.lvTx:setString('x'..awards[j]:getNum())
                cell.awardImg:loadTexture(awards[j]:getIcon())
                local godId = awards[j]:getGodId()
                awards[j]:setLightEffect(cell.awardBgImg)
            else
                icon:setVisible(false)
            end
        end

        local got = tempCell:getChildByName('got')
        local getBtn = tempCell:getChildByName('get_btn')
        getBtn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))

        local gotoBtn = tempCell:getChildByName('goto_btn')
        self.gotoBtn = gotoBtn
        gotoBtn:setVisible(false)
        gotoBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('ACTIVITY_VIPLIMIT4'))

        local target1 = confData.target1
        local target2 = confData.target2
        local progress = self.data.first_pay.progress[tostring(confData.id)]
        local rewards = self.data.first_pay.rewards

        local progress1 = progress[tostring(1)] or 0
        local progress2 = progress[tostring(2)] or 0
        if (progress1 >= target1) or (target2 > 0 and progress2 >= target2) then
            if rewards[tostring(confData.id)] and rewards[tostring(confData.id)] == 1 then 
                getBtn:setVisible(false)
                got:setVisible(true)
                got:loadTexture(HASGETAWARD)
            else 
                getBtn:setVisible(true)
                got:setVisible(false)
            end
        else
            getBtn:setVisible(false)
            got:setVisible(true)
            got:loadTexture(NOTREATCH)
        end

        getBtn:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                MessageMgr:sendPost('get_first_pay_reward','activity',json.encode({id = confData.id}),
		        function(response)
			        if(response.code == 0) then
    			        local awards = response.data.awards
    			        if awards then
    				        GlobalApi:parseAwardData(awards)
    				        GlobalApi:showAwardsCommon(awards,nil,nil,true)
    			        end
                        
                        self.data.first_pay.rewards[tostring(confData.id)] = 1
                        UserData:getUserObj().activity.first_pay = self.data.first_pay
                        self:refreshSV()
                    elseif jsonObj.code == 1 then
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LVGROWFUND_DES2'),COLOR_TYPE.RED)
                        else
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LVGROWFUND_DES3'),COLOR_TYPE.RED)
                    end
		        end)
            end 
        end)

        -- ±êÌâ
        local richText = xx.RichText:create()
        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')
	    richText:setContentSize(cc.size(5000, 40))
	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(20,119))
	    tempCell:addChild(richText)

        local re1 = xx.RichTextLabel:create('\n',26, COLOR_TYPE.PALE)
	    re1:setFont('font/gamefont.ttf')
	    re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
	    richText:addElement(re1)
	    xx.Utils:Get():analyzeHTMLTag(richText,confData.desc)
        richText:format(true)
        
    end
    innerContainer:setPositionY(size.height - allHeight)

end


function FirstRechargeUI:ActionClose(call)
	-- AudioMgr.stopEffect(self.audioId)
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	bg2:runAction(cc.FadeOut:create(0.15))
	bg2:runAction(cc.Sequence:create(cc.DelayTime:create(0.15),cc.CallFunc:create(function ()
		self:hideUI()
		if(call ~= nil) then
			return call()
		end
	end)))
end

-- 创建特效动画
function FirstRechargeUI:createEffectAnim(size) 
    local effect = GlobalApi:createLittleLossyAniByName("ui_light_effect")
    -- effect:getAnimation():playWithIndex(0, -1, 1)
    effect:getAnimation():play('idle', -1, 1)
    effect:setName('ui_light_effect')
    effect:setPosition(cc.p(size.width/2,size.height/2))
    effect:setLocalZOrder(-2)
    effect:setVisible(true)
    return effect
end

-- 创建粒子特效
function FirstRechargeUI:createParticleEffect(url,scale)
    local particle = cc.ParticleSystemQuad:create(url)
    -- local localOrder = order or 0
    local localScale = scale or 1
    particle:setScale(localScale)
    -- particle:setLocalZOrder(localOrder)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    -- particle:setPosition(cc.p(size.width/2, size.height/2+20))
    return particle
end

return FirstRechargeUI