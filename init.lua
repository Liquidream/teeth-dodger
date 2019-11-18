
-- globals
_t=0
mouths = {}
pSystems = {} -- all particle systems
tweens = {}
title = {}
mouthCount=1


-- locals
local Sounds = require 'sounds'
local mouthType=1
local mouthTypeCount=1


function init_game()
  init_data()
  init_sugarcoat()  
  load_assets()
  init_input()

  -- show the title
  init_title()
end

function init_title()
  _t=0
  tweens = {}
  player = nil
  gameState = GAME_STATE.TITLE
  use_palette(ak54)
  init_level()
  title = {
    logo_ypos = TITLE_LOGO_NORM_Y,
    prompt_ypos = TITLE_PROMPT_NORM_Y,
    show_credit = true,
    orderedHighScores = {}
  }

  -- Get Global saved data
  refreshGlobalHighScores()
  
  -- start playing the music
  Sounds.music:seek(4,"seconds")
  Sounds.music:play()
end

function createMouth(num)
  srand(mouthCount)

  local widths={48,32,16}

  local mouth = {
    level = num,
    lastLevel = 0,
    openAmount = (num==1) and MHEIGHT_OPEN or (mouthCount%6)*20, --(0-60, at 100% size)
    upperTeeth = {},
    lowerTeeth = {},
    col_type = mouthType,
    frame = (num==1) and 0 or irnd(MMAX_FRAMES),
    dir = 1 -- mouth open close direction
  }
  -- generate UPPER teeth  
  for t=1,8 do
    -- create tooth
    --  > height can ben between 0-4 (opposite tooth must fit or be <, no overlap)
    mouth.upperTeeth[t] = {
      height = irnd(NUM_TEETH)+1,
      --type = irnd(2)
      blood = false
    }
  end
  -- generate LOWER teeth  
  for t=1,8 do
    -- create tooth
    --  > height can ben between 0-4 (opposite tooth must fit or be <, no overlap)
    mouth.lowerTeeth[t] = {
      height = 10 - mouth.upperTeeth[t].height,
      --type = irnd(2),
      gap = false,
      blood = false
    }
  end

  -- now make a GAP in one (or more) in the teeth
  local numGaps = max(1,5-flr(mouthCount/5))
  local gapsMade = 0
  while gapsMade < numGaps do
    local t_idx = irnd(#mouth.lowerTeeth)+1
    -- only create a gap (or another one) if enough "tooth" left
    if mouth.upperTeeth[t_idx].height>2 
     and mouth.lowerTeeth[t_idx].height > 2 
    then
      mouth.upperTeeth[t_idx].height = mouth.upperTeeth[t_idx].height - 1.5
      mouth.lowerTeeth[t_idx].height = mouth.lowerTeeth[t_idx].height - 1.5
      mouth.lowerTeeth[t_idx].gap = true
      gapsMade = gapsMade + 1
    end
  end

  -- next one  
  mouthCount = mouthCount+1
  -- bounce mouthType from 1-3 (e.g. 1,2,3,2,1,2,3...)
  mouthTypeCount = mouthTypeCount % 4
  mouthTypeCount = mouthTypeCount + 1
  mouthType = mouthTypeCount - (mouthTypeCount > 3 and mouthTypeCount % 3 + 1 or 0)
 
  return mouth
end


function init_sugarcoat()
  init_sugar("Teeth-Dodger", GAME_WIDTH, GAME_HEIGHT, GAME_SCALE)
  
  -- start with splash screen palette 
  load_png("splash", "assets/splash.png", palettes.pico8, true)

  --use_palette(ak54)
  load_font ("assets/Hungry.ttf", 32, "main-font", true)
  load_font ("assets/Hungry.ttf", 16, "small-font", true)
  load_png("title", "assets/title-text.png", ak54, true)
  screen_render_stretch(false)
  screen_render_integer_scale(false)
  set_frame_waiting(60)

   -- Get User info  
   me = castle.user.getMe()    
   my_id = me.userId
   my_name = me.username
   -- get photo
   if me.photoUrl then
     load_png("photo", me.photoUrl, ak54) 
   end
   
  -- init splash
  -- gameState = GAME_STATE.SPLASH 
  -- use_palette(palettes.pico8)
  -- splashStartTime = t()
end

function init_data()
  -- ####################################
  -- WARNING: Wipe GLOBAL data!
  -- ####################################
  --storage.setGlobalValue("globalHighScores",{})
  -- ####################################

    --##### temp test data  ##################
    -- globalHighScores={}
    -- globalHighScores[1] = { score = 1, name = "panman" }
    -- globalHighScores[2] = { score = 10, name = "panman22" }
    -- globalHighScores[3] = { score = 2, name = "panman333" }
    -- globalHighScores[4] = { score = 9, name = "panman4444" }
    -- globalHighScores[5] = { score = 3, name = "panman55555" }
    -- globalHighScores[6] = { score = 8, name = "panman666666" }
    -- globalHighScores[7] = { score = 4, name = "panman7777777" }
    -- globalHighScores[8] = { score = 7, name = "panman88888888" }
    -- globalHighScores[9] = { score = 5, name = "panman999999999" }
    -- globalHighScores[10] = { score = 6, name = "panman000000000" }
    -- globalHighScores[11] = { score = 40, name = "panman898989898" }
    -- globalHighScores[12] = { score = 30, name = "panman787877878787" }
    
    -- save global changes
    --storage.setGlobalValue("globalHighScores",globalHighScores)

end

function addTween(tween)
  table.insert( tweens, tween )
end


function refreshGlobalHighScores()
  -- Get Global saved data
  storage.getGlobalValue("globalHighScores", {}, function(retValue) 
    globalHighScores = retValue
    -- debug contents
    for key,playerData in pairs(globalHighScores) do
      log(" > ["..key.."] score="..playerData.score)
    end

    -- this uses an custom sorting function ordering by score descending
    title.orderedHighScores = {}
    local pos = 1
    for key,playerData in spairs(globalHighScores, function(t,a,b) 
      return (t[a].score > (t[b].score))
     end) 
    do
      log("got score "..pos)
      title.orderedHighScores[pos] = playerData
      pos = pos + 1
    end
  end)
end

function init_input()
  -- keyboard & gamepad input
  register_btn(0, 0, {input_id("keyboard", "left"),
                      input_id("keyboard", "a"),
                      input_id("controller_button", "dpleft")})
  register_btn(1, 0, {input_id("keyboard", "right"),
                      input_id("keyboard", "d"),
                      input_id("controller_button", "dpright")})
  register_btn(2, 0, {input_id("keyboard", "up"),
                      input_id("keyboard", "w"),
                      input_id("controller_button", "dpup")})
  register_btn(3, 0, {input_id("keyboard", "down"),
                      input_id("keyboard", "s"),
                      input_id("controller_button", "dpdown")})

  -- mouse input
  register_btn(5,  0, input_id("mouse_position", "x"))
  register_btn(6,  0, input_id("mouse_position", "y"))
  register_btn(7,  0, input_id("mouse_button", "lb"))


end

function init_level()
  -- reset game time
  game_time = 0
  state_time = 0
  mouthCount=1
  speed_factor=0.8

  -- create the initial set of mouths/teeth
  mouths={}
  for i=1,4 do
    local newMouth = createMouth(i)
    mouths[i] = newMouth
  end

  -- Sounds.startLevel:play()
  -- Sounds.music:play()

  log("init_level done.")
end

function init_player()
  player = {
    t_index = 6,  -- which tooth is player standing on (1-x, from left-right)
    x = 30,       -- actual screen pos
    y = 30,
    lives = 3,
    size = 32,
    score = 0,
    moveCount = 0, -- number of moves player has made
    dead = false,
    deathCount = 0
  }
end

function restart_player()
  player.dead = false
end

function init_sounds()
  Sounds.music = Sound:new('ambience.mp3', 1)
  Sounds.music:setVolume(0.75)
  Sounds.music:setLooping(true)

  Sounds.chomps = {}
  Sounds.chomps[1] = Sound:new('chomp.mp3', 3)
  Sounds.chomps[1]:setVolume(0.75)
  Sounds.chomps[2] = Sound:new('chomp.mp3', 3)
  Sounds.chomps[2]:setVolume(0.5)
  Sounds.chomps[3] = Sound:new('chomp.mp3', 3)
  Sounds.chomps[3]:setVolume(0.25)

  Sounds.jump = Sound:new('jump.mp3', 3)
  Sounds.jump:setVolume(0.5)

  Sounds.death = Sound:new('death.mp3', 3)
  Sounds.death:setVolume(1.0)

  Sounds.success = Sound:new('success.mp3', 3)
  Sounds.success:setVolume(0.25)

  Sounds.roars = {}
  Sounds.roars[1] = Sound:new('roar.mp3', 3)
  Sounds.roars[1]:setVolume(0.5)
  Sounds.roars[2] = Sound:new('roar2.mp3', 3)
  Sounds.roars[2]:setVolume(0.5)
end

function load_assets()
  -- load gfx
  load_png("spritesheet", "assets/spritesheet.png", ak54, true)
  spritesheet_grid(16,16)
    
  -- todo: load sfx + music
  init_sounds()
end