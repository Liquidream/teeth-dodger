--[[
-- Teeth Dodger
-- by Paul Nicholas

## TODO's
  • 
  • 
  
  ## IDEAS
  • 
  • 
  •   
  
## DONE  
  • 

## ACKNOWLEDGEMENTS
  • @somepx for Hungry font
   (https://www.patreon.com/posts/new-free-font-27405348)

]]


if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'common.lua',
    'draw.lua',
    'init.lua',
    'main.lua',
    --'storage.lua',
    --'ui_input.lua',
    'update.lua',
    'sugarcoat/sugarcoat.lua',
    'sprinklez.lua',
    'assets/Hungry.ttf',
    'assets/spritesheet.png',
    'assets/title-text.png',
    -- 'assets/splash.png',
    -- 'assets/controls.gif',
    -- 'assets/snd/music.mp3',
    -- 'assets/snd/win.mp3',
    -- 'assets/snd/fall.mp3',
    -- 'assets/snd/step.mp3',
    -- 'assets/snd/collect.mp3',
    -- 'assets/snd/flicker_high.mp3',
    -- 'assets/snd/flicker_low.mp3',
    -- 'assets/snd/start_level.mp3',
  })
end

require("sugarcoat/sugarcoat")
sugar.utility.using_package(sugar.S, true)
tween = require 'lib/tween'
require("common")
require("init")
require("update")
require("draw")
require("sprinklez")



function love.load()
  init_game()
end

function love.update(dt)
  update_game(dt)
end

function love.draw()
  draw_game()
end