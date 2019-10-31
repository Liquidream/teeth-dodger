
-- Simple wrapper around Castle's storage API
-- https://castle.games/documentation/storage-api-reference

local storage = {}

-- --------------------------------------------------------
-- USER STORAGE
-- --------------------------------------------------------

-- Get "User" storage value for given key
-- (or use the default value specified)
storage.getUserValue = function(key,default,func_callback)
  -- set the default while we wait for response
  storage[key] = default

  network.async(function()
    local retValue = castle.storage.get(key)
    log("getUserValue["..key.."]:"..tostring(retValue))
    -- store the final setting (or default if none found)
    storage[key] = retValue or default
    -- run callback?
    if func_callback then
      func_callback()
    end
  end)
end

-- Set "User" storage value (if null passed - key will be deleted)
storage.setUserValue = function(key,value,func_callback)
  log("setUserValue["..key.."]:"..tostring(value))
    network.async(function()
      castle.storage.set(key, value)
      -- run callback?
      if func_callback then
        func_callback()
      end
    end)
end

-- Save all "User" values to Castle 
-- (helpful if been using the storage table directly to update values)
storage.saveUserValues = function(func_callback)
  log("saveUserValues()...")
  network.async(function()
    for key,value in pairs(storage) do
      -- skip functions
      if type(value) ~= "function" then
        castle.storage.set(key, value)
      end
    end
    -- run callback?
    if func_callback then
      func_callback()
    end
  end)
end

-- --------------------------------------------------------
-- GLOBAL STORAGE
-- --------------------------------------------------------

-- Get "Global" storage value for given key
-- (or use the default value specified)
storage.getGlobalValue = function(key,default,func_callback)  
  -- set the default while we wait for response
  storage[key] = default

  network.async(function()
    local retValue = castle.storage.getGlobal(key) or default
    log("getGlobalValue["..key.."]:"..tostring(retValue))
    -- store the final setting (or default if none found)
    storage[key] = retValue
    -- run callback?
    if func_callback then
      func_callback(retValue)
    end
  end)
end

-- Set "Global" storage value (if null passed - key will be deleted)
storage.setGlobalValue = function(key,value)
  log("setGlobalValue["..key.."]:"..tostring(value))
  network.async(function()
    castle.storage.setGlobal(key, value)
  end)
end


return storage