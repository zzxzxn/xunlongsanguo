local TerritorialWarRuleBook = class("TerritorialWarRuleBook", BaseUI)

local TITLE_TEXTURE_NOR = {
    'uires/ui/common/title_btn_nor_2.png',
    'uires/ui/common/title_btn_nor_2.png',
    'uires/ui/common/title_btn_nor_2.png',
}
local TITLE_TEXTURE_SEL = {
    'uires/ui/common/title_btn_sel_2.png',
    'uires/ui/common/title_btn_sel_2.png',
    'uires/ui/common/title_btn_sel_2.png',
}

local res = "uires/ui/territorialwars/book/book_"
function TerritorialWarRuleBook:ctor()
	self.uiIndex = GAME_UI.UI_WORLD_MAP_RULE_BOOK
end

function TerritorialWarRuleBook:init()

	self.richText = {}
	self.bookRule = {}
	self.maxItemNum = 0

	local dfBookCfg = GameData:getConfData('dfhandbookpicture')
	for k,v in pairs(dfBookCfg) do
		local booktype = v.type
		if not self.bookRule[booktype] then
			self.bookRule[booktype] = {}
			self.bookRule[booktype][#self.bookRule[booktype]+1] = v 
		else
			self.bookRule[booktype][#self.bookRule[booktype]+1] = v 
		end
	end

    local function bookSort(a, b)
        return tonumber(a.id) < tonumber(b.id)
    end

    for booktype, v in pairs(self.bookRule) do
        table.sort(self.bookRule[booktype], bookSort)
    end

	local dfBookTextCfg = GameData:getConfData('dfhandbooktext')
	local alphaBg = self.root:getChildByName("alpha_img")
	local outBg = alphaBg:getChildByName("out_bg")
	self:adaptUI(alphaBg, outBg)
    local bg = outBg:getChildByName("bg_img")

	self.pageBtns = {}
    for i=1,3 do
        local btn = outBg:getChildByName("title_btn_" .. i)
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:chooseWin(i)
            end
        end) 
        local infoTx = btn:getChildByName("info_tx")
        self.pageBtns[i] = {}
        self.pageBtns[i].btn = btn
        self.pageBtns[i].infoTx = infoTx        
        self.pageBtns[i].infoTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT" .. (46+i-1)))
    end

 	local innerBg = bg:getChildByName("inner_bg")
 	self.itemSv =  innerBg:getChildByName("item_sv")
 	self.itemSv:setScrollBarEnabled(false)

 	self.ruleTxBg = innerBg:getChildByName("ruletx_bg")
 	local titleTx = self.ruleTxBg:getChildByName("title_tx")
 	titleTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT49"))
 	local svBg = self.ruleTxBg:getChildByName("sv_bg")
 	local textSv = svBg:getChildByName("text_sv")
 	textSv:setScrollBarEnabled(false)

 	local svSize = textSv:getContentSize()

 	local str = string.gsub(dfBookTextCfg[1].desc, "<line>", "\n")
    local richText = xx.RichText:create()
    richText:setContentSize(cc.size(svSize.width, 480))
    richText:setAnchorPoint(cc.p(0,1))
    richText:setAlignment('left')
    textSv:addChild(richText)

    local re1 = xx.RichTextLabel:create('\n',23, COLOR_TYPE.PALE)
	re1:setFont('font/gamefont.ttf')
	richText:addElement(re1)
	xx.Utils:Get():analyzeHTMLTag(richText,str)
    richText:format(true)
    
    local labelheight = richText:getBrushY()
    if labelheight > svSize.height then
    	textSv:setInnerContainerSize(cc.size(svSize.width,labelheight))
    end
    richText:setPosition(cc.p(0,textSv:getInnerContainerSize().height - 10))--]]
    --按钮事件
    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:closeRuleBookUI()
        end
    end) 

    self:chooseWin(1)
end

