USE Conecta_Comercio;
GO

/*
Object: StoredProcedure [dbo].[usp_InserirDadosCliente]
Script Date: 09/11/2026
Objetivo:
Inserir um novo cliente na tabela Clientes, gerando
automaticamente um identificador único (IdCliente)
com base no maior ID existente. Caso a tabela esteja
vazia, o identificador será iniciado em 1.

Desenvolvedor: Guilherme Paiva Alves
Alterações: Criação da procedure para inserção de clientes
com geração sequencial do identificador.
Data Alteração: 09/11/2026
*/
CREATE OR ALTER PROCEDURE dbo.usp_InserirDadosCliente
    @NOME NVARCHAR(100),
    @EMAIL NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_MAX INT;

    SET @ID_MAX = (SELECT MAX(id) FROM dbo.Clientes);

    IF @ID_MAX IS NULL
    BEGIN
        SET @ID_MAX = 1;
    END
    ELSE
    BEGIN
        SET @ID_MAX += 1;
    END

    INSERT INTO dbo.Clientes (id, nome, email)
    VALUES (@ID_MAX, @NOME, @EMAIL);
END;
GO

/*
Object: StoredProcedure [dbo].[usp_InserirDadosFornecedor]
Script Date: 09/11/2026

Objetivo:
Inserir um novo fornecedor na tabela Fornecedores,
gerando automaticamente um identificador único (id)
com base no maior ID existente. Caso a tabela esteja
vazia, o identificador será iniciado em 1.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da procedure para inserção de fornecedores
com geração sequencial do identificador.

Data Alteração: 09/11/2026
*/
CREATE OR ALTER PROCEDURE dbo.usp_InserirDadosFornecedor
    @EMAIL NVARCHAR(100),
    @TELEFONE NVARCHAR(100),
    @RAZAO_SOCIAL NVARCHAR(300)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_MAX INT;

    SET @ID_MAX = (SELECT MAX(id) FROM dbo.Fornecedores);

    IF @ID_MAX IS NULL
    BEGIN
        SET @ID_MAX = 1;
    END
    ELSE
    BEGIN
        SET @ID_MAX += 1;
    END

    INSERT INTO dbo.Fornecedores (id,email,telefone,razao_social)
    VALUES (@ID_MAX, @EMAIL, @TELEFONE, @RAZAO_SOCIAL);
END;
GO

/*
Object: StoredProcedure [dbo].[usp_InserirDadosProdutos]
Script Date: 09/11/2026

Objetivo:
Inserir um novo produto na tabela Produtos, gerando
automaticamente um identificador único (id) com base
no maior ID existente. Caso a tabela esteja vazia,
o identificador será iniciado em 1.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da procedure para inserção de produtos
com geração sequencial do identificador.

Data Alteração: 09/11/2026
*/

CREATE OR ALTER PROCEDURE dbo.usp_InserirDadosProdutos
    @EMAIL_FORNECEDOR NVARCHAR(100),
    @NOME NVARCHAR(100),
    @PRECO DECIMAL(10,2),
    @ESTOQUE INT = 0
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_FORNECEDOR INT;
    DECLARE @ID_MAX INT;

    -- Recupera o identificador do fornecedor pelo email
    SELECT @ID_FORNECEDOR = id
    FROM dbo.Fornecedores
    WHERE email = @EMAIL_FORNECEDOR;

    -- Verifica se o fornecedor existe
    IF @ID_FORNECEDOR IS NULL
        THROW 50001, 'Fornecedor nao encontrado.', 1;

    -- Valida os valores do produto
    IF @PRECO < 0 OR @ESTOQUE < 0
        THROW 50002, 'Preco e estoque nao podem ser negativos.', 1;

    -- Gera o próximo identificador
    SELECT @ID_MAX = MAX(id)
    FROM dbo.Produtos;

    IF @ID_MAX IS NULL
        SET @ID_MAX = 1;
    ELSE
        SET @ID_MAX += 1;

    -- Insere o produto
    INSERT INTO dbo.Produtos
        (id, id_fornecedor, nome, preco, estoque)
    VALUES
        (@ID_MAX, @ID_FORNECEDOR, @NOME, @PRECO, @ESTOQUE);
END;
GO


