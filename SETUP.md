# MyHomework
Two complete projects

Homework 2 + Homework 3 | Setup instructions | 16 October 2026

**Use this package**

Extract MyHomework_Thearin.zip. Create one GitHub repository named MyHomework. It contains two full source projects named after your teacher's Homework 2 and Homework 3.

| Project | Purpose | Public app |
| --- | --- | --- |
| Homework2/ | Automatic deployment from main pushes | http://MANAGER_PUBLIC_IP/ |
| Homework3/ | Three tagged releases and a real rollback | http://MANAGER_PUBLIC_IP:8082/ |

Student: Thearin. Demo: PocketLedger. A personal expense tracker with a budget and remaining balance. PDF optional: keep this guide locally; optional/*.pdf is excluded from Git commits. Read important.txt before submission.

## Which files go in each folder?

| File / folder | Homework2 | Homework3 |
| --- | --- | --- |
| index.html, Dockerfile | Own website and image | Own website and image |
| Jenkinsfile | Main-push pipeline | Tag/parameter/rollback pipeline |
| docker-stack.yml | homework2 stack / port 80 | homework3 stack / port 8082 |
| ci/ | Own settings and helper | Own settings/helper + observer |
| aws/ | Own ECR IAM policy | Own ECR IAM policy |
| README + deployment history | Own usage and real results | Own usage and real results |
| RELEASING.md | Not needed | Release and rollback instructions |
| screenshots/ | HW2 screenshots | HW3 screenshots and log |
| reports/ | Write HW2_Report.pdf | Write HW3_Report.pdf |

All source files are already in their correct folders. FILE_MAP.md gives the exact mapping. Each folder also includes its own .gitignore, .dockerignore, and .gitattributes. Both Jenkinsfiles already handle this repository layout.

## Where to run commands

LOCAL: Windows PowerShell. MANAGER: Ubuntu manager SSH. WORKER: Ubuntu worker SSH. BROWSER: AWS, GitHub, Jenkins, or your app.

Use one manager + one worker and one Jenkins installation for both projects. Each project uses a separate private ECR repository and Swarm stack. This source is prepared for you to run; the reports must contain your actual results.

# Step 1 - Extract and configure

WHERE: LOCAL - Windows PowerShell

Start Docker Desktop in Linux container mode. You also need Git, VS Code, GitHub, and an AWS account permitted to create EC2/ECR/IAM resources.

~~~
$zip = "$env:USERPROFILE\Downloads\MyHomework_Thearin.zip"
$dest = "$env:USERPROFILE\Documents\CI_CD_Assignments_Thearin"
Expand-Archive -Path $zip -DestinationPath $dest -Force
Set-Location "$dest\MyHomework"
git --version
docker version
docker info --format '{{.OSType}}'
code .
~~~

**CHECK BEFORE CONTINUING**

Docker shows Client and Server and the OS type is linux. VS Code opens the MyHomework folder containing Homework2 and Homework3.

## Edit these two policy files

Replace YOUR_ACCOUNT_ID with your 12-digit AWS account ID in both:
Homework2/aws/jenkins-ecr-policy.json
Homework3/aws/jenkins-ecr-policy.json

## Keep these non-secret settings consistent

| Setting | Homework2/ci/settings.env | Homework3/ci/settings.env |
| --- | --- | --- |
| AWS_REGION | ap-southeast-1 | ap-southeast-1 |
| ECR_REPO | thearin-homework2 | thearin-homework3 |
| STACK_NAME | homework2 | homework3 |
| APP_PORT | 80 | 8082 |

If your instructor requires a different region, update both settings files and both IAM policy ARNs. The EC2 role supplies AWS credentials; do not put access keys in settings.env.

**Repository boundary**

Initialize Git only at MyHomework. Keep both project folders inside it. The package also includes separate screenshots/ and reports/ folders for each homework.

# Step 2 - Test both apps locally

WHERE: LOCAL - start from MyHomework

## Homework 2

~~~
Set-Location .\Homework2
docker build --build-arg APP_VERSION=local -t homework2:local .
docker run -d --name hw2-local -p 8088:80 homework2:local
curl.exe -f http://localhost:8088/health
curl.exe -f http://localhost:8088/version.txt
~~~

Open http://localhost:8088/.

**SCREENSHOT HW2-01**

Save the local website showing local and successful Docker/curl output under Homework2/screenshots/.

~~~
docker rm -f hw2-local
Set-Location ..
~~~

## Homework 3

~~~
Set-Location .\Homework3
docker build --build-arg APP_VERSION=local -t homework3:local .
docker run -d --name hw3-local -p 8089:80 homework3:local
curl.exe -f http://localhost:8089/health
curl.exe -f http://localhost:8089/version.txt
~~~

Open http://localhost:8089/.

**SCREENSHOT HW3-01**

Save the Homework 3 local website and Docker test under Homework3/screenshots/.

~~~
docker rm -f hw3-local
Set-Location ..
~~~

**CHECK BEFORE CONTINUING**

Both apps serve /health = ok and /version.txt = local. You are back in MyHomework. Finish this local verification before creating AWS resources.

# Step 3 - GitHub repository and PR

WHERE: BROWSER - create a public, empty GitHub repository named MyHomework

Leave GitHub README/license/.gitignore initialization unchecked. Replace YOUR_GITHUB_USER and YOUR_GITHUB_EMAIL below.

WHERE: LOCAL - MyHomework folder

~~~
git init -b main
git config user.name "Thearin"
git config user.email "YOUR_GITHUB_EMAIL"
git add README.md FILE_MAP.md SETUP.md .gitignore .gitattributes
git add important.txt
git commit -m "docs: start individual homework repository"
git remote add origin https://github.com/YOUR_GITHUB_USER/MyHomework.git
git push -u origin main
git switch -c feature/homework-projects
git add Homework2
git commit -m "feat: add Homework 2 automated deployment project"
git add Homework3
git commit -m "feat: add Homework 3 release and rollback project"
git push -u origin feature/homework-projects
~~~

## Merge the feature branch

GitHub -> Pull requests -> New pull request. Base: main; compare: feature/homework-projects. Create the PR, describe the two projects, and merge using Create a merge commit.

~~~
git switch main
git pull --ff-only
git log --oneline --graph --all -10
~~~

**SCREENSHOT HW2-02**

Capture the merged PR and meaningful separate commits. Save in Homework2/screenshots/.

**CHECK BEFORE CONTINUING**

The main branch contains the Homework2 and Homework3 folders, each with its own Jenkinsfile. All later local Git commands in this guide run from MyHomework unless stated otherwise.

# Step 4 - ECR repositories and EC2 role

WHERE: BROWSER - AWS Console, ap-southeast-1

## Create two PRIVATE ECR repositories

ECR -> Private registry -> Repositories -> Create repository. Create each name below with image tag mutability Immutable and no mutable exclusions.

| Assignment | ECR repository | Example image tags |
| --- | --- | --- |
| Homework 2 | thearin-homework2 | build-2-abc123456789 |
| Homework 3 | thearin-homework3 | v1.0.0, v1.1.0, v1.1.1 |

Copy both repository URIs. They begin with your actual AWS account ID and end in the corresponding repository name.

## Create two IAM policies

IAM -> Policies -> Create policy -> JSON. Paste the correct project's aws/jenkins-ecr-policy.json, with YOUR_ACCOUNT_ID already replaced.

| Policy name | JSON file |
| --- | --- |
| ThearinHomework2EcrPolicy | Homework2/aws/jenkins-ecr-policy.json |
| ThearinHomework3EcrPolicy | Homework3/aws/jenkins-ecr-policy.json |

## Create one manager role

IAM -> Roles -> Create role -> Trusted entity: AWS service -> Use case: EC2. Attach both policies. Role name: ThearinJenkinsEcrRole.

**CHECK BEFORE CONTINUING**

Two private immutable ECR repositories exist. ThearinJenkinsEcrRole can authenticate and push/pull/describe images in both repositories. Attach it to the manager in Step 5.

If your instructor supplies a restricted training account, use the assigned EC2 role with equivalent permissions. The application pipeline does not need hard-coded AWS keys. The worker receives ECR authentication through Swarm deployment.

# Step 5 - EC2 instances and firewall rules

WHERE: BROWSER - AWS EC2

Launch two Ubuntu Server 24.04 LTS, x86_64 instances in the same VPC and subnet, with public IPv4 enabled. Use the same key pair, downloaded as homework-key.pem.

| Instance | Suggested lab size | Disk / IAM role |
| --- | --- | --- |
| swarm-manager | 4 GiB RAM, e.g. t3.medium | 30 GiB gp3 / ThearinJenkinsEcrRole |
| swarm-worker | 1 GiB+ RAM, e.g. t3.micro | 12 GiB gp3 / no role required |

Record the public and private IP of each instance. AWS resources and public IPv4 can incur charges. Keep both apps available through grading.

## Create and attach these security groups

| Group / attached to | Inbound rules |
| --- | --- |
| sg-lab-access / both nodes | TCP 22: My IP (/32).; TCP 80: 0.0.0.0/0 (Homework 2).; TCP 8082: 0.0.0.0/0 (Homework 3). |
| sg-swarm / both nodes | TCP 2377; TCP 7946; UDP 7946; UDP 4789.; Source for each rule: sg-swarm itself. |
| sg-jenkins-hook / manager | TCP 8080 from each current GitHub webhook IPv4 CIDR. |

Keep default outbound connectivity for GitHub, ECR, package repositories, and image storage. Swarm traffic stays on private node addresses.

## Find the current GitHub webhook ranges

WHERE: LOCAL - PowerShell

~~~
$meta = Invoke-RestMethod https://api.github.com/meta
$meta.hooks | Where-Object { $_ -notmatch ":" }
~~~

Add one TCP 8080 rule per printed range to sg-jenkins-hook. Your Jenkins admin UI uses an SSH tunnel later.

**SCREENSHOT HW2-03**

Capture the two Running EC2 instances and security group rules, including public app ports 80 and 8082 and the restricted private Swarm ports.

**CHECK BEFORE CONTINUING**

Both nodes have sg-lab-access and sg-swarm. Only the manager has ThearinJenkinsEcrRole and sg-jenkins-hook.

# Step 6 - Install Docker on BOTH nodes

WHERE: LOCAL - open two PowerShell windows

~~~
ssh -i "$env:USERPROFILE\Downloads\homework-key.pem" ubuntu@MANAGER_PUBLIC_IP
ssh -i "$env:USERPROFILE\Downloads\homework-key.pem" ubuntu@WORKER_PUBLIC_IP
~~~

Use the first command in the manager window and the second in the worker window. Replace the IP placeholders. Run the block below once in each Ubuntu SSH session.

WHERE: MANAGER and WORKER - Ubuntu

~~~
sudo apt-get update
sudo apt-get install -y ca-certificates curl git jq
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
sudo tee /etc/apt/sources.list.d/docker.sources >/dev/null <<'EOF'
Types: deb
URIs: https://download.docker.com/linux/ubuntu
Suites: noble
Components: stable
Architectures: amd64
Signed-By: /etc/apt/keyrings/docker.asc
EOF
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io \
  docker-buildx-plugin docker-compose-plugin
sudo systemctl enable --now docker
sudo usermod -aG docker ubuntu
exit
~~~

Reconnect to each host using its SSH command, then run:

~~~
docker version
docker run --rm hello-world
~~~

**CHECK BEFORE CONTINUING**

Docker works without sudo in each new session. hello-world succeeds. Linux backslash continuation syntax belongs in Ubuntu, not Windows PowerShell.

# Step 7 - Form one Swarm cluster

WHERE: MANAGER - Ubuntu SSH

~~~
docker swarm init --advertise-addr MANAGER_PRIVATE_IP
~~~

Use the manager's private IP from EC2. Copy the exact worker join command printed by Docker.

WHERE: WORKER - Ubuntu SSH

~~~
docker swarm join --token PASTE_THE_REAL_TOKEN MANAGER_PRIVATE_IP:2377
~~~

Paste the actual token and private manager address. This joins the worker to the manager's Swarm.

WHERE: MANAGER - Ubuntu SSH

~~~
docker node ls
~~~

**CHECK BEFORE CONTINUING**

The manager and worker are Ready and Active. Exactly one manager is Leader.

**SCREENSHOT HW2-04**

Capture docker node ls showing both Ready nodes. Keep the join token out of your screenshot.

## Two projects on this same cluster

| Stack / service | Replicas | App port |
| --- | --- | --- |
| homework2 / homework2_web | 2 | 80 |
| homework3 / homework3_web | 2 | 8082 |

The stack files request hostname spreading. Temporary extra replicas are allowed during start-first rolling updates. Check actual placement after deployment.

This coursework layout runs trusted builds on the manager with Jenkins. One manager is sufficient for the assignment, but it is not a high-availability manager design.

# Step 8 - Install AWS CLI and Jenkins

WHERE: MANAGER only - Ubuntu SSH

~~~
sudo snap install aws-cli --classic
/snap/bin/aws --version
/snap/bin/aws sts get-caller-identity --region ap-southeast-1
sudo apt-get update
sudo apt-get install -y fontconfig openjdk-21-jre
java -version
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2026.key \
  -o /etc/apt/keyrings/jenkins-keyring.asc
echo "deb [signed-by=/etc/apt/keyrings/jenkins-keyring.asc]" \
  "https://pkg.jenkins.io/debian-stable binary/" | \
  sudo tee /etc/apt/sources.list.d/jenkins.list >/dev/null
sudo apt-get update
sudo apt-get install -y jenkins
sudo usermod -aG docker jenkins
sudo systemctl enable jenkins
sudo systemctl restart jenkins
sudo systemctl status jenkins --no-pager
sudo -u jenkins -H docker ps
sudo -u jenkins -H /snap/bin/aws sts get-caller-identity
~~~

**CHECK BEFORE CONTINUING**

Jenkins is active. The jenkins user can run Docker and AWS STS. STS shows the manager's assumed ThearinJenkinsEcrRole. The instance role supplies credentials automatically.

## Open the admin UI securely through SSH

WHERE: LOCAL - new PowerShell window; keep this tunnel open

~~~
$keyPath = "$env:USERPROFILE\Downloads\homework-key.pem"
ssh -N -L 18080:127.0.0.1:8080 -i $keyPath ubuntu@MANAGER_PUBLIC_IP
~~~

Open http://localhost:18080/. Get the unlock password from MANAGER:

~~~
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
~~~

Unlock Jenkins, install suggested plugins, create your administrator account, and finish setup. Keep passwords outside screenshots.

# Step 9 - Plugins, node, and GitHub webhook

WHERE: BROWSER - Jenkins through localhost:18080

## Plugins and build node

Manage Jenkins -> Plugins: install/check Pipeline, Git, GitHub, GitHub Branch Source, Basic Branch Build Strategies, Pipeline: Stage View, Timestamper. Restart if requested.

Manage Jenkins -> Nodes -> Built-In Node -> Configure: Labels = swarm-manager; Number of executors = 1. One executor serializes jobs on this manager.

Manage Jenkins -> System -> Jenkins Location: Jenkins URL = http://MANAGER_PUBLIC_IP:8080/. Keep using the SSH tunnel for browser login.

## Shared secret

WHERE: MANAGER - generate privately

~~~
openssl rand -hex 32
~~~

Jenkins -> Manage Jenkins -> Credentials -> System -> Global -> Add Credentials: Kind Secret text, paste the value, ID github-webhook-secret.

Manage Jenkins -> System -> GitHub -> Advanced -> Shared secret / Hook secret configuration: select that credential. Select SHA-256 if shown. Keep automatic hook management off.

## Create one manual GitHub webhook

WHERE: BROWSER - MyHomework repository -> Settings -> Webhooks -> Add

| Field | Value |
| --- | --- |
| Payload URL | http://MANAGER_PUBLIC_IP:8080/github-webhook/ |
| Content type | application/json |
| Secret | The same generated secret stored in Jenkins |
| Events | Select Pushes AND Branch or tag creation |
| Active | Checked |

Keep the trailing slash. The example HTTP hook is for this public-code lab and uses a signed secret. If you use an HTTPS endpoint, leave SSL verification enabled. Keep the shared secret out of screenshots. GitHub must reach port 8080 from its published webhook ranges.

# Step 10 - Deploy and prove Homework 2

WHERE: BROWSER - Jenkins -> New Item -> HW2-main -> Pipeline

| Field | Value |
| --- | --- |
| Definition / SCM | Pipeline script from SCM / Git |
| Repository URL | https://github.com/YOUR_GITHUB_USER/MyHomework.git |
| Credentials / Branch | None for public repo / */main |
| Script Path | Homework2/Jenkinsfile |

