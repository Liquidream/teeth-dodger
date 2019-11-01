
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
  cls()
  
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
  -- todo: read pixel data for level
  spritesheet("spritesheet")  
  use_font("main-font")

  draw_mouth(3, 3)
  draw_mouth(2, 2)
  draw_mouth(1, 1)

 
  pprint("TODO: Everything!", 30,50, 18,29)

end


function draw_mouth(num, level)
  local mw=703
  local mh=479

  pal()

  -- calc pos/scale
  local t2 = _t+level*10
  local dw = mw/level + cos(t2/100)*20/level
  local dh = (mh/level) + sin(t2/100)*20/level
  --local dh = (mh/level)
  --local dh = (mh/level) + sin(t2/100)*100/level
  local offx = sin(t2/100)*2/level
  local offy = sin(t2/80)*2/level

  -- draw teeth
  srand(num)
  local t_cols = {
    { 47 },
    { 12 },
    { 41 }
  }
  local twidth = 32
  local gap = (GAME_WIDTH-twidth*8)/8
  for l=1,2 do
    for t=1,8 do
      local x = offx + t*twidth + (t-1)*gap
      local y = GAME_HEIGHT/2-dh/2 + offy + (mh/level/2-dh/2) + (l==1 and 0 or 80)
      -- draw tooth
      rectfill(x,y, x+twidth, y+twidth*2, t_cols[level][1])
    end
  end

  

  -- change col, based on depth level
  local m_cols = {
    { 38 },
    { 39 },
    { 40 }
  }
  pal(38, m_cols[level][1])

  sspr(0,0, mw,mh, 
      GAME_WIDTH/2-dw/2 + offx,
      GAME_HEIGHT/2-dh/2 + offy, 
      dw,dh)

  --spr(0, -40,-20, 22,15)
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