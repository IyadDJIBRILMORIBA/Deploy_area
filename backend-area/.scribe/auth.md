# Authenticating requests

To authenticate requests, include an **`Authorization`** header with the value **`"Bearer Bearer {YOUR_AUTH_TOKEN}"`**.

All authenticated endpoints are marked with a `requires authentication` badge in the documentation below.

Pour obtenir un token, vous devez vous enregistrer via <code>POST /api/register</code> puis vous connecter via <code>POST /api/login</code>. Le token JWT retourné doit être inclus dans le header Authorization avec le préfixe Bearer.
