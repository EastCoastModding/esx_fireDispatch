------------------------------           ------------------------------
------------------------------ Variables ------------------------------
------------------------------           ------------------------------

local fireHornLocation = {
  { x = 216.85, y = -1648.05, z = 30.72, name = "Davis Station"},
  { x = 1194.27, y = -1464.01, z = 36.65, name = "El Burro Station"},
  { x = -634.79, y = -124.02, z = 39.01, name = "Rockford Hills Station"},
}

local fireSpawnLocation = {
  { x = 1161.0, y = -1452.53, z = 34.72, name = "El Burro Station", id = 1, isFuel = false}, --fire // id = type of fire
}

------------------------------          ------------------------------
------------------------------ Dispatch ------------------------------
------------------------------          ------------------------------

RegisterNetEvent("triggerSound")
AddEventHandler("triggerSound", function()
  --ShowNotification("You have triggered the ~r~alarm~w~!")
  local plX, plY, plZ = table.unpack(GetEntityCoords(GetPlayerPed(-1), true)) --Gets player XYZ
  local nearestStation

  for i = 1, #fireHornLocation, 1 do
    --ShowNotification(fireHornLocation[i].name.." responding!")

    local distDiff = Vdist(plX, plY, plZ, fireHornLocation[i].x, fireHornLocation[i].y, fireHornLocation[i].z) --Gets distance between player and firestation[i]
    local nearestStationDiff

    if nearestStation == nil then --if there is no nearest station yet (first run) then...
      nearestStation = i
      nearestStationDiff = Vdist(plX, plY, plZ, fireHornLocation[i].x, fireHornLocation[i].y, fireHornLocation[i].z) --Gets distance between player and firestation[i]
    else -- if there already a value attached to "nearestStation"
      nearestStationDiff = Vdist(plX, plY, plZ, fireHornLocation[nearestStation].x, fireHornLocation[nearestStation].y, fireHornLocation[nearestStation].z) --Gets distance between player and nearest station so far
    end

    if distDiff <= nearestStationDiff then -- if new station is the closest yet
      nearestStation = i -- assign new closest station
      print(nearestStation)
    end
  end


  ---- PLAYING THE SOUND IN A RYTHM
  for i = 1, 10, 1 do -- repeat to make it sound like an alarm
    for i = 1, 10, 1 do -- used to make it louder
      PlaySoundFromCoord(i, "scanner_alarm_os", fireHornLocation[nearestStation].x, fireHornLocation[nearestStation].y, fireHornLocation[nearestStation].z, "dlc_xm_iaa_player_facility_sounds", 1, 500, 0) --Plays sound from nearest station
    end
    Wait(1000)
  end
  Wait(1000)
  for i = 1, 3, 1 do -- repeat to make it sound like an alarm
    for i = 1, 10, 1 do -- used to make it louder
      PlaySoundFromCoord(i, "scanner_alarm_os", fireHornLocation[nearestStation].x, fireHornLocation[nearestStation].y, fireHornLocation[nearestStation].z, "dlc_xm_iaa_player_facility_sounds", 1, 500, 0) --Plays sound from nearest station
    end
    Wait(2000)
  end
end)

------------------------------      ------------------------------
------------------------------ Fire ------------------------------
------------------------------      ------------------------------
RegisterCommand("startFire", function(source, args, rawCommand)
  TriggerServerEvent("potato:syncFire", source); -- syncs fire
end, false)

