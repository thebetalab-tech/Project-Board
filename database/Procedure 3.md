# Project Board - Master Stored Procedures Guide

This document outlines the **Master/Catch-All Stored Procedure Architecture** for the Project Board database. By utilizing an `@Action` parameter, this design reduces database clutter, consolidating dozens of standard queries into just two procedures per table: one for Selections (Read) and one for Actions (Create, Update, Delete).

## Architectural Note for C# Integration
All parameters in these procedures (except `@Action`) default to `NULL`. When calling these from your ASP.NET backend, you only need to pass the parameters required for that specific action. You do not need to pass blank values for the others.

---

## 1. Users Table Procedures

### `sp_select_users`
**Description:** Handles all data retrieval operations for the Users table.
* **`@Action = 'ALL'`**: Fetches all active users in the system.
* **`@Action = 'BY_ID'`**: Fetches a single user's complete profile. Requires `@UserId`.
* **`@Action = 'BY_ROLE'`**: Fetches all active users of a specific type. Requires `@Role` (e.g., 'Student', 'Faculty').

### `sp_crud_users`
**Description:** Handles all data manipulation operations for the Users table.
* **`@Action = 'INSERT'`**: Registers a new user. Requires `@FullName`, `@Email`, `@PasswordHash`, `@Role`, and optionally `@EnrollmentNo` and `@IsLeader`.
* **`@Action = 'UPDATE'`**: Edits an existing user's profile. Requires `@UserId` and the specific fields to update.
* **`@Action = 'DELETE'`**: Performs a soft-delete by setting `IsActive = 0`. Requires `@UserId`.

---

## 2. Technologies Table Procedures

### `sp_select_technologies`
**Description:** Handles all data retrieval for the approved college technology domains.
* **`@Action = 'ALL'`**: Retrieves the alphabetical list of all available technologies.
* **`@Action = 'BY_ID'`**: Retrieves a specific technology name. Requires `@TechId`.

### `sp_crud_technologies`
**Description:** Handles all data manipulation for technology domains (Admin only).
* **`@Action = 'INSERT'`**: Adds a new technology. Requires `@TechName`.
* **`@Action = 'UPDATE'`**: Renames an existing technology. Requires `@TechId` and `@TechName`.
* **`@Action = 'DELETE'`**: Permanently deletes a technology (fails if actively in use). Requires `@TechId`.

---

## 3. Groups Table Procedures

### `sp_select_groups`
**Description:** Handles all data retrieval for student project groups.
* **`@Action = 'ALL'`**: Fetches the base data for all groups.
* **`@Action = 'BY_ID'`**: Fetches base data for a single group. Requires `@GroupId`.
* **`@Action = 'BY_MENTOR'`**: Fetches all groups assigned to a specific faculty member. Requires `@MentorId`.
* **`@Action = 'FULL_DETAILS'`**: Executes the complex reporting query, returning Group Name, Leader, Mentor, and a comma-separated list of all accepted members.

### `sp_crud_groups`
**Description:** Handles the lifecycle management of student project groups.
* **`@Action = 'INSERT'`**: Creates a new group and automatically adds the creator as the accepted Leader. Requires `@GroupName`, `@LeaderId`, and `@TechId`.
* **`@Action = 'UPDATE_STATUS'`**: Changes the phase of the group (e.g., 'Forming', 'Active'). Requires `@GroupId` and `@Status`.
* **`@Action = 'ASSIGN_MENTOR'`**: Attaches a faculty member to the group and moves their status to 'Pending Faculty Approval'. Requires `@GroupId` and `@MentorId`.
* **`@Action = 'DELETE'`**: Permanently deletes a group. Requires `@GroupId`.

---

## 4. Projects Table Procedures

### `sp_select_projects`
**Description:** Handles all data retrieval for submitted project proposals.
* **`@Action = 'ALL'`**: Fetches all projects in the system.
* **`@Action = 'BY_GROUP'`**: Fetches the specific project proposal for a team. Requires `@GroupId`.
* **`@Action = 'BY_STATUS'`**: Fetches projects filtered by approval state (e.g., 'Pending', 'Approved'). Requires `@Status`.

### `sp_crud_projects`
**Description:** Handles the submission and status tracking of project proposals.
* **`@Action = 'INSERT'`**: Submits a new project for mentor review. Requires `@GroupId`, `@ProjectType`, `@ProjectTitle`, `@NormalizedTitle`, and `@Functionality`.
* **`@Action = 'UPDATE_STATUS'`**: Approves or Rejects a project. Requires `@ProjectId` and `@Status`.
* **`@Action = 'DELETE'`**: Removes a project proposal. Requires `@ProjectId`.

---
