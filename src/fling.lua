-- // Fling System
-- // Handles fling command
-- // Load: loadstring(game:HttpGet("FLING_URL"))()

local Players = game:GetService("Players")

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

local function flingTarget(targetName)
    local targetPlr = Players:FindFirstChild(targetName)
    
    if not targetPlr or not targetPlr.Parent then
        return
    end
    
    local tchar = targetPlr.Character
    if not tchar then
        return
    end
    
    local thum = tchar:FindFirstChildOfClass("Humanoid")
    local trp = thum and thum.RootPart
    local thead = tchar:FindFirstChild("Head")
    local accessory = tchar:FindFirstChildOfClass("Accessory")
    local handle = accessory and accessory:FindFirstChild("Handle")
    
    if not (char and hum and hrp) then
        return
    end
    
    getgenv().FPDH = getgenv().FPDH or workspace.FallenPartsDestroyHeight
    
    if hrp.Velocity.Magnitude < 50 then
        getgenv().OldPos = hrp.CFrame
    end
    
    if thum and thum.Sit then
        return
    end
    
    if thead then
        workspace.CurrentCamera.CameraSubject = thead
    elseif handle then
        workspace.CurrentCamera.CameraSubject = handle
    elseif thum then
        workspace.CurrentCamera.CameraSubject = thum
    end
    
    if not tchar:FindFirstChildWhichIsA("BasePart") then
        return
    end
    
    local function FPos(basePart, posCFrame, angCFrame)
        if not (hrp and char) then return end
        local combined = CFrame.new(basePart.Position) * (posCFrame or CFrame.new()) * (angCFrame or CFrame.new())
        pcall(function()
            hrp.CFrame = combined
            if char.PrimaryPart then
                char:SetPrimaryPartCFrame(combined)
            else
                char:TranslateBy(combined.p - hrp.CFrame.p)
            end
            hrp.Velocity = Vector3.new(9e7, 9e7 * 10, 9e7)
            hrp.RotVelocity = Vector3.new(9e8, 9e8, 9e8)
        end)
    end
    
    local function SFBasePart(basePart)
        local TimeToWait = 2
        local startTick = tick()
        local angle = 0
        
        repeat
            if not (hrp and thum and basePart and basePart.Parent == targetPlr.Character and targetPlr.Parent == Players) then
                break
            end
            
            if basePart.Velocity.Magnitude < 50 then
                angle = angle + 100
                
                FPos(basePart, CFrame.new(0, 1.5, 0) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, 0) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(2.25, 1.5, -2.25) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(-2.25, -1.5, 2.25) + (thum.MoveDirection * (basePart.Velocity.Magnitude / 1.25)), CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, 1.5, 0) + thum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, 0) + thum.MoveDirection, CFrame.Angles(math.rad(angle), 0, 0))
                task.wait()
            else
                FPos(basePart, CFrame.new(0, 1.5, thum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, -thum.WalkSpeed), CFrame.Angles(0, 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, 1.5, thum.WalkSpeed), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, 1.5, (trp and trp.Velocity.Magnitude or 0) / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, - (trp and trp.Velocity.Magnitude or 0) / 1.25), CFrame.Angles(0, 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, 1.5, (trp and trp.Velocity.Magnitude or 0) / 1.25), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(90), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(math.rad(-90), 0, 0))
                task.wait()
                
                FPos(basePart, CFrame.new(0, -1.5, 0), CFrame.Angles(0, 0, 0))
                task.wait()
            end
        until (basePart.Velocity.Magnitude > 500)
            or (basePart.Parent ~= targetPlr.Character)
            or (targetPlr.Parent ~= Players)
            or (tick() > startTick + TimeToWait)
            or (thum and thum.Sit)
            or (hum and hum.Health <= 0)
    end
    
    workspace.FallenPartsDestroyHeight = 0/0
    
    local BV = Instance.new("BodyVelocity")
    BV.Name = "EpixVel"
    BV.Parent = hrp
    BV.Velocity = Vector3.new(9e8, 9e8, 9e8)
    BV.MaxForce = Vector3.new(1/0, 1/0, 1/0)
    
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, false)
    
    if trp and thead then
        if (trp.Position - thead.Position).Magnitude > 5 then
            SFBasePart(thead)
        else
            SFBasePart(trp)
        end
    elseif trp then
        SFBasePart(trp)
    elseif thead then
        SFBasePart(thead)
    elseif handle then
        SFBasePart(handle)
    else
        BV:Destroy()
        hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
        workspace.CurrentCamera.CameraSubject = hum
        workspace.FallenPartsDestroyHeight = getgenv().FPDH
        return
    end
    
    if BV and BV.Parent then
        BV:Destroy()
    end
    hum:SetStateEnabled(Enum.HumanoidStateType.Seated, true)
    workspace.CurrentCamera.CameraSubject = hum
    
    if getgenv().OldPos then
        repeat
            if not (hrp and getgenv().OldPos) then break end
            pcall(function()
                hrp.CFrame = getgenv().OldPos * CFrame.new(0, .5, 0)
                if char.PrimaryPart then
                    char:SetPrimaryPartCFrame(getgenv().OldPos * CFrame.new(0, .5, 0))
                end
                hum:ChangeState("GettingUp")
                for _, part in ipairs(char:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.Velocity = Vector3.new()
                        part.RotVelocity = Vector3.new()
                    end
                end
            end)
            task.wait()
        until (hrp.Position - getgenv().OldPos.p).Magnitude < 25
    end
    
    workspace.FallenPartsDestroyHeight = getgenv().FPDH
end

-- Export function
_G.AltFling = {
    flingTarget = flingTarget
}

