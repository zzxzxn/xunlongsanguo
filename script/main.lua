--[[
				   _ooOoo_
				  o8888888o
				  88" . "88
				  (| -_- |)
				  O\  =  /O
			   ____/`---'\____
			 .'  \\|     |//  `.
		    /  \\|||  :  |||//  \
		   /  _||||| -:- |||||-  \
		   |   | \\\  -  /// |   |
		   | \_|  ''\---/''  |   |
		   \  .-\__  `-`  ___/-. /
		 ___`. .'  /--.--\  `. . __
	  ."" '<  `.___\_<|>_/___.'  >'"".
	 | | :  `- \`.;`\ _ /`;.`/ - ` : | |
	 \  \ `-.   \_ __\ /__ _/   .-` /  /
======`-.____`-.___\_____/___.-`____.-'======
				   `=---='
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
		 佛祖保佑!       永无BUG!
]]
     
require "socket"
require "script/config"
require "cocos/init"
require "script/app/game"

cc.exports.printall = function(t)
	if type(t) ~= 'table' then
		print(t)
	else
		for k,v in pairs(t) do
			if type(v) == 'table' then
				print(k .. ':')
				printall(v)
			else
				print(k, v)
			end
		end
	end
end

cc.exports.requireOnce = function (file)
	local obj = require(file)
	package.loaded[file] = nil
	return obj
end

local lastErrMsg = ""

function __G__TRACKBACK__(msg)
	local errMsg = msg .. "\n" .. debug.traceback()
	if lastErrMsg ~= errMsg then
		lastErrMsg = errMsg
		local args = {
			msg = errMsg
		}
		SocketMgr:send("error", "user", args)
	end
	local str = ""
	if MessageMgr and CCApplication:getInstance():getTargetPlatform() ~= kTargetWindows then
		str = MessageMgr.fuckServerForceToAddThisMsg
	end
	release_print("----------------------------------------")
	release_print("LUA ERROR: " .. errMsg .. "\n")
	release_print(str .. "\n")
	release_print("----------------------------------------")
end

local function main()
	if jit then
		jit.off()
	end
	math.randomseed(os.time())
	collectgarbage("setpause", 100)
	collectgarbage("setstepmul", 5000)
	--require("script/app/update/update")
	cc.Director:getInstance():setAnimationInterval(1/60)
	--cc.Director:getInstance():setDisplayStats(true)
	cc.Texture2D:setDefaultAlphaPixelFormat(cc.TEXTURE2_D_PIXEL_FORMAT_AUTO)
	cc.Director:getInstance():setProjection(cc.DIRECTOR_PROJECTION_2D)
	-- cc.Director:getInstance():setDepthTest(true)
	-- cc.Director:getInstance():setAlphaBlending(true)
	cc.Device:setKeepScreenOn(true)
	Game:init()
	Game:start()
end

xpcall(main, __G__TRACKBACK__)