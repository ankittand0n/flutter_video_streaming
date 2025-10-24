import React, { useState } from 'react'
import api from '../services/api'

const Login: React.FC<{ onSuccess: (token: string) => void }> = ({ onSuccess }) => {
  const [emailOrUsername, setEmailOrUsername] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')

  async function doLogin(e: React.FormEvent) {
    e.preventDefault()
    setLoading(true)
    setError('')
    try {
      const res = await api.login(emailOrUsername, password)
      if (res && res.token) {
        onSuccess(res.token)
      } else {
        setError(res.error || 'Login failed')
      }
    } catch (err) {
      console.error(err)
      setError('Network error occurred')
    } finally { setLoading(false) }
  }

  return (
    <div className="max-w-md mx-auto p-6 bg-card rounded-lg border border-accent-secondary/20">
      <h2 className="text-2xl font-semibold mb-6 text-foreground">Sign in</h2>
      <form onSubmit={doLogin} className="flex flex-col gap-4">
        <input 
          className="p-3 bg-background-2 rounded-lg border border-accent-secondary focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors text-foreground" 
          placeholder="Email or Username" 
          value={emailOrUsername} 
          onChange={e => setEmailOrUsername(e.target.value)} 
        />
        <input 
          type="password" 
          className="p-3 bg-background-2 rounded-lg border border-accent-secondary focus:border-accent focus:ring-1 focus:ring-accent outline-none transition-colors text-foreground" 
          placeholder="Password" 
          value={password} 
          onChange={e => setPassword(e.target.value)} 
        />
        {error && <div className="text-accent text-sm bg-accent/10 p-2 rounded border border-accent/20">{error}</div>}
        <div className="flex gap-2">
          <button 
            type="submit" 
            disabled={loading} 
            className="px-4 py-2 rounded-lg bg-accent text-white font-medium hover:bg-accent-secondary disabled:opacity-50 disabled:cursor-not-allowed transition-colors flex-1"
          >
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </div>
      </form>
    </div>
  )
}

export default Login
