# frozen_string_literal: true

class MessagesController < ApplicationController
  
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_message, only: %i[edit update destroy]

  def index
    authorize @trip, :ai_chat?
    
    @hide_header = true
    @messages = @trip.messages.order(created_at: :asc)
    @message = Message.new
    
    respond_to do |format|
      format.html
      format.turbo_stream
    end
  end

  def show
    redirect_to trip_messages_path(@trip)
  end

  def edit
    authorize @message
    render 'edit'
  end

  def create
    @message = @trip.messages.build(message_params)
    @message.user = current_user
    
    authorize @message

    if @message.save
      # @ai_message をセットし、create.turbo_stream.erb でレンダリングする
      @ai_message = generate_ai_response(@message)

      respond_to do |format|
        format.html { redirect_to trip_messages_path(@trip), notice: t('messages.user_message.create_success') }
        format.turbo_stream
      end
    else
      redirect_to trip_messages_path(@trip), alert: t('messages.user_message.create_failure')
    end
  end

  def update
    authorize @message

    # 変更前: obsolete_messages = @trip.messages.where('created_at > ?', @message.created_at)
    obsolete_messages = @trip.messages.where('id > ?', @message.id)
    
    @deleted_message_ids = obsolete_messages.pluck(:id)
    obsolete_messages.destroy_all

    if @message.update(message_params)
      # AI応答を再生成
      @ai_message = generate_ai_response(@message)

      respond_to do |format|
        format.html { redirect_to trip_messages_path(@trip), notice: t('messages.user_message.update_success') }
        format.turbo_stream # update.turbo_stream.erb を探す
      end
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    authorize @message
    
    obsolete_messages = @trip.messages.where('id > ?', @message.id)
    @deleted_message_ids = obsolete_messages.pluck(:id) # 画面から消すためにIDを控える
    obsolete_messages.destroy_all
    
    # 本体のメッセージを削除
    @message.destroy

    respond_to do |format|
      flash.now[:notice] = t('messages.user_message.delete_success') 
      
      format.html { redirect_to trip_messages_path(@trip), status: :see_other } 
      format.turbo_stream # destroy.turbo_stream.erb を使用
    end
  end

  # AI応答を生成し、メッセージレコードを返す
  def generate_ai_response(message_record)
    system_instruction, contents = build_request_content(message_record)

    raw_response = handle_ai_api_request(system_instruction, contents)

    handle_ai_response(raw_response)
  rescue StandardError => e
    Rails.logger.error "Gemini API Error: #{e.message}"
    
    # これにより、Message.new でない、有効なレコードが @ai_message にセットされる
    @trip.messages.create!(response: t('messages.ai.communication_error', error: e.message), user_id: nil)
  end

  private

  # AI応答を処理し、DBに保存された AIメッセージレコードを返す
  def handle_ai_response(raw_response)
    ai_response = nil
    if raw_response && raw_response['candidates'].present?
      ai_response = raw_response['candidates'][0].dig('content', 'parts', 0, 'text')
    end

    if ai_response.present?
      # ```json ... ``` の形式のブロックを空文字に置換
      cleaned_response = ai_response.gsub(/```json\s*\{.*?\}\s*```/m, '').strip
      
      response_text = cleaned_response.present? ? cleaned_response : t('messages.ai.no_valid_response')
    else
      response_text = t('messages.ai.no_valid_response')
    end

    # AI応答メッセージを作成し、返す
    @trip.messages.create!(response: response_text, user_id: nil) 
  end
  
  def build_request_content(message_record)
    system_instruction, = helpers.build_system_instruction_for_ai
    contents = build_conversation_contents(message_record)
    [system_instruction, contents]
  end

  def build_conversation_contents(message_record)
    past_messages = @trip.messages.order(created_at: :asc)
    contents = []
    
    past_messages.each do |msg|
      # user_id があればユーザーメッセージ、なければモデルメッセージと仮定
      role_type = msg.user_id.present? ? 'user' : 'model' 

      # AIに渡す会話履歴は、直前のメッセージまで
      if msg.created_at < message_record.created_at
        text_content = msg.prompt.presence || msg.response.presence
        if text_content
          contents << { role: role_type, parts: [{ text: text_content }] }
        end
      end
    end
    
    # 現在のプロンプトを追加
    contents << { role: 'user', parts: [{ text: message_record.prompt }] }
    
    contents
  end
  
  def handle_ai_api_request(system_instruction, contents)
    client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        version: 'v1beta',
        api_key: Rails.application.credentials.gemini[:api_key]
      },
      options: { model: 'gemini-2.0-flash', server_sent_events: false }
    )

    result = client.generate_content({
                                       contents: contents,
                                       system_instruction: { parts: { text: system_instruction } }
                                     })

    result.is_a?(Array) ? result.first : result
  end

  def set_trip
    @trip = Trip.find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: t('messages.trip.not_found')
  end

  def set_message
    @message = @trip.messages.find(params[:id]) 
  rescue ActiveRecord::RecordNotFound
    redirect_to trip_messages_path(@trip), alert: t('messages.user_message.not_found')
  end

  def message_params
    params.require(:message).permit(:prompt)
  end
  
end