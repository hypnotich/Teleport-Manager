pcall(function() game.CoreGui:FindFirstChild("TeleportManagerGUI"):Destroy() end)
pcall(function() if game.Players.LocalPlayer.Backpack:FindFirstChild("RemoveTool") then game.Players.LocalPlayer.Backpack.RemoveTool:Destroy() end end)

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()

_G.Teleporters = _G.Teleporters or {}
local Visuals = {}
local UndoStack = {}
local TeleportRepeat = false
local TeleportDelay = 1

local function getRoot()
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    return Character and Character:FindFirstChild("HumanoidRootPart")
end

local function createVisual(pos)
    local part = Instance.new("Part", workspace)
    part.Size = Vector3.new(6, 0.5, 6)
    part.Position = pos
    part.Anchored = true
    part.Transparency = 0.3
    part.Color = Color3.fromRGB(0, 170, 255)
    part.CanCollide = false
    part.Name = "TeleporterVisual"
    table.insert(Visuals, {pos = pos, part = part})
end

local function removeVisual(pos)
    for i, v in ipairs(Visuals) do
        if (v.pos - pos).magnitude < 1 then
            v.part:Destroy()
            table.remove(Visuals, i)
            break
        end
    end
end

local function teleportSequence()
    local root = getRoot()
    if root and #_G.Teleporters > 0 then
        local original = root.CFrame
        repeat
            for _, pos in ipairs(_G.Teleporters) do
                root = getRoot()
                if root then
                    root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                    task.wait(TeleportDelay)
                end
            end
            root = getRoot()
            if root then root.CFrame = original end
            task.wait(0.5)
        until not TeleportRepeat
    end
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TeleportManagerGUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 350)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "💫Teleport Manager"
title.Size = UDim2.new(1, -60, 0, 30)
title.Position = UDim2.new(0, 5, 0, 0)
title.BackgroundTransparency = 1
title.TextColor3 = Color3.new(1, 1, 1)
title.Font = Enum.Font.SourceSansBold
title.TextSize = 20
title.TextXAlignment = Enum.TextXAlignment.Left

local minimize = Instance.new("TextButton", frame)
minimize.Text = "-"
minimize.Size = UDim2.new(0, 25, 0, 25)
minimize.Position = UDim2.new(1, -55, 0, 2)
minimize.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
minimize.TextColor3 = Color3.new(1, 1, 1)

local close = Instance.new("TextButton", frame)
close.Text = "X"
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
close.TextColor3 = Color3.new(1, 1, 1)

