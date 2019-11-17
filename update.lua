local Sounds = require 'sounds'

function updateSplash(dt)
  if splashStartTime then
      duration = t()-splashStartTime 
      if duration > 3.53 then
        -- Now show "Title" level
         init_level()
      end
  end
end

function update_game(dt)
  _t=_t+1

  -- Update all particle systems
  for key, psys in pairs(pSystems) do
    psys:update(dt)

    -- purge old emitters
    if psys._lifecount > 100 then
      --log("purging old pSystem...")
      table.remove(pSystems, key)
    end
  end

  -- Update all tween animations
  for key, tween in pairs(tweens) do
    local complete = tween:update(dt)
    -- purge completed tweens
    if complete then
      table.remove(tweens, key)
    end
  end
  
  ------------------------------
  -- splash screen
  ------------------------------
  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen
    updateSplash(dt)

  ------------------------------
  -- title screen
  ------------------------------
  elseif gameState == GAME_STATE.TITLE then
    --update_player(dt)
    game_time = game_time + 1
    update_mouths(dt, true)
    -- check for press
    if btnp(0) or btnp(0) or btnp(7) then
      gameState = GAME_STATE.LVL_PLAY
      init_player()
      init_level()
    end
    -- transition to highscore table?
    if game_time%1200 == 300 then
      log("TODO: switch to highscore...")
      addTween(
        tween.new(1, title, {logo_ypos = TITLE_LOGO_SCORES_Y}, 'outCirc')
      )
      addTween(
        tween.new(1, title, {prompt_ypos = TITLE_PROMPT_SCORES_Y}, 'outCirc')
      )
      title.show_credit = false
    end
    -- transition back to normal title?
    if game_time%1201 == 1200 then
      log("TODO: switch to normal...")
      addTween(
        tween.new(1, title, {logo_ypos = TITLE_LOGO_NORM_Y}, 'outCirc')
      )
      addTween(
        tween.new(1, title, {prompt_ypos = TITLE_PROMPT_NORM_Y}, 'outCirc')
      )
      title.show_credit = true
    end

  ------------------------------
  -- game play
  ------------------------------
  elseif gameState == GAME_STATE.LVL_PLAY then
    update_player(dt)
    game_time = game_time + 1
    update_mouths(dt, false)      
  
  ------------------------------
  -- game over
  ------------------------------
  elseif gameState == GAME_STATE.GAME_OVER then
    game_time = game_time + 1
    update_mouths(dt, false)
    -- wait for keypress/time-out...
    if btnp(0) or btnp(0) or btnp(7) then
     -- restart game
     gameState = GAME_STATE.LVL_PLAY
     init_player()
     init_level()
  
    -- ...or been 10+ secs?
    elseif game_time - gameEndTime > 10*60 then 
      -- go back to title
      init_title()
    end
  end

end



function update_mouths(dt, autozoom)
  -- update mouths/teeth
  for i=1,3 do
    local mouth = mouths[i]
    
    if autozoom then
      -- constant zoom in
      mouth.level = mouth.level - 0.01
    end
              
    -- open/close all but current mouth

    local inAutoOpenRange = mouth.level<=0.8 and mouth.lastLevel>=0.8

    if i == 1 and not inAutoOpenRange and not autozoom then
      -- front mouth
      if mouth.frame == flr(300*speed_factor) then 
        addTween(
            tween.new(0.5*speed_factor, mouth, {openAmount = MHEIGHT_CLOSED}, 'outCirc')
          )
      end
      if mouth.frame == flr(400*speed_factor) then 
        addTween(
            tween.new(1*speed_factor, mouth, {openAmount = MHEIGHT_OPEN}, 'outBack')
          )
      end

      -- only advance frames if not too close
      if mouth.level > 0.9 then
        mouth.frame = mouth.frame + 1
        mouth.frame = flr(mouth.frame % (500*speed_factor))
      end
    
     else

      if i ~= 1 or not autozoom then        
        -- opening/closing mouth
        if mouth.frame == flr(50*speed_factor) then 
          addTween(
              tween.new(0.5*speed_factor, mouth, {openAmount = MHEIGHT_CLOSED}, 'outCirc')
            )
        end
        --log("2) frm>"..mouths[2].frame)
        if mouth.frame == flr(150*speed_factor) then 
          addTween(
              tween.new(1*speed_factor, mouth, {openAmount = MHEIGHT_OPEN}, 'outBack')
            )
        end
      end

      -- if autozoom, auto-open mouth when close to "camera"
      if inAutoOpenRange then
        addTween(
              tween.new(1*speed_factor, mouth, {openAmount = MHEIGHT_OPEN}, 'outBack')
            )
      end

      mouth.frame = mouth.frame + 1
      mouth.frame = mouth.frame % flr(MMAX_FRAMES*speed_factor)
          
    end

    if player then
      -- check for closed mouth player state
      if i == 1 
      and mouth.openAmount <= 7 -- closed enough to squish player?
      and not mouth.zooming 
      then
        -- check player position (e.g. in a gap?)
        if mouth.lowerTeeth[player.t_index].gap then
          -- player is safe
          player.score = player.score + 1
          -- zoom into next mouth (using tweening!)
          for i=1,3 do
            addTween(
              tween.new(2*speed_factor,  mouths[i], {level= mouths[i].level-1}, 'inOutQuad')
            )
          end
          -- speed up
          speed_factor=speed_factor*0.99
          log("speed_factor = "..speed_factor)
          -- start the next mouth opening
          mouths[2].frame = flr(150*speed_factor)
          log("1) frm>"..mouths[2].frame)
          -- make sure we don't trip this code again
          mouth.zooming = true
        elseif not player.dead then
          killPlayer()
        end
      end

    end

    -- remember...
    mouth.lastLevel = mouth.level

  end -- end loop mouths

  -- time to create new mouth?
  if mouths[1].level <= 0.25 then
    -- first, shift other mouths up
    mouths[1] = mouths[2]
    mouths[1].origWidth = nil
    
    mouths[2] = mouths[3]
    mouths[2].origWidth = nil
    
    -- create a new mouth
    mouths[3] = createMouth(3)
  end
