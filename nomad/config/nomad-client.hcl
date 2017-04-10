client {
  enabled         = true
  client_max_port = 15000

  options {
    "docker.cleanup.image"   = "0"
    "driver.raw_exec.enable" = "1"
  }

  meta {
    region       = "{{ region }}"
    machine_type = "{{ machine_type }}"
  }
}
