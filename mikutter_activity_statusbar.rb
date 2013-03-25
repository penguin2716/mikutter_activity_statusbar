# -*- coding: utf-8 -*-

Plugin.create :activity_statusbar do

  def update(status_message, avtivity_type, span = 10)
    if span <= 0 or span > 600
      span = 600
    end
    Thread.new {
      context = (("a".."z").to_a + ("A".."Z").to_a + (0..9).to_a).shuffle[0..7].join
      statusbar = ObjectSpace.each_object(Gtk::Statusbar).to_a.first
      statusbar.push(statusbar.get_context_id(context), Time.now.strftime(" [Activity::#{avtivity_type} (%H:%M:%S)] ") + status_message)
      sleep span
      statusbar.pop(statusbar.get_context_id(context))
    }
  end

  on_favorite do |service, user, message|
    update "@#{user[:idname]} が @#{message.user[:idname]} のツイートをふぁぼりました" + ': ' + message.to_s.gsub(/\s/, ' '), 'Favorite'
  end

  on_unfavorite do |service, user, message|
    update "@#{user[:idname]} が @#{message.user[:idname]} のツイートをあんふぁぼしました" + ': ' + message.to_s.gsub(/\s/, ' '), 'Unfavorite'
  end

  on_retweet do |retweets|
    retweets.each do |retweet|
      retweet.retweet_source_d.next { |source|
        update "@#{retweet.user[:idname]} が @#{source.user[:idname]} のツイートをリツイートしました" + ': ' + source.to_s.gsub(/\s/, ' '), 'Retweet'
      }
    end
  end

  on_list_member_added do |service, user, list, source_user|
    update "@#{user[:idname]} が @#{source_user[:idname]} のリスト「#{list[:full_name]}」に追加されました", 'List_Add'
  end

  on_list_member_removed do |service, user, list, source_user|
    update "@#{user[:idname]} が @#{source_user[:idname]} のリスト「#{list[:full_name]}」から削除されました", 'List_Remove'
  end

  on_follow do |by, to|
    update "@#{by[:idname]} が @#{to[:idname]} をフォローしました", 'Follow'
  end

  on_direct_messages do |service, dms|
    dms.each { |dm|
      date = Time.parse(dm[:created_at])
      if date > BOOT_TIME
        if dm[:sender].is_me?
          update "@#{dm[:recipient][:idname]} にダイレクトメッセージを送信しました" + ': ' + dm.to_s.gsub(/\s/, ' '), 'DM_Send'
        else
          update "@#{dm[:sender][:idname]} からダイレクトメッセージを受信しました" + ': ' + dm.to_s.gsub(/\s/, ' '), 'DM_Receive'
        end
      end
    }
  end

  on_mention do |service, messages|
    messages.each do |message|
      update "@#{message.user[:idname]} からリプライが来ました" + ': ' + message.to_s.gsub(/\s/, ' '), 'Reply'
    end
  end

end
