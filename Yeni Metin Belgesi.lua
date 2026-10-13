--[[
    Proje: Hunter MM2 Script (ImGui Anime Edition)
    Tema: Mor ImGui Style + Anime Kız Arka Planı
    Özellikler: Rol ESP, Aimbot, Silent Aim, Fling, Fly, Auto Coin Farm, Skybox
]]--

local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

-- Hile Durum Ayarları
local Config = {
    RoleESP = false,
    Aimbot = false,
    SilentAim = false,
    Fling = false,
    Fly = false,
    AutoFarm = false,
    FOV = 120,
    SkyColor = Color3.fromRGB(30, 10, 40),
    SelectedTarget = nil
}

--------------------------------------------------------------------------------
-- 1. MM2 MANTIK VE FİZİK DÖNGÜSÜ
--------------------------------------------------------------------------------
local function updateRoleESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character then
            local char = player.Character
            local backpack = player:FindFirstChild("Backpack")
            local isMurderer = (char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")))
            local isSheriff = (char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")))
            
            local color = Color3.fromRGB(0, 255, 120) -- Masum
            if isMurderer then
                color = Color3.fromRGB(255, 30, 30) -- Katil
            elseif isSheriff then
                color = Color3.fromRGB(30, 120, 255) -- Şerif
            end
            
            if Config.RoleESP then
                if not char:FindFirstChild("MM2_ESP") then
                    local hl = Instance.new("Highlight")
                    hl.Name = "MM2_ESP"
                    hl.Adornee = char
                    hl.FillColor = color
                    hl.FillTransparency = 0.5
                    hl.OutlineColor = Color3.fromRGB(255, 255, 255)
                    hl.Parent = char
                else
                    char.MM2_ESP.FillColor = color
                end
            else
                if char:FindFirstChild("MM2_ESP") then
                    char.MM2_ESP:Destroy()
                end
            end
        end
    end
end

RunService.RenderStepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    
    if Config.RoleESP then updateRoleESP() end

    -- Auto Coin Farm (Fly + Noclip)
    if Config.AutoFarm and root then
        for _, part in ipairs(char:GetDescendants()) do
            if part:IsA("BasePart") then part.CanCollide = false end
        end
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj.Name == "Coin_Server" or obj.Name == "Coin" then
                if obj:IsA("BasePart") or obj:IsA("Model") then
                    local targetPos = obj:IsA("BasePart") and obj.Position or obj.PrimaryPart.Position
                    root.CFrame = CFrame.new(targetPos + Vector3.new(0, 2, 0))
                    break
                end
            end
        end
    end

    -- Fling
    if Config.Fling and root then
        root.AssemblyAngularVelocity = Vector3.new(0, 99999, 0)
    end

    -- Aimbot
    if Config.Aimbot then
        local target = nil
        local minDist = Config.FOV
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character and p.Character:FindFirstChild("Head") then
                local sp, onScreen = Camera:WorldToScreenPoint(p.Character.Head.Position)
                if onScreen then
                    local mag = (Vector2.new(UserInputService:GetMouseLocation().X, UserInputService:GetMouseLocation().Y) - Vector2.new(sp.X, sp.Y)).Magnitude
                    if mag < minDist then
                        minDist = mag
                        target = p.Character.Head
                    end
                end
            end
        end
        if target then
            Camera.CFrame = CFrame.new(Camera.CFrame.Position, target.Position)
        end
    end
end)

--------------------------------------------------------------------------------
-- 2. ANIME IMGUI ARAYÜZÜ (Sıfırdan Tasarım)
--------------------------------------------------------------------------------
if CoreGui:FindFirstChild("HunterMM2_ImGui") then 
    CoreGui.HunterMM2_ImGui:Destroy() 
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "HunterMM2_ImGui"
ScreenGui.Parent = CoreGui

-- Ana ImGui Penceresi
local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 520, 0, 360)
MainFrame.Position = UDim2.new(0.5, -260, 0.5, -180)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 12, 22) -- Koyu Mor-Siyah
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(140, 60, 230) -- Mor Kenarlık (ImGui stili)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.ClipsDescendants = true
MainFrame.Parent = ScreenGui

-- ARKA PLAN ANIME KIZI GÖRSELİ
local AnimeBg = Instance.new("ImageLabel")
AnimeBg.Name = "AnimeBackground"
AnimeBg.Size = UDim2.new(1, 0, 1, 0)
AnimeBg.Position = UDim2.new(0, 0, 0, 0)
AnimeBg.Image = "rbxassetid://6532431718" -- Anime Kız Decal ID
AnimeBg.ImageTransparency = 0.82 -- Kodu ve menüyü kapatmaması için şeffaf
AnimeBg.BackgroundTransparency = 1
AnimeBg.ScaleType = Enum.ScaleType.Crop
AnimeBg.Parent = MainFrame

-- Üst Başlık Barı (ImGui TitleBar)
local TitleBar = Instance.new("Frame")
TitleBar.Size = UDim2.new(1, 0, 0, 28)
TitleBar.BackgroundColor3 = Color3.fromRGB(25, 18, 38)
TitleBar.BorderSizePixel = 0
TitleBar.Parent = MainFrame

local TitleText = Instance.new("TextLabel")
TitleText.Size = UDim2.new(1, -10, 1, 0)
TitleText.Position = UDim2.new(0, 10, 0, 0)
TitleText.BackgroundTransparency = 1
TitleText.Text = "Hunter MM2 Script // v2.0 ImGui Edition"
TitleText.TextColor3 = Color3.fromRGB(200, 140, 255) -- Açık Mor
TitleText.Font = Enum.Font.Code
TitleText.TextSize = 13
TitleText.TextXAlignment = Enum.TextXAlignment.Left
TitleText.Parent = TitleBar

