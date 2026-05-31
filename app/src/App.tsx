import { useEffect, useState } from "react";
import { Header } from "./components/Header";
import { AuthPage } from "./pages/AuthPage";
import { ProviderProfilePage } from "./pages/ProviderProfilePage";
import { ProvidersPage } from "./pages/ProvidersPage";
import { api, type User } from "./services/api";

export function App() {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.me()
      .then(setUser)
      .catch(() => localStorage.removeItem("daumgrito.token"))
      .finally(() => setLoading(false));
  }, []);

  function handleAuthenticated(nextUser: User, token: string) {
    localStorage.setItem("daumgrito.token", token);
    setUser(nextUser);
  }

  function logout() {
    localStorage.removeItem("daumgrito.token");
    setUser(null);
  }

  if (loading) return <div className="loading">Carregando...</div>;

  return (
    <>
      <Header user={user} onLogout={logout} />
      {!user ? <AuthPage onAuthenticated={handleAuthenticated} /> : user.userType === "provider" ? <ProviderProfilePage /> : <ProvidersPage user={user} />}
    </>
  );
}
