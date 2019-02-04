CREATE OR REPLACE VIEW BasicInformation AS
SELECT idnr, Students.name AS name, login, Students.program AS program, 
    Branches.name AS branch
FROM Students, Branches
WHERE Students.program = Branches.program;

CREATE OR REPLACE VIEW FinishedCourses AS
SELECT student, course, grade, credits
FROM Taken, Courses
WHERE course= code;

CREATE OR REPLACE VIEW PassedCourses AS
SELECT student, course, credits
FROM Taken, Courses
WHERE course= code AND grade <> 'U';
