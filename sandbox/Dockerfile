FROM node:20-alpine

RUN apk add --no-cache python3 py3-pip ruby go gcc musl-dev

WORKDIR /app
COPY package.json ./
RUN npm install --production

COPY . .

EXPOSE 8080
USER node

CMD ["node", "server.js"]
