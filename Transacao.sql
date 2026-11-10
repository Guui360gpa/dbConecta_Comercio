-- =================TRANSAÇÕES========================

/*
Objeto: Transação [Venda Atômica]
Script Date: 10/11/2026

Objetivo:
Realizar uma venda de forma atômica, garantindo que todas
as operações sejam concluídas com sucesso ou desfeitas
em caso de falha.

Utiliza BEGIN TRANSACTION, COMMIT, TRY/CATCH e ROLLBACK
para controlar a transação, incluindo a validação dos dados
do cliente e produto, a inclusão do pedido e de seus itens.

Aciona automaticamente a Trigger trg_AtualizarEstoque,
responsável pela atualização do estoque e pelo registro
da movimentação de saída.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação de script transacional para processamento de vendas,
com tratamento de erros e controle de consistência dos dados.

Data Alteração: 10/11/2026
*/


-- Dados da venda
DECLARE @ID_CLIENTE INT = 1;
DECLARE @ID_PRODUTO INT = 1;
DECLARE @QUANTIDADE INT = 2;

-- Variáveis de controle
DECLARE @ID_PEDIDO INT;
DECLARE @ID_MAX INT;
DECLARE @PRECO_UNITARIO DECIMAL(10,2);

SET XACT_ABORT ON;

BEGIN TRY

    -- Inicia a transação
    BEGIN TRANSACTION;

    -- Valida a existência do cliente
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Clientes
        WHERE id = @ID_CLIENTE
    )
        THROW 50010, 'Cliente não encontrado.', 1;

    -- Obtém o preço do produto
    SELECT @PRECO_UNITARIO = preco
    FROM dbo.Produtos
    WHERE id = @ID_PRODUTO;

    IF @PRECO_UNITARIO IS NULL
        THROW 50011, 'Produto não encontrado.', 1;

    -- Valida a quantidade
    IF @QUANTIDADE <= 0
        THROW 50012, 'Quantidade deve ser maior que zero.', 1;

    -- Gera o próximo ID do pedido
    SELECT @ID_MAX = ISNULL(MAX(id), 0)
    FROM dbo.Pedidos;

    SET @ID_PEDIDO = @ID_MAX + 1;

    -- Insere o pedido
    INSERT INTO dbo.Pedidos
    (
        id,
        id_cliente,
        situacao
    )
    VALUES
    (
        @ID_PEDIDO,
        @ID_CLIENTE,
        N'Pendente'
    );

    -- Insere o item do pedido
    -- A Trigger de estoque será executada automaticamente
    INSERT INTO dbo.ItensPedidos
    (
        id_pedido,
        id_produto,
        quantidade,
        preco_unitario
    )
    VALUES
    (
        @ID_PEDIDO,
        @ID_PRODUTO,
        @QUANTIDADE,
        @PRECO_UNITARIO
    );

    -- Confirma todas as operações
    COMMIT TRANSACTION;

    PRINT 'Venda realizada com sucesso!';

END TRY
BEGIN CATCH

    -- Desfaz as operações caso ocorra algum erro
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Erro ao realizar a venda.';
    PRINT ERROR_MESSAGE();

END CATCH;
GO


-- =================EXECUÇÕES========================

-- Consultar o pedido
SELECT * FROM dbo.Pedidos
ORDER BY id DESC;

-- Consultar os itens
SELECT * FROM dbo.ItensPedidos
ORDER BY id_pedido DESC;

-- Consultar o estoque
SELECT * FROM dbo.Produtos;

-- Consultar as movimentações
SELECT * FROM dbo.MovimentosEstoque
ORDER BY id DESC;



/*
Objeto: Transação [Venda com Estoque Insuficiente]
Script Date: 10/11/2026

Objetivo:
Demonstrar o controle transacional de uma venda com
estoque insuficiente, garantindo a consistência dos dados
por meio do cancelamento de todas as operações realizadas.

Utiliza BEGIN TRANSACTION, TRY/CATCH, THROW e ROLLBACK
para simular uma falha durante a inclusão de um pedido.

A Trigger trg_AtualizarEstoque identifica a insuficiência
de estoque e interrompe a operação, permitindo que o
ROLLBACK desfaça as alterações realizadas na transação.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação de script transacional para testar o cenário de
estoque insuficiente e demonstrar o cancelamento da venda.

Data Alteração: 10/11/2026
*/
-- Dados da venda
DECLARE @ID_CLIENTE INT = 1;
DECLARE @ID_PRODUTO INT = 1;

-- Variáveis de controle
DECLARE @ID_PEDIDO INT;
DECLARE @ID_MAX INT;
DECLARE @PRECO_UNITARIO DECIMAL(10,2);
DECLARE @ESTOQUE_ATUAL INT;
DECLARE @QUANTIDADE INT;

SET XACT_ABORT ON;

BEGIN TRY

    BEGIN TRANSACTION;

    -- Verifica a existência do cliente
    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Clientes
        WHERE id = @ID_CLIENTE
    )
        THROW 50010, 'Cliente não encontrado.', 1;

    -- Consulta o preço e o estoque do produto
    SELECT
        @PRECO_UNITARIO = preco,
        @ESTOQUE_ATUAL = estoque
    FROM dbo.Produtos
    WHERE id = @ID_PRODUTO;

    IF @PRECO_UNITARIO IS NULL
        THROW 50011, 'Produto não encontrado.', 1;

    -- Solicita uma quantidade superior ao estoque disponível
    SET @QUANTIDADE = @ESTOQUE_ATUAL + 1;

    -- Gera o próximo ID do pedido
    SELECT @ID_MAX = ISNULL(MAX(id), 0)
    FROM dbo.Pedidos;

    SET @ID_PEDIDO = @ID_MAX + 1;

    -- Insere o pedido
    INSERT INTO dbo.Pedidos
    (
        id,
        id_cliente,
        situacao
    )
    VALUES
    (
        @ID_PEDIDO,
        @ID_CLIENTE,
        N'Pendente'
    );

    -- Tenta inserir o item
    -- A Trigger identificará o estoque insuficiente
    INSERT INTO dbo.ItensPedidos
    (
        id_pedido,
        id_produto,
        quantidade,
        preco_unitario
    )
    VALUES
    (
        @ID_PEDIDO,
        @ID_PRODUTO,
        @QUANTIDADE,
        @PRECO_UNITARIO
    );

    -- Não deverá chegar até aqui
    COMMIT TRANSACTION;

    PRINT 'Venda realizada com sucesso!';

END TRY
BEGIN CATCH

    -- Desfaz todas as operações da transação
    IF XACT_STATE() <> 0
        ROLLBACK TRANSACTION;

    PRINT 'Venda cancelada!';
    PRINT ERROR_MESSAGE();

END CATCH;
GO