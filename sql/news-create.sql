CREATE TABLE categories (
       catname	 	VARCHAR(15) PRIMARY KEY,
       name	 	VARCHAR(30) NOT NULL, 
       type 		CHAR(5) NOT NULL,
       uri	 	VARCHAR(254),
       description 	VARCHAR(254)
);



CREATE TABLE users (
       username		VARCHAR(8) PRIMARY KEY,
       name	 	VARCHAR(30) NOT NULL,
       email	 	VARCHAR(30), 
       uri	 	VARCHAR(254),
       passwd 		VARCHAR(40)
);


CREATE TABLE contributors (
       username 	VARCHAR(8) PRIMARY KEY REFERENCES users ON DELETE CASCADE ON UPDATE CASCADE,
       authlevel 	SMALLINT,
       bio	 	VARCHAR(254)
);

CREATE TABLE stories (
       storyname     VARCHAR(10),
       sectionid     VARCHAR(10),
       image	     VARCHAR(100),
       primcat	     VARCHAR(15) NOT NULL REFERENCES categories (catname) ON DELETE RESTRICT ON UPDATE CASCADE,
       seccat	     VARCHAR(15)[],
       freesubject   VARCHAR(15)[],
       editorok	     BOOLEAN DEFAULT false,
       title	     VARCHAR(40) NOT NULL,
       minicontent   TEXT,
       content	     TEXT,
       username	     VARCHAR(8) NOT NULL REFERENCES users ON DELETE SET NULL ON UPDATE CASCADE,
       submitterid   VARCHAR(8),
       linktext      VARCHAR(15),
       timestamp     TIMESTAMP NOT NULL,
       lasttimestamp TIMESTAMP NOT NULL,
       PRIMARY KEY (storyname, sectionid)
);
  
 
CREATE TABLE comments (
       commentpath   VARCHAR(254),
       storyname     VARCHAR(10),
       sectionid     VARCHAR(10),
       title	     VARCHAR(40) NOT NULL,
       content	     TEXT,
       timestamp     TIMESTAMP NOT NULL,
       username	     VARCHAR(8) REFERENCES users ON DELETE CASCADE ON UPDATE CASCADE, 
       PRIMARY KEY (commentpath, storyname, sectionid),
       FOREIGN KEY (storyname, sectionid) REFERENCES stories ON DELETE SET NULL ON UPDATE CASCADE       
);

