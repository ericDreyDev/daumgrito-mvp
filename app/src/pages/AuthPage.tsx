import { useState } from "react";
import { api, type User } from "../services/api";

interface AuthPageProps {
  onAuthenticated: (user: User, token: string) => void;
}

const initialForm = {
  name: "",
  email: "",
  phone: "",
  password: "",
  city: "",
  neighborhood: "",
  userType: "client"
};

export function AuthPage({ onAuthenticated }: AuthPageProps) {
  const [mode, setMode] = useState<"login" | "register">("register");
  const [form, setForm] = useState(initialForm);
  const [error, setError] = useState("");

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    setError("");

    try {
      const response =
        mode === "login"
          ? await api.login({ email: form.email, password: form.password })
          : await api.register(form);
      onAuthenticated(response.user, response.token);
    } catch (err) {
      setError(err instanceof Error ? err.message : "Erro inesperado.");
    }
  }

  return (
    <main className="auth-layout">
      <section className="auth-panel">
        <div className="auth-copy">
          <h1>Dá um grito!</h1>
          <p>Encontre profissionais próximos ou divulgue seus serviços em poucos passos.</p>
        </div>
        <form onSubmit={handleSubmit} className="form-grid">
          <div className="segmented">
            <button type="button" className={mode === "register" ? "active" : ""} onClick={() => setMode("register")}>
              Cadastro
            </button>
            <button type="button" className={mode === "login" ? "active" : ""} onClick={() => setMode("login")}>
              Login
            </button>
          </div>

          {mode === "register" && (
            <>
              <input required placeholder="Nome" value={form.name} onChange={(e) => setForm({ ...form, name: e.target.value })} />
              <input required placeholder="Telefone" value={form.phone} onChange={(e) => setForm({ ...form, phone: e.target.value })} />
              <input required placeholder="Cidade" value={form.city} onChange={(e) => setForm({ ...form, city: e.target.value })} />
              <input required placeholder="Bairro" value={form.neighborhood} onChange={(e) => setForm({ ...form, neighborhood: e.target.value })} />
              <select value={form.userType} onChange={(e) => setForm({ ...form, userType: e.target.value })}>
                <option value="client">Cliente</option>
                <option value="provider">Prestador</option>
              </select>
            </>
          )}

          <input required type="email" placeholder="E-mail" value={form.email} onChange={(e) => setForm({ ...form, email: e.target.value })} />
          <input required type="password" minLength={6} placeholder="Senha" value={form.password} onChange={(e) => setForm({ ...form, password: e.target.value })} />

          {error && <p className="error">{error}</p>}
          <button className="primary" type="submit">{mode === "login" ? "Entrar" : "Criar conta"}</button>
        </form>
      </section>
    </main>
  );
}
