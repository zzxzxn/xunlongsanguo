local JadesealGetAwardUI = class("JadesealGetAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local MAXAWARD = 6
function JadesealGetAwardUI:ctor(jadesealid,awards )
	self.uiIndex = GAME_UI.UI_JADESEALGETAWARD
    self.jadesealconf = GameData:getConfData('jadeseal')
    self.jadesealid = jadesealid
    self.index = index
    self.awards = awards
end

function JadesealGetAwardUI:init()
	self.bgimg = self.root:getChildByName("bg_img")
    local winSize = cc.Director:getInstance():getWinSize()
    self.bgimg:setPosition(cc.p(winSize.width/2,0))
    self.titlebg = self.bgimg:getChildByName('title_bg')
    self.titlebg:setLocalZOrder(1)
    self.titlebg:setPosition(cc.p(self.titlebg:getPositionX(),winSize.height-50))
    self.titlebg:setScale(2)
    self.titlebg:runAction(cc.Sequence:create(cc.ScaleTo:create(0.3,1.5),cc.ScaleTo:create(0.2,1)))
    local titlenameimg = self.titlebg:getChildByName('title_name_img')
    titlenameimg:loadTexture('uires/ui/jadeseal/jadeseal_'..self.jadesealconf[self.jadesealid].jadesealnameicon)
    self.itembg = self.bgimg:getChildByName('item_bg')
    self.funcbtn = self.bgimg:getChildByName('func_btn')
    self.funcbtn:setVisible(false)
    self.funcbtn:setLocalZOrder(998)
    local funcbtntx = self.funcbtn:getChildByName('btn_tx')
    funcbtntx:setString(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES5'))
    self.funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local showWidgets = {}
            local awardTab = DisplayData:getDisplayObjs(self.awards)
            for k,v in ipairs(awardTab) do
                local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..v:getName()..'x'..v:getNum(), 'font/gamefont.ttf', 24)
                w:setTextColor(v:getNameColor())
                w:enableOutline(v:getNameOutlineColor(),1)
                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
                table.insert(showWidgets, w)
            end
            promptmgr:showAttributeUpdate(showWidgets)
            MainSceneMgr:hideJadesealGetAwardUI()
        end
    end)
    self.itembg:setLocalZOrder(999)
    self.itembg:setVisible(false)
    self.light1img = self.bgimg:getChildByName('light1_img')
    self.light1img:setLocalZOrder(1000)
    self.light1img:setVisible(false)
    local jadesealimg = self.light1img:getChildByName('jadeseal_img')
    self.light2img = self.bgimg:getChildByName('light2_img')
    self.light2img:setLocalZOrder(2)
    self.light2img:setVisible(false)

    jadesealimg:loadTexture('uires/ui/jadeseal/jadeseal_'..self.jadesealconf[self.jadesealid].jadesealicon)
    local displayobjs = DisplayData:getDisplayObjs(self.jadesealconf[self.jadesealid].awards)
    for i=1,MAXAWARD do
        if displayobjs[i] then
            local node = self.itembg:getChildByName('award_node_'..i)
            local tab = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, displayobjs[i], node)
            ClassItemCell:setGodLight(tab.awardBgImg, displayobjs[i]:getGodId())
        end
    end
    AudioMgr.playEffect("media/effect/jadeseal_getaward.mp3", false)
end

function JadesealGetAwardUI:_onShowUIAniOver()
    
    local winSize = cc.Director:getInstance():getWinSize()
    local bgImg = ccui.ImageView:create('uires/ui/common/bg_black.png')
    bgImg:setScale9Enabled(true)
    bgImg:setContentSize(cc.size(winSize.width,winSize.height))
    bgImg:setPosition(cc.p(self.bgimg:getContentSize().width/2,winSize.height/2))
    bgImg:setOpacity(125)
    self.bgimg:addChild(bgImg)
    self.itembg:setVisible(true)
    self.light1img:setVisible(true)
    self.funcbtn:setVisible(true)
    local action = cc.Spawn:create(cc.FadeIn:create(0.5),cc.ScaleTo:create(0.5,1))
    self.itembg:runAction(cc.Sequence:create(action))
    self.light1img:runAction(cc.Sequence:create(action))
end
return JadesealGetAwardUI
