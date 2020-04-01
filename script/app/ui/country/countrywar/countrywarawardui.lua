local CountryWarAwardUI = class("CountryWarAwardUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')
function CountryWarAwardUI:ctor(page,page1,countryRank,weekRank,dayRank)
    self.uiIndex = GAME_UI.UI_COUNTRYWAR_AWARD
    self.conf = {GameData:getConfData('countrywarcamp'),GameData:getConfData('countrywarpersonal')}
    self.pageBtns = {}
    self.cells = {{},{}}
    self.page = page or 1
    self.page1 = page1 or 1
    self.weekRank = weekRank or 0
    self.countryRank = countryRank or 0
    self.dayRank = dayRank or 0
end

function CountryWarAwardUI:updateRightPanel()
    local conf
    if self.page == 1 then
        conf = GameData:getConfData('countrywarcamp')[self.page1 or 1]
    else
        conf = GameData:getConfData('countrywarpersonal')
    end
    local singleSize
    for i=1,#conf do
        if not self.cells[self.page][i] then
            local cellNode = cc.CSLoader:createNode("csb/countrywarawardcell.csb")
            local rankBgImg = cellNode:getChildByName('rank_bg_img')
            local rankImg = rankBgImg:getChildByName('rank_img')
            local rankTx = rankBgImg:getChildByName('rank_tx')
            local meImg = rankBgImg:getChildByName('me_img')
            if not rankTx then
                rankTx = cc.LabelBMFont:create()
                rankTx:setFntFile('uires/ui/number/number2.fnt')
                rankTx:setName('rank_tx')
                rankTx:setPosition(cc.p(93,51))
                rankBgImg:addChild(rankTx)
            end
            local awards = {}
            local scale = 0.8
            for j=1,4 do
                local cell = ClassItemCell:create()
                cell.awardBgImg:setScale(scale)
                cell.awardBgImg:setPosition(cc.p(245 + 115*j*scale,41))
                rankBgImg:addChild(cell.awardBgImg)
                awards[j] = cell
            end
            rankBgImg:removeFromParent(false)
            self.sv[self.page]:addChild(rankBgImg)
            self.cells[self.page][i] = {rankBgImg = rankBgImg,rankImg = rankImg,awards = awards,rankTx = rankTx,meImg = meImg}
        end
        self.cells[self.page][i].rankBgImg:setVisible(true)
        if not singleSize then
            singleSize = self.cells[self.page][i].rankBgImg:getContentSize()
        end
        if i <= 3 then
            self.cells[self.page][i].rankTx:setString('')
            self.cells[self.page][i].rankImg:loadTexture('uires/ui/rankinglist_v3/rlistv3_rank_'..i..'.png')
            self.cells[self.page][i].meImg:setVisible(
                (i == self.weekRank and self.page == 1 and self.page1 == self.countryRank)
                or (i == self.dayRank and self.page == 2)
                )
        elseif i == #conf then
            self.cells[self.page][i].rankImg:setVisible(false)
            self.cells[self.page][i].rankTx:setString((conf[i].rank - 1)..GlobalApi:getLocalStr('E_STR_PVP_WAR_DESC4'))
            self.cells[self.page][i].meImg:setVisible(
                (self.weekRank > (conf[i].rank - 1) and self.page == 1 and self.page1 == self.countryRank)
                or (self.dayRank > (conf[i].rank - 1) and self.page == 2)
                )
        else
            self.cells[self.page][i].rankImg:setVisible(false)
            local conf1 = conf[i + 1]
            if conf[i].rank == conf1.rank - 1 then
                self.cells[self.page][i].rankTx:setString(conf[i].rank)
                self.cells[self.page][i].meImg:setVisible(
                    (conf[i].rank == self.weekRank and self.page == 1 and self.page1 == self.countryRank)
                    or (conf[i].rank == self.dayRank and self.page == 2)
                    )
            else
                self.cells[self.page][i].rankTx:setString(conf[i].rank..'-'..(conf1.rank - 1))
                self.cells[self.page][i].meImg:setVisible(
                    (conf[i].rank <= self.weekRank 
                    and self.weekRank <= (conf1.rank - 1) 
                    and self.page == 1
                    and self.page1 == self.countryRank)
                    or (conf[i].rank <= self.dayRank 
                    and self.dayRank <= (conf1.rank - 1) 
                    and self.page == 2)
                    )
            end
        end
        self.cells[self.page][i].rankImg:ignoreContentAdaptWithSize(true)
        local awards = DisplayData:getDisplayObjs(conf[i].awards)
        for i,v in ipairs(self.cells[self.page][i].awards) do
            local award = awards[i]
            if award then
                v.awardBgImg:setVisible(true)
                v.awardBgImg:loadTexture(award:getBgImg())
                v.awardImg:loadTexture(award:getIcon())
                v.awardImg:ignoreContentAdaptWithSize(true)
                if award:getType() == 'equip' then
                    v.lvTx:setVisible(false)
                    ClassItemCell:setGodLight(v.awardBgImg,award:getGodId())
                else
                    v.lvTx:setVisible(true)
                    v.lvTx:setString('x'..award:getNum())
                    ClassItemCell:setGodLight(v.awardBgImg,0)
                    award:setLightEffect(v.awardBgImg)
                end
                v.awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        GetWayMgr:showGetwayUI(award,false)
                    end
                end)
            else
                v.awardBgImg:setVisible(false)
            end
        end
    end

    for i=#conf + 1,#self.cells[self.page] do
        self.cells[self.page][i].rankBgImg:setVisible(false)
    end
    print('=================xxxx',singleSize)
    if singleSize then
        local size = self.sv[self.page]:getContentSize()
        if #conf * singleSize.height > size.height then
            self.sv[self.page]:setInnerContainerSize(cc.size(size.width,#conf * (singleSize.height + 10)))
        else
            self.sv[self.page]:setInnerContainerSize(size)
        end
        if #conf < 5 then
            for i=1,#conf do
                self.cells[self.page][i].rankBgImg:setPosition(cc.p(2,size.height - i*(singleSize.height + 10)))
            end
        else
            for i=1,#conf do
                self.cells[self.page][i].rankBgImg:setPosition(cc.p(2,(#conf - i)*(singleSize.height + 10)))
            end
        end
    end
end

function CountryWarAwardUI:updatePageBtn()
    for i=1,2 do
        local infoTx = self.pageBtns[i]:getChildByName('info_tx')
        if i == self.page then
            self.neiBgImgs[i]:setVisible(true)
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.highlight)
            self.pageBtns[i]:setTouchEnabled(false)
            infoTx:setColor(COLOR_TYPE.PALE)
            infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        else
            self.neiBgImgs[i]:setVisible(false)
            self.pageBtns[i]:setBrightStyle(ccui.BrightStyle.normal)
            self.pageBtns[i]:setTouchEnabled(true)
            infoTx:setColor(COLOR_TYPE.DARK)
            infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,1)
            infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
        end
    end
    if self.page == 1 then
        for i,v in ipairs(self.pageBtns1) do
            local infoTx = v:getChildByName('info_tx')
            if i == self.page1 then
                v:setBrightStyle(ccui.BrightStyle.highlight)
                infoTx:setColor(COLOR_TYPE.PALE)
                infoTx:enableOutline(COLOROUTLINE_TYPE.PALE,2)
                infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
            else
                v:setBrightStyle(ccui.BrightStyle.normal)
                infoTx:setColor(COLOR_TYPE.DARK)
                infoTx:enableOutline(COLOROUTLINE_TYPE.DARK,2)
                infoTx:enableShadow(GlobalApi:getLabelCustomShadow(ENABLESHADOW_TYPE.TITLE))
            end
            if i == self.countryRank then
                local posX,posY = v:getPosition()
                self.meImg:setPosition(cc.p(posX - 75,posY + 20))
            end
        end
        self.descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_3'))
    else
        self.descTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_53'))
    end
end

function CountryWarAwardUI:updatePanel()
    self:updatePageBtn()
    self:updateRightPanel()
end

function CountryWarAwardUI:init()
    local bgImg = self.root:getChildByName("countrywar_bg_img")
    local bgImg1 = bgImg:getChildByName("countrywar_img")
    self:adaptUI(bgImg, bgImg1)
    local winSize = cc.Director:getInstance():getVisibleSize()
    local closeBtn = bgImg1:getChildByName("close_btn")
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            CountryWarMgr:hideCountryWarAward()
        end
    end)

    local bgImg2 = bgImg1:getChildByName('bg_img')
    local titleImg = bgImg2:getChildByName('title_img')
    local descTx = titleImg:getChildByName('desc_tx')
    self.descTx = descTx
    for i=1,2 do
        local btn = bgImg1:getChildByName('page_'..i..'_btn')
        local infoTx = btn:getChildByName('info_tx')
        infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_DESC_'..i))
        self.pageBtns[i] = btn
        btn:addTouchEventListener(function (sender, eventType)
            if eventType == ccui.TouchEventType.began then
                AudioMgr.PlayAudio(11)
            elseif eventType == ccui.TouchEventType.ended then
                self.page = i
                self:updatePanel()
            end
        end)
    end

    local bgImg = bgImg1:getChildByName('bg_img')
    self.neiBgImgs = {}
    self.pageBtns1 = {}
    self.sv = {}
    for i=1,2 do
        self.neiBgImgs[i] = bgImg:getChildByName('nei_bg_img_'..i)
        self.sv[i] = self.neiBgImgs[i]:getChildByName('rank_sv')
        self.sv[i]:setScrollBarEnabled(false)
        local meImg = self.neiBgImgs[i]:getChildByName('me_img')
        if meImg then
            self.meImg = meImg
        end
        for j=1,3 do
            local pageBtn = self.neiBgImgs[i]:getChildByName('page_1'..j..'_btn')
            if pageBtn then
                local infoTx = pageBtn:getChildByName('info_tx')
                infoTx:setString(GlobalApi:getLocalStr('COUNTRY_WAR_LIST_PAGE_DESC_'..j))
                self.pageBtns1[j] = pageBtn
                pageBtn:setTouchEnabled(true)
                pageBtn:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        self.page1 = j
                        self:updatePanel()
                    end
                end)
            end
        end
    end
    self:updatePanel()
end

return CountryWarAwardUI