-- Delete existing table
PRAGMA foreign_keys = ON;

-- Create PictureOptions enum table
CREATE TABLE IF NOT EXISTS PictureOptions (
  option	TEXT		PRIMARY KEY NOT NULL
);

-- Create wallpaper table
CREATE TABLE IF NOT EXISTS Wallpapers  (
  inode		INTEGER 	PRIMARY KEY,
  file_path	TEXT 		UNIQUE,
  category	INTEGER(+1) 	CHECK (category >= 0),
  width 	INTEGER 	CHECK (width > 0),
  height 	INTEGER 	CHECK (height > 0),
  selected 	INTEGER(+1) 	CHECK (selected >= 0 AND selected <= 1) NOT NULL ON CONFLICT FAIL
  );

CREATE TABLE IF NOT EXISTS Metadata (
  inode		INTEGER		REFERENCES wallpapers(inode),
  view_count	INTEGER 	CHECK (view_count >= 0),
  star_rating	INTEGER(+1) 	CHECK (star_rating >= 0),
  user_comments	TEXT,
  option	TEXT		REFERENCES PictureOptions(option)
  );

-- Fill with values
INSERT OR IGNORE INTO PictureOptions VALUES ("centered");
INSERT OR IGNORE INTO PictureOptions VALUES ("scaled");
INSERT OR IGNORE INTO PictureOptions VALUES ("spanned");
INSERT OR IGNORE INTO PictureOptions VALUES ("zoom");
INSERT OR IGNORE INTO PictureOptions VALUES ("stretched");
INSERT OR IGNORE INTO PictureOptions VALUES ("wallpaper");


-- BEGIN TEST SUITE
-- Test Insertion
--INSERT INTO wallpapers VALUES (234905, "/home/user/Pictures/example.png", 0, 0, 0, null, 1600, 1000, 0);
--INSERT INTO wallpapers VALUES (340985, "/home/user/Pictures/example2.jpg", 0, 0, 0, null, 1600, 900, 0);
--.print
--.print Wallpapers are...
---- Show results
--SELECT * FROM wallpapers;
--
--.print
--.print Aspect ratios...
---- Get aspect ratio
--SELECT (CAST (width AS REAL) / height) AS ratio FROM wallpapers;
--
--.print
--.print 16:10 wallpapers
---- Get 16:10 walls only
--SELECT file_path FROM wallpapers WHERE (width * 1.0/ height = 1.6);
