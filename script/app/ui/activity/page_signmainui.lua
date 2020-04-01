local SignMainUI = class("SignMainUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function SignMainUI:ctor()
	self.uiIndex = GAME_UI.UI_SIGNMAINUI
    self.signconf = GameData:getConfData('sign')
	self.signdata = UserData:getUserObj():getSign()
    self.celltab = {}
end
function SignMainUI:init()
	local bgimg = self.root:getChildByName("root")

    self.sv = bgimg:getChildByName('scrollView')
    self.sv:setScrollBarEnabled(false)

	self.bgimg4 = bgimg:getChildByName('bg_img4')
	self.getawardbtn = self.bgimg4:getChildByName('func_btn')
	self.getawardbtntx = self.getawardbtn:getChildByName('btn_tx')
	self.getawardbtntx:setString(GlobalApi:getLocalStr('SIGN_BTNTX3'))
	self.getawardbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
		elseif eventType == ccui.TouchEventType.ended then
            if (tonumber(self.signdata.day) ~= tonumber(Time.getDayToModifiedServerDay())) then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('SIGN_DESC11'), COLOR_TYPE.RED)
                return
            end
			if self.signdata.continuous_reward ~= 0 then
				promptmgr:showSystenHint(GlobalApi:getLocalStr('SIGN_DESC1'), COLOR_TYPE.RED)
				return
			end
			MessageMgr:sendPost("sign_continuous_reward", "user", json.encode(args), function (jsonObj)
				print(json.encode(jsonObj))
				local code = jsonObj.code
				if code == 0 then
					self.signdata.continuous_reward =  1
					local awards = jsonObj.data.awards
					if awards then
						GlobalApi:parseAwardData(awards)
						GlobalApi:showAwardsCommon(awards,nil,nil,true)
					end
					local costs = jsonObj.data.costs
					if costs then
						GlobalApi:parseAwardData(costs)
					end
					self:update()

                    self:updateMark()

				end
			end)
		end
	end)
	local awardbtn = self.bgimg4:getChildByName('award_btn')
	local awardbtntx = awardbtn:getChildByName('btn_tx')
	awardbtntx:setString(GlobalApi:getLocalStr('SIGN_BTNTX4'))
	awardbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
		elseif eventType == ccui.TouchEventType.ended then
			MainSceneMgr:showSignReward()
		end
	end)
	self.itemtab = {}
	for i=1,2 do
		local arr = {}
		arr.bg = self.bgimg4:getChildByName('item_'..i..'_bg')
		arr.icon = arr.bg:getChildByName('icon_img')
		arr.numtx = arr.bg:getChildByName('num_tx')
		self.itemtab[i]=arr
	end
    ActivityMgr:showRightCueMonthResetHour()
    self:update()
end

