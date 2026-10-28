local SoundService = game:GetService("SoundService")

local ok, Rayfield = pcall(function()
    return loadstring(game:HttpGet(
        "https://sirius.menu/rayfield"
    ))()
end)

if not ok or not Rayfield then
    warn("Не удалось загрузить Rayfield")
    return
end

local Window = Rayfield:CreateWindow({
    Name = "Boombox Hub",
    LoadingTitle = "Boombox Hub",
    LoadingSubtitle = "Audio Player",
    ConfigurationSaving = {Enabled = false},
    Discord = {Enabled = false},
    KeySystem = false
})

local Tab = Window:CreateTab("Boombox", 4483362458)
local Settings = Window:CreateTab("Настройки", 4483362458)

local audioId = ""
local volume = 0.5
local loopEnabled = false
local paused = false

local sound = Instance.new("Sound")
sound.Name = "BoomboxHubSound"
sound.Volume = volume
sound.Looped = loopEnabled
sound.Parent = SoundService

local function notify(title, content)
    Rayfield:Notify({
        Title = title,
        Content = content,
        Duration = 3
    })
end

local function play()
    local id = audioId:match("^%s*(.-)%s*$")
    id = id and (
        id:match("^rbxassetid://(%d+)$")
        or id:match("^(%d+)$")
    )

    if not id or id == "0" then
        notify("Ошибка", "Введи корректный Audio ID")
        return
    end

    local success, err = pcall(function()
        sound:Stop()
        sound.SoundId = "rbxassetid://" .. id
        sound.Volume = volume
        sound.Looped = loopEnabled
        sound.TimePosition = 0
        sound:Play()
    end)

    if success then
        paused = false
        notify("Boombox Hub", "Запуск ID: " .. id)
    else
        notify("Ошибка", tostring(err))
    end
end

Tab:CreateInput({
    Name = "Roblox Audio ID",
    PlaceholderText = "Вставь ID песни",
    RemoveTextAfterFocusLost = false,
    Callback = function(value)
        audioId = value
    end
})

Tab:CreateButton({
    Name = "▶ Play",
    Callback = play
})

Tab:CreateToggle({
    Name = "🔁 Loop",
    CurrentValue = false,
    Flag = "BoomboxLoop",
    Callback = function(value)
        loopEnabled = value
        sound.Looped = value

        notify(
            "Boombox Hub",
            value and "Loop включён" or "Loop выключен"
        )
    end
})

Tab:CreateButton({
    Name = "■ Stop",
    Callback = function()
        sound:Stop()
        paused = false
        notify("Boombox Hub", "Музыка остановлена")
    end
})

Tab:CreateButton({
    Name = "⏯ Pause / Resume",
    Callback = function()
        if sound.IsPlaying then
            sound:Pause()
            paused = true
            notify("Boombox Hub", "Пауза")
        elseif paused then
            sound:Resume()
            paused = false
            notify("Boombox Hub", "Продолжение")
        else
            notify("Boombox Hub", "Сначала нажми Play")
        end
    end
})

Tab:CreateButton({
    Name = "ℹ Текущий Audio ID",
    Callback = function()
        notify(
            "Audio ID",
            audioId ~= "" and audioId or "ID не задан"
        )
    end
})

Settings:CreateSlider({
    Name = "Громкость",
    Range = {0, 100},
    Increment = 5,
    Suffix = "%",
    CurrentValue = 50,
    Callback = function(value)
        volume = value / 100
        sound.Volume = volume
    end
})

Settings:CreateButton({
    Name = "Остановить звук",
    Callback = function()
        sound:Stop()
        paused = false
        notify("Настройки", "Воспроизведение остановлено")
    end
})

Rayfield:Notify({
    Title = "Boombox Hub",
    Content = "Загружен! Loop доступен.",
    Duration = 4
})
