-- Pet Lab v1: панель локального изменения WalkSpeed
local Players = game:GetService("Players")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local oldGui = playerGui:FindFirstChild("PetLabSpeed")
local oldDefault = oldGui and oldGui:GetAttribute("DefaultWalkSpeed")
if oldGui then oldGui:Destroy() end

local function humanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local current = humanoid()
local defaultSpeed = tonumber(oldDefault) or (current and current.WalkSpeed) or 16

local gui = Instance.new("ScreenGui")
gui.Name = "PetLabSpeed"
gui.ResetOnSpawn = false
gui.DisplayOrder = 9000
gui:SetAttribute("DefaultWalkSpeed", defaultSpeed)
gui.Parent = playerGui

local panel = Instance.new("Frame")
panel.Size = UDim2.fromOffset(360, 244)
panel.Position = UDim2.new(0.5, -180, 0.5, -122)
panel.BackgroundColor3 = Color3.fromRGB(25, 29, 40)
panel.BorderSizePixel = 0
panel.Parent = gui
Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 12)

local function element(class, label, x, y, w, h)
    local item = Instance.new(class)
    item.Size = UDim2.fromOffset(w, h)
    item.Position = UDim2.fromOffset(x, y)
    item.Font = Enum.Font.Gotham
    item.Text = label
    item.TextSize = 15
    item.TextColor3 = Color3.fromRGB(240, 243, 248)
    item.BackgroundTransparency = 1
    item.Parent = panel
    return item
end

local title = element("TextLabel", "PET LAB  |  SPEED", 16, 10, 328, 34)
title.Font = Enum.Font.GothamBold
title.TextSize = 19
title.TextXAlignment = Enum.TextXAlignment.Left

local status = element("TextLabel", "", 16, 49, 328, 30)
status.TextXAlignment = Enum.TextXAlignment.Left

local function button(label, x, y, w, h, callback)
    local b = element("TextButton", label, x, y, w, h)
    b.Font = Enum.Font.GothamBold
    b.BackgroundTransparency = 0
    b.BackgroundColor3 = Color3.fromRGB(58, 112, 189)
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
    b.Activated:Connect(callback)
    return b
end

local input = element("TextBox", tostring(defaultSpeed), 16, 139, 166, 38)
input.BackgroundTransparency = 0
input.BackgroundColor3 = Color3.fromRGB(42, 48, 64)
input.ClearTextOnFocus = false
input.PlaceholderText = "Скорость от 1 до 100"
Instance.new("UICorner", input).CornerRadius = UDim.new(0, 8)

local function refresh()
    local h = humanoid()
    status.Text = h and ("Текущая скорость: " .. tostring(h.WalkSpeed))
        or "Персонаж ещё не загружен"
end

local function setSpeed(value)
    local speed = tonumber(value)
    if not speed or speed < 1 or speed > 100 then
        status.Text = "Введи число от 1 до 100"
        return
    end
    local h = humanoid()
    if not h then
        status.Text = "Humanoid не найден"
        return
    end
    h.WalkSpeed = speed
    input.Text = tostring(speed)
    refresh()
    print("[PET LAB] Speed:", speed)
end

button("16", 16, 91, 102, 36, function() setSpeed(16) end)
button("28", 129, 91, 102, 36, function() setSpeed(28) end)
button("48", 242, 91, 102, 36, function() setSpeed(48) end)
button("ПРИМЕНИТЬ", 194, 139, 150, 38, function() setSpeed(input.Text) end)
button("СБРОС", 16, 191, 158, 36, function() setSpeed(defaultSpeed) end)
button("ЗАКРЫТЬ", 186, 191, 158, 36, function()
    setSpeed(defaultSpeed)
    gui:Destroy()
end)

local characterConnection
characterConnection = player.CharacterAdded:Connect(function(character)
    local h = character:WaitForChild("Humanoid", 10)
    if h and gui.Parent then
        defaultSpeed = h.WalkSpeed
        gui:SetAttribute("DefaultWalkSpeed", defaultSpeed)
        input.Text = tostring(defaultSpeed)
        refresh()
    end
end)

gui.Destroying:Connect(function()
    if characterConnection then characterConnection:Disconnect() end
end)

refresh()
print("[PET LAB] Speed panel ready")
