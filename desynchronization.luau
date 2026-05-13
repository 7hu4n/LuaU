local run_service = game:GetService("RunService");local player = game:GetService("Players").LocalPlayer;local input_service = game:GetService("UserInputService");local cam = workspace.CurrentCamera

local char, root, head, hum
local active = false
local static_pos = nil
local ghost = nil
local cam_part = nil

local function setup(new_char)
    char = new_char
    root = new_char:WaitForChild("HumanoidRootPart")
    head = new_char:WaitForChild("Head")
    hum = new_char:WaitForChild("Humanoid")
    hum.Died:Connect(function()
        active = false
        cam.CameraSubject = hum
        if ghost then ghost:Destroy() end
        if cam_part then cam_part:Destroy() end
    end)
end
if player.Character then setup(player.Character) end
player.CharacterAdded:Connect(setup)

local function make_ghost()
    if ghost then ghost:Destroy() end
    char.Archivable = true
    ghost = char:Clone()
    char.Archivable = false
	
	local main = ghost:FindFirstChild("HumanoidRootPart")
    if main then
        ghost.PrimaryPart = main
    end

    for _, item in pairs(ghost:GetDescendants()) do
        if item:IsA("BasePart") then
            item.Transparency = 0.5
            item.CanCollide = false
            item.Anchored = true
        elseif item:IsA("LocalScript") or item:IsA("Script") or item:IsA("TouchTransmitter") then
            item:Destroy()
        end
    end

    local glow = Instance.new("Highlight")
    glow.Name = "Glow"
    glow.FillTransparency = 1
    glow.OutlineColor = Color3.fromRGB(0, 255, 127)
    glow.OutlineTransparency = 0
    glow.Adornee = ghost
    glow.Parent = ghost

    ghost.Parent = workspace
end

local function make_cam_part()
    if cam_part then cam_part:Destroy() end
    cam_part = Instance.new("Part")
    cam_part.Name = "CamView"
    cam_part.Transparency = 1
    cam_part.CanCollide = false
    cam_part.Anchored = true
    cam_part.Size = Vector3.new(1, 1, 1)
    cam_part.Parent = workspace
end

run_service.Heartbeat:Connect(function()
    if active and root and static_pos and head then
        local real_pos = root.CFrame
        if cam_part then
            cam_part.CFrame = head.CFrame
        end
        root.CFrame = static_pos
        local speed = root.Velocity
        root.Velocity = Vector3.new(0, 0, 0)
        run_service.RenderStepped:Wait()
        if root and root.Parent then
            root.CFrame = real_pos
            root.Velocity = speed
        end
    end
end)

input_service.InputBegan:Connect(function(key, typing)
    if not typing and key.KeyCode == Enum.KeyCode.X then
        if not char or not root then return end
        active = not active
        if active then
            static_pos = root.CFrame
            make_ghost()
            make_cam_part()
            ghost:SetPrimaryPartCFrame(static_pos)
            cam.CameraSubject = cam_part
        else
            cam.CameraSubject = hum
            if ghost then ghost:Destroy() end
            if cam_part then cam_part:Destroy() end
        end
    end
end)

run_service.RenderStepped:Connect(function()
    if active and ghost and static_pos then
        ghost:SetPrimaryPartCFrame(static_pos)
    end
end)
