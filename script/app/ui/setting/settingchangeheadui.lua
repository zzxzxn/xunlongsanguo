
local SettingChangeHeadUI = class("SettingChangeHeadUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function SettingChangeHeadUI:ctor(obj,callback)
	self.uiIndex = GAME_UI.UI_SETTINGCHANGEHEAD
	self.callback = callback
end

function SettingChangeHeadUI:onShow()
	--self:updatePanel()
end

function SettingChangeHeadUI:updatePanel()

end


function SettingChangeHeadUI:init()
    local vipConf = GameData:getConfData("vip")
    local maxVip = 0
    for k, v in pairs(vipConf) do
        if maxVip < tonumber(k) then
            maxVip = tonumber(k)
        end
    end
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))
	
	local panel = bg2:getChildByName('contentPanel')
	
	--title
	local infoTx = panel:getChildByName("tx")
	infoTx:setString(GlobalApi:getLocalStr("SETTING_CHANGEHEAD_TITLE"))

	local headSv = panel:getChildByName("head_sv")
    headSv:setScrollBarEnabled(false)
    local svSize = headSv:getContentSize()
    local innerContainer = headSv:getInnerContainer()

    local allHead = GameData:getConfData('settingheadicon')
    local allNum = #allHead
    local showTab = {}
    for i = 1,allNum do
        local data = allHead[i]
        if not showTab[tostring(data.vip_condition)] then
            showTab[tostring(data.vip_condition)] = {}
        end
        table.insert(showTab[tostring(data.vip_condition)],data)
    end

    local tabHeight = {}

    local nameHeight = 40
    local itemHeight = 94
    local itemWidth = 94
    local colNum = 5
    local lineOffset = 7.1
    local heightOffset = 10

    local allHeight = 0

    for j = 0,maxVip do
        local data = showTab[tostring(j)]
        if data then
            local allNum = #data
            local height = nameHeight
            local num = 0 
            if allNum <= 5 then
                num = 1
            else
                num = math.ceil(allNum/colNum)
            end
            height = height + (itemHeight + heightOffset) * num
            table.insert(tabHeight,height)
            allHeight = allHeight + height
        end
    end

    if allHeight < svSize.height then
        allHeight = svSize.height
    end
    print('==============+++++++++++' .. allHeight)
    innerContainer:setContentSize(cc.size(svSize.width,allHeight))
    innerContainer:setPositionY(svSize.height - allHeight)

    local tempHeight = 0
    local k = 1
    for j = 0,maxVip do
        local data = showTab[tostring(j)]
        local tabTempHeight = tabHeight[k]
        if data and tabTempHeight then
            tempHeight = tempHeight + tabTempHeight
            local widgetItem = ccui.Widget:create()
            widgetItem:setAnchorPoint(cc.p(0,0))
            widgetItem:setContentSize(cc.size(svSize.width,tabTempHeight))
            widgetItem:setPosition(cc.p(0, allHeight - tempHeight))
            headSv:addChild(widgetItem)


            if j == 0 then
                local title = cc.Label:createWithTTF(GlobalApi:getLocalStr("VIP_DES1"), "font/gamefont.ttf", 24)
                title:setAnchorPoint(cc.p(0,0))
                title:setPosition(cc.p(5,tabTempHeight - nameHeight + 5))
                title:setColor(COLOR_TYPE.WHITE)
                title:enableOutline(COLOR_TYPE.BLACK, 1)
                title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BLACK))
                widgetItem:addChild(title)
            else
                local vipImg = ccui.ImageView:create()
                vipImg:setAnchorPoint(cc.p(0,0))
                vipImg:loadTexture(('uires/ui/rech/rech_vip_small.png'))
                vipImg:setPosition(cc.p(10,tabTempHeight - nameHeight + 12))
                widgetItem:addChild(vipImg)

                local vipLabel = cc.LabelAtlas:_create(j, "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
	            vipLabel:setAnchorPoint(cc.p(0, 0))
                vipLabel:setPosition(cc.p(vipImg:getContentSize().width + 12,tabTempHeight - nameHeight + 12))
	            widgetItem:addChild(vipLabel)

                local title = cc.Label:createWithTTF(GlobalApi:getLocalStr("VIP_DES2"), "font/gamefont.ttf", 24)
                title:setAnchorPoint(cc.p(0,0))
                title:setPosition(cc.p(vipLabel:getPositionX() + vipLabel:getContentSize().width + 2,tabTempHeight - nameHeight + 7))
                title:setColor(COLOR_TYPE.WHITE)
                title:enableOutline(COLOR_TYPE.BLACK, 1)
                title:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.BLACK))
                widgetItem:addChild(title)

            end

            local remainHeight = tabTempHeight - nameHeight
            local num = #data
            for m = 1,num do
                local leftNum = m % colNum
                if leftNum == 0 then
                    leftNum = 5
                end
                local leftPos = (leftNum - 1) * (lineOffset + itemWidth)

                local line = 0 

                if m <= 5 then
                    line = 1
                else
                    line = math.ceil(m/colNum)
                end
                local posHeight = line * itemHeight + (line - 1)*heightOffset
                local rightPos = remainHeight - posHeight

                local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)

                local userVip = UserData:getUserObj():getVip()

                headpicCell.awardBgImg:setAnchorPoint(cc.p(0,0))
                headpicCell.awardBgImg:setPosition(cc.p(leftPos,rightPos))
                widgetItem:addChild(headpicCell.awardBgImg)

		        for k, v in pairs(RoleData:getRoleMap()) do   
			        if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== true then    
				        self.frameBg=v:getBgImg()
			        end 
		        end
		        headpicCell.awardBgImg:loadTexture(self.frameBg)
                headpicCell.awardImg:loadTexture(data[m].icon)
                headpicCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
                headpicCell.headframeImg:setVisible(true)

                if j > userVip then
                    ShaderMgr:setGrayForWidget(headpicCell.awardBgImg)
                    ShaderMgr:setGrayForWidget(headpicCell.awardImg)
                end

                headpicCell.awardBgImg:addClickEventListener(function ()      
                    if j > userVip then
                        promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr('VIP_DES3'),j), COLOR_TYPE.RED)
                        return
                    end
			        local args={}
			        args.id=data[m].id
			        MessageMgr:sendPost('set_headpic','user',json.encode(args),function (response)
							
							        local code = response.code
							        if code == 0 then
								        UserData:getUserObj().headpic=data[m].id
			    				        SettingMgr:hideSettingChangeHead()
							        end
						        end)	
			        AudioMgr.PlayAudio(11)					
                end)
            end
            k = k + 1
        end
    end
	bg1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingChangeHead()
			AudioMgr.PlayAudio(11)
	    end
	end)
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
end

