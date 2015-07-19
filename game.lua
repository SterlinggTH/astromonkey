local storyboard = require "storyboard"
local CBE = require "CBEffects.Library"
local physics = require "physics"
local data = require "data"
local gamevars = require "gamevars"
local obstacles = require "obstacles"
local scene = storyboard.newScene()

local monkey, pauseButton, touchField, buttonSound, xGravities, xInstants

local function cycleSpace()
	gamevars.space.y = _H
	gamevars.space.transition = transition.to(gamevars.space, {time = _H*64, y = _H*(8/3), onComplete = cycleSpace})
end

local function createMonkey()
	monkey = display.newGroup()
	
	local monkeySheetOptions = {width = 58, height = 58, numFrames = 2, sheetContentWidth = 116, sheetContentHeight = 58}
	local monkeySheet = graphics.newImageSheet("images/monkey.png", monkeySheetOptions)
	local body = display.newSprite(monkeySheet, {
		{ name = "noShield", frames = {1} },
		{ name = "shield", frames = {2} },
		{ name = "flicker", frames = {1, 2}, time = 250, loopCount = 4}
	})
	
	--local body = display.newImageRect("images/monkey.png", 48, 48)
	monkey:insert(body)

	local function buildFlame() local size = math.random(125, 150) return display.newImageRect("CBEffects/textures/glow.png", size, size) end
	monkey.burner1 = CBE.newVent {
		x = -1*body.width/18,
		y = body.height/2,
		preset="burn",
		build = buildFlame,
		perEmit = 2,
		scale=.2,
		physics = {angles={{265,275}}, gravityY=.2},
		parentGroup = monkey
	}

	monkey.burner2 =CBE.newVent {
		x = body.width - body.width/2.5,
		y = body.height/2,
		preset="burn",
		build = buildFlame,
		perEmit = 2,
		scale=.2,
		physics = {angles={{265,275}}, gravityY=.2},
		parentGroup = monkey
	}
	monkey.burner1:start()
	monkey.burner2:start()

	monkey.x = _W/2-monkey.width/2; monkey.y = _H*(3/4)
	local shape={_W/32, _H/32, gamevars.objectSize*(4/3), _H/32, gamevars.objectSize*(3/3), gamevars.objectSize*(4/3), _W/32+ gamevars.objectSize*(1/3), gamevars.objectSize*(4/3)}
	physics.addBody(monkey, "dynamic", {friction = 0, bounce = 0, shape=shape, filter = {categoryBits = 1, maskBits = 2}})
	monkey.type = "user"
	gamevars.maingroup:insert(monkey)

	local function monkeyCollision(event)
		if(event.phase == "began")then
			if(event.other.type == "obstacle")then
				if(gamevars.hasShield)then
					if(data.settings.soundsEnabled == 1) then
						audio.play(gamevars.soundTable["hitSound"])
					end
					obstacles.removeFromObstacles(event.other)
				else
					if(data.settings.soundsEnabled == 1) then
						audio.play(gamevars.soundTable["monkeySound"])
					end
					gamevars.gameOver = true
					storyboard.showOverlay("popup", {params = {message = "Game Over", button = "replay"}, isModel = true})
				end
			elseif(event.other.type == "bananas")then
				obstacles.bananasAction(event.other)
			elseif(event.other.type == "shield")then
				monkey[1]:setSequence("shield")
				local time = 4000
				if(data.settings.shieldUpgrade == 1) then
					time = time*2
				end
				gamevars.shieldTimer = timer.performWithDelay(time-1000, function()
					monkey[1]:setSequence("flicker")
					monkey[1]:play()
					gamevars.shieldTimer = timer.performWithDelay(1000, function()
						monkey[1]:setSequence("noShield")
						gamevars.hasShield = false
						gamevars.timerStatus["shield"] = "nil"
						end)
					end)
				obstacles.shieldAction(event.other)
			elseif(event.other.type == "slow")then
				obstacles.slowAction(event.other)
			end
		end
	end
	monkey:addEventListener("collision", monkeyCollision)
end

local function pauseButtonTap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	storyboard.showOverlay("popup", {params = {message = "Paused", button = "resume"}, isModel = true})
end

