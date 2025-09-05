local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

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
    button.TouchTap:Connect(function()
        callback()
    end)
    
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
        local tween = TweenService:Create(
            button,
            TweenInfo.new(0.2),
            {BackgroundColor3 = Color3.fromRGB(65, 105, 225)}
        )
        tween:Play()
    end)
    
    return button
end

-- Переменные для функций
local autoJumpEnabled = false
local jumpConnection = nil

-- Функция авто-прыжка
local function toggleAutoJump()
    autoJumpEnabled = not autoJumpEnabled
    
    if autoJumpEnabled then
        -- Включаем авто-прыжки
        local character = player.Character or player.CharacterAdded:Wait()
        local humanoid = character:WaitForChild("Humanoid")
        
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

-- Создаем кнопки меню
local buttonY = 40
local autoJumpButton = createMenuButton("AutoJumpButton", "Авто-прыжок: ВЫКЛ", UDim2.new(0.05, 0, 0, buttonY), toggleAutoJump)
buttonY = buttonY + 45

-- Добавляем другие кнопки (заглушки для будущих функций)
createMenuButton("Feature1Button", "Функция 1", UDim2.new(0.05, 0, 0, buttonY), function()
    print("Функция 1 активирована")
end)
buttonY = buttonY + 45

createMenuButton("Feature2Button", "Функция 2", UDim2.new(0.05, 0, 0, buttonY), function()
    print("Функция 2 активирована")
end)
buttonY = buttonY + 45

createMenuButton("Feature3Button", "Функция 3", UDim2.new(0.05, 0, 0, buttonY), function()
    print("Функция 3 активирована")
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
player.CharacterAdded:Connect(function(character)
    if autoJumpEnabled and jumpConnection then
        jumpConnection:Disconnect()
        wait(1) -- Ждем загрузки персонажа
        toggleAutoJump() -- Перезапускаем авто-прыжок
    end
end)
