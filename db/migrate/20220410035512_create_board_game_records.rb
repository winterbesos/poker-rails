class CreateBoardGameRecords < ActiveRecord::Migration[7.0]
  def change
    create_table :board_game_records do |t|
      t.references :board_game, null: false, foreign_key: true
      t.string :player
      t.string :content

      t.timestamps
    end
  end
end
