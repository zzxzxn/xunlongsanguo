local TavernLimitAwardUI = class("TavernLimitAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local ClassRoleObj  =require('script/app/obj/roleobj')

local MAXNUM = 6

function TavernLimitAwardUI:ctor(type,awards)
	self.uiIndex = GAME_UI.UI_TAVEN_LIMIT_AWARD_PANNEL
    self.tavernHotConf = GameData:getConfData("tavernhot")
    self.type = type or 'cash'
    self.awards = awards
    self.state = true
end

function TavernLimitAwardUI:init()
    local bgimg = self.root:getChildByName("bg_img")
	local winSize = cc.Director:getInstance():getWinSize()
	--bgimg:setPosition(cc.p(winSize.width/2,winSize.height/2))
    local bgAlpha = bgimg:getChildByName("bg_alpha")

    local bg = self.root:getChildByName("bg")
    local bgimg2 = bg:getChildByName("bg_img2")
    self.bgimg2 = bgimg2

    -- 存储第一个位置
    local frame = bgimg2:getChildByName("frame" .. 1)
    self.firstPos = {frame:getPositionX(),frame:getPositionY()} 
    self.rotation = frame:getRotation()


    -- 确定
    local requireBtn = bgimg2:getChildByName('require_btn')
    requireBtn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('REQUIRE_TEXT'))
	requireBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	TavernMgr:hideTavernLimitAwardUI()
        end
    end)


    -- 再次招募
    local again_btn = bgimg2:getChildByName('again_btn')
    again_btn:getChildByName('inputbtn_text'):setString(GlobalApi:getLocalStr('TAVERN_AGAIN_TIME'))
	again_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self.state = false
        	local function callBack(awards)
                local temp = {}
                for i = 1,MAXNUM do
                    if awards[i][1] == 'card' then
                        table.insert(temp,awards[i])
                    end
                end
                for i = 1,MAXNUM do
                    if awards[i][1] == 'card' then   
                    else
                        table.insert(temp,awards[i])
                    end
                end

                self.awards = temp

                for i = 1,MAXNUM do
                    local frame = bgimg2:getChildByName("frame" .. i)
                    if frame:getChildByName('effect') then
                        frame:removeChildByName('effect')
                    end
                    local cell = frame.cell
                    if cell then
                        frame:removeAllChildren()
                        frame.cell = nil
                    end
                end

                self:refresh()

            end
		    TavernMgr:buyHot(self.type,callBack)
        end
    end)

    -- 碎片描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(600, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TAVERN_NOW_OWN'), 24, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')
	local re2 = xx.RichTextLabel:create('', 24, COLOR_TYPE.RED)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES1') .. ':', 24, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')
    local re4 = xx.RichTextLabel:create('', 24, COLOR_TYPE.GREEN)
	re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re4:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
	richText:addElement(re3)
    richText:addElement(re4)

    richText:setAlignment('middle')
    richText:setVerticalAlignment('middle')
    richText:format(true)

    local expBg = bgimg2:getChildByName("exp_bg")
	richText:setAnchorPoint(cc.p(0.5,0.5))
	richText:setPosition(cc.p(expBg:getPositionX(),125))
	bgimg2:addChild(richText)

    self.fragramentRe2 = re2
    self.fragramentRe4 = re4
    self.richText = richText

    self:refresh()
    self:adaptUI(bgimg,bgAlpha)
    self:adaptUI(bg,bgimg2)


end

