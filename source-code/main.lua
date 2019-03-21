--[[
    slot machine game
    name: abhinav lakhani
    3398akshu@gmail.com
]]

require 'constants'
require 'dependencies'

local slotPadding = (WINDOW_WIDTH - gTextures['slot-machine']:getWidth()) / 2

local slotReels = {{}, {}, {}}

local slotIcons = {'50', 'apple', 'banana', 'pineapple', 'cherry', 
                    'lemon', 'strawberry', 'orange'}

local slotVelocities = {0, 0, 0}

local stops = {
    { target = 0, total = 0},
    { target = 0, total = 0},
    { target = 0, total = 0}
}

local running = false
local win = false
local colorIndex = 1

function love.load()
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT)
    love.window.setTitle('slot-machine')

    math.randomseed(os.time())

    -- populate each slot reel with icons
    for i = 1, 3 do

        -- generate entire slot reels for this column
        for k, v in pairs(slotIcons) do
            table.insert(slotReels[i], {
                icon = v,
                x = slotPadding + HORIZONTAL_SLOT_OFFSET + (SLOT_ICON_OFFSET * (i - 1)),
                y = VERTICAL_SLOT_OFFSET + (k - 1) * ICON_SIZE
            })
        end    
    end
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    end

    if key == 'space' then        
        -- set velocities of reels
        if slotVelocities[1] == 0 and not running then
            running = true
            win = false

            timer.tween(2, {
                [slotVelocities] = {[1] = 500}
            })
            
            timer.after(0.1, function()
                timer.tween(2, {
                    [slotVelocities] = {[2] = 500}
                })                
            end)

            timer.after(0.2, function()
                timer.tween(2, {
                    [slotVelocities] = {[3] = 500}
                })                
            end)
        elseif slotVelocities[1] == 500 then
            timer.tween(2, {
                [slotVelocities] = {[1] = 30}
            }):finish(function()
                stops[1].target = math.random(3)
            end)
        elseif slotVelocities[2] == 500 then
            timer.tween(2, {
                [slotVelocities] = {[2] = 30}
            }):finish(function()
                stops[2].target = math.random(3)
            end)
        elseif slotVelocities[3] == 500 then
            timer.tween(2, {
                [slotVelocities] = {[3] = 30}
            }):finish(function()
                stops[3].target = math.random(3)
            end)
        end        
    end
end

function love.update(dt)

    timer.update(dt)

    -- scroll all of the wheels
    for i = 1, 3 do
        for k, icon in pairs(slotReels[i]) do
            icon.y = icon.y - slotVelocities[i] * dt            
        end
    end

    -- loop wheel if necessery
    for i = 1, 3 do
        if slotReels[i][1].y < SLOT_LOOP_Y then
            table.insert(slotReels[i], table.remove(slotReels[i], 1))
            slotReels[i][#slotIcons].y = slotReels[i][#slotIcons -1].y + ICON_SIZE

            -- only check if we have target
            if stops[i].target > 0 then
                stops[i].total = stops[i].total + 1

                if stops[i].target == stops[i].total then
                    slotVelocities[i] = 0
                    stops[i].total = 0
                    stops[i].target = 0

                    -- check for a win & flag slot as finished running
                    if slotVelocities[1] == slotVelocities[2] and slotVelocities[1] == slotVelocities[3] then
                        running = false

                        if slotReels[1][2].icon == slotReels[2][2].icon and slotReels[1][2].icon ==  slotReels[3][2].icon then
                            win = true

                            -- set winning color index
                            colorIndex = math.random(255)
                        end
                    end
                end
            end
        end
    end
end

function love.draw()
    love.graphics.draw(gTextures['casino'], 0, -100)        

    for i = 1, 3 do
        for k, v in pairs(slotReels[i]) do 

            if v.y > 140 and v.y < 400 then
            love.graphics.draw(
                gTextures[v.icon], v.x, v.y)
            end
        end
    end

    if win then
        love.graphics.setColor(colorIndex, colorIndex, colorIndex, 0.2)
        for i = 1, 3 do
            love.graphics.rectangle('fill', slotReels[i][2].x + 2, slotReels[i][2].y,
                SLOT_ICON_OFFSET, ICON_SIZE)
        end
        love.graphics.setColor(colorIndex, colorIndex, colorIndex, 1)
    end

    love.graphics.draw(gTextures['slot-machine'], slotPadding, 0)
end