local CampaignMainUI = class("CampaignUI", BaseUI)

function CampaignMainUI:ctor(index,index1)
	self.uiIndex = GAME_UI.UI_CAMPAIGN
    self.panels = {}
    self.currPanel = nil
    self.index = index
    self.index1 = index1
end

function CampaignMainUI:init()
    self.campaignsConf = GameData:getConfData("campaignlist")
    self:initUI()
    self:addCampaigns()
    self:changeCampaign(self.index, false)
end

function CampaignMainUI:initUI()
    local winsize = cc.Director:getInstance():getWinSize()
    local campaignBgImg = self.root:getChildByName("campaign_bg_img")
    campaignBgImg:setContentSize(winsize)
    campaignBgImg:setPosition(cc.p(winsize.width/2, winsize.height/2))

    self.childPanel = self.root:getChildByName("child_panel")
    self.childPanel:setPosition(cc.p(winsize.width/2, winsize.height/2))
    -- 上
    local topTiao = self.root:getChildByName("top_tiao")
    topTiao:setPosition(cc.p(winsize.width/2, winsize.height))
    self.titleLabel = topTiao:getChildByName("title_tx")
    self.infoLabel = topTiao:getChildByName("info_tx")
    -- 下
    local bottomTiao = self.root:getChildByName("bottom_tiao")
    bottomTiao:setPosition(cc.p(winsize.width/2, 0))
    -- 左
    local leftTiao = self.root:getChildByName("left_tiao")
    leftTiao:setPosition(cc.p(0, winsize.height/2))
    -- 右
    local rightTiao = self.root:getChildByName("right_tiao")
    rightTiao:setPosition(cc.p(winsize.width - rightTiao:getContentSize().width, winsize.height/2))
    -- 左上的条
    self.extraBg1 = self.root:getChildByName("extra_bg_1")
    self.extraBg1:setPosition(cc.p(winsize.width/2 - 86, winsize.height - 130))
    self.extraLabel1 = self.root:getChildByName("extra_info_tx_1")
    self.extraLabel1:setPosition(cc.p(winsize.width/2 - 200, winsize.height - 130))
    self.addBtn1 = self.root:getChildByName("extra_add_btn_1")
    self.addBtn1:setPosition(cc.p(winsize.width/2 - 180, winsize.height - 130))
    self.addBtn1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.currPanel:onClickAddBtn()
        end
    end)
    -- 右上的条
    self.extraBg2 = self.root:getChildByName("extra_bg_2")
    self.extraBg2:setPosition(cc.p(winsize.width/2 + 86, winsize.height - 130))
    self.extraLabel2 = self.root:getChildByName("extra_info_tx_2")
    self.extraLabel2:setPosition(cc.p(winsize.width/2 + 200, winsize.height - 130))
    self.addBtn2 = self.root:getChildByName("extra_add_btn_2")
    self.addBtn2:setPosition(cc.p(winsize.width/2 + 180, winsize.height - 130))
    self.addBtn2:setVisible(false)
    -- 关闭按钮
    local closeBtn = self.root:getChildByName("close_btn")
    closeBtn:setPosition(cc.p(winsize.width - 70, winsize.height - 56))
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CampaignMgr:hideCampaignMain()
        end
    end)
    -- 战斗按钮
    local fightBtn = self.root:getChildByName("fight_btn")
    fightBtn:setPosition(cc.p(winsize.width - 90, 62))
    fightBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.currPanel:enterCampaign()
        end
    end)
end

