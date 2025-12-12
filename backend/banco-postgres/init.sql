-- Criação da Tabela de Contas
CREATE TABLE IF NOT EXISTS Contas (
    numeroConta INTEGER PRIMARY KEY, -- [cite: 18]
    dataCriacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- [cite: 19]
    saldo DECIMAL(15, 2) NOT NULL -- 
);

-- Criação da Tabela de Livro Caixa (Movimentações)
CREATE TABLE IF NOT EXISTS livroCaixa (
    idtransacao SERIAL PRIMARY KEY, -- [cite: 22]
    dataTransacao TIMESTAMP DEFAULT CURRENT_TIMESTAMP, -- [cite: 23]
    valorTransacao DECIMAL(15, 2) NOT NULL, -- [cite: 24]
    numeroConta INTEGER NOT NULL, -- [cite: 25]
    operacao VARCHAR(10) CHECK (operacao IN ('ENTRADA', 'SAIDA')), -- [cite: 26]
    destino VARCHAR(255), -- [cite: 27]
    origem VARCHAR(255), -- [cite: 28]
    
    -- Chave estrangeira ligando à tabela de Contas
    CONSTRAINT fk_conta
      FOREIGN KEY(numeroConta) 
      REFERENCES Contas(numeroConta)
);

-- (Opcional) Inserir dados de exemplo para testar
INSERT INTO Contas (numeroConta, saldo) VALUES (123456, 1000.00);

INSERT INTO livroCaixa (valorTransacao, numeroConta, operacao, destino, origem) 
VALUES (60.00, 123456, 'SAIDA', 'Fabio Pereira', 'Tatiana Favoretti');