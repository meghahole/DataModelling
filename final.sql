-- 1
CREATE TYPE Artist AS OBJECT (
  artist_id NUMBER,
  name VARCHAR2(100),
  genre VARCHAR2(50),
  debut_date DATE,
  rank number,
  relative ref Artist
) NOT FINAL;
/

-- 2

DROP TYPE Artist;
CREATE OR REPLACE TYPE Artist AS OBJECT ( 
  artist_id NUMBER,
  name VARCHAR2(100),
  genre VARCHAR2(50),
  debut_date DATE,
  rank number,
  relative ref Artist,
  MAP MEMBER FUNCTION compareArtist return number,
  MEMBER PROCEDURE displayInfo(SELF Artist)
) NOT FINAL;
/

CREATE TYPE BODY Artist AS
  MAP MEMBER FUNCTION compareArtist return number is
  BEGIN
    RETURN rank;
  END compareArtist;

  MEMBER PROCEDURE displayInfo(SELF Artist) IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Artist ID: ' || SELF.artist_id);
    DBMS_OUTPUT.PUT_LINE('Name: ' || SELF.name);
    DBMS_OUTPUT.PUT_LINE('Genre: ' || SELF.genre);
    DBMS_OUTPUT.PUT_LINE('Rank: ' || SELF.rank);
    DBMS_OUTPUT.PUT_LINE('Debut Date: ' || TO_CHAR(SELF.debut_date, 'YYYY-MM-DD'));
  END displayInfo;
END;
/

-- 3

CREATE TABLE ArtistInfo OF Artist(
  CONSTRAINT pk_artist PRIMARY KEY (artist_id),
  CONSTRAINT genre_notnull CHECK (genre IS NOT NULL),
  CONSTRAINT rank_valid CHECK (rank > 0),
  CONSTRAINT rank_unique UNIQUE (rank)
);

-- 4

DECLARE
BEGIN
  INSERT INTO ArtistInfo VALUES (Artist(1, 'Beyoncé', 'Pop/R&B', TO_DATE('1997-08-16', 'YYYY-MM-DD'), 5, null));
  INSERT INTO ArtistInfo VALUES (Artist(2, 'Ed Sheeran', 'Pop', TO_DATE('2004-02-17', 'YYYY-MM-DD'), 1, null));
  INSERT INTO ArtistInfo VALUES (Artist(3, 'Taylor Swift', 'Pop/Country', TO_DATE('2006-10-24', 'YYYY-MM-DD'), 2, null));
  INSERT INTO ArtistInfo VALUES (Artist(4, 'Michael Jackson', 'Pop/Rock', TO_DATE('1964-11-14', 'YYYY-MM-DD'), 4, null));
  INSERT INTO ArtistInfo VALUES (Artist(5, 'Elvis Presley', 'Rock and Roll', TO_DATE('1954-07-19', 'YYYY-MM-DD'), 3, null));

  UPDATE ArtistInfo a SET a = Artist(1, 'Beyoncé Knowles', 'Pop/R&B', TO_DATE('1997-08-16', 'YYYY-MM-DD'), 5, null) WHERE a.artist_id = 1;

  DELETE FROM ArtistInfo a WHERE a.artist_id = 2;
  
END;
/

-- 5

DECLARE
  a Artist;
  CURSOR c1 IS SELECT VALUE(t) FROM ArtistInfo t;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO a;
    EXIT WHEN c1%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE('*** next artist ***'); 
    a.displayInfo();
  END LOOP;
  CLOSE c1;
END;
/

-- 6

DECLARE
  TYPE artist_array IS TABLE OF Artist;
  artists artist_array;
BEGIN 
  SELECT VALUE(t) BULK COLLECT INTO artists FROM ArtistInfo t;
  FOR i IN 1..artists.COUNT LOOP
    artists(i).displayInfo();
  END LOOP;
END;
/

-- 7

DECLARE
  a_ref REF Artist;
BEGIN
  SELECT REF(a) INTO a_ref FROM ArtistInfo a WHERE a.artist_id = 1;
  INSERT INTO ArtistInfo VALUES (Artist(6, 'Janet Jackson', 'Pop/R&B', TO_DATE('1982-11-21', 'YYYY-MM-DD'), 8, a_ref));
END;
/

DECLARE
  a1 Artist;
  a2 Artist;
BEGIN
  SELECT VALUE(t) INTO a1 FROM ArtistInfo t WHERE artist_id = 6;
  SELECT DEREF(a1.relative) INTO a2 FROM DUAL;
  a2.displayInfo();
END;
/

-- 8

CREATE OR REPLACE TYPE RockArtist UNDER Artist (
  instrument_played VARCHAR2(50),
  MEMBER FUNCTION get_instrument_played RETURN VARCHAR2,     --cannot override
  FINAL MEMBER PROCEDURE display_instrument_played
) NOT FINAL;
/
CREATE OR REPLACE TYPE BODY RockArtist AS
  MEMBER FUNCTION get_instrument_played RETURN VARCHAR2 IS
  BEGIN
    RETURN ('Instrument Played: ' || instrument_played);
  END;

  FINAL MEMBER PROCEDURE display_instrument_played IS
  BEGIN
    DBMS_OUTPUT.PUT_LINE('Instrument Played: ' || instrument_played);
  END;
END;
/

-- 9

CREATE OR REPLACE TYPE MichiganRockArtist UNDER RockArtist (  
       address VARCHAR2(100),
       OVERRIDING MEMBER FUNCTION get_instrument_played RETURN VARCHAR2
       --OVERRIDING MEMBER PROCEDURE display_instrument_played  /*FINAL method cannot be overriden*/
    ) NOT FINAL;   
/

CREATE OR REPLACE TYPE BODY MichiganRockArtist AS
     OVERRIDING MEMBER FUNCTION get_instrument_played RETURN VARCHAR2 IS
     BEGIN
    	RETURN 'Michigan Artist, Instrument Played: ' || instrument_played;
     END;
END;
/