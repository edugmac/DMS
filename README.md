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

# Sobre o projeto
Desenvolvemos um sistema seguro para medir a capacidade de frenagem de veículos. Esse sistema visa garantir a integridade dos resultados de um tipo de DMS denominado frenômetro. A arquitura está dividida em três etapas de medição: sensoriamento, concretização da medição e armazenamento. Na primeira etapa os sinais da medição são criptografados em um kernel seguro no ambiente de execução confiável do processador (TEE, do inglês, Trust Enviroment Execution). A medição criptografada é enviada para uma rede blockchain, onde smart contracts realizam os cálculos necessários para obter o resultado de medição. Esse resultado é então armazenado no ledger do blockchain, não podendo ser alterada. A seguir é apresentada a implementação do ambiente seguro usando OP-TEE (tanto um protótipo com Raspberry Pi, como virtualização com Qemu). Na sequência, está descrita a implementação da rede blockchain em HyperLedger Fabric e do smart contract desenvolvido para concretizar as medições do frenômetro.

# Publicações relacionadas
As publicações a seguir estão relacionadas a este projeto.
[Blockchain-based Architecture to Enhance Security in Distributed Measurement Systems] (10.1109/CSDE59766.2023.10487656)
[Blockchain network to conformity assessment bodies] (https://metrologia2023.org.br/?page_id=6627)

# Financiamento
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

## Preparando a máquina
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
## Instalação e emulação pelo QEMU
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

## Instalação para o Raspberry Pi
O procedimento é similar ao da instalação para emulação, porém possui algumas diferenças nos passos e alguns procedimentos extras.

Para começar, crie um outro repositório:
```ruby
mkdir optee_rasp
cd optee_rasp
```