Save. Click Build Now once to register the trigger and check setup. Confirm GitHub hook trigger for GITScm polling becomes checked. The later Git push below supplies the automatic-build evidence.

WHERE: LOCAL - edit Homework2/index.html in VS Code

Change the release note from Homework 2 first deployment. to Homework 2 automatic update. Save, then run from MyHomework:

~~~
git add Homework2/index.html
git commit -m "feat: demonstrate Homework 2 automatic deployment"
git push origin main
~~~

WHERE: BROWSER - GitHub Recent Deliveries + Jenkins HW2-main

**SCREENSHOT HW2-05 / HW2-06**

Capture the real main push delivery and the automatically started successful Jenkins Build, Push, Deploy and Verify stages. Save in Homework2/screenshots/.

WHERE: MANAGER - verify actual deployment

~~~
docker stack services homework2
docker service ps --no-trunc homework2_web
curl -fsS http://127.0.0.1/version.txt
~~~

**CHECK BEFORE CONTINUING**

homework2_web is 2/2 and its build-N-SHA version matches the image in thearin-homework2 and the public app at http://MANAGER_PUBLIC_IP/.

**SCREENSHOT HW2-07 / HW2-08**

Capture the private ECR image and public website with matching version. Download the Jenkins deployment artifact and record the real build/time in Homework2/DEPLOYMENT_HISTORY.md.

