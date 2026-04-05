# Task is to take input via sys.argv 
# Process it through our python 
# Python uses API to analyze the input

import requests
import sys

target_ip = sys.argv[1]

# I forgot how this was suppose to work
'''
if len(sys.argv) < 1:
    print("Error Arugment is less than 1")
    exit
else:
    pass
    '''

def abuseIP(ip):
    
    # Abuse url
    api_url = "https://api.abuseipdb.com/api/v2/check"

    # Essential Header
    response_header = {"Accept" : "application/json",
                       "Key" : "<API_Key>"}
    # Our query (We just want the IP)
    response_query = {"ipAddress" : f"{ip}"}

    # This is incase we get error and we want to know what it is
    # In this cause if it takes too long to reach the Endpoint it will give us a message telling us so
    # This way if an error related to reaching the endpoint occurs, we will know that it is that instead of wondering what went wrong
    try:
        response = requests.get(api_url, headers=response_header, params=response_query, timeout= 3)
        # print("Endpoint Reached") for testing. Bash doesn't like reading text
    except requests.exceptions.ReadTimeout:
        # print("Endpoint Took to Long to Reach") Testing
        return None

    # We first have to check if the website has been reached or not
    # Response code 200 means Ok
    if response.status_code == 200:
        # print("Data Retrived Successfully") Testing
        ip_data = response.json() # Here is where the data from the website will be stored
        return ip_data
    else:
        # This is, in my opinion, really good for troubleshooting
        # If it just says can't reach we might not know what to do but when we return that message with the response code its better
        print(f"Unable to Retrive Data Status Code:{response.status_code}")

    # For Testing
    # print(f"Here is your IP {ip}")

# This is so that if we anyone imports our code they wont see our 'main function' because that is our personal code and where we do our testing
if __name__ == "__main__":
    abuse_info = abuseIP(target_ip)
    

    if abuse_info:
        # We need to use single quotes and send back scores rather than strings since bash will have a hard time reading
        print(f"{abuse_info['data']['abuseConfidenceScore']}")

