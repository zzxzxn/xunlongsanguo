local SettingChangeHeadFrameUI = class("SettingChangeHeadFrameUI", BaseUI)
local ClassItemCell = require('script/app/global/itemcell')

function SettingChangeHeadFrameUI:ctor(obj,callback,data)
	self.uiIndex = GAME_UI.UI_SITTING_HEAD_FRAME
	self.callback = callback
    self.conf = GameData:getConfData('settingheadframe')
    self.data = data
end

function SettingChangeHeadFrameUI:init()
	local bg1 = self.root:getChildByName("bgimg")
	local bg2 = bg1:getChildByName("bgimg1")
	self:adaptUI(bg1, bg2)
    local bg3 = bg2:getChildByName('bgimg2')
    local closeBtn = bg3:getChildByName('close_btn')
    closeBtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            SettingMgr:hideSettingChangeHeadFrame()
        end
    end)
    bg2:setTouchEnabled(true)
    bg2:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            SettingMgr:hideSettingChangeHeadFrame()
        end
    end)
    self.leftbg = bg3:getChildByName('left_img')
    self.rightbg = bg3:getChildByName('right_img')
	bg2:setOpacity(0)
    bg2:runAction(cc.FadeIn:create(0.3))
    self.selectframeid = 1
    self.cells = {}
    self.cell= self.root:getChildByName('head_cell')
    self.cell:setVisible(false)
    self.frametab = {}
    self:update()
    self.leftsv:scrollToTop(0.01, false)
end

function SettingChangeHeadFrameUI:update()
    self:initLeft()
    self:initRight()
end

