## mongodb-session-deletion scripr: used to clear the session collection on our mongodb server.

#!/bin/bash

# =========================================================
# MongoDB Session Cleanup Script
# =========================================================

set -o pipefail

# =========================
# MongoDB Connection String
# =========================
MONGO_URI="xxxx"

# =========================
# Log Files
# =========================
MAIN_LOG_FILE="/var/log/mongodb-session-cleanup.log"
TMP_LOG_FILE="/tmp/mongodb-session-cleanup-$(date +%Y%m%d%H%M%S).log"

TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

echo "[$TIMESTAMP] Starting MongoDB session cleanup..." >> "$TMP_LOG_FILE"

# =========================================================
# Verify mongosh Exists
# =========================================================
if ! command -v mongosh >/dev/null 2>&1; then

    echo "ERROR: mongosh is not installed or not in PATH." >> "$TMP_LOG_FILE"

    cat "$TMP_LOG_FILE" >> "$MAIN_LOG_FILE"
    rm -f "$TMP_LOG_FILE"

    exit 1
fi

# =========================================================
# Execute Mongo Cleanup
# =========================================================

mongosh "$MONGO_URI" <<EOF >> "$TMP_LOG_FILE" 2>&1

// =====================================================
// NEXTGEN_IPO_API_1
// =====================================================
use NEXTGEN_IPO_API_1

db.SessionHistory.deleteMany({})

db.nextgen_session_0.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_1.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_2.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_3.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_4.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })

// =====================================================
// NEXTGEN_IPO_API_2
// =====================================================
use NEXTGEN_IPO_API_2

db.nextgen_session_5.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_6.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_7.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_8.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_9.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })

// =====================================================
// NEXTGEN_IPO_API_3
// =====================================================
use NEXTGEN_IPO_API_3

db.nextgen_session_10.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_11.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_12.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_13.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_14.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })

// =====================================================
// NEXTGEN_IPO_API_4
// =====================================================
use NEXTGEN_IPO_API_4

db.nextgen_session_15.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_16.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_17.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_18.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_19.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_20.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })
db.nextgen_session_21.deleteMany({ "SessionExpireAt": { \$lt: new Date() } })

EOF

# =========================================================
# Capture mongosh Exit Code
# =========================================================
EXIT_CODE=$?

# =========================================================
# Handle Errors
# =========================================================
if [ $EXIT_CODE -ne 0 ]; then

    echo "" >> "$TMP_LOG_FILE"
    echo "ERROR: MongoDB cleanup failed." >> "$TMP_LOG_FILE"

    if grep -qi "Authentication failed" "$TMP_LOG_FILE"; then
        echo "CAUSE: MongoDB authentication failed." >> "$TMP_LOG_FILE"

    elif grep -qi "ECONNREFUSED\|connect ECONNREFUSED" "$TMP_LOG_FILE"; then
        echo "CAUSE: Unable to connect to MongoDB server." >> "$TMP_LOG_FILE"

    elif grep -qi "timed out" "$TMP_LOG_FILE"; then
        echo "CAUSE: MongoDB connection timed out." >> "$TMP_LOG_FILE"

    else
        echo "CAUSE: Unknown MongoDB/mongosh error." >> "$TMP_LOG_FILE"
    fi

    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleanup failed." >> "$TMP_LOG_FILE"
    echo "==============================================================" >> "$TMP_LOG_FILE"

    # Append temp log to permanent log
    cat "$TMP_LOG_FILE" >> "$MAIN_LOG_FILE"

    # Delete temp log
    rm -f "$TMP_LOG_FILE"

    exit 1
fi

# =========================================================
# Success Logging
# =========================================================
echo "[$(date '+%Y-%m-%d %H:%M:%S')] MongoDB session cleanup completed successfully." >> "$TMP_LOG_FILE"
echo "==============================================================" >> "$TMP_LOG_FILE"

# =========================================================
# Append Temp Log to Permanent Log
# =========================================================
cat "$TMP_LOG_FILE" >> "$MAIN_LOG_FILE"

# =========================================================
# Delete Temp Log
# =========================================================
rm -f "$TMP_LOG_FILE"

exit 0
