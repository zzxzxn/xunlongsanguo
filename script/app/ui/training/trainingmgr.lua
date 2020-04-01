local ClassTrainingMainUI = require("script/app/ui/training/trainingmain")
local ClassTrainingSelectUI = require("script/app/ui/training/trainingselect")

cc.exports.TrainingMgr = {
    uiClass = {
        TrainingMainUI = nil,
        TrainingSelectUI = nil,
    }
}

setmetatable(TrainingMgr.uiClass, {__mode = "v"})

function TrainingMgr:showTrainingMain()
    if self.uiClass["TrainingMainUI"] == nil then
		local args={}
		MessageMgr:sendPost('get_train','hero',json.encode(args),
			function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["TrainingMainUI"] = ClassTrainingMainUI.new(data)
				self.uiClass["TrainingMainUI"]:showUI(UI_SHOW_TYPE.STUDIO)
			end
		end)
    end
end

function TrainingMgr:showTrainingMain2()
    if self.uiClass["TrainingMainUI"] == nil then
		local args={}
		MessageMgr:sendPost('get_train','hero',json.encode(args),
			function (response)
			
			local code = response.code
			local data = response.data
			if code == 0 then
				self.uiClass["TrainingMainUI"] = ClassTrainingMainUI.new(data)
				self.uiClass["TrainingMainUI"]:showUI(UI_SHOW_TYPE.STUDIO)
                WarCollegeMgr:showWarCollege()
			end
		end)
    end
end

function TrainingMgr:hideTrainingMain()
    if self.uiClass["TrainingMainUI"] ~= nil then
        self.uiClass["TrainingMainUI"]:ActionClose()
        self.uiClass["TrainingMainUI"] = nil
    end
end	


function TrainingMgr:showTrainingSelect(heroList)
    if self.uiClass["TrainingSelectUI"] == nil then
        self.uiClass["TrainingSelectUI"] = ClassTrainingSelectUI.new(heroList)
        self.uiClass["TrainingSelectUI"]:showUI()
    end
end

function TrainingMgr:hideTrainingSelect(callback)
    if self.uiClass["TrainingSelectUI"] ~= nil then
        self.uiClass["TrainingSelectUI"]:ActionClose(callback)
        self.uiClass["TrainingSelectUI"] = nil
    end
end

function TrainingMgr:SetTrainingSlot(hero)
	if self.uiClass["TrainingMainUI"] ~= nil then
		self.uiClass["TrainingMainUI"]:SendTrainingHero(hero)
	end
end