function SettingChangeHeadFrameUI:initLeft()
    self.leftsv = self.leftbg:getChildByName('sv')
    self.leftsv:setScrollBarEnabled(false)
    self.leftsv:setInertiaScrollEnabled(true)
    self.leftsv:removeAllChildren()
    self.cells = {}
    local svwidth = 504
    local svheight = 200
    local cellheight = {}
    local innerContainer = self.leftsv:getInnerContainer()
    local size = self.leftsv:getContentSize()
    local num = self:calcNumOfType()
    for i = 1,num do
        cellheight[i] = 0
    end
    local headframeselectImg = ccui.ImageView:create('uires/ui/common/head_select.png')
    headframeselectImg:setName('headframeselectImg')
    headframeselectImg:setVisible(true)
    headframeselectImg:setScale(1.2)
    for i = num,1,-1 do
        if not self.cells[i] then
            local tempCell = self.cell:clone()
            tempCell:setVisible(true)
            local namebg = tempCell:getChildByName('name_bg')
            local nametx = tempCell:getChildByName('name_tx')
            nametx:setString(self:getNameByType(i))
            local pl = tempCell:getChildByName('head_pl')
            local arr =self:getArrByType(i)
            local plheight = 95*(math.ceil(#arr/5))
            pl:setContentSize(cc.size(svwidth,plheight))
            svheight = 40+plheight
            cellheight[i] = svheight
            tempCell:setContentSize(cc.size(svwidth,svheight))
            pl:setPosition(cc.p(0,plheight))
            namebg:setPosition(cc.p(0,svheight))
            nametx:setPosition(cc.p(0,svheight-15))

            for j = 1, #arr do
                local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
                cell.awardBgImg:loadTexture(RoleData:getMainRole():getBgImg())
                cell.awardBgImg:setScale(0.8)
                cell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
                cell.headframeImg:loadTexture(arr[j].icon)
                cell.headframeImg:setVisible(true)
                cell.awardBgImg:setTouchEnabled(true)
                local lockimg = ccui.ImageView:create('uires/ui/common/lock_3.png')
                lockimg:setName('lockimg')
                lockimg:setPosition(cc.p(75,17))
                lockimg:setScale(0.86)
                cell.awardBgImg:addChild(lockimg)

                local useimg = ccui.ImageView:create('uires/ui/text/using.png')
                useimg:setName('useimg')
                useimg:setPosition(cc.p(75,17))
                useimg:setScale(1.2)
                useimg:setVisible(false)
                cell.awardBgImg:addChild(useimg)

                cell.awardBgImg:addTouchEventListener(function (sender, eventType)
                    if eventType == ccui.TouchEventType.began then
                        AudioMgr.PlayAudio(11)
                    elseif eventType == ccui.TouchEventType.ended then
                        self.selectframeid = arr[j].id
                        self:update()
                    end
                end)
                local x = 60+90*((j-1)%5)
                local y = plheight-45-90*(math.ceil(j/5)-1)
                cell.awardBgImg:setPosition(cc.p(x,y))
                
                if arr[j].id == self.selectframeid then
                    local size = cell.awardBgImg:getContentSize()
                    headframeselectImg:setPosition(cc.p(size.width/2,size.height/2))
                    cell.awardBgImg:addChild(headframeselectImg)
                end 
                
                if self.data.head_frame_status ~= nil then
                    local isactive = false 
                    for k,v in pairs(self.data.head_frame_status) do
                        if tostring(arr[j].id) == k and tonumber(v) == 1 then
                            isactive = true
                        end
                    end
                    if isactive then
                        ShaderMgr:restoreWidgetDefaultShader(cell.awardBgImg)
                        ShaderMgr:restoreWidgetDefaultShader(cell.awardImg)
                        ShaderMgr:restoreWidgetDefaultShader(cell.headframeImg)
                        lockimg:setVisible(false) 

                    else
                        ShaderMgr:setGrayForWidget(cell.awardBgImg)
                        ShaderMgr:setGrayForWidget(cell.awardImg)
                        ShaderMgr:setGrayForWidget(cell.headframeImg)
                        lockimg:setVisible(true)    
                    end
                else
                    ShaderMgr:setGrayForWidget(cell.awardBgImg)
                    ShaderMgr:setGrayForWidget(cell.awardImg)
                    ShaderMgr:setGrayForWidget(cell.headframeImg)
                    lockimg:setVisible(true)               
                end
                if UserData:getUserObj():getHeadFrameId() == arr[j].id then
                    useimg:setVisible(true)
                else
                    useimg:setVisible(false)
                end
                pl:addChild(cell.awardBgImg)
            end
            
            local heighttemp = 0 
            for s = 1, num do
                heighttemp = heighttemp + cellheight[s]
            end
            local tcellheight = 0
            for n = i,num do
                if n == num then
                    break
                else
                   tcellheight = tcellheight + cellheight[n+1]
                end
            end  
            if heighttemp > size.height then
                innerContainer:setContentSize(cc.size(svwidth,heighttemp))
            end
            tempCell:setPosition(cc.p(0,tcellheight))

            self.leftsv:addChild(tempCell)
        end
    end
end

function SettingChangeHeadFrameUI:calcNumOfType()
    local num = 0
    local typetab = {}
    for k, v in pairs(self.conf) do
        local n  = GlobalApi:tableFind(typetab,v.type)
        if n == 0 then
            table.insert(typetab,v.type)
        end
    end
    return #typetab
end

function SettingChangeHeadFrameUI:getArrByType(value)
    local num = 0
    local typearr = {}
    for k, v in pairs(self.conf) do
        if v.type == value and tonumber(v.display) == 1 then
            table.insert(typearr,v)
        end
    end
    table.sort(typearr,function(a,b)
        return a.id < b.id
    end)
    return typearr
end

function SettingChangeHeadFrameUI:getNameByType(value)
    local name = ''
    for k, v in pairs(self.conf) do
        if v.type == value then
            name = v.typeName
            break
        end
    end
    return name
end

function SettingChangeHeadFrameUI:initRight()
    local titletx = self.rightbg:getChildByName('title_tx')
    titletx:setString(self.conf[self.selectframeid].name)
   
    local headframe_node = self.rightbg:getChildByName('head_node')
     headframe_node:removeAllChildren()
    local cell = ClassItemCell:create(ITEM_CELL_TYPE.HEADPIC)
    cell.awardBgImg:loadTexture(RoleData:getMainRole():getBgImg())
    cell.awardImg:loadTexture(UserData:getUserObj():getHeadpic())
    cell.headframeImg:loadTexture(self.conf[self.selectframeid].icon)
    cell.headframeImg:setVisible(true)
    headframe_node:addChild(cell.awardBgImg)
    local infotx = self.rightbg:getChildByName('info_tx')
    infotx:setString(self.conf[self.selectframeid].timDesc)
    local limittx = self.rightbg:getChildByName('limit_tx')
    limittx:setString(self.conf[self.selectframeid].conditionDesc)
    local funcbtn = self.rightbg:getChildByName('func_btn')
    local funcbtntx =funcbtn:getChildByName('text')
    funcbtntx:setString(GlobalApi:getLocalStr("HERAFRAME_DESC_1"))
    funcbtn:addTouchEventListener(function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioMgr.PlayAudio(11)
        elseif eventType == ccui.TouchEventType.ended then
            self:sendMsg()
        end
    end)
    local isactive = false
    if self.data.head_frame_status ~= nil then  
        for k,v in pairs(self.data.head_frame_status) do
            if tostring(self.selectframeid) == k and tonumber(v) == 1 then
                isactive = true
            end
        end
        if isactive then
            funcbtn:setVisible(true)
            limittx:setVisible(false)
        else
            funcbtn:setVisible(false)
            limittx:setVisible(true) 
        end
    else
        funcbtn:setVisible(false)
        limittx:setVisible(true)           
    end
    if UserData:getUserObj():getHeadFrameId() == self.selectframeid then
        funcbtn:setBright(false)
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.GRAY1,1)
        funcbtntx:setString(GlobalApi:getLocalStr("HERAFRAME_DESC_2"))
    else
        funcbtntx:enableOutline(COLOROUTLINE_TYPE.WHITE1,1)
        funcbtn:setBright(true)
        funcbtntx:setString(GlobalApi:getLocalStr("HERAFRAME_DESC_1"))
    end
    local barbg = self.rightbg:getChildByName('bar_bg')
    local bar = barbg:getChildByName('bar')
    bar:setScale9Enabled(true)
    bar:setCapInsets(cc.rect(10,15,1,1))
    local bartx = self.rightbg:getChildByName('bar_tx')
    if not isactive and tonumber(self.conf[self.selectframeid].schedule) == 1 then
        barbg:setVisible(true)
        bartx:setVisible(true)
        if self.data.progress and self.data.progress[tostring(self.selectframeid)] then
            local percent  = math.floor(self.data.progress[tostring(self.selectframeid)]*100/self.conf[self.selectframeid].value)
            
            bar:setPercent(percent)
            bartx:setString(self.data.progress[tostring(self.selectframeid)]..'/'..self.conf[self.selectframeid].value)
        else
            bartx:setString('0/'..self.conf[self.selectframeid].value)
            bar:setPercent(0)
        end
    else
        barbg:setVisible(false)
        bartx:setVisible(false)
    end

end
function SettingChangeHeadFrameUI:ActionClose(call)
	local bg1 = self.root:getChildByName("bgimg")
	local panel=ccui.Helper:seekWidgetByName(bg1,"bgimg1")
    panel:runAction(cc.EaseQuadraticActionIn:create(cc.ScaleTo:create(0.3, 0.05)))
    panel:runAction(cc.Sequence:create(cc.DelayTime:create(0.3),cc.CallFunc:create(function ()
        self:hideUI()
        if(call ~= nil) then
            return call()
        end
    end)))
end

function SettingChangeHeadFrameUI:sendMsg()
	local args = {
		id = self.selectframeid,
	}
    MessageMgr:sendPost('set_headframe','user',json.encode(args),function (response)
        local code = response.code
        local data = response.data
        if code == 0 then
            UserData:getUserObj():setHeadFrameId(self.selectframeid)
            SettingMgr:hideSettingChangeHeadFrame()
        end
    end)
end

return SettingChangeHeadFrameUI