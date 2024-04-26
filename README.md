# Smart sensor para sistemas distribuídos de medição: experimento do frenômetro
Esse repositório contém a implementação do projeto de um sensor inteligente (smart sensor) seguro para aplição em sistemas distribuídos de medição (DMS, do inglês, Distributed Measuring Systems). A implementação é parte da tese de doutorado do MEng. Eduardo Gonçalves Machado e da cooperação entre o Instituto Nacional de Metrologia, Qualidade e Tecnologia (Inmetro) e a empresa Auge Tecnologia e Produções Ltda (Auge Tech).

Grupo de pesquisa:
* Eduardo Gonçalves Machado (egmachado@colaborador.inmetro.gov.br)
* Eduardo Valente Alves Martins (evmartins@colaborador.inmetro.gov.br)
* Gustavo de Jesus Martins (gustavojmartins02@gmail.com)
* Rafael Tiribas Rabiega Gomes (rtrabiega@colaborador.inmetro.gov.br)

Orientadores:
* Wilson de Souza Melo Junior (wsjunior@inmetro.gov.br)
* Igor Leandro Vieira (augetechrj@gmail.com)

### Sobre o projeto
Desenvolvemos um sistema seguro para medir a capacidade de frenagem de veículos. Esse sistema visa garantir a integridade dos resultados de um tipo de DMS denominado frenômetro. A arquitura está dividida em três etapas de medição: sensoriamento, concretização da medição e armazenamento. Na primeira etapa os sinais da medição são criptografados em um kernel seguro no ambiente de execução confiável do processador (TEE, do inglês, Trust Enviroment Execution). A medição criptografada é enviada para uma rede blockchain, onde smart contracts realizam os cálculos necessários para obter o resultado de medição. Esse resultado é então armazenado no ledger do blockchain, não podendo ser alterada. A seguir é apresentada a implementação do ambiente seguro usando OP-TEE (tanto um protótipo com Raspberry Pi, como virtualização com Qemu). Na sequência, está descrita a implementação da rede blockchain em HyperLedger Fabric e do smart contract desenvolvido para concretizar as medições do frenômetro.

### Publicações relacionadas
As publicações a seguir estão relacionadas a este projeto.
[Blockchain-based Architecture to Enhance Security in Distributed Measurement Systems] (10.1109/CSDE59766.2023.10487656)
[Blockchain network to conformity assessment bodies] (https://metrologia2023.org.br/?page_id=6627)

### Financiamento
Este trabalho foi parcilamente financiado por pela Fundação Carlos Chagas Filho de Amparo à Pesquisa do Rio de Janeiro (FAPERJ), bolsas E-26/290.124/2021, E-26/205.266/2022, and E-26/260.179/2023 e pelo Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq), bolsa 151399/2023-9.

# Especificações de hardware
Durante as nossas instalações, foram usados dois dispositivos diferentes, sendo um notebook rodando linux Ubuntu e o Raspberry Pi, com as especificações citadas abaixo:
### Notebook:
Processador Intel(R) Core(TM) i3-7020U<br>
Linux Ubuntu versão 22.04.4 LTS

### Raspberry Pi:
Raspberry Pi 3 B+<br>
Processador com arquitetura ARMv8<br>
Cartão SD Sandisk 16 GB

# OP-TEE para Raspberry Pi e Qemu
OP-TEE é um "Trusted Execution Environment" (TEE) focado em garantir segurança para dispositivos. No nosso caso, estaremos usando ele para proteção de um Dispositivo de medição distribuida (ou DMS, em inglês). O OP-TEE divide o processador em dois "mundos". Apenas o mundo comum é liberado para acesso do usuário, permitindo apenas execução dos scripts e impedindo qualquer visualização e/ou alteração dos códigos e dados. Para fazer os processos descritos abaixo.
>[!TIP]
>Recomendamos utilizar um computador com um linux instalado, de preferência o Ubuntu. Não recomendamos o uso de máquinas virtuais, pois além do processo de virtualização deixar partes da instalação mais lentas, também pode afetar alguns procedimentos.