function TavernLimitAwardUI:refresh()
    local bgimg2 = self.bgimg2

    local tavenLimitData = TavernMgr:getTavenLimitData()

	local heroConf = GameData:getConfData("hero")
    local data = self.tavernHotConf[tavenLimitData.limitHot]
    local awards = DisplayData:getDisplayObjs(data.award1)
    local roleId = awards[1]:getId()
    local heroData = heroConf[roleId]
    local heroName = heroData.heroName

    local fragmentItem = BagData:getFragmentById(roleId) -- 这个也是碎片的id
    local num = 0
    if fragmentItem then
        num = fragmentItem:getNum()
    end

    self.fragramentRe2:setString(heroName)
    self.fragramentRe4:setString(num)
    self.richText:format(true)

    -- 奖励品
    self.itemIndexs = {}
    self.pos = {}
    local disPlayData = DisplayData:getDisplayObjs(self.awards)
    for i = 1,MAXNUM do
        local frame = bgimg2:getChildByName("frame" .. i)

        table.insert(self.itemIndexs,i)
        local tempPos ={frame:getPositionX(),frame:getPositionY()}
        table.insert(self.pos,tempPos)

        local awards = disPlayData[i]

        if self.awards[i][1] == 'card' then
            local effect = ccui.ImageView:create()
            :loadTexture('uires/ui/strength/strength_light_bg.png')
            :setAnchorPoint(0.5,0.5)
            :setName('effect')
            effect:setScale(0.5)
            effect:runAction(cc.RepeatForever:create(cc.RotateBy:create(20, 360)))
            frame:addChild(effect)
        end

        if frame.cell == nil then
            local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM)
            cell.awardBgImg:setTouchEnabled(true)
            local name = cc.Label:createWithTTF('', 'font/gamefont.ttf', 22)
		    name:setAnchorPoint(cc.p(0.5, 0.5))
		    name:setPosition(cc.p(47, -18.25))
            cell.awardBgImg:addChild(name)
            cell.name = name
            frame:addChild(cell.awardBgImg)
            frame.cell = cell
        end
        local cell = frame.cell
        ClassItemCell:updateItem(cell, awards, 1)
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)
        cell.name:setString(awards:getName())
        cell.name:setColor(awards:getNameColor())
        cell.name:enableOutline(awards:getNameOutlineColor(),1)
        cell.name:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
        cell.awardBgImg:setScale(0)
        cell.name:setVisible(false)
        cell.awardBgImg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if awards:getType() == 'card' then
                    local obj = ClassRoleObj.new(awards:getId(),0)
                    ChartMgr:showChartInfo(nil, ROLE_SHOW_TYPE.NORMAL, obj)
                else
                    GetWayMgr:showGetwayUI(awards,false)
                end 
            end
        end)
    end

    -- 消耗
    local cost = bgimg2:getChildByName("txt_cost")
    local yuanbaoImg = bgimg2:getChildByName("yuanbao_img")
    if self.type == 'love' then
        cost:setString(GlobalApi:getGlobalValue('tavernCostLoveNum'))
        if UserData:getUserObj():getCash() >= tonumber(GlobalApi:getGlobalValue('tavernHotCashCost')) then
		    cost:setTextColor(cc.c3b(255,249,243)) -- 白色
		    cost:enableOutline(cc.c4b(0,0,0,255),2)
	    else
		    cost:setTextColor(cc.c3b(255,0,0)) -- 红色
		    cost:enableOutline(cc.c4b(65,8,8,255),2)
	    end
        yuanbaoImg:loadTexture('uires/ui/res/res_love.png')
    else
        cost:setString(GlobalApi:getGlobalValue('tavernHotCashCost'))
        if UserData:getUserObj():getCash() >= tonumber(GlobalApi:getGlobalValue('tavernHotCashCost')) then
		    cost:setTextColor(cc.c3b(255,249,243)) -- 白色
		    cost:enableOutline(cc.c4b(0,0,0,255),2)
	    else
		    cost:setTextColor(cc.c3b(255,0,0)) -- 红色
		    cost:enableOutline(cc.c4b(65,8,8,255),2)
	    end
    end

    -- 进度条
    local expBg = bgimg2:getChildByName("exp_bg")
    local expBar = expBg:getChildByName("exp_bar")
    local expVal = expBar:getChildByName("exp_val")
    expBar:setScale9Enabled(true)
    expBar:setCapInsets(cc.rect(10,15,1,1))

    local havaNum = UserData:getUserObj():getTavenLuck()
    local allNum = TavernMgr:getExchangeCostMaxLuckValue()
    if havaNum >= tonumber(allNum) then
        expBar:setPercent(100)
    else
        expBar:setPercent(100 * havaNum/tonumber(allNum))
    end
    expVal:setString(string.format(GlobalApi:getLocalStr('TAVERN_LIMIT_GET_DES7'),havaNum,allNum))


    local judge = false
    local temp = {}
    for i = 1,MAXNUM do
        if self.awards[i][1] == 'card' then
            judge = true
        end
    end
    if judge == true then
        self:play()
    else
        self.state = true
        self:play2()
    end

