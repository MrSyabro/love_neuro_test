local ui = require "love_engine.UI"
local nord = require "love_engine.nord"

local function convert_color(color)
    local ch = 1
    if color:sub(1,1) == "#" then
        ch = 2
    end
    local c = {}
    for i = 1, 3 do
        c[i] = tonumber(color:sub(ch, ch + 1), 16) / 256
        ch = ch + 2
    end

    return c
end

grid = ui.new_grid ("grid", 0, 0, utils.tc(1, 1))

color1 = ui.new_textentry("color1_entry")
color1.textinput = "#bf616a"
color2 = ui.new_textentry("color2_entry")
color2.textinput = "#ebcb8b"
color3 = ui.new_textentry("color3_entry")
color3.textinput = "#b48ead"

text1 = ui.new_text("color1_text")
text2 = ui.new_text("color2_text")
text3 = ui.new_text("color3_text")

button1 = ui.new_button("start_bt", utils.tc(0.01, 0.26))
button1.printed_name = "Start"
function button1.callbacks.mousepressed(self)
    engine.userdata[1] = convert_color(color1.textinput)
    utils.info (("Add color 1 {%f, %f, %f}"):format(engine.userdata[1][1], engine.userdata[1][2], engine.userdata[1][3]))
    engine.userdata[2] = convert_color(color2.textinput)
    utils.info (("Add color 2 {%f, %f, %f}"):format(engine.userdata[2][1], engine.userdata[2][2], engine.userdata[2][3]))
    engine.userdata[3] = convert_color(color3.textinput)
    utils.info (("Add color 3 {%f, %f, %f}"):format(engine.userdata[3][1], engine.userdata[3][2], engine.userdata[3][3]))

    engine:load_scene("neuro_scene.lua")
end

grid1 = ui.new_grid ("grid1")
grid:add(grid1, 2, 2)

grid1:add(text1, 1, 1)
grid1:add(text2, 1, 2)
grid1:add(text3, 1, 3)
grid1:add(color1, 2, 1)
grid1:add(color2, 2, 2)
grid1:add(color3, 2, 3)
grid1:add(button1, 3, 3)

objs:add(grid1)
