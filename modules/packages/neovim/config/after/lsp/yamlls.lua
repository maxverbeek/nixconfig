-- Schema-to-glob mapping. Values may be a single glob or a list of globs.
-- yamlls globs only support `*` — `?` and `{a,b}` are matched literally, so
-- regex-flavoured patterns like "ya?ml" silently never match.
--
-- Public schemas (Chart.yaml, compose, kustomization, github-workflow, ...)
-- are matched automatically via the schemastore.org catalog (enabled by
-- default); only schemas the catalog can't know about are listed here.
--
-- Local schema paths are read straight from the working copy, so schema edits
-- apply on the next (re)open of a matching buffer. For one-off files, use an
-- inline modeline instead:
--   # yaml-language-server: $schema=/path/or/url/to/schema.json
local researchable = "/home/max/Researchable/"

-- Kubernetes manifests are validated per kind. The catch-all
-- kubernetes-json-schema all.json is useless for validation: it is one giant
-- oneOf, so every manifest triggers "Matches multiple schemas" and property
-- errors are swallowed. Instead, resolve apiVersion + kind from the buffer to
-- the kind-specific schema (kubernetes-json-schema for builtins, the datree
-- CRDs-catalog for CRDs) and register it for exactly this file.
local K8S_VERSION = "v1.32.1"

local function k8s_schema_url(bufnr)
  local api_version, kind, docs = nil, nil, 0
  for _, l in ipairs(vim.api.nvim_buf_get_lines(bufnr, 0, 200, false)) do
    if l:find("^apiVersion:") then
      docs = docs + 1
    end
    api_version = api_version or l:match("^apiVersion:%s*[\"']?([%w%./%-]+)")
    kind = kind or l:match("^kind:%s*[\"']?([%w%-]+)")
  end
  -- multi-document files can't be expressed as a single per-file schema
  if not api_version or not kind or docs > 1 then
    return nil
  end

  local group, version = api_version:match("^([^/]+)/(.+)$")
  kind = kind:lower()
  if not group then
    -- core group, e.g. apiVersion: v1
    return string.format(
      "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/%s-standalone-strict/%s-%s.json",
      K8S_VERSION,
      kind,
      api_version
    )
  elseif not group:find("%.") or group:find("%.k8s%.io$") then
    -- builtin groups: apps/v1, batch/v1, networking.k8s.io/v1, ...
    return string.format(
      "https://raw.githubusercontent.com/yannh/kubernetes-json-schema/master/%s-standalone-strict/%s-%s-%s.json",
      K8S_VERSION,
      kind,
      group:match("^[^%.]+"),
      version
    )
  end
  -- anything else is a CRD: argoproj.io, external-secrets.io, ...
  return string.format(
    "https://raw.githubusercontent.com/datreeio/CRDs-catalog/main/%s/%s_%s.json",
    group:lower(),
    kind,
    version
  )
end

local url_exists = {} -- url -> true/false, cached for the session

local function attach_k8s_schema(client, bufnr)
  local url = k8s_schema_url(bufnr)
  if not url then
    return
  end
  local function register()
    local schemas = vim.tbl_get(client.settings, "yaml", "schemas") or {}
    local fname = vim.api.nvim_buf_get_name(bufnr)
    if schemas[url] == fname then
      return
    end
    schemas[url] = fname
    client.settings = vim.tbl_deep_extend("force", client.settings, { yaml = { schemas = schemas } })
    client:notify("workspace/didChangeConfiguration", { settings = client.settings })
  end
  if url_exists[url] ~= nil then
    return url_exists[url] and register() or nil
  end
  -- only register schemas that exist, so unknown CRDs degrade to no schema
  -- instead of an "unable to load schema" diagnostic
  vim.system({ "curl", "-sfI", "--max-time", "10", url }, {}, function(out)
    url_exists[url] = out.code == 0
    if out.code == 0 then
      vim.schedule(register)
    end
  end)
end

return {
  on_attach = function(client, bufnr)
    attach_k8s_schema(client, bufnr)
    vim.api.nvim_create_autocmd("BufWritePost", {
      buffer = bufnr,
      callback = function()
        attach_k8s_schema(client, bufnr)
      end,
    })
  end,
  settings = {
    yaml = {
      validate = true,
      kubernetesCRDStore = { enable = true },
      schemas = {
        -- GitLab hosts this itself since its removal from schemastore.org.
        ["https://gitlab.com/gitlab-org/gitlab/-/raw/master/app/assets/javascripts/editor/schema/ci.json"] = {
          "*gitlab-ci*.yml",
          "*gitlab-ci*.yaml",
        },

        -- app-chart values: researchable.yaml in app repos, plus the chart's
        -- own default values and test inputs.
        [researchable .. "general/devops/app-chart/values.schema.json"] = {
          "researchable.yaml",
          "**/.researchable/*.yaml",
        },

        [researchable .. "general/devops/argocd/charts/project/values.schema.json"] = {
          "argocd/projects/*.yaml",
        },

        ["kubernetes"] = {
          "/manifests/**/*.yaml",
          "/argo/**/*.yaml",
        },
      },
    },
  },
}
