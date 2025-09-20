--[[ 
Show All ESP Universal
Funciona em qualquer jogo Roblox
--]]

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local HighlightFolder = Instance.new("Folder", Workspace)
HighlightFolder.Name = "ESP_Highlights"

-- Função para criar highlight para cada objeto
local function createHighlight(part)
    local highlight = Instance.new("BoxHandleAdornment")
    highlight.Adornee = part
    highlight.Size = part.Size
    highlight.Color3 = Color3.fromRGB(255, 0, 0)
    highlight.Transparency = 0.5
    highlight.AlwaysOnTop = true
    highlight.ZIndex = 10
    highlight.Parent = HighlightFolder
end

-- Inicial: aplica highlight em todos os objetos visuais
for _, obj in pairs(Workspace:GetDescendants()) do
    if obj:IsA("BasePart") and not obj:IsDescendantOf(HighlightFolder) then
        createHighlight(obj)
    end
end

-- Atualiza dinamicamente se novos objetos aparecerem
Workspace.DescendantAdded:Connect(function(obj)
    if obj:IsA("BasePart") then
        createHighlight(obj)
    end
end)

-- Opcional: mostra nome e distância
RunService.RenderStepped:Connect(function()
    for _, part in pairs(HighlightFolder:GetChildren()) do
        if part.Adornee then
            local distance = (part.Adornee.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            part.Adornee:SetAttribute("ESP_Info", part.Adornee.Name .. " | " .. math.floor(distance) .. " studs")
        end
    end
end)
