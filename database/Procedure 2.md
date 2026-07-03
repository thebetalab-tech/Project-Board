# Project Board - CRUD Operations Guide

This document outlines the standard Create, Read, Update, and Delete (CRUD) Stored Procedures used to manage data across the Project Board platform. It is organized by the primary entities they affect.

---

## 1. User Management (Admin & Profiles)
These procedures handle the daily management of user accounts, ensuring data integrity without permanently deleting historical records.

* **`sp_GetUserById`**
  * **What it does:** Fetches the complete profile of a single user based on their unique ID.
  * **Use Case:** Loading a user's profile page or dashboard to display their Name, Role, Enrollment Number, and Leader status.

* **`sp_GetUsersByRole`**
  * **What it does:** Pulls a list of all *active* users belonging to a specific role (Student, Faculty, or Admin).
  * **Use Case:** Populating the Admin's "Manage Faculty" or "Manage Students" data grids.

* **`sp_UpdateUser`**
  * **What it does:** Updates a user's basic editable information. 
  * **Use Case:** Allowing a user to update their email address or fix a typo in their name/enrollment number via an "Edit Profile" screen.

* **`sp_DeactivateUser` (Soft Delete)**
  * **What it does:** Instead of erasing the user from the database (which would break past projects and groups), it flips their `IsActive` toggle to `0`.
  * **Use Case:** Suspending a student or removing a retired faculty member. They will immediately disappear from dropdowns and search results, but their past project records remain intact.

---

## 2. Technology Domains (Admin Panel)
These procedures control the centralized list of approved technologies that students can choose from.

* **`sp_AddTechnology`**
  * **What it does:** Inserts a new technology stack into the system (e.g., "MERN Stack", "Flutter").
  * **Use Case:** Admin adding a newly approved college technology for the upcoming semester.

* **`sp_GetAllTechnologies`**
  * **What it does:** Retrieves the complete, alphabetical list of available technologies.
  * **Use Case:** Populating the dropdown menu when a group leader is forming a team and picking their domain.

* **`sp_UpdateTechnology`**
  * **What it does:** Corrects the spelling or formatting of an existing technology name.
  * **Use Case:** Admin renaming "node js" to "Node.js" for consistency.

* **`sp_DeleteTechnology`**
  * **What it does:** Attempts to permanently remove a technology from the list.
  * **Safety Note:** The database's strict Foreign Keys will automatically block this action if any student group or faculty member is currently using this technology.

---

## 3. Faculty Domain Assignments (System Mapping)
These procedures map faculty members to the specific technologies they are qualified to mentor.

* **`sp_AssignFacultyTech`**
  * **What it does:** Creates a link between a specific Faculty ID and a specific Technology ID.
  * **Use Case:** Admin authorizing Prof. Smith to accept projects in the "Python" domain.

* **`sp_GetFacultyByTech`**
  * **What it does:** Looks up exactly which active faculty members are assigned to a given technology.
  * **Use Case:** After a group leader selects "ASP.NET", this procedure powers the next dropdown, showing only the professors who teach ASP.NET.

* **`sp_RemoveFacultyTech`**
  * **What it does:** Severs the link between a professor and a technology.
  * **Use Case:** A professor stops teaching Java; the admin removes this tag so no future Java groups can request them.

---

## 4. Group & Project Edits (Faculty & Leader Actions)
These handle the mid-lifecycle changes to groups and project proposals.

* **`sp_GetGroupById`**
  * **What it does:** Pulls the core structural data of a specific group (who the leader is, what tech they chose, who the mentor is, and their current phase).
  * **Use Case:** Loading the details for a specific group's control panel.

* **`sp_UpdateGroupStatus`**
  * **What it does:** Moves the group forward or backward in the lifecycle (e.g., 'Forming', 'Pending Faculty Approval', 'Active').
  * **Use Case:** The system calls this to lock a group's roster once they send a mentor request, or to unlock it if they are dropped.

* **`sp_RemoveGroupMember`**
  * **What it does:** Kicks a specific student out of a group.
  * **Use Case:** A group leader removing a teammate who isn't contributing, provided the group is still in the 'Forming' stage.

* **`sp_GetProjectByGroupId`**
  * **What it does:** Retrieves the submitted project proposal attached to a specific group.
  * **Use Case:** The faculty mentor clicking on a group to read their project's functionality and title.

* **`sp_UpdateProjectStatus`**
  * **What it does:** Changes the project's status to 'Approved', 'Rejected', or 'Pending'.
  * **Use Case:** The mentor clicking the "Approve" or "Reject" button on a submitted proposal.

---

## 5. Project Keywords (Duplicate Detection Engine)
These procedures power your custom anti-bypass and fuzzy-matching security features.

* **`sp_AddProjectKeyword`**
  * **What it does:** Attaches a highly specific domain keyword (e.g., "hospital", "inventory") to an approved project.
  * **Use Case:** Immediately after a mentor clicks "Approve", a popup asks them to tag the project. This procedure saves those tags.

* **`sp_GetKeywordsByTech`**
  * **What it does:** Pulls a massive list of all restricted keywords currently used by *Approved* projects within a specific technology domain.
  * **Use Case:** When a student starts typing a new project name, your C# backend calls this procedure, grabs the restricted words, and runs the Jaro-Winkler algorithm to see if the student's idea is too similar to past projects.

* **`sp_DeleteProjectKeyword`**
  * **What it does:** Removes a specific keyword tag.
  * **Use Case:** A mentor realizes they added a tag that was too broad (like "management") and needs to delete it so they don't accidentally block valid future projects.