--// SERVICES \\--
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local VirtualUser = game:GetService("VirtualUser")

--// PLAYER \\--
local Player = game.Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local HumanoidRootPart = Character:FindFirstChild("HumanoidRootPart")
local Humanoid : Humanoid = Character:FindFirstChild("Humanoid")

local PlayerGui = Player.PlayerGui
local Backpack = Player.Backpack

--// VARIABLES \\--
local Remotes = ReplicatedStorage:FindFirstChild("Remotes")
local CommF_ : RemoteFunction = Remotes:FindFirstChild("CommF_")

local Modules = ReplicatedStorage:FindFirstChild("Modules")

local NPCs = workspace:FindFirstChild("NPCs")
local Enemies = workspace:FindFirstChild("Enemies")

local Level = Player.Data.Level
local Money = Player.Data.Beli

local MainGui = PlayerGui.Main
local QuestGui : Frame = MainGui.Quest

local ActiveQuest = QuestGui.Visible

local Net = Modules:FindFirstChild("Net")
local RegisterAttack = Net["RE/RegisterAttack"]
local RegisterHit = Net["RE/RegisterHit"]

local PRIORITY = ""
local Tween : Tween = nil
local TWEEN_SPEED = 265

local function AddConnection(conn, tbl)
	if conn then
		table.insert(tbl, conn)
	end

	return conn
end

local function ClearConnections(tbl)
	for _, conn in ipairs(tbl) do
		pcall(function()
			conn:Disconnect()
		end)
	end
	table.clear(tbl)
end

local RADIUS = 50
local STUDS_ABOVE_NPCS = 15 -- MAX 70
local AUTO_FARM_LEVEL = true
local AUTO_BUSO = true

local PULL_DIST = 500
local LEVEL_CAP = 2800

local function EquipTool(nameOrType)
	for _, tool in Backpack:GetChildren() do
		if tool.Name == nameOrType then
			Humanoid:EquipTool(tool)
			return true
		end
	end

	for _, tool in Backpack:GetChildren() do
		if tool:GetAttribute("WeaponType") == nameOrType then
			Humanoid:EquipTool(tool)
			return true
		end
	end

	return false
end

-- When a specified NPC is dead (in most of the cases, a boss)
local function OnNPCDied(name, code)
	local npc = Enemies:FindFirstChild(name)
	if npc then
		local hum : Humanoid = npc:FindFirstChild("Humanoid")

		local tempConn

		tempConn = hum.Died:Connect(function()
			if code then
				code()
			else
				print("NPC: " .. name .. " died.")
			end

			if tempConn then
				tempConn:Disconnect()
				tempConn = nil
			end
		end)
	end
end

local function Freeze()
	if not HumanoidRootPart:FindFirstChild("BodyVelocity") then
		local bv = Instance.new("BodyVelocity")
		bv.Name = "BodyYeppo"
		bv.Parent = HumanoidRootPart
		bv.MaxForce = Vector3.new(10000, 10000, 10000)
		bv.Velocity = Vector3.new(0, 0, 0)
	end

	for _, v in Character:GetDescendants() do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
end

local function Unfreeze()
	if HumanoidRootPart:FindFirstChild("BodyVelocity") then
		HumanoidRootPart.BodyVelocity:Destroy()
	end
end

local function GetEnemiesInRange()	
	local OthersEnemies = {}
	local BasePart = nil
	local pos = HumanoidRootPart.Position

	for _, Enemy in Enemies:GetChildren() do				
		local Head = Enemy:FindFirstChild("Head")
		local hrp = Enemy:FindFirstChild("HumanoidRootPart")
		local hum = Enemy:FindFirstChild("Humanoid")

		if Head and hrp and hum and hum.Health > 0 then
			if (hrp.Position - pos).Magnitude <= RADIUS then
				table.insert(OthersEnemies, { Enemy, Head })
				if not BasePart then
					BasePart = Head
				end

				Enemy.Humanoid.JumpPower = 0
				Enemy.Humanoid.WalkSpeed = 0
				Enemy.HumanoidRootPart.CanCollide = false
				Enemy.Humanoid:ChangeState(11)
				Enemy.Humanoid:ChangeState(14)
			end
		end
	end

	return BasePart, OthersEnemies
end

local function CurrentWorld()
	local World1 = false
	local World2 = false
	local World3 = false

	local id = game.PlaceId
	if id == 2753915549 then 
		World1 = true
	elseif id == 4442272183 then 
		World2 = true
	elseif id == 7449423635 then 
		World3 = true
	end

	if World1 == nil and World2 == nil and World3 == nil then
		warn("WORLD NOT IDENTIFIED. PLEASE OWNER, UPDATE THIS.")
		return
	end

	return World1 and 1 or World2 and 2 or World3 and 3
end

local _AttackNearEnemies = false

local function AttackNearEnemies(enabled)
	task.spawn(function()
		_AttackNearEnemies = true

		if _AttackNearEnemies then
			while _AttackNearEnemies do
				task.wait(0.05)

				pcall(function()
					local BasePart, OthersEnemies = GetEnemiesInRange()

					if BasePart and #OthersEnemies > 0 then
						RegisterAttack:FireServer(0)
						RegisterHit:FireServer(BasePart, OthersEnemies)
					end
				end)	
			end
		end
	end)
