USE Conecta_Comercio;
GO

-- =================TABELAS TEMPORÁRIAS (#/##)========================

/*
Objetivo:
Demonstrar a criação e utilização de tabelas temporárias
locais (#) e globais (##), verificando a visibilidade
entre diferentes sessões do SQL Server.

A tabela local é acessível somente pela sessão que a criou,
enquanto a tabela global pode ser acessada por outras sessões.

Ao final, ambas são descartadas para evitar que a tabela
temporária global permaneça disponível.

Desenvolvedor: Guilherme Paiva Alves
*/

-- tabela temporária (LOCAL)
CREATE TABLE #ProdutosTemporarios (
    id INT,
    nome NVARCHAR(100),
    preco DECIMAL(10,2)
);

INSERT INTO #ProdutosTemporarios (id, nome, preco)
VALUES
    (1, N'Notebook', 3500.00),
    (2, N'Mouse', 80.00),
    (3, N'Teclado', 150.00);



SELECT * FROM #ProdutosTemporarios;

-- para testar sua incompatibilidade com outra sessão
-- execute "SELECT * FROM #ProdutosTemporarios;" em outra sessão, ou seja, em uma outra janela
-- irá apresentar um erro informando que o objeto não existe

-- tabela temporária (GLOBAL)
CREATE TABLE ##ProdutosTemporarios (
    id INT,
    nome NVARCHAR(100),
    preco DECIMAL(10,2)
);

INSERT INTO ##ProdutosTemporarios (id, nome, preco)
VALUES
    (1, N'Notebook', 3500.00),
    (2, N'Mouse', 80.00),
    (3, N'Teclado', 150.00);

SELECT * FROM ##ProdutosTemporarios;

-- para testar sua compatibilidade com as demais sessões 
-- execute "SELECT * FROM ##ProdutosTemporarios;" em outra sessão, ou seja em outra janela
-- A consulta funcionará demonstrando que podem ser acessadas por outras sessões enquanto estiverem disponíveis

-- Descartando tabelas temporárias 
DROP TABLE IF EXISTS #ProdutosTemporarios;

DROP TABLE IF EXISTS ##ProdutosTemporarios;