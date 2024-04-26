# Blockchain e Contratos Inteligentes

Nós usamos o [Hyperledger Fabric 2.2 LTS](https://hyperledger-fabric.readthedocs.io/en/release-2.2/) como nossa plataforma Blockchain. Nós configuramos uma distribuição global que suporta a execução de chaincode.

## A rede Blockchain customizada

Se você não está acostumado com o Hyperledger Fabric, recomendamos fortemente este [tutorial](https://hyperledger-fabric.readthedocs.io/en/release-2.2/test_network.html). Ele ensina em detalhes a como criar uma rede Fabric de teste.

### 1. Preparando a máquina.

Para realizar a instalação do Hyperledger Fabric 2.2 LTS e suas [dependências](https://hyperledger-fabric.readthedocs.io/en/latest/prereqs.html, é necessário seguir alguns passos específicos. Com o objetivo de simplificar o processo, disponibilizamos um script que automatiza a instalação de todos os componentes necessários em um sistema **Ubuntu 20.04 LTS** limpo. Caso você esteja utilizando essa distribuição, nosso script é adequado para o seu ambiente. Se estiver utilizando uma distribuição diferente, ainda é possível tentar executar o script ou personalizá-lo para funcionar em seu sistema.

Para iniciar a instalação, é necessário executar o script de instalação localizado na pasta de pré-requisitos em ambos os hosts. Você deve executar o seguinte comando no terminal do Linux:

```console
./prerequirements/installFabric.sh
```

**OBSERVAÇÃO**: Não é necessário executar o script como *sudo*. O script solicitará automaticamente sua senha de *sudo* quando necessário. Isso é importante para manter os contêineres Docker em execução com sua conta de usuário em uso. Será necessário reiniciar sua máquina após executar este script.

### 2. Gerando os artefatos MSP

Os artefatos MSP incluem todo o material criptográfico necessário para identificar os peers de uma rede Fabric. Basicamente, eles consistem em pares de chaves criptográficas assimétricas e certificados digitais autoassinados. Apenas uma organização precisa executar este procedimento e replicar os artefatos MSP para as outras.

Execute o script para gerar os artefatos MSP no host designado. Você pode utilizar o seguinte comando:

```console
./start.sh generateMSP
```

Este script utiliza os arquivos **configtx.yaml** e **crypto-config-nmi.yaml** para criar os certificados MSP na pasta **crypto-config**. Ele também gera o arquivo do bloco de gênese genesis.block. Observe que este script depende das ferramentas instaladas juntamente com o Fabric. O script installFabric.sh, executado anteriormente, deve modificar a variável $PATH e habilitar a execução direta das ferramentas do Fabric. Se isso não ocorrer, tente corrigir o $PATH manualmente. As ferramentas geralmente estão na pasta /$HOME/fabric-samples/bin.

### 3. Gerenciando os contêineres do docker

Utilizamos a ferramenta **docker-compose** para gerenciar os contêineres do docker em nossa rede. Essa ferramenta lê os arquivos peer-*.yaml e cria/inicia/interrompe todos os contêineres ou um grupo específico de contêineres. Você pode encontrar mais detalhes na Documentação do [Docker Compose Documents](https://docs.docker.com/compose/).


Em ambos os hosts, você deve utilizar o seguinte comando para iniciar a rede:

```console
./start.sh up
```

A mesma ferramenta pode ser usada para parar os contêineres, caso seja necessário interromper a rede blockchain por qualquer motivo. De maneira semelhante ao feito anteriormente, utilize o seguinte comando para parar todos os contêineres:

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

