class AddFieldNameToTableName < ActiveRecord::Migration
  def change
    add_column :people, :email, :string
    add_column :people, :username, :string
  end
end
