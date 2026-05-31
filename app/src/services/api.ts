const API_URL = import.meta.env.VITE_API_URL ?? "http://localhost:3333";

export interface User {
  id: string;
  name: string;
  email: string;
  phone: string;
  city: string;
  neighborhood: string;
  userType: "client" | "provider";
}

export interface Provider {
  id: string;
  userId: string;
  name: string;
  phone: string;
  city: string;
  neighborhood: string;
  photoUrl?: string;
  services: string[];
  professionalDescription?: string;
  availability?: string;
  averagePrice?: string;
  averageRating: number;
}

export const serviceCategories = [
  "Faxineiro(a)",
  "Encanador(a)",
  "Eletricista",
  "Montador de móveis",
  "Manutenção básica",
  "Jardineiro"
];

function authHeaders(): Record<string, string> {
  const token = localStorage.getItem("daumgrito.token");
  return token ? { Authorization: `Bearer ${token}` } : {};
}

async function request<T>(path: string, options: RequestInit = {}): Promise<T> {
  const headers = {
    "Content-Type": "application/json",
    ...authHeaders(),
    ...(options.headers as Record<string, string> | undefined)
  };

  const response = await fetch(`${API_URL}${path}`, {
    ...options,
    headers
  });

  const data = await response.json().catch(() => null);
  if (!response.ok) {
    throw new Error(data?.message ?? "Não foi possível concluir a operação.");
  }
  return data as T;
}

export const api = {
  register: (body: unknown) =>
    request<{ user: User; token: string }>("/auth/register", { method: "POST", body: JSON.stringify(body) }),
  login: (body: unknown) =>
    request<{ user: User; token: string }>("/auth/login", { method: "POST", body: JSON.stringify(body) }),
  me: () => request<User>("/users/me"),
  listProviders: (query: URLSearchParams) => request<Provider[]>(`/providers?${query.toString()}`),
  getProvider: (id: string) => request<Provider>(`/providers/${id}`),
  saveProviderProfile: (body: unknown) =>
    request<Provider>("/providers/profile", { method: "PUT", body: JSON.stringify(body) }),
  createServiceRequest: (body: unknown) =>
    request("/service-requests", { method: "POST", body: JSON.stringify(body) })
};
