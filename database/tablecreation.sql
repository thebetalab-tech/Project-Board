-- ==========================================
-- 1. TABLE CREATION
-- ==========================================

CREATE TABLE Users (
    UserId INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    Email NVARCHAR(100) UNIQUE NOT NULL,
    PasswordHash NVARCHAR(256) NOT NULL,
    EnrollmentNo NVARCHAR(20) NULL,
    Role NVARCHAR(10) NOT NULL,    
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME DEFAULT GETDATE(),
    IsLeader BIT DEFAULT 0         
);

CREATE TABLE Technologies (
    TechId INT IDENTITY(1,1) PRIMARY KEY,
    TechName NVARCHAR(50) UNIQUE NOT NULL 
);

CREATE TABLE Faculty (
    FacultyId INT FOREIGN KEY REFERENCES Users(UserId),
    TechId INT FOREIGN KEY REFERENCES Technologies(TechId),
    PRIMARY KEY (FacultyId, TechId) 
);

CREATE TABLE Groups (
    GroupId INT IDENTITY(1,1) PRIMARY KEY,
    GroupName NVARCHAR(100) NOT NULL,
    LeaderId INT FOREIGN KEY REFERENCES Users(UserId),
    TechId INT FOREIGN KEY REFERENCES Technologies(TechId),
    MentorId INT FOREIGN KEY REFERENCES Users(UserId) NULL,
    Status NVARCHAR(30) DEFAULT 'Forming' 
);

CREATE TABLE GroupMembers (
    GroupId INT FOREIGN KEY REFERENCES Groups(GroupId),
    UserId INT FOREIGN KEY REFERENCES Users(UserId),
    JoinStatus NVARCHAR(15) DEFAULT 'Pending', 
    PRIMARY KEY (GroupId, UserId) 
);

CREATE TABLE Projects (
    ProjectId INT IDENTITY(1,1) PRIMARY KEY,
    GroupId INT FOREIGN KEY REFERENCES Groups(GroupId),
    ProjectType CHAR(3) NOT NULL,          
    ProjectTitle NVARCHAR(150) NOT NULL,
    NormalizedTitle NVARCHAR(150) NOT NULL,
    Functionality NVARCHAR(1000) NOT NULL,
    Status NVARCHAR(15) DEFAULT 'Pending', 
    SubmittedAt DATETIME DEFAULT GETDATE()
);

CREATE TABLE ProjectKeywords (
    TagId INT IDENTITY(1,1) PRIMARY KEY,
    ProjectId INT FOREIGN KEY REFERENCES Projects(ProjectId),
    Keyword NVARCHAR(30) NOT NULL 
);

CREATE TABLE GroupMentorRejections (
    GroupId INT FOREIGN KEY REFERENCES Groups(GroupId),
    FacultyId INT FOREIGN KEY REFERENCES Users(UserId),
    RejectedAt DATETIME DEFAULT GETDATE(),
    PRIMARY KEY (GroupId, FacultyId) 
);