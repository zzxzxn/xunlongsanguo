local TavernRecruit = class("TavernRecruit")
local WIDTH = 284
local HEIGHT = 327

local ActiveTavernActiveBoxUI = require("script/app/ui/activity/page_activiy_tavern_activeboxui")
local TavernRecruitAward = require("script/app/ui/activity/page_tavern_recruit_award")

function TavernRecruit:init(msg)
    self.rootBG = self.root:getChildByName("root")
    self.tavern_recruit = msg.tavern_recruit

    UserData:getUserObj().activity.tavern_recruit = self.tavern_recruit

    self:initTop()

    self:initData()
    self:initLeft()

    self:refreshCount()

    self:initRight()
    self:initRightBottom()

    self:updateMark()
end

function TavernRecruit:updateMark()
    if UserData:getUserObj():getSignByType('tavern_recruit') then
		ActivityMgr:showMark("tavern_recruit", true)
	else
		ActivityMgr:showMark("tavern_recruit", false)
	end
end

function TavernRecruit:initData()
    self.avTavernRecruitConf = GameData:getConfData('avtavernrecruit')
    self.avTavernRecruitFrequencyConf = GameData:getConfData('avtavernrecruitfrequency')
end

function TavernRecruit:initTop()
    ActivityMgr:showRightTavernRecruitRemainTime()
    ActivityMgr:showLefTavernRecruitCue()   -- °ïÖú°´Å¥
end