local container = Instance.new("Frame", frame)
container.Position = UDim2.new(0, 0, 0, 35)
container.Size = UDim2.new(1, 0, 1, -50)
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function createButton(text, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(0, 260, 0, 35)
    btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Text = text
    btn.Font = Enum.Font.SourceSansBold
    btn.TextSize = 18
    btn.MouseButton1Click:Connect(function()
        callback(btn)
    end)
    return btn
end

local speedLabel = Instance.new("TextLabel", container)
speedLabel.Text = "Speed (higher = faster):"
speedLabel.Size = UDim2.new(0, 260, 0, 20)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.SourceSans

local speedBox = Instance.new("TextBox", container)
speedBox.Size = UDim2.new(0, 260, 0, 30)
speedBox.Text = "1"
speedBox.TextColor3 = Color3.new(1, 1, 1)
speedBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
speedBox.Font = Enum.Font.SourceSans
speedBox.TextSize = 16
speedBox.FocusLost:Connect(function()
    local n = tonumber(speedBox.Text)
    if n and n > 0 then
        TeleportDelay = 1 / n
    else
        speedBox.Text = tostring(1 / TeleportDelay)
    end
end)

local repeatToggle = createButton("Repeat: OFF", function(btn)
    TeleportRepeat = not TeleportRepeat
    btn.Text = "Repeat: " .. (TeleportRepeat and "ON" or "OFF")
    if TeleportRepeat then
        task.spawn(teleportSequence)
    end
end)

local objectNameBox = Instance.new("TextBox", container)
objectNameBox.Size = UDim2.new(0, 260, 0, 30)
objectNameBox.Text = "Type object name like 'Coin'"
objectNameBox.TextColor3 = Color3.new(1, 1, 1)
objectNameBox.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
objectNameBox.Font = Enum.Font.SourceSans
objectNameBox.TextSize = 16
objectNameBox.ClearTextOnFocus = true

local counterLabel = Instance.new("TextLabel", gui)
counterLabel.Size = UDim2.new(0, 200, 0, 30)
counterLabel.Position = UDim2.new(0.5, -100, 0, 10)
counterLabel.BackgroundTransparency = 1
counterLabel.TextColor3 = Color3.new(1, 1, 1)
counterLabel.Text = ""
counterLabel.Font = Enum.Font.SourceSansBold
counterLabel.TextSize = 18

createButton("Add Teleporters to Name", function(btn)
    local keyword = objectNameBox.Text
    if not keyword or keyword == "" then return end
    local matches = {}
    for _, obj in ipairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") and obj.Name:lower():find(keyword:lower()) then
            table.insert(matches, obj.Position)
        end
    end
    local total = #matches
    counterLabel.Text = "0/"..total
    local index = 0
    task.spawn(function()
        for _, pos in ipairs(matches) do
            index += 1
            table.insert(_G.Teleporters, pos)
            createVisual(pos)
            counterLabel.Text = index.."/"..total
            table.insert(UndoStack, {action = "add", pos = pos})
            task.wait(0.01)
        end
        task.wait(0.5)
        counterLabel.Text = ""
    end)
end)

createButton("Place Teleporter", function()
    local root = getRoot()
    if root then
        table.insert(_G.Teleporters, root.Position)
        createVisual(root.Position)
        table.insert(UndoStack, {action = "add", pos = root.Position})
    end
end)

createButton("Run Teleporters", function()
    local root = getRoot()
    if root and #_G.Teleporters > 0 then
        local original = root.CFrame
        for _, pos in ipairs(_G.Teleporters) do
            root = getRoot()
            if root then
                root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                task.wait(TeleportDelay)
            end
        end
        root = getRoot()
        if root then root.CFrame = original end
    end
end)

createButton("Undo", function()
    if #UndoStack > 0 then
        local lastAction = table.remove(UndoStack)
        if lastAction.action == "add" then
            for i, pos in ipairs(_G.Teleporters) do
                if pos == lastAction.pos then
                    table.remove(_G.Teleporters, i)
                    removeVisual(pos)
                    break
                end
            end
        elseif lastAction.action == "remove" then
            table.insert(_G.Teleporters, lastAction.pos)
            createVisual(lastAction.pos)
        end
    end
end)

local tool = Instance.new("Tool")
tool.RequiresHandle = false
tool.Name = "RemoveTool"
tool.Activated:Connect(function()
    local target = Mouse.Target
    if target and target.Name == "TeleporterVisual" then
        local pos = target.Position
        for i, tp in ipairs(_G.Teleporters) do
            if (tp - pos).magnitude < 1 then
                table.remove(_G.Teleporters, i)
                removeVisual(pos)
                table.insert(UndoStack, {action = "remove", pos = pos})
                break
            end
        end
    end
end)
tool.Parent = LocalPlayer.Backpack

local minimized = false
minimize.MouseButton1Click:Connect(function()
    minimized = not minimized
    container.Visible = not minimized
    frame.Size = minimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 350)
end)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)

local creditsLabel = Instance.new("TextLabel", frame)
creditsLabel.Text = "Made by Hypnotich @hypnotich on discord"
creditsLabel.Size = UDim2.new(1, -10, 0, 10)
creditsLabel.Position = UDim2.new(0, 5, 1, -15)
creditsLabel.BackgroundTransparency = 1
creditsLabel.TextColor3 = Color3.new(1, 1, 1)
creditsLabel.TextSize = 10
creditsLabel.TextXAlignment = Enum.TextXAlignment.Center
