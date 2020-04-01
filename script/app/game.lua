local SCRIPT_FILES = {
	"script/app/common",
	"script/app/global/globalenum",
	"script/app/data/globaldata",
	"script/app/utils/time",
	"script/app/utils/shadermgr",
	"script/app/utils/utils",
	"script/app/utils/eventmgr",
	"script/app/utils/audiomgr",
	"script/app/global/globalapi",
	"script/app/data/gamedata",
	"script/app/data/roledata",
	"script/app/data/mapdata",
	"script/app/data/userdata",
	"script/app/data/bagdata",
	"script/app/data/displaydata",
	"script/app/data/sdkdata",
	"script/app/net/messagemgr",
	"script/app/net/socketmgr",
	"script/app/ui/baseui",
	"script/app/ui/promptmgr",
	"script/app/ui/uimanager",
	"script/app/ui/login/loginmgr",
	"script/app/ui/battle/battlemanager",
	"script/app/ui/mainscene/mainscenemgr",
	"script/app/ui/tavern/tavernmgr",
	"script/app/ui/campaign/campaignmgr",
	"script/app/ui/shippers/shippersmgr",
	"script/app/ui/role/rolemgr",
	"script/app/ui/map/mapmgr",
	"script/app/ui/bag/bagmgr",
	"script/app/ui/goldmine/goldminemgr",
	"script/app/ui/arena/arenamgr",
	"script/app/ui/tower/towermgr",
	"script/app/ui/getway/getwaymgr",
	"script/app/ui/tips/tipsmgr",
	"script/app/ui/guide/guidemgr",
	"script/app/ui/legion/legionmgr",
	"script/app/ui/worldwar/worldwarmgr",
	"script/app/ui/country/citycraft/citycraftmgr",
	"script/app/ui/country/countrywar/countrywarmgr",
	"script/app/ui/country/countrymgr",
	"script/app/ui/rankinglist/rankinglistmgr",
	"script/app/ui/guard/guardmgr",
	"script/app/ui/recharge/rechargemgr",
	"script/app/ui/setting/settingmgr",
	"script/app/ui/training/trainingmgr",
    "script/app/ui/firstweekactivity/firstweekactivitymgr",
    "script/app/ui/honorhall/honorhallmgr",
    "script/app/ui/activity/activitymgr",
    "script/app/ui/chart/chartmgr",
    "script/app/ui/country/countryjade/countryjademgr",
    "script/app/ui/warcollege/warcollegemgr",
    "script/app/yvsdk/yvsdkmgr",
    "script/app/ui/help/helpmgr",
    "script/app/ui/goldmine/digminemgr",
    "script/app/ui/legion/legiontrial/legiontrialmgr",
    --"script/app/ui/infinitebattle/infinitebattlemanager", 功能屏蔽
    "script/app/ui/friends/friendsmgr",
    "script/app/ui/territorialwars/territorialwarmgr",
    "script/app/ui/loginpopwindow/loginpopwindowmgr",
    "script/app/ui/legion/legionwish/legionwishmgr",
    "script/app/ui/territorialwars/playermap",
    "script/app/ui/chat/chatnewmgr",
    "script/app/ui/peopleking/peoplekingmgr",
    "script/app/ui/exclusive/exclusivemgr",
    "script/app/ui/mainscene/taskmgr",
}

cc.exports.Game = {}

function Game:init()
	print('...........................................')
	self:addActivitySearchPath()
	self:loadScript()
	self:extendCocos()
	ShaderMgr:init()
	self:addReloadListener()
	AudioMgr.stopAll()
	AudioMgr.Init()

    -- YVSdk
    YVSdkMgr:init()

    SdkData:init()
end

function Game:addActivitySearchPath()
	local avSearchPath = cc.FileUtils:getInstance():getWritablePath() .. "update_activity/"
	local searchPaths = cc.FileUtils:getInstance():getSearchPaths()
	local needAdd = true
	for k, path in ipairs(searchPaths) do
		if avSearchPath == path then
			needAdd = false
			break
		end
	end
	if needAdd then
		cc.FileUtils:getInstance():addSearchPath(avSearchPath, true)
		package.path = avSearchPath .. "/?.lua;" .. package.path
	end
end

