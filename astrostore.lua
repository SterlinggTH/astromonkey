local storyboard = require "storyboard"
local widget = require "widget"
local data = require "data"
local store = require "store"
local GGTwitter = require "GGTwitter.GGTwitter"
local scene = storyboard.newScene()

local bananasDisplay, bombDisplay, buttonSound
local x2, shieldImage, slowMoImage, bombImage, x3, shieldUpgradeImage, slowMoUpgradeImage, twitterImage
local x2PriceDisplay, shieldPriceDisplay, slowMoPriceDisplay, x3priceDisplay, shieldUpgradePriceDisplay, slowMoUpgradePriceDisplay
local x2Field, shieldField, slowMoField, x3Field, shieldUpgradeField, slowMoUpgradeField, twitterField

local x2Price = 50
local shieldPrice = 250
local slowMoPrice = 350
local bombPrice = 400
local x3Price = 650
local shieldUpgradePrice = 800
local slowMoUpgradePrice = 950

local powerupSheetOptions = {width = 60, height = 60, numFrames = 11, sheetContentWidth = 660, sheetContentHeight = 60}
local powerupSheet = graphics.newImageSheet("images/storeicons.png", powerupSheetOptions)

function storeTransaction(event)
	local transaction = event.transaction
	if(transaction.state == "purchased")then
		--print("Transaction succuessful!")
		--print("productIdentifier", transaction.productIdentifier)
		--print("receipt", transaction.receipt)
		--print("transactionIdentifier", transaction.identifier)
		--print("date", transaction.date)
		
		if(transaction.productIdentifier == "com.sterlinghackley.astromonkeyadventure.500bananas") then
			data.settings.bananas = data.settings.bananas + 500
			local alert = native.showAlert( "Cha-Ching!", "500 bananas successfully purchased!", { "OK" })
		elseif(transaction.productIdentifier == "com.sterlinghackley.astromonkeyadventure.1500bananas") then
			data.settings.bananas = data.settings.bananas + 1500
			local alert = native.showAlert( "Cha-Ching!", "1500 bananas successfully purchased!", { "OK" })
		elseif(transaction.productIdentifier == "com.sterlinghackley.astromonkeyadventure.5000bananas") then
			data.settings.bananas = data.settings.bananas + 5000
			local alert = native.showAlert( "Cha-Ching!", "5000 bananas successfully purchased!", { "OK" })
		end
		bananasDisplay.text = data.settings.bananas
		data.saveData()
	elseif(transaction.state == "cancelled")then
		--print("User cancelled transaction")
	elseif(transaction.state == "failed")then
		--print("Transaction failed, type:", transaction.errorType, transaction.errorString)
	end
	store.finishTransaction( transaction )
end
store.init(storeTransaction)

local function twitterTap(event)
	--print("Twitter Tap")
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	
	local twitter
	local function twitterHandler(event)
		if(event.phase == "authorised") then
			--print("Account Authorized")
			twitter:post("Check out Astro Monkey Adventure, this addicting new FREE game for iOS and Android! http://bit.ly/astromonkey")
			twitter:destroy()
			twitter = nil
			
			data.settings.bananas = data.settings.bananas + 500
			data.settings.tweet = 1
			data.saveData()
			twitterImage:setSequence("unlocked")
			bananasDisplay.text = data.settings.bananas
			twitterField:removeEventListener("tap", twitterTap)
			
			local alert = native.showAlert( "Cha-Ching!", "Tweet successfully sent. (This can only be done once)", { "OK" })
		elseif(event.phase == "failed") then
			local alert = native.showAlert( "Sorry", "The tweet was unsuccessful.", { "OK" })
		end
	end
	twitter = GGTwitter:new("ZsxOp88hC2VD5J621xqL0SbJc", "eBlLO6u7tA11BvF6hPEVCo526WzNMQz9sUsnKWfJStn08uqVXv", twitterHandler, "http://sterlinghackley.com/astromonkey.php")
	if(twitter:isAuthorised() == false) then
		--print("Authorizing")
		twitter:authorise()
	end
		
end

