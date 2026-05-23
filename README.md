# meta-lab — Orquestrador do Laboratório

Repositório meta que clona, orquestra e gerencia o ciclo de vida de todos os domínios do laboratório Platform Engineering.

## Estrutura

```
meta-lab/
├── Makefile          # Orquestração principal (bootstrap, all, clean)
├── .env.example      # Variáveis de ambiente
├── config/           # Configurações globais
│   ├── global-values.yaml
│   └── network-policies.yaml
├── scripts/
│   ├── bootstrap.sh
│   ├── sync-repos.sh
│   └── teardown.sh
└── README.md
```

## Uso rápido

```bash
# Clona todos os repositórios e faz deploy sequencial
make all

# Limpa tudo em ordem reversa
make clean

# Apenas clona os repositórios
make bootstrap
```

## Domínios orquestrados

| Domínio      | Repositório     | Responsabilidade              |
|-------------|----------------|-------------------------------|
| Infra       | lab-infra      | Terraform + LocalStack        |
| Kubernetes  | lab-k8s        | KIND + Helm                   |
| Observability | lab-observability | Prometheus + Grafana      |
| Messaging   | lab-messaging   | RabbitMQ/Kafka               |
| GitOps      | lab-gitops      | ArgoCD                        |

## Interface padronizada

Cada domínio expõe: `make {setup, deploy, test, teardown, validate}`

## Boas práticas

- Nunca use `latest` — pinne todas as versões
- Documente a interface pública em cada `README.md`
- Evite submódulos Git; prefira referências diretas
- Use tags semânticas para versionamento independente
