locals {
  lab            = "002"
  workload       = "main"
  workload_short = null

  project_name = var.project

  project_tags = merge(local.tags, {
    project = local.project_name
  })

  # TODO: Dodaj local budgets_for_alerts (budżet, krok 2)
  budgets_for_alerts = toset(["10", "20", "50"])

  # TODO: Dodaj local principal_id (Key Vault/SOPS, krok 3)
}