end

function magnitude(x, y) -- must be cframe or vector3 (recommended: vector3)
	local v1 = x
	local v2 = y
	
	-- if cframe, then it becomes a vector3
	if typeof(x) == "CFrame" then
		v1 = x.Position
	end
	
	if typeof(y) == "CFrame" then
		v2 = y.Position
	end
	
	return (v1 - v2).Magnitude
end

-- Tween thingo
function TweenPosTo(target, onCompleted)
	local usedSubTarget = false

	if typeof(target) ~= "Instance" then
		local substituteTarget = Instance.new("Part")
		substituteTarget.Anchored = true
		substituteTarget.CanCollide = false
		substituteTarget.Transparency = 1
		substituteTarget.CastShadow = false
		substituteTarget.CFrame = target

		target = substituteTarget

		usedSubTarget = true
	end

	if not target then
		warn("An error has ocurred while the code execution. Check TweenPosTo function.")
	end

	local Distance = (target.Position - HumanoidRootPart.Position).Magnitude
	local Speed = 265

	local info = TweenInfo.new(
		Distance / Speed,
		Enum.EasingStyle.Linear
	)

	Tween = TweenService:Create(
		HumanoidRootPart,
		info,
		{CFrame = target.CFrame}
	)

	Tween:Play()

	local tempConn = nil

	tempConn = Tween.Completed:Connect(function()				
		if usedSubTarget then 
			pcall(function()
				target:Destroy()
			end)
		end

		if onCompleted then
			pcall(function()
				onCompleted()
			end)
		end

		if tempConn then
			tempConn:Disconnect()
			tempConn = nil
		end
	end)

end

function CancelTween()
	if Tween then
		if Tween.PlaybackState == Enum.PlaybackState.Playing then
			Tween:Pause()
			Tween = nil
		end
	end
end

-- Simple TP
function TPTo(cframe)
	HumanoidRootPart.CFrame = cframe
end

local StartMagnet = false
local MonFarm = ""
local PosMon = CFrame.new(0, 0, 0)

local function PullNPCs(controllerVariable, specifiedNPC)
	spawn(function()
		while controllerVariable do
			task.wait()

			pcall(function()
				if StartMagnet then
					local targetName = specifiedNPC or MonFarm

					if targetName == nil then return end

					for _, v in pairs(Enemies:GetChildren()) do
						if v.Name == targetName and v:FindFirstChild("Humanoid") and v.Humanoid.Health > 0 then
							if (v.HumanoidRootPart.Position - PosMon.Position).Magnitude <= PULL_DIST then
								v.Humanoid.JumpPower = 0
								v.Humanoid.WalkSpeed = 0
								v.Humanoid:ChangeState(11)
								v.Humanoid:ChangeState(14)
								v.Head.CanCollide = false
								v.HumanoidRootPart.CanCollide = false
								-- v.HumanoidRootPart.Size = Vector3.new(60, 60, 60)
								v.HumanoidRootPart.CFrame = PosMon
								sethiddenproperty(Player, "SimulationRadius", math.huge)
							end
						end
					end
				end
			end)
		end
	end)
end

function timeTravelled(from, to, speed)
	
	if typeof(from) == "CFrame" then
		from = from.Position
	end
	
	if typeof(to) == "CFrame" then
		to = to.Position
	end
	
	return (from - to).Magnitude / speed
end

-- requestEntrance CFrames
local Vector3Entrances = {
	-- SEA 1
	{
		-- Fishman Island
		Vector3.new(61163.8515625, 11.6796875, 1819.7841796875),

		-- Outside Fishman Island
		Vector3.new(3864.8515625, 6.6796875, -1926.7841796875),

		-- Lower Skylands (but not the floor)
		Vector3.new(-4607.8227539063, 872.54248046875, -1667.5568847656),

		-- Upper Skylands
		Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047)
	},
	
	
}

local _Noclip = false
local FuncsUsingNoclip = 0

local function Noclip(option)
	if option then
		FuncsUsingNoclip += 1

		if FuncsUsingNoclip ~= 1 then return end -- prevent from multiples 'whiles' being created :v

		task.spawn(function()
			while _Noclip do
				task.wait()

				if Player.Character then
					Player.Character.LowerTorso.CanCollide = true
					Player.Character.UpperTorso.CanCollide = true
				end	
			end
		end)
	else
		FuncsUsingNoclip -= 1

		if FuncsUsingNoclip == 0 then
			_Noclip = false

			if Player.Character then
				Player.Character.LowerTorso.CanCollide = false
				Player.Character.UpperTorso.CanCollide = false
			end
		end
	end
end

-- Verifies if player have styles bought
-- 0 = non bought
-- 1 = bought
local function HasStyleBought(boughtParam)
	if not boughtParam then
		return nil
	end

	local hasBought = tonumber(CommF_:InvokeServer(boughtParam, true))

	return hasBought == 1
end

local _AutoElectric = false
local HasElectric = false

