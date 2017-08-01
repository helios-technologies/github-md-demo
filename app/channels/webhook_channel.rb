class WebhookChannel < ApplicationCable::Channel
  def subscribed
    stream_from 'webhook_channel'
  end
end
