import { Search } from "lucide-react";
import { useEffect, useState } from "react";
import { ProviderCard } from "../components/ProviderCard";
import { api, serviceCategories, type Provider, type User } from "../services/api";

interface ProvidersPageProps {
  user: User;
}

export function ProvidersPage({ user }: ProvidersPageProps) {
  const [providers, setProviders] = useState<Provider[]>([]);
  const [selectedProvider, setSelectedProvider] = useState<Provider | null>(null);
  const [filters, setFilters] = useState({ service: "", city: "", neighborhood: "", availability: "", bestRating: false });
  const [requestForm, setRequestForm] = useState({ service: "", description: "", desiredDate: "", locationNeighborhood: "" });
  const [message, setMessage] = useState("");

  async function loadProviders() {
    const query = new URLSearchParams();
    Object.entries(filters).forEach(([key, value]) => {
      if (value) query.set(key, String(value));
    });
    setProviders(await api.listProviders(query));
  }

  useEffect(() => {
    loadProviders();
  }, []);

  async function createRequest(event: React.FormEvent) {
    event.preventDefault();
    if (!selectedProvider) return;
    setMessage("");
    await api.createServiceRequest({ ...requestForm, providerId: selectedProvider.id });
    setMessage("Solicitação criada com status Solicitado.");
    setRequestForm({ service: "", description: "", desiredDate: "", locationNeighborhood: "" });
  }

  return (
    <main className="workspace">
      <section className="filters">
        <h2>Buscar prestadores</h2>
        <div className="filter-row">
          <select value={filters.service} onChange={(e) => setFilters({ ...filters, service: e.target.value })}>
            <option value="">Serviço</option>
            {serviceCategories.map((category) => (
              <option key={category}>{category}</option>
            ))}
          </select>
          <input placeholder="Cidade" value={filters.city} onChange={(e) => setFilters({ ...filters, city: e.target.value })} />
          <input placeholder="Bairro/região" value={filters.neighborhood} onChange={(e) => setFilters({ ...filters, neighborhood: e.target.value })} />
          <input placeholder="Disponibilidade" value={filters.availability} onChange={(e) => setFilters({ ...filters, availability: e.target.value })} />
          <label className="check">
            <input type="checkbox" checked={filters.bestRating} onChange={(e) => setFilters({ ...filters, bestRating: e.target.checked })} />
            Melhor avaliação
          </label>
          <button onClick={loadProviders}>
            <Search size={17} />
            Filtrar
          </button>
        </div>
      </section>

      <section className="content-grid">
        <div className="list-panel">
          <h2>Profissionais</h2>
          {providers.length === 0 ? (
            <p className="muted">Nenhum prestador encontrado. Cadastre um usuário prestador para começar.</p>
          ) : (
            providers.map((provider) => <ProviderCard key={provider.id} provider={provider} onSelect={setSelectedProvider} />)
          )}
        </div>

        <aside className="detail-panel">
          {selectedProvider ? (
            <>
              <div className="detail-header">
                <div className="avatar large" style={{ backgroundImage: selectedProvider.photoUrl ? `url(${selectedProvider.photoUrl})` : undefined }}>
                  {!selectedProvider.photoUrl && selectedProvider.name.slice(0, 1)}
                </div>
                <div>
                  <h2>{selectedProvider.name}</h2>
                  <p>{selectedProvider.city}, {selectedProvider.neighborhood}</p>
                  <strong>{selectedProvider.averageRating ? `${selectedProvider.averageRating.toFixed(1)} estrelas` : "Sem avaliações"}</strong>
                </div>
              </div>
              <p>{selectedProvider.professionalDescription ?? "Perfil profissional em preenchimento."}</p>
              <div className="tag-row">
                {selectedProvider.services.map((service) => <span key={service}>{service}</span>)}
              </div>
              <p><strong>Disponibilidade:</strong> {selectedProvider.availability ?? "A combinar"}</p>
              <p><strong>Valor:</strong> {selectedProvider.averagePrice ?? "A combinar"}</p>

              {user.userType === "client" && (
                <form className="form-grid compact" onSubmit={createRequest}>
                  <h3>Solicitar serviço</h3>
                  <select required value={requestForm.service} onChange={(e) => setRequestForm({ ...requestForm, service: e.target.value })}>
                    <option value="">Serviço desejado</option>
                    {selectedProvider.services.map((service) => <option key={service}>{service}</option>)}
                  </select>
                  <textarea required minLength={10} placeholder="Descreva o problema ou necessidade" value={requestForm.description} onChange={(e) => setRequestForm({ ...requestForm, description: e.target.value })} />
                  <input required type="date" value={requestForm.desiredDate} onChange={(e) => setRequestForm({ ...requestForm, desiredDate: e.target.value })} />
                  <input required placeholder="Local/bairro" value={requestForm.locationNeighborhood} onChange={(e) => setRequestForm({ ...requestForm, locationNeighborhood: e.target.value })} />
                  <button className="primary" type="submit">Iniciar conversa ou solicitar</button>
                  {message && <p className="success">{message}</p>}
                </form>
              )}
            </>
          ) : (
            <p className="muted">Selecione um profissional para ver detalhes e criar uma solicitação.</p>
          )}
        </aside>
      </section>
    </main>
  );
}
