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
    <div className="max-w-md mx-auto p-6">
      <h2 className="text-xl mb-4">Sign in</h2>
      <form onSubmit={doLogin} className="flex flex-col gap-3">
        <input 
          className="p-2 bg-card rounded border border-red-800" 
          placeholder="Email or Username" 
          value={emailOrUsername} 
          onChange={e => setEmailOrUsername(e.target.value)} 
        />
        <input 
          type="password" 
          className="p-2 bg-card rounded border border-red-800" 
          placeholder="Password" 
          value={password} 
          onChange={e => setPassword(e.target.value)} 
        />
        {error && <div className="text-red-500 text-sm">{error}</div>}
        <div className="flex gap-2">
          <button 
            type="submit" 
            disabled={loading} 
            className="px-3 py-1 rounded bg-accent text-black disabled:opacity-50"
          >
            {loading ? 'Signing in...' : 'Sign in'}
          </button>
        </div>
      </form>
    </div>
  )
}

export default Login
