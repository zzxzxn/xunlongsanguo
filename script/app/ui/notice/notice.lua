local NoticeUI = class("NoticeUI", BaseUI)

function NoticeUI:ctor()
    self.uiIndex = GAME_UI.UI_NOTICE
end

function NoticeUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local bgNode = bgImg:getChildByName("bg_node")
    self:adaptUI(bgImg, bgNode)

    bgImg:addClickEventListener(function ()
        self:hideUI()
    end)


    self.img_role = bgNode:getChildByName("img_role")
    self.img3 = bgNode:getChildByName("img3")
    self.img = bgNode:getChildByName("img")
    
    


    self.imgNotice = bgNode:getChildByName("img_notice")
    self.text = self.imgNotice:getChildByName("text")
    self.text:setString(GlobalApi:getLocalStr("GAME_NOTICE"))

    local infoLabel = bgNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))


    self.img2 = bgNode:getChildByName("img2")
    self.sv = self.img2:getChildByName("sv")
    self.sv:setScrollBarEnabled(false)

    self.svSize = self.sv:getContentSize()


    self.contentWidget = ccui.Widget:create()
    self.sv:addChild(self.contentWidget)
    self.contentWidget:setPosition(cc.p(0, self.svSize.height))


    self.richText = xx.RichText:create()
    self.richText:setContentSize(cc.size(self.svSize.width, 40))
    self.richText:setAnchorPoint(cc.p(0,0.5))
    self.richText:setPosition(cc.p(0,23))
    self.contentWidget:addChild(self.richText)


    self.re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.PALE)
    self.re1:setFont('font/gamefont.ttf')
    self.re1:setStroke(COLOROUTLINE_TYPE.PALE, 2)
    self.richText:addElement(self.re1)


    

    local targetPlatform = CCApplication:getInstance():getTargetPlatform()



    local str = GlobalData:getContent()
    xx.Utils:Get():analyzeHTMLTag(self.richText,str)
    self.richText:format(true)
    local labelheight = self.richText:getBrushY()
    if labelheight > self.svSize.height then
        self.sv:setInnerContainerSize(cc.size(self.svSize.width,labelheight))
    end
    self.contentWidget:setPosition(cc.p(0, self.sv:getInnerContainerSize().height - 10))
    self.richText:setPosition(cc.p(0,0))

    -- local winSize = cc.Director:getInstance():getVisibleSize()

    -- local scale = 1280/720

    if targetPlatform ~= kTargetWindows then 
        self:hideOther()
        local webView = ccexp.WebView:create()
        webView:addTo(bgNode)
        webView:setPosition(cc.p(0, 0))
        -- webView:setContentSize(winSize.width/scale, winSize.height/scale)
        webView:setContentSize(720, 480)
        webView:loadURL(GlobalData:getBulletin())
        -- webview:reload()
        self.wv = webView

    end 


end

function NoticeUI:hideOther()
    self.imgNotice:setVisible(false)
    self.img2:setVisible(false)
    self.img_role:setVisible(false)
    self.img3:setVisible(false)
    self.img:setVisible(false)
end



return NoticeUI