After saving Homework 2 evidence, disable HW2-main before the Homework 3 tag-only tests. Leave its Swarm stack running on port 80.

# Step 11 - Configure Homework 3 tag jobs

WHERE: BROWSER - Jenkins -> New Item -> HW3-release -> Multibranch Pipeline

| Field | Value |
| --- | --- |
| Branch Source | GitHub. Repository HTTPS URL: https://github.com/YOUR_GITHUB_USER/MyHomework |
| Credentials | None for public repository |
| Behaviours | Discover tags. Remove branch discovery and all PR discovery behaviours. |
| Name filter | Filter by name (regular expression), using the expression below. |
| Build Strategies | Add Tags only. Leave both age-limit options off/blank. |
| Build Configuration | By Jenkinsfile; Script Path = Homework3/Jenkinsfile |
| Scan triggers | Keep periodic scanning off; new tag events use the GitHub webhook. |

~~~
^v[0-9]+[.][0-9]+[.][0-9]+$
~~~

Save. With no version tags yet, an empty initial scan is expected. Tags must contain the committed Homework3/Jenkinsfile. Both Discover tags and the Tags build strategy are needed.

**SCREENSHOT HW3-02**

Capture tag-only discovery/filter/build strategy settings under Homework3/screenshots/.

## Parameters inside each discovered tag child job

