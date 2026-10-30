require('helpers')

local const = require('const')

function main()
  print('Welcome to Game Platform\n')

  print('Which game do you want to play?')

  local games = const.games
  for i,gameConfig in ipairs(games) do
    print(i .. ' - ' .. gameConfig.name)
  end

  local gameId = readNumber('Choose the game: ', 1, #games, 'Invalid choice. Try again.')
  local gameConfig = games[gameId]

  local GameClass = require(gameConfig.filename)
  local game = GameClass.create(gameConfig)
  game:run()
end

main()
