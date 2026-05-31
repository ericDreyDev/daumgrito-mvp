export const serviceCategories = [
  { id: "faxineiro", name: "Faxineiro(a)" },
  { id: "encanador", name: "Encanador(a)" },
  { id: "eletricista", name: "Eletricista" },
  { id: "montador-moveis", name: "Montador de móveis" },
  { id: "manutencao-basica", name: "Manutenção básica" },
  { id: "jardineiro", name: "Jardineiro" }
];

export const demoProviders = [
  {
    userId: "demo-provider-ana",
    profileId: "demo-profile-ana",
    name: "Ana Souza",
    email: "ana.faxina@demo.local",
    phone: "(11) 90000-1001",
    city: "São Paulo",
    neighborhood: "Vila Mariana",
    services: ["Faxineiro(a)", "Manutenção básica"],
    professionalDescription: "Atendimento residencial com foco em limpeza detalhada e organização de ambientes.",
    availability: "Segunda a sexta",
    averagePrice: "A partir de R$ 120",
    averageRating: 4.8
  },
  {
    userId: "demo-provider-carlos",
    profileId: "demo-profile-carlos",
    name: "Carlos Lima",
    email: "carlos.eletrica@demo.local",
    phone: "(11) 90000-1002",
    city: "São Paulo",
    neighborhood: "Tatuapé",
    services: ["Eletricista", "Manutenção básica"],
    professionalDescription: "Instalação, reparos elétricos simples e manutenção preventiva para residências.",
    availability: "Noites e sábados",
    averagePrice: "A combinar",
    averageRating: 4.6
  },
  {
    userId: "demo-provider-marcos",
    profileId: "demo-profile-marcos",
    name: "Marcos Oliveira",
    email: "marcos.reparos@demo.local",
    phone: "(11) 90000-1003",
    city: "Guarulhos",
    neighborhood: "Centro",
    services: ["Encanador(a)", "Montador de móveis"],
    professionalDescription: "Pequenos reparos hidráulicos, montagem de móveis e ajustes gerais para o lar.",
    availability: "Todos os dias",
    averagePrice: "R$ 80 por visita",
    averageRating: 4.9
  }
];
