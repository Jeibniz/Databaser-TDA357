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
