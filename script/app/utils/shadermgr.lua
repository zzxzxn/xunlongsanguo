cc.exports.ShaderMgr = {}

local targetPlatform = CCApplication:getInstance():getTargetPlatform()

local function loadCommonShader(name, fsh)
	local vshFile = "shaders/default.vsh"
	local vshFile_MVP = "shaders/default_mvp.vsh"
	local fshFile = "shaders/" .. fsh

	local program = cc.GLProgramCache:getInstance():getGLProgram(name)
	if program == nil then
		program = cc.GLProgram:create(vshFile, fshFile)
		program:link()
		program:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(program, name)
	end

	local program_mvp = cc.GLProgramCache:getInstance():getGLProgram(name .. "_mvp")
	if program_mvp == nil then
		program_mvp = cc.GLProgram:create(vshFile_MVP, fshFile)
		program_mvp:link()
		program_mvp:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(program_mvp, name .. "_mvp")
	end
end

local function reloadCommonShader(name, fsh)
	local vshFile = "shaders/default.vsh"
	local vshFile_MVP = "shaders/default_mvp.vsh"
	local fshFile = "shaders/" .. fsh

	local p = cc.GLProgramCache:getInstance():getGLProgram(name)
	if p then
		p:reset()
		p:initWithFilenames(vshFile, fshFile)
		p:link()
		p:updateUniforms()
	end

	local mvp = cc.GLProgramCache:getInstance():getGLProgram(name .. "_mvp")
	if mvp then
		mvp:reset()
		mvp:initWithFilenames(vshFile_MVP, fshFile)
		mvp:link()
		mvp:updateUniforms()
	end
end

local function loadSpineShader(shaderName)
	local fileName = "shaders/" .. shaderName .. ".fsh"
	local fileUtiles = cc.FileUtils:getInstance()
	local fragSource = fileUtiles:getStringFromFile(fileName)
	local fileName2 = "shaders/default_mvp.vsh"
	local vertSource = fileUtiles:getStringFromFile(fileName2)

	local glProgam = cc.GLProgramCache:getInstance():getGLProgram(shaderName .. "_spine")
	if glProgam == nil then
		glProgam = cc.GLProgram:createWithByteArrays(vertSource, fragSource)
		glProgam:link()
		glProgam:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(glProgam, shaderName .. "_spine")
	end
end

local function reloadSpineShader(shaderName)
	local fileUtiles = cc.FileUtils:getInstance()
	local fileName = "shaders/" .. shaderName .. ".fsh"
	local fileName2 = "shaders/default_mvp.vsh"
	local fragSource = fileUtiles:getStringFromFile(fileName)
	local vertSource = fileUtiles:getStringFromFile(fileName2)
	local p = cc.GLProgramCache:getInstance():getGLProgram(shaderName .. "_spine")
	if p then
		p:reset()
		p:initWithByteArrays(vertSource, fragSource)
		p:link()
		p:updateUniforms()
	end
end

local function loadETCShader(shaderName, fsh)
	local vshFile = "shaders/default_etc.vsh"
	local vshFile_MVP = "shaders/default_etc_mvp.vsh"
	local fshFile = "shaders/" .. fsh .. "_etc.fsh"

	local program = cc.GLProgramCache:getInstance():getGLProgram(shaderName .. "_etc")
	if program == nil then
		program = cc.GLProgram:create(vshFile, fshFile)
		program:link()
		program:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(program, shaderName .. "_etc")
	end
	local program2 = cc.GLProgramCache:getInstance():getGLProgram(shaderName .. "_etc_mvp")
	if program2 == nil then
		program2 = cc.GLProgram:create(vshFile_MVP, fshFile)
		program2:link()
		program2:updateUniforms()
		cc.GLProgramCache:getInstance():addGLProgram(program2, shaderName .. "_etc_mvp")
	end
end

local function reloadETCShader(shaderName, fsh)
	local vshFile = "shaders/default_etc.vsh"
	local vshFile_MVP = "shaders/default_etc_mvp.vsh"
	local fshFile = "shaders/" .. fsh .. "_etc.fsh"

	local p = cc.GLProgramCache:getInstance():getGLProgram(shaderName .. "_etc")
	if p then
		p:reset()
		p:initWithFilenames(vshFile, fshFile)
		p:link()
		p:updateUniforms()
	end

	local mvp = cc.GLProgramCache:getInstance():getGLProgram(shaderName .. "_etc_mvp")
	if mvp then
		mvp:reset()
		mvp:initWithFilenames(vshFile_MVP, fshFile)
		mvp:link()
		mvp:updateUniforms()
	end
