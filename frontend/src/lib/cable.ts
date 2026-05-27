import { createConsumer, Consumer } from "@rails/actioncable";
import { useAuthStore } from "../store/authStore";

const CABLE_URL = import.meta.env.VITE_CABLE_URL || "ws://localhost:3000/cable";

let consumer: Consumer | null = null;

export function getCableConsumer(): Consumer {
  if (!consumer) {
    const token = useAuthStore.getState().token;
    consumer = createConsumer(`${CABLE_URL}?token=${token}`);
  }
  return consumer;
}

export function resetCable() {
  consumer?.disconnect();
  consumer = null;
}
