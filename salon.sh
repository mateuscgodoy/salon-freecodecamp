#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~ Welcome to FreeCutSalon ~~~~\n"

MAIN_MENU() {
  echo "Checkout our available services:"

  SERVICES=$($PSQL "SELECT * FROM services;")

  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  echo -e "\nPlease enter the service number:"

  read SERVICE_ID_SELECTED

  MAX_SERVICE_ID=$($PSQL "SELECT MAX(service_id) FROM services;")
  
  if [[ $SERVICE_ID_SELECTED -gt $MAX_SERVICE_ID || $SERVICE_ID_SELECTED -lt 1 ]]
  then
    MAIN_MENU
  else
    echo -e "\nOkay. Now I need you to enter your phone number:"

    read CUSTOMER_PHONE

    CUSTOMER_RECORD=$($PSQL "SELECT * FROM customers WHERE phone='$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_RECORD ]]
    then
      echo -e "\nThat's a new phone number.\nPlease enter your name so we can complete your registration."

      read CUSTOMER_NAME

      INSERT_NEW_CUSTOMER=$($PSQL "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME');")

      if [[ $INSERT_NEW_CUSTOMER == "INSERT 0 1" ]]
      then
        echo -e "\nRegistration complete. Welcome, $CUSTOMER_NAME."
      else
        # should end the application?
        echo -e "\nSomething went wrong with our system. Please try contact support."
        exit 1
      fi
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")
    
    echo -e "\nPlease enter the time you would like to schedule your appointment.\nExamples: 10:30, 8am"

    read SERVICE_TIME

    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');")



    if [[ $INSERT_APPOINTMENT == "INSERT 0 1" ]]
    then
      SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
      CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE customer_id=$CUSTOMER_ID;")
      echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -E 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')."
    else
        # should end the application, again?
        echo -e "\nSomething went wrong with our system. Please try contact support."
        exit 2
    fi
  fi

}

MAIN_MENU