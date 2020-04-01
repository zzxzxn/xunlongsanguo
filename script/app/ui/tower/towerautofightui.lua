local TowerAutoFightUI = class("TowerAutoFightUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TowerAutoFightUI:ctor(awards,floor,cur_room)
    self.uiIndex = GAME_UI.UI_TOWER_AUTOFIGHT
    self.awards = awards
    --self.awardstab = {}
    self.floor = floor
    self.cur_room = cur_room
end

function TowerAutoFightUI:init()
    local bgimg = self.root:getChildByName("bg_img")
    local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    local gobtn = bgimg1:getChildByName("goon_btn")
    local gobtntx = gobtn:getChildByName('btn_tx')
    gobtntx:setString(GlobalApi:getLocalStr('TOWER_AUTOEND'))
    gobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TowerMgr:hideTowerAutoFight()
        end
    end)
    --[[
    for i=1,3 do
        local arr = {
            numtx = nil,
            award = {}
        }
        local bg = bgimg1:getChildByName('awardcell_'..i..'_img')
        arr.numtx = bg:getChildByName('num_tx')
        for j=1,3 do
            local awardframeNode = bg:getChildByName('awardframe_'..j..'_node')
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            cell.nameTx:setAnchorPoint(cc.p(0, 0.5))
            cell.nameTx:setPosition(cc.p(110, 47))
            awardframeNode:addChild(cell.awardBgImg)
            arr['award'][j] = cell
        end     
        self.awardstab[i] = arr
    end
    --]]
    local desctx =bgimg1:getChildByName('desc_tx')
    self.richtext = xx.RichText:create()
    self.richtext:setContentSize(cc.size(480, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TOWER_TOTAL_STAR')..TowerMgr:getTowerData().max_star,25, COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
    self.richtext:addElement(re1)
    self.richtext:addElement(re2)
    --self.richtext:setAnchorPoint(cc.p(0,0.5))
    self.richtext:setAlignment('middle')
    self.richtext:setPosition(cc.p(0,3))
    desctx:addChild(self.richtext,9527)
    self.richtext:setVisible(true) 

    local titlebg = bgimg1:getChildByName('title_bg')
    local titletx =titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('RAIDS2'))
    --self:update()

    self.awardCell = bgimg1:getChildByName('awardcell_1_img')
    self.awardCell:setVisible(false)

    self.awardSv = bgimg1:getChildByName('award_sv')
	self.awardSv:setScrollBarEnabled(false)
    self:update2()
end

function TowerAutoFightUI:update2()
    local num = #self.awards
    local size = self.awardSv:getContentSize()
    local innerContainer = self.awardSv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 5

    local height = num * self.awardCell:getContentSize().height + (num - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = self.awardCell:getContentSize().height
    local curFight = (self.floor-1)*3+1
    for i = 1,num do
        local tempCell = self.awardCell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        if i ~= 1 then
            space = cellSpace
        end
        offset = offset + tempHeight + space
        tempCell:setPosition(cc.p(0,allHeight - offset))
        self.awardSv:addChild(tempCell)

        -- À¢–¬œ‘ æ
        local numTx = tempCell:getChildByName('num_tx')
        local str = string.format(GlobalApi:getLocalStr('TOWER_GUANQIA'),curFight)
        numTx:setString(str)

        local awardFrame = tempCell:getChildByName('awardframe')
        local awardData = self.awards[i]
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]
        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM,awards,awardFrame)
        cell.awardBgImg:setPosition(cc.p(94/2,94/2))
        cell.awardBgImg:loadTexture(awards:getBgImg())
        cell.chipImg:setVisible(true)
        cell.chipImg:loadTexture(awards:getChip())
        cell.lvTx:setString('x'..awards:getNum())
        --cell.lvTx:setVisible(false)
        cell.awardImg:loadTexture(awards:getIcon())
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        cell.nameTx:setAnchorPoint(cc.p(0, 0.5))
        cell.nameTx:setPosition(cc.p(110, 47))
        cell.nameTx:setString(awards:getName())
        cell.nameTx:setTextColor(awards:getNameColor())
        cell.nameTx:enableOutline(awards:getNameOutlineColor(), 2)

        local towercoinrewardConf = GameData:getConfData("towercoinreward")
        local towerData = towercoinrewardConf[curFight]
        local des4
        local re4
        if awards:getNum() == towerData['crit' .. 3] then
            des4 = GlobalApi:getLocalStr('BATTLE_VICTORY_DES2')
            re4 = xx.RichTextLabel:create(des4, 26, COLOR_TYPE.PURPLE)
	        re4:setStroke(COLOR_TYPE.BLACK,1)
            re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
            re4:setFont('font/gamefont.ttf')
        elseif awards:getNum() == towerData['luckyCrit' .. 3] then
            des4 = GlobalApi:getLocalStr('BATTLE_VICTORY_DES3')
            re4 = xx.RichTextLabel:create(des4, 26, COLOR_TYPE.RED)
	        re4:setStroke(COLOR_TYPE.BLACK,1)
            re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
            re4:setFont('font/gamefont.ttf')
        end

        if re4 then
            local richText = xx.RichText:create()
	        richText:setContentSize(cc.size(500, 40))
            richText:addElement(re4)

            richText:setAlignment('left')
            richText:setVerticalAlignment('middle')

	        richText:setAnchorPoint(cc.p(0,0.5))
            richText:setPosition(cc.p(cell.nameTx:getPositionX() + cell.nameTx:getContentSize().width + 20,cell.nameTx:getPositionY() - 6.5))
            richText:format(true)
            cell.awardBgImg:addChild(richText)
        end

        curFight = curFight + 1
    end
    innerContainer:setPositionY(0)
