"use client";

import React, { useState } from "react";
import { useRouter } from "next/navigation";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Card, CardHeader, CardTitle, CardContent } from "@/components/ui/card";
import { SUPER_USER } from "@/lib/constants";
import { Crown } from "lucide-react";

export default function SuperUserLogin() {
  const router = useRouter();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState("");

  const handleSuperUserLogin = (e: React.FormEvent) => {
    e.preventDefault();
    setError("");

    if (email === SUPER_USER.email && password === SUPER_USER.password) {
      // Create super user session data
      const superUserData = {
        id: 'super-user',
        email: SUPER_USER.email,
        name: SUPER_USER.name,
        officerCode: SUPER_USER.officerCode,
        roleId: 'super-role',
        role: {
          id: 'super-role',
          name: SUPER_USER.role,
          description: 'Super Administrator with full system access'
        }
      };

      // Store super user data in localStorage (no API token needed)
      localStorage.setItem('user', JSON.stringify(superUserData));
      localStorage.setItem('isSuperUser', 'true');
      sessionStorage.setItem('user', JSON.stringify(superUserData));
      sessionStorage.setItem('isSuperUser', 'true');

      // Redirect to dashboard
      router.push('/dashboard');
    } else {
      setError("Invalid super user credentials");
    }
  };

  return (
    <div className="min-h-screen flex items-center justify-center bg-gray-50">
      <Card className="w-full max-w-md">
        <CardHeader className="text-center">
          <div className="flex items-center justify-center mb-4">
            <Crown className="h-12 w-12 text-yellow-500" />
          </div>
          <CardTitle className="text-2xl">Super User Access</CardTitle>
          <p className="text-sm text-muted-foreground mt-2">
            Emergency system access for administrators
          </p>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleSuperUserLogin} className="space-y-4">
            <div>
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                placeholder="Enter super user email"
                required
              />
            </div>
            <div>
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                placeholder="Enter super user password"
                required
              />
            </div>
            
            {error && (
              <div className="text-red-500 text-sm text-center">{error}</div>
            )}

            <Button type="submit" className="w-full bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600">
              <Crown className="h-4 w-4 mr-2" />
              Super User Login
            </Button>

            <div className="text-xs text-center text-muted-foreground">
              <p>Super User Credentials:</p>
              <p>Email: {SUPER_USER.email}</p>
              <p>Password: {SUPER_USER.password}</p>
            </div>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
