{
  lib,
  ...
}:

let
  inherit (lib)
    findFirst
    # concatMap
    optionalAttrs
    # filterAttrs
    ;

  # The meta attribute is passed in the resulting attribute set,
  # but it's not part of the actual derivation, i.e., it's not
  # passed to the builder and is not a dependency.  But since we
  # include it in the result, it *is* available to nix-env for queries.
  # Example:
  #   meta = checkMeta.commonMeta { inherit validity attrs pos references; };
  #   validity = checkMeta.assertValidity { inherit meta attrs; };
  commonMeta =
    {
      attrs,
      pos ? null,
	  ...
    }:
    let
      outputs = attrs.outputs or [ "out" ];
      hasOutput = out: builtins.elem out outputs;
    in
    {
      # If the packager hasn't specified `outputsToInstall`, choose a default,
      # which is the name of `p.bin or p.out or p` along with `p.man` when
      # present.
      #
      # If the packager has specified it, it will be overridden below in
      # `// meta`.
      #
      #   Note: This default probably shouldn't be globally configurable.
      #   Services and users should specify outputs explicitly,
      #   unless they are comfortable with this default.
      outputsToInstall = [
        (
          if hasOutput "bin" then
            "bin"
          else if hasOutput "out" then
            "out"
          else
            findFirst hasOutput null outputs
        )
      ]; # TODO: option # ++ optional (hasOutput "man") "man";
    }
    # // (filterAttrs (_: v: v != null) {
    #   CI scripts look at these to determine pings. Note that we should filter nulls out of this,
    #   or nix-env complains: https://github.com/NixOS/nix/blob/2.18.8/src/nix-env/nix-env.cc#L963
    #   maintainersPosition = builtins.unsafeGetAttrPos "maintainers" (attrs.meta or { });
    #   teamsPosition = builtins.unsafeGetAttrPos "teams" (attrs.meta or { });
    # })
    // attrs.meta or { }
    # Fill `meta.position` to identify the source location of the package.
    // optionalAttrs (pos != null) {
      position = pos.file + ":" + toString pos.line;
    }
    # // {
    #   Maintainers should be inclusive of teams.
    #   Note that there may be external consumers of this API (repology, for instance) -
    #   if you add a new maintainer or team attribute please ensure that this expectation is still met.
    #   maintainers =
    #     attrs.meta.maintainers or [ ]
    #     ++ concatMap (team: team.members or [ ]) attrs.meta.teams or [ ];
    # }
    // {
      available = true;
    };

  assertValidity =
    { ... }: true;

in
{
  disabledModules = [
	"pkgs/stdenv/generic/check-meta.nix"
  ];
  inherit assertValidity commonMeta;
}