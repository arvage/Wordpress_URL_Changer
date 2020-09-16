#!/bin/bash

# On-Screen Colors
NC='\033[0m'            # No Color
RED='\033[1;31m'        # Light Red
YELLOW='\033[0;33m'     # Yellow
GREEN='\033[0;32m'      # Green


# Check if script is running under root 
if [[ "${UID}" -ne 0 ]]
then 
  echo;echo
  echo "${RED}You must be root to run this command." >&2
  echo "Please run it with sudo${NC}" >&2
  echo
  exit 1
fi

echo -e "${YELLOW}Enter your WordPress database name: (Hit enter to list all your database names)${NC}"
read DB

while [ -z "$DB" ]; do
    mysql -u root -e "show databases;"
    echo -e "${YELLOW}Enter your WordPress database name: (Select from the list above)${NC}"
    read DB
    if [ -z "$DB" ]; then
        clear
        echo -e "${RED}\nDatabase not set! try again${NC}\n"
    else
        echo -e "\nDatabase set to --> ${GREEN}$DB${NC}\n"
    fi
done

echo -e "${YELLOW}Enter Old Site URL/IP: (Example: http://192.168.234.111 or https://dev.contoso.com)${NC}"
read CURRENT_URL
echo -e "Old URL/IP Set to: ${GREEN}$CURRENT_URL${NC}\n"
echo -e "${YELLOW}Enter New Site URL/IP: (Example: http://64.216.171.240 or https://www.contoso.com)${NC}" 
read NEW_URL
echo -e "New URL/IP Set to: ${GREEN}$NEW_URL${NC}\n"
echo
echo -e "Updating ${GREEN}$CURRENT_URL ---> $NEW_URL${NC}"

mysql -u root $DB -e "UPDATE wp_options SET option_value = replace(option_value, '$CURRENT_URL', '$NEW_URL') WHERE option_name = 'home' OR option_name = 'siteurl';"

mysql -u root $DB -e "UPDATE wp_posts SET guid = replace(guid, '$CURRENT_URL','$NEW_URL');"

mysql -u root $DB -e "UPDATE wp_posts SET post_content = replace(post_content, '$CURRENT_URL', '$NEW_URL');"

mysql -u root $DB -e "UPDATE wp_postmeta SET meta_value = replace(meta_value,'$CURRENT_URL','$NEW_URL');"
echo -e "${GREEN}\n\nDone!${NC}"