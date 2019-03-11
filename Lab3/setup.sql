----------drop.sql----------
-- Drops all tables to reset the database.
DROP TABLE IF EXISTS Departments, Programs, Students, 
    Branches, Courses, LimitedCourses, Classifications,
    StudentBranches, Classified, MandatoryProgram,
    MandatoryBranch, RecommendedBranch, Registered, 
    Taken, WaitingList CASCADE;

DROP VIEW IF EXISTS BasicInformation, FinishedCourses,
Registrations, UnreadMandatory, PathToGraduation;

DROP FUNCTION IF EXISTS add_to_waitnglist_when_full(), add_from_waitinglist_when_unregister();

DROP TRIGGER IF EXISTS register_to_course ON Registrations;
DROP TRIGGER IF EXISTS unregister_from_course ON Registrations;

----------tables.sql----------
CREATE TABLE Departments (
    name TEXT,
    abberiation TEXT UNIQUE,
    PRIMARY KEY(name)
);

CREATE TABLE Programs (
    name TEXT,
    abberiation TEXT,
    department  TEXT[],
    PRIMARY KEY(name)
);

CREATE TABLE Students (
    idnr    NUMERIC(10) CHECK (idnr > 0),
    name    TEXT NOT NULL,
    login   TEXT NOT NULL UNIQUE,
    program TEXT REFERENCES Programs(name),
    PRIMARY KEY(idnr)
);

CREATE TABLE Branches(
    name    TEXT,
    program TEXT REFERENCES Programs(name),
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code            CHAR(6),
    name            TEXT NOT NULL UNIQUE,
    credits         FLOAT NOT NULL,
    department      TEXT REFERENCES Departments(name),
    prerequisite    CHAR(6) ARRAY,
    PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
    code    CHAR(6) REFERENCES Courses(code),
    seats   INT NOT NULL,
    PRIMARY KEY(code)
);

CREATE TABLE Classifications(
    name TEXT, 
    PRIMARY KEY(name)
);

CREATE TABLE StudentBranches(
    student NUMERIC(10,0) REFERENCES Students(idnr),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(student),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Classified(
    course CHAR(6) REFERENCES Courses(code),
    classification TEXT REFERENCES Classifications(name),
    PRIMARY KEY(course, classification)
);

CREATE TABLE MandatoryProgram(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT REFERENCES Programs(name),
    PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch (
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE RecommendedBranch (
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course, branch, program),
    FOREIGN KEY (branch, program) REFERENCES Branches(name, program)
);

CREATE TABLE Registered (
    student NUMERIC(10) REFERENCES Students(idnr), 
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken (
    student NUMERIC(10) REFERENCES Students(idnr), 
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL CHECK (grade IN ('U', '3', '4', '5')),
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList (
    student NUMERIC(10) REFERENCES Students(idnr), 
    course CHAR(6) REFERENCES LimitedCourses(code),
    position SERIAL,
    PRIMARY KEY(student, course)
);


----------views.sql----------
-- Uses a join to create a table that contains all students and not only
-- those that have ma branch.
CREATE OR REPLACE VIEW BasicInformation AS
SELECT idnr, Students.name, login, Students.program, 
    StudentBranches.branch
FROM Students LEFT OUTER JOIN StudentBranches 
    ON Students.idnr = StudentBranches.student AND 
        Students.program = StudentBranches.program; 

CREATE OR REPLACE VIEW FinishedCourses AS
SELECT student, course, grade, credits
FROM Taken, Courses
WHERE course = code;

CREATE OR REPLACE VIEW PassedCourses AS
SELECT student, course, credits
FROM Taken, Courses
WHERE course = code AND grade <> 'U';

CREATE OR REPLACE VIEW Registrations AS
SELECT student, course, 'registered' as status
FROM Registered
UNION
SELECT student, course, 'waiting' as status
FROM WaitingList;

--The first two queries creates a table that contains all mandatory courses for
--students. The last query contains all passed course for students.
CREATE OR REPLACE VIEW UnreadMandatory AS
SELECT DISTINCT idnr AS student, course
FROM BasicInformation, MandatoryProgram
WHERE BasicInformation.program = MandatoryProgram.program
UNION
SELECT DISTINCT idnr AS student, course
FROM BasicInformation, MandatoryBranch
WHERE BasicInformation.branch = MandatoryBranch.branch AND BasicInformation.program = MandatoryBranch.program
EXCEPT
SELECT student, course
FROM PassedCourses;

-- Uses a with clause and a chain of LEFT OUTER JOIN operations to combine them.
CREATE OR REPLACE VIEW PathToGraduation AS
WITH ids AS (
        SELECT idnr AS student FROM Students),
    totalCredits AS (
        SELECT student, SUM(credits) AS totalCredits
        FROM PassedCourses
        GROUP BY student),
    -- Uses a join to create a table that contains all students and not only
    -- those that have mandatory courses left.
    mandaLeft AS (
        SELECT ids.student, COUNT(DISTINCT  course) AS mandatoryLeft
        FROM ids LEFT OUTER JOIN UnreadMandatory ON 
        ids.student = UnreadMandatory.student
        GROUP BY ids.student),
    mathCred AS (
        SELECT student, SUM(credits) AS mathCredits
        FROM PassedCourses, Classified
        WHERE classification = 'math' AND PassedCourses.course = Classified.course
        GROUP BY student),
    resCred AS (
        SELECT student, SUM(credits) AS researchCredits
        FROM PassedCourses, Classified
        WHERE classification = 'research' AND PassedCourses.course = Classified.course
        GROUP BY student),
    semCorse AS (
        SELECT student, COUNT(PassedCourses.course) AS seminarCourses
        FROM PassedCourses, Classified
        WHERE classification = 'seminar' AND PassedCourses.course = Classified.course
        GROUP BY student),
    qual AS (
        SELECT DISTINCT ids.student, mandatoryLeft = 0 AND mathCredits >= 20 
            AND researchCredits >= 10 AND seminarCourses >= 1 AND 
            --Makes sure that the student is in a branch
            ids.student IN (SELECT student from StudentBranches) AS qualified 
        FROM ids, mandaLeft, mathCred, resCred, semCorse
        WHERE ids.student = mandaLeft.student AND ids.student = mathCred.student AND
        ids.student = resCred.student AND ids.student = semCorse.student
    )
SELECT ids.student, COALESCE(totalCredits,0) AS totalCredits, mandatoryLeft AS mandatoryLeft,
    COALESCE(mathCredits,0) AS mathCredits, COALESCE(researchCredits,0) AS researchCredits, 
    COALESCE(seminarCourses,0) AS seminarCourses, COALESCE(qualified,false) AS qualified
FROM ids 
    LEFT OUTER JOIN totalCredits ON ids.student = totalCredits.student
    LEFT OUTER JOIN mandaLeft ON ids.student = mandaLeft.student
    LEFT OUTER JOIN mathCred ON ids.student = mathCred.student
    LEFT OUTER JOIN resCred ON ids.student = resCred.student
    LEFT OUTER JOIN semCorse ON ids.student = semCorse.student
    LEFT OUTER JOIN qual ON ids.student = qual.student;

CREATE OR REPLACE VIEW CourseQueuePositions AS
SELECT student, course, ROW_NUMBER () OVER (ORDER BY position) AS position
FROM WaitingList;

----------inserts.sql----------
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