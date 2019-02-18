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
    code        CHAR(6),
    name        TEXT NOT NULL UNIQUE,
    credits     FLOAT NOT NULL,
    department  TEXT REFERENCES Departments(name),
    PRIMARY KEY(code)
);

CREATE TABLE LimitedCourses(
    code CHAR(6) REFERENCES Courses(code),
    seats INT NOT NULL,
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