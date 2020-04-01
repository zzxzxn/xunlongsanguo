local ChongZhuang = {}

function ChongZhuang:afterPlaySkillAnimation(skill)
	skill.owner:dispelBuff(1)
	skill.owner.ignoreControl = skill.owner.ignoreControl + 1
	if skill.owner.limitMove > 0 then
		skill:skip()
		skill.owner:movementComplete(skill:getActionName())
	else
		skill:effect()
		local x, y = skill.owner:getPosition()
		local dir = skill.owner:getDirection()
		local targetX = x + 400*dir
		skill.owner:moveToBySkill(2, cc.p(targetX, y), 1, function ()
			if not skill.owner:isDead() then
				local flag = skill.owner:moveToBySkill(2, cc.p(x, y), 1, function ()
					skill:finished()
					skill.owner:movementComplete(skill:getActionName())
				end)
				if not flag then
					skill:finished()
					skill.owner:movementComplete(skill:getActionName())
				end
			end
		end)
	end
end

function ChongZhuang:afterSkillFinish(skill)
	skill.owner.ignoreControl = skill.owner.ignoreControl - 1
	skill.owner:removeBuffById(skill.baseInfo.ownerBuffId)
end

return ChongZhuang