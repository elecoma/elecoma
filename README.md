[![エレコマ(Elephant Commerce)](http://ec.appirits.com/files/2013/02/elecoma_logo.png)](http://ec.appirits.com)
===============================================================================================================

[![Build Status](https://secure.travis-ci.org/elecoma/elecoma.png)](http://travis-ci.org/elecoma/elecoma)
[![Code Climate](https://codeclimate.com/github/elecoma/elecoma.png)](https://codeclimate.com/github/elecoma/elecoma)
[![Coverage Status](https://coveralls.io/repos/elecoma/elecoma/badge.png)](https://coveralls.io/r/elecoma/elecoma)

エレコマはRuby on Railsで開発したECommerceシステムです。  
オープンソースとしてMIT Licenseを採用しています。


デモ
----

下記ページより、動作画面をご確認いただけます。

- [フロントページ](http://demo-ec.appirits.jp)
- [管理画面](http://demo-ec.appirits.jp/admin)

        ユーザー名: guest
        パスワード: pass


動作環境
--------

エレコマを動かすに辺り、以下の環境を奨励します。  
（下記環境以外でも動作する可能性はあります）

- OS    : CentOS 6.4
- DB    : PostgreSQL 8.4系
- Ruby  : 1.9.3
- Rails : 2.3.18


依存プラグイン
--------------

エレコマではプラグインの一部を含めて配布しています。  
以下のプラグインが同梱されています。

- [active-form](https://github.com/realityforge/rails-active-form)  
  rev: _f1e74bec3d87c23cfc05ca7df11925c08e55514f_

- [acts_as_paranoid](https://github.com/technoweenie/acts_as_paranoid)  
  rev: _b0a5d2b8ba89eae03f673e4af2e52619260fcc30_

- [mbmail](https://github.com/tmtysk/mbmail)  
  rev: _654ce3ec2dfa10ac3b05cd9354eb84456d206a6d_

- [ssl_requirement](https://github.com/rails/ssl_requirement)  
  rev: _34a9a138c4093bd7d5678822f8f1e62c31d47299_

- [double_submit_protection](https://github.com/DianthuDia/double_submit_protection)  
  rev: _7fc2e629b9fccb1736be7ea9da63e578f835a307_

- [image_submit_tag_ext](https://github.com/champierre/image_submit_tag_ext)  
  rev: _572ce5ce5d40ee1494ddd0a121483e8791bb2184_



インストールについて
====================

推奨環境
--------

CentOS 6.4でのインストールを想定しています。  
前提条件は以下となります。

- CentOS 6.4 minimal をインストール済み


インストール手順
----------------

マシンにログイン後、下記手順に従ってコマンドを入力してしてください。

1. Rubyのインストール

  ```
  # yum -y groupinstall "Base" "Development tools"
  # yum -y install zlib-devel
  # yum -y install openssl-devel
  # yum -y install ncurses-devel
  # yum -y install readline-devel
  # wget ftp://ftp.ruby-lang.org/pub/ruby/1.9/ruby-1.9.3-p194.tar.gz
  # tar zxf ruby-1.9.3-p194.tar.gz
  # cd ruby-1.9.3-p194
  # ./configure
  # make
  # make install
  ```

2. RubyGemsのインストール

  ```
  # wget http://rubyforge.org/frs/download.php/76032/rubygems-1.8.23.tgz
  # tar zxf rubygems-1.8.23.tgz
  # cd rubygems-1.8.23
  # ruby setup.rb
  ```

3. ImageMagickのインストール

  ```
  # yum -y install libjpeg-devel libpng-devel gd-devel freetype-devel
  # wget http://ftp.nl.netbsd.org/pub/pub/ImageMagick/ImageMagick-6.8.1-7.tar.gz
  # tar zxf ImageMagick-6.8.1-7.tar.gz
  # cd ImageMagick-6.8.1-7
  # ./configure --disable-openmp
  # make
  # make install
  ```

4. PostgreSQLのインストール

  ```
  # yum -y install postgresql84-devel postgresql84-server
  ```

5. PostgreSQLのセットアップ

  ```
  # /etc/init.d/postgresql initdb
  # vim /var/lib/pgsql/data/pg_hba.conf
  ```

  TYPEが「host」のCIDR-ADDRESSが「127.0.0.1/32」となっている行の、METHODを「md5」(*1) に設定します。  
  (*1 うまく動作しない場合は、ここを「trust」にしてみてください)

  ```
  # /etc/init.d/postgresql start
  # su - postgres
  $ createuser ec
  Shall the new role be a superuser? (y/n) y
  $ psql template1
  # alter user ec with password 'elephant';
  # \q
  ```

6. ecユーザの作成

  ```
  # adduser ec
  # passwd ec
  ```

  パスワードを適当なものに変更してください。

7. エレコマの展開

  ```
  # cd /usr/local
  # git clone git://github.com/elecoma/elecoma.git ec
  # chown -R ec:ec /usr/local/ec
  ```

8. 依存するgemのインストール

  ```
  # gem install bundler --no-ri --no-rdoc
  # su - ec
  $ cd /usr/local/ec
  $ bundle install --path vendor/bundle --without mysql sqlite
  ```

9. 開発向けセットアップ

  ```
  $ cd /usr/local/ec
  $ cd config
  $ cp database.yml.postgresql database.yml
  $ vim database.yml
  $ diff database.yml.postgresql database.yml 
  3,4c3,4
  <   username: postgres
  <   password: 
  ---
  >   username: ec
  >   password: elephant
  ```

  必要であれば ``$RAILS_ROOTenvironments/production.rb`` 内のメールサーバ設定を変更してください。

10. Passengerのインストール

  ```
  # yum -y install gcc-c++
  # yum -y install httpd-devel
  # yum -y install curl-devel
  # gem install passenger
  # passenger-install-apache2-module 
  ```

11. Apacheの設定

  ```
  # vim /etc/httpd/conf.d/ec.conf
  LoadModule passenger_module /usr/local/lib/ruby/gems/1.9.1/gems/passenger-4.0.5/libout/apache2/mod_passenger.so
  PassengerRoot /usr/local/lib/ruby/gems/1.9.1/gems/passenger-4.0.5
  PassengerRuby /usr/local/bin/ruby
  
  <VirtualHost *:80>
    ServerName ec.example.com
    DocumentRoot /usr/local/ec/public
    RailsEnv production
    <Directory /usr/local/ec/public>
      AllowOverride all
      Options -MultiViews
    </Directory>
  </VirtualHost>
  ```

12. production環境のDB作成

  ```
  # su - ec
  $ bundle exec rake db:create db:migrate RAILS_ENV=production
  ```

13. Apacheの再起動

  ```
  # /etc/init.d/httpd restart
  ```

  (※下記コマンドでWEBrickでの起動も可能です)

  ```
  $ bundle exec ruby script/server -e production
  ```

14. メールマガジン用プロセスを起動

  ```
  $ bundle exec ruby lib/daemons/mail.rb -e production start
  ```


管理者ユーザー追加手順
---------------------

エレコマを起動した直後は管理者ユーザーが存在しません。  
ユーザー登録は ``$RAILS_ROOT/test/fixtures/admin_users.yml`` の5，6，8行目を任意のものに修正した後、  
コンソールから以下のようにデータを登録します。

  ```
  $ bundle exec rake db:fixtures:load FIXTURES=admin_users RAILS_ENV=production
  ```

ユーザーを登録した後、管理画面(http://\<ドメイン名\>/admin)にアクセスすると、  
ログイン画面が表示されますので ``$RAILS_ROOT/test/fixtures/admin_users.yml`` で指定した  
登録したログインIDとパスワードでログインしてください。  

なお、初期状態ではSHOPマスタの情報が入っておりませんので、  
SHOPマスタ登録にて初期情報を入力してください。


商品追加手順
------------

エレコマを起動した直後は商品が存在していません。
管理画面から、商品の追加を行う必要があります。

1. 管理者ユーザーでログインする
2. 商品の登録  
   商品登録前に、あらかじめカテゴリ, 規格の設定が必要となります。
   - カテゴリの登録  
     管理画面の ``商品管理`` -> ``カテゴリ管理`` よりカテゴリを登録する
   - 規格の管理  
     管理画面の ``商品管理`` -> ``規格管理`` より規格を登録する
   - 商品の登録
     - 1つずつ登録する場合  
       管理画面の ``商品管理`` -> ``商品登録`` より商品の登録を行う
     - CSVで一括登録する場合  
       管理画面の ``商品管理`` -> ``商品マスタ`` -> ``CSVアップロード`` から アップロードする
3. 商品規格の登録
   1. 商品登録完了画面もしくは商品マスタの ``商品一覧`` -> ``規格登録`` から規格を選択し ``表示する`` をクリックする
   2. 規格リストが表示されるので、必要な規格の登録項目にチェックを入れ、商品コード, 価格を登録する
4. 在庫の登録  
   管理画面の ``発注・出荷管理`` -> ``在庫管理`` より対象商品の在庫数を登録する

以上で、商品がフロント画面に表示されるようになります


住所マスタ更新手順
------------------

エレコマの住所マスタは郵便事業株式会社の郵便番号マスタを利用しています。  
登録はコンソールから以下のように行ないます。

  ```
  $ bundle exec ruby script/runner -e production Zip.import
  ```

郵便番号マスタは以下のサイトにて配布されているものを自動的に取り込みます。  
http://www.post.japanpost.jp/zipcode/download.html

住所マスタ更新機能はLhaLibに依存しています。  
LhaLibの詳細については以下のサイトをご確認ください。  
http://www.artonx.org/collabo/backyard/?LhaLibEn



ユニットテスト
=============

エレコマではユニットテストにRspecを利用しています。  
利用するには、以下のようにコマンドを実行してください。

rspecの実行
-----------

下記コマンドを発行するとユニットテストが実行されます。

  ```
  $ bundle exec ruby script/spec spec
  ```


SSLの切り替え
=============

エレコマではSSLの設定をデータベースに保存しています。  
そのため、万が一管理画面にアクセスできなくなった場合は、  
以下のようにして手動で切替えてください。

  ```
  $ bundle exec ruby script/console production
  >> system = System.first
  >> system.use_ssl = false
  >> system.save
  ```

``use_ssl`` の値は ``true`` の時にSSLを利用し、``false`` の時にSSLを利用しなくなります。



ライセンス
==========

本ソフトウェアはMIT Licenceを採用しています。
ライセンスの詳細についてはCOPYRIGHTファイルを参照してください。

配布物に含まれる「エレコマ」のロゴはクリエイティブ・コモンズノ表示-継承 2.1 
日本ライセンスに従った範囲内でご利用いただけます。



配布物に含まれる別プロジェクトのファイル
========================================

1. さざなみフォント  
配布物に含まれる以下のファイルはさざなみフォントを利用しています。  
    ```lib/sazanami-gothic.ttf```  
さざなみフォントは以下のライセンスに基づきます。  

    Copyright (c) 1990-2003
            Wada Laboratory, the University of Tokyo. All rights reserved.
    Copyright (c) 2003-2004
            Electronic Font Open Laboratory (/efont/). All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions
    are met:
    1. Redistributions of source code must retain the above copyright notice,
       this list of conditions and the following disclaimer.
    2. Redistributions in binary form must reproduce the above copyright notice,
       this list of conditions and the following disclaimer in the documentation
       and/or other materials provided with the distribution.
    3. Neither the name of the Wada Laboratory, the University of Tokyo nor
       the names of its contributors may be used to endorse or promote products
       derived from this software without specific prior written permission.
    
    THIS SOFTWARE IS PROVIDED BY WADA LABORATORY, THE UNIVERSITY OF TOKYO AND
    CONTRIBUTORS ``AS IS'' AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT
    NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
    PARTICULAR PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE LABORATORY OR
    CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
    PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS;
    OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
    WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
    ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
