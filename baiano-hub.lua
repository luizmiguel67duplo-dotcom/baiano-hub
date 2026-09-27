-- ============================================
-- 🎩 BAIANO HUB
-- Andar no Ar + God Mode
-- ============================================

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

local parentGui = gethui and gethui() or player:WaitForChild("PlayerGui")

local andarAtivo = false
local godAtivo = false
local connectionAndar = nil
local connectionGod = nil
local conexoesGod = {}
local alturaAlvo = nil
local aguardandoApice = false

-- ============================================
-- INTERFACE
-- ============================================

local sg = Instance.new("ScreenGui")
sg.Name = "BaianoHub"
sg.ResetOnSpawn = false
sg.Parent = parentGui

local painel = Instance.new("Frame")
painel.Size = UDim2.new(0, 200, 0, 160)
painel.Position = UDim2.new(0.5, -100, 0.15, 0)
painel.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
painel.BorderSizePixel = 0
painel.Active = true
painel.Draggable = true
painel.Parent = sg
Instance.new("UICorner", painel).CornerRadius = UDim.new(0, 12)
local ps = Instance.new("UIStroke", painel)
ps.Color = Color3.fromRGB(255, 200, 0)
ps.Thickness = 2

local titulo = Instance.new("TextLabel")
titulo.Size = UDim2.new(1, 0, 0, 32)
titulo.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
titulo.Text = "🎩 BAIANO HUB"
titulo.TextColor3 = Color3.fromRGB(25, 25, 30)
titulo.TextScaled = true
titulo.Font = Enum.Font.GothamBlack
titulo.Parent = painel
Instance.new("UICorner", titulo).CornerRadius = UDim.new(0, 12)

local fix = Instance.new("Frame")
fix.Size = UDim2.new(1, 0, 0, 8)
fix.Position = UDim2.new(0, 0, 1, -8)
fix.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
fix.BorderSizePixel = 0
fix.Parent = titulo

local botaoAndar = Instance.new("TextButton")
botaoAndar.Size = UDim2.new(1, -20, 0, 45)
botaoAndar.Position = UDim2.new(0, 10, 0, 40)
botaoAndar.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
botaoAndar.Text = "Andar no Ar: OFF"
botaoAndar.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoAndar.TextScaled = true
botaoAndar.Font = Enum.Font.GothamBold
botaoAndar.Active = true
botaoAndar.Parent = painel
Instance.new("UICorner", botaoAndar).CornerRadius = UDim.new(0, 8)

local botaoGod = Instance.new("TextButton")
botaoGod.Size = UDim2.new(1, -20, 0, 45)
botaoGod.Position = UDim2.new(0, 10, 0, 95)
botaoGod.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
botaoGod.Text = "God Mode: OFF"
botaoGod.TextColor3 = Color3.fromRGB(255, 255, 255)
botaoGod.TextScaled = true
botaoGod.Font = Enum.Font.GothamBold
botaoGod.Active = true
botaoGod.Parent = painel
Instance.new("UICorner", botaoGod).CornerRadius = UDim.new(0, 8)

-- ============================================
-- REFS DO PERSONAGEM
-- ============================================

player.CharacterAdded:Connect(function(c)
    character = c
    humanoid = c:WaitForChild("Humanoid")
    rootPart = c:WaitForChild("HumanoidRootPart")
    task.wait(1)
    if godAtivo then pcall(aplicarGod) end
end)

-- ============================================
-- ANDAR NO AR
-- ============================================

local function iniciarAndar()
    if connectionAndar then connectionAndar:Disconnect() end
    alturaAlvo = nil
    aguardandoApice = false
    
    connectionAndar = RunService.Heartbeat:Connect(function()
        if not andarAtivo or not character or not rootPart or not humanoid then return end
        if humanoid.Health <= 0 then return end
        
        local pos = rootPart.Position
        local vel = rootPart.AssemblyLinearVelocity
        
        local rp = RaycastParams.new()
        rp.FilterDescendantsInstances = {character}
        rp.FilterType = Enum.RaycastFilterType.Exclude
        local rr = workspace:Raycast(pos, Vector3.new(0, -3.5, 0), rp)
        local noChao = rr ~= nil and humanoid.FloorMaterial ~= Enum.Material.Air
        
        if noChao then
            alturaAlvo = nil
            aguardandoApice = false
            if vel.Y > 1 then aguardandoApice = true end
            return
        end
        
        if aguardandoApice then
            if vel.Y <= 0.5 then
                alturaAlvo = pos.Y
                aguardandoApice = false
            else
                return
            end
        end
        
        if not alturaAlvo then alturaAlvo = pos.Y end
        
        local dif = pos.Y - alturaAlvo
        local vy = 0
        if math.abs(dif) > 0.1 then
            vy = math.clamp(-dif * 8, -30, 30)
        end
        
        rootPart.AssemblyLinearVelocity = Vector3.new(vel.X, vy, vel.Z)
        
        if Vector3.new(vel.X, 0, vel.Z).Magnitude > 0.5 then
            pcall(function() humanoid:ChangeState(Enum.HumanoidStateType.Running) end)
        end
    end)
