local ClassTavernMainUI = require("script/app/ui/tavern/tavernmainui")
local ClassTavernMainUI2 = require("script/app/ui/tavern/tavernmainui2")
local ClassTavernAnimateUI = require('script/app/ui/tavern/tavernanimateui')
local ClassTavernTenUI = require('script/app/ui/tavern/taverntenui')
local ClassTavernLimitUI = require('script/app/ui/tavern/tavernlimitui')
local ClassTavernLimitAwardUI = require('script/app/ui/tavern/tavernlimitawardui')
local ClassTavernExchangeUI = require('script/app/ui/tavern/tavernexchangeui')
local ClassTavernMasterUI = require('script/app/ui/tavern/tavernmasterui')
cc.exports.TavernMgr = {
	uiClass = {
		tavernMainUI = nil,
		tavernAwardsUI = nil,
		tavernAnimateUI = nil,

        tavernTenUI = nil,
        tavernLimitUI = nil,
        tavernLimitAwardUI = nil,
        tavernExchangeUI = nil,
        tavernMasterUI = nil,
	},
    tavenLimitData = nil,
    luck = 0,
}

setmetatable(TavernMgr.uiClass, {__mode = "v"})

-- 1版
--[[
function TavernMgr:showTavernMain()
    if self.uiClass["tavernMainUI"] == nil then
		self.uiClass["tavernMainUI"] = ClassTavernMainUI.new()
		self.uiClass["tavernMainUI"]:showUI(UI_SHOW_TYPE.STUDIO)
	end
end

function TavernMgr:hideTavernMain()
    if self.uiClass["tavernMainUI"] then
		self.uiClass["tavernMainUI"]:hideUI()
		self.uiClass["tavernMainUI"] = nil
	end
end
--]]

-- 2版
function TavernMgr:showTavernMain()
    if self.uiClass["tavernMainUI"] == nil then
        if self.uiClass["tavernLimitUI"] == nil then
            MessageMgr:sendPost('get_hot','tavern',json.encode({}),function(jsonObj)
                print("     showTavernMain    ",json.encode(jsonObj))
                if(jsonObj.code ~= 0) then
                    return
                end
                self.tavenLimitData = jsonObj.data.tavern
                self.world_hot = jsonObj.data.world_hot

                self.uiClass["tavernMainUI"] = ClassTavernMainUI2.new()
		        self.uiClass["tavernMainUI"]:showUI(UI_SHOW_TYPE.STUDIO)
            end)
	    end
	end
end

function TavernMgr:hideTavernMain()
    if self.uiClass["tavernMainUI"] then
		self.uiClass["tavernMainUI"]:hideUI()
		self.uiClass["tavernMainUI"] = nil
	end
end

function TavernMgr:showTavernMainFromFight(fightIndex)
    if self.uiClass["tavernMainUI"] == nil then
        if self.uiClass["tavernLimitUI"] == nil then
            MessageMgr:sendPost('get_hot','tavern',json.encode({}),function(jsonObj)
                print("     showTavernMainFromFight    ",json.encode(jsonObj))
                if(jsonObj.code ~= 0) then
                    return
                end
                self.tavenLimitData = jsonObj.data.tavern

                self.uiClass["tavernMainUI"] = ClassTavernMainUI2.new()
		        self.uiClass["tavernMainUI"]:showUI(UI_SHOW_TYPE.STUDIO)
                --print('+++++++++++++++++++++++' .. fightIndex)
                if fightIndex == 1 then
                    ChartMgr:showChartMain(fightIndex)
                elseif fightIndex == 2 then
                    self:showTavernLimitUI()
                    ChartMgr:showChartMain(fightIndex)
                elseif fightIndex == 3 then
                    self:showTavernTenUI()
                    ChartMgr:showChartMain(fightIndex)
                end
                
            end)
	    end
	end
end

function TavernMgr:UpdateTavernMain()
	if self.uiClass["tavernMainUI"] then
		self.uiClass["tavernMainUI"]:update()
	end
end

function TavernMgr:UpdateTavernLimitUI()
	if self.uiClass["tavernMainUI"] then
		self.uiClass["tavernMainUI"]:upLimitAward()
	end
end

function TavernMgr:showTavernAnimate(awards, func, recuitetype)
    if self.uiClass["tavernAnimateUI"] == nil then
		self.uiClass["tavernAnimateUI"] = ClassTavernAnimateUI.new(awards, func, recuitetype)
		self.uiClass["tavernAnimateUI"]:showUI()
	end
end

