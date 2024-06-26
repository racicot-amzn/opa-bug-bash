package test

import rego.v1

default allow := false

allow if {
    setting := input.resourceProperties.ClusterSettings[_]
    setting.Name == "containerInsights"
    setting.Value == "enabled"
}