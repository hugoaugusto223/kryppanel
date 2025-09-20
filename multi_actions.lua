--[[ 
    Brainrot Counter + Webhook (com GUI e webhook já configurado)
    Funciona no Wave e outros executores
--]]

------------------------------
-- CONFIGURAÇÕES
------------------------------
local WEBHOOK_URL = "https://discord.com/api/webhooks/1418742012403777576/DAfbKA6HMqGx4wLq3DxLC4MXgao5t3FYB68a7S6GjMXnrqR7w6G6WS4VTAORXVy9WReO"
------------------------------

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

-- Remove GUI antiga se existir
if PlayerGui:FindFirstChild("BrainrotGui") then
    PlayerGui:FindFirstChild("BrainrotGui"):Destroy()
end

--------------------------------
-- GUI
--------------------------------
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "BrainrotGui"
ScreenGui.Parent = PlayerGui

local Frame = Instance.new("Frame")
Frame.Size = UDim2.new(0, 260, 0, 150)
Frame.Position = UDim2.new(0, 10, 1, -160) -- canto inferior esquerdo
Frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Frame.BorderSizePixel = 0
Frame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = Frame

-- Título
local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Text = "Brainrot Counter"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextScaled = true
Title.Parent = Frame

-- Status
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Size = UDim2.new(1, -20, 0, 30)
StatusLabel.Position = UDim2.new(0, 10, 0, 40)
StatusLabel.BackgroundTransparency = 1
StatusLabel.Text = "Aguardando..."
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextScaled = true
StatusLabel.Parent = Frame

-- Botão
local SendButton = Instance.new("TextButton")
SendButton.Size = UDim2.new(1, -20, 0, 45)
SendButton.Position = UDim2.new(0, 10, 0, 85)
SendButton.BackgroundColor3 = Color3.fromRGB(50, 150, 50)
SendButton.Text = "Enviar para Discord"
SendButton.TextColor3 = Color3.fromRGB(255, 255, 255)
SendButton.Font = Enum.Font.GothamBold
SendButton.TextScaled = true
SendButton.Parent = Frame

local BtnCorner = Instance.new("UICorner")
BtnCorner.CornerRadius = UDim.new(0, 10)
BtnCorner.Parent = SendButton

--------------------------------
-- LÓGICA DE CONTAGEM
--------------------------------
local brainrotCounter = {}

-- Função para adicionar um brainrot na contagem
local function addBrainrot(playerName, brainrotName, amount)
    if not brainrotCounter[playerName] then
        brainrotCounter[playerName] = {}
    end

    if not brainrotCounter[playerName][brainrotName] then
        brainrotCounter[playerName][brainrotName] = 0
    end

    brainrotCounter[playerName][brainrotName] += amount
end

-- SIMULAÇÃO: Testando manualmente
-- addBrainrot("Kryp", "Los Combi", 60)
-- addBrainrot("Kryp", "La Grande Combinassion", 15)

--------------------------------
-- ENVIO PARA DISCORD
--------------------------------
local function sendToDiscord()
    if not WEBHOOK_URL or WEBHOOK_URL == "" then
        StatusLabel.Text = "Webhook não configurado!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        return
    end

    -- Monta a mensagem
    local message = "**Brainrot Report**\n\n"
    for playerName, brainrots in pairs(brainrotCounter) do
        message = message .. "👤 **" .. playerName .. "**\n"
        for brainrotName, amount in pairs(brainrots) do
            message = message .. "- " .. brainrotName .. ": " .. tostring(amount) .. "M\n"
        end
        message = message .. "\n"
    end

    if message == "**Brainrot Report**\n\n" then
        StatusLabel.Text = "Nenhum brainrot registrado!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0)
        return
    end

    local data = {
        ["username"] = "Brainrot Bot",
        ["content"] = message
    }

    local jsonData = HttpService:JSONEncode(data)

    -- Envia requisição HTTP
    local request = (http_request or request or syn and syn.request or fluxus and fluxus.request)
    if request then
        local success, response = pcall(function()
            return request({
                Url = WEBHOOK_URL,
                Method = "POST",
                Headers = {
                    ["Content-Type"] = "application/json"
                },
                Body = jsonData
            })
        end)

        if success then
            StatusLabel.Text = "Enviado com sucesso!"
            StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        else
            StatusLabel.Text = "Erro ao enviar!"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
    else
        StatusLabel.Text = "Executor sem HTTP!"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
    end
end

-- Evento do botão
SendButton.MouseButton1Click:Connect(sendToDiscord)
