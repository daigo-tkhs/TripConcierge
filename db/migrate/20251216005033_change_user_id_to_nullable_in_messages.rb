class ChangeUserIdToNullableInMessages < ActiveRecord::Migration[7.1]
  def change
    # messages テーブルの user_id カラムの NOT NULL 制約を解除（null: true にする）
    change_column_null :messages, :user_id, true
  end
end