/*
Object: StoredProcedure [dbo].[usp_InserirDadosPedidos]
Script Date: 09/11/2026

Objetivo:
Inserir um novo pedido na tabela Pedidos, recuperando
automaticamente o identificador do cliente por meio
do seu email. O identificador do pedido é gerado
sequencialmente com base no maior ID existente.
Também realiza a validação da situação do pedido,
permitindo apenas os valores predefinidos.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da procedure para inserção de pedidos,
com recuperação do identificador do cliente pelo email,
validação da situação e geração sequencial do identificador.

Data Alteração: 09/11/2026
*/
CREATE OR ALTER PROCEDURE dbo.usp_InserirDadosPedidos
    @EMAIL_CLIENTE NVARCHAR(100),
    @SITUACAO NVARCHAR(100)
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @ID_CLIENTE INT;
    DECLARE @ID_MAX INT;

    -- Recupera o identificador do cliente pelo email
    SELECT @ID_CLIENTE = id
    FROM dbo.Clientes
    WHERE email = @EMAIL_CLIENTE;

    -- Verifica se o cliente existe
    IF @ID_CLIENTE IS NULL
        THROW 50001, 'Cliente nao encontrado.', 1;

    -- Valida a situacao do pedido
    IF @SITUACAO IS NULL OR @SITUACAO NOT IN (
        N'Pendente',
        N'Aprovado',
        N'Enviado',
        N'Cancelado'
    )
        THROW 50002, 'Situacao invalida.', 1;

    -- Gera o proximo identificador
    SELECT @ID_MAX = MAX(id)
    FROM dbo.Pedidos;

    IF @ID_MAX IS NULL
        SET @ID_MAX = 1;
    ELSE
        SET @ID_MAX += 1;

    -- Insere o pedido
    INSERT INTO dbo.Pedidos
        (id, id_cliente, situacao)
    VALUES
        (@ID_MAX, @ID_CLIENTE, @SITUACAO);
END;
GO


/*
Object: StoredProcedure [dbo].[usp_InserirDadosItensPedidos]
Script Date: 09/11/2026

Objetivo:
Inserir um novo item na tabela ItensPedidos, utilizando
os identificadores do pedido e do produto informados.
Recupera automaticamente o preço unitário do produto
na tabela Produtos por meio do seu identificador.
Também realiza a validação da existência do pedido e
do produto, além da quantidade informada.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da procedure para inserção de itens em pedidos,
com recuperação automática do preço unitário e validação
dos dados antes da inserção.

Data Alteração: 09/11/2026
*/
CREATE OR ALTER PROCEDURE dbo.usp_InserirDadosItensPedidos
    @ID_PEDIDO INT,
    @ID_PRODUTO INT,
    @QUANTIDADE INT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @PRECO_UNITARIO DECIMAL(10,2);

    -- Verifica se o pedido existe
    IF @ID_PEDIDO IS NULL OR NOT EXISTS (
        SELECT 1 FROM dbo.Pedidos WHERE id = @ID_PEDIDO
    )
        THROW 50001, 'Pedido nao encontrado.', 1;

    -- Recupera o preco unitario do produto
    SELECT @PRECO_UNITARIO = preco
    FROM dbo.Produtos
    WHERE id = @ID_PRODUTO;

    -- Verifica se o produto existe
    IF @ID_PRODUTO IS NULL OR @PRECO_UNITARIO IS NULL
        THROW 50002, 'Produto nao encontrado.', 1;

    -- Valida a quantidade
    IF @QUANTIDADE IS NULL OR @QUANTIDADE <= 0
        THROW 50003, 'Quantidade deve ser maior que zero.', 1;

    -- Insere o item do pedido
    INSERT INTO dbo.ItensPedidos
        (id_pedido, id_produto, quantidade, preco_unitario)
    VALUES
        (@ID_PEDIDO, @ID_PRODUTO, @QUANTIDADE, @PRECO_UNITARIO);
END;
GO

