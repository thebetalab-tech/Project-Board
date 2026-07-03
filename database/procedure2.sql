-- READ: Get a single user by ID
GO
CREATE PROCEDURE sp_GetUserById
    @UserId INT
AS
BEGIN
    SELECT UserId, FullName, Email, EnrollmentNo, Role, IsActive, CreatedAt, IsLeader
    FROM Users
    WHERE UserId = @UserId;
END
GO

-- READ: Get all active users by Role (Useful for Admin grids)
CREATE PROCEDURE sp_GetUsersByRole
    @Role NVARCHAR(10)
AS
BEGIN
    SELECT UserId, FullName, Email, EnrollmentNo, IsActive, IsLeader
    FROM Users
    WHERE Role = @Role AND IsActive = 1
    ORDER BY FullName;
END
GO

-- UPDATE: Update basic user details
CREATE PROCEDURE sp_UpdateUser
    @UserId INT,
    @FullName NVARCHAR(100),
    @Email NVARCHAR(100),
    @EnrollmentNo NVARCHAR(20) = NULL
AS
BEGIN
    UPDATE Users
    SET FullName = @FullName, 
        Email = @Email, 
        EnrollmentNo = @EnrollmentNo
    WHERE UserId = @UserId;
END
GO

-- DELETE: Soft Delete (Deactivate) a User
CREATE PROCEDURE sp_DeactivateUser
    @UserId INT
AS
BEGIN
    UPDATE Users
    SET IsActive = 0
    WHERE UserId = @UserId;
END
GO



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////


-- CREATE: Add a new technology
CREATE PROCEDURE sp_AddTechnology
    @TechName NVARCHAR(50)
AS
BEGIN
    INSERT INTO Technologies (TechName)
    VALUES (@TechName);
END
GO

-- READ: Get all technologies (For dropdowns)
CREATE PROCEDURE sp_GetAllTechnologies
AS
BEGIN
    SELECT TechId, TechName
    FROM Technologies
    ORDER BY TechName;
END
GO

-- UPDATE: Rename a technology
CREATE PROCEDURE sp_UpdateTechnology
    @TechId INT,
    @TechName NVARCHAR(50)
AS
BEGIN
    UPDATE Technologies
    SET TechName = @TechName
    WHERE TechId = @TechId;
END
GO

-- DELETE: Remove a technology (Note: Will fail if groups/faculty are still linked to it)
CREATE PROCEDURE sp_DeleteTechnology
    @TechId INT
AS
BEGIN
    DELETE FROM Technologies
    WHERE TechId = @TechId;
END
GO




/---------------------------------------------------------------------------------------------

-- CREATE: Assign a technology to a faculty mentor
CREATE PROCEDURE sp_AssignFacultyTech
    @FacultyId INT,
    @TechId INT
AS
BEGIN
    INSERT INTO Faculty (FacultyId, TechId)
    VALUES (@FacultyId, @TechId);
END
GO

-- READ: Get all Faculty who mentor a specific Technology (For Student Mentor Selection)
CREATE PROCEDURE sp_GetFacultyByTech
    @TechId INT
AS
BEGIN
    SELECT u.UserId AS FacultyId, u.FullName, u.Email
    FROM Users u
    INNER JOIN Faculty f ON u.UserId = f.FacultyId
    WHERE f.TechId = @TechId AND u.IsActive = 1;
END
GO

-- DELETE: Remove a technology assignment from a mentor
CREATE PROCEDURE sp_RemoveFacultyTech
    @FacultyId INT,
    @TechId INT
AS
BEGIN
    DELETE FROM Faculty
    WHERE FacultyId = @FacultyId AND TechId = @TechId;
END
GO



/------------------------------------------------------------------------------------------------/


-- READ: Get a specific Group's details by its ID
CREATE PROCEDURE sp_GetGroupById
    @GroupId INT
AS
BEGIN
    SELECT GroupId, GroupName, LeaderId, TechId, MentorId, Status
    FROM Groups
    WHERE GroupId = @GroupId;
END
GO

-- UPDATE: Update Group Status (e.g., from 'Forming' to 'Active')
CREATE PROCEDURE sp_UpdateGroupStatus
    @GroupId INT,
    @NewStatus NVARCHAR(30)
AS
BEGIN
    UPDATE Groups
    SET Status = @NewStatus
    WHERE GroupId = @GroupId;
END
GO

-- DELETE: Remove a member from a group (Leader action before final submission)
CREATE PROCEDURE sp_RemoveGroupMember
    @GroupId INT,
    @UserId INT
AS
BEGIN
    DELETE FROM GroupMembers
    WHERE GroupId = @GroupId AND UserId = @UserId;
END
GO

-- READ: Get a Project by Group ID
CREATE PROCEDURE sp_GetProjectByGroupId
    @GroupId INT
AS
BEGIN
    SELECT ProjectId, ProjectType, ProjectTitle, Functionality, Status, SubmittedAt
    FROM Projects
    WHERE GroupId = @GroupId;
END
GO

-- UPDATE: Update Project Status (Mentor Action: Approve or Reject)
CREATE PROCEDURE sp_UpdateProjectStatus
    @ProjectId INT,
    @Status NVARCHAR(15)
AS
BEGIN
    UPDATE Projects
    SET Status = @Status
    WHERE ProjectId = @ProjectId;
END
GO









/----------------------------------------------------------------------------------------------------/

-- CREATE: Add a keyword tag to an approved project
CREATE PROCEDURE sp_AddProjectKeyword
    @ProjectId INT,
    @Keyword NVARCHAR(30)
AS
BEGIN
    INSERT INTO ProjectKeywords (ProjectId, Keyword)
    VALUES (@ProjectId, @Keyword);
END
GO

-- READ: Get all keywords for a specific technology domain (Used by C# for fuzzy matching)
CREATE PROCEDURE sp_GetKeywordsByTech
    @TechId INT
AS
BEGIN
    SELECT pk.Keyword, p.ProjectTitle
    FROM ProjectKeywords pk
    INNER JOIN Projects p ON pk.ProjectId = p.ProjectId
    WHERE p.TechId = @TechId AND p.Status = 'Approved';
END
GO

-- DELETE: Remove a keyword tag (Admin correction)
CREATE PROCEDURE sp_DeleteProjectKeyword
    @TagId INT
AS
BEGIN
    DELETE FROM ProjectKeywords
    WHERE TagId = @TagId;
END
GO


