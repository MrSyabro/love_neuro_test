local ui = require "love_engine.UI"
local nord = require "love_engine.nord"
local nn = require "nn"

local ww, wh = love.window.getMode()
network = ui.new_object("network")
network.colors = {}
network.colors[1] = engine.userdata[1]
network.colors[2] = engine.userdata[2]
network.colors[3] = engine.userdata[3]
network.inputs = {}
network.outputs = {}
network.points = {}
network.pause_train = false
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

    if not self.pause_train then
        for c = 0, 50 do
            for i = 1, #self.inputs do
                self.nn:train(self.inputs[i], self.colors[self.outputs[i]], 1)
            end
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
    if key == "s" then
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
    elseif key == "p" then
        self.pause_train = not self.pause_train
    end
end

function network:draw()
    for k,i in ipairs(self.points) do
        love.graphics.setColor(i[3], i[4], i[5])
        love.graphics.circle("fill", i[1], i[2], 7)
    end
    
    for k,i in ipairs(self.inputs) do
        love.graphics.setColor(self.colors[self.outputs[k]])
        local x, y = utils.tc(i[1], i[2])
        love.graphics.circle("fill", x, y, 8)
        love.graphics.setColor(216 /256, 222 / 256, 233 / 256)
        love.graphics.circle("line", x, y, 10)
    end

    if self.pause_train then
        local x, y = utils.tc(0.5, 0.5)
        love.graphics.setColor(1,0,0)
        love.graphics.print("pause", x, y)
        love.graphics.setColor(1,1,1)
    end
end

objs:add(network)

fps = ui.new_element("fps", utils.tc(0.96, 0.01))
fps.printed_text = ""
fps.timer = 0
fps.count = 0
fps.size.w = 50
fps.size.h = 13
function fps:update(dt)
    self.timer = self.timer + dt
    self.count = self.count + 1
    if self.timer >= 1 then
        self.printed_text = "TPS "..self.count
        self.timer = 0
        self.count = 0
    end
end
function fps:draw()
    love.graphics.polygon( "fill", 
			self.pos.x, self.pos.y, 
			self.pos.x + self.size.w, self.pos.y, 
			self.pos.x + self.size.w, self.pos.y + self.size.h, 
			self.pos.x, self.pos.y + self.size.h )
    love.graphics.setColor(0,0,0)
    love.graphics.print(self.printed_text, self.pos.x, self.pos.y)
    love.graphics.setColor(1,1,1)
end

objs:add(fps)