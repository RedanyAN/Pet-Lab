-- Pet Lab v0.2 | Темная панель с разделами (клиентский Luau)
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

local old = playerGui:FindFirstChild("PetLabMenu")
local legacy = playerGui:FindFirstChild("PetLabSpeed")
local previousDefault = (old and old:GetAttribute("DefaultWalkSpeed"))
    or (legacy and legacy:GetAttribute("DefaultWalkSpeed"))
if old then old:Destroy() end
if legacy then legacy:Destroy() end

local function humanoid()
    local character = player.Character
    return character and character:FindFirstChildOfClass("Humanoid")
end

local function rootPart()
    local character = player.Character
    return character and character:FindFirstChild("HumanoidRootPart")
end

local h = humanoid()
local originalSpeed = tonumber(previousDefault) or (h and h.WalkSpeed) or 16
local savedCFrame = nil
local activePage = "Главная"
local minimized = false
local closed = false

local C = {
    bg = Color3.fromRGB(14, 18, 27),
    sidebar = Color3.fromRGB(18, 23, 34),
    header = Color3.fromRGB(23, 29, 42),
    surface = Color3.fromRGB(25, 32, 46),
    input = Color3.fromRGB(34, 42, 59),
    line = Color3.fromRGB(49, 61, 78),
    blue = Color3.fromRGB(79, 143, 248),
    blueDim = Color3.fromRGB(35, 69, 115),
    white = Color3.fromRGB(236, 241, 250),
    gray = Color3.fromRGB(148, 163, 186),
    green = Color3.fromRGB(107, 215, 162)
}

local function make(class, parent, values)
    local obj = Instance.new(class)
    for property, value in pairs(values or {}) do
        obj[property] = value
    end
    obj.Parent = parent
    return obj
end

local function round(obj, pixels)
    make("UICorner", obj, {CornerRadius = UDim.new(0, pixels)})
    return obj
end

local function label(parent, text, x, y, width, height, color, fontSize)
    return make("TextLabel", parent, {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundTransparency = 1,
        Text = text,
        TextColor3 = color or C.white,
        TextSize = fontSize or 15,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Center,
        TextWrapped = true,
        Font = Enum.Font.Gotham
    })
end

local function button(parent, text, x, y, width, height, callback, subtle)
    local b = make("TextButton", parent, {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = subtle and C.input or C.blueDim,
        AutoButtonColor = true,
        Text = text,
        TextColor3 = C.white,
        Font = Enum.Font.GothamBold,
        TextSize = 14
    })
    round(b, 8)
    b.Activated:Connect(callback)
    return b
end

local function entry(parent, text, x, y, width, height, placeholder)
    local e = make("TextBox", parent, {
        Position = UDim2.fromOffset(x, y),
        Size = UDim2.fromOffset(width, height),
        BackgroundColor3 = C.input,
        Text = text,
        ClearTextOnFocus = false,
        TextColor3 = C.white,
        PlaceholderText = placeholder or "",
        PlaceholderColor3 = C.gray,
        TextSize = 15,
        Font = Enum.Font.Gotham
    })
    round(e, 8)
    return e
end

local gui = make("ScreenGui", playerGui, {
    Name = "PetLabMenu",
    ResetOnSpawn = false,
    DisplayOrder = 9000
})
gui:SetAttribute("DefaultWalkSpeed", originalSpeed)

local panel = make("Frame", gui, {
    Name = "Panel",
    Position = UDim2.new(0.5, -380, 0.5, -245),
    Size = UDim2.fromOffset(760, 490),
    BackgroundColor3 = C.bg,
    BorderSizePixel = 0
})
round(panel, 12)
make("UIStroke", panel, {Color = C.line, Thickness = 1})

local header = make("Frame", panel, {
    Position = UDim2.fromOffset(1, 1),
    Size = UDim2.new(1, -2, 0, 53),
    BackgroundColor3 = C.header,
    BorderSizePixel = 0
})
round(header, 11)
local headerFix = make("Frame", header, {
    Position = UDim2.new(0, 0, 1, -12),
    Size = UDim2.new(1, 0, 0, 12),
    BackgroundColor3 = C.header,
    BorderSizePixel = 0
})
local brand = label(header, "PET LAB", 22, 7, 158, 38, C.white, 21)
brand.Font = Enum.Font.GothamBold
label(header, "CLIENT TOOLS  /  v0.2", 154, 9, 330, 34, C.gray, 12)

