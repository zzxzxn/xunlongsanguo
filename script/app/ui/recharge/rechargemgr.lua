cc.exports.RechargeMgr = {
	uiClass = {
		rechargeUI = nil,
		firstRechargeUI = nil,
		rechargeWaittingUI = nil
	},
	vipChanged = false,

	beforeCash = 0,		--充值前钻石数
	curPayConf = nil	--当前充值配置数值
}

setmetatable(RechargeMgr.uiClass, {__mode = "v"})

local ClassRechargeUI = require("script/app/ui/recharge/recharge")
local ClassFirstRechargeUI = require("script/app/ui/recharge/firstrecharge")
local ClassRechargeWaittingUI = require("script/app/ui/recharge/rechargewaitting")

function RechargeMgr:showRecharge(vip)
	if GlobalData:getIsOpenPay() == false then		--屏蔽充值
		promptmgr:showSystenHint(GlobalApi:getLocalStr("TAKE_OFF_CHONGZHI"), COLOR_TYPE.RED)
		return
	end
	
	if self.uiClass['rechargeUI'] == nil then
		self.uiClass['rechargeUI'] = ClassRechargeUI.new(vip)
		self.uiClass['rechargeUI']:showUI()
	end
end

function RechargeMgr:updateRechargeDataByArr(data)
	UserData:getUserObj().cash = data.cash
	UserData:getUserObj():initPayment(data.payment)
	if data.vip then
		UserData:getUserObj().vip = data.vip
	end
	if data.vip_xp then
		UserData:getUserObj().vip_xp = data.vip_xp
	end
	UserData:getUserObj():getMark().first_pay = data.first_pay
	self:updateRecharge()
	UIManager:updateSidebar()
end

function RechargeMgr:updateRechargeData(id)
	local rechargeName = SdkData:getRechargeConfName()
	local conf = GameData:getConfData(rechargeName)[id]
	if not conf then
		return
	end
	local paymentInfo = UserData:getUserObj():getPayment()
	local cash = conf.cash
	if not paymentInfo.pay_list[tostring(id)] or paymentInfo.pay_list[tostring(id)] <= 0 then
		if conf.type ~= 'monthCard' and conf.type ~= 'longCard' then
			cash = cash*2
		end
	end
	GlobalApi:parseAwardData({{'user','cash',cash}})
	paymentInfo.pay_list[tostring(id)] = (paymentInfo.pay_list[tostring(id)] or 0) + 1
	paymentInfo.money = (paymentInfo.money or 0) + conf.amount
	paymentInfo.day_money = (paymentInfo.day_money or 0) + conf.amount
	local vip_xp = UserData:getUserObj():getVipXp()
	vip_xp = vip_xp + conf.cash
	UserData:getUserObj():setVipXp(vip_xp)
	UserData:getUserObj():initPayment(paymentInfo)
	local vipConf = GameData:getConfData('vip')
	local oldVip = UserData:getUserObj():getVip()
	local vip = 0
	for k,v in pairs(vipConf) do
		if v.cash <= vip_xp then
			vip = tonumber(k)
		else
			break
		end
	end
	if (oldVip == tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')) - 1
		and vip == tonumber(GlobalApi:getGlobalValue('promoteOrangeVipRestrict')))
		or (oldVip == tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict')) - 1
		and vip == tonumber(GlobalApi:getGlobalValue('promoteRedVipRestrict'))) then
		self.vipChanged = true
	end
	UserData:getUserObj().vip = vip or 0
	self:updateRecharge()
	UIManager:updateSidebar()
end

function RechargeMgr:updateRecharge()
	if self.uiClass['rechargeUI'] ~= nil then
		self.uiClass['rechargeUI']:updatePanel()
	end
end

function RechargeMgr:hideRecharge()
	if self.uiClass['rechargeUI'] ~= nil then
		self.uiClass['rechargeUI']:hideUI()
		self.uiClass['rechargeUI'] = nil
	end
end

function RechargeMgr:showFirstRecharge()
    
    if self.uiClass['firstRechargeUI'] == nil then
		local args = {}
		MessageMgr:sendPost('get_first_pay','activity',json.encode(args),function (response)		
			local code = response.code
			if code == 0 then
				local data = response.data
				self.uiClass['firstRechargeUI'] = ClassFirstRechargeUI.new(data)
		        self.uiClass['firstRechargeUI']:showUI()
			end
		end)
	end
end

function RechargeMgr:hideFirstRecharge(callback)
	if self.uiClass['firstRechargeUI'] ~= nil then
		self.uiClass['firstRechargeUI']:ActionClose(callback)
		self.uiClass['firstRechargeUI'] = nil
	end
end

function RechargeMgr:queryRecharge()
	-- if SdkData:getSDKPlatform() ~= "dev" then
	-- 	local RechargeHelper = require("script/app/ui/recharge/rechargehelper_" .. SdkData:getSDKPlatform())
	-- 	RechargeHelper:queryRecharge()
	-- end
end

