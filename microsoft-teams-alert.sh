#!/bin/bash

#
# Checks for server and db availability
##################
# Teams Workflow Webhook
####################################################
WEBHOOK_URL="http://xxxx"
####################################################
# Configuration
####################################################
SERVER_NAME="Falcon DB Server"
SERVER_IP="x.x.x.x"
DB_PORT="x.x.x.x"

####################################################
# Check Server Reachability
####################################################
if ping -c 2 -W 2 "$SERVER_IP" >/dev/null 2>&1; then
    SERVER_STATUS="🟢 UP"
else
    SERVER_STATUS="🔴 DOWN"
fi

####################################################
# Check Database Port
####################################################
if nc -z -w 3 "$SERVER_IP" "$DB_PORT" >/dev/null 2>&1; then
    DB_STATUS="🟢 UP"
else
    DB_STATUS="🔴 DOWN"
fi

####################################################
# Date
####################################################
CHECK_TIME=$(date '+%d %b %Y %H:%M:%S')

####################################################
# Build Adaptive Card
####################################################
PAYLOADCHECK=$(cat <<EOF
{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "content": {
        "type": "AdaptiveCard",
        "version": "1.5",
        "body": [
          {
            "type": "TextBlock",
            "text": "Server Health Check",
            "weight": "Bolder",
            "size": "Large"
          },
          {
            "type": "FactSet",
            "facts": [
              {
                "title": "Server",
                "value": "${SERVER_NAME}"
              },
              {
                "title": "IP Address",
                "value": "${SERVER_IP}"
              },
              {
                "title": "Server Status",
                "value": "${SERVER_STATUS}"
              },
              {
                "title": "Database Port",
                "value": "${DB_PORT}"
              },
              {
                "title": "Database Status",
                "value": "${DB_STATUS}"
              },
              {
                "title": "Checked At",
                "value": "${CHECK_TIME}"
              }
            ]
          }
        ]
      }
    }
  ]
}
EOF
)

####################################################
# Send to Teams
####################################################
HTTP_CODE=$(curl \
    --silent \
    --output /dev/null \
    --write-out "%{http_code}" \
    -X POST \
    -H "Content-Type: application/json" \
    -d "$PAYLOADCHECK" \
    "$WEBHOOK_URL")

if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "202" ]; then
    echo "Teams notification sent successfully."
else
    echo "Failed to send Teams notification. HTTP Status: $HTTP_CODE"
fi

if [ "$SERVER_STATUS" = "🔴 DOWN" ] || [ "$DB_STATUS" = "🔴 DOWN" ]; then
      echo "Health check failed. Exiting..."
      exit 1
fi

###############################
# END OF CHECKS
################################


####START OF DB ROW COUNT
####################################################
# PostgreSQL Configuration
####################################################
DB_HOST="x.x.x.x"
DB_PORT="xxxx"
DB_NAME="xxxx"
DB_USER="xxxx"
DB_PASSWORD="xxxxxx"

TABLE_NAME="xxxxxxxx"

####################################################
# Teams Workflow Webhook
####################################################
# WEBHOOK_URL="xxxx"
####################################################
# Export Password
####################################################
export PGPASSWORD="$DB_PASSWORD"

####################################################
# Query
####################################################
ROW_COUNT=$(psql \
    -h "$DB_HOST" \
    -p "$DB_PORT" \
    -U "$DB_USER" \
    -d "$DB_NAME" \
    -tA \
    -c "SELECT COUNT(*) FROM vol.${TABLE_NAME};")

EXIT_CODE=$?

unset PGPASSWORD

####################################################
# Validate Query
####################################################
if [ $EXIT_CODE -ne 0 ]; then
    echo "Failed to retrieve row count."
    exit 1
fi

####################################################
# Build Adaptive Card
####################################################
PAYLOAD=$(cat <<EOF
{
  "type": "message",
  "attachments": [
    {
      "contentType": "application/vnd.microsoft.card.adaptive",
      "content": {
        "type": "AdaptiveCard",
        "version": "1.5",
        "body": [
          {
            "type": "TextBlock",
            "text": "Database: ${DB_NAME} | Table: ${TABLE_NAME}",
            "weight": "Bolder",
            "size": "Small"
          },
          {
            "type": "TextBlock",
            "text": "The row count is => ${ROW_COUNT}",
            "weight": "Bolder",
            "size": "Large"
          }
        ]
      }
    }
  ]
}
EOF
)

####################################################
# Send to Teams
####################################################
echo "$PAYLOAD"

curl \
    --silent \
    --show-error \
    --fail \
    -H "Content-Type: application/json" \
    -X POST \
    -d "$PAYLOAD" \
    "$WEBHOOK_URL"

if [ $? -eq 0 ]; then
    echo "Message sent successfully."
else
    echo "Failed to send Teams message."
    exit 1
fi