function SettingChangeHeadUI:getHeadIcon()
    
end

function SettingChangeHeadUI:init2()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))
	
	local panel = bg2:getChildByName('contentPanel')
	
	--title
	local infoTx = panel:getChildByName("tx")
	infoTx:setString(GlobalApi:getLocalStr("SETTING_CHANGEHEAD_TITLE"))
	
	local picSize=94
	local colNum=5
	local showedHeadNum = 0
    local curHeadNum = 0
	local headSv = panel:getChildByName("head_sv")
    local contentWidget = ccui.Widget:create()
    headSv:addChild(contentWidget)
    local svSize = headSv:getContentSize()
    headSv:setScrollBarEnabled(false)
    contentWidget:setPosition(cc.p(0, svSize.height))

	--local allHead=self:getAllHead()
	local allHead=GameData:getConfData('settingheadicon')
	local showedHeadArr = allHead
    showedHeadNum = #showedHeadArr
	--for k, v in pairs(allHead) do
        --table.insert(showedHeadArr, v)
        --showedHeadNum = showedHeadNum + 1
	--end

	local function createHeadPic(data)
        local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
		for k, v in pairs(RoleData:getRoleMap()) do   
			if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== true then    
				self.frameBg=v:getBgImg()
			end 
		end
		headpicCell.awardBgImg:loadTexture(self.frameBg)
        headpicCell.awardImg:loadTexture(data.icon)
        headpicCell.headframeImg:loadTexture(UserData:getUserObj():getHeadFrame())
        headpicCell.headframeImg:setVisible(true)
		headpicCell.awardBgImg:addClickEventListener(function ()
			local args={}
			args.id=data.id
			MessageMgr:sendPost('set_headpic','user',json.encode(args),function (response)
				local code = response.code
				if code == 0 then
					UserData:getUserObj().headpic=data.id
    				SettingMgr:hideSettingChangeHead()
				end
			end)	
			AudioMgr.PlayAudio(11)					
        end)
        return headpicCell.awardBgImg
	end
	
	local dis = (svSize.width - picSize)/(colNum-1)
    local height = 110
	local function addHeadPic()
		if curHeadNum < showedHeadNum then
			local num = curHeadNum
            curHeadNum = curHeadNum + 20
            curHeadNum = curHeadNum > showedHeadNum and showedHeadNum or curHeadNum
		
			local innerHeight
			for i = num + 1, curHeadNum do
				local headPic = createHeadPic(showedHeadArr[i])
				innerHeight = math.ceil(i/colNum)*height
				headPic:setPosition(cc.p(((i-1)%colNum)*dis + picSize/2, 50-innerHeight))
				contentWidget:addChild(headPic)
			end
			innerHeight = innerHeight < svSize.height and svSize.height or innerHeight
			headSv:setInnerContainerSize(cc.size(svSize.width, innerHeight))
			contentWidget:setPosition(cc.p(0, innerHeight))
		end
		
	end
	
	if showedHeadNum > 0 then
        addHeadPic()
    end
	local function scrollViewEvent(sender, evenType)
        if evenType == ccui.ScrollviewEventType.scrollToBottom then
            addHeadPic()
        end
    end
    headSv:addEventListener(scrollViewEvent)
	
	--[[
	local closeBtn = bg2:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingChangeHead()
	    end
	end)
	--]]
	
	bg1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			SettingMgr:hideSettingChangeHead()
			AudioMgr.PlayAudio(11)
	    end
	end)
	--self:updatePanel()
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
end

function SettingChangeHeadUI:ActionClose(call)
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

return SettingChangeHeadUI