/*
Objeto: Trigger [dbo].[trg_AtualizarEstoque]
Script Date: 09/11/2026

Objetivo:
Automatizar a atualização do estoque e o registro de movimentações
sempre que novos itens forem inseridos na tabela ItensPedidos.

Funcionamento:
- Agrupa as quantidades inseridas por produto.
- Verifica se existe estoque suficiente para atender aos pedidos.
- Atualiza a quantidade disponível na tabela Produtos.
- Registra uma movimentação do tipo 'Saida' na tabela MovimentosEstoque.
- Cancela a operação caso não exista estoque suficiente.

Desenvolvedor: Guilherme Paiva Alves

Alterações:
Criação da trigger para automatizar o controle de estoque
a partir da inclusão de itens nos pedidos.

Data Alteração: 09/11/2026
*/
CREATE OR ALTER TRIGGER dbo.trg_AtualizarEstoque
ON dbo.ItensPedidos
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    -- Agrupa as quantidades por produto
    DECLARE @ProdutosInseridos TABLE (
        id_produto INT PRIMARY KEY,
        quantidade INT NOT NULL
    );

    INSERT INTO @ProdutosInseridos (id_produto, quantidade)
    SELECT
        id_produto,
        SUM(quantidade)
    FROM inserted
    GROUP BY id_produto;

    -- Atualiza o estoque somente se houver quantidade suficiente
    UPDATE p
    SET p.estoque = p.estoque - i.quantidade
    FROM dbo.Produtos p
    INNER JOIN @ProdutosInseridos i
        ON p.id = i.id_produto
    WHERE p.estoque >= i.quantidade;

    -- Verifica se todos os produtos tiveram o estoque atualizado
    IF @@ROWCOUNT <> (SELECT COUNT(*) FROM @ProdutosInseridos)
        THROW 50004, 'Estoque insuficiente para realizar o pedido.', 1;

    -- Gera os IDs das movimentações
    DECLARE @ID_MAX INT;

    SELECT @ID_MAX = ISNULL(MAX(id), 0)
    FROM dbo.MovimentosEstoque;

    -- Registra as movimentações de saída
    INSERT INTO dbo.MovimentosEstoque (
        id,
        id_produto,
        tipo,
        quantidade
    )
    SELECT
        @ID_MAX + ROW_NUMBER() OVER (ORDER BY id_produto),
        id_produto,
        N'Saida',
        quantidade
    FROM @ProdutosInseridos;
END;
GO



-- inserir clientes
EXEC dbo.usp_InserirDadosCliente N'Ana Martins','ana.martins@email.com';
EXEC dbo.usp_InserirDadosCliente N'Carlos Oliveira','carlos.oliveira@email.com';
EXEC dbo.usp_InserirDadosCliente N'Mariana Costa','mariana.costa@email.com';
EXEC dbo.usp_InserirDadosCliente N'Rafael Santos', 'rafael.santos@email.com';
EXEC dbo.usp_InserirDadosCliente N'Juliana Ferreira', 'juliana.ferreira@email.com';
EXEC dbo.usp_InserirDadosCliente N'Pedro Almeida', 'pedro.almeida@email.com';
EXEC dbo.usp_InserirDadosCliente N'Beatriz Lima', 'beatriz.lima@email.com';
EXEC dbo.usp_InserirDadosCliente N'Lucas Pereira', 'lucas.pereira@email.com';
EXEC dbo.usp_InserirDadosCliente N'Camila Rodrigues', 'camila.rodrigues@email.com';
EXEC dbo.usp_InserirDadosCliente N'Fernando Souza', 'fernando.souza@email.com';
GO

SELECT * FROM dbo.Clientes;

-- inserir fornecedores
EXEC dbo.usp_InserirDadosFornecedor 'contato@techsolutions.com', '(11) 3456-7890', N'Tech Solutions Comércio de Tecnologia Ltda';
EXEC dbo.usp_InserirDadosFornecedor 'vendas@eletromais.com', '(11) 3456-7891', N'Eletro Mais Distribuidora Ltda';
EXEC dbo.usp_InserirDadosFornecedor 'comercial@moveisideal.com', '(11) 3456-7892', N'Móveis Ideal Indústria e Comércio Ltda';
EXEC dbo.usp_InserirDadosFornecedor 'contato@papelariaexpress.com', '(11) 3456-7893', N'Papelaria Express Ltda';
EXEC dbo.usp_InserirDadosFornecedor 'atendimento@centralinformatica.com', '(11) 3456-7894', N'Central Informática Distribuidora Ltda';
GO

-- conferir fornecedores 
SELECT * FROM dbo.Fornecedores;


