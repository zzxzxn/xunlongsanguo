cc.exports.UserData = {
	verify = 0
}

function UserData:initWithData(jsonData)
	self.verify = jsonData.data.verify
	GlobalApi:initConfuseStr()
	self.userObj = require("script/app/obj/userobj")
	self.userObj:initUserStatus(jsonData.data.status,jsonData.data.first_login)
    self.userObj:initCountryJade(jsonData.data.country_jade,jsonData.data.country_jade_time)
	self.userObj:initUserInfo(jsonData.data.info)
	self.userObj:initUserTavern(jsonData.data.tavern)
    self.userObj:initUserIdentity(jsonData.data.identity)
	self.userObj:initUserResCopy(jsonData.data.rescopy)
	RoleData:initWithData(jsonData.data.pos) -- 初始化槽位相关
	RoleData:initDragon(jsonData.data.dragon) -- 初始化君主技能相关
	BagData:parseBagData(jsonData.data.bag) -- 最后初始化背包，因为部分道具会先发到背包里然后再装备到对应的位置上
	UserData:getUserObj():addGlobalTime()
	self.userObj:setEquipValume(jsonData.data.equip_valume)
	self.userObj:setDragonGemValume(jsonData.data.dragongem_valume)
	self.userObj:setMineDuration(jsonData.data.mine_duration)
    self.userObj:setMineId(jsonData.data.mine_id)
	self.userObj:initUserMail(jsonData.data)
	self.userObj:setTreasure(jsonData.data.treasure)
	self.userObj:setSkills(jsonData.data.skills)
	--self.userObj:setDragonInfo(jsonData.data.dragon)
	self.userObj:initShipper(jsonData.data.shipper)
	self.userObj:initAltar(jsonData.data.altar)
	self.userObj:initSign(jsonData.data.sign)
    self.userObj:initTask(jsonData.data.task)
	self.userObj:setLegion(jsonData.data.lid, jsonData.data.lname, jsonData.data.llevel,jsonData.data.lgold_tree,jsonData.data.lduty,jsonData.data.ltype,jsonData.data.wish)
	self.userObj:initJadeSeal(jsonData.data.jade_seal)
	self.userObj:initJadeSealHero(jsonData.data.jade_seal_hero)
	self.userObj:initPayment(jsonData.data.payment)
	self.userObj:initMark(jsonData.data.mark)
	self.userObj:initMake(jsonData.data.make)
	self.userObj:initTower(jsonData.data.tower)
	self.userObj:initTrain(jsonData.data.train)
	self.userObj:setServerOpenTime(jsonData.data.server_open_time)
	self.userObj:setWorldWarOpenTime(jsonData.data.worldwar_open_time)
	self.userObj:setActivityInfo(jsonData.data.activity,jsonData.data.grow_fund_count,jsonData.data.avconf)
	self.userObj:setTipsInfo(jsonData.data.tips)
	self.userObj:setLegionInfo(jsonData.data.legion)
	self.userObj:initGuard(jsonData.data.guard)
	self.userObj:initWorldWar(jsonData.data.worldwar)
	self.userObj:initArenaInfo(jsonData.data.arena)
	self.userObj:initCountryInfo(jsonData.data.country)
	self.userObj:initWarCollege(jsonData.data.war_college)
    self.userObj:setTerritorialWar(jsonData.data.territory_war)
	--self.userObj:setInfinite(jsonData.data.unlimited) -- 功能屏蔽
    self.userObj:setFriendsysInfo(jsonData.data.friendsys_info)
    self.userObj:initConspiracy(jsonData.data.conspiracy)
    self.userObj:setPromoteWheel(jsonData.data.promote_wheel)
    self.userObj:setOpenCDKeyStatus(jsonData.data.cdkey)
    self.userObj:setResBackSign(jsonData.data.hasresback)
    self.userObj:initGuide(jsonData.data.guide)		--玩法指引数据
    self.userObj:initPeopleKing(jsonData.data.sky_suit)
	MapData:initWithData(jsonData.data.battle)
	RoleData:init()
    self.userObj:addGlobalTime()
    self.userObj:setSocketMailStatus(false)
end

function UserData:addAttrData(datas)
	self.userObj:addAttrData(datas)
end

function UserData:getUserObj()
	return self.userObj
end

function UserData:removeAllData()
	if self.userObj then
		BagData:removeAllData()
		RoleData:removeAllData()
		MapData:removeAllData()
		self.userObj = nil
	end
end

function UserData:isVerify()
	return self.verify == 1
end