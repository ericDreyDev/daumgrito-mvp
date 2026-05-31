import { LogOut, Megaphone } from "lucide-react";
import type { User } from "../services/api";

interface HeaderProps {
  user: User | null;
  onLogout: () => void;
}

export function Header({ user, onLogout }: HeaderProps) {
  return (
    <header className="app-header">
      <div className="brand">
        <span className="brand-icon">
          <Megaphone size={22} />
        </span>
        <div>
          <strong>Dá um grito!</strong>
          <small>Serviços domiciliares da sua região</small>
        </div>
      </div>
      {user && (
        <div className="user-chip">
          <span>{user.name}</span>
          <button className="icon-button" onClick={onLogout} title="Sair">
            <LogOut size={18} />
          </button>
        </div>
      )}
    </header>
  );
}
