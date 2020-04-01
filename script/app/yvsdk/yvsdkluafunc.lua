-- c++调用lua，lua里面的接口必须是全局变量
-- 这里必须按照下面的方式写，把局部函数转化为全局函数

-- 登陆
local function cpLoginCallBack_(result,msg,name,iconUrl,thirdUserId,thirdUserName,uid)
    print('cpLoginCallBack......' .. 'result' .. result ..'msg' .. msg ..  'name:' .. name .. 'iconUrl:' .. iconUrl .. 'thirdUserId:' .. thirdUserId .. 'thirdUserName:' .. thirdUserName .. 'uid:' .. uid)

    -- 登陆失败
    if result ~= 0 then
        YVSdkMgr.loginResult = false
        return
    end
    YVSdkMgr.loginResult = true
    YVSdkMgr:setRecord()
    if YVSdkMgr.YVSdkCallBackList.cpLoginCallBack then
        local data = {}
        data.result = result
        data.msg = msg
        data.name = name
        data.iconUrl = iconUrl
        data.thirdUserId = thirdUserId
        data.thirdUserName = thirdUserName
        data.uid = uid

        YVSdkMgr.YVSdkCallBackList.cpLoginCallBack(data)
        YVSdkMgr.YVSdkCallBackList.cpLoginCallBack = nil
    end
end
cc.exports.cpLoginCallBack = cpLoginCallBack_

-- 录音结束
local function gLuaRecordCallBack_(time,strfilepath,ext)
    print('gLuaRecordCallBack_......time:' .. time)
    
    if YVSdkMgr.YVSdkCallBackList.recordFinishCallBack then       
        YVSdkMgr.YVSdkCallBackList.recordFinishCallBack(time)
        YVSdkMgr.YVSdkCallBackList.recordFinishCallBack = nil
    end

end
cc.exports.gLuaRecordCallBack = gLuaRecordCallBack_

-- 播放录音完成（包括在线播放和本地播放）
local function gLuaFinishPlayCallBack_(result,describe,ext)
    AudioMgr.resumeAll()
    print('gLuaFinishPlayCallBack_......')

    if YVSdkMgr.YVSdkCallBackList.finishPlayCallBack then
        YVSdkMgr.YVSdkCallBackList.finishPlayCallBack(result)
        YVSdkMgr.YVSdkCallBackList.finishPlayCallBack = nil

    end
end
cc.exports.gLuaFinishPlayCallBack = gLuaFinishPlayCallBack_

-- 上传文件完成
local function gLuaUpLoadFileCallBack_(result,msg,fileid,fileurl,percent)
    print('gLuaUpLoadFileCallBack_......')

    if YVSdkMgr.YVSdkCallBackList.upLoadFileCallBack then
        local data = {}
        data.result = result
        data.msg = msg
        data.fileid = fileid
        data.fileurl = fileurl
        data.percent = percent

        YVSdkMgr.YVSdkCallBackList.upLoadFileCallBack(data)
        YVSdkMgr.YVSdkCallBackList.upLoadFileCallBack = nil
    end

end
cc.exports.gLuaUpLoadFileCallBack = gLuaUpLoadFileCallBack_

-- 语音识别完成:result是文本,url是地址
local function gLuaSpeechCallBack_(ext,url,result,err_id,err_msg)
    print('gLuaRecordVoiceCallBack_......' .. '\n result:' .. result .. '\n url:' .. url .. '\n err_id:' .. err_id .. '\n err_msg:' .. err_msg)

    if YVSdkMgr.YVSdkCallBackList.speechCallBack then
        local data = {}
        data.ext = ext
        data.url = url
        data.resultText = result
        data.err_id = err_id
        data.err_msg = err_msg

        YVSdkMgr.YVSdkCallBackList.speechCallBack(data)
        YVSdkMgr.YVSdkCallBackList.speechCallBack = nil
    end

end
cc.exports.gLuaSpeechCallBack = gLuaSpeechCallBack_

-- 音量回调事件,volume音量，从0到100
local function gLuaRecordVoiceCallBack_(ext, volume)
    --print('gLuaRecordVoiceCallBack_......' .. '\n volume:' .. volume)

    if YVSdkMgr.YVSdkCallBackList.recordVoiceCallBack then
        YVSdkMgr.YVSdkCallBackList.recordVoiceCallBack(volume)
    end

end
cc.exports.gLuaRecordVoiceCallBack = gLuaRecordVoiceCallBack_

-- 网络连接状态事件,0表示断开连接，1表示连接
local function gLuaNetWorkStateCallBack_(state) 
    print("gLuaNetWorkStateCallBack_" .. '\n state:' .. state)

end
cc.exports.gLuaNetWorkStateCallBack = gLuaNetWorkStateCallBack_