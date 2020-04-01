local LegionWishWeekAwardPanelUI = class("LegionWishWeekAwardPanelUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
local YILINGQU  = 'uires/ui/activity/yilingq.png'
local WEIDACHENG= 'uires/ui/activity/weidac.png'

function LegionWishWeekAwardPanelUI:ctor(data)
	self.uiIndex = GAME_UI.UI_LEGION_WISH_WEEK_AWARD
    self.legionWishaAhievementConf = GameData:getConfData('legionwishachievement')
    self.data = data
    self.award = self.data.wish_reward
    self.wish_progress = self.data.wish_progress

    if not self.award[tostring(2)] then
        self.award[tostring(2)] = 0
    end
    if not self.award[tostring(3)] then
        self.award[tostring(3)] = 0
    end

    if not self.wish_progress[tostring(2)] then
        self.wish_progress[tostring(2)] = 0
    end
    if not self.wish_progress[tostring(3)] then
        self.wish_progress[tostring(3)] = 0
    end

    UserData:getUserObj():getLegionInfo().wish.wish_progress = self.wish_progress
    UserData:getUserObj():getLegionInfo().wish.wish_reward = self.award
end

function LegionWishWeekAwardPanelUI:init()
    local bgBigImg = self.root:getChildByName("bg_img")
    local bgImg = bgBigImg:getChildByName('bg_img1')
    local bgImg2 = bgImg:getChildByName('bg_img2')
    self:adaptUI(bgBigImg, bgImg)

    local closebtn = bgImg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            LegionWishMgr:hideLegionWishWeekAwardPanelUI()
        end
    end)

    local titleBg = bgImg2:getChildByName('title_bg')
    local titleTx = titleBg:getChildByName('title_tx')
    titleTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC21'))

    local descTx = bgImg2:getChildByName('desc_tx')
    descTx:setString(GlobalApi:getLocalStr('LEGION_WISH_DESC22'))

    for i = 1,2 do
        local bgImg = bgImg2:getChildByName('cell_' .. i)
        local confData = self.legionWishaAhievementConf[i + 1]
        bgImg.confData = confData
        self:updateCell(i,bgImg)
    end
end

function LegionWishWeekAwardPanelUI:updateCell(i,bgImg)
    local confData = bgImg.confData
    local progress = self.wish_progress[tostring(i + 1)]
    local award = self.award

    local tab = {}
    for k,v in pairs(confData) do
        if type(v) == 'table' then
            table.insert(tab,v)
        end
    end

    table.sort(tab, function (a, b)
		return a.level < b.level
	end)

    local data = tab[#tab]
    local judge = false
    for j = 1,#tab do
        if (award[tostring(i + 1)] + 1) == tonumber(tab[j].level) then
            data = tab[j]
            judge = true
            break
        end
    end

    local titleImg = bgImg:getChildByName('title_img')
    local titleTx = titleImg:getChildByName('title_tx')
    titleTx:setString(data.name)

    local descTx = bgImg:getChildByName('desc_tx')
    descTx:setString(data.desc)

    -- 进度
    local infoTx = bgImg:getChildByName('info_tx')
    infoTx:setString(string.format(GlobalApi:getLocalStr('ACTIVITY_DAILY_RECHARGE_DES1'),progress > data.target and data.target or progress,data.target))

    local awards = DisplayData:getDisplayObjs(data.award)
	for i=1,2 do
		local awardBgImg = bgImg:getChildByName('award_'..i..'_img')
		if not awardBgImg then
			local tab = ClassItemCell:create()
			awardBgImg = tab.awardBgImg
			awardBgImg:setScale(0.8)
			awardBgImg:setName('award_'..i..'_img')
			bgImg:addChild(awardBgImg)
			awardBgImg:setPosition(cc.p(70 + 90*(i - 1),135))
		end
		local awardImg = awardBgImg:getChildByName('award_img')
		local numTx = awardBgImg:getChildByName('lv_tx')
		if awards[i] then
			awardBgImg:loadTexture(awards[i]:getBgImg())
			awardBgImg:setVisible(true)
			awardImg:loadTexture(awards[i]:getIcon())
			awardImg:ignoreContentAdaptWithSize(true)
			numTx:setString('x'..awards[i]:getNum())
			awardBgImg:addTouchEventListener(function (sender, eventType)
				if eventType == ccui.TouchEventType.began then
			        AudioMgr.PlayAudio(11)
			    elseif eventType == ccui.TouchEventType.ended then
					GetWayMgr:showGetwayUI(awards[i],false)
				end
			end)
		else
			awardBgImg:setVisible(false)
		end
	end

    -- 状态
    local getBtn = bgImg:getChildByName('get_btn')
	getBtn:getChildByName('info_tx'):setString(GlobalApi:getLocalStr('STR_GET_1'))
    local stage = bgImg:getChildByName('stage')
    getBtn:addTouchEventListener(function (sender, eventType)
		if eventType == ccui.TouchEventType.began then
			AudioMgr.PlayAudio(11)
		elseif eventType == ccui.TouchEventType.ended then
            local args = {id = i + 1}
            MessageMgr:sendPost('get_wish_awards','legion',json.encode(args),function (response)
                local code = response.code
		        local data = response.data
		        if code == 0 then
                    self.award[tostring(i + 1)] = self.award[tostring(i + 1)] + 1
                    local awards = data.awards
                    if awards then
                        GlobalApi:parseAwardData(awards)
                        GlobalApi:showAwardsCommon(awards,nil,nil,true)
                    end
                    UserData:getUserObj():getLegionInfo().wish.wish_reward = self.award
                    self:updateCell(i,bgImg)
                else
                    LegionWishMgr:popWindowErrorCode(code)
		        end
	        end)
		end
	end)

    if judge == true then
        if progress >= data.target then -- 达成
            getBtn:setVisible(true)
            stage:setVisible(false)
        else
            getBtn:setVisible(false)
            stage:setVisible(true)
            stage:loadTexture(WEIDACHENG)
        end
    else    -- 已经领取
        getBtn:setVisible(false)
        stage:setVisible(true)
        stage:loadTexture(YILINGQU)
    end
end

return LegionWishWeekAwardPanelUI