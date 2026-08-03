return {
    name = "Vanguard Breaker",
    audio = {
        asset = "pawn", delay = 0.08, duration = 0.78,
        fade = 0.12, volume = 0.78, pitch = 1.04,
    },
    range = 2,
    effectRadius = 0,
    fps = 15,
    frameCount = 7,
    feedback = {
        impactAt = 0.08, duration = 0.28, radius = 0.72, offsetY = -18,
        color = { 1, 0.78, 0.22 },
    },
    layers = {
        {
            image = "assets/skill-effects/combo/vanguard-flash.png",
            frameWidth = 96, frameHeight = 48, frameCount = 8, columns = 2, fps = 15,
            scale = 0.95, offsetY = -24, directional = true, anchor = "source",
        },
        {
            image = "assets/skill-effects/combo/vanguard-impact.png",
            frameWidth = 140, frameHeight = 50, frameCount = 7, fps = 15,
            scale = 1.25, offsetY = -18, delay = 0.08, directional = true,
        },
        {
            image = "assets/skill-effects/combo/arcane-spark.png",
            frameWidth = 32, frameHeight = 32, frameCount = 7, fps = 15,
            scaleFrom = 1.1, scaleTo = 1.9, offsetY = -20, delay = 0.10,
        },
        {
            image = "assets/skill-effects/sparkle.png",
            frameWidth = 32, frameHeight = 32, frameCount = 14, fps = 15,
            scale = 1.45, offsetY = -22, delay = 0.14, fadeOut = 0.35,
        },
    },
}
