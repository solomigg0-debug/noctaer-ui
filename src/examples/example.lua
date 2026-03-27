local Noctaer = loadstring(game:HttpGet("LINK_AQUI"))()

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
