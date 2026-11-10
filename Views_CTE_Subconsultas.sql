USE Conecta_Comercio;
GO

-- =================VIEWS========================

/*
Objeto: View [dbo].[vw_ConsultarPedidosDoDia]
Script Date: 10/11/2026

Objetivo:
Disponibilizar uma consulta dos pedidos realizados na data atual,
apresentando o identificador do pedido, o nome do cliente,
a data do pedido e sua respectiva situação.

Funcionamento:
- Relaciona as tabelas Pedidos e Clientes por meio de INNER JOIN.
- Filtra os registros considerando a data atual do servidor SQL Server.
- Utiliza GETDATE() convertido para DATE para comparar somente a data,
  desconsiderando informações de horário.
- Atualiza os resultados dinamicamente conforme a data da consulta.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da VIEW para facilitar a consulta dos pedidos realizados
diariamente.

Data Alteração: 10/11/2026
*/
CREATE OR ALTER VIEW dbo.vw_ConsultarPedidosDoDia
AS
SELECT
    p.id AS id_pedido,
    c.nome AS cliente,
    p.data_pedido,
    p.situacao
FROM dbo.Pedidos p
INNER JOIN dbo.Clientes c
    ON p.id_cliente = c.id
WHERE p.data_pedido = CAST(GETDATE() AS DATE);
GO

/*
Objeto: View [dbo].[vw_ResumoPedidos]
Script Date: 10/11/2026

Objetivo:
Apresentar um resumo dos pedidos cadastrados, incluindo informações
dos clientes, quantidade de itens e valor total de cada pedido.

Funcionamento:
- Relaciona Pedidos com Clientes e ItensPedidos.
- Calcula a quantidade de itens de cada pedido.
- Calcula o valor total dos pedidos.
- Utiliza LEFT JOIN para incluir pedidos que ainda não possuem itens.
- Apresenta a situação e a data de cada pedido.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da VIEW para facilitar a consulta e análise dos pedidos.

Data Alteração: 10/11/2026
*/
CREATE OR ALTER VIEW dbo.vw_ResumoPedidos
AS
SELECT
    p.id AS id_pedido,
    c.nome AS cliente,
    p.data_pedido,
    p.situacao,
    COUNT(ip.id_produto) AS quantidade_itens,
    COALESCE(SUM(ip.quantidade), 0) AS total_unidades,
    COALESCE(
        SUM(ip.quantidade * ip.preco_unitario),
        0
    ) AS valor_total
FROM dbo.Pedidos p
INNER JOIN dbo.Clientes c
    ON p.id_cliente = c.id
LEFT JOIN dbo.ItensPedidos ip
    ON p.id = ip.id_pedido
GROUP BY
    p.id,
    c.nome,
    p.data_pedido,
    p.situacao;
GO

/*
Objeto: View [dbo].[vw_ProdutosEstoqueBaixo]
Script Date: 10/11/2026

Objetivo:
Disponibilizar uma consulta dos produtos que possuem estoque
igual ou inferior a 10 unidades, facilitando o acompanhamento
dos produtos que necessitam de reposição.

Funcionamento:
- Relaciona as tabelas Produtos e Fornecedores.
- Apresenta o nome do produto e seu respectivo fornecedor.
- Exibe o preço e a quantidade disponível em estoque.
- Filtra os produtos com estoque menor ou igual a 10 unidades.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da VIEW para monitoramento de produtos com estoque baixo.

Data Alteração: 10/11/2026
*/

CREATE OR ALTER VIEW dbo.vw_ProdutosEstoqueBaixo
AS
SELECT
    p.id AS id_produto,
    p.nome AS produto,
    f.razao_social AS fornecedor,
    p.preco,
    p.estoque
FROM dbo.Produtos p
INNER JOIN dbo.Fornecedores f
    ON p.id_fornecedor = f.id
WHERE p.estoque <= 10;
GO

