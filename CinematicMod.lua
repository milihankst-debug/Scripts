--[[
    RobloxSuperScripts
    Cinematic Hub v1.1
    Rayfield UI
]]

local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local Rayfield = loadstring(
    game:HttpGet("https://sirius.menu/rayfield")
)()

local Window = Rayfield:CreateWindow({
    Name = "RobloxSuperScripts | Cinematic Hub",
    LoadingTitle = "Cinematic Hub v1.1",
    LoadingSubtitle = "by RobloxSuperScripts",
    Theme = "Default",
    ToggleUIKeybind = "K",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "RobloxSuperScripts",
        FileName = "CinematicHub"
    },
    KeySystem = false
})

local CameraTab = Window:CreateTab("Camera", 4483362458)
local GraphicsTab = Window:CreateTab("Graphics", 4483362458)
local EffectsTab = Window:CreateTab("Effects", 4483362458)
local SettingsTab = Window:CreateTab("Settings", 4483362458)

local function Notify(message)
    Rayfield:Notify({
        Title = "Cinematic Hub",
        Content = message,
        Duration = 3
    })
end

-- STATE

local OriginalFOV = workspace.CurrentCamera
    and workspace.CurrentCamera.FieldOfView or 70

local OriginalBrightness = Lighting.Brightness

local ShakeEnabled = false
local ShakeIntensity = 0.5
local ShakeSpeed = 15
local ShakeTime = 0

local BarsGui
local ColorEffect
local BloomEffect
local AtmosphereEffect
local DOFEffect

local function GetCamera()
    return workspace.CurrentCamera
end

-- CAMERA SHAKE

local function StopShake()
    ShakeEnabled = false

    pcall(function()
        RunService:UnbindFromRenderStep("RSS_CinematicShake")
    end)
end

local function StartShake()
    StopShake()
    ShakeEnabled = true
    ShakeTime = 0

    RunService:BindToRenderStep(
        "RSS_CinematicShake",
        Enum.RenderPriority.Camera.Value + 1,
        function(dt)
            if not ShakeEnabled then
                return
            end

            local Camera = GetCamera()
            if not Camera then
                return
            end

            ShakeTime += dt

            local Strength = ShakeIntensity * 0.12
            local Speed = ShakeSpeed

            local X = math.noise(ShakeTime * Speed, 0, 0)
            local Y = math.noise(0, ShakeTime * Speed, 0)
            local Z = math.noise(0, 0, ShakeTime * Speed)

            Camera.CFrame = Camera.CFrame * CFrame.new(
                X * Strength,
                Y * Strength,
                Z * Strength * 0.25
            )
        end
    )
end

CameraTab:CreateSection("Camera Settings")

CameraTab:CreateSlider({
    Name = "Field of View",
    Range = {40, 120},
    Increment = 1,
    CurrentValue = 70,
    Callback = function(value)
        local camera = GetCamera()
        if camera then
            TweenService:Create(
                camera,
                TweenInfo.new(0.2),
                {FieldOfView = value}
            ):Play()
        end
    end
})

CameraTab:CreateSlider({
    Name = "Shake Intensity",
    Range = {0, 100},
    Increment = 1,
    CurrentValue = 50,
    Callback = function(value)
        ShakeIntensity = value / 100
    end
})

CameraTab:CreateSlider({
    Name = "Shake Speed",
    Range = {1, 30},
    Increment = 1,
    CurrentValue = 15,
    Callback = function(value)
        ShakeSpeed = value
    end
})

CameraTab:CreateToggle({
    Name = "Camera Shake PRO",
    CurrentValue = false,
    Callback = function(value)
        if value then
            StartShake()
            Notify("Camera Shake enabled!")
        else
            StopShake()
            Notify("Camera Shake disabled!")
        end
    end
})

CameraTab:CreateButton({
    Name = "Preset: Cinematic",
    Callback = function()
        ShakeIntensity = 0.15
        ShakeSpeed = 5
        Notify("Cinematic preset selected!")
    end
})

CameraTab:CreateButton({
    Name = "Preset: Earthquake",
    Callback = function()
        ShakeIntensity = 1
        ShakeSpeed = 25
        Notify("Earthquake preset selected!")
    end
})

CameraTab:CreateButton({
    Name = "Reset Camera",
    Callback = function()
        StopShake()

        local camera = GetCamera()
        if camera then
            camera.FieldOfView = OriginalFOV
        end

        Notify("Camera reset!")
    end
})

-- GRAPHICS

GraphicsTab:CreateSection("Lighting Effects")

