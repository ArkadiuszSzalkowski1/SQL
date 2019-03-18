DROP DATABASE IF EXISTS system;
DROP USER IF EXISTS 'admin_system';
#tworzenie bazy o kodowaniu z polskimi znakami
CREATE DATABASE system DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci;
USE system;

#tworzenie admina bazy i nadanie mu wszystkich uprawnień do tej bazy
CREATE USER 'admin_system' IDENTIFIED BY 'qzhyzbjtxqyk7xo';
GRANT ALL PRIVILEGES ON system.* TO 'admin_system';


CREATE TABLE IF NOT EXISTS KLIENCI (
    id INT AUTO_INCREMENT,
    telefon INT(15) NOT NULL,
    imie VARCHAR(15) NOT NULL,
    nazwisko VARCHAR(30),
    email VARCHAR(30) NOT NULL,
    facebook VARCHAR(50),
    plec ENUM('K', 'M'),
    czy_zarejestrowany ENUM('T', 'N') NOT NULL,
    PRIMARY KEY (id),
    UNIQUE INDEX email_idx (email ASC)
);
CREATE TABLE IF NOT EXISTS KONTA (
    id_klienta INT NOT NULL,
    login VARCHAR(15) NOT NULL UNIQUE,
    haslo VARCHAR(255) NOT NULL,
    PRIMARY KEY (id_klienta),
    UNIQUE INDEX login_klienta_dx (login ASC)
);


#Połączenie między tabelą KLIENT a DOSTEPKLIENTA typu "jeden do jednego"
ALTER TABLE KONTA
ADD CONSTRAINT id_klient_dostep FOREIGN KEY(id_klienta) REFERENCES KLIENCI(id);


CREATE TABLE IF NOT EXISTS PRACOWNICY (
    id INT PRIMARY KEY AUTO_INCREMENT,
    telefon INT(15) NOT NULL,
    imie VARCHAR(15) NOT NULL,
    nazwisko VARCHAR(30) NOT NULL,
    email VARCHAR(30) NOT NULL,
    adres VARCHAR(50),
    login VARCHAR(15) NOT NULL,
    haslo VARCHAR(255) NOT NULL,
    UNIQUE INDEX login_pracownika_idx (login ASC)
);


CREATE TABLE IF NOT EXISTS KATEGORIE (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nazwa VARCHAR(15) NOT NULL
);


CREATE TABLE IF NOT EXISTS USLUGI (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nazwa VARCHAR(30) NOT NULL,
    cena DOUBLE(4 , 2 ) NOT NULL,
    czas TIME NOT NULL,
    id_kategorii INT NOT NULL,
    CONSTRAINT id_kategorii_fk FOREIGN KEY (id_kategorii)
        REFERENCES KATEGORIE (id)
);


CREATE TABLE IF NOT EXISTS TERMINARZ (
    id_klient INT NOT NULL,
    id_pracownik INT NOT NULL,
    id_uslugi INT NOT NULL,
    data DATE NOT NULL,
    godzina TIME NOT NULL,
    PRIMARY KEY (id_klient , id_pracownik , id_uslugi),
    CONSTRAINT id_klient_fk FOREIGN KEY (id_klient)
        REFERENCES KLIENCI (id),
    CONSTRAINT id_pracownik_fk FOREIGN KEY (id_pracownik)
        REFERENCES PRACOWNICY (id),
    CONSTRAINT id_uslugi_fk FOREIGN KEY (id_uslugi)
        REFERENCES USLUGI (id)
);

CREATE TABLE IF NOT EXISTS POSIADA (
    id_uslugi INT,
    id_pracownika INT,
    CONSTRAINT posiada_pk PRIMARY KEY (id_uslugi , id_pracownika),
    CONSTRAINT posiada_fk1 FOREIGN KEY (id_pracownika)
        REFERENCES PRACOWNICY (id),
    CONSTRAINT posiada_fk2 FOREIGN KEY (id_uslugi)
        REFERENCES USLUGI (id)
);

# Tabela zawierająca dane o społecznościach do sekcji "O nas"
CREATE TABLE DANEOFIRMIE(
	id_spolecznosci INT AUTO_INCREMENT,
	nazwa_spolecznosci VARCHAR(30),
    # adres www
    link VARCHAR(255),
    # adres miejsca ikony na serwerze
    ikona VARCHAR(30),
    # flaga czy dana społeczność ma się wyświetlać
    fl_spolecznosci ENUM('T', 'N') NOT NULL,
    PRIMARY KEY(id_spolecznosci)
);

SELECT nazwa_spolecznosci, link, ikona
FROM DANEOFIRMIE
WHERE fl_spolecznosci = 'T';

INSERT INTO zabukuj.DANEOFIRMIE VALUES(null, 'Facebook', 'https://www.facebook.com/arkadiusz.szalkowski', 'ikona', 'T');

