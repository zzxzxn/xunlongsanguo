local LvGrowFundUI = class("LvGrowFundUI", BaseUI)
-- 通用的item数据显示模型
local ClassItemCell = require('script/app/global/itemcell')

function LvGrowFundUI:ctor(data)
	self.uiIndex = GAME_UI.UI_LV_GROW_FUND
	self.maxNum = 0
	-- 获取人物当前的等级
	self.lv = UserData:getUserObj():getLv()
	self.isCanGet = false
	-- 获取服务器的数据进行矫正
	self.cells = {}
	self.conf = GameData:getConfData("avlvgrowfund")
	self:getData(data)

	-- 新增是否在每日首登中点击
	local uid = UserData:getUserObj():getUid()
	cc.UserDefault:getInstance():setBoolForKey(uid.."LvGrowFund",false)
end

-- 获取到界面显示数据
function LvGrowFundUI:getData(data)
	self.data =data.grow_fund
	-- 判断是否已经购买
	if self.data.bought and self.data.bought == 1 then
		self.isCanGet = true
	end
end

-- 更新list界面的显示
function LvGrowFundUI:updatePanel()	
	local maxNum = 0	-- 用于计算cell的位置
	local size   		-- cell的大小
	local differSize = 5 	-- 上下的间距
	local conf = self.conf
	if not(conf) then
		conf =  GameData:getConfData("avlvgrowfund")
	end
	local data = self.data  
	local awardsData = self.data.rewards

	-- 创建显示
	for k,v in ipairs(conf) do
		if self.cells[k] == nil then
			local node = cc.CSLoader:createNode('csb/lvgrowfundcell.csb')
			local bgImg = node:getChildByName('bg_img')
			bgImg:removeFromParent(false)
			self.Sv:addChild(bgImg)
			self.cells[k] = bgImg

			local getBtn = bgImg:getChildByName('get_btn')
			local nameTx = getBtn:getChildByName('info_tx')
			local gradeTx = bgImg:getChildByName('grade_tx')
			local noGetBtn = bgImg:getChildByName('noget_btn')
			local noGetTx = noGetBtn:getChildByName('info_tx')

			bgImg.getBtn = getBtn
			bgImg.nameTx = nameTx
			bgImg.gradeTx = gradeTx
			bgImg.noGetBtn = noGetBtn
			bgImg.noGetTx = noGetTx
			
			getBtn:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	-- 刷新界面
                    local function callBack()
                        local args = {
                            id = v.id
                        }
                        MessageMgr:sendPost('get_lv_grow_fund_reward','activity',json.encode(args),function (jsonObj)
                            if jsonObj.code == 0 then
                                local awards = jsonObj.data.awards
                                if awards then
                                    GlobalApi:parseAwardData(awards)
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                                end
                                local costs = jsonObj.data.costs
                                if costs then
                                    GlobalApi:parseAwardData(costs)
                                end
                                -- 修改活动数据，刷新显示
                                self.data.rewards[tostring(args.id)] = 1
                                UserData:getUserObj().activity.lv_grow_fund = self.data


								self.Sv:removeChild(bgImg)
                            elseif jsonObj.code == 1 then
                                	promptmgr:showSystenHint(GlobalApi:getLocalStr('LVGROWFUND_DES2'),COLOR_TYPE.RED)
                                else
                                	promptmgr:showSystenHint(GlobalApi:getLocalStr('LVGROWFUND_DES3'),COLOR_TYPE.RED)
                            end
                        end)
                    end

                    callBack()
		        end
		    end)

		    -- 更新奖励物品信息
			for i = 1,2 do
				local bg = bgImg:getChildByName('node_'..i)
				local index = "awards"..i
				local showAwards = DisplayData:getDisplayObjs(v[index])
				if showAwards then
					local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, showAwards[1], bg)
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
				end
			end 
		end

		local bgImg = self.cells[k]
		size = bgImg:getContentSize()

		-- 判断是否可以领取
		bgImg.noGetBtn:setVisible(true)
		bgImg.getBtn:setVisible(false)

		if self.lv >= v.condition and self.data.bought == 1 then
			if self.data.rewards and self.data.rewards[tostring(v.id)] == 1 then
				-- bgImg.noGetBtn:setVisible(false)
				-- bgImg.getBtn:setVisible(true)
				-- bgImg.nameTx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
				-- bgImg.getBtn:setTouchEnabled(false)
				-- bgImg.getBtn:setBright(false)
				self.Sv:removeChild(bgImg)
			else
				bgImg.noGetBtn:setVisible(false)
				bgImg.getBtn:setVisible(true)
				bgImg.nameTx:setString(GlobalApi:getLocalStr('STR_GET'))
			end	
		end

		bgImg.gradeTx:setString(v.condition)

	end
