# Homework 3 - PocketLedger

Student: Thearin. Add your required school/student ID.

This is a complete sample source project for Homework 3.
It has its own website, Dockerfile, Jenkinsfile, Swarm stack, settings,
ECR role policy, screenshot checklist, and report template.
Cloud resources must still be configured and verified by you.

## Local test - Windows PowerShell

From MyHomework:

    Set-Location .\Homework3
    docker build --build-arg APP_VERSION=local -t homework3:local .
    docker run -d --name hw3-local -p 8089:80 homework3:local
    curl.exe -f http://localhost:8089/version.txt
    docker rm -f hw3-local
    Set-Location ..

## AWS configuration

Edit ci/settings.env for non-secret settings:

- Region: ap-southeast-1
- ECR repository: thearin-homework3
- Swarm stack: homework3
- Swarm service: homework3_web
- Published app port: 8082
- App URL: http://MANAGER_PUBLIC_IP:8082/

Replace YOUR_ACCOUNT_ID in aws/jenkins-ecr-policy.json.
Attach this policy to the manager's ThearinJenkinsEcrRole.
When both homework projects use one manager, attach both project policies.
The worker receives registry authentication through --with-registry-auth.

## Jenkins

For the one-repository MyHomework layout:

- Job: HW3-release (GitHub Multibranch Pipeline)
- Repository: https://github.com/YOUR_GITHUB_USER/MyHomework.git
- Script Path: Homework3/Jenkinsfile
- Node label: swarm-manager
- Built-in executors: 1

The Jenkinsfile detects this project folder. Its helper changes into its own
project directory before Docker build, settings loading, and stack deployment.
If this folder is instead its own standalone repository, use Script Path
Jenkinsfile; the same pipeline also supports that layout.

Discover tags only; remove branch/PR discovery. Add a semantic version
name filter and the Tags build strategy with both age filters off.
Create tags only after this Homework3/Jenkinsfile is committed.

ACTION parameters:

| ACTION | Behavior |
| --- | --- |
| release | Build, push, deploy, verify; automatic default |
| build | Build locally only |
| push | Build and push only |
| deploy | Deploy an existing ECR image and verify; no build/push |
| rollback | Deploy a prior existing ECR image and verify; no build/push |

VERSION blank uses the discovered tag. For rollback from v1.1.1 set
ACTION=rollback and VERSION=v1.0.0 in the same tag child job.
All three immutable ECR versions must remain available.
Use ACTION=deploy to retry a version that has already been pushed.

## Verify on the manager

    docker node ls
    docker stack services homework3
    docker service ps --no-trunc homework3_web
    docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' homework3_web
    curl -fsS http://127.0.0.1:8082/version.txt

## Actual submission values - fill after verification

- Repository/subfolder URL: FILL_IN
- ECR URI and region: FILL_IN
- Live app URL and current version: FILL_IN
- Successful Jenkins build numbers: FILL_IN

Save actual screenshots under screenshots/ and your 1-2 page finished report as
reports/HW3_Report.pdf. The template is not a completed report.
Record real UTC deployment results in DEPLOYMENT_HISTORY.md.
Keep the deployed service available until grading is complete.

The source has been checked locally; no real AWS/Jenkins success is claimed.
See ../SETUP.md and the accompanying setup PDF for all cloud commands.

## Demo application

A personal expense tracker with a budget and remaining balance.
This is a static browser demo served by Nginx; local demo data stays in this browser.
The version footer is supplied by the built image through /version.txt.
