
revoke all on function public.handle_new_user() from public, anon, authenticated;
revoke all on function public.has_role(uuid, public.app_role) from public, anon;
revoke all on function public.is_manager_of(uuid, uuid) from public, anon;
grant execute on function public.has_role(uuid, public.app_role) to authenticated, service_role;
grant execute on function public.is_manager_of(uuid, uuid) to authenticated, service_role;
revoke all on function public.get_minimal_task_context(uuid) from public, anon;
revoke all on function public.get_resume_message(uuid) from public, anon;
grant execute on function public.get_minimal_task_context(uuid) to authenticated, service_role;
grant execute on function public.get_resume_message(uuid) to authenticated, service_role;
