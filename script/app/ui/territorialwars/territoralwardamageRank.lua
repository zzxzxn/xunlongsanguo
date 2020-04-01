local TerritoralwarDamageRankUI = class("TerritoralwarDamageRankUI", BaseUI)

local TITLE_TEXTURE_NOR = {
    'uires/ui/common/title_btn_nor_2.png',
    'uires/ui/common/title_btn_nor_2.png',
}
local TITLE_TEXTURE_SEL = {
    'uires/ui/common/title_btn_sel_2.png',
    'uires/ui/common/title_btn_sel_2.png',
}

local rankImgUrl = "uires/ui/report/report_rank_"
local legionIconUrl = "uires/ui/legion/legion_"
function TerritoralwarDamageRankUI:ctor(myRankInfo,legionRankInfo,playerRankInfo)

    self.uiIndex = GAME_UI.UI_WORLD_MAP_DAMAGE_RANK

    self.myRankInfo = myRankInfo                                --自己的排位信息
    self.legionRankInfo = {}                                    --军团排行榜信息
    for k,v in pairs(legionRankInfo) do
        self.legionRankInfo[tonumber(k)+1] = v
    end

    self.playerRankInfo = {}                                    --个人排行榜信息
    for k,v in pairs(playerRankInfo) do
        self.playerRankInfo[#self.playerRankInfo+1] = v
    end

end

function TerritoralwarDamageRankUI:init()

    local alphaBg = self.root:getChildByName("alpha_img")
    local bg = alphaBg:getChildByName("bg_img") 
    self:adaptUI(alphaBg, bg)

    self.pageBtns = {}
    for i=1,2 do
        local btn = bg:getChildByName("title_btn_" .. i)
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self:chooseWin(i)
            end
        end) 
        local infoTx = btn:getChildByName("info_tx")
        self.pageBtns[i] = {}
        self.pageBtns[i].btn = btn
        self.pageBtns[i].infoTx = infoTx        
        self.pageBtns[i].infoTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT" .. (27+i-1)))
    end

    --内容界面
    self.damageRank = {}
    local innerBgImg = bg:getChildByName("inner_bg")
    for i=1,2 do
        local damageRank = innerBgImg:getChildByName("damage_rank_" .. i)
        self.damageRank[i] = damageRank
    end
    
    --初始化个人排行
    self:initPlayerDamageRank()

    --初始化军团排行
    self:initLegionDamageRank()

    --按钮事件
    local closeBtn = bg:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:closeDamageRankUI()
        end
    end) 

    self:chooseWin(1)
end