end

function killPlayer()
  player.dead = true
  player.lives = player.lives - 1
  player.deathCount = 100
  player.origDeathCount = player.deathCount

  -- create a new particle system
  local pEmitter = Sprinklez:createSystem(
    player.x, 
    player.y)

  -- set clip bounds
  pEmitter.game_width = GAME_WIDTH + 20 -- add some leway for particles to spawn at edges
  pEmitter.game_height = GAME_HEIGHT + 20

  -- tweak effect for blood splatter 😁🩸
  pEmitter.spread = math.pi*2
  pEmitter.lifetime = 4     -- Only want 1 "burst"
  pEmitter.rate = 150
  pEmitter.acc_min = 30
  pEmitter.acc_max = 100
  pEmitter.max_rnd_start = 30 --21
  pEmitter.cols = particle_cols.COL_BLOOD
  pEmitter.size_min = 1
  pEmitter.size_max = 3
  -- up
  pEmitter.angle = (math.pi/2)*1

  pEmitter.gravity = 7  -- make more of explosion (slow mo)

  -- Add to particle system
  table.insert( pSystems, pEmitter )
end


-- submit player's time/deaths
function submitHighScore()
  -- look for previous time
  local prevScore = globalHighScores[my_id]
  log("prevScore = "..tostring(prevScore))
  if not prevScore 
   or player.score > prevScore.score
  then
    log("player.score = "..player.score)
    if prevScore then
      log("prevScore.score = "..prevScore.score)
    end
    -- Submit THIS score
    local newScore = {
      score = player.score,
      name = my_name,
    }
    -- add/replace player's score
    globalHighScores[my_id] = newScore
        
    -- save global changes
    storage.setGlobalValue("globalHighScores",globalHighScores)
  end
end


function update_player(dt)
  -- handle player control/movement

  -- update mouse/touch state
  local mousePressed = btnp(7) 
  local mx, my = flr(btnv(5)), flr(btnv(6))

  if not player.dead 
   and not mouths[1].zooming then
    -- left
    if btnp(0)
     or (mousePressed and mx < GAME_WIDTH/2) then
      player.t_index = max(player.t_index-1, 1)      
    end
    -- right
    if btnp(1) 
     or (mousePressed and mx >GAME_WIDTH/2)then         
      player.t_index = min(player.t_index+1, NUM_TEETH+1)
    end    
  end

  -- update death count (if there)
  if player.deathCount > 0 then
    player.deathCount = player.deathCount - 1
    -- blood-stain the teeth?
    if player.deathCount == player.origDeathCount-5 then
      mouths[1].upperTeeth[player.t_index].blood = true
      mouths[1].lowerTeeth[player.t_index].blood = true
    end
    -- respawn player?
    if player.deathCount == 0 then
      
      if player.lives > 0 then
        respawn_player()
      else
        -- game over
        gameState = GAME_STATE.GAME_OVER
        gameEndTime = game_time
        -- Submit player's score (if better than prev)        
        submitHighScore()        
      end
    end  
  end

end


function respawn_player()  
  player.dead = false
end


function makeParticles(x, y, col)
  -- create a new particle system
  local pEmitter = Sprinklez:createSystem(x, y)
  -- set clip bounds
  pEmitter.game_width = GAME_WIDTH
  pEmitter.game_height = GAME_HEIGHT
  -- tweak effect for pickup "poof" 
  pEmitter.angle = 23
  pEmitter.spread = 16 --math.pi --180
  pEmitter.lifetime = 1 -- Only want 1 burst
  pEmitter.rate = 15
  pEmitter.acc_min = 3
  pEmitter.acc_max = 7
  pEmitter.size_min = 0
  pEmitter.size_max = 1
  pEmitter.max_rnd_start = 15
  pEmitter.gravity = 0.15
  pEmitter.cols = particle_cols[col] --{47,35,26,30} 

  table.insert( pSystems, pEmitter )
end
