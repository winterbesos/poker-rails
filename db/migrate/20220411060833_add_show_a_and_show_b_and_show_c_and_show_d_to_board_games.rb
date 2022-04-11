class AddShowAAndShowBAndShowCAndShowDToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :show_a, :string
    add_column :board_games, :show_b, :string
    add_column :board_games, :show_c, :string
    add_column :board_games, :show_d, :string
  end
end
