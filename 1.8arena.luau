
local Players=game:GetService("Players")
local ReplicatedStorage=game:GetService("ReplicatedStorage")
local UserInputService=game:GetService("UserInputService")
local RunService=game:GetService("RunService")
local Workspace=game:GetService("Workspace")

local LocalPlayer=Players.LocalPlayer
local Remotes=ReplicatedStorage:WaitForChild("Remotes")
local HitRequest=Remotes:WaitForChild("HitRequest")
local enabled=false
local conn=nil
local lastSwing=0
local RANGE=55

local function getOrigin()
	local char=LocalPlayer.Character
	if not char then return nil end
	local eyeLevel=char:FindFirstChild("PlayerEyeLevel")
	if eyeLevel and eyeLevel:IsA("BasePart") then
		return eyeLevel.Position
	end
	local hitbox=char:FindFirstChild("PlayerHitbox")
	if hitbox and hitbox:IsA("BasePart") then
		return hitbox.Position+Vector3.new(0,1.5,0)
	end
	return nil
end

local function getCameraDirection()
	local camera=Workspace.CurrentCamera
	if camera then
		return camera.CFrame.LookVector.Unit
	end
	return Vector3.new(0,0,-1)
end

local function valid(c)
	return c and c:FindFirstChild("Humanoid") and c.Humanoid.Health>0
end

local function nearest()
	local origin=getOrigin()
	if not origin then return nil,nil end
	local best,bestDist,bestPlayer=nil,RANGE,nil
	local otherChars=Workspace:FindFirstChild("OtherCharacters")
	if otherChars then
		for _,targetChar in ipairs(otherChars:GetChildren()) do
			if valid(targetChar) then
				local targetPart=targetChar:FindFirstChild("HumanoidRootPart")
				if not targetPart then
					for _,part in ipairs(targetChar:GetChildren()) do
						if part:IsA("BasePart") then
							targetPart=part
							break
						end
					end
				end
				if targetPart then
					local dist=(targetPart.Position-origin).Magnitude
					if dist<bestDist then
						best=targetChar
						bestDist=dist
						local playerName=targetChar.Name:gsub("_FakeCharacter","")
						bestPlayer=Players:FindFirstChild(playerName)
					end
				end
			end
		end
	end
	return best,bestPlayer
end

local function hit(t,targetPlayer)
	local origin=getOrigin()
	if not origin then return end
	local now=tick()
	if now-lastSwing<0.15 then return end
	local direction
	if t then
		local targetPart=t:FindFirstChild("HumanoidRootPart")
		if not targetPart then
			for _,part in ipairs(t:GetChildren()) do
				if part:IsA("BasePart") then
					targetPart=part
					break
				end
			end
		end
		if targetPart then
			direction=(targetPart.Position-origin).Unit
		else
			direction=getCameraDirection()
		end
	else
		direction=getCameraDirection()
	end
	pcall(function()
		HitRequest:FireServer(origin,direction,t,targetPlayer)
	end)
	lastSwing=now
end

local sg=Instance.new("ScreenGui",game.CoreGui)
sg.Name="killaura"
local f=Instance.new("Frame")
f.Size=UDim2.new(0,80,0,80)
f.Position=UDim2.new(0.85,0,0.7,0)
f.BackgroundColor3=Color3.fromRGB(40,40,40)
f.BorderSizePixel=0
f.Active=true
f.Draggable=true
f.Parent=sg

Instance.new("UICorner",f).CornerRadius=UDim.new(0,12)

local b=Instance.new("TextButton",f)
b.Size=UDim2.new(0.8,0,0.8,0)
b.Position=UDim2.new(0.1,0,0.1,0)
b.BackgroundColor3=Color3.fromRGB(60,60,60)
b.BorderSizePixel=0
b.Font=Enum.Font.GothamBold
b.Text="K"
b.TextColor3=Color3.fromRGB(255,255,255)
b.TextSize=28

Instance.new("UICorner",b).CornerRadius=UDim.new(0,8)
b.Activated:Connect(function()
	enabled=not enabled
	if enabled then
		conn=RunService.Heartbeat:Connect(function()
			if enabled then
				local t,tp=nearest()
				if t then
					hit(t,tp)
				end
			end
		end)
	else
		if conn then conn:Disconnect() conn=nil end
	end
	b.BackgroundColor3=enabled and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,60,60)
end)

UserInputService.InputBegan:Connect(function(i)
	if i.KeyCode==Enum.KeyCode.K then
		enabled=not enabled
		if enabled then
			conn=RunService.Heartbeat:Connect(function()
				if enabled then
					local t,tp=nearest()
					if t then
						hit(t,tp)
					end
				end
			end)
		else
			if conn then conn:Disconnect() conn=nil end
		end
		if b then
			b.BackgroundColor3=enabled and Color3.fromRGB(100,200,100) or Color3.fromRGB(200,60,60)
		end
	end
end)

b.BackgroundColor3=Color3.fromRGB(200,60,60)