local minimizeButton = button(header, "−", 675, 9, 34, 34, function() end, true)
local closeButton = button(header, "×", 717, 9, 34, 34, function() end, true)

local sidebar = make("Frame", panel, {
    Position = UDim2.fromOffset(1, 54),
    Size = UDim2.new(0, 185, 1, -55),
    BackgroundColor3 = C.sidebar,
    BorderSizePixel = 0
})
local sidebarHeading = label(sidebar, "РАЗДЕЛЫ", 18, 18, 140, 20, C.gray, 11)
sidebarHeading.Font = Enum.Font.GothamBold

local area = make("Frame", panel, {
    Position = UDim2.fromOffset(186, 54),
    Size = UDim2.new(1, -187, 1, -55),
    BackgroundTransparency = 1
})
local pageTitle = label(area, "Обзор", 22, 15, 505, 36, C.white, 23)
pageTitle.Font = Enum.Font.GothamBold
local pageSub = label(area, "Состояние клиента и доступные инструменты", 22, 49, 516, 28, C.gray, 12)

local scroll = make("ScrollingFrame", area, {
    Position = UDim2.fromOffset(18, 89),
    Size = UDim2.new(1, -32, 1, -135),
    CanvasSize = UDim2.new(0, 0, 0, 0),
    BorderSizePixel = 0,
    BackgroundTransparency = 1,
    ScrollBarThickness = 5,
    ScrollBarImageColor3 = C.blue
})
local layout = make("UIListLayout", scroll, {
    FillDirection = Enum.FillDirection.Vertical,
    HorizontalAlignment = Enum.HorizontalAlignment.Center,
    SortOrder = Enum.SortOrder.LayoutOrder,
    Padding = UDim.new(0, 12)
})
layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scroll.CanvasSize = UDim2.fromOffset(0, layout.AbsoluteContentSize.Y + 12)
end)

local footer = label(area, "Готово", 23, 403, 510, 24, C.gray, 12)
local navButtons = {}
local pages = {
    {"Главная", "⌂"},
    {"Скорость", ">>"},
    {"Телепорт", "◈"},
    {"Автофарм", "◎"},
    {"Передача Bucks", "$"},
    {"Питомцы", "◇"},
    {"Настройки", "⚙"}
}

local function notice(message)
    footer.Text = message
    print("[PET LAB] " .. message)
end

local function clearPage()
    for _, child in ipairs(scroll:GetChildren()) do
        if child ~= layout then child:Destroy() end
    end
    scroll.CanvasPosition = Vector2.new(0, 0)
end

local function card(caption, height)
    local frame = make("Frame", scroll, {
        Name = "Card",
        Size = UDim2.new(1, -10, 0, height),
        BackgroundColor3 = C.surface,
        BorderSizePixel = 0
    })
    round(frame, 10)
    local head = label(frame, caption, 18, 12, 480, 26, C.white, 16)
    head.Font = Enum.Font.GothamBold
    return frame
end

local function speedApply(value)
    local speed = tonumber(value)
    if not speed or speed < 1 or speed > 100 then
        notice("Введите скорость от 1 до 100")
        return
    end
    local hum = humanoid()
    if not hum then
        notice("Персонаж не загружен")
        return
    end
    hum.WalkSpeed = speed
    notice("Скорость установлена: " .. tostring(speed))
end

local showPage

local function mainPage()
    local c = card("ОБЗОР", 155)
    label(c, "Аккаунт", 18, 51, 145, 24, C.gray, 13)
    label(c, player.Name, 185, 51, 280, 24, C.white, 15)
    label(c, "WalkSpeed", 18, 80, 145, 24, C.gray, 13)
    local hum = humanoid()
    label(c, hum and tostring(hum.WalkSpeed) or "Нет персонажа", 185, 80, 280, 24, C.green, 15)
    label(c, "Версия панели", 18, 110, 145, 24, C.gray, 13)
    label(c, "0.2", 185, 110, 280, 24, C.white, 15)

    local q = card("БЫСТРЫЙ ДОСТУП", 114)
    button(q, "Настроить скорость", 18, 53, 225, 42, function() showPage("Скорость") end)
    button(q, "Открыть телепорт", 260, 53, 225, 42, function() showPage("Телепорт") end)
end

