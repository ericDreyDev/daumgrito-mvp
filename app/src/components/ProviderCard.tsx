import { MapPin, Star } from "lucide-react";
import type { Provider } from "../services/api";

interface ProviderCardProps {
  provider: Provider;
  onSelect: (provider: Provider) => void;
}

export function ProviderCard({ provider, onSelect }: ProviderCardProps) {
  const mainService = provider.services[0] ?? "Serviços gerais";

  return (
    <article className="provider-card">
      <div className="avatar" style={{ backgroundImage: provider.photoUrl ? `url(${provider.photoUrl})` : undefined }}>
        {!provider.photoUrl && provider.name.slice(0, 1)}
      </div>
      <div className="provider-info">
        <div>
          <h3>{provider.name}</h3>
          <p>{mainService}</p>
        </div>
        <div className="meta-line">
          <MapPin size={16} />
          <span>
            {provider.city}, {provider.neighborhood}
          </span>
        </div>
        <div className="meta-line">
          <Star size={16} />
          <span>{provider.averageRating ? provider.averageRating.toFixed(1) : "Sem avaliações"}</span>
        </div>
        <span className="availability">{provider.availability ?? "Disponibilidade a combinar"}</span>
      </div>
      <button onClick={() => onSelect(provider)}>Ver detalhes</button>
    </article>
  );
}
