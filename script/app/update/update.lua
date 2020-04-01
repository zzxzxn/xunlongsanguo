


local function enterGame()
    Game:init()
    Game:start()
    cc.UserDefault:getInstance():setStringForKey('versionid',GlobalData:getVersionData())
end

function UpdateLayer.create()
    local layer = cc.CSLoader:createNode('csb/updatepl.csb')
    local winSize = cc.Director:getInstance():getVisibleSize()
    local spine = GlobalApi:createSpineByName("login", "spine_lossless/login/login", 2)
    spine:setAnimation(0, "idle01", true)
    spine:registerSpineEventHandler(function (event)
        if math.random(100) > 50 then
            spine:setAnimation(0, "idle", true)
        else
            spine:setAnimation(0, "idle01", true)
        end
    end, sp.EventType.ANIMATION_COMPLETE)
    spine:setLocalZOrder(-1)
    spine:setPosition(cc.p(winSize.width*0.5, winSize.height*0.5))
    if 1142/770 > winSize.width/winSize.height then
        spine:setScale(winSize.height/770.01)
    else
        spine:setScale(winSize.width/1142.01)
    end
    layer:addChild(spine)

    local loadingBarBg = cc.Sprite:create("uires/ui/common/common_bar_bg_1.png")
    local size = loadingBarBg:getContentSize()
    local loadingBar = cc.ProgressTimer:create(cc.Sprite:create("uires/ui/common/common_bar_1.png"))
    local barSize = loadingBar:getContentSize()
    loadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    loadingBar:setMidpoint(cc.p(0, 0))
    loadingBar:setBarChangeRate(cc.p(1, 0))
    loadingBarBg:addChild(loadingBar)
    loadingBar:setPosition(cc.p(size.width/2, size.height/2))
    loadingBar:setPercentage(0)

    
    layer:addChild(loadingBarBg)


    local function onNodeEvent(event)
        if "enter" == event then
            onEnter()
        elseif "exit" == event then
            
        end
    end
    layer:registerScriptHandler(onNodeEvent)
    return layer
end

local function AssetsManagerExTestMain()
    local scene = cc.Scene:create()
    scene:addChild(UpdateLayer.create())
    return scene
end

function UpdateLayer.reloadModule(list)
    
end

return UpdateLayer
