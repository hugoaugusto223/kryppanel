-- painel_debug.lua
-- Versão pronta para colar no executor (cliente). Logs e fallbacks inclusos.
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")

local commands = {"rocket", "ragdoll", "balloon", "inverse", "nightvision", "jail", "jumpscare"}

local LocalPlayer = Players.LocalPlayer
print("[debug] LocalPlayer inicial:", LocalPlayer and LocalPlayer.Name or "nil")

local tryWait = 0
while not LocalPlayer and tryWait < 5 do
    task.wait(0.5)
    LocalPlayer = Players.LocalPlayer
    tryWait = tryWait + 0.5
    print(("[debug] esperando LocalPlayer... (%.1f)"):format(tryWait))
end

if not LocalPlayer then
    print("[erro] LocalPlayer não disponível. Executor pode não estar injetando no contexto do cliente.")
    return
end

local PlayerGui = LocalPlayer:FindFirstChild("PlayerGui")
if not PlayerGui then
    print("[aviso] PlayerGui não encontrado. Tentando fallback para CoreGui.")
end

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "AlwaysVisibleAdminPanel_debug"

if PlayerGui then
    screenGui.Parent = PlayerGui
    print("[debug] ScreenGui parentado em PlayerGui")
else
    local ok, err = pcall(function() screenGui.Parent = game:GetService("CoreGui") end)
    if ok then
        print("[debug] ScreenGui parentado em CoreGui (fallback)")
    else
        print("[erro] não foi possível parentar em CoreGui:", err)
    end
end

local frame = Instance.new("Frame")
frame.Size = UDim2.new(0,250,0,300)
frame.AnchorPoint = Vector2.new(1,1)
frame.Position = UDim2.new(1,-20,1,-20)
frame.BackgroundColor3 = Color3.fromRGB(50,0,50)
frame.BackgroundTransparency = 0.1
frame.Parent = screenGui

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1,0,0,30)
title.BackgroundTransparency = 1
title.Text = "kryp loves mgby (debug)"
title.TextColor3 = Color3.new(1,1,1)
title.TextScaled = true
title.Font = Enum.Font.GothamBold
title.Parent = frame

local scrollFrame = Instance.new("ScrollingFrame")
scrollFrame.Size = UDim2.new(1,0,1,-30)
scrollFrame.Position = UDim2.new(0,0,0,30)
scrollFrame.BackgroundTransparency = 1
scrollFrame.CanvasSize = UDim2.new(0,0,0,0)
scrollFrame.ScrollBarThickness = 6
scrollFrame.Parent = frame

local layout = Instance.new("UIListLayout")
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Padding = UDim.new(0,5)
layout.FillDirection = Enum.FillDirection.Vertical
layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
layout.Parent = scrollFrame

layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
    scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)
end)
scrollFrame.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 10)

do
    local dragging, dragInput, mousePos, framePos

    local function update(input)
        local delta = input.Position - mousePos
        frame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
end

local function getExecuteEvent()
    if ReplicatedStorage:FindFirstChild("Packages") and ReplicatedStorage.Packages:FindFirstChild("Net") then
        local net = ReplicatedStorage.Packages.Net
        local candidate = net:FindFirstChild("RE/AdminPanelService/ExecuteCommand")
        if candidate then
            print("[debug] encontrou ExecuteCommand no caminho esperado")
            return candidate
        end
        for _,v in ipairs(net:GetDescendants()) do
            if v:IsA("RemoteEvent") and string.find(v.Name:lower(), "execute") and string.find(v.Name:lower(), "command") then
                print("[debug] encontrou RemoteEvent parecido:", v:GetFullName())
                return v
            end
        end
    else
        print("[debug] Packages/Net não encontrados em ReplicatedStorage")
    end
    return nil
end

local event = getExecuteEvent()
if not event then
    print("[aviso] RemoteEvent ExecuteCommand não encontrado — as chamadas FireServer serão puladas.")
end

local function createPlayerButton(targetPlayer)
    local button = Instance.new("TextButton")
    button.Size = UDim2.new(0.9,0,0,30)
    button.BackgroundColor3 = Color3.fromRGB(100,0,100)
    button.TextColor3 = Color3.new(1,1,1)
    button.Text = targetPlayer.Name
    button.Font = Enum.Font.Gotham
    button.TextScaled = true
    button.Parent = scrollFrame

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0,10)
    corner.Parent = button

    local capturedPlayer = targetPlayer

    button.MouseButton1Click:Connect(function()
        print(("[debug] botão clicado em %s"):format(capturedPlayer.Name))
        task.spawn(function()
            for _, cmd in ipairs(commands) do
                if event then
                    local ok, err = pcall(function()
                        event:FireServer(capturedPlayer, cmd)
                    end)
                    if not ok then
                        print(("[erro] FireServer falhou para %s com comando %s -> %s"):format(capturedPlayer.Name, cmd, tostring(err)))
                    else
                        print(("[debug] FireServer chamado para %s com %s"):format(capturedPlayer.Name, cmd))
                    end
                else
                    print("[debug] nenhum event para FireServer, pulando chamada")
                end
                task.wait(0.5)
            end
        end)
    end)
end

for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        createPlayerButton(player)
    end
end

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        createPlayerButton(player)
    end
end)

print("[debug] script de painel pronto")
