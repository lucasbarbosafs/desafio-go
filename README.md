# Desafio GO - Curso Full Cycle
Este repositório contém a minha solução para o desafio proposto no Módulo de Docker do Curso Full Cycle 3.0.

## Desafio
O Desafio consistia nas seguintes etapas:

1) Gerar uma imagem docker que apresente a mensagem: "Full Cycle Rocks!!" utilizando a liguagem go.
2) A imagem final gerada não poderia ultrapassar o tamanho de 2MB.
3) Disponibilizar a imagem gerada no docker hub.

## Solução Etapa 1

Para resolver a primeira parte do desafio e gerar uma imagem docker que apresentasse a mensagem "Full Cycle Rocks!!" em GO, segui os seguintes passos:

1) Criei o arquivo *fullcycle.go* e adicionei o código responsável por imprimir a mensagem desejada:

```
package main

import "fmt"

func main() {
    fmt.Println("Full Cycle Rocks!!")
}
```

2) Depois criei o arquivo Dockerfile a partir de uma imagem base do golang disponível no docker hub:

```
FROM golang:1.21.3

WORKDIR /usr/src/app

COPY fullcycle.go /usr/src/app

RUN go mod init fullcycle && go build fullcycle.go

ENTRYPOINT [ "./fullcycle" ]
```

Nesse arquivo realizei a cópia do meu arquivo *fullcycle.go* da maquina host para o WORKDIR /usr/src/app, após isso iniciei um arquivo para o gerenciamento dos pacotes do go usando o comando ```go mod init fullcycle``` e realizei a compilação do meu arquivo *fullcycle.go* utilizando o comando ```go build fullcycle.go``` (segui o exemplo contido na [documentação](https://go.dev/doc/tutorial/getting-started) da linguagem). Os comandos foram concatenados utilizando o operador ```&&``` em um único comando RUN para não gerar camadas desnecessárias na imagem.

Para validar essa etapa realizei a construção da imagem utilizando o comando:

```docker build -t lucasbarbosafs/fullcycle .``` 

e após a construção da imagem executei o container com o comando:

```docker run --rm lucasbarbosafs/fullcycle```.

Feito isso, a mensagem "Full Cycle Rocks!!" foi impressa no console.

## Solução Etapa 2

Ao construir a imagem na etapa anterior obtive um tamanho total de aproximadamente 842MB, e como a segunda etapa do desafio exigia que a imagem final possuisse menos de 2MB precisei fazer mais modificações no Dockerfile e usar o conceito de *multi stage build*. Esse conceito permite criar etapas de build intermediárias e "carregar" para o próximo estágio somente o resultado desejado do build anterior. Após aplicar esse conceito, construi o seguinte Dockerfile:

```
FROM golang:1.21.3 AS BUILDER

WORKDIR /usr/src/app

COPY fullcycle.go /usr/src/app

RUN go mod init fullcycle && go build fullcycle.go

FROM scratch

WORKDIR /usr/src/app

COPY --from=BUILDER /usr/src/app /usr/src/app

ENTRYPOINT [ "./fullcycle" ]
```

Como pode-se observar existem agora dois estágios de construção da imagem, o primeiro estágio (Primeiro FROM do Dockerfile) é responsável por compilar o arquivo *fullcycle.go* e gerar o seu executável. Já o segundo estágio (Segundo FROM do Dockerfile) é iniciado a partir de uma imagem denominada ```scratch```, que representa uma imagem mínima e vazia do docker. Essa imagem irá receber uma cópia do executável gerado no primeiro estágio e a partir daí executá-lo através do comando ```ENTRYPOINT```.

Para validar essa etapa realizei novamente a construção da imagem utilizando o comando:

```docker build -t lucasbarbosafs/fullcycle .``` 

e após a construção da imagem executei o container com o comando:

```docker run --rm lucasbarbosafs/fullcycle```.

Obtivemos o mesmo resultado da etapa anterior, só que agora a nova imagem construída passou a ocupar somente 1.8MB. Essa redução se deve ao fato de que a nova imagem conterá somente o executável que por si só já possui todo o necessário para sua própria execução.

## Dificuldades encontradas na Etapa 2

Antes de chegar ao resultado final citado na Solução da etapa 2, tive algumas dificuldades, pois inicialmente pensei em utilizar o conceito de *multi stage build* com imagens baseadas no linux alpine e por mais que tentasse otimizar a construção da imagem o menor tamanho que conseguia obter era de aproximadamente 7MB. 

Após um tempo de pesquisa, percebi que por menor que seja uma imagem do linux alpine ela por si só já carrega algumas camadas que somadas ao tamanho do executável ultrapassavam o limite proposto no desafio e a partir disso passei a pesquisar pelas menores imagens do docker, foi a partir daí que consegui encontrar a imagem ```scratch``` do docker.

A imagem ```scratch``` representa uma imagem vazia do docker, não possuindo arquivos e/ou pastas e serve como ponto de partida para construção de imagens. Como o executável gerado é independente e possui por si só todo o necessário para sua própria execução e a imagem ```scratch``` não possui nenhuma camada adicional, a nova imagem possuirá somente uma camada com o tamanho do próprio executável.

## Solução Etapa 3

Após otimizar o tamanho da imagem, restou somente a última parte do desafio que era a disponibilização da imagem gerada no Docker Hub. 

Para disponibilizar a imagem gerada na etapa 2 no Docker Hub bastou realizar o login através do comando ```docker login``` com as credenciais do meu usuário na plataforma e realizar o push da imagem através do comando ```docker push lucasbarbosafs/fullcycle```.

## Considerações finais

Ao concluir o desafio pude perceber um pouco mais o poder do docker, primeiramente por conseguir compilar e executar uma aplicação em Go sem ter que instalar toda a infraestrutura necessária na minha máquina local, fazer isso de uma forma isolada é realmente muito benéfico e poupa muito tempo gasto em configurações de ambiente. Outro ponto que pude reforçar no decorrer do desafio foi o conceito de *multi stage build*, a capacidade de criar etapas intermediárias e levar para os proximos estágios somente os artefatos desejados otimiza muito a criação e o tamanho das novas imagens, fora o fato de podermos fazer tudo isso dentro de um mesmo Dockerfile.

## Execução da nova imagem a partir do Docker Hub

Como minha imagem foi disponibilizada no Docker com o nome de ```lucasbarbosafs/fullcycle```, caso queira executar um container a partir dela, basta executar o seguinte comando:

```docker run lucasbarbosafs/fullcycle```

Link da imagem no Docker Hub: https://hub.docker.com/r/lucasbarbosafs/fullcycle