end

local function pararAndar()
    if connectionAndar then connectionAndar:Disconnect() connectionAndar = nil end
    alturaAlvo = nil
    aguardandoApice = false
end

-- ============================================
-- GOD MODE
-- ============================================

function aplicarGod()
    for _, c in ipairs(conexoesGod) do pcall(function() c:Disconnect() end) end
    conexoesGod = {}
    if connectionGod then connectionGod:Disconnect() end
    
    if not humanoid then return end
    pcall(function()
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
        humanoid.BreakJointsOnDeath = false
    end)
    
    connectionGod = RunService.Heartbeat:Connect(function()
        if not godAtivo or not humanoid or not humanoid.Parent then return end
        pcall(function()
            if humanoid.MaxHealth < 1e10 then humanoid.MaxHealth = math.huge end
            if humanoid.Health < humanoid.MaxHealth then humanoid.Health = humanoid.MaxHealth end
        end)
    end)
    
    table.insert(conexoesGod, humanoid.Died:Connect(function()
        if godAtivo then pcall(function() humanoid.Health = humanoid.MaxHealth end) end
    end))
    
    table.insert(conexoesGod, humanoid.HealthChanged:Connect(function(v)
        if godAtivo and v <= 0 then
            pcall(function() humanoid.Health = humanoid.MaxHealth end)
        end
    end))
end

function desativarGod()
    for _, c in ipairs(conexoesGod) do pcall(function() c:Disconnect() end) end
    conexoesGod = {}
    if connectionGod then connectionGod:Disconnect() connectionGod = nil end
    if humanoid then
        pcall(function()
            humanoid.MaxHealth = 100
            humanoid.Health = 100
            humanoid.BreakJointsOnDeath = true
        end)
    end
end

-- ============================================
-- BOTÕES
-- ============================================

botaoAndar.MouseButton1Click:Connect(function()
    andarAtivo = not andarAtivo
    if andarAtivo then
        botaoAndar.Text = "Andar no Ar: ON"
        botaoAndar.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        iniciarAndar()
    else
        botaoAndar.Text = "Andar no Ar: OFF"
        botaoAndar.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        pararAndar()
    end
end)

botaoGod.MouseButton1Click:Connect(function()
    godAtivo = not godAtivo
    if godAtivo then
        botaoGod.Text = "God Mode: ON"
        botaoGod.BackgroundColor3 = Color3.fromRGB(40, 180, 40)
        pcall(aplicarGod)
    else
        botaoGod.Text = "God Mode: OFF"
        botaoGod.BackgroundColor3 = Color3.fromRGB(180, 40, 40)
        pcall(desativarGod)
    end
end)

-- ============================================
-- NOTIFICAÇÃO
-- ============================================

local notif = Instance.new("TextLabel")
notif.Size = UDim2.new(0, 250, 0, 40)
notif.Position = UDim2.new(0.5, -125, 0.02, 0)
notif.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
notif.TextColor3 = Color3.fromRGB(255, 200, 0)
notif.Text = "🎩 BAIANO HUB carregado!"
notif.TextScaled = true
notif.Font = Enum.Font.GothamBold
notif.Parent = sg
Instance.new("UICorner", notif).CornerRadius = UDim.new(0, 8)
local nStroke = Instance.new("UIStroke", notif)
nStroke.Color = Color3.fromRGB(255, 200, 0)
nStroke.Thickness = 2

task.wait(3)
notif:Destroy()

print("[BAIANO HUB] Carregado! 🎩")
