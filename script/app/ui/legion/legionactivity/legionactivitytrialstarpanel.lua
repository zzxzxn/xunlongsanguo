local LegionActivityTrialStarUI = class("LegionActivityTrialStarUI", BaseUI)
function LegionActivityTrialStarUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONACTIVITYTRIALSTARUI
  self.data = data
  self.awardtab = {}
end

function LegionActivityTrialStarUI:onShow()
    self:update()
end

function LegionActivityTrialStarUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    -- bgimg2:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionActivityTrialStarUI()
    --     end
    -- end)
    self:adaptUI(bgimg1, bgimg2)
    local bgimg3 = bgimg2:getChildByName('bg_img1')
    local bgimg4 = bgimg3:getChildByName('bg_img2')
    local closebtn = bgimg3:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionActivityTrialStarUI()
        end
    end)
    local titlebg = bgimg3:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_TITLE'))
    self.trialconf = GameData:getConfData('trial')[LegionMgr:calcTrialLv()]
    local desctx1 = bgimg3:getChildByName('desc_tx_1')
    desctx1:setString(string.format(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_DESC1'),self.trialconf.level))
    local desctx2 = bgimg3:getChildByName('desc_tx_2')
    desctx2:setString(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_DESC2')..self.data.trial_stars..'  ')
    self.sv = bgimg3:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function LegionActivityTrialStarUI:addCells(index,data)
    local node = cc.CSLoader:createNode("csb/legionactivitytrialstarcell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.awardtab[index] = ccui.Widget:create()
    self.awardtab[index]:addChild(bgimg)

    self:updateCell(index,data)
    local bgimg = self.awardtab[index]:getChildByName("bg_img")
    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.sv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height-10
    self.awardtab[index]:setPosition(cc.p(3,posy))
    self.sv:addChild(self.awardtab[index])
end

function LegionActivityTrialStarUI:updateCell(index,data)
    local bgimg = self.awardtab[index]:getChildByName('bg_img')
    local bgimg1 = bgimg:getChildByName('bg_img')
    if index%2 == 1 then
        bgimg1:setVisible(true)
    else
        bgimg1:setVisible(false)
    end
    local displayobj = DisplayData:getDisplayObj(data[2][1])
    local frameimg = bgimg:getChildByName('frame_img')
    frameimg:loadTexture(displayobj:getBgImg())
    local iconimg = frameimg:getChildByName('icon_img')
    iconimg:loadTexture(displayobj:getIcon())
    local awardnametx = bgimg:getChildByName('award_name_tx')
    awardnametx:setString(displayobj:getName()..'X'..displayobj:getNum())
    local funcbtn = bgimg:getChildByName('func_btn')
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                star = index*3
            }
            MessageMgr:sendPost('get_trial_star_award','legion',json.encode(args),function (response)
                
                local code = response.code
                local data = response.data
                local awards = data.awards
                if awards then
                    GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                end
                local costs = data.costs
                if costs then
                    GlobalApi:parseAwardData(costs)
                end 
                self.data.trial_award[tostring(index*3)] = 1
                local legioninfo = UserData:getUserObj():getLegionInfo()
                legioninfo.trial_award = self.data.trial_award
                self:update()  
            end) 
        end
    end)
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_GET'))
    local limittx = bgimg:getChildByName('limit_tx')
    limittx:setString('')
    local statetx = bgimg:getChildByName('state_tx')
    statetx:setString('')
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(490, 40))

    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_DESC3')..index*3, 25, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing.png')
    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_ACTIVITY_TRIALSTAR_DESC4'), 25, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setPosition(cc.p(limittx:getPositionX(),limittx:getPositionY()))
    richText:setAnchorPoint(cc.p(0,0.5))
    bgimg:addChild(richText,1,index+9999)
    richText:setVisible(true)

    if self.data.trial_stars < index*3 then
        funcbtn:setVisible(false)
        statetx:setString(GlobalApi:getLocalStr('STR_ONDOING'))
        statetx:setTextColor(COLOR_TYPE.RED)
    else
        if self.data.trial_award ~= nil and tonumber(self.data.trial_award[tostring(index*3)]) == 1 then
            statetx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
            statetx:setTextColor(COLOR_TYPE.GREEN)
            statetx:setVisible(true)
            funcbtn:setVisible(false)  
        else
            funcbtn:setVisible(true)
            statetx:setVisible(false)
        end
    end
end

function LegionActivityTrialStarUI:update()
    self.sv:removeAllChildren()
    local legionglobalconf = GameData:getConfData('legion')
    self.num = legionglobalconf['legionTrialMaxCount'].value
    self.awardarr = {}
    
    for i=1,self.num do
        local arr = {}
        arr[1] = i*3
        arr[2] = self.trialconf[tostring('starAward'..i*3)]
        self.awardarr[i] = arr
       self:addCells(i,self.awardarr[i])
    end
    self.sv:scrollToTop(0.1,true)
end


return LegionActivityTrialStarUI