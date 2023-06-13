#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~ The Salon ~~"
echo -e "\nPlease select a service:\n"

MAIN_MENU() {
  # get all the services offered from the database
  SERVICES_OFFERED=$($PSQL "SELECT * FROM services")
  # loop through each service
  echo -e "$SERVICES_OFFERED" | while read SERVICE_ID BAR NAME
  do
    # display the service in the proper format
    echo "$SERVICE_ID) $NAME"
  done
  read SERVICE_ID_SELECTED
  SERVICE_ID_SELECTED_LOOKUP=$($PSQL "SELECT service_id FROM services WHERE service_id = '$SERVICE_ID_SELECTED'")
  # if not found
  if [[ -z $SERVICE_ID_SELECTED_LOOKUP ]]
  then
    # return to the main menu
    MAIN_MENU
  else
    # get the customer's phone number
    echo -e "\nPlease enter your phone number:"
    read CUSTOMER_PHONE
    # get customer name
    CUSTOMER_NAME_LOOKUP=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # if not found
    if [[ -z $CUSTOMER_NAME_LOOKUP ]]
    then
      echo -e "\nThat phone number is not yet on file. Please enter your name:"
      read CUSTOMER_NAME
      # insert into customer table
      INSERT_CUSTOMER_INFO=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # set the appointment info
    APPOINTMENT_INFO
  fi
}

#appointment info function
APPOINTMENT_INFO() {
  echo -e "\nPlease enter the time for your appointment:"
  read SERVICE_TIME
  CUSTOMER_ID_LOOKUP=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  SERVICE_NAME_LOOKUP=$($PSQL "SELECT name FROM services WHERE service_id = '$SERVICE_ID_SELECTED_LOOKUP'") 
  INSERT_SERVICE=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ('$CUSTOMER_ID_LOOKUP', '$SERVICE_ID_SELECTED_LOOKUP', '$SERVICE_TIME')")
  echo -e "\nI have put you down for a$SERVICE_NAME_LOOKUP at $SERVICE_TIME, $CUSTOMER_NAME."
  EXIT
}

# exit program function
EXIT() {
  echo -e "\nThanks for stopping in.\n"
}

MAIN_MENU
