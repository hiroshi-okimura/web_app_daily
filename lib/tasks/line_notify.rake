namespace :line_notify do
  desc "LINE通知メッセージ送信"
  task send_line_message: :environment do
    client = Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }

    # UTC時間に9時間を加算して日本時間を取得
    current_hour_jst = (Time.current.utc.hour + 9) % 24

    # 日本時間をUTCに変換
    current_hour_utc = (current_hour_jst - 9) % 24

    users_to_notify = User.where("EXTRACT(HOUR FROM notify_time AT TIME ZONE 'UTC') = ?", current_hour_utc)
    users_to_notify.each do |user|
      next unless user.uid # user.uidがnilや空の場合は次のループへ
      
      message = {
        type: 'text',
        text: "新しいWebアプリが提供されています!\n確認しましょう!(PC推奨です)\n\nhttps://web-app-diary-387ded82e725.herokuapp.com/"
      }
      response = client.push_message(user.uid, message)
      p response
    end
  end
end