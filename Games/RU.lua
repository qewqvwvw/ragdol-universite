--local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local PlayerService = game:GetService("Players")
local Workspace = game:GetService("Workspace")

repeat task.wait() until Workspace:FindFirstChild("Drops") and Workspace:FindFirstChild("Projectiles")

local Camera = Workspace.CurrentCamera
local LocalPlayer = PlayerService.LocalPlayer
local SilentAim, Aimbot, Trigger = nil, false, false
local ProjectileSpeed, ProjectileGravity, GravityCorrection
= 1000, Vector3.new(0, Workspace.Gravity, 0), 2
local Key, KeyEvent = nil, nil

local KnownBodyParts = {
    {"Head", true}, {"Torso", true},
    {"Right Arm", false}, {"Left Arm", false},
    {"Right Leg", false}, {"Left Leg", false}
}

local Window = Parvus.Utilities.UI:Window({
    Name = ("Parvus Hub %s %s"):format(utf8.char(8212), Parvus.Game.Name),
    Position = UDim2.new(0.5, -248 * 3, 0.5, -248)
})

local CombatTab = Window:Tab({Name = "Combat"})
local AimbotSection = CombatTab:Section({Name = "Aimbot", Side = "Left"})
AimbotSection:Toggle({Name = "Enabled", Flag = "Aimbot/Enabled", Value = false})
:Keybind({Flag = "Aimbot/Keybind", Value = "MouseButton2", Mouse = true, DisableToggle = true,
Callback = function(Key, KeyDown) Aimbot = Window.Flags["Aimbot/Enabled"] and KeyDown end})

AimbotSection:Toggle({Name = "Always Enabled", Flag = "Aimbot/AlwaysEnabled", Value = false})
AimbotSection:Toggle({Name = "Prediction", Flag = "Aimbot/Prediction", Value = false})

AimbotSection:Toggle({Name = "Team Check", Flag = "Aimbot/TeamCheck", Value = false})
AimbotSection:Toggle({Name = "Distance Check", Flag = "Aimbot/DistanceCheck", Value = false})
AimbotSection:Toggle({Name = "Visibility Check", Flag = "Aimbot/VisibilityCheck", Value = false})
AimbotSection:Slider({Name = "Sensitivity", Flag = "Aimbot/Sensitivity", Min = 0, Max = 100, Value = 20, Unit = "%"})
AimbotSection:Slider({Name = "Field Of View", Flag = "Aimbot/FOV/Radius", Min = 0, Max = 500, Value = 100, Unit = "r"})
AimbotSection:Slider({Name = "Distance Limit", Flag = "Aimbot/DistanceLimit", Min = 25, Max = 1000, Value = 250, Unit = "studs"})

