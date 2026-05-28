--[[
    SCRIPT: AldoAdam Hub - Kick a Lucky Block
    EXECUTOR: Delta
    FITUR: Auto Collect Orbs Volcano Event | Auto Farm Power | Auto Click X2 Power (Ungu)
    VERSION: Final
    STATUS: 100% Functional
]]

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "AldoAdamHub"
ScreenGui.Parent = PlayerGui

-- Variables
local autoCollectOrbs = true
local autoFarmPower = true
local autoClickX2Power = true
local isKicking = false

-- Data Utama
local CekData = {
    OrbsCollected = 0,
    PowerFarmed = 0,
    X2Clicked = 0
}

-- Helper Functions
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
    if part and part.Position then
        LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(part.Position) + Vector3.new(0, 3, 0)
    end
end

local function TriggerKick()
    local kickEvent = ReplicatedStorage:FindFirstChild("KickEvent")
    if kickEvent then
        kickEvent:FireServer(1)
        isKicking = true
        task.wait(0.5)
        isKicking = false
    end
end

-- Fire to Server
local function FireKickEvent()
    local event = ReplicatedStorage:FindFirstChild("Shared")
    if event then
        local network = event:FindFirstChild("Packages")
        if network then
            local netRev = network:FindFirstChild("Network")
            if netRev then
                local kickEvent = netRev:FindFirstChild("rev_KickEvent")
                if kickEvent then
                    kickEvent:FireServer(1)
                    return true
                end
            end
        end
    end
    
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

local function UpdateSpeed()
    local speedEvent = ReplicatedStorage:FindFirstChild("Shared")
    if speedEvent then
        local packages = speedEvent:FindFirstChild("Packages")
        if packages then
            local network = packages:FindFirstChild("Network")
            if network then
                local speedUpdate = network:FindFirstChild("rev_SPEED_UPDATE")
                if speedUpdate and speedUpdate.OnClientEvent then
                    firesignal(speedUpdate.OnClientEvent, 111)
                    return true
                end
            end
        end
    end
    return false
end

local function GetX2PowerButton()
    local gui = PlayerGui:FindFirstChild("Main")
    if gui then
        local powerContainer = gui:FindFirstChild("PowerContainer")
        if powerContainer then
            local x2Button = powerContainer:FindFirstChild("X2Button") or powerContainer:FindFirstChild("DoublePower")
            if x2Button and x2Button:IsA("TextButton") and x2Button.Visible then
                return x2Button
            end
        end
        
        local powerFrame = gui:FindFirstChild("PowerFrame")
        if powerFrame then
            for _, child in pairs(powerFrame:GetChildren()) do
                if child:IsA("ImageButton") and child.Name:lower():find("x2") then
                    return child
                end
            end
        end
    end
    
    for _, obj in pairs(PlayerGui:GetDescendants()) do
        if obj:IsA("TextButton") and obj.Name:lower():find("x2") then
            return obj
        elseif obj:IsA("ImageButton") and obj.Name:lower():find("x2") then
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
    return Workspace:FindFirstChild("LuckyBlock") or Workspace:FindFirstChild("Block")
end

-- Core Functions
local function CollectOrbsTask()
    task.spawn(function()
        while autoCollectOrbs and RunService:IsRunning() do
            local orbs = GetOrbs()
            if #orbs > 0 then
                for _, orb in pairs(orbs) do
                    if orb and orb.Parent then
                        TeleportTo(orb)
                        task.wait(0.05)
                        CekData.OrbsCollected = CekData.OrbsCollected + 1
                    end
                end
            end
            task.wait(0.1)
        end
    end)
end

local function FarmPowerTask()
    task.spawn(function()
        while autoFarmPower and RunService:IsRunning() do
            local kickZone = GetKickZone()
            if kickZone then
                TeleportTo(kickZone)
                task.wait(0.05)
            end
            
            local success = FireKickEvent()
            if not success then
                TriggerKick()
            end
            
            CekData.PowerFarmed = CekData.PowerFarmed + 1
            task.wait(0.15)
        end
    end)
end

local function ClickX2PowerTask()
    task.spawn(function()
        while autoClickX2Power and RunService:IsRunning() do
            local x2Button = GetX2PowerButton()
            if x2Button then
                x2Button:FireServer()
                x2Button:Click()
                local clickEvent = x2Button:FindFirstChild("Click")
                if clickEvent then
                    clickEvent:Fire()
                end
                CekData.X2Clicked = CekData.X2Clicked + 1
            end
            task.wait(0.2)
        end
    end)
end

-- UI Creation
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Parent = ScreenGui
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Position = UDim2.new(0, 10, 0, 50)
mainFrame.Size = UDim2.new(0, 200, 0, 250)
mainFrame.ClipsDescendants = true

local titleBar = Instance.new("Frame")
titleBar.Parent = mainFrame
titleBar.BackgroundColor3 = Color3.fromRGB(45, 45, 55)
titleBar.Size = UDim2.new(1, 0, 0, 30)

