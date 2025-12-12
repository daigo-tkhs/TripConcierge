# frozen_string_literal: true

source 'https://rubygems.org'

ruby '3.2.0'

gem 'rails', '~> 7.1.6'

# -- Core Tech Stack --
gem 'importmap-rails'
gem 'jbuilder'
gem 'mysql2', '~> 0.5'
gem 'puma', '>= 5.0'
gem 'sprockets-rails'
gem 'stimulus-rails'
gem 'turbo-rails'

# -- Database/Security --
gem 'bcrypt', '~> 3.1.7' 
gem 'bootsnap', require: false
gem 'tzinfo-data', platforms: %i[windows jruby]

# -- Application Features (Custom Gems) --
gem 'devise', '~> 4.9' 
gem 'gemini-ai', '~> 4.3' 
gem 'geocoder', '~> 1.8' 
gem 'rolify', '~> 6.0' 

# Punditは認証機能としてここに移動
gem 'pundit'


group :development, :test do
  gem 'debug', platforms: %i[mri windows]
  gem 'rspec-rails', '~> 6.0'
  gem 'factory_bot_rails'
  gem 'faker' 
  gem 'rubocop', require: false
  gem 'rubocop-performance', require: false
  gem 'rubocop-rails', require: false
  
  # 統合テスト/UIテスト関連
  gem 'capybara', '~> 3.37'
  gem 'selenium-webdriver' 
end

group :development do
  gem 'letter_opener_web'
  gem 'web-console'
end


group :production do
  gem 'pg', '~> 1.0'
end

gem 'tailwindcss-rails', '~> 4.4'

gem 'devise-i18n'

gem 'google_maps_service'

gem 'acts_as_list'

gem 'dotenv-rails', groups: %i[development test]

gem 'image_processing', '~> 1.14.0'

gem "stimulus-rails"

gem "turbo-rails"