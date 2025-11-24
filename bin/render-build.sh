#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Gemのインストール
echo "Installing Gems..."
bundle install

# 2. アセットの事前コンパイル
echo "Precompiling Assets..."
bundle exec rails assets:precompile