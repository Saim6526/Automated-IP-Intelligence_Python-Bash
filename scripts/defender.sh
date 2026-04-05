#!/bin/bash

# These are best practices for a resilient scripting
# -e exits immediately if a command returns a none-zero value
# -u exits if the script tries to use an undefined variables
# -o exits if a command in a pipe ( <cmd_1> | <cmd_2>) fails, the entire command is considered a faliure
set -euo pipefail



# This will always be running because we don't want to stop any internal services from running
sudo iptables -A INPUT -i lo -j ACCEPT


# The function will take in an arguement (IP) that needs to be blocked.
# This will be done using 'iptables'
# I will add a whitelist and blacklist along side with a command for allowing interal services to run
sanitize(){ 


	# Here it takes positional arguments (first one) and stores it in our local variable (This variable cant be used outside)
	# The functions needs to be called like this 'sanitize <ip>'
	local ip=$1

	# This will give you your current IP
	local personal_ip=$(hostname -I | awk '{print $1}')
    	
	# This is for remembering
	# whiteips=("127.0.0.1" "$personalip")

	# 127.0.0.1 is a standard IPv4 Loopback address to allow you internal services to talk to each other
	if [[ $ip == "127.0.0.1" || $ip == $personal_ip ]]; then
		echo "[*]Local IP Detected: $ip"
		return 0 # This is for an if statment to return if to say everything is good. In a loop we would use continue for skipping  
	else
		
		# Here we are drop any IP that is not whitelisted or has a score above 50 (check scanner)
		sudo iptables -A INPUT -s $ip -j DROP
		
		# Afters its been dropped the IP is sent to a file called blocklist
		echo "$ip" >> blocklist.txt
	fi

	# This won't work sadly
	# whitelist=$(sudo iptables -A INPUT -s ${whiteips[@]} -j ACCEPT) 

	# Lets first make a command to block ip
	# I want to put this is the 'scanner' functions 'if statement' where if the score is above 50 the IP gets sent here
	# Where it will be dropped (For the first 3-5 tries) after which it will be blocked
	# The trick now is to know how many times a malicious IP has tried to get access or tried to interact
	



}

# I will be storing different processes in different function for efficincy 
# I will use tail -F to monitor the logs in real time and awk to extrat the ips 
# Ensure the script doesn't blast abuseIPDB with 1000+ request in under a minute and get our key banned

scanner(){


	# The 'fakelog.sh' file is create fake logs and storing them in 'logfile.txt'
	# We will store the path into fakelog_file for a cleaner look
	fakelog_file="/path/to/file/logfile.txt"

	# We are using tail to read the fakelog file then passing it through a while read loop
	# This will cause the program to keep reading till the file end (it won't)


	# We will use an associative array to ensure that we don't waste our credits on repeated IPS
  # If there were an IP that attacked us 1000x then we would be out of creadit, so we will save it so that we dont have to scan it over and over again

	# We declare it outside the loop because we don't want it to reset per line (tail -F)
	declare -A scanned_ip



	# Everytime tail reads a log from 'fakelogs' it gets stored in 'file_log'
	tail -F $fakelog_file | while read -r file_logs; do
	

	  # Here we are print the variable file_log and reading the last then first word in their repected column
	  # We had to use echo since awk can't go and grab the item stored in a variable
		# In the 'fakelog' file that I created IP is the first vaule
		current_ip=$(echo "$file_logs" | awk '{print $1}')
	
		# Lets first check if the IP is already present in the blocklist
		# If it is then there is no need to continue with that loop and waste our API credit,  we skip to the next one
		# You don't need brackets [] for writting grep commands
	
		if  grep -q "$current_ip" "blocklist.txt" ;then
			echo "[!] IP:$current_ip is already present in blocklist. Skipping Local Scan"
			continue
		fi


		# We will need to check first if the IP is already listed 
		# If it is then we skip the scanning and continue
		if [[ -v scanned_ip["$current_ip"]  ]];then
      echo "[!] This IP: $current_ip has already been cleared"
			continue # This ends the loop and starts it again. This is especially helpful since we don't need to scan it again
		fi
		
		ip_score=$(python3 brain_1.py $current_ip)
		

		# Refer to test_file.sh
                # key value pair
		# We will pair it up now since it passed the first if statement
                # Again default value (ip_score:-0 defaults to 0 if no value returned) to avoid errors
		scanned_ip+=( ["$current_ip"]="${ip_score:-0}")
		
		# This is for testing
		# echo "${scanned_ip[@]} ${!scanned_ip[@]}"

			# Again default value to avoid errors
			# Here it checks if the score returned by AbuseIPDB is above 50
			# If it is then it calls the 'sanitize' function giving it the IP with the score above 50 as its first argument
			if (( ${ip_score:-0} >= 50)); then
				echo "[*] IP: $current_ip has a score above 50"
				echo "[*] Sending to blocklist.txt"
				sanitize $current_ip
			else
				# If the IP score is not above 50 then it gives us a message saying it good to pass
				echo "[*] IP: $current_ip is clean"
			fi

		# Since we are working with APIs now, we need to be careful to not overload our API with requests
                # This could get us banned or the api would stop taking the requests
		# So we will use the sleep command which in this case will help us by giving a delay (I set it to 1 second)
		sleep 1

	done
}

# Calling the scanner function
scanner
