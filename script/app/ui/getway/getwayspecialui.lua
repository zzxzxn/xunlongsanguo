local GetWaySpecialUI = class("GetWaySpecialUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function GetWaySpecialUI:ctor(obj,showgetway,num,posobj,lv,ismerge)
	self.uiIndex = GAME_UI.UI_GETWAY
	self.listview = nil
    self.obj = obj
    self.posobj = posobj
    self.neednum = num
    self.showgetway = showgetway
    self.lv = lv
    self.roleCellTable = {}
    self.ismerge = ismerge
    self.extranum = 0

	self.cloneObject = obj.cloneObject
	self.exclusiveObj = obj.exclusiveObj
end

function GetWaySpecialUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetWaySpecialUI()
        end
    end)
	local bgimg1 = bgimg:getChildByName('bg_img1')
    self:adaptUI(bgimg, bgimg1)
    self.bgimg2 = bgimg1:getChildByName('bg_img6')
	local closebtn = self.bgimg2:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetWaySpecialUI()
        end
    end)
    if not self.showgetway then
        closebtn:setVisible(false)
    end
    for i=1,8 do
        local pl = self.bgimg2:getChildByName('head_'..i..'_pl')
        pl:setVisible(false)
    end
    self:initHead()
    self:initBottom()
end

function GetWaySpecialUI:initHead()
    local typestr = self.obj:getObjType()
    print("typestr" ,typestr)
    if typestr =='material' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initMaterial()
    end
    self.parent:setVisible(true)
end

function GetWaySpecialUI:initMaterial()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)
    
    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')

    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
    infotx:setFontSize(22)
    self.obj:setLightEffect(cell.awardBgImg)

    if infotx:getContentSize().width >= 620 then
    	infotx:setFontSize(17)
    elseif infotx:getContentSize().width >= 492 then
        infotx:setFontSize(18)
    end
    infotx:setTextAreaSize(cc.size(250,80))

	iconBgNode:addChild(self.cloneObject)
	self.cloneObject:setPosition(cc.p(0,0))
	self.cloneObject:setScale(1)
	self.exclusiveObj:setLightEffect(self.cloneObject)
end


function GetWaySpecialUI:initBottom()
    self.getWayArr = GetWayMgr:getWayArr()
    local bgimg3 = self.bgimg2:getChildByName('bg_img2')
    local bgimg4 = self.bgimg2:getChildByName('bg_img5')
    local bgimg5 = self.bgimg2:getChildByName('bg_img7')
    local bgimg8 = self.bgimg2:getChildByName('bg_img8')
    local getwayimg = bgimg3:getChildByName('way_img')
    local getwaytx = getwayimg:getChildByName('way_tx')
    getwaytx:setString(GlobalApi:getLocalStr('STR_GETWAY'))
    -- local conf = GameData:getConfData('getway')[self.getWayArr[1]]
    bgimg4:setVisible(false)
    bgimg5:setVisible(false)
    bgimg8:setVisible(false)
    bgimg3:setVisible(false)

    if self.showgetway and self.getWayArr and GameData:getConfData('getway')[self.getWayArr[1]] then
        bgimg3:setVisible(true)
        self.bgimg2:setPosition(cc.p(480,320))
        self.listview = bgimg3:getChildByName('getway_listview')
        local node = cc.CSLoader:createNode("csb/getwaycell.csb")
        local cellbgimg = node:getChildByName("bg_img")
        self.listview:setItemModel(cellbgimg)
        self.listview:setScrollBarEnabled(false)
        self:initSv()
    else
        local typestr = self.obj:getObjType()
        if typestr == "skyweapon" or typestr == "skywing" then
            self.bgimg2:setPosition(cc.p(480,320))
            bgimg8:setVisible(true)
        elseif typestr == 'limitmat' then
            bgimg5:setVisible(true)
            self.bgimg2:setPosition(cc.p(480,120))
        else
            self.bgimg2:setPosition(cc.p(480,120))
            bgimg4:setVisible(true)
        end
    end
end

