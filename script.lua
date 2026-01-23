-- Detector
local placeId = 10449761463
if game.PlaceId ~= placeId then return end

-- Services
local uis = game:GetService("UserInputService")

-- Player Variables
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:FindFirstChild("Humanoid")
local Animator = Humanoid:WaitForChild("Animator")

-- Instances
local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "ZM V1.2"
ScreenGui.Enabled = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")
ScreenGui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
ScreenGui.ResetOnSpawn = false

function createMenu(name, sizeX)
	local Frame = Instance.new("Frame")
	local Name = Instance.new("TextLabel")
	local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
	local hider = Instance.new("TextButton")
	local mods = Instance.new("Folder")
	local holder = Instance.new("Frame")
	local UIGridLayout = Instance.new("UIGridLayout")
	local UIDragDetector = Instance.new("UIDragDetector")

	-- Properties
	Frame.Name = name
	Frame.Parent = ScreenGui
	Frame.AnchorPoint = Vector2.new(0.5, 0.5)
	Frame.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	Frame.BorderSizePixel = 0
	Frame.Position = UDim2.new(sizeX, 0, 0.5, 0)
	Frame.Size = UDim2.new(0.17, 0, 0.7, 0)

	Name.Parent = Frame
	Name.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	Name.BorderSizePixel = 0
	Name.Size = UDim2.new(1, 0, 0.1, 0)
	Name.Font = Enum.Font.Sarpanch
	Name.Text = name
	Name.TextColor3 = Color3.fromRGB(255, 255, 255)
	Name.TextScaled = true
	Name.TextWrapped = true
	UITextSizeConstraint.Parent = Name
	UITextSizeConstraint.MaxTextSize = 23

	hider.Name = "hider"
	hider.Parent = Frame
	hider.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
	hider.BackgroundTransparency = 1
	hider.Position = UDim2.new(0.79, 0, 0, 0)
	hider.Size = UDim2.new(0.21, 0, 0.1, 0)
	hider.ZIndex = 2
	hider.AutoButtonColor = false
	hider.Font = Enum.Font.Sarpanch
	hider.Text = "-"
	hider.TextColor3 = Color3.fromRGB(255, 255, 255)
	hider.TextSize = 23

	mods.Name = "mods"
	mods.Parent = Frame
	UIDragDetector.Parent = Frame

	holder.Name = "holder"
	holder.Parent = Frame
	holder.BackgroundTransparency = 1
	holder.Position = UDim2.new(0, 0, 0.1, 0)
	holder.Size = UDim2.new(1, 0, 0.9, 0)

	UIGridLayout.Parent = holder
	UIGridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	UIGridLayout.CellPadding = UDim2.new(0, 5, 0, 0)
	UIGridLayout.CellSize = UDim2.new(1, 0, 0.07, 0)

	-- Hider Func

	hider.MouseButton1Down:Connect(function()
		local transparent = Frame.BackgroundTransparency == 0
		Frame.BackgroundTransparency = transparent and 1 or 0
		UIDragDetector.Enabled = not transparent

		for _, tbs in pairs(holder:GetChildren()) do
			if tbs:IsA("TextButton") then
				tbs.Visible = not transparent
			end
		end
	end)
end

-- VARIABLES
local cam = workspace.CurrentCamera
local Live = workspace:WaitForChild("Live")

local sounds = {}

local kjTrack

local kjAnim = Instance.new("Animation")
kjAnim.AnimationId = "rbxassetid://77727115892579"

local cVConns = {}
-- FUNCTIONS

