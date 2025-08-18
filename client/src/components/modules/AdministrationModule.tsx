"use client";

import React, { useState, useEffect } from "react";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { Tabs, TabsList, TabsTrigger, TabsContent } from "@/components/ui/tabs";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import {
  Select,
  SelectTrigger,
  SelectValue,
  SelectContent,
  SelectItem,
} from "@/components/ui/select";
import { Badge } from "@/components/ui/badge";
import { MENU_DEFINITIONS, AUTH_TYPES, SUPER_USER } from "@/lib/constants";
import { useToast } from "@/hooks/use-toast";
import api from "@/lib/api";

interface Role {
  id: string;
  name: string;
  description: string | null;
  createdAt: string;
  updatedAt: string;
}

interface RolePermission {
  id: string;
  roleId: string;
  menuId: string[];
  authType: string[];
  createdAt: string;
  updatedAt: string;
}

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
  createdAt: string;
  updatedAt: string;
}

export default function AdministrationModule() {
  const { toast } = useToast();
  const [isSuperUser, setIsSuperUser] = useState(false);
  const [hasData, setHasData] = useState(true);
  const [isLoading, setIsLoading] = useState(false);
  
  // Check if current user is super user
  useEffect(() => {
    const isSuperUserFlag = localStorage.getItem('isSuperUser') || sessionStorage.getItem('isSuperUser');
    const currentUser = JSON.parse(localStorage.getItem('user') || sessionStorage.getItem('user') || '{}');
    setIsSuperUser(isSuperUserFlag === 'true' && currentUser.email === SUPER_USER.email);
    
    // Check if there's any data in the system
    checkSystemData();
  }, []);

  const checkSystemData = async () => {
    try {
      setIsLoading(true);
      // Try to fetch roles to see if system has data
      const rolesRes = await api.get("/role");
      if (rolesRes.data && rolesRes.data.length > 0) {
        setRoles(rolesRes.data);
        try {
          const usersRes = await api.get("/users");
          if (usersRes.data) {
            setUsers(usersRes.data);
          }
        } catch (userError) {
          console.log("No users found yet");
        }
      }
    } catch (error) {
      // If API fails, system has no data yet - but interface is still shown
      console.log("No existing data found, system needs setup");
    } finally {
      setIsLoading(false);
    }
  };

  /** ===================== ROLES TAB ===================== **/
  const [roles, setRoles] = useState<Role[]>([]);
  const [roleName, setRoleName] = useState("");
  const [roleDesc, setRoleDesc] = useState("");
  const [editingRoleId, setEditingRoleId] = useState<string | null>(null);
  const [isSubmitting, setIsSubmitting] = useState(false);

  const fetchRoles = async () => {
    try {
      const res = await api.get("/role");
      setRoles(res.data);
    } catch (error) {
      console.error("Failed to fetch roles", error);
      toast({
        title: "Error",
        description: "Failed to fetch roles. Please try again.",
        variant: "destructive",
      });
    }
  };

  useEffect(() => {
    if (hasData) {
      fetchRoles();
    }
  }, [hasData]);

  const handleRoleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    try {
      if (editingRoleId) {
        await api.put("/role", { id: editingRoleId, name: roleName, description: roleDesc });
        toast({
          title: "Success",
          description: "Role updated successfully!",
        });
        setEditingRoleId(null);
      } else {
        await api.post("/role", { name: roleName, description: roleDesc });
        toast({
          title: "Success",
          description: "Role created successfully!",
        });
      }
      setRoleName("");
      setRoleDesc("");
      fetchRoles();
    } catch (error: any) {
      console.error("Failed to save role", error);
      toast({
        title: "Error",
        description: error.response?.data?.error || "Failed to save role. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsSubmitting(false);
    }
  };

  const handleEditRole = (role: Role) => {
    setEditingRoleId(role.id);
    setRoleName(role.name);
    setRoleDesc(role.description || "");
  };

  const handleCancelEdit = () => {
    setEditingRoleId(null);
    setRoleName("");
    setRoleDesc("");
  };

  /** ===================== ROLE PERMISSIONS TAB ===================== **/
  const [rolePermissions, setRolePermissions] = useState<RolePermission[]>([]);
  const [selectedRoleId, setSelectedRoleId] = useState<string>("");
  const [permissionForm, setPermissionForm] = useState<Record<string, string>>({});
  const [isPermissionSubmitting, setIsPermissionSubmitting] = useState(false);

  const fetchRolePermissions = async (roleId?: string) => {
    try {
      const url = roleId ? `/rolepermission?roleId=${roleId}` : "/rolepermission";
      const res = await api.get(url);
      setRolePermissions(res.data);
    } catch (error) {
      console.error("Failed to fetch role permissions", error);
      toast({
        title: "Error",
        description: "Failed to fetch role permissions. Please try again.",
        variant: "destructive",
      });
    }
  };

  const handleRoleChange = async (roleId: string) => {
    setSelectedRoleId(roleId);
    if (roleId) {
      await fetchRolePermissions(roleId);
      
      // Initialize permission form with default "N" for all menus
      const initialPermissions: Record<string, string> = {};
      MENU_DEFINITIONS.forEach(menu => {
        initialPermissions[menu.id] = "N";
      });
      setPermissionForm(initialPermissions);
      
      // Load existing permissions for this role
      try {
        const res = await api.get(`/rolepermission?roleId=${roleId}`);
        const existingPermissions = res.data;
        
        if (existingPermissions && existingPermissions.length > 0) {
          // Find the permission record for this role
          const rolePermission = existingPermissions.find((p: RolePermission) => p.roleId === roleId);
          
          if (rolePermission) {
            // Map existing permissions to form
            const loadedPermissions: Record<string, string> = { ...initialPermissions };
            
            rolePermission.menuId.forEach((menuId, index) => {
              const authType = rolePermission.authType[index];
              if (menuId && authType) {
                loadedPermissions[menuId] = authType;
              }
            });
            
            setPermissionForm(loadedPermissions);
          }
        }
      } catch (error) {
        console.error("Failed to load existing permissions", error);
        // Keep default "N" permissions if loading fails
      }
    }
  };

  const handlePermissionChange = (menuId: string, authType: string) => {
    setPermissionForm(prev => ({
      ...prev,
      [menuId]: authType
    }));
  };

  const handleSavePermissions = async () => {
    if (!selectedRoleId) return;
    
    setIsPermissionSubmitting(true);
    try {
      // Save all permissions for this role at once
      await api.post("/rolepermission", {
        roleId: selectedRoleId,
        permissions: permissionForm
      });
      
      toast({
        title: "Success",
        description: "Role permissions saved successfully!",
      });
      
      // Refresh permissions list
      fetchRolePermissions(selectedRoleId);
    } catch (error: any) {
      console.error("Failed to save permissions", error);
      toast({
        title: "Error",
        description: error.response?.data?.error || "Failed to save permissions. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsPermissionSubmitting(false);
    }
  };

  /** ===================== USERS TAB ===================== **/
  const [users, setUsers] = useState<User[]>([]);
  const [editingUserId, setEditingUserId] = useState<string | null>(null);
  const [isUserSubmitting, setIsUserSubmitting] = useState(false);
  const [userForm, setUserForm] = useState({
    id: "",
    employeeId: "",
    name: "",
    email: "",
    password: "",
    roleId: ""
  });

  const fetchUsers = async () => {
    try {
      const res = await api.get("/users");
      setUsers(res.data);
    } catch (error) {
      console.error("Failed to fetch users", error);
      toast({
        title: "Error",
        description: "Failed to fetch users. Please try again.",
        variant: "destructive",
      });
    }
  };

  useEffect(() => {
    if (hasData) {
      fetchUsers();
    }
  }, [hasData]);

  const handleUserSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsUserSubmitting(true);
    try {
      if (editingUserId) {
        await api.put("/users", {
          id: editingUserId,
          email: userForm.email,
          name: userForm.name,
          password: userForm.password,
          roleId: userForm.roleId,
          officerCode: userForm.employeeId
        });
        toast({
          title: "Success",
          description: "User updated successfully!",
        });
        setEditingUserId(null);
      } else {
        await api.post("/users", {
          email: userForm.email,
          name: userForm.name,
          password: userForm.password,
          roleId: userForm.roleId,
          officerCode: userForm.employeeId
        });
        toast({
          title: "Success",
          description: "User created successfully!",
        });
      }
      
      // Reset form
      setUserForm({
        id: "",
        employeeId: "",
        name: "",
        email: "",
        password: "",
        roleId: ""
      });
      
      fetchUsers();
    } catch (error: any) {
      console.error("Failed to save user", error);
      toast({
        title: "Error",
        description: error.response?.data?.error || "Failed to save user. Please try again.",
        variant: "destructive",
      });
    } finally {
      setIsUserSubmitting(false);
    }
  };

  const handleEditUser = (user: User) => {
    setEditingUserId(user.id);
    setUserForm({
      id: user.id,
      employeeId: user.officerCode || "",
      name: user.name || "",
      email: user.email,
      password: "",
      roleId: user.roleId
    });
  };

  const handleCancelUserEdit = () => {
    setEditingUserId(null);
    setUserForm({
      id: "",
      employeeId: "",
      name: "",
      email: "",
      password: "",
      roleId: ""
    });
  };

  const getAuthTypeLabel = (authType: string) => {
    switch (authType) {
      case "F": return "Full";
      case "R": return "Read";
      case "N": return "None";
      default: return "None";
    }
  };

  const getAuthTypeColor = (authType: string) => {
    switch (authType) {
      case "F": return "bg-green-100 text-green-800";
      case "R": return "bg-blue-100 text-blue-800";
      case "N": return "bg-gray-100 text-gray-800";
      default: return "bg-gray-100 text-gray-800";
    }
  };

  return (
    <div className="p-4">
      {/* Super User Banner */}
      {isSuperUser && (
        <div className="mb-6 p-4 bg-gradient-to-r from-yellow-500 to-orange-500 rounded-lg text-white">
          <div className="flex items-center gap-3">
            <div className="text-2xl">👑</div>
            <div>
              <h2 className="text-lg font-semibold">Super Administrator Access</h2>
              <p className="text-sm opacity-90">
                You have full system access and can manage all roles, permissions, and users.
              </p>
            </div>
          </div>
        </div>
      )}

      <Tabs defaultValue="roles" className="w-full">
        <TabsList className="grid grid-cols-3 w-full mb-4">
          <TabsTrigger value="roles">Roles</TabsTrigger>
          <TabsTrigger value="permissions">Role Permissions</TabsTrigger>
          <TabsTrigger value="users">Users</TabsTrigger>
        </TabsList>

        {/* ===================== ROLES TAB ===================== */}
        <TabsContent value="roles">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                {editingRoleId ? "Update Role" : "Create Role"}
                {isSuperUser && (
                  <Badge variant="secondary" className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                    Super Admin
                  </Badge>
                )}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4" onSubmit={handleRoleSubmit}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label>Role Name</Label>
                    <Input
                      value={roleName}
                      onChange={(e) => setRoleName(e.target.value)}
                      placeholder="Enter role name"
                      required
                    />
                  </div>
                  <div>
                    <Label>Description</Label>
                    <Input
                      value={roleDesc}
                      onChange={(e) => setRoleDesc(e.target.value)}
                      placeholder="Enter description"
                    />
                  </div>
                </div>
                <div className="flex gap-2">
                  <Button type="submit" disabled={isSubmitting}>
                    {isSubmitting ? "Saving..." : (editingRoleId ? "Update Role" : "Add Role")}
                  </Button>
                  {editingRoleId && (
                    <Button type="button" variant="outline" onClick={handleCancelEdit}>
                      Cancel
                    </Button>
                  )}
                </div>
              </form>
            </CardContent>
          </Card>

          <Card className="mt-6">
            <CardHeader>
              <CardTitle>Roles List</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <div className="relative w-full overflow-auto">
                  <Table className="text-sm w-full">
                    <TableHeader className="sticky top-0 bg-background z-10">
                      <TableRow>
                        <TableHead className="w-16">#</TableHead>
                        <TableHead>Name</TableHead>
                        <TableHead>Description</TableHead>
                        <TableHead>Created</TableHead>
                        <TableHead>Action</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody className="max-h-[300px] overflow-y-auto">
                      {roles.map((r, index) => (
                        <TableRow key={r.id} className="hover:bg-muted/50">
                          <TableCell className="py-2">{index + 1}</TableCell>
                          <TableCell className="py-2 font-medium">{r.name}</TableCell>
                          <TableCell className="py-2">{r.description || "-"}</TableCell>
                          <TableCell className="py-2 text-sm text-muted-foreground">
                            {new Date(r.createdAt).toLocaleDateString()}
                          </TableCell>
                          <TableCell className="py-2">
                            <Button size="sm" variant="outline" onClick={() => handleEditRole(r)}>
                              Edit
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* ===================== ROLE PERMISSIONS TAB ===================== */}
        <TabsContent value="permissions">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                Assign Role Permissions
                {isSuperUser && (
                  <Badge variant="secondary" className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                    Super Admin
                  </Badge>
                )}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <div className="grid gap-4">
                <div>
                  <Label>Select Role</Label>
                  <Select value={selectedRoleId} onValueChange={handleRoleChange}>
                    <SelectTrigger>
                      <SelectValue placeholder="Choose role" />
                    </SelectTrigger>
                    <SelectContent>
                      {roles.map((r) => (
                        <SelectItem key={r.id} value={r.id}>
                          {r.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>

                {selectedRoleId && (
                  <>
                    <div className="grid gap-2">
                      {MENU_DEFINITIONS.map((menu) => {
                        const currentPermission = permissionForm[menu.id] || "N";
                        return (
                          <div
                            key={menu.id}
                            className={`flex items-center justify-between border p-3 rounded-lg ${
                              currentPermission === "N" ? "bg-gray-50" : 
                              currentPermission === "F" ? "bg-green-50 border-green-200" : 
                              "bg-blue-50 border-blue-200"
                            }`}
                          >
                            <div>
                              <span className="font-medium">{menu.name}</span>
                              <p className="text-sm text-muted-foreground">{menu.description}</p>
                              <span className={`text-xs px-2 py-1 rounded-full ${
                                currentPermission === "F" ? "bg-green-100 text-green-800" :
                                currentPermission === "R" ? "bg-blue-100 text-blue-800" :
                                "bg-gray-100 text-gray-600"
                              }`}>
                                Current: {currentPermission === "F" ? "Full Access" : 
                                         currentPermission === "R" ? "Read Only" : "No Access"}
                              </span>
                            </div>
                            <div className="flex gap-4">
                              {Object.entries(AUTH_TYPES).map(([key, value]) => (
                                <label key={key} className="flex items-center gap-2 cursor-pointer">
                                  <input
                                    type="radio"
                                    name={`permission-${menu.id}`}
                                    value={value}
                                    checked={permissionForm[menu.id] === value}
                                    onChange={() => handlePermissionChange(menu.id, value)}
                                    className="accent-blue-500"
                                  />
                                  <span className={`text-sm font-medium ${
                                    permissionForm[menu.id] === value ? 
                                      (value === "F" ? "text-green-700" : 
                                       value === "R" ? "text-blue-700" : "text-gray-700") : 
                                      "text-gray-500"
                                  }`}>
                                    {key}
                                  </span>
                                </label>
                              ))}
                            </div>
                          </div>
                        );
                      })}
                    </div>
                    <div className="flex gap-2 items-center">
                      <Button 
                        onClick={handleSavePermissions} 
                        disabled={isPermissionSubmitting}
                        className="w-fit"
                      >
                        {isPermissionSubmitting ? "Saving..." : "Save Permissions"}
                      </Button>
                      <span className="text-sm text-muted-foreground">
                        {Object.values(permissionForm).filter(p => p === "F").length} Full, {" "}
                        {Object.values(permissionForm).filter(p => p === "R").length} Read, {" "}
                        {Object.values(permissionForm).filter(p => p === "N").length} None
                      </span>
                    </div>
                  </>
                )}
              </div>
            </CardContent>
          </Card>

          <Card className="mt-6">
            <CardHeader>
              <CardTitle>Role Permissions List</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <div className="relative w-full overflow-auto">
                  <Table className="text-sm w-full">
                    <TableHeader className="sticky top-0 bg-background z-10">
                      <TableRow>
                        <TableHead className="w-16">ID</TableHead>
                        <TableHead>Role</TableHead>
                        <TableHead>Menu</TableHead>
                        <TableHead>Permission</TableHead>
                        <TableHead>Updated</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody className="max-h-[400px] overflow-y-auto">
                      {rolePermissions.map((p) => (
                        <TableRow key={p.id} className="hover:bg-muted/50">
                          <TableCell className="py-2">{p.id}</TableCell>
                          <TableCell className="py-2">
                            {roles.find(r => r.id === p.roleId)?.name || p.roleId}
                          </TableCell>
                          <TableCell className="py-2">
                            <div className="space-y-1">
                              {p.menuId.map((menuId, index) => {
                                const menu = MENU_DEFINITIONS.find(m => m.id === menuId);
                                const authType = p.authType[index];
                                return (
                                  <div key={index} className="flex items-center gap-2">
                                    <span className="text-sm">{menu ? menu.name : menuId}</span>
                                    <Badge 
                                      className={`${getAuthTypeColor(authType)}`}
                                    >
                                      {getAuthTypeLabel(authType)}
                                    </Badge>
                                  </div>
                                );
                              })}
                            </div>
                          </TableCell>
                          <TableCell className="py-2">
                            <div className="flex gap-1 flex-wrap">
                              {p.authType.map((auth, index) => (
                                <Badge 
                                  key={index} 
                                  className={`${getAuthTypeColor(auth)}`}
                                >
                                  {getAuthTypeLabel(auth)}
                                </Badge>
                              ))}
                            </div>
                          </TableCell>
                          <TableCell className="py-2 text-sm text-muted-foreground">
                            {new Date(p.updatedAt).toLocaleDateString()}
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* ===================== USERS TAB ===================== */}
        <TabsContent value="users">
          <Card>
            <CardHeader>
              <CardTitle className="flex items-center gap-2">
                {editingUserId ? "Update User" : "Create User"}
                {isSuperUser && (
                  <Badge variant="secondary" className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                    Super Admin
                  </Badge>
                )}
              </CardTitle>
            </CardHeader>
            <CardContent>
              <form className="grid gap-4" onSubmit={handleUserSubmit}>
                <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                  <div>
                    <Label>Officer Code</Label>
                    <Input 
                      placeholder="00001" 
                      value={userForm.employeeId}
                      onChange={(e) => setUserForm({...userForm, employeeId: e.target.value})}
                      required
                    />
                  </div>
                  <div>
                    <Label>Name</Label>
                    <Input 
                      placeholder="Enter name" 
                      value={userForm.name}
                      onChange={(e) => setUserForm({...userForm, name: e.target.value})}
                      required
                    />
                  </div>
                  <div>
                    <Label>Email</Label>
                    <Input 
                      type="email" 
                      placeholder="Enter email" 
                      value={userForm.email}
                      onChange={(e) => setUserForm({...userForm, email: e.target.value})}
                      required
                    />
                  </div>
                  <div>
                    <Label>Password {editingUserId && "(leave blank to keep current)"}</Label>
                    <Input 
                      type="password" 
                      placeholder="Enter password" 
                      value={userForm.password}
                      onChange={(e) => setUserForm({...userForm, password: e.target.value})}
                      required={!editingUserId}
                    />
                  </div>
                </div>
                
                <div>
                  <Label>Select Role</Label>
                  <Select
                    value={userForm.roleId}
                    onValueChange={(value) => setUserForm({...userForm, roleId: value})}
                  >
                    <SelectTrigger>
                      <SelectValue placeholder="Choose role" />
                    </SelectTrigger>
                    <SelectContent>
                      {roles.map((r) => (
                        <SelectItem key={r.id} value={r.id}>
                          {r.name}
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
                
                <div className="flex gap-2">
                  <Button type="submit" disabled={isUserSubmitting}>
                    {isUserSubmitting ? "Saving..." : (editingUserId ? "Update User" : "Create User")}
                  </Button>
                  {editingUserId && (
                    <Button type="button" variant="outline" onClick={handleCancelUserEdit}>
                      Cancel
                    </Button>
                  )}
                </div>
              </form>
            </CardContent>
          </Card>

          <Card className="mt-6">
            <CardHeader>
              <CardTitle>Users List</CardTitle>
            </CardHeader>
            <CardContent>
              <div className="rounded-md border">
                <div className="relative w-full overflow-auto">
                  <Table className="text-sm w-full">
                    <TableHeader className="sticky top-0 bg-background z-10">
                      <TableRow>
                        <TableHead className="w-16">ID</TableHead>
                        <TableHead>Officer Code</TableHead>
                        <TableHead>Name</TableHead>
                        <TableHead>Email</TableHead>
                        <TableHead>Role</TableHead>
                        <TableHead>Created</TableHead>
                        <TableHead>Action</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody className="max-h-[400px] overflow-y-auto">
                      {users.map((u) => (
                        <TableRow key={u.id} className="hover:bg-muted/50">
                          <TableCell className="py-2">{u.id}</TableCell>
                          <TableCell className="py-2 font-medium">{u.officerCode || "-"}</TableCell>
                          <TableCell className="py-2">{u.name || "-"}</TableCell>
                          <TableCell className="py-2">{u.email}</TableCell>
                          <TableCell className="py-2">
                            {u.email === SUPER_USER.email ? (
                              <Badge variant="secondary" className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                                👑 SUPER ADMIN
                              </Badge>
                            ) : (
                              <Badge variant="secondary">{u.role.name}</Badge>
                            )}
                          </TableCell>
                          <TableCell className="py-2 text-sm text-muted-foreground">
                            {new Date(u.createdAt).toLocaleDateString()}
                          </TableCell>
                          <TableCell className="py-2">
                            <Button size="sm" variant="outline" onClick={() => handleEditUser(u)}>
                              Edit
                            </Button>
                          </TableCell>
                        </TableRow>
                      ))}
                    </TableBody>
                  </Table>
                </div>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}