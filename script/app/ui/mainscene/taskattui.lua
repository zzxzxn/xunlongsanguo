local TaskAttUI = class("TaskAttUI", BaseUI)

function TaskAttUI:ctor(ntype,id)
	self.uiIndex = GAME_UI.UI_TASKATT
	self.ntype = ntype
	self.id = id
end

function TaskAttUI:init()
	local bg = self.root:getChildByName('award_bg_img')
	local bg1 = bg:getChildByName('award_alpha_img')
	self:adaptUI(bg, bg1)

	bg1:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	MainSceneMgr:hideTaskAtt()
        end
    end)

	local lightImg = bg1:getChildByName('light_img')
	lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(10, 360)))
	local node = bg1:getChildByName('middle_node')
	local titleTx = node:getChildByName('title_tx')
	local imgDi = node:getChildByName('img_di')
	local descTx = imgDi:getChildByName('desc_tx')
	descTx:setString(GlobalApi:getLocalStr('TASK_DESC_6'))
	local attr = {}
	if self.ntype == 1 then
		titleTx:setString(GlobalApi:getLocalStr('TASK_DESC_5'))
		local conf = GameData:getConfData('achievement')[self.id]
		attr = {conf.attr1,conf.attr2,conf.attr3,conf.attr4}
	else
		titleTx:setString(GlobalApi:getLocalStr('TASK_DESC_4'))
		attr = RoleData:getAchievementAttr()
	end
	for i=1,4 do
		local numTx = imgDi:getChildByName('num_'..i..'_tx')
		numTx:setString('+ '..attr[i])
	end
end

return TaskAttUI
