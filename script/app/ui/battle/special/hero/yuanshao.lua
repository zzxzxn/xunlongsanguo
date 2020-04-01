local BaseClass = require("script/app/ui/battle/special/hero/base")

local YuanShao = class("YuanShao", BaseClass)

function YuanShao:init()
	self.addAtkFlag = false
end

-- 所有群雄武将属性增加
function YuanShao:effectBeforeCreate(owner, army, enemy)
	if self.skill1 then
		for k, v in ipairs(army) do
			if v.heroInfo.camp == 4 then
				v.heroInfo.atk = v.heroInfo.atk + v.heroInfo.baseAtk*self.value1[1]/100
				v.heroInfo.phyDef = v.heroInfo.phyDef + v.heroInfo.basePhyDef*self.value1[1]/100
				v.heroInfo.magDef = v.heroInfo.magDef + v.heroInfo.baseMagDef*self.value1[1]/100
				-- v.heroInfo.hp = v.heroInfo.hp + v.heroInfo.baseHp*self.value1[1]/100
				v.heroInfo.hit = v.heroInfo.hit + v.heroInfo.baseHit*self.value1[1]/100
				v.heroInfo.dodge = v.heroInfo.dodge + v.heroInfo.baseDodge*self.value1[1]/100
				v.heroInfo.crit = v.heroInfo.crit + v.heroInfo.baseCrit*self.value1[1]/100
				v.heroInfo.resi = v.heroInfo.resi + v.heroInfo.baseResi*self.value1[1]/100
			end
		end
	end
end

-- 生命值高于攻击者，则受到伤害减少
function YuanShao:effectWhenGetHurt(hpNum, flag, skillType, atker)
	if self.skill2 and hpNum < 0 and not atker.isPlayerSkill and self.owner.hp > atker.hp then
		hpNum = math.floor(hpNum*(1+self.value2[1]/100))
	end
	return hpNum
end

-- 自身生命值高于一定比例时增加攻击力
function YuanShao:effectBeforeFight()
	if self.skill3 and not self.addAtkFlag and self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
		self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[2]/100
		self.addAtkFlag = true
	end
end

function YuanShao:effectWhenChangeHp()
	if self.skill3 then
		if self.owner.hp/self.owner.maxHp >= self.value3[1]/100 then
			if not self.addAtkFlag then
				self.owner.atk = self.owner.atk + self.owner.baseAtk*self.value3[2]/100
				self.addAtkFlag = true
			end
		else
			if self.addAtkFlag then
				self.owner.atk = self.owner.atk - self.owner.baseAtk*self.value3[2]/100
				self.addAtkFlag = false
			end
		end
	end
end

return YuanShao