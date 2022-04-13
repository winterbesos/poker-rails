class AddPreparedToCardTables < ActiveRecord::Migration[7.0]
  def change
    add_column :card_tables, :prepared, :integer
  end
end
