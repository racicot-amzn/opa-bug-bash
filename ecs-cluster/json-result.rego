package test

import rego.v1

result := {
  "allowed": count(violations) == 0,
  "violations": violations
}

violations contains msg if {
  msg := sprintf("ECS Cluster container insights not enabled for: %s", [input.resourceProperties.ClusterName])
  not settings_has_container_insights_enabled(input.resourceProperties.ClusterSettings)
}

settings_has_container_insights_enabled(settings) if {
    setting := settings[_]
    setting.Name == "containerInsights"
    setting.Value == "enabled"
}
