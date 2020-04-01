local LegioncitysuipianUI = class("LegioncitysuipianUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function LegioncitysuipianUI:ctor(roledata,id)
    self.uiIndex = GAME_UI.UI_NEW_LEGIONCITY_SUIPIAN
    self.roledata = roledata

    local buildIndex = 4
    local buildId = (id - 1) * 4 + buildIndex
    local buildLevel = UserData:getUserObj():getLegionCityBuildingLevel(buildId)
    local buildingConf = GameData:getConfData('legioncityconf')
    print(buildId ,buildLevel)

    self.buildInfo = buildingConf[buildId][buildLevel]

    local cityConf = GameData:getConfData('legioncitybase')
    local cityInfo = cityConf[id]
    self.buildName = cityInfo['buildName' .. buildIndex]

    local functionConf = GameData:getConfData('legioncityfunction')
    local funcInfo = functionConf[cityInfo['buildFunction' .. buildIndex]]

    self.descValue = {}
    self.desc = {}
    for i=1,2 do
    	local value = 0
	    if self.buildInfo then
	        value = self.buildInfo.value[i]
	    end
	    self.descValue[i] = "0"
	    if value ~= 0 then
	    	self.descValue[i] = string.format(funcInfo.desc2[i], value) .. funcInfo.desc3
	    end
	    self.desc[i] = funcInfo.desc1[i]
    end

end

function LegioncitysuipianUI:init()
    
    

    local alphaBg = self.root:getChildByName("bg_img")
    local bg = alphaBg:getChildByName("bg_img1")
    self:adaptUI(alphaBg,bg)

    local outImg = bg:getChildByName("out_img")
    local winImg = outImg:getChildByName("wnd_img")

    local infoBg = winImg:getChildByName("info_bg")
    for i=1,2 do
    	local descTx = infoBg:getChildByName("desc" .. i)
    	local infoTx = infoBg:getChildByName("info" .. i)
    	descTx:setString(self.desc[i])
    	infoTx:setString(self.descValue[i])
    end

    local iconNode = winImg:getChildByName("icon_bg_node")
    local cardobj = RoleData:getRoleInfoById(self.roledata:getId())
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, cardobj, iconNode)
    cell.awardBgImg:setTouchEnabled(false)
    cell.lvTx:setVisible(false)

    --名字
    local nameTx = winImg:getChildByName("name")
    nameTx:setString(cardobj:getName())
    nameTx:setColor(cardobj:getNameColor())

    local descTx = winImg:getChildByName("desc")
    local str = string.format(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT56"),self.buildName,cardobj:getName())
    descTx:setString(str)

    local closebtn = outImg:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then    
        	 LegionMgr:hideLegionSuiPianUI()
        end
    end)
   	outImg:setTouchEnabled(true)
   	outImg:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then    
        	 LegionMgr:hideLegionSuiPianUI()
        end
    end)
end

return LegioncitysuipianUI