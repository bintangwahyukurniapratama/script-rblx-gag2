-- ====================================================================
-- KYRIEL HUB v3.0 - GROW A GARDEN 2 (NATIVE MOBILE UI EDITION)
-- Slogan: I just give the tools, whether they're used right or not is your business, boss.
-- ====================================================================

-- Mencegah duplikasi menu jika skrip dijalankan ulang
if game.CoreGui:FindFirstChild("KyrielHubGAG2") then
    game.CoreGui.KyrielHubGAG2:Destroy()
end

-- 1. PEMBUATAN INTERFACE UI ASLI ROBLOX (NATIVE SCREEN_GUI)
local ScreenGui = Instance.new("ScreenGui")
local MainFrame = Instance.new("Frame")
local TitleLabel = Instance.new("TextLabel")
local SloganLabel = Instance.new("TextLabel")
local UIListLayout = Instance.new("UIListLayout")

ScreenGui.Name = "KyrielHubGAG2"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

-- Bingkai Utama Menu (Bisa digeser di layar HP)
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.Position = UDim2.new(0.3, 0, 0.2, 0)
MainFrame.Size = UDim2.new(0, 240, 0, 280)
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50)

-- Judul Menu
TitleLabel.Name = "TitleLabel"
TitleLabel.Parent = MainFrame
TitleLabel.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
TitleLabel.Size = UDim2.new(1, 0, 0, 35)
TitleLabel.Font = Enum.Font.SourceSansBold
TitleLabel.Text = "KYRIEL HUB | GAG 2"
TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
TitleLabel.TextSize = 18

-- Slogan Kecil di Bawah Judul
SloganLabel.Name = "SloganLabel"
SloganLabel.Parent = MainFrame
SloganLabel.BackgroundTransparency = 1
SloganLabel.Position = UDim2.new(0, 0, 0, 35)
SloganLabel.Size = UDim2.new(1, 0, 0, 15)
SloganLabel.Font = Enum.Font.SourceSansItalic
SloganLabel.Text = "I just give the tools..."
SloganLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
SloganLabel.TextSize = 11

-- Wadah Tombol-Tombol Saklar
local ButtonContainer = Instance.new("Frame")
ButtonContainer.Name = "ButtonContainer"
ButtonContainer.Parent = MainFrame
ButtonContainer.BackgroundTransparency = 1
ButtonContainer.Position = UDim2.new(0, 10, 0, 55)
ButtonContainer.Size = UDim2.new(1, -20, 1, -65)

UIListLayout.Parent = ButtonContainer
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 8)

-- 2. NEGARA VARIABLE KONTROL
_G.AutoHarvest = false
_G.StealNight = false
_G.GoldSeed = false
_G.RainbowSeed = false
_G.BypassDistance = false

-- 3. FUNGSI UNTUK MEMBUAT TOMBOL SAKLAR KUSTOM (TOGGLE BUTTON)
local function createToggle(name, callback)
    local Button = Instance.new("TextButton")
    Button.Name = name .. "Btn"
    Button.Parent = ButtonContainer
    Button.Size = UDim2.new(1, 0, 0, 32)
    Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Button.Font = Enum.Font.SourceSansSemibold
    Button.Text = name .. " : OFF"
    Button.TextColor3 = Color3.fromRGB(255, 100, 100)
    Button.TextSize = 14
    Button.BorderSizePixel = 0
    
    local active = false
    Button.MouseButton1Click:Connect(function()
        active = not active
        if active then
            Button.BackgroundColor3 = Color3.fromRGB(35, 100, 35)
            Button.TextColor3 = Color3.fromRGB(100, 255, 100)
            Button.Text = name .. " : ON"
        else
            Button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            Button.TextColor3 = Color3.fromRGB(255, 100, 100)
            Button.Text = name .. " : OFF"
        end
        callback(active)
    end)
end

-- 4. MENYUNTIKKAN TOMBOL KE MENU VISUAL
createToggle("Auto Harvest (Milik Sendiri)", function(state) _G.AutoHarvest = state end)
createToggle("Auto Steal Night (Nyolong)", function(state) _G.StealNight = state end)
createToggle("Prioritas Gold Seed", function(state) _G.GoldSeed = state end)
createToggle("Prioritas Rainbow Seed", function(state) _G.RainbowSeed = state end)
createToggle("Bypass Batasan Jarak", function(state) _G.BypassDistance = state end)

-- Tombol Minimize Menu (Biar gak menonjol di layar HP)
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = MainFrame
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(1, -32, 0, 2)
MinBtn.BackgroundColor3 = Color3.fromRGB(60, 20, 20)
MinBtn.Text = "-"
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.TextSize = 16
local minimized = false
MinBtn.MouseButton1Click:Connect(function()
    minimized = not minimized
    if minimized then
        ButtonContainer.Visible = false
        MainFrame.Size = UDim2.new(0, 240, 0, 35)
        MinBtn.Text = "+"
    else
        ButtonContainer.Visible = true
        MainFrame.Size = UDim2.new(0, 240, 0, 280)
        MinBtn.Text = "-"
    end
end)

-- 5. FUNGSI UTAMA PEMICU PANEN GAME
local function triggerPrompt(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration)
        prompt:InputHoldEnd()
    end
end

-- 6. ENGINE PENGGERAK FUNGSI (BACKGROUND THREAD)
task.spawn(function()
    while true do
        task.wait(0.1)
        
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    
                    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                    local objectText = obj.ObjectText:lower()
                    local actionText = obj.ActionText:lower()
                    
                    local inRange = true
                    if not _G.BypassDistance then
                        local distance = (hrp.Position - obj.Parent.Position).Magnitude
                        if distance > 25 then
                            inRange = false
                        end
                    end
                    
                    if inRange then
                        -- Ambil Rainbow Seed
                        if _G.RainbowSeed and (string.find(parentName, "rainbow") or string.find(objectText, "rainbow") or string.find(actionText, "rainbow")) then
                            triggerPrompt(obj)
                            continue
                        end

                        -- Ambil Gold Seed
                        if _G.GoldSeed and (string.find(parentName, "gold") or string.find(objectText, "gold") or string.find(actionText, "gold")) then
                            triggerPrompt(obj)
                            continue
                        end

                        -- Curi saat Steal Night
                        if _G.StealNight and (string.find(actionText, "steal") or string.find(objectText, "steal")) then
                            triggerPrompt(obj)
                            continue
                        end
                        
                        -- Panen Normal kebun sendiri
                        if _G.AutoHarvest and (string.find(actionText, "harvest") or string.find(actionText, "collect")) then
                            triggerPrompt(obj)
                        end
                    end

                end
            end
        end
    end
end)

print("[Kyriel Hub] Native UI successfully loaded, Boss!")
