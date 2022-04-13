class AddAResultAndBResultAndCResultAndDResultToBoardGames < ActiveRecord::Migration[7.0]
  def change
    add_column :board_games, :a_result, :integer
    add_column :board_games, :b_result, :integer
    add_column :board_games, :c_result, :integer
    add_column :board_games, :d_result, :integer
  end
end
