local CampaignBasePanel = require("script/app/ui/campaign/campaignbasepanel")
local CampaignPatrolPanel = class("CampaignPatrolPanel", CampaignBasePanel)

function CampaignPatrolPanel:ctor(index, showByClick)
    self.root = cc.CSLoader:createNode('csb/campaignpatrolpanel.csb')
end

function CampaignPatrolPanel:enterCampaign()
    GlobalApi:getGotoByModule('patrol')
end

return CampaignPatrolPanel