end

function TowerAutoFightUI:update()
    for i=1,3 do
        local str = string.format(GlobalApi:getLocalStr('TOWER_GUANQIA'),(self.floor-1)*3+i)
        local awardtab = self.awards[i]
        self.awardstab[i].numtx:setString(str)
        if  awardtab then
            for j=1,3 do
                local awardarr = DisplayData:getDisplayObjs(awardtab)
                if awardarr[j] then
                    ClassItemCell:updateItem(self.awardstab[i]['award'][j], awardarr[j], 1)
                    self.awardstab[i]['award'][j].awardBgImg:setVisible(true)
                    self.awardstab[i]['award'][j].nameTx:setString(awardarr[j]:getName())
                    self.awardstab[i]['award'][j].nameTx:setTextColor(awardarr[j]:getNameColor())
                    self.awardstab[i]['award'][j].nameTx:enableOutline(awardarr[j]:getNameOutlineColor(), 2)

                    local cur_floor = (self.floor-1)*3+self.cur_room
                    local towercoinrewardConf = GameData:getConfData("towercoinreward")
                    local towerData = towercoinrewardConf[cur_floor]
                    local des4
                    local re4
                    if awardarr[j]:getNum() == towerData['crit' .. 3] then
                        des4 = GlobalApi:getLocalStr('BATTLE_VICTORY_DES2')
                        re4 = xx.RichTextLabel:create(des4, 26, COLOR_TYPE.PURPLE)
	                    re4:setStroke(COLOR_TYPE.BLACK,1)
                        re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
                        re4:setFont('font/gamefont.ttf')
                    elseif awardarr[j]:getNum() == towerData['luckyCrit' .. 3] then
                        des4 = GlobalApi:getLocalStr('BATTLE_VICTORY_DES3')
                        re4 = xx.RichTextLabel:create(des4, 26, COLOR_TYPE.RED)
	                    re4:setStroke(COLOR_TYPE.BLACK,1)
                        re4:setShadow(COLOR_TYPE.BLACK, cc.size(0, -1))
                        re4:setFont('font/gamefont.ttf')
                    end

                    if re4 then
                        local richText = xx.RichText:create()
	                    richText:setContentSize(cc.size(500, 40))
                        richText:addElement(re4)

                        richText:setAlignment('left')
                        richText:setVerticalAlignment('middle')

                        local nametx = self.awardstab[i]['award'][j].nameTx
	                    richText:setAnchorPoint(cc.p(0,0.5))
                        richText:setPosition(cc.p(nametx:getPositionX() + nametx:getContentSize().width + 20,nametx:getPositionY() - 6.5))
                        richText:format(true)
                        self.awardstab[i]['award'][j].awardBgImg:addChild(richText)
                    end
                else
                    self.awardstab[i]['award'][j].awardBgImg:setVisible(false)
                end
            end           
        end
    end
end


return TowerAutoFightUI