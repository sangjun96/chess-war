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
    for skillId in pairs(skillCatalog) do
        local path = self.root .. "/" .. skillId .. ".ogg"
        if love.filesystem.getInfo(path, "file") then
            self.sources[skillId] = love.audio.newSource(path, "static")
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