local function AutoElectric(enabled)
	if enabled then
		_AutoElectric = true

		Noclip(true)

		while _AutoElectric do
			task.wait()

			if HasElectric then continue end

			if PRIORITY ~= "" and PRIORITY ~= "AutoElectric" then continue end

			if Money.Value < 500000 then continue end

			PRIORITY = "AutoElectric"

			TweenPosTo(CFrame.new(-5411, 10, -2138))

			repeat
				CommF_:InvokeServer("BuyElectro")

				task.wait(.1)

				HasElectric = HasStyleBought("BuyElectro")
			until HasElectric == true

			CommF_:InvokeServer("AbandonQuest")
			PRIORITY = ""

			Noclip(false)
		end
	else
		_AutoElectric = false
		Noclip(false)

		if PRIORITY == "AutoElectric" then
			PRIORITY = ""
			CancelTween()
		end
	end
end

local _AutoDarkStep = false
local HasDarkStep = false

local function AutoDarkStep(enabled)
	if enabled then
		Noclip(true)
		_AutoDarkStep = true

		while _AutoDarkStep do
			task.wait()

			if HasDarkStep then continue end

			if PRIORITY ~= "" and PRIORITY ~= "AutoDarkStep" then continue end

			if Money.Value < 150000 then continue end

			PRIORITY = "AutoDarkStep"

			TweenPosTo(CFrame.new(-987, 14, 3987))

			repeat
				CommF_:InvokeServer("BuyBlackLeg")

				task.wait(.1)

				HasDarkStep = HasStyleBought("BuyBlackLeg")
			until HasDarkStep == true

			CommF_:InvokeServer("AbandonQuest")
			PRIORITY = ""
		end
	else
		Noclip(false)
		_AutoDarkStep = false

		if PRIORITY == "AutoDarkStep" then
			PRIORITY = ""
			CancelTween()
		end
	end
end

task.spawn(function()
	HasDarkStep = HasStyleBought("BuyBlackLeg")
	HasElectric = HasStyleBought("BuyElectro")
end)

local _AutoNextSea = false

local function AutoNextSea(enabled)
	if enabled then
		Noclip(true)
		_AutoNextSea = true

		if not Character:FindFirstChild("HasBuso") then
			CommF_:InvokeServer("Buso")
		end

		while _AutoNextSea do
			task.wait()

			if PRIORITY ~= "" and PRIORITY ~= "NextSea" then continue end

			if Level.Value == nil then continue end

			if CurrentWorld() == 1 then
				if Level.Value >= 700 then
					local Door : Part = workspace.Map.Ice.Door
					if not Door then continue end

					PRIORITY = "NextSea"

					if Door.CanCollide == true and Door.Transparency == 0 then
						CommF_:InvokeServer("DressrosaQuestProgress", "Detective")

						EquipTool("Key")

						CommF_:InvokeServer("AbandonQuest")

						-- goes to the target [...]
						TweenPosTo(CFrame.new(1347.7124, 37.3751602, -1325.6488))

					elseif Door.CanCollide == false and Door.Transparency == 1 then						
						local AdmiralHead = nil

						if not Enemies:FindFirstChild("Ice Admiral") then -- so the player opened the door but died (or opened it and left the game)
							TweenPosTo(CFrame.new(1347.7124, 37.3751602, -1325.6488))
						end

						repeat AdmiralHead = Enemies:FindFirstChild("Ice Admiral")
							task.wait(.1)
						until AdmiralHead ~= nil

						AdmiralHead = AdmiralHead.Head

						if AdmiralHead then
							local function TweenFinished()
								AttackNearEnemies(true)
								Freeze()
								EquipTool("Melee")
							end

							CancelTween()
							TweenPosTo(AdmiralHead.CFrame * CFrame.new(0, STUDS_ABOVE_NPCS, 0), TweenFinished)

							local function NPCDied()
								AttackNearEnemies(false)
								PRIORITY = ""
								task.wait(2)
								CommF_:InvokeServer("TravelDressrosa")
							end

							OnNPCDied("Ice Admiral", NPCDied)
						end
					end
				end
			end
		end
	else
		Noclip(false)
		_AutoNextSea = false

		if PRIORITY == "NextSea" then
			Unfreeze()
			PRIORITY = ""
			CancelTween()
		end
	end
end

local _AutoStoreFruits = false

local function AutoStoreFruits(enabled)
	if enabled then
		_AutoStoreFruits = true

		local FruitName = nil
		local NameOnly = nil

		while _AutoStoreFruits do
			for _, v in Backpack:GetChildren() do
				if string.find(v.Name, "Fruit") then
					FruitName = v.Name
					NameOnly = string.gsub(v.Name, " Fruit", "")

					if Backpack:FindFirstChild(FruitName) or Character:FindFirstChild(FruitName) then
						local args = {
							[1] = "StoreFruit",
							[2] = NameOnly .. "-" .. NameOnly,
							[3] = Backpack:FindFirstChild(FruitName)
						}

						CommF_:InvokeServer(unpack(args))
					end
				end
			end

			task.wait(1)
		end
	else
		_AutoStoreFruits = false
	end
