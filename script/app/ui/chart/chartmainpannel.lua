local ChartMainPannelUI = class("ChartMainPannelUI", BaseUI)

function ChartMainPannelUI:ctor(fightIndex)
    self.uiIndex = GAME_UI.UI_CHART_MAIN_PANNEL
    self.fightIndex = fightIndex
    self:initData()
end

local defaultNor = 'uires/ui/common/title_btn_nor_2.png'
local defaultSel = 'uires/ui/common/title_btn_sel_2.png'

local MAXLOCALZORD = 1000
local MINLOCALZORD = 999

local text = {
	[1] = { ["text"] = GlobalApi:getLocalStr('WEI_JIANG') },
	[2] = { ["text"] = GlobalApi:getLocalStr('SHU_JIANG') },
	[3] = { ["text"] = GlobalApi:getLocalStr('WU_JIANG') },
    [4] = { ["text"] = GlobalApi:getLocalStr('QUN_XIONG') },
}

function ChartMainPannelUI:init()
    local fightIndex = self.fightIndex

    local bgimg = self.root:getChildByName("bg_img")
	local bgimg1 = bgimg:getChildByName("bg_img1")
    local bgimg2 = bgimg1:getChildByName('bg_img2')

    local closebtn = bgimg2:getChildByName("close_btn")
    closebtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            ChartMgr:hideChartMain()
            --ChartMgr:showChartInfo()
            ChartMgr:clearDemoData()
        end
    end)

    local svBg = bgimg2:getChildByName('sv_bg')
    local sv = svBg:getChildByName('sv')
    sv:setScrollBarEnabled(false)
    self.sv = sv

    local titleBg = bgimg2:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('CHART_TITLE'))

    -- 左边按钮
    self.btns = {}
    local btnsv = bgimg2:getChildByName('btn_sv')
    btnsv:setScrollBarEnabled(false)
    for i=1,self.leftBtnNum do
    	self.btns[i] = btnsv:getChildByName('btn' .. i)
    	self.btns[i].text = self.btns[i]:getChildByName('text')
    	self.btns[i]:addTouchEventListener(function (sender, eventType)
    		if eventType ==ccui.TouchEventType.began then
				AudioMgr.PlayAudio(11)
    		elseif eventType == ccui.TouchEventType.ended then
                if i == self.celltype then
                    return
                end
    			self:swapList(i)
                if self.state == 1 then
                    self:start()
                    self:updateItem()
                end

    		end
    	end)
    end
    self.btnsv = btnsv

    -- 底部
    local bottomBg = bgimg2:getChildByName("bottom_bg")

    local textBg = bgimg2:getChildByName("text_bg")
    self.textBg = textBg

    local label = textBg:getChildByName("text")
    self.label = label
    label:setString(GlobalApi:getLocalStr('HAS_COLLECT'))
    local collectText = textBg:getChildByName("collect_text")
    self.collectText = collectText
    
    local roleDemoPlay = bgimg2:getChildByName("role_demo_play")   -- 试玩
    roleDemoPlay:getChildByName("inputbtn_text"):setString(GlobalApi:getLocalStr('ROLE_DEMO_TEXT'))
    roleDemoPlay:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:start()
            self:updateItem()

            self.textBg:setVisible(false)
            self.roleDemoPlay:setVisible(false)
            self.demoBg:setVisible(true)

            self.state = 1

        end
    end)
    self.roleDemoPlay = roleDemoPlay


    -- 底部试玩
    local demoBg = bgimg2:getChildByName("demo_bg")
    demoBg:setVisible(false)
    self.demoBg = demoBg

    local startBtn = demoBg:getChildByName("start_btn")
    startBtn:getChildByName("inputbtn_text"):setString(GlobalApi:getLocalStr('START_TEXT'))
    startBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then          
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            if ChartMgr:getDemoDataNum() == 0 then
                promptmgr:showSystenHint(GlobalApi:getLocalStr('CHOOSE_ROLE_NULL'), COLOR_TYPE.RED)
            else
                local customObj = {
                    heroIds = ChartMgr:getDemoData(),
                    formation = tonumber(GlobalApi:getGlobalValue("chartEnemyFormation"))
                }
                BattleMgr:playBattle(BATTLE_TYPE.CHART, customObj, function ()
                    if not fightIndex then
                        MainSceneMgr:showMainCity(function ()
                            ChartMgr:clearDemoData()
                        end)
                        return
                    end
                    
                    if fightIndex and fightIndex == 4 then
                        MapMgr:showMainScene(2,nil,function()
                            ChartMgr:clearDemoData()
                            MapMgr:showLiubeiInfoPanel()
                        end)
                        return
                    end
                    MainSceneMgr:showMainCity(function()
                        ChartMgr:clearDemoData()

                        -- 1版

                        --TavernMgr:showTavernMain()
                        --ChartMgr:showChartMain()

                        -- 2版                     
                        TavernMgr:showTavernMainFromFight(fightIndex)
   
                    end, nil, GAME_UI.UI_CHART_MAIN_PANNEL)
                    
                end)
            end
        end
    end)

    local giveupBtn = demoBg:getChildByName("giveup_btn")
    giveupBtn:getChildByName("inputbtn_text"):setString(GlobalApi:getLocalStr('GIVE_UP_TEXT'))
    giveupBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		end
        if eventType == ccui.TouchEventType.ended then
            self:giveUp()

            ChartMgr:clearDemoData()

        end
    end)

    self.frames = {}
    for i = 1,7 do
        self.frames[i] = demoBg:getChildByName("frame_" .. i)
        self.frames[i].icon = self.frames[i]:getChildByName("icon")
        self.frames[i].icon.index = i
        self.frames[i].close = self.frames[i]:getChildByName("close")
        self.frames[i].close.index = i
        self.frames[i]:setVisible(false)

        self.frames[i].icon:setTouchEnabled(true)
        self.frames[i].close:setTouchEnabled(true)

        self.frames[i].icon:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                if self.state == 1 and sender:isVisible() == true then            
                    self:removeItem(sender.index)
                end

            end
        end)


        self.frames[i].close:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                if self.state == 1 and sender:isVisible() == true then
                    self:removeItem(sender.index)
                end

            end
        end)

    end

    self.tempCard = self.sv:getChildByName("card")
    self.tempCard:setVisible(false)
    self.tempCard:setTouchEnabled(false)

    self:swapList(self.celltype)


    self:adaptUI(bgimg, bgimg1)

