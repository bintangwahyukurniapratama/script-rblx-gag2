-- ====================================================================
-- KYRIEL HUB - GROW A GARDEN 2 (CLEAN & SAFE VERSION)
-- Slogan: I just give the tools, whether they're used right or not is your business, boss.
-- ====================================================================

-- 1. MEMUAT LIBRARY UI (Menggunakan Orion Library yang sangat bersahabat dengan Delta Mobile)
local OrionLib = loadstring(game:HttpGet(('https://raw.githubusercontent.com/shlexware/Orion/main/source')))()

-- 2. MEMBUAT WINDOW UTAMA
local Window = OrionLib:MakeWindow({
    Name = "Kyriel Hub | Grow a Garden 2", 
    HidePremium = true, 
    SaveConfig = false, 
    ConfigFolder = "KyrielConfig"
})

-- 3. NEGARA VARIABLE GLOBAL (Untuk Status On/Off Fitur)
_G.AutoHarvest = false
_G.StealNight = false
_G.GoldSeed = false
_G.RainbowSeed = false
_G.BypassDistance = false -- Fitur ambil jarak jauh
_G.WalkSpeed = 16
_G.JumpPower = 50
_G.InfJump = false

-- 4. MEMBUAT TAB-TAB MENU
local FarmTab = Window:MakeTab({
    Name = "Auto Farm",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

local PlayerTab = Window:MakeTab({
    Name = "Player",
    Icon = "rbxassetid://4483345998",
    PremiumOnly = false
})

-- 5. MENAMBAHKAN ELEMEN TAB: AUTO FARM
FarmTab:AddSection({
    Name = "Mekanisme Panen"
})

FarmTab:AddToggle({
    Name = "Auto Harvest (Kebun Sendiri)",
    Default = false,
    Callback = function(Value)
        _G.AutoHarvest = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Steal Night (Curi Kebun Lain)",
    Default = false,
    Callback = function(Value)
        _G.StealNight = Value
    end    
})

FarmTab:AddSection({
    Name = "Prioritas Event Spesial"
})

FarmTab:AddToggle({
    Name = "Auto Ambil Gold Seed",
    Default = false,
    Callback = function(Value)
        _G.GoldSeed = Value
    end    
})

FarmTab:AddToggle({
    Name = "Auto Ambil Rainbow Seed",
    Default = false,
    Callback = function(Value)
        _G.RainbowSeed = Value
    end    
})

FarmTab:AddSection({
    Name = "Modifikasi Jangkauan"
})

FarmTab:AddToggle({
    Name = "Bypass Batasan Jarak",
    Default = false,
    Callback = function(Value)
        _G.BypassDistance = Value
    end    
})

-- 6. MENAMBAHKAN ELEMEN TAB: PLAYER (WALKSPEED & JUMPPOWER)
PlayerTab:AddSection({
    Name = "Statistik Karakter"
})

PlayerTab:AddSlider({
    Name = "Kecepatan Jalan (WalkSpeed)",
    Min = 16,
    Max = 150,
    Default = 16,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Speed",
    Callback = function(Value)
        _G.WalkSpeed = Value
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
        end
    end    
})

PlayerTab:AddSlider({
    Name = "Tinggi Lompatan (JumpPower)",
    Min = 50,
    Max = 300,
    Default = 50,
    Color = Color3.fromRGB(255,255,255),
    Increment = 1,
    ValueName = "Power",
    Callback = function(Value)
        _G.JumpPower = Value
        if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
            game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
        end
    end    
})

PlayerTab:AddToggle({
    Name = "Lompatan Tanpa Batas (Inf Jump)",
    Default = false,
    Callback = function(Value)
        _G.InfJump = Value
    end    
})

-- 7. FUNGSI EKSEKUSI TOMBOL PANEN GAME (PROXIMITY PROMPT)
local function triggerHarvest(prompt)
    if fireproximityprompt then
        fireproximityprompt(prompt)
    else
        -- Cara alternatif jika eksekutor tidak mendukung bypass native
        prompt:InputHoldBegin()
        task.wait(prompt.HoldDuration)
        prompt:InputHoldEnd()
    end
end

-- 8. THREAD UTAMA UNTUK AUTO-FARMING (BACKGROUND WORKER)
task.spawn(function()
    while true do
        task.wait(0.1) -- Menjaga HP/Emulator tidak overheat
        
        local Players = game:GetService("Players")
        local LocalPlayer = Players.LocalPlayer
        
        if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = LocalPlayer.Character.HumanoidRootPart
            
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj:IsA("ProximityPrompt") then
                    
                    local parentName = obj.Parent and obj.Parent.Name:lower() or ""
                    local objectText = obj.ObjectText:lower()
                    local actionText = obj.ActionText:lower()
                    
                    -- Pengecekan Jarak jika fitur bypass dimatikan
                    local inRange = true
                    if not _G.BypassDistance then
                        local distance = (hrp.Position - obj.Parent.Position).Magnitude
                        if distance > 25 then
                            inRange = false
                        end
                    end
                    
                    if inRange then
                        -- [A] EVENT RAINBOW SEED
                        if _G.RainbowSeed and (string.find(parentName, "rainbow") or string.find(objectText, "rainbow") or string.find(actionText, "rainbow")) then
                            triggerHarvest(obj)
                            continue
                        end

                        -- [B] EVENT GOLD SEED
                        if _G.GoldSeed and (string.find(parentName, "gold") or string.find(objectText, "gold") or string.find(actionText, "gold")) then
                            triggerHarvest(obj)
                            continue
                        end

                        -- [C] EVENT STEAL NIGHT
                        if _G.StealNight and (string.find(actionText, "steal") or string.find(objectText, "steal")) then
                            triggerHarvest(obj)
                            continue
                        end
                        
                        -- [D] PANEN NORMAL
                        if _G.AutoHarvest and (string.find(actionText, "harvest") or string.find(actionText, "collect")) then
                            triggerHarvest(obj)
                        end
                    end

                end
            end
        end
    end
end)

-- 9. THREAD UNTUK LOOP PLAYER (WALKSPEED & INFINITE JUMP)
task.spawn(function()
    -- Cek Infinite Jump
    game:GetService("UserInputService").JumpRequest:Connect(function()
        if _G.InfJump and game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid") then
            game.Players.LocalPlayer.Character:FindFirstChildOfClass("Humanoid"):ChangeState("Jumping")
        end
    end)
    
    -- Jaga agar WalkSpeed & JumpPower tidak reset saat karakter mati/respawn
    game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
        local hum = char:WaitForChild("Humanoid")
        task.wait(1)
        hum.WalkSpeed = _G.WalkSpeed
        hum.JumpPower = _G.JumpPower
    end)
end)

-- 10. NOTIFIKASI SUKSES AKTIF
OrionLib:MakeNotification({
    Name = "Kyriel Hub Aktif!",
    Content = "Gak pake key, gak pake iklan. Nikmatin gamenya, Bos!",
    Image = "rbxassetid://4483345998",
    Time = 6
})

OrionLib:Init()
