class RemoveFieldNameFromTableName < ActiveRecord::Migration
  def change
    remove_column :people, :password, :string
    add_column :people, :password_hash, :string
    add_column :people, :password_salt, :string
  end
end