function GetWaySpecialUI:initSv()
    local cellnum = #self.getWayArr
    local isaddextion = false
    for i=1,cellnum do
        local count,maxcount,ispass,objarr = GetWayMgr:getwayCountarr(self.getWayArr[i],i)
        self.extranum = self.extranum + #objarr

        if #objarr > 0 then
            isaddextion = true
            self:initMap(i,objarr)           
        else
            self.listview:pushBackDefaultItem()
            local index = 0
            if isaddextion then
                index = i-1 + self.extranum -1
            else
                index = i - 1
            end
            local item = self.listview:getItem(index)
            item:setName('item_'..index)
            item:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                    GetWayMgr:hideGetWaySpecialUI()
                    GetWayMgr:goto(self.getWayArr[i],self.neednum)
                end
            end)
            local contentsize = item:getContentSize()
            local getwayconf = GameData:getConfData('getway')[tonumber(self.getWayArr[i])]
            local chapternumtx = item:getChildByName('chapter_num_tx')
            chapternumtx:setString(getwayconf.name)
            local chapternametx = item:getChildByName('chapter_name_tx')
            chapternametx:setString(getwayconf.desc)
            local chapterimg = item:getChildByName('arrow_img')
            chapterimg:ignoreContentAdaptWithSize(true)
            chapterimg:loadTexture('uires/ui/getway/' ..getwayconf.icon)
            local gopl = item:getChildByName('go_pl')
            local infotx = item:getChildByName('info_tx')
            infotx:setString(GlobalApi:getLocalStr('STR_NOTOPEN'))
            local starpl = item:getChildByName('star_pl')
            starpl:setVisible(false)
            if getwayconf.havelimit == "1" then
                local hasnum = count
                local neednum = '/' ..maxcount ..'）'
                local tx = '（' --..
                local richText = xx.RichText:create()
                richText:setContentSize(cc.size(200, 40))
                local re1 = xx.RichTextLabel:create(hasnum,23, COLOR_TYPE.RED)
                if hasnum > 0 then
                    re1:setColor(COLOR_TYPE.WHITE)
                else
                    re1:setColor(COLOR_TYPE.RED)
                end
                re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                local re2 = xx.RichTextLabel:create(neednum,23, COLOR_TYPE.WHITE)
                re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                local re3 = xx.RichTextLabel:create(tx,23, COLOR_TYPE.WHITE)
                re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_COUNT'),23, COLOR_TYPE.ORANGE)
                re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
                richText:addElement(re4)
                richText:addElement(re3)
                richText:addElement(re1)
                richText:addElement(re2)
                richText:setAnchorPoint(cc.p(0,0.5))
            
                richText:format(true)
                item:addChild(richText,9527)
                richText:setVisible(true)

                if #objarr < 1 then
                    richText:setPosition(cc.p(103.80,32.55))
                    chapternametx:setString('')-- printall(mapobj)
                end
            end
            print('ispass==='..tostring(ispass))
            if ispass then
                gopl:setVisible(true)
                infotx:setVisible(false)
                item:setTouchEnabled(true)
            else
                infotx:setVisible(true)
                gopl:setVisible(false)
                item:setTouchEnabled(false)
            end
        end
    end
end

