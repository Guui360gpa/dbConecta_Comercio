CREATE DATABASE Conecta_Comercio;
GO

USE Conecta_Comercio;
GO

CREATE TABLE Clientes (
	id INT PRIMARY KEY,
	nome NVARCHAR(100) NOT NULL,
	email NVARCHAR(100) NOT NULL UNIQUE
);
GO

CREATE TABLE Fornecedores (
	id INT PRIMARY KEY,
	email NVARCHAR(100) NOT NULL UNIQUE,
	telefone NVARCHAR(100) NOT NULL UNIQUE,
	razao_social NVARCHAR(300) NOT NULL
);
GO

CREATE TABLE Produtos (
	id INT PRIMARY KEY,
	id_fornecedor INT NOT NULL,
	nome NVARCHAR(100) NOT NULL,
	preco DECIMAL(10,2) NOT NULL CHECK(preco >= 0),
	estoque INT NOT NULL CHECK(estoque >= 0) DEFAULT 0,

	CONSTRAINT FK_Produtos_Fornecedores
		FOREIGN KEY(id_fornecedor)
		REFERENCES Fornecedores(id)
);
GO

CREATE TABLE Pedidos (
	id INT PRIMARY KEY,
	id_cliente INT NOT NULL,
	data_pedido DATE NOT NULL DEFAULT GETDATE(),
	situacao NVARCHAR(100) NOT NULL CHECK (situacao IN (N'Pendente', N'Aprovado',N'Enviado',N'Cancelado')),

	CONSTRAINT FK_Pedidos_Clientes
		FOREIGN KEY(id_cliente)
		REFERENCES Clientes(id)
);
GO

CREATE TABLE ItensPedidos (
	id_pedido INT NOT NULL,
	id_produto INT NOT NULL,
	quantidade INT NOT NULL CHECK(quantidade > 0),
	preco_unitario DECIMAL(10,2) NOT NULL CHECK (preco_unitario >= 0),

	PRIMARY KEY(id_pedido,id_produto),

	    CONSTRAINT FK_ItensPedidos_Pedidos
        FOREIGN KEY(id_pedido)
        REFERENCES Pedidos(id),

    CONSTRAINT FK_ItensPedidos_Produtos
        FOREIGN KEY(id_produto)
        REFERENCES Produtos(id)
);
GO

CREATE TABLE MovimentosEstoque (
	id INT PRIMARY KEY,
	id_produto INT NOT NULL,
	tipo NVARCHAR(100) NOT NULL CHECK(tipo IN ('Entrada', 'Saida', 'Ajuste')),
	quantidade INT NOT NULL CHECK(quantidade > 0),
	data_movimento DATE NOT NULL DEFAULT GETDATE(),

	CONSTRAINT FK_MovimentosEstoque_Produtos
		FOREIGN KEY(id_produto)
		REFERENCES Produtos(id)
);
GO

CREATE TABLE Auditorias (
	id INT PRIMARY KEY,
	tabela NVARCHAR(100) NOT NULL,
	operacao NVARCHAR(100) NOT NULL CHECK(operacao IN (N'INSERT',N'UPDATE',N'DELETE')),
	data_evento DATETIME NOT NULL DEFAULT GETDATE(),
	descricao NVARCHAR(700)  NOT NULL DEFAULT N''
);
GO