-- Check if roles table exists and what roles are in it
SELECT 
    id,
    name,
    description,
    created_at
FROM roles
ORDER BY name;

-- If the above query fails with "relation roles does not exist", 
-- then run fix_roles_for_registration.sql first
