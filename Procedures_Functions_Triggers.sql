USE Conecta_Comercio;
GO

-- =================PROCEDURES========================

/*
Observação:
A procedure dbo.usp_InserirDadosPedidos já foi desenvolvida
anteriormente, contemplando a inclusão de pedidos com
parâmetros e validações necessárias.

Por esse motivo, não será recriada nesta etapa.
*/



/*
Objeto: StoredProcedure [dbo].[usp_ConsultarPedidosFiltrados]
Script Date: 10/11/2026

Objetivo:
Consultar os pedidos cadastrados no banco de dados,
permitindo a aplicação de filtros opcionais por cliente,
situação e intervalo de datas.

A procedure também apresenta informações consolidadas
dos pedidos, incluindo quantidade de itens, total de unidades
e valor total.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da procedure para consulta de pedidos com filtros
dinâmicos e validação dos parâmetros informados.

Data Alteração: 10/11/2026
*/
CREATE OR ALTER PROCEDURE dbo.usp_ConsultarPedidosFiltrados
(
    @ID_CLIENTE INT = NULL,
    @SITUACAO NVARCHAR(100) = NULL,
    @DATA_INICIAL DATE = NULL,
    @DATA_FINAL DATE = NULL
)
AS
BEGIN
    SET NOCOUNT ON;

    -- Valida a situação informada.
    IF @SITUACAO IS NOT NULL
       AND @SITUACAO NOT IN (
           N'Pendente',
           N'Aprovado',
           N'Enviado',
           N'Cancelado'
       )
    BEGIN
        THROW 50005, 'Situação do pedido inválida.', 1;
    END;

    -- Valida o intervalo de datas.
    IF @DATA_INICIAL IS NOT NULL
       AND @DATA_FINAL IS NOT NULL
       AND @DATA_INICIAL > @DATA_FINAL
    BEGIN
        THROW 50006, 'A data inicial não pode ser maior que a data final.', 1;
    END;

    SELECT
        p.id AS id_pedido,
        c.nome AS cliente,
        p.data_pedido,
        p.situacao,
        COUNT(ip.id_produto) AS quantidade_itens,
        COALESCE(SUM(ip.quantidade), 0) AS total_unidades,
        COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0) AS valor_total
    FROM dbo.Pedidos p
    INNER JOIN dbo.Clientes c
        ON p.id_cliente = c.id
    LEFT JOIN dbo.ItensPedidos ip
        ON p.id = ip.id_pedido
    WHERE
        (@ID_CLIENTE IS NULL OR p.id_cliente = @ID_CLIENTE)
        AND (@SITUACAO IS NULL OR p.situacao = @SITUACAO)
        AND (@DATA_INICIAL IS NULL OR p.data_pedido >= @DATA_INICIAL)
        AND (@DATA_FINAL IS NULL OR p.data_pedido <= @DATA_FINAL)
    GROUP BY
        p.id,
        c.nome,
        p.data_pedido,
        p.situacao
    ORDER BY
        p.data_pedido DESC,
        p.id DESC;
END;
GO

-- consulta sem filtros
EXEC dbo.usp_ConsultarPedidosFiltrados;

-- filtrar por cliente 
EXEC dbo.usp_ConsultarPedidosFiltrados
    @ID_CLIENTE = 1;

-- filtrar pela situação
EXEC dbo.usp_ConsultarPedidosFiltrados
    @SITUACAO = N'Aprovado';

-- filtrar por intervalos de datas 
EXEC dbo.usp_ConsultarPedidosFiltrados
    @DATA_INICIAL = '2026-11-01',
    @DATA_FINAL = '2026-11-10';


-- combinar vários filtros 
EXEC dbo.usp_ConsultarPedidosFiltrados
    @ID_CLIENTE = 1,
    @SITUACAO = N'Aprovado',
    @DATA_INICIAL = '2026-11-01',
    @DATA_FINAL = '2026-11-10';


-- =================FUNCTIONS========================

-- Function escalar
/*
Objeto: Function [dbo].[fn_CalcularSubtotal]
Script Date: 10/11/2026

Objetivo:
Calcular o subtotal de um produto com base no preço
unitário e na quantidade informada, retornando o resultado
da multiplicação entre esses valores.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da função escalar para calcular o subtotal,
com validação dos parâmetros de entrada.

Data Alteração: 10/11/2026
*/
CREATE OR ALTER FUNCTION dbo.fn_CalcularSubtotal 
(
    @PRECO DECIMAL(10,2),
    @QUANTIDADE INT
)
RETURNS DECIMAL(18,2)
AS 
BEGIN
    IF @PRECO IS NULL OR @PRECO < 0
       OR @QUANTIDADE IS NULL OR @QUANTIDADE <= 0
        RETURN NULL;

    RETURN @PRECO * @QUANTIDADE;
END;
GO


