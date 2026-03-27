local Noctaer = loadstring(game:HttpGet("https://raw.githubusercontent.com/solomigg0-debug/noctaer-ui/refs/heads/main/src/Noctaer.lua"))()

local Window = Noctaer:CreateWindow({
    Title = "Noctaer",
    Subtitle = "Demo"
})

local Tab = Window:CreateTab("Main")

Tab:CreateButton({
    Name = "Test",
    Callback = function()
        print("ok")
    end
})