--[[local function gameTouch(event)
	if(event.phase == "began" or event.phase == "moved")then
		local pos = event.x
		if(pos < 0) then 
			pos = 0
		elseif(pos > _W - monkey[1].width) 
			then pos = _W - monkey[1].width
		end
		monkey.x = pos
	end
end]]

local function movement(event)
	xGravities[3] = xGravities[2]
	xGravities[2] = xGravities[1]
	xGravities[1] = event.xGravity
	local avgxGravity = (xGravities[1] + xGravities[2] + xGravities[3])/3
	
	local pos = _W*.5 - monkey[1].width*.5 + _W*.5 * 4 * (avgxGravity)
	if(pos < 0) then 
		pos = 0
	elseif(pos > _W - monkey[1].width) 
		then pos = _W - monkey[1].width
	end
	
	xInstants[3] = xInstants[2]
	xInstants[2] = xInstants[1]
	xInstants[1] = event.xInstant
	local avgxInstant = (xInstants[1] + xInstants[2] + xInstants[3])/3
	
	monkey.x = pos
	monkey.rotation = 45*avgxInstant
end

local function startGame()
	cycleSpace()
	createMonkey()
	obstacles.spawnALevel()
	local function incScore()
		gamevars.score = gamevars.score+1;
		gamevars.scoreDisplay.text = string.format("Score: %05d", gamevars.score);
	end
	gamevars.scoreTimer = timer.performWithDelay(100, incScore, 0)
	gamevars.timerStatus["score"] = "running"
	if(data.settings.bombs > 0) then
		gamevars.bombButton:addEventListener("tap", obstacles.activateBomb)
	end
	--touchField:addEventListener("touch", gameTouch)
	pauseButton:addEventListener("tap", pauseButtonTap)
	Runtime:addEventListener("accelerometer", movement)
end

function scene:createScene(event)
	--print("game.lua - createScene")
	physics.start()
	local group = self.view
	
	gamevars.interface = display.newGroup()
	gamevars.maingroup = display.newGroup()
	group:insert(gamevars.maingroup)
	group:insert(gamevars.interface)
	
	local scoreboardBackground = display.newImageRect("images/frame_thin.jpg", _W, gamevars.scoreboardHeight)
	scoreboardBackground.anchorX = 0; scoreboardBackground.anchorY = 0
	--scoreboardBackground:setFillColor(.643,.643,.643)
	gamevars.interface:insert(scoreboardBackground)
	
	local banana = display.newImageRect("images/bananas.png", 30, 30)
	banana.anchorX = 0; banana.anchorY = .5
	banana.x = _W/40; banana.y = gamevars.scoreboardHeight/2
	gamevars.interface:insert(banana)

	gamevars.bananasDisplay = display.newText({text = 0, font = "BebasNeue", fontSize = _W/(32/3)})
	gamevars.bananasDisplay.anchorX = 0; gamevars.bananasDisplay.anchorY = .5
	gamevars.bananasDisplay.x = banana.x + banana.width; gamevars.bananasDisplay.y = gamevars.scoreboardHeight/2
	gamevars.bananasDisplay:setFillColor(0,0,0)
	gamevars.interface:insert(gamevars.bananasDisplay)

	gamevars.scoreDisplay = display.newText({text = "Score: 00000", font = "BebasNeue", fontSize = _W/(32/3)})
	gamevars.scoreDisplay.anchorX = .5; gamevars.scoreDisplay.anchorY = .5
	gamevars.scoreDisplay.x = _W/2; gamevars.scoreDisplay.y = gamevars.scoreboardHeight/2
	gamevars.scoreDisplay:setFillColor(0,0,0)
	gamevars.interface:insert(gamevars.scoreDisplay)
	
	pauseButton = display.newImageRect("images/pause.png", 30, 30)
	pauseButton.anchorX = 1; pauseButton.anchorY = .5
	pauseButton.x = _W-_W/80; pauseButton.y = gamevars.scoreboardHeight/2
	gamevars.interface:insert(pauseButton)
	
	touchField = display.newRect(0, gamevars.scoreboardHeight, _W, _H-gamevars.scoreboardHeight)
	touchField.isVisible = false; touchField.isHitTestable = true
	gamevars.interface:insert(touchField)
	
	gamevars.bombButton = display.newSprite(obstacles.powerupSheet, {{ name = "none", frames = {2} }, { name = "bomb", frames = {5} }})
	gamevars.bombButton.anchorX = 0; gamevars.bombButton.anchorY = 1;
	gamevars.bombButton.x = _W/80; gamevars.bombButton.y = _H - _H/120
	gamevars.interface:insert(gamevars.bombButton)
	
	gamevars.highscoreDisplay = display.newText({text = "Highscore: " .. data.settings.highscore, font = "BebasNeue", fontSize = _W/16})
	gamevars.highscoreDisplay.anchorX = 1; gamevars.highscoreDisplay.anchorY = 1;
	gamevars.highscoreDisplay.x = _W-_W/80; gamevars.highscoreDisplay.y = _H
	gamevars.highscoreDisplay.alpha = .5
	gamevars.interface:insert(gamevars.highscoreDisplay)

	local bottomWall = display.newRect(0, _H + gamevars.objectSize, _W, gamevars.wallThickness)
	physics.addBody(bottomWall, "static", {friction = 0, bounce = 0, filter = {categoryBits = 4, maskBits = 2}})
	bottomWall.isVisible = false; bottomWall.isHitTestable = true
	bottomWall.type = "bottomWall"
	gamevars.maingroup:insert(bottomWall)
