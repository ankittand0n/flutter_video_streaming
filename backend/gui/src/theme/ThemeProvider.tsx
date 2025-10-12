import React, { useEffect, useState } from 'react'

const defaultVars = {
  '--bg': '#000000',
  '--bg-2': '#0b0b0b',
  '--fg': '#f5f5f5',
  '--muted': '#bdbdbd',
  '--accent': '#ff1b1b',
  '--accent-2': '#b30f0f',
  '--card': '#0f0f0f'
} as Record<string, string>

const ThemeProvider: React.FC<{ children: React.ReactNode }> = ({ children }) => {
  const [themeVars] = useState(defaultVars)

  useEffect(() => {
    const root = document.documentElement
    Object.entries(themeVars).forEach(([k, v]) => {
      root.style.setProperty(k, v)
    })
  }, [themeVars])

  return <>{children}</>
}

export default ThemeProvider
