-- User :

-- 1. SELECTION SP (What to see)
GO
CREATE PROCEDURE sp_select_users
    @Action NVARCHAR(20),       -- 'ALL', 'BY_ID', 'BY_ROLE'
    @UserId INT = NULL,
    @Role NVARCHAR(10) = NULL
AS
BEGIN
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Users WHERE IsActive = 1;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT * FROM Users WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'BY_ROLE'
    BEGIN
        SELECT * FROM Users WHERE Role = @Role AND IsActive = 1;
    END
END
GO

-- 2. CRUD SP (What to do)
CREATE PROCEDURE sp_crud_users
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE', 'DELETE'
    @UserId INT = NULL,
    @FullName NVARCHAR(100) = NULL,
    @Email NVARCHAR(100) = NULL,
    @PasswordHash NVARCHAR(256) = NULL,
    @EnrollmentNo NVARCHAR(20) = NULL,
    @Role NVARCHAR(10) = NULL,
    @IsLeader BIT = 0
AS
BEGIN
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Users (FullName, Email, PasswordHash, EnrollmentNo, Role, IsLeader)
        VALUES (@FullName, @Email, @PasswordHash, @EnrollmentNo, @Role, @IsLeader);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Users
        SET FullName = ISNULL(@FullName, FullName), 
            Email = ISNULL(@Email, Email), 
            EnrollmentNo = ISNULL(@EnrollmentNo, EnrollmentNo)
        WHERE UserId = @UserId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        -- Soft Delete
        UPDATE Users SET IsActive = 0 WHERE UserId = @UserId;
    END
END
GO




--  Technologies Table (Master SPs)

-- 1. SELECTION SP
CREATE PROCEDURE sp_select_technologies
    @Action NVARCHAR(20),       -- 'ALL', 'BY_ID'
    @TechId INT = NULL
AS
BEGIN
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Technologies ORDER BY TechName;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT * FROM Technologies WHERE TechId = @TechId;
    END
END
GO

-- 2. CRUD SP
CREATE PROCEDURE sp_crud_technologies
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE', 'DELETE'
    @TechId INT = NULL,
    @TechName NVARCHAR(50) = NULL
AS
BEGIN
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Technologies (TechName) VALUES (@TechName);
    END
    ELSE IF @Action = 'UPDATE'
    BEGIN
        UPDATE Technologies SET TechName = @TechName WHERE TechId = @TechId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Technologies WHERE TechId = @TechId;
    END
END
GO


--- Groups Table (Master SPs)
-- 1. SELECTION SP
CREATE PROCEDURE sp_select_groups
    @Action NVARCHAR(20),       -- 'ALL', 'BY_ID', 'FULL_DETAILS', 'BY_MENTOR'
    @GroupId INT = NULL,
    @MentorId INT = NULL
AS
BEGIN
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Groups;
    END
    ELSE IF @Action = 'BY_ID'
    BEGIN
        SELECT * FROM Groups WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'BY_MENTOR'
    BEGIN
        SELECT * FROM Groups WHERE MentorId = @MentorId;
    END
    ELSE IF @Action = 'FULL_DETAILS'
    BEGIN
        -- The complex aggregated report query
        SELECT 
            g.GroupName, Leader.FullName AS LeaderName, ISNULL(Mentor.FullName, 'Not Assigned') AS MentorName,
            STRING_AGG(Member.FullName, ', ') AS AllMembers
        FROM Groups g
        INNER JOIN Users Leader ON g.LeaderId = Leader.UserId
        LEFT JOIN Users Mentor ON g.MentorId = Mentor.UserId
        LEFT JOIN GroupMembers gm ON g.GroupId = gm.GroupId AND gm.JoinStatus = 'Accepted'
        LEFT JOIN Users Member ON gm.UserId = Member.UserId
        GROUP BY g.GroupName, Leader.FullName, Mentor.FullName;
    END
END
GO

-- 2. CRUD SP
CREATE PROCEDURE sp_crud_groups
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE_STATUS', 'ASSIGN_MENTOR', 'DELETE'
    @GroupId INT = NULL,
    @GroupName NVARCHAR(100) = NULL,
    @LeaderId INT = NULL,
    @TechId INT = NULL,
    @MentorId INT = NULL,
    @Status NVARCHAR(30) = NULL
AS
BEGIN
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Groups (GroupName, LeaderId, TechId, Status)
        VALUES (@GroupName, @LeaderId, @TechId, 'Forming');
        
        -- Auto add leader to members table
        DECLARE @NewGroupId INT = SCOPE_IDENTITY();
        INSERT INTO GroupMembers (GroupId, UserId, JoinStatus) VALUES (@NewGroupId, @LeaderId, 'Accepted');
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE Groups SET Status = @Status WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'ASSIGN_MENTOR'
    BEGIN
        UPDATE Groups SET MentorId = @MentorId, Status = 'Pending Faculty Approval' WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Groups WHERE GroupId = @GroupId;
    END
END
GO


-- Projects Table (Master SPs)

-- 1. SELECTION SP
CREATE PROCEDURE sp_select_projects
    @Action NVARCHAR(20),       -- 'BY_GROUP', 'BY_STATUS', 'ALL'
    @ProjectId INT = NULL,
    @GroupId INT = NULL,
    @Status NVARCHAR(15) = NULL
AS
BEGIN
    IF @Action = 'ALL'
    BEGIN
        SELECT * FROM Projects;
    END
    ELSE IF @Action = 'BY_GROUP'
    BEGIN
        SELECT * FROM Projects WHERE GroupId = @GroupId;
    END
    ELSE IF @Action = 'BY_STATUS'
    BEGIN
        SELECT * FROM Projects WHERE Status = @Status;
    END
END
GO

-- 2. CRUD SP
CREATE PROCEDURE sp_crud_projects
    @Action NVARCHAR(20),       -- 'INSERT', 'UPDATE_STATUS', 'DELETE'
    @ProjectId INT = NULL,
    @GroupId INT = NULL,
    @ProjectType CHAR(3) = NULL,
    @ProjectTitle NVARCHAR(150) = NULL,
    @NormalizedTitle NVARCHAR(150) = NULL,
    @Functionality NVARCHAR(1000) = NULL,
    @Status NVARCHAR(15) = NULL
AS
BEGIN
    IF @Action = 'INSERT'
    BEGIN
        INSERT INTO Projects (GroupId, ProjectType, ProjectTitle, NormalizedTitle, Functionality, Status)
        VALUES (@GroupId, @ProjectType, @ProjectTitle, @NormalizedTitle, @Functionality, 'Pending');
    END
    ELSE IF @Action = 'UPDATE_STATUS'
    BEGIN
        UPDATE Projects SET Status = @Status WHERE ProjectId = @ProjectId;
    END
    ELSE IF @Action = 'DELETE'
    BEGIN
        DELETE FROM Projects WHERE ProjectId = @ProjectId;
    END
END
GO

