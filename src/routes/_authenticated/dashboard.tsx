import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { useServerFn } from "@tanstack/react-start";
import { useState } from "react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { supabase } from "@/integrations/supabase/client";
import { createStaffAccount, getMyAccount, listMyStaff } from "@/lib/account.functions";

export const Route = createFileRoute("/_authenticated/dashboard")({
  head: () => ({
    meta: [
      { title: "لوحة التحكم — الحسابات والأدوار" },
      { name: "description", content: "إدارة الحساب والأدوار وإنشاء حسابات الموظفين." },
      { property: "og:title", content: "لوحة التحكم — الحسابات والأدوار" },
      { property: "og:description", content: "إدارة الحساب والأدوار وإنشاء حسابات الموظفين." },
    ],
  }),
  component: Dashboard,
});

const ROLE_LABELS: Record<string, string> = {
  admin: "مدير النظام",
  admin_staff: "موظف إدارة",
  user: "مستخدم",
  user_staff: "موظف تابع للمستخدم",
};

function Dashboard() {
  const navigate = useNavigate();
  const queryClient = useQueryClient();

  const fetchAccount = useServerFn(getMyAccount);
  const fetchStaff = useServerFn(listMyStaff);
  const createStaff = useServerFn(createStaffAccount);

  const account = useQuery({ queryKey: ["account"], queryFn: () => fetchAccount() });
  const staff = useQuery({ queryKey: ["staff"], queryFn: () => fetchStaff() });

  const roles = account.data?.roles ?? [];
  const isAdmin = roles.includes("admin");
  const isUser = roles.includes("user");
  const canCreate = isAdmin || isUser;

  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [role, setRole] = useState("user_staff");

  const mutation = useMutation({
    mutationFn: () => createStaff({ data: { email, password, fullName, role: role as never } }),
    onSuccess: () => {
      toast.success("تم إنشاء الحساب");
      setEmail("");
      setPassword("");
      setFullName("");
      queryClient.invalidateQueries({ queryKey: ["staff"] });
    },
    onError: (error: Error) => toast.error(error.message),
  });

  async function signOut() {
    await queryClient.cancelQueries();
    queryClient.clear();
    await supabase.auth.signOut();
    navigate({ to: "/auth", replace: true });
  }

  const createOptions = isAdmin
    ? ["admin", "admin_staff", "user", "user_staff"]
    : ["user_staff"];

  return (
    <div className="min-h-screen bg-muted/20 px-4 py-8">
      <div className="mx-auto max-w-3xl space-y-6">
        <div className="flex items-center justify-between">
          <h1 className="text-2xl font-bold">لوحة التحكم</h1>
          <Button variant="outline" onClick={signOut}>
            تسجيل الخروج
          </Button>
        </div>

        <Card>
          <CardHeader>
            <CardTitle>حسابي</CardTitle>
          </CardHeader>
          <CardContent className="space-y-1 text-sm">
            <p>الاسم: {account.data?.profile?.full_name || "—"}</p>
            <p dir="ltr" className="text-start">
              {account.data?.profile?.email ?? ""}
            </p>
            <p>
              الدور:{" "}
              {roles.length ? roles.map((r) => ROLE_LABELS[r] ?? r).join("، ") : "—"}
            </p>
          </CardContent>
        </Card>

        {canCreate && (
          <Card>
            <CardHeader>
              <CardTitle>إنشاء حساب موظف</CardTitle>
            </CardHeader>
            <CardContent>
              <form
                className="grid gap-3 sm:grid-cols-2"
                onSubmit={(e) => {
                  e.preventDefault();
                  mutation.mutate();
                }}
              >
                <Input
                  placeholder="الاسم الكامل"
                  value={fullName}
                  onChange={(e) => setFullName(e.target.value)}
                  required
                />
                <Input
                  type="email"
                  dir="ltr"
                  placeholder="البريد الإلكتروني"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  required
                />
                <Input
                  type="password"
                  dir="ltr"
                  placeholder="كلمة المرور"
                  minLength={6}
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  required
                />
                <select
                  className="h-9 rounded-md border border-input bg-background px-3 text-sm"
                  value={role}
                  onChange={(e) => setRole(e.target.value)}
                >
                  {createOptions.map((r) => (
                    <option key={r} value={r}>
                      {ROLE_LABELS[r]}
                    </option>
                  ))}
                </select>
                <Button type="submit" disabled={mutation.isPending} className="sm:col-span-2">
                  {mutation.isPending ? "جارٍ الإنشاء..." : "إنشاء الحساب"}
                </Button>
              </form>
            </CardContent>
          </Card>
        )}

        <Card>
          <CardHeader>
            <CardTitle>الحسابات التابعة لي</CardTitle>
          </CardHeader>
          <CardContent className="space-y-2 text-sm">
            {staff.isLoading && <p className="text-muted-foreground">جارٍ التحميل...</p>}
            {!staff.isLoading && (staff.data?.length ?? 0) === 0 && (
              <p className="text-muted-foreground">لا توجد حسابات بعد.</p>
            )}
            {staff.data?.map((person) => (
              <div key={person.id} className="flex items-center justify-between rounded-md border p-3">
                <span>{person.full_name || "—"}</span>
                <span dir="ltr" className="text-muted-foreground">
                  {person.email}
                </span>
              </div>
            ))}
          </CardContent>
        </Card>
      </div>
    </div>
  );
}
