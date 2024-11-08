#!/bin/bash

# Function to display services
display_services() {
  echo "Available services:"
  psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services" | while read SERVICE_ID BAR NAME; do
    echo "$SERVICE_ID) $NAME"
  done
}

# Main script to book appointments
book_appointment() {
  display_services

  # Prompt for service selection
  echo -e "\nPlease select a service by entering the service_id:"
  read SERVICE_ID_SELECTED

  # Check if the service_id is valid
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nInvalid selection. Please choose a valid service."
    book_appointment
  else
    # Prompt for phone number
    echo -e "\nEnter your phone number:"
    read CUSTOMER_PHONE

    # Check if customer exists
    CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # If new customer, prompt for name and add to customers table
    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nEnter your name:"
      read CUSTOMER_NAME
      psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (name, phone) VALUES ('$CUSTOMER_NAME', '$CUSTOMER_PHONE')"
    fi

    # Get customer_id
    CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'")

    # Prompt for appointment time
    echo -e "\nEnter appointment time:"
    read SERVICE_TIME

    # Insert the appointment
    psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')"

    # Output confirmation message
    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

# Execute the appointment booking function
book_appointment
