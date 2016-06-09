class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :loginName
      t.string :salt_masterkey
      t.string :pubkey_user
      t.string :privatekey_user_enc

      t.timestamps null: false
    end
  end
end
