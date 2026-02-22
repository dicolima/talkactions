-- /addforgedust playername, 100
-- Adiciona forge dusts ao jogador (máximo 300)

local addForgeDust = TalkAction("/addforgedust")

local MAX_FORGE_DUST = 300

function addForgeDust.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	-- Verifica se o parâmetro foi passado
	if param == "" then
		player:sendCancelMessage("Player name param required.")
		logger.error("[addForgeDust.onSay] - Player name param not found")
		return true
	end

	local split = param:split(",")

	-- Verifica se o nome foi passado
	local name = split[1]:trim()
	local normalizedName = Game.getNormalizedPlayerName(name)
	if not normalizedName then
		player:sendCancelMessage("A player with name " .. name .. " does not exist.")
		return true
	end
	name = normalizedName

	-- Verifica se o amount foi passado e é válido
	local amount = nil
	if split[2] then
		amount = tonumber(split[2]:trim())
	end

	if amount == nil or amount <= 0 then
		player:sendCancelMessage("Invalid amount. Use a positive number.")
		return true
	end

	-- Busca o valor atual de forge_dusts no banco
	local resultId = db.storeQuery(
		"SELECT `id`, `forge_dusts` FROM `players` WHERE `name` = " .. db.escapeString(name)
	)

	if not resultId then
		player:sendCancelMessage("Could not find player " .. name .. " in the database.")
		logger.error("[addForgeDust.onSay] - Player not found in database: " .. name)
		return true
	end

	local playerId    = result.getNumber(resultId, "id")
	local currentDust = result.getNumber(resultId, "forge_dusts")
	result.free(resultId)

	-- Calcula novo valor respeitando o cap de 300
	local newDust = math.min(currentDust + amount, MAX_FORGE_DUST)
	local added   = newDust - currentDust

	if added <= 0 then
		player:sendCancelMessage(name .. " already has the maximum forge dusts (" .. MAX_FORGE_DUST .. ").")
		return true
	end

	-- Atualiza no banco (funciona para online e offline)
	db.query(
		"UPDATE `players` SET `forge_dusts` = " .. newDust ..
		", `forge_dust_level` = " .. newDust ..
		" WHERE `id` = " .. playerId
	)

	-- Se o jogador estiver online, atualiza a sessão em memória também
	local targetPlayer = Player(name)
	if targetPlayer then
		-- Tenta usar o método nativo se existir, senão força um reload via save/load
		if targetPlayer.setForgeDusts then
			targetPlayer:setForgeDusts(newDust)
		end
		targetPlayer:sendTextMessage(MESSAGE_EVENT_ADVANCE,
			player:getName() .. " added " .. added .. " forge dusts to your character. (" ..
			newDust .. "/" .. MAX_FORGE_DUST .. ")"
		)
	end

	-- Feedback para o God
	player:sendTextMessage(MESSAGE_EVENT_ADVANCE,
		"Successfully added " .. added .. " forge dusts to " .. name ..
		". (" .. newDust .. "/" .. MAX_FORGE_DUST .. ")"
	)

	-- Log
	logger.info("{} added {} forge dusts to {} (total: {}/{})",
		player:getName(), added, name, newDust, MAX_FORGE_DUST)

	return true
end

addForgeDust:separator(" ")
addForgeDust:groupType("god")
addForgeDust:register()