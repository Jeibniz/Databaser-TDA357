-- TODO: CHANGE TO VARCHAR
CREATE TABLE Students (
    idnr    NUMERIC(10) PRIMARY KEY,
    name    TEXT NOT NULL,
    login   TEXT NOT NULL,
    program TEXT NOT NULL --TODO: Change to reference
);

CREATE TABLE Branches (
    name    TEXT,
    program TEXT,
    PRIMARY KEY(name, program) --TODO: Change to reference
);

-- Courses(_code_, name, credits, department)
CREATE TABLE Courses (
    code        TEXT PRIMARY KEY,
    name        TEXT NOT NULL,
    credits     NOT NULL,
    department  TEXT NOT NULL --TODO: Change to reference
);
