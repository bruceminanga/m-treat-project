package main

# 1. Phase 6: Drop all Linux capabilities
deny contains msg if {
    some service_name
    service := input.services[service_name]
    not service.cap_drop
    msg := sprintf("[Phase 6] Service '%v' must explicitly declare 'cap_drop: [ALL]'", [service_name])
}

# 2. Phase 6: Prevent privilege escalation
deny contains msg if {
    some service_name
    service := input.services[service_name]
    opts := object.get(service, "security_opt", [])
    not "no-new-privileges:true" in opts
    msg := sprintf("[Phase 6] Service '%v' must set 'security_opt: [no-new-privileges:true]'", [service_name])
}

# 3. Phase 6: Enforce read-only root filesystem
deny contains msg if {
    some service_name
    service := input.services[service_name]
    not service.read_only == true
    msg := sprintf("[Phase 6] Service '%v' must set 'read_only: true' for production hardening", [service_name])
}

# 4. Phase 6: Never use host networking
deny contains msg if {
    some service_name
    service := input.services[service_name]
    service.network_mode == "host"
    msg := sprintf("[Phase 6] Service '%v' must not use 'network_mode: host' (bypasses network isolation)", [service_name])
}

# 5. Phase 5: Safe Local Port Binding (No binding to 0.0.0.0)
deny contains msg if {
    some service_name
    service := input.services[service_name]
    some port in service.ports
    not startswith(port, "127.0.0.1:")
    msg := sprintf("[Phase 5] Service '%v' binds port '%v' publicly. Bind explicitly to loopback (127.0.0.1:port:port)", [service_name, port])
}

# 6. Phase 6: Set memory and CPU limits
deny contains msg if {
    some service_name
    service := input.services[service_name]
    not service.deploy.resources.limits.memory
    msg := sprintf("[Phase 6] Service '%v' must define CPU and memory resource limits", [service_name])
}
