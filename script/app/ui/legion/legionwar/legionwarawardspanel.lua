local LegionWarAwardsUI = class("LegionWarAwardsUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local defaultNor = 'uires/ui/common/title_btn_nor_2.png'
local defaultSel = 'uires/ui/common/title_btn_sel_2.png'
function LegionWarAwardsUI:ctor(awardsdata)
	self.uiIndex = GAME_UI.UI_LEGIONWAR_AWARDS
  	self.data = legiondata
    self.currtype = page or 1
    self.btnarr ={}
    self.btntxarr = {}
    self.awardplarr = {}
    self.newimgtab = {}
    self.fightcelltab = {}
    self.awardsdata = awardsdata
    self.num = 0
end

function LegionWarAwardsUI:init()
	local bgimg1 = self.root:getChildByName("bg_img")
	local bgimg2 = bgimg1:getChildByName('bg_img1')
	self:adaptUI(bgimg1, bgimg2)
	local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionWarAwardsUI()
        end
    end)
    for i=1,2 do
        self.btnarr[i] = bgimg2:getChildByName('award_' .. i .. '_btn')
        self.btntxarr[i] = self.btnarr[i]:getChildByName('btn_tx')
        self.awardplarr[i] = bgimg2:getChildByName('award_' .. i .. '_pl')
        self.awardplarr[i]:setVisible(false)
        self.btntxarr[i]:setColor(COLOR_TYPE.DARK)
        self.btntxarr[i]:enableOutline(COLOROUTLINE_TYPE.DARK,1)
        self.newimgtab[i] = self.btnarr[i]:getChildByName('new_img')
        self.newimgtab[i]:setVisible(false)
        self.btnarr[i]:addTouchEventListener(function (sender, eventType)
            if eventType ==ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.currtype and self.currtype == i then
                    return
                end
                
                for j=1,2 do
                    self.btnarr[j]:loadTextureNormal(defaultNor)
                    self.btntxarr[j]:setColor(COLOR_TYPE.DARK)
                    self.btntxarr[j]:enableOutline(COLOROUTLINE_TYPE.DARK,1)
                    self.awardplarr[j]:setVisible(false)
                end
                self.btnarr[i]:loadTextureNormal(defaultSel)
                self.btntxarr[i]:setColor(COLOR_TYPE.PALE)
                self.btntxarr[i]:enableOutline(COLOROUTLINE_TYPE.PALE,1)
                self.awardplarr[i]:setVisible(true)
                self.currtype = i
                self:update()
            end
        end)
    end
    self.btntxarr[1]:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC39'))
    self.btntxarr[2]:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC40'))
    local desctx = self.awardplarr[2]:getChildByName('desc_tx')
    desctx:setString(GlobalApi:getLocalStr('LEGION_WAR_DESC38'))

    local bgimgtype1 = self.awardplarr[1]:getChildByName('bg_img2')
    self.warsv = bgimgtype1:getChildByName('sv_1')
    self.warsv:setScrollBarEnabled(false)
    self.contentWidget1 = ccui.Widget:create()
    self.contentWidget1:setPosition(cc.p(343,440))
    self.warsv:addChild(self.contentWidget1)

    local barbg = bgimgtype1:getChildByName('bar_bg')
    local desctx = barbg:getChildByName('bar_desc')
    desctx:removeAllChildren()
    desctx:setString('')
    local richText = xx.RichText:create()
    desctx:addChild(richText)
    richText:setContentSize(cc.size(600, 30))
    richText:setPosition(cc.p(0,-5))
    richText:setAlignment('left')
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC61'), 22, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re1:setFont('font/gamefont.ttf')
    local  legiondat = GameData:getConfData('legion')
    local re2 = xx.RichTextLabel:create(legiondat['legionWarWinAndLost'].value, 22, COLOR_TYPE.GREEN)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_WAR_DESC62')..'！', 22, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re3:setFont('font/gamefont.ttf')

    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)

    richText:setVerticalAlignment('middle')
    richText:setAlignment('middle')
    richText:format(true)
    richText:setAnchorPoint(cc.p(0.5,0.5))

    self.fightsv = self.awardplarr[2]:getChildByName('sv_2')
    self.fightsv:setScrollBarEnabled(false)
    self.contentWidget2 = ccui.Widget:create()
    self.contentWidget2:setPosition(cc.p(343,415))
    self.fightsv:addChild(self.contentWidget2)

    local warawardconf = GameData:getConfData('legionwarrank')
    self.awardtab = {}
    for k,v in pairs(warawardconf) do
        table.insert(self.awardtab, v)
    end
    table.sort( self.awardtab, function (a,b )
        return a.id > b.id
    end )
    for i=1,#self.awardtab do
        self:addCellWar(i,self.awardtab[i])
    end
    self:update()
