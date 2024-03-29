
-- draw intro splash screen
function drawSplash()
  cls()
  if duration then
    local offset = math.sin(duration)*2
    fade(max(14-(offset-1.1)*25,0))
    -- title logo
    if surface_exists("splash") then
        local w,h = surface_size("splash")
        spr_sheet("splash", flr(GAME_WIDTH/2-w/2), flr(GAME_HEIGHT/2-h/2))
    end
  end
end

-- draw the actual game 
-- (including the title screen)
function draw_game()
  cls() --5
  
  -- set default pprint style
  printp(
    0x2220, 
    0x2120, 
    0x2220, 
    0x0)
  printp_color(47, 0, 0, 0)

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen
    drawSplash()

  elseif gameState == GAME_STATE.TITLE then
    -- todo: title screen
    draw_level()

    palt()
    palt(0,false)
    palt(35,true)
    spr_sheet("title", 90, title.logo_ypos) 
    set_default_pal()
    
    -- title 
    use_font("main-font") 
    if (_t%100 < 50) then
      pprint("PRESS   OR   TO START", 105, title.prompt_ypos, 9,4)
      spritesheet("keys")
      aspr(0, 188, title.prompt_ypos+5, 1,1,1,0,0, 2,2)
      aspr(1, 258, title.prompt_ypos+5, 1,1,1,0,0, 2,2)
    end
    
    spritesheet("spritesheet")

    -- high score table?
    local scoreTime = game_time%1200
    if scoreTime > 150 and scoreTime < 950 then
      draw_highscore()
    end

    --if title.show_credit then
      use_font("small-font")
      pprint("BY PAUL NICHOLAS ", 195, 250, 47,4)
    --end
  else
    -- normal play (level intro/outro/game-over)    
    draw_level()

    -- lives, etc.
    pprint("MOUTHS: "..player.score, 2, -5, 9,4)
    pprint("LIVES: "..player.lives, 390,-5, 9,4)

    if player.lives == 0 then
      
      if gameState == GAME_STATE.GAME_OVER 
       and game_time - gameEndTime > 4*60 then
        draw_highscore()
      else
        pprint("GAME OVER", 195,120, 35,4)
      end

      use_font("main-font") 
      if (_t%100 < 50) then
        pprint("PRESS   OR   TO START", 105, title.prompt_ypos, 9,4)
        spritesheet("keys")
        aspr(0, 188, title.prompt_ypos+5, 1,1,1,0,0, 2,2)
        aspr(1, 258, title.prompt_ypos+5, 1,1,1,0,0, 2,2)
      end
      
      --if (_t%100 < 50) then
        use_font("small-font")  
        pprint("(DON'T FORGET TO SHARE YOUR SCORE) ", 140, 270, 47,4)
      --end
    end
  end

end

function draw_highscore()
  pprint("MOST MOUTHS", 175,75, 35,4)
  use_font("small-font")
  for i=1,10 do
    local scoreData = title.orderedHighScores[i]
    local scoreYPos = 90+(i*12)
    if scoreData then
      pprint(scoreData.score, 195, scoreYPos, 47,4)
      pprint(string.upper(scoreData.name), 235, scoreYPos, 47,4)
    end
  end
end

function draw_level()
  local levelNum = num or storage.currLevel

  use_font("main-font")

  -- draw mouths/teeth
  for i=#mouths-1,1,-1 do
    draw_mouth(mouths[i], i)
  end

end

function draw_player(player,dw,dh)    
  local x = player.x
  local y = player.y+3

  pal()
  palt(0, false)

  if surface_exists("photo") then
    -- draw bg frame in player's colour
    rectfill(x-1, y-1, x+dw, y+dh, 4)
    -- draw the actual photo
    spritesheet("photo")
    local w,h = surface_size("photo")
    sspr(0, 0, w, h, x, y, dw, dh)
  end

  palt()
end

function set_default_pal()
  pal() 
  palt()
  palt(0, false)
  palt(9, true)
end


