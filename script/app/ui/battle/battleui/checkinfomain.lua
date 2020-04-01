local CheckInfoMainUI = class("CheckInfoMainUI", BaseUI)
local ClassRoleObj = require('script/app/obj/roleobj')
local ClassItemCell = require('script/app/global/itemcell')

function CheckInfoMainUI:ctor(data, uid)
    self.uiIndex = GAME_UI.UI_CHECK_INFO_MAIN

	self.data = data
    self.uid = tonumber(uid)
end

function CheckInfoMainUI:init()
    local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
    self.bg2 = bg2
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2))

    local topImg = bg2:getChildByName('top_img')
	local closeBtn = topImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			BattleMgr:hideCheckInfo()
	    end
	end)

    self:initTop()
    self:initBottom()
end

function CheckInfoMainUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bg1")
	local panel=ccui.Helper:seekWidgetByName(bg1,"bg2")
    panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
    panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
        self:hideUI()
        if(call ~= nil) then
            return call()
        end
    end)))
end

function CheckInfoMainUI:initTop()
    local topImg = self.bg2:getChildByName('top_img')
    local img = topImg:getChildByName('img')

    --
    local titleFramenode  = img:getChildByName('title_node')
    local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    titleFramenode:addChild(headpicCell.awardBgImg)
    local quality = 1
    headpicCell.awardBgImg:loadTexture(COLOR_FRAME_TYPE[quality])
    local conf = GameData:getConfData('settingheadicon')[self.data.info.headpic or 1]
    headpicCell.awardImg:loadTexture(conf.icon)
    headpicCell.lvTx:setString(50)
    local lvTx = headpicCell.lvTx
    headpicCell.headframeImg:loadTexture(GlobalApi:getHeadFrame(self.data.info.headframe))

    local nameBg = img:getChildByName('name_bg')
    local name = nameBg:getChildByName('name')
    name:setString(self.data.info.un)

    local imgV = nameBg:getChildByName('img_v')
    imgV:setPositionX(name:getPositionX() + name:getContentSize().width + 4)
    local vip = self.data.info.vip
    if vip and vip > 0 then
        local vipLabel = cc.LabelAtlas:_create(vip, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	    vipLabel:setAnchorPoint(cc.p(0, 0.5))
	    nameBg:addChild(vipLabel)
        vipLabel:setScale(1.2)
        vipLabel:setPosition(cc.p(imgV:getPositionX() + 26,imgV:getPositionY()))
    else
        imgV:setVisible(false)
    end

    -- �ж��Ƿ��о���
    local legionImg = nameBg:getChildByName('legion_img')
    local legionName = nameBg:getChildByName('legion_name')

    if self.data.info.notrealuser and self.data.info.notrealuser == true then
        legionImg:setVisible(false)
        legionName:setVisible(false)
    else
        if self.data.info.legion_name == "" then
            legionImg:setVisible(false)
            legionName:setVisible(false)
        else
            if self.data.info.legion_icon then
                legionImg:setVisible(true)
                legionName:setVisible(true)
                legionImg:loadTexture('uires/ui/legion/legion_' .. self.data.info.legion_icon .. '_jun.png')
                legionName:setString(self.data.info.legion_name)
            else
                legionImg:setVisible(false)
                legionName:setVisible(false)
            end
        end
    end

    local addfriendBtn = img:getChildByName('addfriend_btn')
    local addfriendBtnTx = addfriendBtn:getChildByName('func_tx')
    addfriendBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local isOpen,isNotIn,id,level = GlobalApi:getOpenInfo('friend')
            local str = ''
            local cityData = MapData.data[id]
            if level then
                str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN4'),level)
            elseif cityData then
                str = string.format(GlobalApi:getLocalStr('STR_POSCANTOPEN5'),cityData:getName())
            end
            if isOpen == false then
                promptmgr:showSystenHint(str, COLOR_TYPE.RED)
                return
            end

            local obj = {
		        id = tonumber(self.uid)
		    }
		    MessageMgr:sendPost('apply','friend',json.encode(obj),function (response)    
		        local code = response.code
		        local data = response.data
		        if code == 0 then
				    if response.data.status == 0 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_5'), COLOR_TYPE.GREEN)
				    elseif response.data.status == 1 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_8'), COLOR_TYPE.RED)
				    elseif response.data.status == 2 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_9'), COLOR_TYPE.RED)
				    elseif response.data.status == 3 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_3'), COLOR_TYPE.RED) 
				    elseif response.data.status == 4 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_2'), COLOR_TYPE.RED) 
				    elseif response.data.status == 5 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_6'), COLOR_TYPE.GREEN) 
				    elseif response.data.status == 6 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_1'), COLOR_TYPE.RED)
				    elseif response.data.status == 7 then
				        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_10'), COLOR_TYPE.RED)    
                    elseif response.data.status == 8 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_12'), COLOR_TYPE.RED)
                    elseif response.data.status == 9 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_4'), COLOR_TYPE.RED) 
                    elseif response.data.status == 10 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('FRIENDS_MSG_DESC_14'), COLOR_TYPE.RED)    
				    end
		        else
		        end      
		    end)
        end
    end)
    if not self.data.isFriend then
 		addfriendBtn:setBright(true)
        addfriendBtn:setEnabled(true)
        addfriendBtnTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        addfriendBtnTx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_27'))
 	else
 		addfriendBtn:setBright(false)
 		addfriendBtn:setEnabled(false)
 		addfriendBtnTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
 		addfriendBtnTx:setString(GlobalApi:getLocalStr('FRIENDS_DESC_28'))
 	end

    local titleTx = img:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('CHECK_INFO_DESC2'))

    local fightforceTx = img:getChildByName('fightforce_tx')
    local allFightForce = 0
    for k,v in pairs(self.data.info.pos) do
        allFightForce = allFightForce + v.fight_force
    end
    fightforceTx:setString(allFightForce)

    -- sv
    local bottomImg = img:getChildByName('bottom_img')
    local sv = bottomImg:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    local cell = bottomImg:getChildByName('cell')
    cell:setVisible(false)

    self.heroList = {}
    self.heroConfig = GameData:getConfData("hero")
	self.equipConfig = GameData:getConfData("equip")
    local tempList = {}
	for k,v in pairs(self.data.info.pos) do
		local hero={}
		local info=self.heroConfig[tonumber(v.hid)]
        local obj = ClassRoleObj.new(tonumber(v.hid),0)
        obj:setPromoted(v.promote)
		if info~=nil then
			hero.hid=tonumber(v.hid)
			hero.pos=k
			hero.fightForce=v.fight_force
			hero.level=v.level
			hero.talent=v.talent
			hero.quality=obj:getQuality()
			hero.uiOffsetY = info.uiOffsetY
			hero.isKing = (tonumber(k)==1) and true or false
			hero.icon=(hero.isKing==true and isDroid==false) and headIcon or "uires/icon/hero/" .. info.heroIcon
			hero.url=(hero.isKing==true and isDroid==false) and dragonUrl or info.url			
			hero.name=(hero.isKing==true) and GlobalApi:getLocalStr('STR_MAIN_NAME') or info.heroName
			hero.name=(hero.talent>0) and hero.name.."+"..hero.talent or hero.name
            hero.talent = hero.talent
            hero.promoteSpecial = v.promote
			if hero.isKing == true then
				table.insert(self.heroList, hero)
			else
				table.insert(tempList, hero)
			end
		end
	end
	table.sort(tempList, function (a, b)
        return a.fightForce > b.fightForce
    end)
	for i=1, #tempList do
		table.insert(self.heroList, tempList[i])
	end

    if #self.heroList > 0 then
        headpicCell.lvTx:setString(self.heroList[1].level)
        headpicCell.awardBgImg:loadTexture(COLOR_FRAME[self.heroList[1].quality])
    else
        headpicCell.lvTx:setString(1)
    end

    local num = #self.heroList
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 20

    local CELLWIDTH = 94
    local CELLHEIGHT = 94

    local width = num * CELLWIDTH + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = CELLWIDTH
    for i = 1,num,1 do
        local tempCell = cell:clone()
        tempCell:setVisible(true)
        local size = tempCell:getContentSize()

        local space = 0
        local offsetWidth = 0
        if i ~= 1 then
            space = cellSpace
            offsetWidth = tempWidth
        end
        offset = offset + offsetWidth + space
        tempCell:setPosition(cc.p(offset,25))
        sv:addChild(tempCell)

        local data = self.heroList[i]
        local icon = tempCell:getChildByName('icon')
        local lvTx = tempCell:getChildByName('lv_tx')
        local tupoTx = tempCell:getChildByName('tupo_tx')

        ---------------------------
        ClassItemCell:setHeroPromote(tempCell,data.hid,data.promoteSpecial)
        ---------------------------
        icon:loadTexture(data.icon)
        lvTx:setString(data.level)
        if data.talent and data.talent > 0 then
            tupoTx:setString('+' .. data.talent)
            tupoTx:setVisible(true)
        else
            tupoTx:setVisible(false)
        end
        	
	    tempCell:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.ended then
			    BattleMgr:showCheckLastInfo(self.data, tonumber(self.uid))
	        end
	    end)

    end
    innerContainer:setPositionX(0)
