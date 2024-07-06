# Никоноров Денис - FOPS-8

# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

**Перед началом работы над дипломным заданием изучите [Инструкция по экономии облачных ресурсов](https://github.com/netology-code/devops-materials/blob/master/cloudwork.MD).**

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Этапы выполнения:


### Создание облачной инфраструктуры

Для начала необходимо подготовить облачную инфраструктуру в ЯО при помощи [Terraform](https://www.terraform.io/).

Особенности выполнения:

- Бюджет купона ограничен, что следует иметь в виду при проектировании инфраструктуры и использовании ресурсов;
Для облачного k8s используйте региональный мастер(неотказоустойчивый). Для self-hosted k8s минимизируйте ресурсы ВМ и долю ЦПУ. В обоих вариантах используйте прерываемые ВМ для worker nodes.

Предварительная подготовка к установке и запуску Kubernetes кластера.

1. Создайте сервисный аккаунт, который будет в дальнейшем использоваться Terraform для работы с инфраструктурой с необходимыми и достаточными правами. Не стоит использовать права суперпользователя
2. Подготовьте [backend](https://www.terraform.io/docs/language/settings/backends/index.html) для Terraform:  
   а. Рекомендуемый вариант: S3 bucket в созданном ЯО аккаунте(создание бакета через TF)
   б. Альтернативный вариант:  [Terraform Cloud](https://app.terraform.io/)  
3. Создайте VPC с подсетями в разных зонах доступности.
4. Убедитесь, что теперь вы можете выполнить команды `terraform destroy` и `terraform apply` без дополнительных ручных действий.
5. В случае использования [Terraform Cloud](https://app.terraform.io/) в качестве [backend](https://www.terraform.io/docs/language/settings/backends/index.html) убедитесь, что применение изменений успешно проходит, используя web-интерфейс Terraform cloud.

Ожидаемые результаты:

1. Terraform сконфигурирован и создание инфраструктуры посредством Terraform возможно без дополнительных ручных действий.
2. Полученная конфигурация инфраструктуры является предварительной, поэтому в ходе дальнейшего выполнения задания возможны изменения.

---
### Создание Kubernetes кластера

На этом этапе необходимо создать [Kubernetes](https://kubernetes.io/ru/docs/concepts/overview/what-is-kubernetes/) кластер на базе предварительно созданной инфраструктуры.   Требуется обеспечить доступ к ресурсам из Интернета.

Это можно сделать двумя способами:

1. Рекомендуемый вариант: самостоятельная установка Kubernetes кластера.  
   а. При помощи Terraform подготовить как минимум 3 виртуальных машины Compute Cloud для создания Kubernetes-кластера. Тип виртуальной машины следует выбрать самостоятельно с учётом требовании к производительности и стоимости. Если в дальнейшем поймете, что необходимо сменить тип инстанса, используйте Terraform для внесения изменений.  
   б. Подготовить [ansible](https://www.ansible.com/) конфигурации, можно воспользоваться, например [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/)  
   в. Задеплоить Kubernetes на подготовленные ранее инстансы, в случае нехватки каких-либо ресурсов вы всегда можете создать их при помощи Terraform.
2. Альтернативный вариант: воспользуйтесь сервисом [Yandex Managed Service for Kubernetes](https://cloud.yandex.ru/services/managed-kubernetes)  
  а. С помощью terraform resource для [kubernetes](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_cluster) создать **региональный** мастер kubernetes с размещением нод в разных 3 подсетях      
  б. С помощью terraform resource для [kubernetes node group](https://registry.terraform.io/providers/yandex-cloud/yandex/latest/docs/resources/kubernetes_node_group)
  
Ожидаемый результат:

1. Работоспособный Kubernetes кластер.
2. В файле `~/.kube/config` находятся данные для доступа к кластеру.
3. Команда `kubectl get pods --all-namespaces` отрабатывает без ошибок.

---
### Создание тестового приложения

Для перехода к следующему этапу необходимо подготовить тестовое приложение, эмулирующее основное приложение разрабатываемое вашей компанией.

Способ подготовки:

1. Рекомендуемый вариант:  
   а. Создайте отдельный git репозиторий с простым nginx конфигом, который будет отдавать статические данные.  
   б. Подготовьте Dockerfile для создания образа приложения.  
2. Альтернативный вариант:  
   а. Используйте любой другой код, главное, чтобы был самостоятельно создан Dockerfile.

Ожидаемый результат:

1. Git репозиторий с тестовым приложением и Dockerfile.
2. Регистри с собранным docker image. В качестве регистри может быть DockerHub или [Yandex Container Registry](https://cloud.yandex.ru/services/container-registry), созданный также с помощью terraform.

---
### Подготовка cистемы мониторинга и деплой приложения

Уже должны быть готовы конфигурации для автоматического создания облачной инфраструктуры и поднятия Kubernetes кластера.  
Теперь необходимо подготовить конфигурационные файлы для настройки нашего Kubernetes кластера.

Цель:
1. Задеплоить в кластер [prometheus](https://prometheus.io/), [grafana](https://grafana.com/), [alertmanager](https://github.com/prometheus/alertmanager), [экспортер](https://github.com/prometheus/node_exporter) основных метрик Kubernetes.
2. Задеплоить тестовое приложение, например, [nginx](https://www.nginx.com/) сервер отдающий статическую страницу.

Способ выполнения:
1. Воспользоваться пакетом [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus), который уже включает в себя [Kubernetes оператор](https://operatorhub.io/) для [grafana](https://grafana.com/), [prometheus](https://prometheus.io/), [alertmanager](https://github.com/prometheus/alertmanager) и [node_exporter](https://github.com/prometheus/node_exporter). Альтернативный вариант - использовать набор helm чартов от [bitnami](https://github.com/bitnami/charts/tree/main/bitnami).

2. Если на первом этапе вы не воспользовались [Terraform Cloud](https://app.terraform.io/), то задеплойте и настройте в кластере [atlantis](https://www.runatlantis.io/) для отслеживания изменений инфраструктуры. Альтернативный вариант 3 задания: вместо Terraform Cloud или atlantis настройте на автоматический запуск и применение конфигурации terraform из вашего git-репозитория в выбранной вами CI-CD системе при любом комите в main ветку. Предоставьте скриншоты работы пайплайна из CI/CD системы.

Ожидаемый результат:
1. Git репозиторий с конфигурационными файлами для настройки Kubernetes.
2. Http доступ к web интерфейсу grafana.
3. Дашборды в grafana отображающие состояние Kubernetes кластера.
4. Http доступ к тестовому приложению.

---
### Установка и настройка CI/CD

Осталось настроить ci/cd систему для автоматической сборки docker image и деплоя приложения при изменении кода.

Цель:

1. Автоматическая сборка docker образа при коммите в репозиторий с тестовым приложением.
2. Автоматический деплой нового docker образа.

Можно использовать [teamcity](https://www.jetbrains.com/ru-ru/teamcity/), [jenkins](https://www.jenkins.io/), [GitLab CI](https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/) или GitHub Actions.

Ожидаемый результат:

1. Интерфейс ci/cd сервиса доступен по http.
2. При любом коммите в репозиторие с тестовым приложением происходит сборка и отправка в регистр Docker образа.
3. При создании тега (например, v1.0.0) происходит сборка и отправка с соответствующим label в регистри, а также деплой соответствующего Docker образа в кластер Kubernetes.

---
## Что необходимо для сдачи задания?

1. Репозиторий с конфигурационными файлами Terraform и готовность продемонстрировать создание всех ресурсов с нуля.
2. Пример pull request с комментариями созданными atlantis'ом или снимки экрана из Terraform Cloud или вашего CI-CD-terraform pipeline.
3. Репозиторий с конфигурацией ansible, если был выбран способ создания Kubernetes кластера при помощи ansible.
4. Репозиторий с Dockerfile тестового приложения и ссылка на собранный docker image.
5. Репозиторий с конфигурацией Kubernetes кластера.
6. Ссылка на тестовое приложение и веб интерфейс Grafana с данными доступа.
7. Все репозитории рекомендуется хранить на одном ресурсе (github, gitlab)

---

---

# Выполнение дипломного практикума

```shell
tofu version
ansible --version
python --version
docker --version
git --version
kubectl version
helm version
yc -v
```
Версии моих компонент 

![alt text](img/1.png)

Облачная инфраструктура.

Решил выбрать вместо Terraform открытый форк OpenTofu.

## Создание облачной инфрастуктуры

1. Создаем сервисный аккаунт с правами для работы c Yandex Cloud

```terraform
resource "yandex_iam_service_account" "service" {
	folder_id = var.folder_id
	name = var.account_name
}

resource "yandex_resourcemanager_folder_iam_member" "serivce_editor" {
	folder_id = var.folder_id
	role = "editor"
	member = "serviceAccount:${yandex_iam_service_account.service.id}"
}

```

2. Подготовлен backend для OpenTofu(Terraform). Использую S3-bucket:

```terraform

resource "yandex_iam_service_account_static_access_key" "terraform_service_account_key" {
	service_account_id = yandex_iam_service_account.service.id
}

resource "yandex_storage_bucket" "tf-bucket" {
	bucket = "s3-bucket-mxssclxck"
	access_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key
	secret_key = yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key

	anonymous_access_flags {
		read = false
		list = false
	}

	force_destroy = true

provisioner "local-exec" {
	command = "echo export ACCESS_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.access_key} > ../terraform/backend.tfvars"
}
provisioner "local-exec" {
	command = "echo export SECRET_KEY=${yandex_iam_service_account_static_access_key.terraform_service_account_key.secret_key} >> ../terraform/backend.tfvars"
}
}

```

Применяю код `tofu apply`

![alt text](/img/2.png)

В результате выполнения был создан сервисный аккаунт с правами для редактирования, ключ доступа и S3-bucket. Переменные AWS_ACCESS_KEY и AWS_SECRET_KEY будут записаны в файл `backend.tfvars`. Так как эти данные являются секретными и не рекомендуются их хранить в облаке. Данные переменные будут экспортированы в оболочку рабочего окружения.

Теперь проверим создался ли S3-bucket и сервисный аккаунт.

![alt text](/img/3.png)

Сервисный аккаунт и S3-bucket были созданы.

После создания, выполним настройку для его использования в качестве backend для OpenTofu (Terraform)

```terraform

terraform {
	backend "s3" {
		endpoint = "storage.yandexcloud.net"
		bucket = "s3-bucket-mxssclxck"
		region = "ru-central1"
		key = "s3-bucket-mxssclxck/terraform.tfstate"
		skip_region_validation = true
		skip_credentials_validation = true
		skip_metadata_api_check = true
	}
}

```

Данный код настраивает OpenTofu (Terraform) на использование Yandex Cloud Storage в качестве места для хранения файла состояния `terraform.tfstate`, который содержит информацию о конфигурации и состоянии управляемых OpenTofu (Terraform) ресурсов. Для того чтобы код корректно применился и OpenTofu (Terraform) успешно инициализировался, заданы параметры для доступа к S3 хранилищу. С помощью переменных окружения:

![alt text](/img/4.png)

Создаем VPC c подсетями в разных зонах доступности.

```terraform

resource "yandex_vpc_network" "diplom" {
	name = var.vpc_name
}

resource "yandex_vpc_subnet" "diplom-ffops8-subnet1" {
	name = var.subnet1
	zone = var.zone1
	network_id = yandex_vpc_network.diplom.id
	v4_cidr_blocks = var.cidr1
}

resource "yandex_vpc_subnet" "diplom-ffops8-subnet2" {
	name = var.subnet2
	zone = var.zone2
	network_id = yandex_vpc_network.diplom.id
	v4_cidr_blocks = var.cidr2
}

variable "zone1" {
	type = string
	default = "ru-central1-a"
	description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "zone2" {
	type = string
	default = "ru-central1-b"
	description = "https://cloud.yandex.ru/docs/overview/concepts/geo-scope"
}

variable "cidr1" {
	type = list(string)
	default = [ "10.0.1.0/24" ]
	description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "cidr2" {
	type = list(string)
	default = [ "10.0.2.0/24" ]
	description = "https://cloud.yandex.ru/docs/vpc/operations/subnet-create"
}

variable "vpc_name" {
	type = string
	default = "diplom-ffops8"
	description = "VPC network & subnet name"
}

variable "bucket_name" {
	type = string
	default = "tf-state"
	description = "VPC network & subnet name"
}

variable "subnet1" {
	type = string
	default = "diplom-ffops8-subnet1"
	description = "subnet name"
}

variable "subnet2" {
	type = string
	default = "diplom-ffops8-subnet2"
	description = "subnet name"
}

```

Для создания виртуальных машин для Kubernetes кластера использую одну Master и две Worker ноды что бы была экономия ресурсов и денежных средств на счету т.к (работаю с Yandex Cloud без купона(истек срок активации 😢)).

Инициализирую OpenTofu (Terraform)

![alt text](/img/5.png)

OpenTofu успешно инициализирован, backend с типом s3 настроился. OpenTofu будет использовать этот backend для хранения файла состояния `terraform.tfstate`

Проверю правильность кода на ошибки, использую команды `tofu validate` и `tofu plan`.
Были синтаксически ошибки, но они были исправлены т.к OpenTofu показывает в каком файле и в какой строке ошибка.

![alt text](/img/6.png)

Применяю код для создания облачной инфраструктуры. Состоит из одной мастер и двух воркер нод, сети и подсети:

![alt text](/img/7.png)

Так же создается ресурс из файла `ansible.tf`, который по шаблону из `hosts.tftpl` создает inventory файл.
Данный inventory файл дальше будет использован для развертывания K8S кластера из репозитория Kuberspray.

При развертывании ВМ будет использоваться файл `cloud-init.yml`, который установит на ВМ утилиты curl, git, mc, atop и другие.

Код для создания Мастер ноды находится в файлах [master.tf](/terraform/master.tf)

Код для создания Воркер ноды находится в файлах [worker.tf](/terraform/worker.tf)

[cloud-init.yml](/terraform/cloud-init.yml) код для установки необходимых утилит на ВМ при развертывании.

Проверяю развернулись ли ВМ:

![alt text](/img/8.png)

Как видно ВМ содались в разных зонах доступности и разных подсетках.

А что же видно веб интерфейсе Yandex Cloud? Проверим!

- Сервисный аккаунт

![alt text](/img/9.png)

- S3-bucket

![alt text](/img/10.png)

- Сеть и подсетки

![alt text](/img/11.png)

- ВМки

![alt text](/img/12.png)

Так деньги не бесконечны (эээх жаль ). Теперь проверим удаление сосзданных ресурсов.

![alt text](/img/13.png)

![alt text](/img/14.png)

Все успешно созданные ВМ, сеть, подсеть, сервисный аккаунт, статический ключ и S3-bucket успешно удалились.

---
Написан github workflow который будет автоматически применять, обновление кода OpenTofu (Terraform).

Событие `workflow_dispatch` позволяет запускать применение и удаление кода в ручную.
При нажатии на кнопку Run workflow видно 2 условия, первое при вводе `true` запустит удаление инфраструктуры, второе запустит ее создание.

![alt text](/img/15.png)

Также при `git push` кода OpenTofu (Terraform) в `master` ветку репы запустится автоматическое применение этого кода. Это давет автоматическое обновление облачой конфигурации при изменении каких либо ресурсов и параметров.

Пример workflow запуска и удалени.

![alt text](/img/16.png)

![alt text](/img/17.png)

Код Workflow досупен [terraform-cloud.yml](https://github.com/mxssclxck/diplom-ffops-8/blob/master/.github/workflows/terraform-cloud.yml)

Выполненые [GitHub Actions](https://github.com/mxssclxck/diplom-ffops-8/actions) доступны по ссылке

Полный код Terraform для создания сервисного аккаунта, статического ключа и S3-bucket доступны по ссылке [terraform-s3](https://github.com/mxssclxck/diplom-ffops-8/tree/master/terraform-s3)

Полный код Terraform для создания сети, подсети, вм доступны по ссылке [terraform](https://github.com/mxssclxck/diplom-ffops-8/tree/master/terraform)

Входе выполнения работы код может быть изменен или дополнен.

## Теперь развернем кластер K8S

Успешно развернутая облачная инфраструктуру приступаю к развертыванию K8S кластера.

Развернем из репозитория Kubespray.
Сконирован на локальную машину репозиторий.

![alt text](/img/18.png)

```terraform

resource "local_file" "hosts_cfg_kubespray" {
	count = var.exclude_ansible ? 0 : 1

	content = templatefile("${path.module}/hosts.tftpl",{
		workers = yandex_compute_instance.worker
		masters = yandex_compute_instance.master
	})
	filename = "../../kubespray/inventory/mycluster/hosts.yml"
}

```

Данный код по пути ~/kubespray/inventory/mycluster/hosts.yml создаст файл hosts.yml и по шаблону автоматически заполнит его ip адресами нод.

Файл шаблона выглядит так:

```

all:
  hosts:%{ for idx, master in masters }
    master:
      ansible_host: ${master.network_interface[0].nat_ip_address}
      ip: ${master.network_interface[0].ip_address}%{ endfor }%{ for idx, worker in workers }
    worker-${idx + 1}:
      ansible_host: ${worker.network_interface[0].nat_ip_address}
      ip: ${worker.network_interface[0].ip_address}%{ endfor }
  children:
    kube_control_plane:
      hosts:%{ for idx, master in masters }
        ${master.name}:%{ endfor }
    kube_node:
      hosts:%{ for idx, worker in workers }
        ${worker.name}:%{ endfor }
    etcd:
      hosts:%{ for idx, master in masters }
        ${master.name}:%{ endfor }
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}

```

Перед запуском установки k8s на вм

Необходимо установить `pip install -r requirements.txt` из папки kubespray.

Потом запускаем команду установки
Переходим в директорию `~/kubespray/`

```
ansible-playbook -i inventory/mycluster/hosts.yaml -u ubuntu -b -v --private-key=~/.ssh/id_ed25519 cluster.yml

```

Ждем завершения установки:

![alt text](/img/19.png)

Теперь нужно создать конфигурационный файл кластера K8S:

Для этого надо подключится к мастер ноде и выполнить команды:

![alt text](/img/20.png)

Создаю директорию для хранения файла конфигурации, копируем созданный при установке Kubernetes кластера конфигурационный файл в созданную директорию и назначает права для пользователя на директорию и файл.

Теперь надо проверить доступны ли поды и ноды кластера:

![alt text](/img/21.png)

Видно что поды и ноды кластера доступны и находятся в состоянии готовности, следовательно развернутый k8s успешно завершен.

## Создам тестовое приложение

1. Создан репозиторий для тестового приложения:

![alt text](/img/22.png)

Создана статичная страница которая будет показывать текст и картинку.

![alt text](/img/23.png)

![alt text](/img/24.png)

Инициализирую git, делаю коммит и отправляю в репозиторий:

![alt text](/img/25.png)

![alt text](/img/26.png)

Ссылка на [репозиторий](https://github.com/mxssclxck/diplom-website-test)

2. Теперь напишу Dockerfile, который создаст контейнер с nginx и покажет страницу `index.html`.

![alt text](/img/27.png)

Теперь авторизуемся в Docker Hub:

![alt text](/img/28.png)

Создаем Docker image:

`docker build -t mrmxssclxck/diplom-website-test:0.1 .`

![alt text](/img/29.png)

Проверяю создался image:

`docker images`

![alt text](/img/30.png)

Образ создан.

Теперь опубликую созданный image в Docker Hub:

![alt text](/img/31.png)

Перешел на сайт Docker Hub проверю загрузился ли образ:

![alt text](/img/32.png)

Ссылка на [Docker Hub](https://hub.docker.com/repository/docker/mrmxssclxck/diplom-website-test/general)

Подготовка тестового приложения закончена.

## Готовим систему мониторинка и деплой приложения

Для удобства управления k8s кластером, скопирую конфигурационный файл с мастер ноды на свою локальную манишу и надо заменить IP адрес сервера:

Копирую с сервака файл конфигурации 

`scp ubuntu@:51.250.95.110~/.kube/config /home/thegamer8161/.kube/diplom/config`

![alt text](/img/33.png)

`export KUBECONFIG=~/.kube/diplom-k8s`

`kubectl get nodes`

Проверяю работу kubectl

![alt text](/img/34.png)

k8s кластер доступен с локальной машины.

Добавим репозиторий `prometeus-community` для установки и использую `helm`:

`helm repo add prometheus-community https://prometheus-community.github.io/helm-charts`

`helm repo update`

![alt text](/img/35.png)

А для доступа к Grafana снаружи кластера k8s используем тип сервиса NodePort.

Сохраним значение по умолчанию Helm чарта `prometheus-community` в файл и отредактируем его:

`helm show values prometheus-community/kube-prometheus-stack > helm-prometeus/values.yaml`

---

`mkdir helm-prometheus`

`helm show values prometheus-community/kube-prometheus-stack > helm-prometheus/values.yaml`

![alt text](/img/36.png)
---

Изменим пароль по умолчанию в Grafana:

![alt text](/img/37.png)

Изменю порт у сервиса:

![alt text](/img/38.png)

```
grafana:
	service:
		portName: http-web
		type: NodePort
		nodePort: 30050
```

И так теперь используя Helm и подготовленный файл значений `values.yaml` выполняю установку `prometheus-community`:

`helm upgrade --install monitoring prometheus-community/kube-prometheus-stack --create-namespace -n monitoring -f helm-prometheus/values.yaml --kube-insecure-skip-tls-verify`

![alt text](/img/39.png)

При установке создается отдельный Namespace с названием `monitoring`

Проверим результат установки:

`kubectl -n monitoring get pods -o wide`
`kubectl -n monitoring get svc -o wide`

![alt text](/img/40.png)

![alt text](/img/40_1.png)

Установка выполнена.
Файл значений `values.yaml`, использованный при установке `prometheus-community` доступен по [ссылке]()

Открываем web-gui Grafana:

![alt text](/img/41.png)

Авторизуюсь с измененым паролем выше:

![alt text](/img/42.png)

Видно авторизация успешна данные о состоянии кластера отображаются на dashbord'ах

![alt text](/img/43.png)

Мониторинг успешно развернут.

Теперь развернем тестовое приложение на k8s кластере.

Создаем отдельный Namespace, в котором будем разворачивать тестовое приложение:

`mkdir k8s-app`
`cd k8s-app`
`kubectl create namespace diplom-website`

![alt text](/img/44.png)

Готовим манифест Deployment с тестовым приложением:

```yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: diplom-ffops8-app
  namespace: diplom-website
  labels:
    app: web-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: diplom-website
        image: mrmxssclxck/diplom-website-test:0.1
        resources:
          requests:
            cpu: "1"
            memory: "200Mi"
          limits:
            cpu: "1"
            memory:  "400Mi"
        ports:
        containerPort: 80`
```

Применим данный манифест Deploymetn и посмотрим результат:

![alt text](/img/45.png)

`kubectl apply -f deployment.yml -n diplom-website`

`kubectl get deployment -n diplom-website`

Как видно Deployment создан и запущен. Проверим работу:

![alt text](/img/46.png)

Приложение в рабочем состоянии.

Ссылка на манифест [Deployment](/k8s-app/deployment.yml)

Теперь готовим манифест сервиса NodePort для доступа к web-интерфейсу тестового приложения

```yml

apiVersion: v1
kind: Service
metadata:
  name: diplom-ffops8-site-service
  namespace: diplom-website
spec:
  type: NodePort
  selector:
    app: web-app
  ports:
  - protocol: TCP
    port: 80
    nodePort: 30051

```

Применим манифест сервиса и проверим результат:

![alt text](/img/47.png)
`kubectl apply -f service.yml -n diplom-website`

`kubectl -n diplom-website get svc -o wide`

Сервис создан. Проверим доступ к приложению из интернета

![alt text](/img/48.png)

Видно сайт открывается

Ссылка на манифест [Service](/k8s-app/service.yml)

Из-за указанного в Deployment две реплики приложения для обеспечения отказоустойчивости, необходимо балансировщик нагрузки.

Готовим код OpenTofu (Terraform) для реализации балансировщика нагрузки. Создается группа балансирощика нагрузки она будет использоваться для балансировки м/у экземплярами.
Создаем балансировщик с именем grafana, ему даем прослушивать на порту 3000, который будет перенаправлять трафик на порт 30050, настраиваем проверку работоспособности (healthcheck) на порту 30050. Еще создаем балансировщик с именем web-app, он будет прослушивать 80 порт, который будет перенаправлять трафик на порт 30051 так же проверку работоспособности (healthcheck) на порту 30051.

Ссылка на код OpenTofu (Trraform) балансировщика нагрузки:
[loadbalanser.tf](/terraform/loadbalanser.tf)

После применения балансировщика к облачной инфраструктуре output будет выглятеть так:

![alt text](/img/49.png)

Проверим работу балансировщика нагрузки. Приложение будет открыватся по порту 80, а Grafana будет открываться по порту 3000:

- Тестовое приложение

![alt text](/img/50.png)

- Grafana

![alt text](/img/51.png)

В Grafana видно что отобразились созданный Namespace и Deployment c подами

Мониторин и тестовое приложение развернуто 

## Установка и настройка CI/CD

Для организации CI/CD буду использовать GitLab.

Создан пустой проект в GitLab c именем `dimlom-website-test`

![alt text](/img/52.png)

Отправляю в GitLab репозиторий созданный ранее статичную страницу и Dockerfile.

![alt text](/img/53.png)

![alt text](/img/54.png)

Для атоматизации процесса CI/CD нужен GitLab Runner, который будет выполнять задачи из файла .gitlab-ci.yml

В GitLab создаю ранер для проекта.

![alt text](/img/55.png)

Подготавливаю k8s кластера к установке GitLab Runner.
Создаю отдельный Namespace, в котором будет распологаться GitLab Runner и создам k8s secret, который будет использоваться для регистрации установленного GitLab Runner:

![alt text](/img/56.png)

Еще нужно подготовить файл значений values.yaml, для того, чтобы указать в нем количество Runners, время проверки наличия новых задач, настройка логирования, набор правил для доступа к ресурсам Kubernetes, ограничения на ресурсы процессора и памяти.

Файл значений values.yaml, который будет использоваться при установке GitLab Runner доступен по ссылке: [values.yaml](/helm-runner/values.yml)

Устанавливаем GitLab Runner. будем использовать Helm:

![alt text](/img/57.png)

Проверим результат установки

![alt text](/img/58.png)

GitLab Runner установили и запустили. Также можно через web-интерфейс проверить, подключился ли GitLab Runner к GitLab репозиторию:

![alt text](/img/59.png)

Подключение GitLab Runner к репозиторию GitLab завершено.

Для выполнения GitLab CI/CD Pipeline нужно в настройках созданного проекта в разделе Variables указать переменные:

![alt text](/img/60.png)

В переменных указан адрес реестра Docker Hub, данные для авторизации в нем, а также имя собираемого образа и конфигурационный файл Kubernetes для доступа к развёрнутому выше кластеру. Для большей безопасности конфигурационный файл Kubernetes размещен в формате base64. 
Также часть переменных будет указана в самом файле .gitlab-ci.yml.

Написан конфигурайионный файл .gitlab-ci.yml для автоматической сборки docker image и деплоя приложения при изменении кода.

Pipeline будет разделен на две стадии:

1. На первой стадии (build) будет происходить авторизация в Docker Hub, сборка образа и его публикация в реестре Docker Hub. Сборка образа будет происходить только для main ветки и только в GitLab Runner с тегом diplom. Сам процесс сборки происходит следующим образом - если при git push указан тег, то Docker образ будет создан именно с этим тегом. Если при git push тэг не указывать, то Docker образ будет собран с тегом `latest`. Cборка будет происходить на основе контейнера `gcr.io/kaniko-project/executor:v1.22.0-debug`. 
Так как не удалось запустить Docker-in-Docker в GitLab Runner и я получал ошибку доступа к docker.socket. 

2. На второй стадии (deploy) будет применяться конфигурационный файл для доступа к кластеру Kubernetes и манифесты из git репозитория. Также будет перезапущен Deployment методом rollout restart для применения обновленного приложение. 
Такой метод обновления полезен, например, если нужно обновить Frontend часть приложения незаметно для пользователя этого приложения. Эта стадия выполняться только для ветки master и на GitLab Runner с тегом diplom и только при условии, что первая стадия build была выполнена успешно.

Проверим работу Pipeline. Исходная страница приложения:

![alt text](/img/50.png)

В процессе изменения и отправки в репозиторий были ошибки в коде `.gitlab-ci.yml`

Не спервого раза применился deploy к куберу по этому с v0.2 прыгнул на v0.3

![alt text](/img/61.png)

В Docker Hub так же создался образ c v0.3

![alt text](/img/62.png)

И проверяю обновление на странице

![alt text](/img/63.png)

Теперь проверим что будет если просто пушим изменения без тега

![alt text](/img/64.png)

Проверим а что же происходит в докер хаб

![alt text](/img/65.png)

Оп image билд успешно создался c тегом `latest`.

Но деплой на кубер также не прошел вывалился в ошибку. В итоге снова в опечатка была в `.gitlab-ci.yml`.

![alt text](/img/66.png)

В итоге все получилось.

Ссылка на [пайплайн](https://gitlab.com/mrmxssclxck/diplom-website-test/-/pipelines) гитлаба 

Итог

- Репозиторий с конфигурационными файлами OpenTofu (Terraform)

[terraform-s3](https://github.com/mxssclxck/diplom-ffops-8/tree/master/terraform-s3)

[terraform](https://github.com/mxssclxck/diplom-ffops-8/tree/master/terraform)

- CI/CD OpenTofu(Terraform) pipeline

[workflow](https://github.com/mxssclxck/diplom-ffops-8/blob/master/.github/workflows/terraform-cloud.yml)

Для разворачивания k8s был использован [Kubespray](https://github.com/kubernetes-sigs/kubespray)

- Ссылка на [Docker Image](https://hub.docker.com/repository/docker/mrmxssclxck/diplom-website-test/tags)

- Ссылка на тестовое приложение: [http://158.160.168.8/](http://158.160.168.8/)

- Ссылка на web-gui Grafana c данными доступа:
[http://158.160.166.53:3000/](http://158.160.166.53:3000/)

`login: admin`\
`password: netologyNDAfops8`