function SignMainUI:createAward()
    

	local bgimg = ccui.ImageView:create('uires/ui/sign/signed_bg.png')
	bgimg:setTouchEnabled(true)
	bgimg:setAnchorPoint(cc.p(0.5,0.5))
	local size = bgimg:getContentSize()
    local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM) 
    local awardBgImg = tab.awardBgImg
	local awardsize = awardBgImg:getContentSize()
    awardBgImg:setPosition(cc.p(size.width/2,size.height/2+10))
    awardBgImg:setTouchEnabled(false)
	bgimg:addChild(awardBgImg)

    local awardImg = tab.awardImg

    local chipImg = ccui.ImageView:create('uires/ui/common/icon_chip.png')
    chipImg:setAnchorPoint(cc.p(0.5,0.5))
    chipImg:setScaleX(-1)
    chipImg:setPosition(cc.p(awardsize.width/2,awardsize.height/2))

	local mendimg = ccui.ImageView:create('uires/ui/sign/sign_up.png')
	mendimg:setAnchorPoint(cc.p(1,0))
	mendimg:setPosition(cc.p(awardsize.width,0))

	local signimg = ccui.ImageView:create('uires/ui/sign/signed_bg.png')
	signimg:setAnchorPoint(cc.p(0.5,0.5))
	signimg:setPosition(cc.p(size.width/2,size.height/2))

	local signsimg = ccui.ImageView:create('uires/ui/sign/signed_img.png')
	signsimg:setAnchorPoint(cc.p(0.5,0.5))
	signsimg:setPosition(cc.p(signimg:getContentSize().width/2,signimg:getContentSize().height/2))
	signimg:addChild(signsimg)

    local doubleImg = ccui.ImageView:create('uires/ui/sign/sign_vip_new.png')
    doubleImg:setAnchorPoint(cc.p(0,1))
    doubleImg:setPosition(cc.p(0,size.height))

    local doubleVImg = ccui.ImageView:create('uires/ui/sign/sign_v_img.png')
    doubleVImg:setAnchorPoint(cc.p(0.5,0.5))
    doubleVImg:setPosition(cc.p(19,20))

    local vipLabel = cc.LabelAtlas:_create("", "uires/ui/number/font_vip_2.png", 17, 22, string.byte('0'))
    vipLabel:setName("vip_tx")
    vipLabel:setAnchorPoint(cc.p(0.5, 0.5))
    vipLabel:setScale(0.8)
    vipLabel:setPosition(cc.p(35,30))
    vipLabel:setRotation(327)

    -- local richText2 = xx.RichText:create()
    -- richText2:setContentSize(cc.size(100, 40))
    -- local re1 = xx.RichTextLabel:create('', 20, COLOR_TYPE.WHITE)
    -- re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    -- local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC9'), 20, COLOR_TYPE.WHITE)
    -- re2:setFont('font/gamefont.ttf')
    -- re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)

    -- richText2:addElement(re1)
    -- richText2:addElement(re2)
    -- richText2:setAlignment('middle')
    -- richText2:setVerticalAlignment('middle')
    -- richText2:setPosition(cc.p(45,30))
    -- richText2:setAnchorPoint(cc.p(0.5,0.5))
    -- richText2:setRotation(327)
    local vipdesc = cc.Label:createWithTTF("", "font/gamefont.ttf", 20)
    -- numtx:setScale(0.7)
    vipdesc:setName('lv_tx')
    vipdesc:setAnchorPoint(cc.p(0.5,0.5))
    vipdesc:setPosition(cc.p(60,48))
    vipdesc:enableOutline(COLOR_TYPE.BLACK, 1)
    vipdesc:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    vipdesc:setRotation(327)
    vipdesc:setString(GlobalApi:getLocalStr('SIGN_DESC9'))

    doubleImg:addChild(vipdesc)
    doubleImg:addChild(doubleVImg)
    doubleImg:addChild(vipLabel)
    --richText2:setVisible(true)  

    -- local numtx = cc.Label:createWithTTF("", "font/gamefont.ttf", 23)
    -- numtx:setColor(COLOR_TYPE.WHITE)
    -- numtx:enableOutline(COLOR_TYPE.BLACK, 1)
    -- numtx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
    -- numtx:setName('lv_tx')
    -- numtx:setAnchorPoint(cc.p(0.5,0.5))
    -- numtx:setPosition(cc.p(awardsize.width/2,-15))
    local numtx = cc.LabelAtlas:_create('', "uires/ui/number/number1.png", 16, 22, string.byte('-'))
    -- numtx:setScale(0.7)
    numtx:setName('lv_tx')
    numtx:setAnchorPoint(cc.p(0.5,0.5))
    numtx:setPosition(cc.p(awardsize.width/2,-15))

    local effect = GlobalApi:createLittleLossyAniByName('sign_light')
    effect:setPosition(cc.p(awardsize.width/2,awardsize.height/2))
    effect:getAnimation():playWithIndex(0, -1, 1)
    effect:setTag(9527)
    effect:setVisible(false)
    effect:setScale(1.25)
   

    awardBgImg:addChild(chipImg,1,999)
    awardBgImg:addChild(numtx,1,997)
	awardBgImg:addChild(mendimg,3,1000)
    awardBgImg:addChild(effect,2,10003)
    bgimg:addChild(doubleImg,1,1000)
	bgimg:addChild(signimg,1,1001)
    
    
    local tab = {bgImg = bgimg,awardBgImg = awardBgImg,awardImg = awardImg,numtx = numtx,chipImg = chipImg,doubleImg = doubleImg,
        signimg = signimg, vipLabel = vipLabel,effect =effect,mendimg =mendimg}
    return tab
