# KitchenOwl Home Assistant Add-on

Run KitchenOwl, a self-hosted grocery list and recipe manager, directly in your Home Assistant!

## About

KitchenOwl is a smart grocery list and recipe manager that helps you organize your household:

- 🛒 **Real-time Shopping Lists** - Sync across multiple users
- 📝 **Recipe Management** - Store and share your favorite recipes
- 📅 **Meal Planning** - Plan your weekly meals
- 💰 **Expense Tracking** - Track household shopping expenses
- 📱 **Multi-platform** - Use on mobile, web, or desktop

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "KitchenOwl" add-on
3. Configure the JWT secret (see below)
4. Start the add-on
5. Access via the web UI button or `http://homeassistant.local:8080`

## Configuration

### Required

**jwt_secret** (required)

A secure random string for authentication. Generate one with:

```bash
openssl rand -base64 32
```

Example configuration:

```yaml
jwt_secret: "your-generated-secret-here"
```

### Optional

You can access KitchenOwl at:
- Direct: `http://homeassistant.local:8080`
- Or click "Open Web UI" in the add-on info page

## First Run

1. After starting the add-on, open the web interface
2. Create your first user account
3. Start adding items to your shopping list!

## Data Persistence

All your data (shopping lists, recipes, user accounts) is stored persistently in the `/data` directory managed by Home Assistant. Your data will survive add-on updates and restarts.

## Support

For issues related to:
- **This add-on**: Open an issue in this repository
- **KitchenOwl itself**: Visit [KitchenOwl GitHub](https://github.com/TomBursch/kitchenowl)
- **Home Assistant**: Visit [Home Assistant Community](https://community.home-assistant.io/)

## Links

- [KitchenOwl GitHub Repository](https://github.com/TomBursch/kitchenowl)
- [Home Assistant Add-on Documentation](https://developers.home-assistant.io/docs/add-ons/)
