cc.exports.AudioMgr = {
	musicVal = 1,
	soundVal = 1,
	musicId = cc.AUDIO_INVAILD_ID,
	isMusicPlaying = false
}

function AudioMgr.Init()
	ccexp.AudioEngine:lazyInit()
	AudioMgr.Conf = GameData:getConfData('sound')
	local musicVal = cc.UserDefault:getInstance():getFloatForKey('musicValue', 1)
	local soundVal = cc.UserDefault:getInstance():getFloatForKey('soundValue', 1)
	AudioMgr.setMusicVolume(musicVal)
	AudioMgr.setEffectsVolume(soundVal)
end

function AudioMgr.setMusicVolume(volume)
	AudioMgr.musicVal = volume
	ccexp.AudioEngine:setVolume(AudioMgr.musicId, volume)
end

function AudioMgr.setEffectsVolume(volume)
	AudioMgr.soundVal = volume
end

function AudioMgr.playMusic(idx, filename, isLoop)
    local loopValue = true
    if nil ~= isLoop then
        loopValue = isLoop
    end
	if filename ~= nil and AudioMgr.lastMusicFile ~= filename then
		AudioMgr.lastMusicFile = filename
		AudioMgr.musicId = ccexp.AudioEngine:play2d(filename, loopValue, AudioMgr.musicVal)
		if AudioMgr.musicId ~= cc.AUDIO_INVAILD_ID then
			AudioMgr.isMusicPlaying = true
			local function finishCallback(audioID, filePath)
				AudioMgr.isMusicPlaying=false
			end
			ccexp.AudioEngine:setFinishCallback(AudioMgr.musicId, finishCallback)
		end
	end
	return AudioMgr.musicId
end

function AudioMgr.stopMusic()
	if AudioMgr.isMusicPlaying and AudioMgr.musicId ~= cc.AUDIO_INVAILD_ID then
		ccexp.AudioEngine:stop(AudioMgr.musicId)
		AudioMgr.isMusicPlaying = false
	end
end

function AudioMgr.stopEffect(audioId)
	if audioId ~= cc.AUDIO_INVAILD_ID then
		ccexp.AudioEngine:stop(audioId)
	end
end

function AudioMgr.playEffect(filename, isLoop)
    local loopValue = false
    if nil ~= isLoop then
        loopValue = isLoop
    end
	local audioId = ccexp.AudioEngine:play2d(filename, loopValue, AudioMgr.soundVal)
	return audioId
end

function AudioMgr.PlayAudio(idx)
	if AudioMgr.Conf[idx] ~= nil then
		local data = AudioMgr.Conf[idx]
		if data.audioType == 1 then
			return AudioMgr.playMusicByIndex(idx)
		else
			return AudioMgr.playEffectByIndex(idx)
		end
	end
	return cc.AUDIO_INVAILD_ID
end

function AudioMgr.playMusicByIndex(idx)
	if AudioMgr.Conf[idx] ~= nil then
		local data = AudioMgr.Conf[idx]
		if data.resPath ~= nil and string.len(data.resPath) > 0 then
			if AudioMgr.isMusicPlaying and AudioMgr.musicId ~= cc.AUDIO_INVAILD_ID then
				if AudioMgr.lastMusicFile ~= data.resPath then
					ccexp.AudioEngine:stop(AudioMgr.musicId)
				end
			end
			local isLoop = AudioMgr.Conf[idx].isLoop > 0 and true or false
			return AudioMgr.playMusic(idx, data.resPath, isLoop)
		end
	end
	return cc.AUDIO_INVAILD_ID
end

function AudioMgr.playEffectByIndex(idx,isLoop)
	if AudioMgr.Conf[idx] ~= nil then
		local isLoop = AudioMgr.Conf[idx].isLoop > 0 and true or false
		local data = AudioMgr.Conf[idx]
		if data.resPath ~= nil and string.len(data.resPath) > 0 then
			return AudioMgr.playEffect(data.resPath,isLoop)
		end
	end
	return cc.AUDIO_INVAILD_ID
end

function AudioMgr.resumeAll()
	ccexp.AudioEngine:resumeAll()
end

function AudioMgr.pauseAll()
	ccexp.AudioEngine:pauseAll()
end

function AudioMgr.stopAll()
	AudioMgr.isMusicPlaying = false
	AudioMgr.musicId = cc.AUDIO_INVAILD_ID
	AudioMgr.lastMusicFile = nil
	ccexp.AudioEngine:stopAll()
end

function AudioMgr.uncacheAll()
	--ccexp.AudioEngine:uncacheAll()
end

function AudioMgr.uncache(name)
	--ccexp.AudioEngine:uncache(name)
end

function AudioMgr.setFinishCallback(audioId, callback)
	ccexp.AudioEngine:setFinishCallback(audioId, callback)
end