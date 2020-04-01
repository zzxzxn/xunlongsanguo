local GemMergeMainUI = class("GemMergeMainUI", BaseUI)
local ClassGemObj = require('script/app/obj/gemobj')
local ClassItemCell = require('script/app/global/itemcell')
local MAX_GEM = 10
local diffSize = 7

function GemMergeMainUI:ctor(obj)
	self.uiIndex = GAME_UI.UI_GEM_MERGE_MAIN
	self.obj = obj
	self.page = math.floor(obj:getId()/100) or 1
end

function GemMergeMainUI:onShow()
	-- self:updatePanel()
end

function GemMergeMainUI:updatePanel()
	local desc = GlobalApi:getLocalStr('GEM_PAGE_'..self.page)
	for i=2,MAX_GEM do
        local bgImg = self.cellSv:getChildByName('bg_img_'..i)
        if not bgImg then
            local cellNode = cc.CSLoader:createNode("csb/gemmergecell.csb")
            bgImg = cellNode:getChildByName('bg_img')
            bgImg:removeFromParent(false)
            bgImg:setName('bg_img_'..i)
            local size = bgImg:getContentSize()
            bgImg:setPosition(cc.p(7,(MAX_GEM - i)*(size.height + diffSize) + diffSize - 2))
            self.cellSv:addChild(bgImg)
        end
        local awardBgImg = bgImg:getChildByName('award_bg_img')
        local awardImg = awardBgImg:getChildByName('award_img')
        local nameTx = bgImg:getChildByName('name_tx')
        local descTx = bgImg:getChildByName('desc_tx')
        local numBgImg = bgImg:getChildByName('num_bg_img')
        local descTx1 = numBgImg:getChildByName('desc_tx')
        local numTx = numBgImg:getChildByName('num_tx')
        local mergeBtn = bgImg:getChildByName('merge_btn')
        local obj = BagData:getGemObjById(self.page*100 + i)
        local num = obj:getAutoMergeNum()
        awardImg:loadTexture(obj:getIcon())
        awardImg:ignoreContentAdaptWithSize(true)
        awardBgImg:loadTexture(obj:getBgImg())
        nameTx:setString(i..GlobalApi:getLocalStr('LEGION_LV_DESC')..desc)
        nameTx:setColor(obj:getNameColor())
        nameTx:enableOutline(obj:getNameOutlineColor(),1)
        descTx:setString(obj:getAttrName()..' +'..obj:getValue())
        descTx1:setString(GlobalApi:getLocalStr('GEM_MERGE_DESC_1')..'：')
        numTx:setString(num)
        mergeBtn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
                if num > 0 then
                    BagMgr:showGemMerge(self.page*100 + i,function()
                        self:updatePanel()
                    end)
                else
                    promptmgr:showSystenHint(GlobalApi:getLocalStr('GEMUPGERADE_DESC1'),COLOR_TYPE.RED)
                end
	        end
	    end)
	end

    for i=1,4 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        if i == self.page then
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
end

function GemMergeMainUI:init()
	self.bgImg = self.root:getChildByName("merge_bg_img")
	local mergeImg = self.bgImg:getChildByName("merge_img")
	self:adaptUI(self.bgImg, mergeImg)
	local winSize = cc.Director:getInstance():getVisibleSize()
	mergeImg:setPosition(cc.p(winSize.width/2,winSize.height/2 - 40))

	local closeBtn = mergeImg:getChildByName("close_btn")
	closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
           BagMgr:hideGemMergeMain()
        end
    end)

	local neiBgImg = mergeImg:getChildByName('nei_bg_img')
	self.cellSv = neiBgImg:getChildByName('cell_sv')
	self.cellSv:setScrollBarEnabled(false)
	local size = self.cellSv:getContentSize()
	self.cellSv:setInnerContainerSize(cc.size(size.width,(MAX_GEM - 1)*(120 + diffSize) + diffSize - 2))

	self.pageBtns = {}
	for i=1,4 do
	    local btn = mergeImg:getChildByName('page_'..i..'_btn')
	    local infoTx = btn:getChildByName('info_tx')
	    infoTx:setString(GlobalApi:getLocalStr('GEM_PAGE_'..i))
	    self.pageBtns[i] = btn
	    btn:addTouchEventListener(function (sender, eventType)
	        if eventType == ccui.TouchEventType.began then
	            AudioMgr.PlayAudio(11)
	        elseif eventType == ccui.TouchEventType.ended then
	            self.page = i
	            self:updatePanel()
	        end
	    end)
	end
    self:updatePanel()
end

return GemMergeMainUI