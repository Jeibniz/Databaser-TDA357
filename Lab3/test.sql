\i setup.sql

-- registered to unlimited course
INSERT INTO Registrations VALUES (1111111111,'CCC111');
SELECT * FROM Registrations;
-- registered to limited course + waiting for limited course
INSERT INTO Registrations VALUES (1111111111,'CCC222');
INSERT INTO Registrations VALUES (2222222222,'CCC222');
INSERT INTO Registrations VALUES (3333333333,'CCC222');
SELECT * FROM Registrations;
--Register multiple times
INSERT INTO Registrations VALUES (1111111111,'CCC111');
INSERT INTO Registrations VALUES (2222222222,'CCC222');
SELECT * FROM Registrations;

--Hasn't prerequisite
INSERT INTO Registrations VALUES (2222222222,'CCC333');
--Has prerequisite
INSERT INTO Taken VALUES(3333333333,'CCC111','5');
INSERT INTO Registrations VALUES (3333333333,'CCC333');
SELECT * FROM Registrations;

-- unregistered from unlimited course
DELETE FROM Registrations WHERE student = 1111111111 AND course = 'CCC111';
SELECT * FROM Registrations;
-- unregistered from limited course without waiting list
DELETE FROM Registrations WHERE student = 3333333333 AND course = 'CCC333';
SELECT * FROM Registrations;
-- unregistered from limited course with waiting list
--from registerd
DELETE FROM Registrations WHERE student = 1111111111 AND course = 'CCC222';
SELECT * FROM Registrations;
--from waitnglist
DELETE FROM Registrations WHERE student = 3333333333 AND course = 'CCC222';
SELECT * FROM Registrations;
-- unregiestered from overfull course with waiting list
INSERT INTO Registered VALUES (1111111111,'CCC222');
INSERT INTO Registrations VALUES (3333333333,'CCC222');
DELETE FROM Registrations WHERE student = 1111111111 AND course = 'CCC222';
SELECT * FROM Registrations;

/*
EXPECTED OUTPUT: 

  student   | course |   status   
------------+--------+------------
 1111111111 | CCC111 | registered
(1 row)

INSERT 0 1
INSERT 0 1
INSERT 0 1
  student   | course |   status   
------------+--------+------------
 1111111111 | CCC222 | registered
 3333333333 | CCC222 | waiting
 1111111111 | CCC111 | registered
 2222222222 | CCC222 | waiting
(4 rows)

psql:test.sql:27: ERROR:  The student is already registerd to this course.
CONTEXT:  PL/pgSQL function add_to_waitnglist_when_full() line 10 at RAISE
psql:test.sql:28: ERROR:  The student is already registerd to this course.
CONTEXT:  PL/pgSQL function add_to_waitnglist_when_full() line 10 at RAISE
  student   | course |   status   
------------+--------+------------
 1111111111 | CCC222 | registered
 3333333333 | CCC222 | waiting
 1111111111 | CCC111 | registered
 2222222222 | CCC222 | waiting
(4 rows)

psql:test.sql:32: ERROR:  The student has not taken the prerequisite courses.
CONTEXT:  PL/pgSQL function add_to_waitnglist_when_full() line 23 at RAISE
INSERT 0 1
INSERT 0 1
  student   | course |   status   
------------+--------+------------
 3333333333 | CCC333 | registered
 1111111111 | CCC222 | registered
 3333333333 | CCC222 | waiting
 1111111111 | CCC111 | registered
 2222222222 | CCC222 | waiting
(5 rows)

DELETE 0
  student   | course |   status   
------------+--------+------------
 3333333333 | CCC333 | registered
 1111111111 | CCC222 | registered
 3333333333 | CCC222 | waiting
 2222222222 | CCC222 | waiting
(4 rows)

DELETE 0
  student   | course |   status   
------------+--------+------------
 1111111111 | CCC222 | registered
 3333333333 | CCC222 | waiting
 2222222222 | CCC222 | waiting
(3 rows)

DELETE 0
  student   | course |   status   
------------+--------+------------
 3333333333 | CCC222 | waiting
 2222222222 | CCC222 | registered
(2 rows)

DELETE 0
  student   | course |   status   
------------+--------+------------
 2222222222 | CCC222 | registered
(1 row)

INSERT 0 1
INSERT 0 1
DELETE 0
  student   | course |   status   
------------+--------+------------
 3333333333 | CCC222 | waiting
 2222222222 | CCC222 | registered
(2 rows)
*/