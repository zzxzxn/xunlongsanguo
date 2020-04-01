local LegionApplyUI = class("LegionApplyUI", BaseUI)

local defaultnor = 'uires/ui/common/title_btn_nor_1.png'
local defaultsel = 'uires/ui/common/title_btn_sel_1.png'

function LegionApplyUI:ctor(data)
  self.uiIndex = GAME_UI.UI_LEGIONAPPLY
  self.data = data
  self.applylistdata = self.data.applicant_list
  self.legionTable = {}
  self.legionglobalconf = GameData:getConfData('legion')
  self.legionlvconf = GameData:getConfData('legionlevel')
end

function LegionApplyUI:addCells(index,data)
    local node = cc.CSLoader:createNode("csb/legionapplycell.csb")
    local bgimg = node:getChildByName("bg_img")
    bgimg:removeFromParent(false)
    self.legionTable[index] = ccui.Widget:create()
    self.legionTable[index]:addChild(bgimg)

    --self.legionTable[index] = cc.CSLoader:createNode("csb/legionapplycell.csb")
    self:updateCell(index,data)
    local bgimg = self.legionTable[index]:getChildByName("bg_img")
    local contentsize = bgimg:getContentSize()
    if self.num*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,self.num*(contentsize.height+5)))
    end

    local posy = self.sv:getInnerContainerSize().height-(5 + contentsize.height)*(index-1)- contentsize.height-10
    self.legionTable[index]:setPosition(cc.p(3,posy))
    self.sv:addChild(self.legionTable[index])
end

function LegionApplyUI:onShow()
    self:initCreate()
    self:initApply()
end

function LegionApplyUI:updateCell(index,data)
    local bgimg = self.legionTable[index]:getChildByName("bg_img")
    bgimg:setSwallowTouches(false)
    bgimg:setPropagateTouchEvents(false)
    local legioniconbg = bgimg:getChildByName('legion_icon_bg')
    local legionicon = legioniconbg:getChildByName('icon_img')
    legionicon:ignoreContentAdaptWithSize(true)
    local iconConf = GameData:getConfData("legionicon") 
    legioniconbg:loadTexture(COLOR_FRAME[iconConf[data[2].icon].frameQuality])
    legionicon:loadTexture(iconConf[data[2].icon].icon)
    local legionnametx = bgimg:getChildByName('legion_name_tx')
    legionnametx:setString(data[2].name)
    local legionlvtx = bgimg:getChildByName('legion_lv_tx')
    legionlvtx:setString('Lv.'..data[2].level)
    local legionmembertx = bgimg:getChildByName('legion_member_num_tx')
    legionmembertx:setString('('..data[2].members_count ..'/'..self.legionlvconf[data[2].level].memberMax..')')
    if data[2].members_count == self.legionlvconf[data[2].level].memberMax then
        legionmembertx:setTextColor(COLOR_TYPE.RED)
    else
        legionmembertx:setTextColor(COLOR_TYPE.GREEN)
    end
    local legionlvlimittx = bgimg:getChildByName('legion_lv_limit')
    local str = string.format(GlobalApi:getLocalStr('LEGION_LV_LIMIT'),data[2].level_limit)
    legionlvlimittx:setString(str)
    if UserData:getUserObj():getLv() < data[2].level_limit then
        legionlvlimittx:setTextColor(COLOR_TYPE.RED)
    else
        legionlvlimittx:setTextColor(COLOR_TYPE.WHITE)
    end

    local leadernametx = bgimg:getChildByName('leader_name_tx')
    local leadernamedesctx = bgimg:getChildByName('leader_name_desc_tx')
    leadernamedesctx:setString(GlobalApi:getLocalStr('VITALITY')..': '..data[2].xp)
    --leadernametx:setString()
    local applybtn = bgimg:getChildByName('apply_btn')
    local applybtntx = applybtn:getChildByName('btn_tx')

    if self:isApplyed(data[1]) then
        applybtntx:setString(GlobalApi:getLocalStr('LEGION_APPLY_BTN_DESC3'))
    elseif data[2].type == 1 and self:isApplyed(data[1]) ~= true then
        applybtntx:setString(GlobalApi:getLocalStr('LEGION_APPLY_BTN_DESC2'))
    else
        applybtntx:setString(GlobalApi:getLocalStr('LEGION_APPLY_BTN_DESC1'))
    end
    applybtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if self:isApplyed(data[1]) then
                local obj = {
                    lid = tonumber(data[1])
                }
                MessageMgr:sendPost('revoke_request','legion',json.encode(obj),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        self.applylistdata = data.applicant_list
                        self:updateCell(index,self.legionarr[index])
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_REVOKE_SUC'), COLOR_TYPE.GREEN)
                    elseif code == 102 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_102'), COLOR_TYPE.RED)
                    elseif code == 117 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_117'), COLOR_TYPE.RED)
                    elseif code == 104 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_104'), COLOR_TYPE.RED)        
                    end
                end)
            else
                if GlobalData:getServerTime() - self.legionglobalconf['joinTimeLimit'].value < self.data.leave_time then
                    local str = string.format(GlobalApi:getLocalStr('LEGION_APPLY_TIME_NEED'),math.ceil((self.data.leave_time+self.legionglobalconf['joinTimeLimit'].value-GlobalData:getServerTime())/3600))
                    promptmgr:showSystenHint(str, COLOR_TYPE.RED)
                    return                    
                end
                if #self.applylistdata >= tonumber(self.legionglobalconf['memberApplicantLimit'].value) then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_MAX'), COLOR_TYPE.RED)
                    return
                end
                if UserData:getUserObj():getLv() < data[2].level_limit then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LV_NOT_ENOUCH'), COLOR_TYPE.RED)
                    return
                end
                if data[2].members_count == self.legionlvconf[data[2].level].memberMax then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_MAMBER_MAX'), COLOR_TYPE.RED)
                    return
                end
                local obj = {
                    lid = tonumber(data[1])
                }
                MessageMgr:sendPost('join','legion',json.encode(obj),function (response)
                    
                    local code = response.code
                    local data = response.data
                    if code == 0 then
                        if data.legion then
                            local firstJoin = cc.UserDefault:getInstance():getBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',false)
                            if not firstJoin then
                                cc.UserDefault:getInstance():setBoolForKey(UserData:getUserObj():getUid()..'first_join_legion',true)
                            end
							UserData:getUserObj():setLegion(data.legion.lid, data.legion.name, data.legion.level,data.legion.gold_tree,data.legion.lduty,data.legion.ltype,data.legion.wish)
                            LegionMgr:hideLegionApplyUI()
                            LegionMgr:showLegionMainUI(data.legion)
                        else
                            self.applylistdata = data.applicant_list
                            self:updateCell(index,self.legionarr[index]) 
                            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_APPLY_SUC'), COLOR_TYPE.GREEN)          
                        end
                    elseif code == 102 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_102'), COLOR_TYPE.RED)
                    elseif code == 104 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_104'), COLOR_TYPE.RED)
                    elseif code == 105 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_105'), COLOR_TYPE.RED)
                    elseif code == 117 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_117'), COLOR_TYPE.RED) 
                    end
                end)
            end
        end
    end)
