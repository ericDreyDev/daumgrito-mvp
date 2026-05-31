import { Save } from "lucide-react";
import { useState } from "react";
import { api, serviceCategories } from "../services/api";

export function ProviderProfilePage() {
  const [form, setForm] = useState({
    photoUrl: "",
    services: [] as string[],
    professionalDescription: "",
    availability: "",
    averagePrice: ""
  });
  const [message, setMessage] = useState("");

  async function submit(event: React.FormEvent) {
    event.preventDefault();
    await api.saveProviderProfile(form);
    setMessage("Perfil profissional salvo.");
  }

  function toggleService(service: string) {
    setForm((current) => ({
      ...current,
      services: current.services.includes(service)
        ? current.services.filter((item) => item !== service)
        : [...current.services, service]
    }));
  }

  return (
    <main className="workspace narrow">
      <section className="profile-editor">
        <h2>Perfil do prestador</h2>
        <form className="form-grid" onSubmit={submit}>
          <input placeholder="URL da foto de perfil" value={form.photoUrl} onChange={(e) => setForm({ ...form, photoUrl: e.target.value })} />
          <div className="service-options">
            {serviceCategories.map((service) => (
              <label key={service} className="check tile">
                <input type="checkbox" checked={form.services.includes(service)} onChange={() => toggleService(service)} />
                {service}
              </label>
            ))}
          </div>
          <textarea required minLength={10} placeholder="Descrição profissional" value={form.professionalDescription} onChange={(e) => setForm({ ...form, professionalDescription: e.target.value })} />
          <input required placeholder="Disponibilidade" value={form.availability} onChange={(e) => setForm({ ...form, availability: e.target.value })} />
          <input required placeholder="Valor médio ou a combinar" value={form.averagePrice} onChange={(e) => setForm({ ...form, averagePrice: e.target.value })} />
          <button className="primary" type="submit">
            <Save size={18} />
            Salvar perfil
          </button>
          {message && <p className="success">{message}</p>}
        </form>
      </section>
    </main>
  );
}
