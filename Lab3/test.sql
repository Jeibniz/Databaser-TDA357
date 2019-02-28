\i setup.sql

--Setup inserts
INSERT INTO Departments VALUES ('Dep1', 'D1');
INSERT INTO Programs VALUES ('Prog1', 'P1', '{"Dep1"}');

INSERT INTO Students VALUES (1111111111,'S1','ls1','Prog1');
INSERT INTO Students VALUES (2222222222,'S2','ls2','Prog1');
INSERT INTO Students VALUES (3333333333,'S3','ls3','Prog1');

INSERT INTO Courses VALUES ('CCC111','C1',10,'Dep1');
INSERT INTO Courses VALUES ('CCC222','C2',20,'Dep1');
INSERT INTO Courses VALUES ('CCC333','C3',30,'Dep1', '{CCC111}');

INSERT INTO LimitedCourses VALUES ('CCC222',1);
INSERT INTO LimitedCourses VALUES ('CCC333',2);

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