INSERT INTO KLIENCI VALUES(null, 500500500, 'Jan', 'Kowalski', 'jankowalski@email.pl', 'facebook.pl/jankowalski', 'M', 'T');
INSERT INTO KLIENCI VALUES(null, 500500500, 'Jan', 'Nowak', 'jannowak@email.pl', 'facebook.pl/jannowak', 'M', 'N');
INSERT INTO KLIENCI VALUES(null, 500200000, 'Karol', 'Nowakowski', 'karolnowakowski@email.pl', 'facebook.pl/karolnowakowski', 'M', 'N');
INSERT INTO KLIENCI VALUES(null, 500100100, 'Michał', 'Kowal', 'michalkowal@email.pl', 'facebook.pl/michalkowal', 'M', 'N');

INSERT INTO KONTA VALUES(1, 'janek', 'haslojanka');



INSERT INTO PRACOWNICY VALUES(null, 80080800, 'Anna', 'Wiśniewska', 'annawisniewska@email.pl', '45-678 Janów, ul. Piękna 17', 'aniafryzjerka', 'hasloAni');
INSERT INTO PRACOWNICY VALUES(null, 800700700, 'Maria', 'Wozniak', 'mariawozniak@email.pl', '45-678 Janów, ul. Wiejska 2', 'marysia', 'hasloMarysi');
INSERT INTO PRACOWNICY VALUES(null, 800600600, 'Karolina', 'Zawadzka', 'karolinazawadzka@email.pl', '45-678 Janów, ul. Nowa 33/78', 'karola', 'hasloKaroli');



INSERT INTO KATEGORIE VALUES(null, 'Strzyżenie');
INSERT INTO KATEGORIE VALUES(null, 'Koloryzacja');
INSERT INTO KATEGORIE VALUES(null, 'Modelowanie');



INSERT INTO USLUGI VALUES(null, 'Strzyżenie krótkie', 30.00, 1500, 1); 
INSERT INTO USLUGI VALUES(null, 'Strzyżenie długie', 30.00, 3000, 1); 
INSERT INTO USLUGI VALUES(null, 'Strzyżenie nowoczesne', 30.00, 4500, 1); 



SET AUTOCOMMIT=0;
START TRANSACTION;
BEGIN;
INSERT INTO KONTA VALUES(3,'karol','haslokarola');

UPDATE KLIENCI 
SET 
    czy_zarejestrowany = 'T'
WHERE
    id = 3;
COMMIT;

# wyzwalacz zmieniający użytkownikowi na nie zarejestrowany
# uruchamiany po usuwaniu
CREATE TRIGGER if_delete_user AFTER DELETE ON KONTA
FOR EACH ROW
UPDATE KLIENCI
SET czy_zarejestrowany = 'N'
WHERE id NOT IN (SELECT id_klienta FROM KONTA);

# polecenie wyłączające chwilowo bezpieczne zmiany
SET SQL_SAFE_UPDATES=0;

DELETE FROM KONTA 
WHERE
    id_klienta = 1;

SET SQL_SAFE_UPDATES=1; 


# wyzwalacz uniemożliwiający wpisanie drugiej takiej samej/podobnej usługi do bazy

USE SYSTEM;
DROP TRIGGER IF EXISTS nowa_usluga;
DELIMITER //

CREATE TRIGGER nowa_usluga 
BEFORE INSERT ON USLUGI
FOR EACH ROW

BEGIN
DECLARE done INT DEFAULT 0;
DECLARE v_nazwa VARCHAR(30);
DECLARE k_nazwa CURSOR FOR
SELECT nazwa FROM USLUGI;
DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;

OPEN k_nazwa;
my_loop: LOOP
FETCH k_nazwa INTO v_nazwa;
IF done = 1 THEN LEAVE my_loop;
ELSEIF LOWER(NEW.nazwa) = LOWER(v_nazwa) THEN
SIGNAL SQLSTATE '45001' SET MESSAGE_TEXT = 'Ta usługa już istnieje';
ELSEIF SOUNDEX(LOWER(NEW.nazwa)) = SOUNDEX(LOWER(v_nazwa)) THEN
SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Podobna usługa już istnieje';
END IF;
END LOOP;
CLOSE k_nazwa;
END //
DELIMITER ;

# polecenie wyzwalające
INSERT INTO USLUGI VALUES(null, 'Strzyżeniekrótkie', 30.00,4500,1);
INSERT INTO USLUGI VALUES(null, 'Strzyenie krotkie', 30.00,4500,1);
INSERT INTO USLUGI VALUES(null, 'Stzyzenie krotkie', 30.00,4500,1);
INSERT INTO USLUGI VALUES(null, 'Strzyzenie krokie', 30.00,4500,1);
INSERT INTO USLUGI VALUES(null, 'stryzeniekrokie', 30.00,4500,1);