end

local _AutoBuyRandomFruits = false

local function AutoBuyRandomFruits(enabled)
	if enabled then
		_AutoBuyRandomFruits = true

		while _AutoBuyRandomFruits do
			local args = {
				"Cousin",
				"DLCBoxData"
			}

			CommF_:InvokeServer(unpack(args))

			task.wait(1)
		end
	else
		_AutoBuyRandomFruits = false
	end
end

local SelectedStat = "Melee"
local PointsPerAdd = 10
local _AutoStats = false

local function AutoStats(enabled)
	if enabled then
		AutoStats = true

		while AutoStats do
			local args = {
				[1] = "AddPoint",
				[2] = SelectedStat,
				[3] = PointsPerAdd
			}

			CommF_:InvokeServer(unpack(args))

			task.wait()
		end
	else
		AutoStats = false
	end
end

local LevelFarmConnections = {}
local LevelFarm = false

local function AutoLevelFarm(enabled)
	local Data = nil

	local bindEvent = Instance.new("BindableEvent")

	local globalconns = {}

	local sky1Entrance = workspace.Map.SkyArea1.PathwayTemple.Entrance

	local function OnDisabled()
		LevelFarm = false

		Noclip(false)
		CancelTween()

		sky1Entrance.CanTouch = true

		-- removes the freeze in air effect
		if HumanoidRootPart:FindFirstChild("BodyYeppo") then
			HumanoidRootPart.BodyYeppo:Destroy()
		end

		ClearConnections(LevelFarmConnections)

		PRIORITY = ""
		StartMagnet = false
	end

	if enabled then
		Noclip(true)

		task.wait()

		sethiddenproperty(Player, "SimulationRadius", math.huge)

		LevelFarm = true
		sky1Entrance.CanTouch = false

		task.spawn(function()
			while LevelFarm do
				if not LevelFarm then
					if LevelFarm == false then
						OnDisabled()
					end
				end

				task.wait()
			end
		end)

		local function listenBindEvent(_string, code)
			local tempConn = nil

			tempConn = bindEvent.Event:Connect(function(param)
				if _string == param then
					if code then
						code()
					else
						print("bindable event reached a signal.")
					end
				end

				if tempConn then
					tempConn:Disconnect()
					tempConn = nil
				end
			end)
		end

		AddConnection(QuestGui:GetPropertyChangedSignal("Visible"):Connect(function()
			ActiveQuest = QuestGui.Visible
			bindEvent:Fire("Quest")
		end), LevelFarmConnections)


		task.spawn(function()
			while LevelFarm do
				task.wait(0.05)

				pcall(function()
					local BasePart, OthersEnemies = GetEnemiesInRange()

					if BasePart and #OthersEnemies > 0 then
						RegisterAttack:FireServer(0)
						RegisterHit:FireServer(BasePart, OthersEnemies)
					end
				end)	
			end
		end)
		CommF_:InvokeServer("AbandonQuest") -- first of all, abandons the quest cuz its a lil buggy with it ON

		export type QuestType = {
			Min: number,
			Max: number,
			QuestName: string,
			NPCName: string,
			QuestId: number,
			QuestArea: CFrame,
			SpecialFunc: () -> ()
		}

		local QuestData : {QuestType} = {}

		local function GetQuestData()
			for _, Data in ipairs(QuestData) do
				local Min, Max = Data.Min, Data.Max

				if Level.Value >= Min and Level.Value <= Max then
					return Data
				end
			end

			return nil
		end

		local function Configure(Min, Max, QuestName, NPCName, QuestId, QuestArea, SpecialFunc)
			table.insert(QuestData, {
				Min = Min,
				Max = Max,
				QuestName = QuestName,
				NPCName = NPCName,
				QuestId = QuestId,
				QuestArea = QuestArea,
				SpecialFunc = SpecialFunc
			})
		end

		local function OnQuest()
			return QuestGui.Visible and true or false
		end

		local function DoQuest()
			if not Data then
				Data = GetQuestData()
			end

			local function TweenFinished()
				local Pos = Data.QuestArea * CFrame.new(0, STUDS_ABOVE_NPCS, 0)

				MonFarm = Data.NPCName
				PosMon = Pos * CFrame.new(0, -STUDS_ABOVE_NPCS, 0)
				StartMagnet = true

				local function QuestFinished()			
					PRIORITY = ""

					if OnQuest() then return end

					StartMagnet = false
				end

				listenBindEvent("Quest", QuestFinished)
			end

			listenBindEvent("Quest", TweenFinished)

			CommF_:InvokeServer("StartQuest", Data.QuestName, Data.QuestId) -- FIRSTLY starts the quest
		end

		Configure(1, 9, "BanditQuest1", "Bandit", 1, CFrame.new(1190.14, 16.77, 1611.25))
		Configure(10, 14, "JungleQuest", "Monkey", 1, CFrame.new(-1496, 39, 35))
		Configure(15, 29, "JungleQuest", "Gorilla", 2, CFrame.new(-1237, 6, -486))
		Configure(30, 39, "BuggyQuest1", "Pirate", 1, CFrame.new(-1115, 14, 3938))
		Configure(40, 59, "BuggyQuest1", "Brute", 2, CFrame.new(-1145, 15, 4350))
		Configure(60, 74, "DesertQuest", "Desert Bandit", 1, CFrame.new(932, 7, 4484))
		Configure(75, 89, "DesertQuest", "Desert Officer", 2, CFrame.new(1572, 10, 4373))
		Configure(90, 99, "SnowQuest", "Snow Bandit", 1, CFrame.new(1289, 106, -1442))
		Configure(100, 119, "SnowQuest", "Snowman", 2, CFrame.new(1289, 106, -1442))
		Configure(120, 149, "MarineQuest2", "Chief Petty Officer", 1, CFrame.new(-4855, 23, 4308))

		Configure(150, 174, "SkyQuest", "Sky Bandit", 1, CFrame.new(-4981, 278, -2830), function()
			PRIORITY = "UsingTP"
			CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.8227539063, 872.54248046875, -1667.5568847656))
			PRIORITY = ""
		end)

		Configure(175, 189, "SkyQuest", "Dark Master", 2, CFrame.new(-5250, 389, -2272), function()
			PRIORITY = "UsingTP"
			CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.8227539063, 872.54248046875, -1667.5568847656))
			PRIORITY = ""
		end)

		Configure(190, 209, "PrisonerQuest", "Prisoner", 1, CFrame.new(5411, 96, 690))
		Configure(210, 249, "PrisonerQuest", "Dangerous Prisoner", 2, CFrame.new(5411, 96, 690))
		Configure(250, 299, "ColosseumQuest", "Toga Warrior", 1, CFrame.new(-1824, 50, -2743))
		Configure(300, 329, "MagmaQuest", "Military Soldier", 1, CFrame.new(-5408, 11, 8447))
		Configure(330, 374, "MagmaQuest", "Military Spy", 2, CFrame.new(-5815, 84, 8820))

		Configure(375, 399, "FishmanQuest", "Fishman Warrior", 1, CFrame.new(60859, 19, 1501), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
		end)

		Configure(400, 449, "FishmanQuest", "Fishman Commando", 2, CFrame.new(61891, 19, 1470), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(61163.8515625, 11.6796875, 1819.7841796875))
		end)

		Configure(450, 474, "SkyExp1Quest", "God's Guard", 1, CFrame.new(-4698, 845, -1912), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(-4607.8227539063, 872.54248046875, -1667.5568847656))
		end)

		Configure(475, 524, "SkyExp1Quest", "Shanda", 2, CFrame.new(-7685, 5567, -502), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
		end)

		Configure(525, 549, "SkyExp2Quest", "Royal Squad", 1, CFrame.new(-7670, 5607, -1460), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
		end)

		Configure(550, 624, "SkyExp2Quest", "Royal Soldier", 2, CFrame.new(-7828, 5607, -1744), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(-7894.6176757813, 5547.1416015625, -380.29119873047))
		end)

		Configure(625, 649, "FountainQuest", "Galley Pirate", 1, CFrame.new(5589, 45, 3996), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(3864.8515625, 6.6796875, -1926.7841796875))
		end)

		Configure(650, 700, "FountainQuest", "Galley Captain", 2, CFrame.new(5649, 39, 4936), function()
			CommF_:InvokeServer("requestEntrance", Vector3.new(3864.8515625, 6.6796875, -1926.7841796875))
		end)

		-- SEA 2
		Configure(700, 724, "Area1Quest", "Raider", 1, CFrame.new(-746, 39, 2390))
		Configure(725, 774, "Area1Quest", "Mercenary", 2, CFrame.new(-874, 141, 1312))
		Configure(775, 799, "Area2Quest", "Swan Pirate", 1, CFrame.new(878, 122, 1235))
		Configure(800, 874, "Area2Quest", "Factory Staff", 2, CFrame.new(295, 73, -56))
		Configure(875, 899, "MarineQuest3", "Marine Lieutenant", 1, CFrame.new(-2806, 73, -3038))
		Configure(900, 949, "MarineQuest3", "Marine Captain", 2, CFrame.new(-1869, 73, -3320))
		Configure(950, 974, "ZombieQuest", "Zombie", 1, CFrame.new(-5736, 126, -728))
		Configure(975, 999, "ZombieQuest", "Vampire", 2, CFrame.new(-6033, 7, -1317))
		Configure(1000, 1049, "SnowMountainQuest", "Snow Trooper", 1, CFrame.new(478, 402, -5362))
		Configure(1050, 1099, "SnowMountainQuest", "Winter Warrior", 2, CFrame.new(1157, 430, -5188))
		Configure(1100, 1124, "IceSideQuest", "Lab Subordinate", 1, CFrame.new(-5782, 42, -4484))
		Configure(1125, 1174, "IceSideQuest", "Horned Warrior", 2, CFrame.new(-6406, 24, -5805))
		Configure(1175, 1199, "FireSideQuest", "Magma Ninja", 1, CFrame.new(-5428, 78, -5959))
		Configure(1200, 1249, "FireSideQuest", "Lava Pirate", 2, CFrame.new(-5270, 42, -4800))
		Configure(1250, 1274, "ShipQuest1", "Ship Deckhand", 1, CFrame.new(1198, 126, 33031))
		Configure(1275, 1299, "ShipQuest1", "Ship Engineer", 2, CFrame.new(918, 44, 32787))
		Configure(1300, 1324, "ShipQuest2", "Ship Steward", 1, CFrame.new(915, 130, 33419))
		Configure(1325, 1349, "ShipQuest2", "Ship Officer", 2, CFrame.new(916, 181, 33335))
		Configure(1350, 1374, "FrostQuest", "Arctic Warrior", 1, CFrame.new(6038, 29, -6231))
		Configure(1375, 1424, "FrostQuest", "Snow Lurker", 2, CFrame.new(5560, 42, -6826))
		Configure(1425, 1449, "ForgottenQuest", "Sea Soldier", 1, CFrame.new(-3022, 16, -9722))
		Configure(1450, 1500, "ForgottenQuest", "Water Fighter", 2, CFrame.new(-3385, 239, -10542))

		-- SEA 3
		Configure(1500, 1524, "PiratePortQuest", "Pirate Millionaire", 1, CFrame.new(-373, 75, 5550))
		Configure(1525, 1574, "PiratePortQuest", "Pistol Billionaire", 2, CFrame.new(-469, 74, 5904))
		Configure(1575, 1599, "DragonCrewQuest", "Dragon Crew Warrior", 1, CFrame.new(6338, 52, -1213))
		Configure(1600, 1624, "DragonCrewQuest", "Dragon Crew Archer", 2, CFrame.new(6594, 383, 139))
		Configure(1625, 1649, "VenomCrewQuest", "Hydra Enforcer", 1, CFrame.new(5308, 819, 1047))
		Configure(1650, 1699, "VenomCrewQuest", "Venomous Assailant", 2, CFrame.new(4951, 602, -68))
		Configure(1700, 1724, "MarineTreeIsland", "Marine Commodore", 1, CFrame.new(2447, 73, -7470))
		Configure(1725, 1774, "MarineTreeIsland", "Marine Rear Admiral", 2, CFrame.new(3671, 161, -6932))
		Configure(1775, 1799, "DeepForestIsland3", "Fishman Raider", 1, CFrame.new(-10560, 332, -8466))
		Configure(1800, 1824, "DeepForestIsland3", "Fishman Captain", 2, CFrame.new(-10993, 332, -8940))
		Configure(1825, 1849, "DeepForestIsland", "Forest Pirate", 1, CFrame.new(-13479, 333, -7905))
		Configure(1850, 1899, "DeepForestIsland", "Mythological Pirate", 2, CFrame.new(-13545, 470, -6917))
		Configure(1900, 1924, "DeepForestIsland2", "Jungle Pirate", 1, CFrame.new(-12106, 332, -10549))
		Configure(1925, 1974, "DeepForestIsland2", "Musketeer Pirate", 2, CFrame.new(-13286, 392, -9768))
		Configure(1975, 1999, "HauntedQuest1", "Reborn Skeleton", 1, CFrame.new(-8760, 142, 6039))
		Configure(2000, 2024, "HauntedQuest1", "Living Zombie", 2, CFrame.new(-10144, 140, 5932))
		Configure(2025, 2049, "HauntedQuest2", "Demonic Soul", 1, CFrame.new(-9506, 172, 6158))
		Configure(2050, 2074, "HauntedQuest2", "Posessed Mummy", 2, CFrame.new(-9577, 6, 6223))
		Configure(2075, 2099, "NutsIslandQuest", "Peanut Scout", 1, CFrame.new(-2124, 123, -10435))
		Configure(2100, 2124, "NutsIslandQuest", "Peanut President", 2, CFrame.new(-2124, 123, -10435))
		Configure(2125, 2149, "IceCreamIslandQuest", "Ice Cream Chef", 1, CFrame.new(-641, 127, -11062))
		Configure(2150, 2199, "IceCreamIslandQuest", "Ice Cream Commander", 2, CFrame.new(-641, 127, -11062))
		Configure(2200, 2224, "CakeQuest1", "Cookie Crafter", 1, CFrame.new(-2365, 38, -12099))
		Configure(2225, 2249, "CakeQuest1", "Cake Guard", 2, CFrame.new(-1651, 38, -12308))
		Configure(2250, 2274, "CakeQuest2", "Baking Staff", 1, CFrame.new(-1870, 38, -12938))
		Configure(2275, 2299, "CakeQuest2", "Head Baker", 2, CFrame.new(-1926, 88, -12850))
		Configure(2300, 2324, "ChocQuest1", "Cocoa Warrior", 1, CFrame.new(231, 23, -12194))
		Configure(2325, 2349, "ChocQuest1", "Chocolate Bar Battler", 2, CFrame.new(231, 23, -12194))
		Configure(2350, 2374, "ChocQuest2", "Sweet Thief", 1, CFrame.new(71, 77, -12632))
		Configure(2375, 2399, "ChocQuest2", "Candy Rebel", 2, CFrame.new(134, 77, -12882))
		Configure(2400, 2424, "CandyQuest1", "Candy Pirate", 1, CFrame.new(-1310, 26, -14562))
		Configure(2425, 2449, "CandyQuest1", "Snow Demon", 2, CFrame.new(-880, 71, -14538))
		Configure(2450, 2474, "TikiQuest1", "Isle Outlaw", 1, CFrame.new(-16442, 116, -264))
		Configure(2475, 2499, "TikiQuest1", "Island Boy", 2, CFrame.new(-16901, 84, -192))
		Configure(2500, 2524, "TikiQuest2", "Sun-kissed Warrior", 1, CFrame.new(-16349, 92, 1123))
		Configure(2525, 2549, "TikiQuest2", "Isle Champion", 2, CFrame.new(-17003, 175, 1050))
		Configure(2550, 2574, "TikiQuest3", "Serpent Hunter", 1, CFrame.new(-16587, 154, 1533))
		Configure(2575, 2599, "TikiQuest3", "Skull Slayer", 2, CFrame.new(-16885, 114, 1627))
		Configure(2600, 2624, "SubmergedQuest1", "Reef Bandit", 1, CFrame.new(10875, -2101, 9294))
		Configure(2625, 2649, "SubmergedQuest1", "Coral Pirate", 2, CFrame.new(10875, -2101, 9294))
		Configure(2650, 2674, "SubmergedQuest2", "Sea Chanter", 1, CFrame.new(10672, -2057, 10048))
		Configure(2675, 2699, "SubmergedQuest2", "Ocean Prophet", 2, CFrame.new(11063, -2001, 10149))
		Configure(2700, 2724, "SubmergedQuest3", "High Disciple", 1, CFrame.new(9808, -1942, 9674))
		Configure(2725, 3000, "SubmergedQuest3", "Grand Devotee", 2, CFrame.new(9555, -1993, 9829))

		-- Melees tbl
		local Melees = {
			"Combat",
			"Electro",
			"Black Leg"
		}

		-- Auto Equip Melee
		task.spawn(function()
			while LevelFarm do
				task.wait()

				if PRIORITY ~= "DoingQuest" then continue end

				local inBackpackTool = nil

				-- gets the correct melee
				for _, tool in Backpack:GetChildren() do
					if tool:IsA("Tool") and table.find(Melees, tool.Name) then
						inBackpackTool = tool
						break
					end
				end

				if inBackpackTool ~= nil then
					Humanoid:EquipTool(inBackpackTool)
				end
			end
		end)

		-- Quest
		task.spawn(function()
			Freeze()
			PullNPCs(LevelFarm)

			local lastNPCName = nil
			local AlreadyTPed = false

			while LevelFarm do
				task.wait()

				if CurrentWorld() == 1 and Level.Value >= 700 then
					print("Cannot Farm Anymore")
					return
				elseif CurrentWorld() == 2 and Level.Value >= 1500 then
					print("Cannot Farm Anymore")
					return
				elseif CurrentWorld() == 3 and Level.Value >= LEVEL_CAP then
					print("Cannot Farm Anymore. You (probably), reached the max level. Check it.")
					return
				end

				if not OnQuest() then
					if PRIORITY ~= "" and PRIORITY ~= "DoingQuest" then continue end

					PRIORITY = "DoingQuest"

					Data = GetQuestData()
					
					if Data then
						local dist = magnitude(HumanoidRootPart.Position, Data.QuestArea)
						
						-- resets the AlreadyTPed var thingooo lolo :ooo
						if lastNPCName ~= nil and lastNPCName ~= Data.NPCName then
							AlreadyTPed = false
						end
						
						lastNPCName = Data.NPCName
						
						if not AlreadyTPed then
							if not Vector3Entrances[CurrentWorld()] then continue end
							
							AlreadyTPed = true
							
							local hrpPos = HumanoidRootPart.Position
							
							local TweenTimeTravelled = timeTravelled(hrpPos, Data.QuestArea, 265)
							local TPTimeTravelled = nil
							
							local bestPos = nil
							local lastTimeTravelled = nil
							
							for _, _vector3 in ipairs(Vector3Entrances[CurrentWorld()]) do
								if not bestPos then
									bestPos = _vector3
									lastTimeTravelled = timeTravelled(_vector3, Data.QuestArea, 265)
									continue
								end
								
								local currentTravel = timeTravelled(_vector3, Data.QuestArea, 265)
								
								-- we're analysing SECONDS, btw. just look at the timeTravelled func
								if currentTravel < lastTimeTravelled then
									bestPos = _vector3
									lastTimeTravelled = currentTravel
									
									TPTimeTravelled = lastTimeTravelled
								end
							end
							
							if TPTimeTravelled <= TweenTimeTravelled then
								CommF_:InvokeServer("requestEntrance", bestPos)
								continue
							end
						end
						
						--[[
						if Data.SpecialFunc ~= nil and dist > 3000 and not AlreadyTPed then
							lastNPCName = Data.NPCName
							AlreadyTPed = true

							PRIORITY = "UsingSpecialFunc"

							Data.SpecialFunc()

							task.wait(.5)

							PRIORITY = ""
							continue
						end
						]]

						TweenPosTo(Data.QuestArea * CFrame.new(0, STUDS_ABOVE_NPCS, 0), DoQuest)
					end
				end
			end
		end)

		-- Auto buso
		task.spawn(function()
			if AUTO_BUSO then
				while LevelFarm do
					if not Character:FindFirstChild("HasBuso") then
						CommF_:InvokeServer("Buso")
					end

					task.wait(1)
				end
			end
		end)

		-- Redeem codes
		local Codes = loadstring(game:HttpGet('https://pastebin.com/raw/JUYmrTBK'))()

		local RedeemEvent : RemoteFunction = Remotes:FindFirstChild("Redeem")

		function Redeem(value)
			RedeemEvent:InvokeServer(value)
		end

		task.spawn(function()
			for _, v in Codes do
				Redeem(v)
			end
		end)

		-- Simple anti afk
		AddConnection(Player.Idled:Connect(function()
			VirtualUser:Button1Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
			task.wait(1)
			VirtualUser:Button1Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
		end), LevelFarmConnections)

		-- just some colisions removal
		for _, obj in Character:GetChildren() do
			if obj:IsA("BasePart") then
				obj.CanCollide = false
			end
		end

		for _, npc in NPCs:GetChildren() do
			if npc:IsA("Model") then
				for _, obj in npc:GetChildren() do
					if obj:IsA("BasePart") then
						obj.CanCollide = false
					end
				end
			end
		end

		AddConnection(NPCs.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				for _, obj in child:GetChildren() do
					if obj:IsA("BasePart") then
						obj.CanCollide = false
					end
				end
			end
		end), LevelFarmConnections)

		for _, enemie in Enemies:GetChildren() do
			if enemie:IsA("Model") then
				for _, obj in enemie:GetChildren() do
					if obj:IsA("BasePart") then
						obj.CanCollide = false
					end
				end
			end
		end

		AddConnection(Enemies.ChildAdded:Connect(function(child)
			if child:IsA("Model") then
				for _, obj in child:GetChildren() do
					if obj:IsA("BasePart") then
						obj.CanCollide = false
					end
				end
			end
		end), LevelFarmConnections)

	else
		OnDisabled()
	end
