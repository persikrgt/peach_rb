local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- Ожидаем загрузки персонажа
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

-- Создаем основное меню
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GameMenuGui"
screenGui.Parent = playerGui

-- Создаем кнопку для открытия/закрытия меню
local toggleButton = Instance.new("TextButton")
toggleButton.Name = "ToggleMenuButton"
toggleButton.Size = UDim2.new(0, 50, 0, 50)
toggleButton.Position = UDim2.new(0, 20, 0, 20)
toggleButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
toggleButton.Text = "Меню"
toggleButton.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleButton.Font = Enum.Font.SourceSansBold
toggleButton.TextSize = 16
toggleButton.Parent = screenGui

-- Создаем основное меню (изначально скрытое)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainMenuFrame"
mainFrame.Size = UDim2.new(0, 200, 0, 300)
mainFrame.Position = UDim2.new(0, 20, 0, 75)
mainFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
mainFrame.Visible = false
mainFrame.Parent = screenGui

-- Добавляем заголовок меню
local titleLabel = Instance.new("TextLabel")
titleLabel.Name = "MenuTitle"
titleLabel.Size = UDim2.new(1, 0, 0, 30)
titleLabel.Position = UDim2.new(0, 0, 0, 0)
titleLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
titleLabel.Text = "Меню функций"
titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
titleLabel.Font = Enum.Font.SourceSansBold
titleLabel.TextSize = 18
titleLabel.Parent = mainFrame

-- Переменные для функций
local autoJumpEnabled = false
local speedBoostEnabled = false
local jumpConnection = nil
local autoJumpButton = nil
local speedButton = nil
local cooldownButton = nil
local cooldownRemoved = false

-- Функция для создания кнопок в меню
local function createMenuButton(name, text, position, callback)
    local button = Instance.new("TextButton")
    button.Name = name
    button.Size = UDim2.new(0.9, 0, 0, 40)
    button.Position = position
    button.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    button.Text = text
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.SourceSansBold
    button.TextSize = 16
    button.Parent = mainFrame
    
    button.MouseButton1Click:Connect(callback)
    
    -- Анимация при наведении
    button.MouseEnter:Connect(function()
        local tween = TweenService:Create(
            button,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(100, 149, 237)}
        )
        tween:Play()
    end)
    
    button.MouseLeave:Connect(function()
        local color = Color3.fromRGB(65, 105, 225)
        
        -- Проверяем специальные состояния кнопок
        if button.Name == "AutoJumpButton" and autoJumpEnabled then
            color = Color3.fromRGB(50, 205, 50)
        elseif button.Name == "SpeedButton" and speedBoostEnabled then
            color = Color3.fromRGB(255, 140, 0)
        elseif button.Name == "CooldownButton" and cooldownRemoved then
            color = Color3.fromRGB(50, 205, 50)
        end
        
        local tween = TweenService:Create(
            button,
            TweenInfo.new(0.2),
            {BackgroundColor3 = color}
        )
        tween:Play()
    end)
    
    return button
end

-- Функция авто-прыжка
local function toggleAutoJump()
    autoJumpEnabled = not autoJumpEnabled
    
    if autoJumpEnabled then
        -- Включаем авто-прыжки
        if jumpConnection then
            jumpConnection:Disconnect()
        end
        
        jumpConnection = RunService.Heartbeat:Connect(function()
            if autoJumpEnabled and humanoid and humanoid:GetState() ~= Enum.HumanoidStateType.Freefall then
                humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
            end
        end)
        
        -- Обновляем текст кнопки
        autoJumpButton.Text = "Авто-прыжок: ВКЛ"
        autoJumpButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    else
        -- Выключаем авто-прыжки
        if jumpConnection then
            jumpConnection:Disconnect()
        end
        
        -- Обновляем текст кнопки
        autoJumpButton.Text = "Авто-прыжок: ВЫКЛ"
        autoJumpButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    end
end

-- Функция ускорения
local function toggleSpeedBoost()
    speedBoostEnabled = not speedBoostEnabled
    
    if speedBoostEnabled then
        -- Увеличиваем скорость
        if humanoid then
            humanoid.WalkSpeed = 45
        end
        
        -- Обновляем текст кнопки
        speedButton.Text = "Ускорение: ВКЛ"
        speedButton.BackgroundColor3 = Color3.fromRGB(255, 140, 0)
    else
        -- Возвращаем обычную скорость
        if humanoid then
            humanoid.WalkSpeed = 25
        end
        
        -- Обновляем текст кнопки
        speedButton.Text = "Ускорение: ВЫКЛ"
        speedButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
    end
end

