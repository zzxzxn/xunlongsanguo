local InfiniteBattleMain = class("InfiniteBattleMain", BaseUI)
local ClassActiveBox = require('script/app/ui/mainscene/activeboxui')

function InfiniteBattleMain:ctor(chapterId, openui)
	self.uiIndex = GAME_UI.UI_INFINITE_BATTLE_MAIN
	self.chapterId = chapterId or 1
	self.bgIndex = (chapterId - 1)%5 + 1
	self.openui = openui
end

function InfiniteBattleMain:onShowUIAniOver()
	if self.openui == 1 then

	elseif self.openui == 2 then
		InfiniteBattleMgr:showInfiniteBattleBoss(self.chapterId)
	end
end

function InfiniteBattleMain:onShow()
	self:updateStar()
end

function InfiniteBattleMain:init()
	local winSize = cc.Director:getInstance():getWinSize()
	local bg_alpha_img = self.root:getChildByName("bg_alpha_img")
	bg_alpha_img:setContentSize(winSize)
	bg_alpha_img:setPosition(cc.p(winSize.width/2, winSize.height/2))

	local bg_widget = self.root:getChildByName("bg_widget")
	bg_widget:setContentSize(winSize)
	bg_widget:setPosition(cc.p(winSize.width/2, winSize.height/2))

	local bg_img = bg_widget:getChildByName("bg_img")
	bg_img:loadTexture("uires/ui/infinitebattle/infinitebattle_bg_"..self.bgIndex..".jpg")
	bg_img:ignoreContentAdaptWithSize(true)
	bg_img:setAnchorPoint(cc.p(0, 0.5))
	bg_img:setPosition(cc.p(0, winSize.height/2))
	self.bg_img = bg_img

	local bgImgSize = bg_img:getContentSize()
	if winSize.width < bgImgSize.width then
		local bgImgPosX = 0
	    local infiniteData = UserData:getUserObj():getInfinite()
		local currId = infiniteData.city_id
	    if self.chapterId == infiniteData.chapter_id then
			local midPosX = winSize.width/2
			local conf = GameData:getConfData("itmain")[self.chapterId]
			local potinToWorldPos = bg_img:convertToWorldSpace(cc.p(conf[currId].pos[1], conf[currId].pos[2]))
			if potinToWorldPos.x > midPosX then
				bgImgPosX = midPosX - potinToWorldPos.x
			end
		end
		local limitLW = winSize.width - bgImgSize.width
	    local limitRW = 0
	    local preMovePos = nil
	    local movePos = nil
	    local bgImgDiffPosX = nil
	    local beganPos = nil
	    local targetPosX = nil
	    if bgImgPosX > limitRW then
            bgImgPosX = limitRW
        end
        if bgImgPosX < limitLW then
            bgImgPosX = limitLW
        end
        bg_img:setPositionX(bgImgPosX)
		bg_widget:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.moved then
	            preMovePos = movePos
	            movePos = sender:getTouchMovePosition()
	            if preMovePos then
	                bgImgDiffPosX = movePos.x - preMovePos.x
	                targetPosX = bgImgPosX + bgImgDiffPosX
	                if targetPosX > limitRW then
	                    targetPosX = limitRW
	                end
	                if targetPosX < limitLW then
	                    targetPosX = limitLW
	                end
	                bgImgPosX = targetPosX
	                bg_img:setPositionX(targetPosX)
	            end
	        elseif eventType == ccui.TouchEventType.began then
	            preMovePos = nil
	            movePos = nil
	            bgImgDiffPosX = nil
	            beganPos = sender:getTouchBeganPosition()
	        elseif eventType == ccui.TouchEventType.ended then
	            preMovePos = nil
	            movePos = nil
	            bgImgDiffPosX = nil
	        end
	    end)
	end

	local close_btn = self.root:getChildByName("close_btn")
	close_btn:setPosition(cc.p(winSize.width - 40, winSize.height - 40))
	close_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	InfiniteBattleMgr:hideInfiniteBattleMain()
        end
    end)

    local help_btn = self.root:getChildByName("help_btn")
    help_btn:setPosition(cc.p(35, winSize.height - 35))
	help_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	HelpMgr:showHelpUI(HELP_SHOW_TYPE.INFINITE_BATTLE_MAIN)
        end
    end)

    
	local star_btn = self.root:getChildByName("star_btn")
    star_btn:setPosition(cc.p(winSize.width - 60, 60))
	star_btn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	InfiniteBattleMgr:showInfiniteStarAward(self.chapterId)
        end
    end)
    self:createPoint()
    self:createSpecialItem()
    self:updateStar()
