local storyboard = require "storyboard"
local widget = require "widget"
local data = require "data"
local scene = storyboard.newScene()

local musicDisplay, soundsDisplay, buttonSound

local function menuButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	storyboard.gotoScene("menu", {effect = "fade"})
end

local function toggleMusic(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	data.settings.musicEnabled = math.abs(data.settings.musicEnabled - 1) --toggle
	data.saveData()
	if(data.settings.musicEnabled == 1) then
		musicDisplay.text = "Music: ON"
	else
		musicDisplay.text = "Music: OFF"
	end
end

local function toggleSounds(event)
	data.settings.soundsEnabled = math.abs(data.settings.soundsEnabled - 1) --toggle
	data.saveData()
	if(data.settings.soundsEnabled == 1) then
		soundsDisplay.text = "Sounds: ON"
		buttonSound = audio.loadSound("audio/button.wav")
		audio.play(buttonSound)
	else
		soundsDisplay.text = "Sounds: OFF"
		audio.dispose(buttonSound)
	end
end

function scene:createScene(event)
	--print("options.lua - createScene")
	local group = self.view
	
	local buttonSheetOptions = {width = 180, height = 60, numFrames = 2, sheetContentWidth = 360, sheetContentHeight = 60}
	local buttonSheet = graphics.newImageSheet("images/button.png", buttonSheetOptions)
	local labelColor = {default={0, 0, 0}, over={0, 0, 0, 2}}
	local menuButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "back", 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										onRelease = menuButtonTouch}
	menuButton.anchorX = .5; menuButton.anchorY = 1
	menuButton.x = _W/2; menuButton.y = _H  - _H/240
	group:insert(menuButton)
	
	local musicButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "toggle music", 
										font = "BebasNeue", fontSize = _W/10, labelColor = labelColor, emboss = true,
										onRelease = toggleMusic}
	musicButton.anchorX = .5; musicButton.anchorY = .5
	musicButton.x = _W/2; musicButton.y = _H*.3
	group:insert(musicButton)
	
	local soundsButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "toggle sounds", 
										font = "BebasNeue", fontSize = _W/10, labelColor = labelColor, emboss = true,
										onRelease = toggleSounds}
	soundsButton.anchorX = .5; soundsButton.anchorY = .5
	soundsButton.x = _W/2; soundsButton.y = _H*.3 + musicButton.height + _W/64
	group:insert(soundsButton)
	
	musicDisplay = display.newText({text = "Music:", font = "BebasNeue", fontSize = _W/10})
	musicDisplay.anchorX = .5; musicDisplay.anchorY = .5
	musicDisplay.x = _W/2; musicDisplay.y = _H*.55
	group:insert(musicDisplay)
	
	soundsDisplay = display.newText({text = "Sounds:", font = "BebasNeue", fontSize = _W/10})
	soundsDisplay.anchorX = .5; soundsDisplay.anchorY = .5
	soundsDisplay.x = _W/2; soundsDisplay.y = _H*.55 + musicDisplay.height*(2/3)
	group:insert(soundsDisplay)
end

function scene:willEnterScene(event)
	--print("options.lua - willEnterScene")
	if(data.settings.musicEnabled == 1) then
		musicDisplay.text = "Music: ON"
	else
		musicDisplay.text = "Music: OFF"
	end
	
	if(data.settings.soundsEnabled == 1) then
			soundsDisplay.text = "Sounds: ON"
			buttonSound = audio.loadSound("audio/button.wav")
	else
		soundsDisplay.text = "Sounds: OFF"
	end
end 

scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
return scene