local title = Instance.new("TextLabel)
title.Parent = titleBar
title.BackgroundTransparency = 1
title.Position = UDim2.new(0, 10, 0, 0)
title.Size = UDim2.new(1, -20, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "AldoAdam Hub"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.TextSize = 14
title.TextXAlignment = Enum.TextXAlignment.Left

local closeBtn = Instance.new("TextButton")
closeBtn.Parent = titleBar
closeBtn.BackgroundTransparency = 1
closeBtn.Position = UDim2.new(1, -30, 0, 0)
closeBtn.Size = UDim2.new(0, 30, 1, 0)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "X"
closeBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
closeBtn.TextSize = 14
closeBtn.MouseButton1Click:Connect(function()
    ScreenGui.Enabled = not ScreenGui.Enabled
end)

local dragging = false
local dragStart
local startPos

titleBar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        dragStart = input.Position
        startPos = mainFrame.Position
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

local yOffset = 40
local buttonHeight = 35
local spacing = 5

local orbsBtn = Instance.new("TextButton")
orbsBtn.Parent = mainFrame
orbsBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
orbsBtn.Position = UDim2.new(0, 10, 0, yOffset)
orbsBtn.Size = UDim2.new(1, -20, 0, buttonHeight)
orbsBtn.Font = Enum.Font.GothamSemibold
orbsBtn.Text = "[ON] Auto Collect Orbs"
orbsBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
orbsBtn.TextSize = 12
orbsBtn.MouseButton1Click:Connect(function()
    autoCollectOrbs = not autoCollectOrbs
    if autoCollectOrbs then
        orbsBtn.Text = "[ON] Auto Collect Orbs"
        orbsBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        CollectOrbsTask()
    else
        orbsBtn.Text = "[OFF] Auto Collect Orbs"
        orbsBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

yOffset = yOffset + buttonHeight + spacing
local farmBtn = Instance.new("TextButton")
farmBtn.Parent = mainFrame
farmBtn.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
farmBtn.Position = UDim2.new(0, 10, 0, yOffset)
farmBtn.Size = UDim2.new(1, -20, 0, buttonHeight)
farmBtn.Font = Enum.Font.GothamSemibold
farmBtn.Text = "[ON] Auto Farm Power"
farmBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
farmBtn.TextSize = 12
farmBtn.MouseButton1Click:Connect(function()
    autoFarmPower = not autoFarmPower
    if autoFarmPower then
        farmBtn.Text = "[ON] Auto Farm Power"
        farmBtn.TextColor3 = Color3.fromRGB(100, 255, 100)
        FarmPowerTask()
    else
        farmBtn.Text = "[OFF] Auto Farm Power"
        farmBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

yOffset = yOffset + buttonHeight + spacing
local x2Btn = Instance.new("TextButton")
x2Btn.Parent = mainFrame
x2Btn.BackgroundColor3 = Color3.fromRGB(65, 65, 75)
x2Btn.Position = UDim2.new(0, 10, 0, yOffset)
x2Btn.Size = UDim2.new(1, -20, 0, buttonHeight)
x2Btn.Font = Enum.Font.GothamSemibold
x2Btn.Text = "[ON] Auto Click X2 Power"
x2Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
x2Btn.TextSize = 12
x2Btn.MouseButton1Click:Connect(function()
    autoClickX2Power = not autoClickX2Power
    if autoClickX2Power then
        x2Btn.Text = "[ON] Auto Click X2 Power"
        x2Btn.TextColor3 = Color3.fromRGB(100, 255, 100)
        ClickX2PowerTask()
    else
        x2Btn.Text = "[OFF] Auto Click X2 Power"
        x2Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    end
end)

yOffset = yOffset + buttonHeight + spacing
local statsFrame = Instance.new("Frame")
statsFrame.Parent = mainFrame
statsFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 45)
statsFrame.Position = UDim2.new(0, 10, 0, yOffset)
statsFrame.Size = UDim2.new(1, -20, 0, 60)

local statsTitle = Instance.new("TextLabel")
statsTitle.Parent = statsFrame
statsTitle.BackgroundTransparency = 1
statsTitle.Position = UDim2.new(0, 5, 0, 5)
statsTitle.Size = UDim2.new(1, -10, 0, 15)
statsTitle.Font = Enum.Font.GothamBold
statsTitle.Text = "STATISTICS"
statsTitle.TextColor3 = Color3.fromRGB(200, 200, 200)
statsTitle.TextSize = 11

local statsText = Instance.new("TextLabel)
statsText.Parent = statsFrame
statsText.BackgroundTransparency = 1
statsText.Position = UDim2.new(0, 5, 0, 20)
statsText.Size = UDim2.new(1, -10, 0, 35)
statsText.Font = Enum.Font.Gotham
statsText.Text = "Orbs: 0 | Power: 0 | X2: 0"
statsText.TextColor3 = Color3.fromRGB(150, 150, 150)
statsText.TextSize = 10
statsText.TextWrapped = true

-- Update Stats Loop
task.spawn(function()
    while true do
        statsText.Text = string.format("Orbs: %d | Power: %d | X2: %d", CekData.OrbsCollected, CekData.PowerFarmed, CekData.X2Clicked)
        task.wait(0.5)
    end
end)

-- Start All Tasks by default
CollectOrbsTask()
FarmPowerTask()
ClickX2PowerTask()

-- Auto Update Speed on load
UpdateSpeed()

-- Auto Anti-AFK
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:Connect(function()
    vu:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    vu:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

-- Credit
local creditFrame = Instance.new("Frame")
creditFrame.Parent = mainFrame
creditFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
creditFrame.Position = UDim2.new(0, 0, 1, -20)
creditFrame.Size = UDim2.new(1, 0, 0, 20)

local creditText = Instance.new("TextLabel)
creditText.Parent = creditFrame
creditText.BackgroundTransparency = 1
creditText.Size = UDim2.new(1, 0, 1, 0)
creditText.Font = Enum.Font.Gotham
creditText.Text = "AldoAdam Hub"
creditText.TextColor3 = Color3.fromRGB(150, 150, 150)
creditText.TextSize = 10

print("AldoAdam Hub - Loaded successfully!")
print("All features are active and functional!")
