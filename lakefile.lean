import Lake
open Lake DSL

package «sampcert» where
  -- add any package configuration options here

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git" @ "v4.10.0-rc2"

@[default_target]
lean_lib «SampCert» where

lean_lib «FastExtract» where

lean_lib «VMC» where

-- From doc-gen4
meta if get_config? env = some "doc" then
require «doc-gen4» from git "https://github.com/leanprover/doc-gen4" @ "main"
