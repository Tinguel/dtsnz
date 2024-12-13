#!/bin/bash

# Function to generate all IP addresses in a subnet using ipcalc
generate_ips() {
    
    # Account for /32 range
    if [[ $1 == */32 ]]; then
	echo "${1%/32}"
    else    
    # Extract Host min and Host max IPs
    hostmin=$(ipcalc -n "$1" | grep "HostMin" | awk '{print $2}')
    hostmax=$(ipcalc -n "$1" | grep "HostMax" | awk '{print $2}')

    # Convert IPs to numeric for range generation
    start=$(ip2int "$hostmin")
    end=$(ip2int "$hostmax")

    # Generate and print all IPs in the range
    for ((ip=start; ip<=end; ip++)); do
        int2ip "$ip"
	echo "$ip"
    done
    fi
}
#generate_ips "10.0.0.1/32"
# Convert IP to integer for easier range calculations
ip2int() {
    local ip="$1"
    local a b c d
    IFS=. read -r a b c d <<< "$ip"
    echo $((a * 256**3 + b * 256**2 + c * 256 + d))
}

# Convert integer back to IP address
int2ip() {
    local ip="$1"
    local a=$((ip / 256**3))
    local b=$((ip % 256**3 / 256**2))
    local c=$((ip % 256**2 / 256))
    local d=$((ip % 256))
    echo "$a.$b.$c.$d"
}

# File containing your subnets (one per line)
subnets_file="subnets.txt"

#generate_ips "10.2.2.0/29"

# Read subnets from the file and process each one
while read -r subnet; do
    echo "Checking subnet: $subnet"
    generate_ips "$subnet" | while read -r ip; do
        # Run dig for each IP, suppress empty output
        result=$(dig -x "$ip" +short)
        if [ -n "$result" ]; then
            echo "$ip: $result"
        fi
    done
done < "$subnets_file"
