cc.exports.YVSdkMgr = {}

function YVSdkMgr:init()
    -- self:initSDK()
    self.YVSdkCallBackList = {}
    -- self.recordPath = cc.FileUtils:getInstance():getWritablePath() .. "record.amr"

    -- -- sdk默认最大录制时间60s
    -- self.sdkMaxRecordTime = 60
    -- self.loginResult = true
end

function YVSdkMgr:initSDK()
    -- print("\n-------------------------------------- YVsdK initSDK  begin !")
    -- yvcc.YVTool:getInstance():initSDK(1000592,cc.FileUtils:getInstance():getWritablePath(),false)
    -- print("\n-------------------------------------- YVsdK initSDK  end !")
end

-- 登陆
function YVSdkMgr:cpLogin(name,passWord)
    -- yvcc.YVTool:getInstance():cpLogin(name,passWord)
end

-- 注销登陆
function YVSdkMgr:cpLogout()
    -- yvcc.YVTool:getInstance():cpLogout()
end

function YVSdkMgr:setCpLoginCallBack(callBack)
    -- self.YVSdkCallBackList.cpLoginCallBack = callBack
end

-- 开始录音
function YVSdkMgr:startRecord()
    -- AudioMgr.pauseAll()
    -- yvcc.YVTool:getInstance():startRecord(self.recordPath)
end

-- 停止录音
function YVSdkMgr:stopRecord()
    -- AudioMgr.resumeAll()
    -- yvcc.YVTool:getInstance():stopRecord()
end

function YVSdkMgr:setRecordFinishCallBack(callBack)
    -- self.YVSdkCallBackList.recordFinishCallBack = callBack
end

-- 播放录音（本地）
function YVSdkMgr:playRecord()
    -- AudioMgr.pauseAll()
    -- yvcc.YVTool:getInstance():playRecord(self.recordPath,'')
end

-- 播放录音（云播）
function YVSdkMgr:playRecordFromUrl(url)
    -- AudioMgr.pauseAll()
    -- if url and url ~= '' then
    --     yvcc.YVTool:getInstance():playRecord('',url,'')
    -- end
end

function YVSdkMgr:stopPlay()
    -- yvcc.YVTool:getInstance():stopPlay()
end

function YVSdkMgr:setFinishPlayCallBack(callBack)
    -- self.YVSdkCallBackList.finishPlayCallBack = callBack
end

-- 上传文件
function YVSdkMgr:upLoadFile()
    -- yvcc.YVTool:getInstance():upLoadFile(self.recordPath)
end

function YVSdkMgr:setUpLoadFileCallBack(callBack)
    -- self.YVSdkCallBackList.upLoadFileCallBack = callBack
end

-- 语音识别,默认识别本地记录的，默认上传
function YVSdkMgr:speechVoice()
    -- yvcc.YVTool:getInstance():speechVoice(self.recordPath,'',true)
end

function YVSdkMgr:setSpeechCallBack(callBack)
    -- self.YVSdkCallBackList.speechCallBack = callBack
end

-- 设置录音，用户登陆了，才有音量回调事件
function YVSdkMgr:setRecord()
    -- yvcc.YVTool:getInstance():setRecord(60, true)
end

function YVSdkMgr:setRecordVoiceCallBack(callBack)
    -- self.YVSdkCallBackList.recordVoiceCallBack = callBack
end
