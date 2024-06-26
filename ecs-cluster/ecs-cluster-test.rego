package test

import rego.v1

result := {
  "allowed": count(violations) == 0,
  "violations": violations
}

violations contains "ECS Cluster container insights not enabled" if {
  not settings_has_container_insights_enabled(input.resourceProperties.ClusterSettings)
}

settings_has_container_insights_enabled(settings) if {
    setting := settings[_]
    setting.Name == "containerInsights"
    setting.Value == "enabled"
}
