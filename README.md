# Conecta_Comercio — Projeto SQL Server

Projeto desenvolvido com **SQL Server e Transact-SQL (T-SQL)** para demonstrar a modelagem e a manipulação de um banco de dados comercial, além de recursos de programação, controle transacional, administração, segurança e otimização de consultas.

O repositório reúne scripts SQL organizados em uma sequência de execução, um relatório com as respostas teóricas e evidências das atividades. O objetivo é servir como material de estudo e portfólio, apresentando conceitos de banco de dados relacional aplicados a um cenário de comércio.

## Objetivos do projeto

- Criar e popular um banco de dados relacional para representar clientes, fornecedores, produtos, pedidos e movimentações de estoque.
- Consultar e organizar informações usando views, CTEs, subconsultas e tabelas temporárias.
- Implementar regras de negócio com stored procedures, functions e triggers.
- Aplicar transações para preservar a consistência das operações de venda.
- Demonstrar recursos de administração, permissões, backup e restauração.
- Analisar consultas e índices considerando desempenho de leitura e custo de escrita.

## Tecnologias e ferramentas

- **SGBD:** Microsoft SQL Server.
- **Linguagem:** Transact-SQL (T-SQL).
- **Ferramenta de execução recomendada:** SQL Server Management Studio (SSMS). Também é possível utilizar outra ferramenta compatível com SQL Server.

### Versão do SQL Server

**Compatibilidade recomendada:** SQL Server 2019 ou superior.

A versão exata utilizada na execução deve ser registrada conforme a instância local. Para consultá-la, execute:

```sql
SELECT @@VERSION AS versao_sql_server;
```

> Antes de publicar o repositório, substitua esta observação pela versão/edição efetivamente utilizada, caso queira documentar o ambiente de desenvolvimento com precisão. Não declare uma versão como testada sem ter executado os scripts nela.

## Estrutura do repositório

```text
Conecta_Comercio/
│
├── 01_Criacao.sql
├── 02_Dados.sql
├── 03_Views_CTE_Subconsultas.sql
├── 04_Temporarias.sql
├── 05_Procedures_Functions_Triggers.sql
├── 06_Transacoes.sql
├── 07_Administracao.sql
├── 08_Otimizacao.sql
├── Relatorio.pdf
└── README.md
```

## Ordem de execução

Execute os arquivos **na ordem abaixo**, pois os scripts posteriores dependem do banco, das tabelas, dos dados e dos objetos criados anteriormente.

| Ordem | Arquivo | Finalidade |
|---:|---|---|
| 1 | `01_Criacao.sql` | Cria o banco `Conecta_Comercio`, as tabelas, chaves primárias e estrangeiras, restrições e relacionamentos. |
| 2 | `02_Dados.sql` | Insere os dados de exemplo utilizados nos exercícios e nas consultas. |
| 3 | `03_Views_CTE_Subconsultas.sql` | Demonstra views, expressões de tabela comuns (CTEs) e subconsultas. |
| 4 | `04_Temporarias.sql` | Demonstra a criação e utilização de tabelas temporárias locais (`#`) e globais (`##`). |
| 5 | `05_Procedures_Functions_Triggers.sql` | Implementa procedimentos armazenados, funções e gatilhos para regras de negócio e operações do banco. |
| 6 | `06_Transacoes.sql` | Demonstra transações, confirmação (`COMMIT`), cancelamento (`ROLLBACK`) e tratamento de erros em operações de venda. |
| 7 | `07_Administracao.sql` | Demonstra logins, usuários, roles, permissões, backup e procedimentos de verificação/restauração. |
| 8 | `08_Otimizacao.sql` | Analisa consultas com plano de execução e estatísticas de IO/tempo, cria índices e discute seus impactos. |

### Como executar

1. Inicie o SQL Server e conecte-se à instância pelo SSMS.
2. Abra `01_Criacao.sql` e execute o script completo.
3. Abra e execute os arquivos seguintes, respeitando a ordem da tabela.
4. Confira as mensagens e os resultados de cada execução antes de avançar para o próximo arquivo.
5. Para atividades que dependem de permissões administrativas, utilize uma conta autorizada ou adapte o script ao nível de permissão disponível.