end
function LegionApplyUI:init()
    local bgimg1 = self.root:getChildByName("bg_big_img")
    local bgimg2 = bgimg1:getChildByName('bg_img')
    -- bgimg2:addTouchEventListener(function (sender, eventType)
    --     if eventType == ccui.TouchEventType.ended then
    --         LegionMgr:hideLegionApplyUI()
    --     end
    -- end)
    self:adaptUI(bgimg1, bgimg2)
    local bgimg3 = bgimg2:getChildByName('bg_img1')
    local closebtn = bgimg3:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:hideLegionApplyUI()
        end
    end)
    self.applybtn = bgimg3:getChildByName('apply_btn')
    self.applybtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            self.createpl:setVisible(false)
            self.applypl:setVisible(true)
            self.applybtn:loadTextureNormal(defaultsel)
            self.createbtn:loadTextureNormal(defaultnor)
            self.createbtntx:setTextColor(cc.c4b(207,186,141,255))
            self.applybtntx:setTextColor(cc.c4b(255,255,255,255))
        end
    end)
    

    self.createbtn = bgimg3:getChildByName('create_btn')
    self.createbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.createpl:setVisible(true)
            self.applypl:setVisible(false)
            self.applybtn:loadTextureNormal(defaultnor)
            self.createbtn:loadTextureNormal(defaultsel)
            self.applybtntx:setTextColor(cc.c4b(207,186,141,255))
            self.createbtntx:setTextColor(cc.c4b(255,255,255,255))
        end
    end)
    self.applybtntx = self.applybtn:getChildByName('btn_tx')
    self.applybtntx:setString(GlobalApi:getLocalStr('LEGION_JION_TITLE'))
    self.createbtntx = self.createbtn:getChildByName('btn_tx')
    self.createbtntx:setString(GlobalApi:getLocalStr('LEGION_CREATE_TITLE'))
    local titlebg = bgimg3:getChildByName('title_bg')
    local titletx = titlebg:getChildByName('title_tx')
    titletx:setString(GlobalApi:getLocalStr('LEGION_TITLE'))
    self.createpl = bgimg3:getChildByName('create_pl')
    local nameidboxbg = self.createpl:getChildByName('idbox_bg')
    local nameidboxtx = nameidboxbg:getChildByName('idbox_tx')
    nameidboxbg:setLocalZOrder(1)
    nameidboxtx:setString(GlobalApi:getLocalStr('LEGION_NAME_LIMIT'))

    local maxLen = self.legionglobalconf['legionNameMax'].value
    self.nameeditbox = cc.EditBox:create(cc.size(318, 50), 'uires/ui/common/common_bg_10.png')
    self.nameeditbox:setPlaceholderFontColor(cc.c3b(255, 255, 255))
    self.nameeditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.nameeditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.nameeditbox:setPlaceHolder('')
    self.nameeditbox:setPosition(484, 396)
    self.nameeditbox:setFontSize(25)
    self.nameeditbox:setText('')
    self.nameeditbox:setFontColor(cc.c3b(255, 255, 255))
    -- self.nameeditbox:setMaxLength(maxLen)
    -- self.nameeditbox:setOpacity(0)
    self.createpl:addChild(self.nameeditbox)

    self.nameTx = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    self.nameTx:setPosition(cc.p(484, 396))
    self.nameTx:setColor(COLOR_TYPE.WHITE)
    self.nameTx:enableOutline(COLOR_TYPE.BLACK, 1)
    self.nameTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx:setAnchorPoint(cc.p(0.5,0.5))
    self.nameTx:setName('name_tx')
    self.createpl:addChild(self.nameTx)

    local oldStr = ''
    self.nameeditbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.nameeditbox:setText(self.nameTx:getString())
            oldStr = self.nameTx:getString()
            self.nameTx:setString('')
            nameidboxtx:setString('')
        elseif event == "ended" then
            local str = self.nameeditbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
                self.nameTx:setString(str1 or oldStr or '')
            else
                self.nameTx:setString(str)
            end
            self.nameeditbox:setText('')
            if self.nameTx:getString() == '' then
                nameidboxtx:setString(GlobalApi:getLocalStr('LEGION_NAME_LIMIT'))
            else
                nameidboxtx:setString('')
            end
        end
    end)
    

    self.applypl = bgimg3:getChildByName('apply_pl')
    local svtitlebg = self.applypl:getChildByName('sv_title_bg')
    local idboxbg = svtitlebg:getChildByName('idbox_bg')
    idboxbg:setLocalZOrder(2)
    self.idboxtx = idboxbg:getChildByName('idbox_tx')
    self.idboxtx:setString(GlobalApi:getLocalStr('LEGION_ID_LIMIT'))
    
    self.ideditbox = cc.EditBox:create(cc.size(318, 50), 'uires/ui/common/common_bg_10.png')
    self.ideditbox:setPlaceholderFontColor(cc.c4b(255, 255, 255,0))
    self.ideditbox:setPlaceHolder('')
    self.ideditbox:setPosition(289, 30)
    self.ideditbox:setFontSize(25)
    self.ideditbox:setText('')
    self.ideditbox:setInputFlag(cc.EDITBOX_INPUT_FLAG_SENSITIVE)
    self.ideditbox:setInputMode(cc.EDITBOX_INPUT_MODE_SINGLELINE)
    self.ideditbox:setFontColor(cc.c3b(255, 255, 255))
    self.ideditbox:setMaxLength(8)
    -- self.ideditbox:setOpacity(0)
    svtitlebg:addChild(self.ideditbox)

    self.nameTx1 = cc.Label:createWithTTF("", "font/gamefont.ttf", 25)
    self.nameTx1:setPosition(cc.p(289, 30))
    self.nameTx1:setColor(COLOR_TYPE.WHITE)
    self.nameTx1:enableOutline(COLOR_TYPE.BLACK, 1)
    self.nameTx1:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    self.nameTx1:setAnchorPoint(cc.p(0.5,0.5))
    self.nameTx1:setName('name_tx')
    svtitlebg:addChild(self.nameTx1)

    local oldStr1 = ''
    self.ideditbox:registerScriptEditBoxHandler(function(event,pSender)
        if event == "began" then
            self.ideditbox:setText(self.nameTx1:getString())
            oldStr1 = self.nameTx1:getString()
            self.nameTx1:setString('')
            self.idboxtx:setString('')
        elseif event == "ended" then
            local str = self.ideditbox:getText()
            local unicode = GlobalApi:utf8_to_unicode(str)
            local len = string.len(unicode)
            unicode = string.sub(unicode,1,maxLen*6)
            local utf8 = GlobalApi:unicode_to_utf8(unicode)
            str = utf8
            local isOk,str1 = GlobalApi:checkSensitiveWords(str)
            if not isOk then
                -- promptmgr:showMessageBox(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), MESSAGE_BOX_TYPE.MB_OK)
                self.nameTx1:setString(str1 or oldStr1 or '')
            else
                self.nameTx1:setString(str)
            end
            self.ideditbox:setText('')
            if self.nameTx1:getString() == '' then
                self.idboxtx:setString(GlobalApi:getLocalStr('LEGION_ID_LIMIT'))
            else
                self.idboxtx:setString('')
            end
        end
    end)

    self.sv = self.applypl:getChildByName('sv')
    self.sv:setScrollBarEnabled(false)
    self.createpl:setVisible(false)
    self.applypl:setVisible(true)
    self.applybtn:loadTextureNormal(defaultsel)
    self.createbtn:loadTextureNormal(defaultnor)
    self.createbtntx:setTextColor(cc.c4b(207,186,141,255))
    self.applybtntx:setTextColor(cc.c4b(255,255,255,255))
    self:initCreate()
    self:initApply()
    self:update()
