local ClassArenaReportCell = require('script/app/ui/arena/arenareportcell')

local ArenaV2ReportUI = class('ArenaV2ReportUI', BaseUI)

function ArenaV2ReportUI:ctor()
	self.uiIndex = GAME_UI.UI_ARENA_V2_REPORT
	self.reportCellNum = 0
	self.maxReportCellNum = 0
	self.reportCellTotalHeight = 10
	self.reportList = {}
end

function ArenaV2ReportUI:init()
	local arenarankBgImg = self.root:getChildByName('arenarank_bg_img')
	local arenarankAlphaImg = arenarankBgImg:getChildByName('arenarank_alpha_img')
	self:adaptUI(arenarankBgImg, arenarankAlphaImg)

	local arenarankImg = arenarankAlphaImg:getChildByName('arenarank_img')
	self.noReportImg = arenarankImg:getChildByName('no_report_img')
	local closeBtn = arenarankImg:getChildByName('close_btn')
	closeBtn:addClickEventListener(function ()
		ArenaMgr:hideArenaV2Report()
	end)

	local title_bg = arenarankImg:getChildByName('title_bg')
	local title_tx = title_bg:getChildByName('title_tx')
	title_tx:setString(GlobalApi:getLocalStr('STR_BATTLE_REPORT1'))
	-- reportLabel:enableOutline(COLOROUTLINE_TYPE.BLACK, 1)
	-- reportLabel:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))

	local reportNode = arenarankImg:getChildByName('report_node')
	self.reportNode = reportNode

	local reportSv = reportNode:getChildByName('report_sv')
	reportSv:setScrollBarEnabled(false)
	self.reportSv = reportSv
	local function scrollViewEvent2(sender, evenType)
		if evenType == ccui.ScrollviewEventType.scrollToBottom then
			self:addReportCells()
		end
	end
	reportSv:addEventListener(scrollViewEvent2)
	self.reportSvSize = reportSv:getContentSize()
	self.reportContentWidget = ccui.Widget:create()
	reportSv:addChild(self.reportContentWidget)

	local obj = {
		uid = UserData:getUserObj():getUid()
	}
	MessageMgr:sendPost('get_report', 'arena', json.encode(obj), function (jsonObj)
		-- print(json.encode(jsonObj))
		if jsonObj.code == 0 then
			self.reportList = jsonObj.data.report
			self.maxReportCellNum = #self.reportList
			self.noReportImg:setVisible(self.maxReportCellNum <= 0)
			self:addReportCells()
		end
	end)
end

function ArenaV2ReportUI:addReportCells()
	table.sort( self.reportList, function(a,b)
		return a[1] > b[1]
	end )
	if self.reportCellNum < self.maxReportCellNum then -- 每次创建10个
		local currNum = self.reportCellNum
		self.reportCellNum = self.reportCellNum + 20
		self.reportCellNum = self.reportCellNum > self.maxReportCellNum and self.maxReportCellNum or self.reportCellNum
		for i = currNum + 1, self.reportCellNum do
			local cell = ClassArenaReportCell.new(self.reportList[i], i)
			local w, h = cell:getSize()
			self.reportCellTotalHeight = self.reportCellTotalHeight + h + 5
			cell:setPosition(cc.p(0, h*0.5 - self.reportCellTotalHeight + 10))
			self.reportContentWidget:addChild(cell:getPanel())
		end
		local posY = self.reportSvSize.height
		if self.reportCellTotalHeight > posY then
			posY = self.reportCellTotalHeight
		end
		self.reportSv:setInnerContainerSize(cc.size(self.reportSvSize.width, posY))
		self.reportContentWidget:setPosition(cc.p(self.reportSvSize.width*0.5, posY))
	end
end

return ArenaV2ReportUI
