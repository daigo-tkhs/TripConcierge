# spec/support/capybara.rb

# Capybaraのデフォルトドライバを :rack_test に設定 (JSなしテスト用)
# rack_test は高速ですが、CSS/JSの解釈や外部サイトへのアクセスはできません。
Capybara.default_driver = :rack_test 

# JavaScriptを使用するテストのためのドライバ設定
Capybara.register_driver :selenium_chrome_headless do |app|
  # ブラウザ起動オプションを設定
  options = Selenium::WebDriver::Chrome::Options.new
  
  # Headless (GUIなし) モードでの起動を設定
  options.add_argument('headless')
  options.add_argument('disable-gpu')
  
  # ウィンドウサイズを設定 (ヘッドレスでは重要)
  options.add_argument('window-size=1920/1080')
  
  # Linux環境 (特にDockerやSnap) での安定性向上のためのオプション
  options.add_argument('no-sandbox')
  options.add_argument('disable-dev-shm-usage')

  # NOTE: ServiceやBinaryのパスは設定せず、Seleniumの自動探索に任せる
  # これにより、webdriversやselenium-managerの複雑な互換性問題を避ける
  Capybara::Selenium::Driver.new(app, browser: :chrome, options: options)
end

# Feature Spec (統合テスト) のデフォルトJavaScriptドライバを設定
# (RSpecで js: true を指定した際にこのドライバが使用されます)
Capybara.javascript_driver = :selenium_chrome_headless

RSpec.configure do |config|
  # RSpecがファイルパスからタイプを推論できるように設定
  config.define_derived_metadata(file_path: %r{/spec/features/}) do |metadata|
    metadata[:type] = :feature
  end
end