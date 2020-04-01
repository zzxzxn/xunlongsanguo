local ArenaAwardUI = class("ArenaAwardUI", BaseUI)

function ArenaAwardUI:ctor(ntype,tx,callback)
	self.uiIndex = GAME_UI.UI_ARENA_V2_AWARD
	self.ntype = ntype
	self.tx = tx
	self.callback = callback
end

function ArenaAwardUI:init()
	local bg = self.root:getChildByName('award_bg_img')
	local node = bg:getChildByName('award_node')
	self:adaptUI(bg, node)

	node:setVisible(true)
	local bg1 = node:getChildByName('award_alpha_img')
	local node = bg1:getChildByName('middle_node')
	local titleImg = node:getChildByName('img_title_tx')
	local imgDi = node:getChildByName('img_di')
	local tx1 = imgDi:getChildByName('tx_1')
	local tx2 = imgDi:getChildByName('tx_2')
	local imgCash = imgDi:getChildByName('img_cash')
	if self.ntype == 1 then
		tx1:setString(GlobalApi:getLocalStr('ARENA_AWARD_DESC_1'))
		titleImg:loadTexture('uires/ui/text/tx_gx.png')
		imgCash:loadTexture('uires/icon/user/arena_xp.png')
	else
		tx1:setString(GlobalApi:getLocalStr('ARENA_AWARD_DESC_2'))
		titleImg:loadTexture('uires/ui/text/tx_ltsj.png')
		imgCash:loadTexture('uires/icon/user/arena.png')
	end
	titleImg:ignoreContentAdaptWithSize(true)
	imgCash:ignoreContentAdaptWithSize(true)
	tx2:setString(self.tx)
	local okBtn = node:getChildByName('ok_btn')
	local infoTx = okBtn:getChildByName('text')
	infoTx:setString(GlobalApi:getLocalStr('STR_OK2'))
	okBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
        	ArenaMgr:hideArenaAward()
        	if self.callback then
        		self.callback()
        	end
        end
    end)
end

return ArenaAwardUI
