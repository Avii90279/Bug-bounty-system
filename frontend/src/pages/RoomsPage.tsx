import { useEffect, useState } from "react";
import { Link, useNavigate } from "react-router-dom";
import { Plus, Users } from "lucide-react";
import toast from "react-hot-toast";
import api from "../lib/api";
import type { Room } from "../types";

export default function RoomsPage() {
  const [rooms, setRooms] = useState<Room[]>([]);
  const navigate = useNavigate();

  useEffect(() => {
    api.get("/rooms").then(({ data }) => setRooms(data.rooms));
  }, []);

  const createRoom = async () => {
    try {
      const { data } = await api.post("/rooms", { name: "Bug Hunt Room" });
      toast.success(`Room created: ${data.code}`);
      navigate(`/rooms/${data.id}`);
    } catch {
      toast.error("Failed to create room");
    }
  };

  return (
    <div>
      <div className="flex justify-between items-center mb-8">
        <div>
          <h1 className="text-3xl font-bold">Multiplayer Rooms</h1>
          <p className="text-slate-400 mt-1">Compete in real-time bug hunting</p>
        </div>
        <button onClick={createRoom} className="btn-primary flex items-center gap-2">
          <Plus className="h-4 w-4" /> Create Room
        </button>
      </div>

      <div className="grid md:grid-cols-2 gap-4">
        {rooms.map((room) => (
          <Link key={room.id} to={`/rooms/${room.id}`} className="card hover:border-brand-500/50 block">
            <div className="flex justify-between">
              <h3 className="font-semibold">{room.name}</h3>
              <span className="font-mono text-brand-400">{room.code}</span>
            </div>
            <p className="text-slate-400 text-sm mt-2 flex items-center gap-1">
              <Users className="h-4 w-4" /> {room.participants.length} players · {room.status}
            </p>
          </Link>
        ))}
        {!rooms.length && <p className="text-slate-400 col-span-2 text-center py-12">No active rooms — create one!</p>}
      </div>
    </div>
  );
}
