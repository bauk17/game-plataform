local Board = require('board')
local Sudoku = {}

function Sudoku.create(config)
  local sudoku = {}
  sudoku.board = Board.create(9, 9, '-')

  setmetatable(sudoku, {
    __index = Sudoku
  })
  return sudoku
end

function Sudoku:run()
  print('Sudoku is starting...')
  self.board:draw()
  print('Sudoku has finished!')
end

return Sudoku
