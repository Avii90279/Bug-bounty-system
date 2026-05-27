class RoomChannel < ApplicationCable::Channel
  def subscribed
    room = Room.find(params[:room_id])
    stream_for room
  end

  def unsubscribed
    stop_all_streams
  end

  def update_progress(data)
    room = Room.find(params[:room_id])
    participant = room.room_participants.find_by(user: current_user)
    return unless participant

    participant.update!(score: data["score"], finished: data["finished"])
    room.broadcast_state
  end
end
