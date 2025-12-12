# config/initializers/assets.rb

Rails.application.config.assets.version = '1.0'

# ▼▼▼ 修正版: Gemのアセットパスを読み込む（最も確実） ▼▼▼
if defined?(Stimulus::Rails::Engine)
  Rails.application.config.assets.paths << Stimulus::Rails::Engine.root.join('app', 'assets', 'javascripts')
end

# Tailwind CSS のアセットビルドパスも念のため再確認（ある場合）
Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'builds')