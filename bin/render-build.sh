#!/usr/bin/env bash
# exit on error
set -o errexit

# Install gems
echo "Installing Gems..."
bundle install

# 2. DBマイグレーションの行を削除 (Render Release Commandへ移動)
# bundle exec rails db:migrate 

# 3. アセットの事前コンパイル
echo "Precompiling Assets..."
bundle exec rails assets:precompile