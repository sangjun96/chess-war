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
        local paths = {
            definition.audio and self.root .. "/" .. definition.audio .. ".mp3",
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

function SkillAudio:play(skillId)
    local source = self.sources[skillId]
    if not source then return end
    local instance = source:clone()
    instance:play()
    table.insert(self.playing, instance)
end

function SkillAudio:update()
    for index = #self.playing, 1, -1 do
        if not self.playing[index]:isPlaying() then table.remove(self.playing, index) end
    end
end

return SkillAudio
