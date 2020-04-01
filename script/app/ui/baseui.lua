cc.exports.BaseUI = {
	uiIndex = nil,
	uiData = nil,
	root = nil,
	_showAnimation = false,
	eventListeners = {}
}

function BaseUI:init()
	
end

function BaseUI:showUI(showType)
	UIManager:showUI(self, showType)
end

function BaseUI:hideUI(hideType)
	UIManager:hideUI(self, hideType)
end

function BaseUI:initWithNode(node, uiData)
	self.root = node
	self.uiData = uiData
	self.eventListeners = {}
	self._showAnimation = true
	self:init()
end

function BaseUI:onShow()
	
end

function BaseUI:onHide()
	
end

function BaseUI:onCover()
	
end

function BaseUI:onClose()
	self:onHide()
	for k, v in pairs(self.eventListeners) do
		self:removeCustomEventListener(k)
	end
end

function BaseUI:addCustomEventListener(key, func)
	CustomEventMgr:addEventListener(key, self, func)
	self.eventListeners[key] = 1
end

function BaseUI:removeCustomEventListener(key)
	CustomEventMgr:removeEventListener(key, self)
	self.eventListeners[key] = nil
end

function BaseUI:adaptUI(firstNode, secondNode, bigBg)
	if firstNode then
		local winSize = cc.Director:getInstance():getWinSize()
		if bigBg then
			local imgSize = firstNode:getContentSize()
			if imgSize.width/imgSize.height > winSize.width/winSize.height then
				firstNode:setScale(winSize.height/imgSize.height + 0.01)
			else
				firstNode:setScale(winSize.width/imgSize.width + 0.01)
			end
		else
			firstNode:setScale9Enabled(true)
			firstNode:setContentSize(winSize)
			if secondNode then
				secondNode:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
			end
		end
		firstNode:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
	end
end

function BaseUI:adaptCenterUI(node)
	if node then
		local winSize = cc.Director:getInstance():getWinSize()
		node:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
	end
end

function BaseUI:adaptSizeUI(node)
	if node then
		local winSize = cc.Director:getInstance():getWinSize()
		node:setContentSize(winSize)
	end
end

function BaseUI:getLocalZOrder()
	return self.root:getLocalZOrder()
end

function BaseUI:isOnTop()
	return UIManager:getTopNodeIndex() == self.uiIndex
end

function BaseUI:_onShowUIAniOver()
	self:onShowUIAniOver()
	self._showAnimation = false
	CustomEventMgr:dispatchEvent(CUSTOM_EVENT.UI_SHOW, self.uiIndex)
end

function BaseUI:onShowUIAniOver()
end