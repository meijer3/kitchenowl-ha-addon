# KitchenOwl Add-on Documentation

## About

KitchenOwl is a self-hosted grocery list and recipe manager with real-time synchronization across multiple users.

Features:
- Real-time shopping list synchronization
- Recipe management and sharing
- Meal planning
- Expense tracking

## Installation

1. Add the repository to Home Assistant: `https://github.com/meijer3/kitchenowl-ha-addon`
2. Install the KitchenOwl add-on
3. Configure the JWT secret (see below)
4. Start the add-on

## Configuration

### jwt_secret (required)

This is a secure random string used for authentication tokens. You must generate a strong random string.

**Generate a secret:**

```bash
openssl rand -base64 32
```

**Add to configuration:**

```yaml
jwt_secret: "paste-your-generated-secret-here"
```

## First Run

1. After starting the add-on, click "Open Web UI"
2. Create your first user account
3. Start using KitchenOwl!

## Data Persistence

All data is stored in `/data` and persists across add-on restarts and updates. This includes:
- User accounts
- Shopping lists
- Recipes
- Uploaded images

## Accessing the Web Interface

- Click "Open Web UI" in the add-on info page
- Or visit: `http://homeassistant.local:8080`

## Troubleshooting

### Add-on won't start

Check the logs for errors. Common issues:
- JWT secret not configured
- Port 8080 already in use

### Can't access web interface

- Verify the add-on is running
- Check if port 8080 is accessible
- Try accessing via `http://[your-ha-ip]:8080`

### Data not persisting

- Check add-on logs for database errors
- Verify `/data` directory is writable

## Support

For issues with:
- **This add-on**: [Create an issue](https://github.com/meijer3/kitchenowl-ha-addon/issues)
- **KitchenOwl app**: [KitchenOwl GitHub](https://github.com/TomBursch/kitchenowl)
