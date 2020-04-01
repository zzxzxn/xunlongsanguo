local CampaignBasePanel = require("script/app/ui/campaign/campaignbasepanel")
local CampaignRescopyPanel = class("CampaignRescopyPanel", CampaignBasePanel)

local MAX_NUM = 4
local MAX_LENGTH = 200
local LEFT_NUM = 1
local RIGHT_NUM = 1
local stypes = {'rebornRescopy','xpRescopy','goldRescopy','destinyRescopy'}
function CampaignRescopyPanel:ctor(pos, showByClick)
    local winsize = cc.Director:getInstance():getWinSize()
    self.root = cc.CSLoader:createNode('csb/campaignrescopypanel.csb')
    local infoImg = self.root:getChildByName("info_img")
    infoImg:setPosition(cc.p(0, 90 - winsize.height/2))
    self.infoLabel1 = infoImg:getChildByName("info_tx1")
    self.infoLabel2 = infoImg:getChildByName("info_tx2")
    self.infoLabel3 = infoImg:getChildByName("info_tx3")
    self.rescopyListConf = GameData:getConfData("rescplist")
    self.imgs = {}
    local addition = UserData:getUserObj():getJadeSealAddition("rescopy")
    local pl = self.root:getChildByName("panel")
    for i = 1,MAX_NUM do
        local flag = pl:getChildByName("flag_" .. i)
        local nameTx = flag:getChildByName('name_tx')
        local lvTx = flag:getChildByName('lv_tx')
        local newImg = flag:getChildByName('new_img')
        local desc = GlobalApi:getGotoByModule(stypes[i],true)
        if desc then
            lvTx:setString(desc..GlobalApi:getLocalStr("STR_POSCANTOPEN_1"))
        end
        self.imgs[i] = flag
        nameTx:setString(self.rescopyListConf[i].name)
        newImg:setVisible(UserData:getUserObj():getSignByType(stypes[i]))

        local addition_img = flag:getChildByName("addition_img")
        addition_img:setTouchEnabled(true)
        addition_img:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                local additionPos = flag:convertToWorldSpace(cc.p(addition_img:getPosition()))
                TipsMgr:showJadeSealAdditionTips(additionPos, "rescopy")
            end
        end)
        local addition_tx = addition_img:getChildByName("addition_tx")
        addition_tx:setString(addition[2] .. "%")
        if not addition[1] then
            ShaderMgr:setGrayForWidget(addition_img)
            addition_tx:enableOutline(COLOROUTLINE_TYPE.GRAY1, 1)
        end
    end
    GlobalApi:setCardRunRound(pl,self.imgs,pos or 1,1,2,200,true,3,{1,0.85,0.7},function(i)
        self:changeRescopy(i, true)
    end,nil,function()
        self:enterCampaign()
    end)
    self:changeRescopy(pos, false)
end

function CampaignRescopyPanel:getExtraInfos()
    local info = UserData:getUserObj():getRescopyinfo()
    local count = 0
    local buy = 0
    if self.currIndex == 3 then
        count = info.gold.count
        buy = info.gold.buy
        self.infoLabel2:setString(tostring(info.gold.damage))
    elseif self.currIndex == 2 then
        count = info.xp.count
        buy = info.xp.buy
        self.infoLabel2:setString(tostring(info.xp.kill))
    elseif self.currIndex == 1 then
        count = info.reborn.count
        buy = info.reborn.buy
        self.infoLabel2:setString(tostring(info.reborn.time))
    elseif self.currIndex == 4 then
        count = info.destiny.count
        buy = info.destiny.buy
        self.infoLabel2:setString(tostring(info.destiny.round))
    end
    local extraInfos = {GlobalApi:getLocalStr("STR_COPY_TIMES") .. self.rescopyListConf[self.currIndex].limit - count + buy .. "/" .. self.rescopyListConf[self.currIndex].limit}
    return extraInfos
end

function CampaignRescopyPanel:enterCampaign()
    local info = UserData:getUserObj():getRescopyinfo()
    local difficulty = 1
    local vip = UserData:getUserObj():getVip()
    local vipConf = GameData:getConfData("vip")
    local rescopyCount = vipConf[tostring(vip)].rescopyCount
    if self.currIndex == 3 then
        if self.rescopyListConf[self.currIndex].limit - info.gold.count + info.gold.buy <= 0 then
            if info.gold.buy < rescopyCount then
                self:onClickAddBtn()
                return
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("REMAIN_TIMES_NOT_ENOUGH"), COLOR_TYPE.RED)
                return
            end
        end
        difficulty = info.gold.difficulty
    elseif self.currIndex == 2 then
        if self.rescopyListConf[self.currIndex].limit - info.xp.count + info.xp.buy  <= 0 then
            if info.xp.buy < rescopyCount then
                self:onClickAddBtn()
                return
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("REMAIN_TIMES_NOT_ENOUGH"), COLOR_TYPE.RED)
                return
            end
        end
        difficulty = info.xp.difficulty
    elseif self.currIndex == 1 then
        if self.rescopyListConf[self.currIndex].limit - info.reborn.count + info.reborn.buy  <= 0 then
            if info.reborn.buy < rescopyCount then
                self:onClickAddBtn()
                return
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("REMAIN_TIMES_NOT_ENOUGH"), COLOR_TYPE.RED)
                return
            end
        end
        difficulty = info.reborn.difficulty
    elseif self.currIndex == 4 then
        if self.rescopyListConf[self.currIndex].limit - info.destiny.count + info.destiny.buy  <= 0 then
            if info.destiny.buy < rescopyCount then
                self:onClickAddBtn()
                return
            else
                promptmgr:showSystenHint(GlobalApi:getLocalStr("REMAIN_TIMES_NOT_ENOUGH"), COLOR_TYPE.RED)
                return
            end
        end
        difficulty = info.destiny.difficulty
    end
    local desc,isOpen = GlobalApi:getGotoByModule(stypes[self.currIndex],true)
    if desc then
        promptmgr:showSystenHint(desc..GlobalApi:getLocalStr("STR_POSCANTOPEN_1"), COLOR_TYPE.RED)
        return
    end
    CampaignMgr:showRescopyDifficulty(self.currIndex, difficulty)