end

function scene:willEnterScene(event)
	--print("game.lua - willEnterScene")
	gamevars.scoreDisplay.text = string.format("Score: 00000")
	if(data.settings.bombs > 0) then
		gamevars.bombButton:setSequence("bomb")
	end
end

function scene:enterScene(event)
	--print("game.lua - enterScene")
	local group = self.view
	physics.start()
	physics.setGravity(0, 0)
	--physics.setDrawMode("hybrid")
	xGravities = {0, 0, 0}
	xInstants = {0, 0, 0}
	
	gamevars.gameOver = false
	gamevars.score = 0
	gamevars.bananas = 0
	gamevars.level = 0
	gamevars.hasShield = false
	gamevars.slowMo = false
	gamevars.exploding = false
	gamevars.shieldSpawned = false
	gamevars.slowSpawned = false
	obstacles.objectList = {}
	
	gamevars.timerStatus = {}
	gamevars.timerStatus["score"] = "nil"
	gamevars.timerStatus["spawn"] = "nil"
	gamevars.timerStatus["otherSpawn"] = "nil"
	gamevars.timerStatus["slow"] = "nil"
	gamevars.timerStatus["shield"] = "nil"
	
	if(data.settings.soundsEnabled == 1) then
		gamevars.soundTable = {
		    bananaSound = audio.loadSound("audio/banana.wav"),
		    bombSound = audio.loadSound("audio/bomb.wav"),
		    monkeySound = audio.loadSound("audio/monkey.wav"),
		    shieldSound = audio.loadSound("audio/shield.wav"),
			 slowSound = audio.loadSound("audio/slow.wav"),
			 speedupSound = audio.loadSound("audio/speedup.wav"),
			 hitSound = audio.loadSound("audio/hit.wav")
		}
		buttonSound = audio.loadSound("audio/button.wav")
	end

	if(data.settings.musicEnabled == 1) then
		audio.setVolume(.5, {channel=2, loop=-1})
		local backgroundMusic = audio.loadStream("audio/music.mp3")
		audio.play(backgroundMusic, {channel=2})
	end
	
	timer.performWithDelay(500, startGame)
end

