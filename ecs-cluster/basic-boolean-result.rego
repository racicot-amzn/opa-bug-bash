package test

default allow := false

allow = true {
    setting := input.resourceProperties.ClusterSettings[_]
    setting.Name == "containerInsights"
    setting.Value == "enabled"
}