class CreateCardTables < ActiveRecord::Migration[7.0]
  def change
    create_table :card_tables do |t|
      t.references :board_game, null: true, foreign_key: true
      t.integer :status
      t.string :a
      t.string :b
      t.string :c
      t.string :d

      t.timestamps
    end
  end
end