local function speedPage()
    local hum = humanoid()
    local c = card("НАСТРОЙКА WALKSPEED", 212)
    label(c, "Текущая скорость: " .. tostring(hum and hum.WalkSpeed or "н/д"), 18, 48, 458, 27, C.green, 15)
    label(c, "Готовые значения", 18, 82, 460, 21, C.gray, 12)
    button(c, "16", 18, 106, 145, 37, function() speedApply(16); showPage("Скорость") end)
    button(c, "28", 178, 106, 145, 37, function() speedApply(28); showPage("Скорость") end)
    button(c, "48", 338, 106, 145, 37, function() speedApply(48); showPage("Скорость") end)
    local value = entry(c, tostring(hum and hum.WalkSpeed or originalSpeed), 18, 155, 225, 38, "Число от 1 до 100")
    button(c, "ПРИМЕНИТЬ", 260, 155, 223, 38, function()
        speedApply(value.Text)
        if tonumber(value.Text) and tonumber(value.Text) >= 1 and tonumber(value.Text) <= 100 then
            showPage("Скорость")
        end
    end)

    local r = card("СБРОС", 100)
    label(r, "Вернуть скорость при открытии панели: " .. tostring(originalSpeed), 18, 43, 320, 38, C.gray, 13)
    button(r, "СБРОСИТЬ", 347, 46, 136, 34, function()
        speedApply(originalSpeed)
        showPage("Скорость")
    end, true)
end

local function teleportPage()
    local c = card("ЛОКАЛЬНЫЙ ТЕСТ ТЕЛЕПОРТА", 175)
    label(c, "Запомните текущую позицию, затем проверьте возврат.", 18, 47, 470, 36, C.gray, 13)
    label(c, "Сервер может отклонить или исправить перемещение.", 18, 77, 470, 24, C.gray, 12)
    button(c, "ЗАПОМНИТЬ", 18, 118, 224, 38, function()
        local root = rootPart()
        if not root then notice("HumanoidRootPart не найден"); return end
        savedCFrame = root.CFrame
        notice("Текущая позиция сохранена")
    end)
    button(c, "ВЕРНУТЬСЯ", 260, 118, 223, 38, function()
        local root = rootPart()
        if not root or not savedCFrame then notice("Сначала сохраните точку"); return end
        root.CFrame = savedCFrame
        notice("Локальный переход выполнен — проверьте позицию")
    end)

    local info = card("МЕСТА", 103)
    label(info, "Дом, магазин, друзья: точки перехода пока не настроены.", 18, 42, 465, 49, C.gray, 13)
end

local function plannedPage(title, description, steps)
    local c = card(title, 161)
    label(c, "МОДУЛЬ ЕЩЁ НЕ ПОДКЛЮЧЁН", 18, 49, 470, 32, C.blue, 15)
    label(c, description, 18, 88, 466, 60, C.gray, 13)

    local q = card("ПЛАН", 119)
    label(q, steps, 18, 42, 466, 65, C.gray, 13)
end

local function petsPage()
    local c = card("ДИАГНОСТИКА ПИТОМЦА", 160)
    local pet = workspace:FindFirstChild("Pets")
    local focus = playerGui:FindFirstChild("FocusPetApp")
    label(c, "Workspace.Pets: " .. (pet and "найден" or "не найден"), 18, 49, 468, 28, C.white, 14)
    label(c, "FocusPetApp: " .. (focus and "найден" or "не найден"), 18, 81, 468, 28, C.white, 14)
    button(c, "ОБНОВИТЬ", 18, 115, 465, 32, function()
        showPage("Питомцы")
        notice("Клиентские сведения обновлены")
    end)
    local q = card("ПОТРЕБНОСТИ", 101)
    label(q, "В следующей версии добавим чтение AilmentContainer.", 18, 43, 464, 46, C.gray, 13)
end

local function closePanel()
    if closed then return end
    closed = true
    local hum = humanoid()
    if hum then hum.WalkSpeed = originalSpeed end
    gui:Destroy()
end

local function toggleMinimize()
    minimized = not minimized
    sidebar.Visible = not minimized
    area.Visible = not minimized
    if minimized then
        panel.Size = UDim2.fromOffset(760, 54)
        minimizeButton.Text = "+"
        notice("Панель свернута")
    else
        panel.Size = UDim2.fromOffset(760, 490)
        minimizeButton.Text = "−"
        notice("Панель развернута")
    end
end

