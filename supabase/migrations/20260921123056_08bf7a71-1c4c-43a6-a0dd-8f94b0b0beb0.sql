-- =========================
-- PART 2: FOREIGN KEYS
-- =========================

-- projects self/cross links
ALTER TABLE public.projects
  ADD CONSTRAINT projects_description_id_fkey FOREIGN KEY (description_id) REFERENCES public.project_description(id) ON DELETE SET NULL,
  ADD CONSTRAINT projects_current_task_id_fkey FOREIGN KEY (current_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL,
  ADD CONSTRAINT projects_active_constitution_id_fkey FOREIGN KEY (active_constitution_id) REFERENCES public.constitutions(id) ON DELETE SET NULL;

-- project_id on every child table
ALTER TABLE public.artifacts ADD CONSTRAINT artifacts_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.checkpoints ADD CONSTRAINT checkpoints_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.constitution_rule_history ADD CONSTRAINT constitution_rule_history_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.constitution_rules ADD CONSTRAINT constitution_rules_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.constitution_sections ADD CONSTRAINT constitution_sections_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.constitutions ADD CONSTRAINT constitutions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.execution_logs ADD CONSTRAINT execution_logs_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.execution_position ADD CONSTRAINT execution_position_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.phases ADD CONSTRAINT phases_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.project_decisions ADD CONSTRAINT project_decisions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.project_description ADD CONSTRAINT project_description_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.project_description_history ADD CONSTRAINT project_description_history_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.project_execution_summary ADD CONSTRAINT project_execution_summary_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.resume_packages ADD CONSTRAINT resume_packages_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.state_conflicts ADD CONSTRAINT state_conflicts_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_artifacts ADD CONSTRAINT task_artifacts_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_changes ADD CONSTRAINT task_changes_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_constitution_rules ADD CONSTRAINT task_constitution_rules_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_cycles ADD CONSTRAINT task_cycles_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_dependencies ADD CONSTRAINT task_dependencies_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_executions ADD CONSTRAINT task_executions_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.task_relations ADD CONSTRAINT task_relations_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;
ALTER TABLE public.tasks ADD CONSTRAINT tasks_project_id_fkey FOREIGN KEY (project_id) REFERENCES public.projects(id) ON DELETE CASCADE;

-- tasks internal links
ALTER TABLE public.tasks
  ADD CONSTRAINT tasks_phase_id_fkey FOREIGN KEY (phase_id) REFERENCES public.phases(id) ON DELETE SET NULL,
  ADD CONSTRAINT tasks_parent_task_id_fkey FOREIGN KEY (parent_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;

-- task_cycles / task_executions
ALTER TABLE public.task_cycles ADD CONSTRAINT task_cycles_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;
ALTER TABLE public.task_executions
  ADD CONSTRAINT task_executions_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT task_executions_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES public.task_cycles(id) ON DELETE SET NULL;

-- checkpoints
ALTER TABLE public.checkpoints
  ADD CONSTRAINT checkpoints_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT checkpoints_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES public.task_cycles(id) ON DELETE SET NULL,
  ADD CONSTRAINT checkpoints_execution_id_fkey FOREIGN KEY (execution_id) REFERENCES public.task_executions(id) ON DELETE SET NULL;

-- constitution structures
ALTER TABLE public.constitution_sections ADD CONSTRAINT constitution_sections_constitution_id_fkey FOREIGN KEY (constitution_id) REFERENCES public.constitutions(id) ON DELETE CASCADE;
ALTER TABLE public.constitution_rules
  ADD CONSTRAINT constitution_rules_section_id_fkey FOREIGN KEY (section_id) REFERENCES public.constitution_sections(id) ON DELETE SET NULL,
  ADD CONSTRAINT constitution_rules_constitution_id_fkey FOREIGN KEY (constitution_id) REFERENCES public.constitutions(id) ON DELETE CASCADE;
ALTER TABLE public.constitution_rule_history
  ADD CONSTRAINT constitution_rule_history_rule_id_fkey FOREIGN KEY (rule_id) REFERENCES public.constitution_rules(id) ON DELETE CASCADE,
  ADD CONSTRAINT constitution_rule_history_related_task_id_fkey FOREIGN KEY (related_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;

-- execution logs
ALTER TABLE public.execution_logs
  ADD CONSTRAINT execution_logs_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT execution_logs_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES public.task_cycles(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_logs_execution_id_fkey FOREIGN KEY (execution_id) REFERENCES public.task_executions(id) ON DELETE SET NULL;

-- execution position
ALTER TABLE public.execution_position
  ADD CONSTRAINT execution_position_current_phase_id_fkey FOREIGN KEY (current_phase_id) REFERENCES public.phases(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_position_current_task_id_fkey FOREIGN KEY (current_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_position_last_completed_task_id_fkey FOREIGN KEY (last_completed_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_position_last_checkpoint_id_fkey FOREIGN KEY (last_checkpoint_id) REFERENCES public.checkpoints(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_position_last_execution_id_fkey FOREIGN KEY (last_execution_id) REFERENCES public.task_executions(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_position_next_natural_task_id_fkey FOREIGN KEY (next_natural_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL,
  ADD CONSTRAINT execution_position_reopened_from_task_id_fkey FOREIGN KEY (reopened_from_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;

-- decisions
ALTER TABLE public.project_decisions
  ADD CONSTRAINT project_decisions_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE SET NULL,
  ADD CONSTRAINT project_decisions_superseded_by_fkey FOREIGN KEY (superseded_by) REFERENCES public.project_decisions(id) ON DELETE SET NULL;

-- summary
ALTER TABLE public.project_execution_summary ADD CONSTRAINT project_execution_summary_current_task_id_fkey FOREIGN KEY (current_task_id) REFERENCES public.tasks(id) ON DELETE SET NULL;

-- resume packages
ALTER TABLE public.resume_packages
  ADD CONSTRAINT resume_packages_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT resume_packages_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES public.task_cycles(id) ON DELETE SET NULL,
  ADD CONSTRAINT resume_packages_last_checkpoint_id_fkey FOREIGN KEY (last_checkpoint_id) REFERENCES public.checkpoints(id) ON DELETE SET NULL,
  ADD CONSTRAINT resume_packages_position_id_fkey FOREIGN KEY (position_id) REFERENCES public.execution_position(id) ON DELETE SET NULL;

-- conflicts
ALTER TABLE public.state_conflicts
  ADD CONSTRAINT state_conflicts_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE SET NULL,
  ADD CONSTRAINT state_conflicts_execution_id_fkey FOREIGN KEY (execution_id) REFERENCES public.task_executions(id) ON DELETE SET NULL;

-- task link tables
ALTER TABLE public.task_artifacts
  ADD CONSTRAINT task_artifacts_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT task_artifacts_artifact_id_fkey FOREIGN KEY (artifact_id) REFERENCES public.artifacts(id) ON DELETE CASCADE,
  ADD CONSTRAINT task_artifacts_cycle_id_fkey FOREIGN KEY (cycle_id) REFERENCES public.task_cycles(id) ON DELETE SET NULL;
ALTER TABLE public.task_changes ADD CONSTRAINT task_changes_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;
ALTER TABLE public.task_constitution_rules
  ADD CONSTRAINT task_constitution_rules_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT task_constitution_rules_rule_id_fkey FOREIGN KEY (rule_id) REFERENCES public.constitution_rules(id) ON DELETE CASCADE;
ALTER TABLE public.task_dependencies
  ADD CONSTRAINT task_dependencies_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT task_dependencies_depends_on_task_id_fkey FOREIGN KEY (depends_on_task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;
ALTER TABLE public.task_relations
  ADD CONSTRAINT task_relations_task_id_fkey FOREIGN KEY (task_id) REFERENCES public.tasks(id) ON DELETE CASCADE,
  ADD CONSTRAINT task_relations_related_task_id_fkey FOREIGN KEY (related_task_id) REFERENCES public.tasks(id) ON DELETE CASCADE;

-- helpful indexes on FK columns
CREATE INDEX IF NOT EXISTS idx_tasks_project_id ON public.tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_phase_id ON public.tasks(phase_id);
CREATE INDEX IF NOT EXISTS idx_checkpoints_task_id ON public.checkpoints(task_id);
CREATE INDEX IF NOT EXISTS idx_execution_logs_task_id ON public.execution_logs(task_id);
CREATE INDEX IF NOT EXISTS idx_resume_packages_task_id ON public.resume_packages(task_id);
CREATE INDEX IF NOT EXISTS idx_task_artifacts_task_id ON public.task_artifacts(task_id);
CREATE INDEX IF NOT EXISTS idx_constitution_rules_constitution_id ON public.constitution_rules(constitution_id);

-- =========================
-- PART 3: OWNERSHIP HELPER, GRANTS, RLS POLICIES, TRIGGERS
-- =========================

CREATE OR REPLACE FUNCTION public.is_project_owner(_project_id uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.projects p
    WHERE p.id = _project_id AND p.owner_id = auth.uid()
  )
$$;

-- grants (authenticated users only; RLS restricts rows)
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'projects','tasks','phases','artifacts','checkpoints','constitutions','constitution_sections',
    'constitution_rules','constitution_rule_history','execution_logs','execution_position',
    'project_decisions','project_description','project_description_history','project_execution_summary',
    'resume_packages','state_conflicts','task_artifacts','task_changes','task_constitution_rules',
    'task_cycles','task_dependencies','task_executions','task_relations'
  ]
  LOOP
    EXECUTE format('GRANT SELECT, INSERT, UPDATE, DELETE ON public.%I TO authenticated', t);
    EXECUTE format('GRANT ALL ON public.%I TO service_role', t);
    EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', t);
  END LOOP;
END $$;

-- projects: owner-scoped
CREATE POLICY "Owners manage their projects" ON public.projects
  FOR ALL TO authenticated
  USING (owner_id = auth.uid())
  WITH CHECK (owner_id = auth.uid());

-- all project-scoped tables
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
    EXECUTE format(
      'CREATE POLICY "Project owners manage %1$s" ON public.%1$I FOR ALL TO authenticated USING (public.is_project_owner(project_id)) WITH CHECK (public.is_project_owner(project_id))',
      t
    );
  END LOOP;
END $$;

-- updated_at triggers for remaining tables
DO $$
DECLARE t text;
BEGIN
  FOREACH t IN ARRAY ARRAY[
    'projects','tasks','constitution_rules','constitution_sections','execution_position',
    'project_decisions','project_description','project_execution_summary','resume_packages'
  ]
  LOOP
    EXECUTE format('DROP TRIGGER IF EXISTS trg_%1$s_touch ON public.%1$I', t);
    EXECUTE format('CREATE TRIGGER trg_%1$s_touch BEFORE UPDATE ON public.%1$I FOR EACH ROW EXECUTE FUNCTION public.touch_updated_at()', t);
  END LOOP;
END $$;