function CampaignMainUI:addCampaigns()
    local num = #self.campaignsConf
    self.buttons = {}
    for i = 1, num do
        local button = ccui.Button:create("uires/ui/campaign/icon_" .. i .. "_n.png", "uires/ui/campaign/icon_" .. i .. "_s.png")
        local newImg = ccui.ImageView:create('uires/ui/common/new_img.png')
        newImg:setName('new_img')
        button:setName("btn_" .. i)
        button:addClickEventListener(function ()
            AudioMgr.PlayAudio(11)
            self.index = i
            self:changeCampaign(i, true)
            for k, v in pairs(self.buttons) do
                if k ~= i then                     
                    v:setTouchEnabled(true)
                    v:setBrightStyle(ccui.BrightStyle.normal)
                end
            end
        end)
        button:addChild(newImg)
        local size = button:getContentSize()
        newImg:setPosition(cc.p(size.width - 30,size.height - 30))
        button:setPosition(cc.p(80 + (i-1)*120, 62))
        self.root:addChild(button)
        self.buttons[i] = button
        if i == 1 then
            newImg:setVisible(UserData:getUserObj():getSignByType('rescopy'))
        elseif i == 2 then
            newImg:setVisible(UserData:getUserObj():getSignByType('shipper'))
        elseif i == 3 then
            newImg:setVisible(UserData:getUserObj():getSignByType('guard'))
        else
            newImg:setVisible(false)
        end
    end
end


function CampaignMainUI:updateShowGuard()
    self.buttons[3]:getChildByName("new_img"):setVisible(UserData:getUserObj():getSignByType('guard'))
end

function CampaignMainUI:updateShowRescopy()
    self.buttons[1]:getChildByName("new_img"):setVisible(UserData:getUserObj():getSignByType('rescopy'))
end

function CampaignMainUI:updateShowShipper()
    self.buttons[2]:getChildByName("new_img"):setVisible(UserData:getUserObj():getSignByType('shipper'))
end

function CampaignMainUI:changeCampaign(index, showByClick)
    self.buttons[index]:setTouchEnabled(false)
    self.buttons[index]:setBrightStyle(ccui.BrightStyle.highlight)   
    self.titleLabel:setString(self.campaignsConf[index].name)
    if self.currPanel then
        self.currPanel:hidePanel()
    end
    if self.panels[index] then
        self.currPanel = self.panels[index]
        self.currPanel:showPanel()
    else
        local index1 = self.index1
        local panel = require("script/app/ui/campaign/" .. self.campaignsConf[index].panelName).new(index1, showByClick)
        self.currPanel = panel
        self.childPanel:addChild(panel:getPanel())
    end
    self:updateExtraInfo()
end

function CampaignMainUI:updateExtraInfo()
    local extraInfos = self.currPanel:getExtraInfos()
    if extraInfos[1] then
        self.extraBg1:setVisible(true)
        self.extraLabel1:setVisible(true)
        self.extraLabel1:setString(extraInfos[1])
    else
        self.extraBg1:setVisible(false)
        self.extraLabel1:setVisible(false)
    end
    if extraInfos[2] then
        self.extraBg2:setVisible(true)
        self.extraLabel2:setVisible(true)
        self.extraLabel2:setString(extraInfos[2])
    else
        self.extraBg2:setVisible(false)
        self.extraLabel2:setVisible(false)
    end
    local desc = self.currPanel:getDesc()
    if desc then
        self.infoLabel:setString(desc)
    else
        self.infoLabel:setString(self.campaignsConf[self.index].desc)
    end
    self.addBtn1:setVisible(self.currPanel:isShowAddBtn())
end

function CampaignMainUI:onShow()
    self:updatePanel()
end

function CampaignMainUI:updatePanel()
    self:updateExtraInfo()
    self.currPanel:updatePanel()
    self:updateShowRescopy()
    self:updateShowGuard()
    self:updateShowShipper()
    self:updateNewImg()
end

function CampaignMainUI:updateRescopyAddBtn()
    self.currPanel:onClickAddBtn()
end

function CampaignMainUI:updateNewImg()
    for i, button in ipairs(self.buttons) do
        local newImg = button:getChildByName("new_img")
        if i == 1 then
            newImg:setVisible(UserData:getUserObj():getSignByType('rescopy'))
        elseif i == 2 then
            newImg:setVisible(UserData:getUserObj():getSignByType('shipper'))
        elseif i == 3 then
            newImg:setVisible(UserData:getUserObj():getSignByType('guard'))
        else
            newImg:setVisible(false)
        end
    end
end

return CampaignMainUI