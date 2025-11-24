#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Gemのインストール
echo "Installing Gems..."
bundle install

# 2. アセットの事前コンパイル
echo "Precompiling Assets..."
bundle exec rails assets:precompile
# bundle exec rails assets:clean # クリーンアップはRenderの自動処理に任せることが多い