addresses {
  rpc  = "{{ local_ip }}"
  serf = "{{ local_ip }}"
}

server {
  enabled          = true
  bootstrap_expect = {{ bootstrap_expect }}
  heartbeat_grace  = "30s"
}
