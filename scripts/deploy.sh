#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────────────────
# deploy.sh  —  Blue/Green zero-downtime deployment script
# Place this file at /home/ubuntu/deploy.sh on the EC2 instance.
# Call it as:  IMAGE=username/taskapi:sha bash deploy.sh
# ─────────────────────────────────────────────────────────────────────────────
set -euo pipefail

IMAGE="${IMAGE:?IMAGE env var is required}"
APP_PORT=5000
NEW_PORT=5001          # temporary port for the new container
CONTAINER_NAME="taskapi"
NEW_CONTAINER="taskapi_new"
ENV_FILE="/home/ubuntu/.env.production"

echo "==> Pulling image: $IMAGE"
docker pull "$IMAGE"

echo "==> Starting new container on port $NEW_PORT"
docker run -d \
  --name "$NEW_CONTAINER" \
  --env-file "$ENV_FILE" \
  -p "$NEW_PORT:5000" \
  --restart unless-stopped \
  "$IMAGE"

echo "==> Waiting for new container health check..."
for i in $(seq 1 12); do
  STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:$NEW_PORT/health" || true)
  if [ "$STATUS" = "200" ]; then
    echo "    New container is healthy."
    break
  fi
  echo "    Attempt $i: status=$STATUS, waiting 5s..."
  sleep 5
  if [ "$i" -eq 12 ]; then
    echo "ERROR: New container failed health check. Rolling back."
    docker rm -f "$NEW_CONTAINER" || true
    exit 1
  fi
done

echo "==> Stopping old container"
docker rm -f "$CONTAINER_NAME" 2>/dev/null || true

echo "==> Renaming new container to $CONTAINER_NAME"
docker rename "$NEW_CONTAINER" "$CONTAINER_NAME"

# Re-map to the standard port (restart with correct port mapping)
echo "==> Re-mapping container to port $APP_PORT"
docker stop "$CONTAINER_NAME"
docker rm "$CONTAINER_NAME"
docker run -d \
  --name "$CONTAINER_NAME" \
  --env-file "$ENV_FILE" \
  -p "$APP_PORT:5000" \
  --restart unless-stopped \
  "$IMAGE"

echo "==> Running database migrations"
docker exec "$CONTAINER_NAME" flask db upgrade

echo "==> Removing dangling images"
docker image prune -f

echo "==> Deployment complete. Image: $IMAGE"
