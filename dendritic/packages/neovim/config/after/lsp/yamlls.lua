return {
  settings = {
    yaml = {
      validate = false,
      schemas = {
        kubernetes = "{manifests,argo}/**/*.ya?ml",
        ["https://json.schemastore.org/gitlab-ci"] = "*gitlab-ci*.{ya?ml}",
        ["https://json.schemastore.org/renovate"] = "renovate.json5?",
        ["https://json.schemastore.org/docker-compose.yml"] = "**/(docker-)?compose(..*)?.ya?ml",
        ["https://json.schemastore.org/kustomization"] = "kustomization.{ya?ml}",
        ["https://json.schemastore.org/chart"] = "Chart.{ya?ml}",
        ["https://json.schemastore.org/github-workflow"] = ".github/workflows/*",
        ["https://json.schemastore.org/github-action"] = ".github/action.{ya?ml}",
        ["https://json.schemastore.org/prettierrc"] = ".prettierrc.{ya?ml}",
        ["https://json.schemastore.org/package"] = "package.json",
      },
    },
  },
}
