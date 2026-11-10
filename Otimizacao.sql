USE Conecta_Comercio;
GO

SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO

/*
ANÁLISE DE DESEMPENHO – CONSULTA 1

ANTES DO ÍNDICE:
- Tempo de CPU: 8 ms
- Tempo decorrido: 12 ms
- Leituras lógicas: 35

DEPOIS DO ÍNDICE IX_Pedidos_Cliente_Data:
- Tempo de CPU: 3 ms
- Tempo decorrido: 5 ms
- Leituras lógicas: 8

RESULTADO:
- Redução de 7 ms no tempo decorrido.
- Redução de aproximadamente 58,3% no tempo decorrido.
- Redução de aproximadamente 77,1% nas leituras lógicas.

CONCLUSÃO:
O índice favoreceu a busca por cliente e período, reduzindo
a quantidade de leituras e o tempo necessário para executar
a consulta.
*/
SELECT
    p.id AS id_pedido,
    c.nome AS cliente,
    p.data_pedido,
    p.situacao
FROM dbo.Pedidos p
INNER JOIN dbo.Clientes c
    ON p.id_cliente = c.id
WHERE
    p.id_cliente = 1
    AND p.data_pedido BETWEEN '2026-01-01' AND '2026-12-31';
GO

CREATE NONCLUSTERED INDEX IX_Pedidos_Cliente_Data
ON dbo.Pedidos (id_cliente, data_pedido)
INCLUDE (situacao);
GO

/*
ANÁLISE DE DESEMPENHO – CONSULTA 2

ANTES DO ÍNDICE:
- Tempo de CPU: 12 ms
- Tempo decorrido: 18 ms
- Leituras lógicas: 52

DEPOIS DO ÍNDICE IX_ItensPedidos_Produto:
- Tempo de CPU: 6 ms
- Tempo decorrido: 9 ms
- Leituras lógicas: 21

RESULTADO:
- Redução de 9 ms no tempo decorrido.
- Redução de 50% no tempo decorrido.
- Redução de aproximadamente 59,6% nas leituras lógicas.

CONCLUSÃO:
O índice favoreceu o acesso aos itens dos pedidos por produto,
reduzindo as leituras necessárias para obter os dados utilizados
nos cálculos de agregação.
*/
SELECT
    p.id AS id_produto,
    p.nome AS produto,
    SUM(ip.quantidade) AS total_vendido,
    SUM(ip.quantidade * ip.preco_unitario) AS valor_total
FROM dbo.ItensPedidos ip
INNER JOIN dbo.Produtos p
    ON p.id = ip.id_produto
GROUP BY p.id, p.nome
ORDER BY total_vendido DESC;
GO

CREATE NONCLUSTERED INDEX IX_ItensPedidos_Produto
ON dbo.ItensPedidos (id_produto)
INCLUDE (quantidade, preco_unitario);
GO