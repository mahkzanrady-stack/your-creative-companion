# Infrastructure & Governance Document (internal — never surface in the UI)

> This is NOT a project. It is the infrastructure and governance layer that
> precedes any project and governs how any project built on top is executed.
> No project has started yet — the infrastructure is ready; a project begins
> only when the owner provides a project description.

## Purpose
Any executor (Lovable, vibe-coding tool, or developer) entering mid-task can
read this to know the foundation that already exists and the red lines that
govern everything built on it — without re-discovering, repeating, or
conflicting with prior work.

## Infrastructure ready (do not rebuild)
- Supabase email/password auth; signup requires full name; auto profile trigger.
- Roles enum: admin, admin_staff, user, user_staff — stored ONLY in `user_roles` table.
- Staff never self-register: managers create staff from /dashboard (createStaffAccount, server-verified via has_role).
- profiles.manager_id links staff to manager; RLS: self row, manager sees staff, admin/admin_staff see all.
- Pages: `/` home, `/auth` login/signup, `/dashboard` (protected). UI Arabic RTL.

## Constitution (red lines — govern every project on this infrastructure)
1. Roles only in user_roles table. 2. No staff self-registration. 3. Server-side permission checks only.
4. New roles need owner decision. 5. Arabic RTL UI. 6. This file never referenced in the UI. 7. RLS + GRANT on every table.

## Current state / next step
- Infrastructure is complete and stable. No project has started yet.
- Owner account still role `user` — needs upgrade to `admin` before a project begins.
- Next: owner provides a project description; that description becomes the first project built on this infrastructure.

## For any new executor entering
Read this first. It describes the infrastructure and the governance — not a project.
Ask the owner: "What is your project description?" Do not invent modules or start
building before the owner defines the project. Update this file after each milestone.
