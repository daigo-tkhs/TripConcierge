class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_trip
  before_action :set_message, only: [:edit, :update, :destroy]

  def index
    @hide_header = true
    @messages = @trip.messages.order(created_at: :asc)
    @message = Message.new
  end

  def create
    @message = @trip.messages.build(message_params)
    @message.user = current_user

    if @message.save
      generate_ai_response(@message) # AI応答生成をメソッド化
    else
      redirect_to trip_messages_path(@trip), alert: 'メッセージを入力してください。'
    end
  end

  def edit
  end

  def update
    @trip.messages.where("created_at > ?", @message.created_at).destroy_all

    if @message.update(message_params)
      generate_ai_response(@message)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @message.destroy
    respond_to do |format|
      format.html { redirect_to trip_messages_path(@trip), notice: 'メッセージを削除しました。', status: :see_other }
      format.turbo_stream
    end
  end

  private

  # --- AI連携ロジック（共通化） ---
  def generate_ai_response(message_record)
    begin
      system_instruction = <<~INSTRUCTION
        あなたは旅行プランニングのアシスタントです。
        ユーザーの要望に合わせて、観光スポット、レストラン、または宿泊施設（ホテル・旅館）を提案してください。
        
        【重要】
        具体的な場所を提案する場合は、必ず以下の**JSON形式のみ**で返答してください。余計な文章は不要です。
        提案する場所がない場合（挨拶や質問への回答など）は、普通のテキストで返答してください。
        
        # スポット提案時のJSONフォーマット例:
        {
          "is_suggestion": true,
          "spots": [
            {
              "name": "東京タワー",
              "description": "東京のシンボル。メインデッキからは東京の景色を一望できます。",
              "estimated_cost": 1200,
              "duration": 60,
              "google_map_url": "http://googleusercontent.com/maps.google.com/..."
            }
          ],
          "message": "東京タワーはいかがでしょうか？定番ですが外せません！"
        }

        # 注意事項:
        1. estimated_cost は必ず**日本円(JPY)**の数値で入力してください。（ホテルの場合は1泊1名あたりの目安）
        2. description は簡潔に魅力的な説明を入れてください。
      INSTRUCTION

      client = Gemini.new(
        credentials: {
          service: 'generative-language-api',
          version: 'v1beta',
          api_key: Rails.application.credentials.gemini[:api_key]
        },
        options: { model: 'gemini-2.0-flash', server_sent_events: false }
      )

      # 会話履歴の構築
      past_messages = @trip.messages.where.not(id: message_record.id).order(created_at: :asc)
      
      contents = []
      past_messages.each do |msg|
        contents << { role: 'user', parts: { text: msg.prompt } }
        if msg.response.present?
          contents << { role: 'model', parts: { text: msg.response } }
        end
      end
      
      # 今回のメッセージを追加
      contents << { role: 'user', parts: { text: message_record.prompt } }

      result = client.generate_content({
        contents: contents,
        system_instruction: { parts: { text: system_instruction } }
      })

      raw_response = result.is_a?(Array) ? result.first : result
      
      if raw_response && raw_response['candidates'].present?
          candidates = raw_response['candidates']
          ai_response = candidates[0].dig('content', 'parts', 0, 'text')
          
          if ai_response.present?
            message_record.update!(response: ai_response)
            # 必ずリダイレクト（画面更新）を行う
            redirect_to trip_messages_path(@trip)
          else
             redirect_to trip_messages_path(@trip), alert: 'AIからの応答テキストが見つかりませんでした。'
          end
      else
          redirect_to trip_messages_path(@trip), alert: 'AIからの有効な応答がありませんでした。'
      end

    rescue => e
      Rails.logger.error "Gemini API Error: #{e.message}"
      redirect_to trip_messages_path(@trip), alert: "AIとの通信に失敗しました: #{e.message}"
    end
  end
  

  def set_trip
    @trip = Trip.shared_with_user(current_user).find(params[:trip_id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "指定された旅程が見つからないか、アクセス権がありません。"
  end

  def set_message
    @message = @trip.messages.where(user_id: current_user.id).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to trip_messages_path(@trip), alert: "権限がないか、メッセージが見つかりません。"
  end

  def message_params
    params.require(:message).permit(:prompt)
  end
end