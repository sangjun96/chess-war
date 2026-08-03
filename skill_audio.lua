local SkillAudio = {}
SkillAudio.__index = SkillAudio

function SkillAudio.new(root)
    return setmetatable({
        root = root,
        sources = {},
        playing = {},
    }, SkillAudio)
end

function SkillAudio:load(skillCatalog)
    self.sources = {}
    for skillId, definition in pairs(skillCatalog) do
        -- Piece-named MP3s are the preferred assets; the old skill-named Ogg
        -- layout remains supported for custom sound packs.
        local audio = definition.audio
        local asset = type(audio) == "table" and audio.asset or audio
        local paths = {
            asset and self.root .. "/" .. asset .. ".mp3",
            self.root .. "/" .. skillId .. ".ogg",
        }
        for _, path in ipairs(paths) do
            if path and love.filesystem.getInfo(path, "file") then
                self.sources[skillId] = love.audio.newSource(path, "static")
                break
            end
        end
    end
end

function SkillAudio:play(skillId, cue)
    local source = self.sources[skillId]
    if not source then return false end
    cue = cue or {}
    local instance = source:clone()
    local volume = cue.volume or 1
    if instance.setVolume then instance:setVolume(volume) end
    if instance.setPitch then instance:setPitch(cue.pitch or 1) end
    instance:play()
    table.insert(self.playing, {
        source = instance,
        elapsed = 0,
        duration = cue.duration,
        fade = cue.fade or 0.1,
        volume = volume,
    })
    return true
end

function SkillAudio:update(dt)
    for index = #self.playing, 1, -1 do
        local playback = self.playing[index]
        playback.elapsed = playback.elapsed + dt
        local finished = not playback.source:isPlaying()
        if playback.duration and playback.elapsed >= playback.duration then
            if playback.source.stop then playback.source:stop() end
            finished = true
        elseif playback.duration and playback.source.setVolume then
            local fadeAt = playback.duration - playback.fade
            if playback.elapsed > fadeAt then
                local remaining = math.max(0, playback.duration - playback.elapsed)
                playback.source:setVolume(playback.volume * remaining / playback.fade)
            end
        end
        if finished then table.remove(self.playing, index) end
    end
end

return SkillAudio