function TavernMgr:hideTavernAnimate()
    if self.uiClass["tavernAnimateUI"] then
		self.uiClass["tavernAnimateUI"]:hideUI()
		self.uiClass["tavernAnimateUI"] = nil
        SpineCache:del_s('qianglingpai')
		--UIManager:clearCamera()
	end
end

function TavernMgr:recuit(index)
    if self.uiClass["tavernMainUI"] then
		self.uiClass["tavernMainUI"]:recuit(index)
	end
end

function TavernMgr:recuitTen(index,useid)
    if self.uiClass["tavernTenUI"] then
		self.uiClass["tavernTenUI"]:recuit(index,useid)
	end
end

function TavernMgr:showTavernTenUI()
    if self.uiClass["tavernTenUI"] == nil then
        MessageMgr:sendPost('get','tavern',"{}",function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.luck = data.luck
                self.uiClass["tavernTenUI"] = ClassTavernTenUI.new()
                self.uiClass["tavernTenUI"]:showUI(UI_SHOW_TYPE.STUDIO)
            end
        end)
    end
end

function TavernMgr:getLuck()
    return self.luck
end

function TavernMgr:hideTavernTenUI()
    if self.uiClass["tavernTenUI"] then
		self.uiClass["tavernTenUI"]:hideUI()
		self.uiClass["tavernTenUI"] = nil
	end
end

function TavernMgr:UpdateTavernTenUI()
	if self.uiClass["tavernTenUI"] then
		self.uiClass["tavernTenUI"]:update()
	end
end

function TavernMgr:showTavernLimitUI()
    if self.uiClass["tavernLimitUI"] == nil then
        self.uiClass["tavernLimitUI"] = ClassTavernLimitUI.new()
		self.uiClass["tavernLimitUI"]:showUI()
	end
end

function TavernMgr:showTavernLimitUI2()
	if self.uiClass["tavernLimitUI"] == nil then
        if self.uiClass["tavernLimitUI"] == nil then
            MessageMgr:sendPost('get_hot','tavern',json.encode({}),function(jsonObj)
                print("     showTavernLimitUI2    ",json.encode(jsonObj))
                if(jsonObj.code ~= 0) then
                    return
                end
                self.tavenLimitData = jsonObj.data.tavern
                self.world_hot = jsonObj.data.world_hot

				self.uiClass["tavernLimitUI"] = ClassTavernLimitUI.new()
				self.uiClass["tavernLimitUI"]:showUI()
            end)
	    end
	end
end

function TavernMgr:hideTavernLimitUI()
    if self.uiClass["tavernLimitUI"] then
		self.uiClass["tavernLimitUI"]:hideUI()
		self.uiClass["tavernLimitUI"] = nil
	end
end

function TavernMgr:UpdateTavernMainLimitUIRefresh()
	if self.uiClass["tavernLimitUI"] then
		self.uiClass["tavernLimitUI"]:refresh()
	end
end

function TavernMgr:showTavernLimitAwardUI(type,awards)
    if self.uiClass["tavernLimitAwardUI"] == nil then
		self.uiClass["tavernLimitAwardUI"] = ClassTavernLimitAwardUI.new(type,awards)
		self.uiClass["tavernLimitAwardUI"]:showUI()
	end
end

function TavernMgr:hideTavernLimitAwardUI()
    if self.uiClass["tavernLimitAwardUI"] then
		self.uiClass["tavernLimitAwardUI"]:hideUI()
		self.uiClass["tavernLimitAwardUI"] = nil
	end
end


function TavernMgr:showTavernExchangeUI()
    if self.uiClass["tavernExchangeUI"] == nil then
		self.uiClass["tavernExchangeUI"] = ClassTavernExchangeUI.new()
		self.uiClass["tavernExchangeUI"]:showUI()
	end
end

function TavernMgr:hideTavernExchangeUI()
    if self.uiClass["tavernExchangeUI"] then
		self.uiClass["tavernExchangeUI"]:hideUI()
		self.uiClass["tavernExchangeUI"] = nil
	end
end

function TavernMgr:getTavenLimitData()
    return self.tavenLimitData
end

--- 得到下次限时热点武将（循环算法）
function TavernMgr:getNextId()
    local curId = self.world_hot
    local temp = {}

    local tavernHotConf = GameData:getConfData("tavernhot")
    for k,v in ipairs(tavernHotConf) do
        if v.type == 1 then
            table.insert(temp,v.id)
        end
    end

    local curIndex

    while (curIndex == nil) do
        for i = 1,#temp,1 do
            if temp[i] == curId  then
                curIndex = curId + 1
                if tavernHotConf[tonumber(curIndex)]['type'] == 1 and tavernHotConf[tonumber(curIndex)]['hotRound'] == 1 then
                    break
                else
                    curIndex = nil
                    if curId == #temp then
                        curId = 0
                    end
                    curId = curId + 1
                end
            end
        end
    end

    return temp[curIndex]
