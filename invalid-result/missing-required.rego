package test

import rego.v1

default missing_required := {
  "violations": ["Reason to fail", "another reason to fail"]
}