package test

import rego.v1

result := {
    "allowed": resp.status_code == 500,
    "violations": [resp.raw_body]
}

resp := http.send({"url": "https://example.com", "method": "GET"})