function Game:extendCocos()
	if cc.EventAssetsManagerEx and cc.EventAssetsManagerEx.EventCode then
		cc.EventAssetsManagerEx.EventCode.MOVE_SCRIPT_FILES = 901
		cc.EventAssetsManagerEx.EventCode.MOVE_SCRIPT_FILES_FAILED = 902
		cc.EventAssetsManagerEx.EventCode.REMOVE_OLD_FILES_FAILED = 903
		cc.EventAssetsManagerEx.EventCode.UPDATE_WAITING = 904
		cc.EventAssetsManagerEx.EventCode.REMOVE_FAILED_FILE_FAILED = 905
	end
end

function Game:start()
	local logoScene = require("script/app/scene/logoscene").new()
	logoScene:enter()
end

function Game:exit()
end

function Game:releaseCaches()
	SpineCache:destory_s()
	local jsonMap = GlobalApi.jsonMap
	local armatureMap = GlobalApi.armatureMap
	local existJson = {}
	for armature, url in pairs(armatureMap) do
		existJson[url] = 1
	end
	for url, v in pairs(jsonMap) do
		if existJson[url] == nil then
			ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(url .. ".json")
			jsonMap[url] = nil
		end
	end
	cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
	cc.Director:getInstance():getTextureCache():removeUnusedTextures()
end

function Game:releaseUnusedCaches()
	if UIManager:getUIByIndex(GAME_UI.UI_BATTLE) == nil then
		collectgarbage("collect")
		collectgarbage("collect")
		local jsonMap = GlobalApi.jsonMap
		local armatureMap = GlobalApi.armatureMap
		local existJson = {}
		for armature, url in pairs(armatureMap) do
			existJson[url] = 1
		end
		for url, v in pairs(jsonMap) do
			if existJson[url] == nil then
				ccs.ArmatureDataManager:getInstance():removeArmatureFileInfo(url .. ".json")
				jsonMap[url] = nil
			end
		end
		cc.SpriteFrameCache:getInstance():removeUnusedSpriteFrames()
		cc.Director:getInstance():getTextureCache():removeUnusedTextures()
	end
end

function Game:loadScript()
	for file, v in pairs(package.loaded) do
		if string.sub(file, 1, 7) == "script/" then
			if package.loaded[file] then
				package.loaded[file] = nil
			end
		end
	end
	require "script/config"
	require "script/app/game"
	for k, v in ipairs(SCRIPT_FILES) do
		require(v)
	end
end

-- 临时修复0.3.0.0版本动态更新bug,下次大版本可以删除
function Game:loadScriptAgain()
	for k, v in ipairs(SCRIPT_FILES) do
		require(v)
	end
end

function Game:applicationDidEnterBackground()
	if AudioMgr then
		AudioMgr.pauseAll()
	end
	if CustomEventMgr then
		CustomEventMgr:dispatchEvent(CUSTOM_EVENT.ENTER_BACKGROUND)
	end
end

function Game:applicationWillEnterForeground()
	if AudioMgr then
		AudioMgr.resumeAll()
	end
	if CustomEventMgr then
		CustomEventMgr:dispatchEvent(CUSTOM_EVENT.ENTER_FOREGROUND)
	end
end

function Game:addReloadListener()
	local targetPlatform = CCApplication:getInstance():getTargetPlatform()
	if targetPlatform == kTargetAndroid then
        self._backToForegroundListener = cc.EventListenerCustom:create("event_renderer_recreated", function (eventCustom)
            if ShaderMgr then
				ShaderMgr:reloadCustomGLProgram()
			end
        end)
        cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(self._backToForegroundListener, -1)
    end
end

function Game:purgeAll()
	GuideMgr:forceOver()
	CustomEventMgr:purge()
	AudioMgr.stopAll()
	AudioMgr.uncacheAll()
	SocketMgr:close()
	UIManager:removeAll()
	GameData:purge()
	cc.Director:getInstance():purgeCachedData()
	local targetPlatform = CCApplication:getInstance():getTargetPlatform()
	if targetPlatform == kTargetAndroid and self._backToForegroundListener then
		cc.Director:getInstance():getEventDispatcher():removeEventListener(self._backToForegroundListener)
		self._backToForegroundListener = nil
	end
end

function Game:purgeWhenBackToLogin()
	CustomEventMgr:purge()
	AudioMgr.stopAll()
	AudioMgr.uncacheAll()
	SocketMgr:close()
	GameData:purgeActivity()
	UserData:removeAllData()
end

function Game:restartGame()
	collectgarbage("restart")
	self:init()
	self:start()
end

function Game:logoutAndRestartGame()
	CustomEventMgr:dispatchEvent(CUSTOM_EVENT.RESTART_GAME)
	Game:purgeAll()
	self:restartGame()
end