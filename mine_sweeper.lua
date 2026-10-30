math.randomseed(os.time())

local Board = require('board')
local MineSweeper = {}

function MineSweeper.create(config)
  local mineSweeper = {}
  mineSweeper.config = config
  mineSweeper.defaultValue = "."
  mineSweeper.board = nil
  mineSweeper.gameRunning = true
  mineSweeper.difficulty = nil
  mineSweeper.mines = {}
  mineSweeper.flags = 0
  mineSweeper.revealedCells = 0
  mineSweeper.gameWon = false
  mineSweeper.gameAborted = false
  mineSweeper.cheatMode = false

  setmetatable(mineSweeper, {
    __index = MineSweeper
  })

  return mineSweeper
end

function MineSweeper:selectDifficulty()
  while true do
    print("Select Difficulty: Easy, Medium, Hard")

    local difficulty = io.read()
    if not difficulty then
      self.gameAborted = true
      return false
    end

    local normalizedDifficulty = string.lower(string.gsub(difficulty, "%s+", ""))

    if normalizedDifficulty == "easy" then
      self.difficulty = self.config.difficulties.easy
      break
    elseif normalizedDifficulty == "medium" then
      self.difficulty = self.config.difficulties.medium
      break
    elseif normalizedDifficulty == "hard" then
      self.difficulty = self.config.difficulties.hard
      break
    elseif normalizedDifficulty == "cheat" then
      self.cheatMode = true
      self.difficulty = self.config.difficulties.easy
      break
    else
      print("Invalid difficulty. Try again")
    end
  end

  return true
end

function MineSweeper:generateMines()
  local remainingMineCount = self.difficulty.mines
  while remainingMineCount > 0 do
    local randomRow = math.random(1, self.difficulty.rows)
    local randomColumn = math.random(1, self.difficulty.columns)
    local position = randomRow .. ":" .. randomColumn
    if not self.mines[position] then
      self.mines[position] = true
      remainingMineCount = remainingMineCount - 1
    end
  end

end

function MineSweeper:countAdjacentMines(row, column)
  local minesFound = 0
  for i = -1, 1 do
    for j = -1, 1 do
      local neighborRow = row + i
      local neighborColumn = column + j

      if not (i == 0 and j == 0) then
        if neighborRow >= 1 and neighborRow <= self.difficulty.rows and neighborColumn >= 1 and neighborColumn <= self.difficulty.columns then
          if self.mines[neighborRow .. ":" ..neighborColumn] then
            minesFound = minesFound + 1
          end
        end
      end
    end
  end
  return minesFound
end

function MineSweeper:revealCell(row, column)
  local verified = self.board:getValue(row, column)

  if verified ~= "." then
    return
  end

  if self.mines[row .. ":" .. column] then
    self.board:setValue(row, column, "M")
    self.gameWon = false
    self.gameRunning = false
    return
  end

  local minesFound = self:countAdjacentMines(row, column)

  if minesFound == 0 then
    self.board:setValue(row, column, " ")
    self.revealedCells = self.revealedCells + 1
    self:checkWin()
    for i = -1, 1 do
      for j = -1, 1 do
        local neighborRow = row + i
        local neighborColumn = column + j

        if not (i == 0 and j == 0) then
          if neighborRow >= 1 and neighborRow <= self.difficulty.rows and neighborColumn >= 1 and neighborColumn <= self.difficulty.columns then
            self:revealCell(neighborRow, neighborColumn)
          end
        end
      end
    end
  else
    self.board:setValue(row, column, tostring(minesFound))
    self.revealedCells = self.revealedCells + 1
    self:checkWin()
  end
end

function MineSweeper:readCoordinates()
  print("Choose action:")
  print("1 - Reveal Cell")
  print("2 - Toggle Flag")
  local selectedAction = io.read()

  if not selectedAction then
    self.gameAborted = true
    self.gameRunning = false
    return
  end

  if selectedAction ~= "1" and selectedAction ~= "2" then
    print("Invalid choice. Type 1 to reveal or 2 to toggle a flag.")
    return
  end

  print("Enter the row:")
  local rowInput = io.read()
  if not rowInput then
    self.gameAborted = true
    self.gameRunning = false
    return
  end

  print("Enter the column:")
  local columnInput = io.read()
  if not columnInput then
    self.gameAborted = true
    self.gameRunning = false
    return
  end

  local row = tonumber(rowInput)
  local column = tonumber(columnInput)

  if not row or not column then
    print("Invalid coordinate.")
    return
  end

  if row % 1 ~= 0 or column % 1 ~= 0 then
    print("Coordinates must be integers.")
    return
  end

  if row < 1 or row > self.difficulty.rows or column < 1 or column > self.difficulty.columns then
    print("Invalid coordinate.")
    return
  end

  if selectedAction == "1" then
    self:revealCell(row, column)
  else
    self:toggleFlag(row, column)
  end
end

function MineSweeper:toggleFlag(row, column)
  local cellValue = self.board:getValue(row, column)
  if cellValue == "." then
    self.board:setValue(row, column, "F")
    self.flags = self.flags + 1
  elseif cellValue == "F" then
    self.board:setValue(row, column, ".")
    self.flags = self.flags - 1
  end
