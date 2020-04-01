local CampaignBasePanel = class("CampaignBasePanel")

function CampaignBasePanel:ctor()
end

function CampaignBasePanel:getPanel()
    return self.root
end

function CampaignBasePanel:hidePanel()
    self.root:setVisible(false)
end

function CampaignBasePanel:showPanel()
    self.root:setVisible(true)
end

function CampaignBasePanel:getExtraInfos()
    return {}
end

function CampaignBasePanel:enterCampaign()
end

function CampaignBasePanel:updatePanel()
end

function CampaignBasePanel:getDesc()
	return nil
end

function CampaignBasePanel:onClickAddBtn()
end

function CampaignBasePanel:isShowAddBtn()
	return false
end

return CampaignBasePanel