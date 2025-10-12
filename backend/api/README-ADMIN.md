Creating an admin user (Prisma)

This repository has an optional helper script that creates an admin user in the MySQL database using Prisma.

1. Set environment variables (recommended):

```bash
cd api
export ADMIN_EMAIL=admin@example.com
export ADMIN_USERNAME=admin
export ADMIN_PASSWORD='StrongPass123!'
export BCRYPT_ROUNDS=12
```

On Windows (PowerShell):

```powershell
$env:ADMIN_EMAIL = 'admin@example.com'
$env:ADMIN_USERNAME = 'admin'
$env:ADMIN_PASSWORD = 'StrongPass123!'
$env:BCRYPT_ROUNDS = '12'
```

2. Run the script:

```bash
cd api
node scripts/create-admin-prisma.js
```

Notes
- The script hashes the password before creating the user.
- The project also has a Prisma middleware in `src/prisma/client.js` that will hash passwords on Prisma `create`/`update` for the `user` model. This script hashes explicitly to avoid relying on middleware order.
- Do not commit your admin password to source control. Use environment variables.
