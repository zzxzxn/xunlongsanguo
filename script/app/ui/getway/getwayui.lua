local GetWayUI = class("GetWayUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function GetWayUI:ctor(obj,showgetway,num,posobj,lv,ismerge)
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
end

function GetWayUI:init()
	local bgimg = self.root:getChildByName("bg_img")
    bgimg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            GetWayMgr:hideGetwayUI()
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
            GetWayMgr:hideGetwayUI()
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

function GetWayUI:initHead()
    local typestr = self.obj:getObjType()
    print("typestr" ,typestr)
    if typestr =='material' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initMaterial()
    elseif typestr == 'card' then
        self.parent = self.bgimg2:getChildByName('head_2_pl')
        self:initRole()
    elseif typestr == 'equip' then
        self.parent = self.bgimg2:getChildByName('head_3_pl')
        self:initEquip()
    elseif typestr == 'fragment' then
        self.parent = self.bgimg2:getChildByName('head_4_pl')
        self:initFragment()
    elseif typestr == 'gem' then
        self.parent = self.bgimg2:getChildByName('head_5_pl')
        self:initGem()
    elseif typestr == 'dress' then
        self.parent = self.bgimg2:getChildByName('head_6_pl')
        self:initDress()
    elseif typestr == 'user' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initUse()
    elseif typestr == 'dragon' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initDragon()
    elseif typestr == 'headframe' then
        self.parent = self.bgimg2:getChildByName('head_1_pl')
        self:initMaterial()
    elseif typestr == "limitmat" then
        self.parent = self.bgimg2:getChildByName('head_7_pl')
        self:initLimitMat()
    elseif typestr == "skyweapon" or typestr == "skywing" then
        self.parent = self.bgimg2:getChildByName('head_8_pl')
        self:initPeopleKing()
	elseif typestr == 'exclusive' then
		self.parent = self.bgimg2:getChildByName('head_1_pl')
		self:initExclusive()
    end
    self.parent:setVisible(true)
end

function GetWayUI:initExclusive()
	self:initMaterial()
	local iconBgNode = self.parent:getChildByName('icon_bg_node')
	local awardBgImg = iconBgNode:getChildByName('award_bg_img')
	ClassItemCell:updateExclusiveStar(awardBgImg,self.obj)
end

function GetWayUI:initFragment()
    local cardobj = RoleData:getRoleInfoById(self.obj:getId())
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local displayobj = DisplayData:getDisplayObj({'fragment',cardobj:getId(),1})
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local getwarytx = self.parent:getChildByName('getway_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infobtn = self.parent:getChildByName('info_btn')
    local infobtntx = infobtn:getChildByName('func_tx')
    infobtntx:setString(GlobalApi:getLocalStr('INFO'))
    infobtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if ChartMgr.uiClass["chartInfoUI"] then
                GetWayMgr:hideGetwayUI()
            else
                ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.CHIP_MERGET, self.obj)
            end           
        end
    end)
    
    getwarytx:setString(GlobalApi:getLocalStr('STR_GETWAY2'))
    local richText = xx.RichText:create()
    local hasnum = 0
    if self.showgetway then
        hasnum =self.obj:getNum()
    else
        hasnum =self.obj:getOwnNum()
    end
    local neednum = self.obj:getMergeNum()
    local tx1 = hasnum
    local tx2 = '/' .. neednum ..')'
    local tx3 = '('
    richText:setContentSize(cc.size(130, 40))
    local re1 = xx.RichTextLabel:create(tx1,23, COLOR_TYPE.RED)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,23, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(tx3,23, COLOR_TYPE.WHITE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re3)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(numtx:getPositionX(),numtx:getPositionY()))
    self.parent:addChild(richText,9527)
    richText:setVisible(true)
end