end

function  LvGrowFundUI:refrshUI()
	-- 数据发生变化
	MessageMgr:sendPost("get_lv_grow_fund", "activity", "{}", function (jsonObj)
			local data = jsonObj.data
        	if jsonObj.code == 0 then
        		-- 重新获取数据
        		self:getData(data)
        		-- 更具数据变化重新给列表进行刷新
				self:updatePanel()
			end
	    end)
end

-- 初始化界面
function LvGrowFundUI:init()
	local bgImg = self.root:getChildByName("bg_img")
	local bgImg1 = bgImg:getChildByName("bg_img1")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
	bgImg1:setPosition(cc.p(winSize.width/2,winSize.height/2 - 30))

    local closeBtn = bgImg1:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:hideLvGrowFundUI()
	    end
	end)
	-- list界面
    self.Sv = bgImg1:getChildByName('cell_sv')
    self.Sv:setScrollBarEnabled(false)


    -- 购买按钮
    local getBuyBtn = bgImg1:getChildByName('goto_btn')
	local infoTx = getBuyBtn:getChildByName('tx')
	self.infoTx = infoTx
	self.getBuyBtn = getBuyBtn
	infoTx:setString(GlobalApi:getLocalStr('BUY'))

	local playData = GameData:getConfData("recharge")
    getBuyBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	-- print("开启购买的接口")
        	local info = GameData:getConfData("recharge")[111]
            RechargeMgr:pay(info,function(code)
            	-- print("进入支付流程")
                self:buyCallback(code)
            end)
	    end
	end)

	if self.isCanGet then
		getBuyBtn:setTouchEnabled(false)
		getBuyBtn:setBright(false)
		self.infoTx:setString(GlobalApi:getLocalStr('PURCHASED'))
	end

    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(480, 40))

	local re1 = xx.RichTextLabel:create(" "..GlobalApi:getLocalStr('LVGROWFUND_DES1'), 20, cc.c4b(254,227,134,255))
	re1:setStroke(cc.c4b(140,56,0,255),1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(" "..GameData:getConfData('global').lvRewardlv.value.."级", 24, COLOR_TYPE.GREEN)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LVGROWFUND_DES4'), 20, cc.c4b(254,227,134,255))
	re3:setStroke(cc.c4b(140,56,0,255),1)
    re3:setFont('font/gamefont.ttf')

	local re4 = xx.RichTextLabel:create(tostring(playData[111].amount).."元", 24, COLOR_TYPE.GREEN)
    re4:setFont('font/gamefont.ttf')

    richText:addElement(re4)
	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(360,450))
    bgImg1:addChild(richText)
    richText:format(true)

	self:updatePanel()


    CustomEventMgr:addEventListener("get_recharge_raward",self,function (code) 
        self:buyCallback(code)
    end)
	local function onNodeEvent(event)
		if "exit" == event then
            CustomEventMgr:removeEventListener("get_recharge_raward",self)
        end
    end
    self.root:registerScriptHandler(onNodeEvent)
    
end

function LvGrowFundUI:buyCallback(code)
	if code == 1 then -- 购买成功
		self.infoTx:setString(GlobalApi:getLocalStr('HAD_BOUGHT'))
		self.getBuyBtn:setTouchEnabled(false)
		self.getBuyBtn:setBright(false)
		self:refrshUI()
	elseif jsonObj.code == 100 then 
		promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
	end
end

return LvGrowFundUI