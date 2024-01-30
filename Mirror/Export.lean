import Lean
import Mirror.Translate
import Mirror.IRToDafny

namespace Lean.ToDafny

syntax (name := export_dafny) "export_dafny" : attr

open Meta

def saveMethod (m : Method) : CoreM Unit :=
  modifyEnv fun env => extension.addEntry env (.toExport s!"{m.print}")

def toDafnyMethod(declName: Name) : MetaM Unit := do
  saveMethod (← CodeGen (← toDafnyRandomMDefIn declName))

initialize
  registerBuiltinAttribute {
    ref   := by exact decl_name%
    name  := `export_dafny
    descr := "instruct Lean to convert the given definition to a Dafny method"
    applicationTime := AttributeApplicationTime.afterTypeChecking
    add   := fun declName _ _attrKind =>
      let go : MetaM Unit :=
        do
          toDafnyMethod declName
      discard <| go.run {} {}
    erase := fun _ => do
      throwError "this attribute cannot be removed"
  }

end Lean.ToDafny
