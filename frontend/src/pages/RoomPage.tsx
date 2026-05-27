import { useEffect, useState } from "react";
import { useParams } from "react-router-dom";
import api from "../lib/api";
import { getCableConsumer } from "../lib/cable";
import type { Room } from "../types";

export default function RoomPage() {
  const { id } = useParams();
  const [room, setRoom] = useState<Room | null>(null);

  useEffect(() => {
    api.get(`/rooms/${id}`).then(({ data }) => setRoom(data));
  }, [id]);

  useEffect(() => {
    if (!id) return;
    const consumer = getCableConsumer();
    const sub = consumer.subscriptions.create(
      { channel: "RoomChannel", room_id: id },
      {
        received(data: { payload: Room }) {
          setRoom(data.payload);
        }
      }
    );
    return () => sub.unsubscribe();
  }, [id]);

  const startRoom = async () => {
    const { data } = await api.post(`/rooms/${id}/start`);
    setRoom(data);
  };

  if (!room) return <div className="text-center py-20">Loading room...</div>;

  return (
    <div className="max-w-2xl mx-auto space-y-6">
      <div className="card text-center">
        <p className="text-slate-400">Room Code</p>
        <p className="text-4xl font-mono font-bold text-brand-400 tracking-widest">{room.code}</p>
        <h1 className="text-xl font-semibold mt-4">{room.name}</h1>
        <p className="text-slate-500 capitalize mt-1">{room.status}</p>
        {room.status === "waiting" && (
          <button onClick={startRoom} className="btn-primary mt-6">Start Challenge</button>
        )}
      </div>

      <div className="card">
        <h2 className="font-semibold mb-4">Participants</h2>
        <ul className="space-y-2">
          {room.participants.map((p) => (
            <li key={p.user_id} className="flex justify-between py-2 border-b border-slate-800 last:border-0">
              <span>{p.username}</span>
              <span className="font-mono text-brand-400">{p.score} pts {p.finished && "✓"}</span>
            </li>
          ))}
        </ul>
      </div>
    </div>
  );
}
