
local TrainingSelectUI = class("TrainingSelectUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function TrainingSelectUI:ctor(heroList)
	self.uiIndex = GAME_UI.UI_TRAININGSELECT
	self.heroList=heroList

	RoleMgr:sortByQuality(self.heroList,ROLELISTTYPE.UI_ASSIST)
end

function TrainingSelectUI:onShow()
	self:updatePanel()
end

function TrainingSelectUI:updatePanel()

end

function TrainingSelectUI:init()
	local bg1 = self.root:getChildByName("bg1")
	local bg2 = bg1:getChildByName("bg2")
	self:adaptUI(bg1, bg2)
	local winSize = cc.Director:getInstance():getVisibleSize()
	bg2:setPosition(cc.p(winSize.width/2,winSize.height/2 - 45))	
	
	self.tempHeroCell=ccui.Helper:seekWidgetByName(bg2, 'heroCell')
    self.tempHeroCell:setVisible(false)
	self.tempHeroCell:setTouchEnabled(false)
	
	--hero view
	self.heroSv = bg2:getChildByName('hero_sv')
    local contentWidget = ccui.Widget:create()
    self.heroSv:addChild(contentWidget)
    local svSize = self.heroSv:getContentSize()
    self.heroSv:setScrollBarEnabled(false)
    contentWidget:setPosition(cc.p(0, svSize.height))
	
	local col=2
	local dis = svSize.width - 430
	local innerHeight=0
	for i = 1, #self.heroList do
		local cell = self:createHeroCell(i)
		innerHeight = math.ceil(i/col)*148
		cell:setPosition(cc.p(((i-1)%col)*dis+430/2, 70-innerHeight))
		contentWidget:addChild(cell)
	end
	innerHeight = innerHeight < svSize.height and svSize.height or innerHeight
	self.heroSv:setInnerContainerSize(cc.size(svSize.width, innerHeight))
	contentWidget:setPosition(cc.p(0, innerHeight))
	
	--close
	bg1:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.ended then
			TrainingMgr:hideTrainingSelect()
			AudioMgr.PlayAudio(11)
	    end
	end)
	
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
	
	self:updatePanel()	
end

function TrainingSelectUI:createHeroCell(idx)
	--hero is class of roleObject
	local hero=self.heroList[idx]

    local newCell = self.tempHeroCell:clone()
	
	newCell:setName('cell'..idx)

	newCell.bgPic = ccui.Helper:seekWidgetByName(newCell,"bgPic")
	local bgPicSize = newCell.bgPic:getContentSize()
	local headpicCell = ClassItemCell:create(ITEM_CELL_TYPE.HERO, hero, newCell.bgPic)
	headpicCell.awardBgImg:setTouchEnabled(false)
	headpicCell.awardBgImg:setPosition(bgPicSize.width/2, bgPicSize.height/2)
    newCell.nameText = ccui.Helper:seekWidgetByName(newCell,"name")
	newCell.lvText = ccui.Helper:seekWidgetByName(newCell,"lv")
	newCell.expBar = ccui.Helper:seekWidgetByName(newCell,"expBar")
	newCell.expVal = ccui.Helper:seekWidgetByName(newCell,"expText")
	newCell.job = ccui.Helper:seekWidgetByName(newCell,"type")
	newCell.mask = ccui.Helper:seekWidgetByName(newCell,"mask")
	newCell.maskText = ccui.Helper:seekWidgetByName(newCell,"maskText")
	newCell.nameText:setString(hero:getName())
	newCell.job:loadTexture('uires/ui/common/soldier_'..hero:getSoldierId()..'.png')
	newCell.job:ignoreContentAdaptWithSize(true)
	local lv=hero:getLevel()
	newCell.lvText:setString(lv)
	local percent, curexp ,needexp=hero:getExpPercent()
	newCell.expVal:setString(percent.."%")
	newCell.expBar:setPercent(percent)
	
	local isShowMask=hero.isTraining
	newCell.mask:setVisible(isShowMask)
	newCell.maskText:setVisible(isShowMask)
	newCell.mask:setTouchEnabled(isShowMask)
	newCell.mask:addClickEventListener(function ()
			AudioMgr.PlayAudio(11)
			promptmgr:showSystenHint(GlobalApi:getLocalStr('TRAINING_HERO_ISTRAIN_NOW'), COLOR_TYPE.RED)
        end)
		
    newCell:setVisible(true)
	newCell:setTouchEnabled(true)
	
	newCell:addClickEventListener(function ()
			AudioMgr.PlayAudio(11)
			
			-- if tonumber(hero:getLevel())>= tonumber(UserData:getUserObj():getLv()) then
			-- 	promptmgr:showSystenHint(GlobalApi:getLocalStr('LVUP_FAIL2'), COLOR_TYPE.RED)				
			-- else
				self:setHero(idx)
			-- end
        end)
		
    return newCell
end

function TrainingSelectUI:setHero(idx)
	
	local function Attack()
		TrainingMgr:SetTrainingSlot(self.heroList[idx])
	end
	TrainingMgr:hideTrainingSelect(Attack)
end

function TrainingSelectUI:ActionClose(call)
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

return TrainingSelectUI