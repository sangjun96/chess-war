return {
    name = "Starfall Requiem",
    audio = {
        asset = "queen", delay = 0.34, duration = 1.55,
        fade = 0.18, volume = 0.74, pitch = 1.02,
    },
    range = 5,
    effectRadius = 1,
    fps = 15,
    frameCount = 17,
    feedback = {
        impactAt = 0.36, duration = 0.50, radius = 1.5, offsetY = -34,
        color = { 0.92, 0.3, 1 },
    },
    layers = {
        {
            image = "assets/skill-effects/combo/arcane-spark.png",
            frameWidth = 32, frameHeight = 32, frameCount = 7, fps = 15,
            scaleFrom = 2.0, scaleTo = 0.9, offsetY = -34, anchor = "source",
        },
        {
            image = "assets/skill-effects/combo/dark-bolt.png",
            frameWidth = 88, frameHeight = 88, frameCount = 8, fps = 15,
            scaleFrom = 0.8, scaleTo = 1.15, offsetY = -34, delay = 0.08,
            directional = true, anchor = "travel", travelDuration = 0.28,
        },
        {
            image = "assets/skill-effects/combo/queen-nova.png",
            frameWidth = 96, frameHeight = 96, frameCount = 10, fps = 15,
            scaleFrom = 1.0, scaleTo = 1.58, offsetY = -38, delay = 0.34,
        },
        {
            image = "assets/skill-effects/combo/queen-sparkle.png",
            frameWidth = 64, frameHeight = 64, frameCount = 17, fps = 15,
            scale = 1.8, offsetY = -36, delay = 0.38,
        },
        {
            image = "assets/skill-effects/combo/arcane-fireworks.png",
            frameWidth = 96, frameHeight = 96, frameCount = 27, columns = 10, fps = 15,
            scale = 1.15, offsetY = -40, delay = 0.45, fadeOut = 0.25,
        },
        {
            image = "assets/skill-effects/sparkle.png",
            frameWidth = 32, frameHeight = 32, frameCount = 14, fps = 15,
            scale = 1.8, offsetY = -38, delay = 0.50, fadeOut = 0.4,
        },
    },
}
