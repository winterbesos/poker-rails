class AddAScoreAndBScoreAndCScoreAndDScoreToCardTables < ActiveRecord::Migration[7.0]
  def change
    add_column :card_tables, :a_score, :integer
    add_column :card_tables, :b_score, :integer
    add_column :card_tables, :c_score, :integer
    add_column :card_tables, :d_score, :integer
  end
end
