output "control_plane_public_ip" {
  description = "Public IP address of the Control Plane node."
  value       = aws_instance.control_plane.public_ip
}

output "worker_nodes_public_ips" {
  description = "Public IP addresses of the Worker nodes."
  value       = aws_instance.worker_nodes[*].public_ip
}