local function bananaTap(event)
	--print("Banana Tap")
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
   if(system.getInfo("targetAppStore") == "amazon")then
      store.purchase("com.sterlinghackley.astromonkeyadventure.500bananas")
   else
      store.purchase({"com.sterlinghackley.astromonkeyadventure.500bananas"})
   end
end

local function banana2Tap(event)
	--print("Banana2 Tap")
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
   if(system.getInfo("targetAppStore") == "amazon")then
      store.purchase("com.sterlinghackley.astromonkeyadventure.1500bananas")
   else
      store.purchase({"com.sterlinghackley.astromonkeyadventure.1500bananas"})
   end
end

local function barrelTap(event)
	--print("Barrel Tap")
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
   if(system.getInfo("targetAppStore") == "amazon")then
      store.purchase("com.sterlinghackley.astromonkeyadventure.5000bananas")
   else
      store.purchase({"com.sterlinghackley.astromonkeyadventure.5000bananas"})
   end
end

local function x2Tap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.bananas >= x2Price) then
		data.settings.bananas = data.settings.bananas - x2Price
		data.settings.x2Enabled = 1
		data.saveData()
		x2:setFillColor(1, .6, 0)
		x2PriceDisplay.text = "0"
		bananasDisplay.text = data.settings.bananas
		x2Field:removeEventListener("tap", x2Tap)
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function shieldTap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.bananas >= shieldPrice) then
		data.settings.bananas = data.settings.bananas - shieldPrice
		data.settings.shieldEnabled = 1
		data.saveData()
		shieldImage:setSequence("unlocked")
		shieldPriceDisplay.text = "0"
		bananasDisplay.text = data.settings.bananas
		shieldField:removeEventListener("tap", shieldTap)
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function slowMoTap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.bananas >= slowMoPrice) then
		data.settings.bananas = data.settings.bananas - slowMoPrice
		data.settings.slowMoEnabled = 1
		data.saveData()
		slowMoImage:setSequence("unlocked")
		slowMoPriceDisplay.text = "0"
		bananasDisplay.text = data.settings.bananas
		slowMoField:removeEventListener("tap", slowMoTap)
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function bombTap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.bananas >= bombPrice) then
		if(data.settings.bombs == 0) then
			bombImage:setSequence("unlocked")
		end
		data.settings.bananas = data.settings.bananas - bombPrice
		data.settings.bombs = data.settings.bombs + 2
		data.saveData()
		bananasDisplay.text = data.settings.bananas
		bombDisplay.text = data.settings.bombs
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function x3Tap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.x2Enabled == 0) then
		local alert = native.showAlert( "Sorry", "You must unlock the X2 banana multiplier first.", { "OK" })
	elseif(data.settings.bananas >= x3Price) then
		data.settings.bananas = data.settings.bananas - x3Price
		data.settings.x3Enabled = 1
		data.saveData()
		x3:setFillColor(1, .3, 0)
		x3PriceDisplay.text = "0"
		bananasDisplay.text = data.settings.bananas
		x3Field:removeEventListener("tap", x3Tap)
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function shieldUpgradeTap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.shieldEnabled == 0) then
		local alert = native.showAlert( "Sorry", "You must unlock the shield powerup first.", { "OK" })
	elseif(data.settings.bananas >= shieldUpgradePrice) then
		data.settings.bananas = data.settings.bananas - shieldUpgradePrice
		data.settings.shieldUpgrade = 1
		data.saveData()
		shieldUpgradeImage:setSequence("unlocked")
		shieldUpgradePriceDisplay.text = "0"
		bananasDisplay.text = data.settings.bananas
		shieldUpgradeField:removeEventListener("tap", shieldUpgradeTap)
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function slowMoUpgradeTap(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	if(data.settings.slowMoEnabled == 0) then
		local alert = native.showAlert( "Sorry", "You must unlock the slowmo powerup first.", { "OK" })
	elseif(data.settings.bananas >= slowMoUpgradePrice) then
		data.settings.bananas = data.settings.bananas - slowMoUpgradePrice
		data.settings.slowMoUpgrade = 1
		data.saveData()
		slowMoUpgradeImage:setSequence("unlocked")
		slowMoUpgradePriceDisplay.text = "0"
		bananasDisplay.text = data.settings.bananas
		slowMoUpgradeField:removeEventListener("tap", slowMoUpgradeTap)
	else
		local alert = native.showAlert( "Sorry", "You don't have enough bananas. You can buy more by tapping the Banana Packs.", { "OK" })
	end
end

local function menuButtonTouch(event)
	if(data.settings.soundsEnabled == 1) then
		audio.play(buttonSound)
	end
	storyboard.gotoScene("menu", {effect = "fade"})
end

function scene:createScene(event)
	--print("astrostore.lua - createScene")
	local group = self.view
	
	local buttonSheetOptions = {width = 180, height = 60, numFrames = 2, sheetContentWidth = 360, sheetContentHeight = 60}
	local buttonSheet = graphics.newImageSheet("images/button.png", buttonSheetOptions)
	local labelColor = {default={0, 0, 0}, over={0, 0, 0, 2}}
	local menuButton = widget.newButton{sheet = buttonSheet, defaultFrame = 1, overFrame = 2, label = "back", 
										font = "BebasNeue", fontSize = _W/(20/3), labelColor = labelColor, emboss = true,
										onRelease = menuButtonTouch}
	menuButton.anchorX = .2; menuButton.anchorY = 1
	menuButton.x = _W/2; menuButton.y = _H  - _H/240
	group:insert(menuButton)
	
	local scrollView = widget.newScrollView {
		left = 0,
		top = 0,
		width = _W,
		height = _H*(5/6),
		horozontalScrollDisabled = true,
		verticalScrollDisabled = false,
		bottomPadding = _W*(3/2)/-80,
		hideBackground = true
	}
	group:insert(scrollView)
	
	for i = 1,11 do
		local frame1 = display.newImageRect("images/frame.jpg", 310, 70)
		frame1.anchorX = .5; frame1.anchorY = .5
		frame1.x = _W/2; frame1.y = _W*(3/2)*(i/7) - _W*(3/2)/15
		scrollView:insert(frame1)
	end
	
	for i = 5,11 do
		local banana = display.newImageRect("images/bananas.png", 30, 30)
		banana.anchorX = 0; banana.anchorY = 1
		banana.x = _W/20; banana.y = _W*(3/2)*(i/7) - _W*(3/2)/15
		scrollView:insert(banana)
	end
	
	for i = 1,4 do
		local dollar = display.newImageRect("images/dollar.png", 20, 30)
		dollar.anchorX = 0; dollar.anchorY = 1
		dollar.x = _W/20; dollar.y = _W*(3/2)*(i/7) - _W*(3/2)/15
		scrollView:insert(dollar)
	end
	
	------------------------------------------------------------------
	
	local twitterText = display.newText({text = "500 Bananas", font = "BebasNeue", fontSize = _W/10})
	twitterText.anchorX = 0; twitterText.anchorY = .1
	twitterText.x = _W/20; twitterText.y = _W*(3/2)*(1/7) - _W*(3/2)/15
	twitterText:setFillColor(0,0,0)
	scrollView:insert(twitterText)
	
	local twitterPriceDisplay = display.newText({text = "FREE", font = "BebasNeue", fontSize = _W/12})
	twitterPriceDisplay.anchorX = .2; twitterPriceDisplay.anchorY = .9
	twitterPriceDisplay.x = _W/8 + _W/40; twitterPriceDisplay.y = _W*(3/2)*(1/7) - _W*(3/2)/15
	twitterPriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(twitterPriceDisplay)
	
	twitterImage = display.newSprite(powerupSheet, {{ name = "locked", frames = {11} }, { name = "unlocked", frames = {10} }})
	twitterImage.anchorX = .5; twitterImage.anchorY = .5
	twitterImage.x = _W*(5/6); twitterImage.y = _W*(3/2)*(1/7) - _W*(3/2)/15
	scrollView:insert(twitterImage)
	
	if(data.settings.tweet == 1) then
		twitterImage:setSequence("unlocked")
	else
		twitterField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		twitterField.anchorX = .5; twitterField.anchorY = .5
		twitterField.x = _W/2; twitterField.y = _W*(3/2)*(1/7) - _W*(3/2)/15
		twitterField.alpha = 0
		twitterField.isHitTestable = true
		scrollView:insert(twitterField)
		twitterField:addEventListener("tap", twitterTap)
	end
	
	---
	
	local bananaText = display.newText({text = "500 Bananas", font = "BebasNeue", fontSize = _W/10})
	bananaText.anchorX = 0; bananaText.anchorY = .1
	bananaText.x = _W/20; bananaText.y = _W*(3/2)*(2/7) - _W*(3/2)/15
	bananaText:setFillColor(0,0,0)
	scrollView:insert(bananaText)
	
	local bananasPriceDisplay = display.newText({text = ".99", font = "BebasNeue", fontSize = _W/12})
	bananasPriceDisplay.anchorX = .2; bananasPriceDisplay.anchorY = .9
	bananasPriceDisplay.x = _W/8 + _W/40; bananasPriceDisplay.y = _W*(3/2)*(2/7) - _W*(3/2)/15
	bananasPriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(bananasPriceDisplay)
	
	local bananaImage = display.newImage(powerupSheet, 4, 60, 60)
	bananaImage.anchorX = .5; bananaImage.anchorY = .5
	bananaImage.x = _W*(5/6); bananaImage.y = _W*(3/2)*(2/7) - _W*(3/2)/15
	scrollView:insert(bananaImage)
	
	local bananaField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
	bananaField.anchorX = .5; bananaField.anchorY = .5
	bananaField.x = _W/2; bananaField.y = _W*(3/2)*(2/7) - _W*(3/2)/15
	bananaField.alpha = 0
	bananaField.isHitTestable = true
	scrollView:insert(bananaField)
	bananaField:addEventListener("tap", bananaTap)
	
	---
	
	local banana2Text = display.newText({text = "1500 Bananas", font = "BebasNeue", fontSize = _W/10})
	banana2Text.anchorX = 0; banana2Text.anchorY = .1
	banana2Text.x = _W/20; banana2Text.y = _W*(3/2)*(3/7) - _W*(3/2)/15
	banana2Text:setFillColor(0,0,0)
	scrollView:insert(banana2Text)
	
	local banana2PriceDisplay = display.newText({text = "1.99", font = "BebasNeue", fontSize = _W/12})
	banana2PriceDisplay.anchorX = .2; banana2PriceDisplay.anchorY = .9
	banana2PriceDisplay.x = _W/8 + _W/40; banana2PriceDisplay.y = _W*(3/2)*(3/7) - _W*(3/2)/15
	banana2PriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(banana2PriceDisplay)
	
	local banana2Image = display.newImage(powerupSheet, 6, 60, 60)
	banana2Image.anchorX = .5; banana2Image.anchorY = .5
	banana2Image.x = _W*(5/6); banana2Image.y = _W*(3/2)*(3/7) - _W*(3/2)/15
	scrollView:insert(banana2Image)
	
	local banana2Field = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
	banana2Field.anchorX = .5; banana2Field.anchorY = .5
	banana2Field.x = _W/2; banana2Field.y = _W*(3/2)*(3/7) - _W*(3/2)/15
	banana2Field.alpha = 0
	banana2Field.isHitTestable = true
	scrollView:insert(banana2Field)
	banana2Field:addEventListener("tap", banana2Tap)
	
	---
	
	local barrelText = display.newText({text = "5000 Bananas", font = "BebasNeue", fontSize = _W/10})
	barrelText.anchorX = 0; barrelText.anchorY = .1
	barrelText.x = _W/20; barrelText.y = _W*(3/2)*(4/7) - _W*(3/2)/15
	barrelText:setFillColor(0,0,0)
	scrollView:insert(barrelText)
	
	local barrelPriceDisplay = display.newText({text = "4.99", font = "BebasNeue", fontSize = _W/12})
	barrelPriceDisplay.anchorX = .2; barrelPriceDisplay.anchorY = .9
	barrelPriceDisplay.x = _W/8 + _W/40; barrelPriceDisplay.y = _W*(3/2)*(4/7) - _W*(3/2)/15
	barrelPriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(barrelPriceDisplay)
	
	local barrelImage = display.newImage(powerupSheet, 5, 60, 60)
	barrelImage.anchorX = .5; barrelImage.anchorY = .5
	barrelImage.x = _W*(5/6); barrelImage.y = _W*(3/2)*(4/7) - _W*(3/2)/15
	scrollView:insert(barrelImage)
	
	local barrelField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
	barrelField.anchorX = .5; barrelField.anchorY = .5
	barrelField.x = _W/2; barrelField.y = _W*(3/2)*(4/7) - _W*(3/2)/15
	barrelField.alpha = 0
	barrelField.isHitTestable = true
	scrollView:insert(barrelField)
	barrelField:addEventListener("tap", barrelTap)
	
	---
	
	local x2Text = display.newText({text = "Banana Multiplier", font = "BebasNeue", fontSize = _W/10})
	x2Text.anchorX = 0; x2Text.anchorY = .1
	x2Text.x = _W/20; x2Text.y = _W*(3/2)*(5/7) - _W*(3/2)/15
	x2Text:setFillColor(0,0,0)
	scrollView:insert(x2Text)
	
	x2PriceDisplay = display.newText({text = x2Price, font = "BebasNeue", fontSize = _W/12})
	x2PriceDisplay.anchorX = 0; x2PriceDisplay.anchorY = .9
	x2PriceDisplay.x = _W/8 + _W/40; x2PriceDisplay.y = _W*(3/2)*(5/7) - _W*(3/2)/15
	x2PriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(x2PriceDisplay)
	
	local x2Drop = display.newText({text = "X2", font = "BebasNeue", fontSize = _W/5 + _W/80})
	x2Drop.anchorX = .5; x2Drop.anchorY = .5
	x2Drop.x = _W*(5/6); x2Drop.y = _W*(3/2)*(5/7) - _W*(3/2)/15
	x2Drop:setFillColor(0, 0, 0)
	scrollView:insert(x2Drop)
	
	x2 = display.newText({text = "X2", font = "BebasNeue", fontSize = _W/5})
	x2.anchorX = .5; x2.anchorY = .5
	x2.x = _W*(5/6); x2.y = _W*(3/2)*(5/7) - _W*(3/2)/15
	x2:setFillColor(.3, .3, .3)
	scrollView:insert(x2)
	
	if(data.settings.x2Enabled == 1) then
		x2:setFillColor(1, .6, 0)
		x2PriceDisplay.text = "0"
	else
		x2Field = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		x2Field.anchorX = .5; x2Field.anchorY = .5
		x2Field.x = _W/2; x2Field.y = _W*(3/2)*(5/7) - _W*(3/2)/15
		x2Field.alpha = 0
		x2Field.isHitTestable = true
		scrollView:insert(x2Field)
		x2Field:addEventListener("tap", x2Tap)
	end
	
	---
	
	local shieldText = display.newText({text = "Unlock Shield", font = "BebasNeue", fontSize = _W/10})
	shieldText.anchorX = 0; shieldText.anchorY = .1
	shieldText.x = _W/20; shieldText.y = _W*(3/2)*(6/7) - _W*(3/2)/15
	shieldText:setFillColor(0,0,0)
	scrollView:insert(shieldText)
	
	shieldPriceDisplay = display.newText({text = shieldPrice, font = "BebasNeue", fontSize = _W/12})
	shieldPriceDisplay.anchorX = 0; shieldPriceDisplay.anchorY = .9
	shieldPriceDisplay.x = _W/8 + _W/40; shieldPriceDisplay.y = _W*(3/2)*(6/7) - _W*(3/2)/15
	shieldPriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(shieldPriceDisplay)
	
	shieldImage = display.newSprite(powerupSheet, {{ name = "locked", frames = {7} }, { name = "unlocked", frames = {1} }})
	shieldImage.anchorX = .5; shieldImage.anchorY = .5
	shieldImage.x = _W*(5/6); shieldImage.y = _W*(3/2)*(6/7) - _W*(3/2)/15
	scrollView:insert(shieldImage)
	
	if(data.settings.shieldEnabled == 1) then
		shieldImage:setSequence("unlocked")
		shieldPriceDisplay.text = "0"
	else
		shieldField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		shieldField.anchorX = .5; shieldField.anchorY = .5
		shieldField.x = _W/2; shieldField.y = _W*(3/2)*(6/7) - _W*(3/2)/15
		shieldField.alpha = 0
		shieldField.isHitTestable = true
		scrollView:insert(shieldField)
		shieldField:addEventListener("tap", shieldTap)
	end

	---
	
	local slowMoText = display.newText({text = "Unlock SlowMo", font = "BebasNeue", fontSize = _W/10})
	slowMoText.anchorX = 0; slowMoText.anchorY = .1
	slowMoText.x = _W/20; slowMoText.y = _W*(3/2)*(7/7) - _W*(3/2)/15
	slowMoText:setFillColor(0,0,0)
	scrollView:insert(slowMoText)
	
	slowMoPriceDisplay = display.newText({text = slowMoPrice, font = "BebasNeue", fontSize = _W/12})
	slowMoPriceDisplay.anchorX = 0; slowMoPriceDisplay.anchorY = .9
	slowMoPriceDisplay.x = _W/8 + _W/40; slowMoPriceDisplay.y = _W*(3/2)*(7/7) - _W*(3/2)/15
	slowMoPriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(slowMoPriceDisplay)
	
	slowMoImage = display.newSprite(powerupSheet, {{ name = "locked", frames = {8} }, { name = "unlocked", frames = {2} }})
	slowMoImage.anchorX = .5; slowMoImage.anchorY = .5
	slowMoImage.x = _W*(5/6); slowMoImage.y = _W*(3/2)*(7/7) - _W*(3/2)/15
	scrollView:insert(slowMoImage)
	
	if(data.settings.slowMoEnabled == 1) then
		slowMoImage:setSequence("unlocked")
		slowMoPriceDisplay.text = "0"
	else
		slowMoField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		slowMoField.anchorX = .5; slowMoField.anchorY = .5
		slowMoField.x = _W/2; slowMoField.y = _W*(3/2)*(7/7) - _W*(3/2)/15
		slowMoField.alpha = 0
		slowMoField.isHitTestable = true
		scrollView:insert(slowMoField)
		slowMoField:addEventListener("tap", slowMoTap)
	end

	---
	
	local bombText = display.newText({text = "2x Bombs", font = "BebasNeue", fontSize = _W/10})
	bombText.anchorX = 0; bombText.anchorY = .1
	bombText.x = _W/20; bombText.y = _W*(3/2)*(8/7) - _W*(3/2)/15
	bombText:setFillColor(0,0,0)
	scrollView:insert(bombText)
	
	local bombPriceDisplay = display.newText({text = bombPrice, font = "BebasNeue", fontSize = _W/12})
	bombPriceDisplay.anchorX = 0; bombPriceDisplay.anchorY = .9
	bombPriceDisplay.x = _W/8 + _W/40; bombPriceDisplay.y = _W*(3/2)*(8/7) - _W*(3/2)/15
	bombPriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(bombPriceDisplay)
	
	bombImage = display.newSprite(powerupSheet, {{ name = "locked", frames = {9} }, { name = "unlocked", frames = {3} }})
	bombImage.anchorX = .5; bombImage.anchorY = .5
	bombImage.x = _W*(5/6); bombImage.y = _W*(3/2)*(8/7) - _W*(3/2)/15
	scrollView:insert(bombImage)
	
	local bombField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
	bombField.anchorX = .5; bombField.anchorY = .5
	bombField.x = _W/2; bombField.y = _W*(3/2)*(8/7) - _W*(3/2)/15
	bombField.alpha = 0
	bombField.isHitTestable = true
	scrollView:insert(bombField)
	bombField:addEventListener("tap", bombTap)
	
	---
	
	local x3Text = display.newText({text = "Banana Multiplier", font = "BebasNeue", fontSize = _W/10})
	x3Text.anchorX = 0; x3Text.anchorY = .1
	x3Text.x = _W/20; x3Text.y = _W*(3/2)*(9/7) - _W*(3/2)/15
	x3Text:setFillColor(0,0,0)
	scrollView:insert(x3Text)
	
	x3PriceDisplay = display.newText({text = x3Price, font = "BebasNeue", fontSize = _W/12})
	x3PriceDisplay.anchorX = 0; x3PriceDisplay.anchorY = .9
	x3PriceDisplay.x = _W/8 + _W/40; x3PriceDisplay.y = _W*(3/2)*(9/7) - _W*(3/2)/15
	x3PriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(x3PriceDisplay)
	
	local x3Drop = display.newText({text = "X3", font = "BebasNeue", fontSize = _W/5 + _W/80})
	x3Drop.anchorX = .5; x3Drop.anchorY = .5
	x3Drop.x = _W*(5/6); x3Drop.y = _W*(3/2)*(9/7) - _W*(3/2)/15
	x3Drop:setFillColor(0, 0, 0)
	scrollView:insert(x3Drop)
	
	x3 = display.newText({text = "X3", font = "BebasNeue", fontSize = _W/5})
	x3.anchorX = .5; x3.anchorY = .5
	x3.x = _W*(5/6); x3.y = _W*(3/2)*(9/7) - _W*(3/2)/15
	x3:setFillColor(.3, .3, .3)
	scrollView:insert(x3)
	
	if(data.settings.x3Enabled == 1) then
		x3:setFillColor(1, .3, 0)
		x3PriceDisplay.text = "0"
	else
		x3Field = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		x3Field.anchorX = .5; x3Field.anchorY = .5
		x3Field.x = _W/2; x3Field.y = _W*(3/2)*(9/7) - _W*(3/2)/15
		x3Field.alpha = 0
		x3Field.isHitTestable = true
		scrollView:insert(x3Field)
		x3Field:addEventListener("tap", x3Tap)
	end
	
	---
	
	local shieldUpgradeText = display.newText({text = "Upgrade Shield", font = "BebasNeue", fontSize = _W/10})
	shieldUpgradeText.anchorX = 0; shieldUpgradeText.anchorY = .1
	shieldUpgradeText.x = _W/20; shieldUpgradeText.y = _W*(3/2)*(10/7) - _W*(3/2)/15
	shieldUpgradeText:setFillColor(0,0,0)
	scrollView:insert(shieldUpgradeText)
	
	shieldUpgradePriceDisplay = display.newText({text = shieldUpgradePrice, font = "BebasNeue", fontSize = _W/12})
	shieldUpgradePriceDisplay.anchorX = 0; shieldUpgradePriceDisplay.anchorY = .9
	shieldUpgradePriceDisplay.x = _W/8 + _W/40; shieldUpgradePriceDisplay.y = _W*(3/2)*(10/7) - _W*(3/2)/15
	shieldUpgradePriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(shieldUpgradePriceDisplay)
	
	shieldUpgradeImage = display.newSprite(powerupSheet, {{ name = "locked", frames = {7} }, { name = "unlocked", frames = {1} }})
	shieldUpgradeImage.anchorX = .5; shieldUpgradeImage.anchorY = .5
	shieldUpgradeImage.x = _W*(5/6); shieldUpgradeImage.y = _W*(3/2)*(10/7) - _W*(3/2)/15
	scrollView:insert(shieldUpgradeImage)
	
	if(data.settings.shieldUpgrade == 1) then
		shieldUpgradeImage:setSequence("unlocked")
		shieldUpgradePriceDisplay.text = "0"
	else
		shieldUpgradeField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		shieldUpgradeField.anchorX = .5; shieldUpgradeField.anchorY = .5
		shieldUpgradeField.x = _W/2; shieldUpgradeField.y = _W*(3/2)*(10/7) - _W*(3/2)/15
		shieldUpgradeField.alpha = 0
		shieldUpgradeField.isHitTestable = true
		scrollView:insert(shieldUpgradeField)
		shieldUpgradeField:addEventListener("tap", shieldUpgradeTap)
	end
	
	---
	
	local slowMoUpgradeText = display.newText({text = "Upgrade SlowMo", font = "BebasNeue", fontSize = _W/10})
	slowMoUpgradeText.anchorX = 0; slowMoUpgradeText.anchorY = .1
	slowMoUpgradeText.x = _W/20; slowMoUpgradeText.y = _W*(3/2)*(11/7) - _W*(3/2)/15
	slowMoUpgradeText:setFillColor(0,0,0)
	scrollView:insert(slowMoUpgradeText)
	
	slowMoUpgradePriceDisplay = display.newText({text = slowMoUpgradePrice, font = "BebasNeue", fontSize = _W/12})
	slowMoUpgradePriceDisplay.anchorX = 0; slowMoUpgradePriceDisplay.anchorY = .9
	slowMoUpgradePriceDisplay.x = _W/8 + _W/40; slowMoUpgradePriceDisplay.y = _W*(3/2)*(11/7) - _W*(3/2)/15
	slowMoUpgradePriceDisplay:setFillColor(.3,.3,.3)
	scrollView:insert(slowMoUpgradePriceDisplay)
	
	slowMoUpgradeImage = display.newSprite(powerupSheet, {{ name = "locked", frames = {8} }, { name = "unlocked", frames = {2} }})
	slowMoUpgradeImage.anchorX = .5; slowMoUpgradeImage.anchorY = .5
	slowMoUpgradeImage.x = _W*(5/6); slowMoUpgradeImage.y = _W*(3/2)*(11/7) - _W*(3/2)/15
	scrollView:insert(slowMoUpgradeImage)
	
	if(data.settings.slowMoUpgrade == 1) then
		slowMoUpgradeImage:setSequence("unlocked")
		slowMoUpgradePriceDisplay.text = "0"
	else
		slowMoUpgradeField = display.newRect(0, 0, _W*(31/32), _W*(3/2)*(7/48))
		slowMoUpgradeField.anchorX = .5; slowMoUpgradeField.anchorY = .5
		slowMoUpgradeField.x = _W/2; slowMoUpgradeField.y = _W*(3/2)*(11/7) - _W*(3/2)/15
		slowMoUpgradeField.alpha = 0
		slowMoUpgradeField.isHitTestable = true
		scrollView:insert(slowMoUpgradeField)
		slowMoUpgradeField:addEventListener("tap", slowMoUpgradeTap)
	end
	
	-----------------------------------------------------------------
	
	local banana = display.newImageRect("images/bananas.png", 30, 30)
	banana.anchorX = 0; banana.anchorY = 1
	banana.x = _W/80; banana.y = _H-_H/120
	group:insert(banana)
	
	bananasDisplay = display.newText({text = data.settings.bananas, font = "BebasNeue", fontSize = _W/10})
	bananasDisplay.anchorX = 0; bananasDisplay.anchorY = 1;
	bananasDisplay.x = _W/40 + banana.width; bananasDisplay.y = _H + _H/240
	group:insert(bananasDisplay)
	
	local bomb = display.newImageRect("images/bomb.png", 30, 30)
	bomb.anchorX = 0; bomb.anchorY = 1
	bomb.x = _W/80; bomb.y = _H - _H/12
	group:insert(bomb)
	
	bombDisplay = display.newText({text = data.settings.bombs, font = "BebasNeue", fontSize = _W/10})
	bombDisplay.anchorX = 0; bombDisplay.anchorY = 1;
	bombDisplay.x = _W/40 + bomb.width; bombDisplay.y = _H - _H/15
	group:insert(bombDisplay)
end

function scene:willEnterScene(event)
	--print("astrostore.lua - willEnterScene")
	bananasDisplay.text = data.settings.bananas
	bombDisplay.text = data.settings.bombs
	
	if(data.settings.bombs > 0) then
		bombImage:setSequence("unlocked")
	end
	
	if(data.settings.soundsEnabled == 1) then
		buttonSound = audio.loadSound("audio/button.wav")
	end
end 

function scene:enterScene(event)
	if(data.settings.firstTimeStore == 1) then
		data.settings.firstTimeStore = 0
		data.saveData()
		local alert = native.showAlert( "Welcome to the Astro Store", "Want 500 bananas for free? Just tweet a link to this game!", { "OK" })
	end
end

function scene:destroyScene(event)
	if(data.settings.soundsEnabled == 1) then
		audio.dispose(buttonSound)
	end
end

scene:addEventListener("createScene", scene)
scene:addEventListener("willEnterScene", scene)
scene:addEventListener("enterScene", scene)
scene:addEventListener("destroyScene", scene)
return scene