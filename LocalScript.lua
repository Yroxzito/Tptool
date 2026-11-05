
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera
local tpEvent = ReplicatedStorage:WaitForChild("TeleportarTeste")

local toolEquipped = false

-- Detectar quando a ferramenta é equipada
local function setupCharacter(char)

    toolEquipped = false

    local function connectTool(child)

        if child.Name == "Teste" and child:IsA("Tool") then

            child.Equipped:Connect(function()
                toolEquipped = true
            end)

            child.Unequipped:Connect(function()
                toolEquipped = false
            end)

        end

    end

    -- Verificar ferramentas que já estão no personagem
    for _, child in ipairs(char:GetChildren()) do
        connectTool(child)
    end

    -- Detectar ferramentas adicionadas depois
    char.ChildAdded:Connect(connectTool)

end

-- Detectar personagem atual e futuros personagens
if player.Character then
    setupCharacter(player.Character)
end

player.CharacterAdded:Connect(setupCharacter)

-- Detectar clique ou toque na tela
UserInputService.InputBegan:Connect(function(input, gameProcessed)

    if gameProcessed then
        return
    end

    if not toolEquipped then
        return
    end

    -- Clique esquerdo do mouse ou toque no celular
    if input.UserInputType == Enum.UserInputType.MouseButton1
        or input.UserInputType == Enum.UserInputType.Touch then

        local screenPos = input.Position

        camera = workspace.CurrentCamera

        local ray = camera:ViewportPointToRay(
            screenPos.X,
            screenPos.Y
        )

        -- Ignorar o próprio personagem
        local params = RaycastParams.new()

        params.FilterType = Enum.RaycastFilterType.Exclude
        params.FilterDescendantsInstances = {
            player.Character
        }

        -- Detectar o objeto atingido
        local result = workspace:Raycast(
            ray.Origin,
            ray.Direction * 5000,
            params
        )

        -- Enviar posição para o servidor
        if result then
            tpEvent:FireServer(result.Position)
        end

    end

end)
