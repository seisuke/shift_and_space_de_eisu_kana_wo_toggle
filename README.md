# shift_and_space_de_eisu_kana_wo_toggle

macOS Tahoe以降で、左Shift+Spaceを押すたびに英数入力とかな入力を切り替える、
小さなメニューバー常駐アプリです。
ログインセッション全体のキーイベントを監視します。

アプリアイコンは「砥」です。アプリ起動後、メニューバーのアイコンはかな入力時は
「砥」、英数入力時は「T」を表示します。

## How to install

Homebrewでインストールします。

```sh
brew tap seisuke/shift-and-space-de-eisu-kana-wo-toggle https://github.com/seisuke/shift_and_space_de_eisu_kana_wo_toggle
brew install --cask shift-and-space-de-eisu-kana-wo-toggle
open "/Applications/shift_and_space_de_eisu_kana_wo_toggle.app"
```

初回起動時は「システム設定 → プライバシーとセキュリティ →
アクセシビリティ」でアプリを許可してください。許可後、アイコンから
「アプリを再起動」を選ぶと左Shift+Spaceが有効になります。

## 必要環境

- macOS Tahoe 26以降
- Xcode 26以降（ソースからビルドする場合）

## ソースからビルド

```sh
make test
make app
open .build/app/shift_and_space_de_eisu_kana_wo_toggle.app
```

ローカルへインストールする場合は次を実行します。

```sh
make install
open "$HOME/Applications/shift_and_space_de_eisu_kana_wo_toggle.app"
```

アイコンから、機能の一時停止、ログイン時起動、アクセシビリティ設定、
アプリの再起動、終了を操作できます。

## 権限と署名

キーイベントを監視・変更するため、App Sandboxは使用していません。
`make install`では、このMac上でビルドしたアプリにad hoc署名を行います。
Homebrew Caskでは、GitHub Releaseで配布する公証済みアプリをインストールします。

GitHub Releaseのビルド済みアプリはDeveloper IDで署名し、Appleの公証を受けて
配布します。リリース用のGitHub Actionsには次のRepository secretsが必要です。

- `DEVELOPER_ID_CERTIFICATE_BASE64`: 秘密鍵を含むDeveloper ID Application証明書（`.p12`）をBase64化した値
- `DEVELOPER_ID_CERTIFICATE_PASSWORD`: `.p12`の書き出しパスワード
- `KEYCHAIN_PASSWORD`: Actions内で一時的に作成するキーチェーンのパスワード
- `APPLE_ID`: 公証に使用するApple Account
- `APPLE_APP_SPECIFIC_PASSWORD`: Apple Accountのアプリ用パスワード
- `APPLE_TEAM_ID`: Apple Developer ProgramのTeam ID

`v`から始まるタグをpushすると、署名、Hardened Runtimeの有効化、公証、
公証チケットの付与と検証を行い、GitHub ReleaseへZIPを公開します。
