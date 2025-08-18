import { useState, useEffect } from "react";
import api from "@/lib/api";
import { SUPER_USER, MENU_DEFINITIONS } from "@/lib/constants";

interface User {
  id: string;
  email: string;
  name: string | null;
  officerCode: string | null;
  roleId: string;
  role: {
    id: string;
    name: string;
    description: string | null;
  };
}

interface RolePermission {
  id: string;
  roleId: string;
  menuId: string[];
  authType: string[];
  createdAt: string;
  updatedAt: string;
}

interface UserPermissions {
  user: User;
  permissions: Record<string, string>; // menuId -> F/R/N
}

export function usePermissions() {
  const [userPermissions, setUserPermissions] = useState<UserPermissions | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [isSuperUser, setIsSuperUser] = useState(false);

  useEffect(() => {
    fetchPermissions();
  }, []);

  const fetchPermissions = async () => {
    try {
      setIsLoading(true);
      setError(null);

      // storage मधून user व token घे
      const storedUser =
        JSON.parse(localStorage.getItem("user") || sessionStorage.getItem("user") || "{}") || null;
      const token = localStorage.getItem("token") || sessionStorage.getItem("token");

      if (!storedUser || !token) {
        setError("No authentication token or user found");
        setIsLoading(false);
        return;
      }

      // ✅ SUPER USER → Full access
      const isSuperUserFlag =
        localStorage.getItem("isSuperUser") || sessionStorage.getItem("isSuperUser");
      if (isSuperUserFlag === "true" && storedUser.email === SUPER_USER.email) {
        setIsSuperUser(true);

        const superPerms: UserPermissions = {
          user: storedUser,
          permissions: {},
        };

        MENU_DEFINITIONS.forEach((menu) => {
          superPerms.permissions[menu.id] = "F";
        });

        setUserPermissions(superPerms);
        setIsLoading(false);
        return;
      }

      // ✅ NORMAL USER → फक्त roleId वरून data आण
      const rolePermsResponse = await api.get(`/rolepermission?roleId=${storedUser.roleId}`);
      const rolePermissions: RolePermission[] = rolePermsResponse.data;

      if (!rolePermissions || rolePermissions.length === 0) {
        setError(`Role permissions not set for role: ${storedUser.role?.name}`);
        setUserPermissions({
          user: storedUser,
          permissions: {},
        });
        setIsLoading(false);
        return;
      }

      // roleId वरून permissions तयार कर
      const permissions: Record<string, string> = {};
      MENU_DEFINITIONS.forEach((menu) => {
        permissions[menu.id] = "N"; // default
      });

      rolePermissions.forEach((perm: RolePermission) => {
        perm.menuId.forEach((menuId, idx) => {
          if (perm.authType[idx]) {
            permissions[menuId] = perm.authType[idx];
          }
        });
      });

      setUserPermissions({
        user: storedUser,
        permissions,
      });
      setIsSuperUser(false);
    } catch (err) {
      console.error("Failed to load permissions", err);
      setError("Failed to load permissions");
    } finally {
      setIsLoading(false);
    }
  };

  // Helpers
  const hasPermission = (menuId: string, required: "F" | "R" = "R"): boolean => {
    if (isSuperUser) return true;
    if (!userPermissions) return false;

    const perm = userPermissions.permissions[menuId];
    if (!perm || perm === "N") return false;

    return required === "F" ? perm === "F" : perm === "F" || perm === "R";
  };

  const canAccess = (menuId: string) => hasPermission(menuId, "R");
  const canEdit = (menuId: string) => hasPermission(menuId, "F");
  const getMenuPermission = (menuId: string) =>
    isSuperUser ? "F" : userPermissions?.permissions[menuId] || "N";

  return {
    userPermissions,
    isLoading,
    error,
    hasPermission,
    canAccess,
    canEdit,
    getMenuPermission,
    user: userPermissions?.user || null,
    isSuperUser,
  };
}
