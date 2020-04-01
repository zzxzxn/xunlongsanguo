local SkillSelectUI = class("SkillSelectUI", BaseUI)

function SkillSelectUI:ctor(callback,desc,desc1)
	self.uiIndex = GAME_UI.UI_SKILL_SELECT
    self.callback = callback
    self.desc = desc
    self.desc1 = desc1
end

function SkillSelectUI:createCards()
    local conf = GameData:getConfData("playerskill")
    local neiBgImg = self.pl:getChildByName('nei_bg_img')
    local cardSv = neiBgImg:getChildByName('card_sv')
    cardSv:setScrollBarEnabled(false)
    local treasureInfo = UserData:getUserObj():getTreasure()
    local id = tonumber(treasureInfo.id)
    local treasureConf = GameData:getConfData("treasure")
    local size1
    local maxLevel = id
    for i=1,maxLevel do
        local img = ccui.ImageView:create('uires/ui/treasure/treasure_kapai.png')
        size1 = img:getContentSize()
        img:setTouchEnabled(true)
        local anim = GlobalApi:createLittleLossyAniByName(conf[i].res)
        anim:setPosition(cc.p(size1.width/2 + 5, size1.height/2 - 30))
        anim:getAnimation():play('idle', -1, 1)
        anim:setScale(0.6)
        local cellImg = ccui.ImageView:create('uires/ui/treasure/treasure_cell.png')
        cellImg:setPosition(cc.p(138.85,116.15))
        local nameImg = ccui.ImageView:create('uires/ui/treasure/treasure_'..string.gsub(conf[i].icon,'icon','name'))
        nameImg:setPosition(cc.p(size1.width/2 + 10,58))
        img:addChild(anim)
        img:addChild(cellImg)
        img:addChild(nameImg)
        img:setScale(0.5)
        img:setPosition(cc.p((i - 0.5)*(size1.width*0.5 + 20),100))
        cardSv:addChild(img)
        local isNotOpen = false
        if i > id then
            isNotOpen = true
            ShaderMgr:setGrayForWidget(img)
            ShaderMgr:setGrayForArmature(anim, "default_etc")
            ShaderMgr:setGrayForWidget(cellImg)
            ShaderMgr:setGrayForWidget(nameImg)
        end
        img:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if isNotOpen and self.desc1 then
                    promptmgr:showSystenHint(self.desc1, COLOR_TYPE.RED)
                else
                    MainSceneMgr:hideSkillSelect()
                    if self.callback then
                        self.callback(i)
                    end
                end
            end
        end)
    end
    local size = cardSv:getContentSize()
    if maxLevel * (size1.width*0.5 + 20) > size.width then
        cardSv:setInnerContainerSize(cc.size((maxLevel)*(size1.width*0.5 + 20),size.height))
    else
        cardSv:setInnerContainerSize(cc.size(size.width,size.height))
    end
end

function SkillSelectUI:init()
    local skillBgImg = self.root:getChildByName("skill_bg_img")
    self.pl = skillBgImg:getChildByName('pl')
    self:adaptUI(skillBgImg,self.pl)
    local winSize = cc.Director:getInstance():getVisibleSize()
    
    local neiBgImg = self.pl:getChildByName('nei_bg_img')
    self.pl:setContentSize(cc.size(winSize.width,winSize.height))
    neiBgImg:setPosition(cc.p(winSize.width/2,winSize.height/2 + 50))
    local infoTx = neiBgImg:getChildByName('info_tx')
    infoTx:setString(self.desc)

    self.pl:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideSkillSelect()
        end
    end)

    self:createCards()
end
    
return SkillSelectUI