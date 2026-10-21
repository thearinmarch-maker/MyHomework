#!/usr/bin/env bash
set -euo pipefail
PROJECT_ROOT=$(cd -- "$(dirname -- "$0")/.." && pwd)
cd "$PROJECT_ROOT"
if [ "$#" -ne 2 ]; then
  echo "Usage: bash ci/pipeline.sh build|push|deploy|rollback|verify VERSION"
  exit 2
fi
ACTION="$1"
VERSION="$2"
if ! [[ "$VERSION" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
  echo "Invalid version: $VERSION"; exit 2
fi
source ci/settings.env
export APP_PORT AWS_REGION AWS_DEFAULT_REGION="$AWS_REGION" AWS_PAGER=""
# Snap's AWS CLI executable is available to the Jenkins service too.
export PATH="/snap/bin:$PATH"
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
REGISTRY="$ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com"
IMAGE_REF="$REGISTRY/$ECR_REPO:$VERSION"
SERVICE="$STACK_NAME"_web
GIT_SHA=$(git rev-parse HEAD)
AUTH_DIR=$(mktemp -d)
trap 'rm -rf "$AUTH_DIR"' EXIT

lookup_digest() {
  if DIGEST=$(aws ecr describe-images \
      --repository-name "$ECR_REPO" --image-ids imageTag="$VERSION" \
      --query 'imageDetails[0].imageDigest' --output text \
      2>"$AUTH_DIR/error"); then
    return 0
  fi
  if grep -q 'ImageNotFoundException' "$AUTH_DIR/error"; then
    return 1
  fi
  cat "$AUTH_DIR/error" >&2
  exit 1
}
require_absent() {
  if lookup_digest; then
    echo "Image already exists. Use deploy or rollback; never overwrite."
    exit 1
  fi
}
require_image() {
  if ! lookup_digest; then
    echo "No existing ECR image for $VERSION"; exit 1
  fi
  export IMAGE_URI="$IMAGE_REF@$DIGEST"
}
login_ecr() {
  aws ecr get-login-password --region "$AWS_REGION" |
    docker --config "$AUTH_DIR" login --username AWS \
      --password-stdin "$REGISTRY"
}
case "$ACTION" in
  build)
    require_absent
    docker build --build-arg APP_VERSION="$VERSION" \
      --build-arg GIT_SHA="$GIT_SHA" -t "$IMAGE_REF" .
    ;;
  push)
    require_absent
    BUILT_SHA=$(docker image inspect --format \
      '{{index .Config.Labels "org.opencontainers.image.revision"}}' \
      "$IMAGE_REF")
    test "$BUILT_SHA" = "$GIT_SHA"
    login_ecr
    docker --config "$AUTH_DIR" push "$IMAGE_REF"
    ;;
  deploy|rollback)
    require_image
    echo "$ACTION: using existing $IMAGE_URI (no build here)"
    login_ecr
    docker --config "$AUTH_DIR" stack deploy --with-registry-auth \
      --compose-file docker-stack.yml "$STACK_NAME"
    ;;
  verify)
    require_image
    READY=false
    for attempt in $(seq 1 60); do
      STATE=$(docker service inspect --format \
        '{{if .UpdateStatus}}{{.UpdateStatus.State}}{{end}}' "$SERVICE")
      case "$STATE" in
        paused|rollback_paused|rollback_completed)
          echo "Update did not reach requested image: $STATE"; exit 1 ;;
      esac
      SPEC_IMAGE=$(docker service inspect --format \
        '{{.Spec.TaskTemplate.ContainerSpec.Image}}' "$SERVICE")
      TASKS_OK=$(docker service ps --no-trunc \
        --filter desired-state=running --format '{{json .}}' "$SERVICE" |
        jq -s --arg image "$IMAGE_REF" \
          'length == 2 and all(.[];
           (.CurrentState | startswith("Running")) and
           ((.Image | split("@")[0]) == $image))')
      if [ "$SPEC_IMAGE" = "$IMAGE_URI" ] && [ "$TASKS_OK" = true ]; then
        LIVE=$(curl -fsS --connect-timeout 2 --max-time 3 \
          "http://127.0.0.1:$APP_PORT/version.txt" || true)
        if [ "$LIVE" = "$VERSION" ] &&
           { [ -z "$STATE" ] || [ "$STATE" = completed ]; }; then
          READY=true; break
        fi
      fi
      sleep 3
    done
    if [ "$READY" != true ]; then
      docker service ps --no-trunc "$SERVICE"; exit 1
    fi
    {
      date -u '+UTC: %Y-%m-%dT%H:%M:%SZ'
      printf 'Version: %s\nImage: %s\n' "$VERSION" "$IMAGE_URI"
      printf 'Source commit: %s\n' "$GIT_SHA"
      printf 'Action: %s\n' "$(printenv DO_ACTION || true)"
      docker node ls
      docker stack services "$STACK_NAME"
      docker service ps --no-trunc "$SERVICE"
      printf 'Live version: %s\n' "$LIVE"
    } | tee "deployment-$VERSION.txt"
    ;;
  *)
    echo "Unknown action: $ACTION"; exit 2 ;;
esac
