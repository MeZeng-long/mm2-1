--[[
    Proje: Hunter MM2 - Envanter Taramalı Rol ESP
    Özellik: Katil (Kırmızı), Şerif (Mavi), Masum (Yeşil)
    Açıklama: Envanter ve karakter eşyalarını anlık tarar.
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Config = {
    ESPEnabled = false
}

--------------------------------------------------------------------------------
-- Gelişmiş Envanter ve Eşya Taraması
--------------------------------------------------------------------------------
local function checkInventoryForRole(player)
    if not player then return "Masum" end
    
    -- 1. Karakter ve Çanta Taraması
    local char = player.Character
    local backpack = player:FindFirstChild("Backpack")
    
    local itemsToScan = {}
    
    if char then
        for _, item in ipairs(char:GetChildren()) do
            if item:IsA("Tool") then table.insert(itemsToScan, item.Name) end
        end
    end
    
    if backpack then
        for _, item in ipairs(backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(itemsToScan, item.Name) end
        end
    end
    
    -- 2. İsim Taraması (Katil ve Şerif Eşyaları)
    for _, itemName in ipairs(itemsToScan) do
        local lowerName = string.lower(itemName)
        if lowerName == "knife" or string.find(lowerName, "blade") or string.find(lowerName, "sword") then
            return "Katil"
        elseif lowerName == "gun" or lowerName == "revolver" or string.find(lowerName, "pistol") then
            return "Şerif"
        end
    end
    
    return "Masum"
end

--------------------------------------------------------------------------------
-- ESP ÇİZİM VE GÜNCELLEME
--------------------------------------------------------------------------------
local function clearAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Hunter_ESP") then
            player.Character.Hunter_ESP:Destroy()
        end
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function setup(char)
        if not char then return end
        if char:FindFirstChild("Hunter_ESP") then char.Hunter_ESP:Destroy() end
        if not Config.ESPEnabled then return end
        
        local folder = Instance.new("Folder")
        folder.Name = "Hunter_ESP"
        folder.Parent = char
        
        local hl = Instance.new("Highlight")
        hl.Name = "Box"
        hl.Adornee = char
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.Parent = folder
        
        local head = char:WaitForChild("Head", 5)
        if not head then return end
        
        local bg = Instance.new("BillboardGui")
        bg.Name = "Tag"
        bg.Adornee = head
        bg.Size = UDim2.new(0, 150, 0, 40)
        bg.StudsOffset = Vector3.new(0, 2.5, 0)
        bg.AlwaysOnTop = true
        bg.Parent = folder
        
        local txt = Instance.new("TextLabel")
        txt.Size = UDim2.new(1, 0, 1, 0)
        txt.BackgroundTransparency = 1
        txt.Text = player.Name
        txt.TextSize = 13
        txt.Font = Enum.Font.Code
        txt.TextStrokeTransparency = 0.4
        txt.Parent = bg
    end

    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(function() setup(player.Character) end) end
end

-- Sürekli Envanter Takip Döngüsü
RunService.RenderStepped:Connect(function()
    if not Config.ESPEnabled then return end
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Hunter_ESP") then
            local role = checkInventoryForRole(player)
            local folder = player.Character.Hunter_ESP
            local hl = folder:FindFirstChild("Box")
            local tag = folder:FindFirstChild("Tag")
            
            local color = Color3.fromRGB(0, 255, 120) -- Masum
            local roleTitle = player.Name .. " [Masum]"
            
            if role == "Katil" then
                color = Color3.fromRGB(255, 30, 30) -- Katil
                roleTitle = player.Name .. " [KATİL!]"
            elseif role == "Şerif" then
                color = Color3.fromRGB(30, 120, 255) -- Şerif
                roleTitle = player.Name .. " [Şerif]"
            end
            
            if hl then hl.FillColor = color end
            if tag and tag:FindFirstChild("TextLabel") then
                tag.TextLabel.Text = roleTitle
                tag.TextLabel.TextColor3 = color
            end
        end
    end
end)

local function toggleESP(state)
    Config.ESPEnabled = state
    if state then
        for _, p in ipairs(Players:GetPlayers()) do applyESP(p) end
    else
        clearAllESP()
    end
end

Players.PlayerAdded:Connect(applyESP)

--------------------------------------------------------------------------------
-- ARAYÜZ (GUI)
--------------------------------------------------------------------------------
local ParentGui = gethui and gethui() or CoreGui

if ParentGui:FindFirstChild("Hunter_MM2_UI") then 
    ParentGui.Hunter_MM2_UI:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "Hunter_MM2_UI"
ScreenGui.Parent = ParentGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 240, 0, 110)
MainFrame.Position = UDim2.new(0.5, -120, 0.5, -55)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(140, 60, 230)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 6)

local TitleBar = Instance.new("TextLabel")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
TitleBar.Text = "  Hunter MM2 // Envanter ESP"
TitleBar.TextColor3 = Color3.fromRGB(200, 140, 255)
TitleBar.Font = Enum.Font.Code
TitleBar.TextSize = 11
TitleBar.TextXAlignment = Enum.TextXAlignment.Left
TitleBar.Parent = MainFrame

Instance.new("UICorner", TitleBar).CornerRadius = UDim.new(0, 6)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0, 210, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -105, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
ToggleBtn.Text = "Rol ESP: Kapalı"
ToggleBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 12
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

ToggleBtn.MouseButton1Click:Connect(function()
    local newState = not Config.ESPEnabled
    toggleESP(newState)
    ToggleBtn.Text = newState and "Rol ESP: Açık" or "Rol ESP: Kapalı"
    ToggleBtn.BackgroundColor3 = newState and Color3.fromRGB(150, 50, 255) or Color3.fromRGB(45, 35, 65)
    ToggleBtn.TextColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
end)