| ACTION | Behavior |
| --- | --- |
| release | Build + push + deploy + verify; automatic default |
| build | Build locally only |
| push | Build + push only |
| deploy | Deploy an existing ECR image + verify; no build/push |
| rollback | Deploy a prior existing image + verify; no build/push |

VERSION blank uses the tag of that job. Build with Parameters becomes available after its first run. Use an existing tag child job for manual rollback.

# Step 12 - Run three release cycles

WHERE: LOCAL - MyHomework root

## Release 1: v1.0.0

~~~
git switch main
git pull --ff-only
git tag -a v1.0.0 -m "Initial Homework 3 release"
git push origin v1.0.0
~~~

Wait for HW3-release/v1.0.0 to start automatically and succeed. Verify ECR thearin-homework3:v1.0.0 and the app at http://MANAGER_PUBLIC_IP:8082/.

## Release 2: v1.1.0 + branch-ignore test

Edit Homework3/index.html: change First release. to New feature: release banner.

~~~
git add Homework3/index.html
git commit -m "feat: improve Homework 3 release banner"
git push origin main
~~~

**SCREENSHOT HW3-03**

Pause before tagging. Capture the main push delivery and unchanged release build history. HW2-main is disabled; no Homework 3 release build should start from this branch push.

~~~
git tag -a v1.1.0 -m "Add Homework 3 release banner"
git push origin v1.1.0
~~~