end

function LegionApplyUI:initCreate()
    local legionglobalconf = GameData:getConfData('legion')
    local legionnametx = self.createpl:getChildByName('legion_name_tx')
    legionnametx:setString(GlobalApi:getLocalStr('LEGION_NAME')..':')
    local legionicontx = self.createpl:getChildByName('icon_tx')
    legionicontx:setString(GlobalApi:getLocalStr('LEGION_ICON')..':')
    --local legionlimittx =self.createpl:getChildByName('need_tx')
    --legionlimittx:setString(string.format(GlobalApi:getLocalStr('LEGION_LIMIT'),'VIP2'))
    local createbtn = self.createpl:getChildByName('create_btn')
    local buyImg = self.createpl:getChildByName('buy_img')
    local txtCost = buyImg:getChildByName('txt_cost')
    txtCost:setString(1000)
    -- 判断是否是免费的
    local cost = tonumber(legionglobalconf['legionCreateCost'].value)
    local judge = false
    if UserData:getUserObj():getVip() >= tonumber(legionglobalconf['legionCreateVip'].value) and UserData:getUserObj().mark.first_create_legion == 1 then -- 免费
        judge = true
    else
        judge = false
    end

    local winSize = cc.Director:getInstance():getWinSize()
    if judge == true then -- 免费
        createbtn:setPositionX(winSize.width/2 - 100)
        buyImg:setVisible(false)
    else
        createbtn:setPositionX(winSize.width/2)
        buyImg:setVisible(true)
        txtCost:setString(cost)
    end

    local legioniconimg = self.createpl:getChildByName('icon_bg_img')
    local legionicon = legioniconimg:getChildByName('icon_img')
    legionicon:ignoreContentAdaptWithSize(true)
    local iconConf = GameData:getConfData("legionicon") 
    legioniconimg:loadTexture(COLOR_FRAME[iconConf[LegionMgr:getSelectIconID()].frameQuality])
    legionicon:loadTexture(iconConf[LegionMgr:getSelectIconID()].icon)
    local createbtntx = createbtn:getChildByName('btn_tx')
    createbtntx:setString(GlobalApi:getLocalStr('LEGION_CREATE'))
    createbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- 创建的时候判断是否消耗元宝
            if self.nameTx:getString() == '' then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_ERROR_2'), COLOR_TYPE.RED)
            else
                if judge == true then
                    local function callBack()
                        UserData:getUserObj().mark.first_create_legion = 0
                    end
                    self:createMsg(callBack)
                else
                    UserData:getUserObj():cost('cash',cost,function()
                        self:createMsg()
                    end)     
                end
                --UserData:getUserObj():cost('vip',legionglobalconf['legionCreateVip'].value,self:createMsg(),true,'')
            end
            
        end
    end)
    local changeiconbtn = self.createpl:getChildByName('changeicon_btn')
    local changeiconbtntx = changeiconbtn:getChildByName('btn_tx')
    changeiconbtntx:setString(GlobalApi:getLocalStr('LEGION_CHANGE_ICON'))
    changeiconbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionMgr:showLegionIconSelectUI()
        end
    end)

    -- 右边文字
    if not self.richText then
        local richText = xx.RichText:create()
        richText:setName(richTextName)
	    richText:setContentSize(cc.size(500, 40))
	    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_MENBER_DES13'), 24,COLOR_TYPE.WHITE)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re1:setShadow(COLOROUTLINE_TYPE.BLACK, cc.size(0, -1))
        re1:setFont('font/gamefont.ttf')

	    local re2 = xx.RichTextLabel:create('VIP'.. 2, 24,COLOR_TYPE.ORANGE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re2:setShadow(COLOROUTLINE_TYPE.BLACK, cc.size(0, -1))
        re2:setFont('font/gamefont.ttf')

	    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('LEGION_MENBER_DES12'), 24,COLOR_TYPE.WHITE)
	    re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
        re3:setShadow(COLOROUTLINE_TYPE.BLACK, cc.size(0, -1))
        re3:setFont('font/gamefont.ttf')

	    richText:addElement(re1)
	    richText:addElement(re2)
        richText:addElement(re3)

        richText:setAlignment('left')
        richText:setVerticalAlignment('middle')

	    richText:setAnchorPoint(cc.p(0,0.5))
	    richText:setPosition(cc.p(createbtn:getPositionX() + createbtn:getContentSize().width/2,createbtn:getPositionY() - 2))
        richText:format(true)
        self.createpl:addChild(richText)
        self.richText = richText
    end

