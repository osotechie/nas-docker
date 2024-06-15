<div align="center">

<img src="https://avatars.githubusercontent.com/u/34251619?v=4" align="center" width="144px" height="144px"/>

### NAS Docker Stacks Repo
_... managed with GitHub Actions_ 🤖

[![VALIDATION](https://github.com/osotechie/nas-docker/actions/workflows/validation.yml/badge.svg)](https://github.com/osotechie/nas-docker/actions/workflows/validation.yml) [![DEPLOY](https://github.com/osotechie/nas-docker/actions/workflows/deploy.yml/badge.svg)](https://github.com/osotechie/nas-docker/actions/workflows/deploy.yml)

</div>


---

## 📖 Overview

This repo is for my docker stacks I use on my home NAS. I am trying to adhere to Infrastructure as Code (IaC) and CI/CD practices to manage my NAS using tools like [Ansible](https://www.ansible.com/), [Docker](https://www.docker.com/), and [GitHub Actions](https://github.com/features/actions).

---

## 🏗️ Structure
I have created the following structure to store my docker stacks. The structure reflects the different functions I use docker for.

```
📁 {functional area}       -  sub folder to house all the files related to a given functional area (e.g. homeautomation, media, network)
├─🗒️ .env                   -  contains the environment variables used within the docker-compose.yml
└─🗒️ docker-compose.yml    -  contains the configuration for each of the docker containers I run related to the functional area.
```

## 🤐 Secrets & Variables
To avoid storing secrets in the .env or docker-compose.yml files I use a combination of environment variables GitHub Secrets, and Azure KeyVault.

For any sensitive information contained within the docker-compose.yml I specify environment variable tags (e.g. ${TAG}), that I then create a matching entry in the associated .env file for the docker stack.

> [!NOTE]
> For more information about using environment variables in your docker compose files, refer to the following [Ways to set environment variables with Compose | Docker Docs](https://docs.docker.com/compose/environment-variables/set-environment-variables/).  


Within the .env file I then create a token (e.g. #{TAG}#), that I can then use the [Replace Token](https://github.com/marketplace/actions/replace-tokens) step to update the value with the actual secret from either GitHub Action Repo Secrets, or Azure KeyVault.

For GitHub Secrets I simply create a new GitHub Action Repo Secret, this will automatically be made available to any Actions in the repo, and the "Replace Tokens" step to update the .env files. I typically don't use GitHub Action Repo Secrets as you can't easily edit or see the current value of the Secret.

For Azure KeyVault secrets, I use several some additional steps within the GitHub Action to securely connect to Azure KeyVault and retreive secrets ([Azure KeyVault - Get Secrets Fast](https://github.com/marketplace/actions/azure-keyvault-get-secrets-fast)) which then makes them available as secrets within the running Action (just like GitHub Actions Repo Secret).


## 📑 TEMPLATES

### 🗒️ .env
The following is a template .env file for a new docker stack

```sh
#General Variables
COMPOSE_PROJECT_NAME={functional area}
TZ=Pacific/Auckland
DOCKERDIR=/docker/${COMPOSE_PROJECT_NAME}
DOMAIN=#{DOMAIN}#

#Stack Specific Variables
MYSECRET: #{MYSECRET}#

```
> [!TIP]
> Remember to update the following in the above template with the correct values:
>
> - [x] ***{functional area}*** - replace this with the name functional name for this docker stack. I typically name these the same as the folder they reside in (e.g. ai, or proxy)

### 🗒️ docker-compose.yml
The following is a starting template docker-compose.yml file for a new docker stack. This template is based on my own environment and how I typically layout my docker environment.

```yml
services: 

  {ContainerName}:
    container_name: {ContainerName}
    hostname: {containername}
    image: {docker image}
    restart: always
    networks:
      {COMPOSE_PROJECT_NAME}:
    environment:
      - SECRET=${MYSECRET}
    labels:
    # Traefik - Service
    - traefik.enable=true
    - traefik.http.services.{containername}.loadbalancer.server.port={port}
    # Traefik - Router - HTTPS
    - traefik.http.routers.{containername}.rule=Host(`autogen.${DOMAIN}`)
    - traefik.http.routers.{containername}.entryPoints=websecure
    - traefik.http.routers.autogen.middlewares=Real-IP@file, Headers@file

#Shared Networks between containers
networks:
  #Internal Docker Networks
  {COMPOSE_PROJECT_NAME}:
    name: {COMPOSE_PROJECT_NAME}

```
> [!TIP]
> Remember to update the following in the above template with the correct values:
> - [x] ***{ContainerName}*** - replace this with the Display Name for the Container. Usually as one word without spaces (e.g. HomeAssistant)
> - [x] ***{containername}*** - replace this with the hostname of the container. Usually I match this to the Display Name, usually in lowercase and as again as one word (e.g. homeassistant)
> - [x] ***{docker image}*** - replace this with the reference to the docker image the contaier will be using (e.g. homeassistant/home-assistant:latest)
> - [x] ***{COMPOSE_PROJECT_NAME}*** - replace this with the name of the docker stack.


I typically like to configure my stacks with the following standards. As such you will note the following:

1. I set the *container_name* and *hostname* to be the same
2. I typically always set my containers to *restart: always* to ensure they automatically restart if there are issues
3. My traefik services and routers use the name of the container they are releated to
4. I typically create an internal network per stack, matching the network to the docker stacks name
