repeat task.wait() until game.IsLoaded
repeat task.wait() until game.GameId ~= 0

if Parvus and Parvus.Loaded then
    Parvus.Utilities.UI:Push({
        Title = "Varus Hub",
        Description = "Script already running!",
        Duration = 5
    }) return
end

--[[if Parvus and (Parvus.Game and not Parvus.Loaded) then
    Parvus.Utilities.UI:Push({
        Title = "Varus Hub",
        Description = "Something went wrong!",
        Duration = 5
    }) return
end]]

local PlayerService = game:GetService("Players")
repeat task.wait() until PlayerService.LocalPlayer
local LocalPlayer = PlayerService.LocalPlayer

local Branch, NotificationTime, IsLocal = ...
--local ClearTeleportQueue = clear_teleport_queue
local QueueOnTeleport = queue_on_teleport

local function GetFile(File)
    return IsLocal and readfile("Parvus/" .. File)
    or game:HttpGet(("%s%s"):format(Parvus.Source, File))
end

local function LoadScript(Script)
    return loadstring(GetFile(Script .. ".lua"), Script)()
end

local function IsDeadlineGame()
    -- Check for Deadline-specific identifiers
    local Workspace = game:GetService("Workspace")
    
    -- Check if "characters" folder exists (Deadline-specific identifier)
    local charactersFolder = Workspace:FindFirstChild("characters")
    if charactersFolder then
        return true
    end
    
    -- Try waiting for it with a short timeout
    local success, result = pcall(function()
        return Workspace:WaitForChild("characters", 3)
    end)
    
    return success and result ~= nil
end

local function GetGameInfo()
    -- Special check for Deadline - verify it's actually Deadline before loading
    if tostring(game.GameId) == "12144402492" then
        if IsDeadlineGame() then
            return Parvus.Games["12144402492"]
        else
            -- Game ID matches but structure doesn't match Deadline
            -- Fall back to Universal instead
            warn("Game ID matches Deadline but game structure doesn't match. Loading Universal instead.")
            return Parvus.Games.Universal
        end
    end
    
    for Id, Info in pairs(Parvus.Games) do
        if tostring(game.GameId) == Id then
            return Info
        end
    end

    return Parvus.Games.Universal
end

getgenv().Parvus = {
    Source = "-- Loader.lua
-- Loader.lua
local function loadModule(path)
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/qewqvwvw/ragdol-universite/main/" .. path)
    end)
    if success and result then
        local func, err = loadstring(result, path)
        if func then
            return func()
        else
            warn("Ошибка в " .. path .. ": " .. err)
        end
    else
        warn("Не удалось загрузить " .. path)
    end
    return nil
end

local Main = loadModule("Utilities/Main.lua")
local Ragdoll = loadModule("Games/RU.lua")
loadModule("Universal.lua")

print("✅ Репозиторий @ingamekid загружен!")

    Games = {
        ["580765040" ] = { Name = "RAGDOLL UNIVERSE",           Script = "Games/RU"   }
    }
}

Parvus.Utilities = LoadScript("Utilities/Main")
Parvus.Utilities.UI = LoadScript("Utilities/UI")
Parvus.Utilities.Physics = LoadScript("Utilities/Physics")
Parvus.Utilities.Drawing = LoadScript("Utilities/Drawing")

Parvus.Cursor = GetFile("Utilities/ArrowCursor.png")
Parvus.Loadstring = GetFile("Utilities/Loadstring")
Parvus.Loadstring = Parvus.Loadstring:format(
    Parvus.Source, Branch, NotificationTime, tostring(IsLocal)
)

LocalPlayer.OnTeleport:Connect(function(State)
    if State == Enum.TeleportState.InProgress then
        --ClearTeleportQueue()
        QueueOnTeleport(Parvus.Loadstring)
    end
end)

Parvus.Game = GetGameInfo()
LoadScript(Parvus.Game.Script)
Parvus.Loaded = true

Parvus.Utilities.UI:Push({
    Title = "Varus Hub",
    Description = Parvus.Game.Name .. " loaded! \n This Script Was Made By Ayham.",
    Duration = NotificationTime
})