-- Улучшенная функция для удаления задержки на использование предметов
local function removeCooldowns()
    if cooldownRemoved then
        return
    end
    
    cooldownRemoved = true
    
    -- Сохраняем оригинальные функции
    local originalWait = task.wait
    local originalSpawn = task.spawn
    local originalDelay = task.delay
    
    -- Заменяем функции задержки
    task.wait = function(seconds)
        if seconds and seconds > 0.1 then
            return originalWait(0)
        end
        return originalWait(seconds)
    end
    
    task.spawn = function(func, ...)
        if type(func) == "function" then
            return originalSpawn(func, ...)
        end
    end
    
    task.delay = function(seconds, func, ...)
        if seconds and seconds > 0.1 then
            return originalSpawn(func, ...)
        end
        return originalDelay(seconds, func, ...)
    end
    
    -- Перехватываем RemoteEvents
    local originalFireServer
    originalFireServer = hookfunction(getupvalue(Instance.new("RemoteEvent").FireServer, 1), function(self, ...)
        if not checkcaller() then
            return originalFireServer(self, ...)
        end
        
        -- Пытаемся определить, является ли это событие задержкой
        local args = {...}
        local shouldBypass = false
        
        -- Проверяем аргументы на наличие информации о задержке
        for _, arg in ipairs(args) do
            if type(arg) == "string" and (arg:lower():find("cooldown") or arg:lower():find("delay")) then
                shouldBypass = true
                break
            end
        end
        
        if shouldBypass then
            -- Пропускаем задержку
            return
        end
        
        return originalFireServer(self, ...)
    end)
    
    -- Перехватываем BindableEvents
    local originalFire
    originalFire = hookfunction(getupvalue(Instance.new("BindableEvent").Fire, 1), function(self, ...)
        if not checkcaller() then
            return originalFire(self, ...)
        end
        
        -- Аналогичная логика для BindableEvents
        local args = {...}
        local shouldBypass = false
        
        for _, arg in ipairs(args) do
            if type(arg) == "string" and (arg:lower():find("cooldown") or arg:lower():find("delay")) then
                shouldBypass = true
                break
            end
        end
        
        if shouldBypass then
            return
        end
        
        return originalFire(self, ...)
    end)
    
    -- Меняем текст кнопки
    cooldownButton.Text = "Задержки убраны!"
    cooldownButton.BackgroundColor3 = Color3.fromRGB(50, 205, 50)
    
    print("Задержки на использование предметов убраны!")
end

-- Функция для безопасного перехвата методов
local function hookfunction(func, newfunc)
    if not func or not newfunc then return end
    
    local function hook(...)
        return newfunc(...)
    end
    
    return setfenv(1, {[func] = hook})[func]
end

-- Функция для проверки, является ли текущий код вызывающим кодом
local function checkcaller()
    return true -- Упрощенная версия, в реальности нужно использовать более сложную логику
end

-- Создаем кнопки меню
local buttonY = 40
autoJumpButton = createMenuButton("AutoJumpButton", "Авто-прыжок: ВЫКЛ", UDim2.new(0.05, 0, 0, buttonY), toggleAutoJump)
buttonY = buttonY + 45

speedButton = createMenuButton("SpeedButton", "Ускорение: ВЫКЛ", UDim2.new(0.05, 0, 0, buttonY), toggleSpeedBoost)
buttonY = buttonY + 45

cooldownButton = createMenuButton("CooldownButton", "Убрать задержки", UDim2.new(0.05, 0, 0, buttonY), removeCooldowns)
buttonY = buttonY + 45

-- Добавляем другие кнопки (заглушки для будущих функций)
createMenuButton("FlyButton", "Полёт", UDim2.new(0.05, 0, 0, buttonY), function()
    -- Заглушка для функции полёта
    print("Функция полёта будет добавлена позже")
end)
buttonY = buttonY + 45

createMenuButton("CloseMenuButton", "Закрыть меню", UDim2.new(0.05, 0, 0, buttonY), function()
    mainFrame.Visible = false
end)

-- Функция для переключения видимости меню
local isMenuOpen = false
toggleButton.MouseButton1Click:Connect(function()
    isMenuOpen = not isMenuOpen
    mainFrame.Visible = isMenuOpen
end)

-- Обработчик для сенсорных устройств
toggleButton.TouchTap:Connect(function()
    isMenuOpen = not isMenuOpen
    mainFrame.Visible = isMenuOpen
end)

-- Добавляем возможность перемещения меню
local dragging = false
local dragInput, dragStart, startPos

local function update(input)
    local delta = input.Position - dragStart
    mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

titleLabel.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

titleLabel.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and (input == dragInput) then
        update(input)
    end
end)

-- Обработчик изменения персонажа
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    
    -- Восстанавливаем состояния функций при смене персонажа
    if autoJumpEnabled then
        if jumpConnection then
            jumpConnection:Disconnect()
        end
        task.wait(1) -- Ждем загрузки персонажа
        toggleAutoJump() -- Перезапускаем авто-прыжок
    end
    
    if speedBoostEnabled then
        task.wait(1) -- Ждем загрузки персонажа
        toggleSpeedBoost() -- Перезапускаем ускорение
    end
    
    -- Сбрасываем статус удаления задержек
    cooldownRemoved = false
    cooldownButton.Text = "Убрать задержки"
    cooldownButton.BackgroundColor3 = Color3.fromRGB(65, 105, 225)
end)

-- Обработчик удаления GUI при выходе из игры
game:GetService("CoreGui").ChildRemoved:Connect(function(child)
    if child == screenGui then
        if jumpConnection then
            jumpConnection:Disconnect()
        end
    end
end)
