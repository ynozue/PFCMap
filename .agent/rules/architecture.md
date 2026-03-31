---
trigger: always_on
---

# アーキテクチャ構成
- 本プロジェクトは、主に **MVVM** パターンをベースに実装されています。
- strict concurrency checking を有効にしてください。

## Data Flow
- API/DB > Repository > PageModel/ViewModel > Domain > Store > View

## ディレクトリ構成
```
├── AppDirectory                     # メインアプリターゲット
│   ├── Model                        # Model
│   │   ├── API                      # リモート API
│   │   │   ├── DTO                  # API 用データ転送オブジェクト
│   │   │   └── Dummy                # リモート API Dummy
│   │   ├── DataSource               # データソース層
│   │   │   ├── DB                   # SwiftData 用
│   │   │   │   └── Entity           # SwiftData エンティティ
│   │   │   ├── Defaults             # UserDefaults サービス
│   │   │   │   └── Dummy            # UserDefaults サービス Dummy
│   │   │   └── Keychain             # Keychain サービス
│   │   │       └── Dummy            # Keychain サービス Dummy
│   │   ├── Domain                   # ドメインモデル
│   │   ├── Repository               # リポジトリ層
│   │   │   └── Dummy                # リポジトリ層 Dummy
│   │   └── Factory.swift            # DI
│   └── View
│       ├── Page                     # 画面
│       │   └── Part                 # 画面内の共通パーツ
│       ├── Resource
│       │   ├── Assets.xcassets      # Image関連Assets
│       │   └── Colors.xcassets      # Color関連Assets
│       └── Store                    # 状態管理 Store
├── EatLeftTests                     # ユニットテスト
└── EatLeftUITests                   # UI テスト
```

## 定義

### 全般
- テストやプレビュー用のモックデータは Dummy 以下のファイルを使用すること

### エラーハンドリング
- API通信やDB操作でエラーが発生した場合、PageModelでエラーをキャッチしユーザーにエラーメッセージを表示する

### Model/API
- Protocolを定義する
- Protocolの命名規則は「プロジェクト名」+「RemoteClient」とする
- 実装の命名規則は「Protocol名」+「Impl」とする
- 実装はDataRace対応のため「actor」とする
- 実装はNZCore.remoteClientを利用する
- Dummyの命名規則は「Protocol名」+「Dummy」とする

### Model/API/DTO
- Request/Response用のDTOを作成する
- DTOはEncodable/Decodableを利用する
- CodingKeysを利用しマッピングを行う

### Model/DB/Entity
- SwiftDataを利用する
- NZData.DomainConvertibleModelを利用する
- DomainConvertibleModelはextensionで実装する

### Model/Defaults
- `UserDefaults` へのアクセスを抽象化する `UserDefaultsService` プロトコルを利用する
- プロトコルの命名規則は `UserDefaultsService` とする
- 実装の命名規則は `UserDefaultsServiceImpl` とする
- 実装は DataRace 対応のため `actor` とし、`NZData` ライブラリの各メソッドを利用する
- Dummy の命名規則は `UserDefaultsServiceDummy` とする
- 設定値（キーとデフォルト値）を管理するための `UserDefaultsKey` を利用した enum を定義する
- enum の命名規則は「プロジェクト名」+ `UserDefaultsKeys` とする

### Model/Keychain
- キーを管理するためのenumを定義する
- enumの命名規則は「プロジェクト名」+「KeychainKeys」とする
- enumは「String, NZData.KeychainKeys」を実装する
- Dummyの命名規則は「KeychainServiceDummy」とする
- Dummyは「NZData.KeychainService」を実装する

### Model/Repository
- Protocolを定義する
- Protocolの命名規則は「機能名」+「Repository」とする
- 実装の命名規則は「Protocol名」+「Impl」とする
- 実装はDataRace対応のため「actor」とする
- 実装はextensionを利用してProtocolで定義した内容を実装する
- Dummyの命名規則は「Protocol名」+「Dummy」とする
- データベースの操作はすべて `DataOperator` を介して行う
- 更新処理は必ず `withTransaction` メソッドを活用してトランザクションで管理する

### Model/Factory.swift
- FactoryはRepository/Serviceを管理する
- Factory.create(env: Env)で生成する
- Envの命名規則は「プロジェクト名」+「Env」とする
- Envは「prod」「dev」「preview」を定義
- Repository/Serviceはextensionで「make」+「repository/service名」という形で定義
- previewの場合はDummy用のrepository/serviceを利用
- prod/dev/previewなど環境固有の値についてもFactory内で生成する
- FactoryはAppの初期処理にて#Debugかを判断して生成する
- Factory作成後にStoreを生成しenvironmentにて設定する

### View/Page
- 「@MainActor」を必ずつけてください
- 画面単位で定義する
- 画面の命名規則は「画面名」+「Page」とする
- 画面のViewModelを定義する
- ViewModelの命名規則は「画面名」+「PageModel」とする
- ViewModelでは画面の状態を管理する
- その画面（Page）独自のUI状態（例：ローディング中フラグ、入力フォームのテキストなど）を保持・管理し、StoreやRepositoryを呼び出す (@Observable クラス)。
- データはStore経由で取得する
- Storeは「.environment」を利用する
- プレビューを定義する
- プレビューは「Store(factory: .create(env: .preview))」のような形でPreview用のデータをセットする

### View/Page/Part
- 「@MainActor」を必ずつけてください
- パーツ単位で定義する
- パーツは画面（Page）に依存しない形で定義する
- パーツの命名規則は「パーツ名」+「View」とする
- 画面のViewModelを定義する
- ViewModelの命名規則は「パーツ名」+「ViewModel」とする
- ViewModelでは画面の状態を管理する

### View/Store
- 「@MainActor」を必ずつけてください
- アプリ全体や複数画面で共有する状態（例：現在取得済みのデータなど）を保持する
- データ保持用のStoreを定義する
- Storeは「@Observable」で管理する
- メインのStoreの命名規則は「プロジェクト名」+「Store」とする
- 保持データ毎にStoreを定義する
- データ毎のStoreの命名規則は「データ名」+「Store」とする
- メインのStore内にデータ毎のStoreを保持する

## 利用ライブラリ
- https://github.com/ynozue/NZUtils.git