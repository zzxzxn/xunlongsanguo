local ClassGuideBase = require("script/app/ui/guide/guidebase")
local GuideTalk = class("GuideTalk", ClassGuideBase)

function GuideTalk:ctor(guideNode, guideObj)
    self.guideObj = guideObj
    self.guideNode = guideNode
end

function GuideTalk:startGuide()
    local winSize = cc.Director:getInstance():getWinSize()

    local guideObj = self.guideObj
    local conf = GameData:getConfData("local/guidetext")[guideObj.text]
    local node = cc.Node:create()

    --获取第一个送的英雄
    local reward = GameData:getConfData('specialreward')['guide_guanyu'].reward
    local npcId = tonumber(reward[1][2])
    local npcConf = GameData:getConfData('hero')[npcId]
    local npc = nil
    local npcName = nil

    npc = GlobalApi:createLittleLossyAniByName("guide_npc_"..guideObj.npc)
    if guideObj.npc == 1 then
        npcName = cc.Label:createWithTTF("我", "font/gamefont.ttf", 24)
    else
        npcName = cc.Label:createWithTTF(npcConf["heroName"], "font/gamefont.ttf", 20)
    end
    npc:getAnimation():play("idle", -1, -1)
    npc:setAnchorPoint(cc.p(0.5, 0))
    local npcSize = npc:getContentSize()

    --npc名字
    local nameBg = cc.Sprite:create("uires/ui/yindao/yindao_6.png")
    npcName:setTextColor(cc.c4b(107,20,133, 255))
    nameBg:addChild(npcName, 99)
    npc:addChild(nameBg, 99)

    if not guideObj.npcscalex or guideObj.npcscalex and guideObj.npcscalex ~= -1 then
        -- npc:setScaleX(-1)
        -- npcName:setScaleX(-1)
    end

    --对话框底
    local dialog = ccui.ImageView:create("uires/ui/yindao/yindao_1.png")
    dialog:ignoreContentAdaptWithSize(false)
    local dialogSize = cc.size(winSize.width, dialog:getContentSize().height)
    dialog:setContentSize(dialogSize)
    dialog:setVisible(false)
    dialog:setAnchorPoint(cc.p(0.5, 0))
    dialog:setPosition(cc.p(winSize.width/2, 0))
    node:addChild(dialog)

    --对话框里文字
    local contentLable = GlobalApi:createFaceString(conf.text, 0, 0, 20, nil, true, cc.size(winSize.width - npcSize.width, 100))
    dialog:addChild(contentLable)

    -- 提示文字
    local label2 = cc.Label:createWithTTF(GlobalApi:getLocalStr("CLICK_ANY_POS_CONTINUE"), "font/gamefont.ttf", 18)
    label2:setTextColor(cc.c4b(144,238,144, 255))
    label2:setPosition(cc.p(dialogSize.width/2, 20))
    label2:enableOutline(COLOROUTLINE_TYPE.BLACK,1)
    dialog:addChild(label2)
    label2:runAction(cc.RepeatForever:create(cc.Sequence:create(cc.DelayTime:create(0.5), cc.FadeOut:create(1.0), cc.FadeIn:create(1.0))))
    
    node:addChild(npc)

    local startPos
    local scaleX = 1
    self.audioId = -1
    local function showTalk()
        self.clickFlag = false
        dialog:setVisible(true)
        if conf.soundRes ~= "0" then
            self.audioId = AudioMgr.playEffect("media/guide/" .. conf.soundRes, false)
        end
    end

    --是主角就在左边
    if guideObj.npc == 1 then
        startPos = cc.p(npcSize.width / 2 - 20, 0)
        npc:setPosition(startPos)
        nameBg:setPosition(cc.p(0, 10))
        npcName:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)

        contentLable:setContentSize(cc.size(winSize.width - npcSize.width + 20, dialogSize.height - 40))
        contentLable:setAnchorPoint(cc.p(0, 0))
        contentLable:setPosition(cc.p(npcSize.width - 40, 20))
    else   --非主角在右边
        startPos = cc.p(winSize.width - npcSize.width / 2 + 40, 0)
        npc:setPosition(startPos)
        nameBg:setPosition(cc.p(0, 10))
        npcName:setPosition(nameBg:getContentSize().width/2, nameBg:getContentSize().height/2)
        
        contentLable:setContentSize(cc.size(winSize.width - npcSize.width + 20, dialogSize.height - 40))
        contentLable:setAnchorPoint(cc.p(0, 0))
        contentLable:setPosition(cc.p(20, 20))
    end
    npc:setScaleX(scaleX)
    npcName:setScaleX(scaleX)

    self.guideNode:addChild(node)
    self.dialog = dialog
    self.npc = npc
    self.mainNode = node
    self.startPos = startPos
    showTalk()
end

function GuideTalk:onClickScreen()
    if not self.clickFlag then
        self.clickFlag = true
        self.dialog:setVisible(false)
        if self.audioId ~= -1 then
            AudioMgr.stopEffect(self.audioId)
        end
        self.mainNode:removeFromParent()
        self:finish()
        if self.guideObj.finish == "msg" then
            local obj = {
                request = "guide_guanyu"
            }
            MessageMgr:sendPost("mark_guide", "user", json.encode(obj),function (jsonObj)
                if jsonObj.code == 0 then
                    GlobalApi:parseAwardData(jsonObj.data.awards)
                    TavernMgr:showTavernAnimate(jsonObj.data.awards, function ()
                        TavernMgr:hideTavernAnimate()
                    end, 4)
                end
            end)
        end
    end
end

return GuideTalk