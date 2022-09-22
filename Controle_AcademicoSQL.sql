CREATE DATABASE Controle_Academico;

USE Controle_Academico;

CREATE TABLE Aluno(

	RA int NOT NULL,
	Nome varchar (50) NOT NULL,

	CONSTRAINT PK_Aluno PRIMARY KEY(RA)
);
SELECT * FROM Aluno;

INSERT INTO Aluno (RA, Nome)
VALUES (1, 'WESLEN'),
	   (2, 'THALYA'),
	   (3, 'FELIPE'),
	   (4, 'LARISSA'),
	   (5, 'MAICON'),
	   (6, 'GABI'),
	   (7, 'LUIS FELIPE'),
	   (8, 'GIOVANI'),
	   (9, 'JULIA'),
	   (10, 'LUCIANO');

CREATE TABLE Disciplina (
    Sigla char(3) NOT NULL,
    Nome varchar(20) NOT NULL,
    Carga_Horaria int NOT NULL

	CONSTRAINT PK_Disciplina PRIMARY KEY(Sigla)
);
SELECT * FROM Disciplina;

ALTER TABLE Disciplina
ALTER COLUMN Nome varchar(50);

INSERT INTO Disciplina (Sigla, Nome, Carga_Horaria)
VALUES ('CA', 'CALCULO', 100),
	   ('EDS', 'ESTUDOS DISCIPLINARES', 140),
	   ('MAT', 'MATEMÁTICA', 120),
	   ('POR', 'PORTUGUÊS', 100),
	   ('ING', 'INGLÊS', 90),
	   ('POO', 'PROGRA_ORIENT_OBJETOS', 140),
	   ('ES', 'ENGENHARIA DE SOFTWARE', 120),
	   ('TCC', 'TRABALHO CONCLUSÃO DE CURSO', 100),
	   ('DS', 'DESENVOLVIMENTO SUSTENTÁVEL', 100),
	   ('ALG', 'ALGORITMO',100 );


CREATE TABLE Matricula(
    RA int NOT NULL,
    Sigla char(3) NOT NULL,
    Data_Ano int NOT NULL,
    Data_Semestre int NOT NULL,
    Falta int NULL,
    Nota_N1 float,
    Nota_N2 float,
    Nota_Sub float,
    Nota_Media float,
    Situacao bit

	CONSTRAINT PK_Matricula PRIMARY KEY (RA, Sigla, Data_Ano, Data_Semestre),
    FOREIGN KEY (RA) REFERENCES Aluno(RA),
    FOREIGN KEY (Sigla) REFERENCES Disciplina(Sigla)
);

ALTER TABLE Matricula
ALTER COLUMN Situacao varchar (20);
SELECT * FROM Matricula;

INSERT INTO Matricula (RA, Sigla, Data_Ano, Data_Semestre)
VALUES (1,'CA' ,2021, 2),
	   (1,'EDS',2021, 2),
	   (2,'ING',2021, 2),
	   (2,'EDS',2021, 2),
	   (3,'POO',2021, 2),
	   (7,'ALG',2021, 2);

DELETE FROM Matricula;

