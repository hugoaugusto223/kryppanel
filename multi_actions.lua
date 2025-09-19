--[[ 
Brainrot Counter + Webhook (versão Wave) - com M
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local HttpService = game:GetService("HttpService")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1418742012403777576/DAfbKA6HMqGx4wLq3DxLC4MXgao5t3FYB68a7S6GjMXnrqR7w6G6WS4VTAORXVy9WReO"

local request = http_request or request or syn and syn.request or fluxus and fluxus.request
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

-- Contabiliza brainrots e soma M
local function contarBrainrots()
    local brainrotStats = {}

    for _, o in ipairs(Workspace:GetDescendants()) do
        if o:IsA("TextLabel") and o.Name == "Generation" and not o.Text:lower():find("fusing") then
            local parent = o.Parent
            local basePart
            while parent and parent ~= Workspace do
                if parent:IsA("Model") and parent:FindFirstChild("Base") then
                    basePart = parent.Base
                    break
                end
                parent = parent.Parent
            end

            if basePart then
                local displayName = o.Parent:FindFirstChild("DisplayName")
                local mobName = displayName and displayName.Text or "N/A"

                local mValueLabel = o.Parent:FindFirstChild("MValue") -- ajuste conforme seu jogo
                local mValue = tonumber(mValueLabel and mValueLabel.Text:match("%d+")) or 0

                if not brainrotStats[mobName] then
                    brainrotStats[mobName] = {count = 0, totalM = 0}
                end

                brainrotStats[mobName].count += 1
                brainrotStats[mobName].totalM += mValue
            end
        end
    end

    return brainrotStats
end

-- Gera mensagem formatada pro Discord
local function gerarMensagem(brainrotStats)
    local linhas = {}
    for nome, info in pairs(brainrotStats) do
        table.insert(linhas, string.format("**%dx %s** — Total M: %d", info.count, nome, info.totalM))
    end

    if #linhas == 0 then
        return "Nenhum brainrot encontrado no mapa."
    else
        table.sort(linhas)
        return "**📊 Contagem de Brainrots:**\n" .. table.concat(linhas, "\n")
    end
end

-- GUI
local player = Players.LocalPlayer
if not player then warn("LocalPlayer não encontrado!") return end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotCounter"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = player:WaitForChild("PlayerGui")

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 140)
Frame.Position = UDim2.new(0, 20, 0, 200)
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
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