end

function LegionWarAwardsUI:onShow()
    self:update()
end

function LegionWarAwardsUI:update()
    local status = {
        false,
        UserData:getUserObj():getSignByType('legion_fightnum'),
    }
    
    for i=1,2 do
        if tonumber(self.currtype) == i then
            self.btnarr[i]:loadTextureNormal(defaultSel)
            self.btntxarr[i]:setColor(COLOR_TYPE.PALE)
            self.btntxarr[i]:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            self.awardplarr[i]:setVisible(true)
        end
        self.newimgtab[i]:setVisible(status[i])
    end
    if self.currtype == 2  then
        local fightawardconf = GameData:getConfData('legionwarattackaward')
        self.awardsarr = {}
        for k,v in pairs(fightawardconf) do
            local tab  = {}
            tab[1] = k
            tab[2] = v
            -- if self.awardsdata.fightNumAwardMark[tostring(k)] then
            --     tab[3] = 1
            -- else
            --     tab[3] = 0
            -- end
            table.insert(self.awardsarr,tab)
        end

        table.sort( self.awardsarr, function (a,b)
            --if a[3] == b[3] then
                return a[1] < b[1]
            -- else
            --     return a[3] < b[3]
            -- end
        end )
        if self.num > 0 then
            for i=1,#self.awardsarr do
                self:updateFightCell(i)
            end            
        else
            for i=1,#self.awardsarr do
                self:addCellFight(i,self.awardsarr[i])
            end
        end
    end
   
end

function LegionWarAwardsUI:addCellWar(index)
    local node = cc.CSLoader:createNode("csb/legion_war_awards_cell_1.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    local contentsize = bgimg:getContentSize()
    local cell = ccui.Widget:create()
    cell:addChild(bgimg)
    local lvimg = bgimg:getChildByName('lv_img')
    lvimg:loadTexture('uires/ui/legionwar/legionwar_'..tostring(self.awardtab[index].icon))
    local desctx = lvimg:getChildByName('lv_desc_tx')
    
    desctx:setString(self.awardtab[index].name)
    local blueimg = bgimg:getChildByName('blue_bg')
    local redimg = bgimg:getChildByName('red_bg')
    local winawards = DisplayData:getDisplayObjs(self.awardtab[index].winAward)
    local winawardtab = {}
    for i=1,4 do
        winawardtab[i] = redimg:getChildByName('award_'..i)
        if winawards[i] then
            local itemcell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, winawards[i], winawardtab[i])
            winawardtab[i]:setScale(0.8)
            itemcell.awardBgImg:setSwallowTouches(false)
        end
    end
    local posy = -(contentsize.height + 3)*(index-1) - contentsize.height/2
    cell:setPosition(cc.p(0,posy))
    self.contentWidget1:addChild(cell)
    if index*(contentsize.height+3) > self.warsv:getContentSize().height then
        self.warsv:setInnerContainerSize(cc.size(self.warsv:getContentSize().width,index*(contentsize.height+3)))
    end
    self.contentWidget1:setPosition(cc.p(self.warsv:getInnerContainerSize().width/2,self.warsv:getInnerContainerSize().height))
end

