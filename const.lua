local const = {
  games = {
    {
      name = 'Sudoku',
      filename = 'sudoku',
    },
    {
      name = "Minesweeper",
      filename = "mine_sweeper",
      startMessage = "Minesweeper is starting!",
      difficulties = {
        easy = {
          rows = 10,
          columns = 10,
          mines = 30
        },
        medium = {
          rows = 14,
          columns = 14,
          mines = 50
        },
        hard = {
          rows = 30,
          columns = 30,
          mines = 150
        }
      },
    }
  }
}

return const