end

function SignMainUI:update()
    if self.signdata.continuous_reward == 1 then
        self.getawardbtn:setTouchEnabled(false)
        self.getawardbtn:setBright(false)
        self.getawardbtntx:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
        self.getawardbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1)
    else
        self.getawardbtn:setTouchEnabled(true)
        self.getawardbtn:setBright(true)
        self.getawardbtntx:setString(GlobalApi:getLocalStr('STR_GET_1'))
        self.getawardbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1)
    end
    self.num = #self.signconf
    self.sv:removeAllChildren()
    for i=1, self.num do
        self:addCells(i,self.signconf[i])
    end
	self:updateRight()
end

function SignMainUI:addCells(index)
    self.celltab[index]= self:createAward()
    self:updateCell(index)
    local contentsize = self.celltab[index].bgImg:getContentSize()
    if math.ceil(self.num/6)*(contentsize.height+10) > self.sv:getContentSize().height then
        self.sv:setInnerContainerSize(cc.size(self.sv:getContentSize().width,math.ceil(self.num/6)*(contentsize.height+10)))
    end
    local posx = (contentsize.width+4.5)*((index-1)%6)+contentsize.width/2
    local posy = self.sv:getInnerContainerSize().height-(contentsize.height+10)*(math.floor((index-1)/6)) -contentsize.height/2
    self.celltab[index].bgImg:setPosition(cc.p(posx,posy))
    self.sv:addChild(self.celltab[index].bgImg)
end