end

function TavernLimitAwardUI:play()
    local bgimg2 = self.bgimg2
    local speed = 1
    local allCount = MAXNUM

    local frame = bgimg2:getChildByName("frame" .. 1)
    
    frame:setPosition(cc.p(self.firstPos[1],self.firstPos[2])) -- 因为可能位置错位了，要调整到一个位置去

    local cell = frame.cell
    if allCount < 1 then
        allCount = 1
    end
    local delayTime = math.random(1,allCount)

    if self.awards[1][1] == 'card' then
        local temp = {}
        table.insert(temp,self.awards[1])
        TavernMgr:showTavernAnimate(temp, function()
            print('---+++++++=====55555555555')
            self.state = true
            cell.awardBgImg:setScale(1)
            cell.name:setVisible(true)
            allCount = allCount - 1
            
            self.itemIndexs = {}
            for i = 2,MAXNUM do
                table.insert(self.itemIndexs,i)
            end


            local tempPos = {}
            for i = 1,#self.pos do
                if self.pos[i][1] == self.firstPos[1] and self.pos[i][2] == self.firstPos[2] then
                else
                    table.insert(tempPos,self.pos[i])
                end
            end
            self.pos = tempPos

            self:play2()
            

		end, 4)

    end

end

function TavernLimitAwardUI:play2()
    local itemIndexs = self.itemIndexs
    local bgimg2 = self.bgimg2
    local speed = 1
    local allCount = #itemIndexs
    if allCount == 0 then
        print('========+++++++++++99999999999999')
        if self.awards and self.state == true then
            GlobalApi:showAwardsCommonByText(self.awards, true)
        end
        return
    end
    local index = math.random(1,allCount)   -- 这个是动画出现的随机
    --print("+++++++++++++" .. index .. '-----------------' .. itemIndexs[index])
    local frame = bgimg2:getChildByName("frame" .. itemIndexs[index]) 

    --local posIndex = math.random(1,allCount)    -- 位置随机
    local posIndex = index
    --print("===============" .. posIndex .. '*****************' .. self.pos[posIndex][1] .. '############' ..self.pos[posIndex][2])
    frame:setPosition(cc.p(self.pos[posIndex][1],self.pos[posIndex][2]))


    local cell = frame.cell
    if allCount < 1 then
        allCount = 1
    end
    local delayTime = allCount*0.5 + allCount

    local act1 = cc.DelayTime:create(0.1*delayTime*speed)
	local act2 = cc.CallFunc:create(function ()
        if frame:getChildByName('getitem') then
            frame:getChildByName('getitem'):removeFromParent()
        end
        local size = cell.awardBgImg:getContentSize()
        local particle = cc.ParticleSystemQuad:create("particle/getitem.plist")
        particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
        particle:setPosition(cell.awardBgImg:getPosition())
        particle:setName('getitem')
        frame:addChild(particle)

        AudioMgr.playEffect("media/effect/show_award.mp3", false)
    end)
    local act3 = cc.DelayTime:create(0.1*speed*3)
    local act4 = cc.Spawn:create(cc.MoveTo:create(0.2*speed, cc.p(0,0)),cc.ScaleTo:create(0.2*speed, 1), cc.RotateTo:create(0.2*speed, 720))
    local act5 = cc.CallFunc:create(function ()
        cell.name:setVisible(true)
        allCount = allCount - 1
    end)

	cell.awardBgImg:runAction(cc.Sequence:create(act1,act2,act3,act4,act5))

    local temp = {}
    for i = 1,#itemIndexs do
        if itemIndexs[i] == itemIndexs[index] then
        else
            table.insert(temp,itemIndexs[i])
        end
    end
    self.itemIndexs = temp


    local tempPos = {}
    for i = 1,#self.pos do
        if self.pos[i][1] == self.pos[posIndex][1] and self.pos[i][2] == self.pos[posIndex][2] then
        else
            table.insert(tempPos,self.pos[i])
        end
    end
    self.pos = tempPos


    self:play2()


end

return TavernLimitAwardUI