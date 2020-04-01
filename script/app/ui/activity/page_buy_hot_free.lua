local BuyHotFree = class("buy_hot_free")
local ClassItemCell = require('script/app/global/itemcell')

function BuyHotFree:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self.msg = msg
	UserData:getUserObj().activity.buy_hot_free = self.msg.buy_hot_free
	ActivityMgr:showRightBuyHotFreeRemainTime()
    self:updateMark()
	self:update()
	ActivityMgr:showLefTavernRecruitCue()
end

function BuyHotFree:updateMark()
    if UserData:getUserObj():getSignByType('buy_hot_free') then
		ActivityMgr:showMark("buy_hot_free", true)
	else
		ActivityMgr:showMark("buy_hot_free", false)
	end
end

function BuyHotFree:update()
	local bg = self.rootBG:getChildByName('bg')
	local trvernIcon = bg:getChildByName('trvern_icon')

    if self.msg.buy_hot_free.id and self.msg.buy_hot_free.id > 0 then
        local tavernHotConf = GameData:getConfData("tavernhot")[self.msg.buy_hot_free.id]
        if tavernHotConf.icon then
            trvernIcon:loadTexture('uires/icon/tavern/' .. tavernHotConf.icon .. '.png')
        end
    end

	local rightBg = bg:getChildByName('right_bg')
	local des1 = rightBg:getChildByName('desc1')
	des1:setString(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES1'))
	local des2 = rightBg:getChildByName('desc2')
	des2:setString(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES2'))

	local buyHotCount = tonumber(GlobalApi:getGlobalValue('buyHotCount'))
	local buyHotVip = tonumber(GlobalApi:getGlobalValue('buyHotVip'))

	local remainCount = buyHotCount - self.msg.buy_hot_free.buy_count
	if remainCount <= 0 then
		remainCount = 0 
	end

	local count = rightBg:getChildByName('count')
	count:setString(remainCount)

	local cash = rightBg:getChildByName('cash')
	cash:setString(self.msg.buy_hot_free.cash)
	local cashImg = rightBg:getChildByName('cash_img')
	cashImg:setPositionX(cash:getPositionX() + cash:getContentSize().width + 2)

	local gotoBtn = bg:getChildByName('goto_btn')
    gotoBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES3'))
    gotoBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if remainCount > 0 then
				TavernMgr:showTavernLimitUI2()
				ActivityMgr:hideUI()
			else
				promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES4'), COLOR_TYPE.RED)
			end
        end
    end)

	local awardBtn = rightBg:getChildByName('award_btn')
	local awardBtnTx = awardBtn:getChildByName('tx')
	if UserData:getUserObj():getVip() < buyHotVip then
		awardBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES6'))
	else
		awardBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES5'))
	end

    awardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            if UserData:getUserObj():getVip() < buyHotVip then
				RechargeMgr:showRecharge()
				ActivityMgr:hideUI()
			else
				if self.msg.buy_hot_free.cash > 0 then
					MessageMgr:sendPost("get_buy_hot_free_reward", "activity", json.encode(args), function (response)
						local code = response.code
						if code == 0 then
							local awards = response.data.awards
							if awards then
								GlobalApi:parseAwardData(awards)
								GlobalApi:showAwardsCommon(awards,nil,nil,true)
							end
							local costs = response.data.costs
							if costs then
								GlobalApi:parseAwardData(costs)
							end
							self.msg.buy_hot_free.cash = 0
							self:update()
						end
					end)
				else
					if remainCount <= 0 then
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES4'), COLOR_TYPE.RED)
					else
						promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_BUY_HOT_FREE_DES7'), COLOR_TYPE.RED)
					end
				end
			end
			
        end
    end)


end

return BuyHotFree