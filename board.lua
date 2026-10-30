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
  local parts = {"   "}

  for i = 1, self.columns do
    parts[#parts + 1] = string.format("%2d ", i)
  end

  parts[#parts + 1] = "\n"

  for i = 1, self.rows do
    local row = self.data[i]

    parts[#parts + 1] = string.format("%2d ", i)

    for j = 1, #row do
      parts[#parts + 1] = string.format("%2s ", tostring(row[j]))
    end

    parts[#parts + 1] = "\n"
  end

  print(table.concat(parts))
end

function Board:setValue(row, column, value)
  self.data[row][column] = value
end

function Board:getValue(row, column)
  return self.data[row][column]
end

return Board
