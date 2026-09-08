{ lib, ... }:
rec {
  /**
    Find importable Nix files below one or more paths.

    Files whose names start with `_` are excluded.

    # Type

    ```
    listFiles :: Path | [Path] -> [Path]
    ```
  */
  listFiles =
    dir:
    let
      expand =
        path:
        if builtins.readFileType path == "directory" then
          lib.filesystem.listFilesRecursive path
        else
          [ path ];
    in
    lib.filter (
      path:
      let
        name = builtins.baseNameOf path;
      in
      (lib.hasSuffix ".nix" name) && !(lib.hasPrefix "_" name)
    ) (lib.concatMap expand (lib.lists.toList dir));

  /**
    Turn the collected values at a namespace path into a Nix module.

    Lists are flattened into the module's imports. An attrset is split into
    one module per top-level attribute so attrsets below the collection depth
    remain module configuration rather than namespace branches.

    # Type

    ```
    aggregateModules :: [String] -> [{ file :: String; value :: Module | [Module]; }] -> Module
    ```
  */
  aggregateModules =
    path: shards:
    let
      validate =
        value:
        if
          builtins.isAttrs value
          || builtins.isFunction value
          || builtins.isPath value
          || builtins.isString value
        then
          value
        else
          throw "aggregateModules: expected a module or a list of modules, got ${builtins.typeOf value}";

      normalize =
        value:
        if builtins.isList value then
          map validate value
        else if builtins.isAttrs value then
          map (name: { ${name} = value.${name}; }) (builtins.attrNames value)
        else
          [ (validate value) ];
    in
    {
      # A stable key gives the virtual module an identity for import
      # deduplication in the Nix module system.
      key = "sharded-module-${lib.concatStringsSep "." path}";
      imports = map (shard: {
        # The module system uses _file as the source location for definitions
        # and errors originating from this shard.
        _file = shard.file;
        imports = normalize shard.value;
      }) shards;
    };

  /**
    Traverse attrsets to a fixed depth and aggregate matching leaves.

    The values below each path are opaque to the traversal. `aggregate`
    receives the path and all values collected there.

    # Type

    ```
    collectAttrs :: Int -> ([String] -> [a] -> b) -> [AttrTree a] -> AttrTree b
    ```
  */
  collectAttrs =
    depth: aggregate: attrsets:
    let
      collect =
        depth: path: values:
        if depth == 0 then
          aggregate path values
        else
          builtins.zipAttrsWith (
            name: childValues: collect (depth - 1) (path ++ [ name ]) childValues
          ) values;
    in
    collect depth [ ] attrsets;

  /**
    Apply a function to every value at a fixed attrset depth.

    # Type

    ```
    mapLeaves :: Int -> (a -> b) -> AttrTree a -> AttrTree b
    ```
  */
  mapLeaves =
    depth: f: value:
    if depth == 0 then
      f value
    else
      builtins.mapAttrs (_: mapLeaves (depth - 1) f) value;

  /**
    Import sharded attrsets and expose a virtual module at every leaf.

    # Type

    ```
    importSharded :: Int -> Path | [Path] -> Attrs
    ```
  */
  importSharded =
    depth: dir:
    let
      paths = listFiles dir;
      attrsets = map (
        path:
        mapLeaves depth (value: {
          file = toString path;
          inherit value;
        }) (import path)
      ) paths;
    in
    collectAttrs depth aggregateModules attrsets;
}
