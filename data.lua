local storyboard = require "storyboard"
local sqlite = require "sqlite3"

local path = system.pathForFile("db.sqlite", system.DocumentsDirectory)

data = {}
data.settings = {}
data.db = sqlite3.open(path)

local createTable = [[CREATE TABLE IF NOT EXISTS settings (key STRING PRIMARY KEY, value INTEGER);]]
data.db:exec(createTable)

function data.createTable()
	--print("Database Created")
	local entrys = {}
	entrys[1] = [[INSERT INTO settings VALUES ("highscore", 0);]]
	entrys[2] = [[INSERT INTO settings VALUES ("bananas", 0);]]
	entrys[3] = [[INSERT INTO settings VALUES ("bombs", 0);]]
	entrys[4] = [[INSERT INTO settings VALUES ("x2Enabled", 0);]]
	entrys[5] = [[INSERT INTO settings VALUES ("x3Enabled", 0);]]
	entrys[6] = [[INSERT INTO settings VALUES ("shieldEnabled", 0);]]
	entrys[7] = [[INSERT INTO settings VALUES ("slowMoEnabled", 0);]]
	entrys[8] = [[INSERT INTO settings VALUES ("shieldUpgrade", 0);]]
	entrys[9] = [[INSERT INTO settings VALUES ("slowMoUpgrade", 0);]]
	entrys[10] = [[INSERT INTO settings VALUES ("tweet", 0);]]
	entrys[11] = [[INSERT INTO settings VALUES ("firstTimeStore", 1);]]
	entrys[12] = [[INSERT INTO settings VALUES ("musicEnabled", 1);]]
	entrys[13] = [[INSERT INTO settings VALUES ("soundsEnabled", 1);]]
	for i=1, 13 do
		data.db:exec(entrys[i])
	end
end

function data.isEmpty()
	for row in data.db:nrows("SELECT * FROM settings") do
		return false;
	end
	return true;
end

function data.saveData()
	local entrys = {}
	entrys[1] = [[UPDATE settings SET value=']] .. data.settings.highscore .. [[' WHERE key='highscore';]]
	entrys[2] = [[UPDATE settings SET value=']] .. data.settings.bananas .. [[' WHERE key='bananas';]]
	entrys[3] = [[UPDATE settings SET value=']] .. data.settings.bombs .. [[' WHERE key='bombs';]]
	entrys[4] = [[UPDATE settings SET value=']] .. data.settings.x2Enabled .. [[' WHERE key='x2Enabled';]]
	entrys[5] = [[UPDATE settings SET value=']] .. data.settings.x3Enabled .. [[' WHERE key='x3Enabled';]]
	entrys[6] = [[UPDATE settings SET value=']] .. data.settings.shieldEnabled .. [[' WHERE key='shieldEnabled';]]
	entrys[7] = [[UPDATE settings SET value=']] .. data.settings.slowMoEnabled .. [[' WHERE key='slowMoEnabled';]]
	entrys[8] = [[UPDATE settings SET value=']] .. data.settings.shieldUpgrade .. [[' WHERE key='shieldUpgrade';]]
	entrys[9] = [[UPDATE settings SET value=']] .. data.settings.slowMoUpgrade .. [[' WHERE key='slowMoUpgrade';]]
	entrys[10] = [[UPDATE settings SET value=']] .. data.settings.tweet .. [[' WHERE key='tweet';]]
	entrys[11] = [[UPDATE settings SET value=']] .. data.settings.firstTimeStore .. [[' WHERE key='firstTimeStore';]]
	entrys[12] = [[UPDATE settings SET value=']] .. data.settings.musicEnabled .. [[' WHERE key='musicEnabled';]]
	entrys[13] = [[UPDATE settings SET value=']] .. data.settings.soundsEnabled .. [[' WHERE key='soundsEnabled';]]
	for i=1, 13 do
		data.db:exec(entrys[i])
	end
end

function data.loadData()
	if(data.isEmpty()) then
		data.createTable()
	else
		--print("Database Loaded")
		local table = {}
		for row in data.db:nrows("SELECT * FROM settings") do
			table[row.key] = row.value;
		end
		return table 
	end
end

return data