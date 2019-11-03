
--
-- Constants
--
DEBUG_MODE = true
GAME_WIDTH = 512  -- 16:9 aspect ratio that fits nicely
GAME_HEIGHT = 288 -- within the default Castle window size
GAME_SCALE = 3
GAME_STATE = { SPLASH=0, TITLE=1, INFO=2, LVL_INTRO=3, LVL_PLAY=4, LVL_END=5, LOSE_LIFE=6, GAME_OVER=7, COMPLETED=8 }

START_LEVEL = 1
MAX_LEVELS = 60

-- particle_cols={
--   [COL_PINK] = {47,35,26,30},
--   [COL_FINISH] = {47,9,8,6},
--   [COL_START] = {47,9,8,6}  -- in Reverse mode
-- }

-- Andrew Kensler (+another black!)
-- https://lospec.com/palette-list/andrew-kensler-54
ak54 = {
    0x000000, 0x05fec1, 0x32af87, 0x387261,  
    0x000000, 0x1c332a, 0x2a5219, 0x2d8430, 
    0x00b716, 0x50fe34, 0xa2d18e, 0x84926c, 
    0xaabab3, 0xcdfff1, 0x05dcdd, 0x499faa, 
    0x2f6d82, 0x3894d7, 0x78cef8, 0xbbc6ec, 
    0x8e8cfd, 0x1f64f4, 0x25477e, 0x72629f, 
    0xa48db5, 0xf5b8f4, 0xdf6ff1, 0xa831ee, 
    0x3610e3, 0x241267, 0x7f2387, 0x471a3a, 
    0x93274e, 0x976877, 0xe57ea3, 0xd5309d, 
    0xdd385a, 0xf28071, 0xee2911, 0x9e281f, 
    0x4e211a, 0x5b5058, 0x5e4d28, 0x7e751a, 
    0xa2af22, 0xe0f53f, 0xfffbc6, 0xffffff, 
    0xdfb9ba, 0xab8c76, 0xeec191, 0xc19029, 
    0xf8cb1a, 0xea7924, 0xa15e30, 0x10082e
    -- custom colours
}

fadeBlackTable={
    {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
    {1,1,1,1,1,1,1,0,0,0,0,0,0,0,0},
    {2,2,2,2,2,2,1,1,1,0,0,0,0,0,0},
    {3,3,3,3,3,3,1,1,1,0,0,0,0,0,0},
    {4,4,4,2,2,2,2,2,1,1,0,0,0,0,0},
    {5,5,5,5,5,1,1,1,1,1,0,0,0,0,0},
    {6,6,13,13,13,13,5,5,5,5,1,1,1,0,0},
    {7,6,6,6,6,13,13,13,5,5,5,1,1,0,0},
    {8,8,8,8,2,2,2,2,2,2,0,0,0,0,0},
    {9,9,9,4,4,4,4,4,4,5,5,0,0,0,0},
    {10,10,9,9,9,4,4,4,5,5,5,5,0,0,0},
    {11,11,11,3,3,3,3,3,3,3,0,0,0,0,0},
    {12,12,12,12,12,3,3,1,1,1,1,1,1,0,0},
    {13,13,13,5,5,5,5,1,1,1,1,1,0,0,0},
    {14,14,14,13,4,4,2,2,2,2,2,1,1,0,0},
    {15,15,6,13,13,13,5,5,5,5,5,1,1,0,0}
}

--
-- Globals (saved values)
--
-- storage is used for all Castle-saved data
storage = require("storage")
-- time game was opened
sessionStartTime = love.timer.getTime()
-- time progress was last "saved"
lastSaveTime = nil
-- global high score table
globalHighScores = nil

-- Other state global vars
levelReady = nil

--
-- Helper Functions
--

-- Re-seed the Random Number Generation
-- so that if called quickly (sub-seconds)
-- it'll still be random
_incSeed=0
function resetRNG()
    _incSeed = _incSeed + 1
    local seed=os.time() + _incSeed
    math.randomseed(seed)
end

function formatTime(timeInSecs)
  local s = timeInSecs * 1000
  local ms = s % 1000
  s = (s - ms) / 1000
  local secs = s % 60
  s = (s - secs) / 60
  local mins = s % 60
  local strTime = mins..":"..(secs<10 and "0" or "")..secs
  --log("formatTime() = "..strTime)
  return strTime
end

function alternate()
  return flr(t())%2 == 0 
end

-- https://stackoverflow.com/a/15706820
function spairs(t, order)
  -- collect the keys
  local keys = {}
  for k in pairs(t) do keys[#keys+1] = k end

  -- if order function given, sort by it by passing the table and keys a, b,
  -- otherwise just sort the keys 
  if order then
      table.sort(keys, function(a,b) return order(t, a, b) end)
  else
      table.sort(keys)
  end

  -- return the iterator function
  local i = 0
  return function()
      i = i + 1
      if keys[i] then
          return keys[i], t[keys[i]]
      end
  end
end