CREATE TRIGGER TRG_Controle
On Matricula
AFTER UPDATE
AS
BEGIN
	DECLARE
	@Nota1 DECIMAL(10,1),
	@Nota2 DECIMAL(10,1),
	@Media DECIMAL(10,1),
	@Sub DECIMAL(10,1),
	@Ra int,
	@Sigla char(3),
	@Falta int,
	@Carga_Horaria int,
	@SiglaD char (3),
	@SiglaM char (3),
	@Situacao varchar(20)
	
	/* Frequencia do aluno e Situação*/
	SELECT @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub, @Falta = Falta FROM INSERTED
	SELECT @Carga_Horaria = Carga_Horaria FROM Disciplina WHERE Disciplina.Sigla = @Sigla
	UPDATE Matricula SET Situacao = 'Aprovado'
	WHERE   RA = @Ra AND Sigla = @Sigla AND Falta < @Carga_Horaria * 0.25 AND Data_Ano = 2021

	UPDATE Matricula SET Situacao = 'Reprovado',
		Nota_Media = NULL
	WHERE   RA = @Ra AND Sigla = @Sigla AND Falta > @Carga_Horaria * 0.25 AND Data_Ano = 2021
	
	/* Notas e Situação do aluno*/
	SELECT @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub FROM INSERTED
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Nota2) / 2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 'Aprovado'  

	/*Comando para Notas Substitutivas*/
	SELECT @Media = Nota_Media, @Nota1 = Nota_N1, @Nota2 = Nota_N2, @Ra = RA, @Sigla = Sigla, @Sub = Nota_Sub FROM INSERTED
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Sub) /2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 'Aprovado' AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 > Nota_N2 AND Data_Ano = 2021
	
	UPDATE Matricula SET Nota_Media = (@Nota1 + @Sub) /2 
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 'Aprovado' AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 = Nota_N2 AND Data_Ano = 2021
	
	UPDATE Matricula SET Nota_Media = (@Nota2 + @Sub) /2
	WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 'Aprovado' AND Nota_Sub > 0 AND Nota_Media < 5 AND Nota_N1 < Nota_N2 AND Data_Ano = 2021
	
	UPDATE Matricula SET Situacao = 'Reprovado'
	WHERE RA = @Ra AND Sigla = @Sigla AND Nota_Media < 5  AND Data_Ano = 2021

	/*Rematricula do Aluno Reprovado*/
	INSERT INTO Matricula(RA, Sigla, Data_Ano, Data_Semestre)
		(SELECT RA, Sigla, 2022, 2 FROM Matricula WHERE RA = @Ra AND Sigla = @Sigla AND Situacao = 'Reprovado' )
	
END

/* Insere Notas e Faltas*/
UPDATE Matricula SET Nota_N1 = 8,
					 Nota_N2 = 8,
					 Nota_Sub = NULL,
					 Falta = null
					 WHERE RA = 1 AND Sigla = 'CA'
SELECT * FROM Matricula;

UPDATE Matricula SET Nota_N1 = 1,
					 Nota_N2 = 2,
					 Nota_Sub = 4,
					 Falta = 5
					 WHERE RA = 1 AND Sigla = 'EDS'

UPDATE Matricula SET Nota_N1 = 3,
					 Nota_N2 = 9,
					 Nota_sub = null,
					 Falta = 20
					 WHERE RA = 2 AND Sigla = 'EDS'

UPDATE Matricula SET Nota_N1 = 10,
					 Nota_N2 = 6,
					 Nota_Sub = null,
					 Falta = 10
					 WHERE RA = 2 AND Sigla = 'ING'

UPDATE Matricula SET Nota_N1 = 5,
					 Nota_N2 = 3,
					 Nota_Sub = 2,
					 Falta = 10
					 WHERE RA = 3 AND Sigla = 'POO'

UPDATE Matricula SET Nota_N1 = 10,
					 Nota_N2 = 10,
					 Nota_Sub = NULL,
					 Falta = 50
					 WHERE RA = 7 AND Sigla = 'ALG'

SELECT * FROM Matricula;


/* Visualiza quais são alunos de uma determinada disciplina ministrada no ano de 2021, com suas 
notas, faltas e Situação Final.-*/
SELECT a.RA, a.Nome AS 'Aluno', d.Nome 'Disciplina', m.Nota_N1, m.Nota_N2, m.Nota_Sub, m.Nota_Media, m.Falta, m.Situacao
FROM Aluno a, Matricula m, Disciplina d
WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Sigla = 'EDS'

/*Visualiza quais são as notas, faltas e situação final (Boletim) de um aluno em todas as disciplinas
por ele cursadas no ano de 2021, no segundo semestre.*/
SELECT a.RA, a.Nome AS 'Aluno', d.Nome 'Disciplina', m.Nota_N1, m.Nota_N2, m.Nota_Sub, m.Nota_Media, m.Falta, m.Situacao
FROM Aluno a, Matricula m, Disciplina d
WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND a.RA = 1

/* Visualiza quais são os alunos reprovados por nota (média inferior a cinco) no ano de 2021 e, o 
nome das disciplinas em que eles reprovaram, com suas notas e médias.*/
SELECT a.RA, a.Nome AS 'Aluno', d.Nome 'Disciplina', m.Nota_N1, m.Nota_N2, m.Nota_Sub, m.Nota_Media, m.Situacao, m.Falta
FROM Aluno a, Matricula m, Disciplina d
WHERE a.RA = m.RA AND m.Sigla = d.Sigla AND m.Situacao = 'Reprovado' AND m.Nota_Media < 5









