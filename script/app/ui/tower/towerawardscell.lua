local TowerAwardCell = class("TowerAwardCell")
local ClassItemCell = require('script/app/global/itemcell')
function TowerAwardCell:ctor(pos, starNum)
	self.starNum =starNum 
	self.pos = pos
	self:initPanel()
end

function TowerAwardCell:initPanel()
	local panel = cc.CSLoader:createNode("csb/towerawardscell.csb")
	local bgimg = panel:getChildByName("awardcell_img")
	bgimg:removeFromParent(false)
	self.panel = ccui.Widget:create()
	self.panel:addChild(bgimg)
	local tab  =ClassItemCell:create()
	local node = bgimg:getChildByName('award_node')
	self.framebg = tab.awardBgImg--bgimg:getChildByName('awardframe_img')
	self.iconimg = tab.awardImg--self.framebg:getChildByName('award_img')
	node:addChild(self.framebg)
	self.nametx = bgimg:getChildByName('name_tx')
	self.lv = bgimg:getChildByName('lv_tx')
	local desc1 = bgimg:getChildByName('desc_1_tx')
	desc1:setString('')
	-- self.desc2 = bgimg:getChildByName('desc_2_tx')
	-- self.desc2:setString(GlobalApi:getLocalStr('STR_CANGET'))
	self.richtext = xx.RichText:create()
    self.richtext:setContentSize(cc.size(480, 40))
    local re1 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_NEEDSTAR'), 25, COLOR_TYPE.ORANGE)
    re1:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.re2 = xx.RichTextLabel:create(tostring(self.starNum), 25, COLOR_TYPE.WHITE)
    self.re2:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    local re3 = xx.RichTextImage:create('uires/ui/common/icon_xingxing2.png')
    local re4 = xx.RichTextLabel:create(GlobalApi:getLocalStr('STR_CANGET'), 25, COLOR_TYPE.ORANGE)
    re4:setStroke(COLOROUTLINE_TYPE.BLACK, 1)
    self.richtext:addElement(re1)
    self.richtext:addElement(self.re2)
    self.richtext:addElement(re3)
    self.richtext:addElement(re4)
    --self.richtext:setAnchorPoint(cc.p(0,0.5))
    self.richtext:setAlignment('middle')
    self.richtext:setPosition(cc.p(0,3))
    desc1:addChild(self.richtext,9527)
    self.richtext:setVisible(true) 

	self.desc3 = bgimg:getChildByName('desc_3_tx')
	self.desc3:setString(GlobalApi:getLocalStr('STR_ONDOING'))
	--self.numtx = bgimg:getChildByName('num_tx')
	self.bgimg1 = bgimg:getChildByName('bg_img')
	self.bgimg1:setVisible(self.pos%2 ~= 0)
	self.funcbtn = bgimg:getChildByName('get_btn')
	self.funcbtn:setPropagateTouchEvents(false)
	local funcbtntx =self.funcbtn:getChildByName('info_tx')
	funcbtntx:setString(GlobalApi:getLocalStr('STR_GET'))
	self.funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local args = {
                id = self.starNum,
            }
            MessageMgr:sendPost('get_star_awards','tower',json.encode(args),function (response)
				
				local code = response.code
				local data = response.data
				if code == 0 then
					GlobalApi:parseAwardData(response.data.awards)
					local costs = response.data.costs
	                if costs then
	                    GlobalApi:parseAwardData(costs)
	                end
	                TowerMgr:getTowerData().got[tostring(self.starNum)] = 1
	                local showWidgets = {}
		            local awardTab = DisplayData:getDisplayObjs(response.data.awards)
		            for k,v in ipairs(awardTab) do
		                local w = cc.Label:createWithTTF(GlobalApi:getLocalStr('CONGRATULATION_TO_GET')..':'..v:getName()..'x'..v:getNum(), 'font/gamefont.ttf', 24)
		                w:setTextColor(v:getNameColor())
		                w:enableOutline(v:getNameOutlineColor(),1)
		                w:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.NORMAL))
		                table.insert(showWidgets, w)
		            end
		            promptmgr:showAttributeUpdate(showWidgets)
					self:update()
					
				end
			end)
        end
    end)
	self:update()
end

function TowerAwardCell:getPanel()
	return self.panel
end

function TowerAwardCell:update()
	local conf = GameData:getConfData('towerstarreward')[self.starNum]
	local award = DisplayData:getDisplayObj(conf['award'][1])
	local awardobj =award:getObj()
	if award  then
		self.framebg:loadTexture(award:getBgImg())
		ClassItemCell:setGodLight(self.framebg,award:getGodId())
		self.framebg:addTouchEventListener(function (sender, eventType)
			if eventType == ccui.TouchEventType.began then
            	AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	        	--GetWayMgr:showGetwayUI(award,false)
	        	if awardobj then
	        		GetWayMgr:showGetwayUI(awardobj,false)
	        	else
	        		GetWayMgr:showGetwayUI(award,false)
	        	end
	        end
	    end)
		self.iconimg:loadTexture(award:getIcon())
		self.nametx:setString(award:getName())
		self.nametx:setTextColor(award:getNameColor())
    	--self.nametx:enableOutline(award:getNameOutlineColor(),2)
    	if award:getObjType() ~= 'equip'  then
    		self.lv:setString('x' ..award:getNum())
    	else
			self.lv:setString('Lv.' ..award:getLevel())
		end
	end
	
	if TowerMgr:getTowerData().max_star < self.starNum then
		self.funcbtn:setVisible(false)
		self.desc3:setString(GlobalApi:getLocalStr('STR_ONDOING'))
		self.desc3:setTextColor(COLOR_TYPE.RED)
    	--self.desc3:enableOutline(COLOROUTLINE_TYPE.RED,2)
	else
		if TowerMgr:getTowerData().got ~= nil and tonumber(TowerMgr:getTowerData().got[tostring(self.starNum)]) == 1 then
			self.desc3:setString(GlobalApi:getLocalStr('STR_HAVEGET'))
			self.desc3:setTextColor(COLOR_TYPE.GREEN)
    		--self.desc3:enableOutline(COLOROUTLINE_TYPE.GREEN,2)
    		self.desc3:setVisible(true)
    		self.funcbtn:setVisible(false)	
		else
			self.funcbtn:setVisible(true)
			self.desc3:setVisible(false)
		end
	end
	self.re2:setString(self.starNum)
	self.richtext:format(true)
	--self.numtx:setString(self.starNum)
end

return TowerAwardCell