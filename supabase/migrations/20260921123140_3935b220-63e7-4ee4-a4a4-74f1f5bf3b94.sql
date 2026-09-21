-- replace helper-function policies with inline ownership checks
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'tasks','phases','artifacts','checkpoints','constitutions','constitution_sections',
    'constitution_rules','constitution_rule_history','execution_logs','execution_position',
    'project_decisions','project_description','project_description_history','project_execution_summary',
    'resume_packages','state_conflicts','task_artifacts','task_changes','task_constitution_rules',
    'task_cycles','task_dependencies','task_executions','task_relations'
  ]
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS "Project owners manage %1$s" ON public.%1$I', t);
    EXECUTE format(
      'CREATE POLICY "Project owners manage %1$s" ON public.%1$I FOR ALL TO authenticated USING (EXISTS (SELECT 1 FROM public.projects p WHERE p.id = %1$I.project_id AND p.owner_id = auth.uid())) WITH CHECK (EXISTS (SELECT 1 FROM public.projects p WHERE p.id = %1$I.project_id AND p.owner_id = auth.uid()))',
      t
    );
  END LOOP;
END $$;

DROP FUNCTION IF EXISTS public.is_project_owner(uuid);

-- internal maintenance function must not be callable through the API
REVOKE ALL ON FUNCTION public.rls_auto_enable() FROM PUBLIC, anon, authenticated;