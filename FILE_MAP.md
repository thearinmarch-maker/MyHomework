# Which files belong to which homework?

Homework2 and Homework3 match the numbers in your teacher's two PDFs.

| File or folder | Homework2/ | Homework3/ |
| --- | --- | --- |
| index.html | Automatic deployment website | Release/rollback website |
| Dockerfile | Own copy | Own copy |
| docker-stack.yml | homework2 stack, port 80 | homework3 stack, port 8082 |
| Jenkinsfile | Main-push pipeline | Tag jobs, ACTION/VERSION and rollback |
| ci/pipeline.sh | Own build/push/deploy/verify helper | Own helper including rollback |
| ci/settings.env | thearin-homework2 / homework2 / 80 | thearin-homework3 / homework3 / 8082 |
| ci/observe.sh | Not required | Rollback availability monitor |
| aws/jenkins-ecr-policy.json | thearin-homework2 ECR permissions | thearin-homework3 ECR permissions |
| README.md | Homework 2 usage and submission values | Homework 3 usage and values |
| RELEASING.md | Not required | Tag convention and rollback procedure |
| DEPLOYMENT_HISTORY.md | Actual branch deployments | Actual releases and rollback |
| screenshots/ | Homework 2 real captures | Homework 3 real captures and log |
| reports/ | Write HW2_Report.pdf here | Write HW3_Report.pdf here |
| .dockerignore/.gitignore/.gitattributes | Own copies | Own copies |

At MyHomework root: README.md, FILE_MAP.md and SETUP.md explain both projects.
All source files are already placed in their correct folders.
