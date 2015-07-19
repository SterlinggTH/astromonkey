local gamevars = {}

gamevars.wallThickness = _W/20 -- 16px
gamevars.scoreboardHeight = _H/12 --40px
gamevars.objectSize = _W*(9/80) --36px

gamevars.space = nil
gamevars.interface = nil
gamevars.maingroup = nil

gamevars.gameOver = false
gamevars.score = 0
gamevars.bananas = 0
gamevars.level = 0
gamevars.hasShield = false
gamevars.slowMo = false
gamevars.exploding = false
gamevars.shieldSpawned = false
gamevars.slowSpawned = false

gamevars.bombButton = {}
gamevars.scoreDisplay = {}
gamevars.highscoreDisplay = {}
gamevars.bananasDisplay = {}

gamevars.timerStatus = {}
gamevars.spawnTimer = nil
gamevars.scoreTimer = nil
gamevars.otherSpawnTimer = nil
gamevars.slowTimer = nil
gamevars.shieldTimer = nil

gamevars.soundTable = {}

return gamevars