-- Loader.lua - ИСПРАВЛЕНО
-- by @ingamekid

print("🔥 RAGDOLL UNIVERSE by @ingamekid")
print("🔄 Загрузка...")

-- Функция безопасной загрузки модулей
local function loadModule(path)
    local success, result = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/qewqvwvw/ragdol-universite/main/" .. path)
    end)
    if success and result then
        local func, err = loadstring(result, path)
        if func then
            return func()
        else
            warn("❌ Ошибка в " .. path .. ": " .. err)
        end
    else
        warn("❌ Не удалось загрузить " .. path)
    end
    return nil
end

-- Загружаем модули
local Main = loadModule("Utilities/Main.lua")
local Ragdoll = loadModule("Games/RU.lua")
local Universal = loadModule("Universal.lua")

-- Проверяем загрузку
if Main and Ragdoll then
    print("✅ Модули загружены!")
    
    -- Если есть функция инициализации в Main, вызываем её
    if Main.Initialize then
        Main.Initialize()
    end
    
    print("✅ Скрипт готов к работе!")
else
    warn("❌ Не удалось загрузить модули")
end

print("✅ Репозиторий @ingamekid загружен!")
