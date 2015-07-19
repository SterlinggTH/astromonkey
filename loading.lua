local storyboard = require "storyboard"
local CBE = require "CBEffects.Library"
local scene = storyboard.newScene()

local load

local function toGame()
	load:stop()
	storyboard.gotoScene("game", {effect = "fade"})
end

function scene:createScene(event)
	--print"loading.lua - createScene")
	local group = self.view

	local loading  = display.newText("Loading", 0,0, "BebasNeue", _W/4)
	loading.anchorX = .5; loading.anchorY = .5
	loading.x = _W/2; loading.y = _H/5
	group:insert(loading)
end

function scene:enterScene(event)
	--print"loading.lua - enterScene")
	load = CBE.newVent {
		preset="default",
		positionType="fromPointList",
		x=_W/2 - _W/16,
		y=_H/2,
		pointList={{60, 60}, {13, 84}, {-39, 76}, {-76, 39}, {-84, -13}, {-60, -60}, {-13, -84}, {39, -76}, {76, -39}, {84, 13}},
		cyclePoint=true,
		build=function() return display.newImageRect("CBEffects/textures/generic_particle.png", 50, 50) end,
		perEmit=1,
		fadeInTime=150,
		startAlpha=0,
		outTime=400,
		lifeTime=0,
		emitDelay=50,
		physics={gravityY=0, velocity=0}
	}
	load:start()
	storyboard.loadScene("game")
	timer.performWithDelay(750, toGame)
end

function scene:exitScene(event)
	--print"loading.lua - exitScene")
	load:destroy()
	load = nil
end

scene:addEventListener("createScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("exitScene", scene)
return scene