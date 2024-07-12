# Documentação da Infraestrutura AWS com Terraform

Este repositório contém a configuração do Terraform para criar e gerenciar uma instância EC2 na AWS, incluindo configuração de rede, grupo de segurança e script de inicialização para rodar um contêiner Docker. O propósito é provisionar uma infraestrutura automatizada, facilitando o deploy contínuo e a gestão de infraestrutura como código.

## Visão Geral

### Provedor e Backend
- **provider.tf**: Define o provedor AWS e a região onde os recursos serão criados.
- **backend.tf**: Configura o backend remoto no S3 para armazenar o estado do Terraform, garantindo que múltiplos usuários possam colaborar e que o estado seja persistente.

### Data Source
- **data.tf**: Utiliza um data source para obter o ID do Elastic IP usado para a aplicação.

### Instância EC2
- **ec2.tf**: Cria uma instância EC2 usando a AMI obtida, especifica um script de inicialização (`user_data.sh`) que instala o Docker, inicia o serviço e executa um contêiner Docker.

### Grupo de Segurança
- **sg.tf**: Configura uma security group para permitir tráfego HTTP (porta 80) e SSH (porta 22).

### Saída
- **outputs.tf**: Define os valores de saída, como o endereço público da instância EC2, para facilitar o acesso pós-provisionamento.

### Script de Inicialização
- **user_data.sh**: Script executado na inicialização da instância EC2 que instala e configura o Docker, e roda um contêiner específico.

## Estrutura dos Arquivos

### provider.tf
```hcl
provider "aws" {
  region = "us-west-2"
}

```

### backend.tf
```hcl
terraform {
  backend "s3" {
    bucket = "meu-terraform-bucket"
    key    = "path/to/my/key"
    region = "us-west-2"
  }
}
```

### data.tf
```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

### data.tf
```hcl
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}
```

### ec2.tf

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"

  user_data = file("user_data.sh")

  tags = {
    Name = "WebServer"
  }
}

### sg.tf
```hcl
resource "aws_security_group" "web_sg" {
  name_prefix = "web-sg-"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### outputs.tf

```hcl
output "instance_ip" {
  value = aws_instance.web.public_ip
}
```

### user_data.sh

```bash
#!/bin/bash

sudo su
yum update -y
yum install -y docker
service docker start
usermod -a -G docker ec2-user
docker run -p 80:80 --rm --name app-orbbi marialazararibeiro/orbbi-app

```

## Passos para Uso

1. **Configurar Credenciais AWS**: Certifique-se de que suas credenciais AWS estão configuradas em seu ambiente.
2. **Inicializar o Terraform**:
    
    ```
    terraform init
    
    ```
    
3. **Planejar a Infraestrutura**:
    
    ```
    terraform plan
    
    ```
    
4. **Aplicar as Mudanças**:
    
    ```
    terraform apply
    
    ```
    
5. **Acessar a Instância**: Após a execução bem-sucedida, o endereço IP público da instância será exibido como saída.

# Integração com GitLab CI/CD

## Estágios da Pipeline

A pipeline é composta pelos seguintes estágios:

1. **Validate**: Verifica se a configuração do Terraform é válida.
2. **Plan**: Gera um plano de execução para a infraestrutura desejada.
3. **Apply**: Aplica as mudanças planejadas na infraestrutura.
4. **Destroy**: (Comentado) Remove a infraestrutura criada.

## Configuração da Pipeline

### Imagem Docker

A pipeline utiliza a imagem `hashicorp/terraform:light`, que contém o Terraform instalado.

```yaml
image:
  name: hashicorp/terraform:light
  entrypoint:
  - '/usr/bin/env'
  - 'PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin'
```
### Antes dos Scripts

Antes de executar qualquer estágio, as seguintes ações são realizadas:

- Exportação das chaves de acesso da AWS.
- Remoção do diretório `.terraform` (se existir).
- Verificação da versão do Terraform instalada.
- Inicialização do Terraform.

```yaml
before_script:
- export AWS_ACCESS_KEY=${AWS_ACCESS_KEY_ID}
- export AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
- rm -rf .terraform
- terraform --version
- terraform init
```
### Plan

O estágio `plan` cria um plano de execução para a infraestrutura e salva em um arquivo chamado `planfile`. Este estágio depende do estágio `validate`.

```yaml
plan:
  stage: plan
  script:
  - terraform plan -out "planfile"
  dependencies:
  - validate
  artifacts:
    paths:
    - planfile

```

### Apply

O estágio `apply` aplica as mudanças descritas no `planfile`. Este estágio depende do estágio `plan`.

```yaml
apply:
  stage: apply
  script:
  - terraform apply -input=false "planfile"
  dependencies:
  - plan
  #when: manual

```

### Destroy

O estágio `destroy` (atualmente comentado) remove toda a infraestrutura criada. 

```yaml
#destroy:
#  stage: destroy
#  script:
#  - terraform destroy -auto-approve

```


