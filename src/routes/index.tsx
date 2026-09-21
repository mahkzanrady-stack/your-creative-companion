import { createFileRoute, Link } from "@tanstack/react-router";

import { Button } from "@/components/ui/button";

export const Route = createFileRoute("/")({
  head: () => ({
    meta: [
      { title: "الصفحة الرئيسية" },
      {
        name: "description",
        content: "منصة إدارة الحسابات والصلاحيات: تسجيل الدخول وإدارة حسابات الموظفين.",
      },
      { property: "og:title", content: "الصفحة الرئيسية" },
      {
        property: "og:description",
        content: "منصة إدارة الحسابات والصلاحيات: تسجيل الدخول وإدارة حسابات الموظفين.",
      },
    ],
  }),
  component: Index,
});

function Index() {
  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/20 px-4">
      <div className="max-w-xl text-center">
        <h1 className="text-3xl font-bold">ذاكرة تنفيذ المشاريع</h1>
        <div className="mt-6 flex justify-center">
          <Button asChild>
            <Link to="/auth">تسجيل الدخول</Link>
          </Button>
        </div>
      </div>
    </div>
  );
}