**Atenção:** execute os arquivos no contexto da instância correta. O primeiro script cria o banco; os demais devem operar sobre `Conecta_Comercio`. Alguns comandos usam `GO`, que separa lotes no SSMS. `GO` não cria uma nova conexão.

Os scripts de criação de objetos podem utilizar `CREATE OR ALTER`, mas isso não significa que todos os arquivos de dados possam ser executados repetidamente sem efeitos. Em especial, a execução duplicada de `02_Dados.sql` pode gerar conflitos de chave primária ou restrições `UNIQUE`. Antes de repetir a carga, verifique o conteúdo atual das tabelas.

## Modelo de dados

O cenário representa operações básicas de um comércio. As principais entidades são:

| Tabela | Responsabilidade |
|---|---|
| `Clientes` | Armazena os dados dos clientes. |
| `Fornecedores` | Armazena os dados dos fornecedores. |
| `Produtos` | Mantém os produtos, seus fornecedores, preços e quantidades em estoque. |
| `Pedidos` | Registra os pedidos realizados pelos clientes e suas situações. |
| `ItensPedidos` | Registra os produtos, quantidades e preços unitários associados a cada pedido. |
| `MovimentosEstoque` | Registra movimentações de entrada, saída e ajuste de estoque. |
| `Auditorias` | Armazena eventos de auditoria realizados no banco. |

As tabelas são relacionadas por chaves primárias e estrangeiras. Também são utilizadas restrições, como `NOT NULL`, `UNIQUE` e `CHECK`, para reforçar a integridade dos dados.

## Conceitos demonstrados

### Modelagem e integridade relacional

- Banco de dados relacional, tabelas e relacionamentos.
- Chaves primárias (`PRIMARY KEY`) e estrangeiras (`FOREIGN KEY`).
- Restrições `NOT NULL`, `UNIQUE`, `DEFAULT` e `CHECK`.
- Integridade referencial e regras de domínio.

### Consultas e organização de dados

- `SELECT`, filtros com `WHERE`, ordenação com `ORDER BY` e agrupamentos com `GROUP BY`.
- Junções `INNER JOIN` e `LEFT JOIN`.
- Funções de agregação, como `COUNT`, `SUM`, `AVG`, `MIN` e `MAX`.
- Views para encapsular consultas reutilizáveis.
- CTEs (`WITH`) para estruturar consultas em etapas.
- Subconsultas escalares e correlacionadas, além de `IN`, `EXISTS` e `NOT EXISTS`.
- Tabelas temporárias locais (`#`) e globais (`##`).

### Programação no banco de dados

- Stored procedures para encapsular operações e regras de negócio.
- Functions escalares e funções que retornam tabelas.
- Parâmetros de entrada e parâmetros opcionais.
- Variáveis, estruturas condicionais, validações e tratamento de erros com `THROW`.
- Triggers DML e uso das tabelas lógicas `inserted` e `deleted`.
- Tratamento de operações que afetam múltiplas linhas.

### Transações e consistência

- `BEGIN TRANSACTION`, `COMMIT` e `ROLLBACK`.
- Blocos `TRY...CATCH` e tratamento de falhas.
- Utilização de transações para manter a atomicidade de uma venda, incluindo o pedido, seus itens e a atualização do estoque.
- Teste de cenário de estoque insuficiente.

### Administração e segurança

- Separação entre login de servidor, usuário de banco de dados e role.
- Gerenciamento de permissões com `GRANT`, `REVOKE` e `DENY`.
- Backup completo (`BACKUP DATABASE`).
- Verificação de backup com `RESTORE VERIFYONLY` e exercício de restauração.

### Desempenho e otimização

