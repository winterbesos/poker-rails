class AddShoseOwnerToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :shose_owner, :string
  end
end
