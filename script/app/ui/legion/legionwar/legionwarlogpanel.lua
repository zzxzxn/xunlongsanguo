local LegionWarLogUI = class("LegionWarLogUI", BaseUI)

function LegionWarLogUI:ctor(logdata)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_LOG
  	self.data = logdata
end

function LegionWarLogUI:init()
	local bgimg1 = self.root:getChildByName("bg_img")
	local bgimg2 = bgimg1:getChildByName('bg_img1')
	local closebtn = bgimg2:getChildByName('close_btn')
	self:adaptUI(bgimg1, bgimg2)
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarLogUI()
        end
    end)
    local titlebg = bgimg2:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC9'))
    local bgimg3 = bgimg2:getChildByName('bg_img2')   
    self.sv = bgimg3:getChildByName('sv_1')
    self.sv:setScrollBarEnabled(false)
    self.contentWidget = ccui.Widget:create()
    self.contentWidget:setPosition(cc.p(342,448))
    self.sv:addChild(self.contentWidget)
    self.noimg = bgimg3:getChildByName('no_img')
    self:update()
end

function LegionWarLogUI:update()
    self.dataarr = {}
    if self.data then
        for k,v in pairs(self.data) do
            local tab = {}
            tab[1] = v.time
            tab[2] = v
            table.insert(self.dataarr,tab)
        end
    end
    table.sort( self.dataarr, function(a,b )
        return a[1] > b[1]
    end )
    self.num = #self.dataarr
    for i=1,self.num do
        self:addCells(i,self.dataarr[i])
    end
    if self.num == 0 then
        self.noimg:setVisible(true)
    else
        self.noimg:setVisible(false)
    end
end
function LegionWarLogUI:addCells(index,celldata)
    local node = cc.CSLoader:createNode("csb/legion_war_log_cell.csb")
    local bgimg = node:getChildByName("logcell_img")
    bgimg:removeFromParent(false)
    self.contentsize = bgimg:getContentSize()
    local cell = ccui.Widget:create()
    cell:addChild(bgimg)
    local bgimg2 = bgimg:getChildByName('bg_img')
    self.num = self.num + 1

    if self.num%2 == 0 then
        bgimg2:setVisible(true)
    else
        bgimg2:setVisible(false)
    end

    local infotx = bgimg:getChildByName('info_tx')
    infotx:removeAllChildren()
    infotx:setString('')
    local richText = xx.RichText:create()
    infotx:addChild(richText)
    richText:setContentSize(cc.size(600, 30))
    richText:setPosition(cc.p(0,0))
    richText:setAlignment('left')
    local re1 = xx.RichTextLabel:create(celldata[2].attacker, 28, COLOR_TYPE.BLUE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC53'), 28, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(celldata[2].defender, 28, COLOR_TYPE.RED)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re3:setFont('font/gamefont.ttf')

    local re4 = xx.RichTextLabel:create('', 28, COLOR_TYPE.WHITE)
    re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re4:setFont('font/gamefont.ttf')

    local wlimg = bgimg:getChildByName('wl_img')
    if celldata[2].win == true then
        re4:setString(','..GlobalApi:getLocalStr('LEGION_WAR_DESC54').."！")
        wlimg:loadTexture('uires/ui/arena/victory.png')
    else
        re4:setString(','..GlobalApi:getLocalStr('LEGION_WAR_DESC55').."！")
        wlimg:loadTexture('uires/ui/arena/failure.png')
    end

    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)

    richText:setVerticalAlignment('middle')
    richText:format(true)
    richText:setAnchorPoint(cc.p(0,0.5))

    local replaybtn = bgimg:getChildByName('replay_btn')
    replaybtn:setVisible(false)
    replaybtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            print(index)
        end
    end)

    local heartimg = bgimg:getChildByName('heart_img')
    local heartnum = bgimg:getChildByName('heart_num')
    heartnum:setString('-'..celldata[2].power..'%')

    local posy = -(self.contentsize.height)*(index-1) - self.contentsize.height/2
    cell:setPosition(cc.p(0,posy))
    self.contentWidget:addChild(cell)
    if index*(self.contentsize.height) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,index*(self.contentsize.height)))
    end
    self.contentWidget:setPosition(cc.p(self.sv:getInnerContainerSize().width/2,self.sv:getInnerContainerSize().height))
end

return LegionWarLogUI