if getgenv().Aiming then return getgenv().Aiming end

-- // Services
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local GuiService = game:GetService("GuiService")
local RunService = game:GetService("RunService")

-- // Vars
local Heartbeat = RunService.Heartbeat
local LocalPlayer = Players.LocalPlayer
local CurrentCamera = Workspace.CurrentCamera
local Mouse = LocalPlayer:GetMouse()

-- // Optimisation Vars (ugly)
local Drawingnew = Drawing.new
local Color3fromRGB = Color3.fromRGB
local Vector2new = Vector2.new
local GetGuiInset = GuiService.GetGuiInset
local Randomnew = Random.new
local mathfloor = math.floor
local CharacterAdded = LocalPlayer.CharacterAdded
local CharacterAddedWait = CharacterAdded.Wait
local WorldToViewportPoint = CurrentCamera.WorldToViewportPoint
local RaycastParamsnew = RaycastParams.new
local EnumRaycastFilterTypeBlacklist = Enum.RaycastFilterType.Blacklist
local Raycast = Workspace.Raycast
local GetPlayers = Players.GetPlayers
local Instancenew = Instance.new
local IsDescendantOf = Instancenew("Part").IsDescendantOf
local FindFirstChildWhichIsA = Instancenew("Part").FindFirstChildWhichIsA
local FindFirstChild = Instancenew("Part").FindFirstChild
local tableremove = table.remove
local tableinsert = table.insert

-- // Silent Aim Vars
getgenv().Aiming = {
Enabled = true,
ShowFOV = false,
FOVSides = 12,
FOVColour = Color3fromRGB(231, 84, 128),
VisibleCheck = true,
FOV = 12,
HitChance = 100,
Selected = LocalPlayer,
SelectedPart = nil,
TargetPart = {randomBodyPart()},
Ignored = {
Teams = {
{
Team = LocalPlayer.Team,
TeamColor = LocalPlayer.TeamColor,
},
},
Players = {
LocalPlayer,
1
}
}
}
local Aiming = getgenv().Aiming

-- // Possible target body parts
local possibleParts = {"Head", "Torso", "RightArm", "LeftArm", "RightLeg", "LeftLeg"}

-- // Function to select a random body part from possibleParts table
function randomBodyPart()
return possibleParts[math.random(#possibleParts)]
end

-- // Show FOV
local circle = Drawingnew("Circle")
circle.Transparency = 1
circle.Thickness = 2
circle.Color = Aiming.FOVColour
circle.Filled = false
function Aiming.UpdateFOV()
if (circle) then
-- // Set Circle Properties
circle.Visible = Aiming.ShowFOV
circle.Radius = (Aiming.FOV * 2)
circle.Position = Vector2new(Mouse.X, Mouse.Y + GetGuiInset(GuiService).Y)
circle.NumSides = Aiming.FOVSides
circle.Color = Aiming.FOVColour
    -- // Return circle
    return circle
end
end
-- // Custom Functions
local CalcChance = function(percentage)
percentage = mathfloor(percentage)
local chance = mathfloor(Randomnew().NextNumber(Randomnew(), 0, 1) * 100) / 100
return chance <= percentage / 100
end

-- // Customisable Checking Functions: Is a part visible
function Aiming.IsPartVisible(Part, PartDescendant)
-- // Vars
local Character = LocalPlayer.Character or CharacterAddedWait(CharacterAdded)
local Origin = CurrentCamera.CFrame.Position
local _, OnScreen = WorldToViewportPoint(CurrentCamera, Part.Position)
-- // If Part is on the screen
if (OnScreen) then
    -- // Vars: Calculating if is visible
    local raycastParams = RaycastParamsnew()
    raycastParams.FilterType = EnumRaycastFilterTypeBlacklist
    raycastParams.FilterDescendantsInstances = {Character, CurrentCamera}

    local Result = Raycast(Workspace, Origin, Part.Position - Origin, raycastParams)
    if (Result) then
        local PartHit = Result.Instance
        local Visible = (not PartHit or IsDescendantOf(PartHit, Part))

        -- // Return
        if (Visible and CalcChance(Aiming.HitChance)) then
            return true
        end
    end
end
end
-- // Targetting Function
function Aiming.Target()
for i, Player in pairs(GetPlayers(Players)) do
if (Player ~= LocalPlayer) then
local randomPart = randomBodyPart()
local Character = Player.Character
if (Character) then
local TargetPart = FindFirstChildWhichIsA(Character, randomPart)
if (TargetPart) then
if (Aiming.IsPartVisible(TargetPart)) then
Aiming.Selected = Player
Aiming.SelectedPart = TargetPart
return
end
end
end
end
end
end
-- // Main Loop
Heartbeat:Connect(function()
if (Aiming.Enabled) then
Aiming.Target()
end
end)

-- // Mains
Aiming.TeamCheck(false)

local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local CurrentCamera = Workspace.CurrentCamera

local DaHoodSettings = {
SilentAim = true,
AimLock = false,
Prediction = 0.165,
AimLockKeybind = Enum.KeyCode.E
}
getgenv().DaHoodSettings = DaHoodSettings

function Aiming.Check()
if not (Aiming.Enabled == true and Aiming.Selected ~= LocalPlayer and Aiming.SelectedPart ~= nil) then
return false
end
local Character = Aiming.Character(Aiming.Selected)
local KOd = Character:WaitForChild("BodyEffects")["K.O"].Value
local Grabbed = Character:FindFirstChild("GRABBING_CONSTRAINT") ~= nil

if (KOd or Grabbed) then
    return false
end

return true
end
local __index
__index = hookmetamethod(game, "__index", function(t, k)
if (t:IsA("Mouse") and (k == "Hit" or k == "Target") and Aiming.Check()) and _G.SAEnabled then
local SelectedPart = Aiming.SelectedPart
    if (DaHoodSettings.SilentAim and (k == "Hit" or k == "Target")) then
        local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * DaHoodSettings.Prediction)

        return (k == "Hit" and Hit or SelectedPart)
    end
end

return __index(t, k)
end)
RunService:BindToRenderStep("AimLock", 0, function()
if (DaHoodSettings.AimLock and Aiming.Check() and UserInputService:IsKeyDown(DaHoodSettings.AimLockKeybind)) then
local SelectedPart = Aiming.SelectedPart

    local Hit = SelectedPart.CFrame + (SelectedPart.Velocity * DaHoodSettings.Prediction)

    CurrentCamera.CFrame = CFrame.lookAt(CurrentCamera.CFrame.Position, Hit.Position)
end
end)
-- // Additional Functions
function randomBodyPart()
local bodyParts = {"Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Torso"}
local index = math.random(1, #bodyParts)
return bodyParts[index]
end

-- // Keybinds
game:GetService("UserInputService").InputBegan:connect(function(input)
if input.KeyCode == Enum.KeyCode.V then
_G.SAEnabled = true
end
if input.KeyCode == Enum.KeyCode.C then
_G.SAEnabled = false
end
if input.KeyCode == Enum.KeyCode.Minus then
Aiming.ShowFOV = Aiming.ShowFOV == true
end
if input.KeyCode == Enum.KeyCode.Equals then
Aiming.ShowFOV = Aiming.ShowFOV == false
end
end)

return Aiming

-- // End of Script

-- // Additional Notes
-- This script may be considered illegal in some communities, use at your own risk.
