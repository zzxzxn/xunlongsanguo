local ClassCampaignMainUI = require("script/app/ui/campaign/campaignmainui")
local ClassRescopyDifficultyUI = require("script/app/ui/campaign/rescopydifficultyui")


cc.exports.CampaignMgr = {
	uiClass = {
		campaignMainUI = nil,
		rescopyDifficultyUI = nil
	}
}

setmetatable(CampaignMgr.uiClass, {__mode = "v"})

function CampaignMgr:showCampaignMain(index,index1)
	index = index or 1
	index1 = index1 or 1
	if self.uiClass["campaignMainUI"] == nil then
		self.uiClass["campaignMainUI"] = ClassCampaignMainUI.new(index,index1)
		self.uiClass["campaignMainUI"]:showUI()
	end
end

function CampaignMgr:hideCampaignMain()
	if self.uiClass["campaignMainUI"] then
		self.uiClass["campaignMainUI"]:hideUI()
		self.uiClass["campaignMainUI"] = nil
	end
end

function CampaignMgr:updateCampaignMain()
	if self.uiClass["campaignMainUI"] then
		self.uiClass["campaignMainUI"]:updatePanel()
	end
end

function CampaignMgr:updateExtraInfo()
	if self.uiClass["campaignMainUI"] then
		self.uiClass["campaignMainUI"]:updateExtraInfo()
	end
end

function CampaignMgr:showRescopyDifficulty(currId, difficulty)
	if self.uiClass["rescopyDifficultyUI"] == nil then
		self.uiClass["rescopyDifficultyUI"] = ClassRescopyDifficultyUI.new(currId, difficulty)
		self.uiClass["rescopyDifficultyUI"]:showUI()
	end
end

function CampaignMgr:hideRescopyDifficulty()
	if self.uiClass["rescopyDifficultyUI"] then
		self.uiClass["rescopyDifficultyUI"]:hideUI()
		self.uiClass["rescopyDifficultyUI"] = nil
	end
end


function CampaignMgr:updateShowGuard()
	if self.uiClass["campaignMainUI"] ~= nil then
        self.uiClass["campaignMainUI"]:updateShowGuard()
	end
end

function CampaignMgr:updateShowRescopy()
	if self.uiClass["campaignMainUI"] ~= nil then
        self.uiClass["campaignMainUI"]:updateShowRescopy()
	end
end

function CampaignMgr:updateRescopyAddBtn()
	if self.uiClass["campaignMainUI"] ~= nil then
        self.uiClass["campaignMainUI"]:updateRescopyAddBtn()
	end
end