# OP-TEE para Raspberry Pi e Qemu
OP-TEE é um "Trusted Execution Environment" (TEE) focado em garantir segurança para dispositivos. No nosso caso, estaremos usando ele para proteção de um Dispositivo de medição distribuida (ou DMS, em inglês). O OP-TEE divide o processador em dois "mundos". Apenas o mundo comum é liberado para acesso do usuário, permitindo apenas execução dos scripts e impedindo qualquer visualização e/ou alteração dos códigos e dados. Para fazer os processos descritos abaixo.
>[!TIP]
>Recomendamos utilizar um computador com um linux instalado, de preferência o Ubuntu. Não recomendamos o uso de máquinas virtuais, pois além do processo de virtualização deixar partes da instalação mais lentas, também pode afetar alguns procedimentos.

# Especificações de hardware
Durante as nossas instalações, foram usados dois dispositivos diferentes, sendo um notebook rodando linux Ubuntu e o Raspberry Pi, com as especificações citadas abaixo:
### Notebook:
Processador Intel(R) Core(TM) i3-7020U<br>
Linux Ubuntu versão 22.04.4 LTS

### Raspberry Pi:
Raspberry Pi 3 B+<br>
Processador com arquitetura ARMv8<br>
Cartão SD Sandisk 16 GB

# Preparando a máquina
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
# Instalação e emulação pelo QEMU
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

# Instalação para o Raspberry Pi
O procedimento é similar ao da instalação para emulação, porém possui algumas diferenças nos passos e alguns procedimentos extras.

Para começar, crie um outro repositório:
```ruby
mkdir optee_rasp
cd optee_rasp
```

