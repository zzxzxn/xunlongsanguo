local GuardSkillUI = class("GuardSkillUI", BaseUI)

function GuardSkillUI:ctor(data)
	self.uiIndex = GAME_UI.UI_GUARDSKILL
end

function GuardSkillUI:init()
	local skillBgImg = self.root:getChildByName("skill_bg_img")
	local bgimg1 = skillBgImg:getChildByName('bg_img1')
    local skillImg = bgimg1:getChildByName('skill_img')
    self:adaptUI(skillBgImg,  bgimg1)

	local closeBtn = skillImg:getChildByName('close_btn')
	closeBtn:addTouchEventListener(function (sender, eventType)
		if eventType ==  ccui.TouchEventType.ended then
			GuardMgr:hideGuardSkill()
		end
	end)

	local data = GuardMgr:getAllCityData()
	local timeTx = skillImg:getChildByName('add_time_tx')

	local richText = xx.RichText:create()
    richText:setContentSize(cc.size(439, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('GUARD_DESC18'),25, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re2 = xx.RichTextLabel:create(data.guard.accumulate..GlobalApi:getLocalStr('STR_HOUR'),25, COLOR_TYPE.WHITE)
    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    richText:addElement(re1)
    richText:addElement(re2)
    richText:setPosition(cc.p(0,-10))
    richText:setAlignment('middle')
    timeTx:addChild(richText,9527)
	timeTx:setString('')
	local tiltebg = skillImg:getChildByName('title_bg')
	local titletx = tiltebg:getChildByName('title_tx')
	titletx:setString(GlobalApi:getLocalStr('GUARD_DESC21'))
	self.cellSv = skillImg:getChildByName('card_sv')
	self.cellSv:setBounceEnabled(false)
    self.cellSv:setScrollBarEnabled(false)
    self.cellSv:setInnerContainerSize(cc.size(780, 6 * 120))
    self:update()
end

function GuardSkillUI:update()
	local data = GuardMgr:getAllCityData()
	local cityConf  = GameData:getConfData('guardfield')	
	for i = 1, 6 do
		local skillConf = GameData:getConfData('guardskill')[i]
		local cell = cc.CSLoader:createNode("csb/guardskillcell.csb")
		local bgImg = cell:getChildByName('card_img')
		local cityIco = bgImg:getChildByName('city_ico')
		cityIco:loadTexture('uires/ui/guard/guard_' .. i .. '.png')
		local nameTx = bgImg:getChildByName('name_tx')
		nameTx:setString(cityConf[i].name)
		local canlv = false
		local lvTx = bgImg:getChildByName('lv_tx')
		local richText2 = xx.RichText:create()
	    richText2:setContentSize(cc.size(439, 40))
	    local re12 = xx.RichTextLabel:create('',20, COLOR_TYPE.WHITE)
	    re12:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	   	local re13 = xx.RichTextLabel:create('',20, COLOR_TYPE.GREEN)
	    re13:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    richText2:addElement(re12)
	    richText2:addElement(re13)
	    richText2:setAnchorPoint(cc.p(0,0.5))
	    richText2:setPosition(cc.p(0,-6))
	    lvTx:addChild(richText2,9527)
		local bgimg2 = bgImg:getChildByName('bg_img2')
		local addTimeTx = bgImg:getChildByName('open_tx')
		addTimeTx:setString('（'..GlobalApi:getLocalStr('GUARD_DESC23')..'）')
		local infoTx = bgimg2:getChildByName('info_tx')
		local str = string.format(GlobalApi:getLocalStr('GUARD_DESC17'),cityConf[i].name,skillConf[1].prob..'%')
		infoTx:setString(str)
		local maxlvimg = bgImg:getChildByName('max_lv_img')
		local richText = xx.RichText:create()
	    richText:setContentSize(cc.size(439, 40))
	    local re1 = xx.RichTextLabel:create('',20, COLOR_TYPE.GREEN)
	    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    local re2 = xx.RichTextLabel:create('',20, COLOR_TYPE.WHITE)
	    re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	   	local re3 = xx.RichTextLabel:create('',20, COLOR_TYPE.GREEN)
	    re3:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
	    richText:addElement(re1)
	    richText:addElement(re2)
	    richText:addElement(re3)
	    richText:setAnchorPoint(cc.p(1,0.5))
	    richText:setPosition(cc.p(0,-3))
	    richText:setAlignment('right')
	    addTimeTx:addChild(richText,9527)

		local cashIco = bgImg:getChildByName('cash_ico')
		cashIco:setVisible(false)
		local chahTx = cashIco:getChildByName('cash_tx')
		local upBtn = bgImg:getChildByName('up_btn')
		upBtn:addTouchEventListener(function (sender, eventType)
			if eventType ==  ccui.TouchEventType.ended then
				if not canlv then
					return
				end
				local cost = skillConf[tonumber(data.guard.field[tostring(i)].skill) + 1]['costs'][1]
				local displayobj = DisplayData:getDisplayObj(cost)
				UserData:getUserObj():cost('cash',displayobj:getNum(),function()
					local args = {
						id = i
					}
					MessageMgr:sendPost('upgrade_skill','guard',json.encode(args),function (jsonObj)
						print(json.encode(jsonObj))
						if jsonObj.code == 0 then
							local data = GuardMgr:getAllCityData()
							data.guard.field[tostring(i)].skill = data.guard.field[tostring(i)].skill +1
							local awards = jsonObj.data.awards
							if awards then
								GlobalApi:parseAwardData(awards)
								GlobalApi:showAwardsCommon(awards,nil,nil,true)
							end
							local costs = jsonObj.data.costs
							if costs then
								GlobalApi:parseAwardData(costs)
							end
							self:update(2)
						end
					end)
				end,true,string.format(GlobalApi:getLocalStr('NEED_CASH'),displayobj:getNum()))

			end
		end)
		upBtn:setBright(false)
    	upBtn:setTouchEnabled(false)
    	upBtn:setVisible(true)
		local upTx = upBtn:getChildByName('up_tx')
		upTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
		upTx:setString(GlobalApi:getLocalStr('STR_NOTOPEN'))
		maxlvimg:setVisible(false)
		for k, v in pairs(data.guard.field) do
			if tonumber(k) == i then
				if tonumber(v.skill) >= 5 then
					upBtn:setVisible(false)
					addTimeTx:setString('')
					re12:setString(v.skill)
					re13:setString(GlobalApi:getLocalStr('LEGION_LV_DESC'))
					richText2:format(true)
					lvTx:setString('')
					maxlvimg:setVisible(true)
					local str = string.format(GlobalApi:getLocalStr('GUARD_DESC37'),cityConf[i].name,skillConf[tonumber(v.skill)].prob..'%')
					infoTx:setString(str)		
				else
					if tonumber(data.guard.accumulate) >= tonumber(skillConf[tonumber(v.skill) + 1].need) then
						upBtn:setBright(true)
		    			upBtn:setTouchEnabled(true)
						upTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
		    			canlv = true
		    			addTimeTx:setString('')
						if tonumber(v.skill) == 0 then
							upTx:setString(GlobalApi:getLocalStr('GUARD_DESC20'))
							local str = string.format(GlobalApi:getLocalStr('GUARD_DESC17'),cityConf[i].name,skillConf[tonumber(v.skill) + 1].prob..'%')
							infoTx:setString(str)					
						else
							print('aaaa')
							upTx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
							re12:setString(v.skill)
							re13:setString(GlobalApi:getLocalStr('LEGION_LV_DESC'))
							richText2:format(true)
							lvTx:setString('')
							upTx:setString(GlobalApi:getLocalStr('UPGRADE1'))
							local str = string.format(GlobalApi:getLocalStr('GUARD_DESC37'),cityConf[i].name,skillConf[tonumber(v.skill)].prob..'%')
							infoTx:setString(str)	
						end
						cashIco:setVisible(true)
						local cost = skillConf[tonumber(v.skill) + 1]['costs'][1]
						local displayobj = DisplayData:getDisplayObj(cost)
						chahTx:setString('X'..displayobj:getNum())	
					else
						if tonumber(v.skill) == 0 then
							upTx:setString(GlobalApi:getLocalStr('STR_NOTOPEN'))
							upBtn:setBright(false)
	    					upBtn:setTouchEnabled(false)
							upTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
							re1:setString('（'..GlobalApi:getLocalStr('GUARD_DESC18'))
							re2:setString(skillConf[tonumber(v.skill) + 1].need)
							re3:setString(GlobalApi:getLocalStr('GUARD_DESC22')..'）')
							richText:format(true)
							addTimeTx:setString('')
						else
							re12:setString(v.skill)
							re13:setString(GlobalApi:getLocalStr('LEGION_LV_DESC'))
							richText2:format(true)
							lvTx:setString('')

							upTx:setString(GlobalApi:getLocalStr('UPGRADE1'))
							upBtn:setBright(false)
	    					upBtn:setTouchEnabled(false)
							upTx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
							re1:setString('（'..GlobalApi:getLocalStr('GUARD_DESC18'))
							re2:setString(skillConf[tonumber(v.skill) + 1].need)
							re3:setString(GlobalApi:getLocalStr('GUARD_DESC27')..'）')
							richText:format(true)
							addTimeTx:setString('')
						end
					end
				end	
			end
		end
		cell:setPosition(cc.p(0, 6 * 120 - i * 115))
		self.cellSv:addChild(cell)
	end		
end

return GuardSkillUI