### Preparando a máquina
A instalação pode ser feita tanto para simulação no Qemu, quanto para instalação direta em um raspberry pi
>[!NOTE]
>Alguns modelos de raspberry podem não ser compatíveis com o sistema operacional do OP-TEE. Para mais informações, consultar o [site oficial](https://optee.readthedocs.io/en/latest/building/devices/rpi3.html#what-versions-of-raspberry-pi-will-work).

Antes de iniciar a instalação, é necessário instalar os seguintes pacotes:
```ruby
sudo apt install-y adb acpica-tools autoconf automake bc bison build-essential ccache cpio cscope curl device-tree-compiler e2tools\
expect fastboot flex ftp-upload disk git libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev\
libmpc-dev libncurses5-dev libpixman-1-dev libslirp-dev libssl-dev libtool libusb-1.0-0-dev make mtools netcat ninja-build\
python3-cryptography python3-pip python3-pyelftools python3-serial python-is-python3 rsync swig unzip uuid-dev wget xdg-utils xterm\
xz-utils zlib1g-dev curl
```
A seguir, deve-se instalar o Google Repo:
```ruby
sudo apt install repo
```
Próximo passo é criar uma pasta para armazenar os arquivos do OP-TEE. A pasta pode ser criada no diretório de preferência do usuário, mas deve-se ter em mente a localização dela para passos futuros.
Recomendamos a criação da pasta no diretório raiz do linux:
```ruby
mkdir optee     #O nome da pasta pode ser customizado pelo usuário
cd optee 
```
Atenção: Esse diretório só deve ser usado para uma das versões do OP-TEE. Caso queira usar ambas as duas, crie outra pasta separada da primeira.
### Instalação e emulação pelo QEMU
A simulação do OP-TEE é muito útil, pois pode ser usada tanto para testes de instalação, quanto para testes de scripts e trusted applications. Para fazer essa simulação, deve-se primeiramente iniciar o repositório do OP-TEE baseado para o QEMU:
```ruby
repo init -u https://github.com/OP-TEE/manifest.git -m default.xml -b 3.19.0
```
Ao executar este passo em uma máquina nova ou com o linux recém instalado, será necessário configurar o nome e e-mail de usuário do Github. Para isso, utilize o seguinte:
```ruby
git config --global user.name "Seu nome"
git config --global user.mail "SeuEmail@mail.com"
```
Após a inicialização do repositório na pasta, basta sincronizar:
```ruby
repo sync --no-clone-bundle
```
Terminada a sincronização, a simulação já pode ser iniciada com o comando `make run`. Três terminais serão abertos: Um para o mundo comum, um para o mundo seguro e um para controle da emulação. No terminal da emulação, digite `c` e a simulação irá iniciar. Para confirmar o funcionamento, pode-se fazer login como "root" e usar o comando `xtest`, que verifica se toda a instalação ocorreu como previsto.

### Instalação para o Raspberry Pi
O procedimento é similar ao da instalação para emulação, porém possui algumas diferenças nos passos e alguns procedimentos extras.

Para começar, crie um outro repositório:
```ruby
mkdir optee_rasp
cd optee_rasp
```






# braketester-smart-contract

We adopt [Hyperledger Fabric 2.2 LTS](https://hyperledger-fabric.readthedocs.io/en/release-2.2/) as our blockchain platform. We configure a globally distributed blockchain network that supports the execution of Golang chaincodes.

## The customized blockchain network

If you are not used to the Hyperledger Fabric, we strongly recommend this [tutorial](https://hyperledger-fabric.readthedocs.io/en/release-2.2/test_network.html). It teaches in detail how to create a test Fabric network.

### 1. Prepare the host machine.

You need to install the **Hyperledger Fabric 2.2 LTS** basic software and [dependencies](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html). We try to make things simpler by providing a shell script that installs all these stuff in a clean **Ubuntu 20.04 LTS** system. If you are using this distribution, our script works for you. If you have a different distribution, you can still try the script or customize it to work in your system.

Execute the **installation script**, localizated in prerequirements folder, in both host.

```console
./prerequirements/installFabric.sh
```

**OBSERVATION**: You do not need to run the script as *sudo*. The script will automatically ask for your *sudo* password when necessary. That is important to keep the docker containers running with your working user account. You will need to reboot your machine after execute this script.

### 2. Generate the MSP artifacts

The MSP artifacts include all the cryptographic stuff necessary to identify the peers of a Fabric network. They are basically asymmetric cryptographic key pairs and self-signed digital certificates. Currently, we are working on security policy to generate and distribute the MSP artifacts among organizations. As a workaround, only one organization must execute this procedure and replicate the MSP artifacts for the others. 

Execute the script to generate MSP artifacts in one host and copy to the other:

```console
./start.sh generateMSP
```

This script uses **configtx.yaml** and **crypto-config-nmi.yaml** to create the MSP certificates in the folder **crypto-config**. It also generates the genesis block file *genesis.block*. Notice that this script depends on the tools installed together with Fabric. The script *installFabric.sh* executed previously is expected to modify your $PATH variable and enable the Fabric tools' direct execution. If this does not happen, try to fix the $PATH manually. The tools usually are in the folder /$HOME/fabric-samples/bin.

### 3. Manage the docker containers

We use the **docker-compose** tool to manage the docker containers in our network. It reads the peer-*.yaml files and creates/starts/stops all the containers or a specific group of containers. You can find more details in the [Docker Compose Documents](https://docs.docker.com/compose/).


In both hosts, you must use the following command to start the network:

```console
./start.sh up
```

The same tool can be used to stop the containers, just if you need to stop the blockchain network for any reason. In a similar manner as done before, use the following command to stop all the containers:

```console
./start.sh down
```

### 4. Create the Fabric channel and join the peers

The next step consists of creating a channel (in practice, the ledger among the peers) and joining all the active peers on it. It is important to remember that we create a channel only once, in **host_aws**. Thus the first organization to start its peers *MUST* create the channel. The following organizations will only fetch for an existing channel and join on it. The script [start.sh](start.sh) implements both situations.

```console
./start.sh createChannel
```

If you succeed in coming so far, the Hyperledger Fabric shall be running in your server, with an instance of your organization network profile. You can see information from the containers by using the following commands:

```console
docker ps
docker stats
```

### 5. Deploy a chaincode

Chaincodes are smart contracts in Fabric. In this document, we assume you already know how to implement and deploy a chaincode. If it is not your case, there is a [nice tutorial](https://hyperledger-fabric.readthedocs.io/en/release-2.2/chaincode4ade.html) covering a lot of information about this issue. We strongly recommend you to check it before continuing.

A copy of the chaincode source is available [here](nesa/nesa.go).

Our blockchain network profiles include, for each organization, a client container *cli*, which effectively manages chaincodes. The *cli* is necessary to compile the chaincode and install it in an endorser peer. It is also handy to test chaincodes. It provides an interface to execute the command *peer chaincode*. 

By default, we associate *cli* with the *peer0* of the respective organization. You also can replicate its configuration to create additional client containers. We provide the script **start.sh** that encapsulates the use of a client container and simplifies the chaincode life cycle management. The script has the following syntax:

```console
./start.sh deployCC -ccn <chaincode name> -ccp <chaincode path> -ccl <chaincode language>
```

A example of this command is:

```console
./start.sh deployCC -ccn braketester -ccp braketester -ccl go
```

This command will do all you need to invoke the chaincode.

obs: Deploy first the chaincode in **host2_aws** and after in **host_aws**.

### 6. Test a chaincode

You can test the chaincode using this command.

```console
./start.sh testCC -c <channel-name> -ccn <chaincode name> -args <arguments>
```

## Dealing with client applications

The client application is a set of Python 3 modules that use the blockchain network's chaincode services.

You need to install some dependencies and libraries before getting the clients running correctly. We described all the steps necessary to prepare your machine to do that.

### Get pip3

Install the Python PIP3 using the following command:

```console
sudo apt install python3-pip
```

### Get the Fabric Python SDK

The [Fabric Python SDK](https://github.com/hyperledger/fabric-sdk-py) is not part of the Hyperledger Project. It is maintained by an independent community of users from Fabric. However, this SDK works fine, at least to the basic functionalities we need.

You need to install the Python SDK dependencies first:

```console
sudo apt-get install python-dev python3-dev libssl-dev
```

Now, install the Python SDK using *git*. Notice that the repository is cloned into the current path, so we recommend installing it in your $HOME directory. After cloning the repository, it is necessary to check out the tag associated with the version 1.0.

```console
cd $HOME
git clone https://github.com/hyperledger/fabric-sdk-py.git
cd fabric-sdk-py
git checkout tags/v1.0.0-beta
sudo make install
```

### Configure the .json network profile
The Python SDK applications depend on a network profile encoded in a .json format. Since we have two independent organizations, the network profile changes accordingly to them. In this repository, we provide the [inmetro.br.json](nesa-cli/inmetro.br.json) file. The network profile keeps the necessary credentials to access the blockchain network. You must configure this file properly every time that you create new digital certificates in the MSP:

* Open the respective .json in a text editor;
* Check for the entries called "tlsCACerts", "clientKey", "clientCert", "cert" and "private_key" on each organization. Notice that they point out to different files into the (./cripto-config) directory that corresponds to digital certificates and keys of each organization. The private key must correspond to the user who will submit the transactions (by default, we use Admin);
* Check the MSP file structure in your deployment and verify the correct name of the files that contain the certificates or keys;
* Modify the .json file with the correct name and path of each required file.

### The Client Application modules

The Client Application includes the following modules:

* [keygen-ecdsa.py](fabpki-cli/keygen-ecdsa.py): It is a simple Python script that generates a pair of ECDSA keys. These keys are necessary to run all the other modules.
* [register-ecdsa.py](fabpki-cli/register-ecdsa.py): It invokes the *registerMeter* chaincode, which appends a new meter digital asset into the ledger. You must provide the respective ECDSA public key.
* [verify-ecdsa.py](fabpki-cli/verify-ecdsa.py): It works as a client that verifies if a given digital signature corresponds to the meter's private key. The client must provide a piece of information and the respective digital signature. The client module will inform **True** for a legitimate signature and **False** in the opposite.
* [Insert Measurement](nesa-cli/InsertbMeasurement): The folder InsertMeasurement contains the clients responsible for collecting data from a path, convert in json format and calling chaincode methods to insert this data into the blockchain.
* [Query History](nesa-cli/countHistory.py): Count all transactions present in the ledger for an id.
* [Get Consumption](nesa-cli/getConsumption.py): Get the data of a meter id.
* [Mongo](nesa-cli/mongo.py): A client to acess directly the database of the blockchain.
* [App](nesa-cli/app.py): An interface to acess the clients using your browser.

## Using the Hyperledger Explorer

The [Hyperledger Explorer](https://www.hyperledger.org/projects/explorer) is a web tool that helps to monitor the blockchain network with a friendly interface. Our repository includes the extensions to use Explorer together with our experiment. We take the Explorer container-based distribution, that consists of two Docker images:
* **explorer**: a web server that delivers the application.
* **explorer-db**: a PostgreSQL database server that is required to run Explorer.

The following steps describe how to start and stop Explorer. Firstly, make sure that the blockchain network is up and that you executed the previous steps related to install and instantiate the *braketester* chaincode. You can check these points with the following command:

```console
docker ps
```
The Explorer is also a blockchain client. Before continuing, you must fix the Explorer connection profile, just like you did previously to the Python client. Again, we have this configuration in the [inmetro.br.json](explorer/inmetro.br.json) file. Notice that this file are very similar to our Python client connection profile. The procedure to fix them is also the same, with the difference that the Explorer **must** use the Admin credentials. Find the entries called "tlsCACerts", "clientKey", "clientCert", "signedCert" and "adminPrivateKey" of each organization. Replace them with the respective filenames in your MSP configuration, when necessary. **Do not change the files path** because it already points to the container's internal path that the Explorer knows (i.e., the path "/tmp/crypto" maps your local "./crypto-config" folder). Finally, edit the file [config.json](explorer/config.json) to point out for your organization connection profile (PTB or Inmetro).

Now, access the [explorer](explorer) folder and start the Hyperledger Explorer containers.
```console
cd explorer
docker-compose -f explorer-inmetro.yaml up -d
```

The first execution will pulldown the Docker images, and also create the PostgresSQL database. These procedures can require some time to execute. Wait 30 seconds and open the following local address in a web browser: [http://localhost:8080](http://localhost:8080). You must see the Hyperledger Explorer login screen.

* **login**: exploreradmin
* **password**: exploreradminpw

If you need to stop or shut down the Hyperledger Explore, proceed with the respective *docker-compose* commands, using *stop* to suspend the container's execution and *down* to remove the containers' instances. Here is an example:
```console
docker-compose -f explorer-ptb.yaml down
```

Eventually, you will need to remove the database volumes associated with the Hyperledger Explorer physically. You can do that by executing the following commands:
```console
docker volume prune
docker volume rm explorer_pgdata explorer_walletstore
```

### Issues

If you have any problem trying to bring up the network, creating the channel or deploying the chaincode, execute this steps:

First, bring down the network using the following command:

```console
./start.sh down
```

Now, use this to remove all volumes:

```console
docker volume rm $(docker volume ls)
```

This will solve most of your problems, so you can bring up the network again without any error. If that doesn't work, try praying. xD