function SignMainUI:updateCell(index)
    local data = self.signconf[index]
    local ismonthaward = self.signconf[index].monthly
    local displayobj = nil
    if ismonthaward >0 then
        local awrard = GameData:getConfData('signmonth')[tonumber(Time:getCurMonth())][tostring('award'..ismonthaward)]
        displayobj = DisplayData:getDisplayObj(awrard[1])
    else
        displayobj = DisplayData:getDisplayObj(data['award'][1])
    end

    if not displayobj then
        return
    end
    
    if displayobj:getObjType() ~= 'fragment' then
        self.celltab[index].chipImg:setVisible(false)
    else
        self.celltab[index].chipImg:loadTexture(displayobj:getChip())
    end
    displayobj:setLightEffect(self.celltab[index].awardBgImg)
    local light = self.celltab[index].awardBgImg:getChildByName('chip_light')
    if light then
        light:setLocalZOrder(2)
    end
    local temp1 = Time.getCurDay()
    local temp2 = tonumber(Time.getDayToModifiedServerDay())
    if index <= math.max(self.signdata.count,(Time.getCurDay()- GlobalApi:getMouthCannotSignDay())) then
        if index <= self.signdata.count then -- 这个是已经签到了的(已经签了)
            self.celltab[index].signimg:setVisible(true)
            self.celltab[index].mendimg:setVisible(false)
            self.celltab[index].effect:setVisible(false)
        elseif  (tonumber(self.signdata.day) == tonumber(Time.getDayToModifiedServerDay())) and index == self.signdata.count+1 then -- 这个是即将要签的（明天签）
            self.celltab[index].signimg:setVisible(false)
            self.celltab[index].mendimg:setVisible(true)
            self.celltab[index].effect:setVisible(true)
            self.celltab[index].mendimg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),cc.FadeIn:create(2),cc.FadeOut:create(2))))
        elseif index == self.signdata.count+1 and (tonumber(self.signdata.day) ~= tonumber(Time.getDayToModifiedServerDay())) then -- 这个是正好要签的(今天签)
            self.celltab[index].signimg:setVisible(false)
            self.celltab[index].mendimg:setVisible(false)
            self.celltab[index].effect:setVisible(true)
        elseif index > self.signdata.count+1 and index  <= (Time.getCurDay()- GlobalApi:getMouthCannotSignDay()) then  -- 这个是还未签的（不能签）
            self.celltab[index].signimg:setVisible(false)
            self.celltab[index].mendimg:setVisible(true)
            self.celltab[index].effect:setVisible(false)
            self.celltab[index].mendimg:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(2),cc.FadeIn:create(2),cc.FadeOut:create(2))))
        end
    else
        self.celltab[index].signimg:setVisible(false)
        self.celltab[index].mendimg:setVisible(false)
        self.celltab[index].effect:setVisible(false)
    end
    if self.signconf[index].vip > 0 then
        self.celltab[index].doubleImg:setVisible(true)
        self.celltab[index].vipLabel:setString(self.signconf[index].vip)
    else
        self.celltab[index].doubleImg:setVisible(false)
    end
    local contentsize = self.celltab[index].bgImg:getContentSize()
    self.celltab[index].awardBgImg:loadTexture(displayobj:getBgImg())
    self.celltab[index].bgImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)        
        elseif eventType == ccui.TouchEventType.ended then
            if index == self.signdata.count+1 or (index == self.signdata.count and tonumber(self.signdata.day) ~=  tonumber(Time.getDayToModifiedServerDay())) then
                if tonumber(self.signdata.day) ~=  tonumber(Time.getDayToModifiedServerDay()) then
                 MessageMgr:sendPost("sign", "user", json.encode(args), function (jsonObj)
                     print(json.encode(jsonObj))
                     local code = jsonObj.code
                     if code == 0 then
                         self.signdata.count = self.signdata.count + 1
                         -- year*10000+month*100+day
                         if tonumber(self.signdata.day) ~=  tonumber(Time.getDayToModifiedServerDay()) then
                             self.signdata.continuous  = self.signdata.continuous +1
                             self.signdata.day = tonumber(Time.getDayToModifiedServerDay())
                         end
                         local awards = jsonObj.data.awards
                         GlobalApi:parseAwardData(awards)
                         --GlobalApi:showAwards(awards)
                         GlobalApi:showAwardsCommon(awards,nil,nil,true)
                         local costs = jsonObj.data.costs
                         if costs then
                             GlobalApi:parseAwardData(costs)
                         end
                        self:updateCell(index)
                        if self.signconf[index+1] then
                            self:updateCell(index+1)
                        end

                        self:update()
                     end
                 end)
                elseif self.signdata.count < (Time.getCurDay() - GlobalApi:getMouthCannotSignDay())  then
                    if tonumber(UserData:getUserObj():getVip()) >= tonumber(GlobalApi:getGlobalValue('resignVipRequire'))then
                        local cost = tonumber(GlobalApi:getGlobalValue('resignCashCost'))
                        local richText = xx.RichText:create()
                        richText:setContentSize(cc.size(416, 40))
                        local tx = string.format(GlobalApi:getLocalStr("RESIGN_NEED"), cost)
                        local re = xx.RichTextLabel:create(tx, 25, COLOR_TYPE.ORANGE)
                        re:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
                        richText:addElement(re)
                        richText:setPosition(cc.p(262,216))
                        richText:setAnchorPoint(cc.p(0.5,0.5))

                        local function callback()
                            local args = {}
                            MessageMgr:sendPost("resign", "user", json.encode(args), function (jsonObj)
                                print(json.encode(jsonObj))
                                local code = jsonObj.code
                                if code == 0 then
                                    self.signdata.count = self.signdata.count + 1
                                    -- year*10000+month*100+day
                                    if tonumber(self.signdata.day) ~=  tonumber(Time.getDayToModifiedServerDay()) then
                                        self.signdata.continuous  = self.signdata.continuous +1
                                        self.signdata.day = tonumber(Time.getDayToModifiedServerDay())
                                    end
                                    local awards = jsonObj.data.awards
                                    GlobalApi:parseAwardData(awards)
                                    --GlobalApi:showAwards(awards)
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
                                    local costs = jsonObj.data.costs
                                    if costs then
                                        GlobalApi:parseAwardData(costs)
                                    end
                                    self:updateCell(index)
                                    if self.signconf[index+1] then
                                        self:updateCell(index+1)
                                    end
                                end
                            end)
                        end
                        UserData:getUserObj():cost('cash',cost,callback,1,richText)
                    else
                        promptmgr:showSystenHint(GlobalApi:getLocalStr('SIGN_NEED_VIP'), COLOR_TYPE.RED)
                    end
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('SIGN_DESC6'), COLOR_TYPE.RED)
                end
            else
                GetWayMgr:showGetwayUI(displayobj,false)
            end

        end
    end)
    self.celltab[index].awardImg:loadTexture(displayobj:getIcon())
    self.celltab[index].numtx:setString(displayobj:getNum())
