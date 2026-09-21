import { createFileRoute, useNavigate } from "@tanstack/react-router";
import { useEffect, useState } from "react";
import { toast } from "sonner";

import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { supabase } from "@/integrations/supabase/client";

export const Route = createFileRoute("/auth")({
  ssr: false,
  head: () => ({
    meta: [
      { title: "تسجيل الدخول — ذاكرة التنفيذ" },
      { name: "description", content: "الدخول إلى لوحة إدارة ذاكرة تنفيذ المشاريع." },
      { property: "og:title", content: "تسجيل الدخول — ذاكرة التنفيذ" },
      { property: "og:description", content: "الدخول إلى لوحة إدارة ذاكرة تنفيذ المشاريع." },
    ],
  }),
  component: AuthPage,
});

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <label className="block space-y-1.5">
      <span className="text-xs text-muted-foreground">{label}</span>
      {children}
    </label>
  );
}

function AuthPage() {
  const navigate = useNavigate();
  const [mode, setMode] = useState<"signin" | "signup">("signin");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [fullName, setFullName] = useState("");
  const [busy, setBusy] = useState(false);

  useEffect(() => {
    supabase.auth.getSession().then(({ data }) => {
      if (data.session) navigate({ to: "/dashboard" });
    });
  }, [navigate]);

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    setBusy(true);
    try {
      if (mode === "signup") {
        const { error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            emailRedirectTo: `${window.location.origin}/dashboard`,
            data: { full_name: fullName, role: "user" },
          },
        });
        if (error) throw error;
        toast.success("تم إنشاء الحساب");
      } else {
        const { error } = await supabase.auth.signInWithPassword({ email, password });
        if (error) throw error;
      }
      const { data } = await supabase.auth.getSession();
      if (data.session) navigate({ to: "/dashboard" });
      else toast.info("تحقق من بريدك لتأكيد الحساب ثم سجّل الدخول");
    } catch (error: any) {
      toast.error(error?.message ?? "تعذر إتمام العملية");
    } finally {
      setBusy(false);
    }
  }

  return (
    <div className="flex min-h-screen items-center justify-center bg-muted/30 px-4">
      <Card className="w-full max-w-sm">
        <CardHeader>
          <CardTitle>{mode === "signin" ? "تسجيل الدخول" : "إنشاء حساب"}</CardTitle>
        </CardHeader>
        <CardContent>
          <form className="space-y-4" onSubmit={submit}>
            {mode === "signup" && (
              <Field label="الاسم الكامل">
                <Input value={fullName} onChange={(e) => setFullName(e.target.value)} required />
              </Field>
            )}
            <Field label="البريد الإلكتروني">
              <Input type="email" value={email} onChange={(e) => setEmail(e.target.value)} required dir="ltr" />
            </Field>
            <Field label="كلمة المرور">
              <Input type="password" value={password} onChange={(e) => setPassword(e.target.value)} required dir="ltr" minLength={6} />
            </Field>
            <Button type="submit" className="w-full" disabled={busy}>
              {busy ? "جارٍ..." : mode === "signin" ? "دخول" : "إنشاء"}
            </Button>
            <button
              type="button"
              className="w-full text-xs text-muted-foreground underline"
              onClick={() => setMode(mode === "signin" ? "signup" : "signin")}
            >
              {mode === "signin" ? "ليس لديك حساب؟ إنشاء حساب" : "لديك حساب؟ تسجيل الدخول"}
            </button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
