# Releasing

Convention: vMAJOR.MINOR.PATCH. MAJOR is an incompatible change,
MINOR adds a compatible feature, PATCH fixes a compatible defect.
For this coursework use v1.0.0, v1.1.0, v1.1.1.

Commit and push the intended main branch change, then create an annotated tag:

    git tag -a v1.0.0 -m "Initial website release"
    git push origin v1.0.0

Push one tag at a time. Wait for Jenkins, ECR, and the app to verify that
release before pushing the next tag. Never move, force-push, or reuse tags.
The Docker tag matches the Git tag, and ECR prevents overwriting it.

The GitHub tag event creates a HW3-release tag job, whose default
ACTION=release builds, pushes, deploys, and verifies the image.

To roll back after v1.1.1, open that same tag job and use:

- Build with Parameters
- ACTION = rollback
- VERSION = v1.0.0

The pipeline checks that the old ECR image exists, deploys its exact digest
with a rolling stack update, and verifies two running replicas and version.txt.
Build and push stages are skipped. No image is rebuilt or overwritten.

For a deployment retry of an already-pushed version use ACTION=deploy.
Record real UTC timestamps, versions, images, and build links in
DEPLOYMENT_HISTORY.md. Publish GitHub Release notes for the three tags.

Run Git release commands from the MyHomework repository root.
Change Homework3/index.html for each meaningful release commit.
