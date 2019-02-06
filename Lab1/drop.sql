-- Drops all tables to reset the database.
DROP TABLE IF EXISTS Students, Branches, Courses,
    LimitedCourses, Classifications, StudentBranches,
    Classified, MandatoryProgram, MandatoryBranch, 
    RecommendedBranch, Registered, Taken, WaitingList
    CASCADE;
DROP VIEW IF EXISTS BasicInformation, FinishedCourses,
Registrations, UnreadMandatory, PathToGraduation;
