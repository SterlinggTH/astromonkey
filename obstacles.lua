local storyboard = require "storyboard"
local CBE = require "CBEffects.Library"
local gamevars = require "gamevars"

local obstacles = {}

local random = math.random
local asteroidSheetOptions = {width = 18, height = 18, numFrames = 16, sheetContentWidth = 288, sheetContentHeight = 18}
local powerupSheetOptions = {width = 36, height = 36, numFrames = 5, sheetContentWidth = 180, sheetContentHeight = 36}

obstacles.asteroidSheet = graphics.newImageSheet("images/asteroids.png", asteroidSheetOptions)
obstacles.powerupSheet = graphics.newImageSheet("images/powerups.png", powerupSheetOptions)
obstacles.objectList = {}

function obstacles.createObstacle(obLength, pos, speed)
	local obstacle = display.newGroup()
	for i=1, obLength do
		local part = display.newImageRect(obstacles.asteroidSheet, random(1,16), 18, 18)
		part.x = gamevars.objectSize/2*(i-1); part.y = 0
		obstacle:insert(part)
	end
	obstacle.x = pos; obstacle.y = gamevars.scoreboardHeight-gamevars.objectSize/2
	obstacle.type = "obstacle"
	gamevars.maingroup:insert(obstacle)
	
	local shape={0, 0, gamevars.objectSize/2*obLength, 0, gamevars.objectSize/2*obLength, gamevars.objectSize/2, 0, gamevars.objectSize/2}
	physics.addBody(obstacle, "dynamic", {friction=0, bounce=0, shape=shape, isSensor=true, filter={categoryBits = 2, maskBits = 5}})
	obstacle:setLinearVelocity(0, speed)
	obstacle:addEventListener("collision", obstacles.obstacleCollision)
	table.insert(obstacles.objectList, obstacle)
end

function obstacles.createItem(t, frame, pos, speed)
	local item = display.newImageRect(obstacles.powerupSheet, frame, 36, 36)
	item.x = pos; item.y = gamevars.scoreboardHeight-gamevars.objectSize
	item.type = t
	gamevars.maingroup:insert(item)
	obstacles.setup(item, speed, t=="bananas")
end

function obstacles.setup(object, speed, spin)
	physics.addBody(object, "dynamic", {friction=0, bounce=0, isSensor=true, filter={categoryBits = 2, maskBits = 5}})
	object:setLinearVelocity(0, speed)
	if(spin) then 
		local a = {random(-135,-45), random(45,135)}
		object.angularVelocity = a[random(1,2)]
	 end
	object:addEventListener("collision", obstacles.obstacleCollision)
	table.insert(obstacles.objectList, object)
end

function obstacles.bananasAction(object)
	if(data.settings.soundsEnabled == 1) then
		audio.play(gamevars.soundTable["bananaSound"])
	end
	obstacles.removeFromObstacles(object)
	gamevars.bananas = gamevars.bananas+1
	gamevars.bananasDisplay.text = gamevars.bananas
end

function obstacles.shieldAction(object)
	gamevars.shieldSpawned = false
	if(data.settings.soundsEnabled == 1) then
		audio.play(gamevars.soundTable["shieldSound"])
	end
	obstacles.removeFromObstacles(object)
	gamevars.hasShield = true
	gamevars.timerStatus["shield"] = "running"
end

function obstacles.slowAction(object)
	gamevars.slowSpawned = false
	if(data.settings.soundsEnabled == 1) then
		audio.play(gamevars.soundTable["slowSound"])
	end
	obstacles.removeFromObstacles(object)
	gamevars.slowMo = true
	for k in pairs(obstacles.objectList) do
		--print("slowed down " .. obstacles.objectList[k].type)
		local vx, vy = obstacles.objectList[k]:getLinearVelocity()
		obstacles.objectList[k]:setLinearVelocity(vx, vy/2)
	end
	local function speedUp()
		if(data.settings.soundsEnabled == 1) then
			audio.play(gamevars.soundTable["speedupSound"])
		end
		gamevars.timerStatus["slow"] = "nil"
		gamevars.slowMo = false
		for k in pairs(obstacles.objectList) do
			local vx, vy = obstacles.objectList[k]:getLinearVelocity()
			obstacles.objectList[k]:setLinearVelocity(vx, vy*2)
		end
	end
	local time = 4000
	if(data.settings.slowMoUpgrade == 1) then
		time = time*2
	end
	gamevars.slowTimer = timer.performWithDelay(time, speedUp)
	gamevars.timerStatus["slow"] = "running"
end