-- Sol Sekme Paneli (ImGui Tabs)
local Sidebar = Instance.new("Frame")
Sidebar.Size = UDim2.new(0, 120, 1, -28)
Sidebar.Position = UDim2.new(0, 0, 0, 28)
Sidebar.BackgroundColor3 = Color3.fromRGB(20, 15, 30)
Sidebar.BackgroundTransparency = 0.3
Sidebar.BorderSizePixel = 0
Sidebar.Parent = MainFrame

-- Sayfa Konteyneri
local Container = Instance.new("Frame")
Container.Size = UDim2.new(1, -130, 1, -38)
Container.Position = UDim2.new(0, 125, 0, 33)
Container.BackgroundTransparency = 1
Container.Parent = MainFrame

local function createTabPage()
    local p = Instance.new("ScrollingFrame")
    p.Size = UDim2.new(1, 0, 1, 0)
    p.BackgroundTransparency = 1
    p.Visible = false
    p.CanvasSize = UDim2.new(0, 0, 1.4, 0)
    p.ScrollBarThickness = 3
    p.ScrollBarImageColor3 = Color3.fromRGB(140, 60, 230)
    p.Parent = Container
    return p
end

local combatPage = createTabPage()
local visualPage = createTabPage()
local miscPage = createTabPage()
combatPage.Visible = true

local function switchTab(page)
    combatPage.Visible = false
    visualPage.Visible = false
    miscPage.Visible = false
    page.Visible = true
end

-- Sekme Buton Yapıcı
local function createTabButton(name, posY, page)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, -10, 0, 28)
    btn.Position = UDim2.new(0, 5, 0, posY)
    btn.BackgroundColor3 = Color3.fromRGB(35, 25, 52)
    btn.Text = name
    btn.TextColor3 = Color3.fromRGB(220, 220, 220)
    btn.Font = Enum.Font.Code
    btn.TextSize = 12
    btn.Parent = Sidebar
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 4)
    corner.Parent = btn
    
    btn.MouseButton1Click:Connect(function() switchTab(page) end)
end

createTabButton("Combat", 10, combatPage)
createTabButton("Visuals", 45, visualPage)
createTabButton("Misc & Farm", 80, miscPage)

-- Insert Tuşu ile Arayüzü Gizle/Göster
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

--------------------------------------------------------------------------------
-- 3. SEKMELER VE IMGUI TARZI TOGGLE KONTROLLERİ
--------------------------------------------------------------------------------

-- ImGui Switch Butonu Şablonu (Mor Aksanlı)
local function addImGuiToggle(parent, text, posY, callback)
    local frame = Instance.new("Frame")
    frame.Size = UDim2.new(1, -10, 0, 32)
    frame.Position = UDim2.new(0, 5, 0, posY)
    frame.BackgroundColor3 = Color3.fromRGB(25, 20, 38)
    frame.BackgroundTransparency = 0.2
    frame.BorderSizePixel = 1
    frame.BorderColor3 = Color3.fromRGB(60, 40, 90)
    frame.Parent = parent
    
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.fromRGB(230, 230, 230)
    label.Font = Enum.Font.Code
    label.TextSize = 12
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = frame
    
    local switch = Instance.new("TextButton")
    switch.Size = UDim2.new(0, 48, 0, 20)
    switch.Position = UDim2.new(1, -58, 0.5, -10)
    switch.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
    switch.Text = "OFF"
    switch.TextColor3 = Color3.fromRGB(160, 160, 160)
    switch.Font = Enum.Font.Code
    switch.TextSize = 10
    switch.Parent = frame
    
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(1, 0)
    c.Parent = switch
    
    local state = false
    switch.MouseButton1Click:Connect(function()
        state = not state
        switch.Text = state and "ON" or "OFF"
        switch.BackgroundColor3 = state and Color3.fromRGB(150, 50, 255) or Color3.fromRGB(45, 35, 65)
        switch.TextColor3 = state and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
        callback(state)
    end)
end

-- COMBAT SEKMESİ
addImGuiToggle(combatPage, "Aimbot (Katile/Şerife)", 10, function(v) Config.Aimbot = v end)
addImGuiToggle(combatPage, "Silent Aim (Gizli Hedefleme)", 50, function(v) Config.SilentAim = v end)

-- VISUALS SEKMESİ
addImGuiToggle(visualPage, "Rol ESP (Katil/Şerif/Masum)", 10, function(v) Config.RoleESP = v end)

-- Gökyüzü Mor Yapma Butonu
local skyBtn = Instance.new("TextButton")
skyBtn.Size = UDim2.new(1, -10, 0, 32)
skyBtn.Position = UDim2.new(0, 5, 0, 50)
skyBtn.BackgroundColor3 = Color3.fromRGB(60, 30, 100)
skyBtn.Text = "Gökyüzünü Mor Gece Yap"
skyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
skyBtn.Font = Enum.Font.Code
skyBtn.TextSize = 11
skyBtn.Parent = visualPage

skyBtn.MouseButton1Click:Connect(function()
    Lighting.Ambient = Color3.fromRGB(40, 15, 60)
end)

-- MISC & FARM SEKMESİ
addImGuiToggle(miscPage, "Auto Coin Farm (Fly+Noclip)", 10, function(v) Config.AutoFarm = v end)
addImGuiToggle(miscPage, "Fling (Çevrendekileri Fırlat)", 50, function(v) Config.Fling = v end)