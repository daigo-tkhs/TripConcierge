class AddRoleToMessages < ActiveRecord::Migration[7.1]
  def change
    add_column :messages, :role, :string, null: false, default: 'user'
  end
end