local function createSounds()
	for _, s in pairs(sounds) do
		if s then
			s:Destroy()
		end
	end

	sounds = {}

	local kjphysic = Instance.new("Sound")
	kjphysic.SoundId = "rbxassetid://99126314241685"
	kjphysic.Volume = 2.5
	kjphysic.Parent = workspace

	local kjvoice = Instance.new("Sound")
	kjvoice.SoundId = "rbxassetid://128136381213631"
	kjvoice.Volume = 2.5
	kjvoice.Parent = workspace

	local kjmusic = Instance.new("Sound")
	kjmusic.SoundId = "rbxassetid://95410275491981"
	kjmusic.Volume = 2.5
	kjmusic.Parent = workspace

	table.insert(sounds, kjphysic)
	table.insert(sounds, kjvoice)
	table.insert(sounds, kjmusic)
end

local function kjSetup(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Animator = Humanoid:WaitForChild("Animator")

	kjTrack = Animator:LoadAnimation(kjAnim)

	createSounds()
end

local function createDCImage(chr)
	local BillboardGui = Instance.new("BillboardGui")
	local ImageLabel = Instance.new("ImageLabel")

	--Properties:
	BillboardGui.Name = "CounterV"
	BillboardGui.Parent = chr.Head
	BillboardGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	BillboardGui.Active = true
	BillboardGui.LightInfluence = 1
	BillboardGui.Size = UDim2.new(3, 0, 3, 0)
	BillboardGui.StudsOffset = Vector3.new(0, 4, 0)

	ImageLabel.Parent = BillboardGui
	ImageLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	ImageLabel.BackgroundTransparency = 1
	ImageLabel.BorderColor3 = Color3.fromRGB(0, 0, 0)
	ImageLabel.BorderSizePixel = 0
	ImageLabel.Size = UDim2.new(1, 0, 1, 0)
	ImageLabel.Image = "rbxassetid://137607954274376"
end

local function cVReconnector(chr)
	chr.ChildAdded:Connect(function(c)
		if c.Name == "Counter" and c:IsA("Accessory") then
			createDCImage(chr)
		end
	end)

	chr.ChildRemoved:Connect(function(c)
		if c.Name == "Counter" and c:IsA("Accessory") then
			chr.Head:FindFirstChild("CounterV"):Destroy()
		end
	end)
end

local cloneCamConnection
local function cloneCam()
	local newCam = Instance.new("Camera")
	newCam.CameraSubject = Humanoid
	newCam.CameraType = Enum.CameraType.Custom
	newCam.Parent = workspace

	cam = newCam

	cloneCamConnection = newCam:GetPropertyChangedSignal("CameraType"):Connect(function()
		newCam:Destroy()
		cloneCam()
	end)
end

-- Toggle With T Key
uis.InputBegan:Connect(function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.T then
		ScreenGui.Enabled = not ScreenGui.Enabled
	end
end)

-- MAIN
createMenu("Combat", .1)
createMenu("Player", .3)
createMenu("Visuals", .5)
createMenu("Miscellaneous", .7)

local function createModButton(name, category, toggle, code)
	local btn = Instance.new("TextButton")

	for _, cat in pairs(ScreenGui:GetDescendants()) do
		if cat.Name == category then
			btn.Parent = cat:FindFirstChild("holder")
		end
	end

	btn.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
	btn.BorderSizePixel = 0
	btn.Font = Enum.Font.Sarpanch
	btn.Text = name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.AutoButtonColor = false
	btn:SetAttribute("activated", false)

	btn.MouseButton1Down:Connect(function()
		if toggle then
			if btn:GetAttribute("activated") then
				btn:SetAttribute("activated", false) -- disabled
				btn.BackgroundColor3 = Color3.fromRGB(44, 44, 44)
				code(false)
			else
				btn:SetAttribute("activated", true) -- enabled
				btn.BackgroundColor3 = Color3.fromRGB(0, 163, 166)
				code(true)
			end
		else
			if btn.BackgroundColor3 == Color3.fromRGB(127, 0, 0) then return end
			btn.BackgroundColor3 = Color3.fromRGB(127, 0, 0)

			code()
		end
	end)
end

-- M1 Reset
local m1Connection
createModButton("M1 Reset", "Combat", true, function(isEnabled)
	if isEnabled then
		m1Connection = uis.InputBegan:Connect(function(i, p)
			if p then return end

			if i.KeyCode == Enum.KeyCode.R then
				if Character and Character:FindFirstChild("HumanoidRootPart") then
					local root = Character.HumanoidRootPart
					local look = root.CFrame.LookVector
					root.CFrame = root.CFrame + (-look * 26)
				end
			end
		end)
	elseif m1Connection then
		m1Connection:Disconnect()
		m1Connection = nil
	end
end)

-- Force AutoRotate
local forceAutoRotateConnection
createModButton("Force AutoRotate", "Player", true, function(isEnabled)
	if isEnabled then
		forceAutoRotateConnection = Humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
			if not Character:FindFirstChild("Ragdoll") then
				Humanoid.AutoRotate = true
			end
		end)
	elseif forceAutoRotateConnection then
		forceAutoRotateConnection:Disconnect()
		forceAutoRotateConnection = nil
	end
end)

