CREATE TABLE categories (
       catname	 	VARCHAR(15) PRIMARY KEY NOT NULL,
       name	 	VARCHAR(30) NOT NULL, 
       type 		CHAR(5) NOT NULL,
       uri	 	VARCHAR(254),
       description 	VARCHAR(254)
);

INSERT INTO categories (
       catname,
       type,
       name,
       uri,
       description
)
VALUES ( 
       'felines',
       'categ',
       'Catcategory',
       'http://dev.kjernsmo.net/cats/felines',
       'This is a cat about felines'
);

INSERT INTO categories (
       catname,
       type,
       name,
       uri,
       description
)
VALUES ( 
       'kittens',
       'categ',
       'Kittens',
       'http://dev.kjernsmo.net/cats/kittens',
       'Cats are cute when small'
);


INSERT INTO categories (
       catname,
       type,
       name,
       uri,
       description
)
VALUES ( 
       'cats',
       'categ',
       'Another Cats category',
       'http://dev.kjernsmo.net/cats/cats',
       'This is a cat about cats'
);


INSERT INTO categories (
       catname,
       type,
       name,
       uri,
       description
)
VALUES ( 
       'test1',
       'frees',
       'Free Subject test 1'
);


INSERT INTO categories (
       catname,
       type,
       name,
       uri,
       description
)
VALUES ( 
       'test2',
       'frees',
       'Free Subject test 2',
       'http://dev.kjernsmo.net/test1',
       'Test 2'
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




INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/foo',
       'coolhack',
       'features',
       'Comment title',
       'Yeah, that was cool!',
       '20020210',
       'foo'
);


INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/foo/bar',
       'coolhack',
       'features',
       'Huh, what?',
       'aint seen a thing!',
       '20030219',
       'bar'
);


INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/foo/foobar',
       'coolhack',
       'features',
       'Re: Comment title',
       'Yeah, agreed',
       '20030222',
       'foobar'
);



INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/foo/foobar/foo',
       'coolhack',
       'features',
       'Re: Huh',
       'The hack! That was cool!',
       '20030227',
       'foo'
);


INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/bar',
       'coolhack',
       'features',
       'Whaddayamean?',
       'Am I blind, or is this story devoid of content?',
       '20030307',
       'bar'
);


INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/bar/kjetil',
       'coolhack',
       'features',
       'Editors comment',
       'Well, it is not easy to see, but...',
       '20030310',
       'kjetil'
);


INSERT INTO comments (
       commentpath,
       storyname,
       sectionid,
       title,
       content,
       timestamp,
       username
) 
VALUES (
       '/foo',
       'coolhack',
       'smallcats',
       'The point is:',
       'Check out the expanded category info',
       '20031211',
       'foo'
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
  
INSERT INTO stories (
       storyname,
       sectionid,
       primcat,
       title,
       content,
       username,
       submitterid,
       timestamp,
       lasttimestamp
) 
VALUES (
       'coolhack',
       'features',
       'cats',
       'Article about Cool Hacks',
       'Once upon a time, there was this really cool hack',
       'kjetil',
       'kjetil',
       '20030209',
       '20030227'
);



INSERT INTO stories (
       storyname,
       sectionid,
       primcat,
       seccat,
       freesubject,
       title,
       content,
       username,
       submitterid,
       timestamp,
       lasttimestamp
) 
VALUES (
       'smallcats',
       'features',
       'felines',
       '{"kittens","cats"}',
       '{"test1","test2"}',
       'Interesting post about smaller cats.',
       'There are a bunch of small cats running around out there.',
       'kjetil',
       'foobar',
       '20031205',
       '20031211'
);



CREATE TABLE users (
       username		VARCHAR(8) PRIMARY KEY NOT NULL,
       name	 	VARCHAR(30) NOT NULL,
       email	 	VARCHAR(30), 
       uri	 	VARCHAR(254),
       passwd		VARCHAR(40)
);

INSERT INTO users (
       username, 
       name,
       email,
       uri,
       passwd
) 
VALUES (
       'kjetil',
       'Kjetil Kjernsmo',
       'kjetil@kjernsmo.net',
       'http://www.kjetil.kjernsmo.net/',
       '$1$1ee9HLjU$7/gwrsXwt0UDEjyIDhiz8.'
);

INSERT INTO users (
       username, 
       name,
       email,
       uri,
       passwd
) 
VALUES (
       'foo',
       'Foo',
       'foo@example.com',
       'http://www.example.com/foo/',
       '$1$1ee9HLjU$7/gwrsXwt0UDEjyIDhiz8.'
);


INSERT INTO users (
       username, 
       name,
       uri,
       passwd
) 
VALUES (
       'bar',
       'Bar',
       'http://www.example.com/bar',
       '$1$1ee9HLjU$7/gwrsXwt0UDEjyIDhiz8.'
);

INSERT INTO users (
       username, 
       name,
       email,
       uri,
       passwd
) 
VALUES (
       'foobar',
       'Foo Bar',
       'foobar@foobar.org',
       'http://www.foobar.org/',
       '$1$1ee9HLjU$7/gwrsXwt0UDEjyIDhiz8.'
);


CREATE TABLE contributors (
       username 	VARCHAR(8) PRIMARY KEY NOT NULL,
       authlevel 	SMALLINT,
       bio	 	VARCHAR(254)
);

INSERT INTO contributors (
       username, 
       authlevel,
       bio
) 
VALUES (
       'kjetil',
       9,
       'TABOO developer'
);

INSERT INTO contributors (
       username, 
       authlevel,
       bio
) 
VALUES (
       'foo',
       1,
       'We all know Foo'
);


INSERT INTO contributors (
       username, 
       authlevel,
       bio
) 
VALUES (
       'bar',
       5,
       'Bar is an well known editor'
);

INSERT INTO contributors (
       username, 
       authlevel,
       bio
) 
VALUES (
       'foobar',
       1
);


