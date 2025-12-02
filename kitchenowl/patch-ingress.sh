#!/bin/bash
# Patch KitchenOwl's index.html to work with Home Assistant ingress

INGRESS_ENTRY="$1"
INDEX_FILE="/var/www/web/kitchenowl/index.html"

if [ -z "$INGRESS_ENTRY" ]; then
    echo "No ingress entry provided, skipping patch"
    exit 0
fi

echo "Patching index.html for ingress: ${INGRESS_ENTRY}"

# Backup original if not already backed up
if [ ! -f "${INDEX_FILE}.original" ]; then
    cp "${INDEX_FILE}" "${INDEX_FILE}.original"
fi

# Restore from backup to ensure clean patching
cp "${INDEX_FILE}.original" "${INDEX_FILE}"

# Update base href
sed -i "s|<base href=\"/\">|<base href=\"${INGRESS_ENTRY}/\">|g" "${INDEX_FILE}"

# Update script and link references to be relative
sed -i 's|src="/|src="|g' "${INDEX_FILE}"
sed -i 's|href="/|href="|g' "${INDEX_FILE}"

echo "Index.html patched successfully"
