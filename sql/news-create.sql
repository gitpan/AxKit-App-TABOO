CREATE TABLE categories (
       catname	 	VARCHAR(15) PRIMARY KEY NOT NULL,
       name	 	VARCHAR(30) NOT NULL, 
       type 		CHAR(5) NOT NULL,
       uri	 	VARCHAR(254),
       description 	VARCHAR(254)
);


  
CREATE TABLE comments (
       commentpath   VARCHAR(254) NOT NULL,
       storyname     VARCHAR(10) NOT NULL,
       sectionid     VARCHAR(10) NOT NULL,
       title	     VARCHAR(40) NOT NULL,
       content	     TEXT,
       timestamp     TIMESTAMP NOT NULL,
       username	     VARCHAR(8) 
);


CREATE TABLE stories (
       storyname     VARCHAR(10) NOT NULL,
       sectionid     VARCHAR(10) NOT NULL,
       image	     VARCHAR(100),
       primcat	     VARCHAR(15) NOT NULL,
       seccat	     VARCHAR(15)[],
       freesubject   VARCHAR(15)[],
       editorok	     BOOLEAN DEFAULT false,
       title	     VARCHAR(40) NOT NULL,
       minicontent   TEXT,
       content	     TEXT,
       username	     VARCHAR(8) NOT NULL,
       submitterid   VARCHAR(8),
       linktext      VARCHAR(15),
       timestamp     TIMESTAMP NOT NULL,
       lasttimestamp TIMESTAMP NOT NULL
);
  



CREATE TABLE users (
       username		VARCHAR(8) PRIMARY KEY NOT NULL,
       name	 	VARCHAR(30) NOT NULL,
       email	 	VARCHAR(30), 
       uri	 	VARCHAR(254),
       passwd 		VARCHAR(40)
);


CREATE TABLE contributors (
       username 	VARCHAR(8) PRIMARY KEY NOT NULL,
       authlevel 	SMALLINT,
       bio	 	VARCHAR(254)
);