-- inserir produtos
EXEC dbo.usp_InserirDadosProdutos 'contato@techsolutions.com', N'Notebook Dell Inspiron', 3499.90, 15;
EXEC dbo.usp_InserirDadosProdutos 'vendas@eletromais.com', N'Monitor LG 24 polegadas', 899.90, 20;
EXEC dbo.usp_InserirDadosProdutos 'comercial@moveisideal.com', N'Cadeira de Escritório', 649.90, 12;
EXEC dbo.usp_InserirDadosProdutos 'contato@papelariaexpress.com', N'Kit de Material Escolar', 79.90, 50;
EXEC dbo.usp_InserirDadosProdutos 'atendimento@centralinformatica.com', N'Teclado Mecânico', 259.90, 30;
EXEC dbo.usp_InserirDadosProdutos 'contato@techsolutions.com', N'Mouse sem fio', 89.90, 40;
EXEC dbo.usp_InserirDadosProdutos 'contato@techsolutions.com', N'Headset USB', 149.90, 25;
EXEC dbo.usp_InserirDadosProdutos 'contato@techsolutions.com', N'Webcam Full HD', 219.90, 18;
EXEC dbo.usp_InserirDadosProdutos 'contato@techsolutions.com', N'Notebook Lenovo', 4299.90, 10;
EXEC dbo.usp_InserirDadosProdutos 'contato@techsolutions.com', N'Suporte para notebook', 99.90, 35;
EXEC dbo.usp_InserirDadosProdutos 'vendas@eletromais.com', N'Monitor Samsung 27 polegadas', 1299.90, 14;
EXEC dbo.usp_InserirDadosProdutos 'vendas@eletromais.com', N'Impressora Epson', 899.90, 12;
EXEC dbo.usp_InserirDadosProdutos 'vendas@eletromais.com', N'Caixa de som Bluetooth', 179.90, 30;
EXEC dbo.usp_InserirDadosProdutos 'vendas@eletromais.com', N'Roteador Wi-Fi', 249.90, 22;
EXEC dbo.usp_InserirDadosProdutos 'vendas@eletromais.com', N'HD externo 1TB', 349.90, 16;
EXEC dbo.usp_InserirDadosProdutos 'comercial@moveisideal.com', N'Mesa para escritório', 799.90, 8;
EXEC dbo.usp_InserirDadosProdutos 'comercial@moveisideal.com', N'Estante organizadora', 459.90, 10;
EXEC dbo.usp_InserirDadosProdutos 'comercial@moveisideal.com', N'Gaveteiro móvel', 329.90, 15;
EXEC dbo.usp_InserirDadosProdutos 'comercial@moveisideal.com', N'Armário de escritório', 999.90, 6;
EXEC dbo.usp_InserirDadosProdutos 'comercial@moveisideal.com', N'Poltrona de escritório', 1199.90, 7;
EXEC dbo.usp_InserirDadosProdutos 'contato@papelariaexpress.com', N'Caderno universitário', 24.90, 100;
EXEC dbo.usp_InserirDadosProdutos 'contato@papelariaexpress.com', N'Caneta esferográfica', 3.50, 200;
EXEC dbo.usp_InserirDadosProdutos 'contato@papelariaexpress.com', N'Kit de lápis de cor', 19.90, 80;
EXEC dbo.usp_InserirDadosProdutos 'contato@papelariaexpress.com', N'Papel A4 pacote', 32.90, 60;
EXEC dbo.usp_InserirDadosProdutos 'contato@papelariaexpress.com', N'Agenda executiva', 39.90, 45;
EXEC dbo.usp_InserirDadosProdutos 'atendimento@centralinformatica.com', N'Pen drive 64GB', 49.90, 50;
EXEC dbo.usp_InserirDadosProdutos 'atendimento@centralinformatica.com', N'SSD 480GB', 299.90, 20;
EXEC dbo.usp_InserirDadosProdutos 'atendimento@centralinformatica.com', N'Memória RAM 8GB', 189.90, 24;
EXEC dbo.usp_InserirDadosProdutos 'atendimento@centralinformatica.com', N'Fonte 500W', 279.90, 13;
EXEC dbo.usp_InserirDadosProdutos 'atendimento@centralinformatica.com', N'Placa de vídeo', 1899.90, 5;
GO

-- conferir produtos
SELECT
    p.id,
    p.nome,
    f.razao_social AS fornecedor,
    p.preco,
    p.estoque
FROM dbo.Produtos p
INNER JOIN dbo.Fornecedores f
    ON p.id_fornecedor = f.id;


