-- =================LOGIN/USER/ROLE========================

-- Criando o LOGIN
-- O LOGIN representa as credenciais utilizadas para se autenticar na instância do SQL Server.
USE master;
GO

CREATE LOGIN login_conecta_consulta
WITH PASSWORD = 'Conecta@Consulta2026';
GO

-- Criando o USER
-- Agora vamos associar o login criado a um usuário dentro do banco Conecta_Comercio.
USE Conecta_Comercio;
GO

CREATE USER user_conecta_consulta
FOR LOGIN login_conecta_consulta;
GO

-- Criando a ROLE
-- A Role funcionará como um grupo de permissões
CREATE ROLE role_consulta;
GO

--Associando o USER na ROLE
ALTER ROLE role_consulta
ADD MEMBER user_conecta_consulta;
GO


-- Concedendo permissão com GRANT de consulta em todas as tabelas e views do esquema dbo
USE Conecta_Comercio;
GO

GRANT SELECT ON SCHEMA::dbo
TO role_consulta;
GO

-- Testando a permissão de consulta

USE Conecta_Comercio;
GO

EXECUTE AS LOGIN = 'login_conecta_consulta';

SELECT * FROM dbo.Produtos;

REVERT;
GO

-- Revogando a permissão de consulta com REVOKE
USE Conecta_Comercio;
GO

REVOKE SELECT ON SCHEMA::dbo
FROM role_consulta;
GO

-- Testando a permissão de consulta após o REVOKE

USE Conecta_Comercio;
GO

EXECUTE AS LOGIN = 'login_conecta_consulta';

SELECT * FROM dbo.Produtos;

REVERT;
GO

-- =================BACKUP========================

-- Backup FULL de banco de dados Conecta_Comercio

USE master;
GO

BACKUP DATABASE Conecta_Comercio
TO DISK = N'C:\BackupSQL\Conecta_Comercio_FULL.bak'
WITH
    CHECKSUM,
    STATS = 10;
GO


-- verifica se o arquivo de beckup apareceu na pasta "C:\BackupSQL"
RESTORE VERIFYONLY
FROM DISK = N'C:\BackupSQL\Conecta_Comercio_FULL.bak'
WITH CHECKSUM;
GO

-- =================RESTAURAÇÃO DE BACKUP========================

-- restaura banco do do arquivo .bak "C:\BackupSQL\Conecta_Comercio_FULL.bak"
USE master;
GO

RESTORE DATABASE Conecta_Comercio_Lab
FROM DISK = N'C:\BackupSQL\Conecta_Comercio_FULL.bak'
WITH
    MOVE N'Conecta_Comercio'
        TO N'C:\BackupSQL\Conecta_Comercio_Lab.mdf',

    MOVE N'Conecta_Comercio_log'
        TO N'C:\BackupSQL\Conecta_Comercio_Lab_log.ldf',

    RECOVERY,
    STATS = 10;
GO

-- verifica se banco foi restaurado com sucesso (ONLINE)
SELECT
    name,
    state_desc
FROM sys.databases
WHERE name = 'Conecta_Comercio_Lab';

-- Testa as tabelas do banco restaurado
USE Conecta_Comercio_Lab;
GO

SELECT * FROM dbo.Clientes;
SELECT * FROM dbo.Produtos;
SELECT * FROM dbo.Pedidos;
SELECT * FROM dbo.ItensPedidos;
GO