-- No Cutscene
local noCutsceneConnection
createModButton("No Cutscene", "Miscellaneous", true, function(isEnabled)
	if isEnabled then
		noCutsceneConnection = cam:GetPropertyChangedSignal("CameraType"):Connect(function()
			cam:Destroy()
			cloneCam()
		end)
	elseif noCutsceneConnection then
		noCutsceneConnection:Disconnect()
		noCutsceneConnection = nil
	end
end)

-- Counter Visualizer

createModButton("Counter Visualizer", "Visuals", true, function(isEnabled)
	if isEnabled then
		for _, v in pairs(Live:GetChildren()) do		
			if game.Players:GetPlayerFromCharacter(v) then		
				local plr = game.Players:GetPlayerFromCharacter(v)

				if v:FindFirstChild("Counter") then
					createDCImage(v)
				end

				cVConns[#cVConns+1] = plr.CharacterAdded:Connect(function(chr)
					cVReconnector(chr)
				end)

				cVConns[#cVConns+1] = v.ChildAdded:Connect(function(c)
					if c.Name == "Counter" and c:IsA("Accessory") then
						createDCImage(v)
					end
				end)

				cVConns[#cVConns+1] = v.ChildRemoved:Connect(function(c)
					if c.Name == "Counter" and c:IsA("Accessory") then
						v.Head:FindFirstChild("CounterV"):Destroy()
					end
				end)
			end
		end
	else
		for _, conn in pairs(cVConns) do
			if conn then
				conn:Disconnect()
			end
		end
		
		cVConns = {}
	end
end)

-- KJ Flexworks Anim
createModButton("KJ Flexworks Anim", "Miscellaneous", false, function()
	kjSetup(Character)

	uis.InputBegan:Connect(function(input, processed)
		if processed then return end

		-- Stop KJ'S Anim
		if input.KeyCode == Enum.KeyCode.F then
			if kjTrack and kjTrack.IsPlaying then
				kjTrack:Stop()
			end

			for _, s in pairs(sounds) do
				if s.IsPlaying then
					s:Stop()
				end
			end
		end

		-- Start
		if input.KeyCode == Enum.KeyCode.Z then
			if kjTrack.IsPlaying then
				kjTrack:Stop()
				task.wait(0.05)
			end
			kjTrack:Play()

			for _, s in pairs(sounds) do
				if s.IsPlaying then
					s:Stop()
					task.wait(0.05)
				end
				s:Play()
			end
		end
	end)
end)

Player.CharacterAdded:Connect(function(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")

	-- Reloads the previous ' ON ' options
	if forceAutoRotateConnection then -- it means it is on
		forceAutoRotateConnection = Humanoid:GetPropertyChangedSignal("AutoRotate"):Connect(function()
			if not char:FindFirstChild("Ragdoll") then
				Humanoid.AutoRotate = true
			end
		end)
	end

	kjSetup(char)
end)
