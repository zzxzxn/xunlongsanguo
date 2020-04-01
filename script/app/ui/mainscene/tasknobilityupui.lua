local TaskNobilityUpUI = class("TaskNobilityUpUI", BaseUI)
local nobilityIconUrl = "uires/ui/worldwar/worldwar_"
function TaskNobilityUpUI:ctor(callback,nobilityId,nobiltyStar)
	self.uiIndex = GAME_UI.UI_NEW_TASK_NOBILITY_UP
	self.callback = callback
	self.nobilityId = nobilityId
	self.nobiltyStar = nobiltyStar
end

function TaskNobilityUpUI:init()

	local nobilitybaseCfg = GameData:getConfData('nobiltybase')
	local alphaBg = self.root:getChildByName("alpha_bg")
	local bg = alphaBg:getChildByName("bg_img")
	self:adaptUI(alphaBg, bg)

    local nobilityId,nobiltyStar = self.nobilityId,self.nobiltyStar
    
	local nobiltyIcon = bg:getChildByName("nobilityIcon")
	local nameTx = nobiltyIcon:getChildByName("text")
	nobiltyIcon:loadTexture(nobilityIconUrl .. nobilitybaseCfg[nobilityId].icon)
	nameTx:setString(nobilitybaseCfg[nobilityId].name)

	local beforNameTx = bg:getChildByName("name1")
	local beforId  = nobilityId-1
	if beforId <= 0 then
		beforId = 1
	end
	beforNameTx:setString(nobilitybaseCfg[beforId].name)
	local afterNameTx = bg:getChildByName("name2")
	afterNameTx:setString(nobilitybaseCfg[nobilityId].name)

	local tipTx = bg:getChildByName("tip")
	tipTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT50"))

	local preNobilityId = nobilityId-1
	if preNobilityId <=0 then
		preNobilityId = 1
	end

	--攻击,物防,法防,生命
	for i=1,4 do	
		local attrName = GlobalApi:getLocalStr("STR_ATT" .. i)
		if i==2 then
			attrName = GlobalApi:getLocalStr("STR_ATT3")
		elseif i == 3  then
			attrName = GlobalApi:getLocalStr("STR_ATT4")
		elseif i ==4 then
			attrName = GlobalApi:getLocalStr("STR_ATT2")
		end
		local preAttrValue = nobilitybaseCfg[preNobilityId]["attr" .. i]
		local attrValue = nobilitybaseCfg[nobilityId]["attr" .. i]
		local attrNameTx = bg:getChildByName("attr" .. i)
		local valueTx = bg:getChildByName("attrvalue" .. i)
		attrNameTx:setString(attrName)
		valueTx:setString("+" .. preAttrValue)

		local attrNameTx1 = bg:getChildByName("attrR" .. i)
		local valueTx1 = bg:getChildByName("attrvalueR" .. i)
		attrNameTx1:setString(attrName)
		valueTx1:setString("+" .. attrValue)

	end
	alphaBg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            MainSceneMgr:hideTaskNobilityUpUI()
            if self.callback then
            	self.callback()
            end
        end
    end)

    local descTx = bg:getChildByName("desc_tx")
    descTx:setString(GlobalApi:getLocalStr('CLICK_ANY_POS_CONTINUE'))
    descTx:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.FadeOut:create(1),cc.FadeIn:create(1))))

    local lightImg = bg:getChildByName("light_bg")
    lightImg:runAction(cc.RepeatForever:create(cc.RotateBy:create(10, 360)))
end

return TaskNobilityUpUI