end

local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

local Window = WindUI:CreateWindow({
	Title = "Seitium Hub",
	Icon = "eye",
	Author = "all scripts made by infernus",
})

Window:SetToggleKey(Enum.KeyCode.Insert)

local Farm_Tab = Window:Tab({
	Title = "Auto Farm",
	Icon = "square-mouse-pointer",
})

Farm_Tab:Select()

Farm_Tab:Toggle({
	Title = "Auto Level Farm",
	Callback = function(state)
		AutoLevelFarm(state)
	end,
})

local Stats_Tab = Window:Tab({
	Title = "Stats",
	Icon = "chart-no-axes-column",
})

local Stats_Section = Stats_Tab:Section({
	Title = "Status Config",
	Box = true,
	BoxBorder = true,
	Opened = true
})

local AutoStats_Toggle = Stats_Section:Toggle({
	Title = "Auto Stats",
	Callback = function(state)
		AutoStats(state)
	end,
})

Stats_Section:Space()

local Select_Stats = Stats_Section:Dropdown({
	Title = "Select Stats",
	Values = {
		"Melee",
		"Defense",
		"Sword",
		"Gun",
		"Demon Fruit"
	},
	Value = "Melee",
	Callback = function(selected)
		SelectedStat = selected
	end,
})

Stats_Section:Space()