function GetWayUI:initDress()
    local infobtn = self.parent:getChildByName("info_btn")
    local infotx = infobtn:getChildByName('func_tx')
    infotx:setString(GlobalApi:getLocalStr('EQUIP'))
    local getwaytx = self.parent:getChildByName('desc_3')
    local limittx =self.parent:getChildByName('limit_tx')
    if self.showgetway  then
        infobtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType ==  ccui.TouchEventType.ended then
                local hasnum = self.obj:getNum()
                if hasnum >= self.neednum then
                    local args = {
                        pos = self.posobj:getPosId(),
                        slot = self.obj:getId()%10
                    }
                    MessageMgr:sendPost("dress_wear", "hero", json.encode(args), function (jsonObj)
                        print(json.encode(jsonObj))
                        local code = jsonObj.code
                        if code == 0 then
                            local awards = jsonObj.data.awards
                            GlobalApi:parseAwardData(awards)
                            local costs = jsonObj.data.costs
                            if costs then
                                GlobalApi:parseAwardData(costs)
                            end
                            self.posobj:setSoldierdress(self.obj:getId()%10)
                            self.posobj:setFightForceDirty(true)
                            RoleMgr:updateRoleMainUI()
                            GetWayMgr:hideGetwayUI()
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('EQUIP_SUCC'), COLOR_TYPE.GREEN)
                        end
                    end)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('MATERIAL_NOT_ENOUGH'), COLOR_TYPE.RED)
                end
            end
        end)
        infobtn:setVisible(true)


        getwaytx:setString('')
        local numtx = self.parent:getChildByName('desc_3')

        local richText = xx.RichText:create()
        local hasnum = 0
        if self.showgetway then
            hasnum =self.obj:getNum()
        else
            hasnum = self.obj:getOwnNum()
        end

        local tx1 = hasnum
        local tx2 = '/' .. self.neednum ..')'
        local tx3 = '('
        local tx4 = GlobalApi:getLocalStr('STR_GETWAY2')..':'
        richText:ignoreContentAdaptWithSize(false)
        richText:setContentSize(cc.size(250, 40))
        local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.WHITE)
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.WHITE)
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re4 = xx.RichTextLabel:create(tx4,21, COLOR_TYPE.ORANGE)
        re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

        local infotx = infobtn:getChildByName('func_tx')
        if hasnum >= self.neednum then
            --re1:setColor(COLOR_TYPE.WHITE)
            infobtn:setBright(true)
            infobtn:setEnabled(true)
            infotx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        else
            re1:setColor(COLOR_TYPE.RED)
            infobtn:setBright(false)
            infobtn:setEnabled(false)
            infotx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        end
        
        richText:addElement(re4)
        richText:addElement(re3)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:setAnchorPoint(cc.p(0,1))
        richText:setAlignment('left')
        richText:setPosition(cc.p(0,0))
        numtx:addChild(richText,9527)
        richText:setVisible(true)
        if self.ismerge then
            infobtn:setVisible(false)
            re1:setString(hasnum)
            re2:setString('')
            re3:setString('')
        else
            if self.posobj and tonumber(self.posobj:getLevel()) < tonumber(self.lv) then
                limittx:setString(string.format(GlobalApi:getLocalStr('STR_NEEDLV'),self.lv))
                infobtn:setVisible(false)
            else
                limittx:setString('')
                infobtn:setVisible(true)
            end
        end
        richText:format(true)
    else
        infobtn:setVisible(false)
        getwaytx:setString('')
        limittx:setString('')
        local infotx = self.parent:getChildByName('desc_3')
        infotx:ignoreContentAdaptWithSize(false)
        infotx:setTextAreaSize(cc.size(250,80))
        infotx:setString(self.obj:getDesc())
        local richText = xx.RichText:create()
        local neednum = self.neednum
        local tx1 = GlobalApi:getLocalStr('STR_HAD')
        local tx2 = self.obj:getOwnNum()
        local tx3 = GlobalApi:getLocalStr('GE')

        richText:setContentSize(cc.size(200, 40))
        local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.ORANGE)
        re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
        re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.ORANGE)
        re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        richText:addElement(re1)
        richText:addElement(re2)
        richText:addElement(re3)
        richText:setAnchorPoint(cc.p(1,0.5))
        richText:setAlignment('right')
        richText:setPosition(cc.p(400,87))
        self.parent:addChild(richText,9527)
        richText:setVisible(true)
    end
    local nametx = self.parent:getChildByName('name_tx')
    nametx:setString(self.obj:getName())

    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)
end

function GetWayUI:initGem()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(250,80))
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
    self.obj:setLightEffect(cell.awardBgImg)
    local richText = xx.RichText:create()
    local gemobj =BagData:getGemById(self.obj:getId())
    local hasnum = 0
    if gemobj ~= nil then
        hasnum =gemobj:getNum()
    end
    local tx1 = GlobalApi:getLocalStr('STR_HAD')
    local tx2 = hasnum
    local tx3 = GlobalApi:getLocalStr('GE')
    richText:setContentSize(cc.size(200, 40))
    local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.ORANGE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setAnchorPoint(cc.p(1,0.5))
    richText:setAlignment('right')
    richText:setPosition(cc.p(numtx:getPositionX(),numtx:getPositionY()-6))
    self.parent:addChild(richText,9527)
    richText:setVisible(true)
end

