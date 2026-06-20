export type UserType = "client" | "provider";

export type RequestStatus =
  | "Solicitado"
  | "Aguardando aceite"
  | "Em negociação"
  | "Em negociaÃ§Ã£o"
  | "Agendado"
  | "Aceito"
  | "Recusado"
  | "Em andamento"
  | "Concluído"
  | "ConcluÃ­do"
  | "Finalizado"
  | "Cancelado";

export type PaymentMethod = "Pix" | "cartÃ£o" | "dinheiro";
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
