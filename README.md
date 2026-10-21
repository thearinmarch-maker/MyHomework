# MyHomework - two complete CI/CD projects

Individual student: Thearin. Add your required student ID.

| Assignment | Project | Jenkins Script Path | Public app |
| --- | --- | --- | --- |
| Homework 2 | Homework2/ | Homework2/Jenkinsfile | http://MANAGER_PUBLIC_IP/ |
| Homework 3 | Homework3/ | Homework3/Jenkinsfile | http://MANAGER_PUBLIC_IP:8082/ |

Each folder is a complete sample source project with its own website,
Dockerfile, stack, Jenkinsfile, helper, settings, AWS role policy,
README, screenshot checklist, and report template.
Homework 3 adds tag-based releases and rollback.

Both projects can share one EC2 manager, one worker, and Jenkins.
They use separate ECR repositories and Swarm stacks so the two apps remain
available together. Security groups must allow public TCP 80 and 8082.

Read SETUP.md or optional/MyHomework_Two_Projects_Setup.pdf for the numbered setup.
FILE_MAP.md lists exactly which files belong to each assignment.
Replace YOUR_ACCOUNT_ID in both project IAM policy JSON files.
Complete the live setup and supply actual screenshots, reports, and history.

Create one Git repository at this MyHomework level; commit both projects.
Do not initialize nested Git repositories inside Homework2 or Homework3.

Use each folder's direct GitHub link for its teacher submission, for example:

- https://github.com/YOUR_GITHUB_USER/MyHomework/tree/main/Homework2
- https://github.com/YOUR_GITHUB_USER/MyHomework/tree/main/Homework3

Actual submission values:

- Repository: FILL_IN
- Homework 2 app / ECR / successful Jenkins build: FILL_IN
- Homework 3 app / ECR / release and rollback builds: FILL_IN

The setup PDF and templates are working instructions, not completed reports.
Local checks and simulated pipeline tests do not replace real AWS/Jenkins
deployment evidence. Keep both apps running through the grading window.

## Application in this package

PocketLedger: A personal expense tracker with a budget and remaining balance.

Read important.txt before completing your submission.
The optional setup PDF can stay on your computer; .gitignore excludes it.
These projects use a shared CI/CD learning scaffold. Each student completes
their own deployment, tests, screenshots, Git history, and reports.