function TavernRecruit:initLeft()
    local leftBg = self.rootBG:getChildByName("left_bg")
    local title = leftBg:getChildByName("title")
    title:setString(GlobalApi:getLocalStr("ACTIVE_TAVERN_RECRUIT_DES1"))

    --local tips = leftBg:getChildByName("tips")
    --tips:setString(string.format(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES2'),self.avTavernRecruitFrequencyConf[1].num))

    local recruitBtn = leftBg:getChildByName("recruit_btn")
    recruitBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            -- µ½¾Æ¹Ý½çÃæ
            TavernMgr:showTavernMain()
            ActivityMgr:hideUI()
        end
    end)
    recruitBtn:getChildByName("tx"):setString(GlobalApi:getLocalStr("ACTIVE_TAVERN_RECRUIT_DES3"))

    local tipsCountDesc = leftBg:getChildByName("tips_count_desc")
    tipsCountDesc:setString(GlobalApi:getLocalStr("ACTIVE_TAVERN_RECRUIT_DES4"))

end

function TavernRecruit:refreshCount()
    local leftBg = self.rootBG:getChildByName("left_bg")
    local tipsCount = leftBg:getChildByName("tips_count")
    tipsCount:setString(self.tavern_recruit.frequency or 0)
end

function TavernRecruit:initRight()
    local sv = self.rootBG:getChildByName("sv")
    sv:setScrollBarEnabled(false)
    self.sv = sv
    sv:setVisible(false)

    local cell = self.rootBG:getChildByName("cell")
    cell:setVisible(false)
    self.cell = cell

    self:refreshSv()
end

function TavernRecruit:refreshSv()
    if self.rootBG:getChildByName('scrollView_sv') then
        self.rootBG:removeChildByName('scrollView_sv')
    end
    local sv = self.sv:clone()
    sv:setVisible(true)
    sv:setName('scrollView_sv')
    self.rootBG:addChild(sv)

    local cell = self.cell

    local num = self.tavern_recruit.num
    local id = num + 1
    local showId = id
    -- ¿´ÊÇ·ñ´ïµ½´ÎÊý
    local judge = 1  -- 1:²»ÄÜÁìÈ¡£¬2£º¿ÉÒÔÁìÈ¡£¬3£ºÒÑ¾­ÁìÈ¡ÍêÁË£¬ÏÔÊ¾µÚ1ÂÖµÄ
    if id > #self.avTavernRecruitFrequencyConf then
        id = 1
        showId = #self.avTavernRecruitFrequencyConf
        judge = 3
    else        
        if self.tavern_recruit.frequency >= self.avTavernRecruitFrequencyConf[id].num then
            judge = 2
        else
            judge = 1
        end
    end

    local leftBg = self.rootBG:getChildByName("left_bg")
    local tips = leftBg:getChildByName("tips")
    --tips:setString(string.format(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES2'),self.avTavernRecruitFrequencyConf[showId].num))
    if leftBg:getChildByName('richText_tips') then
        leftBg:removeChildByName('richText_tips')
    end
    if leftBg:getChildByName('richText_tips2') then
        leftBg:removeChildByName('richText_tips2')
    end

    local richText = xx.RichText:create()
    richText:setName('richText_tips')
	richText:setContentSize(cc.size(250, 150))

	local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES14'), 25, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create(string.format(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES15'),self.avTavernRecruitFrequencyConf[showId].num), 25, COLOR_TYPE.ORANGE)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES16'), 25, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:addElement(re5)
    richText:addElement(re6)

    richText:setAlignment('left')
    richText:setVerticalAlignment('top')

	richText:setAnchorPoint(cc.p(0,1))
	richText:setPosition(tips:getPosition())
    richText:format(true)
    leftBg:addChild(richText)


    local richText2 = xx.RichText:create()
    richText2:setName('richText_tips2')
	richText2:setContentSize(cc.size(250, 150))

    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES18'), 25, COLOR_TYPE.WHITE)
	re1:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re1:setFont('font/gamefont.ttf')

    local re2 = xx.RichTextLabel:create('+1', 25, COLOR_TYPE.GREEN)
	re2:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES17'), 25, COLOR_TYPE.WHITE)
	re3:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re3:setFont('font/gamefont.ttf')

    local re4 = xx.RichTextLabel:create('+2', 25, COLOR_TYPE.GREEN)
	re4:setStroke(COLOROUTLINE_TYPE.BLACK,1)
    re4:setFont('font/gamefont.ttf')

	richText2:addElement(re1)
	richText2:addElement(re2)
    richText2:addElement(re3)
    richText2:addElement(re4)

    richText2:setAlignment('left')
    richText2:setVerticalAlignment('top')

	richText2:setAnchorPoint(cc.p(0,1))
	richText2:setPosition(cc.p(tips:getPositionX(),tips:getPositionY() - 63))
    richText2:format(true)
    leftBg:addChild(richText2)

    print('====================+++++++++++++++++++++' .. id)

    local awardData = self.avTavernRecruitFrequencyConf[id].awards
    local disPlayData = DisplayData:getDisplayObjs(awardData)

    local num = #disPlayData
    local size = sv:getContentSize()
    local innerContainer = sv:getInnerContainer()
    local allWidth = size.width
    local cellSpace = 0

    local width = num * WIDTH + (num - 1)*cellSpace
    if width > size.width then
        innerContainer:setContentSize(cc.size(width,size.height))
        allWidth = width
    else
        allWidth = size.width
        innerContainer:setContentSize(size)
    end

    local offset = 0
    local tempWidth = WIDTH
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
        tempCell:setPosition(cc.p(offset,0))
        sv:addChild(tempCell)

        -- ×´Ì¬,cardÊý¾Ý
        local data = disPlayData[i]
        local roleobj = RoleData:getRoleInfoById(data:getId())

        local name = tempCell:getChildByName('name')
        self.quality = roleobj:getNameColor()
        name:setString(roleobj:getName())
        name:setColor(cc.c4b(self.quality.r ,self.quality.g ,self.quality.b ,self.quality.a))


        local county = tempCell:getChildByName('county')
        county:setVisible(false)

        --xyh
        --类型
        local type_img = tempCell:getChildByName('type_img')

        if roleobj:getAbilityType() == 1 then
            type_img:loadTexture("uires/ui/common/professiontype_1.png")
        elseif roleobj:getAbilityType() == 2 then
            type_img:loadTexture("uires/ui/common/professiontype_2.png")
        elseif roleobj:getAbilityType() == 3 then
            type_img:loadTexture("uires/ui/common/professiontype_3.png")
        else
            type_img:loadTexture("uires/ui/common/professiontype_4.png")
        end


        --阵营
        local camp_img = tempCell:getChildByName('camp_img')

        if roleobj:getCamp() == 1 then
            camp_img:loadTexture("uires/ui/common/camp_1.png")
        elseif roleobj:getCamp() == 2 then
            camp_img:loadTexture("uires/ui/common/camp_2.png")
        elseif roleobj:getCamp() == 3 then
            camp_img:loadTexture("uires/ui/common/camp_3.png")
        else
            camp_img:loadTexture("uires/ui/common/camp_4.png")
        end



        
        -- ¿¨ÅÆspine
        local spineAni = GlobalApi:createLittleLossyAniByName(roleobj:getUrl() .. "_display")
	    if spineAni then
	        spineAni:setScale(1.1)
		    local shadow = spineAni:getBone(roleobj:getUrl() .. "_shadow")
		    if shadow then
			    shadow:changeDisplayWithIndex(-1, true)
		    end
		    local effectIndex = 1
		    repeat
			    local aniEffect = spineAni:getBone(roleobj:getUrl() .. "_effect" .. effectIndex)
			    if aniEffect == nil then
				    break
			    end
			    aniEffect:changeDisplayWithIndex(-1, true)
			    aniEffect:setIgnoreMovementBoneData(true)
			    effectIndex = effectIndex + 1
		    until false
		    --spineAni:setLocalZOrder(999)
		    spineAni:setTag(9527)
		    tempCell:addChild(spineAni)
		    spineAni:getAnimation():play('idle', -1, 1)
            spineAni:setPosition(cc.p(size.width/2,60 + roleobj:getUiOffsetY()))
	    end

        -- µã»÷ÊÂ¼þ
        tempCell:setTouchEnabled(true)
        tempCell:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if judge == 1 then
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES11'), COLOR_TYPE.RED)
                elseif judge == 2 then
                    --local tavernRecruitAward = TavernRecruitAward.new(awardData,self)
			        --tavernRecruitAward:showUI()
                    promptmgr:showMessageBox(
				        GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES13'),
				        MESSAGE_BOX_TYPE.MB_OK_CANCEL,
				        function()
                            local args = {id = i - 1}

					        MessageMgr:sendPost('get_tavern_recruit_generals','activity',json.encode(args),function (jsonObj)
                            print(json.encode(jsonObj))
                                if jsonObj.code == 0 then
                                    local awards = jsonObj.data.awards
                                    if awards then
                                        GlobalApi:parseAwardData(awards)
                                        local awards1 = awardData
                                        local displayobj = DisplayData:getDisplayObjs(awards1)
                                        if displayobj[i]:getObjType() == 'card' then
                                            TavernMgr:showTavernAnimate(awards, function ()
                                                TavernMgr:hideTavernAnimate()
                                            end, 4)
                                        else
                                            GlobalApi:showAwardsCommon(awards,nil,nil,true)
                                        end
                                    end
                                    local costs = jsonObj.data.costs
                                    if costs then
                                        GlobalApi:parseAwardData(costs)
                                    end
                                    self.tavern_recruit.num = self.tavern_recruit.num + 1
                                    UserData:getUserObj().activity.tavern_recruit.num = self.tavern_recruit.num
                                    self:refreshSv()
                                    self:updateMark()
                                end
                            end)

				    end)

                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVE_TAVERN_RECRUIT_DES12'), COLOR_TYPE.RED)
                end
            end
        end)

    end
    innerContainer:setPositionX(0)

