# KitchenOwl Add-on

Self-hosted grocery list and recipe manager for Home Assistant.

## Configuration

**jwt_secret** (required)

A secure random string for authentication. Generate one with:

```bash
openssl rand -base64 32
```

Example:
```yaml
jwt_secret: "your-generated-secret-here"
```

## Usage

1. Configure the JWT secret
2. Start the add-on
3. Open the Web UI
4. Create your first user account
5. Start managing your shopping lists and recipes!

## Support

- [KitchenOwl Documentation](https://github.com/TomBursch/kitchenowl)
- [Report Issues](https://github.com/meijer3/kitchenowl-ha-addon/issues)
