CREATE OR REPLACE FUNCTION public.get_resume_message(_project_id uuid)
RETURNS text
LANGUAGE plpgsql
STABLE
SET search_path = public
AS $$
DECLARE
  p record;
  pos record;
  cur record;
  ph record;
  lastc record;
  chk record;
  nxt record;
  rp record;
  blockers text;
  affected text;
  msg text;
BEGIN
  SELECT * INTO p FROM public.projects WHERE id = _project_id;
  IF NOT FOUND THEN
    RETURN 'PROJECT RESUME POSITION' || E'\n\n' || 'لا يوجد مشروع بهذا المعرف.';
  END IF;

  SELECT * INTO pos FROM public.execution_position
   WHERE project_id = _project_id AND is_active
   ORDER BY updated_at DESC LIMIT 1;

  -- نقطة الاستئناف: أولوية in_progress ثم reopened ثم blocked ثم verify ثم ما هو مسجل
  SELECT * INTO cur FROM public.tasks
   WHERE project_id = _project_id AND deleted_at IS NULL
     AND status IN ('in_progress','reopened','blocked','verify')
   ORDER BY CASE status
       WHEN 'in_progress' THEN 1
       WHEN 'reopened' THEN 2
       WHEN 'verify' THEN 3
       WHEN 'blocked' THEN 4 END,
     priority DESC, updated_at DESC
   LIMIT 1;

  IF cur IS NULL AND pos.current_task_id IS NOT NULL THEN
    SELECT * INTO cur FROM public.tasks WHERE id = pos.current_task_id;
  END IF;

  IF cur.phase_id IS NOT NULL THEN
    SELECT * INTO ph FROM public.phases WHERE id = cur.phase_id;
  ELSIF pos.current_phase_id IS NOT NULL THEN
    SELECT * INTO ph FROM public.phases WHERE id = pos.current_phase_id;
  END IF;

  SELECT * INTO lastc FROM public.tasks
   WHERE project_id = _project_id AND status = 'completed' AND deleted_at IS NULL
   ORDER BY completed_at DESC NULLS LAST, updated_at DESC LIMIT 1;

  IF cur.id IS NOT NULL THEN
    SELECT * INTO chk FROM public.checkpoints
     WHERE task_id = cur.id ORDER BY created_at DESC LIMIT 1;
    SELECT * INTO rp FROM public.resume_packages
     WHERE task_id = cur.id AND is_active ORDER BY updated_at DESC LIMIT 1;
  END IF;

  -- المهمة الطبيعية التالية
  IF pos.next_natural_task_id IS NOT NULL THEN
    SELECT * INTO nxt FROM public.tasks WHERE id = pos.next_natural_task_id;
  ELSE
    SELECT t.* INTO nxt FROM public.tasks t
      LEFT JOIN public.phases f ON f.id = t.phase_id
     WHERE t.project_id = _project_id AND t.deleted_at IS NULL
       AND t.status = 'pending'
       AND (cur.id IS NULL OR t.id <> cur.id)
       AND NOT EXISTS (
         SELECT 1 FROM public.task_dependencies d
           JOIN public.tasks dt ON dt.id = d.depends_on_task_id
          WHERE d.task_id = t.id AND dt.status <> 'completed')
     ORDER BY COALESCE(f.sort_order, 2147483647), t.priority DESC, t.created_at
     LIMIT 1;
  END IF;

  blockers := COALESCE(NULLIF(pos.blocked_by,''), NULLIF(cur.notes, ''));

  SELECT string_agg(dt.code || ' — ' || dt.title, E'\n') INTO affected
    FROM public.tasks dt
   WHERE dt.project_id = _project_id AND dt.deleted_at IS NULL
     AND cur.id IS NOT NULL
     AND dt.id = ANY (SELECT unnest(COALESCE(pos.affected_later_tasks, '{}'::text[]))::uuid);

  msg :=
    'PROJECT RESUME POSITION' || E'\n\n' ||
    'المشروع: ' || p.name || E'\n\n' ||
    'أين نحن؟' || E'\n' || COALESCE(ph.title, 'لم تُحدد مرحلة') || E'\n\n' ||
    'المهمة الحالية:' || E'\n' || COALESCE(COALESCE(cur.code || ' — ', '') || cur.title, 'لا توجد مهمة مفتوحة') || E'\n\n' ||
    'حالة المهمة:' || E'\n' || COALESCE(upper(cur.status::text), '—') || E'\n\n' ||
    'لماذا نحن هنا؟' || E'\n' || COALESCE(pos.resume_reason::text,
        CASE cur.status
          WHEN 'in_progress' THEN 'OPEN_TASK'
          WHEN 'reopened' THEN 'REOPENED_TASK'
          WHEN 'blocked' THEN 'BLOCKED_TASK'
          ELSE 'NEW_TASK' END) || E'\n\n' ||
    'آخر مهمة مكتملة:' || E'\n' || COALESCE(COALESCE(lastc.code || ' — ', '') || lastc.title, 'لا يوجد') || E'\n\n' ||
    'ما تم:' || E'\n' || COALESCE(NULLIF(rp.completed,''), NULLIF(chk.done_summary,''), NULLIF(pos.completed_work,''), 'غير مسجل') || E'\n\n' ||
    'ما تبقى:' || E'\n' || COALESCE(NULLIF(rp.remaining,''), NULLIF(chk.remaining,''), NULLIF(pos.remaining_work,''), 'غير مسجل') || E'\n\n' ||
    'آخر Checkpoint:' || E'\n' || COALESCE(chk.last_successful_step || ' (' || to_char(chk.created_at,'YYYY-MM-DD HH24:MI') || ')', 'لا يوجد') || E'\n\n' ||
    'Last Known Good State:' || E'\n' || COALESCE(NULLIF(rp.last_known_good_state,''), NULLIF(cur.last_known_good_state,''), NULLIF(pos.last_known_good_state,''), 'غير مسجل') || E'\n\n' ||
    'Next Action:' || E'\n' || COALESCE(NULLIF(rp.next_action,''), NULLIF(chk.next_action,''), NULLIF(cur.next_action,''), NULLIF(pos.next_action,''), 'غير محدد — يحدده المستخدم') || E'\n\n' ||
    'Next Natural Task:' || E'\n' || COALESCE(COALESCE(nxt.code || ' — ', '') || nxt.title, 'لا يوجد') || E'\n\n' ||
    'قاعدة الاستئناف:' || E'\n' ||
      CASE
        WHEN cur.id IS NULL THEN 'لا توجد مهمة مفتوحة. اعرض المهمة الطبيعية التالية وانتظر إذن المستخدم. لا تبدأ تلقائيًا.'
        WHEN cur.status = 'blocked' THEN 'المهمة محجوبة: ' || COALESCE(blockers,'السبب غير مسجل') || '. لا تتجاوزها ولا تنشئ مسارًا بديلًا.'
        WHEN cur.status = 'reopened' THEN 'هذه المهمة كانت مكتملة ثم أُعيد فتحها، فهي نقطة التنفيذ الحالية حتى لو وُجدت مهام لاحقة مكتملة. أكملها وتحقق منها قبل الانتقال.'
        WHEN cur.status = 'verify' THEN 'المهمة في مرحلة التحقق. أكمل التحقق وسجل النتائج قبل الإغلاق.'
        ELSE 'المهمة مفتوحة. أكملها من Next Action ولا تنتقل إلى المهمة التالية.'
      END || E'\n\n' ||
    'المهام اللاحقة المتأثرة:' || E'\n' || COALESCE(affected, 'لا يوجد');

  RETURN msg;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.get_resume_message(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.get_resume_message(uuid) TO authenticated, service_role;
