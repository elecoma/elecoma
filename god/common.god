God::Contacts::Email.message_settings = {
  :from => "kbmjec@gmail.com"
}

God::Contacts::Email.server_settings = {
  :address => '127.0.0.1',
  :port => 25
}

God.contact(:email) do |c|
  c.name = "god"
  c.email = "ec@kbmj.com"
end

# レスポンス監視用
def watch_kill(n, u, g, w, port, rails_root, rails_env, path = "/")
 mongrel_options = ""
 if "/" != path
   mongrel_options << " --prefix #{path}"
 end
 w.name = "#{n}-mongrel-#{port}"  # mongrelの名前を渡す
 w.uid = u  # ユーザ名を渡す
 w.gid = g  # グループ名を渡す
 w.group = "mongrel_cluster"
 w.interval = 30.seconds # default
 w.pid_file = File.join(rails_root, "log/mongrel.#{port}.pid")
 #w.start = "mongrel_rails start -d -e #{rails_env} -c #{rails_root} -p #{port} -P #{w.pid_file} -l log/mongrel.#{port}.log #{mongrel_options}"
 #w.start = "mongrel_rails cluster::start -C #{RAILS_ROOT}/config/mongrel_cluster_#{RAILS_ENV}.yml"
 w.start = "mongrel_rails cluster::start -C #{rails_root}/config/mongrel_cluster.yml"
 # w.stop = "mongrel_rails stop -P #{w.pid_file}"
 # killコマンド
 # RMコマンドでPIDファイルを削除、PSで停止対象のプロセスIDを取得
 # 結果をパイプしプロセスIDのみを出力、KILLコマンドでmongrelを強制終了
 w.stop = "rm -f #{w.pid_file}; ps -o pid,command -C mongrel_rails -U #{w.uid}|grep \"p $port\"|awk '{print $1}'|xargs kill -9"
 # あとで PID を元にログを追えるように、pid ファイルをバックアップ
 w.restart = "cp -f #{w.pid_file} #{w.pid_file}.old; #{w.stop}; sleep 1; #{w.start}"
 w.start_grace = 10.seconds
 w.restart_grace = 10.seconds

 w.behavior(:clean_pid_file)

 # プロセス監視
 # w.start_if do |start|
 #   start.condition(:process_running) do |c|
 #     c.interval = 10.seconds
 #     c.running = false
 #     c.notify = "god"
 #   end
 # end

 # メモリ監視
 # w.restart_if do |restart|
 #   restart.condition(:memory_usage) do |c|
 #     c.interval = 10.seconds
 #     c.above = 250.megabytes
 #     c.times = [3, 5] # 3 out of 5 intervals
 #     c.notify = "god"
 #   end
 # end

 # レスポンス監視
 w.restart_if do |restart|
   restart.condition(:http_response_code) do |c|
     c.host = "localhost"
     c.port = port
     c.path = path
     c.code_is_not = [200, 301, 302]
     c.times = [2, 2]
     c.notify = "god"
   end
 end

 # 監視間隔
 w.lifecycle do |on|
   on.condition(:flapping) do |c|
     c.to_state = [:start, :restart]
     c.times = 5
     c.within = 5.minute
     c.transition = :unmonitored
     c.retry_in = 10.minutes
     c.retry_times = 5
     c.retry_within = 2.hours
   end
 end
end

# プロセス/メモリ監視用
def watch_restart(n, u, g, w, port, rails_root, rails_env, path = "/")
 mongrel_options = ""
 if "/" != path
   mongrel_options << " --prefix #{path}"
 end
 w.name = "#{n}-mongrel-#{port}"  # mongrelの名前を渡す
 w.uid = u  # ユーザ名を渡す
 w.gid = g  # グループ名を渡す
 w.group = "mongrel_cluster"
 w.interval = 30.seconds # default
 w.pid_file = File.join(rails_root, "log/mongrel.#{port}.pid")
 w.start = "mongrel_rails cluster::start -C #{rails_root}/config/mongrel_cluster.yml"
 w.stop = "mongrel_rails stop -P #{w.pid_file}"  # 通常のstopコマンド
 # あとで PID を元にログを追えるように、pid ファイルをバックアップ
 w.restart = "cp -f #{w.pid_file} #{w.pid_file}.old; #{w.stop}; sleep 1; #{w.start}"
 w.start_grace = 10.seconds
 w.restart_grace = 10.seconds

 w.behavior(:clean_pid_file)

 # プロセス監視
 w.start_if do |start|
   start.condition(:process_running) do |c|
     c.interval = 10.seconds
     c.running = false
     c.notify = "god"
   end
 end

 # メモリ監視
 w.restart_if do |restart|
   restart.condition(:memory_usage) do |c|
     c.interval = 10.seconds
     c.above = 400.megabytes
     c.times = [3, 5] # 3 out of 5 intervals
     c.notify = "god"
   end
 end

 # 監視間隔
 w.lifecycle do |on|
   on.condition(:flapping) do |c|
     c.to_state = [:start, :restart]
     c.times = 5
     c.within = 5.minute
     c.transition = :unmonitored
     c.retry_in = 10.minutes
     c.retry_times = 5
     c.retry_within = 2.hours
   end
 end
end

