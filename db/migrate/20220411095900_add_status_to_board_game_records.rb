class AddStatusToBoardGameRecords < ActiveRecord::Migration[7.0]
  def change
    add_column :board_game_records, :status, :integer
  end
end