Stats_Section:Slider({
	Title = "Select Points Quantity",
	Value = {
		Min = 1,
		Max = 10,
		Default = 10
	},
	Callback = function(value)
		PointsPerAdd = value
	end,
})

local Fruits_Tab = Window:Tab({
	Title = "Fruits",
	Icon = "apple",
})

local AutoBuyRandomFruits_Toggle = Fruits_Tab:Toggle({
	Title = "Auto Buy Random Fruits",
	Callback = function(state)
		AutoBuyRandomFruits(state)
	end,
})

local AutoStoreFruits_Toggle = Fruits_Tab:Toggle({
	Title = "Auto Store Fruits",
	Callback = function(state)
		AutoStoreFruits(state)
	end,
})

local Quest_Tab = Window:Tab({
	Title = "Quest",
	Icon = "map"
})

local AutoNextSea_Toggle = Quest_Tab:Toggle({
	Title = "Auto Next Sea",
	Callback = function(state)
		AutoNextSea(state)
	end,
})

local AutoBuy_Tab = Window:Tab({
	Title = "Buy",
	Icon = "banknote-arrow-down"
})

local AutoDarkStep_Toggle = AutoBuy_Tab:Toggle({
	Title = "Auto Dark Step",
	Callback = function(state)
		AutoDarkStep(state)
	end,
})

local AutoElectric_Toggle = AutoBuy_Tab:Toggle({
	Title = "Auto Electric",
	Callback = function(state)
		AutoElectric(state)
	end,
})
