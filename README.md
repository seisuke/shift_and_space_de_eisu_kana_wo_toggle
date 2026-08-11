# shift_and_space_de_eisu_kana_wo_toggle

macOS Tahoe以降で、左Shift+Spaceを押すたびに英数入力とかな入力を切り替える、
小さなメニューバー常駐アプリです。
ログインセッション全体のキーイベントを監視します。

アプリアイコンは「砥」です。アプリ起動後、メニューバーのアイコンはかな入力時は
「砥」、英数入力時は「T」を表示します。

## How to install

Homebrewでインストールします。

```sh
brew tap seisuke/shift-and-space-de-eisu-kana-wo-toggle
brew install --HEAD shift-and-space-de-eisu-kana-wo-toggle
open "$(brew --prefix shift-and-space-de-eisu-kana-wo-toggle)/shift_and_space_de_eisu_kana_wo_toggle.app"
```

初回起動時は「システム設定 → プライバシーとセキュリティ →
アクセシビリティ」でアプリを許可してください。許可後、アイコンから
「アプリを再起動」を選ぶと左Shift+Spaceが有効になります。

## 必要環境

- macOS Tahoe 26以降
- Xcode 26以降（Homebrewまたはソースからビルドする場合）

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
Homebrewおよび`make install`では、このMac上でビルドしたアプリにad hoc署名を
行います。
