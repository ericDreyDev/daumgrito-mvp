export type UserType = "client" | "provider";

export type RequestStatus =
  | "Aguardando aceite"
  | "Aceito"
  | "Recusado"
  | "Em andamento"
  | "Finalizado"
  | "Cancelado";

export type ProviderValidationStatus = "Pendente" | "Aprovado" | "Reprovado";

export type PaymentMethod = "Pix" | "cartão" | "dinheiro";
export type PaymentStatus = "pendente" | "pago" | "cancelado";

export interface AuthUser {
  id: string;
  name: string;
  email: string;
  phone: string;
  document: string;
  city: string;
  neighborhood: string;
  userType: UserType;
}