end

function ChartMainPannelUI:onShow()
    self.roleDemoPlay:setTouchEnabled(true)
    if ChartMgr:getDemoDataNum() > 0 then
        self:start()
        self:updateItem()

        self.textBg:setVisible(false)
        self.roleDemoPlay:setVisible(false)
        self.demoBg:setVisible(true)

        self.state = 1
    else
        self.state = 0
    end
    
end

function ChartMainPannelUI:updateItem()
	for i = 1,7 do
        self:updateEveryItem(i)
    end

end

function ChartMainPannelUI:updateEveryItem(i)
    local demoData = ChartMgr:getDemoData()
    local heroconf = GameData:getConfData('hero')
    self.frames[i]:setVisible(true)
    if demoData[i] > 0 then
        local cardData = heroconf[demoData[i]]
        local goldframeImg = self.frames[i].icon:getChildByName('gold_frame_img')
        if not goldframeImg then
            goldframeImg = GlobalApi:createLittleLossyAniByName('ui_jinjiangtouxiang')
            goldframeImg:setScale(0.6)
            local iconSize = self.frames[i].icon:getContentSize()
            goldframeImg:setPosition(cc.p(iconSize.width/2, iconSize.height/2))
            goldframeImg:getAnimation():playWithIndex(0, -1, 1)
            goldframeImg:setName('gold_frame_img')
            self.frames[i].icon:addChild(goldframeImg)
        end
        goldframeImg:setVisible(false)
        if cardData.quality == 7 then
            self.frames[i]:loadTexture('uires/ui/common/frame_gold.png')
            goldframeImg:setVisible(true)
        elseif cardData.quality == 6 then
            self.frames[i]:loadTexture('uires/ui/common/frame_red.png')
        elseif cardData.quality == 5 then
            self.frames[i]:loadTexture('uires/ui/common/frame_yellow.png')
        elseif cardData.quality == 4 then
            self.frames[i]:loadTexture('uires/ui/common/frame_purple.png')
        else
            self.frames[i]:loadTexture('uires/ui/common/frame_default.png')
        end
        self.frames[i].icon:loadTexture('uires/icon/hero/' .. cardData.heroIcon)
        self.frames[i].icon:setVisible(true)
        self.frames[i].close:setVisible(true)

        for k,v in pairs(self.cells) do
            if v and v.id == demoData[i] then
                v.maskImg:setVisible(true)
                v.imgRight:setVisible(true)
                break
            end
        end
    else
        self.frames[i]:loadTexture('uires/ui/common/frame_default.png')
        self.frames[i].icon:setVisible(false)
        self.frames[i].close:setVisible(false)
    end

