# config/initializers/assets.rb

Rails.application.config.assets.version = '1.0'

if defined?(Stimulus::Rails::Engine)
  Rails.application.config.assets.paths << Stimulus::Rails::Engine.root.join('app', 'assets', 'javascripts')
end

Rails.application.config.assets.paths << Rails.root.join('app', 'assets', 'builds')

Rails.application.config.assets.paths << Rails.root.join("app/javascript")
Rails.application.config.assets.precompile += %w( controllers/*.js )