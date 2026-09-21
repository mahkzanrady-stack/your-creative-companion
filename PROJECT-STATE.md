# Project State & Constitution (internal — never surface in the UI)

## Built foundation (do not rebuild)
- Supabase email/password auth; signup requires full name; auto profile trigger.
- Roles enum: admin, admin_staff, user, user_staff — stored ONLY in `user_roles` table.
- Staff never self-register: managers create staff from /dashboard (createStaffAccount, server-verified via has_role).
- profiles.manager_id links staff to manager; RLS: self row, manager sees staff, admin/admin_staff see all.
- Pages: `/` home, `/auth` login/signup, `/dashboard` (protected). UI Arabic RTL.

## Constitution (red lines)
1. Roles only in user_roles table. 2. No staff self-registration. 3. Server-side permission checks only.
4. New roles need owner decision. 5. Arabic RTL UI. 6. This file never referenced in the UI. 7. RLS + GRANT on every table.

## Current state / next step
- Owner account still role `user` — needs upgrade to `admin`.
- No per-role dashboards yet. Next: owner's project description, then build modules per role.

## For any new agent entering this project
Read this first. Ask the owner: "What is your project description?" Update this file after each milestone.
