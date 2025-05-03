pcall(function() game.CoreGui:FindFirstChild("TeleporterGUI"):Destroy() end)
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
                root.CFrame = CFrame.new(pos + Vector3.new(0, 5, 0))
                task.wait(TeleportDelay)
            end
            root.CFrame = original
            task.wait(0.5)
        until not TeleportRepeat
    end
end

local gui = Instance.new("ScreenGui", game.CoreGui)
gui.Name = "TeleporterGUI"
local frame = Instance.new("Frame", gui)
frame.Size = UDim2.new(0, 300, 0, 300)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
frame.BorderSizePixel = 0
frame.Active = true
frame.Draggable = true

local title = Instance.new("TextLabel", frame)
title.Text = "Teleporter Manager"
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
minimize.TextColor3 = Color3.new(1,1,1)

local close = Instance.new("TextButton", frame)
close.Text = "X"
close.Size = UDim2.new(0, 25, 0, 25)
close.Position = UDim2.new(1, -30, 0, 2)
close.BackgroundColor3 = Color3.fromRGB(100, 40, 40)
close.TextColor3 = Color3.new(1,1,1)

local container = Instance.new("Frame", frame)
container.Position = UDim2.new(0.5, -150, 0, 35)  -- Center the container
container.Size = UDim2.new(0, 300, 1, -50)  -- Adjust size for centering
container.BackgroundTransparency = 1

local layout = Instance.new("UIListLayout", container)
layout.Padding = UDim.new(0, 5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center  -- Ensure buttons are centered horizontally

local function createButton(text, callback)
    local btn = Instance.new("TextButton", container)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Position = UDim2.new(0, 10, 0, 0)
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
speedLabel.Size = UDim2.new(1, -20, 0, 20)
speedLabel.Position = UDim2.new(0, 10, 0, 0)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.TextSize = 16
speedLabel.Font = Enum.Font.SourceSans

local speedBox = Instance.new("TextBox", container)
speedBox.Size = UDim2.new(1, -20, 0, 30)
speedBox.Position = UDim2.new(0, 10, 0, 0)
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

createButton("Place Teleporter", function()
    local root = getRoot()
    if root then
        table.insert(_G.Teleporters, root.Position)
        createVisual(root.Position)
        table.insert(UndoStack, {action = "add", pos = root.Position})
        undoBtn.Visible = true
    end
end)

createButton("Run Teleporters", function()
    teleportSequence()
end)

local undoBtn = createButton("Undo", function()
    local last = table.remove(UndoStack)
    if last then
        if last.action == "add" then
            for i = #_G.Teleporters, 1, -1 do
                if (_G.Teleporters[i] - last.pos).magnitude < 1 then
                    removeVisual(_G.Teleporters[i])
                    table.remove(_G.Teleporters, i)
                    break
                end
            end
        elseif last.action == "remove" then
            table.insert(_G.Teleporters, last.pos)
            createVisual(last.pos)
        end
    end
    undoBtn.Visible = #UndoStack > 0
end)
undoBtn.Visible = false

local credit = Instance.new("TextLabel", frame)
credit.Text = "Made by Hypnotich @hypnotich on Discord"
credit.Size = UDim2.new(1, 0, 0, 15)
credit.Position = UDim2.new(0, 0, 1, -15)
credit.BackgroundTransparency = 1
credit.TextColor3 = Color3.new(1, 1, 1)
credit.Font = Enum.Font.SourceSans
credit.TextSize = 14

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
                undoBtn.Visible = true
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
    frame.Size = minimized and UDim2.new(0, 300, 0, 35) or UDim2.new(0, 300, 0, 300)
end)
close.MouseButton1Click:Connect(function()
    gui:Destroy()
end)