GraphicsTab:CreateToggle({
    Name = "Sunset Filter",
    CurrentValue = false,
    Callback = function(value)
        if value then
            ColorEffect = Instance.new("ColorCorrectionEffect")
            ColorEffect.Name = "RSS_CinematicColor"
            ColorEffect.TintColor = Color3.fromRGB(255, 205, 160)
            ColorEffect.Saturation = 0.15
            ColorEffect.Contrast = 0.1
            ColorEffect.Parent = Lighting
        elseif ColorEffect then
            ColorEffect:Destroy()
            ColorEffect = nil
        end
    end
})

GraphicsTab:CreateToggle({
    Name = "Bloom",
    CurrentValue = false,
    Callback = function(value)
        if value then
            BloomEffect = Instance.new("BloomEffect")
            BloomEffect.Name = "RSS_CinematicBloom"
            BloomEffect.Intensity = 0.6
            BloomEffect.Size = 32
            BloomEffect.Threshold = 1
            BloomEffect.Parent = Lighting
        elseif BloomEffect then
            BloomEffect:Destroy()
            BloomEffect = nil
        end
    end
})

GraphicsTab:CreateToggle({
    Name = "Atmosphere",
    CurrentValue = false,
    Callback = function(value)
        if value then
            AtmosphereEffect = Instance.new("Atmosphere")
            AtmosphereEffect.Name = "RSS_CinematicAtmosphere"
            AtmosphereEffect.Density = 0.25
            AtmosphereEffect.Haze = 1.5
            AtmosphereEffect.Glare = 0.15
            AtmosphereEffect.Parent = Lighting
        elseif AtmosphereEffect then
            AtmosphereEffect:Destroy()
            AtmosphereEffect = nil
        end
    end
})

GraphicsTab:CreateSlider({
    Name = "Brightness",
    Range = {0, 5},
    Increment = 0.1,
    CurrentValue = OriginalBrightness,
    Callback = function(value)
        Lighting.Brightness = value
    end
})

-- CINEMATIC BARS

EffectsTab:CreateSection("Cinematic Effects")

EffectsTab:CreateToggle({
    Name = "Cinematic Bars",
    CurrentValue = false,
    Callback = function(value)
        if BarsGui then
            BarsGui:Destroy()
            BarsGui = nil
        end

        if value then
            BarsGui = Instance.new("ScreenGui")
            BarsGui.Name = "RSS_CinematicBars"
            BarsGui.IgnoreGuiInset = true
            BarsGui.ResetOnSpawn = false
            BarsGui.DisplayOrder = 100
            BarsGui.Parent = PlayerGui

            for _, data in ipairs({
                {
                    Name = "TopBar",
                    Position = UDim2.new(0, 0, 0, 0)
                },
                {
                    Name = "BottomBar",
                    Position = UDim2.new(0, 0, 0.9, 0)
                }
            }) do
                local bar = Instance.new("Frame")
                bar.Name = data.Name
                bar.Size = UDim2.new(1, 0, 0.1, 0)
                bar.Position = data.Position
                bar.BackgroundColor3 = Color3.new(0, 0, 0)
                bar.BorderSizePixel = 0
                bar.Parent = BarsGui
            end

            Notify("Cinematic Bars enabled!")
        end
    end
})

EffectsTab:CreateToggle({
    Name = "Depth of Field",
    CurrentValue = false,
    Callback = function(value)
        if value then
            DOFEffect = Instance.new("DepthOfFieldEffect")
            DOFEffect.Name = "RSS_CinematicDOF"
            DOFEffect.FarIntensity = 0.2
            DOFEffect.FocusDistance = 25
            DOFEffect.InFocusRadius = 20
            DOFEffect.NearIntensity = 0.1
            DOFEffect.Parent = Lighting
        elseif DOFEffect then
            DOFEffect:Destroy()
            DOFEffect = nil
        end
    end
})

-- SETTINGS

SettingsTab:CreateSection("General")

SettingsTab:CreateParagraph({
    Title = "RobloxSuperScripts",
    Content = "Cinematic Hub v1.1\nCamera, lighting and cinematic effects."
})

SettingsTab:CreateButton({
    Name = "Reset All Effects",
    Callback = function()
        StopShake()

        if BarsGui then
            BarsGui:Destroy()
            BarsGui = nil
        end

        for _, effect in ipairs({
            ColorEffect,
            BloomEffect,
            AtmosphereEffect,
            DOFEffect
        }) do
            if effect then
                effect:Destroy()
            end
        end

        ColorEffect = nil
        BloomEffect = nil
        AtmosphereEffect = nil
        DOFEffect = nil

        Lighting.Brightness = OriginalBrightness

        local camera = GetCamera()
        if camera then
            camera.FieldOfView = OriginalFOV
        end

        Notify("All effects reset!")
    end
})

Rayfield:Notify({
    Title = "Cinematic Hub v1.1",
    Content = "RobloxSuperScripts loaded successfully!",
    Duration = 5
})

Rayfield:LoadConfiguration()
