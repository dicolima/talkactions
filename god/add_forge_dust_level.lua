-- /addforgedustlevel playername

local addForgeDustLevel = TalkAction("/addforgedustlevel")

local MIN_FORGE_DUST_LEVEL = 100
local MAX_FORGE_DUST_LEVEL = 300
local STEP = 100

function addForgeDustLevel.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	if param == "" then
		player:sendCancelMessage("Player name param required.")
		logger.error("[addForgeDustLevel.onSay] - Player name param not found")
		return true
	end

	local name = param:trim()
	local normalizedName = Game.getNormalizedPlayerName(name)
	if not normalizedName then
		player:sendCancelMessage("A player with name " .. name .. " does not exist.")
		return true
	end
	name = normalizedName

	-- Busca o valor atual de forge_dust_level no banco
	local resultId = db.storeQuery(
		"SELECT `id`, `forge_dust_level` FROM `players` WHERE `name` = " .. db.escapeString(name)
	)

	if not resultId then
		player:sendCancelMessage("Could not find player " .. name .. " in the database.")
		logger.error("[addForgeDustLevel.onSay] - Player not found in database: " .. name)
		return true
	end

	local playerId     = result.getNumber(resultId, "id")
	local currentLevel = result.getNumber(resultId, "forge_dust_level")
	result.free(resultId)

	-- Garante que o valor atual nunca seja menor que o mínimo
	if currentLevel < MIN_FORGE_DUST_LEVEL then
		currentLevel = MIN_FORGE_DUST_LEVEL
	end

	-- Verifica se já está no máximo
	if currentLevel >= MAX_FORGE_DUST_LEVEL then
		player:sendCancelMessage(name .. " already has the maximum forge dust level (" .. MAX_FORGE_DUST_LEVEL .. ").")
		return true
	end

	-- Sempre soma 100
	local newLevel = currentLevel + STEP

	-- Atualiza no banco
	db.query(
		"UPDATE `players` SET `forge_dust_level` = " .. newLevel ..
		" WHERE `id` = " .. playerId
	)

	-- Se o jogador estiver online, atualiza em memória também
	local targetPlayer = Player(name)
	if targetPlayer then
		if targetPlayer.setForgeDustLevel then
			targetPlayer:setForgeDustLevel(newLevel)
		end
		targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			player:getName() .. " increased your forge dust level to " .. newLevel .. "/" .. MAX_FORGE_DUST_LEVEL .. "."
		)
	end

	-- Feedback para o God
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
		"Successfully increased forge dust level of " .. name ..
		" to " .. newLevel .. "/" .. MAX_FORGE_DUST_LEVEL .. "."
	)

	-- Log
	logger.info("{} increased forge dust level of {} to {}/{}", player:getName(), name, newLevel, MAX_FORGE_DUST_LEVEL)

	return true
end

addForgeDustLevel:separator(" ")
addForgeDustLevel:groupType("god")
addForgeDustLevel:register()