'use client'
import { useState } from 'react'
import { useRouter } from 'next/navigation'
import { Button } from '@/components/ui/button'
import { Input } from '@/components/ui/input'
import { Label } from '@/components/ui/label'
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card'
import { Alert, AlertDescription } from '@/components/ui/alert'
import { APP_NAME, COMPANY_INFO, SUPER_USER } from '@/lib/constants'
import { Crown } from 'lucide-react'
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
    <div className="min-h-screen flex items-center justify-center bg-gray-50 py-12 px-4 sm:px-6 lg:px-8">
      <Card className="w-full max-w-md">
        <CardHeader className="space-y-1">
          <CardTitle className="text-2xl font-bold text-center">{APP_NAME}</CardTitle>
          <CardDescription className="text-center">
            {showSuperUser ? 'Super User Access' : 'Sign in to your account'}
          </CardDescription>
        </CardHeader>
        <CardContent>
          <form onSubmit={showSuperUser ? handleSuperUserLogin : handleSubmit} className="space-y-4">
            {error && (
              <Alert variant="destructive">
                <AlertDescription>{error}</AlertDescription>
              </Alert>
            )}

            <div className="space-y-2">
              <Label htmlFor="email">Email</Label>
              <Input
                id="email"
                name="email"
                type="email"
                autoComplete="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                required
                placeholder={showSuperUser ? "Enter super user email" : "Enter your email"}
              />
            </div>

            <div className="space-y-2">
              <Label htmlFor="password">Password</Label>
              <Input
                id="password"
                name="password"
                type="password"
                autoComplete="current-password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                required
                placeholder={showSuperUser ? "Enter super user password" : "Enter your password"}
              />
            </div>

            <Button 
              type="submit" 
              className={`w-full ${showSuperUser ? 'bg-gradient-to-r from-yellow-500 to-orange-500 hover:from-yellow-600 hover:to-orange-600' : ''}`} 
              disabled={loading}
            >
              {showSuperUser && <Crown className="h-4 w-4 mr-2" />}
              {loading ? 'Signing in...' : showSuperUser ? 'Super User Login' : 'Sign In'}
            </Button>
          </form>

          {/* Toggle Button */}
          <div className="mt-4 text-center">
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={toggleSuperUser}
              className="text-xs"
            >
              {showSuperUser ? '← Regular Login' : '👑 Super User Access'}
            </Button>
          </div>

          {/* Super User Info */}
          {showSuperUser && (
            <div className="mt-4 p-4 bg-gradient-to-r from-yellow-50 to-orange-50 rounded-lg border border-yellow-200">
              <h3 className="font-semibold text-sm mb-2 flex items-center gap-2">
                <Crown className="h-4 w-4 text-yellow-600" />
                Super User Credentials:
              </h3>
              <div className="text-xs space-y-1 text-yellow-800">
                <div><strong>Email:</strong> {SUPER_USER.email}</div>
                <div><strong>Password:</strong> {SUPER_USER.password}</div>
                <div className="mt-2 text-yellow-700">
                  <strong>Note:</strong> Super user bypasses all role permissions and has full system access.
                </div>
              </div>
            </div>
          )}

          {/* Demo Accounts */}
          {!showSuperUser && (
            <div className="mt-6 p-4 bg-blue-50 rounded-lg">
              <h3 className="font-semibold text-sm mb-2">Demo Accounts:</h3>
              <div className="text-xs space-y-1">
                <div><strong>DAO:</strong> dao@agrishield.com</div>
                <div><strong>Field Officer:</strong> field@agrishield.com</div>
                <div><strong>Legal Officer:</strong> legal@agrishield.com</div>
                <div><strong>Lab Coordinator:</strong> lab@agrishield.com</div>
                <div><strong>HQ Monitoring:</strong> hq@agrishield.com</div>
                <div><strong>District Admin:</strong> admin@agrishield.com</div>
                <div className="mt-2"><strong>Password:</strong> password123</div>
              </div>
            </div>
          )}

          <div className="mt-4 text-center text-xs text-gray-500">
            <div>© 2024 {APP_NAME}</div>
            <div>Developed by {COMPANY_INFO.name}</div>
            <div>Contact: {COMPANY_INFO.contact}</div>
          </div>
        </CardContent>
      </Card>
    </div>
  )
}