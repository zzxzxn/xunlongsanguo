local ClassWarCollegeUI = require("script/app/ui/warcollege/warcollegeui")

cc.exports.WarCollegeMgr = {
    uiClass = {
        warCollegeUI = nil,
    },
    report = nil
}

setmetatable(WarCollegeMgr.uiClass, {__mode = "v"})

function WarCollegeMgr:showWarCollege(isFromTrain)
    if self.uiClass["warCollegeUI"] == nil then
        self.uiClass["warCollegeUI"] = ClassWarCollegeUI.new(isFromTrain)
        self.uiClass["warCollegeUI"]:showUI()
    end
end

function WarCollegeMgr:hideWarCollege()
    if self.uiClass["warCollegeUI"] ~= nil then
        self.uiClass["warCollegeUI"]:hideUI()
        self.uiClass["warCollegeUI"] = nil
    end
end

function WarCollegeMgr:startLesson(lessonId, rootNode)
    local winSize = cc.Director:getInstance():getWinSize()
    local alphaBg = ccui.ImageView:create("uires/ui/common/bg1_alpha.png")
    alphaBg:setLocalZOrder(9999)
    alphaBg:setScale9Enabled(true)
    alphaBg:setContentSize(winSize)
    alphaBg:setPosition(cc.p(winSize.width/2, winSize.height/2))
    alphaBg:setTouchEnabled(true)
    alphaBg:addClickEventListener(function ()
        if self.currLesson then
            self.currLesson:onClick()
        end
    end)
    rootNode:addChild(alphaBg)
    self.alphaBg = alphaBg
    self.step = 0
    self.lessonObj = require("data/warcollege/lesson_" .. lessonId)
    if self.lessonObj then
        self:nextStep()
    end
end

function WarCollegeMgr:nextStep()
    self.currLesson = nil
    self.alphaBg:removeAllChildren()
    self.alphaBg:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.CallFunc:create(function ()
        self.step = self.step + 1
        if self.lessonObj[self.step] then
            if self.lessonObj[self.step].name == "talk" then
                self.currLesson = require("script/app/ui/warcollege/talklesson")
                self.currLesson:startLesson(self.lessonObj[self.step], self.alphaBg)
            elseif self.lessonObj[self.step].name == "ui" then
                self.currLesson = require("script/app/ui/warcollege/uilesson")
                self.currLesson:startLesson(self.lessonObj[self.step], self.alphaBg)
            end
        else
            self:finishLesson()
        end
    end)))
end

function WarCollegeMgr:finishLesson()
    self.alphaBg:removeFromParent()
    self.alphaBg = nil
    self.step = nil
    self.lessonObj = nil
    self.currLesson = nil
end