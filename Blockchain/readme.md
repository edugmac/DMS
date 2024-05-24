# Blockchain e Contratos Inteligentes

Usamos o [Hyperledger Fabric 2.2 LTS](https://hyperledger-fabric.readthedocs.io/en/release-2.2/) como nossa plataforma Blockchain. Configuramos uma distribuição global que suporta a execução de chaincode.

## A rede Blockchain customizada

Se você não está acostumado com o Hyperledger Fabric, recomendamos fortemente este [tutorial](https://hyperledger-fabric.readthedocs.io/en/release-2.2/test_network.html). Ele ensina em detalhes a como criar uma rede Fabric de teste.

### 1. Preparando a máquina.

Para realizar a instalação do Hyperledger Fabric 2.2 LTS e suas [dependências](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html), é necessário seguir alguns passos específicos. Com o objetivo de simplificar o processo, disponibilizamos um script que automatiza a instalação de todos os componentes necessários em um sistema **Ubuntu 22.04 LTS** limpo. Caso você esteja utilizando essa distribuição, nosso script é adequado para o seu ambiente. Se estiver utilizando uma distribuição diferente, ainda é possível tentar executar o script ou personalizá-lo para funcionar em seu sistema.

Para iniciar a instalação, é necessário executar o script de instalação localizado na pasta de pré-requisitos. Você deve executar o seguinte comando no terminal do Linux:
```console
cd DMS/Blockchain/projeto-braketester-main/OneHost
./prerequirements/installFabric.sh
```

> [!NOTE]
> Não é necessário executar o script como *sudo*. O script solicitará automaticamente sua senha de *sudo* quando necessário. Isso é importante para manter os contêineres Docker em execução com sua conta de usuário em uso. Será necessário reiniciar sua máquina após executar este script.

### 2. Gerando os artefatos MSP
Execute o script para gerar os artefatos MSP no host designado. Você pode utilizar o seguinte comando:
```console
./start.sh generateMSP
```
> [!WARNING]
> Algumas redes empresariais, como no caso do Inmetro, podem bloquear parte da instalação. Caso algum erro aconteça no passo atual, troque a rede do dispositivo e refaça o passo anterior, isso irá resolver o problema.

Os artefatos MSP incluem todo o material criptográfico necessário para identificar os peers de uma rede Fabric. Basicamente, eles consistem em pares de chaves criptográficas assimétricas e certificados digitais autoassinados. Apenas uma organização precisa executar este procedimento e replicar os artefatos MSP para as outras.

Este script utiliza os arquivos **configtx.yaml** e **crypto-config-nmi.yaml** para criar os certificados MSP na pasta **crypto-config**. Ele também gera o arquivo do bloco de gênese genesis.block. Observe que este script depende das ferramentas instaladas juntamente com o Fabric. O script installFabric.sh, executado anteriormente, deve modificar a variável $PATH e habilitar a execução direta das ferramentas do Fabric. Se isso não ocorrer, tente corrigir o $PATH manualmente. As ferramentas geralmente estão na pasta /$HOME/fabric-samples/bin.

### 3. Gerenciando os contêineres do docker

Você deve utilizar o seguinte comando para iniciar a rede:
```console
./start.sh up
```
Utilizamos a ferramenta **docker-compose** para gerenciar os contêineres do docker em nossa rede. Essa ferramenta lê os arquivos peer-*.yaml e cria/inicia/interrompe todos os contêineres ou um grupo específico de contêineres. Você pode encontrar mais detalhes na [Documentação Oficial](https://docs.docker.com/compose/).</br>
A mesma ferramenta pode ser usada para parar os contêineres, caso seja necessário interromper a rede blockchain por qualquer motivo.</br>
De maneira semelhante ao feito anteriormente, utilize o seguinte comando para parar todos os contêineres:
```console
./start.sh down
```

### 4. Criando o channel no Fabric e reunindo os peers

O próximo passo consiste em criar um channel (na prática, o ledger que reúne os peers) e unir todos os peers ativos a ele. É importante lembrar que criamos um canal apenas uma vez, no **OneHost**. Portanto, a primeira organização a iniciar seus pares *DEVE* criar o canal. As organizações subsequentes apenas buscarão por um canal existente e se juntarão a ele. O script [start.sh](start.sh) implementa ambas as situações.

Para a implementação do channel, execute o seguinte código:
```console
./start.sh createChannel
```

Se você conseguiu chegar até aqui, o Hyperledger Fabric estará em execução em seu servidor, com uma instância do perfil de rede de sua organização. Você pode visualizar informações dos contêineres utilizando os seguintes comandos:

```console
docker ps     #Exibe as informações gerais dos contâineres
docker stats  #Exibe informações em tempo real
```

### 5. Implantando um chaincode

Os chaincodes são contratos inteligentes no Fabric. Neste documento, presumimos que você já saiba como implantar um chaincode. Se esse não for o seu caso, há um ótimo [tutorial](https://hyperledger-fabric.readthedocs.io/en/release-2.2/chaincode4ade.html) que abrange muitas informações sobre este assunto. Recomendamos fortemente que você o consulte antes de prosseguir.

Nossos perfis de rede blockchain incluem, para cada organização, um contêiner cliente *cli*, que efetivamente gerencia os chaincodes. O *cli* é necessário para compilar o chaincode e instalá-lo em um peer endossador. Também é útil para testar chaincodes, fornecendo uma interface para executar o comando peer chaincode.

Por padrão, associamos *cli* ao *peer0* da respectiva organização. Você também pode replicar sua configuração para criar contêineres de cliente adicionais. Fornecemos o script start.sh que encapsula o uso de um contêiner cliente e simplifica o gerenciamento do ciclo de vida do chaincode. 

Para instalar o nosso chaincode, utilize o código abaixo:

```console
./start.sh deployCC -ccn braketester -ccp braketester -ccl go
```
Esse comando fará tudo o que você precisa para invocar um chaincode.
> [!TIP]
> Caso queira instalar um chaincode próprio, considere a estrutura do código como *./start.sh deployCC -ccn &lt;chaincode name&gt; -ccp &lt;chaincode path&gt; -ccl &lt;chaincode language&gt;*, editando somente as partes necessárias.


### 6. Testando um chaincode

Você pode testar um chaincode usando o seguinte comando.

```console
./start.sh testCC -c <channel-name> -ccn <chaincode name> -args <arguments>
```

## Lidando com aplicações clientes

A aplicação cliente é um grupo de modulos Python 3 que usa os serviços de chaincode da rede Blockchain.

Você precisa instalar algumas dependências e bibliotecas antes de conseguir rodar os clientes corretamente. Nós descrevemos todos os passos necessários para preparar a sua maquina para fazer isso.

### Instalar pip3

Instale o Python PIP3 usando o seguinte comando:

```console
sudo apt install python3-pip
```

### Instale o Fabric Python SDK

O [Fabric Python SDK](https://github.com/hyperledger/fabric-sdk-py) não é parte do projeto Hyperledger. Ele é mantido por uma comunidade indepentente de usuários do Fabric. Porém, este SDK funciona perfeitamente para as nossas necessidades.

Você precisa instalar as suas dependências antes:

```console
sudo apt-get install python-dev python3-dev libssl-dev
```

Agora, instale o Python SDK usando o *git*. 
>[!NOTE]
> Note que o repositório é clonado no caminho atual, portanto, recomendamos instalar no seu diretório `$HOME`. Após clonar o repositório, é necessario checar a tag associada com a versão 1.0.

```console
cd $HOME
git clone https://github.com/hyperledger/fabric-sdk-py.git
cd fabric-sdk-py
git checkout tags/v1.0.0-beta
sudo make install
```

### Configure o perfil .json da rede
As aplicações do Python SDK dependem de um perfil da rede codificado em um formato .json. Como temos duas organizações independentes, o perfil da rede muda de acordo com elas. Neste repositório, nós disponibilizamos o arquivo [inmetro.br.json](braketester-cli/inmetro.br.json). O perfil da rede contém as credenciais necessarias para acessar a rede Blockchain. Você deve configurar este arquivo propriamente cada vez que quiser adicionar novos certificados digitais ao MSP:

* Abra o texto em um editor .json;
* Cheque por entradas nomeadas "tlsCACerts", "clientKey", "clientCert", "cert" e "private_key" em cada organização. Note que elas apontam para diferentes arquivos no diretório (./cripto-config) que corresponde aos certificados digitais e chaves de cada organização. A chave privada deve corresponder com o usuário que submeter as transações (por padrão, usamos Admin);
* Cheque a estrutura de arquivos MSP na sua instalação e verifique o nome correto dos arquivos que contém certificados ou chaves;
* Modifique o arquivo .json com o nome e caminho correto para cada arquivo requerido.

### Módulos da aplicação cliente

A aplicação cliente contém os seguintes módulos:

* [keygen-ecdsa.py](fabpki-cli/keygen-ecdsa.py): É um simples script Python que gera um par de chaves ECDSA. Essas chaves são necessarias para executar todos os outros módulos.
* [register-ecdsa.py](fabpki-cli/register-ecdsa.py): Invoca o chaincode *registerMeter*, que acrescenta um novo asset de medidor digital ao ledger. Você deve prover a chave ECSDA pública respectiva.
* [verify-ecdsa.py](fabpki-cli/verify-ecdsa.py): Funciona como um cliente que verifica se uma dada assinatura digital corresponde com a chave privada do medidor. O cliente deve prover alguma informação e a assinatura digital respectiva. O modulo cliente vai informar **True** para uma assinatura digital legitima e **false** caso contrário. 
* [Insert Measurement](braketester-cli/InsertbMeasurement): A pasta InsertMeasurement contém os clientes responsáveis por coletar dados de um path, convertido em formato json e chamar os métodos do chaincode para inserir esses dados na rede Blockchain.
* [Query History](braketester-cli/countHistory.py): Conta todas as transações presentes no ledger para um ID.
* [Get Consumption](braketester-cli/getConsumption.py): Pega os dados de um ID de um medidor.
* [Mongo](braketester-cli/mongo.py): Um cliente para acessar diretamente a  banco de dados da rede Blockchain.
* [App](braketester-cli/app.py): Uma interface para acessar os clientes usando o seu navegador.

## Usando o Hyperledger Explorer

O [Hyperledger Explorer](https://www.hyperledger.org/projects/explorer) é uma ferramenta web que ajuda a monitorar a rede com uma interface mais amigável. Nosso repositório inclui as extensões para usar o Explorer junto do nosso experimento. Nós usamos a distribuição baseada em contêineres do Explorer, que consite em duas imagens Docker:
* **explorer**: Um web server que entrega a aplicação.
* **explorer-db**: Um servidor banco de dados PostrgreSQL que é necessário para rodar o Explorer a PostgreSQL.

Os passos seguintes descrevem como iniciar e parar o explorer. Primeiramente, confirme que a rede blockchain está ativa e que você executou os passos anteriores relacionados a instalar e instânciar o chaincode *braketester*. Você pode checar estes pontos com o seguinte comando:

```console
docker ps
```
O explorer também é um cliente blockchain. Antes de continuar, você deve consertar o perfil de conexão do Explorer, assim como você fez anteriormente com o cliente Python. Novamente, nós temos esta configuração no arquivo [inmetro.br.json](explorer/inmetro.br.json). Note que este arquivo é muito similar com o nosso perfil de conexão do cliente Python. O procedimento para consertá-los também é o mesmo, com a diferença de que o explorer **deve** usar as credenciais de Admin. Encontre as entradas nomeadas "tlsCACerts", "clientKey", "clientCert", "signedCert" e "adminPrivateKey" de cada organização. Troque elas com os nomes respectivos em sua configuração MSP, quando necessário. **Não mude o caminho dos arquivos** porque ele já aponta para o caminho interno dos contâineres que o Explorer conhece (por exemplo, o caminho "/tmp/crypto" a sua pasta local "./crypto-config"). Finalmente, edite o arquivo [config.json](explorer/config.json) para apontar para o seu perfil de conexão da organização (Braketester ou Inmetro).

Agora, acesse a pasta [explorer](explorer) e inicie os contâineres do Hyperledger Explorer.
```console 
cd explorer
docker-compose -f explorer-inmetro.yaml up -d
```

A primeira execução vai baixar as imagens Docker e criar o banco de dados PostgresSQL. Esses procedimentos podem necessitar de algum tempo para executar. Espere 30 segundos e abra o seguinte endereço local em um navegador web: [http://localhost:8080](http://localhost:8080). Você deve agora ver a tela de login do Hyperledger Explorer.

* **login**: exploreradmin
* **password**: exploreradminpw

Se você precisa desligar ou parar o Hyperledger Explorer, prossiga com os seguintes comandos *docker-compose*, usando *stop* para suspender a execução dos contâineres e *down* para remover as instâncias deles. Aqui está um exemplo:
```console
docker-compose -f explorer-ptb.yaml down
```

Eventualmente, você irá necessitar de remover os volumes do banco de dados associados com o Hyperledger Fabric físicamente. Você pode fazer isso executando os seguintes comandos:
```console
docker volume prune
docker volume rm explorer_pgdata explorer_walletstore
```

# Problemas conhecidos

Se caso no passo para gerar os artefatos MSP você receba um erro do tipo:
```console
configtxgen tool not found
```
Faça o que está descrito na caixa de alerta, abaixo do código. Isso deverá resolver o problema.

Se você tiver qualquer problema tentando subir a rede, criando os channels ou implantando o chaincode, execute os seguintes passos:

Primeiro, derrube a rede usando o seguinte comando:

```console
./start.sh down
```

Agora, use isso para remover todos os volumes:

```console
docker volume rm $(docker volume ls)
```

Isso resolverá a maioria dos seus problemas para que você possa subir a rede novamente sem nenhum erro.
