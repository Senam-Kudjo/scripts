## I wrote this script to be checking the row count for a particular table on our postgresql server
## this script retrieves the row count then sends it us in our Teams group as an alert
## the script was exectued through a cronjob that runs at 4am,12pm and 5pm every single day => 0 4,12,17 * * * /opt/script/falcon-db-checker/db-fetcher.sh
## the whole purpose of this was to ensure we stopped manually checking the row count ourserlves

#!/bin/bash

####################################################
# PostgreSQL Configuration
####################################################
DB_HOST="x.x.x.x"
DB_PORT="xxxx"
DB_NAME="xxxxx"
DB_USER="xxxxx"
DB_PASSWORD="xxxxx"

TABLE_NAME="xxxx"

####################################################
# Teams Workflow Webhook
####################################################
#insert your microsoft teams generated webhook url in the WEBHOOK_URL value
WEBHOOK_URL="xxx"
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
