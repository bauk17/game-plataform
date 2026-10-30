local Board = {}

function Board.create(rows, columns, defaultValue)
  local board = {}
  board.rows = rows
  board.columns = columns
  board.data = {}

  for i=1,rows do
    board.data[i] = {}
    for j=1,columns do
      board.data[i][j] = defaultValue
    end
  end

  setmetatable(board, {
    __index = Board
  })
  return board
end

function Board:draw()
  local text = ' '
  for i=1,self.columns do
    text = text .. ' ' .. tostring(i)
  end
  text = text .. '\n'
  for i=1,self.rows do
    local row = self.data[i]
    text = text .. tostring(i)
    for j=1,#row do
      text = text ..' ' .. row[j]
    end
    text = text .. '\n'
  end
  print(text)
end

function Board:setValue(row, column, value)
  self.data[row][column] = value
end

function Board:getValue(row, column)
  return self.data[row][column]
end

return Board