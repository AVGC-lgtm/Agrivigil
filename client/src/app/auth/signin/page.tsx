'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { APP_NAME, COMPANY_INFO, SUPER_USER } from '@/lib/constants'
import { Crown, Shield, Building2, Leaf, Users, Phone, Mail, MapPin, Loader2 } from 'lucide-react'
import api from '@/lib/api'

export default function SignIn() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [error, setError] = useState('')
  const [loading, setLoading] = useState(false)
  const [showSuperUser, setShowSuperUser] = useState(false)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const res = await api.post('/auth/login', { email, password })
      const { token, user } = res.data
      sessionStorage.setItem('token', token);
      sessionStorage.setItem('user', JSON.stringify(user));
      router.push('/dashboard')
    } catch (err: any) {
      setError(err.response?.data?.message || 'Login failed')
    } finally {
      setLoading(false)
    }
  }

  const handleSuperUserLogin = (e: React.FormEvent) => {
    e.preventDefault()
    setError('')

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
  }

  const toggleSuperUser = () => {
    setShowSuperUser(!showSuperUser);
    setEmail('');
    setPassword('');
    setError('');
  }

  return (
    <div className="min-h-screen bg-gradient-to-br from-green-50 via-blue-50 to-indigo-50">
      {/* Full Screen Loader Overlay */}
      {loading && (
        <div className="fixed inset-0 bg-black/50 backdrop-blur-sm z-50 flex items-center justify-center">
          <div className="bg-white rounded-2xl p-8 shadow-2xl flex flex-col items-center space-y-4">
            <div className="relative">
              <div className="w-16 h-16 bg-gradient-to-r from-green-500 to-blue-600 rounded-full flex items-center justify-center">
                <Shield className="h-8 w-8 text-white" />
              </div>
              <div className="absolute inset-0 rounded-full border-4 border-transparent border-t-green-500 border-r-blue-600 animate-spin"></div>
            </div>
            <div className="text-center">
              <h3 className="text-lg font-semibold text-gray-900">Authenticating...</h3>
              <p className="text-sm text-gray-600">Please wait while we verify your credentials</p>
            </div>
            <div className="flex items-center space-x-2 text-sm text-gray-500">
              <Loader2 className="h-4 w-4 animate-spin" />
              <span>Redirecting to dashboard</span>
            </div>
          </div>
        </div>
      )}
      
      {/* Header */}
      <header className="bg-white/80 backdrop-blur-sm border-b border-green-200/50 shadow-sm">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center space-x-3">
              <div className="p-2 bg-gradient-to-r from-green-500 to-blue-600 rounded-lg">
                <Shield className="h-8 w-8 text-white" />
              </div>
              <div>
                <h1 className="text-2xl font-bold bg-gradient-to-r from-green-600 to-blue-600 bg-clip-text text-transparent">
                  {APP_NAME}
                </h1>
                <p className="text-xs text-gray-600">Agricultural Vigilance System</p>
              </div>
            </div>
            <div className="hidden md:flex items-center space-x-6 text-sm text-gray-600">
              <div className="flex items-center space-x-2">
                <Building2 className="h-4 w-4 text-green-600" />
                <span>Government Portal</span>
              </div>
              <div className="flex items-center space-x-2">
                <Leaf className="h-4 w-4 text-blue-600" />
                <span>AgriTech Solutions</span>
              </div>
            </div>
          </div>
        </div>
      </header>

      {/* Main Content */}
      <main className="flex-1 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8">
        <div className="w-full max-w-md">
          {/* Login Card */}
          <Card className="w-full shadow-2xl border-0 bg-white/90 backdrop-blur-sm">
            <CardHeader className="space-y-3 pb-6">
              <div className="text-center">
                <div className="mx-auto w-16 h-16 bg-gradient-to-r from-green-500 to-blue-600 rounded-full flex items-center justify-center mb-4">
                  <Shield className="h-8 w-8 text-white" />
                </div>
                <CardTitle className="text-3xl font-bold bg-gradient-to-r from-green-600 to-blue-600 bg-clip-text text-transparent">
                  {showSuperUser ? 'Super User Access' : 'Welcome Back'}
                </CardTitle>
                <CardDescription className="text-gray-600 mt-2">
                  {showSuperUser ? 'Access the system with administrative privileges' : 'Sign in to your account to continue'}
                </CardDescription>
              </div>
            </CardHeader>
            
            <CardContent className="space-y-6">
              <form onSubmit={showSuperUser ? handleSuperUserLogin : handleSubmit} className="space-y-5">
                {error && (
                  <Alert variant="destructive" className="border-red-200 bg-red-50">
                    <AlertDescription className="text-red-800">{error}</AlertDescription>
                  </Alert>
                )}

                <div className="space-y-2">
                  <Label htmlFor="email" className="text-sm font-medium text-gray-700">
                    Email Address
                  </Label>
                  <div className="relative">
                    <Mail className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                      id="email"
                      name="email"
                      type="email"
                      autoComplete="email"
                      value={email}
                      onChange={(e) => setEmail(e.target.value)}
                      required
                      className="pl-10 h-12 border-gray-200 focus:border-green-500 focus:ring-green-500 bg-gray-50/50"
                      placeholder={showSuperUser ? "Enter super user email" : "Enter your email address"}
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="password" className="text-sm font-medium text-gray-700">
                    Password
                  </Label>
                  <div className="relative">
                    <Shield className="absolute left-3 top-1/2 transform -translate-y-1/2 h-4 w-4 text-gray-400" />
                    <Input
                      id="password"
                      name="password"
                      type="password"
                      autoComplete="current-password"
                      value={password}
                      onChange={(e) => setPassword(e.target.value)}
                      required
                      className="pl-10 h-12 border-gray-200 focus:border-green-500 focus:ring-green-500 bg-gray-50/50"
                      placeholder={showSuperUser ? "Enter super user password" : "Enter your password"}
                    />
                  </div>
                </div>

                                 <Button 
                   type="submit" 
                   className={`w-full h-12 text-base font-semibold transition-all duration-200 ${
                     showSuperUser 
                       ? 'bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600 shadow-lg hover:shadow-xl' 
                       : 'bg-gradient-to-r from-green-500 to-blue-600 hover:from-green-600 hover:to-blue-700 shadow-lg hover:shadow-xl'
                   }`} 
                   disabled={loading}
                 >
                   {showSuperUser && <Crown className="h-5 w-5 mr-2" />}
                   {loading ? (
                     <div className="flex items-center space-x-2">
                       <Loader2 className="h-5 w-5 animate-spin" />
                       <span>Signing in...</span>
                     </div>
                   ) : (
                     showSuperUser ? 'Super User Login' : 'Sign In'
                   )}
                 </Button>
              </form>

              {/* Toggle Button */}
              <div className="text-center">
                <Button
                  type="button"
                  variant="outline"
                  size="sm"
                  onClick={toggleSuperUser}
                  className="text-sm border-gray-200 hover:border-green-300 hover:bg-green-50"
                >
                  {showSuperUser ? '← Switch to Regular Login' : '👑 Switch to Super User Access'}
                </Button>
              </div>


            </CardContent>
          </Card>
        </div>
      </main>

      {/* Footer */}
      <footer className="bg-white/80 backdrop-blur-sm border-t border-green-200/50 mt-auto">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            {/* Company Info */}
            <div className="space-y-3">
              <div className="flex items-center space-x-2">
                <Shield className="h-6 w-6 text-green-600" />
                <h3 className="text-lg font-semibold text-gray-900">{APP_NAME}</h3>
              </div>
              <p className="text-sm text-gray-600">
                Advanced Agricultural Vigilance and Monitoring System for Government Agencies
              </p>
            </div>

            {/* Contact Info */}
            <div className="space-y-3">
              <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Contact Information</h3>
              <div className="space-y-2 text-sm text-gray-600">
                <div className="flex items-center space-x-2">
                  <Building2 className="h-4 w-4 text-green-600" />
                  <span>{COMPANY_INFO.name}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Phone className="h-4 w-4 text-blue-600" />
                  <span>{COMPANY_INFO.contact}</span>
                </div>
                <div className="flex items-center space-x-2">
                  <Mail className="h-4 w-4 text-indigo-600" />
                  <span>support@agrivigil.com</span>
                </div>
              </div>
            </div>

            {/* Quick Links */}
            <div className="space-y-3">
              <h3 className="text-sm font-semibold text-gray-900 uppercase tracking-wide">Quick Links</h3>
              <div className="space-y-2 text-sm text-gray-600">
                <div className="hover:text-green-600 cursor-pointer transition-colors">Privacy Policy</div>
                <div className="hover:text-green-600 cursor-pointer transition-colors">Terms of Service</div>
                <div className="hover:text-green-600 cursor-pointer transition-colors">Help & Support</div>
                <div className="hover:text-green-600 cursor-pointer transition-colors">System Status</div>
              </div>
            </div>
          </div>

          {/* Bottom Bar */}
          <div className="mt-8 pt-6 border-t border-gray-200">
            <div className="flex flex-col md:flex-row justify-between items-center space-y-4 md:space-y-0">
              <div className="text-sm text-gray-600">
                {COMPANY_INFO.copyright}
              </div>
              <div className="flex items-center space-x-6 text-sm text-gray-600">
                <span>Version 2.0.1</span>
                <span>•</span>
                <span>Last updated: August 2025</span>
              </div>
            </div>
          </div>
        </div>
      </footer>
    </div>
  )
}