end

function LegionApplyUI:createMsg(callBack)
    local obj = {
        name = self.nameTx:getString(),
        icon = LegionMgr:getSelectIconID()
    }
    MessageMgr:sendPost('create','legion',json.encode(obj),function (response)
        
        local code = response.code
        local data = response.data
        if code == 0 then
            if callBack then
                callBack()
            end
            local costs = response.data.costs
            if costs then
                GlobalApi:parseAwardData(costs)
            end
			UserData:getUserObj():setLegion(data.legion.lid, data.legion.name, data.legion.level,data.legion.gold_tree)
            UserData:getUserObj().wish = data.legion.wish
            LegionMgr:hideLegionApplyUI()
            LegionMgr:showLegionMainUI(data.legion)
        elseif code == 100 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('ILLEGAL_CHARACTER'), COLOR_TYPE.RED)
        elseif code == 101 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_101'), COLOR_TYPE.RED)
        elseif code == 102 then
            promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SERVER_ERROR_102'), COLOR_TYPE.RED)
        end
    end)
end
function LegionApplyUI:initApply()
    self.sv:removeAllChildren()
    local titlebg = self.applypl:getChildByName('sv_title_bg')
    local idtx = titlebg:getChildByName('id_tx')
    idtx:setString(GlobalApi:getLocalStr('LEGION_ID')..':')

    local findbtn = titlebg:getChildByName('find_btn')
    local findbtntx =findbtn:getChildByName('btn_tx')
    findbtntx:setString(GlobalApi:getLocalStr('LEGION_FIND'))
    findbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local obj = {
                search = self.nameTx1:getString(),
            }
            MessageMgr:sendPost('search','legion',json.encode(obj),function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    if data.legions then
                        self.data.legions  = data.legions
                        self:initApply()
                    else
                        self.data.legions = nil
                        self:initApply()
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('LEGION_SEARCH_NONE'), COLOR_TYPE.RED)
                        return                        
                    end
                end
            end)
        end
    end)

    local refbtn =titlebg:getChildByName('ref_btn')
    local refbtntx =refbtn:getChildByName('btn_tx')
    refbtntx:setString(GlobalApi:getLocalStr('REFRESH_1'))
    refbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MessageMgr:sendPost('get','legion',"{}",function (response)
                
                local code = response.code
                local data = response.data
                if code == 0 then
                    if data.legion then
                        UserData:getUserObj().wish = data.legion.wish
                        LegionMgr:hideLegionApplyUI()
                        LegionMgr:showLegionMainUI(data.legion)
                    elseif data.legions then
                        self.data.legions = data.legions
                        self.applylistdata = data.applicant_list
                        self.idboxtx:setString(GlobalApi:getLocalStr('LEGION_ID_LIMIT'))
                        self.nameTx1:setString('')
                        self:initApply()
                    end
                end
            end)
        end
    end)

    self.legionarr = {}
    if self.data.legions then
        for k,v in pairs (self.data.legions) do 
            local arr = {}
            arr[1] = k
            arr[2] = v
            table.insert( self.legionarr,arr)
        end
    end
    self.num = #self.legionarr
    for i=1,self.num do
        self:addCells(i,self.legionarr[i])
    end
    self.sv:scrollToTop(0.1,true)
end

function LegionApplyUI:update()

end

function LegionApplyUI:isApplyed(id)
    local rv = false
    if self.applylistdata then
        for k,v in pairs (self.applylistdata) do 
            if tonumber(id) == tonumber(v) then
                rv = true
            end
        end
    end
    return rv
end

return LegionApplyUI