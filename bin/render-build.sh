#!/usr/bin/env bash
# exit on error
set -o errexit

# 1. Gemのインストール
bundle install

# 2. DBマイグレーションをここで実行 (RenderのRelease Commandがない環境向け)
bundle exec rails db:migrate 

# 3. アセットの事前コンパイル
bundle exec rails assets:precompile