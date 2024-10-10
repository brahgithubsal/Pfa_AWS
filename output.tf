output "jenkins_vm_public_ip" {
  description = "Public IP address of the Jenkins VM"
  value       = aws_instance.jenkins.public_ip
}

output "k8s_vm_public_ip" {
  description = "Public IP address of the Kubernetes VM"
  value       = aws_instance.k8s_cluster.public_ip
}
