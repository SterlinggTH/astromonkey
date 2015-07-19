local storyboard = require "storyboard"
local widget = require "widget"
local data = require "data"
local scene = storyboard.newScene()

local bananasDisplay, highscoreDisplay, buttonSound

if(data.settings == nil) then
	data.settings = data.loadData()
end

local function playButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	storyboard:gotoScene("loading", {effect = "fade"})
end

local function storeButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	storyboard:gotoScene("astrostore", {effect = "fade"})
end

local function optionsButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	storyboard:gotoScene("options", {effect = "fade"})
end

function scene:createScene(event)
	--print("menu.lua - createScene")
  	local group = self.view
	
	local astroText = display.newText({text = "Astro", font = "BebasNeue", fontSize = _W/4})
	astroText.anchorX = .5; astroText.anchorY = .5
	astroText.x = _W/2; astroText.y = _H*.15
	group:insert(astroText)
	
	local monkeyText = display.newText({text = "Monkey", font = "BebasNeue", fontSize = _W/4})
	monkeyText.anchorX = .5; monkeyText.anchorY = .5
	monkeyText.x = _W/2; monkeyText.y = _H*.15 + astroText.height*(2/3)
	group:insert(monkeyText)
	
	local buttonSheetOptions = {width = 180, height = 60, numFrames = 2, sheetContentWidth = 360, sheetContentHeight = 60}
	local buttonSheet = graphics.newImageSheet("images/button.png", buttonSheetOptions)
	local labelColor = {default={0, 0, 0}, over={0, 0, 0, 2}}

	local playButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "play", 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										 onRelease = playButtonTouch}
	playButton.anchorX = .5; playButton.anchorY = .5
	playButton.x = _W/2; playButton.y = _H*.45
	group:insert(playButton)
	
	local storeButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "store", 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										 onRelease = storeButtonTouch}
	storeButton.anchorX = .5; storeButton.anchorY = .5
	storeButton.x = _W/2; storeButton.y = _H*.45 + playButton.height + _W/64
	group:insert(storeButton)
	
	local optionsButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "options", 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										 onRelease = optionsButtonTouch}
	optionsButton.anchorX = .5; optionsButton.anchorY = .5
	optionsButton.x = _W/2; optionsButton.y = _H*.45 + playButton.height + storeButton.height + _W/32
	group:insert(optionsButton)
	
	local banana = display.newImageRect("images/bananas.png", 30, 30)
	banana.anchorX = 0; banana.anchorY = 1
	banana.x = _W/80; banana.y = _H-_H/120
	group:insert(banana)
	
	bananasDisplay = display.newText({text = data.settings.bananas, font = "BebasNeue", fontSize = _W/10})
	bananasDisplay.anchorX = 0; bananasDisplay.anchorY = 1;
	bananasDisplay.x = _W/40 + banana.width; bananasDisplay.y = _H + _H/240
	group:insert(bananasDisplay)
	
	highscoreDisplay = display.newText({text = "Highscore: " .. data.settings.highscore, font = "BebasNeue", fontSize = _W/16})
	highscoreDisplay.anchorX = 1; highscoreDisplay.anchorY = 1;
	highscoreDisplay.x = _W-_W/80; highscoreDisplay.y = _H
	group:insert(highscoreDisplay)
end

function scene:willEnterScene(event)
	--print("menu.lua - willEnterScene")
	bananasDisplay.text = data.settings.bananas
	highscoreDisplay.text = "Highscore: " .. data.settings.highscore
	
	if(data.settings.soundsEnabled == 1) then
		buttonSound = audio.loadSound("audio/button.wav")
	end
end

function scene:destroyScene(event)
	if(data.settings.soundsEnabled == 1) then
		audio.dispose(buttonSound)
	end
end


scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("destroyScene", scene)
return scene