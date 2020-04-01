local TerritorialWarsEnemylistUI = class("TerritorialWarsEnemylist", BaseUI)


function TerritorialWarsEnemylistUI:ctor(enemylist,around)
    self.uiIndex = GAME_UI.UI_WORLD_MAP_ENEMYLIST
    self.enemylist = enemylist
    self.around = around
end

function TerritorialWarsEnemylistUI:init()
    
    local bgimg = self.root:getChildByName('bg_img')
    local enemyimg = bgimg:getChildByName('enemy_img')
    self:adaptUI(bgimg, enemyimg)

    local closeBtn = enemyimg:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:hideEnemylistUI()
        end
    end)

    local titleBg = enemyimg:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO32'))

    local innerbg = enemyimg:getChildByName('inner_bg')
    self.cardSv = innerbg:getChildByName('inner_sv')
    self.cardSv:setScrollBarEnabled(false)
    
    self:updateList()
end

function TerritorialWarsEnemylistUI:updateList()
    
    local size1
    local i = 0
    local myLid = UserData:getUserObj():getLid() 
    for k,v in pairs(self.enemylist) do
        if myLid ~= v.lid then
            i = i +1
            local cell = self.cardSv:getChildByTag(i + 100)
		    local cellBg
		    if not cell then
			    local cellNode = cc.CSLoader:createNode('csb/territoralwar_enemylist_cell.csb')
			    cellBg = cellNode:getChildByName('cell_bg')
			    cellBg:removeFromParent(false)
			    cell = ccui.Widget:create()
			    cell:addChild(cellBg)
			    self.cardSv:addChild(cell,1,i+100)
		    else
			    cellBg = cell:getChildByName('cell_bg')
		    end
		    cell:setVisible(true)
		    size1 = cellBg:getContentSize()

            --头像
            local roleIconBg = cellBg:getChildByName('rollIconbg')
            local icon = roleIconBg:getChildByName('rollIcon')
            local picpath=GameData:getConfData('settingheadicon')[v.headpic].icon
            icon:loadTexture(picpath)

            --名字
            local rolename = cellBg:getChildByName('role_name')
            rolename:setString(v.un)
            local vipImg = cellBg:getChildByName('vip_img')
            local vipTx = cellBg:getChildByName('vip_tx')
            vipTx:setString(v.vip or 0)
            local posX1,posY1 = rolename:getPositionX(),rolename:getPositionY()
            local size1 = rolename:getContentSize()
            local size2 = vipImg:getContentSize()
            vipImg:setPosition(cc.p(posX1 + size1.width + 5,posY1))
            vipTx:setPosition(cc.p(posX1 + size1.width + size2.width + 10,posY1))

            --战斗力
            local leftLabel = cc.LabelAtlas:_create(v.fightForce, "uires/ui/number/font_fightforce_3.png", 26, 38, string.byte('0'))
	        leftLabel:setAnchorPoint(cc.p(0,0.5))
	        leftLabel:setPosition(cc.p(152,41.5))
	        leftLabel:setScale(0.6)
	        cellBg:addChild(leftLabel)

            --军团
            local leginName = cellBg:getChildByName('legin_name')
            leginName:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INF14') .. v.legionName)

            --耐力
            local staying = cellBg:getChildByName('staying_num')
            staying:setString(v.stayingPower)

            --攻击中
            local fightImg = cellBg:getChildByName('get_icon')
            local isFighting = v.fightState

            --攻击
            local fightBtn = cellBg:getChildByName('confirm_btn')
            fightBtn:addTouchEventListener(function (sender, eventType)
                if eventType == ccui.TouchEventType.began then
                    AudioMgr.PlayAudio(11)
                elseif eventType == ccui.TouchEventType.ended then
                   self:Fighting(v.uid)
                end
            end)

            if  self.around == true then
                fightBtn:setVisible(not isFighting)
                fightImg:setVisible(isFighting)
            else
                fightBtn:setVisible(self.around)
                fightImg:setVisible(self.around)
            end

            local btnTx = fightBtn:getChildByName('info_tx')
            btnTx:setString(GlobalApi:getLocalStr('TERRITORIAL_WAL_INFO8'))
        end
    end
    
    local count = i
    local size = self.cardSv:getContentSize()
    if count > 0 then
	    if count * size1.height > size.height then
		    self.cardSv:setInnerContainerSize(cc.size(size.width,(count * size1.height+(count-1)*8)))
	    else
		    self.cardSv:setInnerContainerSize(size)
	    end
    
	    local function getPos(i)
	        local size2 = self.cardSv:getInnerContainerSize()
		    return cc.p(3,size2.height - size1.height* i-8*(i-1))
	    end
	    for i=1,count do
		    local cell = self.cardSv:getChildByTag(i + 100)
		    if cell then
			    cell:setPosition(getPos(i))
		    end
	    end
    end
end

function TerritorialWarsEnemylistUI:Fighting(uid)
    
    local conf = GameData:getConfData("dfbasepara")
    local minCost = tonumber(conf['enduranceCostLowest'].value[1])
    local myStayingPower = UserData:getUserObj():getEndurance()
    MessageMgr:sendPost('attack_player', 'territorywar', json.encode({targetUid  = uid}), function (jsonObj)
	    
        local data = jsonObj.data					
		if jsonObj.code == 0 then
			local customObj = {
				info = data.info,
                enemyUid = data.enemy.uid,
                enemyStayingPower = data.enemy.stayingPower,
                myStayingPower = myStayingPower,
				enemy = data.enemy,
				rand1 = data.rand1,
				rand2 = data.rand2,
                minCost = minCost,
                node = self.root,
			}

			BattleMgr:playBattle(BATTLE_TYPE.TERRITORALWAR_PLAYER, customObj, function ()
                TerritorialWarMgr:showMapUI()
			end)
        else
            TerritorialWarMgr:handleErrorCode(jsonObj.code)
		end
	end)

end
return TerritorialWarsEnemylistUI