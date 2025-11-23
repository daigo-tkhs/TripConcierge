## データベーススキーマ定義書 (DB_SCHEMA.MD)

### 1. ユーザー管理と認証 (Users)
| カラム名 | データ型 | 備考 |
|---|---|---|
| `id` | primary_key | 主キー |
| `email` | string | 認証用 |
| `password_digest` | string | パスワード保存 |
| `nickname` | string | |

### 2. 旅程の基本情報と文脈 (Trips)
| カラム名 | データ型 | 備考 |
|---|---|---|
| `id` | primary_key | |
| `owner_id` | integer | 外部キー (users.id, 旅程作成者) |
| `title` | string | AIが生成/ユーザー編集可能 |
| `start_date` | date | 旅程開始日 |
| `total_budget` | integer | 予算制約（要件2-2） |
| `travel_theme` | string | 旅行テーマ |
| `context` | text | **AI会話履歴の文脈保存** (要件3-1) |

### 3. 日々のスポットと移動 (Spots)
| カラム名 | データ型 | 備考 |
|---|---|---|
| `id` | primary_key | |
| `trip_id` | integer | 外部キー (trips.id) |
| `day_number` | integer | 旅程の何日目か |
| `name` | string | スポット/施設名 |
| `estimated_cost` | decimal | 概算費用（要件3-1） |
| `duration` | integer | **移動時間**（分単位/要件3-1） |
| `booking_url` | string | 予約リンク（要件4-1） |

### 4. 共有と権限管理 (TripUsers)
| カラム名 | データ型 | 備考 |
|---|---|---|
| `id` | primary_key | |
| `user_id` | integer | 外部キー (users.id) |
| `trip_id` | integer | 外部キー (trips.id) |
| `permission_level` | integer | **権限レベル** (3=所有者, 2=編集者, 1=閲覧者) |

### 5. 会話履歴 (Messages)
| カラム名 | データ型 | 備考 |
|---|---|---|
| `id` | primary_key | |
| `trip_id` | integer | 外部キー (trips.id) |
| `user_id` | integer | 外部キー (users.id, メッセージ送信者) |
| `prompt` | text | ユーザーの質問 |
| `response` | text | AIの返答 |

### 6. 補助機能（ChecklistItems）
| カラム名 | データ型 | 備考 |
|---|---|---|
| `id` | primary_key | |
| `trip_id` | integer | 外部キー (trips.id) |
| `name` | string | 荷物名 |
| `is_checked` | boolean | 準備完了フラグ |