function GetWayUI:initMaterial()
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
end

function GetWayUI:initLimitMat()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)
    
    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    local timebg = self.parent:getChildByName('time_bg')
    local timetx = timebg:getChildByName('time_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(250,80))
    timetx:setString('')
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
    infotx:setFontSize(22)
    self.obj:setLightEffect(cell.awardBgImg)

    local itemId = tonumber(GlobalApi:getGlobalValue('heroQualityCostItem'))
    if self.obj:getId() == itemId then
        infotx:setFontSize(17)
    elseif self.obj:getId() == 200064 then
        infotx:setFontSize(19)
    end
    if self.showgetway  then
        timetx:removeAllChildren()
        timebg:setVisible(false)
    else
        timebg:setVisible(true)
        local time = 0--GlobalData:getServerTime()
        if tonumber(self.obj:getTimeType()) == 1 then
            time = self.obj:getTime()
            local str1 = string.sub(time,1,-7)
            local str2 = string.sub(time,5,-5)
            local str3 = string.sub(time,7,-3)
            local str4 = string.sub(time,9)
            local str =  str1..GlobalApi:getLocalStr('YEAR')..str2..GlobalApi:getLocalStr('MONTH')..str3..GlobalApi:getLocalStr('DAY_DESC_1')
            local strtemp = GlobalApi:getLocalStr('LIMIT_TIME_DESC')..str..str4..GlobalApi:getLocalStr('HOUR')
            timetx:setString(strtemp)
        elseif tonumber(self.obj:getTimeType()) == 2 then
            time = self.obj:getTime()
            timetx:setString( GlobalApi:getLocalStr('LIMIT_DESC')..'：'..time..GlobalApi:getLocalStr('DAY'))
        end
    end
end

function GetWayUI:initDragon()
    local attconf = GameData:getConfData('attribute')
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(250,80))
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(GlobalApi:getLocalStr("TRARIN_DRAGON_GET_ATTR") .. self.obj:getAttNum() .. "%" .. attconf[self.obj:getAttType()].name)
    infotx:setFontSize(22)
end

function GetWayUI:initUse()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local infotx = self.parent:getChildByName('info_tx')
    infotx:ignoreContentAdaptWithSize(false)
    infotx:setTextAreaSize(cc.size(250,80))
    nametx:setString(self.obj:getName())
    nametx:setColor(self.obj:getNameColor())
    infotx:setString(self.obj:getDesc())
end

function GetWayUI:initRole()
    local cardobj = RoleData:getRoleInfoById(self.obj:getId())
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, cardobj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local numtx = self.parent:getChildByName('num_tx')
    local chipnumtx = self.parent:getChildByName('chip_num_tx')
    nametx:setString(cardobj:getName())
    nametx:setColor(cardobj:getNameColor())

    local richText = xx.RichText:create()
    local cardobj1 =BagData:getCardById(self.obj:getId())
    local hasnum = 0
    if cardobj1 ~= nil then
        if self.showgetway then
            hasnum = cardobj1:getOwnNum()
        else
            hasnum = self.obj:getNum()
        end
    else

    end
    local tx1 = GlobalApi:getLocalStr('STR_HAD')
    local tx2 = hasnum
    local tx3 = GlobalApi:getLocalStr('STR_ZHANG')
    richText:setContentSize(cc.size(130, 40))
    local re1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.ORANGE)
    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:setAnchorPoint(cc.p(0,0.5))
    richText:setPosition(cc.p(numtx:getPositionX(),numtx:getPositionY()-6))
    self.parent:addChild(richText,9527)
    richText:setVisible(true)

    local richTextchip = xx.RichText:create()
    local hasnum = 0
    if cardobj:getId() <= 10000 then
        local fragmentobj1 = BagData:getFragmentById(cardobj:getId())
        if fragmentobj1 ~= nil then
            if self.showgetway then
                hasnum =fragmentobj1:getNum()
            else
                hasnum = fragmentobj1:getOwnNum()
            end
        end
        local neednum = GameData:getConfData("item")[tonumber(cardobj:getId())]['mergeNum']
        --local neednum = fragmentobj1:getMergeNum()
        local tx1 = hasnum
        local tx2 = '/' .. neednum ..')'
        local tx3 = '('
        --local tx4 = '碎片数量：'
        richTextchip:setContentSize(cc.size(260, 40))
        local rechip1 = xx.RichTextLabel:create(tx1,21, COLOR_TYPE.RED)
        rechip1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local rechip2 = xx.RichTextLabel:create(tx2,21, COLOR_TYPE.WHITE)
        rechip2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local rechip3 = xx.RichTextLabel:create(tx3,21, COLOR_TYPE.WHITE)
        rechip3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
        local rechip4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_MERGE_DES2'),21, COLOR_TYPE.WHITE)
        rechip4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

        if hasnum >= neednum then
            rechip1:setColor(COLOR_TYPE.WHITE)
        else
            rechip1:setColor(COLOR_TYPE.RED)
        end
        richTextchip:addElement(rechip4)
        richTextchip:addElement(rechip3)
        richTextchip:addElement(rechip1)
        richTextchip:addElement(rechip2)
        richTextchip:setAnchorPoint(cc.p(0,0.5))
        richTextchip:setPosition(cc.p(chipnumtx:getPositionX(),chipnumtx:getPositionY()-5))
        self.parent:addChild(richTextchip,9527)
        richTextchip:setVisible(true)
    end
