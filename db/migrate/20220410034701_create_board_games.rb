class CreateBoardGames < ActiveRecord::Migration[7.0]
  def change
    create_table :board_games do |t|
      t.text :content
      t.integer :status
      t.string :a
      t.string :b
      t.string :c
      t.string :d

      t.timestamps
    end
  end
end