-- =================EXECUÇÕES========================

-- inserindo novo pedido na data atual 
EXEC dbo.usp_InserirDadosPedidos
    @EMAIL_CLIENTE = 'ana.martins@email.com',
    @SITUACAO = N'Pendente';
GO

-- consutando pedidos do dia
SELECT *
FROM dbo.vw_ConsultarPedidosDoDia;



-- consultando resumo pedidos
SELECT *
FROM dbo.vw_ResumoPedidos
ORDER BY id_pedido;

-- consultando resumo pedidos com situação aprovado
SELECT *
FROM dbo.vw_ResumoPedidos
WHERE situacao = N'Aprovado';

-- consultando produtos com estoque baixo
SELECT *
FROM dbo.vw_ProdutosEstoqueBaixo;



-- =================CTEs========================

-- CTE responsável por consolidar as vendas por cliente,
-- apresentando a quantidade de pedidos, produtos comprados e valor total.
WITH VendasPorCliente AS
(
    SELECT
        c.id AS id_cliente,
        c.nome AS cliente,
        COUNT(DISTINCT p.id) AS quantidade_pedidos,
        SUM(ip.quantidade) AS total_produtos,
        SUM(ip.quantidade * ip.preco_unitario) AS valor_total
    FROM dbo.Clientes c
    INNER JOIN dbo.Pedidos p
        ON c.id = p.id_cliente
    INNER JOIN dbo.ItensPedidos ip
        ON p.id = ip.id_pedido
    GROUP BY
        c.id,
        c.nome
)
SELECT *
FROM VendasPorCliente
ORDER BY valor_total DESC;
GO

-- CTE responsável por analisar e classificar os produtos
-- conforme a quantidade disponível em estoque.
WITH AnaliseEstoque AS
(
    SELECT
        p.id AS id_produto,
        p.nome AS produto,
        f.razao_social AS fornecedor,
        p.preco,
        p.estoque,
        CASE
            WHEN p.estoque = 0 THEN N'Sem estoque'
            WHEN p.estoque <= 10 THEN N'Estoque baixo'
            ELSE N'Estoque adequado'
        END AS situacao_estoque
    FROM dbo.Produtos p
    INNER JOIN dbo.Fornecedores f
        ON p.id_fornecedor = f.id
)
SELECT *
FROM AnaliseEstoque
ORDER BY estoque ASC;
GO



-- =================SUBCONSULTAS========================

-- Subconsulta Escalar
-- Consulta externa: reúne todos os produtos aonde o preco é maior que subconsulta
-- Subconsulta: retorna a médida de preco dos produtos
SELECT
    id,
    nome,
    preco
FROM dbo.Produtos
WHERE preco > (
    SELECT AVG(preco)
    FROM dbo.Produtos
);

-- Subconsulta com IN
-- A subconsulta busca os IDs dos clientes que possuem pedidos.
-- O IN verifica quais clientes possuem seus IDs nessa lista.
-- A consulta externa retorna os dados desses clientes.
SELECT *
FROM dbo.Clientes
WHERE id IN (
    SELECT id_cliente
    FROM dbo.Pedidos
);

-- Subconsulta com EXISTS
-- Consulta externa: busca as informações dos fornecedores cadastrados.
-- Subconsulta: verifica se existe algum produto relacionado ao fornecedor que está sendo analisado.
SELECT
    f.id,
    f.razao_social,
    f.email,
    f.telefone
FROM dbo.Fornecedores f
WHERE EXISTS (
    SELECT 1
    FROM dbo.Produtos p
    WHERE p.id_fornecedor = f.id
);

-- consulta correlacionada(subconsulta dependente da consulta externa)
SELECT
    c.nome,
    (
        SELECT COUNT(*)
        FROM dbo.Pedidos p
        WHERE p.id_cliente = c.id
    ) AS quantidade_pedidos
FROM dbo.Clientes c;