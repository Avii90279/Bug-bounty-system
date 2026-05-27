class Room < ApplicationRecord
  enum status: { waiting: 0, active: 1, finished: 2 }

  belongs_to :host, class_name: "User"
  belongs_to :challenge, optional: true
  has_many :room_participants, dependent: :destroy
  has_many :participants, through: :room_participants, source: :user

  validates :name, presence: true
  validates :code, presence: true, uniqueness: true

  before_validation :generate_code, on: :create

  def full?
    room_participants.count >= max_players
  end

  def broadcast_state
    RoomChannel.broadcast_to(self, payload: room_payload)
  end

  def room_payload
    {
      id: id,
      code: code,
      name: name,
      status: status,
      host_id: host_id,
      challenge_id: challenge_id,
      participants: room_participants.includes(:user).map do |rp|
        { user_id: rp.user_id, username: rp.user.username, score: rp.score, finished: rp.finished }
      end
    }
  end

  private

  def generate_code
    self.code ||= SecureRandom.alphanumeric(6).upcase
  end
end
