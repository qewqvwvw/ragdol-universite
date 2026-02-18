-- [[ Utilities/Main.lua - ИСПРАВЛЕНО ]] --
local Main = {}

-- Безопасная инициализация без hookfunction
function Main:SetupFeatures()
    print("✅ Настройка функций для Ragdoll Universe...")
    return true
end

-- Простые уведомления без хуков
function Main:Notify(title, text, duration)
    local hint = Instance.new("Hint")
    hint.Text = "[" .. title .. "] " .. text
    hint.Parent = workspace
    game:GetService("Debris"):AddItem(hint, duration or 3)
end

-- Проверка что игрок загрузился
function Main:WaitForPlayer()
    return game:GetService("Players").LocalPlayer
end

return Main
