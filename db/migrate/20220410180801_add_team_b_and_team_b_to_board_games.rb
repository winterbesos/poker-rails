class AddTeamBAndTeamBToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :team_a, :string
    add_column :board_games, :team_b, :string
  end
end