end


--- 开始试玩
function ChartMainPannelUI:start()
    local demoData = ChartMgr:getDemoData()
    for k,v in pairs(self.cells) do
        if v then
            v.heroImg:loadTexture('uires/icon/big_hero/' .. v.bigIcon)
            v.maskImg:setVisible(false)
            v.imgRight:setVisible(false)
        end
    end

end

--- 取消试玩
function ChartMainPannelUI:giveUp()
    local demoData = ChartMgr:getDemoData()
    for k,v in pairs(self.cells) do
        if v then
            if v.hasRole then
                v.heroImg:loadTexture('uires/icon/big_hero/' .. v.bigIcon)
                v.maskImg:setVisible(false)                 
            else
                --v.heroImg:loadTexture('uires/ui/common/lvbu.png')
                v.heroImg:loadTexture('uires/icon/big_hero/' .. v.bigIcon)
                v.maskImg:setVisible(true)
            end
            v.imgRight:setVisible(false)

        end
    end

    self.textBg:setVisible(true)
    self.roleDemoPlay:setVisible(true)
    self.demoBg:setVisible(false)

    self.state = 0
    
end


--- 取消选择项
function ChartMainPannelUI:removeItem(index)
    self.frames[index]:loadTexture('uires/ui/common/frame_default.png')
    self.frames[index].icon:setVisible(false)
    self.frames[index].close:setVisible(false)

    local demoData = ChartMgr:getDemoData()
    for k,v in pairs(self.cells) do
        if v and v.id == demoData[index] then
            v.maskImg:setVisible(false)
            v.imgRight:setVisible(false)
            break
        end
    end
      
    ChartMgr:removeDemoDataByIndex(index)
    
end

--- 取消选择项,根据id
function ChartMainPannelUI:removeItemById(id)
    local demoData = ChartMgr:getDemoData()
    local index = nil
    for k,v in pairs(demoData) do
        if v and v == id then
            index = k
            break
        end
    end

    if index then
        self:removeItem(index)
    end

end