-- Function tabular
/*
Objeto: Function [dbo].[fn_RelatorioPedidosPorCliente]
Script Date: 10/11/2026

Objetivo:
Gerar um relatório de pedidos com filtros opcionais
por cliente, situação e intervalo de datas.

Apresenta informações consolidadas dos pedidos,
incluindo quantidade de itens, total de unidades
e valor total de cada pedido.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação de função tabular (Inline Table-Valued Function)
para consulta parametrizada de pedidos.

Data Alteração: 10/11/2026
*/
CREATE OR ALTER FUNCTION dbo.fn_RelatorioPedidosPorCliente
(
    @ID_CLIENTE INT = NULL,
    @SITUACAO NVARCHAR(100) = NULL,
    @DATA_INICIAL DATE = NULL,
    @DATA_FINAL DATE = NULL
)
RETURNS TABLE
AS
RETURN
(
    SELECT
        p.id AS id_pedido,
        c.nome AS cliente,
        p.data_pedido,
        p.situacao,
        COUNT(ip.id_produto) AS quantidade_itens,
        COALESCE(SUM(ip.quantidade), 0) AS total_unidades,
        COALESCE(SUM(ip.quantidade * ip.preco_unitario), 0) AS valor_total
    FROM dbo.Pedidos p
    INNER JOIN dbo.Clientes c
        ON p.id_cliente = c.id
    LEFT JOIN dbo.ItensPedidos ip
        ON p.id = ip.id_pedido
    WHERE
        (@ID_CLIENTE IS NULL OR p.id_cliente = @ID_CLIENTE)
        AND (@SITUACAO IS NULL OR p.situacao = @SITUACAO)
        AND (@DATA_INICIAL IS NULL OR p.data_pedido >= @DATA_INICIAL)
        AND (@DATA_FINAL IS NULL OR p.data_pedido <= @DATA_FINAL)
    GROUP BY
        p.id,
        c.nome,
        p.data_pedido,
        p.situacao
);
GO

-- =================EXECUÇÕES========================

-- Calcula o valor total em estoque de cada produto, multiplicando o preço pela quantidade disponível.
SELECT
    nome AS produto,
    preco,
    estoque,
    dbo.fn_CalcularSubtotal(preco, estoque) AS valor_em_estoque
FROM dbo.Produtos;

-- Essa consulta apresenta o subtotal de cada produto presente nos pedidos.
SELECT
    ip.id_pedido,
    p.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    dbo.fn_CalcularSubtotal(
        ip.preco_unitario,
        ip.quantidade
    ) AS subtotal
FROM dbo.ItensPedidos ip
INNER JOIN dbo.Produtos p
    ON ip.id_produto = p.id;

-- relatório com todos os pedidos 
SELECT *
FROM dbo.fn_RelatorioPedidosPorCliente
(
    DEFAULT,
    DEFAULT,
    DEFAULT,
    DEFAULT
);

-- relatório de pedidos de um cliente específico
SELECT *
FROM dbo.fn_RelatorioPedidosPorCliente
(
    1,
    NULL,
    NULL,
    NULL
);

-- relatório de pedidos aprovados
SELECT *
FROM dbo.fn_RelatorioPedidosPorCliente
(
    NULL,
    N'Aprovado',
    NULL,
    NULL
);

-- relatório de pedidos em um intervalo de datas
SELECT *
FROM dbo.fn_RelatorioPedidosPorCliente
(
    NULL,
    NULL,
    '2026-11-01',
    '2026-11-10'
);



-- =================TRIGGERS========================


/*
Objeto: Trigger [dbo].[trg_AuditarProdutos]
Script Date: 10/11/2026

Objetivo:
Auditar automaticamente as alterações realizadas na tabela
Produtos, registrando na tabela Auditorias os valores
anteriores e novos dos produtos modificados.

A Trigger utiliza as tabelas lógicas inserted e deleted
para comparar os dados, permitindo o tratamento de
atualizações de múltiplas linhas em uma única operação.

Não realiza atualizações na própria tabela Produtos,
evitando lógica de atualização circular.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da Trigger de auditoria para operações UPDATE
na tabela Produtos, com suporte a múltiplos registros.

Data Alteração: 10/11/2026
*/
CREATE OR ALTER TRIGGER dbo.trg_AuditarProdutos
ON dbo.Produtos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_MAX INT;

    SELECT @ID_MAX = ISNULL(MAX(id), 0)
    FROM dbo.Auditorias;

    INSERT INTO dbo.Auditorias
    (
        id,
        tabela,
        operacao,
        descricao
    )
    SELECT
        @ID_MAX + ROW_NUMBER() OVER (ORDER BY i.id),
        N'Produtos',
        N'UPDATE',
        CONCAT(
            N'Produto ID: ', i.id,
            N' | Nome anterior: ', d.nome,
            N' | Novo nome: ', i.nome,
            N' | Preço anterior: ', d.preco,
            N' | Novo preço: ', i.preco,
            N' | Estoque anterior: ', d.estoque,
            N' | Novo estoque: ', i.estoque
        )
    FROM inserted i
    INNER JOIN deleted d
        ON i.id = d.id
    WHERE
        i.nome <> d.nome
        OR i.preco <> d.preco
        OR i.estoque <> d.estoque
        OR i.id_fornecedor <> d.id_fornecedor;
END;
GO


-- =================EXECUÇÕES========================

SELECT * FROM dbo.Produtos;

UPDATE dbo.Produtos
SET preco = preco + 10.00
WHERE id = 1;

SELECT *
FROM dbo.Auditorias
WHERE tabela = N'Produtos'
ORDER BY id DESC;