function TerritorialWarRuleBook:chooseWin(id)
	for i=1,3 do
        if i == id then
            self.pageBtns[i].btn:loadTexture(TITLE_TEXTURE_SEL[i])
            self.pageBtns[i].btn:setTouchEnabled(false)
            self.pageBtns[i].infoTx:setColor(COLOR_TYPE.PALE)
            self.pageBtns[i].infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            self.pageBtns[i].infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.pageBtns[i].btn:loadTexture(TITLE_TEXTURE_NOR[i])
            self.pageBtns[i].btn:setTouchEnabled(true)
            self.pageBtns[i].infoTx:setColor(COLOR_TYPE.DARK)
            self.pageBtns[i].infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            self.pageBtns[i].infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end 

    if id == 1 then
    	self.itemSv:setVisible(false)
    	self.ruleTxBg:setVisible(true)
    else
    	self.itemSv:setVisible(true)
    	self.ruleTxBg:setVisible(false)
    	self:updateRuleBook(id-1)
    end

end

function TerritorialWarRuleBook:updateRuleBook(bookType)

	if bookType < 1 or bookType > 2 then
		bookType = 1
	end

	local bookInfo = self.bookRule[bookType]
    local size1
   	local count = math.ceil(#bookInfo/2)
   	if self.maxItemNum < count then
    	self.maxItemNum = count
    end
    for i=count+1,self.maxItemNum do
    	local cell = self.itemSv:getChildByTag(i + 100)
    	if cell then
            cell:setVisible(false)
        end
    end

    for i=1,count do
        local cell = self.itemSv:getChildByTag(i + 100)
        local cellBg
        if not cell then
            local cellNode = cc.CSLoader:createNode('csb/territorialwar_bookItem.csb')
            cellBg = cellNode:getChildByName('item_bg')
            cellBg:removeFromParent(false)
            cell = ccui.Widget:create()
            cell:addChild(cellBg)
            self.itemSv:addChild(cell,1,i+100)
        else
            cellBg = cell:getChildByName('item_bg')
        end
        cell:setVisible(true)
        size1 = cellBg:getContentSize()

        for j=1,2 do
        	local id = (i-1)*2+j
        	local item = cellBg:getChildByName("item_" .. j)
        	local showItem = false
        	item:setVisible(false)
        	if bookInfo[id]  then
        		item:setVisible(true)
	        	local icon = item:getChildByName("icon")
	        	icon:loadTexture(res .. bookInfo[id].icon)
	        	local nameTx = item:getChildByName("name")
	        	nameTx:setString(bookInfo[id].name)
	        	local descBg = item:getChildByName("desc_bg")
	        	local descTx = descBg:getChildByName("text")
	        	descTx:setString("")
	        	if not self.richText[i] then
	        		self.richText[i] = {}
	        	end
                if not self.richText[i][j]  then
                	local richText = xx.RichText:create()
	                richText:setContentSize(cc.size(240, 70))
	                richText:setAnchorPoint(cc.p(0,1))
	                richText:setPosition(cc.p(0,15))
	                richText:setAlignment('left')
	                richText:setVerticalAlignment('middle')
	                descTx:addChild(richText)
	                self.richText[i][j] = richText
	            else
	            	self.richText[i][j]:clear()
                end
                local str = string.gsub(bookInfo[id].desc, "<line>", "\n")
	            xx.Utils:Get():analyzeHTMLTag(self.richText[i][j],str)
	            self.richText[i][j]:format(true)
	        else
	        	item:setVisible(false)
	        end
        end

    end

    if not size1 then
        self.itemSv:setVisible(false)
        return
    end

    local size = self.itemSv:getContentSize()
    if count * size1.height > size.height then
        self.itemSv:setInnerContainerSize(cc.size(size.width,(count * size1.height)))
    else
        self.itemSv:setInnerContainerSize(size)
    end

    local function getPos(i)
        local size2 = self.itemSv:getInnerContainerSize()     
        return cc.p(1,size2.height - size1.height* i+70)
    end
    for i=1,count do
        local cell = self.itemSv:getChildByTag(i + 100)
        if cell then
            cell:setPosition(getPos(i))
        end
    end
end

return TerritorialWarRuleBook