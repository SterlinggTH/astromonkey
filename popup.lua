local storyboard = require "storyboard"
local widget = require "widget"
local gamevars = require "gamevars"
local data = require "data"
local scene = storyboard.newScene()

local bananasDisplay, buttonSound

local function buttonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(gamevars.gameOver == true) then
		storyboard:gotoScene("loading", {effect = "fade"})
	else
		storyboard.hideOverlay()
	end
end

local function storeButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	gamevars.gameOver = true
	storyboard.hideOverlay()
	storyboard.gotoScene("astrostore", {effect = "fade"})
end

local function menuButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	gamevars.gameOver = true
	storyboard.hideOverlay()
	storyboard.gotoScene("menu", {effect = "fade"})
end

function scene:createScene(event)
	--print("popup.lua - createScene")
	local group = self.view

	local bg = display.newRect(0, 0, _W, _H)
	bg:setFillColor(0,0,0)
	bg.alpha = .7
	group:insert(bg)

	local textview = display.newText(event.params.message, 0,0, "BebasNeue", _W/4)
	textview.anchorX = .5; textview.anchorY = .5
	textview.x = _W/2; 
	if(gamevars.gameOver) then textview.y = _H*.3 else textview.y = _H*.35 end
	group:insert(textview)
	
	local buttonSheetOptions = {width = 180, height = 60, numFrames = 2, sheetContentWidth = 360, sheetContentHeight = 60}
	local buttonSheet = graphics.newImageSheet("images/button.png", buttonSheetOptions)
	local labelColor = {default={0, 0, 0}, over={0, 0, 0, 2}}

	local button = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = event.params.button, 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										 onRelease = buttonTouch}
	button.anchorX = .5; button.anchorY = .5
	button.x = _W/2;
	if(gamevars.gameOver) then button.y = _H*.45 else button.y = _H*.5 end
	group:insert(button)
	
	local storeButton
	if(gamevars.gameOver) then
		storeButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "store", 
											font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
											 onRelease = storeButtonTouch}
		storeButton.anchorX = .5; storeButton.anchorY = .5
		storeButton.x = _W/2; storeButton.y = _H*.45 + button.height + _W/64
		group:insert(storeButton)
	end
	
	local menuButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "menu", 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										 onRelease = menuButtonTouch}
	menuButton.anchorX = .5; menuButton.anchorY = .5
	menuButton.x = _W/2;
	if(gamevars.gameOver) then menuButton.y = _H*.45 + button.height + storeButton.height + _W/32 else
		menuButton.y = _H*.5 + button.height + _W/64 end
	group:insert(menuButton)
	
	if(gamevars.gameOver) then
		local banana = display.newImageRect("images/bananas.png", 30, 30)
		banana.anchorX = 0; banana.anchorY = 1
		banana.x = _W/80; banana.y = _H-_H/120
		group:insert(banana)
		
		bananasDisplay = display.newText({text = data.settings.bananas, font = "BebasNeue", fontSize = _W/10})
		bananasDisplay.anchorX = 0; bananasDisplay.anchorY = 1;
		bananasDisplay.x = _W/40 + banana.width; bananasDisplay.y = _H
		group:insert(bananasDisplay)
	end
end

function scene:enterScene(event)
	--print("popup.lua - enterScene")
	if(gamevars.gameOver) then
		if(gamevars.score > data.settings.highscore) then 
			data.settings.highscore = gamevars.score
		end
		local prevBananas = data.settings.bananas
		data.settings.bananas = data.settings.bananas + gamevars.bananas
		data.saveData()
		if(gamevars.bananas > 0) then
			local inc = 0
			local incBananasTimer
			local function incBananas()
				inc = inc + 1
				bananasDisplay.text = prevBananas + inc
				if(gamevars.bananas == inc) then
					timer.cancel(incBananasTimer)
					incBananasTimer = nil
				end
			end
			incBananasTimer = timer.performWithDelay(1000/(gamevars.bananas), incBananas, 0)
		end
	end
	
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
scene:addEventListener("enterScene", scene)
scene:addEventListener("destroyScene", scene)
return scene