--[[
    Proje: Hunter MM2 - Tam Stream Proof ESP
]]--

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local Config = {
    ESPEnabled = false
}

--------------------------------------------------------------------------------
-- STREAM PROOF KORUMALI PARENT OLUSTURMA
--------------------------------------------------------------------------------
local function getStreamProofParent()
    -- Executor'ın gizli GUI deposunu kontrol et
    if gethui then
        return gethui()
    elseif syn and syn.protect_gui then
        local gui = Instance.new("ScreenGui")
        syn.protect_gui(gui)
        gui.Parent = game:GetService("CoreGui")
        return gui
    else
        return game:GetService("CoreGui")
    end
end

local TargetParent = getStreamProofParent()

--------------------------------------------------------------------------------
-- ESP TEMİZLEME VE OLUŞTURMA
--------------------------------------------------------------------------------
local function clearAllESP()
    for _, player in ipairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("Hunter_MM2_ESP") then
            player.Character.Hunter_MM2_ESP:Destroy()
        end
    end
end

local function applyESP(player)
    if player == LocalPlayer then return end
    
    local function setup(char)
        if not char then return end
        if char:FindFirstChild("Hunter_MM2_ESP") then char.Hunter_MM2_ESP:Destroy() end
        
        if not Config.ESPEnabled then return end
        
        local backpack = player:FindFirstChild("Backpack")
        local isMurderer = (char:FindFirstChild("Knife") or (backpack and backpack:FindFirstChild("Knife")))
        local isSheriff = (char:FindFirstChild("Gun") or (backpack and backpack:FindFirstChild("Gun")))
        
        local color = Color3.fromRGB(0, 255, 120) -- Masum
        if isMurderer then
            color = Color3.fromRGB(255, 30, 30) -- Katil
        elseif isSheriff then
            color = Color3.fromRGB(30, 120, 255) -- Şerif
        end
        
        local folder = Instance.new("Folder")
        folder.Name = "Hunter_MM2_ESP"
        folder.Parent = char
        
        -- Kutu (Highlight)
        local hl = Instance.new("Highlight")
        hl.Name = "Box"
        hl.Adornee = char
        hl.FillColor = color
        hl.FillTransparency = 0.5
        hl.OutlineColor = Color3.fromRGB(255, 255, 255)
        hl.Parent = folder
        
        -- Etiket
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
        txt.TextColor3 = color
        txt.TextSize = 13
        txt.Font = Enum.Font.Code
        txt.TextStrokeTransparency = 0.4
        txt.Parent = bg
    end

    player.CharacterAdded:Connect(setup)
    if player.Character then task.spawn(function() setup(player.Character) end) end
end

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
-- STREAM PROOF MENÜ ARAYÜZÜ
--------------------------------------------------------------------------------
if TargetParent:FindFirstChild("Hunter_ESP_UI") then 
    TargetParent.Hunter_ESP_UI:Destroy() 
end

local ScreenGui
if TargetParent:IsA("ScreenGui") then
    ScreenGui = TargetParent
    ScreenGui.Name = "Hunter_ESP_UI"
else
    ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "Hunter_ESP_UI"
    ScreenGui.Parent = TargetParent
end

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 260, 0, 130)
MainFrame.Position = UDim2.new(0.5, -130, 0.5, -65)
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
TitleBar.Text = "  Hunter MM2 // Stream Proof Active"
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
ToggleBtn.Size = UDim2.new(0, 230, 0, 35)
ToggleBtn.Position = UDim2.new(0.5, -115, 0, 45)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(45, 35, 65)
ToggleBtn.Text = "ESP: Kapalı"
ToggleBtn.TextColor3 = Color3.fromRGB(160, 160, 160)
ToggleBtn.Font = Enum.Font.Code
ToggleBtn.TextSize = 12
ToggleBtn.Parent = MainFrame

Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 5)

ToggleBtn.MouseButton1Click:Connect(function()
    local newState = not Config.ESPEnabled
    toggleESP(newState)
    ToggleBtn.Text = newState and "ESP: Açık" or "ESP: Kapalı"
    ToggleBtn.BackgroundColor3 = newState and Color3.fromRGB(150, 50, 255) or Color3.fromRGB(45, 35, 65)
    ToggleBtn.TextColor3 = newState and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(160, 160, 160)
end)

local InfoLbl = Instance.new("TextLabel")
InfoLbl.Size = UDim2.new(1, 0, 0, 20)
InfoLbl.Position = UDim2.new(0, 0, 0, 95)
InfoLbl.BackgroundTransparency = 1
InfoLbl.Text = "OBS Game Capture Modunda Gizlenir"
InfoLbl.TextColor3 = Color3.fromRGB(100, 200, 100)
InfoLbl.Font = Enum.Font.Code
InfoLbl.TextSize = 10
InfoLbl.Parent = MainFrame
