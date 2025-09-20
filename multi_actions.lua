--[[ 
Brainrot Counter + Webhook (versão Wave) - separado por Player correto
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1418742012403777576/DAfbKA6HMqGx4wLq3DxLC4MXgao5t3FYB68a7S6GjMXnrqR7w6G6WS4VTAORXVy9WReO"

local request = http_request or request or (syn and syn.request) or (fluxus and fluxus.request)
if not request then
    warn("❌ Seu executor não suporta requisições HTTP!")
end

local function sendRequest(data)
    if not request then return false, "Executor não tem suporte a HTTP" end

    local payload = {
        Url = WEBHOOK_URL,
        Method = "POST",
        Headers = { ["Content-Type"] = "application/json" },
        Body = HttpService:JSONEncode(data)
    }

    local success, response = pcall(function()
        return request(payload)
    end)

    if not success then
        warn("Erro na requisição:", response)
        return false, response
    end

    return true, response
end

-- Contabiliza brainrots separados por Player (usando nome do modelo)
local function contarBrainrots()
    local playerStats = {}

    for _, baseModel in ipairs(Workspace:GetChildren()) do
        if baseModel:IsA("Model") and baseModel:FindFirstChild("Base") then
            local playerName = baseModel.Name:gsub("_Base", "")
            playerStats[playerName] = playerStats[playerName] or {}

            for _, descendant in ipairs(baseModel:GetDescendants()) do
                if descendant:IsA("TextLabel") and descendant.Name == "Generation" and not descendant.Text:lower():find("fusing") then
                    local displayName = descendant.Parent:FindFirstChild("DisplayName")
                    local mobName = displayName and displayName.Text or "N/A"

                    local mValueLabel = descendant.Parent:FindFirstChild("MValue")
                    local mValue = tonumber(mValueLabel and mValueLabel.Text:match("%d+")) or 0

                    if not playerStats[playerName][mobName] then
                        playerStats[playerName][mobName] = {count = 0, totalM = 0}
                    end

                    playerStats[playerName][mobName].count = playerStats[playerName][mobName].count + 1
                    playerStats[playerName][mobName].totalM = playerStats[playerName][mobName].totalM + mValue
                end
            end
        end
    end

    return playerStats
end

-- Gera mensagem formatada por Player
local function gerarMensagem(playerStats)
    local linhas = {}

    for playerName, mobs in pairs(playerStats) do
        table.insert(linhas, playerName)
        for mobName, info in pairs(mobs) do
            table.insert(linhas, string.format("%dx %s %dM", info.count, mobName, info.totalM))
        end
        table.insert(linhas, "") -- linha em branco entre players
    end

    if #linhas == 0 then
        return "Nenhum brainrot encontrado no mapa."
    else
local function gerarMensagem(playerStats)
    local linhas = {}

    for playerName, mobs in pairs(playerStats) do
        table.insert(linhas, "Base de: " .. playerName)
        for mobName, info in pairs(mobs) do
            table.insert(linhas, string.format("  %dx %s (%dM)", info.count, mobName, info.totalM))
        end
        table.insert(linhas, "") -- linha em branco entre players
    end

    if #linhas == 0 then
        return "Nenhum brainrot encontrado no mapa."
    else
        return table.concat(linhas, "\n")
    end
end
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = Frame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Counter"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 35)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Aguardando envio..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextScaled = true
StatusLabel.Parent = Frame

local SendButton = Instance.new("TextButton")
SendButton.Size = UDim2.new(1, -20, 0, 40)
SendButton.Position = UDim2.new(0, 10, 0, 75)
SendButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SendButton.Text = "Enviar para Discord"
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.GothamBold
SendButton.TextScaled = true
SendButton.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 8)
BtnCorner.Parent = SendButton

-- Botão
SendButton.MouseButton1Click:Connect(function()
    StatusLabel.Text = "Contando brainrots..."
    StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)

    local stats = contarBrainrots()
    local mensagem = gerarMensagem(stats)

    local payload = {
        username = "Brainrot Bot",
        content = mensagem
    }

    local ok, err = sendRequest(payload)
    if ok then
        StatusLabel.Text = "Enviado com sucesso!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
    else
        StatusLabel.Text = "Erro ao enviar!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        warn("Erro ao enviar: ", err)
    end
end)

