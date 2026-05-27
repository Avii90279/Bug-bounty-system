class RoomSerializer
  def initialize(room)
    @room = room
  end

  def as_json
    @room.room_payload
  end
end
