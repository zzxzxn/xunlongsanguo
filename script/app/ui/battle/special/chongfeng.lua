local ChongFeng = {}

function ChongFeng:afterPlaySkillAnimation(skill)
	skill.owner:dispelBuff(1)
	skill.owner.ignoreControl = skill.owner.ignoreControl + 1
	if skill.owner.limitMove > 0 then
		skill:skip()
		skill.owner:movementComplete(skill:getActionName())
	else
		local targets = skill.targets
		if #targets > 0 then
			local target = targets[1]
			local posx, posy = target:getPosition()
			local x, y = skill.owner:getPosition()
			local dis = cc.pGetDistance(cc.p(posx, posy), cc.p(x, y))
			if dis > target.bodySize then
				if x < posx then -- 如果目标在我右边就冲锋到他的左边
					posx = posx - target.bodySize
				else
					posx = posx + target.bodySize
				end
			end
			skill.owner:moveToBySkill(1, cc.p(posx, posy), 5, function ()
				if not target.legionObj:isDead() then
					local targeLegion = target.legionObj
					local legion = skill.owner.legionObj
					legion:setTarget(targeLegion)
					if not target:isDead() then
						skill.owner:onLock(target, false)
					end
				end
				skill:effect()
				skill:finished()
				skill.owner:movementComplete(skill:getActionName())
			end)
		else
			skill:skip()
			skill.owner:movementComplete(skill:getActionName())
		end
	end
end

function ChongFeng:afterSkillFinish(skill)
	skill.owner.ignoreControl = skill.owner.ignoreControl - 1
end

return ChongFeng