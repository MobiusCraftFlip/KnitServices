local Knit = require(game:GetService("ReplicatedStorage").Knit)

--//Services\\--

local DataStoreService = game:GetService("DataStoreService");
local Players = game:GetService("Players");

--//Variables\\--

local BannedPlayersStore = DataStoreService:GetDataStore("BannedPlayers");

local Knit = require(game:GetService("ReplicatedStorage").Knit)

--Look At The Name
local DefaultBanData = {
	IsBanned = true,
	BanReason = "You have been Banned!",
	BanStarted = os.time(),
	BanLength = 216000,
	BanEnd = os.time() + 216000,
}

local BanService = Knit.CreateService {
	Name = "BanService";
}



function BanService:BanPlayer(PlayerId, Time, BanReason)
	local BanData = {
		IsBanned = true,
		BanReason = BanReason,
		BanStarted = os.time(),
		BanLength = Time,
		BanEnd = os.time() + Time,
	}
	local Player = Players:GetPlayerByUserId(PlayerId)
	if  Player ~= nil then -- Does the Player exist?
		Player:Kick(BanReason)
	end
	
	local success, BanData = pcall(function()
		return BannedPlayersStore:SetAsync(PlayerId, BanData)
	end)
	if success then
		return true
	else
		return error(BanData)
	end
end

-- What do do when a player is added
function BanService:PlayerAdded(plr)
	
	--[[local success, BanData = pcall(function()
		return BannedPlayersStore:SetAsync(plr.UserId, DefaultBanData)
	end)
	]]
	
	local playerID = plr.UserId
	-- Get Player ban data
	local success, BanData = pcall(function()
		return BannedPlayersStore:GetAsync(playerID)
	end)
	if success then
		if  BanData ~= nil then -- Does the player exist in the datastore?
			if BanData.IsBanned then -- Is the player Banned?
				if BanData.BanEnd < os.time() then  -- Is the Time for unban less than the time? 	The player needs to be unbanned
					print("Player is not banned")
				else -- The player needs to be kicked
					plr:Kick(BanData.BanReason)
				end
			end
		end
	else
		-- Did something go wrong?
		error(BanData)
	end
end

function BanService:KnitStart () 
	for _,plr in pairs(Players:GetChildren()) do
		spawn(function ()	
			BanService:PlayerAdded(plr)	
		end)
	end
	
	Players.PlayerAdded:Connect(function (plr) 
		BanService:PlayerAdded(plr)
	end) 
end

return BanService
