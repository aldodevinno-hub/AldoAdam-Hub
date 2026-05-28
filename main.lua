--[[
    SCRIPT: AldoAdam Hub - Kick a Lucky Block
    EXECUTOR: Delta
    FITUR: Auto Collect Orbs Volcano Event | Auto Farm Power | Auto Click X2 Power (Ungu)
    VERSION: Final Fixed
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoAdamHub"
ScreenGui.Parent = PlayerGui

local autoCollectOrbs = true
local autoFarmPower = true
local autoClickX2Power = true
local isKicking = false

local CekData = {
    OrbsCollected = 0,
    PowerFarmed = 0,
    X2Clicked = 0
}

local function GetOrbs()
    local orbs = {}
    for i, v in pairs(Workspace:GetDescendants()) do
        if v.Name:lower():find("orb") or v.Name:lower():find("volcano") then
            if v:IsA("BasePart") and v.Parent and not v.Parent:IsA("Player") then
                table.insert(orbs, v)
            end
        end
    end
    return orbs
end

local function TeleportTo(part)
    if part and part.Position and LocalPlayer.Character then
        local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then
            hrp.CFrame = CFrame.new(part.Position) + Vector3.new(0, 3, 0)
        end
    end
end

local function FireKickEvent()
    local kickRemote = ReplicatedStorage:FindFirstChild("KickEvent")
    if kickRemote then
        kickRemote:FireServer(1)
        return true
    end
    local remote = ReplicatedStorage:FindFirstChild("Kick")
    if remote then
        remote:FireServer(1)
        return true
    end
    return false
end

local function GetX2PowerButton()
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if (obj:IsA("TextButton") or obj:IsA("ImageButton")) and obj.Name:lower():find("x2") and obj.Visible then
            return obj
        end
    end
    return nil
end

local function GetKickZone()
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj.Name:lower():find("kick") or obj.Name:lower():find("lucky") then
            if obj:IsA("BasePart") or obj:IsA("MeshPart") then
                return obj
            end
        end
    end
    return Workspace:FindFirstChild("LuckyBlock")
end

local function CollectOrbsTask()
    task.spawn(function()
        while autoCollectOrbs and RunService:IsRunning() do
            local orbs = GetOrbs()
            for _, orb in pairs(orbs) do
                if orb and orb.Parent then
                    TeleportTo(orb)
                    task.wait(0.05)
                    CekData.OrbsCollected = CekData.OrbsCollected + 1
                end
            end
            task.wait(0.1)
        end
    end)
end

local function FarmPowerTask()
    task.spawn(function()
        while autoFarmPower and RunService:IsRunning() do
            local zone = GetKickZone()
            if zone then TeleportTo(zone) task.wait(0.05) end
            FireKickEvent()
            CekData.PowerFarmed = CekData.PowerFarmed + 1
            task.wait(0.15)
        end
    end)
end

local function ClickX2PowerTask()
    task.spawn(function()
        while autoClickX2Power and RunService:IsRunning() do
            local btn = GetX2PowerButton()
            if btn then
                btn:FireServer()
                btn:Click()
                CekData.X2Clicked = CekData.X2Clicked + 1
            end
            task.wait(0.2)
        end
    end)
end

-- UI
local mainFrame = Instance.new("Frame")
mainFrame.Parent = ScreenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.Size = UDim2.new(0, 200, 0, 250)

local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.Size = UDim2.new(1, 0, 0, 30)

local title = Instance.new("TextLabel")  -- FIXED
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -20, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "AldoAdam Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.MouseButton1Click:Connect(function() ScreenGui.Enabled = not ScreenGui.Enabled end)

local function MakeButton(text, y, color, callback)
    local btn = Instance.new("TextButton")
    btn.Parent = mainFrame
    btn.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
    btn.Position = UDim2.new(0, 10, 0, y)
    btn.Size = UDim2.new(1, -20, 0, 35)
    btn.Text = text
    btn.TextColor3 = color
    btn.TextSize = 12
    btn.MouseButton1Click:Connect(callback)
    return btn
end

local orbsBtn = MakeButton("[ON] Auto Collect Orbs", 40, Color3.fromRGB(100, 255, 100), function()
    autoCollectOrbs = not autoCollectOrbs
    orbsBtn.Text = autoCollectOrbs and "[ON] Auto Collect Orbs" or "[OFF] Auto Collect Orbs"
    orbsBtn.TextColor3 = autoCollectOrbs and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if autoCollectOrbs then CollectOrbsTask() end
end)

local farmBtn = MakeButton("[ON] Auto Farm Power", 80, Color3.fromRGB(100, 255, 100), function()
    autoFarmPower = not autoFarmPower
    farmBtn.Text = autoFarmPower and "[ON] Auto Farm Power" or "[OFF] Auto Farm Power"
    farmBtn.TextColor3 = autoFarmPower and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if autoFarmPower then FarmPowerTask() end
end)

local x2Btn = MakeButton("[ON] Auto Click X2", 120, Color3.fromRGB(100, 255, 100), function()
    autoClickX2Power = not autoClickX2Power
    x2Btn.Text = autoClickX2Power and "[ON] Auto Click X2" or "[OFF] Auto Click X2"
    x2Btn.TextColor3 = autoClickX2Power and Color3.fromRGB(100, 255, 100) or Color3.fromRGB(255, 100, 100)
    if autoClickX2Power then ClickX2PowerTask() end
end)

local statsFrame = Instance.new("Frame")
statsFrame.Parent = mainFrame
statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
statsFrame.Position = UDim2.new(0, 10, 0, 160)
statsFrame.Size = UDim2.new(1, -20, 0, 60)

local statsText = Instance.new("TextLabel")  -- FIXED
statsText.Parent = statsFrame
statsText.BackgroundTransparency = 1
statsText.Position = UDim2.new(0, 5, 0, 5)
statsText.Size = UDim2.new(1, -10, 0, 50)
statsText.Text = "Orbs: 0 | Power: 0 | X2: 0"
statsText.TextColor3 = Color3.fromRGB(200, 200, 200)
statsText.TextSize = 11

task.spawn(function()
    while true do
        statsText.Text = string.format("Orbs: %d | Power: %d | X2: %d", CekData.OrbsCollected, CekData.PowerFarmed, CekData.X2Clicked)
        task.wait(0.5)
    end
end)

local creditText = Instance.new("TextLabel")  -- FIXED
creditText.Parent = mainFrame
creditText.BackgroundTransparency = 1
creditText.Position = UDim2.new(0, 0, 1, -20)
creditText.Size = UDim2.new(1, 0, 0, 20)
creditText.Text = "AldoAdam Hub"
creditText.TextColor3 = Color3.fromRGB(150, 150, 150)
creditText.TextSize = 10

CollectOrbsTask()
FarmPowerTask()
ClickX2PowerTask()

LocalPlayer.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

print("AldoAdam Hub - Loaded successfully!")
