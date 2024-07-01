package test

import rego.v1

default extra_field := {
  "foo": "bar",
  "allowed": false,
  "violations": ["Reason to fail", "another reason to fail"]
}