function GetWaySpecialUI:initMap(index,objarr)
    for i=1,#objarr do
        self.listview:pushBackDefaultItem()
        local item = self.listview:getItem(index-1+i-1)
        item:setName('item_'..(index-1+i-1))
        item:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                print('self.getWayArr[index]'..self.getWayArr[index])
                if self.getWayArr[index] == 101 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('expedition',nil,{objarr[i][1]:getId(),1,self.obj,self.neednum})
                    end
                elseif self.getWayArr[index]  == 201 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('expedition',nil,{objarr[i][1]:getId(),2,self.obj,self.neednum})
                    end
                elseif self.getWayArr[index]  == 401 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('combat',nil,{objarr[i][1]:getId(),self.obj})
                    end
                elseif self.getWayArr[index]  == 701 then
                    if objarr[i][2] then
                        GlobalApi:getGotoByModule('lord',nil,{objarr[i][1]:getId()})
                    end
                end
                GetWayMgr:hideGetWaySpecialUI()
            end
        end)
        local contentsize = item:getContentSize()
        local getwayconf = GameData:getConfData('getway')[tonumber(self.getWayArr[index])]
        local chapternumtx = item:getChildByName('chapter_num_tx')
        chapternumtx:setString(getwayconf.name)
        local chapternametx = item:getChildByName('chapter_name_tx')
        chapternametx:setString(getwayconf.desc)
        local chapterimg = item:getChildByName('arrow_img')
        chapterimg:ignoreContentAdaptWithSize(true)
        chapterimg:loadTexture('uires/ui/getway/' ..getwayconf.icon)
        local gopl = item:getChildByName('go_pl')
        local infotx = item:getChildByName('info_tx')
        infotx:setString(GlobalApi:getLocalStr('STR_NOTOPEN'))
        local starpl = item:getChildByName('star_pl')
        starpl:setVisible(true)
        local stararr = {}
        for i=1,3 do
            local starbg = starpl:getChildByName('star_bg_'..i)
            stararr[i] = starbg:getChildByName('star_img')
            stararr[i]:setVisible(false)
        end
        local richText
        if getwayconf.havelimit == '1' then
            local hasnum = objarr[i][1]:getLimits(objarr[i][4])-objarr[i][1]:getTimes(objarr[i][4])
            local neednum = '/' ..objarr[i][1]:getLimits(objarr[i][4]) ..'）'
            local tx = '（' --..
            richText = xx.RichText:create()
            richText:setContentSize(cc.size(200, 40))
            local re1 = xx.RichTextLabel:create(hasnum,23, COLOR_TYPE.RED)
            if hasnum > 0 then
                re1:setColor(COLOR_TYPE.WHITE)
            else
                re1:setColor(COLOR_TYPE.RED)
            end
            re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re2 = xx.RichTextLabel:create(neednum,23, COLOR_TYPE.WHITE)
            re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re3 = xx.RichTextLabel:create(tx,23, COLOR_TYPE.WHITE)
            re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_COUNT'),23, COLOR_TYPE.ORANGE)
            re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
            richText:addElement(re4)
            richText:addElement(re3)
            richText:addElement(re1)
            richText:addElement(re2)
            richText:setAnchorPoint(cc.p(0,0.5))
        
            richText:format(true)
            item:addChild(richText,9527)
            richText:setVisible(true)
            if objarr[i][2] and objarr[i][3] then
                gopl:setVisible(true)
                infotx:setVisible(false)
                item:setTouchEnabled(true)
                starpl:setVisible(true)
            else
                infotx:setVisible(true)
                gopl:setVisible(false)
                item:setTouchEnabled(false)
                starpl:setVisible(false)
            end
        end

        if tonumber(self.getWayArr[index]) == 101 then
            chapternumtx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('NORMAL2') ..']')
            chapternumtx:setTextColor(COLOR_TYPE.WHITE)
            chapternametx:setString('')
            richText:setPosition(cc.p(103.80,32.55))
            starpl:setVisible(false)
            -- for i=1,objarr[i][1]:getStar(objarr[i][4]) do
            --     stararr[i]:setVisible(true)
            -- end
        elseif tonumber(self.getWayArr[index]) == 201 then
            chapternumtx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('ELITE2') ..']')
            chapternumtx:setTextColor(COLOR_TYPE.WHITE)
            chapternametx:setString('')
            richText:setPosition(cc.p(103.80,32.55))
            if objarr[i][2] and objarr[i][3] then
                starpl:setVisible(true)
                for i=1,objarr[i][1]:getStar(objarr[i][4])  do
                    stararr[i]:setVisible(true)
                end
            end
        elseif tonumber(self.getWayArr[index]) == 401 then
            chapternumtx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('COMBAT2') ..']')
            chapternumtx:setTextColor(COLOR_TYPE.WHITE)
            chapternametx:setString('')
            richText:setPosition(cc.p(103.80,32.55))
            starpl:setVisible(false)
            -- for i=1,objarr[i][1]:getStar(objarr[i][4])  do
            --     stararr[i]:setVisible(true)
            -- end
        else
            if  tonumber(self.getWayArr[index]) == 101 then
                chapternametx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('NORMAL2') ..']'..GlobalApi:getLocalStr('STR_DROP'))-- printall(mapobj)
            elseif tonumber(self.getWayArr[index]) == 201 then
                chapternametx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('ELITE2') ..']'..GlobalApi:getLocalStr('STR_DROP'))
            elseif tonumber(self.getWayArr[index]) == 401 then
                chapternametx:setString('['..objarr[i][1]:getName() ..'-'..GlobalApi:getLocalStr('COMBAT2') ..']'..GlobalApi:getLocalStr('STR_DROP'))
            end
            starpl:setVisible(false)
            chapternametx:setTextColor(COLOR_TYPE.ORANGE)
            richText:setPosition(cc.p(200,70))
        end
    end
end

return GetWaySpecialUI
