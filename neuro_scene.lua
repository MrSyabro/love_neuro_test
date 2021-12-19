local ui = require "love_engine.UI"
local nord = require "love_engine.nord"
local nn = require "nn"

local ww, wh = love.window.getMode()
local draw = false

network = ui.new_object("network")
network.colors = {}
network.colors[1] = engine.userdata[1]
network.colors[2] = engine.userdata[2]
network.colors[3] = engine.userdata[3]
network.inputs = {}
network.outputs = {}
network.points = {}
function network:load()
    self.nn = nn.Network {
        nn.Dense(2, 6),
        nn.Dense(6, 6),
        nn.Dense(6, 6),
        nn.Dense(6, 3)
    }
    objs.mouse:register("pressed", self)
    objs.keys:register("pressed", self)
end

function network:update(dt)

    for c = 0, 50 do
        for i = 1, #self.inputs do
            self.nn:train(self.inputs[i], self.colors[self.outputs[i]], 1)
        end
    end
    local points = {}
    for w = 0, (ww / 10) do
        for h = 0, (wh / 10) do
            local uw, uh = utils.tu(w * 10, h * 10)
            local o = self.nn:predict ( uw, uh )
            table.insert(points, {w * 10, h * 10, o[1], o[2], o[3]})
        end
    end

    self.points = points

    draw = not draw
end

function network:mousepressed( x, y, button, istouch, presses )
    if self.colors[button] then
        table.insert(self.inputs, {utils.tu(x, y)})
        table.insert(self.outputs, button)
        print("Add point to "..x.." * "..y.." with button "..button)
    end
end

function network:keypressed( key, scancode, isrepeat )
    if key == "p" then
        utils.info ("Calculating...")
        local imageData = love.image.newImageData(4096, 3072)
        for w = 0, 4096 - 1 do
            for h = 0, 3072 - 1 do
                local uw = w / 4096
                local uh = h / 3072
                local o = self.nn:predict ( uw, uh )
                imageData:setPixel(w, h, o[1], o[2], o[3], 1)
            end
        end

        imageData:encode("png", "screenshot.png")
        utils.info ("Immage saved.")
    elseif key == "r" then
        utils.info("Reseting network")
        self.nn = nn.Network {
            nn.Dense(2, 6),
            nn.Dense(6, 6),
            nn.Dense(6, 6),
            nn.Dense(6, 3)
        }
    elseif key == "q" then
        engine:load_scene("menu.lua")
    elseif key == "c" then
        self.inputs = {}
        self.outputs = {}
    end
end

function network:draw()
    for k,i in ipairs(self.points) do
        love.graphics.setColor(i[2], i[4], i[5])
        love.graphics.circle("fill", i[1], i[2], 7)
    end
    
    for k,i in ipairs(self.inputs) do
        love.graphics.setColor(self.colors[self.outputs[k]])
        local x, y = utils.tc(i[1], i[2])
        love.graphics.circle("fill", x, y, 8)
        love.graphics.setColor(216 /256, 222 / 256, 233 / 256)
        love.graphics.circle("line", x, y, 10)
    end
end

objs:add(network)