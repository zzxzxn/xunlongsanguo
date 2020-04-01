local ClassBattleUI = require("script/app/ui/battle/battleui/battleui")
local BattleWarCollegeUI = class("BattleWarCollegeUI", ClassBattleUI)

function BattleWarCollegeUI:onShowUIAniOver()
    if not self.customObj.replay and self.customObj.lessonId > 0 then
        WarCollegeMgr:startLesson(self.customObj.lessonId, self.root)
    end
end

function BattleWarCollegeUI:updatePlayerSkillPoint()
end

function BattleWarCollegeUI:sendMessageAfterFight(isWin)
    local starNum = isWin and 3 or 0
    local args = {
        star = starNum,
        challenge = self.customObj.challenge
    }
    MessageMgr:sendPost("war_college_challenge", "warcollege", json.encode(args), function (jsonObj)
        local code = jsonObj.code
        if code == 0 then
            if not self.customObj.replay and isWin then
                UserData:getUserObj():addWarCollegeChallenge()
            end
            GlobalApi:parseAwardData(jsonObj.data.awards)
            if jsonObj.data.costs then
                GlobalApi:parseAwardData(jsonObj.data.costs)
            end
            local displayAwards = DisplayData:getDisplayObjs(jsonObj.data.awards)
            BattleMgr:showBattleResult(isWin, displayAwards, starNum)
        else
            promptmgr:showMessageBox(GlobalApi:getLocalStr("STR_BATTLE_ERROR"), MESSAGE_BOX_TYPE.MB_OK, function ()
                BattleMgr:exitBattleField()
            end)
        end
    end)
end

return BattleWarCollegeUI