-- // Commands System
-- // Handles command execution and sending to alts
-- // Load: loadstring(game:HttpGet("COMMANDS_URL"))()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

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

-- Execute command (for alts)
local function runCommand(cmd, args)
    if cmd == "tpToMe" then
        local p = Players:FindFirstChild(args[1])
        if p and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
            hrp.CFrame = p.Character.HumanoidRootPart.CFrame * CFrame.new(math.random(-5,5), 0, math.random(-5,5))
        end
    elseif cmd == "attach" then
        if _G.AltAttachment then
            _G.AltAttachment.startAttach(args[1], false, tonumber(args[2]) or 1)
        end
    elseif cmd == "rotate" then
        if _G.AltAttachment then
            _G.AltAttachment.startAttach(args[1], true, tonumber(args[2]) or 1)
        end
    elseif cmd == "unattach" then
        if _G.AltAttachment then
            _G.AltAttachment.stopAttach()
            _G.AltAttachment.stopSandwich()
        end
    elseif cmd == "kill" then
        -- Alts should obey this. Main will NOT kill itself.
        if hum then hum.Health = 0 end
    elseif cmd == "sandwich" then
        if _G.AltAttachment then
            local targetName = args[1]
            local position = args[2] -- "front" or "back"
            local distance = args[3] or 4
            _G.AltAttachment.startSandwich(targetName, position, distance)
        end
    elseif cmd == "fling" then
        if _G.AltFling then
            _G.AltFling.flingTarget(args[1])
        end
    end
end

-- Send command to alts (main only)
local function sendToAlts(command, args)
    task.spawn(function()
        -- Special handling for sandwich command - only use first 2 alts
        if command == "sandwich" then
            local targetName = args[1] or LocalPlayer.Name
            local distance = args[2] or 4
            
            -- Send to first alt (BEHIND)
            if #Config.ALTS >= 1 then
                local alt1 = Config.ALTS[1]
                if alt1 ~= Config.MAIN_ACCOUNT and alt1 ~= LocalPlayer.Name then
                    pcall(function()
                        request({
                            Url = Config.SERVER_URL .. "/command",
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode({
                                command = "sandwich",
                                args = { targetName, "back", tostring(distance) },
                                sender = LocalPlayer.Name,
                                target = alt1
                            })
                        })
                    end)
                    task.wait(0.03)
                end
            end
            
            -- Send to second alt (FRONT)
            if #Config.ALTS >= 2 then
                local alt2 = Config.ALTS[2]
                if alt2 ~= Config.MAIN_ACCOUNT and alt2 ~= LocalPlayer.Name then
                    pcall(function()
                        request({
                            Url = Config.SERVER_URL .. "/command",
                            Method = "POST",
                            Headers = { ["Content-Type"] = "application/json" },
                            Body = HttpService:JSONEncode({
                                command = "sandwich",
                                args = { targetName, "front", tostring(distance) },
                                sender = LocalPlayer.Name,
                                target = alt2
                            })
                        })
                    end)
                    task.wait(0.03)
                end
            end
            return
        end
        
        -- Regular commands - send to all alts
        for i, name in ipairs(Config.ALTS) do
            -- Extra safety: never target the main account or this LocalPlayer
            if name ~= Config.MAIN_ACCOUNT and name ~= LocalPlayer.Name then
                local finalArgs = args or {}

                if command == "attach" or command == "rotate" then
                    -- args[1] should be the target player's name (or nil -> use LocalPlayer.Name)
                    local targetForAlts = finalArgs[1] or LocalPlayer.Name
                    finalArgs = { targetForAlts, tostring(i) } -- include orbit index
                end

                pcall(function()
                    request({
                        Url = Config.SERVER_URL .. "/command",
                        Method = "POST",
                        Headers = { ["Content-Type"] = "application/json" },
                        Body = HttpService:JSONEncode({
                            command = command,
                            args = finalArgs,
                            sender = LocalPlayer.Name,
                            target = name
                        })
                    })
                end)
                task.wait(0.03)
            end
        end
    end)
end

-- Export functions
_G.AltCommands = {
    runCommand = runCommand,
    sendToAlts = sendToAlts
}

