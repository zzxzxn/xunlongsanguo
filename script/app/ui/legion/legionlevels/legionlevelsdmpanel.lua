local LegionLevelsDMUI = class("LegionLevelsDMUI", BaseUI)

local MAXCOPY = 6
function LegionLevelsDMUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONLEVELSDM
  self.data = data
  self.awardtab = {}
end

function LegionLevelsDMUI:onShow()
    self:update()
end

function LegionLevelsDMUI:init()
    local winsize = cc.Director:getInstance():getWinSize()
    local bgimg = self.root:getChildByName("bg_img")
    local bgalpha = bgimg:getChildByName('bg_alpha')
    local bgimg1 = bgalpha:getChildByName("bg_img1")
    self:adaptUI(bgimg, bgalpha)
    local closebtn = bgimg1:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionLevelsDmUI()
        end
    end)
    local titletx = bgimg1:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DM'))
    self.sv = bgimg1:getChildByName('info_sv')
    self.sv:setScrollBarEnabled(false)
    self:update()
end

function LegionLevelsDMUI:update()
    self.sv:removeAllChildren()
    local formationawardconf = GameData:getConfData("legioncopyreward")
    self.rewardtab = {}
    for k,v in pairs(formationawardconf) do
        local arr = {}
        arr[1] = k
        arr[2] = v
        arr[3] = 0
        for rk,rv in pairs(self.data.copy_rewards) do
            if tonumber(rv) == tonumber(k) then
                arr[3] = 1
                break
            end
        end
        table.insert(self.rewardtab,arr)
    end

    table.sort( self.rewardtab, function (a,b)
        if a[3] == b[3] then
            return a[1] < b[1]
        else
            return a[3] < b[3]
        end
    end )
    self.num = #self.rewardtab
     for i=1,self.num do
         self:addCells(i,self.rewardtab[i])
     end
end

function LegionLevelsDMUI:addCells(index,data)
    local node = cc.CSLoader:createNode("csb/legionlevelsdmcell.csb")
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

function LegionLevelsDMUI:updateCell(index,data)
    local bg = self.awardtab[index]:getChildByName('bg_img')
    local bgimg1 = bg:getChildByName('bg_img1')
    if index%2 == 0 then
        bgimg1:setVisible(false)
    end
    local displayobj = DisplayData:getDisplayObj(data[2].reward[1])
    local nametx = bg:getChildByName('name_tx')
    nametx:setString(string.format(GlobalApi:getLocalStr('LEGION_LEVELS_DESC11'),data[1]))
    local desctx = bg:getChildByName('desc_tx')
    
    local desctx2 = bg:getChildByName('desc_tx2')
    desctx2:setString(GlobalApi:getLocalStr('STR_ONDOING'))
    desctx2:setVisible(true)
    local itembg = bg:getChildByName('item_bg')
    itembg:loadTexture(displayobj:getBgImg())
    itembg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:showGetwayUI(displayobj,false)
        end
    end)
    local itemicon = itembg:getChildByName('item_icon')
    itemicon:loadTexture(displayobj:getIcon())
    local itemnumtx = itembg:getChildByName('num_tx')
    itemnumtx:setString(displayobj:getNum())
    local funcbtn = bg:getChildByName('func_btn')
    funcbtn:setVisible(false)
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('STR_GET_1'))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local obj = {
                damage = data[1]
            }
            MessageMgr:sendPost("get_damage_reward", "legion", json.encode(obj), function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    local awards = data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
                    end
                    local costs = data.costs
                    if costs then
                        GlobalApi:parseAwardData(costs)
                    end
                    table.insert(self.data.copy_rewards,self.rewardtab[index][1])
                    self:update()
                end
            end)
        end
    end)
    local damage = 0
    if self.data.damage then
        damage = self.data.damage
    end
    if damage >= data[1] and self.data.copy_rewards then
        local haveget = false
        for k,v in pairs(self.data.copy_rewards) do
            if v == data[1] then
                haveget = true
            end
        end
        if haveget then
            funcbtn:setVisible(false)
            desctx2:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
            desctx2:setTextColor(COLOR_TYPE.GREEN)
        else
            funcbtn:setVisible(true)
            desctx2:setVisible(false)
        end
    elseif damage < data[1] then
        desctx2:setString(GlobalApi:getLocalStr('STR_ONDOING'))
        desctx2:setTextColor(COLOR_TYPE.RED)
    end
    desctx:setString(GlobalApi:getLocalStr('LEGION_LEVELS_DESC12')..GlobalApi:toWordsNumber(damage)..'/'..GlobalApi:toWordsNumber(data[1]))
end

return LegionLevelsDMUI