function draw_mouth(mouth, layer)
  local mw=463
  local mh=223
  local level = mouth.level

  local t_cols = {
  [0]={ 47 },
    { 47 },
    { 12 },
    { 41 },
    { 0 }
  }
  
  local tSprites={88,91,94,210} 

  local num_teeth = 8
  local gap = 2  
  local mwidth = GAME_WIDTH - 100  -- mouth width (at 100%)
  local mheight = GAME_HEIGHT - 48 -- (same, height-wise)
  local mheight_curr = (mheight-mouth.openAmount)/level
  local twidth = ((mwidth-(gap*num_teeth))/num_teeth)/level  
  local theight = mheight / 2    
  local level_mid = flr(layer+0.5)
  local col_type = level_mid --flr(level)
  local ttop = (60-mouth.openAmount)/level + (GAME_HEIGHT/2 - mheight/level/2)
  local tbottom = (mheight - (60-mouth.openAmount))/level + (GAME_HEIGHT/2 - mheight/level/2)
  local tleft = gap/2 + (GAME_WIDTH/2 - mwidth/level/2)
  local tright = tleft+mwidth/level - gap


  local t2 = _t+level*10
  local offx = sin(t2/100)*2/level
  local offy = sin(t2/80)*2/level


  spritesheet("spritesheet")
  set_default_pal()

  -- capture orig width (only first time)
  if mouth.origWidth == nil then 
    mouth.origWidth = twidth
  end

  local sNum=tSprites[level_mid]
  local scale = 1/mouth.level

  -- draw UPPER teeth
  for t_idx = 1,#mouth.upperTeeth do
    local tooth = mouth.upperTeeth[t_idx]
    local tx = offx+ (t_idx-1)*twidth + gap/2 + (t_idx-1)*gap  
    + (GAME_WIDTH/2 - mwidth/level/2)
    local ty = offy+ (60-mouth.openAmount)/level + (GAME_HEIGHT/2 - mheight/level/2)
    local curr_ttop = ty+((theight/10)*tooth.height)/level
    -- draw tooth
    --if DEBUG_MODE then rect(tx,ty, tx+twidth, ty+(10*5)/level, 8) end
    
    
    aspr(sNum+(tooth.blood and 9 or 0)+12, 
        tx, (8*-16)*scale+curr_ttop,
        0, 
        3,8, 
        0,0, 
        scale,scale)

    -- rectfill(tx,0, tx+twidth, ty+((theight/10)*tooth.height)/level, t_cols[col_type][1] )
    if DEBUG_MODE then rect(tx,0, tx+twidth, ty+((theight/10)*tooth.height)/level, 7) end
  end
  -- draw LOWER teeth
  for t_idx = 1,#mouth.lowerTeeth do    
    local tooth = mouth.lowerTeeth[t_idx]
    local tx = offx+ (t_idx-1)*twidth + gap/2 + (t_idx-1)*gap  
    + (GAME_WIDTH/2 - mwidth/level/2)
    local ty = offy+ (mheight - (60-mouth.openAmount))/level + (GAME_HEIGHT/2 - mheight/level/2)
    local curr_ttop = ty-((theight/10)*tooth.height)/level
    -- draw tooth
    --if DEBUG_MODE then rect(tx-1,ty, tx+twidth+1, ty-(10*5)/level, 7) end    
    spritesheet("spritesheet")
    set_default_pal()
    
    aspr(sNum+(tooth.blood and 9 or 0), 
        tx, curr_ttop,
        0, 
        3,8, 
        0,0, 
        scale,scale)

    -- aspr(tSprites[layer].num+(tooth.blood and 7 or 0), 
    --     tx, curr_ttop,
    --     0, 
    --     tSprites[layer].w,tSprites[layer].h, 
    --     0,0, 
    --     scale,scale)

    -- spr(tSprites[layer].num+(tooth.blood and 7 or 0), 
    --    tx, curr_ttop, tSprites[layer].w,tSprites[layer].h)

    -- rectfill(tx,GAME_HEIGHT, tx+twidth, curr_ttop, t_cols[col_type][1] )
    if DEBUG_MODE then rect(tx,GAME_HEIGHT, tx+twidth, curr_ttop, 7) end

    
    -- draw player? (only on closest mouth)
    if layer == 1 
     and player
     and not player.dead
     and player.t_index == t_idx 
    then
      local size_x = player.size/level
      local size_y = size_x
      -- calc if squish player
      if mouth.openAmount <= 15 
       and not mouth.lowerTeeth[player.t_index].gap then
        size_y = mouth.openAmount*2
      end

      player.x = tx+9/level
      player.y = curr_ttop-size_y      
      draw_player(player, size_x, size_y)

    end
    
  end

  -- Draw particle system(s)
  for index, psys in pairs(pSystems) do
    psys:draw()
  end
  
  
  -- -------------------------------
  -- draw mouth/gums
  -- 
  -- change col, based on depth level
  local m_cols = {
    [0]={ 38 },
    { 38 },
    { 39 },
    { 40 },
    { 0 }
  }
  
  -- calc movement pos/scale of mouth/lips  
  local dw = (mw-0)/level + cos(t2/100)*10/level
  local dh = (mh-95)/level + sin(t2/100)*10/level
  
  local mleft = GAME_WIDTH/2-dw/2 + offx
  local mtop = ttop -20 + offy --+ sin(t2/100)*2/level-- +(3/level)
  local mright = mleft + dw -2
  --local mbottom = mtop + dh -2
  local mheight_spr = tbottom-ttop + 40



  rectfill(-1,-1,GAME_WIDTH,mtop,m_cols[col_type][1])
  rectfill(-1,-1,mleft,mtop+mheight_spr,m_cols[col_type][1])
  rectfill(mright,0,GAME_WIDTH+1,mtop+mheight_spr,m_cols[col_type][1])
  rectfill(-1, mtop+mheight_spr-1, GAME_WIDTH+1, GAME_HEIGHT+1, m_cols[col_type][1])  

  spritesheet("spritesheet")
  set_default_pal()

  local sx_off = (flr(max(level_mid,1))-1)*mw + (flr(max(level_mid,1))-1)*1

  sspr(0+sx_off,0, 
        mw,mh, 
        mleft,
        mtop, 
        dw,
        mheight_spr)

  
  -- draw mouth/teeth outline
  --if DEBUG_MODE then rect(tleft,ttop, tright, tbottom, 7) end

end



-- pprint, centered
function pprintc(text, y, col1, col2, col3)
    local letterWidth = 6.5
    pprint(text, GAME_WIDTH/2-((#text+1.5)*letterWidth)/2, y, col1,col2,col3)
end

   
function fade(i)
  for c=0,15 do
      if flr(i+1)>=16 or flr(i+1)<=0 then
          pal(c,0)
      else
          pal(c,fadeBlackTable[c+1][flr(i+1)])
      end
  end
end