export type UserType = "client" | "provider";

export type RequestStatus =
  | "Solicitado"
  | "Em negociação"
  | "Agendado"
  | "Em andamento"
  | "Concluído"
  | "Cancelado";

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
