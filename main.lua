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
  
   • @egordorichev for imput icons
    https://egordorichev.itch.io/key-set

]]


if CASTLE_PREFETCH then
  CASTLE_PREFETCH({
    'common.lua',
    'draw.lua',
    'init.lua',
    'main.lua',
    'storage.lua',
    'update.lua',
    'sugarcoat/sugarcoat.lua',
    'sprinklez.lua',
    'assets/Hungry.ttf',
    'assets/spritesheet.png',
    'assets/title-text.png',
    -- 'assets/splash.png',
    -- 'assets/controls.gif',
    'assets/snd/ambience.mp3',
    'assets/snd/chomp.mp3',
    'assets/snd/death.mp3',
    'assets/snd/gameover.mp3',
    'assets/snd/jump.mp3',
    'assets/snd/roar.mp3',
    'assets/snd/roar2.mp3',
    'assets/snd/success.mp3',
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