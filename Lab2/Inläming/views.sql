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