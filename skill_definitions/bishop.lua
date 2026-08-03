return {
    name = "Arcane Judgment",
    audio = {
        asset = "bishop", delay = 0.28, duration = 0.96,
        fade = 0.12, volume = 0.76, pitch = 1.02,
    },
    range = 3,
    effectRadius = 1,
    fps = 15,
    frameCount = 27,
    feedback = {
        impactAt = 0.30, duration = 0.44, radius = 1.34, offsetY = -34,
        color = { 1, 0.86, 0.34 },
    },
    layers = {
        {
            image = "assets/skill-effects/combo/arcane-spark.png",
            frameWidth = 32, frameHeight = 32, frameCount = 7, fps = 15,
            scaleFrom = 1.9, scaleTo = 0.9, offsetY = -28, anchor = "source",
        },
        {
            image = "assets/skill-effects/combo/dark-bolt.png",
            frameWidth = 88, frameHeight = 88, frameCount = 8, fps = 15,
            scaleFrom = 0.65, scaleTo = 0.95, offsetY = -34, delay = 0.10,
            directional = true, anchor = "travel", travelDuration = 0.22,
        },
        {
            image = "assets/skill-effects/combo/arcane-light.png",
            frameWidth = 256, frameHeight = 144, frameCount = 9, fps = 15,
            scaleFrom = 0.5, scaleTo = 0.82, offsetY = -38, delay = 0.28,
        },
        {
            image = "assets/skill-effects/combo/arcane-spark.png",
            frameWidth = 32, frameHeight = 32, frameCount = 7, fps = 15,
            scale = 2.4, offsetY = -30, delay = 0.34,
        },
        {
            image = "assets/skill-effects/combo/arcane-fireworks.png",
            frameWidth = 96, frameHeight = 96, frameCount = 27, columns = 10, fps = 15,
            scale = 1.05, offsetY = -36, delay = 0.40, fadeOut = 0.25,
        },
    },
}
