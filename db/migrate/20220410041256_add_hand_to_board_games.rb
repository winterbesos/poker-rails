class AddHandToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :a_hand, :string
    add_column :board_games, :b_hand, :string
    add_column :board_games, :c_hand, :string
    add_column :board_games, :d_hand, :string
  end
end