function scene:exitScene(event)
	--print("game.lua - exitScene")
	gamevars.space.y = _H
	gamevars.bombButton:setSequence("none")
	gamevars.bananasDisplay.text = 0
	gamevars.highscoreDisplay.text = "Highscore: " .. data.settings.highscore
	
	if(gamevars.timerStatus["score"] ~= "nil") then timer.cancel(gamevars.scoreTimer); gamevars.timerStatus["score"] = "nil"; gamevars.scoreTimer=nil end
	if(gamevars.timerStatus["spawn"] ~= "nil") then timer.cancel(gamevars.spawnTimer); gamevars.timerStatus["spawn"] = "nil"; gamevars.spawnTimer=nil end
	if(gamevars.timerStatus["otherSpawn"] ~= "nil") then timer.cancel(gamevars.otherSpawnTimer); gamevars.timerStatus["otherSpawn"] = "nil"; gamevars.otherSpawnTimer=nil end
	if(gamevars.timerStatus["slow"] ~= "nil") then timer.cancel(gamevars.slowTimer); gamevars.timerStatus["slow"] = "nil" ; gamevars.slowTimer=nil end
	if(gamevars.timerStatus["shield"] ~= "nil") then timer.cancel(gamevars.shieldTimer); gamevars.timerStatus["shield"] = "nil" ; gamevars.shieldTimer=nil end
		
	transition.cancel(gamevars.space.transition)
	gamevars.space.transition = nil
	for k in pairs(obstacles.objectList) do
		obstacles.objectList[k]:removeSelf()
	end
	monkey.burner1:stop();
	monkey.burner2:stop();
	monkey.burner1:destroy()
	monkey.burner2:destroy()
	monkey.burner1 = nil
	monkey.burner2 = nil
	monkey:removeSelf()
	
	if(data.settings.musicEnabled == 1 or data.settings.soundsEnabled == 1) then
		audio.stop()
		if(data.settings.soundsEnabled == 1) then
			for s,v in pairs(gamevars.soundTable) do
			    audio.dispose(gamevars.soundTable[s])
			    gamevars.soundTable[s] = nil
			end
			audio.dispose(buttonSound)
		end

		if(data.settings.musicEnabled == 1) then
			audio.dispose(backgroundMusic)
		end
	end

end

function scene:destroyScene(event)
	--print("game.lua - destroyScene")
	physics.stop()
end

function scene:overlayBegan(event)
	--print("game.lua - overlayBegan")
	if(not(gamevars.exploding)) then
		transition.pause(gamevars.space.transition)
		Runtime:removeEventListener("accelerometer", movement)
		if(gamevars.timerStatus["score"] == "running") then timer.pause(gamevars.scoreTimer); gamevars.timerStatus["score"] = "paused" end
		if(gamevars.timerStatus["slow"] == "running") then timer.pause(gamevars.slowTimer); gamevars.timerStatus["slow"] =  "paused" end
		if(gamevars.timerStatus["shield"] == "running") then timer.pause(gamevars.shieldTimer); gamevars.timerStatus["shield"] =  "paused" end
	end
	physics.pause()
	if(gamevars.timerStatus["spawn"] == "running") then timer.pause(gamevars.spawnTimer); gamevars.timerStatus["spawn"] = "paused" end
	if(gamevars.timerStatus["otherSpawn"] == "running") then timer.pause(gamevars.otherSpawnTimer); gamevars.timerStatus["otherSpawn"] = "paused" end
	--touchField:removeEventListener("touch", gameTouch)
	pauseButton:removeEventListener("tap", pauseButtonTap)
	if(gamevars.bombButton.sequence == "bomb") then gamevars.bombButton:removeEventListener("tap", obstacles.activateBomb) end
end

function scene:overlayEnded(event)
	--print("game.lua - overlayEnded")
	if(not(gamevars.gameOver)) then
		--print("Resumed")
		if(not(gamevars.exploding)) then
			transition.resume(gamevars.space.transition)
			Runtime:addEventListener("accelerometer", movement)
			if(gamevars.timerStatus["score"] == "paused") then timer.resume(gamevars.scoreTimer); gamevars.timerStatus["score"] = "running" end
			if(gamevars.timerStatus["slow"] == "paused") then timer.resume(gamevars.slowTimer); gamevars.timerStatus["slow"] = "running" end
			if(gamevars.timerStatus["shield"] == "paused") then timer.resume(gamevars.shieldTimer); gamevars.timerStatus["shield"] = "running" end
		end
		physics.start()
		if(gamevars.timerStatus["spawn"] == "paused") then timer.resume(gamevars.spawnTimer); gamevars.timerStatus["spawn"] = "running" end
		if(gamevars.timerStatus["otherSpawn"] == "paused") then timer.resume(gamevars.otherSpawnTimer); gamevars.timerStatus["otherSpawn"] = "running" end
		--touchField:addEventListener("touch", gameTouch)
		pauseButton:addEventListener("tap", pauseButtonTap)
		if(gamevars.bombButton.sequence == "bomb") then gamevars.bombButton:addEventListener("tap", obstacles.activateBomb) end
	end
end

scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
scene:addEventListener("destroyScene", scene)
scene:addEventListener("overlayBegan", scene)
scene:addEventListener("overlayEnded", scene)
return scene