Wait for automatic release and verify v1.1.0 before continuing.

## Release 3: v1.1.1

Edit the same release note to Fixed: clearer release banner.

~~~
git add Homework3/index.html
git commit -m "fix: clarify Homework 3 banner"
git push origin main
git tag -a v1.1.1 -m "Fix Homework 3 banner wording"
git push origin v1.1.1
~~~

**SCREENSHOT HW3-04 / HW3-05 / HW3-06 / HW3-07**

After success, capture all three Git tags, all three immutable ECR images, a successful tag-triggered release, and the public app showing v1.1.1. Publish GitHub Release notes for each existing tag.

Never overwrite or move release tags. Record each real UTC deployment/build in Homework3/DEPLOYMENT_HISTORY.md. If an image already exists, use ACTION=deploy to retry deployment.

# Step 13 - Perform an actual rollback

WHERE: MANAGER - separate SSH session for the observer

~~~
cd ~
git clone https://github.com/YOUR_GITHUB_USER/MyHomework.git homework-evidence
bash homework-evidence/Homework3/ci/observe.sh
~~~

The observer automatically enters Homework3, reads APP_PORT=8082, and records 180 request samples. While it runs, start the Jenkins rollback promptly.

WHERE: BROWSER - Jenkins -> HW3-release -> v1.1.1 -> Build with Parameters