function ChartMainPannelUI:initData()
    self.celltype = 2   --当前选择的类型
    
    self.state = 0      -- 0：正常状态，1:试玩状态

    self.dataTab = {
	    [1] = { },
	    [2] = { },
	    [3] = { },
        [4] = { },
    }

    local conf = GameData:getConfData('hero')
    local tempDataTab =  {
	    [1] = { },
	    [2] = { },
	    [3] = { },
        [4] = { },
    }

    self.numTab =  {
	    [1] = { ["hasNum"] = 0 },
	    [2] = { ["hasNum"] = 0 },
	    [3] = { ["hasNum"] = 0 },
        [4] = { ["hasNum"] = 0 },
    }


    local roleCardMap = BagData.roleCardMap

    for k,v in pairs(conf) do
        if tempDataTab[v.camp] and v.display == 1 then
            local index = #tempDataTab[v.camp] + 1
            tempDataTab[v.camp][index] = v
            if roleCardMap[v.id] then -- 这里是只要存在，不管分不分解
                tempDataTab[v.camp][index].hasRole = true
                self.numTab[v.camp].hasNum = self.numTab[v.camp].hasNum + 1
            end
        end
    end

    for i = 1,4 do
        table.sort(tempDataTab[i],function(x,y) return x.id < y.id end)
    end

    for i = 1,4 do
        local temp = tempDataTab[i]
        local temp1 = {}
        local temp2 = {}
        local temp3 = {}
        for j = 1,#temp do
            if temp[j].quality == 4 then
                temp1[#temp1 + 1] = temp[j]
            elseif temp[j].quality == 5 then
                temp2[#temp2 + 1] = temp[j]
            elseif temp[j].quality == 6 then
                temp3[#temp3+1] = temp[j]
            elseif temp[j].quality == 7 then
                self.dataTab[i][#self.dataTab[i] + 1] = temp[j]
            end
        end
        for l = 1,#temp3 do
            self.dataTab[i][#self.dataTab[i] + 1] = temp3[l]
        end
        for m = 1,#temp2 do
            self.dataTab[i][#self.dataTab[i] + 1] = temp2[m]
        end
        for k = 1,#temp1 do
            self.dataTab[i][#self.dataTab[i] + 1] = temp1[k]
        end
    end


    self.leftBtnNum = #self.dataTab
    self.cells = {}


end

function ChartMainPannelUI:swapList(celltype)
    self.celltype = celltype

    for i=1,self.leftBtnNum do
        local str = string.gsub(text[i].text, '|', '\r\n')
    	self.btns[i].text:setString(str)
        if i == self.celltype then
            self.btns[i]:loadTextureNormal(defaultSel)
            self.btns[i].text:setTextColor(cc.c3b(0xff, 0xff, 0xff))
            --self.btns[i].text:enableOutline(cc.c3b(0x4e, 0x31, 0x11),1)
	        --self.btns[i].text:enableShadow(cc.c3b(0x4e, 0x31, 0x11),cc.size(0, -1))   
        else
            self.btns[i]:loadTextureNormal(defaultNor)
            self.btns[i].text:setTextColor(cc.c3b(0xcf, 0xba, 0x8d))
            --self.btns[i].text:enableOutline(cc.c3b(0x4e, 0x31, 0x11),1)
	        --self.btns[i].text:enableShadow(cc.c3b(0x4e, 0x31, 0x11),cc.size(0, -1))  
        end
	end

	self:updateCell(celltype)
    self.sv:scrollToLeft(0.01, false)

end

function ChartMainPannelUI:updateCell(celltype)
	local innerContainer = self.sv:getInnerContainer()
    
    for k,v in pairs(self.cells) do
        if v then
            v:removeFromParent()
        end
    end
    self.cells = {}
    
    local cureDataTab = self.dataTab[celltype]
    
    local offset = 15
    local cardWidth = self.tempCard:getContentSize().width
    local topInitPos = {self.tempCard:getPositionX(),self.tempCard:getPositionY()}
    local bottomInitPos = {self.tempCard:getPositionX(),self.tempCard:getPositionY() - 5 - self.tempCard:getContentSize().height}

    local allWidth = math.floor((#cureDataTab + 1)/2) * (cardWidth + offset) + 20 -- 20是前面和最后面一小段距离
    local svSize = self.sv:getContentSize()
    if allWidth > svSize.width then
        self.sv:setInnerContainerSize(cc.size(allWidth,svSize.height))
    else
        self.sv:setInnerContainerSize(svSize) -- 切换标签页
    end

    for i = 1,#cureDataTab do
        local cardData = cureDataTab[i]
        local card = self.tempCard:clone()
        card:setVisible(true)
        card:setTouchEnabled(true)

        local heroImg = card:getChildByName("hero_img")
        local nameTx = card:getChildByName("name_tx")
        local soldierImg = card:getChildByName("soldier_img")
        local typeImg = card:getChildByName("type_img")
        local img1 = card:getChildByName("img_1")

        local maskImg = card:getChildByName("mask_img")
        local imgRight = card:getChildByName("img_right")
        card.maskImg = maskImg
        card.imgRight = imgRight
        card.soldierImg = soldierImg

        card.id = cardData.id
        card.heroImg = heroImg
        card.bigIcon = cardData.bigIcon
        card.hasRole = cardData.hasRole

        card:loadTexture(COLOR_CARDBG[cardData.quality] or COLOR_CARDBG[1])
        if cardData.hasRole then
            heroImg:loadTexture('uires/icon/big_hero/' .. cardData.bigIcon)   
            maskImg:setVisible(false)    
        else
            --print('dfsadsafdsafdsafdsafasafdsafdsaffafada')
            --heroImg:loadTexture('uires/ui/common/lvbu.png')
            heroImg:loadTexture('uires/icon/big_hero/' .. cardData.bigIcon)  
            maskImg:setVisible(true)
            
        end

        imgRight:setVisible(false)

        nameTx:setString(cardData.heroName)
        local soliderId = cardData.soldierId or 1
        soldierImg:loadTexture('uires/ui/common/'..'soldier_'..soliderId..'.png')

        local campType = cardData.camp or 1
        typeImg:loadTexture('uires/ui/common/camp_'..campType..'.png')

        img1:loadTexture('uires/ui/common/professiontype_'..cardData.ability..'.png')
        
        self.cells[i] = card
        if i == 1 then
            card:setPosition(topInitPos[1],topInitPos[2])
            innerContainer:addChild(card)
        elseif i == 2 then
            card:setPosition(cc.p(bottomInitPos[1],bottomInitPos[2]))
            innerContainer:addChild(card)
        else
            local value = math.floor(i/2)
            if i%2 == 0 then -- 下面
                local addWidth = (cardWidth + offset) * (value - 1)
                card:setPosition(cc.p(bottomInitPos[1] + addWidth,bottomInitPos[2]))
                innerContainer:addChild(card)
            else -- 上面
                local addWidth = (cardWidth + offset) * value
                card:setPosition(cc.p(topInitPos[1] + addWidth,topInitPos[2]))
                innerContainer:addChild(card)
            end
        end
        

        card:addTouchEventListener(function (sender, eventType)
		    if eventType == ccui.TouchEventType.began then
			    AudioMgr.PlayAudio(11)
		    end
            if eventType == ccui.TouchEventType.ended then
                self.roleDemoPlay:setTouchEnabled(false)
                local demoData = ChartMgr:getDemoData()
                local num = #demoData
                if self.state == 1 and ChartMgr:getDemoDataNum() <= 7 then
                    self.roleDemoPlay:setTouchEnabled(true)
                    for i = 1,7 do
                        if demoData[i] and demoData[i] == card.id then
                            -- promptmgr:showSystenHint(GlobalApi:getLocalStr("HAS_CHOOSE_THIS_ROLE"), COLOR_TYPE.RED)
                            -- 已经选择的此项，取消此项
                            self:removeItemById(card.id)
                            return
                        end
                    end

                    if ChartMgr:getDemoDataNum() == 7 then
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("HAS_ENOUTH_TEXT"), COLOR_TYPE.RED)
                    else                       
                        local index = ChartMgr:getMinIndex()
                        ChartMgr:setDemoDataByIndex(index,card.id)
                        self:updateEveryItem(index)
                    end

                elseif self.state == 1 and ChartMgr:getDemoDataNum() > 7 then
                    self.roleDemoPlay:setTouchEnabled(true)
                    promptmgr:showSystenHint(GlobalApi:getLocalStr("HAS_ENOUTH_TEXT"), COLOR_TYPE.RED)
                else
                    ChartMgr:showChartInfo(cardData,ROLE_SHOW_TYPE.CHART)
                end

                

            end
        end)


    end

    self.collectText:setString(string.format(GlobalApi:getLocalStr("COLLECT_NUM"), self.numTab[celltype].hasNum,#self.dataTab[celltype]))

end

return ChartMainPannelUI