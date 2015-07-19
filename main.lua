_W = display.contentWidth
_H = display.contentHeight

display.setStatusBar(display.HiddenStatusBar)
display.setDefault("anchorX", 0 )
display.setDefault("anchorY", 0 )
system.setAccelerometerInterval(30)
system.setIdleTimer(false)

local storyboard = require "storyboard"
local gamevars = require "gamevars"
local data = require "data"

gamevars.space = display.newImageRect("images/space.jpg", _W, _H*(31/12))
gamevars.space.anchorX = 0; gamevars.space.anchorY = 1
gamevars.space.x = 0; gamevars.space.y = _H
gamevars.space.alpha = .4

local topFiller = display.newRect(0, (display.actualContentHeight - _H)/-2, _W, (display.actualContentHeight - _H)/2)
topFiller:setFillColor(0,0,0)

local bottomFiller = display.newRect(0, _H, _W, (display.actualContentHeight - _H)/2)
bottomFiller:setFillColor(0,0,0)

local stage = display.getCurrentStage()
stage:insert(gamevars.space)
stage:insert(storyboard.stage)
stage:insert(topFiller)
stage:insert(bottomFiller)

local function onSystemEvent( event )
	if(event.type == "applicationSuspend" and storyboard.getCurrentSceneName() == "game") then
		if(not(gamevars.gameOver)) then
			storyboard.showOverlay("popup", {params = {message = "Paused", button = "resume"}, isModel = true})
		end
	elseif(event.type == "applicationExit") then
		data.db:close()
	end
end
Runtime:addEventListener("system", onSystemEvent)

data.settings = data.loadData()

local function checkMemory()
   collectgarbage( "collect" )
   local memUsage_str = string.format( "MEMORY = %.3f KB", collectgarbage( "count" ) )
   --print( memUsage_str, "TEXTURE = "..(system.getInfo("textureMemoryUsed") / (1024 * 1024) ) )
end
--timer.performWithDelay( 1000, checkMemory, 0 )

storyboard.gotoScene("menu")