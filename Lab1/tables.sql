-- TODO: CHANGE TO VARCHAR
CREATE TABLE Students (
    idnr    NUMERIC(10) CHECK (idnr > 0),
    name    TEXT NOT NULL,
    login   TEXT NOT NULL UNIQUE,
    program TEXT NOT NULL, --TODO: Change to reference
    PRIMARY KEY(idnr)
);

CREATE TABLE Branches (
    name    TEXT,
    program TEXT, --TODO: Change to reference
    PRIMARY KEY (name, program)
);

CREATE TABLE Courses (
    code        CHAR(6),
    name        TEXT NOT NULL,
    credits     FLOAT NOT NULL,
    department  TEXT NOT NULL, --TODO: Change to reference
    PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code),
    seats INT Not NULL,
    PRIMARY KEY(code)
);

CREATE TABLE Classifications(
    name TEXT, 
    PRIMARY KEY(name)
);

CREATE TABLE StudentBranches(
    student NUMERIC(10,0) REFERENCES Students(idnr),
    branche TEXT,
    program TEXT,
    FOREIGN KEY (branche, program) REFERENCES Branches(name, program),
    PRIMARY KEY(student)
);

CREATE TABLE Classified(
    course CHAR(6) REFERENCES Courses(code),
    classifications TEXT REFERENCES Classifications(name),
    PRIMARY KEY(course, classifications)
);

CREATE TABLE MandatoryProgram(
    course CHAR(6) REFERENCES Courses(code),
    program TEXT,
    PRIMARY KEY(course, program)
);

CREATE TABLE MandatoryBranch (
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course),
    FOREIGN KEY(branch, program) REFERENCES Branches (name, program)
);

CREATE TABLE RecommendedBranch (
    course CHAR(6) REFERENCES Courses(code),
    branch TEXT,
    program TEXT,
    PRIMARY KEY(course),
    FOREIGN KEY(branch, program) REFERENCES Branches (name, program)
);

CREATE TABLE Registered (
    student NUMERIC(10) REFERENCES Students(idnr), 
    course CHAR(6) REFERENCES Courses(code),
    PRIMARY KEY(student, course)
);

CREATE TABLE Taken (
    student NUMERIC(10) REFERENCES Students(idnr), 
    course CHAR(6) REFERENCES Courses(code),
    grade CHAR(1) NOT NULL,
    PRIMARY KEY(student, course)
);

CREATE TABLE WaitingList (
    student NUMERIC(10) REFERENCES Students(idnr), 
    course CHAR(6) REFERENCES Courses(code),
    position SERIAL,
    PRIMARY KEY(student, course)
);



