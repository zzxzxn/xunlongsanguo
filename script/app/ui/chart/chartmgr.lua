local ChartMainPannelUI = require("script/app/ui/chart/chartmainpannel")
local ChartInfoUI = require("script/app/ui/chart/chartinfo")
local ChartPromotedProviewUI = require("script/app/ui/chart/chartpromoteproview")

cc.exports.ChartMgr = {
	uiClass = {
		chartMainPannelUI = nil,
        chartInfoUI = nil,
        chartPromotedProviewUI = nil
	},
    demoData = {0,0,0,0,0,0,0}   -- 试玩数据
}

cc.exports.ROLE_SHOW_TYPE = {
    NORMAL = 1,         -- 正常显示，没有合成和分解，也不是将星录
	CHART = 2,          -- 将星录
    CHIP_MERGET = 3,    -- 碎片合成
    CARD_DECOMPOSE = 4  -- 卡牌分解
}

setmetatable(ChartMgr.uiClass, {__mode = "v"})

function ChartMgr:showChartMain(fightIndex)
	if self.uiClass["chartMainPannelUI"] == nil then
		self.uiClass["chartMainPannelUI"] = ChartMainPannelUI.new(fightIndex)
		self.uiClass["chartMainPannelUI"]:showUI()
	end
end

function ChartMgr:hideChartMain()
	if self.uiClass["chartMainPannelUI"] then
		self.uiClass["chartMainPannelUI"]:hideUI()
		self.uiClass["chartMainPannelUI"] = nil
	end
end


function ChartMgr:showChartInfo(cardData,showType,obj)
	if self.uiClass["chartInfoUI"] == nil then
		self.uiClass["chartInfoUI"] = ChartInfoUI.new(cardData,showType,obj)
		self.uiClass["chartInfoUI"]:showUI()
	end
end

function ChartMgr:hideChartInfo()
	if self.uiClass["chartInfoUI"] then
		self.uiClass["chartInfoUI"]:ActionClose()
		self.uiClass["chartInfoUI"] = nil
	end
end

function ChartMgr:setDemoDataByIndex(index,id)
	self.demoData[index] = id
end

function ChartMgr:removeDemoDataByIndex(index)
	self.demoData[index] = 0
end

function ChartMgr:clearDemoData()
	for i = 1,#self.demoData do
        self.demoData[i] = 0
    end
end

function ChartMgr:getDemoData()
	return self.demoData
end

function ChartMgr:getDemoDataNum()
    local num = 0
    for i = 1,#self.demoData do
        if self.demoData[i] > 0 then
            num = num + 1
        end
    end

    return num
end

--- 得到接下来最小的索引
function ChartMgr:getMinIndex()
    local index = 1
    for i = 1,#self.demoData do
        if self.demoData[i] == 0 then
            break
        end
        index = index + 1
    end

    return index

end

function ChartMgr:showChartPromotedProviewUI(obj,protype)
	if self.uiClass["chartPromotedProviewUI"] == nil then
		self.uiClass["chartPromotedProviewUI"] = ChartPromotedProviewUI.new(obj,protype)
		self.uiClass["chartPromotedProviewUI"]:showUI()
	end
end

function ChartMgr:hideChartPromotedProviewUI()
	if self.uiClass["chartPromotedProviewUI"] then
		self.uiClass["chartPromotedProviewUI"]:hideUI()
		self.uiClass["chartPromotedProviewUI"] = nil
	end
end