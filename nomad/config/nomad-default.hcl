data_dir     = "{{ data_dir }}"
enable_debug = true
bind_addr    = "0.0.0.0"
region       = "{{ region }}"
datacenter   = "{{ datacenter }}"
name         = "{{ name }}"
log_level    = "{{ log_level }}"

advertise {
  http = "{{ local_ip }}:4646"
  rpc  = "{{ local_ip }}:4647"
  serf = "{{ local_ip }}:4648"
}
