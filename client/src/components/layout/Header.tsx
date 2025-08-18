"use client";
import React from "react";
import { useRouter } from "next/navigation";
import { Moon, Sun, Bell, ChevronsUpDown, Crown } from "lucide-react";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
  DropdownMenuSeparator,
} from "@/components/ui/dropdown-menu";
import { Avatar, AvatarFallback, AvatarImage } from "@/components/ui/avatar";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { Badge } from "@/components/ui/badge";
import { SUPER_USER } from "@/lib/constants";

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

interface AppHeaderProps {
  user?: User;
}

export function AppHeader({ user }: AppHeaderProps) {
  const router = useRouter();
  const isSuperUser = user?.email === SUPER_USER.email;
  
  // Client-only logout
  const handleLogout = () => {
    // Remove stored token or session info
    localStorage.removeItem("token");
    sessionStorage.removeItem("token");
    localStorage.removeItem("user");
    sessionStorage.removeItem("user");
    // Redirect to signin page
    router.push("/auth/signin");
  };

  const getUserInitials = () => {
    if (user?.name) {
      return user.name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    }
    if (user?.officerCode) {
      return user.officerCode.slice(0, 2).toUpperCase();
    }
    return user?.email?.slice(0, 2).toUpperCase() || 'U';
  };

  return (
    <header className="sticky top-0 z-30 flex h-14 items-center gap-2 sm:gap-4 border-b bg-background px-3 sm:px-4 py-3 sm:py-4">
      <SidebarTrigger className="md:hidden" />
      <div className="flex items-center gap-3 grow">
        <h2 className="text-lg sm:text-xl font-semibold truncate">
          {user ? `Welcome, ${user.name || user.officerCode || 'User'}` : 'Page Title'}
        </h2>
        {isSuperUser && (
          <Badge className="bg-gradient-to-r from-yellow-500 to-orange-500 text-white border-0">
            <Crown className="h-3 w-3 mr-1" />
            SUPER ADMIN
          </Badge>
        )}
      </div>

      <div className="flex items-center space-x-1.5 sm:space-x-3 md:space-x-4">
        <Button
          variant="ghost"
          size="icon"
          aria-label="Toggle theme"
          className="h-8 w-8 sm:h-9 sm:w-9"
        >
          <Sun className="h-4 w-4 sm:h-5 sm:w-5" />
        </Button>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              variant="ghost"
              size="icon"
              aria-label="Notifications"
              className="relative h-8 w-8 sm:h-9 sm:w-9"
            >
              <Bell className="h-4 w-4 sm:h-5 sm:w-5" />
              <span className="absolute top-0.5 sm:top-1 right-0.5 sm:right-1 h-2.5 w-2.5 sm:h-3 sm:w-3 bg-red-500 rounded-full text-[8px] sm:text-xs flex items-center justify-center text-white">
                3
              </span>
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-64 sm:w-80 text-xs sm:text-sm">
            <DropdownMenuItem>Notification 1</DropdownMenuItem>
            <DropdownMenuItem>Notification 2</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>

        <DropdownMenu>
          <DropdownMenuTrigger asChild>
            <Button
              variant="ghost"
              className="relative h-8 sm:h-9 w-auto px-1.5 sm:px-2 gap-1 sm:gap-2"
            >
              <Avatar className="h-6 w-6 sm:h-7 sm:w-7">
                <AvatarImage
                  src="https://placehold.co/40x40.png?text=U"
                  alt={user?.name || 'User'}
                />
                <AvatarFallback>{getUserInitials()}</AvatarFallback>
              </Avatar>
              <div className="hidden md:flex flex-col items-start">
                <span className="text-xs font-medium">
                  {user?.name || user?.officerCode || 'User'}
                </span>
                {isSuperUser ? (
                  <Badge variant="secondary" className="text-xs bg-gradient-to-r from-yellow-500 to-orange-500 text-white">
                    <Crown className="h-3 w-3 mr-1" />
                    SUPER ADMIN
                  </Badge>
                ) : user?.role && (
                  <Badge variant="secondary" className="text-xs">
                    {user.role.name}
                  </Badge>
                )}
              </div>
              <ChevronsUpDown className="h-3 w-3 sm:h-4 sm:w-4 text-muted-foreground hidden md:inline-block" />
            </Button>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="text-xs sm:text-sm">
            {user && (
              <>
                <div className="px-2 py-1.5">
                  <p className="text-sm font-medium">{user.name || user.officerCode}</p>
                  <p className="text-xs text-muted-foreground">{user.email}</p>
                  {isSuperUser ? (
                    <p className="text-xs text-muted-foreground">Role: Super Administrator</p>
                  ) : user.role && (
                    <p className="text-xs text-muted-foreground">Role: {user.role.name}</p>
                  )}
                </div>
                <DropdownMenuSeparator />
              </>
            )}
            <DropdownMenuItem>Profile</DropdownMenuItem>
            <DropdownMenuItem onClick={handleLogout}>Logout</DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