end
function SignMainUI:updateRight()
	--local title = self.bgimg4:getChildByName('day_tx')
	local desc  = self.bgimg4:getChildByName('cont_desc_tx')
	--title:setString(self.signdata.continuous)
	desc:setString('')

	local richText2 = xx.RichText:create()
	richText2:setContentSize(cc.size(300, 40))
	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC4'), 23, COLOR_TYPE.YELLOW)
    re1:setFont('font/gamefont.ttf')
	re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = nil
    local showContinuous = self.signdata.continuous
    if self.signdata.continuous > 5 then
        showContinuous = 5
    end
    if self.signdata.continuous_reward == 1 then -- 已签
        re2 = xx.RichTextLabel:create(showContinuous, 25, COLOR_TYPE.WHITE)
    else
        re2 = xx.RichTextLabel:create(showContinuous, 25, COLOR_TYPE.WHITE)
    end
	re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('SIGN_DESC5'), 23, COLOR_TYPE.YELLOW)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    re3:setFont('font/gamefont.ttf')
	richText2:addElement(re1)
	richText2:addElement(re2)
	richText2:addElement(re3)
	richText2:setAlignment('middle')
    richText2:setVerticalAlignment('middle')
	richText2:setPosition(cc.p(0,-3))
	desc:removeAllChildren()
	desc:addChild(richText2)
	richText2:setVisible(true)

	local signawardconf = GameData:getConfData('signreward')
	local day = 1
	if self.signdata.continuous > 0 then
		day = self.signdata.continuous
	end
	if day > #signawardconf then
		day = #signawardconf
	end

	local displayarr = DisplayData:getDisplayObjs(signawardconf[day]['awards'])
	for i=1,2 do
		self.itemtab[i].bg:loadTexture(displayarr[i]:getBgImg())
		self.itemtab[i].bg:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)        
			elseif eventType == ccui.TouchEventType.ended then
				GetWayMgr:showGetwayUI(displayarr[i],false)
			end
		end)
        self.itemtab[i].icon:ignoreContentAdaptWithSize(true)
		self.itemtab[i].icon:loadTexture(displayarr[i]:getIcon())
		self.itemtab[i].numtx:setString('X'..displayarr[i]:getNum())
	end
end

function SignMainUI:updateMark()
    if UserData:getUserObj():getActivitySignShowStatus() then
        ActivityMgr:showMark("sign", true)
    else
        ActivityMgr:showMark("sign", false)
    end
end


return SignMainUI
