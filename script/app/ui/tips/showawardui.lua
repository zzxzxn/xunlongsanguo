local ShowAwardUI = class("ShowAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function ShowAwardUI:ctor(awards,ntype,callback,confirmCallback)
    self.uiIndex = GAME_UI.UI_SHOWAWARD
    self.awards = awards
    --printall(self.awards)
    -- self.awards = {{'user','cash',1},{'user','food',2},{'user','cash',3},{'user','food',4},{'user','cash',5}
    -- ,{'user','cash',6},{'user','food',7},{'user','cash',8},{'user','food',9},{'user','cash',10}
    -- ,{'user','cash',11},{'user','food',12},{'user','cash',13},{'user','food',14},{'user','cash',15}}
    -- self.awards = {{'user','cash',1},{'user','cash',2},{'user','cash',3},{'user','cash',4}}
    -- self.awards = {{'user','cash',100},{'user','cash',1000},{'user','cash',1000}}
    -- self.awards = {{'user','cash',100},{'user','cash',1000}}
    -- self.awards = {{'user','cash',100}}
    self.intervalSize = 32
    self.diffHeight = 150
    self.ntype = ntype
    self.cells = {}
    self.nowCount = 0
    self.callback = callback
    self.confirmCallback = confirmCallback

end

function ShowAwardUI:getRepeatAwards()
    local itemTab = {}
    local gemTab = {}
    local materialTab = {}
    local dressTab = {}
    local otherTab = {}
    for i,v in ipairs(self.awards) do
        if v[1] == 'user' then
            itemTab[v[2]] = (itemTab[v[2]] or 0) + v[3]
        elseif v[1] == 'gem' then
            gemTab[v[2]] = (gemTab[v[2]] or 0) + v[3]
        elseif v[1] == 'material' then
            materialTab[v[2]] = (materialTab[v[2]] or 0) + v[3]
        elseif v[1] == 'dress' then
            dressTab[v[2]] = (dressTab[v[2]] or 0) + v[3]
        else
            otherTab[#otherTab + 1] = v
        end
    end
    for i,v in pairs(itemTab) do
        otherTab[#otherTab + 1] = {'user',i,tonumber(v)}
    end
    for i,v in pairs(gemTab) do
        otherTab[#otherTab + 1] = {'gem',i,tonumber(v)}
    end
    for i,v in pairs(materialTab) do
        otherTab[#otherTab + 1] = {'material',i,tonumber(v)}
    end
    for i,v in pairs(dressTab) do
        otherTab[#otherTab + 1] = {'dress',i,tonumber(v)}
    end
    self.awards = otherTab
end

function ShowAwardUI:getPos(i)
    local size = self.awardSv:getContentSize()
    local currRow = ((i-1) - (i-1)%4)/4 + 1
    local currColumn = (i-1)%4+1
    if #self.awards <= 4 then
        local diffWidth = (size.width - #self.awards * self.singleSize.width)/(#self.awards + 1)
        return cc.p(currColumn*(diffWidth + self.singleSize.width) - self.singleSize.width/2,size.height/3*2)
    else
        local diffWidth = (size.width - 4 * self.singleSize.width)/5
        return cc.p(currColumn*(diffWidth + self.singleSize.width) - self.singleSize.width/2,85 + (self.maxLine-currRow)*self.diffHeight)
    end
end

function ShowAwardUI:playAction()
    if #self.cells <= 0 then
        self.isEnd = true
        self.awardSv:setSwallowTouches(false)
        local bgImg = self.root:getChildByName("awards_bg_img")
        local neiBgImg = bgImg:getChildByName("nei_bg_img")
        local okBtn = neiBgImg:getChildByName('ok_btn')
        okBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.callback then
                    self.callback()
                end
                if self.confirmCallback then
                    self.confirmCallback()
                    self.confirmCallback = nil
                end
                self:hideUI()
            end
        end)
        return
    end
    local function play(cell,maxNum,delayTime,i)
        local awardBgImg = cell:getChildByName('award_bg_img')
        local nameTx = awardBgImg:getChildByName('name_tx')
        local layout = awardBgImg:getChildByName('white_mask')
        awardBgImg:runAction(cc.Sequence:create(cc.DelayTime:create(0.1*delayTime*self.skip),cc.CallFunc:create(function ()
            if self.skip == 1 then
                local size = awardBgImg:getContentSize()
                local particle = cc.ParticleSystemQuad:create("particle/getitem.plist")
                particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
                particle:setPosition(awardBgImg:getPosition())
                particle:setName('getitem')
                cell:addChild(particle)
            end
            -- play audio effect
            AudioMgr.playEffect("media/effect/show_award.mp3", false);
        end),cc.DelayTime:create(0.1*maxNum*self.skip),cc.Spawn:create(
        cc.MoveTo:create(0.2*self.skip, cc.p(0,0)), cc.ScaleTo:create(0.2*self.skip, 1), cc.RotateTo:create(0.2*self.skip, 720)),
        cc.CallFunc:create(function()
                layout:setVisible(true)
                layout:runAction(cc.Sequence:create(cc.FadeOut:create(0.2*self.skip),
                    cc.CallFunc:create(function ()
                            local getitem = cell:getChildByName('getitem')
                            if getitem then
                                getitem:removeFromParent()
                            end
                            nameTx:setVisible(true)
                            self.nowCount = self.nowCount - 1
                            if self.nowCount <= 0 then
                                for i=1,maxNum do
                                    table.remove(self.cells,1)
                                end
                                local inner = self.awardSv:getInnerContainer()
                                if #self.cells > 4 then
                                    inner:runAction(cc.Sequence:create(cc.MoveTo:create(0.2*self.skip,cc.p(inner:getPositionX(),inner:getPositionY()+self.diffHeight*2)),cc.CallFunc:create(function()
                                        self:playAction()
                                    end)))
                                elseif #self.cells > 0 then
                                    inner:runAction(cc.Sequence:create(cc.MoveTo:create(0.2*self.skip,cc.p(inner:getPositionX(),inner:getPositionY()+self.diffHeight)),cc.CallFunc:create(function()
                                        self:playAction()
                                    end)))
                                else
                                    self:playAction()
                                end
                            end
                        end)))
            end)))
    end
    if #self.cells > 8 then
        self.nowCount = 8
    else
        self.nowCount = #self.cells
    end
    local tab = {}
    for i=1,self.nowCount do
        tab[#tab + 1] = i
    end
    -- play audio effect
    -- AudioMgr.playEffect("media/effect/show_award.mp3", false)
    for i=1,self.nowCount do
        local index = math.random(1,#tab)
        local delayTime = tab[index]
        local cell = self.cells[i]
        table.remove(tab,index)
        play(cell,self.nowCount,delayTime,i)
    end
end

function ShowAwardUI:createAwards(i)
    local num = #self.awards
    if i > #self.awards or not self.awards[i] then
        self:playAction()
        return
    end

    local rootNode = cc.Node:create()
    self.cells[#self.cells + 1] = rootNode
    local award = DisplayData:getDisplayObj(self.awards[i])

    local param = {
        bgTouchEnaled = false,
        showDoubleImg = true,
        showNameTx = true,
        bgScale = 0
    }
    local awardBgImg = ClassItemCell:updateAwardFrameByObj(rootNode,award,param)

    local whiteMask = ccui.ImageView:create("uires/ui/common/itemframe_white.png")
    whiteMask:setName("white_mask")
    whiteMask:setVisible(false)
    whiteMask:setPosition(cc.p(47, 47))
    awardBgImg:addChild(whiteMask)

    local doubleImg = awardBgImg:getChildByName('double_img')
    if award:getExtraBg() then
        doubleImg:setVisible(true)
    else
        doubleImg:setVisible(false)
    end
    local nameTx = awardBgImg:getChildByName('name_tx')
    nameTx:setVisible(false)
    self.singleSize = awardBgImg:getContentSize()
    rootNode:setPosition(cc.p(self:getPos(i)))
    self.awardSv:addChild(rootNode, 1, i)
    self:createAwards(i+1)
end

function ShowAwardUI:updatePanel()
    local num = #self.awards
    self.maxLine = ((num - 1) - (num - 1)%4)/4+1
    -- print(self.maxLine)
    local size = self.awardSv:getContentSize()
    if self.maxLine*self.diffHeight > size.height then
        self.awardSv:setInnerContainerSize(cc.size(size.width,self.maxLine*self.diffHeight))
    else
        self.awardSv:setInnerContainerSize(size)
    end
    self.awardSv:jumpToTop()

    if num > 0 then
        self:createAwards(1)
    end
end

function ShowAwardUI:init()
    local bgImg = self.root:getChildByName("awards_bg_img")
    local neiBgImg = bgImg:getChildByName("nei_bg_img")
    self:adaptUI(bgImg, neiBgImg)
    local winSize = cc.Director:getInstance():getVisibleSize()
    neiBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))
    self.isEnd = false
    self.skip = 1
    -- local descTx = neiBgImg:getChildByName('desc_tx')
    -- descTx:setString(GlobalApi:getLocalStr('CLICK_SCREEN_CONTINUE'))
    -- descTx:setVisible(true)
    -- descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))

    local okBtn = neiBgImg:getChildByName('ok_btn')
    local infoTx = okBtn:getChildByName('info_tx')
    infoTx:setString(GlobalApi:getLocalStr('STR_OK2'))
    if not self.callback then
        okBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.confirmCallback then
                    self.confirmCallback()
                    self.confirmCallback = nil
                end
                self:hideUI()
            end
        end)
    end

    -- 不显示确定按钮，显示点击任意位置继续
    if self.ntype == 2 then
        local label2 = cc.Label:createWithTTF(GlobalApi:getLocalStr("CLICK_ANY_POS_CONTINUE"), "font/gamefont.ttf", 24)
        label2:setTextColor(COLOR_TYPE.WHITE)
        bgImg:addChild(label2)
        label2:setAnchorPoint(cc.p(0.5, 0))
        label2:setPosition(cc.p(winSize.width/2, 65))
        label2:setString(GlobalApi:getLocalStr('CLICK_ANY_POS_CONTINUE'))
        label2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))
        okBtn:setVisible(false)
        bgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.confirmCallback then
                    self.confirmCallback()
                    self.confirmCallback = nil
                end
                self:hideUI()
            end
        end)
    end

    bgImg:setSwallowTouches(true)
    local lightImg = neiBgImg:getChildByName("light_img")
    lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(20, 360)))
    self.awardSv = neiBgImg:getChildByName('award_sv')
    self.awardSv:setScrollBarEnabled(false)
    if not self.ntype then
        self:getRepeatAwards()
    end
    self:updatePanel()
end

return ShowAwardUI