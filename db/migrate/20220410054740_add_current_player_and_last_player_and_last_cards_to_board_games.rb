class AddCurrentPlayerAndLastPlayerAndLastCardsToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :current_player, :string
    add_column :board_games, :last_player, :string
    add_column :board_games, :last_cards, :string
  end
end
