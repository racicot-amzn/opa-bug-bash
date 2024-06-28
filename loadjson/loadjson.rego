package test

import rego.v1

# Load external data from JSON in bundle
users := data.users

result := {
  "allowed": count(violations) == 0,
  "violations": violations
}

violations contains msg if {
  user := users[_]
  msg := sprintf("User: %s is missing age attribute", [user.name])
  not user.age 
}