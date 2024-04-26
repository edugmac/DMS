# Arquitetura segura para frenômetros baseada em blockchain
Esse repositório contém a implementação do projeto de uma arquitetura segura para aplição em sistemas distribuídos de medição (DMS, do inglês, Distributed Measuring Systems). A implementação é parte da tese de doutorado do MEng. Eduardo Gonçalves Machado e da cooperação entre o Instituto Nacional de Metrologia, Qualidade e Tecnologia (Inmetro) e a empresa Auge Tecnologia e Produções Ltda (Auge Tech).

Grupo de pesquisa:
* Eduardo Gonçalves Machado (egmachado@colaborador.inmetro.gov.br)
* Eduardo Valente Alves Martins (evmartins@colaborador.inmetro.gov.br)
* Gustavo de Jesus Martins (gustavojmartins02@gmail.com)
* Rafael Tiribas Rabiega Gomes (rtrabiega@colaborador.inmetro.gov.br)

Orientadores:
* Wilson de Souza Melo Junior (wsjunior@inmetro.gov.br)
* Igor Leandro Vieira (augetechrj@gmail.com)

### Sobre o projeto
Desenvolvemos um sistema seguro para medir a capacidade de frenagem de veículos usando blockchains. Esse sistema visa garantir a integridade dos resultados de um tipo de DMS denominado frenômetro. A arquitetura está dividida em três etapas de medição: sensoriamento, concretização da medição e armazenamento. Na primeira etapa os sinais da medição são assinados digitalmente em um kernel seguro no ambiente de execução confiável do processador (TEE, do inglês, Trust Enviroment Execution). A medição assinada é enviada para uma rede blockchain, onde smart contracts realizam os cálculos necessários para obter o resultado de medição. Esse resultado é então armazenado no ledger do blockchain, não podendo ser alterado. A seguir é apresentada a implementação da rede blockchain em HyperLedger Fabric e do smart contract desenvolvido para concretizar as medições do frenômetro. Na sequência, está descrita a implementação do ambiente seguro usando OP-TEE (tanto um protótipo com Raspberry Pi, como virtualização com Qemu).

### Publicações relacionadas
As publicações a seguir estão relacionadas a este projeto.

* [A. Martins, E. V., Machado, E. G., B. Gomes, R. T., & Melo Jr., W. S. (2023). Blockchain-based Architecture to Enhance Security in Distributed Measurement Systems. 2023 IEEE Asia-Pacific Conference on Computer Science and Data Engineering (CSDE), 1–4.](10.1109/CSDE59766.2023.10487656)
* [Machado, E. G., Gomes, R. T. R., Martins, E. V. A., Vieira, I. L., Madruga, E. L., & Melo, W. S. (2023). Blockchain network to conformity assessment bodies. Metrologia 2023: Congresso Brasileiro de Metrologia.](https://metrologia2023.org.br/?page_id=6627)

### Financiamento
Este trabalho foi parcilamente financiado por pela Fundação Carlos Chagas Filho de Amparo à Pesquisa do Rio de Janeiro (FAPERJ), bolsas E-26/290.124/2021, E-26/205.266/2022 e E-26/260.179/2023 e pelo Conselho Nacional de Desenvolvimento Científico e Tecnológico (CNPq), bolsa 151399/2023-9 e 303373/2023-7.

# Especificações de hardware
Durante as nossas instalações, foram usados dois dispositivos diferentes, sendo um notebook rodando linux Ubuntu e o Raspberry Pi, com as especificações citadas abaixo:
### Notebook:
Processador Intel(R) Core(TM) i3-7020U<br>
Linux Ubuntu versão 22.04.4 LTS

### Raspberry Pi:
Raspberry Pi 3 B+<br>
Processador com arquitetura ARMv8<br>
Cartão SD Sandisk 16 GB

# Blockchain e Smart Contracts

A implementação da rede blockchain e do contrato inteligente referente à arquitetura segura de medição para o frenômetro estão  documentadas no seguinte link: https://github.com/edugmac/DMS/blob/main/Blockchain/readme.md . Esta documentação serve como um guia para aplicação dos mecanismos propostos, visando a integridade e confiabilidade das medições realizadas.

# OP-TEE para Raspberry Pi e Qemu

A implementação envolvendo TEE está detalhada no seguinte link: https://github.com/edugmac/DMS/blob/main/TEE/readme.md . Esse recurso permite a integração de TEE na arquitetura, que pode ser realizada em ambientes de simulação utilizando o Qemu ou através de um protótipo utilizando Raspberry Pi. Essas opções oferecem flexibilidade para desenvolvedores e pesquisadores explorarem e testarem a aplicação de TEE na arquitetura de medição segura tanto em cenários simulados, quanto em ambientes físicos.
