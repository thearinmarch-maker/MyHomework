# Homework 3 screenshot checklist

Use real results from your deployment. Save screenshots in this folder.
Keep credentials, private keys, and webhook/join secrets out of captures.

- 01-local-docker.png: Homework 3 website runs locally.
- 02-tag-only.png: tag discovery, semantic name filter, Tags build strategy.
- 03-branch-ignored.png: a main push starts no release build.
- 04-tags.png: three annotated version tags / release notes.
- 05-ecr.png: thearin-homework3 has v1.0.0, v1.1.0, v1.1.1 and Immutable tags.
- 06-release.png: tag webhook starts a successful release pipeline.
- 07-before.png: public port 8082 app shows v1.1.1.
- 08-rollback.png: rollback v1.0.0 succeeds; build/push are skipped.
- 09-after.png: image digest, 2/2 replicas and app show v1.0.0.
- 10-availability.png: real monitor results across the rollback.
- rollback-availability.log: copy the actual observed log here.
