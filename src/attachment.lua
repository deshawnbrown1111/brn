-- // Attachment System
-- // Handles attach, rotate, and sandwich commands
-- // Load: loadstring(game:HttpGet("ATTACHMENT_URL"))()

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local Config = _G.AltConfig

-- Character Handling
local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local hrp = char:WaitForChild("HumanoidRootPart")
local hum = char:WaitForChild("Humanoid")

LocalPlayer.CharacterAdded:Connect(function(newChar)
    char = newChar
    hrp = newChar:WaitForChild("HumanoidRootPart")
    hum = newChar:WaitForChild("Humanoid")
end)

-- Attachment System
local attached = false
local attachTarget = nil
local rotating = false
local angle = 0
local connection = nil

-- Sandwich System
local sandwiched = false
local sandwichTarget = nil
local sandwichPosition = nil -- "front" or "back"
local sandwichDistance = 4
local sandwichConnection = nil

local function stopAttach()
    attached = false
    attachTarget = nil
    rotating = false
    if connection then
        connection:Disconnect()
        connection = nil
    end
end

local function stopSandwich()
    sandwiched = false
    sandwichTarget = nil
    sandwichPosition = nil
    if sandwichConnection then
        sandwichConnection:Disconnect()
        sandwichConnection = nil
    end
end

local function startSandwich(targetName, position, distance)
    local targetPlr = Players:FindFirstChild(targetName)
    
    if not (targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")) then
        stopSandwich()
        return
    end
    
    stopSandwich() -- clear old
    stopAttach() -- stop attach if active
    
    sandwichTarget = targetPlr
    sandwiched = true
    sandwichPosition = position
    sandwichDistance = tonumber(distance) or 4
    
    sandwichConnection = RunService.Heartbeat:Connect(function()
        local tHRP = sandwichTarget and sandwichTarget.Character and sandwichTarget.Character:FindFirstChild("HumanoidRootPart")
        if not (tHRP and hrp) then stopSandwich() return end
        
        local targetCFrame = tHRP.CFrame
        
        if sandwichPosition == "front" then
            -- Position in front (positive Z direction)
            hrp.CFrame = targetCFrame * CFrame.new(0, 0, sandwichDistance)
        elseif sandwichPosition == "back" then
            -- Position behind (negative Z direction)
            hrp.CFrame = targetCFrame * CFrame.new(0, 0, -sandwichDistance)
        end
    end)
end

local function startAttach(targetName, rotate, index)
    local targetPlr = Players:FindFirstChild(targetName)

    if not (targetPlr and targetPlr.Character and targetPlr.Character:FindFirstChild("HumanoidRootPart")) then
        stopAttach()
        return
    end

    stopAttach() -- clear old
    stopSandwich() -- stop sandwich if active

    attachTarget = targetPlr
    attached = true
    rotating = rotate
    index = tonumber(index) or 1

    connection = RunService.Heartbeat:Connect(function()
        local tHRP = attachTarget and attachTarget.Character and attachTarget.Character:FindFirstChild("HumanoidRootPart")
        if not (tHRP and hrp) then stopAttach() return end

        if rotating then
            angle = angle + 1.8
            local radius = 5.5
            local total = math.max(0, #Config.ALTS - 1)
            local offsetAngle = total > 0 and (index * 360 / total) or 0
            local rad = math.rad(angle + offsetAngle)
            local offset = Vector3.new(math.cos(rad) * radius, 1.5, math.sin(rad) * radius)
            hrp.CFrame = tHRP.CFrame * CFrame.new(offset)
        else
            hrp.CFrame = tHRP.CFrame
        end
    end)
end

-- Export functions
_G.AltAttachment = {
    startAttach = startAttach,
    stopAttach = stopAttach,
    startSandwich = startSandwich,
    stopSandwich = stopSandwich
}