-- inserir pedidos
EXEC dbo.usp_InserirDadosPedidos'ana.martins@email.com', N'Pendente';
EXEC dbo.usp_InserirDadosPedidos 'carlos.oliveira@email.com', N'Aprovado';
EXEC dbo.usp_InserirDadosPedidos 'mariana.costa@email.com', N'Enviado';
EXEC dbo.usp_InserirDadosPedidos 'rafael.santos@email.com', N'Pendente';
EXEC dbo.usp_InserirDadosPedidos 'juliana.ferreira@email.com', N'Cancelado';
EXEC dbo.usp_InserirDadosPedidos 'ana.martins@email.com', N'Aprovado';
EXEC dbo.usp_InserirDadosPedidos 'carlos.oliveira@email.com', N'Enviado';
EXEC dbo.usp_InserirDadosPedidos 'mariana.costa@email.com', N'Pendente';
EXEC dbo.usp_InserirDadosPedidos 'rafael.santos@email.com', N'Aprovado';
EXEC dbo.usp_InserirDadosPedidos 'juliana.ferreira@email.com', N'Enviado';
EXEC dbo.usp_InserirDadosPedidos 'pedro.almeida@email.com', N'Pendente';
EXEC dbo.usp_InserirDadosPedidos 'beatriz.lima@email.com', N'Aprovado';
EXEC dbo.usp_InserirDadosPedidos 'lucas.pereira@email.com', N'Enviado';
EXEC dbo.usp_InserirDadosPedidos 'camila.rodrigues@email.com', N'Pendente';
EXEC dbo.usp_InserirDadosPedidos 'fernando.souza@email.com', N'Aprovado';
EXEC dbo.usp_InserirDadosPedidos 'ana.martins@email.com', N'Enviado';
EXEC dbo.usp_InserirDadosPedidos 'carlos.oliveira@email.com', N'Pendente';
EXEC dbo.usp_InserirDadosPedidos 'mariana.costa@email.com', N'Aprovado';
EXEC dbo.usp_InserirDadosPedidos 'pedro.almeida@email.com', N'Enviado';
EXEC dbo.usp_InserirDadosPedidos 'beatriz.lima@email.com', N'Cancelado';
GO

-- conferir pedidos
SELECT
    p.id,
    c.nome AS cliente,
    p.data_pedido,
    p.situacao
FROM dbo.Pedidos p
INNER JOIN dbo.Clientes c
    ON p.id_cliente = c.id;


-- inserir item pedido
EXEC dbo.usp_InserirDadosItensPedidos 1, 1, 2;
EXEC dbo.usp_InserirDadosItensPedidos 2, 2, 1;
EXEC dbo.usp_InserirDadosItensPedidos 3, 3, 4;
EXEC dbo.usp_InserirDadosItensPedidos 4, 4, 3;
EXEC dbo.usp_InserirDadosItensPedidos 5, 5, 1;
EXEC dbo.usp_InserirDadosItensPedidos 6, 6, 2;
EXEC dbo.usp_InserirDadosItensPedidos 7, 7, 1;
EXEC dbo.usp_InserirDadosItensPedidos 8, 8, 3;
EXEC dbo.usp_InserirDadosItensPedidos 9, 9, 2;
EXEC dbo.usp_InserirDadosItensPedidos 10, 10, 1;
EXEC dbo.usp_InserirDadosItensPedidos 11, 11, 2;
EXEC dbo.usp_InserirDadosItensPedidos 12, 12, 1;
EXEC dbo.usp_InserirDadosItensPedidos 13, 13, 2;
EXEC dbo.usp_InserirDadosItensPedidos 14, 14, 1;
EXEC dbo.usp_InserirDadosItensPedidos 15, 15, 3;
EXEC dbo.usp_InserirDadosItensPedidos 16, 16, 2;
EXEC dbo.usp_InserirDadosItensPedidos 17, 17, 5;
EXEC dbo.usp_InserirDadosItensPedidos 18, 18, 2;
EXEC dbo.usp_InserirDadosItensPedidos 19, 19, 1;
EXEC dbo.usp_InserirDadosItensPedidos 20, 20, 1;


-- conferir itens pedidos
SELECT
    ip.id_pedido,
    c.nome AS cliente,
    p.nome AS produto,
    ip.quantidade,
    ip.preco_unitario,
    (ip.quantidade * ip.preco_unitario) AS subtotal
FROM dbo.ItensPedidos ip
INNER JOIN dbo.Pedidos pe
    ON ip.id_pedido = pe.id
INNER JOIN dbo.Clientes c
    ON pe.id_cliente = c.id
INNER JOIN dbo.Produtos p
    ON ip.id_produto = p.id
ORDER BY ip.id_pedido;

-- conferir as movimentações no estoque
SELECT
    m.id,
    p.nome AS produto,
    m.tipo,
    m.quantidade,
    m.data_movimento
FROM dbo.MovimentosEstoque m
INNER JOIN dbo.Produtos p
    ON p.id = m.id_produto
ORDER BY m.id;