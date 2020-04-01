local BattleCountDownUI = class("BattleCountDownUI", BaseUI)

function BattleCountDownUI:ctor(battleType, customObj, callback)
    self.uiIndex = GAME_UI.UI_BATTLE_COUNT_DOWN
    self.battleType = battleType
    self.customObj = customObj
    self.callback = callback
    self.countDownTime = 3
    self.schedulerEntryId = 0
end

function BattleCountDownUI:init()
    local bg_img = self.root:getChildByName("bg_img")
    self:adaptUI(bg_img)
    local winSize = cc.Director:getInstance():getWinSize()

    local overFlag = false
    BattleMgr:calculateReport(self.battleType, self.customObj, function (reportField, sig)
        self.reportField = reportField
        self.sig = sig
        if overFlag then
            BattleMgr:hideBattleCountDown()
            self.callback(self.reportField, self.sig)
        else
            overFlag = true
        end
    end)

    self.root:registerScriptHandler(function (event)
        if event == "exit" then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
        end
    end)

    local label = cc.LabelBMFont:create()
    label:setFntFile("uires/ui/number/font1_yellownum.fnt")
    label:setString("3")
    label:setScale(2)
    bg_img:addChild(label)
    label:setPosition(cc.p(winSize.width/2, winSize.height/2))
    self.schedulerEntryId = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function (dt)
        self.countDownTime = self.countDownTime - 1
        label:setString(tostring(self.countDownTime))
        if self.countDownTime <= 0 then
            if self.schedulerEntryId > 0 then
                cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.schedulerEntryId)
                self.schedulerEntryId = 0
            end
            if overFlag then
                BattleMgr:hideBattleCountDown()
                self.callback(self.reportField, self.sig)
            else
                overFlag = true
            end
        end
    end, 1, false)
end

return BattleCountDownUI