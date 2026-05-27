<<<<<<< HEAD
# BugBounty — AI-Powered Bug Bounty Platform

Full-stack security challenge platform with Ruby on Rails API, React frontend, AI-generated challenges, real-time multiplayer rooms, and blockchain NFT badges.

## Architecture

```
┌─────────────┐     REST/WS      ┌──────────────┐     Sidekiq    ┌─────────────┐
│   React     │ ◄──────────────► │  Rails API   │ ─────────────► │    Redis    │
│  (Vite)     │                  │  PostgreSQL  │                └─────────────┘
└─────────────┘                  └──────┬───────┘
                                      │
                    ┌─────────────────┼─────────────────┐
                    ▼                 ▼                 ▼
              ┌──────────┐     ┌──────────┐     ┌──────────────┐
              │ Sandbox  │     │ OpenAI   │     │  Blockchain  │
              │ (Docker) │     │   API    │     │  (ERC-721)   │
              └──────────┘     └──────────┘     └──────────────┘
```

## Features

| Feature | Implementation |
|---------|----------------|
| JWT + Google OAuth | `api/v1/auth` endpoints, `@react-oauth/google` |
| AI challenges | `AiChallengeGenerator` service (OpenAI + fallback) |
| Difficulty levels | Easy, Medium, Hard, Expert enums |
| 8 languages | JS, TS, Python, Ruby, Java, C++, Go, Rust |
| Monaco editor | `@monaco-editor/react` |
| AI evaluation | `AiEvaluator` + Docker sandbox |
| XP, score, badges | PostgreSQL models + `BadgeAwardService` |
| Leaderboard | Ranked by score/XP |
| Multiplayer rooms | ActionCable `RoomChannel` |
| Admin dashboard | `/admin` API + React page |
| Hints | Score penalties per hint level |
| NFT badges | Solidity contract + `BlockchainService` |
| Wallet | MetaMask via `ethers.js` |
| Dark mode | Tailwind `darkMode: class` |

## Quick Start (Docker)

**Prerequisites:** Docker Desktop

```bash
# Clone and configure
cp .env.example .env
# Optional: add OPENAI_API_KEY and GOOGLE_CLIENT_ID to .env

# Start all services
docker compose up --build

# Access
# Frontend:  http://localhost
# API:       http://localhost:3000
# Sidekiq:   http://localhost:3000/sidekiq
# Sandbox:   http://localhost:8080/health
```

**Default admin account** (from seeds):

- Email: `admin@bugbounty.dev`
- Password: `Admin123!Secure`

## Local Development

### Backend (requires Ruby 3.2+, PostgreSQL, Redis)

```bash
cd backend
cp .env.example .env
bundle install
rails db:create db:migrate db:seed
bundle exec puma          # Terminal 1
bundle exec sidekiq       # Terminal 2
```

### Sandbox

```bash
cd sandbox
npm install
npm start   # http://localhost:8080
```

### Frontend (requires Node 18+)

```bash
cd frontend
cp .env.example .env
npm install
npm run dev   # http://localhost:5173
```

## API Overview

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/api/v1/auth/register` | Email registration |
| POST | `/api/v1/auth/login` | JWT login |
| POST | `/api/v1/auth/google` | Google OAuth (`id_token`) |
| GET | `/api/v1/challenges` | List challenges |
| POST | `/api/v1/challenges/generate` | AI-generate challenge |
| POST | `/api/v1/challenges/:id/submit` | Submit fix |
| POST | `/api/v1/challenges/:id/hint` | Request hint |
| GET | `/api/v1/leaderboard` | Rankings |
| POST | `/api/v1/rooms` | Create multiplayer room |
| WS | `/cable` | ActionCable (rooms, submissions) |
| GET | `/api/v1/admin/dashboard` | Admin stats |

All authenticated routes require `Authorization: Bearer <token>`.

## Security

- JWT with refresh tokens and HS256 signing
- CORS restricted to configured origins
- Sandbox runs code in isolated containers with timeouts
- Parameter filtering for secrets in logs
- Wallet connection requires signed message verification
- Admin routes protected by role check

## Project Structure

```
pr2/
├── backend/          # Rails 7 API
│   ├── app/
│   │   ├── controllers/api/v1/
│   │   ├── models/
│   │   ├── services/     # AI, sandbox, blockchain
│   │   ├── jobs/         # Sidekiq workers
│   │   └── channels/     # ActionCable
│   └── db/
├── frontend/         # React + Vite + Tailwind
│   └── src/
│       ├── pages/
│       ├── components/
│       └── lib/
├── sandbox/          # Secure code execution service
├── contracts/        # ERC-721 NFT badge contract
└── docker-compose.yml
```

## Environment Variables

See `backend/.env.example` and `frontend/.env.example` for full list.

| Variable | Purpose |
|----------|---------|
| `JWT_SECRET` | Token signing (min 32 chars in production) |
| `OPENAI_API_KEY` | AI challenge generation & evaluation |
| `GOOGLE_CLIENT_ID` | Google OAuth |
| `SANDBOX_URL` | Code execution service |
| `NFT_CONTRACT_ADDRESS` | On-chain badge contract |

## Production Notes

1. Set strong `JWT_SECRET` and enable `FORCE_SSL`
2. Use managed PostgreSQL and Redis
3. Deploy sandbox with strict resource limits and network isolation
4. Deploy `contracts/BugBountyBadge.sol` and set `NFT_CONTRACT_ADDRESS`
5. Configure CDN for frontend static assets

## License

MIT
=======
# Bug-bounty-system
>>>>>>> cda0c3872540329f61cd3424c280e44fa626f5fa
