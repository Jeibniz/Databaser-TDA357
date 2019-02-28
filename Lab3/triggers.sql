
CREATE FUNCTION add_to_waitnglist_when_full() RETURNS trigger AS $register_to_course$
    DECLARE
        c TEXT;
    BEGIN
        -- Check if students is alredy registerd.
        IF  NEW.student IN ( 
            SELECT Registrations.student FROM Registrations
            WHERE Registrations.course = NEW.COURSE)
        THEN    
            RAISE EXCEPTION 'The student is already registerd to this course.';
        END IF;

        -- Check if student has taken prerequisite course.
        IF (SELECT prerequisite FROM Courses WHERE Courses.code = NEW.course) NOTNULL
        THEN
            FOREACH c IN ARRAY (SELECT prerequisite FROM Courses WHERE Courses.code = NEW.course)
            LOOP
                IF (c NOTNULL) AND c NOT IN 
                (
                    SELECT PassedCourses.course FROM PassedCourses 
                    WHERE PassedCourses.student = NEW.student)
                THEN
                    RAISE EXCEPTION 'The student has not taken the prerequisite courses.';
                END IF;
            END LOOP;
        END IF;

        -- Check if the course is full or not.
        IF NEW.COURSE IN (SELECT LimitedCourses.code FROM LimitedCourses)
            AND (
                (SELECT COUNT(DISTINCT Registered.student) FROM Registered
                WHERE Registered.course = NEW.Course)
                >=
                (SELECT seats FROM LimitedCourses
                WHERE LimitedCourses.code = NEW.course)
            )
        THEN
            -- If full inster into waitning list.
            INSERT INTO WaitingList VALUES (NEW.student, NEW.course);
        ELSE
            --If not, register.
            INSERT INTO Registered VALUES (NEW.student, NEW.course);
        END IF;

        RETURN NEW;
    END;
$register_to_course$ LANGUAGE plpgsql;


CREATE FUNCTION add_from_waitinglist_when_unregister() RETURNS trigger AS $remove_from_waitinglist$
    DECLARE
        first_student NUMERIC(10);
        first_course CHAR(6);
    BEGIN
        -- Check if student was in WaitingList.
        IF  OLD.student IN ( 
            SELECT CourseQueuePositions.student FROM CourseQueuePositions
            WHERE CourseQueuePositions.course = OLD.COURSE)
        THEN   
            DELETE FROM WaitingList WHERE student = OLD.student AND course = OLD.course;
            RETURN NULL;
            --RAISE EXCEPTION 'IFFFFFThe student is in the waithinglist .';
        END IF;
        -- Check if student was registerd.
        IF  OLD.student IN ( 
            SELECT Registered.student FROM Registered
            WHERE Registered.course = OLD.COURSE)
        THEN 
            DELETE FROM Registered WHERE student = OLD.student AND course = OLD.course;
            IF OLD.COURSE IN (SELECT LimitedCourses.code FROM LimitedCourses)
                AND (
                    (SELECT COUNT(DISTINCT Registered.student) FROM Registered
                    WHERE Registered.course = OLD.Course)
                    <
                    (SELECT seats FROM LimitedCourses
                    WHERE LimitedCourses.code = OLD.course)) 
                AND ((SELECT student from CourseQueuePositions
                    WHERE course = OLD.course AND position = 1)
                    NOTNULL
                )
            THEN
            first_student = 
                (SELECT student from CourseQueuePositions
                WHERE course = OLD.course AND position = 1);
            first_course = 
                (SELECT course from CourseQueuePositions
                WHERE course = OLD.course AND position = 1);

            DELETE FROM WaitingList WHERE student = first_student AND course = first_course;
            INSERT INTO Registered VALUES (first_student, first_course);
            END IF;
        END IF;
        RETURN NULL;
    END;
$remove_from_waitinglist$ LANGUAGE plpgsql;

CREATE TRIGGER register_to_course INSTEAD OF INSERT OR UPDATE ON Registrations 
    FOR EACH ROW EXECUTE FUNCTION add_to_waitnglist_when_full();

CREATE TRIGGER unregister_from_course INSTEAD OF DELETE ON Registrations 
    FOR EACH ROW EXECUTE FUNCTION add_from_waitinglist_when_unregister();

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