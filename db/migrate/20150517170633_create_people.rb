class CreatePeople < ActiveRecord::Migration
  def change
    create_table :people do |t|
      t.string :firstname
      t.string :middlename
      t.string :lastname
      t.string :title
      t.string :sex
      t.string :salutation
      t.string :password
      t.integer :roles
      t.integer :status

      t.timestamps null: false
    end
  end
end
