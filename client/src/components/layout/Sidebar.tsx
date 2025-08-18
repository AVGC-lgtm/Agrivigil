"use client";
import React from 'react';
import { Shield, Crown, AlertTriangle } from 'lucide-react';
import {
  Sidebar as ShadSidebar,
  SidebarHeader,
  SidebarContent,
  SidebarMenu,
  SidebarMenuItem,
  SidebarMenuButton,
  SidebarTrigger,
  SidebarFooter,
} from '@/components/ui/sidebar';
import { Button } from '@/components/ui/button';
import { TABS } from '@/lib/constants';
import { Badge } from '@/components/ui/badge';
interface AppSidebarProps {
  activeModule: string | null;
  onModuleChange: (moduleId: string) => void;
  userPermissions?: Record<string, string>; // menuId -> authType (F/R/N)
  isSuperUser?: boolean;
  rolePermissionsNotSet?: boolean;
}
export function AppSidebar({ activeModule, onModuleChange, userPermissions, isSuperUser, rolePermissionsNotSet }: AppSidebarProps) {
  // Filter tabs based on user permissions
  const filteredTabs = TABS.filter(tab => {
    if (isSuperUser) return true; // Super user sees all tabs
    if (rolePermissionsNotSet) return false; // No tabs if permissions not set
    if (!userPermissions) return true; // Show all if no permissions data
    const permission = userPermissions[tab.id];
    return permission && permission !== 'N'; // Hide if no permission or 'N' (None)
  });

  return (
    <ShadSidebar 
      collapsible="icon" 
      variant="sidebar" 
      side="left" 
      className="border-r"
    >
      <SidebarHeader className="p-2">
        {/* Expanded state - App Name with toggle button on right */}
        <div className="flex items-center gap-2 font-semibold text-lg text-sidebar-foreground group-data-[collapsible=icon]:hidden">
          <Button 
            variant="ghost" 
            size="icon" 
            className="rounded-lg bg-sidebar-accent text-sidebar-accent-foreground hover:bg-sidebar-accent/90"
          >
            <Shield className="h-6 w-6" />
          </Button>
          <span>AGRIVIGIL</span>
          <SidebarTrigger />
        </div>
        
        {/* Collapsed state - toggle button inside collapsed bar */}
        <div className="hidden group-data-[collapsible=icon]:flex justify-center">
          <SidebarTrigger />
        </div>
      </SidebarHeader>
      
      <SidebarContent>
        {/* Super User Indicator */}
        {isSuperUser && (
          <div className="px-3 py-2 mb-2">
            <Badge className="w-full justify-center bg-gradient-to-r from-yellow-500 to-orange-500 text-white border-0">
              <Crown className="h-3 w-3 mr-1" />
              SUPER ADMIN
            </Badge>
          </div>
        )}

        {/* Role Permissions Not Set Warning */}
        {rolePermissionsNotSet && (
          <div className="px-3 py-2 mb-2">
            <Badge className="w-full justify-center bg-orange-100 text-orange-800 border-orange-200">
              <AlertTriangle className="h-3 w-3 mr-1" />
              PERMISSIONS NOT SET
            </Badge>
          </div>
        )}
        
        <SidebarMenu>
          {filteredTabs.map((tab) => {
            const permission = userPermissions?.[tab.id];
            const isDisabled = !isSuperUser && (rolePermissionsNotSet || permission === 'N');
            
            return (
              <SidebarMenuItem key={tab.id}>
                <SidebarMenuButton
                  isActive={activeModule === tab.id}
                  aria-label={tab.ariaLabel}
                  tooltip={{ 
                    children: `${tab.text}${isSuperUser ? ' (Super Admin)' : rolePermissionsNotSet ? ' (No Permissions)' : permission ? ` (${permission === 'F' ? 'Full' : 'Read'})` : ''}`, 
                    side: "right", 
                    align: "center" 
                  }}
                  className={`justify-start cursor-pointer transition-colors ${
                    activeModule === tab.id 
                      ? 'bg-sidebar-accent text-sidebar-accent-foreground' 
                      : isDisabled 
                        ? 'opacity-50 cursor-not-allowed' 
                        : 'hover:bg-sidebar-accent/50'
                  }`}
                  onClick={() => !isDisabled && onModuleChange(tab.id)}
                  disabled={isDisabled}
                >
                  <tab.icon className="h-5 w-5" />
                  <span className="group-data-[collapsible=icon]:hidden">{tab.text}</span>
                  {isSuperUser ? (
                    <span className="ml-auto text-xs px-2 py-1 rounded bg-gradient-to-r from-yellow-500 to-orange-500 text-white group-data-[collapsible=icon]:hidden">
                      S
                    </span>
                  ) : rolePermissionsNotSet ? (
                    <span className="ml-auto text-xs px-2 py-1 rounded bg-orange-100 text-orange-800 group-data-[collapsible=icon]:hidden">
                      !
                    </span>
                  ) : permission && (
                    <span className={`ml-auto text-xs px-2 py-1 rounded ${
                      permission === 'F' 
                        ? 'bg-green-100 text-green-800' 
                        : 'bg-blue-100 text-blue-800'
                    } group-data-[collapsible=icon]:hidden`}>
                      {permission === 'F' ? 'F' : 'R'}
                    </span>
                  )}
                </SidebarMenuButton>
              </SidebarMenuItem>
            );
          })}
        </SidebarMenu>
      </SidebarContent>
      <SidebarFooter className="p-2 group-data-[collapsible=icon]:hidden">
        <div className="text-xs text-muted-foreground text-center text-white space-y-1">
          <div>© 2025 App Name</div>
          <div>Developed by Company</div>
          <div>Contact: contact@example.com</div>
        </div>
      </SidebarFooter>
    </ShadSidebar>
  );
}