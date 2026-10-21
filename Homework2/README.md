# Homework 2 - PocketLedger

Student: Thearin. Add your required school/student ID.

This is a complete sample source project for Homework 2.
It has its own website, Dockerfile, Jenkinsfile, Swarm stack, settings,
ECR role policy, screenshot checklist, and report template.
Cloud resources must still be configured and verified by you.

## Local test - Windows PowerShell

From MyHomework:

    Set-Location .\Homework2
    docker build --build-arg APP_VERSION=local -t homework2:local .
    docker run -d --name hw2-local -p 8088:80 homework2:local
    curl.exe -f http://localhost:8088/version.txt
    docker rm -f hw2-local
    Set-Location ..

## AWS configuration

Edit ci/settings.env for non-secret settings:

- Region: ap-southeast-1
- ECR repository: thearin-homework2
- Swarm stack: homework2
- Swarm service: homework2_web
- Published app port: 80
- App URL: http://MANAGER_PUBLIC_IP/

Replace YOUR_ACCOUNT_ID in aws/jenkins-ecr-policy.json.
Attach this policy to the manager's ThearinJenkinsEcrRole.
When both homework projects use one manager, attach both project policies.
The worker receives registry authentication through --with-registry-auth.

## Jenkins

For the one-repository MyHomework layout:

- Job: HW2-main (Pipeline from SCM)
- Repository: https://github.com/YOUR_GITHUB_USER/MyHomework.git
- Script Path: Homework2/Jenkinsfile
- Node label: swarm-manager
- Built-in executors: 1

The Jenkinsfile detects this project folder. Its helper changes into its own
project directory before Docker build, settings loading, and stack deployment.
If this folder is instead its own standalone repository, use Script Path
Jenkinsfile; the same pipeline also supports that layout.

Push a real change in Homework2/index.html to main. The registered
GitHub webhook triggers checkout, a unique build-number/commit image,
push to private ECR, deploy, and verification. Run Build Now once for setup.
Capture a later automatically triggered run for grading.

After collecting Homework 2 evidence, disable HW2-main before Homework 3's
tag-only tests. The already-deployed homework2 stack stays running on port 80.

## Verify on the manager

    docker node ls
    docker stack services homework2
    docker service ps --no-trunc homework2_web
    docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' homework2_web
    curl -fsS http://127.0.0.1:80/version.txt

## Actual submission values - fill after verification

- Repository/subfolder URL: FILL_IN
- ECR URI and region: FILL_IN
- Live app URL and current version: FILL_IN
- Successful Jenkins build numbers: FILL_IN

Save actual screenshots under screenshots/ and your 1-2 page finished report as
reports/HW2_Report.pdf. The template is not a completed report.
Record real UTC deployment results in DEPLOYMENT_HISTORY.md.
Keep the deployed service available until grading is complete.

The source has been checked locally; no real AWS/Jenkins success is claimed.
See ../SETUP.md and the accompanying setup PDF for all cloud commands.

## Demo application

A personal expense tracker with a budget and remaining balance.
This is a static browser demo served by Nginx; local demo data stays in this browser.
The version footer is supplied by the built image through /version.txt.