end

function GetWayUI:initEquip()
    local iconBgNode = self.parent:getChildByName('icon_bg_node')
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, self.obj, iconBgNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    local nametx = self.parent:getChildByName('name_tx')
    local mainatttx = self.parent:getChildByName('mainatt_tx')
    local god1tx = self.parent:getChildByName('god_1_tx')
    local god2tx = self.parent:getChildByName('god_2_tx')
    nametx:setString('Lv.'..self.obj:getLevel()..' '..self.obj:getName())
    nametx:setColor(self.obj:getNameColor())

    local equipConf =GameData:getConfData('equip')[self.obj:getId()]
    local attributeConf = GameData:getConfData("attribute")
    local mainAttribute = {}
    mainAttribute.name = attributeConf[equipConf.attributeType].name
    mainAttribute.value = equipConf.attributeValue

    local mainAttributeStr = mainAttribute.name .. "：+" .. mainAttribute.value
    mainatttx:setString(mainAttributeStr)
    god1tx:setString(GlobalApi:getLocalStr('GETWAY_EQUIP'..self.obj:getQuality()-1) )
    if self.obj:getGodId() and self.obj:getGodId() > 0 then
        local godObj = self.obj:getObj():getGodAttr()
        if godObj[1] then
            god2tx:setString(GlobalApi:getLocalStr('GETWAY_GOD1'))
            if godObj[2] then
                god2tx:setString(GlobalApi:getLocalStr('GETWAY_GOD2'))
            end
        end
    end
end

function GetWayUI:initPeopleKing()

    local modelNode = self.parent:getChildByName('model_node')
    local nameTx = self.parent:getChildByName('name_tx')
    local typeNameTx = self.parent:getChildByName('typename_tx')
    local timeTx = self.parent:getChildByName('time_tx')
    local attrTx = self.parent:getChildByName('attr_tx')

    local customObj = {}
    local typestr = self.obj:getObjType()
    local id = self.obj:getId()
    local typeid,typenameStr = 1,''
    if typestr == "skyweapon" then
        typeid = 1
        customObj.weapon_illusion = id
        typenameStr = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_1")
    elseif typestr == "skywing" then
        typeid = 2
        customObj.wing_illusion = id
        typenameStr = GlobalApi:getLocalStr("PEOPLE_KING_TITLE_DESC_2")
    end

    typeNameTx:setString(typenameStr)
    local roleObj = RoleData:getMainRole()
    local mainRoleAni = GlobalApi:createLittleLossyAniByName(roleObj:getUrl() .. "_display", nil, roleObj:getChangeEquipState(customObj))
    mainRoleAni:getAnimation():play("idle", -1, 1)
    mainRoleAni:setPosition(cc.p(0, 0))
    modelNode:addChild(mainRoleAni)

    local name = self.obj:getName()
    nameTx:setString(name)

    local timeType = self.obj:getTimeType()
    if timeType == "2" then
        timeTx:setString(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_9"))
    else
        local time = self.obj:getTime()
        local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_11"),time)
        timeTx:setString(str)
    end

    local skychangeConf = GameData:getConfData("skychange")[typeid]
    local confInfo = skychangeConf[id]
    if confInfo.attribute == 0 then
        attrTx:setString("")
    else
        local str = string.format(GlobalApi:getLocalStr("PEOPLE_KING_CHANGELOOK_DESC_10"),typenameStr,confInfo.attribute).."%"
        attrTx:setString(str)
    end

end

function GetWayUI:initBottom()

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

function GetWayUI:initSv()
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
                    GetWayMgr:hideGetwayUI()
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

function GetWayUI:initMap(index,objarr)
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
                GetWayMgr:hideGetwayUI()
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

return GetWayUI