end

function MineSweeper:displayGameInfo()
  print("Total Mines: " .. self.difficulty.mines)
  print("Flags: " .. self.flags)
  local elapsedTime = os.difftime(os.time(), self.startTime)
  print("Time: " .. elapsedTime .. " seconds")
end

function MineSweeper:checkWin()
  if self.revealedCells == (self.difficulty.rows * self.difficulty.columns) - self.difficulty.mines then
    self.gameWon = true
    self.gameRunning = false
  end
end


-- Cheat mode

function MineSweeper:hasRevealedNeighbour(row, column)
  for i = -1, 1 do
    for j = -1, 1 do
      if not (i == 0 and j == 0) then
        local neighborRow = row + i
        local neighborColumn = column + j
        if neighborRow >= 1 and neighborRow <= self.difficulty.rows and neighborColumn >= 1 and neighborColumn <= self.difficulty.columns then
          local neighboringCellValue = self.board:getValue(neighborRow, neighborColumn)
          if neighboringCellValue == " " or tonumber(neighboringCellValue) then
            return true
          end
        end
      end
    end
  end

  return false
end

function MineSweeper:getAvailableMoves()
  local safeCells = {}
  local mineCells = {}

  for i = 1, self.difficulty.rows do
    for j = 1, self.difficulty.columns do
      local value = self.board:getValue(i, j)
      local isMine = self.mines[i .. ":" .. j]

      if value == "." and not isMine and self:hasRevealedNeighbour(i, j) then
        table.insert(safeCells, {row = i, column = j})
      elseif value == "." and isMine then
        table.insert(mineCells, {row = i, column = j})
      end
    end
  end

  return safeCells, mineCells
end

function MineSweeper:autoPlay()
  local safeCells, mineCells = self:getAvailableMoves()

  if #safeCells == 0 and #mineCells == 0 then
    return self:firstAutoMove()
  end

  local selectedAction

  if #safeCells > 0 and #mineCells > 0 then
    selectedAction = math.random(1, 2)
  elseif #safeCells > 0 then
    selectedAction = 1
  else
    selectedAction = 2
  end

  if selectedAction == 1 then
    local selectedIndex = math.random(1, #safeCells)
    local selectedCell = safeCells[selectedIndex]

    self:revealCell(selectedCell.row, selectedCell.column)
  else
    local selectedIndex = math.random(1, #mineCells)
    local selectedCell = mineCells[selectedIndex]

    self:toggleFlag(selectedCell.row, selectedCell.column)
  end

  return true
end


function MineSweeper:firstAutoMove()
  local safeCells = {}

  for i = 1, self.difficulty.rows do
    for j = 1, self.difficulty.columns do
      if self.board:getValue(i, j) == "." and not self.mines[i .. ":" .. j] then
        table.insert(safeCells, {row = i, column = j})
      end
    end
  end

  if #safeCells == 0 then
    return false
  end

  local selectedIndex = math.random(1, #safeCells)
  local selectedCell = safeCells[selectedIndex]

  self:revealCell(selectedCell.row, selectedCell.column)

  return true
end

function MineSweeper:wait(seconds)
  if type(seconds) ~= "number" or seconds < 0 then
    error("Wait duration must be a non-negative number")
  end

  if seconds == 0 then
    return
  end

  local command
  if package.config:sub(1, 1) == "\\" then
    local milliseconds = math.floor(seconds * 1000)
    if milliseconds == 0 then
      return
    end
    command = 'powershell.exe -NoProfile -NonInteractive -Command "Start-Sleep -Milliseconds ' .. milliseconds .. '"'
  else
    command = "sleep " .. string.format("%.3f", seconds)
  end

  local success, _, code = os.execute(command)
  if not success then
    error("Unable to wait: sleep command exited with code " .. tostring(code))
  end
end


function MineSweeper:run()
  print(self.config.startMessage)

  if not self:selectDifficulty() then
    print("Game ended.")
    return
  end

  print("-------------------------------------- MINESWEEPER -----------------------------------------------")

  self.board = Board.create(self.difficulty.rows, self.difficulty.columns, self.defaultValue)

  self:generateMines()

  self.startTime = os.time()

  if self.cheatMode then
    print("CHEAT MODE ACTIVATED!")

    self:firstAutoMove()

    self:displayGameInfo()
    self.board:draw()

    local totalSafeCells = (self.difficulty.rows * self.difficulty.columns) - self.difficulty.mines

    while self.revealedCells < totalSafeCells or self.flags < self.difficulty.mines do
      self:wait(0.1)
      local moved = self:autoPlay()

      if not moved then
        break
      end

      self:displayGameInfo()
      self.board:draw()
    end
    self.gameRunning = false
  else
    self.board:draw()

    while self.gameRunning do
      self:readCoordinates()
      self:displayGameInfo()
      self.board:draw()
    end
  end

  if self.gameAborted then
    print("Game ended.")
  elseif self.gameWon then
    print("Congratulations! You won")
  else
    print("You lose. Try again")
  end
end

return MineSweeper
