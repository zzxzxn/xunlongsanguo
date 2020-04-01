local ActivityThreeYuanBuyUI = class("ActivityThreeYuanBuyUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
-- 现在改成18元购
function ActivityThreeYuanBuyUI:ctor(data)
	self.uiIndex = GAME_UI.UI_ACTIVITY_THREE_YUAN_BUY
    self.data = data
    UserData:getUserObj().activity.money_buy2 = self.data.money_buy2
end

function ActivityThreeYuanBuyUI:init()
    local bgimg1 = self.root:getChildByName("bg_img")
    local bgimg2 = bgimg1:getChildByName('bg_img_1')
    local img = bgimg2:getChildByName('img')

    local closebtn = bgimg2:getChildByName('close_btn')
    closebtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            UserData:getUserObj().activity.money_buy2 = self.data.money_buy2
            MainSceneMgr:hideThreeYuanBuyUI()
        end
    end)
    self.closebtn = closebtn
    self.bgimg2 = bgimg2
    self:adaptUI(bgimg1, bgimg2)
    

    -- 描述
    local richText = xx.RichText:create()
	richText:setContentSize(cc.size(480, 40))

	local re1 = xx.RichTextLabel:create("    "..GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES30'), 18, cc.c4b(254,227,134,255))
	re1:setStroke(cc.c4b(140,56,0,255),1)
    re1:setFont('font/gamefont.ttf')

	local re2 = xx.RichTextLabel:create("\n".."    "..GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES23'), 18, COLOR_TYPE.RED)
	--re2:setStroke(cc.c4b(140,56,0,255),1)
    re2:setFont('font/gamefont.ttf')

    local re3 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES24'), 18, cc.c4b(254,227,134,255))
	re3:setStroke(cc.c4b(140,56,0,255),1)
    re3:setFont('font/gamefont.ttf')

	richText:addElement(re1)
	richText:addElement(re2)
    richText:addElement(re3)

    richText:setAlignment('left')
    richText:setVerticalAlignment('middle')

	richText:setAnchorPoint(cc.p(0,0.5))
	richText:setPosition(cc.p(290,430))
    self.bgimg2:addChild(richText)
    richText:format(true)

    -- 
    local buyBtn = self.bgimg2:getChildByName('buy_btn')
    buyBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            local rechageData = GameData:getConfData('recharge')
            if not rechageData[10] then
                return
            end
            if self.data.money_buy2.status == 0 then -- 充值
                self.buyBtn:setTouchEnabled(false)
                self.buyBtn:setBright(false)
                --self.closebtn:setTouchEnabled(false)
                local function callBack(obj)
                    if obj.code == 0 then
                        self.data.money_buy2.status = 1
                        self:refreshBtnStatus()
                        --self.closebtn:setTouchEnabled(true)
                    else
                        self.buyBtn:setTouchEnabled(true)
                        self.buyBtn:setBright(true)
                        --self.closebtn:setTouchEnabled(true)
                    end
                end
                RechargeMgr:specialRecharge(10,callBack)
                self.buyBtn:runAction(cc.Sequence:create(cc.DelayTime:create(10),cc.CallFunc:create(function()
					self.buyBtn:setTouchEnabled(true)
                    self.buyBtn:setBright(true)
                    --self.closebtn:setTouchEnabled(true)
                end)))

                RechargeMgr:pay(rechageData[10], function (code)
                    self:buyCallback(code)
                end)
            end
        end
    end)
    self.buyBtn = buyBtn
    self.buyBtnTx = buyBtn:getChildByName('tx')

    --
    local _,time = ActivityMgr:getActivityTime("three_money_buy")
    if time > 0 then
        local time_desc = bgimg2:getChildByName('time_desc')
        time_desc:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES29'))

        local node = cc.Node:create()
        node:setPosition(cc.p(time_desc:getPositionX() + 50,time_desc:getPositionY()))
        bgimg2:addChild(node)
        local str = string.format(GlobalApi:getLocalStr('REMAINDER_TIME3'),math.floor(time / (24 * 3600)))
        Utils:createCDLabel(node,time % (24 * 3600),COLOR_TYPE.WHITE,COLOR_TYPE.RED,CDTXTYPE.FRONT,str,COLOR_TYPE.WHITE,COLOR_TYPE.RED,22,nil,nil,nil)
    end


    local avOneYuanBuyConf = GameData:getConfData("avthreeyuanbuy")
    -- 创建普通的奖励
    local awardData = avOneYuanBuyConf[1].awards
    local num = #awardData

    local disPlayData = DisplayData:getDisplayObjs(awardData)
    for i = 1,#awardData do      
        self:createItemCell(i,disPlayData[i])
    end

    -- 创建月卡用户奖励
    local awardData2 = avOneYuanBuyConf[1].award1
    local disPlayData2 = DisplayData:getDisplayObjs(awardData2)

    for i = num+1,#awardData2 + num do
        self:createItemCell(i,disPlayData2[i - num],"y")
    end
    num = #awardData2 + num
    -- 创建最高额外奖励
    local awardData3 = avOneYuanBuyConf[1].award2
    local disPlayData3 = DisplayData:getDisplayObjs(awardData3)

    for i = num+1,#awardData3 + num do
        self:createItemCell(i,disPlayData3[i - num],"z")
    end
    -- local name1 = ''
    -- local name2 = ''
    -- local num1 = 0
    -- local num2 = 0
    -- for i = 1,#avOneYuanBuyConf do
    --     local i = tonumber(i)
    --     local icon = self.bgimg2:getChildByName("icon_" .. i)

    --     local awardData = avOneYuanBuyConf[i]
    --     local disPlayData = DisplayData:getDisplayObj(awardData)
    --     local awards = disPlayData
    --     if i == 1 then
    --         name1 = awards:getName()
    --         num1 = awards:getNum()
    --     else
    --         name2 = awards:getName()
    --         num2 = awards:getNum()
    --     end
    --     local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
    --     cell.awardBgImg:setPosition(cc.p(94/2,94/2))
    --     local godId = awards:getGodId()
    --     awards:setLightEffect(cell.awardBgImg)

    --     local effect = GlobalApi:createLittleLossyAniByName('god_light')
    --     effect:setPosition(cc.p(94/2,94/2))
    --     effect:getAnimation():playWithIndex(0, -1, 1)
    --     effect:setName('god_light')
    --     effect:setScale(1.25)
    --     cell.awardBgImg:addChild(effect)

    --     -- 名字
    --     local richTextName = xx.RichText:create()
	   --  richTextName:setContentSize(cc.size(510, 40))

    --     local color = COLOR_TYPE.RED
    --     if i == 1 then
    --         color = COLOR_TYPE.BLUE
    --     elseif i == 2 then
    --         color = COLOR_TYPE.GREEN
    --     elseif i == 3 then
    --         color = COLOR_TYPE.RED
    --     else
    --         color = COLOR_TYPE.YELLOW
    --     end

    --     local heroconf = GameData:getConfData('hero') 
    --     local cardData = heroconf[awards:getId()]

	   --  local re1 = xx.RichTextLabel:create(awards:getName(), 20, awards:getNameColor())
    --     re1:setFont('font/gamefont.ttf')

	   --  --local re2 = xx.RichTextLabel:create(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES3'), 20, COLOR_TYPE.ORANGE)
    --     --re2:setFont('font/gamefont.ttf')

	   --  richTextName:addElement(re1)
	   --  --richTextName:addElement(re2)

    --     richTextName:setAlignment('middle')
    --     richTextName:setVerticalAlignment('middle')

	   --  richTextName:setAnchorPoint(cc.p(0.5,0.5))
	   --  richTextName:setPosition(cc.p(icon:getContentSize().width/2,-22))
    --     icon:addChild(richTextName)
    --     richTextName:format(true)


    self.getBtns = {}
    for i = 1,1 do
        local getBtn = bgimg2:getChildByName('get_btn_' .. i)
        getBtn:getChildByName('tx'):setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES9'))
        table.insert(self.getBtns,getBtn)
        getBtn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                if self.data.money_buy2.status == 1 then -- 领取
                    local function callBack()
                        local args = {
                            id = i
                        }
                        MessageMgr:sendPost('get_money_buy2_reward','activity',json.encode(args),function (jsonObj)
                        -- print(json.encode(jsonObj))
                            if jsonObj.code == 0 then
                                local awards = jsonObj.data.awards
                                if awards then
                                    GlobalApi:parseAwardData(awards)
                                    GlobalApi:showAwardsCommon(awards,nil,nil,true) 
                                end
                                local costs = jsonObj.data.costs
                                if costs then
                                    GlobalApi:parseAwardData(costs)
                                end
                                self.data.money_buy2.status = 2
                                self:refreshBtnStatus()
                            elseif jsonObj.code == 100 then
                                promptmgr:showSystenHint(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES12'),COLOR_TYPE.RED)
                            end
                        end)
                    end
                    local name = name1
                    local num = num1
                    if i == 2 then
                        name = name2
                        num = num2
                    end
                    -- promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES25'),name .. ' * ' .. num), MESSAGE_BOX_TYPE.MB_OK_CANCEL,function()
                        callBack()
                    -- end)

                end
            end
        end)
    end
    
    -- local btn = HelpMgr:getBtn(27)
    -- btn:setScale(0.9)
    -- btn:setPosition(cc.p(60 ,455))
    -- bgimg2:addChild(btn)

    self:refreshBtnStatus()


    CustomEventMgr:addEventListener("get_recharge_raward",self,function (code) 
        self:buyCallback(code)
    end)
    
    local function onNodeEvent(event)
        if "exit" == event then
            CustomEventMgr:removeEventListener("get_recharge_raward",self)
        end
    end

    self.root:registerScriptHandler(onNodeEvent)

end


function ActivityThreeYuanBuyUI:createItemCell(i,data,symbol)
        local i = tonumber(i)
        local icon = self.bgimg2:getChildByName("icon_" .. i)
        icon:setVisible(true)

        local tag = icon:getChildByName("tag_img_1")
        local text = tag:getChildByName("tag_tx_1")
        tag:setLocalZOrder(10)
        tag:setVisible(true)
        local str = ""
        if symbol == "y" then
            text:setString("月卡")
        elseif symbol == "z" then
            text:setString("终身卡")
        else
            tag:setVisible(false)
        end

        local awards = data

        local cell = ClassItemCell:create(ITEM_CELL_TYPE.ITEM, awards, icon)
        cell.awardBgImg:setPosition(cc.p(94/2, 94/2))
        local godId = awards:getGodId()
        awards:setLightEffect(cell.awardBgImg)

        -- 加上duang的特效
        local effect = GlobalApi:createLittleLossyAniByName('god_light')
        effect:setPosition(cc.p(94/2,94/2))
        effect:getAnimation():playWithIndex(0, -1, 1)
        effect:setName('god_light')
        effect:setScale(1.25)
        cell.awardBgImg:addChild(effect)

        -- 名字
        local richTextName = xx.RichText:create()
        richTextName:setContentSize(cc.size(510, 40))

        local color = COLOR_TYPE.RED
        if i == 1 then
            color = COLOR_TYPE.BLUE
        elseif i == 2 then
            color = COLOR_TYPE.GREEN
        elseif i == 3 then
            color = COLOR_TYPE.RED
        else
            color = COLOR_TYPE.YELLOW
        end

        local re1 = xx.RichTextLabel:create(awards:getName(), 20, COLOR_TYPE.ORANGE)
        re1:setFont('font/gamefont.ttf')

        richTextName:addElement(re1)
        richTextName:setAlignment('middle')
        richTextName:setVerticalAlignment('middle')

        richTextName:setAnchorPoint(cc.p(0.5,0.5))
        richTextName:setPosition(cc.p(icon:getContentSize().width/2,-22))
        icon:addChild(richTextName)
        richTextName:format(true)
end

function ActivityThreeYuanBuyUI:buyCallback(code)
    if code == 1 then -- sdk购买成功
        self.data.money_buy2.status = 1
        self:refreshBtnStatus()
        --self.closebtn:setTouchEnabled(true)
    else  -- sdk购买失败
        self.buyBtn:setTouchEnabled(true)
        self.buyBtn:setBright(true)
        --self.closebtn:setTouchEnabled(true)
    end

    self:refreshBtnStatus()
end

-- 刷新按钮状态
function ActivityThreeYuanBuyUI:refreshBtnStatus()

    self.getBtns[1]:setVisible(false)
    if self.data.money_buy2.status == 0 then -- 待充值
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(true)
        self.buyBtn:setTouchEnabled(true)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES14'))
    elseif self.data.money_buy2.status == 1 then -- 待领取
        self.buyBtn:setVisible(false)
        self.getBtns[1]:setVisible(true)
    elseif self.data.money_buy2.status == 2 then -- 已领取
        self.buyBtn:setVisible(true)
        self.buyBtn:setBright(false)
        self.buyBtn:setTouchEnabled(false)
        self.buyBtnTx:setString(GlobalApi:getLocalStr('ACTIVITY_ONE_YUAN_DES10'))
    end
end

return ActivityThreeYuanBuyUI