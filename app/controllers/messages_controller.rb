class MessagesController < ApplicationController
  def create
  end

  def index
    # この旅程に関連するメッセージを全て取得
    @messages = @trip.messages.order(created_at: :asc)
    # 新規投稿用の空のインスタンス
    @message = Message.new
  end

  def update
  end

  def destroy
  end
end