function obstacles.activateBomb()
	if(data.settings.soundsEnabled == 1) then
		audio.play(gamevars.soundTable["bombSound"])
	end
	gamevars.exploding = true
	storyboard.showOverlay("trigger")
	local explosion = CBE.newVent {
		preset="flame",
		positionType = "atPoint",
		emitDelay = 50, 
		perEmit = 5, 
		outTime = 500,
		color={{1, .7843, 0}, {1,.6863,0}, {1, .5882, 0}, {1,.4902,0}, {1, .3922, 0}, {1,.2941,0}, {1, .1961, 0}},
		physics = {velocity = 4, angles={{0, 360}}},
		parentGroup = gamevars.maingroup
	}
	explosion:start()
	
	data.settings.bombs = data.settings.bombs - 1
	data.saveData()
	if(data.settings.bombs == 0) then
		gamevars.bombButton:setSequence("none")
		gamevars.bombButton:removeEventListener("tap", obstacles.activateBomb)
	end
	
	for k in pairs(obstacles.objectList) do
		obstacles.objectList[k]:removeSelf()
		obstacles.objectList[k] = nil
	end
	obstacles.objectList = {}
	
	timer.performWithDelay(1000, function()
		explosion:stop()
		timer.performWithDelay(2000, function() 
			explosion:destroy()
			explosion=nil
			storyboard.hideOverlay()
			gamevars.exploding = false
			if(gamevars.timerStatus["spawn"] == "nil") then
				obstacles.spawnALevel()
			end
		 end)
	end)
end

function obstacles.spawnALevel()
	gamevars.level = gamevars.level + 1
	local numberOfRows = 6 + gamevars.level*2
	local randomFactor = .1
	local obstacleSeparation = 500
	
	local minReactionTime = 450
	local maxReactionTime = 850
	local halfDifflevel = 5 --not really half if slowDiffChange isn't 1
	local slowDiffChange = 1
	local delay = minReactionTime + (maxReactionTime - minReactionTime) / (1 + math.exp(gamevars.level / slowDiffChange - halfDifflevel))
	
	local minLength = math.min(math.max(2, gamevars.level), 5)
	local maxLength = math.min(gamevars.level*2, 10)
	--print("level: " .. gamevars.level)
	--print("delay: " .. delay)
	--print("minLength: " .. minLength)
	--print("maxLength: " .. maxLength)
	
	local count = 0
	local function spawn()
		gamevars.timerStatus["spawn"] = "nil"
		count = count + 1
		local slowMoMod = gamevars.slowMo and 2 or 1
		local speed = (3*_W/2-gamevars.scoreboardHeight) * obstacleSeparation / (slowMoMod*delay)

		if(random(5)==5) then
			local leftLength = random(maxLength+1)
			local rightLength = maxLength+2 - leftLength
			--print("Left " .. leftLength .. " Right " .. rightLength)
			obstacles.createObstacle(leftLength, 0, speed)
			obstacles.createObstacle(rightLength, _W-gamevars.objectSize/2*rightLength, speed)
		else
			local obLength = random(minLength, maxLength)
			local pos = random(0, _W-gamevars.objectSize/2*obLength)
			obstacles.createObstacle(obLength, pos, speed)
		end

		if(count < numberOfRows)then
		    local d = random(slowMoMod*delay*(1-randomFactor), slowMoMod*delay*(1+randomFactor))
		    gamevars.spawnTimer = timer.performWithDelay(d, spawn)
			gamevars.timerStatus["spawn"] = "running"
		end
	end
	
	local function spawnOther()
		gamevars.timerStatus["otherSpawn"] = "nil"
		if(count < numberOfRows)then
			local slowMoMod = gamevars.slowMo and 2 or 1
			local speed = (random(50, 75)/100) * (_H-gamevars.scoreboardHeight) * obstacleSeparation / (slowMoMod*delay)
			
			local pos = random(0, _W-gamevars.objectSize)
			
			local multiplier = 1;
			if(data.settings.x3Enabled == 1) then
				multiplier = .25;
			elseif(data.settings.x2Enabled == 1) then
				multiplier = .5;
			end
			
			local objType = random(6*(1/multiplier))
			if(data.settings.slowMoEnabled == 1 and objType == 4 and not(gamevars.slowMo) and not(gamevars.slowSpawned)) then
				obstacles.createItem("slow", objType, pos, speed)
				gamevars.slowSpawned = true
			elseif(data.settings.shieldEnabled == 1 and objType == 3 and not(gamevars.hasShield) and not (gamevars.shieldSpawned)) then
				obstacles.createItem("shield", objType, pos, speed)
				gamevars.shieldSpawned = true
			else
				obstacles.createItem("bananas", 1, pos, speed)
			end

			local d = random(slowMoMod*delay*3 * multiplier, slowMoMod*delay*4 * multiplier)
			gamevars.otherSpawnTimer = timer.performWithDelay(d, spawnOther)
			gamevars.timerStatus["otherSpawn"] = "running"
		end
	end
	
	gamevars.spawnTimer = timer.performWithDelay(0, spawn)
	gamevars.timerStatus["spawn"] = "running"
	gamevars.otherSpawnTimer = timer.performWithDelay(1000, spawnOther)
	gamevars.timerStatus["otherSpawn"] = "running"
end

function obstacles.removeFromObstacles(object)
	for k in pairs(obstacles.objectList) do
		if(obstacles.objectList[k] == object) then
			table.remove(obstacles.objectList, k)
			break;
		end
	end
	object:removeSelf()
	object=nil
	if(#obstacles.objectList == 0) then
		obstacles.spawnALevel()
	end
end

function obstacles.obstacleCollision(event)
	if(event.phase == "began") then
		if(event.other.type == "bottomWall") then
			if(event.target.type == "slow") then
				gamevars.slowSpawned = false
			elseif(event.target.type == "shield") then
				gamevars.shieldSpawned = false
			end
			obstacles.removeFromObstacles(event.target)
		end
	end
end

return obstacles