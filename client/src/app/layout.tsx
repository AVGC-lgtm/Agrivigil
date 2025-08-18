import type { Metadata } from "next";
import { Geist, Geist_Mono } from "next/font/google";
import "./globals.css";
import { Toaster } from "@/components/ui/toaster";

// Load Google Fonts as CSS variables
const geistSans = Geist({
  variable: "--font-geist-sans",
  subsets: ["latin"],
});

const geistMono = Geist_Mono({
  variable: "--font-geist-mono",
  subsets: ["latin"],
});

export const metadata: Metadata = {
  title: "Agrivigil - Agricultural Monitoring System",
  description: "Comprehensive agricultural monitoring and enforcement system",
};

// Client-only cleaner to remove extension attributes
function ExtensionAttributeCleaner() {
  if (typeof window !== "undefined") {
    document.body.removeAttribute("cz-shortcut-listen");
  }
  return null;
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html
      lang="en"
      className={`${geistSans.variable} ${geistMono.variable} antialiased`}
    >
      <body suppressHydrationWarning>
        <ExtensionAttributeCleaner />
        {children}
        <Toaster />
      </body>
    </html>
  );
}
