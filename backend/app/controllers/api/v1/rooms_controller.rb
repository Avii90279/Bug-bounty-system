module Api
  module V1
    class RoomsController < ApplicationController
      before_action :set_room, only: [:show, :join, :leave, :start]

      def index
        rooms = Room.waiting.includes(:host, :room_participants).order(created_at: :desc).limit(20)
        render json: { rooms: rooms.map { |r| RoomSerializer.new(r).as_json } }
      end

      def show
        render json: RoomSerializer.new(@room).as_json
      end

      def create
        room = current_user.hosted_rooms.create!(
          name: params[:name] || "#{current_user.username}'s Room",
          challenge_id: params[:challenge_id],
          max_players: params[:max_players] || 8
        )
        room.room_participants.create!(user: current_user, joined_at: Time.current)
        room.broadcast_state
        render json: RoomSerializer.new(room).as_json, status: :created
      end

      def join
        return render json: { error: "Room is full" }, status: :unprocessable_entity if @room.full?

        @room.room_participants.find_or_create_by!(user: current_user) { |rp| rp.joined_at = Time.current }
        @room.broadcast_state
        render json: RoomSerializer.new(@room).as_json
      end

      def leave
        @room.room_participants.find_by(user: current_user)&.destroy
        @room.broadcast_state
        head :no_content
      end

      def start
        return render json: { error: "Only host can start" }, status: :forbidden unless @room.host_id == current_user.id

        @room.update!(status: :active, started_at: Time.current, challenge_id: params[:challenge_id] || @room.challenge_id)
        @room.broadcast_state
        render json: RoomSerializer.new(@room).as_json
      end

      private

      def set_room
        @room = Room.find(params[:id])
      end
    end
  end
end
