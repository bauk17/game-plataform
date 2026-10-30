local Board = require('board')
local TicTacToe = {}

function TicTacToe.create(config)
  local ttt = {}
  ttt.config = config
  ttt.defaultValue = '-'
  ttt.board = Board.create(3, 3, ttt.defaultValue)
  ttt.teamSymbols = config.symbols
  ttt.currentTeam = 0
  ttt.teams = 2
  ttt.gameRunning = true -- todo
  ttt.filledCells = 0

  setmetatable(ttt, {
    __index = TicTacToe
  })
  return ttt
end

function TicTacToe:run()
  print(self.config.startMessage)

  while self.gameRunning do
    self.board:draw()

    local symbol = self.teamSymbols[self.currentTeam]
    print("Current turn is " .. symbol)

    local row
    local column
    if self.currentTeam == 0 then
      row = readNumber('Enter the row (123): ', 1, 3, 'Invalid row. Try again.')

      column = readNumber('Enter the column (123): ', 1, 3, 'Invalid column. Try again.')
    else
      local cell = self:chooseRandomCell()
      row = cell[1]
      column = cell[2]
    end

    if self.board:getValue(row, column) ~= self.defaultValue then
      print('Choose another cell')
    else
      self.board:setValue(row, column, symbol)
      self.filledCells = self.filledCells + 1
  
      if self:checkWinner(row, column, symbol) then
        self.board:draw()
        self.gameRunning = false
        print("Winner is " .. symbol)
        break
      elseif self.filledCells == (3*3) then
        self.board:draw()
        self.gameRunning = false
        print('Draw!')
        break
      end
  
      self.currentTeam = self.currentTeam + 1
      self.currentTeam = (self.currentTeam % self.teams)
    end
  end

  print('Tic-tac-toe has finished!')
end

function TicTacToe:checkWinner(row, column, symbol)
  if self.board:getValue(1, column) == self.board:getValue(2, column) and self.board:getValue(1, column) == self.board:getValue(3, column) then
    return true
  end

  if self.board:getValue(row, 1) == self.board:getValue(row,2) and self.board:getValue(row, 1) == self.board:getValue(row, 3) then
    return true
  end

  if self.board:getValue(1, 1) == symbol and self.board:getValue(1, 1) == self.board:getValue(2, 2) and self.board:getValue(1, 1) == self.board:getValue(3, 3) then
    return true
  end

  if self.board:getValue(1, 3) == symbol and self.board:getValue(1, 3) == self.board:getValue(2, 2) and self.board:getValue(1, 3) == self.board:getValue(3, 1) then
    return true
  end

  return false
end

function TicTacToe:chooseRandomCell()
  local availableCells = {}
  for i=1,3 do
    for j=1,3 do
      local value = self.board:getValue(i, j)
      if value == self.defaultValue then
        table.insert(availableCells, { i, j })
      end
    end
  end
  local cell = availableCells[math.random(1, #availableCells)]
  return cell
end

return TicTacToe