function RechargeMgr:specialRecharge(index, callback)
	-- if SdkData:getSDKPlatform() ~= "dev" then
	-- 	local rechargeConf = GameData:getConfData("recharge")
	-- 	local RechargeHelper = require("script/app/ui/recharge/rechargehelper_" .. SdkData:getSDKPlatform())
	-- 	if RechargeHelper.specialRecharge then
	-- 		RechargeHelper:specialRecharge(index, rechargeConf[index], callback)
	-- 	else
	-- 		local obj = {
	-- 			code = -1
	-- 		}
	-- 		callback(obj)
	-- 	end
	-- end
end

function RechargeMgr:showRechargeWatting()
	if self.uiClass['rechargeWaittingUI'] == nil then
		self.uiClass['rechargeWaittingUI'] = ClassRechargeWaittingUI.new()
		self.uiClass['rechargeWaittingUI']:showUI()
	end
end


function RechargeMgr:hideRechargeWatting()
	if self.uiClass['rechargeWaittingUI'] ~= nil then
		self.uiClass['rechargeWaittingUI']:hideUI()
		self.uiClass['rechargeWaittingUI'] = nil
	end
end


--监听服务器主动向客户端push下发奖励
function RechargeMgr:GetLog()
	CustomEventMgr:addEventListener("user_get_pay",self,RechargeMgr.getRechargeRaward)
end

--支付接口
function RechargeMgr:pay(conf, buyCallback)
	if GlobalData:getIsOpenPay() == false then		--屏蔽充值
		promptmgr:showSystenHint(GlobalApi:getLocalStr("TAKE_OFF_CHONGZHI"), COLOR_TYPE.RED)
		return
	end

	dump(conf)
	--只需要商品ID
	local data = {id = conf.id}
	-- if cc.Application:getInstance():getTargetPlatform() == kTargetWindows then
	-- 	return
	-- end

	self.beforeCash = UserData:getUserObj():getCash()
	self.curPayConf = conf

    MessageMgr:sendPost("get_pay_order", "user", json.encode(data),function (response)
        if response.code == 0 then
        	SdkData.order.orderID = response.data.order  --保存订单号
        	SdkData.order.id = conf.id  --商品ID

            local arr = {
                order = response.data.order,  --订单号
                id = conf.id,       	  	  --商品ID
                amount = conf.amount,         --消耗的RMB
                name = conf.itemName, 		  --商品名称
                desc = conf.desc			  --商品描述
            }

            if SdkData:getSDKPlatform() == "dev" then
            	local code
            	UIManager:showLoadMask()
            	MessageMgr:sendPost("test_pay", "user", json.encode({cash = conf.cash,charge_id = conf.id,amount = conf.amount}),function (response)
            		-- dump(response)
            		if response.code == 0 then
            			print("成功支付")
            			code = 1
            		else
            			code = 0
            			print("支付失败")
            		end
    			    UIManager.touchwidget:runAction(cc.Sequence:create(
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							-- UIManager:hideLoadMask()
		            -- 		if buyCallback then
			        			-- buyCallback(tonumber(code))
			        			-- print("支付的结果是："..code)
			        			if tonumber(code) ~= 1 then
			        				UIManager:hideLoadMask()
			        			end
			        		-- end
						end)
					))
            	end)
            else
            --转圈圈
	            UIManager:showLoadMask()

	            SdkData:SDK_pay(function (code)
	            	if tonumber(code) == 1 then
	            		print("   SDK_pay 支付成功 !!!!!     code = ",code)
	            	else
	            		print("   SDK_pay 支付失败 !!!!!    code  =  ",code)
	            		UIManager:hideLoadMask()

	            		CustomEventMgr:dispatchEvent("get_recharge_raward", 0)
	            	end

	            	--3秒后消失转圈圈
	            	UIManager.touchwidget:runAction(cc.Sequence:create(
						cc.DelayTime:create(3),
						cc.CallFunc:create(function()
							UIManager:hideLoadMask()
						end)
					))

	            	--1,3,8元购礼包需要改变按钮
	          --   	if buyCallback then
	        		-- 	buyCallback(tonumber(code))
	        		-- 	print("支付的结果是："..code)
	        		-- 	if tonumber(code) ~= 1 then
	        		-- 		UIManager:hideLoadMask()
	        		-- 	end
	        		-- end
	            end, arr)
        	end
        end
    end)
end

--请求奖励
function RechargeMgr:getRechargeRaward()
	UIManager:hideLoadMask()
	local data = {orderid = SdkData.order.orderID}
	MessageMgr:sendPost("refresh_pay", "user", json.encode(data),function (response)
        if response.code == 0 then
        	RechargeMgr:updateRechargeDataByArr(response.data)
			CustomEventMgr:dispatchEvent("get_recharge_raward", 1)
        	SdkData:trackPayClient()
        	SdkData.order = {}
        end
    end)
end

function RechargeMgr:getBeforeCash()
	return self.beforeCash
end

function RechargeMgr:getCurPayConf()
	return self.curPayConf
end

return RechargeMgr