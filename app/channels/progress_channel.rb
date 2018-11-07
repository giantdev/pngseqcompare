class ProgressChannel < ApplicationCable::Channel
  def subscribed
    # stream_from "some_channel"
    stream_from "progress_channel_#{params[:unq]}"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  # def receive(data)
  #   ActionCable.server.broadcast "progress_channel_#{params[:unq]}", data
  # end
end