local function settingsPage()
    local c = card("УПРАВЛЕНИЕ ОКНОМ", 170)
    label(c, "Панель можно перетаскивать за заголовок.", 18, 47, 465, 31, C.gray, 13)
    button(c, "СВЕРНУТЬ", 18, 96, 223, 42, toggleMinimize)
    button(c, "ЗАКРЫТЬ", 260, 96, 223, 42, closePanel, true)
    local s = card("БЕЗОПАСНОСТЬ ТЕСТА", 123)
    label(s, "При закрытии панели исходная скорость восстанавливается.\nИзменения клиента не гарантируют принятие сервером.", 18, 43, 466, 68, C.gray, 13)
end

showPage = function(name)
    if closed then return end
    activePage = name
    local subtitles = {
        ["Главная"] = "Краткая информация о клиенте",
        ["Скорость"] = "Настройка движения персонажа",
        ["Телепорт"] = "Сохранение и возврат к локальной точке",
        ["Автофарм"] = "Раздел для дальнейшей разработки",
        ["Передача Bucks"] = "Раздел для дальнейшей разработки",
        ["Питомцы"] = "Клиентские сведения об интерфейсе питомцев",
        ["Настройки"] = "Параметры самой панели"
    }
    pageTitle.Text = name
    pageSub.Text = subtitles[name] or ""
    clearPage()
    for key, nav in pairs(navButtons) do
        nav.BackgroundColor3 = key == name and C.blueDim or C.sidebar
        nav.TextColor3 = key == name and C.white or C.gray
    end

    if name == "Главная" then mainPage()
    elseif name == "Скорость" then speedPage()
    elseif name == "Телепорт" then teleportPage()
    elseif name == "Автофарм" then
        plannedPage("АВТОФАРМ", "Пока нет запуска фонового цикла. Он будет добавлен после отдельной проверки состояний игры.", "Потребности питомца → разрешённые действия → проверка результата")
    elseif name == "Передача Bucks" then
        plannedPage("ПЕРЕДАЧА BUCKS", "Автоматическая передача средств не реализована. Баланс и ограничения проверяются сервером.", "Интерфейс игры → проверка суммы → подтверждение пользователем")
    elseif name == "Питомцы" then petsPage()
    elseif name == "Настройки" then settingsPage()
    end
end

for index, page in ipairs(pages) do
    local title = page[1]
    local prefix = page[2]
    local nav = make("TextButton", sidebar, {
        Name = "Nav_" .. title,
        Position = UDim2.fromOffset(10, 53 + (index - 1) * 47),
        Size = UDim2.fromOffset(165, 41),
        BackgroundColor3 = C.sidebar,
        Text = "  " .. prefix .. "   " .. title,
        TextColor3 = C.gray,
        TextSize = 13,
        TextXAlignment = Enum.TextXAlignment.Left,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = true
    })
    round(nav, 7)
    nav.Activated:Connect(function() showPage(title) end)
    navButtons[title] = nav
end
label(sidebar, "LOCAL CLIENT  •  v0.2", 18, 397, 170, 24, C.gray, 10)

minimizeButton.Activated:Connect(toggleMinimize)
closeButton.Activated:Connect(closePanel)

-- Перетаскивание за верхнюю панель (мышь и касание)
local dragging = false
local dragStart
local panelStart
header.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true
        dragStart = input.Position
        panelStart = panel.Position
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then dragging = false end
        end)
    end
end)
local dragConnection = UIS.InputChanged:Connect(function(input)
    if not dragging then return end
    if input.UserInputType ~= Enum.UserInputType.MouseMovement
        and input.UserInputType ~= Enum.UserInputType.Touch then return end
    local delta = input.Position - dragStart
    panel.Position = UDim2.new(
        panelStart.X.Scale, panelStart.X.Offset + delta.X,
        panelStart.Y.Scale, panelStart.Y.Offset + delta.Y
    )
end)

local characterConnection = player.CharacterAdded:Connect(function(character)
    local nextHum = character:WaitForChild("Humanoid", 10)
    if nextHum and not closed then
        originalSpeed = nextHum.WalkSpeed
        gui:SetAttribute("DefaultWalkSpeed", originalSpeed)
        if activePage == "Скорость" or activePage == "Главная" then showPage(activePage) end
    end
end)
gui.Destroying:Connect(function()
    closed = true
    dragConnection:Disconnect()
    characterConnection:Disconnect()
end)

showPage("Главная")
print("[PET LAB] v0.2 ready - sidebar and collapse")