RegisterNetEvent("syncCallback")
AddEventHandler("syncCallback", function()
  local i = math.random(#fireSpawnLocation) -- Choses a random spawn location

  -- Used for calls wich a vehicle:
  local model = GetHashKey("buccaneer") -- Get car's hash
  RequestModel(model) -- Car spawing stuff
  
  -- Stuff to avoid crash
	while not HasModelLoaded(model) do
		Citizen.Wait(0)
  end
  
  if not HasNamedPtfxAssetLoaded("core") then
    RequestNamedPtfxAsset("core")
      while not HasNamedPtfxAssetLoaded("core") do
        Wait(1)
      end
  end
  SetPtfxAssetNextCall("core")

  if(fireSpawnLocation[i].id == 0) then
    CreateVehicle(model,fireSpawnLocation[i].x, fireSpawnLocation[i].y, fireSpawnLocation[i].z, 0.0, true, false)--Spawns vehicle
    StartScriptFire(fireSpawnLocation[i].x, fireSpawnLocation[i].y+1.5, fireSpawnLocation[i].z-1, 25, fireSpawnLocation[i].isFuel) --spawn fire
  else
    StartScriptFire(fireSpawnLocation[i].x, fireSpawnLocation[i].y, fireSpawnLocation[i].z-1, 25, fireSpawnLocation[i].isFuel) --spawn fire
    
    local rmd = math.random(1000) -- Gets random number between 1 and 1000
    if rmd <= 500 then
      print("debug1 = " .. rmd)
      StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_h_fire", fireSpawnLocation[i].x, fireSpawnLocation[i].y, fireSpawnLocation[i].z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)  
    else
      print("debug2 = " .. rmd)
      StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", fireSpawnLocation[i].x, fireSpawnLocation[i].y, fireSpawnLocation[i].z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)  
    end
  end
end)


-- Handeling spreading of fires
Citizen.CreateThread(function()
  --[[
    while true do -- all the time do:
    Wait(10000) -- 10 seconds?
    for y = -4000, 8000, 1 do
      Wait(1)
      print("checking Y=" .. y)
      for x = -3900, 6000, 1 do
        print("checking X=" .. x)

        local firePos = GetClosestFirePos(x, y, 0)
        print("firePos = " .. firePos)
        local rmd = math.random(3) -- Gets random number between 1 and 3

        if firePos ~= 1 then
          if Vdist(firePos.x, firePos.y, firePos.z, x, y, firePos.z) <= 2 then -- Makes sure we are not doubling a fire at the oposite side of the map

            if rmd == 1 then
            print("nothing is hapenning")
            elseif rmd == 2 then
            print("duplicating fire choice X")
            
            local rmdX = math.random(5,10)
            StartScriptFire(firePos.x+rmdX, firePos.y, firePos.z, 25, false) --spawn fire
      
            local rmd = math.random(1000) -- Gets random number between 1 and 1000
            if rmd <= 500 then
              print("debug1 = " .. rmd)
              StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_h_fire", firePos.x+rmdX, firePos.y, firePos.z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)  
            else
              print("debug2 = " .. rmd)
              StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", firePos.x+rmdX, firePos.y, firePos.z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)  
            end

            else
            print("duplicating fire choice Y")

            local rmdY = math.random(5,10)
            StartScriptFire(firePos.x+rmdX, firePos.y, firePos.z, 25, false) --spawn fire
      
            local rmd = math.random(1000) -- Gets random number between 1 and 1000
            if rmd <= 500 then
              print("debug1 = " .. rmd)
              StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_h_fire", firePos.x, firePos.y+rmdY, firePos.z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)  
            else
              print("debug2 = " .. rmd)
              StartParticleFxLoopedAtCoord("ent_ray_heli_aprtmnt_l_fire", firePos.x, firePos.y+rmdY, firePos.z-0.7, 0.0, 0.0, 0.0, 1.0, false, false, false, false)  
            end
            end
          else
            print("Exiting if loop of death")
          end
        end
      end
    end
  end
  --]]

  -- Stuff for particles
  if not HasNamedPtfxAssetLoaded("core") then
    RequestNamedPtfxAsset("core")
    while not HasNamedPtfxAssetLoaded("core") do
      Wait(1)
    end
  end

end)

------------------------------                    ------------------------------
------------------------------ Seperate functions ------------------------------
------------------------------                    ------------------------------

function ShowNotification(text)
  SetNotificationTextEntry("STRING")
  AddTextComponentString(text)
  DrawNotification(0,1)
end