end

function TavernRecruit:initRightBottom()
    local expBar = self.rootBG:getChildByName("exp_bar")   
    expBar:setScale9Enabled(true)
    expBar:setCapInsets(cc.rect(10,15,1,1))

    local maxNum = 0
    for k,v in pairs(self.avTavernRecruitConf) do
        if v.num > maxNum then
            maxNum = v.num
        end
    end

    local percent = 0
    local hasNum = self.tavern_recruit.frequency
    if hasNum >= maxNum then
        percent = 100
    else
        percent = hasNum/maxNum * 100
    end
    expBar:setPercent(percent)

    for i = 1,5 do
        local box = self.rootBG:getChildByName("box_" .. i .. "_img")
        box:setLocalZOrder(10000)

        -- ÅÐ¶Ï´ÎÊýÊÇ·ñ´ïµ½
        local frequency = self.tavern_recruit.frequency
        local state = 1
        if frequency >= self.avTavernRecruitConf[i].num then
            local rewards = self.tavern_recruit.rewards
            if rewards[tostring(i)] and rewards[tostring(i)] == 1 then
                ShaderMgr:setGrayForWidget(box)
                state = 3
                if i == 1 or i == 2 then
                    box:loadTexture('uires/ui/common/box1.png')
                elseif i == 3 or i == 4 then
                    box:loadTexture('uires/ui/common/box2.png')
                else
                    box:loadTexture('uires/ui/common/box3.png')
                end
                box:setTouchEnabled(false)
            else
                ShaderMgr:restoreWidgetDefaultShader(box)
                state = 1
            end
        else
            state = 2
            ShaderMgr:setGrayForWidget(box)
        end

        local numTx = box:getChildByName('num_tx')
        numTx:setString(self.avTavernRecruitConf[i].num)

        box:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if state ~= 3 then
                    local function callBack()
                        self.tavern_recruit.rewards[tostring(i)] = 1
                        UserData:getUserObj().activity.tavern_recruit.rewards = self.tavern_recruit.rewards
                        self:initRightBottom()
                        self:updateMark()
                    end
                    local activeTavernActiveBoxUI = ActiveTavernActiveBoxUI.new(i,callBack,state)
			        activeTavernActiveBoxUI:showUI()
                end
            end
        end)

        if state == 1 then
            self:playEffect(box)
        else
            if box.lvUp then
                box.lvUp:removeFromParent()
                box.lvUp = nil
            end
        end
    end

end

function TavernRecruit:playEffect(img)
    if img.lvUp then
        img.lvUp:removeFromParent()
        img.lvUp = nil
    end
    
    local parent = img:getParent()
    local img = img
    local posX = img:getPositionX()
    local posY = img:getPositionY()

    local size1 = img:getContentSize()
    local lvUp = ccui.ImageView:create("uires/ui/activity/guang.png")
    lvUp:setPosition(cc.p(posX ,posY + 65))
    lvUp:setAnchorPoint(cc.p(0.5,0.5))
    lvUp:setLocalZOrder(100)
    img:setLocalZOrder(101)
    parent:addChild(lvUp)

    local size = lvUp:getContentSize()
    local particle = cc.ParticleSystemQuad:create("particle/ui_xingxing.plist")
    particle:setScale(0.5)
    particle:setPositionType(cc.POSITION_TYPE_RELATIVE)
    particle:setPosition(cc.p(size.width/2, size.height/2))
    lvUp:addChild(particle)

    img.lvUp = lvUp
end
return TavernRecruit