end

function CheckInfoMainUI:initBottom()
    local bottomImg = self.bg2:getChildByName('bottom_img')
    local img = bottomImg:getChildByName('img')

    if self.data.info.notrealuser and self.data.info.notrealuser == true then
        for i = 1,4 do
            local nameBg = img:getChildByName('name_bg' .. i)
            nameBg:setVisible(false)
        end
        return
    end

    local notServerImg = img:getChildByName('not_server_img')
    notServerImg:setVisible(false)

    local showTab = {
        {["name"] = 'CHECK_INFO_DESC3'},
        {["name"] = 'CHECK_INFO_DESC4'},
        {["name"] = 'CHECK_INFO_DESC5'},
        {["name"] = 'CHECK_INFO_DESC6'},
    }

    for i = 1,4 do
        local nameBg = img:getChildByName('name_bg' .. i)
        local nameTx = nameBg:getChildByName('name_tx')
        local desc = nameBg:getChildByName('desc')

        local showData = showTab[i]
        desc:setString(GlobalApi:getLocalStr(showData.name))

        if i == 1 then
            if self.data.info.country and self.data.info.country > 0 then
                nameTx:setString(GlobalApi:getLocalStr("COUNTRY_NAME_" .. self.data.info.country))
            else
                nameTx:setString(GlobalApi:getLocalStr("SETTING_INFO_EMPTY"))
            end
        elseif i == 2 then
            if self.data.info.userPos then
                local conf = GameData:getConfData("position")
                nameTx:setString(conf[self.data.info.userPos].title)
            else
                nameTx:setString(GlobalApi:getLocalStr("SETTING_INFO_EMPTY"))
            end
            
        elseif i == 3 then
            nameTx:setString(self.data.info.arenaRank)
            if self.data.info.arenaRank == 0 then
                nameTx:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
            end
        else
            nameTx:setString(self.data.info.towerRank)
            if self.data.info.towerRank == 0 then
                nameTx:setString(GlobalApi:getLocalStr("RANKING_NO_INLIST"))
            end
        end
        nameTx:setPositionX(desc:getPositionX() + desc:getContentSize().width)
    end
end

return CheckInfoMainUI