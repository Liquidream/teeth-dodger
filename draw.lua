
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
  -- printp(
  --   0x1000, 
  --   0x2000, 
  --   0x0, 
  --   0x0)
  printp_color(47, 0, 0, 0)

  if gameState == GAME_STATE.SPLASH then
    -- todo: splash screen
    drawSplash()

  elseif gameState == GAME_STATE.COMPLETED then
    draw_level(61)
    -- draw congrats!
    pprintc("CONGRATULATIONS", 8, 9,29)
    pprintc("YOU COMPLETED", 24, 47,29)
    pprintc("THE GAME!", 34, 47,29)    
    local myScore = globalHighScores[my_id]
    if myScore then
      pprint("TIME = "..formatTime(myScore.time), 16,51, 45,29)
      pprint("DEATHS = "..myScore.deaths, 16,61, 38,29)
    end
    pprint("DON'T FORGET TO", 1,80, 17,29)
    pprint("SHARE YOUR SCORE", -2,90, 17,29)
  
  else
  --   -- normal play (level intro/outro/game-over)    
    draw_level()
  end

  
  --circfill(x, y, 4 + 2 * cos(t()), 3)
end

function draw_level(num)
  local levelNum = num or storage.currLevel

  use_font("main-font")

  -- draw mouths/teeth
  for i=#mouths,1,-1 do
    draw_mouth(mouths[i], i)
  end

 
  --pprint("TODO: Everything!", 30,50, 18,29)

end

function draw_player(x,y)  
  pal()
  palt(0, false)

  if surface_exists("photo") then
    -- draw bg frame in player's colour
    rectfill(x-1, y-1, x+player.size, y+player.size, 4)
    -- draw the actual photo
    spritesheet("photo")
    local w,h = surface_size("photo")
    sspr(0, 0, w, h, x, y, player.size, player.size)
  end

  palt()
end


function draw_mouth(mouth, layer)
  local mw=463 --703
  local mh=223 --479
  local level = mouth.level
  --log("level = "..tostring(level))

  pal()
  local t_cols = {
  [0]={ 47 },
    { 47 },
    { 12 },
    { 41 },
    { 0 }
  }

  
  local num_teeth = 8
  local gap = 8  
  local mwidth = GAME_WIDTH - 100  -- mouth width (at 100%)
  local mheight = GAME_HEIGHT - 50 -- (same, height-wise)
  local mheight_curr = (mheight-mouth.openAmount)/level
  local twidth = ((mwidth-(gap*num_teeth))/num_teeth)/level
  local theight = mheight / 2    
  local col_type = flr(level)
  local ttop = (60-mouth.openAmount)/level + (GAME_HEIGHT/2 - mheight/level/2)
  local tbottom = (mheight - (60-mouth.openAmount))/level + (GAME_HEIGHT/2 - mheight/level/2)
  local tleft = gap/2 + (GAME_WIDTH/2 - mwidth/level/2)
  local tright = tleft+mwidth/level - gap


  local t2 = _t+level*10
  local offx = sin(t2/100)*2/level
  local offy = sin(t2/80)*2/level

  
  -- draw UPPER teeth
  for t_idx = 1,#mouth.upperTeeth do    
    local tooth = mouth.upperTeeth[t_idx]
    local tx = offx+ (t_idx-1)*twidth + gap/2 + (t_idx-1)*gap  
    + (GAME_WIDTH/2 - mwidth/level/2)
    local ty = offy+ (60-mouth.openAmount)/level + (GAME_HEIGHT/2 - mheight/level/2)
    -- draw tooth
    --if DEBUG_MODE then rect(tx,ty, tx+twidth, ty+(10*5)/level, 8) end
    rectfill(tx,ty, tx+twidth, ty+((theight/10)*tooth.height)/level, tooth.gap and 14 or t_cols[col_type][1] )
    rect(tx,ty, tx+twidth, ty+((theight/10)*tooth.height)/level, 0)
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
    rectfill(tx,ty, tx+twidth, curr_ttop, tooth.gap and 14 or t_cols[col_type][1] )
    rect(tx,ty, tx+twidth, curr_ttop, 0)

    
    -- draw player? (only on closest mouth)
    if layer == 1 and player.t_index == t_idx then
      draw_player(tx+6, curr_ttop-player.size)
    end
    
  end
  
  -- draw mouth/teeth outline
  if DEBUG_MODE then rect(tleft,ttop, tright, tbottom, 7) end

  
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
  local dw = (mw-50)/level + cos(t2/100)*10/level
  local dh = (mh-95)/level + sin(t2/100)*10/level
  
  local mleft = GAME_WIDTH/2-dw/2 + offx
  local mtop = ttop + sin(t2/100)*2/level +(3/level)
  local mright = mleft + dw -2
  local mbottom = mtop + dh -2
  local mheight_spr = tbottom-ttop



  rectfill(0,0,GAME_WIDTH,mtop,m_cols[col_type][1])
  rectfill(0,0,mleft,mtop+mheight_spr,m_cols[col_type][1])
  rectfill(mright,0,GAME_WIDTH,mtop+mheight_spr,m_cols[col_type][1])
  rectfill(0, mtop+mheight_spr-1, GAME_WIDTH, GAME_HEIGHT, m_cols[col_type][1])  

  spritesheet("spritesheet")  

  pal(38, m_cols[col_type][1])

  sspr(0,0, mw,mh, 
          mleft,
          mtop, 
          dw,mheight_spr)  
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