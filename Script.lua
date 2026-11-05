
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Criar RemoteEvent para receber solicitações de teleporte
local tpEvent = Instance.new("RemoteEvent")
tpEvent.Name = "TeleportarTeste"
tpEvent.Parent = ReplicatedStorage

-- Criar Tool (não é necessário Handle)
local function createTool()
    local tool = Instance.new("Tool")

    tool.Name = "Teste"
    tool.RequiresHandle = false
    tool.CanBeDropped = false
    tool.ManualActivationOnly = false

    -- Evitar problemas de ativação no mobile
    return tool
end

-- Criar botão de interface
local function createGui(player)
    local gui = Instance.new("ScreenGui")

    gui.Name = "TpToolGui"
    gui.ResetOnSpawn = false
    gui.Parent = player:WaitForChild("PlayerGui")

    local btn = Instance.new("TextButton")

    btn.Size = UDim2.new(0, 150, 0, 50)
    btn.Position = UDim2.new(0, 20, 0, 20)
    btn.Text = "Gerar Item de Teleporte"
    btn.TextScaled = true
    btn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
    btn.TextColor3 = Color3.new(1, 1, 1)
    btn.Parent = gui

    btn.Activated:Connect(function()

        -- Verificar se já possui, evitar duplicatas
        local backpack = player:FindFirstChildOfClass("Backpack")
        local char = player.Character

        if backpack and backpack:FindFirstChild("Teste") then
            return
        end

        if char and char:FindFirstChild("Teste") then
            return
        end

        local tool = createTool()
        tool.Parent = backpack
    end)
end

-- Criar GUI quando o jogador entrar
Players.PlayerAdded:Connect(function(player)
    createGui(player)
end)

-- Lógica de teleporte no servidor
tpEvent.OnServerEvent:Connect(function(player, targetPos)

    local char = player.Character

    if not char then
        return
    end

    local hrp = char:FindFirstChild("HumanoidRootPart")

    if not hrp then
        return
    end

    -- Validar posição recebida
    if typeof(targetPos) ~= "Vector3" then
        return
    end

    -- Limitar distância
    if (hrp.Position - targetPos).Magnitude > 5000 then
        return
    end

    -- Teleportar jogador
    hrp.CFrame = CFrame.new(
        targetPos + Vector3.new(0, 3, 0)
    )
end)
