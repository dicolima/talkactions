-- /seecommands

local seeCommands = TalkAction("/seecommands")

function seeCommands.onSay(player, words, param)
	-- create log
	logCommand(player, words, param)

	local lines = {
		"=== GOD COMMANDS ===",
		" ",
		"[MONEY]",
		"Comando: /addmoney NomeDoPlayer, 100000",
		"Descricao: Adiciona gold coins ao jogador.",
		" ",
		"[FORGE DUSTS]",
		"Comando: /addforgedust NomeDoPlayer, 100",
		"Descricao: Adiciona forge dusts ao jogador (maximo: 300).",
		" ",
		"[FORGE DUST LEVEL]",
		"Comando: /addforgedustlevel NomeDoPlayer",
		"Descricao: Aumenta o forge dust level em 100 por vez (100 > 200 > 300).",
	}

	for _, line in ipairs(lines) do
		player:sendTextMessage(MESSAGE_EVENT_ADVANCE, line)
	end

	return true
end

seeCommands:separator(" ")
seeCommands:groupType("god")
seeCommands:register()