end

function CampaignRescopyPanel:updatePanel()
    local pl = self.root:getChildByName("panel")
    for i = 1, MAX_NUM do
        local flag = pl:getChildByName("flag_" .. i)
        local newImg = flag:getChildByName('new_img')
        newImg:setVisible(UserData:getUserObj():getSignByType(stypes[i]))
    end
end

function CampaignRescopyPanel:changeRescopy(index, flag)
    self.currIndex = index
    self.infoLabel3:setString(self.rescopyListConf[index].desc)
    self.infoLabel1:setString(self.rescopyListConf[index].desc3)
    if flag then
        CampaignMgr:updateExtraInfo()
    end
end

function CampaignRescopyPanel:getDesc()
    return self.rescopyListConf[self.currIndex].intro
end

function CampaignRescopyPanel:isShowAddBtn()
    return true
end

function CampaignRescopyPanel:onClickAddBtn()
    local buyTimes = 0
    local vip = UserData:getUserObj():getVip()
    local vipConf = GameData:getConfData("vip")
    local rescopyCount = vipConf[tostring(vip)].rescopyCount
    local info = UserData:getUserObj():getRescopyinfo()
    local count = 0
    if self.currIndex == 3 then
        count = info.gold.count
        buyTimes = info.gold.buy
    elseif self.currIndex == 2 then
        count = info.xp.count
        buyTimes = info.xp.buy
    elseif self.currIndex == 1 then
        count = info.reborn.count
        buyTimes = info.reborn.buy
    elseif self.currIndex == 4 then
        count = info.destiny.count
        buyTimes = info.destiny.buy
    end
    if count <= buyTimes then -- 次数满的，不用买
        promptmgr:showSystenHint(GlobalApi:getLocalStr("NO_NEED_BUY_TIMES_1"), COLOR_TYPE.RED)
    elseif buyTimes >= rescopyCount then -- 次数已满
        if vipConf[tostring(vip+1)] == nil then -- vip已经达到最大值
            promptmgr:showSystenHint(GlobalApi:getLocalStr("BUY_TIMES_OVER"), COLOR_TYPE.RED)
        else
            local i = 1
            local flag = false
            while vipConf[tostring(vip+i)] do
                if vipConf[tostring(vip+i)].rescopyCount > buyTimes then
                    flag = true
                    promptmgr:showSystenHint(string.format(GlobalApi:getLocalStr("VIP_LOW_CANNOT_BUY"), vip+i), COLOR_TYPE.RED)
                    break
                end
                i = i + 1
            end
            if not flag then
                promptmgr:showSystenHint(GlobalApi:getLocalStr("BUY_TIMES_OVER"), COLOR_TYPE.RED)
            end
        end
    else
        local cash = UserData:getUserObj():getCash()
        local buyConf = GameData:getConfData("buy")
        local needCash = buyConf[buyTimes+1].rescopyCount
        if cash < needCash then
            promptmgr:showSystenHint(GlobalApi:getLocalStr("NOT_ENOUGH_CASH"), COLOR_TYPE.RED)
        else
            promptmgr:showMessageBox(string.format(GlobalApi:getLocalStr("BUY_TIMES_CASH"), needCash), MESSAGE_BOX_TYPE.MB_OK_CANCEL, function ()
                local args = {
                    type = self.rescopyListConf[self.currIndex].type
                }
                MessageMgr:sendPost("buy_count", "rescopy", json.encode(args), function (response)
                    if response.code == 0 then
                        local info = UserData:getUserObj():getRescopyinfo()
                        local infoType = self.rescopyListConf[self.currIndex].type
                        info[infoType].buy = info[infoType].buy + 1
                        if response.data.costs then
                            GlobalApi:parseAwardData(response.data.costs)
                        end
                        promptmgr:showSystenHint(GlobalApi:getLocalStr("SUCCESS_BUY"), COLOR_TYPE.GREEN)
                        CampaignMgr:updateCampaignMain()
                    end
                end)
            end)
        end
    end
end

return CampaignRescopyPanel