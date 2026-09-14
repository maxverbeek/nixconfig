# Build a configured neovim. `config` is a store path containing init.lua (and
# optionally after/), produced by mkConfigSource; this builder neither knows nor
# cares whether it is a store copy or a working-tree symlink.
#
# Credit: https://github.com/shofel/nvim-on-nix and https://github.com/Gerg-L/mnw.
{
  lib,
  sqlite,
  neovim-unwrapped,
  wrapNeovimUnstable,
}:
{
  config,

  plugins ? [ ],
  extraPackages ? [ ],

  # NVIM_APPNAME; also renames the binary.
  appName ? "nvim",
  aliases ? [ ],

  # sqlite is a dependency of some plugins
  withSqlite ? true,

  extraLuaPackages ? p: [ ],
  extraPython3Packages ? p: [ ],
  withPython3 ? true,
  withRuby ? false,
  withNodeJs ? false,
}:
let
  inherit (lib)
    optional
    optionals
    optionalString
    makeBinPath
    escapeShellArg
    concatStringsSep
    ;

  externalPackages = extraPackages ++ optionals withSqlite [ sqlite ];

  initLua = ''
    -- run `PROF=1 nvim` to profile startup
    -- https://github.com/folke/snacks.nvim/blob/main/docs/profiler.md
    if vim.env.PROF then
      require("snacks.profiler").startup({
        startup = { event = "VimEnter" },
      })
    end

    -- Strip everything from rtp/packpath except what neovim ships and what the
    -- nix wrapper built, so nothing leaks in from $HOME or the system.
    local function cleanupRuntime()
      local keep = { 'vim[-]pack[-]dir', 'neovim[-]unwrapped' }
      local function filter(list)
        local out = {}
        for _, v in pairs(list) do
          for _, pat in ipairs(keep) do
            if string.match(v, pat) then
              table.insert(out, v)
            end
          end
        end
        return out
      end
      vim.opt.packpath = filter(vim.opt.packpath:get())
      vim.opt.rtp = filter(vim.opt.rtp:get())
    end
    cleanupRuntime()

    -- Make `config` behave as if it were ~/.config/nvim
    vim.opt.rtp:prepend("${config}")
    vim.opt.rtp:append("${config}/after")
    dofile("${config}/init.lua")
  '';

  wrapperArgs = concatStringsSep " " (
    optional (appName != "nvim") ''--set NVIM_APPNAME "${appName}"''
    ++ optional (externalPackages != [ ]) ''--prefix PATH : "${makeBinPath externalPackages}"''
    ++ optionals withSqlite [
      ''--set LIBSQLITE_CLIB_PATH "${sqlite.out}/lib/libsqlite3.so"''
      ''--set LIBSQLITE "${sqlite.out}/lib/libsqlite3.so"''
    ]
  );

  # Not neovimUtils.makeNeovimConfig: that shim is deprecated.
  neovim = wrapNeovimUnstable neovim-unwrapped {
    inherit
      plugins
      extraLuaPackages
      extraPython3Packages
      withPython3
      withRuby
      withNodeJs
      ;
    luaRcContent = initLua;
    inherit wrapperArgs;
  };
in
neovim.overrideAttrs (oa: {
  meta.mainProgram = appName;
  buildPhase =
    oa.buildPhase
    + optionalString (appName != "nvim") ''
      mv $out/bin/nvim $out/bin/${escapeShellArg appName}
    ''
    + concatStringsSep ";\n" (
      map (a: "ln -s $out/bin/${escapeShellArg appName} $out/bin/${escapeShellArg a}") aliases
    );
})