function LegionWarAwardsUI:addCellFight(index,celldata)
    local node = cc.CSLoader:createNode("csb/legion_war_awards_cell_2.csb")
    local bgimg = node:getChildByName("awardcell_img")
    bgimg:removeFromParent(false)
    local bgimg2 = bgimg:getChildByName('bg_img')
    local contentsize = bgimg:getContentSize()
    self.fightcelltab[index] = ccui.Widget:create()
    self.fightcelltab[index]:addChild(bgimg)
    self.num = self.num + 1
    if self.num%2 == 0 then
        bgimg2:setVisible(true)
    else
        bgimg2:setVisible(false)
    end

    local counttx = bgimg:getChildByName('lv_name_tx')
    counttx:setString(celldata[1]..GlobalApi:getLocalStr('FREE_TIMES_DESC'))
    local havegotimg = bgimg:getChildByName('have_got_img')
    havegotimg:setVisible(false)

    local funcbtn = bgimg:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendMsg(index,celldata[1])
        end
    end)

    if self.awardsdata.fightNumAwardMark[tostring(celldata[1])] then
        havegotimg:setVisible(true)
        funcbtn:setVisible(false)
    else
        havegotimg:setVisible(false)
        funcbtn:setVisible(true)
    end
    if not self.awardsdata.fightNum then
        self.awardsdata.fightNum = 0
    end
    if self.awardsdata.fightNum >= celldata[1] then
        funcbtntx:setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
        funcbtn:setTouchEnabled(true)
        ShaderMgr:restoreWidgetDefaultShader(funcbtn)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    else
        funcbtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(funcbtn)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        local str = string.format(GlobalApi:getLocalStr('LEGION_WAR_DESC51'),(celldata[1] - self.awardsdata.fightNum))
        funcbtntx:setString(str)
    end
    local countawardtab = {}
    local awards = DisplayData:getDisplayObjs(celldata[2].award)
    local awardtab = {}
    for i=1,4 do
        countawardtab[i] = bgimg:getChildByName('award_node_'..i)
        if awards[i] then
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards[i], countawardtab[i])
            countawardtab[i]:setScale(0.8)
            cell.awardBgImg:setSwallowTouches(false)
        end
    end

    local posy = -(contentsize.height)*(index-1) - contentsize.height/2
    self.fightcelltab[index]:setPosition(cc.p(0,posy))
    self.contentWidget2:addChild(self.fightcelltab[index])
    if index*(contentsize.height) > self.fightsv:getContentSize().height then
        self.fightsv:setInnerContainerSize(cc.size(self.fightsv:getContentSize().width,index*(contentsize.height)))
    end
    self.contentWidget2:setPosition(cc.p(self.fightsv:getInnerContainerSize().width/2,self.fightsv:getInnerContainerSize().height))
end

function LegionWarAwardsUI:updateFightCell(index)
    local bg = self.fightcelltab[index]:getChildByName('awardcell_img')
    local havegotimg = bg:getChildByName('have_got_img')
    local funcbtn = bg:getChildByName('func_btn')
    local funcbtntx = funcbtn:getChildByName('btn_tx')
    if self.awardsdata.fightNumAwardMark[tostring(self.awardsarr[index][1])] then
        havegotimg:setVisible(true)
        funcbtn:setVisible(false)
    else
        havegotimg:setVisible(false)
        funcbtn:setVisible(true)
    end
    if self.awardsdata.fightNum >= self.awardsarr[index][1] then
        funcbtntx:setString(GlobalApi:getLocalStr('ACTIVITY_GETBTN_TEXT'))
        funcbtn:setTouchEnabled(true)
        ShaderMgr:restoreWidgetDefaultShader(funcbtn)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
    else
        funcbtn:setTouchEnabled(false)
        ShaderMgr:setGrayForWidget(funcbtn)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        local str = string.format(GlobalApi:getLocalStr('LEGION_WAR_DESC51'),(self.awardsarr[index][1] - self.awardsdata.fightNum))
        funcbtntx:setString(str)
    end
end

function LegionWarAwardsUI:sendMsg(i,index)
    local args = {
        attackCount = index
    }
    MessageMgr:sendPost("get_user_fightnum_award", "legionwar", json.encode(args), function (response)
        if response.code == 0 then
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
            if not self.awardsdata.fightNumAwardMark then
                local tab = {}
                tab[tostring(index)] = 1
                self.awardsdata.fightNumAwardMark = tab
            else
                self.awardsdata.fightNumAwardMark[tostring(index)] = 1
            end
            
            self:updateFightCell(i)
            self:calcinfo()
        end
    end)
    
end

function LegionWarAwardsUI:calcinfo()

    for i=1,#self.awardsarr do
        --print('self.awardsarr[i][1]==='..self.awardsarr[i][1])
        if not self.awardsdata.fightNumAwardMark[tostring(self.awardsarr[i][1])] and self.awardsdata.fightNum >= self.awardsarr[i][1] then
            UserData:getUserObj():setSignByType('legionwar_fightnum',1)
            return
        end
    end
    UserData:getUserObj():setSignByType('legionwar_fightnum',0)
end

return LegionWarAwardsUI