local HelpUI = class("HelpUI", BaseUI)

function HelpUI:ctor(id)
    self.uiIndex = GAME_UI.UI_HELP_MAIN_PANNEL
    self.id = id
    print("这是帮助文档")
end

function HelpUI:init()
    local bgImg = self.root:getChildByName("bg_img")
    local bgNode = bgImg:getChildByName("bg_node")
    self:adaptUI(bgImg, bgNode)
    local gamedata = GameData:getConfData("helptext")

    bgImg:addClickEventListener(function ()
        HelpMgr:hideHelpUI()
    end)
    
    local text = bgNode:getChildByName("title_tx")
    text:setString(gamedata[self.id].type or '')

    local infoLabel = bgNode:getChildByName("info_tx")
    infoLabel:setString(GlobalApi:getLocalStr("CLICK_SCREEN_CONTINUE"))
    infoLabel:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(2), cc.FadeIn:create(2), cc.DelayTime:create(2))))

    local img2 = bgNode:getChildByName("img2")
    local sv = bgNode:getChildByName("sv")
    sv:setScrollBarEnabled(false)

    local svSize = sv:getContentSize()


    local contentWidget = ccui.Widget:create()
    sv:addChild(contentWidget)
    contentWidget:setPosition(cc.p(0, svSize.height))


    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(svSize.width, 40))
	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(0,23))
	contentWidget:addChild(richText)

    --local str3 = "<font color=\"#fea500ff\" size=\"24\" >亲爱的主公们：</font>\n<font color=\"#ffffffff\" size=\"22\" >1、本次不代表游戏最终品质，欢迎各位主公及时反馈问题，我们将积极优化；\n2、删档测试期间产生的所有数据均会在测试结束时删除；\n3、本次测试期间各位主公通过充值获得的元宝，将在公测时100%返还；</font>"
    --print(str)
	local str = gamedata[self.id].str or ''
    -- 配置中，如果有换行的话就写line（由于编码有问题，都是utf-8,但是dat表里的编码和这里的不同；这里把所有的line替换成这里的换行编码）
    local str = string.gsub(str, "<line>", "\n")

	local re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.PALE)
	re1:setFont('font/gamefont.ttf')
    --re1:clearStroke()
	--re1:setStroke(COLOROUTLINE_TYPE.PALE, 1)
    --re1:setShadow(COLOROUTLINE_TYPE.PALE, cc.size(0, -1))
	richText:addElement(re1)
	xx.Utils:Get():analyzeHTMLTag(richText,str)

    richText:format(true)
    local labelheight = richText:getBrushY()
    if labelheight > svSize.height then
    	sv:setInnerContainerSize(cc.size(svSize.width,labelheight))
    end
    contentWidget:setPosition(cc.p(0, sv:getInnerContainerSize().height - 10))
    richText:setPosition(cc.p(0,0))


end

return HelpUI