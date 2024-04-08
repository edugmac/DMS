```ruby
```
# DMS
Security of distributed measurement systems

# Preparando a máquina
A instalação pode ser feita tanto para simulação no Qemu, quanto para instalação direta em um raspberry pi
(Obs: alguns modelos de raspberry podem não ser compatíveis com o sistema operacional do OP-TEE. Para mais informações, consultar: https://optee.readthedocs.io/en/latest/building/devices/rpi3.html#what-versions-of-raspberry-pi-will-work)

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
mkdir optee     #Não há necessidade do nome ser exatamente esse, podendo ser customizado pelo usuário
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
