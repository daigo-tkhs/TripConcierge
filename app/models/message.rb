# frozen_string_literal: true

# app/models/message.rb

class Message < ApplicationRecord
  belongs_to :trip
  
  # 1. AIメッセージを許容するため、user への関連付けを optional: true にする
  belongs_to :user, optional: true 

  # --- バリデーションの条件付け ---

  # 2. ユーザーメッセージ (user_id が存在する) の場合のみ、prompt を必須とする
  validates :prompt, presence: true, if: -> { user_id.present? }

  # 3. AIメッセージ (user_id が nil) の場合のみ、response を必須とする
  validates :response, presence: true, if: -> { user_id.nil? }
  
  # 4. バリデーション前に、AIメッセージの prompt をクリアする
  before_validation :clear_prompt_for_ai, if: -> { user_id.nil? }
  
  # 5. user_id が存在しない場合（AIメッセージ）は、User IDを必須としない
  # （これは belongs_to :user, optional: true でカバーされますが、明示的に残します）
  validates :user_id, presence: true, if: -> { user_id.present? }

  private

  # AIメッセージには prompt は不要なので、強制的に nil に設定する
  def clear_prompt_for_ai
    self.prompt = nil
  end
end