--个人排行
function TerritoralwarDamageRankUI:initPlayerDamageRank()

    --无军团上榜
    local noneBg = self.damageRank[1]:getChildByName("no_img")

    --排行列表
    self.rankSv = self.damageRank[1]:getChildByName("rank_sv")
    self.rankSv:setScrollBarEnabled(false)
    
    --自己的排行信息
    local myrankBg = self.damageRank[1]:getChildByName("myrank_bg")
    local rankNum = myrankBg:getChildByName("ranking_num")
    local rankImg = myrankBg:getChildByName("ranking_img")
    local norank = myrankBg:getChildByName("no_ranking")
    local showRankImg,showNorank,showRankNum = false,false,false
    if self.myRankInfo.rank == 0 then
        showNorank = true
        norank:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_INF17"))
    elseif self.myRankInfo.rank >=1 and self.myRankInfo.rank <= 3 then
        showRankImg = true
        rankImg:loadTexture(rankImgUrl .. self.myRankInfo.rank .. ".png")
    else
        showRankNum = true
        rankNum:setString(self.myRankInfo.rank)
    end
    norank:setVisible(showNorank)
    rankImg:setVisible(showRankImg)
    rankNum:setVisible(showRankNum)

    --头像
    local roleHeadBg = myrankBg:getChildByName("role_head_bg")
    local roleIcon = roleHeadBg:getChildByName("role_icon")
    roleIcon:loadTexture(UserData:getUserObj():getHeadpic())
    local roleLv = roleHeadBg:getChildByName("role_lv")
    local lv = UserData:getUserObj():getLv()
    roleLv:setString(lv)

    local frameBg = nil
    for k, v in pairs(RoleData:getRoleMap()) do   
        if tonumber(v:getId()) and tonumber(v:getId()) > 0 and v:isJunZhu()== true then    
            frameBg=v:getBgImg()
        end 
    end
    if frameBg then
        roleHeadBg:loadTexture(frameBg)
    end
    
    --名字，军团，VIP信息
    local nameTx = myrankBg:getChildByName("name_tx")
    local name = UserData:getUserObj():getName()
    nameTx:setString(name)
    local nameSize = nameTx:getContentSize()
    local posX = nameTx:getPositionX()
    local vipImg = myrankBg:getChildByName("vip_img")
    local vipTx = vipImg:getChildByName("vip_tx")
    local vipLv = UserData:getUserObj():getVip()
    vipTx:setString(vipLv)
    vipImg:setPositionX(posX+nameSize.width)
    local legionIcon = myrankBg:getChildByName("legion_icon")
    local iconId = self.myRankInfo.legionIcon or 1
    legionIcon:loadTexture(legionIconUrl .. iconId .. "_jun.png")
    local legionName = myrankBg:getChildByName("legion_name")
    legionName:setString(self.myRankInfo.legionName)

    --伤害积分
    local scoreTx = myrankBg:getChildByName("hurt_score_tx")
    scoreTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT25"))
    local scoreNumTx = myrankBg:getChildByName("hurt_score_num")
    scoreNumTx:setString(self.myRankInfo.score)

    local rankAwardBtn = myrankBg:getChildByName("rank_award__btn")
    local btnTx = rankAwardBtn:getChildByName('btn_tx')
    btnTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT26"))
    rankAwardBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            TerritorialWarMgr:showAwardBelongUI(1)
        end
    end)

     
    if #self.playerRankInfo == 0 then
        noneBg:setVisible(true)
        local tx = noneBg:getChildByName("tip_text")
        tx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT31"))
    else
        noneBg:setVisible(false)
        self:updateRankList()    
    end
end

