-- // Main Entry Point
-- // Load this file: loadstring(game:HttpGet("MAIN_URL"))()
-- // This will load all other modules in the correct order

repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer

-- Load Configuration (must be first)
local Config = loadstring(game:HttpGet("https://raw.githubusercontent.com/deshawnbrown1111/brn/refs/heads/main/src/config.lua"))()
_G.AltConfig = Config

local IS_ALT = LocalPlayer.Name ~= Config.MAIN_ACCOUNT

-- Load modules
loadstring(game:HttpGet("https://raw.githubusercontent.com/deshawnbrown1111/brn/refs/heads/main/src/attachment.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/deshawnbrown1111/brn/refs/heads/main/src/fling.lua"))()
loadstring(game:HttpGet("https://raw.githubusercontent.com/deshawnbrown1111/brn/refs/heads/main/src/commands.lua"))()

-- Alt: Poll server for commands
if IS_ALT then
    task.spawn(function()
        while task.wait(0.6) do
            local success, res = pcall(function()
                return request({ Url = Config.SERVER_URL .. "/getCommand?player=" .. LocalPlayer.Name })
            end)
            if success and res and res.Success and res.Body and res.Body ~= "" then
                local ok, data = pcall(function() return HttpService:JSONDecode(res.Body) end)
                if ok and data.command and _G.AltCommands then
                    _G.AltCommands.runCommand(data.command, data.args or {})
                end
            end
        end
    end)
    print("[ALT] Ready →", LocalPlayer.Name)
    return
end

-- Main account: Load GUI
print("[MAIN] Alt Control Loaded → Press K to command")
loadstring(game:HttpGet("https://raw.githubusercontent.com/deshawnbrown1111/brn/refs/heads/main/src/gui.lua"))()
