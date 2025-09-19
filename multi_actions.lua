--// Serviços
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")
local StarterGui = game:GetService("StarterGui")

--// CONFIGURAÇÃO DO WEBHOOK
local WEBHOOK_URL = "https://discord.com/api/webhooks/1418742012403777576/DAfbKA6HMqGx4wLq3DxLC4MXgao5t3FYB68a7S6GjMXnrqR7w6G6WS4VTAORXVy9WReO"

--// Função para criar GUI com botão
local function createButton()
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "BrainrotCounter"
    screenGui.ResetOnSpawn = false
    screenGui.Parent = game.CoreGui

    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0, 200, 0, 50)
    button.Position = UDim2.new(0.5, -100, 0.9, 0) -- centro inferior
    button.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 18
    button.Text = "Enviar Brainrots"
    button.Parent = screenGui

    return button
end

--// Função que faz a contagem por player
local function contarBrainrots()
    local resultado = {}

    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("TextLabel") and o.Name == "Generation" and not o.Text:lower():find("fusing") then
            local parent = o.Parent
            local ownerName = "Desconhecido"

            -- Tenta descobrir o dono do brainrot
            local p = o:FindFirstAncestorWhichIsA("Model")
            if p and p:FindFirstChild("Owner") and p.Owner:IsA("StringValue") then
                ownerName = p.Owner.Value
            end

            -- Nome do brainrot
            local displayName = o.Parent:FindFirstChild("DisplayName")
            local mobName = displayName and displayName.Text or "N/A"

            -- Inicializa tabelas se não existirem
            if not resultado[ownerName] then
                resultado[ownerName] = {}
            end
            if not resultado[ownerName][mobName] then
                resultado[ownerName][mobName] = 0
            end

            resultado[ownerName][mobName] += 1
        end
    end

    return resultado
end

--// Formata a mensagem pro Discord
local function formatarMensagem(dados)
    local linhas = {}
    table.insert(linhas, "**📊 Contagem de Brainrots**\n")

    for playerName, brainrots in pairs(dados) do
        table.insert(linhas, "**" .. playerName .. "**:")
        for brainrotName, quantidade in pairs(brainrots) do
            table.insert(linhas, string.format("`%dx` %s", quantidade, brainrotName))
        end
        table.insert(linhas, "") -- Linha em branco entre players
    end

    return table.concat(linhas, "\n")
end

--// Envia os dados pro Discord
local function enviarParaDiscord()
    local dados = contarBrainrots()
    local mensagem = formatarMensagem(dados)

    local payload = HttpService:JSONEncode({content = mensagem})

    local success, err = pcall(function()
        HttpService:PostAsync(WEBHOOK_URL, payload, Enum.HttpContentType.ApplicationJson)
    end)

    if success then
        StarterGui:SetCore("SendNotification", {
            Title = "Brainrot Counter",
            Text = "✅ Dados enviados com sucesso!",
            Duration = 3
        })
    else
        StarterGui:SetCore("SendNotification", {
            Title = "Brainrot Counter",
            Text = "❌ Erro ao enviar: " .. tostring(err),
            Duration = 5
        })
    end
end

--// Inicializa GUI
local button = createButton()
button.MouseButton1Click:Connect(enviarParaDiscord)
