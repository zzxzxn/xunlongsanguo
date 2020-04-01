local LoadingUI = class("LoadingUI")

function LoadingUI:ctor(type)
    self.type = type
    self.root = cc.CSLoader:createNode("csb/loading.csb")
    self:init()
end

function LoadingUI:init()
    local winSize = cc.Director:getInstance():getWinSize()
    local loadingBg = self.root:getChildByName("loading_bg")
    local loadingImg = loadingBg:getChildByName("loading_img")
    local blackBg = loadingBg:getChildByName("black_bg")
    local logoImg = loadingBg:getChildByName("logo_img")
    self.cloud = {}
    for i = 1, 6 do
        self.cloud[i] = loadingBg:getChildByName("cloud_" .. i)
    end
    if self.type == 1 then
        loadingImg:setTexture("uires/ui/loading/loading_bg_" .. math.random(1, 15) .. ".png")
        blackBg:setVisible(false)
    else
        loadingImg:setTexture("uires/ui/loading/loading_bg_hero_" .. math.random(1, 8) .. ".jpg")
        local imgSize = loadingImg:getContentSize()
        -- if imgSize.width/imgSize.height > winSize.width/winSize.height then
        --     loadingImg:setScale(winSize.width/imgSize.width + 0.01)
        -- else
        --     loadingImg:setScale(winSize.height/imgSize.height + 0.01)
        -- end
        for k, v in ipairs(self.cloud) do
            v:setVisible(false)
        end
    end

    local platform = CCApplication:getInstance():getTargetPlatform()
    -- 添加logo信息
    local logoRes = ""
    if platform == kTargetAndroid or platform == kTargetIphone then
        logoRes = SdkData:SDK_getLogoInfo()
    else
        logoRes = "fjmz.png"
    end

    logoImg = logoImg:setTexture('uires/logo/'..logoRes)
    local tempSize = loadingBg:getContentSize()

    logoImg:setPosition(cc.p((tempSize.width-winSize.width)/2+winSize.width/6, (tempSize.height-winSize.height)/2+winSize.height/6*4))
    logoImg:setScale(0.9)

    local tipsTx = loadingBg:getChildByName("tips_tx")
    tipsTx:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
    local loadingtipsConf = GameData:getConfData("loadingtips")
    tipsTx:setString(GlobalApi:getLocalStr("STR_LOADING_TIPS") .. loadingtipsConf[math.random(1, #loadingtipsConf)].desc)
    
    local loadingBarBg = loadingBg:getChildByName("loading_bar_bg")
    local loadingBar = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/loading/loading_bar.png"))
    local barSize = loadingBar:getContentSize()
    loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    loadingBar:setMidpoint(cc.p(0, 0))
    loadingBar:setBarChangeRate(cc.p(1, 0))
    loadingBarBg:addChild(loadingBar)
    loadingBar:setPosition(cc.p(345, 19))
    loadingBar:setPercentage(0)
    self.logoImg = logoImg
    self.loadingImg = loadingImg
    self.loadingBarBg = loadingBarBg
    self.loadingBar = loadingBar
    self.tipsTx = tipsTx
    self.loadingHead = loadingBg:getChildByName("loading_bar_head")
    self.loadingHead:setPosition(cc.p(265, 120.5))
    self.loadingHead:setLocalZOrder(1)
end

function LoadingUI:setPercent(percent)
    self.loadingHead:setPosition(cc.p(6.16*percent+265, 120.5))
    self.loadingBar:setPercentage(percent)
end

function LoadingUI:runToPercent(time, percent, callback)
    percent = percent > 100 and 100 or percent
    self.loadingBar:runAction(cc.Sequence:create(cc.ProgressTo:create(time, percent), cc.CallFunc:create(function ()
        if percent >= 100 then
            if self.type == 1 then
                self.logoImg:setVisible(false)
                self.loadingImg:setVisible(false)
                self.loadingBarBg:setVisible(false)
                self.loadingBar:setVisible(false)
                self.loadingHead:setVisible(false)
                self.tipsTx:setVisible(false)
                self.cloud[1]:runAction(cc.Sequence:create(cc.MoveBy:create(1, cc.p(850, -320)), cc.CallFunc:create(function ()
                    if callback then
                        callback()
                    end
                end)))
                self.cloud[2]:runAction(cc.MoveBy:create(1, cc.p(620, 680)))
                self.cloud[3]:runAction(cc.MoveBy:create(1, cc.p(-580, -220)))
                self.cloud[4]:runAction(cc.MoveBy:create(1, cc.p(-840, 750)))
                self.cloud[5]:runAction(cc.MoveBy:create(1, cc.p(0, 340)))
                self.cloud[6]:runAction(cc.MoveBy:create(1, cc.p(-540, 370)))
            else
                if callback then
                    callback()
                end
            end
        else
            if callback then
                callback()
            end
        end
    end)))
    self.loadingHead:runAction(cc.MoveTo:create(time, cc.p(6.16*percent+265, 120.5)))
end

-- speed 进度条从0到100所需的时间
function LoadingUI:runByPercent(speed, percent)
    percent = percent > 100 and 100 or percent
    self.loadingBar:stopAllActions()
    self.loadingHead:stopAllActions()
    local currPercent = self.loadingBar:getPercentage()
    self.loadingHead:setPosition(cc.p(6.16*currPercent+265, 120.5))
    local time = (percent - currPercent)*speed/100
    self.loadingBar:runAction(cc.ProgressTo:create(time, percent))
    self.loadingHead:runAction(cc.MoveTo:create(time, cc.p(6.16*percent+265, 120.5)))
end

function LoadingUI:getPanel()
    return self.root
end

function LoadingUI:removeFromParent()
    self.root:removeFromParent()
end

return LoadingUI
