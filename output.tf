output "az-1" {
  value = data.aws_availability_zones.az.names[0]

}

output "az-2" {
  value = data.aws_availability_zones.az.names[1]

}

output "az-3" {
  value = data.aws_availability_zones.az.names[2]

}
