class AddShowTeamToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :show, :integer
  end
end
