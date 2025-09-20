--[[ 
Steal a Brainrot Spy + Webhook
Envia todas as entidades importantes (Players, Brainrots, Bases) UMA ÚNICA VEZ
--]]

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local WEBHOOK_URL = "https://discord.com/api/webhooks/1418742003696402545/YEJJ3xFf6GL6mpZiPPJrCeAAbYJ9F9BgpGfRGKmxJrV-EW40nWdS4UaHUV9bk5Eg5Wkr"

-- Função para enviar dados para webhook
local function sendWebhook(content)
    local data = { ["content"] = content }
    local json = HttpService:JSONEncode(data)
    
    local request = http_request or request or syn and syn.request or fluxus and fluxus.request
    if request then
        request({
            Url = WEBHOOK_URL,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = json
        })
    else
        warn("Executor não suporta requisições HTTP!")
    end
end

-- Função para capturar players
local function getPlayers()
    local result = {}
    for _, player in pairs(Players:GetPlayers()) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local pos = player.Character.HumanoidRootPart.Position
            table.insert(result, "🟢 Player: "..player.Name.." | Position: "..tostring(pos))
        end
    end
    return result
end

-- Função para capturar Brainrots
local function getBrainrots()
    local result = {}
    local brainrotFolder = Workspace:FindFirstChild("Brainrots")
    if brainrotFolder then
        for _, brainrot in pairs(brainrotFolder:GetChildren()) do
            if brainrot:IsA("Model") and brainrot:FindFirstChild("HumanoidRootPart") then
                local pos = brainrot.HumanoidRootPart.Position
                table.insert(result, "🧠 Brainrot: "..brainrot.Name.." | Position: "..tostring(pos))
            end
        end
    end
    return result
end

-- Função para capturar Bases
local function getBases()
    local result = {}
    local baseFolder = Workspace:FindFirstChild("Bases")
    if baseFolder then
        for _, base in pairs(baseFolder:GetChildren()) do
            if base:IsA("Model") and base:FindFirstChild("HumanoidRootPart") then
                local pos = base.HumanoidRootPart.Position
                table.insert(result, "🏠 Base: "..base.Name.." | Position: "..tostring(pos))
            end
        end
    end
    return result
end

-- Espera 60 segundos e envia tudo de uma vez
task.wait(60)

local allEntities = {}
for _, v in pairs(getPlayers()) do table.insert(allEntities, v) end
for _, v in pairs(getBrainrots()) do table.insert(allEntities, v) end
for _, v in pairs(getBases()) do table.insert(allEntities, v) end

if #allEntities > 0 then
    sendWebhook(table.concat(allEntities, "\n"))
end