end

local function restoreDefaultShader(node)
	if node == nil then
		return
	end
	if tolua.type(node) == "ccui.Scale9Sprite" then
		node:setState(0)
	else
		local p = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
		if p == nil then
			return
		end
		node:setGLProgram(p)
	end
end

function ShaderMgr:init()
	-- 加载所有shader
	--loadSpineShader("stone")
	--loadCommonShader("black","black.fsh")
	--loadCommonShader("glow","glow.fsh")
	--loadCommonShader("OutlineShader", "outline.fsh")
	--loadCommonShader("BlurShader2D", "blur2D.fsh")
	--loadCommonShader("MultiTexShader", "mutiTex.fsh")
	--loadCommonShader("BlackAndOutlineShader", "blackandoutline.fsh")
	--loadCommonShader("lightnessColorShader", "lightnessColor.fsh")
	--loadCommonShader('Bling', 'blingbling.fsh')
	--loadLightnessShader()
	--loadSpineShader("default")
	loadCommonShader("GrayShader", "gray.fsh")
	if CCApplication:getInstance():getTargetPlatform() == kTargetAndroid then
		loadETCShader("default", "default")
		loadETCShader("GrayShader", "gray")
	end
end

function ShaderMgr:reloadCustomGLProgram()
	reloadCommonShader("GrayShader", "gray.fsh")
	if CCApplication:getInstance():getTargetPlatform() == kTargetAndroid then
		reloadETCShader("default", "default")
		reloadETCShader("GrayShader", "gray")
	end
end

-- ↓↓↓↓↓↓↓↓↓↓变灰↓↓↓↓↓↓↓↓↓↓
local function enableGrayShader(node)
	if tolua.type(node) == "ccui.Scale9Sprite" then
		node:setState(1)
		return
	else
		local p = cc.GLProgramCache:getInstance():getGLProgram("GrayShader")
		if p == nil then
			return
		end
		node:setGLProgram(p)
	end
end

function ShaderMgr:setGrayForWidget(widget)
	local render = widget:getVirtualRenderer()
	enableGrayShader(render)
end

function ShaderMgr:setGrayForSprite(node)
	enableGrayShader(node)
end

function ShaderMgr:setGrayForArmature(armature)
	-- if cc.Application:getInstance():getTargetPlatform() == kTargetAndroid then
	-- 	xx.Utils:Get():setShaderForArmature(armature, "GrayShader_etc")
	-- else
		xx.Utils:Get():setShaderForArmature(armature, "GrayShader")
	-- end
end
-- ↑↑↑↑↑↑↑↑↑↑变灰↑↑↑↑↑↑↑↑↑↑

-- ↓↓↓↓↓↓↓↓↓↓恢复默认↓↓↓↓↓↓↓↓↓↓
function ShaderMgr:restoreWidgetDefaultShader(widget)
	local render = widget:getVirtualRenderer()
	restoreDefaultShader(render)
end

function ShaderMgr:restoreSpriteDefaultShader(node)
	restoreDefaultShader(node)
end

function ShaderMgr:restoreSpineDefaultShader(node)
	local glprogramstate = cc.GLProgramState:getOrCreateWithGLProgramName("default_spine")
	node:setGLProgramState(glprogramstate)
end

function ShaderMgr:restoreArmatureDefaultShader(armature)
	-- if targetPlatform == kTargetAndroid then
	-- 	xx.Utils:Get():setShaderForArmature(armature, "default_etc")
	-- else
		xx.Utils:Get():setShaderForArmature(armature, "ShaderPositionTextureColor_noMVP")
	-- end
end
-- ↑↑↑↑↑↑↑↑↑↑恢复默认↑↑↑↑↑↑↑↑↑↑

function ShaderMgr:setShaderForSprite(sprite, name)
	-- local p = cc.GLProgramCache:getInstance():getGLProgram(name)
	-- if p == nil then
	-- 	return
	-- end
	-- sprite:setGLProgram(p)
end

function ShaderMgr:setShaderForArmature(armature, name)
	-- xx.Utils:Get():setShaderForArmature(armature, name)
end

function ShaderMgr:setShaderForSpine(spine, name)
	-- local p = cc.GLProgramCache:getInstance():getGLProgram(name)
	-- spine:setGLProgram(p)
end