end

--- 招募
function TavernMgr:buyHot(type,callBack)
    local function callBackBuyHot()
        local judge = false
        if type == 'love' then
            judge = true
        end
        local args = { isLovebuy = judge }
        MessageMgr:sendPost("buy_hot", "tavern", json.encode(args), function (jsonObj)
			print(json.encode(jsonObj))
			local code = jsonObj.code
			if code == 0 then -- 将星值
                if type == 'cash' then
                    UserData:getUserObj():addActivityTavernFrequency(2)
                end
				local awards = jsonObj.data.awards
				GlobalApi:parseAwardData(awards)
				local costs = jsonObj.data.costs
				if costs then
					GlobalApi:parseAwardData(costs)
				end

                if type == 'cash' then
                    if jsonObj.data.hot_time then
                        UserData:getUserObj():setTavenHotTime(jsonObj.data.hot_time)
                    end
                end

                -- 增加将星值
                local luckValue = UserData:getUserObj():getTavenLuck()
                luckValue = luckValue + self:getAddLuckValue()
                UserData:getUserObj():setTavenLuck(luckValue)

				self:UpdateTavernMainLimitUIRefresh()
                self:UpdateTavernLimitUI()

                if callBack then
                    callBack(awards)
                end

			end
		end)
    end

    if type == 'love' then
        local tavernCostLoveNum = tonumber(GlobalApi:getGlobalValue('tavernCostLoveNum'))
        local userLove = UserData:getUserObj():getLove()
        print('===========+++++++++++++++============' .. userLove)
        if userLove < tavernCostLoveNum then            
            promptmgr:showSystenHint(GlobalApi:getLocalStr("TAVERN_LIMIT_GET_DES9"), COLOR_TYPE.RED)
        else
            callBackBuyHot()
        end
    else
        if UserData:getUserObj():judgeTavenLimitState() == true then -- 本次免费
            callBackBuyHot()
        else
            if UserData:getUserObj():getCash() < tonumber(GlobalApi:getGlobalValue('tavernHotCashCost')) then
	            promptmgr:showMessageBox(GlobalApi:getLocalStr('NOT_ENOUGH_GOTO_BUY'), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
				        GlobalApi:getGotoByModule('cash')
			        end,GlobalApi:getLocalStr('MESSAGE_GO_CASH'),GlobalApi:getLocalStr('MESSAGE_NO'))
	        else
		        callBackBuyHot()  
	        end
        end
    end
end

--- 将星值兑换
function TavernMgr:exchangeHot(callBack)
	MessageMgr:sendPost("exchange_hot", "tavern", json.encode({}), function (jsonObj)
		print(json.encode(jsonObj))
		local code = jsonObj.code
		if code == 0 then
			local awards = jsonObj.data.awards
			GlobalApi:parseAwardData(awards)
            
            -- 扣除将星值
            local luckValue = UserData:getUserObj():getTavenLuck()
            UserData:getUserObj():setTavenLuck(luckValue - self:exchangeCostLuckValue())

            self:UpdateTavernMainLimitUIRefresh()

            if callBack then
                callBack(awards)
            end

		end
	end)
    
end

--- 酒馆招募一次增加将星值
function TavernMgr:getAddLuckValue()
    return tonumber(GlobalApi:getGlobalValue('tavernHotLuck'))

end

--- 酒馆兑换一次武将消耗的将星值
function TavernMgr:exchangeCostLuckValue()
    return tonumber(GlobalApi:getGlobalValue('tavernHotExchangeLuck'))

end

--- 酒馆将星值上限值
function TavernMgr:getExchangeCostMaxLuckValue()
    return tonumber(GlobalApi:getGlobalValue('tavernHotExchangeLuck'))

end

function TavernMgr:showTavernMasterUI(func)
    if self.uiClass["tavernMasterUI"] == nil then
        MessageMgr:sendPost('get_luck_list','tavern',"{}",function (response)
            local code = response.code
            local data = response.data
            if code == 0 then
                self.uiClass["tavernMasterUI"] = ClassTavernMasterUI.new(func,data)
                self.uiClass["tavernMasterUI"]:showUI()
            end
        end)
    end
end

function TavernMgr:hideTavernMasterUI()
    if self.uiClass["tavernMasterUI"] then
        self.uiClass["tavernMasterUI"]:hideUI()
        self.uiClass["tavernMasterUI"] = nil
    end
end