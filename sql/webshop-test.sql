
INSERT INTO products ( 
       prodid,
       catname,
       title
)
VALUES (
       't-shirt',
       'clothing',
       'A Fine T-Shirt'
);

INSERT INTO productprices (
       prodid,
       volume,
       price
) VALUES (
  't-shirt',
  2,
  100
);

INSERT INTO productprices (
       prodid,
       volume,
       price
) VALUES (
  't-shirt',
  5,
  80
);

INSERT INTO products ( 
       prodid,
       catname,
       title
)
VALUES (
       'mugs',
       'misc',
       'A Really Nice Mug'
);

INSERT INTO productprices (
       prodid,
       volume,
       price
) VALUES (
  'mugs',
  1,
  10
);

INSERT INTO productsubtypes (
       prodsubid,
       prodid,
       title,
       stockconfirmed,
       stockshipped,
       stockordered
) VALUES (
  'S',
  't-shirt',
  'Small',
  100,
  89,
  87
);

INSERT INTO productsubtypes (
       prodsubid,
       prodid,
       title,
       stockconfirmed,
       stockshipped,
       stockordered
) VALUES (
  'M',
  't-shirt',
  'Medium',
  93,
  71,
  62
);


INSERT INTO productsubtypes (
       prodsubid,
       prodid,
       title,
       stockconfirmed,
       stockshipped,
       stockordered
) VALUES (
  'L',
  't-shirt',
  'Large',
  92,
  89,
  81
);