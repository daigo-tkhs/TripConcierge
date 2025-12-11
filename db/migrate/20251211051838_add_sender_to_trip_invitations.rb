# db/migrate/[タイムスタンプ]_add_sender_to_trip_invitations.rb

class AddSenderToTripInvitations < ActiveRecord::Migration[7.1]
  def up
    add_reference :trip_invitations, :sender, foreign_key: { to_table: :users }

    first_user_id = ActiveRecord::Base.connection.execute("SELECT id FROM users ORDER BY id ASC LIMIT 1;").first['id']
    
    if first_user_id
      execute "UPDATE trip_invitations SET sender_id = #{first_user_id} WHERE sender_id IS NULL;"
    end

    # 3. カラムの制約を NULL 不可に変更
    change_column_null :trip_invitations, :sender_id, false
  end

  def down
    remove_reference :trip_invitations, :sender
  end
end