local PriorityList, BodyPartsList = {{Name = "Closest", Mode = "Button", Value = true}}, {}
for Index, Value in pairs(KnownBodyParts) do
    PriorityList[#PriorityList + 1] = {Name = Value[1], Mode = "Button", Value = false}
    BodyPartsList[#BodyPartsList + 1] = {Name = Value[1], Mode = "Toggle", Value = Value[2]}
end

AimbotSection:Dropdown({Name = "Priority", Flag = "Aimbot/Priority", List = PriorityList})
AimbotSection:Dropdown({Name = "Body Parts", Flag = "Aimbot/BodyParts", List = BodyPartsList})

local AFOVSection = CombatTab:Section({Name = "Aimbot FOV Circle", Side = "Left"})
AFOVSection:Toggle({Name = "Enabled", Flag = "Aimbot/FOV/Enabled", Value = true})
AFOVSection:Toggle({Name = "Filled", Flag = "Aimbot/FOV/Filled", Value = false})
AFOVSection:Colorpicker({Name = "Color", Flag = "Aimbot/FOV/Color", Value = {1, 0.66666662693024, 1, 0.25, false}})
AFOVSection:Slider({Name = "NumSides", Flag = "Aimbot/FOV/NumSides", Min = 3, Max = 100, Value = 14})
AFOVSection:Slider({Name = "Thickness", Flag = "Aimbot/FOV/Thickness", Min = 1, Max = 10, Value = 2})

local SilentAimSection = CombatTab:Section({Name = "Silent Aim", Side = "Right"})
SilentAimSection:Toggle({Name = "Enabled", Flag = "SilentAim/Enabled", Value = false}):Keybind({Mouse = true, Flag = "SilentAim/Keybind"})

SilentAimSection:Toggle({Name = "Team Check", Flag = "SilentAim/TeamCheck", Value = false})
SilentAimSection:Toggle({Name = "Distance Check", Flag = "SilentAim/DistanceCheck", Value = false})
SilentAimSection:Toggle({Name = "Visibility Check", Flag = "SilentAim/VisibilityCheck", Value = false})
SilentAimSection:Slider({Name = "Hit Chance", Flag = "SilentAim/HitChance", Min = 0, Max = 100, Value = 100, Unit = "%"})
SilentAimSection:Slider({Name = "Field Of View", Flag = "SilentAim/FOV/Radius", Min = 0, Max = 500, Value = 100, Unit = "r"})
SilentAimSection:Slider({Name = "Distance Limit", Flag = "SilentAim/DistanceLimit", Min = 25, Max = 1000, Value = 250, Unit = "studs"})

local PriorityList, BodyPartsList = {{Name = "Closest", Mode = "Button", Value = true}, {Name = "Random", Mode = "Button"}}, {}
for Index, Value in pairs(KnownBodyParts) do
    PriorityList[#PriorityList + 1] = {Name = Value[1], Mode = "Button", Value = false}
    BodyPartsList[#BodyPartsList + 1] = {Name = Value[1], Mode = "Toggle", Value = Value[2]}
end

SilentAimSection:Dropdown({Name = "Priority", Flag = "SilentAim/Priority", List = PriorityList})
SilentAimSection:Dropdown({Name = "Body Parts", Flag = "SilentAim/BodyParts", List = BodyPartsList})

local SAFOVSection = CombatTab:Section({Name = "Silent Aim FOV Circle", Side = "Right"})
SAFOVSection:Toggle({Name = "Enabled", Flag = "SilentAim/FOV/Enabled", Value = true})
SAFOVSection:Toggle({Name = "Filled", Flag = "SilentAim/FOV/Filled", Value = false})
SAFOVSection:Colorpicker({Name = "Color", Flag = "SilentAim/FOV/Color",
Value = {0.6666666865348816, 0.6666666269302368, 1, 0.25, false}})
SAFOVSection:Slider({Name = "NumSides", Flag = "SilentAim/FOV/NumSides", Min = 3, Max = 100, Value = 14})
SAFOVSection:Slider({Name = "Thickness", Flag = "SilentAim/FOV/Thickness", Min = 1, Max = 10, Value = 2})

local TriggerSection = CombatTab:Section({Name = "Trigger", Side = "Right"})
TriggerSection:Toggle({Name = "Enabled", Flag = "Trigger/Enabled", Value = false})
:Keybind({Flag = "Trigger/Keybind", Value = "MouseButton2", Mouse = true, DisableToggle = true,
Callback = function(Key, KeyDown) Trigger = Window.Flags["Trigger/Enabled"] and KeyDown end})

TriggerSection:Toggle({Name = "Always Enabled", Flag = "Trigger/AlwaysEnabled", Value = false})
TriggerSection:Toggle({Name = "Hold Mouse Button", Flag = "Trigger/HoldMouseButton", Value = false})
TriggerSection:Toggle({Name = "Prediction", Flag = "Trigger/Prediction", Value = false})

TriggerSection:Toggle({Name = "Team Check", Flag = "Trigger/TeamCheck", Value = false})
TriggerSection:Toggle({Name = "Distance Check", Flag = "Trigger/DistanceCheck", Value = false})
TriggerSection:Toggle({Name = "Visibility Check", Flag = "Trigger/VisibilityCheck", Value = false})

TriggerSection:Slider({Name = "Click Delay", Flag = "Trigger/Delay", Min = 0, Max = 1, Precise = 2, Value = 0.15, Unit = "sec"})
TriggerSection:Slider({Name = "Distance Limit", Flag = "Trigger/DistanceLimit", Min = 25, Max = 1000, Value = 250, Unit = "studs"})
TriggerSection:Slider({Name = "Field Of View", Flag = "Trigger/FOV/Radius", Min = 0, Max = 500, Value = 25, Unit = "r"})

local PriorityList, BodyPartsList = {{Name = "Closest", Mode = "Button", Value = true}, {Name = "Random", Mode = "Button"}}, {}
for Index, Value in pairs(KnownBodyParts) do
    PriorityList[#PriorityList + 1] = {Name = Value[1], Mode = "Button", Value = false}
    BodyPartsList[#BodyPartsList + 1] = {Name = Value[1], Mode = "Toggle", Value = Value[2]}
end

TriggerSection:Dropdown({Name = "Priority", Flag = "Trigger/Priority", List = PriorityList})
TriggerSection:Dropdown({Name = "Body Parts", Flag = "Trigger/BodyParts", List = BodyPartsList})

local TFOVSection = CombatTab:Section({Name = "Trigger FOV Circle", Side = "Left"})
TFOVSection:Toggle({Name = "Enabled", Flag = "Trigger/FOV/Enabled", Value = true})
TFOVSection:Toggle({Name = "Filled", Flag = "Trigger/FOV/Filled", Value = false})
TFOVSection:Colorpicker({Name = "Color", Flag = "Trigger/FOV/Color", Value = {0.0833333358168602, 0.6666666269302368, 1, 0.25, false}})
TFOVSection:Slider({Name = "NumSides", Flag = "Trigger/FOV/NumSides", Min = 3, Max = 100, Value = 14})
TFOVSection:Slider({Name = "Thickness", Flag = "Trigger/FOV/Thickness", Min = 1, Max = 10, Value = 2})

local VisualsTab = Window:Tab({Name = "Visuals"})
local PlayerESPSection = VisualsTab:Section({Name = "Player ESP", Side = "Left"})
PlayerESPSection:Toggle({Name = "Enabled", Flag = "ESP/Player/Enabled", Value = true})
PlayerESPSection:Colorpicker({Name = "Ally Color", Flag = "ESP/Player/Ally", Value = {0.3333333432674408, 0.6666666269302368, 1, 0, false}})
PlayerESPSection:Colorpicker({Name = "Enemy Color", Flag = "ESP/Player/Enemy", Value = {1, 0.6666666269302368, 1, 0, false}})
PlayerESPSection:Toggle({Name = "Team Check", Flag = "ESP/Player/TeamCheck", Value = true})
PlayerESPSection:Toggle({Name = "Use Player Color", Flag = "ESP/Player/TeamColor", Value = false})
PlayerESPSection:Toggle({Name = "Distance Check", Flag = "ESP/Player/DistanceCheck", Value = false})
PlayerESPSection:Slider({Name = "Distance", Flag = "ESP/Player/Distance", Min = 25, Max = 1000, Value = 250, Unit = "studs"})
PlayerESPSection:Toggle({Name = "Box", Flag = "ESP/Player/Box", Value = true})
PlayerESPSection:Toggle({Name = "Name", Flag = "ESP/Player/Name", Value = true})
PlayerESPSection:Toggle({Name = "Health", Flag = "ESP/Player/Health", Value = true})
PlayerESPSection:Toggle({Name = "Distance Text", Flag = "ESP/Player/DistanceText", Value = true})
PlayerESPSection:Toggle({Name = "Tracers", Flag = "ESP/Player/Tracers", Value = false})
PlayerESPSection:Toggle({Name = "Head Dot", Flag = "ESP/Player/HeadDot", Value = false})

local SettingsTab = Window:Tab({Name = "Settings"})
local SettingsSection = SettingsTab:Section({Name = "Menu Settings", Side = "Left"})
SettingsSection:Keybind({Name = "Menu Keybind", Flag = "Menu/Keybind", Value = "RightShift"})

-- Setup functions
Parvus.Utilities.Drawing.SetupFOV("Aimbot", Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("Trigger", Window.Flags)
Parvus.Utilities.Drawing.SetupFOV("SilentAim", Window.Flags)

-- [ВЕСЬ ОСТАЛЬНОЙ КОД (функции Raycast, InEnemyTeam и т.д.) ОСТАВИТЬ КАК ЕСТЬ]
-- ... остальная часть файла без изменений ...
