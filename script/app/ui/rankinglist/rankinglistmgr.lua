local ClassRankingListUI = require("script/app/ui/rankinglist/rankinglistmain")
local ClassRankingListV3UI = require("script/app/ui/rankinglist/rankinglistmain_v3")

cc.exports.RankingListMgr = {
	uiClass = {
		rankingListMainUI = nil,
		rankingListV3UI = nil,
	}
}

setmetatable(RankingListMgr.uiClass, {__mode = "v"})
--增加一个menutab ,用于选择显示某一段排行榜，目前只支持连续的一段
function RankingListMgr:showRankingListMain(page, subpage,menutab)
	if page == nil then
		page = 1
	end
	page = tonumber(page)

	if self.uiClass.rankingListV3UI == nil then
		print('create new panel ...................')
		self.uiClass.rankingListV3UI = ClassRankingListV3UI.new(menutab)
	end
	if self.uiClass.rankingListV3UI:getData(page, subpage) == nil then
		print('msg msg msg msg msg msg msg msg msg msg msg msg msg msg ')
		local ui = self.uiClass.rankingListV3UI
		local menuTree = self.uiClass.rankingListV3UI.menuTree
		local args = menuTree[page].msg_arg
		if menuTree[page].sub_title ~= nil then
			args = menuTree[page].sub_title[subpage].msg_arg
		end
		MessageMgr:sendPost(menuTree[page].msg_act, menuTree[page].msg_mod,json.encode(args),function (jsonObj)
			if 0 ~= jsonObj.code then
				return
			end
			-- print('*********************************************************')
			-- print(json.encode(jsonObj))
			ui:addData(jsonObj.data, page, subpage)
			ui:showUI()
			ui:changeTo(page, subpage,menutab)
		end)
		return
	end
	self.uiClass.rankingListV3UI:showUI()
	self.uiClass.rankingListV3UI:changeTo(page, subpage,menutab)
end

function RankingListMgr:hideRankingListMain()
	if self.uiClass.rankingListV3UI then
		self.uiClass.rankingListV3UI:hideUI()
		self.uiClass.rankingListV3UI = nil
	end
end

