# Infrastructure Document (internal — never surface in the UI)

> This is NOT a project. It is the infrastructure layer that precedes any
> project. A project — with its own constitution — begins only when the owner
> provides a project description and it is converted into execution phases.

## Purpose
Any executor (Lovable, vibe-coding tool, or developer) entering mid-task can
read this to know the foundation that already exists — without re-discovering,
repeating, or conflicting with prior work.

## Infrastructure ready (do not rebuild)
- Supabase email/password auth; signup requires full name; auto profile trigger.
- Roles enum: admin, admin_staff, user, user_staff — stored ONLY in `user_roles` table.
- Staff never self-register: managers create staff from /dashboard (createStaffAccount, server-verified via has_role).
- profiles.manager_id links staff to manager; RLS: self row, manager sees staff, admin/admin_staff see all.
- Pages: `/` home, `/auth` login/signup, `/dashboard` (protected). UI Arabic RTL.

## What comes next (not infrastructure)
1. Owner provides a project description.
2. That description is converted into sequential execution phases and steps.
3. A project-specific constitution (red lines) is created for that project.
4. Only then does building the project begin.

## For any new executor entering
Read this first. It describes the infrastructure only — no project, no constitution.
Ask the owner: "What is your project description?" Do not invent modules or start
building before the owner defines the project.