--个人排行榜
function TerritoralwarDamageRankUI:updateRankList()

    local size1
    for i=1,#self.playerRankInfo do
        local cell = self.rankSv:getChildByTag(i + 100)
        local cellBg
        if not cell then
            local cellNode = cc.CSLoader:createNode('csb/territorialwar_hurtrank_cell.csb')
            cellBg = cellNode:getChildByName('cell_bg')
            cellBg:removeFromParent(false)
            cell = ccui.Widget:create()
            cell:addChild(cellBg)
            self.rankSv:addChild(cell,1,i+100)
        else
            cellBg = cell:getChildByName('cell_bg')
        end
        cell:setVisible(true)
        size1 = cellBg:getContentSize()

        --显示位次
        local rankImg = cellBg:getChildByName("ranking_img")
        local rankTx = cellBg:getChildByName("ranking_num")
        local rankPos = i
        local showRankImg,showRankNum = false,false
        if rankPos>=1 and rankPos <= 3 then
            rankImg:loadTexture(rankImgUrl .. rankPos .. ".png")
            showRankImg = true
        else
            rankTx:setString(rankPos)
            showRankNum = true
        end
        rankImg:setVisible(showRankImg)
        rankTx:setVisible(showRankNum)

        --显示头像
        local roleheadBg = cellBg:getChildByName("role_head_bg")
        local roleIcon = roleheadBg:getChildByName("role_icon")
        local headIcon = self.playerRankInfo[i].headpic or 1
        roleIcon:loadTexture(self:getHeadPic(headIcon))
        local roleLv = roleheadBg:getChildByName("role_lv")
        local level = self.playerRankInfo[i].level or 1
        roleLv:setString(level)
        local mainRole = self.playerRankInfo[i].main_role 
        local quality = GameData:getConfData("hero")[mainRole].quality
        roleheadBg:loadTexture(COLOR_FRAME[quality])

        --名字，军团，VIP信息
        local nameTx = cellBg:getChildByName("name_tx")
        local name = self.playerRankInfo[i].un
        nameTx:setString(name)
        local nameSize = nameTx:getContentSize()
        local posX = nameTx:getPositionX()
        local vipImg = cellBg:getChildByName("vip_img")
        local vipTx = vipImg:getChildByName("vip_tx")
        local vipLv = self.playerRankInfo[i].vip or 1
        vipTx:setString(vipLv)
        vipImg:setPositionX(posX+nameSize.width)
        local legionNameTx = cellBg:getChildByName("legion_name")
        local legionName = self.playerRankInfo[i].legionName or ""
        legionNameTx:setString(legionName)
        local legionIcon = cellBg:getChildByName("legion_icon")
        local iconId = self.playerRankInfo[i].legionIcon or 1
        legionIcon:loadTexture(legionIconUrl .. iconId .. "_jun.png")
        --伤害积分
        local scoreTx = cellBg:getChildByName("hurt_score_tx")
        scoreTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT25"))
        local scoreNumTx = cellBg:getChildByName("hurt_score_num")
        scoreNumTx:setString(self.playerRankInfo[i].score)
    end

    if not size1 then
        self.rankSv:setVisible(false)
        return
    end

    local size = self.rankSv:getContentSize()
    if #self.playerRankInfo * size1.height > size.height then
        self.rankSv:setInnerContainerSize(cc.size(size.width,(#self.playerRankInfo * size1.height+(#self.playerRankInfo-1)*14)))
    else
        self.rankSv:setInnerContainerSize(size)
    end

    local function getPos(i)
        local size2 = self.rankSv:getInnerContainerSize()        
        return cc.p(0,size2.height - size1.height* i-14*(i-1))
    end
    for i=1,#self.playerRankInfo do
        local cell = self.rankSv:getChildByTag(i + 100)
        if cell then
            cell:setPosition(getPos(i))
        end
    end
end

--军团排行榜
function TerritoralwarDamageRankUI:initLegionDamageRank()

    local noneBg = self.damageRank[2]:getChildByName("no_img")
    local legionRankLen = #self.legionRankInfo
    if legionRankLen == 0 then
        local tx = noneBg:getChildByName("tip_text")
        tx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT30"))
        noneBg:setVisible(true)
    else
        noneBg:setVisible(false)
    end

    for i=1,3 do        
        local rankbg = self.damageRank[2]:getChildByName("rank_bg_" .. i)
        if i<=legionRankLen then
            rankbg:setVisible(true)
            local legionIcon = rankbg:getChildByName("legion_icon")
            local urlId = self.legionRankInfo[i].icon or 1
            legionIcon:loadTexture(legionIconUrl .. urlId .. "_jun.png")
            local legionNameTx = rankbg:getChildByName("legion_name")
            local legionName = self.legionRankInfo[i].name or ""
            legionNameTx:setString(legionName)
            local scoreTx = rankbg:getChildByName("score_num")
            local score = self.legionRankInfo[i].score or 0
            scoreTx:setString(score)
            if i==1 then
                local belongTx = rankbg:getChildByName("belong_tx")
                belongTx:setString(GlobalApi:getLocalStr("TERRITORIAL_WAL_HIT24"))
            end
        else
            rankbg:setVisible(false)
        end
    end
end


function TerritoralwarDamageRankUI:chooseWin(id)
    
    for i=1,2 do
        if i == id then
            self.pageBtns[i].btn:loadTexture(TITLE_TEXTURE_SEL[i])
            self.pageBtns[i].btn:setTouchEnabled(false)
            self.pageBtns[i].infoTx:setColor(COLOR_TYPE.PALE)
            self.pageBtns[i].infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            self.pageBtns[i].infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
            self.damageRank[i]:setVisible(true)
        else
            self.pageBtns[i].btn:loadTexture(TITLE_TEXTURE_NOR[i])
            self.pageBtns[i].btn:setTouchEnabled(true)
            self.pageBtns[i].infoTx:setColor(COLOR_TYPE.DARK)
            self.pageBtns[i].infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            self.pageBtns[i].infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
            self.damageRank[i]:setVisible(false)
        end
    end
end

function TerritoralwarDamageRankUI:getHeadPic(headpic)
    local headId= (headpic==0 or headpic>100) and 1 or headpic
    local path=GameData:getConfData('settingheadicon')[headId].icon
    return path
end

return TerritoralwarDamageRankUI