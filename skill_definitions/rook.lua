return {
    name = "Siege Breaker",
    audio = {
        asset = "rook", delay = 0.26, duration = 0.88,
        fade = 0.14, volume = 0.76, pitch = 1.04,
    },
    range = 6,
    effectRadius = 1,
    fps = 15,
    frameCount = 14,
    feedback = {
        impactAt = 0.28, duration = 0.48, radius = 1.55, offsetY = -28,
        color = { 1, 0.45, 0.12 },
    },
    layers = {
        {
            image = "assets/skill-effects/combo/vanguard-flash.png",
            frameWidth = 96, frameHeight = 48, frameCount = 8, columns = 2, fps = 15,
            scale = 0.82, offsetY = -28, directional = true, anchor = "source",
        },
        {
            image = "assets/skill-effects/impact.png",
            frameWidth = 70, frameHeight = 25, frameCount = 7, fps = 15,
            scaleFrom = 1.0, scaleTo = 1.45, offsetY = -26, delay = 0.04,
            directional = true, anchor = "travel", travelDuration = 0.22,
        },
        {
            image = "assets/skill-effects/royal-calamity/crown-firebomb.png",
            frameWidth = 64, frameHeight = 64, frameCount = 14, fps = 15,
            scale = 1.45, offsetY = -24, delay = 0.24,
        },
        {
            image = "assets/skill-effects/combo/siege-explosion.png",
            frameWidth = 96, frameHeight = 96, frameCount = 12, fps = 15,
            scaleFrom = 1.05, scaleTo = 1.48, offsetY = -32, delay = 0.30,
        },
        {
            image = "assets/skill-effects/royal-calamity/impact-burst.png",
            frameWidth = 160, frameHeight = 160, frameCount = 8, fps = 15,
            scale = 1.15, offsetY = -36, delay = 0.36,
        },
        {
            image = "assets/skill-effects/explosion.png",
            frameWidth = 48, frameHeight = 48, frameCount = 10, fps = 15,
            scale = 2.25, offsetY = -28, delay = 0.40,
        },
    },
}
