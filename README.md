# server
Chefを用いて理工展のサーバーの設定を記述します。開発環境も設定できるようにします。

## Vagrantの事前準備
必須プラグインがいくつかあるのでインストールしておきます。
```
$ vagrant plugin install vagrant-berkshelf
$ vagrant plugin install vagrant-omnibus
```

## Vagrantのbox
ベースとなるVagrantのboxは次のコマンドで使えます。

```
$ vagrant init marmot1123/centos71-minimal
$ vagrant up
```