- Plano de execução estimado e real.
- Estatísticas de leitura e tempo com `SET STATISTICS IO` e `SET STATISTICS TIME`.
- Índices não clusterizados (`NONCLUSTERED INDEX`) e colunas incluídas (`INCLUDE`).
- Análise de operações como Index Seek, Index Scan e Table Scan.
- Discussão sobre seletividade, SARGability, custo de manutenção e impacto dos índices em `INSERT`, `UPDATE` e `DELETE`.

## Observações importantes

### Permissões administrativas

O arquivo `07_Administracao.sql` contém operações que podem exigir privilégios no nível do servidor ou do banco, como criar logins, usuários, roles e executar backup/restauração. Caso sua conta não tenha as permissões necessárias, execute essa etapa com uma conta autorizada ou solicite a permissão adequada ao administrador da instância.

### Senhas e informações sensíveis

Este repositório é público. **Não publique senhas reais, credenciais pessoais, endereços internos, tokens ou dados de clientes.** Caso algum script contenha uma senha demonstrativa para `CREATE LOGIN`, substitua-a por um valor de exemplo claramente identificado ou adapte o script para que cada pessoa informe sua própria senha localmente. Nunca reutilize credenciais pessoais ou de produção.

Também evite versionar arquivos `.bak` que contenham dados reais. Backups podem carregar informações sensíveis e devem ser tratados como dados do banco, não como simples arquivos de código.

### Caminhos de backup e restauração

Os caminhos utilizados em `BACKUP DATABASE` e `RESTORE DATABASE` são exemplos e podem precisar de adaptação. O caminho é acessado pelo serviço do SQL Server, e a conta que executa o serviço precisa ter permissão de leitura ou gravação no diretório correspondente.

`RESTORE VERIFYONLY` ajuda a verificar se o conjunto de backup está completo e legível, mas não substitui um teste de restauração. Sempre que possível, restaure o backup em um banco separado de laboratório para validar o procedimento sem sobrescrever o banco original.

### Resultados de desempenho

Os tempos, leituras e planos de execução podem variar conforme volume de dados, índices existentes, cache, hardware, versão do SQL Server e condições da instância. Registre no relatório os resultados efetivamente obtidos no ambiente de teste. Valores ilustrativos não devem ser apresentados como medições reais.

Um índice pode reduzir o custo de determinadas consultas de leitura, mas também consome armazenamento e aumenta o trabalho de manutenção em operações de escrita. A criação de índices deve ser justificada pelas consultas e pelo plano de execução observado.

## Relatório

O arquivo `Relatorio.pdf` reúne as respostas às questões teóricas, evidências, planos de execução e justificativas das atividades desenvolvidas. Consulte-o em conjunto com os scripts para compreender as decisões e os resultados do projeto.

## Referências

- [Microsoft Learn — Documentação do SQL Server](https://learn.microsoft.com/pt-br/sql/sql-server/)
- [Microsoft Learn — Planos de execução](https://learn.microsoft.com/en-us/sql/relational-databases/performance/display-and-save-execution-plans/)
- [Microsoft Learn — SET STATISTICS IO](https://learn.microsoft.com/pt-br/sql/t-sql/statements/set-statistics-io-transact-sql/)
- [Microsoft Learn — SET STATISTICS TIME](https://learn.microsoft.com/en-us/sql/t-sql/statements/set-statistics-time-transact-sql/)
- [Microsoft Learn — BACKUP (Transact-SQL)](https://learn.microsoft.com/pt-br/sql/t-sql/statements/backup-transact-sql)
- [Microsoft Learn — RESTORE e gerenciamento de backups](https://learn.microsoft.com/pt-br/sql/t-sql/statements/restore-statements-for-restoring-recovering-and-managing-backups-transact-sql/)

---

## Autor

**Guilherme Paiva Alves**  
Estudante de Desenvolvimento de Software Multiplataforma — FATEC Osasco  
Foco em desenvolvimento Back-end e banco de dados.

[GitHub](https://github.com/Guui360gpa) · [LinkedIn](https://www.linkedin.com/in/guilherme-paiva-alves/)