| Parameter | Value |
| --- | --- |
| ACTION | rollback |
| VERSION | v1.0.0 |

Click Build. The pipeline checks the old ECR image exists and deploys that image's exact digest. Build and Push stages must be skipped.

**SCREENSHOT HW3-08**

Capture rollback parameters, skipped Build/Push, successful deployment/verification, and the console line showing an existing image is used. Download the deployment-v1.0.0.txt artifact.

WHERE: MANAGER - after the monitor finishes

~~~
docker stack services homework3
docker service ps --no-trunc homework3_web
docker service inspect --format '{{.Spec.TaskTemplate.ContainerSpec.Image}}' homework3_web
curl -fsS http://127.0.0.1:8082/version.txt
~~~

**CHECK BEFORE CONTINUING**

homework3_web is 2/2 and its image is :v1.0.0@sha256:... . The endpoint returns v1.0.0. The Homework 2 app on port 80 remains separate.

**SCREENSHOT HW3-09**

Capture the public port 8082 app showing v1.0.0, along with the matching image and two replicas. Pair it with the before screenshot showing v1.1.1.

# Step 13 - Keep rollback availability evidence

WHERE: MANAGER - Ubuntu SSH

~~~
cd ~/homework-evidence/Homework3
tail -n 5 rollback-availability.log
awk '$2=="FAIL"{n++} END{print "Failures:", n+0}' rollback-availability.log
awk '{print $3}' rollback-availability.log | sort -u
~~~

**SCREENSHOT HW3-10**

Capture the actual failure count and observed versions. A successful observed test should include v1.1.1 and v1.0.0 with Failures: 0. Report your actual result.

This monitor supports availability during the sampled rollback window. If requests fail or one version is missed, inspect the service and repeat a controlled test: deploy v1.1.1 from the existing image, restart the monitor, then rollback to v1.0.0.

## Copy the real log into your homework folder

WHERE: LOCAL - PowerShell, MyHomework root

~~~
$keyPath = "$env:USERPROFILE\Downloads\homework-key.pem"
$node = "ubuntu@MANAGER_PUBLIC_IP"
$remote = $node + ":homework-evidence/Homework3/rollback-availability.log"
scp -i $keyPath $remote .\Homework3\screenshots
~~~

The .gitignore permits screenshot-folder log files, so this real observed log can be committed with the evidence.

## Record what actually happened

