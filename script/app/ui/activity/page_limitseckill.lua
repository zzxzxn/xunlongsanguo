local LimitSeckill = class("LimitSeckill")

function LimitSeckill:init(msg)
    self.rootBG = self.root:getChildByName("root")

    self:initTop()

    self:updateMark()
end

function LimitSeckill:updateMark()
    if UserData:getUserObj():getSignByType('limit_seckill') then
		ActivityMgr:showMark("limit_seckill", true)
	else
		ActivityMgr:showMark("limit_seckill", false)
	end
end

function LimitSeckill:initTop()
    ActivityMgr:showRightLimitSeckillRemainTime()
end

return LimitSeckill