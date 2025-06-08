
# ВСТУП

Цей README файл описує на украйнськой і англійскоой мовах інфрастуктуру як код для учбового застосунку на python на виконня випусконого завдання  Супрунюк Максими для Devops курса в DAN-IT s

Завдання: 
1. Create GitHub repo with:
 - test python backend server. Just script which listening on some port and respond 200 on /
 - Dockerfile with everything needed to run this script
 - GitHub action which will build docker image automatically and push to docker hub. Use Github secrets to store your docker hub creds
2. Use terraform code to create EKS cluster (https://gitlab.com/dan-it/groups/devops_soft/-/tree/main/step-final/EKS?ref_type=heads)
 - one node group with one node
 - nginx ingress controller
3. Write terraform code which will install ArgoCD to EKS using helm chart or raw k8s manifest
 - argocd must have dns name in domain: devops1.test-danit.com (change devops1 to your group number) example: argocd.student1.devops1.test-danit.com where student1 is your cluster name.
4. Write K8S manifests to deploy your app from item 1 to EKS.
 - deployment, service, ingress.
 - app must be available by dns name in domain: devops1.test-danit.com (change devops1 to your group number) example: app.student1.devops1.test-danit.com
5. Write ArgoCD app which will deliver code from item 4 to EKS and will update it on new commit.

# UA CONTENT
## АРХИТЕКТУРА 

### СТРУКТУРА ФАЙЛІВ

step-final/
│
├── eks-terraform/                     # ⚙️ Terraform-код для створення кластера EKS в AWS
│   ├── .gitignore                     # Ігнорує файли Terraform-стану та кеш
│   ├── README.md                      # Інструкція по запуску terraform
│   ├── acm.tf                         # Налаштування сертифікатів SSL (AWS ACM)
│   ├── backend.tf                     # Налаштування бекенда для збереження стану (S3, локально)
│   ├── eks-cluster.tf                 # Опис створення кластеру EKS (control plane)
│   ├── eks-worker-nodes.tf            # Node group — EC2-інстанси для запуску підiв
│   ├── external-dns.tf                # Інтеграція з DNS (Route53 тощо)
│   ├── iam.tf                         # Створення ролей і політик AWS IAM
│   ├── ingress_controller.tf          # Установка NGINX ingress controller через Helm
│   ├── metrics-server.tf              # Установка metrics-server для авто scaling та метрик
│   ├── argocd.tf                      # Установка ArgoCD через Helm (або манифестами)
│   ├── provider.tf                    # Налаштування провайдера AWS (ключі, регіон)
│   ├── sg.tf                          # Security Group — відкриті порти, доступ до інстансів
│   ├── terraform.tfvars               # Конкретні значення змінних (cluster_name, region тощо)
│   └── variables.tf                   # Визначення всіх змінних, які використовуються в *.tf
│
├── app/                                # Python-додаток і Dockerfile
│   ├── app.py                          # Проста API-програма на Python (слухає `/`)
│   ├── requirements.txt                # Залежності Python (якщо є)
│   └── Dockerfile                      # Dockerfile для збірки контейнера
│
├── k8s/                                # Kubernetes-манифести для додатку
│   ├── deployment.yaml                 # Deployment: образ, кількість реплік, порти
│   ├── service.yaml                    # Сервіс: як Kubernetes передає трафік до пода
│   └── ingress.yaml                    # Ingress: зовнішній доступ за DNS через NGINX Ingress
│
├── argocd/                             # ArgoCD Application — визначає, де і що деплоїти
│   └── app.yaml                        # Манифест типу Application (CRD) для ArgoCD
│
├── .github/                            # GitHub Actions (CI/CD автоматизація)
│   └── workflows/
│       └── main.yml                    # CI: збірка Docker-образу, пуш у DockerHub, оновлення image: у YAML
│
├── task.md                             # Завдання або технічне ТЗ
└── README.md                           # Головна інструкція: архітектура, запуск, деплой


# EN CONTENT# step-final
