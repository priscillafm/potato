import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
import { BrowserRouter } from 'react-router-dom'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import './index.css'
import App from './App.jsx'
import ErrorBoundary from './components/ErrorBoundary'
import { THEME_KEY } from './lib/theme'

// Tema claro por defecto; el oscuro solo si la persona lo eligió (se aplica antes de pintar).
let savedTheme = null
try { savedTheme = localStorage.getItem(THEME_KEY) } catch { /* sin localStorage */ }
document.documentElement.setAttribute('data-theme', savedTheme === 'dark' ? 'dark' : 'light')

// Una pestaña abierta antes de publicar una versión nueva pide archivos que ya no existen.
// Recargamos una sola vez automáticamente; si vuelve a fallar, lo maneja el ErrorBoundary.
const RELOAD_KEY = 'potato-reloaded-for-update'
window.addEventListener('vite:preloadError', (event) => {
  try {
    if (sessionStorage.getItem(RELOAD_KEY) === '1') return
    sessionStorage.setItem(RELOAD_KEY, '1')
  } catch { /* sin sessionStorage: dejamos que lo maneje el ErrorBoundary */ return }
  event.preventDefault()
  window.location.reload()
})
setTimeout(() => { try { sessionStorage.removeItem(RELOAD_KEY) } catch { /* nada */ } }, 10000)

const queryClient = new QueryClient({
  defaultOptions: { queries: { staleTime: 1000 * 60 * 2, retry: 1 } },
})

createRoot(document.getElementById('root')).render(
  <StrictMode>
    <QueryClientProvider client={queryClient}>
      <BrowserRouter>
        <ErrorBoundary>
          <App />
        </ErrorBoundary>
      </BrowserRouter>
    </QueryClientProvider>
  </StrictMode>
)