end

function InfiniteBattleMain:updateStar()
	local star_btn = self.root:getChildByName("star_btn")
	local new_img = star_btn:getChildByName("new_img")
	new_img:setVisible(UserData:getUserObj():getUnlimitedStarsShowStatus(self.chapterId))
    local text = star_btn:getChildByName('text')
    local starNum,allNum = InfiniteBattleMgr:getStarByChapterId(self.chapterId)
    local itsectionboxConf = GameData:getConfData("itsectionbox")[self.chapterId]
    local needNum = allNum
    for i,v in ipairs(itsectionboxConf) do
        if InfiniteBattleMgr.chapters[self.chapterId].stars[tostring(i)] == nil then
        	needNum = v.needStar
        	break
        end
    end
    text:setString(starNum..'/'..needNum)
end

function InfiniteBattleMain:createPoint()
    local conf = GameData:getConfData("itmain")[self.chapterId]
    local infiniteData = UserData:getUserObj():getInfinite()
    local branchData = InfiniteBattleMgr.chapters[self.chapterId].branch
    for i=#conf,1,-1 do
    	local pointBtn = ccui.Button:create()
        pointBtn:setPosition(cc.p(conf[i].pos[1],conf[i].pos[2]))
        pointBtn:setAnchorPoint(cc.p(0.5,0))
        self.bg_img:addChild(pointBtn)
    	local progress = 0
    	local isCross = false
    	local isNotOpen = false
    	if conf[i].isBranch == 0 then -- 主线
	    	if self.chapterId < infiniteData.chapter_id then
	    		pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_3.png','','')
	    		isCross = true
	    	elseif self.chapterId == infiniteData.chapter_id then
		    	if i < infiniteData.city_id then
		    		pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_3.png','','')
		    		isCross = true
		    	elseif i == infiniteData.city_id then
		    		pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_'..infiniteData.progress..'.png','','')
		    		progress = infiniteData.progress
		    		if progress >= 3 then
		    			isCross = true
		    		else
		    			local spine = GlobalApi:createSpineByName('map_fight', "spine/map_fight/map_fight", 1)
		    			spine:setPosition(cc.p(conf[i].pos[1],conf[i].pos[2] + 20))
				        spine:setAnimation(0, 'animation', true)
				        spine:setScale(0.5)
				        spine:setLocalZOrder(100)
				        self.bg_img:addChild(spine)
		    		end
		    	else
		    		pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_-1.png','','')
		    		isNotOpen = true
		    	end
	    	else
	    		pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_-1.png','','')
	    		isNotOpen = true
	    	end
	    else -- 支线
	    	local branchObj = branchData[tostring(conf[i].isBranch)]
	    	if branchObj then -- 当前这条支线已经开启
	    		local pointId = next(branchObj)
	    		if pointId then
	    			if tonumber(pointId) > i then
	    				pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_3.png','','')
		    			isCross = true
	    			elseif tonumber(pointId) == i then
	    				progress = tonumber(branchObj[pointId])
	    				pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_'..progress..'.png','','')
	    				if progress >= 3 then
	    					isCross = true
	    				end
	    			else
	    				pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_-1.png','','')
		    			isNotOpen = true
	    			end
	    		else
	    			pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_-1.png','','')
	    			isNotOpen = true
	    		end
	    	else
	    		pointBtn:loadTextures('uires/ui/infinitebattle/infinitebattle_point_-1.png','','')
	    		isNotOpen = true
	    	end
	    end

        pointBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	if isCross then
	        		promptmgr:showSystenHint(GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_3'), COLOR_TYPE.RED)
	        		return
	        	end
	        	if isNotOpen then
	        		promptmgr:showSystenHint(GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_4'), COLOR_TYPE.RED)
	        		return
	        	end
	        	InfiniteBattleMgr:showInfiniteBattle(self.chapterId, i, progress)
	        end
	    end)
    end
end

function InfiniteBattleMain:checkBox(specialBtn,conf)
	local data = InfiniteBattleMgr.chapters[self.chapterId].box[tostring(conf.index)]
	if data then
		promptmgr:showSystenHint(GlobalApi:getLocalStr('STR_HAVEGET'), COLOR_TYPE.RED)
		return
	end
	local tab = string.split(conf.getCondition, '-')
	local isOpen = false
	local info = GlobalApi:getLocalStr('STR_OK2')
	local nameStr = ''
	if tab[1] == 'main' then
		nameStr = GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_6')
		local infiniteData = UserData:getUserObj():getInfinite()
		if infiniteData.chapter_id > tonumber(tab[2]) then
			info = GlobalApi:getLocalStr('STR_GET_1')
			isOpen = true
		elseif infiniteData.chapter_id == tonumber(tab[2]) then
			if infiniteData.city_id > tonumber(tab[3]) then
				info = GlobalApi:getLocalStr('STR_GET_1')
				isOpen = true
			elseif infiniteData.city_id == tonumber(tab[3]) and infiniteData.progress >= 3 then
				info = GlobalApi:getLocalStr('STR_GET_1')
				isOpen = true
			end
		end
	elseif tab[1] == 'branch' then
		nameStr = GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_7')
		local branchData = InfiniteBattleMgr.chapters[self.chapterId].branch
		local itmainConf = GameData:getConfData("itmain")[self.chapterId]
		local branchObj = branchData[tostring(itmainConf[tonumber(tab[3])].isBranch)]
    	if branchObj then -- 当前这条支线已经开启
    		local pointId = next(branchObj)
    		if pointId then
    			if tonumber(pointId) > tonumber(tab[3]) then
    				isOpen = true
    				info = GlobalApi:getLocalStr('STR_GET_1')
    			elseif tonumber(pointId) == tonumber(tab[3]) and branchObj[pointId] >= 3 then
    				isOpen = true
    				info = GlobalApi:getLocalStr('STR_GET_1')
    			end
    		end
    	end
	end
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(400, 30))
    richText:setAlignment('middle')
    local tx1 = GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_10')..GlobalApi:getLocalStr('FUNCTION_DESC_1')
    local tx2 = nameStr
    local tx3 = GlobalApi:getLocalStr('ARENA_AWARDS_INFO_1')
    local tx4 = tab[2]
    local tx5 = GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_8')
    local tx6 = tab[3]
    local tx7 = GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_9')..GlobalApi:getLocalStr('STR_CANGET')
    local re1 = xx.RichTextLabel:create(tx1, 25,COLOR_TYPE.WHITE)
    local re2 = xx.RichTextLabel:create(tx2,25,COLOR_TYPE.ORANGE)
    local re3 = xx.RichTextLabel:create(tx3,25,COLOR_TYPE.WHITE)
    local re4 = xx.RichTextLabel:create(tx4, 25,COLOR_TYPE.ORANGE)
    local re5 = xx.RichTextLabel:create(tx5,25,COLOR_TYPE.WHITE)
    local re6 = xx.RichTextLabel:create(tx6,25,COLOR_TYPE.ORANGE)
    local re7 = xx.RichTextLabel:create(tx7,25,COLOR_TYPE.WHITE)
    re1:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re2:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re3:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re4:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re5:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    re6:setStroke(COLOROUTLINE_TYPE.ORANGE, 1)
    re7:setStroke(COLOROUTLINE_TYPE.WHITE, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:addElement(re3)
    richText:addElement(re4)
    richText:addElement(re5)
    richText:addElement(re6)
    richText:addElement(re7)
	local classActiveBox = ClassActiveBox.new(GlobalApi:getLocalStr('INFINITE_BATTLE_DESC_2'),info,richText,conf.award,isOpen,function(callback)
		local args = {
			id = self.chapterId,
			index = conf.index,
		}
		MessageMgr:sendPost('get_box_awards','unlimited',json.encode(args),function (response)
            local code = response.code
	        local data = response.data
	        if code == 0 then
	        	local awards = data.awards
	            if awards then
	                GlobalApi:parseAwardData(awards)
                    GlobalApi:showAwardsCommon(awards,nil,nil,true)
	            end
	            InfiniteBattleMgr.chapters[self.chapterId].box[tostring(conf.index)] = 1
	    		local str = string.gsub(conf.url,'icon/material','ui/common')
	    		specialBtn:loadTextures(str,'','')
	    		specialBtn:setVisible(false)
	    		InfiniteBattleMgr:checkBossBoxRedPointStatus(self.chapterId)
				if callback then
					callback()
				end
	        end
	    end)
	end)
	classActiveBox:showUI()
end

function InfiniteBattleMain:createSpecialItem()
	local conf = GameData:getConfData("itmapelement")[self.chapterId]
	for i,v in ipairs(conf) do
		local specialBtn
		local npc
		if v.type == 'enhance' then
			if InfiniteBattleMgr.chapters[self.chapterId] == nil or InfiniteBattleMgr.chapters[self.chapterId].boss[tostring(i)] == nil then
		    	specialBtn = ccui.Widget:create()
		    	specialBtn:setTouchEnabled(true)
		    	specialBtn:setContentSize(cc.size(80,70))
		        npc = GlobalApi:createSpineByName(v.url, "spine/city_building/"..v.url, 1)
	    		npc:setScale(0.4)
		        if npc then
		            npc:setAnimation(0, 'idle', true)
		        end
		        npc:setPosition(cc.p(45,0))
		        specialBtn:addChild(npc)
		        specialBtn:setPosition(cc.p(v.pos[1],v.pos[2]))
		        npc:registerSpineEventHandler(function (event)
			        if event.animation == 'idle2' then
			            self.root:runAction(cc.Sequence:create(cc.DelayTime:create(0.1),cc.CallFunc:create(function()
			            	specialBtn:setTouchEnabled(true)
			                npc:setAnimation(0, 'idle', true)
			                self:checkEnhance(specialBtn, v, self.chapterId, i)
			            end)))
			        end
			    end, sp.EventType.ANIMATION_END)

		        local upImg = ccui.ImageView:create('uires/ui/common/arrow1.png')
		        upImg:setAnchorPoint(cc.p(0,1))
		        upImg:setPosition(cc.p(60,90))
		        specialBtn:addChild(upImg)
		    end
	    elseif v.type == 'box' then
	    	local data = InfiniteBattleMgr.chapters[self.chapterId].box[tostring(v.index)]
	    	if data == nil then
	    		specialBtn = ccui.Button:create(v.url,'','')
	    		specialBtn:setPosition(cc.p(v.pos[1],v.pos[2]))
	    	end
	    elseif v.type == 'boss' then
	    	specialBtn = ccui.Button:create(v.url,'','')
	        specialBtn:setPosition(cc.p(v.pos[1],v.pos[2]))
	        local txBg = ccui.ImageView:create('uires/ui/legion/legion_building_bg.png')
	        txBg:setPosition(cc.p(v.pos[1] - 90, v.pos[2]))
	        txBg:setLocalZOrder(10)
	        self.bg_img:addChild(txBg)
	        local txImg = ccui.ImageView:create('uires/ui/text/tx_tz.png')
	        txImg:setPosition(cc.p(v.pos[1] - 90, v.pos[2]))
	        txImg:setLocalZOrder(20)
	        self.bg_img:addChild(txImg)
	    else
	    	specialBtn = ccui.Button:create(v.url,'','')
	        specialBtn:setPosition(cc.p(v.pos[1],v.pos[2]))
	    end
	    if specialBtn then
		    self.bg_img:addChild(specialBtn)
	        specialBtn:addTouchEventListener(function (sender, eventType)
		        if eventType == ccui.TouchEventType.began then
		            AudioMgr.PlayAudio(11)
		        elseif eventType == ccui.TouchEventType.ended then
		        	if v.type == 'enhance' then
					    npc:setAnimation(0, 'idle2', false)
					    specialBtn:setTouchEnabled(false)
		        	elseif v.type == 'box' then
		        		self:checkBox(specialBtn,v)
		        	elseif v.type == 'cage' then
		        		promptmgr:showSystenHint(GlobalApi:getLocalStr('TO_BE_EXPECTED'), COLOR_TYPE.GREEN)
		        	elseif v.type == 'boss' then
		        		InfiniteBattleMgr:showInfiniteBattleBoss(self.chapterId)
		        	end
		        end
		    end)
		end
	end
end

function InfiniteBattleMain:checkEnhance(specialBtn, conf, chapterId, index)
	local infiniteData = UserData:getUserObj():getInfinite()
	local tab = string.split(conf.getCondition, '-')
	local isOpen = false
	if tab[1] == 'main' then
		if infiniteData.chapter_id > tonumber(tab[2]) then
		 	isOpen = true
		elseif infiniteData.chapter_id == tonumber(tab[2]) then
			if infiniteData.city_id > tonumber(tab[3]) then
				isOpen = true
			elseif infiniteData.city_id == tonumber(tab[3]) and infiniteData.progress >= 3 then
				isOpen = true
			end
		end
	elseif tab[1] == 'branch' then
		local branchData = InfiniteBattleMgr.chapters[self.chapterId].branch
		local itmainConf = GameData:getConfData("itmain")[self.chapterId]
		local branchObj = branchData[tostring(itmainConf[tonumber(tab[3])].isBranch)]
    	if branchObj then -- 当前这条支线已经开启
    		local pointId = next(branchObj)
    		if pointId then
    			if tonumber(pointId) > tonumber(tab[3]) then
    				isOpen = true
    			elseif tonumber(pointId) == tonumber(tab[3]) and branchObj[pointId] >= 3 then
    				isOpen = true
    			end
    		end
    	end
	end
	if isOpen then
		InfiniteBattleMgr:showInfiniteBattleBossLevelUp(true, function ()
			local args = {
		    	id = chapterId,
		    	index = index
		    }
			MessageMgr:sendPost('strengthen_boss', 'unlimited', json.encode(args),function (response)
		        if response.code == 0 then
		        	specialBtn:setVisible(false)
		        	local infiniteData2 = UserData:getUserObj():getInfinite()
					infiniteData2.boss_sweep = response.data.boss_sweep
		        	infiniteData2.boss_level = infiniteData2.boss_level + 1
		        	InfiniteBattleMgr.chapters[self.chapterId].boss[tostring(index)] = 1
		        	InfiniteBattleMgr:checkBossBoxRedPointStatus(self.chapterId)
		        	InfiniteBattleMgr:showInfiniteBattleBoss(self.chapterId, true)
		        end
		    end)
		end)
	else
		InfiniteBattleMgr:showInfiniteBattleBossLevelUp(false)
	end
end

return InfiniteBattleMain