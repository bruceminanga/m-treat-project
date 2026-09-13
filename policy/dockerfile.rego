package main

# 1. Phase 3: Pin base images by SHA256 digest
deny contains msg if {
    some i
    input[i].Cmd == "from"
    val := input[i].Value[0]
    val != "scratch"
    not contains(val, "@sha256:")
    msg := sprintf("[Phase 3] Base image '%v' must be pinned with an immutable SHA256 digest (@sha256:...)", [val])
}

# 2. Phase 3: Never use :latest tag
deny contains msg if {
    some i
    input[i].Cmd == "from"
    val := input[i].Value[0]
    contains(val, ":latest")
    msg := sprintf("[Phase 3 & 7] Base image '%v' must not use the mutable ':latest' tag", [val])
}

# 3. Phase 3: Must run as non-root user
deny contains msg if {
    users := [val | some i; input[i].Cmd == "user"; val := input[i].Value[0]]
    count(users) == 0
    msg := "[Phase 3] Dockerfile must declare a non-root 'USER' directive"
}

# 4. Phase 4: Must define HEALTHCHECK
deny contains msg if {
    healthchecks := [val | some i; input[i].Cmd == "healthcheck"; val := input[i].Value]
    count(healthchecks) == 0
    msg := "[Phase 4] Dockerfile must declare a 'HEALTHCHECK' directive"
}

# 5. Phase 3: Must include OCI standard metadata labels
deny contains msg if {
    labels := [val | some i; input[i].Cmd == "label"; val := input[i].Value]
    count(labels) == 0
    msg := "[Phase 3] Dockerfile must define OCI metadata labels (LABEL org.opencontainers.image...)"
}
