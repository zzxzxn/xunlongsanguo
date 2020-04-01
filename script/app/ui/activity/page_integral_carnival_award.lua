local IntegralCarnivalAwardUI = class("IntegralCarnivalAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

local WIDTH = 450
local HEIGHT = 116

function IntegralCarnivalAwardUI:ctor(counts,exchangePoints,msg)
    self.uiIndex = GAME_UI.UI_INTEGRAL_CARNIVAL_AWARD
    self.counts = counts
    self.exchangePointsAwardConf = GameData:getConfData('avintegralcarnivalawards')
    self.exchangePoints = exchangePoints
	self.msg = msg
end

function IntegralCarnivalAwardUI:init()
    local guardBgImg = self.root:getChildByName("guard_bg_img")
    local bgImg = guardBgImg:getChildByName("bg_img1")
    local mainImg = bgImg:getChildByName("guard_img")
    self:adaptUI(guardBgImg, bgImg)

    local winSize = cc.Director:getInstance():getWinSize()

    local closeBtn = mainImg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            AudioMgr.PlayAudio(11)
			self:hideUI()
            self.exchangePoints:refreshCount(UserData:getUserObj().activity.integral_carnival.interval)
        end
    end)
    
    local titleBg = mainImg:getChildByName("title_bg")
    local titleTx = titleBg:getChildByName("title_tx")
    titleTx:setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES12'))

    local rightCue = mainImg:getChildByName("right_cue")

    -- 当前积分
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(500, 40))

    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES4'), 26, COLOR_TYPE.ORANGE)
	re1:setStroke(COLOR_TYPE.BLACK,1)
    re1:setShadow(cc.c3b(0x40, 0x40, 0x40), cc.size(0, -1))
    re1:setFont('font/gamefont.ttf')

    local re2 = xx.RichTextLabel:create(self.counts, 26, COLOR_TYPE.WHITE)
	re2:setStroke(COLOR_TYPE.BLACK,1)
    re2:setShadow(cc.c3b(0x40, 0x40, 0x40), cc.size(0, -1))
    re2:setFont('font/gamefont.ttf')

   	richText:addElement(re1)
	richText:addElement(re2)

    richText:setAnchorPoint(cc.p(1,0.5))
    richText:setAlignment('right')
    richText:setVerticalAlignment('middle')

    richText:setPosition(cc.p(360,15))
    rightCue:addChild(richText)

    richText.re2 = re2
    self.nowCountRichText = richText
    self:refreshCount()

    --
    local bg = mainImg:getChildByName("bg")
    local sv = bg:getChildByName('sv')
    sv:setScrollBarEnabled(false)

    self.tempItemCell = cc.CSLoader:createNode("csb/activity_exhange_points_itemcell.csb"):getChildByName("root")

    self.sv = sv
    self:refreshSv()

end

function IntegralCarnivalAwardUI:refreshSv()
    local num = #self.exchangePointsAwardConf
    local size = self.sv:getContentSize()
    local innerContainer = self.sv:getInnerContainer()
    local allHeight = size.height
    local cellSpace = 3

    local height = num * HEIGHT + (num - 1)*cellSpace
    local height = math.ceil(num/2) * HEIGHT + (math.ceil(num/2) - 1)*cellSpace

    if height > size.height then
        innerContainer:setContentSize(cc.size(size.width,height))
        allHeight = height
    end

    local offset = 0
    local tempHeight = HEIGHT
    for i = 1,num do
        local tempCell = self.tempItemCell:clone()
        tempCell:setVisible(true)
        
        local confData = self.exchangePointsAwardConf[i]

        local space = 0
        if i ~= 1 and i ~= 2 then
            space = (math.ceil(num/2) - 1)*cellSpace
        end

        if i%2 == 1 then
            offset = offset + tempHeight + cellSpace
        end

        local x = 5
        if i%2 == 0 then
            x = WIDTH + 10
        end

        tempCell:setPosition(cc.p(x,allHeight - offset))
        self.sv:addChild(tempCell)

        local item = tempCell:getChildByName('item')

        local awardData = confData.awards
        local disPlayData = DisplayData:getDisplayObjs(awardData)
        local awards = disPlayData[1]
        if awards then
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, item)
            cell.awardBgImg:setPosition(cc.p(47,45))
            cell.lvTx:setString('x'..awards:getNum())
            local godId = awards:getGodId()
            awards:setLightEffect(cell.awardBgImg)
        end

        local itemName = tempCell:getChildByName('item_name')
        itemName:setString(awards:getName())

        local itemCount = tempCell:getChildByName('item_count')
        itemCount:setString(string.format(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES13'),confData.points))

        local btn = tempCell:getChildByName('btn')
        btn:getChildByName('btn_tx'):setString(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES14'))

		local limitTx = ccui.Text:create()
		limitTx:setFontName("font/gamefont.ttf")
		limitTx:setFontSize(22)
		limitTx:setPosition(cc.p(btn:getPositionX(),btn:getPositionY() + 50))
		limitTx:setTextColor(COLOR_TYPE.WHITE)
		limitTx:enableOutline(COLOR_TYPE.BLACK, 1)
		limitTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		limitTx:setAnchorPoint(cc.p(0.5,0.5))
		limitTx:setName('limit_tx')
		tempCell:addChild(limitTx)
		if not self.msg.exchange[tostring(confData.id)] then
			self.msg.exchange[tostring(confData.id)] = 0
		end
		limitTx:setString(string.format(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_30'),confData.limits - self.msg.exchange[tostring(confData.id)]))

        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then      
                local cost = confData.points
                if cost > self.counts then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_EXCHANGE_POINTS_DES15'), COLOR_TYPE.RED)
                    return
                end
				if not self.msg.exchange[tostring(confData.id)] then
					self.msg.exchange[tostring(confData.id)] = 0
				end
				if self.msg.exchange[tostring(confData.id)] >= confData.limits then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_31'), COLOR_TYPE.RED)
                    return
                end	

                MessageMgr:sendPost('integral_carnival_exchange','activity',json.encode({id = confData.id}),
		            function(response)
			            if(response.code ~= 0) then
				            return
			            end
			            local awards = response.data.awards
			            if awards then
				            GlobalApi:parseAwardData(awards)
				            GlobalApi:showAwardsCommon(awards,nil,nil,true)
			            end

                        self.counts = self.counts - cost
						if not self.msg.exchange[tostring(confData.id)] then
							self.msg.exchange[tostring(confData.id)] = 0
						end
						self.msg.exchange[tostring(confData.id)] = self.msg.exchange[tostring(confData.id)] + 1
						if self.msg.exchange[tostring(confData.id)] >= confData.limits then
							self.msg.exchange[tostring(confData.id)] = confData.limits
						end
						limitTx:setString(string.format(GlobalApi:getLocalStr('ACTIVITY__INTEGRAL_CARNIVAL_DESC_30'),confData.limits - self.msg.exchange[tostring(confData.id)]))
                        UserData:getUserObj().activity.integral_carnival.interval = self.counts
                        self:refreshCount()

		        end)
            end
        end)

    end
    innerContainer:setPositionY(size.height - allHeight)
end

function IntegralCarnivalAwardUI:refreshCount()
    self.nowCountRichText.re2:setString(self.counts)
    self.nowCountRichText:format(true)
end

return IntegralCarnivalAwardUI