-- 1. artifact_kind: add integration
ALTER TYPE public.artifact_kind ADD VALUE IF NOT EXISTS 'integration';

-- 2. task_status: add verify
ALTER TYPE public.task_status ADD VALUE IF NOT EXISTS 'verify';

-- 3. project_description.updated_by
ALTER TABLE public.project_description ADD COLUMN IF NOT EXISTS updated_by text;

-- 4. de-duplicate rule severity: keep category + severity_level
UPDATE public.constitution_rules
SET category = CASE severity
    WHEN 'red_line' THEN 'red_line'::public.rule_category
    WHEN 'caution' THEN 'warning'::public.rule_category
    WHEN 'recommendation' THEN 'recommendation'::public.rule_category
    WHEN 'execution_rule' THEN 'execution_rule'::public.rule_category
    WHEN 'verification_rule' THEN 'verification_rule'::public.rule_category
  END
WHERE category IS NULL;

UPDATE public.constitution_rules SET severity_level = 'normal' WHERE severity_level IS NULL;

ALTER TABLE public.constitution_rules
  ALTER COLUMN category SET DEFAULT 'recommendation'::public.rule_category,
  ALTER COLUMN severity_level SET DEFAULT 'normal'::public.rule_severity_level;

ALTER TABLE public.constitution_rules ALTER COLUMN category SET NOT NULL;
ALTER TABLE public.constitution_rules ALTER COLUMN severity_level SET NOT NULL;

ALTER TABLE public.constitution_rules DROP COLUMN severity;

-- 5. decisions: document/stabilise supersede direction
COMMENT ON COLUMN public.project_decisions.superseded_by IS 'القرار الذي ألغى هذا القرار (اتجاه: أُلغي بواسطة)';
CREATE INDEX IF NOT EXISTS idx_project_decisions_superseded_by ON public.project_decisions(superseded_by);
