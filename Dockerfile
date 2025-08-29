# Build stage
FROM node:20-alpine AS frontend
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY app/ ./app/
COPY data/ ./data/
COPY img/ ./img/
COPY public/index.html ./public/
RUN npm run build

FROM golang:1.22.6-alpine AS builder
WORKDIR /app
COPY go.mod go.sum ./
RUN go mod download
COPY . .
COPY --from=frontend /app/public ./public
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

FROM alpine:latest

RUN apk --no-cache add ca-certificates tzdata

WORKDIR /root/
COPY --from=builder /app/main .
COPY --from=builder /app/public ./public

EXPOSE 8080

CMD ["./main"]
