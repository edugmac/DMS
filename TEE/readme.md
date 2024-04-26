# OP-TEE para Raspberry Pi e Qemu
OP-TEE é um ambiente de execução confiável (TEE, do inglês, Trusted Execution Environment) focado em garantir segurança para dispositivos. O OP-TEE divide o processador em dois kernels (mundo real e mundo seguro). Apenas o mundo comum é liberado para acesso do usuário, permitindo apenas execução dos scripts e impedindo qualquer visualização e/ou alteração dos códigos e dados. Para fazer os processos descritos abaixo.
>[!TIP]
>Recomendamos utilizar um computador com um linux instalado, de preferência o Ubuntu. Não recomendamos o uso de máquinas virtuais, pois além do processo de virtualização deixar partes da instalação mais lentas, também pode afetar alguns procedimentos.

## Preparando a máquina
A instalação pode ser feita tanto para simulação no Qemu, quanto para instalação direta em um raspberry pi
>[!NOTE]
>Alguns modelos de raspberry podem não ser compatíveis com o sistema operacional do OP-TEE. Para mais informações, consultar o [site oficial](https://optee.readthedocs.io/en/latest/building/devices/rpi3.html#what-versions-of-raspberry-pi-will-work).

Antes de iniciar a instalação, é necessário atualizar os pacotes nativos do Ubuntu:
```console
sudo apt update
sudo apt upgrade
```
Depois, instale os pré-requisitos:
```console
sudo apt install-y adb acpica-tools autoconf automake bc bison build-essential ccache cpio cscope curl device-tree-compiler e2tools\
expect fastboot flex ftp-upload disk git libattr1-dev libcap-ng-dev libfdt-dev libftdi-dev libglib2.0-dev libgmp3-dev libhidapi-dev\
libmpc-dev libncurses5-dev libpixman-1-dev libslirp-dev libssl-dev libtool libusb-1.0-0-dev make mtools netcat ninja-build\
python3-cryptography python3-pip python3-pyelftools python3-serial python-is-python3 rsync swig unzip uuid-dev wget xdg-utils xterm\
xz-utils zlib1g-dev curl
```
A seguir, deve-se instalar o Google Repo. O Repo será usado no lugar do Git por conta do melhor manuseio e atualização de diretórios, permitindo uma maior facilidade para trabalhar com os arquivos.
```console
sudo apt install repo
```
## instalando o OP-TEE
O primeiro passo é criar uma pasta para armazenar os arquivos do OP-TEE. A pasta pode ser criada no diretório de preferência do usuário, mas deve-se ter em mente o nome e a localização dela para passos futuros.
Recomendamos a criação da pasta no diretório raiz do linux, identificada com o tipo da instalação (QEMU ou Raspberry Pi):
```console
mkdir optee     #O nome da pasta pode ser customizado pelo usuário
cd optee 
```
Atenção: Esse diretório só deve ser usado para uma das versões do OP-TEE. Caso queira usar ambas as duas, crie outra pasta separada da primeira.
### Instalação e emulação pelo QEMU
1- A simulação do OP-TEE é muito útil, pois pode ser usada tanto para testes de instalação, quanto para testes de scripts e trusted applications. Para fazer essa simulação, deve-se primeiramente iniciar o repositório do OP-TEE baseado para o QEMU:
```console
repo init -u https://github.com/OP-TEE/manifest.git -m default.xml -b 3.19.0
```
2- Ao executar este passo em uma máquina nova ou com o linux recém instalado, será necessário configurar o nome e e-mail de usuário do Github. Para isso, utilize o seguinte:
```console
git config --global user.name "Seu nome"
git config --global user.mail "SeuEmail@mail.com"
```
3- Após a inicialização do repositório na pasta, basta sincronizar:
```console
repo sync --no-clone-bundle
```
4- Terminada a sincronização, deve-se baixar as "Toolchains" com o seguinte comando:
>[!NOTE]
>É muito importante que haja uma conexão estável com a internet, pois esse procedimento pode levar algum tempo. Recomendamos que refaça este passo em caso de qualquer erro que venha a acontecer em passos futuros.
```console
cd build
make toolchains
```
Terminando esse procedimento, a simulação já pode ser iniciada com o comando `make run`. Três terminais serão abertos: Um para o mundo comum, um para o mundo seguro e um para controle da emulação. No terminal da emulação, digite `c` e a simulação irá iniciar. Para confirmar o funcionamento, pode-se fazer login como "root" e usar o comando `xtest`, que verifica se toda a instalação ocorreu como previsto.

### Instalação para o Raspberry Pi
O procedimento é similar ao da instalação para emulação, porém possui algumas diferenças nos passos e alguns procedimentos extras.

Para começar, crie um outro repositório:
```console
mkdir optee_rasp
cd optee_rasp
```
Agora, inicie o Repo relacionado ao Raspberry Pi:
```console
repo init -u https://github.com/OP-TEE/manifest.git -m rpi3.xml -b 3.19.0
```
Após a sincronização, repita os passos 2 ao 4 mencionados anteriormente. Quando terminado, use o comando abaxo:
```console
make -j `nproc`
```
### Instalação na memória do Raspberry
A seguir, iremos particionar o cartão SD para colocar nele os arquivos do OP-TEE. Para mais informações, use o comando `make img-help`. Você deverá ver as instruções como abaixo:
```console
$ fdisk /dev/sdx   # where sdx is the name of your sd-card
   > p             # prints partition table
   > d             # repeat until all partitions are deleted
   > n             # create a new partition
   > p             # create primary
   > 1             # make it the first partition
   > <enter>       # use the default sector
   > +64M          # create a boot partition with 64MB of space
   > n             # create rootfs partition
   > p
   > 2
   > <enter>
   > <enter>       # fill the remaining disk, adjust size to fit your needs
   > t             # change partition type
   > 1             # select first partition
   > e             # use type 'e' (FAT16)
   > a             # make partition bootable
   > 1             # select first partition
   > p             # double check everything looks right
   > w             # write partition table to disk.

run the following as root
   $ mkfs.vfat -F16 -n BOOT /dev/sdx1
   $ mkdir -p /media/boot
   $ mount /dev/sdx1 /media/boot
   $ cd /media
   $ gunzip -cd /location/of/optee_rpi3/build/../out-br/images/rootfs.cpio.gz | sudo cpio -idmv "boot/*"
   $ umount boot

run the following as root
   $ mkfs.ext4 -L rootfs /dev/sdx2
   $ mkdir -p /media/rootfs
   $ mount /dev/sdx2 /media/rootfs
   $ cd rootfs
   $ gunzip -cd /location/of/optee_rpi3/build/../out-br/images/rootfs.cpio.gz | sudo cpio -idmv
   $ rm -rf /media/rootfs/boot/*
   $ cd .. && umount rootfs
```
>[!TIP]
>Execute o comando no seu dispositivo, pois ele modifica automaticamente alguns comandos relacionados à localização da pasta de instalação do OP-TEE, facilitando o processo.

Plugue o cartão SD no seu dispositivo. Idealmente, formate ele antes de executar os próximos passos.</br>
Primeiramente, identifique o nome do cartão SD. Você pode fazer isso usando o comando `lsblk`. Isso exibirá os dispositivos de bloco plugados na máquina. Procure pelo dispositivo que corresponde à memória do seu cartão de memória. O nome deve ser algo como `sdx` ou `mmcblkx`, substituindo o `x` por algum número.

>[!CAUTION]
>Execute os passos abaixo com cautela, pois caso algo seja feito incorretamente, toda a instalação a partir daqui precisará ser re-feita.

Repita o processo de particionamento que está indicado no img-help. Em todos os comandos, troque o nome `sdx` pelo nome do cartão SD que foi identificado. Para executá-los, inicie o modo root no terminal, digitando `sudo su`.</br>
Após particionar o cartão SD, os próximos passos são simples, necessitando apenas repetir os comandos mencionados no img-help. Como mencionado anteriormente, ele modificará os comandos para serem compativeis com a instalação do OP-TEE no seu sistema, necessitando alterar apenas o nome do cartão SD nos comandos correspondentes.</br>
Por fim, remova o cartão do computador e plugue no Raspberry Pi. Será necessário conectar um monitor por um cabo HDMI, a fonte e um teclado para poder operar o dispositivo. Para fins de teste, excecute o comando `xtest` para verificar se toda a instalação foi feita corretamente.
