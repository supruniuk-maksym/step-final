task.md has a goal of this code.

шаг 1
создал файл main.py 
псиал тутжа прростой код для запуска сервера с сообщением OK на странице
запускаю командой внутри этой папки python3 main.py
проверяю командой curl http://localhost:5000 что код работет
Вижу что страний возрращеет сообщение ОК.
Выключил сервер командой ctrl+c
Шаг 1 завершен. 

Шаг 2
Создал докерфайл
Положил уровнем выше чем папк app в которой лежить файл main.py из шага 1
Сделал билд simple-server 
Запустить билд комадндой docker run -p 5000:5000 simple-server
Убедилися что http://localhost:5000 также возращает сообщение ОК
Выключ
Шаг 2 заверешен. 

 





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