Fill Homework3/DEPLOYMENT_HISTORY.md with the real UTC rollback time, prior and target versions, Jenkins build number/link, and verified result. Update the README's submission values.

**CHECK BEFORE CONTINUING**

The release and rollback are demonstrated end to end. All three ECR versions remain present, and the live Homework 3 app is v1.0.0 at submission unless the teacher requests another version.

Keep Homework 2's service running too. Check both public URLs from your own computer before submission.

# Step 14 - Reports, GitHub, and submission

WHERE: LOCAL - fill actual evidence and write your two short reports

| Assignment | Where to save |
| --- | --- |
| Homework 2 screenshots | Homework2/screenshots/ |
| Homework 2 finished report | Homework2/reports/HW2_Report.pdf |
| Homework 3 screenshots + observer log | Homework3/screenshots/ |
| Homework 3 finished report | Homework3/reports/HW3_Report.pdf |

Each reports/ folder includes an editable Markdown outline. Produce a 1-2 page PDF for each homework using your own screenshots and results.

HW2 report: architecture; successful automatic main-push pipeline; private ECR image; Ready nodes / 2 replicas; running app; actual challenge and fix.

HW3 report: tag convention; tag-only configuration; ACTION/VERSION design; three retained images; tag-triggered release; before/after real rollback; actual timeline and availability observation.

## Commit the real evidence

WHERE: LOCAL - MyHomework root

~~~
git add README.md Homework2 Homework3
git commit -m "docs: add actual deployment evidence and homework reports"
git push origin main
~~~

HW2-main stays disabled. This documentation branch push must not trigger a Homework 3 release.

## Send two clearly labelled submissions to the Telegram group

Homework 2: GitHub link to /tree/main/Homework2, ECR URI + region, live port 80 app URL/current version, successful automatic pipeline screenshot/log, and HW2_Report.pdf.

Homework 3: GitHub link to /tree/main/Homework3, ECR URI + region, live port 8082 app URL/current version, release/rollback screenshots/logs, and HW3_Report.pdf.

**Final check**

The teacher's PDFs list 16 October 2026, and your Telegram screenshot says individual work. No exact time is given. Keep both websites running through the grading window. Read important.txt. The optional guide and blank templates are not completed submission reports.

# Troubleshooting and references

| Problem | First check / fix |
| --- | --- |
| Wrong project or missing ci file | Use Script Path Homework2/Jenkinsfile or Homework3/Jenkinsfile. Keep the folder names exact. Each helper enters its own project directory. |
| Docker Windows pipe error | Start Docker Desktop and wait for docker version to show Server. Use Linux containers. |
| SSH or admin UI blocked | Check TCP 22 My IP and the current public IP. Keep the SSH tunnel open and browse localhost:18080. |
| Jenkins Docker permission error | sudo usermod -aG docker jenkins; sudo systemctl restart jenkins |
| AWS credentials / ECR denied | Check the manager role and both attached ECR policies; run sudo -u jenkins -H /snap/bin/aws sts get-caller-identity. |
| Homework 3 app unavailable | Check public TCP 8082 on both nodes, the homework3 service, and APP_PORT=8082. |
| Tag discovered but no build | Enable Discover tags AND Tags build strategy; remove both tag age limits. Check the semantic name filter. |
| Immutable tag already exists | Use ACTION=deploy for that existing image. Changed source needs a new version tag. |
| Swarm update fails | docker service ps --no-trunc homework2_web or homework3_web. Inspect task errors, private ports, ECR login, and resources. |

ECR auth tokens last 12 hours. To refresh Homework 3 registry auth, run ACTION=deploy with its current existing version. For Homework 2, a fresh successful pipeline run refreshes auth. Remove unused cloud resources after grading; stopped VMs can retain billable disks.

## Official references checked for this setup

Docker on Ubuntu

Jenkins Linux / Java / signing key

Jenkins fileExists and workspace paths

Docker stack deployment

Tag discovery and tag build strategy

ECR tag immutability

GitHub webhook best practices

Local source checks and simulated command tests validate the folder/build/rollback logic. No live AWS/Jenkins deployment is claimed. Capture actual cloud results while following these steps.
