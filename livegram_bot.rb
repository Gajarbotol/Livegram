require 'telegram/bot'
require 'sinatra'

TOKEN = ENV['TOKEN']
ADMIN_CHAT_ID = ENV['ADMIN_CHAT_ID']

$messages = {}

set :port, 3000

get '/' do
  'Bot is running!'
end

post "/#{TOKEN}" do
  request_data = JSON.parse(request.body.read)
  message = Telegram::Bot::Types::Update.new(request_data).message

  if message
    if message.text == '/start'
      # Respond to the /start command with a welcome message
      bot.api.send_message(
        chat_id: message.chat.id, 
        text: "Welcome to the Livegram Bot! 😊\n\nThis bot allows you to send messages directly to the admin. Feel free to ask any questions or share your thoughts. An admin will get back to you shortly!"
      )
    elsif message.chat.id.to_s == ADMIN_CHAT_ID
      # Admin is replying, forward the message back to the original sender
      original_message_id = message.reply_to_message.message_id
      original_data = $messages[original_message_id]

      if original_data
        bot.api.send_message(
          chat_id: original_data[:chat_id], 
          text: message.text, 
          reply_to_message_id: original_data[:message_id]
        )
      else
        bot.api.send_message(chat_id: ADMIN_CHAT_ID, text: "Error: Original message not found.")
      end
    else
      # User sends a message, forward it to the admin
      forwarded_message = bot.api.forward_message(
        chat_id: ADMIN_CHAT_ID, 
        from_chat_id: message.chat.id, 
        message_id: message.message_id
      )

      # Store original message details for potential replies
      $messages[forwarded_message['message_id']] = { chat_id: message.chat.id, message_id: message.message_id }

      bot.api.send_message(chat_id: message.chat.id, text: "Your message has been forwarded to the admin.")
    end
  end
  status 200
end

Telegram::Bot::Client.run(TOKEN) do |bot|
  bot.api.set_webhook(url: "https://your-vercel-app.vercel.app/#{TOKEN}")
end
